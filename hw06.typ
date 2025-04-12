#import "@preview/cetz:0.3.4"
#import "@preview/cetz-plot:0.1.1": plot, chart
#import "@preview/diverential:0.2.0": *


#let SURNAME_NAME = "Никитин Илья"
#let UNN_GROUP = "3822Б1МА1"
#let n = 21


#set page(
  paper: "a4",
  margin: (top: 3em, rest: 0.8cm),
  numbering: "1 / 1",
  header: [
    ДЗ.06. М. Эйлера и его модификации решения з. Коши для ОДУ 1 порядка.
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
  line(length: 100%),
  it.body,
  line(length: 100%),
)
#set table(
  align: horizon + center,
  stroke: gray + 0.2mm,
)
#set par(justify: true)

#let round(x) = calc.round(x, digits: 4)
#let tick-fmt(v) = { set text(size: 9pt); v }


//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
=== Задание 1
#let ITERATIONS = 2
#let PREC = 10
#let f(x, y) = y - x
#let x0 = 0
#let xend = 0.2
#let y0 = n + 4
#let h = 0.1

#let plot-comparison(plot-block, y-step: 1) = cetz.canvas({
  import plot: *
  cetz.draw.set-style(axes: (
    stroke: (dash: "dotted", paint: gray),
    tick: (stroke: gray + .5pt),
  ))
  plot(
    size: (7, 3),
    x-grid: true,
    x-label: $x$,
    x-tick-step: h / 2,
    y-grid: true,
    y-label: none,
    y-tick-step: y-step,
    mark: "o",
    axis-style: "school-book",
    // y-min: 0,
    // y-max: 0.3,
    // x-format: tick-fmt,
    // y-format: tick-fmt,
    // y-equal: "x",
    // y-mode: "log",
    // y-base: 10,
    // x-mode: "log",
    // x-base: 2000,
    plot-block
  )
})

Вычислить методом Эйлера и его модификациями приближение к $y(xend)$.
Выполнив 2 шага, найти абсолютную погрешность решения для каждого метода.
Сравнить и объяснить полученный результат.
Почему совпали приближения по первой и второй модификациям метода Эйлера?

$ y' = y - x, quad
  y(0) = n + 4 = y0, quad
  h = #h thin. $

$ (Delta y) / (Delta x) = f(x, y), quad
  Delta y = y(x + h) - y(x), quad
  Delta x = (x + h) - x = h thin. $

  
Решим аналитически с помощью интегрирующего множителя $mu(x)$:
$ dv(y, x) = y - x quad <==>
quad dv(y, x) + P(x) y = Q(x),
quad "где" thick P(x) = -1, thick Q(x) = -x. $

$ mu(x) = e^(integral_0^x P(t) dif t) = e^(- integral_0^x dif t) = e^(-x), $

$ e^(-x) dv(y, x) - e^(-x) y = -e^(-x) x quad <==>
quad dv(e^(-x) y, x) = - e^(-x) x quad <==>
quad e^(-x) y = - integral e^(-x) x dif x, $

$ integral e^(-x) x dif x = lr(|#table(
  columns: 2, rows: 2, stroke: none,
  $u = x$, $dif v = e^(-x) dif x$,
  $dif u = dif x$, $v = - e^(-x)$
)|) = -x e^(-x) + integral e^(-x) dif x
    = -x e^(-x) - e^(-x) + C thick ==> thick
  y(x) = x + 1 + C e^x. $

$ y(0) = 1 + C e^0 = 25 quad ==>
quad C = 24, quad y(x) = x + 1 + 24 e^x. $

#let yexact(x) = x + 1 + 24 * calc.exp(x)

Решим классическим методом Эйлера:
$quad x_k = x_0 + h k,
quad y_(k + 1) = y_k + h f(x_k, y_k). $

#let x = range(ITERATIONS + 1).map(k => x0 + k * h)
#let y = (y0,)
#for k in range(ITERATIONS) {
  y.push(y.at(k) + h * f(x.at(k), y.at(k)))
}

