#import "@preview/cetz:0.3.4"
#import "@preview/cetz-plot:0.1.1": plot, chart

#let SURNAME_NAME = "Никитин Илья"
#let UNN_GROUP = "3822Б1МА1"
#let n = 21

#let PLOT_SCALE = 8
#set page(
  width: 210mm,
  height: auto,
  margin: (top: 3em, rest: 1cm),
)
#set par(justify: true)
#show table.cell.where(y: 0): strong

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

Рассмотрим краевую задачу для линейного ОДУ 2-го порядка:

#let alpha = (
  math: $e - 1$,
  code: calc.e - 1,
)
#let a = -1
#let b = 0

$
  y'' - y' = 1,
  quad y(#a) = #alpha.math,
  quad y(#b) = 0
$

#let exact(x) = (x + 2 * calc.exp(x + 1) - calc.exp(x + 2) - calc.e * (x + 2) + calc.e * calc.e) / (calc.e - 1)

Аналитическое решение:
$y = e^(-x) - 1$.

#let gamma1 = 0
#let gamma2 = 1

Вместо этой задачи будем решать
две задачи Коши с начальными условиями
$
  y(#a) = #alpha.math, quad y'(#a) = gamma1
  quad "и" quad
  y(#a) = #alpha.math, quad y'(#a) = gamma2.
$

#let N = 10
#let x0 = a
#let h = 1 / N
#let xs = range(N + 1).map(k => x0 + k * h)

Для численного решения задачи Коши
методом конечных разностей
область изменения переменной $x$
разобьём на $\N = #N$ отрезков
с шагом $h = 1 slash \N$, полагая
$x_n = x_0 + n h, n = overline(0\,\N), x_0 = #a$,
значения искомой функции в узлах сетки
обозначим $y_0, y_1, ... , y_\N$.

Составим разностную схему для уравнения
в узлах сетки $x_1, x_N$, используя центральные
разности второго порядка аппроксимации:
$
  (y_(n+1) - 2y_n + y_(n-1)) / h^2
  - (y_(n+1) - y_(n-1)) / (2h)
  = 1
$

Приведём подобные слагаемые:
$
  y_(n+1) (1 / h^2 - 1 / (2h))
  + y_n (-2 / h^2)
  + y_(n-1) (1 / h^2 + 1 / (2h))
  = 1
  , n = overline(1\,N).
$

Для второго начального условия, используя разностное уравнение в точке $x_0$ и условие на производную, получим:
$ y_1 = y_0 + gamma h + (h^2 / 2) (1 + gamma) $

Разностная схема первой задачи Коши:
$
  y_(n+1) (1 / h^2 - 1 / (2h))
  + y_n (-2 / h^2)
  + y_(n-1) (1 / h^2 + 1 / (2h))
  = 1
  , n = overline(1\,N).
  \ y_0 = #alpha.math
  , quad #if gamma1 != 0 {
    $(y_1 - y_0) / h$
  } else {
    $y_1 - y_0$
  } = gamma1.
$

Разностная схема второй задачи Коши:
$
  y_(n+1) (1 / h^2 - 1 / (2h))
  + y_n (-2 / h^2)
  + y_(n-1) (1 / h^2 + 1 / (2h))
  = 1
  , n = overline(1\,N).
  \ y_0 = #alpha.math
  , quad #if gamma2 != 0 {
    $(y_1 - y_0) / h$
  } else {
    $y_1 - y_0$
  } = gamma2.
$

#let solve_cauchy(a, b, h, alpha, gamma) = {
  let N = int((b - a) / h)
  let y1_val = alpha + gamma * h + (h * h / 2) * (1 + gamma)
  let y = (alpha, y1_val)
  let h2 = h * h
  let A = 1 / h2 - 1 / (2 * h)
  let B = -2 / h2
  let C = 1 / h2 + 1 / (2 * h)

  for n in range(1, N) {
    y.push((1 - B * y.at(n) - C * y.at(n - 1)) / A)
  }
  return y
}

#let y1s = solve_cauchy(a, b, h, alpha.code, gamma1)
#let y2s = solve_cauchy(a, b, h, alpha.code, gamma2)

#let y1b = y1s.at(-1)
#let y2b = y2s.at(-1)
#let yb = exact(b)
#let mnum = (yb - y2b) / (y1b - y2b)

#let numerical_points = range(y1s.len()).map(i => mnum * y1s.at(i) + (1 - mnum) * y2s.at(i))

Решаем обе задачи Коши по полученным
рекуррентным соотношениям.
$ mu approx #calc.round(mnum, digits: 15)$.

#let exact1(x) = calc.exp(x + 1) - x + calc.e - 3
#let exact2(x) = 2 * calc.exp(x + 1) - x + calc.e - 4
#let numerical(x) = mnum * exact1(x) + (1 - mnum) * exact2(x)


В таблице приведены результаты расчётов с пятью
знаками после запятой и абсолютные погрешности.
На рисунке приведены графики полученных решений.

#table(
  columns: (auto, auto, 1fr, 1fr, 1fr, 1fr, 1fr),
  align: center + horizon,
  table.header[
    $i$
  ][
    $x$
  ][
    $y^*$
  ][
    $y^(**)$
  ][
    $y$
  ][
    Точное решение
  ][
    $Delta$
  ],
  ..range(N + 1)
    .map(i => (
      i,
      xs.at(i),
      y1s.at(i),
      y2s.at(i),
      numerical_points.at(i),
      exact(xs.at(i)),
      calc.abs(numerical_points.at(i) - exact(xs.at(i))),
    ))
    .flatten()
    .map(x => $#calc.round(x, digits: 13)$)
)

#align(
  center,
  cetz.canvas({
    plot.plot(
      size: (PLOT_SCALE * 2, PLOT_SCALE * 2),
      x-label: $x$,
      x-grid: true,
      y-label: $y$,
      y-grid: true,
      axis-style: "school-book",
      legend: "north",
      {
        plot.add(xs.zip(y1s), domain: (a, b), label: $y^*$)
        plot.add(xs.zip(y2s), domain: (a, b), label: $y^(**)$)
        plot.add(
          xs.zip(numerical_points),
          mark: "o",
          style: (stroke: none),
          label: "Численное решение",
        )
        plot.add(
          exact,
          domain: (a, b),
          style: (
            stroke: (
              paint: green,
              thickness: 0.5mm,
            ),
          ),
          label: "Аналитическое решение",
        )
      },
    )
  }),
)

Погрешность на правом конце:
$|y_("числ")(#b) - y_("точн")(#b)|
= #calc.abs(numerical_points.at(-1) - exact(b))$
