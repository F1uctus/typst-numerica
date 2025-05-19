#import "@preview/cetz:0.3.4"
#import "@preview/cetz-plot:0.1.1": plot, chart
#import "@preview/numty:0.0.5" as nt

#let SURNAME_NAME = "Никитин Илья"
#let UNN_GROUP = "3822Б1МА1"

#let double-line = block(width: 100%)[
  #block(spacing: 0pt, line(length: 100%))
  #v(2.5pt)
  #block(spacing: 0pt, line(length: 100%))
]

#set page(
  height: auto,
  width: auto,
  margin: (top: 3em, rest: 0.5cm),
  header: [
    ЛР.02.
    #h(1fr)
    #SURNAME_NAME,
    #h(1pt)
    #UNN_GROUP
  ],
)
#set par(justify: true)
#show par: it => align(center, it)
#set table(stroke: 0.3pt)
#show heading: it => align(center, it)
#show heading.where(level: 2): it => align(
  center,
  grid(
    columns: (10em, auto, 10em),
    align: horizon + center,
    column-gutter: 5pt,
    double-line, it.body, double-line,
  ),
)
#show table.cell.where(x: 0): strong
#show table.cell.where(y: 0): strong

//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

#let ITER_LIMIT = 100
#let EPS = 1e-6

#let round(x) = calc.round(x, digits: 13)

// Определение функций уравнений
#let f1(x) = x * x * x - x
#let f2(x) = x * x * x - 3 * x * x + 6 * x - 5
#let f3(x) = x - calc.sin(x) - 0.25
#let f4(x) = x - calc.sin(calc.pi / 2 * x) - 0.25
#let f5(x) = x - calc.cos(x)
#let f6(x) = x - calc.cos(calc.pi / 2 * x)

// Производные для метода Ньютона
#let df1(x) = 3 * x * x - 1
#let df2(x) = 3 * x * x - 6 * x + 6
#let df3(x) = 1 - calc.cos(x)
#let df4(x) = 1 - calc.pi / 2 * calc.cos(calc.pi / 2 * x)
#let df5(x) = 1 + calc.sin(x)
#let df6(x) = 1 + calc.pi / 2 * calc.sin(calc.pi / 2 * x)

// Функции phi(x) для метода простой итерации
#let phi_f1(x) = if x < 0 { x } else { calc.pow(x, 1/3) }
#let phi_f2(x) = (-x * x * x + 3 * x * x + 5) / 6
#let phi_f3(x) = calc.sin(x) + 0.25
#let phi_f4(x) = calc.sin(calc.pi / 2 * x) + 0.25
#let phi_f5(x) = calc.cos(x)
#let phi_f6(x) = calc.cos(calc.pi / 2 * x)

// Производные phi(x)
#let dphi_f1(x) = 1.0 / (3.0 * calc.pow(x, 2.0/3.0))
#let dphi_f2(x) = (-2 * x * x + 6 * x) / 6
#let dphi_f3(x) = calc.cos(x)
#let dphi_f4(x) = calc.pi / 2 * calc.cos(calc.pi / 2 * x)
#let dphi_f5(x) = -calc.sin(x)
#let dphi_f6(x) = -calc.pi / 2 * calc.sin(calc.pi / 2 * x)

// Метод Ньютона для эталонного решения
#let newton-ref(f, df, x0, eps, max-iter) = {
  let x = x0
  for i in range(max-iter) {
    let fx = f(x)
    let dfx = df(x)
    if calc.abs(dfx) < 1e-12 { break }
    let delta = fx / dfx
    x -= delta
    if calc.abs(delta) < eps { break }
  }
  x
}

// Метод половинного деления с историей
#let bisection(a, b, f, eps, max-iter) = {
  let hist = ()
  if f(a) * f(b) >= 0 { return hist }
  for i in range(max-iter) {
    let c = (a + b) / 2
    hist.push(c)
    if f(c) == 0 or (b - a) / 2 < eps { break }
    if f(c) * f(a) < 0 { b = c } else { a = c }
  }
  hist
}

// Метод хорд с историей
#let chord(a, b, f, eps, max-iter) = {
  let hist = ()
  for i in range(max-iter) {
    let c = a - f(a) * (b - a) / (f(b) - f(a))
    hist.push(c)
    if calc.abs(f(c)) < eps { break }
    if f(c) * f(a) < 0 { b = c } else { a = c }
  }
  hist
}

// Метод простой итерации с историей
#let simple-iter(x0, phi, eps, max-iter) = {
  let hist = (x0,)
  let converged = false
  for i in range(max-iter) {
    let x = phi(hist.at(-1))
    hist.push(x)
    if calc.abs(hist.at(-1) - hist.at(-2)) < eps {
      converged = true
      break
    }
  }
  (hist, converged)
}

// Метод Ньютона с историей
#let newton(x0, f, df, eps, max-iter) = {
  let hist = (x0,)
  for i in range(max-iter) {
    let dfx = df(hist.at(-1))
    if calc.abs(dfx) < 1e-12 { break }
    let delta = f(hist.at(-1)) / dfx
    hist.push(hist.at(-1) - delta)
    if calc.abs(delta) < eps { break }
  }
  hist
}

// Проверка сходимости метода простой итерации
#let check-convergence(dphi, a, b) = {
  let steps = 10
  let step = (b - a) / steps
  for i in range(steps + 1) {
    let x = a + i * step
    if calc.abs(dphi(x)) >= 1.0 { return false }
  }
  true
}

== Задание 1

Найти корень уравнения $f(x) = x^3 - x$ на отрезке $[0.5; 2]$.

