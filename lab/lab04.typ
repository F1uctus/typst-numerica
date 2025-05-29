#import "@preview/cetz:0.3.4"
#import "@preview/cetz-plot:0.1.1": plot, chart

#let SURNAME_NAME = "Никитин Илья"
#let UNN_GROUP = "3822Б1МА1"
#let n = 21

#let PREC = 6
#let double-line = block(width: 100%)[
  #block(spacing: 0pt, line(length: 100%))
  #v(2.5pt)
  #block(spacing: 0pt, line(length: 100%))
]
#set page(width: 280mm, height: auto, margin: 0.5cm, columns: 2)
#set columns(gutter: 0.5cm)
#set par(justify: true)
#show heading: it => grid(
  columns: (1fr, auto, 1fr),
  align: horizon + center,
  column-gutter: 5pt,
  double-line, it.body, double-line,
)

#let show-table(data, headers) = {
  show table.cell.where(x: 0): strong
  align(
    center,
    table(
      columns: data.at(0).len(),
      stroke: gray + 0.2mm,
      ..headers,
      ..data.flatten(),
    ),
  )
}

#let show-plot(domain, f1, f2, f_label) = {
  align(
    center,
    cetz.canvas({
      cetz.draw.set-style(
        axes: (
          stroke: (paint: gray, dash: "solid", thickness: 0.1mm),
          tick: (stroke: gray + .5pt),
        ),
        legend: (stroke: none),
      )
      plot.plot(
        size: (8, 15),
        x-label: $n$,
        y-label: $Delta$,
        axis-style: "school-book",
        x-min: domain.at(0),
        x-max: domain.at(1),
        x-tick-step: 10,
        y-format: plot.formats.decimal.with(digits: 10),
        legend: "south",
        {
          plot.add(f1, domain: domain, label: "RK4", style: (stroke: blue + 0.5mm))
          plot.add(f2, domain: domain, label: "AB4", style: (stroke: red + 0.5mm))
          plot.add-legend(f_label)
        },
      )
    }),
  )
}

#let f1(x, y) = y - x
#let exact_solution1(x) = x + 1 + (n + 3) * calc.exp(x)

#let f2(x, y) = y - (2 * x) / y
#let exact_solution2(x) = calc.sqrt(2 * x + 1 + (calc.pow(n + 4, 2) - 1) * calc.exp(2 * x))

#let runge_kutta(f, y0, a, b, steps) = {
  let h = (b - a) / steps
  let x = a
  let y = y0
  let history = ((x, y),)
  for i in range(0, steps) {
    let k1 = h * f(x, y)
    let k2 = h * f(x + h / 2, y + k1 / 2)
    let k3 = h * f(x + h / 2, y + k2 / 2)
    let k4 = h * f(x + h, y + k3)
    y += (k1 + 2 * k2 + 2 * k3 + k4) / 6
    x += h
    history.push((x, y))
  }
  return (y, history)
}

#let adams_bashforth(f, y0, a, b, steps) = {
  if steps < 4 { return (calc.nan, ()) }
  let h = (b - a) / steps
  let x = (a,)
  let y = (y0,)
  let history = ((a, y0),)
  for i in range(0, 3) {
    let k1 = h * f(x.at(i), y.at(i))
    let k2 = h * f(x.at(i) + h / 2, y.at(i) + k1 / 2)
    let k3 = h * f(x.at(i) + h / 2, y.at(i) + k2 / 2)
    let k4 = h * f(x.at(i) + h, y.at(i) + k3)
    let next_y = y.at(i) + (k1 + 2 * k2 + 2 * k3 + k4) / 6
    let next_x = x.at(i) + h
    y.push(next_y)
    x.push(next_x)
    history.push((next_x, next_y))
  }
  for i in range(3, steps) {
    let f_n = f(x.at(i), y.at(i))
    let f_n1 = f(x.at(i - 1), y.at(i - 1))
    let f_n2 = f(x.at(i - 2), y.at(i - 2))
    let f_n3 = f(x.at(i - 3), y.at(i - 3))
    let next_y = y.at(i) + h * (55 * f_n - 59 * f_n1 + 37 * f_n2 - 9 * f_n3) / 24
    let next_x = x.at(i) + h
    y.push(next_y)
    x.push(next_x)
    history.push((next_x, next_y))
  }
  return (y.at(steps), history)
}

