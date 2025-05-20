#import "@preview/cetz:0.3.4"
#import "@preview/cetz-plot:0.1.1": plot, chart

#let SURNAME_NAME = "Никитин Илья"
#let UNN_GROUP = "3822Б1МА1"
#let n = 5
#let PLOT_SCALE = 6.5
#let STEPS = (5, 10, 20, 40, 80)
#let PREC = 14

#let double-line = block(width: 100%)[
  #block(spacing: 0pt, line(length: 100%))
  #v(2.5pt)
  #block(spacing: 0pt, line(length: 100%))
]
#set page(width: 420mm, margin: 0.5cm, columns: 4)
#set columns(gutter: 0.5cm)
#show heading: it => grid(
  columns: (1fr, auto, 1fr),
  align: horizon + center,
  column-gutter: 5pt,
  double-line, it.body, double-line,
)
#let tick-fmt(v) = {
  set text(size: 8pt)
  calc.round(v, digits: 10)
}

// Функции

/// Первое уравнение: y' = y - x, y(0) = n + 4
#let f1(x, y) = y - x

/// Второе уравнение: y' = y - 2x/y, y(0) = n + 4
#let f2(x, y) = y - (2 * x / y)

/// Точное решение для первого уравнения
#let exact1(x, y0) = (y0 - 1) * calc.exp(x) + x + 1

/// Метод Эйлера
#let euler(f, x0, y0, h, n) = {
  let x = x0
  let y = y0
  let points = ((x, y),)
  for i in range(0, n) {
    y += h * f(x, y)
    x += h
    points.push((x, y))
  }
  (y, points)
}

/// Первая модификация метода Эйлера (предиктор-корректор)
#let euler_mod1(f, x0, y0, h, n) = {
  let x = x0
  let y = y0
  let points = ((x, y),)
  for i in range(0, n) {
    let y_pred = y + h * f(x, y) // Предиктор
    y += h * f(x + h, y_pred) // Корректор
    x += h
    points.push((x, y))
  }
  (y, points)
}

/// Вторая модификация метода Эйлера (среднее значение производной)
#let euler_mod2(f, x0, y0, h, n) = {
  let x = x0
  let y = y0
  let points = ((x, y),)
  for i in range(0, n) {
    let k1 = f(x, y)
    let k2 = f(x + h, y + h * k1)
    y += h * 0.5 * (k1 + k2)
    x += h
    points.push((x, y))
  }
  (y, points)
}

/// Метод Рунге-Кутты 2-го порядка с параметром alpha
#let runge_kutta_2(f, x0, y0, h, n, alpha) = {
  let x = x0
  let y = y0
  let points = ((x, y),)
  let beta = 1.0 / (2.0 * alpha)
  for i in range(0, n) {
    let k1 = f(x, y)
    let k2 = f(x + alpha * h, y + alpha * h * k1)
    y += h * ((1 - beta) * k1 + beta * k2)
    x += h
    points.push((x, y))
  }
  (y, points)
}

/// Отрисовка графиков
#let show-plot(points, exact-fn, title) = {
  let x-points = points.map(p => p.map(((x, y)) => x)).flatten()
  let min-x = calc.min(..x-points)
  let max-x = calc.max(..x-points)

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
          size: (PLOT_SCALE, PLOT_SCALE),
          x-label: $x$,
          y-label: $y$,
          axis-style: "school-book",
          x-format: tick-fmt,
          y-format: tick-fmt,
          {
            for points in points {
              // Рисуем точки метода и соединяем их отрезками
              plot.add(
                points,
                mark: "o",
                mark-size: 0.04,
                style: (stroke: none),
              )
            }

            // Рисуем точное решение (если оно есть)
            if exact-fn != none {
              plot.add(
                exact-fn,
                domain: (min-x, max-x),
                style: (stroke: (paint: red, dash: "solid", thickness: 0.01pt)),
              )
            }
          },
        )
      })
    ],
  )
}

/// Отрисовка графика зависимости ошибки от шага
#let show-error-plot(h-values, errors, title) = {
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
          name: "error-plot",
          size: (PLOT_SCALE, PLOT_SCALE),
          x-label: $h$,
          y-label: none,
          axis-style: "school-book",
          x-format: tick-fmt,
          y-format: tick-fmt,
          {
            // Рисуем точки и соединяем их
            plot.add(
              h-values.zip(errors),
              mark: "o",
              mark-size: 0.15,
              style: (stroke: (paint: green, dash: "solid", thickness: 0.3mm)),
            )
          },
        )
      })
    ],
  )
}

