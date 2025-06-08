#import "@preview/cetz:0.3.4"
#import "@preview/cetz-plot:0.1.1": plot, chart
#import "@preview/physica:0.9.5": *
#import "@preview/showybox:2.0.4": showybox
#import "@preview/fletcher:0.5.7": diagram, node, edge


#let SURNAME_NAME = "Никитин Илья"
#let UNN_GROUP = "3822Б1МА1"
#let n = 21


#set page(
  paper: "a4",
  margin: (top: 3em, rest: 0.8cm),
  numbering: "1 / 1",
  header: [
    ДЗ.13. Метод конечных разностей для уравнений в частных производных.
    #h(1fr)
    #eval(mode: "math", "n = " + repr(n))
    #h(1fr)
    #SURNAME_NAME, #UNN_GROUP
  ],
)
#let double-line = [
  #block(spacing: 0pt, line(length: 100%))
  #v(2.5pt)
  #block(spacing: 0pt, line(length: 100%))
]
#show heading: it => grid(
  columns: (1fr, auto, 1fr),
  align: horizon + center,
  column-gutter: 5pt,
  double-line, it.body, double-line,
)
#set par(justify: true)
#set math.cases(gap: 8pt)
#let cases(..children) = math.cases(..children.pos().map(math.display))
#let hl(eqtn) = rect(
  stroke: gray,
  inset: (top: 10pt, bottom: 10pt, left: 5pt, right: 5pt),
  $display(eqtn.body)$,
)
#let seq(a, b, c) = $#a, #b, ..., #c$
#let double-line = [
  #block(spacing: 0pt, line(length: 100%))
  #v(2.5pt)
  #block(spacing: 0pt, line(length: 100%))
]
#let tick-fmt(v) = {
  set text(size: 8pt)
  v
}
#let light-green = green.transparentize(80%)

#let spectrum-circle(r, style, inverse: false) = {
  if inverse {
    plot.add-fill-between(
      domain: (-(2 * r - 1), 0.999),
      style: style,
      x => 10000,
      x => calc.sqrt(r * r - (x + r - 1) * (x + r - 1)),
    )
    plot.add-fill-between(
      domain: (-(2 * r - 1), 0.999),
      style: style,
      x => -calc.sqrt(r * r - (x + r - 1) * (x + r - 1)),
      x => -10000,
    )
    plot.add-fill-between(
      domain: (-10000, -(2 * r - 1)),
      style: style,
      x => -10000,
      x => 10000,
    )
    plot.add-fill-between(
      domain: (1, 10000),
      style: style,
      x => -10000,
      x => 10000,
    )
  } else {
    plot.add-fill-between(
      domain: (-(2 * r - 1), 0.999),
      style: style,
      x => calc.sqrt(r * r - (x + r - 1) * (x + r - 1)),
      x => -calc.sqrt(r * r - (x + r - 1) * (x + r - 1)),
    )
  }
  if "fill" not in style or style.fill == none {
    plot.add-anchor("c" + str(r).replace(".", ""), (1 - r, 0))
  }
}


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

=== Задание 2

$
  (diff u) / (diff t) - 7 (diff u) / (diff x) = 0, quad u(x, 0) = f(x)
$
$
  (u_m^p - u_m^(p - 1)) / tau - 7 (u_(m + 1)^p - u_m^p) / h = 0, quad u_m^0 = f(m h)
$

*Решение.*

*Дифференциальный оператор и правая часть задачи:*
#grid(
  columns: (1fr, 1fr),
  align: center + horizon,
  $L u = cases(
    pdv(u, t) - 7 pdv(u, x) comma &quad x in RR comma space 0 < t <= T semi,
    u(x comma 0) comma &quad x in RR comma space t = 0
  )$,
  $f = cases(
    0 comma &quad x in RR comma space 0 < t <= T semi,
    f(x) comma &quad x in RR comma space t = 0.
  )$,
)

*Разностный оператор и правая часть задачи:*
$
  L_h u^((h)) = cases(
    (u_m^p - u_m^(p - 1)) / tau - 7 (u_(m+1)^p - u_m^p) / h comma &quad m in ZZ comma space p = seq(0, 1, [T/tau] - 1) semi,
    u_m^0 comma &quad m in ZZ
  )
