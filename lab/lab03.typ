#import "@preview/cetz:0.3.4"
#import "@preview/cetz-plot:0.1.1": plot, chart
#import "@preview/physica:0.9.5": dv

#let SURNAME_NAME = "Никитин Илья"
#let UNN_GROUP = "3822Б1МА1"

/// Номер варианта
#let n = 21

/// Выбор alpha для метода Рунге-Кутты 2-го порядка
/// Если не выбран, то для каждого уравнения автоматически
/// будет найден и выбран оптимальный коэффициент alpha.
/// Если он есть в таблице, то он будет выделен зеленым.
#let chosen-alpha = none // Например, напишите 0.5 вместо none

#let ALPHA-VALUES = range(51, step: 5).map(x => calc.exp(0.1 * x)).slice(1)
// #let ALPHA-VALUES = range(-2, 100 + 1, step: 3).map(x => calc.exp(0.01 * x) - 1).slice(1)
// #let ALPHA-VALUES = (1,)

/// Конец отрезка интегрирования
#let X = 2

/// Шаги
#let STEPS = (5, 10, 20, 40)

// Функции

/// Первое уравнение: y' = y - x, y(0) = n + 4
#let f1(x, y) = y - x

/// Точное решение для первого уравнения
#let exact1(x, y0) = (y0 - 1) * calc.exp(x) + x + 1

/// Второе уравнение: y' = y - 2x/y, y(0) = n + 4
#let f2(x, y) = y - (2 * x / y)

/// Точное решение для второго уравнения
#let exact2(x, y0) = calc.sqrt((y0 * y0 - 1) * calc.exp(2 * x) + 2 * x + 1)


#let riccati(x, y) = x * x + y * y

#let abel(x, y) = y * y * y + x

/// Метод Эйлера
#let euler(f, x0, y0, h, n) = {
  let x = x0
  let y = y0
  let points = ((x, y),)
  for i in range(0, n) {
    y += h * f(x, y)
    x = calc.round(x + h, digits: 10)
    points.push((x, y))
  }
  (y, points)
}

/// Первая модификация метода Эйлера
#let euler-mod1(f, x0, y0, h, n) = {
  let x = x0
  let y = y0
  let points = ((x, y),)
  for i in range(0, n) {
    let y2 = y + h / 2 * f(x, y)
    y += h * f(x + h / 2, y2)
    x = calc.round(x + h, digits: 10)
    points.push((x, y))
  }
  (y, points)
}

/// Вторая модификация метода Эйлера
#let euler-mod2(f, x0, y0, h, n) = {
  let x = x0
  let y = y0
  let points = ((x, y),)
  for i in range(0, n) {
    let k1 = f(x, y)
    let k2 = f(x + h, y + h * k1)
    y += h * (k1 + k2) / 2
    x = calc.round(x + h, digits: 10)
    points.push((x, y))
  }
  (y, points)
}

/// Метод Рунге-Кутты 2-го порядка с параметром alpha
/// y_(n+1) = y_n
///         + (h * (1 - 1 / (2 * alpha) * f(x_n, y_n)
///         + 1 / (2 * alpha) * f(
///             x_n + alpha * h,
///             y_n + alpha * h * f(x_n, y_n)
///         ))
#let runge-kutta-2(f, x0, y0, h, n, alpha) = {
  let x = x0
  let y = y0
  let points = ((x, y),)
  let beta = 1.0 / (2.0 * alpha)
  for i in range(0, n) {
    let k1 = f(x, y)
    let k2 = f(x + alpha * h, y + alpha * h * k1)
    y += h * ((1 - beta) * k1 + beta * k2)
    x = calc.round(x + h, digits: 10)
    points.push((x, y))
  }
  (y, points)
}

