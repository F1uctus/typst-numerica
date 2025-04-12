#import "@preview/cetz:0.3.4"
#import "@preview/cetz-plot:0.1.1": plot, chart

#let SURNAME_NAME = "Никитин Илья"
#let UNN_GROUP = "3822Б1МА1"
#let n = 21
#let PLOT_SCALE = 6.5
#let ITERATIONS = 5
#let PREC = 3

#set page(
  paper: "a4",
  margin: (top: 3em, bottom: 1cm, rest: 0.5cm),
  numbering: "1 / 1",
  header: [
    ДЗ.01. Геометрическая интепретация метода Якоби и метода Зейделя.
    #h(1fr)
    #eval(mode: "math", "n = " + repr(n))
    #h(1fr)
    #SURNAME_NAME, #UNN_GROUP
  ],
  columns: 2,
)
#set columns(gutter: 0.5cm)

#show heading: it => box(inset: (bottom: 2mm))[
  #grid(
    columns: (1fr, auto, 1fr),
    align: horizon + center,
    column-gutter: 5pt,
    line(length: 100%),
    it.body,
    line(length: 100%),
  )
]

#let point-to-id(p) = p.map(n => calc.round(n, digits: 4)).map(str).map(n => n.replace(".", "_")).join()

#let show-table(points) = {
  show table.cell.where(x: 0): strong
  align(center, table(
    columns: (1fr, ..points.map(_ => 1fr)),
    stroke: gray + 0.2mm,
    $k$, ..range(points.len()).map(str).map(math.equation),
    $x_1$, ..points.map(x => str(calc.round(x.at(0), digits: PREC))),
    $x_2$, ..points.map(x => str(calc.round(x.at(1), digits: PREC))),
  ))
}

#let show-plot(points, l1, l2) = {
  let plot-name = "plt" + points.map(p => str(int(p.at(0))) + str(int(p.at(1)))).join()
  let min-x = calc.min(..points.map(p => p.at(0)))
  let max-x = calc.max(..points.map(p => p.at(0)))
  align(center, cetz.canvas({
    cetz.draw.set-style(axes: (
      stroke: (paint: gray, dash: "solid", thickness: 0.1mm),
      tick: (stroke: gray + .5pt),
    ))
    plot.plot(
      name: plot-name,
      size: (PLOT_SCALE, PLOT_SCALE),
      x-label: $x_1$,
      y-label: $x_2$,
      axis-style: "school-book",
      x-format: v => { set text(size: 8pt); v },
      y-format: v => { set text(size: 8pt); v },
      {
        plot.add(l1, domain: (min-x, max-x))
        plot.add-anchor("l1", (max-x, l1(max-x)))
        plot.add(l2, domain: (min-x, max-x))
        plot.add-anchor("l2", (max-x, l2(max-x)))
        plot.add(
          points,
          mark: "o",
          mark-size: 0.1,
          style: (stroke: (paint: gray, dash: "dotted", thickness: 0.2mm))
        )
        for (k, p) in points.enumerate() {
          plot.add-anchor("x" + str(k), p)
          plot.add-anchor("x_" + point-to-id(p), p)
        }
      }
    )
    cetz.draw.content(plot-name + ".l1", $l_1$, anchor: "north-east")
    cetz.draw.content(plot-name + ".l2", $l_2$, anchor: "south-east")
    for i in range(points.len() - 1) {
      cetz.draw.line(
        plot-name + ".x" + str(i),
        plot-name + ".x" + str(i + 1),
        stroke: (paint: gray, dash: "dashed", thickness: 0.2mm),
      )
      cetz.draw.rect(
        plot-name + ".x" + str(i), 
        plot-name + ".x" + str(i + 1),
        stroke: (paint: gray, dash: "dotted", thickness: 0.2mm),
      )
    }
    let labels = (:)
    for (k, p) in points.enumerate() {
      let (key, val) = (point-to-id(p), str(k))
      if key in labels {
        labels.at(key).push(val)
      } else {
        labels.insert(key, (val,))
      } 
    }
    for (anchor, texts) in labels {
      cetz.draw.content(
        plot-name + ".x_" + anchor,
        eval(mode: "math", "x_(" + texts.intersperse(";").join() + ")"),
        anchor: "north-east",
        padding: 0,
      )
    }
  }))
}