$
$
  f^((h)) = cases(
    0 comma &quad m in ZZ comma space p = seq(0, 1, [T/tau] - 1) semi,
    f(m h) comma &quad m in ZZ
  )
$

#grid(
  columns: (1fr, 1fr),
  align: horizon,
  [*Шаблон разностной схемы:*],
  align(
    center + horizon,
    cetz.canvas(
      length: 1.5cm,
      {
        import cetz.draw: *

        let m = 1
        let p = 1

        // Соединяем линиями
        line((m, p - 1), (m, p), stroke: gray)
        line((m, p), (m + 1, p), stroke: gray)

        // Выделяем активные точки схемы для (m,p)
        circle((m, p), radius: 0.05, fill: black)
        content((m, p + 0.3), text(size: 8pt, $(m, p)$))

        circle((m, p - 1), radius: 0.05, fill: black)
        content((m + 0.6, p - 1), text(size: 8pt, $(m, p - 1)$))

        circle((m + 1, p), radius: 0.05, fill: black)
        content((m + 1, p + 0.3), text(size: 8pt, $(m + 1, p)$))
      },
    ),
  ),
)

Для аппроксимации частной производной по пространству применяется
левая конечная разность, она имеет первый порядок аппроксимации.
Для аппроксимации частной производной по времени применяется
правая конечная разность, она имеет первый порядок аппроксимации.
Начальные условия задаются точно.
Поэтому ошибка аппроксимации схемы является величиной $O(h) + O(tau)$.

*Погрешность аппроксимации:*
$
  L_h [u]_h = f^(h) + delta f(h),
  space "где" space
  delta f(h) = cases(
    O(tau + h) comma &quad m in ZZ comma space p >= 1 semi,
    0 comma &quad m in ZZ comma space p = 0.
  )
$

*Исследование на устойчивость.*

Применим спектральный признак устойчивости Неймана.
Подставим $u_m^p = lambda^p e^(i alpha m)$
в разностное уравнение:
$
  (lambda^p e^(i alpha m) - lambda^(p - 1) e^(i alpha m)) / tau - 7 (lambda^p e^(i alpha (m + 1)) - lambda^p e^(i alpha m)) / h = 0
$

Вынесем общий множитель $lambda^(p - 1) e^(i alpha m)$ за скобки:
$
  lambda^(p - 1) e^(i alpha m) [(lambda - 1) / tau - 7 lambda (e^(i alpha) - 1) / h] = 0
$

Обозначим $r = 7 tau slash h = "const"$ и выразим $1 slash lambda$.
Тогда
$
  (lambda - 1) / tau = 7 lambda (e^(i alpha) - 1) / h
  quad ==> quad
  1 - 1 / lambda = r (e^(i alpha) - 1)
  quad ==> quad
  1 / lambda(alpha) = 1 + r - r e^(i alpha).
$

#pagebreak(weak: true)

#grid(
  columns: (1fr, auto),
  gutter: 2em,
  align(horizon)[
    В данной задаче спектр не зависит от $tau$. В этом
    случае необходимое спектральное условие Неймана
    равносильно требованию, чтобы спектр $lambda(alpha)$
    лежал внутри единичного круга: $|1 slash lambda(alpha)| >= 1$.
  ],
  align(
    center + horizon,
    cetz.canvas({
      import cetz.draw: *
      import plot: *
      set-style(axes: (stroke: gray, shared-zero: $$))
      plot(
        name: "spec",
        size: (6, 6),
        axis-style: "school-book",
        x-tick-step: 1,
        x-label: $frak(R) lambda^(-1)$,
        x-min: -2,
        x-max: 2,
        x-format: tick-fmt,
        y-tick-step: 1,
        y-label: $frak(I) lambda^(-1)$,
        y-min: -2,
        y-max: 2,
        y-format: tick-fmt,
        {
          spectrum-circle(1, (fill: none, stroke: 0.2pt)) // for reference
          spectrum-circle(0.036, (fill: light-green, stroke: none), inverse: true)
          spectrum-circle(0.1, (fill: none, stroke: (dash: "dashed")))
          spectrum-circle(2.5, (fill: none, stroke: (dash: "dashed")))
        },
      )
      circle("spec.c01", radius: 0.03, fill: black, stroke: none)
      content(
        "spec.c01",
        anchor: "south-east",
        padding: (bottom: 5pt, right: 5pt),
        text(size: 8pt, align(center, $r = 0.01$)),
      )
      circle("spec.c25", radius: 0.03, fill: black)
      content(
        "spec.c25",
        anchor: "south",
        padding: (bottom: 5pt),
        text(size: 8pt, align(center, $1 + r >= 0 \ r = 2.5$)),
      )
    }),
  ),
)

