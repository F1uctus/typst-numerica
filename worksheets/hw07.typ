#import "@preview/cetz:0.3.4"
#import "@preview/cetz-plot:0.1.1": plot, chart
#import "@preview/diverential:0.2.0": *
#import "../src/theme.typ": theme, themed-axes, themed-axes-grid, themed-legend, themed-stroke


#let SURNAME_NAME = "Никитин Илья"
#let UNN_GROUP = "3822Б1МА1"
#let n = 21

#set page(
  fill: theme.bg,
  paper: "a4",
  margin: (top: 3em, rest: 1cm),
  numbering: "1 / 1",
  header: [
    ДЗ.07. Геометрическая интерпретация метода Эйлера и его модификаций.
    #h(1fr)
    #eval(mode: "math", "n = " + repr(n))
    #h(1fr)
    #SURNAME_NAME, #UNN_GROUP
  ],
)
#set text(fill: theme.text)
#show heading: it => grid(
  columns: (1fr, auto, 1fr),
  align: horizon + center,
  column-gutter: 5pt,
  line(length: 100%, stroke: theme.stroke), it.body, line(length: 100%, stroke: theme.stroke),
)
#show table.cell.where(y: 0): strong
#set table(
  align: horizon + center,
  stroke: theme.stroke-muted + 0.2mm,
  inset: 0.5em,
  columns: 5,
)
#set par(justify: true)
#let hl(eqtn) = rect(
  stroke: theme.stroke-muted,
  inset: (top: 10pt, bottom: 10pt, left: 5pt, right: 5pt),
  $display(eqtn.body)$,
)

#let round(x) = calc.round(x, digits: 4)
#let tick-fmt(v) = {
  set text(size: 9pt)
  v
}


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

=== Задание 1
#let PREC = 10
#let ITERATIONS = 1
#let dashes = ("solid", "densely-dotted", "dash-dotted", "dotted")
#let annot-dashes = ("dashed", "dotted", "dash-dotted", "densely-dotted", "solid", "densely-dashed")
#let f(x, y) = y - x
#let y0 = n + 4
#let h = 1
#let x0 = 0
#let xs = range(ITERATIONS + 1).map(k => x0 + k * h)

#let plot-comparison(body) = cetz.canvas({
  import plot: *
  cetz.draw.set-style(
    axes: (
      stroke: (dash: "dotted", paint: theme.plot-stroke),
      tick: (stroke: theme.plot-stroke + .5pt),
    ),
    legend: themed-legend,
  )
  body
})

Выполнить два шага с $h = 1$ методом Эйлера и его модификациями. Показать геометрическую интерпретацию методов для двух шагов.

#let C = n + 3
#let y = x => x + 1 + C * calc.exp(x)
#let dy = x => 1 + C * calc.exp(x)

$
  y' = y - x, quad
  y(0) = n + 4 = y0, quad
  h = #h thin.
$

#grid(
  columns: (auto, 1fr),
  gutter: 1em,
  [Решим аналитически:],
  {
    show math.equation: set align(left)
    $
      y' = y - x quad ==> quad y(x) = x + 1 + C e^x, \
      y(0) = 1 + C e^0 = 25 quad ==>
      quad C = #C, quad y(x) = x + 1 + #C e^x.
    $
  },
)

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

Классический метод Эйлера:
$quad x_k = x_0 + h k,
  quad y_(k + 1) = y_k + h f(x_k, y_k).$

