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
    ДЗ.03. Численные методы решения нелинейных уравнений.
    #h(1fr)
    #eval(mode: "math", "n = " + repr(n))
    #h(1fr)
    #SURNAME_NAME, #UNN_GROUP
  ],
)
#set columns(gutter: 0.5cm)
#set table(
  align: horizon + center,
  stroke: gray + 0.2mm,
)
#set par(justify: true)

#show table.cell.where(x: 0): strong
#show heading: it => grid(
  columns: (1fr, auto, 1fr),
  align: horizon + center,
  column-gutter: 5pt,
  line(length: 100%), it.body, line(length: 100%),
)

#let round(x) = calc.round(eval(str(x)), digits: 5)
#let tick-fmt(v) = {
  set text(size: 9pt)
  v
}

#let fmt-large-n(n) = {
  let s = str(n)
  let result = ""
  for i in range(s.len()) {
    if i > 0 and calc.rem(s.len() - i, 3) == 0 { result += " " }
    result += s.at(i)
  }
  result
}


//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
#let f(x) = x * x * x - 3 * x * x + 6 * x - 5
#let d1f(x) = 3 * x * x - 6 * x + 6
#let d2f(x) = 6 * x - 6
#let evalm(x) = eval(mode: "math", x)


//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
=== Задание 1
Отделить корни аналитически.
Проверить условия применимости метода Ньютона к решению уравнения на отрезке.
Выполнить 5 итераций для уточнения корня, взяв в качестве начального
приближения левую или правую границу отрезка, оценить погрешность.
Выяснить количество верных значащих цифр в приближённом решении.

$
  f(x) = x^3 - 3x^2 + 6x - 5 = 0,
  quad f'(x) = 3x^2 - 6x + 6,
  quad f''(x) = 6x - 6.
$

$
  f(x) = 0 ==>
  x_0 = 1 - root(3, 2 / (1 + sqrt(5)))
  + root(3, 1 / 2 (1 + sqrt(5))) in RR.
$

#let xe = 1 - calc.root(2 / (1 + calc.sqrt(5)), 3) + calc.root(1 / 2 * (1 + calc.sqrt(5)), 3)