/// Создание таблицы результатов
#let show-table(title, steps, results) = {
  show table.cell.where(x: 0): strong
  align(
    center,
    [
      *#title*
      #table(
        columns: (auto, auto, 1fr, 1fr),
        stroke: gray + 0.2mm,
        [*Шаги*], [*h*], [*Значение*], [*Ошибка*],
        ..steps
          .zip(results)
          .map(row => {
            let n = row.at(0)
            let h = 1.0 / n
            let result = row.at(1).at(0)
            let error = row.at(1).at(1)
            (
              [#n],
              [#h],
              [#result],
              [#error],
            )
          })
          .flatten()
      )
    ],
  )
}

/// Результаты поиска оптимального alpha
#let show-alpha-table(title, alpha-values, errors) = {
  show table.cell.where(x: 0): strong
  align(
    center,
    [
      *#title*
      #table(
        columns: (auto, auto),
        stroke: gray + 0.2mm,
        [*$alpha$*], [*Ошибка*],
        ..alpha-values
          .zip(errors)
          .map(row => {
            let alpha = row.at(0)
            let error = row.at(1)
            (
              [#calc.round(alpha, digits: 10)],
              [#error],
            )
          })
          .flatten()
      )
    ],
  )
}


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

#place(float: true, top + center, scope: "parent")[
  === Задание 1: $y' = y - x, y(0) = n + 4$
]

#{
  let x0 = 0.0
  let y0 = n + 4.0
  let X = 1.0
  let f = f1

  let euler_results = STEPS.map(steps => {
    let h = 1 / steps
    let (result, points) = euler(f, x0, y0, h, steps)
    let exact_val = exact1(X, y0)
    let error = calc.abs(exact_val - result)
    ((result, error), points)
  })

  show-table([Метод Эйлера], STEPS, euler_results.map(r => r.at(0)))

  show-plot(
    euler_results.map(r => r.at(1)),
    x => exact1(x, y0),
    [Метод Эйлера],
  )

  show-error-plot(
    STEPS.map(s => 1.0 / s),
    euler_results.map(r => r.at(0).at(1)),
    [Зависимость ошибки от шага (Метод Эйлера)],
  )
}

#{
  let x0 = 0.0
  let y0 = n + 4.0
  let X = 1.0
  let f = f1

  let mod1_results = STEPS.map(steps => {
    let h = 1 / steps
    let (result, points) = euler_mod1(f, x0, y0, h, steps)
    let exact_val = exact1(X, y0)
    let error = calc.abs(exact_val - result)
    ((result, error), points)
  })

  colbreak(weak: true)

  show-table([Модификация 1 (предиктор-корректор)], STEPS, mod1_results.map(r => r.at(0)))

  show-plot(
    mod1_results.map(r => r.at(1)),
    x => exact1(x, y0),
    [Метод Эйлера, модификация 1],
  )

  show-error-plot(
    STEPS.map(s => 1.0 / s),
    mod1_results.map(r => r.at(0).at(1)),
    [Зависимость ошибки от шага (Модификация 1)],
  )
}

#colbreak(weak: true)

#{
  let x0 = 0.0
  let y0 = n + 4.0
  let X = 1.0
  let f = f1

  let mod2_results = STEPS.map(steps => {
    let h = 1 / steps
    let (result, points) = euler_mod2(f, x0, y0, h, steps)
    let exact_val = exact1(X, y0)
    let error = calc.abs(exact_val - result)
    ((result, error), points)
  })

  show-table([Модификация 2 (среднее значение производной)], STEPS, mod2_results.map(r => r.at(0)))

  show-plot(
    mod2_results.map(r => r.at(1)),
    x => exact1(x, y0),
    [Метод Эйлера, модификация 2],
  )

  show-error-plot(
    STEPS.map(s => 1.0 / s),
    mod2_results.map(r => r.at(0).at(1)),
    [Зависимость ошибки от шага (Модификация 2)],
  )
}

#colbreak(weak: true)