#columns(2, {
  show table.cell.where(y: 0): strong
  align(center)[
    #v(1.8em)
    #table(
      inset: 0.5em,
      columns: 5,
      table.header[$k$][$x_k$][$y_k$][$y^*_k$][$Delta_k$],
      ..range(x.len())
       .map(k => (
           k,
           x.at(k),
           y.at(k),
           x.map(yexact).at(k),
           calc.abs(y.at(k) - yexact(x.at(k)))
         )
         .map(a => $#calc.round(a, digits: PREC)$)
       )
       .flatten()
    )
  ]
  colbreak()
  align(center, plot-comparison({
    plot.add(yexact, domain: (0, h * ITERATIONS))
    plot.add(
      x.zip(y),
      mark: "o",
      mark-size: 0.1,
      mark-style: (stroke: none, fill: black),
    )
  }))
})
  
#let error-classic = calc.abs(y.at(-1) - yexact(x.at(-1)))


Решим 1-й модификацией метода:
$quad x_(k + 1/2) = x_0 + h/2 k,
quad y_(k + 1/2) = y_k + h/2 f(x_k, y_k),
quad y_(k + 1) = y_k + h f(x_(k + 1/2), y_(k + 1/2)). $

#let x = range(ITERATIONS + 1).map(k => x0 + h * k)
#let x2 = range(ITERATIONS + 1).map(k => x.at(k) + 1/2 * h)
#let y = (y0,)
#let y2 = ()
#for k in range(ITERATIONS + 1) {
  y2.push(y.at(k) + h/2 * f(x.at(k), y.at(k)))
  y.push(y.at(k) + h * f(x2.at(k), y2.at(k)))
}

#columns(2, {
  show table.cell.where(y: 0): strong
  align(center)[
    #v(1.8em)
    #table(
      inset: 0.5em,
      columns: 7,
      table.header[$k$][$x_k$][$x_(k+1/2)$][$y_(k+1/2)$][$y_k$][$y^*_k$][$Delta_k$],
      ..range(x.len())
       .map(k => (
           k,
           x.at(k),
           x2.at(k),
           y2.at(k),
           y.at(k),
           x.map(yexact).at(k),
           calc.abs(y.at(k) - yexact(x.at(k)))
         )
         .map(a => $#calc.round(a, digits: 5)$)
       )
       .flatten()
    )
  ]
  colbreak()
  align(center, plot-comparison({
    plot.add(yexact, domain: (0, h * ITERATIONS))
    plot.add(
      x.zip(y),
      mark: "o",
      mark-size: 0.1,
      mark-style: (stroke: none, fill: black),
    )
  }))
})

#let error-mod-1 = calc.abs(y.at(-2) - yexact(x.at(-1)))


Решим 2-й модификацией метода:
$quad y_(k + 1) = y_k + h/2 (f(x_k, y_k) + f(x_(k+1), y_k + h f(x_k, y_k))). $

#let x = range(ITERATIONS + 1).map(k => x0 + k * h)
#let y = (y0,)
#for k in range(ITERATIONS) {
  y.push(y.at(k) + h/2 * (
    f(x.at(k), y.at(k)) +
    f(x.at(k + 1), y.at(k) + h * f(x.at(k), y.at(k)))
  ))
}

#columns(2, {
  show table.cell.where(y: 0): strong
  align(center)[
    #v(1.8em)
    #table(
      inset: 0.5em,
      columns: 5,
      table.header[$k$][$x_k$][$y_k$][$y^*_k$][$Delta_k$],
      ..range(x.len())
       .map(k => (
           k,
           x.at(k),
           y.at(k),
           x.map(yexact).at(k),
           calc.abs(y.at(k) - yexact(x.at(k)))
         )
         .map(a => $calc.round(#a, digits: PREC)$)
       )
       .flatten()
    )
  ]
  colbreak()
  align(center, plot-comparison({
    plot.add(yexact, domain: (0, h * ITERATIONS))
    plot.add(
      x.zip(y),
      mark: "o",
      mark-size: 0.1,
      mark-style: (stroke: none, fill: black),
    )
  }))
})

#let error-mod-2 = calc.abs(y.at(-1) - yexact(x.at(-1)))