$
  forall alpha in RR : quad
  abs(1 / lambda(alpha))
  &= abs(1 + r - r e^(i alpha))
  = abs(1 + r - r (cos alpha + i sin alpha))
  = sqrt((1 + r - r cos alpha)^2 + (r sin alpha)^2)
  = \ =& quad
  sqrt((1 + r)^2 - 2r(1 + r)cos alpha + r^2) >= 1
  \ <==>& quad
  (1 + 2r + r^2) - 2r(1 + r) cos alpha + r^2 >= 1
  \ <==>& quad
  1 + 2r + 2r^2 - 2r(1 + r) cos alpha >= 1
  \ <==>& quad
  2r + 2r^2 - 2r(1 + r) cos alpha >= 0
  \ <==>& quad
  1 + r - (1 + r) cos alpha >= 0
  \ <==>& quad
  (1 + r)(1 - cos alpha) >= 0
  \ <==>& quad
  1 + r >= 0
  \ <==>& quad
  r >= -1, " но так как по условию" r >= 0:
  \ <==>& quad
  (7 tau) / h >= 0
  \ <==>& quad
  tau >= 0.
$

#enum(
  numbering: it => [*Ответ:*],
  [
    Схема обладает аппроксимацией первого порядка по времени и пространству,
    является устойчивой и сходящейся при любых значениях параметров.
  ],
)


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

=== Задание 3

$
  (diff u) / (diff t) - 7 (diff u) / (diff x) = 0, quad u(x, 0) = f(x)
$
Разностная схема:
$
  (u_m^p - u_m^(p - 1)) / tau - 7 (u_m^p - u_(m - 1)^p) / h = 0, quad u_m^0 = f(m h)
$

*Решение.*

*Дифференциальный оператор и правая часть задачи:*
#grid(
  columns: (1fr, 1fr),
  align: center + horizon,
  $L u = cases(
    (diff u) / (diff t) - 7 (diff u) / (diff x) &comma quad x in RR comma space t > 0 semi,
    u(x comma 0) comma &quad x in RR comma space t = 0
  )$,
  $f = cases(
    0 &comma quad x in RR comma space t > 0 semi,
    f(x) &comma quad x in RR comma space t = 0.
  )$,
)

*Разностный оператор и правая часть задачи:*
$
  L_h u^((h)) = cases(
    (u_m^(p+1) - u_m^p) / tau - 7 (u_m^p - u_(m-1)^p) / h comma &quad m in ZZ comma space p = seq(0, 1, [T/tau] - 1) semi,
    u_m^0 comma &quad m in ZZ
  )
$
$
  f^((h)) = cases(
    0 comma &quad m in ZZ comma space p = seq(0, 1, [T/tau] - 1) semi,
    f(m h) comma &quad m in ZZ
  )
$

#grid(
  columns: (1fr, 1fr),
  align: horizon,
  [*Шаблон разностной схемы:*],
  align(
    center + horizon,
    cetz.canvas(
      length: 1.5cm,
      {
        import cetz.draw: *

        let m = 1
        let p = 1

        // Соединяем линиями
        line((m, p - 1), (m, p), stroke: gray)
        line((m - 1, p), (m, p), stroke: gray)

        // Выделяем активные точки схемы для (m,p)
        circle((m, p), radius: 0.05, fill: black)
        content((m, p + 0.3), text(size: 8pt, $(m, p)$))
        circle((m, p - 1), radius: 0.05, fill: black)
        content((m + 0.6, p - 1), text(size: 8pt, $(m, p - 1)$))
        circle((m - 1, p), radius: 0.05, fill: black)
        content((m - 1, p + 0.3), text(size: 8pt, $(m - 1, p)$))
      },
    ),
  ),
)