#let compute_errors(f, exact_solution, a, b, y0) = {
  let n_values = (5, 10, 20, 40, 80)
  let errors_rk = ()
  let errors_ab = ()
  let results = ()
  for steps in n_values {
    let (y_rk, _) = runge_kutta(f, y0, a, b, steps)
    let (y_ab, _) = adams_bashforth(f, y0, a, b, steps)
    let y_exact = exact_solution(b)
    let error_rk = calc.abs(y_rk - y_exact)
    let error_ab = calc.abs(y_ab - y_exact)

    errors_rk.push(error_rk)
    errors_ab.push(error_ab)


    results.push((
      [#steps],
      [#calc.round(y_rk, digits: PREC)],
      [#calc.round(y_ab, digits: PREC)],
      [#calc.round(y_exact, digits: PREC)],
      [#calc.round(error_rk, digits: PREC)],
      [#calc.round(error_ab, digits: PREC)],
    ))
  }
  return (results, n_values, errors_rk, errors_ab)
}

#let compute_convergence_order(errors) = {
  let orders = ()
  for i in range(0, errors.len() - 1) {
    if i < errors.len() - 1 {
      let order = calc.log(errors.at(i) / errors.at(i + 1)) / calc.log(2)
      orders.push(calc.round(order, digits: 3))
    }
  }
  return orders
}

#let err_func(errors) = x => {
  if x <= 5 { errors.at(0) } else if x <= 10 { errors.at(0) + (errors.at(1) - errors.at(0)) * (x - 5) / 5 } else if (
    x <= 20
  ) { errors.at(1) + (errors.at(2) - errors.at(1)) * (x - 10) / 10 } else if x <= 40 {
    errors.at(2) + (errors.at(3) - errors.at(2)) * (x - 20) / 20
  } else { errors.at(3) + (errors.at(4) - errors.at(3)) * (x - 40) / 40 }
}

// Методы для систем ДУ (для решения ДУ 2-го порядка)
#let runge_kutta_system(f, y0, a, b, steps) = {
  let h = (b - a) / steps
  let x = a
  let y = y0  // y теперь вектор
  let history = ((x, y),)
  
  for i in range(0, steps) {
    // k1 = h * f(x, y)
    let k1 = f(x, y).map(v => h * v)
    
    // k2 = h * f(x + h/2, y + k1/2)
    let y_temp = y.enumerate().map(((i, yi)) => yi + k1.at(i) / 2)
    let k2 = f(x + h / 2, y_temp).map(v => h * v)
    
    // k3 = h * f(x + h/2, y + k2/2)
    y_temp = y.enumerate().map(((i, yi)) => yi + k2.at(i) / 2)
    let k3 = f(x + h / 2, y_temp).map(v => h * v)
    
    // k4 = h * f(x + h, y + k3)
    y_temp = y.enumerate().map(((i, yi)) => yi + k3.at(i))
    let k4 = f(x + h, y_temp).map(v => h * v)
    
    // y = y + (k1 + 2*k2 + 2*k3 + k4) / 6
    y = y.enumerate().map(((i, yi)) => yi + (k1.at(i) + 2 * k2.at(i) + 2 * k3.at(i) + k4.at(i)) / 6)
    x += h
    history.push((x, y))
  }
  return (y, history)
}

#let adams_bashforth_system(f, y0, a, b, steps) = {
  if steps < 4 { return ((), ()) }
  let h = (b - a) / steps
  let x = (a,)
  let y = (y0,)  // массив векторов
  let history = ((a, y0),)
  
  // Первые 4 точки методом Рунге-Кутты
  for i in range(0, 3) {
    let yi = y.at(i)
    let xi = x.at(i)
    
    let k1 = f(xi, yi).map(v => h * v)
    let y_temp = yi.enumerate().map(((j, yj)) => yj + k1.at(j) / 2)
    let k2 = f(xi + h / 2, y_temp).map(v => h * v)
    
    y_temp = yi.enumerate().map(((j, yj)) => yj + k2.at(j) / 2)
    let k3 = f(xi + h / 2, y_temp).map(v => h * v)
    
    y_temp = yi.enumerate().map(((j, yj)) => yj + k3.at(j))
    let k4 = f(xi + h, y_temp).map(v => h * v)
    
    let next_y = yi.enumerate().map(((j, yj)) => yj + (k1.at(j) + 2 * k2.at(j) + 2 * k3.at(j) + k4.at(j)) / 6)
    let next_x = xi + h
    
    y.push(next_y)
    x.push(next_x)
    history.push((next_x, next_y))
  }
  
  // Остальные точки методом Адамса-Бошфорта
  for i in range(3, steps) {
    let f_n = f(x.at(i), y.at(i))
    let f_n1 = f(x.at(i - 1), y.at(i - 1))
    let f_n2 = f(x.at(i - 2), y.at(i - 2))
    let f_n3 = f(x.at(i - 3), y.at(i - 3))
    
    let next_y = y.at(i).enumerate().map(((j, yj)) => {
      yj + h * (55 * f_n.at(j) - 59 * f_n1.at(j) + 37 * f_n2.at(j) - 9 * f_n3.at(j)) / 24
    })
    let next_x = x.at(i) + h
    
    y.push(next_y)
    x.push(next_x)
    history.push((next_x, next_y))
  }
  
  return (y.at(steps), history)
}

// Функция для подбора количества шагов для заданной точности
#let find_steps_for_tolerance(f, exact_solution, a, b, y0, tolerance, method) = {
  let steps = 5
  let max_steps = 10000
  let error = 1.0
  
  while error > tolerance and steps < max_steps {
    let (y_num, _) = if method == "RK4" {
      runge_kutta(f, y0, a, b, steps)
    } else {
      adams_bashforth(f, y0, a, b, steps)
    }
    let y_exact = exact_solution(b)
    error = calc.abs(y_num - y_exact)
    if error > tolerance {
      steps = calc.round(steps * 1.5)
      steps = int(steps)  // Преобразуем в целое число
    }
  }
  
  return (steps, error)
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


=== Задание 1 (Часть 1)

#let a = 0.0
#let b = 1.0
#let y0 = n + 4
#let (results, n_values, errors_rk, errors_ab) = compute_errors(f1, exact_solution1, a, b, y0)

$ y' = y - x, quad y(0) = #(n + 4) $

Аналитическое решение:
$ y(x) = x + 1 + #(n + 3) e^x $

#show-table(
  results,
  ([n], [RK4], [AB4], [Точное], [Погр. RK4], [Погр. AB4]),
)