#{
  let ITERATIONS = 2
  let xs = range(ITERATIONS + 1).map(k => x0 + k * h)
  let y = (
    math: $x + 1 + #C * e^x$,
    code: x => x + 1 + C * calc.exp(x),
  )
  let ys = (y0,)
  let cs = (C,)
  let yfs = (y,)
  let dashes = ("solid", "densely-dotted", "dash-dotted", "dotted")
  for k in range(ITERATIONS) {
    ys.push(ys.at(k) + h * f(xs.at(k), ys.at(k)))
    cs.push((ys.at(k + 1) - xs.at(k + 1) - 1) / calc.exp(xs.at(k + 1)))
    yfs.push((
      math: $x + 1 + #cs.at(k + 1) * e^x$,
      code: x => x + 1 + cs.at(k + 1) * calc.exp(x),
    ))
  }

  show table.cell.where(y: 0): strong
  align(center)[
    #v(1.5em)
    #table(
      inset: 0.5em,
      columns: 5,
      table.header[$k$][$x_k$][$y_k$][$y^*_k$][$Delta_k$],
      ..range(xs.len())
        .map(k => (
          k,
          xs.at(k),
          ys.at(k),
          xs.map(y.code).at(k),
          calc.abs(ys.at(k) - (y.code)(xs.at(k))),
        ).map(a => $#a$))
        .flatten()
    )
  ]
  for k in range(1, ITERATIONS) {
    $
      y_#(h * k)
    = #xs.at(k) + 1 + C e^#xs.at(k)
    = #ys.at(k)
    ==>
    C
    = (#ys.at(k) - #xs.at(k) - 1) / e^#xs.at(k)
    = #cs.at(k),
    quad
    y_#(h * k)
    = x + 1 + #cs.at(k) e^x
    $
  }
  align(
    center,
    cetz.canvas({
      import plot: *
      cetz.draw.set-style(
        axes: (
          stroke: (dash: "dotted", paint: theme.plot-stroke),
          tick: (stroke: theme.plot-stroke + .5pt),
        ),
        legend: themed-legend,
      )
      plot(
        name: "plt",
        size: (15, 13),
        x-grid: true,
        x-label: $x$,
        x-tick-step: h,
        y-grid: true,
        y-label: none,
        mark: "o",
        axis-style: "school-book",
        legend: "south",
        for k in range(ITERATIONS) {
          add-anchor("x" + str(k), (xs.at(k), ys.at(k)))
          add(
            yfs.map(f => f.code).at(k),
            domain: (0, h * ITERATIONS),
            style: (stroke: (dash: dashes.at(k), paint: theme.stroke)),
            label: $space #if k == 0 {$y$} else {$y^*_#(h * k)$}$,
          )
          add(
            xx => (xx - h * k) * f(xs.at(k), ys.at(k)) + ys.at(k),
            domain: (h * k, h * (k + 1)),
            style: themed-stroke("dashed"),
          )
        },
      )
      for k in range(1, ITERATIONS) {
        cetz.draw.circle("plt.x" + str(k), radius: .08, fill: theme.stroke, stroke: none)
      }
    }),
  )

  let error-classic = calc.abs(ys.at(-1) - (y.code)(xs.at(-1)))
}

#pagebreak(weak: true)

#let ignored() = align(
  center,
  plot-comparison({
    import plot: *
    plot(
      name: "plt1",
      size: (17, 15),
      x-grid: true,
      x-tick-step: h,
      y-grid: true,
      axis-style: "school-book",
      for k in range(ITERATIONS) {
        add-anchor("x" + str(k), (xs.at(k), slope.with(xs, ys, k)(xs.at(k))))
        add(
          yfs.at(k),
          domain: (0, h * ITERATIONS),
          style: (stroke: (dash: dashes.at(k), paint: theme.stroke)),
        )
        add(
          slope.with(xs, ys, k),
          domain: (0, h * ITERATIONS),
          style: (stroke: (dash: annot-dashes.at(k), paint: theme.stroke)),
        )
      },
    )
    for k in range(1, ITERATIONS) {
      cetz.draw.circle("plt1.x" + str(k), radius: .08, fill: theme.stroke, stroke: none)
    }
  }),
)


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

#pagebreak(weak: true)

#let ys = (y0,)
#let cs = (C,)
#let yfs = (y,)
#let slope(xs, ys, k, x) = (x - h * k) * f(xs.at(k), ys.at(k)) + ys.at(k)
#for k in range(ITERATIONS) {
  ys.push(ys.at(k) + h * f(xs.at(k), ys.at(k)))
  cs.push((ys.at(k + 1) - xs.at(k + 1) - 1))
  yfs.push(x => x + 1 + cs.at(k + 1) * calc.exp(x - xs.at(k + 1)))
}

