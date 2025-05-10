#import "@preview/cetz:0.3.4"
#import "@preview/cetz-plot:0.1.1": plot, chart
#import "@preview/physica:0.9.5": *


#let SURNAME_NAME = "Никитин Илья"
#let UNN_GROUP = "3822Б1МА1"
#let n = 21


#set page(
  paper: "a4",
  margin: (top: 3em, rest: 0.8cm),
  numbering: "1 / 1",
  header: [
    ДЗ.08. Метод Рунге-Кутты 4 порядка точности для решения ОДУ 1 порядка.
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

#let big(formula) = $lr(#formula, size: #175%)$

//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
=== Задание 1
#let h = $h$

Записать формулы метода РК4 для системы двух уравнений:

$
  cases(
    gap: #8pt,
    y' = p(x, y, z)\, quad &y(x_0) = y_0\;,
    z' = g(x, y, z)\, quad &z(x_0) = z_0.
  )
$

*Решение:*
для каждого шага $x_(n+1) = x_n + h$ метода выпишем коэффициенты $k$:

$
  k_(1y) = p(x_n, y_n, z_n),
  quad &k_(1z) = g(x_n, y_n, z_n);
  \ \
  k_(2y) = p(x_n + #h / 2, y_n + #h / 2 k_(1y), z_n + #h / 2 k_(1z)),
  quad &k_(2z) = g(x_n + #h / 2, y_n + #h / 2 k_(1y), z_n + #h / 2 k_(1z));
  \ \
  k_(3y) = p(x_n + #h / 2, y_n + #h / 2 k_(2y), z_n + #h / 2 k_(2z)),
  quad &k_(3z) = g(x_n + #h / 2, y_n + #h / 2 k_(2y), z_n + #h / 2 k_(2z));
  \ \
  k_(4y) = p big((x_n + #h, y_n + #h k_(3y), z_n + #h k_(3z))),
  quad &k_(4z) = g big((x_n + #h, y_n + #h k_(3y), z_n + #h k_(3z))).
$

#{
  set enum(numbering: it => align(left + horizon, strong[Ответ:]))
  [
    + $
        cases(
          gap: #1em,
          display(y_(n+1) = y_n + #h / 6 (k_(1y) + 2k_(2y) + 2k_(3y) + k_(4y)))\;,
          display(z_(n+1) = z_n + #h / 6 (k_(1z) + 2k_(2z) + 2k_(3z) + k_(4z)))\.
        )
      $
  ]
}

//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
=== Задание 2
#let h = $h$

Записать формулы метода РК4 для системы двух уравнений,
полученной из ОДУ 2-го порядка:

$ y'' = f(x, y, y'), quad y(x_0) = y_00, quad y'(x_0) = y_10 $

*Решение:*
заменим переменные:

$
  z(x) = y'(x) ==> cases(
    gap: #8pt,
    y' = z\;,
    z' = f(x, y, z).
  )
$

для каждого шага $x_(n+1) = x_n + h$ метода выпишем коэффициенты $k$:

$
  k_(1y) = z_n,
  quad &k_(1z) = f(x_n, y_n, z_n);
  \ \
  k_(2y) = z_n + #h / 2 k_(1z),
  quad &k_(2z) = f(x_n + #h / 2, y_n + #h / 2 k_(1y), z_n + #h / 2 k_(1z));
  \ \
  k_(3y) = z_n + #h / 2 k_(2z),
  quad &k_(3z) = f(x_n + #h / 2, y_n + #h / 2 k_(2y), z_n + #h / 2 k_(2z));
  \ \
  k_(4y) = z_n + #h k_(3z),
  quad &k_(4z) = f big((x_n + #h, y_n + #h k_(3y), z_n + #h k_(3z))).
$

#{
  set enum(numbering: it => align(left + horizon, strong[Ответ:]))
  [
    + $
        cases(
          gap: #1em,
          display(y_(n+1) = y_n + #h / 6 (k_(1y) + 2k_(2y) + 2k_(3y) + k_(4y)))\;,
          display(z_(n+1) = z_n + #h / 6 (k_(1z) + 2k_(2z) + 2k_(3z) + k_(4z)))\.
        )
      $
  ]
}