//////////////////////////////////////////////////

// x^(k+1)_1 = (b1 + A12 * x^(k)_2) / A11
// x^(k+1)_2 = (b2 + A11 * x^(k)_1) / A22
#let solve-jacobi(A, b, x0) = {
  let history = (x0,)
  for _ in range(0, ITERATIONS) {
    let x1 = b.at(0) + A.at(0).at(1) * history.at(-1).at(1)
    let x2 = b.at(1) + A.at(1).at(0) * history.at(-1).at(0)
    history.push((x1, x2))
  }
  history
}

// x^(k+1)_1 = (b1 + A12 * x^(k)_2) / A11
// x^(k+1)_2 = (b2 + A11 * x^(k+1)_1) / A22
#let solve-gauss-seidel(A, b, x0) = {
  let history = (x0,)
  for _ in range(0, ITERATIONS) {
    let x1 = b.at(0) + A.at(0).at(1) * history.at(-1).at(1)
    let x2 = b.at(1) + A.at(1).at(0) * x1
    history.push((x1, x2))
  }
  history
}

//////////////////////////////////////////////////
=== Задание 1
#{
  let A1 = ((1, 1.5), (1, -2))
  let f1 = (0.5, -3)
  let x01 = (n, n + 3)

  let A1aux = ((0, -1.5), (0.5, 0))
  let f1aux = (0.5, 1.5)

  $A = mat(..A1), quad$
  eval(mode: "math", "f = vec" + repr(f1) + ", quad")
  eval(mode: "math", "x^\"(0)\" = vec" + repr(x01) + ".")

  $ cases(
    x_1 = (-3 x_2 + 1) ⁄ 2 \
    x_2 = (   x_1 + 3) ⁄ 2
  ), thick
  alpha = mat(..A1aux), thick
  beta = vec(0.5, 1.5). $

  [Критерий сходимости МПИ *выполняется*:]
  box(height: 4em, align(horizon+center,
    $ det mat(
        -lambda, -1.5;
        0.5, -lambda
      ) = lambda^2 + 3/4 = 0 ==>
      abs(lambda_(1,2)) = abs(plus.minus sqrt(3)/2 i) < 1.
    $
  ))

  [Метод Якоби:]
  $quad bold(x)^"(k+1)" = alpha bold(x)^"(k)" + beta,$

  let history = solve-jacobi(A1aux, f1aux, x01)
  show-table(history)
  show-plot(
    history, 
    x => ((x * 2) - 1) / -3,
    x => (x + 3) / 2,
  )

  [Метод Гаусса-Зейделя:]
  $quad bold(x)^"(k+1)" = alpha vec(x_1^"(k+1)", x_2^"(k)") + beta,$

  let history = solve-gauss-seidel(A1aux, f1aux, x01)
  show-table(history)
  show-plot(
    history,
    x => ((x * 2) - 1) / -3,
    x => (x + 3) / 2,
  )
}

//////////////////////////////////////////////////
#colbreak()
=== Задание 2
#{
  let A2 = ((3, 2), (3, -2))
  let f2 = (-1, -5)
  let x02 = (n, n + 4)

  let A2aux = ((0, -2/3), (3/2, 0))
  let f2aux = (-1/3, 5/2)

  $A = mat(..A2), quad$
  eval(mode: "math", "f = vec" + repr(f2) + ", quad")
  eval(mode: "math", "x^\"(0)\" = vec" + repr(x02))

  $ cases(
    x_1 = (-2 x_2 - 1) ⁄ 3 \
    x_2 = ( 3 x_1 + 5) ⁄ 2
  ), thick
  alpha = mat(0, -2 slash 3; 3 slash 2, 0), thick
  beta = vec(-1 slash 3, 2.5) $

  [Критерий сходимости МПИ *не выполняется*:]
  box(height: 4em, align(horizon+center,
    $ det mat(
        -lambda, -2 slash 3;
        3 slash 2, -lambda
      ) = lambda^2 + 1 = 0 ==>
      abs(lambda_(1,2)) = abs(plus.minus i) = 1.
    $
  ))

  [Метод Якоби:]
  $quad bold(x)^"(k+1)" = alpha bold(x)^"(k)" + beta,$

  let history = solve-jacobi(A2aux, f2aux, x02)
  show-table(history)
  show-plot(
    history,
    x => ((x * 3) + 1) / -2,
    x => (3 * x + 5) / 2,
  )

  [Метод Гаусса-Зейделя:]
  let history = solve-gauss-seidel(A2aux, f2aux, x02)
  show-table(history)
  show-plot(
    history,
    x => ((x * 3) + 1) / -2,
    x => (3 * x + 5) / 2,
  )
}