Первая модификация метода:
$quad x_(k + 1 / 2) = x_0 + h / 2 k,
  quad y_(k + 1 / 2) = y_k + h / 2 f(x_k, y_k),
  quad y_(k + 1) = y_k + h f(x_(k + 1 / 2), y_(k + 1 / 2)).$

#let x2 = range(ITERATIONS + 1).map(k => xs.at(k) + 1 / 2 * h)
#let y2 = range(ITERATIONS + 1).map(k => ys.at(k) + h / 2 * f(xs.at(k), ys.at(k)))
#let ys = (y0,)
#let cs = (1.5 * C,)
#let yfs = (y,)
#let dyfs = (dy,)
#for k in range(ITERATIONS) {
  ys.push(ys.at(k) + h * f(x2.at(k), y2.at(k)))
  cs.push(y2.at(k + 1) - x2.at(k + 1) - 1)
  yfs.push(x => x + 1 + cs.at(k) * calc.exp(x - x2.at(k)))
  dyfs.push(x => 1 + cs.at(k) * calc.exp(x - x2.at(k)))
}

#{
  align(
    center,
    table(
      columns: 7,
      table.header[$k$][$x_k$][$x_(k+1 / 2)$][$y_(k+1 / 2)$][$y_k$][$y^*_k$][$Delta_k$],
      ..range(xs.len())
        .map(k => (
          k,
          xs.at(k),
          x2.at(k),
          y2.at(k),
          ys.at(k),
          xs.map(y).at(k),
          calc.abs(ys.at(k) - y(xs.at(k))),
        ).map(a => $#a$))
        .flatten()
    ),
  )
  for k in range(ITERATIONS) {
    $
      y_#x2.at(k)
      = #x2.at(k) + 1 + C e^#x2.at(k)
      = #y2.at(k)
      quad ==> quad
      C
      = (#y2.at(k) - #x2.at(k) - 1) / e^#x2.at(k)
      = #cs.at(k) e^(-#x2.at(k)),
      \ \
      #hl($
        y_#x2.at(k) = x + 1 + #cs.at(k) e^(x - #x2.at(k))
      $)
    $
  }
}

#align(
  center,
  plot-comparison({
    import plot: *
    let labels = (
      $y^*_k$,
      ..range(ITERATIONS).map(k => $y_#(h * (k + 1/2))$),
    ).map(strong)
    plot(
      name: "plt2",
      size: (17, 15),
      x-grid: true,
      x-tick-step: h / 2,
      y-grid: true,
      axis-style: "school-book",
      legend: "south",
      {
        for k in range(ITERATIONS + 1) {
          add(
            yfs.at(k),
            domain: if k == 0 {
              (0, h * ITERATIONS)
            } else {
              (h * (k - 1), h * k)
            },
            style: (stroke: (dash: dashes.at(k), paint: theme.stroke)),
            label: labels.at(k),
          )
        }
        for k in range(ITERATIONS) {
          let a = h * k
          add(
            x => (x - a) * f(xs.at(k), ys.at(k)) + ys.at(k),
            domain: (a, a + h / 2),
            label: $1$,
            style: themed-stroke(annot-dashes.at(0)),
          )
          let a = h * k + h / 2
          add(
            x => (x - a) * dyfs.at(k)(x2.at(k)) + y2.at(k),
            domain: (a, a + h / 2),
            label: $2$,
            style: themed-stroke(annot-dashes.at(1)),
          )
          let a = h * k
          add(
            x => (x - a) * dyfs.at(k)(x2.at(k)) + ys.at(k),
            domain: (a, a + h),
            label: $3$,
            style: themed-stroke(annot-dashes.at(2)),
          )
        }
      },
    )
  }),
)


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

#pagebreak(weak: true)

Вторая модификация метода:
$quad y_(k + 1) = y_k + h / 2 (f(x_k, y_k) + f(x_(k+1), y_k + h f(x_k, y_k))).$

#let ys = (y0,)
#let cs = (C,)
#let yfs = (y,)
#let slope(xs, ys, k, x) = (x - h * k) * f(xs.at(k), ys.at(k)) + ys.at(k)
#for k in range(ITERATIONS) {
  let m = f(xs.at(k), ys.at(k)) + f(xs.at(k + 1), ys.at(k) + h * f(xs.at(k), ys.at(k)))
  ys.push(ys.at(k) + h / 2 * m)
  cs.push((ys.at(k + 1) - xs.at(k + 1) - 1))
  yfs.push(x => x + 1 + cs.at(k + 1) * calc.exp(x - xs.at(k + 1)))
}