#let orders_rk = compute_convergence_order(errors_rk)
#let orders_ab = compute_convergence_order(errors_ab)

Порядок сходимости RK4: #(orders_rk.map(str).join(", ")) \

Порядок сходимости AB4: #(orders_ab.map(str).join(", "))

// #let error_plot_data = range(4).fold(
//   ((5, errors_rk.at(0)),),
//   (acc, i) => acc + ((2 * acc.at(-1).at(0), errors_rk.at(i + 1)),)
// )
// #let error_plot_data2 = (
//   (5, errors_ab.at(0)),
//   (10, errors_ab.at(1)),
//   (20, errors_ab.at(2)),
//   (40, errors_ab.at(3)),
//   (80, errors_ab.at(4)),
// )

#show-plot((5, 80), err_func(errors_ab), err_func(errors_rk), "Погрешность")


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

#colbreak()

=== Задание 2 (Часть 1)

#let a = 0.0
#let b = 1.0
#let y0 = n + 4
#let (results, n_values, errors_rk, errors_ab) = compute_errors(f2, exact_solution2, a, b, y0)

$ y' = y - 2 x slash y, quad y(0) = #(n + 4) $

Аналитическое решение:
$ y(x) = sqrt(2x + 1 + (#(calc.pow(n + 4, 2) - 1) e^(2x))) $

#show-table(
  results,
  ([n], [RK4], [AB4], [Точное], [Погр. RK4], [Погр. AB4]),
)

#let orders_rk = compute_convergence_order(errors_rk)
#let orders_ab = compute_convergence_order(errors_ab)

Порядок сходимости RK4: #(orders_rk.map(str).join(", ")) \

Порядок сходимости AB4: #(orders_ab.map(str).join(", "))

#show-plot((5, 80), err_func(errors_ab), err_func(errors_rk), "Погрешность")


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

#pagebreak(weak: true)

=== Анализ результатов (Часть 2\*)

*Порядок методов*

В теории методы Рунге-Кутты и Адамса-Бошфорта 4-го порядка должны демонстрировать порядок сходимости близкий к 4. Из результатов видно, что порядки сходимости находятся в диапазоне от 3 до 5, что соответствует ожиданиям с учетом погрешностей вычислений и округлений (например, в методе Адамса-Бошфорта 4-го порядка погрешность начальных приближений влияет на все последующие вычисления).

*Трудоемкость методов*

Метод Рунге-Кутты 4-го порядка требует вычисления функции правой части 4 раза на каждом шаге. Метод Адамса-Бошфорта 4-го порядка требует вычисления функции правой части только 1 раз на каждом шаге, но для запуска метода необходимо вычислить первые 4 точки другим методом (в данной реализации используется метод Рунге-Кутты).
При небольшом числе шагов $(n < 16)$ трудоемкость метода Адамса-Бошфорта сравнима с трудоемкостью метода Рунге-Кутты, но при большом числе шагов $(n > 16)$ метод Адамса-Бошфорта эффективнее примерно в 4 раза по числу вычислений функции правой части.

*Точность методов*

Из полученных результатов видно, что метод Рунге-Кутты 4-го порядка обеспечивает более высокую точность, чем метод Адамса-Бошфорта 4-го порядка при одинаковом числе шагов. Это связано с тем, что метод Адамса-Бошфорта является многошаговым методом, и погрешность начальных приближений влияет на все последующие вычисления.

*Автоматический подбор шагов*

#let tolerance = 1e-6
#let a = 0.0
#let b = 1.0
#let y0 = n + 4

Подбор количества шагов для достижения точности $#tolerance$:

*Задача 1:* $y' = y - x$

#let (steps_rk1, error_rk1) = find_steps_for_tolerance(f1, exact_solution1, a, b, y0, tolerance, "RK4")
#let (steps_ab1, error_ab1) = find_steps_for_tolerance(f1, exact_solution1, a, b, y0, tolerance, "AB4")

- Метод Рунге-Кутты: #steps_rk1 шагов (погрешность: #calc.round(error_rk1, digits: 10))
- Метод Адамса-Бошфорта: #steps_ab1 шагов (погрешность: #calc.round(error_ab1, digits: 10))

*Задача 2:* $y' = y - 2x/y$

#let (steps_rk2, error_rk2) = find_steps_for_tolerance(f2, exact_solution2, a, b, y0, tolerance, "RK4")
#let (steps_ab2, error_ab2) = find_steps_for_tolerance(f2, exact_solution2, a, b, y0, tolerance, "AB4")

- Метод Рунге-Кутты: #steps_rk2 шагов (погрешность: #calc.round(error_rk2, digits: 10))
- Метод Адамса-Бошфорта: #steps_ab2 шагов (погрешность: #calc.round(error_ab2, digits: 10))

*Сравнение трудоемкости:*

Для задачи 1:
- Рунге-Кутта: #(steps_rk1 * 4) вычислений функции
- Адамс-Бошфорт: #(3 * 4 + (steps_ab1 - 3) * 1) вычислений функции

Для задачи 2:
- Рунге-Кутта: #(steps_rk2 * 4) вычислений функции
- Адамс-Бошфорт: #(3 * 4 + (steps_ab2 - 3) * 1) вычислений функции


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

#colbreak(weak: true)

=== Задание 3 (Часть 3\*)

// Новое ДУ 2-го порядка: y'' - y = -2, x in [0, 1]
// Аналитическое решение: y(x) = 2 + exp(-x)
// Начальные условия: y(0) = 3, y'(0) = -1
// Преобразуем в систему ДУ 1-го порядка:
// y1' = y2
// y2' = y1 - 2

#let f_system(x, y) = (
  y.at(1),   // y1' = y2
  y.at(0) - 2  // y2' = y1 - 2
)

