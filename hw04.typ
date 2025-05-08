#import "@preview/cetz:0.3.4"
#import "@preview/cetz-plot:0.1.1": plot, chart

#let SURNAME_NAME = "Никитин Илья"
#let UNN_GROUP = "3822Б1МА1"
#let n = 21

#set page(
  paper: "a4",
  margin: (top: 3em, rest: 0.8cm),
  numbering: "1 / 1",
  header: [
    ДЗ.04. Численные методы решения нелинейных уравнений.
    #h(1fr)
    #eval(mode: "math", "n = " + repr(n))
    #h(1fr)
    #SURNAME_NAME, #UNN_GROUP
  ],
)
#show heading: it => grid(
  columns: (1fr, auto, 1fr),
  align: horizon + center,
  column-gutter: 5pt,
  line(length: 100%), it.body, line(length: 100%),
)
#set table(
  align: horizon + center,
  stroke: gray + 0.2mm,
)
#set par(justify: true)
#show table.cell.where(x: 0): strong

#let round(x) = calc.round(x, digits: 4)
#let tick-fmt(v) = {
  set text(size: 9pt)
  v
}


//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
#let f(x) = x * x * x - 3 * x * x + 6 * x - 5
#let d1f(x) = 3 * x * x - 6 * x + 6
#let d2f(x) = 6 * x - 6
#let sstring(x: "x") = "calc.root(3*" + str(x) + "*" + str(x) + " - 6*" + str(x) + " + 5, 3)"
#let s(x) = eval(sstring(x: x))
#let evalm(x) = eval(mode: "math", x)
#let xe = 1 - calc.root(2 / (1 + calc.sqrt(5)), 3) + calc.root(1 / 2 * (1 + calc.sqrt(5)), 3)


//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
=== Задание 1
Отделить корни аналитически.
Записать уравнение в виде, удобном для итерации.
Убедиться, что достаточное условие сходимости метода простой итерации выполняется.
В противном случае изменить вид, удобный для итерации.
Выполнить 5 итераций для уточнения корня, взяв в качестве начального
приближения левую или правую границу отрезка.

$
  f(x) = x^3 - 3x^2 + 6x - 5 = 0,
  quad f'(x) = 3x^2 - 6x + 6,
  quad f''(x) = 6x - 6.
$

Один вещественный корень:
$x_0 = 1 - root(3, 2 / (1 + sqrt(5)))
+ root(3, 1 / 2 (1 + sqrt(5)))
approx #xe... thick.$

Запишем уравнение в виде, удобном для итерации:
$ x^"(k+1)" = root(3, 3(x^"(k)")^2 - 6x^"(k)" + 5) =: s(x^"(k)") thick. $

#let (a, b) = (1, 2)