#pagebreak()
Обоснуем эквивалентность приближений по первой и второй модификациям метода Эйлера. \
Разложим точное решение в ряд Тейлора:
$  y(x_k + h) &= y(x_k)
               + h y'(x_k)
               + frac(h^2, 2) y'' (x_k)
               + frac(h^3, 6) y''' (x_k)
               + O(h^4) ==> \
==> y_(k + 1) &= y_k
               + h f(x_k, y_k)
               + frac(h^2, 2) y'' (x_k, y_k)
               + frac(h^3, 6) y''' (x_k, y_k)
               + O(h^4),
$
$ y' = y - x, quad y'' = y - x - 1, quad y''' = y - x - 1, ... $

Подставим точное решение в первую модификацию метода:
$ f(x_k + h/2, y_k + h/2 f(x_k, y_k))
= (y_k + h/2 (y_k - x_k)) - (x_k + h/2)
= (y_k - x_k) + h/2 (y_k - x_k - 1), \
quad y_(k+1)
= y_k + h [(y_k - x_k) + h/2 (y_k - x_k - 1)]
= y_k + h(y_k - x_k) + h^2 / 2 (y_k - x_k - 1). $

Подставим точное решение во вторую модификацию метода:
$ f(x_k, y_k) + f(x_(k + 1), y_k + h f(x_k, y_k))
= [y_k - x_k] + [(y_k + h[y_k - x_k]) - x_(k + 1)]
= 2[y_k - x_k] + [h[y_k - x_k] - h] = \
= 2[y_k - x_k] + h[y_k - x_k - 1], \
quad y_(k+1)
= y_k + h/2 [2[y_k - x_k] + h[y_k - x_k - 1]]
= y_k + h(y_k - x_k) + h^2 / 2 (y_k - x_k - 1). $

Формулы обеих модификаций для точного решения дают эквивалентную локальную (шаговую) погрешность
$Delta_#[_лок_] = O(h^3)$, а это значит, что глобальная погрешность для них $Delta_#[_гл_] = O(h^2)$,
и оба метода имеют порядок $O(h^2)$.
Для частного случая $y = x + 1 + 24 e^x$ погрешности методов совпадают.

#set enum(numbering: it => strong[Ответ:])
+ Погрешность для классического метода: $Delta_2 approx #calc.round(error-classic, digits: PREC)$, \
  для первой и второй модификаций: $Delta_2 approx #calc.round(error-mod-1, digits: PREC)$. \


//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

=== Задание 2\*
Вычислить методом Эйлера и его модификациями приближение к $y(0.3)$.
Вычисления выполнять с четырьмя десятичными знаками.
Сравнить и объяснить результат.
Совпадут ли приближения по модификациям метода?

#let ITERATIONS = 1
#let PREC = 4
#let gam = calc.round((2 * (n + 4) / (n + 8)), digits: PREC)
#let f(x, y) = 0.133 * (x * x + calc.sin(gam * x)) + 0.872 * y
#let h = 0.1
#let c1 = 4.86804
#let yexact(x) = (
  - (133 * x * x) / 872
  - (16625 * x) / 47524
  - (57323 * calc.cos((431 * x) / 250)) / 933140
  - (14497 * calc.sin((431 * x) / 250)) / 466570
  + c1 * calc.exp((109 * x) / 125) - 2078125 / 5180116
)
#let x0 = 0.2
#let y02 = calc.round(yexact(0.2), digits: PREC)
#assert.eq(y02, 5.25)

$ dv(y, x) = 0.133 (x^2 + sin(gamma x)) + 0.872 y,
quad y(0.2) = n / 4 = #(n / 4),
quad h = #h,
quad gamma = (2(n + 4))/(n + 8) approx #gam. $


Решим классическим методом Эйлера:
$quad x_k = x_0 + h k,
quad y_(k + 1) = y_k + h f(x_k, y_k). $

#let x = range(ITERATIONS + 1).map(k => calc.round(x0 + k * h, digits: PREC))
#let y = (y02,)
#for k in range(ITERATIONS) {
  y.push(calc.round(y.at(k) + h * f(x.at(k), y.at(k)), digits: PREC))
}