/// Метод Рунге-Кутты 4-го порядка (для эталонного решения)
/// y_(n+1) = y_n + h/6 * (k1 + 2k2 + 2k3 + k4)
/// где:
/// k1 = f(x_n, y_n)
/// k2 = f(x_n + h/2, y_n + h/2 * k1)
/// k3 = f(x_n + h/2, y_n + h/2 * k2)
/// k4 = f(x_n + h, y_n + h * k3)
#let runge-kutta-4(f, x0, y0, h, n) = {
  let x = x0
  let y = y0
  let points = ((x, y),)
  for i in range(0, n) {
    let k1 = f(x, y)
    let k2 = f(x + h / 2, y + h / 2 * k1)
    let k3 = f(x + h / 2, y + h / 2 * k2)
    let k4 = f(x + h, y + h * k3)
    y += h / 6 * (k1 + 2 * k2 + 2 * k3 + k4)
    x = calc.round(x + h, digits: 10)
    points.push((x, y))
  }
  (y, points)
}



////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

#let PLOT_SCALE = 8
#let COLORS = (
  rgb(200, 0, 0),
  rgb(150, 0, 150),
  rgb(50, 50, 200),
  rgb(0, 180, 180),
  rgb(0, 200, 0),
)
#let double-line = block(width: 100%)[
  #block(spacing: 0pt, line(length: 100%))
  #v(2.5pt)
  #block(spacing: 0pt, line(length: 100%))
]
#set page(width: 420mm, height: auto, margin: 0.5cm, columns: 4)
#set columns(gutter: 0.5cm)
#set par(justify: true)
#show heading: it => grid(
  columns: (1fr, auto, 1fr),
  align: horizon + center,
  column-gutter: 5pt,
  double-line, it.body, double-line,
)
#let tick-fmt(v) = {
  set text(size: 10pt)
  calc.round(v, digits: 10)
}

/// Отрисовка графиков
#let show-plot(points, exact-fn, title, x-label: $x$, y-label: $y$, scale: (PLOT_SCALE, PLOT_SCALE)) = {
  let x-points = points.map(p => p.map(((x, y)) => x)).flatten()
  let min-x = calc.min(..x-points)
  let max-x = calc.max(..x-points)

  if points.len() > 4 {
    points = points.dedup()
  }

  align(
    center,
    [
      *#title*
      #cetz.canvas({
        cetz.draw.set-style(
          axes: (
            stroke: (paint: gray, dash: "solid", thickness: 0.1mm),
            tick: (stroke: gray + .5pt),
          ),
        )
        plot.plot(
          name: "method-plot",
          size: scale,
          x-label: x-label,
          y-label: y-label,
          axis-style: "school-book",
          x-format: tick-fmt,
          y-format: tick-fmt,
          {
            // Рисуем точное решение (если оно есть)
            if exact-fn != none {
              plot.add(
                exact-fn,
                domain: (min-x, max-x),
                style: (stroke: (thickness: 0.1mm)),
              )
            }
            for (i, points) in points.rev().enumerate() {
              // Методы в обратном порядке, чтобы улучшить читаемость
              plot.add(
                points,
                mark: "o",
                mark-size: 0.015 * i,
                mark-style: (
                  stroke: COLORS.at(calc.min(i, COLORS.len() - 1)),
                ),
                style: (
                  stroke: (
                    paint: COLORS.at(calc.min(i, COLORS.len() - 1)),
                    dash: "dashed",
                    thickness: 0.1mm,
                  ),
                ),
              )
            }
          },
        )
      })
    ],
  )
}

/// Отрисовка графика зависимости погрешности от шага
#let show-error-plot(h-values, errors, title, x-label: $h$, scale: (PLOT_SCALE, PLOT_SCALE)) = {
  let h-max = calc.max(..h-values)
  let h-min = calc.min(..h-values)
  align(
    center,
    [
      *#title*
      #cetz.canvas({
        cetz.draw.set-style(
          axes: (
            stroke: (paint: gray, dash: "solid", thickness: 0.1mm),
            tick: (stroke: gray + .5pt),
          ),
        )
        plot.plot(
          size: scale,
          x-label: x-label,
          y-label: $Delta$,
          axis-style: "school-book",
          x-format: tick-fmt,
          y-format: tick-fmt,
          {
            plot.add(
              h-values.zip(errors),
              mark: "o",
              mark-size: 0.15,
              mark-style: (
                stroke: none,
                fill: black,
              ),
              style: (
                stroke: (
                  paint: green,
                  thickness: 0.3mm,
                ),
              ),
            )
          },
        )
      })
    ],
  )
}

