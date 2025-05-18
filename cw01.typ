#import "@preview/cetz:0.3.4"
#import "@preview/cetz-plot:0.1.1": plot, chart
#import "@preview/diverential:0.2.0": dvpc
#import "@preview/physica:0.9.5": dv, pdv, evaluated
#import "@preview/numty:0.0.5" as nt

#let SURNAME_NAME = "Никитин Илья"
#let UNN_GROUP = "3822Б1МА1"

#set page(
  paper: "a4",
  margin: (top: 3em, bottom: 1cm, rest: 0.5cm),
  numbering: "1 / 1",
  header: [
    КР.01. Работа над ошибками. Вариант 17.
    #h(1fr)
    #SURNAME_NAME, #UNN_GROUP
  ],
)
#set table(
  align: horizon + center,
  stroke: gray + 0.2mm,
)
#set par(justify: true)

#show heading: it => grid(
  columns: (1fr, auto, 1fr),
  align: horizon + center,
  column-gutter: 5pt,
  line(length: 100%), it.body, line(length: 100%),
)

#let round(x) = calc.round(eval(str(x)), digits: 12)
#let tick-fmt(v) = {
  set text(size: 9pt)
  v
}


//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

=== Задание 1

#let f = (
  math: $x^3 - 3 x^2 + 12 x - 12$,
  code: x => calc.pow(x, 3) - 3 * calc.pow(x, 2) + 12 * x - 12,
)
#let d1f = (
  math: $3 x^2 - 6 x + 12$,
  code: x => 3 * calc.pow(x, 2) - 6 * x + 12,
)
#let d2f = (
  math: $6 x - 6$,
  code: x => 6 * x - 6,
)
#let ITERS = 2

Отделить корни аналитически.
Проверить условия применимости метода Ньютона к решению уравнения на отрезке.
Выполнить #ITERS итерации для уточнения корня, взяв в качестве начального
приближения левую или правую границу отрезка, оценить погрешность.

$
  f(x) = #f.math,
  quad f'(x) = #d1f.math,
  quad f''(x) = #d2f.math.
$

#show math.ast: math.thin
$
  f(x) = 0 ==>
  -3 / root(3, 1 + 2 * sqrt(7))
  + 1
  + root(3, 1 + 2 * sqrt(7))
$

#let xe = (
  -3 / calc.root(1 + 2 * calc.sqrt(7), 3) //
    + 1 //
    + calc.root(1 + 2 * calc.sqrt(7), 3)
)

#let (a, b) = (
  1.1,
  1.5,
)