#columns(2, {
  show table.cell.where(y: 0): strong
  align(center)[
    #v(1.8em)
    #table(
      inset: 0.5em,
      columns: 5,
      table.header[$k$][$x_k$][$y_k$][$y^*_k$][$Delta_k$],
      ..range(x.len())
       .map(k => (
           k,
           x.at(k),
           y.at(k),
           x.map(yexact).at(k),
           calc.abs(y.at(k) - yexact(x.at(k)))
         )
         .map(a => $calc.round(#a, digits: PREC)$)
       )
       .flatten()
    )
  ]
  colbreak()
    align(center, plot-comparison({
      plot.add(yexact, domain: (0.2, 0.2 + h * ITERATIONS))
      plot.add(
        x.zip(y),
        mark: "o",
        mark-size: 0.1,
        mark-style: (stroke: none, fill: black),
      )
    }, y-step: 0.05))
})
  
#let error-classic = calc.abs(y.at(-1) - yexact(x.at(-1)))


Решим 1-й модификацией метода:
$quad x_(k + 1/2) = x_0 + h/2 k,
quad y_(k + 1/2) = y_k + h/2 f(x_k, y_k),
quad y_(k + 1) = y_k + h f(x_(k + 1/2), y_(k + 1/2)). $

#let x = range(ITERATIONS + 1).map(k => calc.round(x0 + h * k, digits: PREC))
#let x2 = range(ITERATIONS + 1).map(k => x.at(k) + 1/2 * h)
#let y = (y02,)
#let y2 = ()
#for k in range(ITERATIONS + 1) {
  y2.push(y.at(k) + h/2 * f(x.at(k), y.at(k)))
  y.push(calc.round(y.at(k) + h * f(x2.at(k), y2.at(k)), digits: PREC))
}

#columns(2, {
  show table.cell.where(y: 0): strong
  align(center)[
    #v(1.8em)
    #table(
      inset: 0.5em,
      columns: 7,
      table.header[$k$][$x_k$][$x_(k+1/2)$][$y_(k+1/2)$][$y_k$][$y^*_k$][$Delta_k$],
      ..range(x.len())
       .map(k => (
           k,
           x.at(k),
           x2.at(k),
           y2.at(k),
           y.at(k),
           x.map(yexact).at(k),
           calc.abs(y.at(k) - yexact(x.at(k)))
         )
         .map(a => $calc.round(#a, digits: PREC)$)
       )
       .flatten()
    )
  ]
  colbreak()
  align(center, plot-comparison({
    plot.add(yexact, domain: (x0, x0 + h * ITERATIONS))
    plot.add(
      x.zip(y),
      mark: "o",
      mark-size: 0.1,
      mark-style: (stroke: none, fill: black),
    )
  }, y-step: 0.05))
})

#let error-mod-1 = calc.abs(y.at(1) - yexact(x.at(1)))


Решим 2-й модификацией метода:
$quad y_(k + 1) = y_k + h/2 (f(x_k, y_k) + f(x_(k+1), y_k + h f(x_k, y_k))). $

#let x = range(ITERATIONS + 1).map(k => calc.round(x0 + k * h, digits: PREC))
#let y = (y02,)
#for k in range(ITERATIONS) {
  y.push(y.at(k) + h/2 * (
    f(x.at(k), y.at(k)) +
    f(x.at(k + 1), y.at(k) + h * f(x.at(k), y.at(k)))
  ))
}

#columns(2, {
  show table.cell.where(y: 0): strong
  align(center)[
    #v(1.8em)
    #table(
      inset: 0.5em,
      columns: 5,
      table.header[$k$][$x_k$][$y_k$][$y^*_k$][$Delta_k$],
      ..range(x.len())
       .map(k => (
           k,
           x.at(k),
           y.at(k),
           x.map(yexact).at(k),
           calc.abs(y.at(k) - yexact(x.at(k)))
         )
         .map(a => $calc.round(#a, digits: PREC)$)
       )
       .flatten()
    )
  ]
  colbreak()
  align(center, plot-comparison({
    plot.add(yexact, domain: (x0, x0 + h * ITERATIONS))
    plot.add(
      x.zip(y),
      mark: "o",
      mark-size: 0.1,
      mark-style: (stroke: none, fill: black),
    )
  }, y-step: 50))
})

#let error-mod-2 = calc.abs(y.at(1) - yexact(x.at(1)))

#let hl(eqtn) = rect(stroke: gray, inset: (top: 10pt, bottom: 10pt), $display(eqtn.body)$)