#let dashes = ("solid", "densely-dotted", "dash-dotted", "dotted")
#for k in range(ITERATIONS) {
  ys.push(ys.at(k) + h * f(xs.at(k), ys.at(k)))
  cs.push((ys.at(k + 1) - xs.at(k + 1) - 1) / calc.exp(xs.at(k + 1)))
  yfs.push((
    math: $x + 1 + #cs.at(k + 1) * e^x$,
    code: x => x + 1 + cs.at(k + 1) * calc.exp(x),
  ))
}

#align(
  center,
  table(
    table.header[$k$][$x_k$][$y_k$][$y^*_k$][$Delta_k$],
    ..range(xs.len())
      .map(k => (
        k,
        xs.at(k),
        ys.at(k),
        xs.map(y).at(k),
        calc.abs(ys.at(k) - y(xs.at(k))),
      ).map(a => $#a$))
      .flatten()
  ),
)
#for k in range(1, ITERATIONS + 1) {
  $
    y_#(h * k)
    = #xs.at(k) + 1 + C e^#xs.at(k)
    = #ys.at(k)
    thick ==> thick
    C
    = (#ys.at(k) - #xs.at(k) - 1) / e^#xs.at(k)
    = #cs.at(k) e^(-#xs.at(k)),
    \ \
    #hl($
      y_#(h * k) = x + 1 + #cs.at(k) e^(x - #k)
    $)
  $
}
#align(
  center,
  plot-comparison({
    import plot: *
    plot(
      name: "plt",
      size: (17, 15),
      x-grid: true,
      x-tick-step: h / 2,
      y-grid: true,
      axis-style: "school-book",
      legend: "south",
      {
        add(
          y,
          domain: (0, h * ITERATIONS + h / 2),
          style: (stroke: (dash: dashes.at(0), paint: theme.stroke)),
          label: $y$,
        )
        let y = y0 + h * f(x0, y0)
        let c = (y - xs.at(1) - 1) / calc.exp(xs.at(1))
        let ang = f(xs.at(1), ys.at(1)) - C / 2
        add(
          x => x + 1 + c * calc.exp(x),
          domain: (0, h * ITERATIONS + h / 2),
          style: (stroke: (dash: dashes.at(0), paint: theme.stroke)),
          label: $x + 1 + #(c * calc.e) e^(x - 1)$,
        )
        add(
          x => x * ang + y0,
          domain: (0, h + h / 2),
          style: themed-stroke(annot-dashes.at(2)),
          label: $3$,
        )
        add(
          slope.with(xs, ys, 0),
          domain: (0, h + h / 2),
          style: themed-stroke(annot-dashes.at(3)),
          label: $4$,
        )
        add(
          x => (x - h) * ang / 0.6 + 2 + c * calc.e,
          domain: (0, h + h / 2),
          style: themed-stroke(annot-dashes.at(4)),
          label: $5$,
        )
        add(
          x => (x - h) * ang + 2 + c * calc.e,
          domain: (0, h + h / 2),
          style: themed-stroke(annot-dashes.at(5)),
          label: $6$,
        )
        add-anchor("x1", (1, 50))
      },
    )
    cetz.draw.circle("plt.x1", radius: .08, fill: theme.stroke, stroke: none)
  }),
)
