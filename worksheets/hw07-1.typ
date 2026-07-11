#import "@preview/cetz:0.3.4"
#import "@preview/cetz-plot:0.1.1": plot, chart
#import "../src/theme.typ": theme


#let SURNAME_NAME = "Никитин Илья"
#let UNN_GROUP = "3822Б1МА1"
#let n = 21


#set page(
  fill: theme.bg,
  paper: "a4",
  margin: (top: 3em, rest: 0.8cm),
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
  line(length: 100%, stroke: theme.stroke),
  it.body,
  line(length: 100%, stroke: theme.stroke),
)
#set table(
  align: horizon + center,
  stroke: theme.stroke-muted + 0.2mm,
)
#set par(justify: true)

#let round(x) = calc.round(x, digits: 4)
#let tick-fmt(v) = { set text(size: 9pt); v }


//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
=== Задание 1
#let ITERATIONS = 3
#let PREC = 10
#let f(x, y) = y - x
#let x0 = 0
#let xend = 0.2
#let y0 = n + 4
#let h = 1

#let plot-comparison(plot-block, y-step: 1) = cetz.canvas({
  import plot: *
  cetz.draw.set-style(axes: (
    stroke: (dash: "dotted", paint: theme.plot-stroke),
    tick: (stroke: theme.plot-stroke + .5pt),
  ))
  plot(
    name: "plt",
    size: (7, 9.5),
    x-grid: true,
    x-label: $x$,
    x-tick-step: h,
    y-grid: true,
    y-label: none,
    mark: "o",
    axis-style: "school-book",
    for k in range(ITERATIONS) {
      plot-block(k)
    }
  )
  for k in range(1, ITERATIONS) {
    cetz.draw.circle("plt.x" + str(k), radius: .08, fill: theme.stroke, stroke: none)
  }
})

Выполнить два шага с $h = 1$ методом Эйлера и его модификациями. Показать геометрическую интерпретацию методов для двух шагов. 

$ y' = y - x, quad
  y(0) = n + 4 = y0, quad
  h = #h thin. $

#grid(
  columns: (auto, 1fr),
  gutter: 1em,
  [Решим аналитически:],
  {
    show math.equation: set align(left)
    $ y' = y - x quad ==> quad y(x) = x + 1 + C e^x, \
      y(0) = 1 + C e^0 = 25 quad ==>
      quad C = 24, quad y(x) = x + 1 + 24 e^x. $
  }
)

#let yexact = (
  math: $x + 1 + 24 * e^x$,
  code: x => x + 1 + 24 * calc.exp(x),
)

Классический метод Эйлера:
$quad x_k = x_0 + h k,
quad y_(k + 1) = y_k + h f(x_k, y_k). $

#let xs = range(ITERATIONS + 1).map(k => x0 + k * h)
#let ys = (y0,)
#let cs = (24,)
#let yfs = (yexact,)
#let dashes = (
  "solid",
  "densely-dotted",
  "dash-dotted",
  "dotted",
)
#for k in range(ITERATIONS) {
  ys.push(ys.at(k) + h * f(xs.at(k), ys.at(k)))
  cs.push((ys.at(k + 1) - xs.at(k + 1) - 1) / calc.exp(xs.at(k + 1)))
  yfs.push((
    math: $x + 1 + #cs.at(k + 1) * e^x$,
    code: x => x + 1 + cs.at(k + 1) * calc.exp(x)
  ))
}

#grid(columns: (1fr, 1fr), {
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
           xs.map(yexact.code).at(k),
           calc.abs(ys.at(k) - (yexact.code)(xs.at(k)))
         )
         .map(a => $#a$)
       )
       .flatten()
    )
  ]
  for k in range(1, ITERATIONS) {
    $ y#(h * k)
    = #xs.at(k) + 1 + C e^#xs.at(k)
    = #ys.at(k)
    ==> \ \ ==>
    C
    = (#ys.at(k) - #xs.at(k) - 1) / e^#xs.at(k)
    = #cs.at(k),
    \ \
    y_#(h * k)
    = x + 1 + #cs.at(k) e^x
    $
  }
},{
  align(center, plot-comparison(k => {
    plot.add-anchor("x" + str(k), (xs.at(k), ys.at(k)))
    plot.add(
      yfs.at(k).code,
      domain: (0, h * ITERATIONS),
      style: (stroke: (dash: dashes.at(k))),
    )
    plot.add(
      xx => (xx - h * k) * f(xs.at(k), ys.at(k)) + ys.at(k),
      domain: (h * k, h * (k + 1)),
    )
  }))
})
  