/// Создание таблицы результатов
#let show-table(title, steps, X, results, glob-max-error: none) = {
  show table.cell.where(y: 0): it => text(size: 8pt, strong(it))
  show table.cell.where(x: 0): it => strong(it)

  let errors = results.map(r => r.at(1))
  let min-error = 0
  let max-error = if glob-max-error == none { calc.max(..errors) } else { glob-max-error }

  align(
    center,
    [
      *#title*
      #table(
        columns: (auto, auto, auto, 1fr),
        stroke: gray + 0.2mm,
        [*Шаги*], [*h*], [*$y(x)$*], [*$Delta$ на последнем шаге*],
        ..steps
          .zip(results)
          .enumerate()
          .map(((i, row)) => {
            let n = row.at(0)
            let h = 1.0 / n
            let result = row.at(1).at(0)
            let error = row.at(1).at(1)
            let error-ratio = if max-error == min-error {
              0
            } else {
              (error - min-error) / (max-error - min-error)
            }
            let k = calc.root(error-ratio, 3)
            let delta-color = rgb(int(k * 255), 255 - int(k * 255), 0)
            (
              table.cell(fill: COLORS.rev().at(i).transparentize(80%))[#n],
              [#h],
              [#result],
              table.cell(fill: delta-color.transparentize(80%))[#error],
            )
          })
          .flatten()
      )
    ],
  )
}

/// Результаты поиска оптимального alpha
#let show-alpha-table(title, alpha-values, errors, highlight-alpha: none) = {
  show table.cell.where(x: 0): strong

  let min-error = calc.min(..errors)
  let max-error = calc.max(..errors)

  align(
    center,
    [
      *#title*
      #table(
        columns: (auto, 1fr),
        stroke: gray + 0.2mm,
        [*$alpha$*], [*Погрешность на последнем шаге*],
        ..alpha-values
          .zip(errors)
          .map(row => {
            let alpha = row.at(0)
            let error = row.at(1)
            (
              table.cell(
                fill: if highlight-alpha == alpha {
                  rgb(0, 255, 0).transparentize(50%)
                } else {
                  none
                },
              )[#calc.round(alpha, digits: 10)],
              {
                let error-ratio = if max-error == min-error {
                  0
                } else {
                  (error - min-error) / (max-error - min-error)
                }
                let k = calc.root(error-ratio, 3)
                let delta-color = rgb(int(k * 255), 255 - int(k * 255), 0)
                table.cell(fill: delta-color.transparentize(90%))[#error]
              },
            )
          })
          .flatten()
      )
    ],
  )
}

#let show-task(f, X, x0, y0, exact-fn, header) = {
  let reference-value = none
  if exact-fn == none {
    let ref-steps = 100
    let ref-h = (X - x0) / ref-steps
    let hist = ()
    (reference-value, hist) = runge-kutta-4(f, x0, y0, ref-h, ref-steps)
    exact-fn = hist
  } else {
    reference-value = exact-fn(X, y0)
    exact-fn = x => exact-fn(x, y0)
  }

  set page(columns: 4)
  place(float: true, top + center, scope: "parent")[
    === #header
  ]

  let euler-results = STEPS.map(steps => {
    let h = X / steps
    let (result, points) = euler(f, x0, y0, h, steps)
    let error = calc.abs(reference-value - result)
    ((result, error), points)
  })

  let mod1-results = STEPS.map(steps => {
    let h = X / steps
    let (result, points) = euler-mod1(f, x0, y0, h, steps)
    let error = calc.abs(reference-value - result)
    ((result, error), points)
  })

  let mod2-results = STEPS.map(steps => {
    let h = X / steps
    let (result, points) = euler-mod2(f, x0, y0, h, steps)
    let error = calc.abs(reference-value - result)
    ((result, error), points)
  })

  let steps = STEPS.at(-1)
  let h = X / steps

  // Сравнение с разными alpha
  let alpha-values = ALPHA-VALUES
  if chosen-alpha != none and not alpha-values.contains(chosen-alpha) {
    alpha-values.push(chosen-alpha)
  }
  alpha-values = alpha-values.sorted()
  let rk-results = alpha-values.map(alpha => {
    let (result, points) = runge-kutta-2(f, x0, y0, h, steps, alpha)
    let error = calc.abs(reference-value - result)
    ((result, error), points, alpha)
  })

  let min-error-idx = 0
  for i in range(1, rk-results.len()) {
    if rk-results.at(i).at(0).at(1) < rk-results.at(min-error-idx).at(0).at(1) {
      min-error-idx = i
    }
  }
  let best-alpha = rk-results.at(min-error-idx).at(2)
  if chosen-alpha != none {
    best-alpha = chosen-alpha
  }

  // Сравнение с разными шагами
  let rk-steps-results = STEPS.map(steps => {
    let h = X / steps
    let (result, points) = runge-kutta-2(f, x0, y0, h, steps, best-alpha)
    let error = calc.abs(reference-value - result)
    ((result, error), points)
  })

  let glob-min-error = calc.min(..rk-steps-results.map(r => r.at(0).at(1)))
  let glob-max-error = calc.max(..euler-results.map(r => r.at(0).at(1)))

  show-table(
    [Метод Эйлера],
    STEPS,
    X,
    euler-results.map(r => r.at(0)),
    glob-max-error: glob-max-error,
  )
  show-plot(euler-results.map(r => r.at(1)), exact-fn, [])
  show-error-plot(
    STEPS.map(s => X / s),
    euler-results.map(r => r.at(0).at(1)),
    [Зависимость погрешности от шага (Метод Эйлера)],
  )

  colbreak(weak: true)

  show-table(
    [Модификация 1],
    STEPS,
    X,
    mod1-results.map(r => r.at(0)),
    glob-max-error: glob-max-error,
  )
  show-plot(mod1-results.map(r => r.at(1)), exact-fn, [])
  show-error-plot(
    STEPS.map(s => X / s),
    mod1-results.map(r => r.at(0).at(1)),
    [Зависимость погрешности от шага (Мод. 1)],
  )

  colbreak(weak: true)

  show-table(
    [Модификация 2],
    STEPS,
    X,
    mod2-results.map(r => r.at(0)),
    glob-max-error: glob-max-error,
  )
  show-plot(mod2-results.map(r => r.at(1)), exact-fn, [])
  show-error-plot(
    STEPS.map(s => X / s),
    mod2-results.map(r => r.at(0).at(1)),
    [Зависимость погрешности от шага (Мод. 2)],
  )

  colbreak(weak: true)

  show-table(
    [Метод Рунге-Кутты c $alpha = #best-alpha$],
    STEPS,
    X,
    rk-steps-results.map(r => r.at(0)),
    glob-max-error: glob-max-error,
  )
  show-plot(rk-steps-results.map(r => r.at(1)), exact-fn, [])
  show-error-plot(
    STEPS.map(s => X / s),
    rk-steps-results.map(r => r.at(0).at(1)),
    [Зависимость $Delta$ от шага (Метод Рунге-Кутты)],
  )

  colbreak(weak: true)

  pagebreak()

  set page(columns: 1, width: 420mm, height: auto)
  place(float: true, top + center, scope: "parent")[
    === #header.body, иетод Рунге-Кутты с разными $alpha$ ($n=#steps, h=#h$)
  ]

  grid(
    columns: (auto, 240mm),
    align: center + horizon,
    column-gutter: 0pt,
    show-alpha-table([], alpha-values, rk-results.map(r => r.at(0).at(1)), highlight-alpha: best-alpha),
    {
      show-plot(
        rk-results.map(r => r.at(1)),
        exact-fn,
        [Метод Рунге-Кутты с разными $alpha$],
        scale: (PLOT_SCALE * 2.5, PLOT_SCALE),
      )
      v(3em)
      show-error-plot(
        alpha-values,
        rk-results.map(r => r.at(0).at(1)),
        [Зависимость погрешности метода Рунге-Кутты от $alpha$],
        x-label: $alpha$,
        scale: (PLOT_SCALE * 2.5, PLOT_SCALE),
      )
    },
  )
}


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

#let deq = $y' = y - x, y(0) = n + 4$
#show-task(f1, X, 0, n + 4, exact1, [=== Задание 1: #deq])
#pagebreak()

#let deq = $y' = y - 2x / y, y(0) = n + 4$
#show-task(f2, X, 0, n + 4, exact2, [=== Задание 2: #deq])
#pagebreak()


#set page(columns: 2)

=== Сравнение методов для уравнения $y' = y - x$

1. *Метод Эйлера* показывает наибольшую погрешность
  Это объясняется тем, что он имеет порядок точности $O(h)$.
2. *Мод. 1* и *Мод. 2* дают идентичные результаты.
  Для линейных ДУ вида $y' = a y + b x + c$ эти методы эквивалентны,
  и имеют второй порядок точности $O(h^2)$.
3. *Метод Рунге-Кутты* дает наименьшую погрешность.

*Сравнение методов для уравнения $y' = y - 2x/y$:*

1. *Метод Эйлера* также демонстрирует наибольшую погрешность.
2. *Модификации 1 и 2* дают близкие, но не идентичные результаты,
  так как для нелинейных уравнений эквивалентность нарушается.
3. *Метод Рунге-Кутты* с оптимальным $alpha$ даёт результат, равный
  модификации 2, так как при $alpha = 1$ методы совпадают.

*Почему совпали результаты модификаций для первого уравнения?*

Обоснуем эквивалентность приближений по первой и второй модификациям метода Эйлера. \
Разложим точное решение в ряд Тейлора:
$
  y(x_k + h) &= y(x_k)
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
$
  f(x_k + h / 2, y_k + h / 2 f(x_k, y_k))
  = (y_k + h / 2 (y_k - x_k)) - (x_k + h / 2)
  = (y_k - x_k) + h / 2 (y_k - x_k - 1), \
  quad y_(k+1)
  = y_k + h [(y_k - x_k) + h / 2 (y_k - x_k - 1)]
  = y_k + h(y_k - x_k) + h^2 / 2 (y_k - x_k - 1).
$

Подставим точное решение во вторую модификацию метода:
$
  f(x_k, y_k) + f(x_(k + 1), y_k + h f(x_k, y_k))
  = [y_k - x_k] + [(y_k + h[y_k - x_k]) - x_(k + 1)]
  = 2[y_k - x_k] + [h[y_k - x_k] - h] = \
  = 2[y_k - x_k] + h[y_k - x_k - 1], \
  quad y_(k+1)
  = y_k + h / 2 [2[y_k - x_k] + h[y_k - x_k - 1]]
  = y_k + h(y_k - x_k) + h^2 / 2 (y_k - x_k - 1).
$

Формулы обеих модификаций для точного решения дают эквивалентную локальную (шаговую)
погрешность $Delta_#[_лок_] = O(h^3)$, а это значит, что глобальная погрешность для
них $Delta = O(h^2)$, и оба метода имеют порядок $O(h^2)$.
Для случая $y' = y - x$ погрешности методов совпадают.

#colbreak()

=== Выводы

1. *Точность методов*:
  - Метод Эйлера имеет первый порядок точности $O(h)$
  - Модификации метода Эйлера и метод Рунге-Кутты имеют второй порядок точности $O(h^2)$

2. *Эквивалентность модификаций*:
  Для линейных дифференциальных уравнений первого порядка первая и вторая модификации
  метода Эйлера эквивалентны и дают идентичные результаты.
  Для нелинейных уравнений эквивалентность нарушается.

3. *Оптимальное значение $alpha$*:
  - Для уравнения $y' = y - x$ оптимальное значение $alpha$ -- любое.
  - Для уравнения $y' = y - 2x/y$ оптимальное значение $alpha -> infinity$.

#pagebreak(weak: true)