Для аппроксимации частной производной по пространству применяется
левая конечная разность, она имеет первый порядок аппроксимации.
Для аппроксимации частной производной по времени применяется
правая конечная разность, она имеет первый порядок аппроксимации.
Начальные условия задаются точно.
Поэтому ошибка аппроксимации схемы является величиной $O(h) + O(tau)$.

*Погрешность аппроксимации:*
$
  L_h [u]_h = f^(h) + delta f(h)
  space "где" space
  delta f(h) = cases(
    O(tau + h) comma &quad m in ZZ comma space p >= 1,
    0 comma &quad m in ZZ comma space p = 0,
  )
$

*Исследование на устойчивость.*

Применим спектральный признак устойчивости Неймана.
Подставим $u_m^p = lambda^p e^(i alpha m)$
в разностное уравнение:
$
  (lambda^p e^(i alpha m) - lambda^(p - 1) e^(i alpha m)) / tau - 7 (lambda^p e^(i alpha m) - lambda^p e^(i alpha (m - 1))) / h = 0
$

Вынесем общий множитель $lambda^(p - 1) e^(i alpha m)$ за скобки:
$
  lambda^(p - 1) e^(i alpha m) [(lambda - 1) / tau - 7 lambda (1 - e^(-i alpha)) / h] = 0
$

Обозначим $r = 7 tau slash h = "const"$ и выразим $1 slash lambda$. Тогда
$
  (lambda - 1) / tau = 7 lambda (1 - e^(-i alpha)) / h
  quad ==> quad
  1 - 1 / lambda = r (1 - e^(-i alpha))
  quad ==> quad
  1 / lambda(alpha) = 1 - r + r e^(-i alpha).
$

#grid(
  columns: (1fr, auto),
  gutter: 2em,
  align(horizon)[
    В данной задаче спектр не зависит от $tau$.
    В этом случае необходимое спектральное условие Неймана
    равносильно требованию, чтобы спектр $lambda(alpha)$
    лежал внутри единичного круга: $|1 slash lambda(alpha)| >= 1$.
  ],
  align(
    center + horizon,
    cetz.canvas({
      import cetz.draw: *
      import plot: *
      set-style(axes: (stroke: gray, shared-zero: $$))
      plot(
        name: "spec",
        size: (6, 6),
        axis-style: "school-book",
        x-tick-step: 1,
        x-label: $frak(R) lambda^(-1)$,
        x-min: -2,
        x-max: 2,
        x-format: tick-fmt,
        y-tick-step: 1,
        y-label: $frak(I) lambda^(-1)$,
        y-min: -2,
        y-max: 2,
        y-format: tick-fmt,
        {
          spectrum-circle(1, (fill: none, stroke: 0.2pt)) // for reference
          spectrum-circle(1, (fill: light-green, stroke: 0.2pt), inverse: true)
          spectrum-circle(0.7, (fill: none, stroke: (dash: "dashed")))
          spectrum-circle(2.5, (fill: none, stroke: (dash: "dashed")))
        },
      )
      circle("spec.c07", radius: 0.03, fill: black)
      content(
        "spec.c07",
        anchor: "south",
        padding: (bottom: 5pt),
        text(size: 8pt, align(center, $1 - r > 1 \ r = 0.7$)),
      )
      circle("spec.c25", radius: 0.03, fill: black)
      content(
        "spec.c25",
        anchor: "south",
        padding: (bottom: 5pt),
        text(size: 8pt, align(center, $1 - r < 1 \ r = 2.5$)),
      )
    }),
  ),
)

