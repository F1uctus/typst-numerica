#import "@preview/cetz:0.3.4"
#import "@preview/cetz-plot:0.1.1": plot, chart

#let SURNAME_NAME = "Никитин Илья"
#let UNN_GROUP = "3822Б1МА1"
#let n = 21

#let PLOT_SCALE = 8
#set page(
  paper: "a4",
  margin: (top: 3em, rest: 1cm),
)

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

#let f(x, y, z) = z + 1 // y'' = y' + 1 => y'' = z + 1
#let g(x, y, z) = z // y' = z

#let exact(x) = calc.exp(-x) - 1

#let runge_kutta4_step(f, g, x, y, z, h) = {
  let k1y = h * g(x, y, z)
  let k1z = h * f(x, y, z)
  let k2y = h * g(x + h / 2, y + k1y / 2, z + k1z / 2)
  let k2z = h * f(x + h / 2, y + k1y / 2, z + k1z / 2)
  let k3y = h * g(x + h / 2, y + k2y / 2, z + k2z / 2)
  let k3z = h * f(x + h / 2, y + k2y / 2, z + k2z / 2)
  let k4y = h * g(x + h, y + k3y, z + k3z)
  let k4z = h * f(x + h, y + k3y, z + k3z)
  let y1 = y + (k1y + 2 * k2y + 2 * k3y + k4y) / 6
  let z1 = z + (k1z + 2 * k2z + 2 * k3z + k4z) / 6
  (y1, z1)
}

#let shoot(y0, z0, x0, x1, h) = {
  let x = x0
  let y = y0
  let z = z0
  let points = ((x, y),)
  let n = int((x1 - x0) / h)
  for i in range(0, n) {
    let (y1, z1) = runge_kutta4_step(f, g, x, y, z, h)
    x += h
    y = y1
    z = z1
    points.push((x, y))
  }
  (y, points)
}

#let boundary_shooting(y_a, y_b, x_a, x_b, h, z_guess1, z_guess2, tol: 1e-8, max_iter: 20) = {
  let F = z0 => shoot(y_a, z0, x_a, x_b, h).at(0) - y_b
  let z1 = z_guess1
  let z2 = z_guess2
  let F1 = F(z1)
  let F2 = F(z2)
  for i in range(0, max_iter) {
    let z = z2 - F2 * (z2 - z1) / (F2 - F1)
    let Fz = F(z)
    if calc.abs(Fz) < tol { return (z, shoot(y_a, z, x_a, x_b, h).at(1)) }
    z1 = z2
    F1 = F2
    z2 = z
    F2 = Fz
  }
  (z2, shoot(y_a, z2, x_a, x_b, h).at(1))
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

#let X0 = -1
#let X1 = 0
#let Y0 = calc.exp(1) - 1
#let Y1 = 0
#let H = 0.05

#let (z_sol, points) = boundary_shooting(Y0, Y1, X0, X1, H, 0.0, 2.0)

$y'' - y' = 1, quad y(-1) = e - 1, quad y(0) = 0$

Аналитическое решение:
$y = e^{-x} - 1$

=== Численное решение задачи методом стрельбы

#table(
  columns: (auto, auto, auto),
  [*"x"*], [*"y (числ.)"*], [*"y (точн.)"*],
  ..points.map(((x, y)) => [#x, #y, #exact(x)])
)

#cetz.canvas({
  plot.plot(
    size: (PLOT_SCALE * 1.2, PLOT_SCALE),
    x-label: $x$,
    y-label: $y$,
    axis-style: "school-book",
    {
      plot.add(points, mark: "o", style: (stroke: (paint: red, thickness: 0.5mm)), label: "Численное решение")
      plot.add(x => exact(x), domain: (X0, X1), style: (stroke: (paint: green, thickness: 0.5mm)), label: "Аналитическое решение")
    },
  )
})

Погрешность на правом конце: $|y_("числ")(0) - y_("точн")(0)| = #calc.abs(points.at(-1).at(1) - exact(X1))$