Проверим достаточное условие сходимости на отрезке $[#a, #b]$:
$display(abs(s'(x)) = abs((2(x - 1)) / root(3, 3x^2 - 6x + 5)^2) < 1)$

$
  s''(x)
  = 2 / root(3, 3 x^2 - 6x + 5)^2
  - (4(x - 1)(6x - 6)) / root(3, 3(3x^2 - 6x + 5)^5)
  = 0
  ==> x_(1,2) = 1 plus.minus sqrt(2) - "критические точки" s'(x).
$

$
  s'(1+sqrt(2)) = sqrt(2) / 2 - "точка максимума", quad
  s'(1-sqrt(2)) = -sqrt(2) / 2 - "точка минимума".
$

#let x0 = a
#let x = (x0,)
#let digits = 0
#let error = 5

Достаточное условие сходимости *выполняется*. \
Выберем $x^"(0)" = #a$ и проведём итерации по схеме
$x^"(k+1)" = s(x^"(k)") :$
#{
  for i in range(1, 6) { x.push(s(x.at(i - 1))) }

  $
    x^"(1)" &= root(3, 3-6+5) = root(3, 2) approx #x.at(1) thick, \
    x^"(2)" &= root(3, 3 root(3, 4) - 6 root(3, 2) + 5) approx #x.at(2) thick, \
    x^"(3)" &approx #x.at(3) thick, \
    x^"(4)" &approx #x.at(4) thick, \
    x^"(5)" &approx #x.at(5) thick.
  $

  while calc.abs(x.at(5) - xe) <= error / 10 {
    error /= 10
    digits += 1
  }
}

#let m = calc.min(..(a, b).map(d1f).map(calc.abs).map(round))
#let M = calc.max(..(a, b).map(d2f).map(calc.abs).map(round))
Оценим абсолютную погрешность:
$quad m = min_[#a, #b] abs(f'(x)) approx #m,
quad M = max_[#a, #b] abs(f''(x)) approx #M,$

$
  Delta x_5 <= M / (2 m) (x^"(5)" - x^"(4)")^2
  = #M / #(2 * m) (#x.at(-1) - #x.at(-2))^2
  approx #((M / (2 * m)) * calc.pow(x.at(-1) - x.at(-2), 2)).
$
$
  Delta x^*_5 := abs(x^"(5)" - x^*)
  = abs(round(#x.at(-1))... - xe)
  approx #round(calc.abs(x.at(-1) - xe))
  <= error.
$

*Ответ*: в пятом приближении #digits верных значащих цифры.


//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
#let f(x) = x * x * x + x - 0.5
#let xe = (
  calc.root(9 + calc.sqrt(129), 3) / calc.root(36, 3) - calc.root(4, 3) / calc.root(3 * (9 + calc.sqrt(129)), 3)
)

=== Задание 2\*
Исследовать возможность решения методом простой итерации уравнения
$ f(x) = x^3 + x - 0.5 = 0. $

Один вещественный корень:
$
  x_0 = root(3, 9 + sqrt(129)) / root(3, 36) - root(3, 4) / root(3, 3 (9 + sqrt(129)))
  approx #xe... thick.
$

#let (a, b) = (0, 1)

#set enum(numbering: it => strong[#numbering("a)", it)])

+ #box(stroke: gray, radius: 5pt, inset: 8pt, width: 1fr)[
    Запишем уравнение для итераций в виде:
    $x^"(k+1)" = 0.5 - (x^"(k)")^3 =: g(x^"(k)") thick.$

    Проверим достаточное условие сходимости на отрезке $[#a, #b]$:
    $display(abs(g'(x)) = abs(-3x^2) < 1).$

    $
      g'(x) "монотонна" quad ==> quad
      g'(0) = 0 - "точка максимума", quad
      g'(1) = -3 - "точка минимума".
    $

    Достаточное условие сходимости *не выполняется*.
  ]
+ #box(stroke: gray, radius: 5pt, inset: 8pt, width: 1fr)[
    Запишем уравнение для итераций в виде:
    $x^"(k+1)" = root(3, 0.5 - x^"(k)") =: g(x^"(k)") thick.$

    Проверим достаточное условие сходимости на отрезке $[#a, #b]$:
    $display(abs(g'(x)) = abs((-1 slash 3) / (x - 0.5)^(2 / 3)) < 1).$

    $
      x = 0.5 - "критическая точка", quad
      lim_(x -> 0.5 plus.minus epsilon) g'(x) = -infinity.
    $

    Достаточное условие сходимости *не выполняется*.
  ]

#let xk = $x^"(k)"$
#let gl = $g_lambda$

Рассмотрим следующий вид уравнения, удобный для итерации:
$
  x^"(k+1)" = xk + lambda(xk^3 + xk - 0.5)
  = xk + lambda f(xk)
  =: gl(xk) thick.
$

Определим условие оптимальной сходимости МПИ в зависимости от параметра $lambda$.
#let ek = $Delta_k$
#let ekp1 = $Delta_(k+1)$

Обозначим $ek := xk - x_0$, штрихом же будем
обозначать производную по переменной, не по $lambda$.

При малых $ek$ рассмотрим разложение в ряд Тейлора:

$
  gl(x_0 + ek) &= gl(x_0) + gl'(x_0) ek + 1 / 2 gl''(x_0) ek^2 + ... thick, \
  x^"(k+1)" &= x_0 + gl'(x_0) ek + 1 / 2 gl''(x_0) ek^2+ ... thick, \
  ekp1 &= gl'(x_0) ek + 1 / 2 gl''(x_0) ek^2 + ... thick.
$

#align(center)[
  При $k -> infinity: quad ek -> 0 quad
  ==> quad ekp1 approx gl'(x_0) ek quad
  ==> quad abs(ekp1) approx abs(gl'(x_0)) abs(ek) quad
  ==> quad frac(abs(ekp1), abs(ek)) approx |gl'(x_0)|$.
]
Для сходимости достаточно $|gl'(x_0)| < 1$,
а чем меньше $|gl'(x_0)|$, тем быстрее сходится метод.

Идеальный случай:
$quad gl'(x_0) = 1 + lambda f'(x_0) = 0, quad "где" quad f'(x) = 3 x^2 + 1.$

#let x0 = a

Вычислим $lambda$:
#let lam = -1 / (3 * xe * xe + 1)
$
  gl'(x_0) = 1 + lambda (3 x_0^2 + 1) = 0 quad
  ==> quad hat(lambda) = -1 / (3 x_0^2 + 1) approx lam.
$
Проведём итерации по схеме $x^"(k+1)" = g_hat(lambda)(xk)$, приняв $x^"(0)" = x0$:

#let gstring = "x + (" + str(lam) + ") * (x*x*x + x - 0.5)"
#let x = (x0,)
#let digits = 0
#let error = 5
#let cols = 2

#columns(
  3,
  align(
    center,
    {
      for i in range(1, 10) {
        x.push(eval(gstring.replace("x", str(x.at(i - 1)))))
        eval(mode: "math", "x^\"(" + str(i) + ")\" approx " + str(x.at(i)))
        parbreak()
        if calc.rem(i, 3) == 0 { colbreak() }
      }
    },
  ),
)

#{
  while calc.abs(x.at(-1) - xe) <= error {
    error /= 10
    digits += 1
  }
  error *= 10
  digits -= 1
}

#let cnt = x.len() - 1
Оценим абсолютную погрешность:
$
  Delta^("("#cnt")") &:= abs(x^("("#cnt")") - x_0)
  = abs(#x.at(-1)... - xe...) = \
  &= #calc.abs(x.at(-1) - xe)...
  <= #error thick.
$

#set enum(numbering: it => strong[Ответ:])
+ Оптимальное значение $hat(lambda) approx #lam$. \
  В приближении $x^("("#cnt")")$ по схеме $x^"(k+1)" = g_hat(lambda)(xk)$
  всего #digits верных значащих цифр.

