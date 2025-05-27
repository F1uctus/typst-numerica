#import "@preview/cetz:0.3.4"
#import "@preview/cetz-plot:0.1.1": plot, chart
#import "@preview/diverential:0.2.0": *


#let SURNAME_NAME = "Никитин Илья"
#let UNN_GROUP = "3822Б1МА1"
// #let n = 21
#let n = -2

#set page(
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
#show heading: it => grid(
  columns: (1fr, auto, 1fr),
  align: horizon + center,
  column-gutter: 5pt,
  line(length: 100%), it.body, line(length: 100%),
)
#show table.cell.where(y: 0): strong
#set table(
  align: horizon + center,
  stroke: gray + 0.2mm,
  inset: 0.5em,
  columns: 5,
)
#set par(justify: true)
#let hl(eqtn) = rect(
  stroke: gray,
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
#let ITERATIONS = 2
#let dashes = ("solid", "densely-dotted", "dash-dotted", "dotted")
#let f(x, y) = y - x
#let y0 = n + 4
#let h = 1
#let x0 = 0
#let xs = range(ITERATIONS + 1).map(k => x0 + k * h)

#let plot-comparison(body) = cetz.canvas({
  import plot: *
  cetz.draw.set-style(
    axes: (
      stroke: (dash: "dotted", paint: gray),
      tick: (stroke: gray + .5pt),
    ),
  )
  body
})

Выполнить два шага с $h = 1$ методом Эйлера и его модификациями. Показать геометрическую интерпретацию методов для двух шагов.

// #let cexact = 24
#let C = 1
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

#let ys = (y0,)
#let cs = (C,)
#let yfs = (y,)
#let slope(xs, ys, k, x) = (x - h * k) * f(xs.at(k), ys.at(k)) + ys.at(k)
#for k in range(ITERATIONS) {
  ys.push(ys.at(k) + h * f(xs.at(k), ys.at(k)))
  cs.push((ys.at(k + 1) - xs.at(k + 1) - 1))
  yfs.push(x => x + 1 + cs.at(k + 1) * calc.exp(x - xs.at(k + 1)))
}

#{
  align(center + horizon)[
    #table(
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
    )
  ]
  for k in range(1, ITERATIONS) {
    $
      y_#(h * k)
      = #xs.at(k) + 1 + C e^#xs.at(k)
      = #ys.at(k)
      quad ==> quad
      C
      = (#ys.at(k) - #xs.at(k) - 1) / e^#xs.at(k)
      = #cs.at(k) e^(-#xs.at(k))
      , quad
      #hl($
        y_#(h * k) = x + 1 + #cs.at(k) e^(x - #k)
      $)
    $
  }
}

#align(
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
          style: (stroke: (dash: dashes.at(k))),
        )
        add(
          slope.with(xs, ys, k),
          domain: (0, h * ITERATIONS),
        )
      },
    )
    for k in range(1, ITERATIONS) {
      cetz.draw.circle("plt1.x" + str(k), radius: .08, fill: black, stroke: none)
    }
  }),
)


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

#pagebreak(weak: true)

Первая модификация метода:
$quad x_(k + 1 / 2) = x_0 + h / 2 k,
  quad y_(k + 1 / 2) = y_k + h / 2 f(x_k, y_k),
  quad y_(k + 1) = y_k + h f(x_(k + 1 / 2), y_(k + 1 / 2)).$

#let x2 = range(ITERATIONS + 1).map(k => xs.at(k) + 1 / 2 * h)
#let y2 = range(ITERATIONS + 1).map(k => ys.at(k) + h / 2 * f(xs.at(k), ys.at(k)))
#let ys = (y0,)
#let cs = (1.5,)
#let yfs = (y,)
#let dyfs = (dy,)
#for k in range(ITERATIONS) {
  ys.push(ys.at(k) + h * f(x2.at(k), y2.at(k)))
  cs.push(y2.at(k + 1) - x2.at(k + 1) - 1)
  yfs.push(x => x + 1 + cs.at(k) * calc.exp(x - x2.at(k)))
  dyfs.push(x => 1 + cs.at(k) * calc.exp(x - x2.at(k)))
}

#{
  align(center + horizon)[
    #table(
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
    )
  ]
  for k in range(ITERATIONS) {
    $
      y_#x2.at(k)
      = #x2.at(k) + 1 + C e^#x2.at(k)
      = #y2.at(k)
      thick ==> thick
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
    plot(
      name: "plt2",
      size: (17, 15),
      x-grid: true,
      x-tick-step: h / 2,
      y-grid: true,
      y-tick-step: 1,
      axis-style: "school-book",
      {
        for k in range(ITERATIONS + 1) {
          add(
            yfs.at(k),
            domain: (0, h * ITERATIONS),
            style: (stroke: (dash: dashes.at(k))),
          )
        }
        for k in range(ITERATIONS) {
          let a = h * k
          add(
            x => (x - a) * f(xs.at(k), ys.at(k)) + ys.at(k),
            domain: (a, a + h / 2),
          )
          let a = h * k + h / 2
          add(
            x => (x - a) * dyfs.at(k)(x2.at(k)) + y2.at(k),
            domain: (a, a + h / 2),
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

#grid(
  columns: (1fr, 1fr),
  {
    align(center + horizon)[
      #table(
        table.header[$k$][$x_k$][$y_k$][$y^*_k$][$Delta_k$],
        ..range(xs.len())
          .map(k => (
            k,
            xs.at(k),
            ys.at(k),
            xs.map(y).at(k),
            calc.abs(ys.at(k) - y(xs.at(k))),
          ).map(a => $calc.round(#a, digits: PREC)$))
          .flatten()
      )
    ]
    for k in range(1, ITERATIONS) {
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
  },
  align(
    center,
    plot-comparison({
      import plot: *
      plot(
        name: "plt",
        size: (7, 25),
        x-grid: true,
        x-tick-step: h,
        y-grid: true,
        axis-style: "school-book",
        for k in range(ITERATIONS) {
          add-anchor("x" + str(k), (xs.at(k), slope.with(xs, ys, k)(xs.at(k))))
          add(
            yfs.at(k),
            domain: (0, h * ITERATIONS),
            style: (stroke: (dash: dashes.at(k))),
          )
          add(
            slope.with(xs, ys, k),
            domain: (h * k, h * (k + 1)),
          )
        },
      )
      for k in range(1, ITERATIONS) {
        cetz.draw.circle("plt.x" + str(k), radius: .08, fill: black, stroke: none)
      }
    }),
  ),
)