//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
#let (a, b) = (1, 2)
#{
  [Проверим условие Фурье на отрезке $[#a, #b]$ *для $x_0$:* \ ]
  table(
    columns: (6fr, 2fr, 3fr),
    table.cell(
      rowspan: 3,
      inset: (right: 15pt),
      cetz.canvas({
        import plot: *
        cetz.draw.set-style(
          axes: (
            stroke: (dash: "dotted", paint: gray),
            tick: (stroke: gray + .5pt),
          ),
        )
        plot(
          name: "p",
          size: (8, 3),
          x-grid: true,
          x-label: $x$,
          x-tick-step: 0.1,
          y-grid: true,
          y-label: none,
          y-tick-step: 1,
          x-format: tick-fmt,
          y-format: tick-fmt,
          {
            add(
              f,
              domain: (a, b),
              style: (stroke: (dash: "solid")),
            )
            add-anchor("f0", (b, f(b)))
            add(
              d1f,
              domain: (a, b),
              style: (stroke: (dash: "dashed")),
            )
            add-anchor("f1", (a, d1f(a)))
            add(
              d2f,
              domain: (a, b),
              style: (stroke: (dash: "dotted")),
            )
            add-anchor("f2", (a, d2f(a)))
          },
        )
        cetz.draw.content("p.f0", $f(x)$, anchor: "west", padding: 0.15)
        cetz.draw.content("p.f1", $f'(x)$, anchor: "east", padding: 0.5)
        cetz.draw.content("p.f2", $f''(x)$, anchor: "east", padding: 0.5)
      }),
    ),
    $ f(#a) f(#b) < 0 $,
    $
      f(#a) &= #round(f(a)) < 0, \
      f(#b) &= #round(f(b)) > 0.
    $,
    $ limits("sign")_[#a,#b] f' eq.triple "const" $,
    $
      min f' = f'(#a) &= #round(d1f(a)) > 0, \
      max f' = f'(#b) &= #round(d1f(b)) > 0.
    $,
    $ limits("sign")_[#a,#b] f'' eq.triple "const" $,
    $
      // TODO сдвинуть левую границу,
      // чтобы было >, а не >=.
      min f'' = f''(#a) &= #round(d2f(a)) > 0, \
      max f'' = f''(#b) &= #round(d2f(b)) > 0.
    $,
  )

  [
    Условие *выполняется*.
    Т.к. $"sign" f' = "sign" f''$ на $[#a, #b]$,
    то $x^"(0)" = #b$. Проведём итерации по схеме
  ]
  $x^"(k+1)" = x^"(k)" - frac(f(x^"(k)"), f'(x^"(k)")) :$

  let x0 = a

  let x1 = "4/3"

  let x2 = "119/90"

  let x3 = "1595924 / 1207035"
  let fx3num = "2310468569"
  let fx3den = "1758569716580767875"
  let dfx3num = 160816814546
  let dfx3den = 485644497075

  let x4num = "769954239502062943"
  let x4den = "582334571236593330"
  let x4 = x4num + " / " + x4den
  let fx4num = "2335074300375426691686978882286804543426320503"
  let fx4den = "197477545403677695951384253696524653291868024479037000"
  let dfx4num = "374314692777351857090770347226858669"
  let dfx4den = "113037850952435663903333087933496300"

  let x5 = "1.32218535462608559663328"

  $
    x^"(1)" &= x0 - frac(f(x0), f'(x0))
    = x0 - frac(#str(f(x0)), #str(d1f(x0)))
    = #evalm(x1) approx #round(x1) thick, \
    x^"(2)" &= #evalm(x1) - frac(f(x1), f'(x1))
    = #evalm(x1) - frac(1 slash 27, 10 slash 3)
    = #evalm(x2) approx #round(x2) thick, \
    x^"(3)" &= #evalm(x2) - frac(f(x2), f'(x2))
    = #evalm(x2) - frac(89 slash 729000, 8941 slash 2700)
    = #evalm(x3) approx #round(x3) thick, \
    x^"(4)" &= #evalm(x3) - frac(f(x3), f'(x3))
    = #evalm(x3) - frac(
      #fmt-large-n(fx3num) slash #fmt-large-n(fx3den),
      #fmt-large-n(dfx3num) slash #fmt-large-n(dfx3den)
    ) = \
    &= frac(#fmt-large-n(x4num), #fmt-large-n(x4den))
    approx #round(x4) thick, \
    x^"(5)" &= frac(#fmt-large-n(x4num), #fmt-large-n(x4den))
    - frac(
      f(#fmt-large-n(x4num) slash #fmt-large-n(x4den)),
      f'(#fmt-large-n(x4num) slash #fmt-large-n(x4den))
    ) = \
    &= frac(#fmt-large-n(x4num), #fmt-large-n(x4den))
    - frac(
      #pad(8pt, $display(frac(-#fmt-large-n(fx4num), #fmt-large-n(fx4den)))$),
      #pad(8pt, $display(frac(#fmt-large-n(dfx4num), #fmt-large-n(dfx4den)))$)
    ) \
    &approx x5 thick.
  $

  let xe = "1.32218535462608559291148"
  let digits = 1000
  for k in range(calc.min(x5.len(), xe.len())).rev() {
    if calc.round(decimal(x5), digits: k) == calc.round(decimal(xe), digits: k) {
      digits = calc.min(digits, k)
      break
    }
  }
  digits += 2

  let m = calc.min(..(a, b).map(d1f).map(calc.abs).map(round))
  let M = calc.max(..(a, b).map(d2f).map(calc.abs).map(round))
  [
    Оценим погрешность:
    $m = min_[#a, #b] abs(f'(x)) approx #m,
    quad M = max_[#a, #b] abs(f''(x)) approx #M.$
  ]

  $
    Delta x_5 &<= M / (2 m) abs(x^"(5)" - x^"(4)")^2
    = #M / #(2 * m) abs(x5... - x4)^2 approx \
    &approx #((M / (2 * m)) * calc.pow(calc.abs(eval(x5 + "-" + x4)), 2)), \
    Delta x^*_5 &:= abs(x^"(5)" - x^*)
    = abs(x5... - xe...) approx \
    &approx #calc.round(decimal(x5) - decimal(xe) + decimal(calc.pow(10, -digits)), digits: digits).
  $

  [
    *Ответ*: в пятом приближении #digits верных значащих цифр,
    $Delta <= 5 dot 10^(-digits)$.
  ]
}