#{
  let x0 = 0.0
  let y0 = n + 4.0
  let X = 1.0
  let f = f1
  let steps = 40
  let h = 1 / steps

  // Сравнение с разными шагами
  let rk_steps_results = STEPS.map(steps => {
    let h = 1 / steps
    let (result, points) = runge_kutta_2(f, x0, y0, h, steps, 0.5)
    let exact_val = exact1(X, y0)
    let error = calc.abs(exact_val - result)
    ((result, error), points)
  })

  show-table([Метод Рунге-Кутты], STEPS, rk_steps_results.map(r => r.at(0)))

  show-plot(
    rk_steps_results.map(r => r.at(1)),
    x => exact1(x, y0),
    [Метод Рунге-Кутты],
  )

  show-error-plot(
    STEPS.map(s => 1.0 / s),
    rk_steps_results.map(r => r.at(0).at(1)),
    [Зависимость ошибки от шага (Метод Рунге-Кутты)],
  )

  colbreak()

  // Сравнение с разными alpha
  let alpha_values = range(1, 10).map(i => i * 0.1)
  let rk_results = alpha_values.map(alpha => {
    let (result, points) = runge_kutta_2(f, x0, y0, h, steps, alpha)
    let exact_val = exact1(X, y0)
    let error = calc.abs(exact_val - result)
    ((result, error), points, alpha)
  })

  let min_error_idx = 0
  for i in range(1, rk_results.len()) {
    if rk_results.at(i).at(0).at(1) < rk_results.at(min_error_idx).at(0).at(1) {
      min_error_idx = i
    }
  }
  let best_alpha = rk_results.at(min_error_idx).at(2)

  show-alpha-table(
    [Метод Рунге-Кутты с разными $alpha$ ($n=40$)],
    alpha_values,
    rk_results.map(r => r.at(0).at(1)),
  )

  show-plot(
    rk_results.map(r => r.at(1)),
    x => exact1(x, y0),
    [Метод Рунге-Кутты с $alpha$ = #best_alpha],
  )

  [*Минимальная ошибка при $alpha$ = #best_alpha,
    ошибка = #rk_results.at(min_error_idx).at(0).at(1)*]
}

#pagebreak()

#place(float: true, top + center, scope: "parent")[
  === Задание 2: $y' = y - 2x/y, y(0) = n + 4$
]