*Решение.*
Проверим условие Фурье на отрезке $[#a, #b]$ *для $x_0$:*
#{
  table(
    columns: (6fr, 2fr, 3fr),
    table.cell(
      rowspan: 3,
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
          size: (9.5, 3),
          x-grid: true,
          x-label: $x$,
          x-tick-step: 0.2,
          y-grid: true,
          y-label: none,
          y-tick-step: 2,
          y-min: -2,
          x-format: tick-fmt,
          y-format: tick-fmt,
          {
            add(
              f.code,
              domain: (0, 2),
              style: (stroke: (dash: "solid")),
            )
            add-anchor("f0", (b, (f.code)(b)))
            add(
              d1f.code,
              domain: (0, 2),
              style: (stroke: (dash: "dashed")),
            )
            add-anchor("f1", (a, (d1f.code)(a)))
            add(
              d2f.code,
              domain: (0, 2),
              style: (stroke: (dash: "dotted")),
            )
            add-anchor("f2", (a, (d2f.code)(a)))
          },
        )
        cetz.draw.content("p.f0", $f(x)$, anchor: "north", padding: 0.3)
        cetz.draw.content("p.f1", $f'(x)$, anchor: "north", padding: 0.2)
        cetz.draw.content("p.f2", $f''(x)$, anchor: "south", padding: 0.2)
      }),
    ),
    $ f(#a) f(#b) < 0 $,
    $
      f(#a) &= #round((f.code)(a)) < 0, \
      f(#b) &= #round((f.code)(b)) > 0.
    $,
    $ limits("sign")_[#a,#b] f' eq.triple "const" $,
    $
      min f' = f'(#a) &= #round((d1f.code)(a)) > 0, \
      max f' = f'(#b) &= #round((d1f.code)(b)) > 0.
    $,
    $ limits("sign")_[#a,#b] f'' eq.triple "const" $,
    $
      min f'' = f''(#a) &= #round((d2f.code)(a)) > 0, \
      max f'' = f''(#b) &= #round((d2f.code)(b)) > 0.
    $,
  )

  [
    Условие *выполняется*.
    Т.к. $"sign" f' = "sign" f''$ на $[#a, #b]$,
    то $x^"(0)" = #b$. \
    #v(0.1em)
    Проведём итерации по схеме
    $display(x^(\(k+1\)) = x^(\(k\)) - frac(f(x^(\(k\))), f'(x^(\(k\))))):$
  ]

  let xs = ((exact: a),)
  for k in range(ITERS) {
    let x = xs.at(-1).exact
    let r = $#round(x)...$
    let exact = x - (f.code)(x) / (d1f.code)(x)
    xs.push((
      exact: exact,
      approx: round(exact),
      f: $
        x^(\(#(k+1)\)) &= #r - frac(f(#r), f'(#r))
        = #r - frac(
          #str(round((f.code)(x)))...,
          #str(round((d1f.code)(x)))...,
        )
        approx #exact
        #if k == ITERS - 1 {$.$} else {$,$}
      $,
    ))
  }

  $
    #for x in xs.slice(1) {
      $#x.f \ $
    }
  $

  let digits = 1000
  for k in range(calc.min(str(xs.at(-1).exact).len(), str(xe).len())).rev() {
    if calc.round(decimal(xs.at(-1).exact), digits: k) == calc.round(decimal(xe), digits: k) {
      digits = calc.min(digits, k)
      break
    }
  }
  digits += 2

  let m = calc.min(..(a, b).map(d1f.code).map(calc.abs).map(round))
  let M = calc.max(..(a, b).map(d2f.code).map(calc.abs).map(round))
  [Оценим погрешность:]
  $display(
    quad m = min_[#a, #b] abs(f'(x)) approx #m\,
    quad M = max_[#a, #b] abs(f''(x)) approx #M.
  )$

  $
    Delta x_#ITERS &<= M / (2 m) abs(x^(\(#ITERS\)) - x^(\(#(ITERS - 1)\)))^2
    = #M / #(2 * m) abs(#xs.at(-1).exact - #xs.at(-2).exact)^2 approx \
    &approx #((M / (2 * m)) * calc.pow(calc.abs(eval(
      (xs.at(-1).exact, " - ", xs.at(-2).exact).map(str).join()
    )), 2)), \
    Delta x^*_#ITERS &:= abs(x^(\(#ITERS\)) - x^\*)
    = abs(#xs.at(-1).exact - xe...) approx \
    &approx #calc.round(decimal(xs.at(-1).exact) - decimal(xe) + decimal(calc.pow(10, -digits)), digits: digits).
  $

  [
    *Ответ*: в приближении №#ITERS всего #digits верных значащих цифр,
    $thick Delta <= 5 dot 10^(-digits)$.
  ]
}


//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

=== Задание 2

#let PRECISION = 5
#let kth(x, ..k) = $#x^lr(paren.l #if k.pos().len() > 0 {
  k.pos().join(",")
} else {
  $k$
} paren.r)$
#let raw-vec(x) = eval(
  mode: "math",
  "vec(" + x.flatten().map(a => calc.round(a, digits: PRECISION)).map(str).join(",") + ")",
)
#let round(x) = str(if type(x) == float { calc.round(x, digits: 3) } else { x })
#let ol(x) = $overline(#x)$
#let jac-eval(J, x, dim: 2) = J.flatten().map(f => f(x)).chunks(dim)

Выполнить 2 итерации метода Ньютона для системы
линейных уравнений при заданном начальном приближении.

#{
  let f1 = (
    math: (x, y) => $ #x + #y^3 - 2 $,
    code: (x, y) => x + calc.pow(y, 3) - 2,
  )
  let f2 = (
    math: (x, y) => $ #y + 5 $,
    code: (x, y) => y + 5,
  )

  let x = ((4, -1),)

  $
    cases(
      x = - y^3 + 2,
      y = -5,
    ),
    quad x^"(0)" = #raw-vec(x.at(0)),
    quad ==> quad cases(
      f_1(x, y) = #(f1.math)($x$, $y$) = 0 comma,
      f_2(x, y) = #(f2.math)($x$, $y$) = 0.
    )
  $

  [*Решение.*]

  let jdet-f(x: "x", fmt: str) = "1"
  let jdet(p, fmt) = 1
  let Fx = ((f1.code)(..x.at(0)), (f2.code)(..x.at(0)))
  $
    ol(F)(kth(ol(x), 0))
    = vec(f_1(kth(x, 0), kth(y, 0)), f_2(kth(x, 0), kth(y, 0)))
    = vec(
      #(f1.math)(..x.at(0)),
      #(f2.math)(..x.at(0)),
    )
    = #raw-vec(Fx).
  $

  $
    J(ol(x)) = mat(
      dvpc(f_1(x, y), x), dvpc(f_1(x, y), y);
      dvpc(f_2(x, y), x), dvpc(f_2(x, y), y);
    )
    = mat(1, 3y^2; 0, 1),
    quad det(J) = #jdet-f() != 0
    thick => thick exists J^(-1).
  $

  let jadj = (
    (x => 1, x => -3 * x.at(1) * x.at(1)),
    (x => 0, x => 1),
  )
  $
    J^(-1)(ol(x)) = 1 / det(J) mat(a_22, -a_12; -a_21, a_11)
    = 1 / #jdet-f() mat(1, -3y^2; 0, 1).
  $

  [Применим формулу метода Ньютона для системы уравнений:]
  $quad kth(ol(x), k+1) = kth(ol(x)) - J^(-1)(kth(ol(x))) ol(F)(kth(ol(x))) :$

  let k = 1
  while (k < 3) {
    let jadjx = jac-eval(jadj, x.at(k - 1))
    let jadjFx = nt.matmul(jadjx, nt.c(..Fx)).flatten()
    x.push(nt.mult(1 / jdet(x.at(k - 1), str), nt.sub(nt.mult(jdet(x.at(k - 1), str), x.at(k - 1)), jadjFx)))

    show math.equation: set text(size: 0.92em)

    block($
      vec(kth(x, #k), kth(y, #k))
      approx #raw-vec(x.at(k - 1)) - 1 / #jdet(x.at(k - 1), round) mat(..#jadjx.flatten().map(round).chunks(2)) #raw-vec(Fx)
      approx #raw-vec(x.at(k - 1)) - 1 / #jdet(x.at(k - 1), round) #raw-vec(jadjFx)
      approx 1 / #jdet(x.at(k - 1), round) #raw-vec(nt.sub(nt.mult(jdet(x.at(k - 1), round), x.at(k - 1)), jadjFx))
      approx #raw-vec(x.at(k).map(x => calc.round(x, digits: PRECISION)).map(float)),

      quad quad

      ol(F)(kth(ol(x), #k))
      approx vec(
        #(f1.math)(..x.at(k)),
        #(f2.math)(..x.at(k)),
      )
      approx vec(#str((f1.code)(..x.at(k))), #str((f2.code)(..x.at(k)))).
    $)

    k += 1
    Fx = ((f1.code)(..x.at(-1)), (f2.code)(..x.at(-1)))
  }

  enum(
    numbering: it => strong[Ответ:],
    [
      Для системы получена последовательность приближений: \ \
      #for (k, v) in x.enumerate() {
        $display(
          vec(
            kth(x, #k) #if str(v.at(0)).len() > 15 { $approx$ } else { $=$ }
            #calc.round(v.at(0), digits: PRECISION),
            kth(y, #k) #if str(v.at(0)).len() > 15 { $approx$ } else { $=$ }
            #calc.round(v.at(1), digits: PRECISION)
          )
        ) #if k + 1 == x.len() { "." } else { "," } quad$
      }
    ],
  )
}


//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

=== Задание 3

#let ITERATIONS = 1
#let PREC = 10
#let f(x, y) = x + y + 2
#let x0 = 0
#let xend = 0.1
#let y0 = -1
#let h = 0.1

#let plot-comparison(plot-block, y-step: 1) = cetz.canvas({
  import plot: *
  cetz.draw.set-style(
    axes: (
      stroke: (dash: "dotted", paint: gray),
      tick: (stroke: gray + .5pt),
    ),
  )
  plot(
    size: (7, 3),
    x-grid: true,
    x-label: $x$,
    x-tick-step: h / 2,
    y-grid: true,
    y-label: none,
    y-tick-step: y-step,
    mark: "o",
    axis-style: "school-book",
    plot-block,
  )
})

Вычислить методом Эйлера и его модификациями приближение к $y(xend)$.
Выполнив 2 шага, найти абсолютную погрешность решения для каждого метода.
Сравнить и объяснить полученный результат.

$
  y' = x + y + 2, quad
  y(0) = y0, quad
  h = #h thin.
$

$
  (Delta y) / (Delta x) = f(x, y), quad
  Delta y = y(x + h) - y(x), quad
  Delta x = (x + h) - x = h thin.
$

*Решение.* Решим аналитически с помощью интегрирующего множителя $mu(x)$:
$
  dv(y, x) = x + y + 2 quad <==>
  quad dv(y, x) + P(x) y = Q(x),
  quad "где" thick P(x) = -1, thick Q(x) = x + 2.
$

$
  mu(x) = e^(integral_0^x P(t) dif t)
  = e^(- integral_0^x dif t) = e^(-x),
$

$
  e^(-x) dv(y, x) - e^(-x) y = -e^(-x) (x + 2) quad <==>
  quad dv(e^(-x) y, x) = - e^(-x) (x + 2) quad <==>
  quad e^(-x) y = - integral e^(-x) (x + 2) dif x,
$

$
  integral e^(-x) (x + 2) dif x = lr(
    |#table(
      columns: 2,
      rows: 2,
      stroke: none,
      $u = x + 2$, $dif v = e^(-x) dif x$,
      $dif u = dif x$, $v = - e^(-x)$,
    )|
  ) = -(x + 2) e^(-x) + integral e^(-x) dif x
  quad ==> quad
  y(x) = -(x + 3) + C e^x.
$

$
  y(0) = -3 + C e^0 = -1 quad ==>
  quad C = 2, quad y(x) = -x - 3 + 2 e^x.
$

#let yexact(x) = -x - 3 + 2 * calc.exp(x)

Решим классическим методом Эйлера:
$quad x_k = x_0 + h k,
  quad y_(k + 1) = y_k + h f(x_k, y_k).$

#let x = range(ITERATIONS + 1).map(k => x0 + k * h)
#let y = (y0,)
#for k in range(ITERATIONS) {
  y.push(y.at(k) + h * f(x.at(k), y.at(k)))
}

#grid(
  columns: (1fr, 1fr),
  inset: 1em,
  align(
    center + horizon,
    table(
      inset: 0.5em,
      columns: 5,
      table.header[*$k$*][*$x_k$*][*$y_k$*][*$y^*_k$*][*$Delta_k$*],
      ..range(x.len())
        .map(k => (
          k,
          x.at(k),
          y.at(k),
          x.map(yexact).at(k),
          calc.abs(y.at(k) - yexact(x.at(k))),
        ).map(a => $#calc.round(a, digits: PREC)$))
        .flatten()
    ),
  ),
  plot-comparison({
    plot.add(yexact, domain: (0, h * ITERATIONS))
    plot.add(
      x.zip(y),
      mark: "o",
      mark-size: 0.1,
      mark-style: (stroke: none, fill: black),
    )
  }),
)

#let error-classic = calc.abs(y.at(-1) - yexact(x.at(-1)))

Решим 1-й модификацией метода:
$thick x_(k + 1 / 2) = x_0 + h k slash 2,
  quad y_(k + 1 / 2) = y_k + h slash 2 dot f(x_k, y_k),
  quad y_(k + 1) = y_k + h f(x_(k + 1 slash 2), y_(k + 1 slash 2)).$

#let x = range(ITERATIONS + 1).map(k => x0 + h * k)
#let x2 = range(ITERATIONS + 1).map(k => x.at(k) + 1 / 2 * h)
#let y = (y0,)
#let y2 = ()
#for k in range(ITERATIONS + 1) {
  y2.push(y.at(k) + h / 2 * f(x.at(k), y.at(k)))
  y.push(y.at(k) + h * f(x2.at(k), y2.at(k)))
}

#grid(
  columns: (1.3fr, 1fr),
  inset: (left: 0em, right: 0em, rest: 1em),
  align(
    center + horizon,
    table(
      inset: 0.5em,
      columns: 7,
      table.header[
        *$k$*
      ][
        *$x_k$*
      ][
        *$x_(k+1 / 2)$*
      ][
        *$y_(k+1 / 2)$*
      ][
        *$y_k$*
      ][
        *$y^*_k$*
      ][
        *$Delta_k$*
      ],
      ..range(x.len())
        .map(k => (
          k,
          x.at(k),
          x2.at(k),
          y2.at(k),
          y.at(k),
          x.map(yexact).at(k),
          calc.abs(y.at(k) - yexact(x.at(k))),
        ).map(a => $#calc.round(a, digits: 10)$))
        .flatten()
    ),
  ),
  plot-comparison({
    plot.add(yexact, domain: (0, h * ITERATIONS))
    plot.add(
      x.zip(y),
      mark: "o",
      mark-size: 0.1,
      mark-style: (stroke: none, fill: black),
    )
  }),
)

#let error-mod-1 = calc.abs(y.at(-2) - yexact(x.at(-1)))

Решим 2-й модификацией метода:
$quad y_(k + 1)
  = y_k + h slash 2 dot (f(x_k, y_k) + f(x_(k+1), y_k + h f(x_k, y_k))).$

#let x = range(ITERATIONS + 1).map(k => x0 + k * h)
#let y = (y0,)
#for k in range(ITERATIONS) {
  y.push(
    y.at(k)
      + h
        / 2
        * (
          f(x.at(k), y.at(k)) + f(x.at(k + 1), y.at(k) + h * f(x.at(k), y.at(k)))
        ),
  )
}

#grid(
  columns: (1fr, 1fr),
  inset: 1em,
  align(
    center + horizon,
    table(
      inset: 0.5em,
      columns: 5,
      table.header[*$k$*][*$x_k$*][*$y_k$*][*$y^*_k$*][*$Delta_k$*],
      ..range(x.len())
        .map(k => (
          k,
          x.at(k),
          y.at(k),
          x.map(yexact).at(k),
          calc.abs(y.at(k) - yexact(x.at(k))),
        ).map(a => $calc.round(#a, digits: PREC)$))
        .flatten()
    ),
  ),
  plot-comparison({
    plot.add(yexact, domain: (0, h * ITERATIONS))
    plot.add(
      x.zip(y),
      mark: "o",
      mark-size: 0.1,
      mark-style: (stroke: none, fill: black),
    )
  }),
)

#let error-mod-2 = calc.abs(y.at(-1) - yexact(x.at(-1)))

Обоснуем эквивалентность приближений по первой и второй
модификациям метода Эйлера. \

Подставим точное решение в первую модификацию метода:
$
  f(x_k + h slash 2, y_k + h slash 2 dot f(x_k, y_k))
  = (x_k + h slash 2) + (y_k + h slash 2 dot (x_k + y_k + 2)) + 2
  = x_k + y_k + 2 + h slash 2 dot (x_k + y_k + 3), \
  quad y_(k+1)
  = y_k + h (x_k + y_k + 2 + h slash 2 dot (x_k + y_k + 3))
  = y_k + h(x_k + y_k + 2) + h^2 / 2 (x_k + y_k + 3).
$

Подставим точное решение во вторую модификацию метода:
$
  f(x_k, y_k) + f(x_(k + 1), y_k + h f(x_k, y_k))
  = (x_k + y_k + 2)
  + (x_k + h + y_k + h (x_k + y_k + 2) + 2) = \
  = 2 x_k + 2 y_k + 4 + h (x_k + y_k + 3), \
  quad y_(k+1)
  = y_k + h / 2 (2 x_k + 2 y_k + 4 + h (x_k + y_k + 3))
  = y_k + h (x_k + y_k + 2) + h^2 / 2 (x_k + y_k + 3).
$

Формулы обеих модификаций для точного решения дают эквивалентную локальную
(шаговую) погрешность $Delta_#[_лок_] = O(h^3)$, а это значит, что глобальная
погрешность для них $Delta_#[_гл_] = O(h^2)$, и оба метода имеют порядок $O(h^2)$.
Для частного случая $y = -x -3 + 2 e^x$ погрешности методов совпадают.

#enum(
  numbering: it => [*Ответ:*],
  [
    Решение: $y = -x - 3 + 2 e^x$. \
    Погрешность для классического метода: $Delta_2 approx #calc.round(error-classic, digits: PREC)$, \
    для первой и второй модификаций: $Delta_2 approx #calc.round(error-mod-1, digits: PREC)$.
  ],
)


//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

=== Задание 4

#let RK2-ru = $upright(P)upright(K)2$
Определить, принадлежит ли формула семейству #RK2-ru методов Рунге-Кутты 2-го порядка точности:

#let f-to-check = $""
  y_(n+1)
  = y_n
  + 0.6 h f(x_n, y_n)
  + 0.4 h f(x_n + 1.25 h, y_n + 1.25 h f(x_n, y_n))
  ""$

#align(center, $ #f-to-check . $)

*Решение.*
Двухэтапный метод Рунге-Кутты второго порядка имеет вид:
$
  y_(n+1) = y_n + p_1 k_1 + p_2 k_2,
  quad k_1 = h f(x_n, y_n),
  quad k_2 = h f(x_n + alpha_2 h, y_n + beta_21 k_1).
$

Коэффициенты $p_1, p_2, alpha_2, beta_21$ должны быть подобраны так,
чтобы разложения в ряд Тейлора точного и приближённого значений
функции $y(x)$ в точке $x_(n+1) = x_n + h$ совпадали до порядка
$h^2$ включительно.

#let evpt = f => $evaluated((#f))_(\(x_n, y_n\))$

Точное решение по формуле Тейлора:
$
  y(x_n + h)
  = y(x_n) + h y'(x_n) + h^2 / 2 y''(x_n) + O(h^3),
  \ "причём "
  y'' = pdv(f, x) = f_x + f_y f
  quad ==> quad
  y(x_n + h) = evpt(y_n + h f + h^2 / 2 (f_x + f_y f)) + O(h^3).
$

Численное решение:
$
  k_1 = h f,
  quad k_2
  = h f(x_n + alpha_2 h, y_n + a_21 k_1)
  = evpt(h f + h^2 (alpha_2 f_x + beta_21 f f_y)) + O(h^3)
  quad ==> \ ==> quad
  y(x_n + h) = evpt(
    y_n
    + (p_1 + p_2) h f
    + p_2 h^2 (alpha_2 f_x + beta_(21) f f_y)
  ) + O(h^3).
$

#show math.frac: it => $#it.num slash #it.denom$

#grid(
  columns: (1.2fr, 0.1fr, 0.7fr),
  {
    [Сравнивая разложения, получим условия принадлежности #RK2-ru:]
    $
      #math.cases(
        gap: 1em,
        $ f = (p_1 + p_2) f $,
        $ 1 / 2 dot (f_x + f_y f) = p_2 (alpha_2 f_x + beta_21 f f_y) $,
      )
      quad ==> quad
      #math.cases(
        gap: 1em,
        $ p_1 + p_2 = 1, $,
        $ p_2 alpha_2 = 1 / 2, $,
        $ p_2 beta_21 = 1 / 2. $,
      )
    $
  },
  [],
  {
    [Выпишем коэф-ты в табличной форме:]
    set table(
      stroke: (x, y) => (
        left: if x == 2 and y < 3 { 0.7pt + black } else { none },
        bottom: if y == 1 { 0.7pt + black } else { none },
      ),
    )
    let h = 4em
    align(
      center,
      table(
        columns: 5,
        rows: (h / 2, h / 2, auto, auto),
        table.cell(rowspan: 2, $display(alpha_i) cases("", "", "")$),
        [0], [], [], table.cell(rowspan: 2, $cases(reverse: #true, "", "", "") display(beta_(i j))$),
        [1.25], [1.25], [],
        [], [], [0.6], [0.4], [],
        [], [], table.cell(
          colspan: 2,
          inset: (left: 8pt, top: -10pt),
          math.underbrace(box(width: 3.5em), $display(p_j)$),
        ), []
      ),
    )
  },
)

#{
  show math.equation: math.display
  [Из схемы:]
  $thin
    quad p_1 = 0.6,
    quad p_2 = 0.4,
    quad alpha_2 = 1.25,
    quad beta_21 = 1.25
    quad ==> quad
    cases(
      gap: #1em,
      p_1 + p_2 = 0.6 + 0.4 = 1\,,
      p_2 alpha_2 = 0.4 dot 1.25 = 1 / 2\,,
      p_2 beta_21 = 0.4 dot 1.25 = 1 / 2 .
    ) quad ("условия выполнены").$
}

#enum(
  numbering: it => strong[Ответ:],
  [формула #f-to-check принадлежит #RK2-ru.],
)

