#import "@preview/cetz:0.3.4"
#import "@preview/cetz-plot:0.1.1": plot, chart

#let SURNAME_NAME = "Никитин Илья"
#let UNN_GROUP = "3822Б1МА1"
#let n = 21

#set page(
  paper: "a4",
  margin: (top: 3em, bottom: 1cm, rest: 0.5cm),
  numbering: "1 / 1",
  header: [
    ДЗ.02. Численные методы решения нелинейных уравнений.
    #h(1fr)
    #eval(mode: "math", "n = " + repr(n))
    #h(1fr)
    #SURNAME_NAME, #UNN_GROUP
  ],
  columns: 2,
)
#set columns(gutter: 0.5cm)
#show heading: it => grid(
  columns: (1fr, auto, 1fr),
  align: horizon + center,
  column-gutter: 5pt,
  line(length: 100%),
  it.body,
  line(length: 100%),
)
#set table(
  align: horizon + center,
  stroke: gray + 0.2mm,
)
#show table.cell.where(x: 0): strong
#set par(justify: true)

#let round(x) = calc.round(x, digits: 4)
#let tick-fmt(v) = { set text(size: 9pt); v }

#let show-newton-plot(
  plot-name,
  f, d1f, a, b, x,
  secant-codomain: (-calc.inf, calc.inf),
  approx-label-anchor: "north-west",
  x-tick-label-offset: 0.1,
  y-tick-step: 0.05,
  y-tick-label-offset: 0.1,
  first-iteration-to-label: 0,
) = {
  secant-codomain = (calc.min(f(a), f(b)), calc.max(f(a), f(b)))
  let eqs = x.map(x0 => x => 
    calc.clamp((x - x0) * d1f(x0) + f(x0), ..secant-codomain)
  )
  align(center, cetz.canvas({
    import plot: *
    cetz.draw.set-style(axes: (
      stroke: (paint: gray, dash: "solid", thickness: 0.2mm),
      tick: (stroke: gray + .5pt),
      x: (tick: (label: (offset: x-tick-label-offset))),
      y: (tick: (label: (offset: y-tick-label-offset))),
    ))
    plot(
      name: plot-name,
      size: (8, 8),
      x-label: $x$,
      x-tick-step: 0.1,
      y-label: none,
      y-tick-step: y-tick-step,
      mark: "o",
      axis-style: "school-book",
      x-format: tick-fmt,
      y-format: tick-fmt,
      {
        add(f, domain: (a, b))
        for e in eqs {
          add(e, domain: (a, b), style: (stroke: (dash: "dotted", paint: gray, thickness: 0.2mm)))
        }
        for i in range(first-iteration-to-label, x.len()) {
          add-anchor("x" + str(i), (x.at(i), 0))
          add-anchor("fx" + str(i), (x.at(i), f(x.at(i))))
        }
      }
    )
    for i in range(first-iteration-to-label, x.len()) {
      cetz.draw.line(
        plot-name + ".x" + str(i),
        plot-name + ".fx" + str(i),
        stroke: (paint: gray, dash: "dashed")
      )
      cetz.draw.content(
        plot-name + ".fx" + str(i),
        eval(mode: "math", "f(x^\"(" + str(i) + ")\")"),
        anchor: approx-label-anchor
      )
    }
  }))
}


//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
#let f(x) = x*x*x + 2*x*x - 3*x - 6
#let d1f(x) = 3*x*x + 4*x - 3
#let d2f(x) = 6*x + 4
#let eqs1 = ()
#let eqs2 = ()


//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
=== Задание 1
$ f(x) = x^3 + 2x^2 - 3x - 6 = 0. $
$ f(x) = (x + 2)(x^2 - 3) = 0
==> x_1 = bold(-2), x_(2,3) = bold(plus.minus sqrt(3)), $
$ f'(x) = 3x^2 + 4x - 3, quad f''(x) = 6x + 4. $