#let error-classic = calc.abs(ys.at(-1) - (yexact.code)(xs.at(-1)))


Решим 1-й модификацией метода:
$quad x_(k + 1/2) = x_0 + h/2 k,
quad y_(k + 1/2) = y_k + h/2 f(x_k, y_k),
quad y_(k + 1) = y_k + h f(x_(k + 1/2), y_(k + 1/2)). $

#let x = range(ITERATIONS + 1).map(k => x0 + h * k)
#let x2 = range(ITERATIONS + 1).map(k => xs.at(k) + 1/2 * h)
#let y = (y0,)
#let y2 = ()
#for k in range(ITERATIONS + 1) {
  y2.push(ys.at(k) + h/2 * f(xs.at(k), ys.at(k)))
  y.push(ys.at(k) + h * f(x2.at(k), y2.at(k)))
}

#columns(2, {
  show table.cell.where(y: 0): strong
  align(center)[
    #v(1.8em)
    #table(
      inset: 0.5em,
      columns: 7,
      table.header[$k$][$x_k$][$x_(k+1/2)$][$y_(k+1/2)$][$y_k$][$y^*_k$][$Delta_k$],
      ..range(x.len())
       .map(k => (
           k,
           xs.at(k),
           x2.at(k),
           y2.at(k),
           ys.at(k),
           x.map(yexact.code).at(k),
           calc.abs(ys.at(k) - (yexact.code)(xs.at(k)))
         )
         .map(a => $#calc.round(a, digits: 5)$)
       )
       .flatten()
    )
  ]
  colbreak()
  align(center, plot-comparison(k => {
        for k in range(ITERATIONS) {
      plot.add-anchor("x" + str(k), (xs.at(k), ys.at(k)))}
    plot.add(yexact.code, domain: (0, h * ITERATIONS))
    plot.add(
      x.zip(y),
      mark: "o",
      mark-size: 0.1,
      mark-style: (stroke: none, fill: theme.stroke),
    )
  }))
})

#let error-mod-1 = calc.abs(ys.at(-2) - (yexact.code)(xs.at(-1)))


Решим 2-й модификацией метода:
$quad y_(k + 1) = y_k + h/2 (f(x_k, y_k) + f(x_(k+1), y_k + h f(x_k, y_k))). $

#let x = range(ITERATIONS + 1).map(k => x0 + k * h)
#let y = (y0,)
#for k in range(ITERATIONS) {
  y.push(ys.at(k) + h/2 * (
    f(xs.at(k), ys.at(k)) +
    f(xs.at(k + 1), ys.at(k) + h * f(xs.at(k), ys.at(k)))
  ))
}

#columns(2, {
  show table.cell.where(y: 0): strong
  align(center)[
    #v(1.8em)
    #table(
      inset: 0.5em,
      columns: 5,
      table.header[$k$][$x_k$][$y_k$][$y^*_k$][$Delta_k$],
      ..range(x.len())
       .map(k => (
           k,
           xs.at(k),
           ys.at(k),
           x.map(yexact.code).at(k),
           calc.abs(ys.at(k) - (yexact.code)(xs.at(k)))
         )
         .map(a => $calc.round(#a, digits: PREC)$)
       )
       .flatten()
    )
  ]
  colbreak()
  align(center, plot-comparison(k => {
            for k in range(ITERATIONS) {
      plot.add-anchor("x" + str(k), (xs.at(k), ys.at(k)))}
    plot.add(yexact.code, domain: (0, h * ITERATIONS))
    plot.add(
      x.zip(y),
      mark: "o",
      mark-size: 0.1,
      mark-style: (stroke: none, fill: theme.stroke),
    )
  }))
})