#let exact_solution_system(x) = 2 + calc.exp(-x)
#let exact_derivative_system(x) = -calc.exp(-x)

#let compute_errors_system(f, exact_solution, exact_derivative, a, b, y0) = {
  let n_values = (5, 10, 20, 40, 80)
  let errors_rk = ()
  let errors_ab = ()
  let results = ()
  
  for steps in n_values {
    let (y_rk, _) = runge_kutta_system(f, y0, a, b, steps)
    let (y_ab, _) = adams_bashforth_system(f, y0, a, b, steps)
    
    let y_exact = exact_solution(b)
    let y_exact_deriv = exact_derivative(b)
    
    let error_rk = calc.abs(y_rk.at(0) - y_exact)
    let error_ab = calc.abs(y_ab.at(0) - y_exact)
    
    errors_rk.push(error_rk)
    errors_ab.push(error_ab)
    
    results.push((
      [#steps],
      [#calc.round(y_rk.at(0), digits: PREC)],
      [#calc.round(y_ab.at(0), digits: PREC)],
      [#calc.round(y_exact, digits: PREC)],
      [#calc.round(error_rk, digits: PREC)],
      [#calc.round(error_ab, digits: PREC)],
    ))
  }
  
  return (results, n_values, errors_rk, errors_ab)
}

#let a = 0.0
#let b = 1.0
#let y0 = (3.0, -1.0)  // начальные условия: y(0) = 3, y'(0) = -1
#let (results, n_values, errors_rk, errors_ab) = compute_errors_system(f_system, exact_solution_system, exact_derivative_system, a, b, y0)

$ y'' - y = -2, quad y(0) = 3, quad y'(0) = -1 $

Аналитическое решение: $y(x) = 2 + e^{-x}$

#show-table(
  results,
  ([n], [RK4], [AB4], [Точное], [Погр. RK4], [Погр. AB4]),
)

#let orders_rk = compute_convergence_order(errors_rk)
#let orders_ab = compute_convergence_order(errors_ab)

Порядок сходимости RK4: #(orders_rk.map(str).join(", ")) \

Порядок сходимости AB4: #(orders_ab.map(str).join(", "))

#show-plot((5, 80), err_func(errors_ab), err_func(errors_rk), "Погрешность")