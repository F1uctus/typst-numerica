#import "@preview/cetz:0.3.4"
#import "@preview/cetz-plot:0.1.1": plot, chart

#let SURNAME_NAME = "Никитин Илья"
#let UNN_GROUP = "3822Б1МА1"
#let n = 21
#let ITERATIONS = 5
#let PREC = 6

#set page(
  paper: "a4",
  margin: (top: 3em, bottom: 1cm, rest: 0.5cm),
  numbering: "1 / 1",
  header: [
    ЛР.04. Численное решение дифференциальных уравнений.
    #h(1fr)
    #eval(mode: "math", "n = " + repr(n))
    #h(1fr)
    #SURNAME_NAME, #UNN_GROUP
  ],
  columns: 2,
)
#set par(justify: true)
#set columns(gutter: 0.5cm)

#show heading: it => grid(
  columns: (1fr, auto, 1fr),
  align: horizon + center,
  column-gutter: 5pt,
  line(length: 100%), it.body, line(length: 100%),
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
        size: (8, 6),
        x-label: $n$,
        y-label: $Delta$,
        axis-style: "school-book",
        x-min: domain.at(0),
        x-max: domain.at(1),
        x-tick-step: 10,
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

#let f3(x, y) = 2 * y / x + 2 * calc.pow(x, 3)
#let exact_solution3(x) = calc.pow(x, 2) + calc.pow(x, 4)

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


//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>


=== Задание 1

#let a = 0.0
#let b = 1.0
#let y0 = n + 4
#let (results, n_values, errors_rk, errors_ab) = compute_errors(f1, exact_solution1, a, b, y0)

$y' = y - x, quad y(0) = #(n + 4)$

Аналитическое решение: $y(x) = x + 1 + #(n + 3) e^x$

#show-table(
  results,
  ([n], [RK4], [AB4], [Точное], [Погр. RK4], [Погр. AB4]),
)

#let orders_rk = compute_convergence_order(errors_rk)
#let orders_ab = compute_convergence_order(errors_ab)

Порядок сходимости RK4: #(orders_rk.map(str).join(", ")) \

Порядок сходимости AB4: #(orders_ab.map(str).join(", "))

#let error_plot_data = (
  (5, errors_rk.at(0)),
  (10, errors_rk.at(1)),
  (20, errors_rk.at(2)),
  (40, errors_rk.at(3)),
  (80, errors_rk.at(4)),
)
#let error_plot_data2 = (
  (5, errors_ab.at(0)),
  (10, errors_ab.at(1)),
  (20, errors_ab.at(2)),
  (40, errors_ab.at(3)),
  (80, errors_ab.at(4)),
)

#let err_func_rk(x) = {
  if x <= 5 { return errors_rk.at(0) }
  if x <= 10 { return errors_rk.at(0) + (errors_rk.at(1) - errors_rk.at(0)) * (x - 5) / 5 }
  if x <= 20 { return errors_rk.at(1) + (errors_rk.at(2) - errors_rk.at(1)) * (x - 10) / 10 }
  if x <= 40 { return errors_rk.at(2) + (errors_rk.at(3) - errors_rk.at(2)) * (x - 20) / 20 }
  return errors_rk.at(3) + (errors_rk.at(4) - errors_rk.at(3)) * (x - 40) / 40
}

#let err_func_ab(x) = {
  if x <= 5 { return errors_ab.at(0) }
  if x <= 10 { return errors_ab.at(0) + (errors_ab.at(1) - errors_ab.at(0)) * (x - 5) / 5 }
  if x <= 20 { return errors_ab.at(1) + (errors_ab.at(2) - errors_ab.at(1)) * (x - 10) / 10 }
  if x <= 40 { return errors_ab.at(2) + (errors_ab.at(3) - errors_ab.at(2)) * (x - 20) / 20 }
  return errors_ab.at(3) + (errors_ab.at(4) - errors_ab.at(3)) * (x - 40) / 40
}

#show-plot((5, 80), err_func_rk, err_func_ab, "Погрешность")


//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>


#colbreak()

=== Задание 2

#let a = 0.0
#let b = 1.0
#let y0 = n + 4
#let (results, n_values, errors_rk, errors_ab) = compute_errors(f2, exact_solution2, a, b, y0)

$y' = y - 2x/y, quad y(0) = #(n + 4)$

