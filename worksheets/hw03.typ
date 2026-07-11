#import "../src/lib.typ": *
#import "../src/theme.typ": theme

#let SURNAME_NAME = "Никитин Илья"
#let UNN_GROUP = "3822Б1МА1"
#let n = 21

#set page(
  fill: theme.bg,
  paper: "a4",
  margin: (top: 3em, bottom: 1cm, rest: 0.5cm),
  numbering: "1 / 1",
  header: [
    ДЗ.03. Численные методы решения нелинейных уравнений.
    #h(1fr)
    #eval(mode: "math", "n = " + repr(n))
    #h(1fr)
    #SURNAME_NAME, #UNN_GROUP
  ],
)
#set text(fill: theme.text)
#set par(justify: true)

#show heading: it => grid(
  columns: (1fr, auto, 1fr),
  align: horizon + center,
  column-gutter: 5pt,
  line(length: 100%, stroke: theme.stroke), it.body, line(length: 100%, stroke: theme.stroke),
)

//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
=== Задание 1
Отделить корни аналитически. Проверить условия применимости метода Ньютона к решению уравнения на отрезке. Выполнить 5
итераций для уточнения корня, взяв в качестве начального приближения левую или правую границу отрезка, оценить
погрешность. Выяснить количество верных значащих цифр в приближённом решении.

#let f = from-math($f(x) = x^3 - 3 x^2 + 6 x - 5$)
#let df = d(f, "x")
#let d2f = d(df, "x")

$
  f(x) = #render(f) = 0,
  quad f'(x) = #render(df),
  quad f''(x) = #render(d2f).
$

$
  f(x) = 0 ==>
  x_0 = 1 - root(3, 2 / (1 + sqrt(5)))
  + root(3, 1 / 2 (1 + sqrt(5))) in RR.
$

//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
#let (a, b) = (1, 2)
#let fourier = fourier-condition(f, a, b, x-tick-step: 0.1, y-tick-step: 1)

Проверим условие Фурье на отрезке $[#a, #b]$ *для $x_0$:* \
#fourier.content

Условие #if fourier.ok [*выполняется*] else [*не выполняется*]
(в левой границе $f'' = 0$, знак $f''$ постоянен нестрого). Возьмём в качестве начального приближения
$#iter-sym("x", 0) = #a$. Проведём итерации по схеме
$#iter-sym("x", "k+1") = #iter-sym("x", "k") - frac(f(#iter-sym("x", "k")), f'(#iter-sym("x", "k"))) :$

#let newton = newton-history(f, a, iterations: 5, df: df)
#show-newton-iterations(f, newton.history, df: df)

//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
#let err = newton-error(f, a, b, newton.history, max-digits: 30)

Оценим погрешность:
$m = min_[#a, #b] abs(f'(x)) = #str(err.m),
quad M = max_[#a, #b] abs(f''(x)) = #str(err.em).$

$
    Delta x_5 & <= M / (2 m) abs(#iter-sym("x", 5) - #iter-sym("x", 4))^2
                = #str(err.em) / #str(2 * err.m) abs(#iter-sym("x", 5) - #iter-sym("x", 4))^2
                approx #render-sci(err.delta), \
  Delta x^*_5 & := abs(#iter-sym("x", 5) - x^*)
                approx #render-sci(calc.abs(mpq-to-float(mpq.sub(newton.history.last(), err.reference)))).
$

*Ответ*: в пятом приближении не менее #err.digits верных значащих цифр (сравнение с уточнённым корнем упирается в окно
сравнения), $Delta <= 5 dot 10^(-#str(err.digits))$.