#show math.equation: set block(breakable: true)
$
  forall alpha in RR : quad
  abs(1 / lambda(alpha))
  &= abs(1 - r + r e^(-i alpha))
  = abs(1 - r + r (cos alpha - i sin alpha))
  = sqrt((1 - r + r cos alpha)^2 + (r sin alpha)^2)
  = \ =& quad
  sqrt((1 - r)^2 + 2r(1 - r)cos alpha + r^2) >= 1
  \ <==>& quad
  (1 - r)^2 + 2r(1 - r) cos alpha + r^2 >= 1
  \ <==>& quad
  (1 - 2r + r^2) + 2r(1 - r) cos alpha + r^2 >= 1
  \ <==>& quad
  1 - 2r + 2r^2 + 2r(1 - r) cos alpha >= 1
  \ <==>& quad
  -2r + 2r^2 + 2r(1 - r) cos alpha >= 0
  \ <==>& quad
  -1 + r + (1 - r) cos alpha >= 0
  \ <==>& quad
  r - 1 + (1 - r) cos alpha >= 0
  \ <==>& quad
  (r - 1) - (r - 1) cos alpha >= 0
  \ <==>& quad
  (r - 1)(1 - cos alpha) >= 0
  \ <==>& quad
  r - 1 >= 0
  \ <==>& quad
  (7 tau) / h >= 1
  \ <==>& quad
  tau >= h / 7.
$

#enum(
  numbering: it => [*Ответ:*],
  [
    Схема обладает аппроксимацией первого порядка по времени и пространству,
    является условно устойчивой при $tau >= h slash 7$,
    является сходящейся с первым порядком при условии $tau >= h slash 7$.
  ],
)


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

=== Задание 4

$
  (diff u) / (diff t) - 7 (diff u) / (diff x) = 0, quad u(x, 0) = f(x)
$
Разностная схема:
$
  (u_m^(p + 1) - u_m^p) / tau - 7 (u_m^p - u_(m - 1)^p) / h = 0, quad u_m^0 = f(m h)
$

*Решение.*

*Дифференциальный оператор и правая часть задачи:*
#grid(
  columns: (1fr, 1fr),
  align: center + horizon,
  $L u = cases(
    (diff u) / (diff t) - 7 (diff u) / (diff x) &comma quad x in RR comma space t > 0 semi,
    u(x comma 0) comma &quad x in RR comma space t = 0
  )$,
  $f = cases(
    0 &comma quad x in RR comma space t > 0 semi,
    f(x) &comma quad x in RR comma space t = 0.
  )$,
)

*Разностный оператор и правая часть задачи:*
$
  L_h u^((h)) = cases(
    (u_m^(p+1) - u_m^p) / tau - 7 (u_m^p - u_(m-1)^p) / h comma &quad m in ZZ comma space p = seq(0, 1, [T/tau] - 1) semi,
    u_m^0 comma &quad m in ZZ
  )
$
$
  f^((h)) = cases(
    0 comma &quad m in ZZ comma space p = seq(0, 1, [T/tau] - 1) semi,
    f(m h) comma &quad m in ZZ
  )
$

#grid(
  columns: (1fr, 1fr),
  [*Шаблон разностной схемы:*],
  align: horizon,
  align(
    center + horizon,
    cetz.canvas(
      length: 1.5cm,
      {
        import cetz.draw: *

        let m = 1
        let p = 1

        // Соединяем линиями
        line((m, p), (m, p + 1), stroke: gray)
        line((m - 1, p), (m, p), stroke: gray)

        // Выделяем активные точки схемы для (m,p)
        circle((m, p), radius: 0.05, fill: black)
        content((m + 0.6, p), text(size: 8pt, $(m, p)$))
        circle((m, p + 1), radius: 0.05, fill: black)
        content((m + 0.6, p + 1), text(size: 8pt, $(m, p + 1)$))
        circle((m - 1, p), radius: 0.05, fill: black)
        content((m - 1, p + 0.3), text(size: 8pt, $(m - 1, p)$))
      },
    ),
  )
)

Для аппроксимации частной производной по пространству применяется
левая конечная разность, она имеет первый порядок аппроксимации.
Для аппроксимации частной производной по времени применяется
правая конечная разность, она имеет первый порядок аппроксимации.
Начальные условия задаются точно.
Поэтому ошибка аппроксимации схемы является величиной $O(h) + O(tau)$.