//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
#let xe = -2
*Для $x_1 = xe$:* \
#{
  let (a, b) = (-3, -1.9)

  [Проверим условие Фурье на отрезке $[#a, #b]$:]
  table(
    columns: (auto, auto, 1fr),
    table.cell(colspan: 3, align(center, cetz.canvas({
      import plot: *
      cetz.draw.set-style(axes: (
        stroke: (paint: gray, dash: "solid", thickness: 0.15mm),
        x: (
          overshoot: 1,
          tick: (
            stroke: none,
            label: (offset: 0.25, anchor: "south")
          ),
          grid: (stroke: gray + 0.1mm)
        ),
        y: (
          overshoot: 0.2,
          tick: (
            stroke: none,
            label: (offset: -0.6)
          ),
          grid: (stroke: gray + 0.1mm)
        ),
      ))
      plot(
        name: "p", size: (6, 3),
        x-label: $x$, y-label: none,
        x-tick-step: 0.2, y-tick-step: 6,
        x-grid: true, y-grid: true,
        axis-style: "school-book",
        x-format: tick-fmt,
        y-format: tick-fmt,
        {
          add(
            f, domain: (a, b),
            style: (stroke: (dash: "solid")),
          )
          add-anchor("f0", (a, f(a)))
          add(
            d1f, domain: (a, b),
            style: (stroke: (dash: "dashed")),
          )
          add-anchor("f1", (a, d1f(a)))
          add(
            d2f, domain: (a, b),
            style: (stroke: (dash: "dotted")),
          )
          add-anchor("f2", (a, d2f(a)))
        }
      )
      cetz.draw.content("p.f0", $f(x)$, anchor: "east", padding: 0.2)
      cetz.draw.content("p.f1", $f'(x)$, anchor: "east", padding: 0.2)
      cetz.draw.content("p.f2", $f''(x)$, anchor: "east", padding: 0.2)
    }))),
    [1],
    $ f(#a) f(#b) < 0 $,
    $ f(#a) &approx #round(f(a)), \
      f(#b) &approx #round(f(b)). $,
    [2],
    $ limits("sign")_[#a,#b] f' eq.triple "const" $,
    $ min f' = f'(#b) &approx #round(d1f(b)) > 0, \
      max f' = f'(#a) &approx #round(d1f(a)) > 0. $,
    [3],
    $ limits("sign")_[#a,#b] f'' eq.triple "const" $,
    $ min f'' = f''(#a) &approx #round(d2f(a)) < 0, \
      max f'' = f''(#b) &approx #round(d2f(b)) < 0. $,
  )

  let x0 = a
  let x1 = x0 - f(x0) / d1f(x0)
  let x2 = x1 - f(x1) / d1f(x1)

  [
    Условие Фурье *выполняется*.
    Так как $"sign" f' != "sign" f''$ на $[#a, #b]$,
    то $x^"(0)" = #x0$. Проведём итерации по схеме
  ]
  $ x^"(k+1)" = x^"(k)" - frac(f(x^"(k)"), f'(x^"(k)")). $

  $ x^"(1)" &= x0 - frac(f(x0), f'(x0))
             = x0 - frac(#str(round(f(x0))), #str(round(d1f(x0))))
             = round(x1) thick, \
    x^"(2)" &= round(x1) - frac(f(round(x1)), f'(round(x1)))
        approx round(x2) thick. $

  let x = (x0, x1, x2)
  show-newton-plot(
    "plot1", f, d1f, -3.1, b, x,
    x-tick-label-offset: -0.5,
    y-tick-step: 0.5,
    y-tick-label-offset: -0.8,
    first-iteration-to-label: 0,
  )

  let m = calc.min(..(a, b).map(d1f).map(calc.abs).map(round))
  let M = calc.max(..(a, b).map(d2f).map(calc.abs).map(round))
  [Оценим погрешность:]
  $    m = min_[#a, #b] abs(f'(x)) approx #m,
  quad M = max_[#a, #b] abs(f''(x)) approx #M, \
    Delta x_2 <= M / (2 m) abs(x^"(2)" - x^"(1)")^2
               = #M / #(2 * m) abs(round(x2) - (x1))
          approx #round((M / (2 * m)) * calc.pow(calc.abs(x1 - xe), 2)). \
    Delta x^*_2 := abs(x^"(2)" - x^*)
                  = abs(round(x2)... - (xe))
             approx #round(calc.abs(x2 - xe)). $
}


//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
#let xe = calc.sqrt(3)
*Для $x_2 = sqrt(3) approx xe$:* \

Проверим условие Фурье на отрезке $[1, 2]$:
#{
  let (a, b) = (1, 2)
  table(
    columns: (auto, auto, 1fr),
    table.cell(colspan: 3, align(center, cetz.canvas({
      import plot: *
      cetz.draw.set-style(axes: (
        stroke: (paint: gray, dash: "solid", thickness: 0.15mm),
        x: (
          overshoot: 0.5,
          tick: (
            stroke: none,
            label: (offset: 0.04, anchor: "south")
          ),
          grid: (stroke: gray + 0.1mm)
        ),
        y: (
          overshoot: 0.05,
          tick: (
            stroke: none,
            label: (offset: 0.03, anchor: "south-east")
          ),
          grid: (stroke: gray + 0.1mm)
        ),
      ))
      plot(
        name: "p", size: (6, 3),
        x-label: $x$, y-label: none,
        x-tick-step: 0.2, y-tick-step: 6,
        x-grid: true, y-grid: true,
        axis-style: "school-book",
        x-format: tick-fmt,
        y-format: tick-fmt,
        {
          add(
            f, domain: (a, b),
            style: (stroke: (dash: "solid")),
          )
          add-anchor("f0", (b, f(b)))
          add(
            d1f, domain: (a, b),
            style: (stroke: (dash: "dashed")),
          )
          add-anchor("f1", (a, d1f(a)))
          add(
            d2f, domain: (a, b),
            style: (stroke: (dash: "dotted")),
          )
          add-anchor("f2", (a, d2f(a)))
        }
      )
      cetz.draw.content("p.f0", $f(x)$, anchor: "west", padding: 0.2)
      cetz.draw.content("p.f1", $f'(x)$, anchor: "east", padding: 0.4)
      cetz.draw.content("p.f2", $f''(x)$, anchor: "east", padding: 0.4)
    }))),
    [1],
    $ f(1) f(2) < 0 $,
    $ f(1) = 1 + 2 - 3 - 6 = &#f(1), \
      f(2) = 8 + 8 - 6 - 6 = &#f(2). $,
    [2],
    $ limits("sign")_[1,2] f' eq.triple "const" $,
    $ min f' = f'(1) &= #d1f(1) > 0, \
      max f' = f'(2) &= #d1f(2) > 0. $,
    [3],
    $ limits("sign")_[1,2] f'' eq.triple "const" $,
    $ min f'' = f''(1) &= #d2f(1) > 0, \
      max f'' = f''(2) &= #d2f(2) > 0. $,
  )

  let x0 = b
  let x1 = x0 - f(x0) / d1f(x0)
  let x2 = x1 - f(x1) / d1f(x1)
  
  [
    Условие Фурье *выполняется*.
    Так как $"sign" f' = "sign" f''$ на $[#a, #b]$,
    то $x^"(0)" = #b$. Проведём итерации по схеме
  ]

  $ x^"(k+1)" = x^"(k)" - frac(f(x^"(k)"), f'(x^"(k)")). $
  $ x^"(1)" &= x0 - frac(f(x0), f'(x0))
             = x0 - #f(x0) / #d1f(x0)
             = round(x1) thick, \
    x^"(2)" &= round(x1) - frac(f(round(x1)), f'(round(x1)))
             = round(x1) - f(round(x1)) / round(d1f(x1))
        approx round(x2) thick. $

  let x = (x0, x1, x2)
  show-newton-plot(
    "plot2", f, d1f, 1.65, 2.01, x,
    secant-codomain: (-4, 2),
    y-tick-step: 0.5,
    approx-label-anchor: "south-east",
  )

  let m = calc.min(..(a, b).map(d1f).map(calc.abs).map(round))
  let M = calc.max(..(a, b).map(d2f).map(calc.abs).map(round))
  [Оценим погрешность:]
  $    m = min_[#a, #b] abs(f'(x)) approx #m,
  quad M = max_[#a, #b] abs(f''(x)) approx #M, \
    Delta x_2 <= M / (2 m) abs(x^"(2)" - x^"(1)")^2
               = #M / #(2 * m) abs(round(x2) - round(x1))
          approx #round((M / (2 * m)) * calc.pow(calc.abs(x2 - x1), 2)). \
    Delta x^*_2 := abs(x^"(2)" - x^*)
                  = abs(round(x2)... - round(xe))
             approx #round(calc.abs(x2 - xe)). $
}


//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
#let xe = -calc.sqrt(3)
*Для $x_3 = -sqrt(3) approx xe$:* \

Проверим условие Фурье на отрезке $[-1.8, -1]$:
#{
  let (a, b) = (-1.8, -1)
  
  table(
    columns: (auto, auto, 1fr),
    table.cell(colspan: 3, inset: (top: 2pt, rest: -8pt), align(center, cetz.canvas({
      import plot: *
      cetz.draw.set-style(axes: (
        stroke: (paint: gray, dash: "solid", thickness: 0.15mm),
        x: (
          overshoot: 1,
          tick: (
            stroke: none,
            label: (offset: -0.2, anchor: "south-east")
          ),
          grid: (stroke: gray + 0.1mm)
        ),
        y: (
          overshoot: 0.1,
          tick: (
            stroke: none,
            label: (offset: -0.7, anchor: "east")
          ),
          grid: (stroke: gray + 0.1mm)
        )
      ))
      plot(
        name: "p", size: (6, 3),
        x-label: $x$, y-label: none,
        x-tick-step: 0.1, y-tick-step: 3,
        x-grid: true, y-grid: true,
        axis-style: "school-book",
        x-format: tick-fmt,
        y-format: tick-fmt,
        {
          add(
            f, domain: (a, b),
            style: (stroke: (dash: "solid")),
          )
          add-anchor("f0", (b, f(b)))
          add(
            d1f, domain: (a, b),
            style: (stroke: (dash: "dashed")),
          )
          add-anchor("f1", (a, d1f(a)))
          add(
            d2f, domain: (a, b),
            style: (stroke: (dash: "dotted")),
          )
          add-anchor("f2", (a, d2f(a)))
        }
      )
      cetz.draw.content("p.f0", $f(x)$, anchor: "west", padding: 0.2)
      cetz.draw.content("p.f1", $f'(x)$, anchor: "east", padding: 0.4)
      cetz.draw.content("p.f2", $f''(x)$, anchor: "east", padding: 0.4)
    }))),
    [1],
    $ f(#a) f(#b) < 0 $,
    $ f(#a) &= #round(f(a)), \
      f(#b) &= #f(b). $,
    [2],
    $ limits("sign")_[#a,#b] f' eq.triple "const" $,
    $ min f' = f'(#b)      &= #d1f(b) < 0, \
      max f' = f'(#a) &approx #round(d1f(a)) < 0. $,
    [3],
    $ limits("sign")_[#a,#b] f'' eq.triple "const" $,
    $ min f'' = f''(#a) &approx #round(d2f(a)) < 0, \
      max f'' = f''(#b)      &= #d2f(b) < 0. $,
  )
  
  let x0 = b
  let x1 = x0 - f(x0) / d1f(x0)
  let x2 = x1 - f(x1) / d1f(x1)

  [
    Условие Фурье *выполняется*.
    Так как $"sign" f' = "sign" f''$ на $[#a, #b]$,
    то $x^"(0)" = #b$. Проведём итерации по схеме
  ]
  
  $ x^"(k+1)" = x^"(k)" - f(x^"(k)") slash f'(x^"(k)"). $
  $ x^"(1)" &= x0 - frac(f(x0), f'(x0))
             = x0 - (#round(f(x0))...) / (#round(d1f(x0))...)
             = x1 thick, \
    x^"(2)" &= x1 - frac(f(x1), f'(x1))
             = x1 - #round(f(x1)) / d1f(x1) 
             = #round(x2)... thick. $

  let x = (x0, x1, x2)
  show-newton-plot(
    "plot3", f, d1f, a, -1, x,
    approx-label-anchor: "north-east",
    y-tick-step: 0.2,
    x-tick-label-offset: -0.6,
    y-tick-label-offset: -1,
  )

  let m = calc.min(..(a, b).map(d1f).map(calc.abs).map(round))
  let M = calc.max(..(a, b).map(d2f).map(calc.abs).map(round))
  [Оценим погрешность:]
  $    m = min_[#a, #b] abs(f'(x)) approx #m,
  quad M = max_[#a, #b] abs(f''(x)) approx #M, \
    Delta x_2 <= M / (2 m) abs(x^"(2)" - x^"(1)")^2
               = #M / #(2 * m) abs(round(x2) - (round(x1)))
          approx #round((M / (2 * m)) * calc.pow(calc.abs(x2 - x1), 2)). \
    Delta x^*_2 := abs(x^"(2)" - x^*)
                  = abs(round(x2)... - (round(xe)))
             approx #round(calc.abs(x2 - xe)). $
}


//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

#let f(x) = x*x*x - x
#let d1f(x) = 3*x*x - 1
#let d2f(x) = 6*x

=== Задание 2
Найти начальное приближение, при котором метод Ньютона зацикливается для функции

$ f(x) = x^3 - x = x(x^2 - 1). $
$ f(x) = 0 ==> x_0 = 0, thick x_(1,2) = plus.minus 1, $
$ f'(x) = 3x^2 - 1, quad f''(x) = 6x. $

В силу нечётности функции нетрудно заметить,
что зацикливание возможно только на интервале
$ [limits(min)_[-1,1] f, limits(max)_[-1,1] f]
= [-1/sqrt(3), 1/sqrt(3)] thick. $

Запишем условие зацикливания:

$ x - frac(f(x), f'(x)) = -x, \
  (2x(3x^2 - 1) - (x^3 - x)) / (3x^2 - 1) = 0, \
  6x^3 - 2x - x^3 + x = 0, \
  5x^3 - x = 0, \
  x_0 = 0, quad
  x_(1,2) = plus.minus 1/sqrt(5) thick.
$

#let sqrt15 = $1 slash sqrt(5)$
#let x0 = 1 / calc.sqrt(5)
#let (a, b) = (-x0, x0)

Проверим условие Фурье на отрезке $[-sqrt15, sqrt15]$:
#table(
  columns: (auto, auto, 1fr),
  table.cell(colspan: 3, inset: (top: 4pt, rest: -8pt), align(center, cetz.canvas({
    import plot: *
    cetz.draw.set-style(axes: (
      stroke: (paint: gray, dash: "solid", thickness: 0.15mm),
      x: (
        overshoot: 0.8,
        tick: (
          stroke: none,
          label: (offset: 0, anchor: "south-east")
        ),
        grid: (stroke: gray + 0.1mm)
      ),
      y: (
        overshoot: 0.1,
        tick: (
          stroke: none,
          label: (offset: 0, anchor: "east")
        ),
        grid: (stroke: gray + 0.1mm)
      ),
      shared-zero: $$,
    ))
    plot(
      name: "p", size: (6, 6),
      x-label: $x$, y-label: none,
      x-tick-step: 0.2, y-tick-step: 1,
      x-grid: true, y-grid: true,
      axis-style: "school-book",
      x-format: tick-fmt,
      y-format: tick-fmt,
      {
        add(
          f, domain: (a, b),
          style: (stroke: (dash: "solid")),
        )
        add-anchor("f0", (a, f(a)))
        add(
          d1f, domain: (a, b),
          style: (stroke: (dash: "dashed")),
        )
        add-anchor("f1", (a, d1f(a)))
        add(
          d2f, domain: (a, b),
          style: (stroke: (dash: "dotted")),
        )
        add-anchor("f2", (a, d2f(a)))
      }
    )
    cetz.draw.content("p.f0", $f(x)$, anchor: "east", padding: 0.4)
    cetz.draw.content("p.f1", $f'(x)$, anchor: "east", padding: 0.4)
    cetz.draw.content("p.f2", $f''(x)$, anchor: "east", padding: 0.4)
  }))),
  [1],
  $ f(script(-sqrt15)) f(script(sqrt15)) < 0 $,
  $ f(-sqrt15) &approx #round(f(-x0)) > 0, \
    f(sqrt15) &approx #round(f(x0)) < 0. $,
  [2],
  $ "sign" f' eq.triple "const" $,
  $ min f' = f'(sqrt15) = \ = #d1f(x0) = max f' < 0. $,
  circle(width: 1.2em)[3],
  $ "sign" f'' eq.triple "const" $,
  $ min f'' &approx #round(d2f(-x0)) < 0, \
    max f'' &approx #round(d2f(x0)) > 0. $,
)

#let x1 = x0 - f(x0) / d1f(x0)
#let x2 = x1 - f(x1) / d1f(x1)
#let x3 = x2 - f(x2) / d1f(x2)

Условие Фурье (3) *не выполняется*.
Выберем $x^"(0)" = sqrt15$ и проведём итерации по схеме
$ x^"(k+1)" = x^"(k)" - frac(f(x^"(k)"), f'(x^"(k)")). $
  
$ x^"(1)" &= sqrt15 - sqrt15(sqrt15^2 - 1) / d1f(x0)
           = -sqrt15, \
  x^"(2)" &= -sqrt15 - (-sqrt15((-sqrt15)^2 - 1)) / d1f(x1)
           = sqrt15, \
  x^"(3)" &= sqrt15 - sqrt15(sqrt15^2 - 1) / d1f(x0)
           = -sqrt15 = x^"(1)". $

#{             
  let arrow-style = (
    mark: (start: ">"),
    stroke: (paint: gray, dash: "dashed"),
  )
  align(center, cetz.canvas({
    import cetz.draw: *
    import plot: *
    set-style(axes: (
      stroke: (dash: "dotted", paint: gray),
      tick: (stroke: gray + .5pt),
    ))
    plot(
      name: "cycle",
      size: (8, 7),
      x-grid: true,
      x-label: $x$,
      x-tick-step: 0.1,
      y-grid: true,
      y-label: none,
      y-tick-step: 0.1,
      mark: "o",
      axis-style: "school-book",
      x-format: tick-fmt,
      y-format: tick-fmt,
      {
        add(f, domain: (-0.5, 0.5))
        add-anchor("x0", (x0, f(x0)))
        add-anchor("x0axis", (x0, 0))
        add-anchor("x1", (x1, f(x1)))
        add-anchor("x1axis", (x1, 0))
      }
    )
    line("cycle.x0", "cycle.x0axis", ..arrow-style)
    line("cycle.x0axis", "cycle.x1", ..arrow-style)
    line("cycle.x1", "cycle.x1axis", ..arrow-style)
    line("cycle.x1axis", "cycle.x0", ..arrow-style)
    content("cycle.x0axis", $x^"(0)"$, anchor: "south-west", padding: .1)
    content("cycle.x0", $f(x^"(0)")$, anchor: "north-east", padding: .1)
    content("cycle.x1axis", $x^"(1)"$, anchor: "south-east", padding: .1)
    content("cycle.x1", $f(x^"(1)")$, anchor: "south-west", padding: .1)
  }))

  [*Ответ*: начальное приближение $x^"(0)" = plus.minus sqrt15$.]
}