//////////////////////////////////////////////////
#pagebreak()
=== Задание 1 (обращённый порядок уравнений)
#{
  let A1 = ((1, -2), (1, 1.5))
  let f1 = (-3, 0.5)
  let x01 = (n, n + 3)

  let A1aux = ((0, 2), (-2/3, 0))
  let f1aux = (-3, 1/3)
  
  $A = mat(..A1), quad$
  eval(mode: "math", "f = vec" + repr(f1) + ", quad")
  eval(mode: "math", "x^\"(0)\" = vec" + repr(x01) + ".")

  $ cases(
    x_1 = ( 2 x_2 - 3) ⁄ 1 \
    x_2 = (-2 x_1 + 1) ⁄ 3
  ), thick
  alpha = mat(0, 2; -2 slash 3, 0), thick
  beta = vec(-3, 1 slash 3). $

  [Критерий сходимости МПИ *не выполняется*:]
  box(height: 4em, align(horizon+center,
    $ det mat(
        -lambda, 2;
        -2 slash 3, -lambda
      ) = lambda^2 + 4/3 = 0 ==>
      abs(lambda_(1,2)) = abs(plus.minus 2/sqrt(3) i) > 1.
    $
  ))
  
  [Метод Якоби:]
  let history = solve-jacobi(A1aux, f1aux, x01)
  show-table(history)
  show-plot(
    history,
    x => (x + 3) / 2,
    x => (-2 * x + 1) / 3,
  )

  [Метод Гаусса-Зейделя:]
  let history = solve-gauss-seidel(A1aux, f1aux, x01)
  show-table(history)
  show-plot(
    history,
    x => (x + 3) / 2,
    x => (-2 * x + 1) / 3,
  )
}

//////////////////////////////////////////////////
#colbreak()
=== Задание 2 (обращённый порядок уравнений)
#{ 
  let A2 = ((3, -2), (3, 2))
  let f2 = (-5, -1)
  let x02 = (n, n + 4)

  let A2aux = ((0, 2/3), (-3/2, 0))
  let f2aux = (-5/3, 1/2)

  $A = mat(..A2), quad$
  eval(mode: "math", "f = vec" + repr(f2) + ", quad")
  eval(mode: "math", "x^\"(0)\" = vec" + repr(x02) + ".")

  $ cases(
    x_1 = ( 2 x_2 - 5) ⁄ 3 \
    x_2 = (-3 x_1 - 1) ⁄ 2
  ), thick
  alpha = mat(0, 2 slash 3; -3 slash 2, 0), thick
  beta = vec(-5 slash 3, -1 slash 2). $

  [Критерий сходимости МПИ *не выполняется*:]
  box(height: 4em, align(horizon+center,
    $ det mat(
        -lambda, 2 slash 3;
        -3 slash 2, -lambda
      ) = lambda^2 + 1 = 0 ==>
      abs(lambda_(1,2)) = abs(plus.minus i) = 1.
    $
  ))
  
  [Метод Якоби:]
  let history = solve-jacobi(A2aux, f2aux, x02)
  show-table(history)
  show-plot(
    history,
    x => ((x * 3) + 5) / 2,
    x => (-3 * x - 1) / 2,
  )

  [Метод Гаусса-Зейделя:]
  let history = solve-gauss-seidel(A2aux, f2aux, x02)
  show-table(history)
  show-plot(
    history,
    x => ((x * 3) + 5) / 2,
    x => (-3 * x - 1) / 2,
  )
}