Аналитическое решение: $y(x) = sqrt(2x + 1 + (#(calc.pow(n + 4, 2) - 1) e^(2x)))$

#show-table(
  results,
  ([n], [RK4], [AB4], [Точное], [Погр. RK4], [Погр. AB4]),
)

#let orders_rk = compute_convergence_order(errors_rk)
#let orders_ab = compute_convergence_order(errors_ab)

Порядок сходимости RK4: #(orders_rk.map(str).join(", ")) \

Порядок сходимости AB4: #(orders_ab.map(str).join(", "))

#let err_func_rk(x) = {
  if x <= 5 { return errors_rk.at(0) }
  if x <= 10 { return errors_rk.at(0) + (errors_rk.at(1) - errors_rk.at(0)) * (x - 5) / 5 }
  if x <= 20 { return errors_rk.at(1) + (errors_rk.at(2) - errors_rk.at(1)) * (x - 10) / 10 }
  if x <= 40 { return errors_rk.at(2) + (errors_rk.at(3) - errors_rk.at(2)) * (x - 20) / 20 }
  return errors_rk.at(3) + (errors_rk.at(4) - errors_rk.at(3)) * (x - 40) / 40
}
#let err_func_ab(x) = {
  if x <= 5 { return errors_ab.at(0) }
  if x <= 10 { return errors_ab.at(0) + (errors_ab.at(1) - errors_ab.at(0)) * (x - 5) / 5 }
  if x <= 20 { return errors_ab.at(1) + (errors_ab.at(2) - errors_ab.at(1)) * (x - 10) / 10 }
  if x <= 40 { return errors_ab.at(2) + (errors_ab.at(3) - errors_ab.at(2)) * (x - 20) / 20 }
  return errors_ab.at(3) + (errors_ab.at(4) - errors_ab.at(3)) * (x - 40) / 40
}
#show-plot((5, 80), err_func_rk, err_func_ab, "Погрешность")


//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>


#pagebreak()

=== Задание 3

#let a = 1.0
#let b = 2.0
#let y0 = 2.0
#let (results, n_values, errors_rk, errors_ab) = compute_errors(f3, exact_solution3, a, b, y0)

$y' = 2y / x + 2x^3, quad y(1) = 2$

Аналитическое решение: $y(x) = x^2 + x^4$

#show-table(
  results,
  ([n], [RK4], [AB4], [Точное], [Погр. RK4], [Погр. AB4]),
)

#let orders_rk = compute_convergence_order(errors_rk)
#let orders_ab = compute_convergence_order(errors_ab)

Порядок сходимости RK4: #(orders_rk.map(str).join(", ")) \

Порядок сходимости AB4: #(orders_ab.map(str).join(", "))

#let err_func_rk(x) = {
  if x <= 5 { return errors_rk.at(0) }
  if x <= 10 { return errors_rk.at(0) + (errors_rk.at(1) - errors_rk.at(0)) * (x - 5) / 5 }
  if x <= 20 { return errors_rk.at(1) + (errors_rk.at(2) - errors_rk.at(1)) * (x - 10) / 10 }
  if x <= 40 { return errors_rk.at(2) + (errors_rk.at(3) - errors_rk.at(2)) * (x - 20) / 20 }
  return errors_rk.at(3) + (errors_rk.at(4) - errors_rk.at(3)) * (x - 40) / 40
}
#let err_func_ab(x) = {
  if x <= 5 { return errors_ab.at(0) }
  if x <= 10 { return errors_ab.at(0) + (errors_ab.at(1) - errors_ab.at(0)) * (x - 5) / 5 }
  if x <= 20 { return errors_ab.at(1) + (errors_ab.at(2) - errors_ab.at(1)) * (x - 10) / 10 }
  if x <= 40 { return errors_ab.at(2) + (errors_ab.at(3) - errors_ab.at(2)) * (x - 20) / 20 }
  return errors_ab.at(3) + (errors_ab.at(4) - errors_ab.at(3)) * (x - 40) / 40
}
#show-plot((5, 80), err_func_rk, err_func_ab, "Погрешность")

//////////////////////////////////////////////////

#colbreak()

=== Анализ результатов

Порядок методов \
В теории методы Рунге-Кутты и Адамса-Бэшфорта 4-го порядка должны демонстрировать порядок сходимости близкий к 4. Из результатов видно, что на практике порядки сходимости находятся в диапазоне от 3.5 до 4.5, что соответствует теоретическим ожиданиям с учетом погрешностей вычислений и округлений .

Трудоемкость методов \
Метод Рунге-Кутты 4-го порядка требует вычисления функции правой части 4 раза на каждом шаге. Метод Адамса-Бэшфорта 4-го порядка требует вычисления функции правой части только 1 раз на каждом шаге, но для запуска метода необходимо вычислить первые 4 точки другим методом (в данной реализации используется метод Рунге-Кутты).
При небольшом числе шагов $(n < 16)$ трудоемкость метода Адамса-Бэшфорта сравнима с трудоемкостью метода Рунге-Кутты, но при большом числе шагов $(n > 16)$ метод Адамса-Бэшфорта эффективнее примерно в 4 раза по числу вычислений функции правой части.

Точность методов \
Из полученных результатов видно, что метод Рунге-Кутты 4-го порядка обеспечивает более высокую точность, чем метод Адамса-Бэшфорта 4-го порядка при одинаковом числе шагов. Это связано с тем, что метод Адамса-Бэшфорта является многошаговым методом, и погрешность начальных приближений влияет на все последующие вычисления.

Выбор числа шагов для заданной точности \
Для достижения точности $10^{-6}$ для всех трех задач достаточно использовать метод Рунге-Кутты с числом шагов $n = 20$. Для метода Адамса-Бэшфорта требуется примерно $n = 40$ шагов для достижения аналогичной точности.