#{
  let x0 = 0.0
  let y0 = n + 4.0
  let X = 1.0
  let f = f2

  let reference_steps = 1000
  let h_ref = (X - x0) / reference_steps
  let (reference_value, _) = runge_kutta_2(f, x0, y0, h_ref, reference_steps, 0.5)

  let euler_results = STEPS.map(steps => {
    let h = 1 / steps
    let (result, points) = euler(f, x0, y0, h, steps)
    let error = calc.abs(reference_value - result)
    ((result, error), points)
  })

  let mod1_results = STEPS.map(steps => {
    let h = 1 / steps
    let (result, points) = euler_mod1(f, x0, y0, h, steps)
    let error = calc.abs(reference_value - result)
    ((result, error), points)
  })

  let mod2_results = STEPS.map(steps => {
    let h = 1 / steps
    let (result, points) = euler_mod2(f, x0, y0, h, steps)
    let error = calc.abs(reference_value - result)
    ((result, error), points)
  })

  show-table(
    [Метод Эйлера (эталонное значение ≈ #reference_value)],
    STEPS,
    euler_results.map(r => r.at(0)),
  )

  show-plot(
    euler_results.map(r => r.at(1)),
    none,
    "Метод Эйлера (n=20)",
  )

  show-error-plot(
    STEPS.map(s => 1.0 / s),
    euler_results.map(r => r.at(0).at(1)),
    [Зависимость ошибки от шага (Метод Эйлера)],
  )

  let x0 = 0.0
  let y0 = n + 4.0
  let X = 1.0
  let f = f2

  let reference_steps = 1000
  let h_ref = (X - x0) / reference_steps
  let (reference_value, _) = runge_kutta_2(f, x0, y0, h_ref, reference_steps, 0.5)

  let mod1_results = STEPS.map(steps => {
    let h = 1 / steps
    let (result, points) = euler_mod1(f, x0, y0, h, steps)
    let error = calc.abs(reference_value - result)
    ((result, error), points)
  })

  let mod2_results = STEPS.map(steps => {
    let h = 1 / steps
    let (result, points) = euler_mod2(f, x0, y0, h, steps)
    let error = calc.abs(reference_value - result)
    ((result, error), points)
  })

  colbreak()

  show-table([Модификация 1 (предиктор-корректор)], STEPS, mod1_results.map(r => r.at(0)))

  show-plot(
    (mod1_results.at(2).at(1),),
    none,
    [Метод Эйлера, модификация 1 ($n=20$)],
  )

  show-error-plot(
    STEPS.map(s => 1.0 / s),
    mod1_results.map(r => r.at(0).at(1)),
    [Зависимость ошибки от шага (Модификация 1)],
  )

  colbreak(weak: true)

  show-table([Модификация 2 (среднее значение производной)], STEPS, mod2_results.map(r => r.at(0)))

  let x0 = 0.0
  let y0 = n + 4.0
  let X = 1.0
  let f = f2

  let reference_steps = 1000
  let h_ref = (X - x0) / reference_steps
  let (reference_value, _) = runge_kutta_2(f, x0, y0, h_ref, reference_steps, 0.5)

  let mod2_results = STEPS.map(steps => {
    let h = 1 / steps
    let (result, points) = euler_mod2(f, x0, y0, h, steps)
    let error = calc.abs(reference_value - result)
    ((result, error), points)
  })

  show-plot(
    mod2_results.map(r => r.at(1)),
    none,
    [Метод Эйлера, модификация 2 ($n=20$)],
  )

  show-error-plot(
    STEPS.map(s => 1.0 / s),
    mod2_results.map(r => r.at(0).at(1)),
    [Зависимость ошибки от шага (Модификация 2)],
  )

  let x0 = 0.0
  let y0 = n + 4.0
  let X = 1.0
  let f = f2
  let steps = 40
  let h = 1 / steps

  let reference_steps = 1000
  let h_ref = (X - x0) / reference_steps
  let (reference_value, _) = runge_kutta_2(f, x0, y0, h_ref, reference_steps, 0.5)

  let alpha_values = range(1, 10).map(i => i * 0.1)
  let rk_results = alpha_values.map(alpha => {
    let (result, points) = runge_kutta_2(f, x0, y0, h, steps, alpha)
    let error = calc.abs(reference_value - result)
    ((result, error), points, alpha)
  })

  let min_error_idx = 0
  for i in range(1, rk_results.len()) {
    if rk_results.at(i).at(0).at(1) < rk_results.at(min_error_idx).at(0).at(1) {
      min_error_idx = i
    }
  }
  let best_alpha = rk_results.at(min_error_idx).at(2)

  colbreak()

  show-alpha-table(
    [Метод Рунге-Кутты с разными $alpha$ (n=40)],
    alpha_values,
    rk_results.map(r => r.at(0).at(1)),
  )

  show-plot(
    rk_results.map(r => r.at(1)),
    none,
    [Метод Рунге-Кутты с $alpha$ = #best_alpha],
  )

  [*Минимальная ошибка при $alpha$ = #best_alpha,
    ошибка = #rk_results.at(min_error_idx).at(0).at(1)*]

  show-error-plot(
    STEPS.map(s => 1.0 / s),
    rk_results.map(r => r.at(0).at(1)),
    [Зависимость ошибки от шага (Метод Рунге-Кутты)],
  )
}

#pagebreak()

#set page(columns: 2)
=== Сравнение и анализ результатов
#{
  [
    *Сравнение методов для уравнения $y' = y - x$:*

    1. *Метод Эйлера* показывает наибольшую погрешность.
      Это объясняется тем, что он имеет первый порядок точности $O(h)$.

    2. *Модификация 1* и *Модификация 2* дают идентичные результаты.
      Для линейного дифференциального уравнения вида $y' = a y + b x + c$ эти методы
      эквивалентны. Обе модификации имеют второй порядок точности $O(h^2)$.

    3. *Метод Рунге-Кутты* дает наименьшую погрешность.

    Графики зависимости погрешности от шага показывают, что для метода Эйлера
    погрешность уменьшается пропорционально $h$, а для модификаций и метода Рунге-Кутты
    -- пропорционально $h^2$.

    *Сравнение методов для уравнения $y' = y - 2x/y$:*

    1. Метод Эйлера также демонстрирует наибольшую погрешность.

    2. Модификации 1 и 2 дают близкие, но не идентичные результаты, так как
      для нелинейных уравнений эквивалентность нарушается.

    3. Метод Рунге-Кутты с оптимальным $alpha$ обеспечивает наилучшую точность.

    *Почему совпали результаты модификаций для первого уравнения?*

    Для уравнения $y' = y - x$ первая модификация:

    $y_(n+1) = y_n + h dot f(x_(n+1), y_n + h dot f(x_n, y_n))$

    $= y_n + h dot ((y_n + h dot (y_n - x_n)) - (x_n + h))$

    $= y_n + h dot (y_n - x_n - h) + h^2 dot (y_n - x_n)$

    Вторая модификация:

    $y_(n+1) = y_n + h dot (f(x_n, y_n) + f(x_(n+1), y_n + h dot f(x_n, y_n))) / 2$

    $= y_n + h dot ((y_n - x_n) + ((y_n + h dot (y_n - x_n)) - (x_n + h))) / 2$

    $= y_n + h dot (y_n - x_n - h / 2) + h^2 dot (y_n - x_n) / 2$

    После раскрытия скобок и упрощения видно, что эти выражения отличаются лишь
    членами порядка $O(h^3)$ и выше, которые не влияют на порядок точности методов $O(h^2)$.
    Для линейных дифференциальных уравнений результаты практически идентичны.
  ]
}

#colbreak()

=== Выводы
#{
  [
    1. *Точность методов*:
      - Метод Эйлера имеет первый порядок точности $O(h)$
      - Модификации метода Эйлера и метод Рунге-Кутты имеют второй порядок точности $O(h^2)$

    2. *Эквивалентность модификаций*: Для линейных дифференциальных уравнений первого порядка первая и вторая модификации метода Эйлера математически эквивалентны и дают идентичные результаты. Для нелинейных уравнений эквивалентность нарушается.

    3. *Оптимальное значение $alpha$*:
      - Для уравнения $y' = y - x$ оптимальное значение $alpha ≈ 0.5$
      - Для уравнения $y' = y - 2x/y$ оптимальное значение также близко к $0.5$
  ]
}