#let func = f1
#let dfunc = df1
#let phifunc = phi_f1
#let dphifunc = dphi_f1
#let a = 0.5
#let b = 2.0

#let x-ref = newton-ref(func, dfunc, (a + b)/2, 1e-10, 1000)
#let bisect-hist = bisection(a, b, func, EPS, ITER_LIMIT)
#let chord-hist = chord(a, b, func, EPS, ITER_LIMIT)
#let (si-hist, si-converged) = simple-iter((a + b)/2, phifunc, EPS, ITER_LIMIT)
#let newton-hist = newton((a + b)/2, func, dfunc, EPS, ITER_LIMIT)

#let plot-data = (
  (bisect-hist, "Метод половинного деления"),
  (chord-hist, "Метод хорд"),
  (si-hist, "Метод простой итерации"),
  (newton-hist, "Метод Ньютона"),
)

#let error-data = plot-data.map(((hist, name)) => (
  hist.enumerate().map(((i, x)) => (i, calc.abs(x - x-ref))),
  name,
))

// #plot.plot(
//   width: 100%,
//   height: 30em,
//   x-axis: (min: a, max: b),
//   y-axis: (min: -2, max: 2),
//   plot-data.map(((hist, name)) => (
//     hist.map(x => (x, func(x))),
//     name,
//   )),
// )

// #plot.plot(
//   width: 100%,
//   height: 30em,
//   x-axis: (min: 0, max: calc.max(error-data.map(h => h.at(0).len()))),
//   y-axis: (min: 0, max: 1),
//   error-data,
// )

== Задание 2

Найти другие корни уравнения $f(x) = x^3 - x$.

#let intervals = ((-0.5, 0.5), (-2.0, -0.5))

#for (a, b) in intervals {
  [=== Корень на отрезке $[#a; #b]$]
  
  let x-ref = newton-ref(func, dfunc, (a + b)/2, 1e-10, 1000)
  let bisect-hist = bisection(a, b, func, EPS, ITER_LIMIT)
  let chord-hist = chord(a, b, func, EPS, ITER_LIMIT)
  let (si-hist, si-converged) = simple-iter((a + b)/2, phifunc, EPS, ITER_LIMIT)
  let newton-hist = newton((a + b)/2, func, dfunc, EPS, ITER_LIMIT)
  
  let plot-data = (
    (bisect-hist, "Метод половинного деления"),
    (chord-hist, "Метод хорд"),
    (si-hist, "Метод простой итерации"),
    (newton-hist, "Метод Ньютона"),
  )
  
  let error-data = plot-data.map(((hist, name)) => (
    hist.enumerate().map(((i, x)) => (i, calc.abs(x - x-ref))),
    name,
  ))
  
  // plot(
  //   width: 100%,
  //   height: 30em,
  //   x-axis: (min: a, max: b),
  //   y-axis: (min: -2, max: 2),
  //   plot-data.map(((hist, name)) => (
  //     hist.map(x => (x, func(x))),
  //     name,
  //   )),
  // )
  
  // plot(
  //   width: 100%,
  //   height: 30em,
  //   x-axis: (min: 0, max: error-data.map(h => h.at(0).len()).max()),
  //   y-axis: (min: 0, max: 1),
  //   error-data,
  // )
}

== Задание 3

Найти корни уравнений 2-6.

#let functions = (
  (f2, df2, phi_f2, dphi_f2, "x^3 - 3x^2 + 6x - 5", (0.5, 2.0)),
  (f3, df3, phi_f3, dphi_f3, "x - sin(x) - 0.25", (1.0, 1.5)),
  (f4, df4, phi_f4, dphi_f4, "x - sin(pi/2 x) - 0.25", (1.0, 1.5)),
  (f5, df5, phi_f5, dphi_f5, "x - cos(x)", (0.5, 1.5)),
  (f6, df6, phi_f6, dphi_f6, "x - cos(pi/2 x)", (0.5, 1.0)),
)

#for (func, dfunc, phifunc, dphifunc, name, (a, b)) in functions {
  [=== Уравнение $f(x) = #name$]
  
  let x-ref = newton-ref(func, dfunc, (a + b)/2, 1e-10, 1000)
  let bisect-hist = bisection(a, b, func, EPS, ITER_LIMIT)
  let chord-hist = chord(a, b, func, EPS, ITER_LIMIT)
  let (si-hist, si-converged) = simple-iter((a + b)/2, phifunc, EPS, ITER_LIMIT)
  let newton-hist = newton((a + b)/2, func, dfunc, EPS, ITER_LIMIT)
  
  let plot-data = (
    (bisect-hist, "Метод половинного деления"),
    (chord-hist, "Метод хорд"),
    (si-hist, "Метод простой итерации"),
    (newton-hist, "Метод Ньютона"),
  )
  
  let error-data = plot-data.map(((hist, name)) => (
    hist.enumerate().map(((i, x)) => (i, calc.abs(x - x-ref))),
    name,
  ))
  
  // plot(
  //   width: 100%,
  //   height: 30em,
  //   x-axis: (min: a, max: b),
  //   y-axis: (min: -2, max: 2),
  //   plot-data.map(((hist, name)) => (
  //     hist.map(x => (x, func(x))),
  //     name,
  //   )),
  // )
  
  // plot(
  //   width: 100%,
  //   height: 30em,
  //   x-axis: (min: 0, max: error-data.map(h => h.at(0).len()).max()),
  //   y-axis: (min: 0, max: 1),
  //   error-data,
  // )
  
  if check-convergence(dphifunc, a, b) {
    [Метод простой итерации сходится на данном отрезке.]
  } else {
    [Метод простой итерации не сходится на данном отрезке.]
  }
} 