*Погрешность аппроксимации:*
$
  L_h [u]_h = f^(h) + delta f(h)
  space "где" space
  delta f(h) = cases(
    O(tau + h) comma &quad m in ZZ comma space p >= 0,
    0 comma &quad m in ZZ comma space p = 0.
  )
$

*Исследование на устойчивость.*

Применим спектральный признак устойчивости Неймана.
Подставим выражение $U_m^p = lambda^p e^(i alpha m)$
в однородное разностное уравнение:
$
  (lambda^(p + 1) e^(i alpha m) - lambda^p e^(i alpha m)) / tau - 7 (lambda^p e^(i alpha m) - lambda^p e^(i alpha (m - 1))) / h = 0
$

Вынесем общий множитель $lambda^p e^(i alpha m)$ за скобки:
$
  lambda^p e^(i alpha m) [(lambda - 1) / tau - 7 (1 - e^(-i alpha)) / h] = 0
$

Обозначим $r = (7 tau) / h = "const"$ и выразим $lambda$. Тогда
$
  (lambda - 1) / tau = 7 (1 - e^(-i alpha)) / h
  quad ==> quad
  lambda - 1 = r (1 - e^(-i alpha))
  quad ==> quad
  lambda(alpha) = 1 + r - r e^(-i alpha)
$

#grid(
  columns: (1fr, auto),
  gutter: 2em,
  align(horizon)[
    В данной задаче спектр не зависит от $tau$.
    В этом случае необходимое спектральное условие Неймана
    равносильно требованию, чтобы спектр $lambda(alpha)$
    лежал внутри единичного круга: $|lambda(alpha)| <= 1$.
  ],
  align(
    center + horizon,
    cetz.canvas({
      import cetz.draw: *
      import plot: *
      set-style(axes: (stroke: gray))
      plot(
        name: "spec",
        size: (6, 3),
        axis-style: "school-book",
        x-tick-step: 1,
        x-label: $frak(R) lambda$,
        x-min: -1,
        x-max: 3,
        x-format: tick-fmt,
        y-tick-step: 1,
        y-label: $frak(I) lambda$,
        y-min: -1,
        y-max: 1,
        y-format: tick-fmt,
        {
          spectrum-circle(1, (fill: none, stroke: 0.2pt)) // for reference
          let r = 1
          add-fill-between(
            domain: (1, 1 + 2 * r),
            style: (fill: red.transparentize(80%), stroke: (dash: "dashed")),
            x => calc.sqrt(calc.abs(r * r - calc.pow(x - (1 + r), 2))),
            x => -calc.sqrt(calc.abs(r * r - calc.pow(x - (1 + r), 2))),
          )
          add-anchor("1", (1 + r, 0))
        },
      )
      content(
        "spec.1",
        anchor: "south",
        padding: (bottom: 5pt),
        text(size: 8pt, align(center, $1 + 2r <= 1 \ r = 0.5$)),
      )
    }),
  ),
)

$
  forall alpha in RR : quad
  abs(lambda(alpha))
  = abs(1 + r - r e^(-i alpha))
  = abs(1 + r - r (cos alpha - i sin alpha))
  = \ =
  sqrt((1 + r - r cos alpha)^2 + (r sin alpha)^2)
  = sqrt((1 + r)^2 - 2r(1 + r)cos alpha + r^2)
  <= 1
$

Максимальное значение $abs(lambda(alpha))$ достигается
при $cos alpha = -1$:
$
  sqrt((1 + r)^2 - 2r(1 + r)cos alpha + r^2)
  <= sqrt(1 + 2r + 2r² - 2r(1 + r)(-1))
  = sqrt(1 + 2r + 2r² + 2r(1 + r))
  = \ =
  sqrt(1 + 2r + 2r² + 2r + 2r²)
  = sqrt(1 + 4r + 4r²)
  = sqrt((1 + 2r)²)
  = |1 + 2r|
$

Для устойчивости нужно $|1 + 2r| <= 1$.
Это условие никогда не выполняется.

Схема неустойчива при любых значениях $tau$ и $h$.

#enum(
  numbering: it => [*Ответ:*],
  [
    Схема обладает аппроксимацией первого порядка по времени и пространству, является неустойчивой при любых значениях параметров, не является сходящейся.
  ],
)