Разложим точное решение в ряд Тейлора:
$   y'' = f_x + f_y y' = f_x + f_y f, \
   y''' = f_(x x) + f_(x y) y' + (f_(y x) + f_(y y) y') f + f_y (f_x + f_y f)
        = f_(x x) + 2f_(x y) f + f_(y y) f^2 + f_y (f_x + f_y f), \
 y(x+h) = y(x)
        + h f
        + h^2/2 (f_x + f_y f)
        + h^3/6 (f_(x x) + 2f_(x y) f + f_(y y) f^2 + f_y (f_x + f_y f))
        + O(h^4). $

Разложим $f$ в решении первым методом:
$ f(x_k + h/2, y_k + h/2 f(x_k, y_k)) = \
= f
+ h/2 (f_x + f_y f)
+ h^2/8 (f_(x x) + 2 f_(x y) f + f_(y y) f^2)
+ h^3/48 (f_(x x x) + 3 f_(x x y) f + 3 f_(x y y) f^2 + f_(y y y) f^3)
+ O(h^4)
==> \ ==> y_(k+1)
= y_k + h ( f + h/2 (...) + h^2/8 (...) + h^3/48 (...) + O(h^4) )
= y_k + h f + h^2/2 (...) + #hl($h^3/8$) (...) + #hl($h^4/48$) (...) + O(h^5).
$

Разложим $f$ в решении вторым методом:
$ f(x_k, y_k) + f(x_k + h, y_k + h f(x_k, y_k)) = \
= 2f
+ h (f_x + f_y f)
+ h^2/2 (f_(x x) + 2 f_(x y) f + f_(y y) f^2)
+ h^3/6 (f_(x x x) + 3 f_(x x y) f + 3 f_(x y y) f^2 + f_(y y y) f^3)
+ O(h^4)
==> \ ==> y_(k+1)
= y_k + h/2( 2f + h (...) + h^2/2 (...) + h^3/6 (...) + O(h^4) )
= y_k + h f + h^2/2 (...) + #hl($h^3/4$) (...) + #hl($h^4/12$) (...) + O(h^5).
$

#let dxxf(x, y) = 0.266 - 0.133 * calc.pow(gam, 2) * calc.sin(gam * x)
#let dxxxf(x, y) = -0.133 * calc.pow(gam, 3) * calc.cos(gam * x)
#let dxyf(x, y) = 0
#let dyyf(x, y) = 0
#let dxxxf-max-x = 250 * calc.pi / 431

Оценим разницу погрешностей первой и второй модификаций с точностью до $O(h^5)$:
$    f_(x x) = 0.266 - 0.133 gamma^2 sin(gamma x),
quad f_(x x x) = -0.133 gamma^3 cos(gamma x),
quad f_(x y) = f_(y y) = f_(x x y) = f_(x y y) = f_(y y y) = 0. $

$  abs(h^3/8 f_(x x) + (3h^4)/48 f_(x x x))
 = abs(f_(x x) / (8 dot 10^3) + (3 f_(x x x)) / (48 dot 10^4))
<= (0.266 + 0.133 gamma^2) / (8 dot 10^3) + (3 dot 0.133 gamma^3) / (48 dot 10^4)
 = #calc.abs((dxxf((3*calc.pi)/(2*gam), 0) / (8*calc.pow(10, 3))) + (dxxxf(calc.pi/gam, 0) / (48 * calc.pow(10, 4)))), $
что близко, но всё же меньше, чем $10^(-4)$.
А значит, разница между методами может и не быть отражена при точности в 4 десятичных знака.

#align(center, table(
  stroke: none,
  rows: 2,
  columns: (auto, auto, auto, auto),
  table.header[№ мод.][$Delta$],
  $1$, $#error-mod-1$,
  table.cell(rowspan: 2, inset: 0pt)[#text(size: 35pt, baseline: -1.6pt)[$}$]],
  table.cell(rowspan: 2, align: left+horizon)[
    $ ==> Delta_(1,2) = #calc.abs(error-mod-1 - error-mod-2).$
  ],
  $2$, $#error-mod-2$,
))

#set enum(numbering: it => strong[Ответ:])
+ Погрешность для классического метода: $Delta_1 approx #calc.round(error-classic, digits: PREC)$, \
  для первой и второй модификаций: $Delta_1 approx #calc.round(error-mod-1, digits: PREC)$. \
