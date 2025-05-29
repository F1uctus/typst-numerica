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
#set par(justify: true, first-line-indent: 2em)
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
$
  L u = cases(
    pdv(u, t) - 7 pdv(u, x) comma &quad x in RR comma space 0 < t <= T semi,
    u(x comma 0) comma &quad x in RR comma space t = 0 dot
  )
$
$
  f = cases(
    0 comma &quad x in RR comma space 0 < t <= T semi,
    f(x) comma &quad x in RR comma space t = 0
  )
$

*Разностный оператор и правая часть задачи:*
$
  L_h u^((h)) = cases(
    (u_m^{p+1} - u_m^p) / tau - 7 (u_(m+1)^p - u_m^p) / h comma &quad m in ZZ comma space p = seq(0, 1, [T/tau] - 1) semi,
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
  align: center + horizon,
  cetz.canvas(
    length: 1.5cm,
    {
      import cetz.draw: *

      // Выделяем активные точки схемы для (m,p)
      let m = 1
      let p = 1
      circle((m, p), radius: 0.05, fill: black)
      content((m, p + 0.3), text(size: 8pt, $(m, p)$))

      circle((m, p - 1), radius: 0.05, fill: black)
      content((m + 0.6, p - 1), text(size: 8pt, $(m, p - 1)$))

      circle((m + 1, p), radius: 0.05, fill: black)
      content((m + 1, p + 0.3), text(size: 8pt, $(m + 1, p)$))

      // Соединяем линиями
      line((m, p - 1), (m, p), stroke: gray)
      line((m, p), (m + 1, p), stroke: gray)
    },
  )
)

Для аппроксимации частной производной по пространству применяется левая конечная разность, она имеет первый порядок аппроксимации. Для аппроксимации частной производной по времени применяется правая конечная разность, она имеет первый порядок аппроксимации.

Начальные условия задаются точно. Таким образом, ошибка аппроксимации схемы является величиной $O(h) + O(tau)$.

*Погрешность аппроксимации:*
$
  L_h [u]_h = f^(h) + delta f(h)
$
где $delta f(h) = cases(O(tau + h) &comma quad m in ZZ comma space p >= 1, 0 &comma quad m in ZZ comma space p = 0)$

*Исследование на устойчивость.*

Исследуем разностную схему на устойчивость, применяя необходимый спектральный признак устойчивости Неймана. Подставим выражение $U_m^p = lambda^p e^(i alpha m)$ в однородное разностное уравнение:
$
  (lambda^p e^(i alpha m) - lambda^(p - 1) e^(i alpha m)) / tau - 7 (lambda^p e^(i alpha (m + 1)) - lambda^p e^(i alpha m)) / h = 0
$

Вынесем общий множитель $lambda^(p - 1) e^(i alpha m)$ за скобки:
$
  lambda^(p - 1) e^(i alpha m) [(lambda - 1) / tau - 7 lambda (e^(i alpha) - 1) / h] = 0
$

Обозначим $r = (7 tau) / h = "const"$ и выразим $lambda$:
$
  (lambda - 1) / tau = 7 lambda (e^(i alpha) - 1) / h
$
$
  lambda - 1 = r lambda (e^(i alpha) - 1)
$
$
  lambda (1 - r (e^(i alpha) - 1)) = 1
$
$
  lambda(alpha) = 1 / (1 - r + r e^(i alpha))
$

В данной задаче спектр не зависит от $tau$. В этом случае необходимое спектральное условие Неймана равносильно требованию, чтобы спектр $lambda(alpha)$ лежал в единичном круге: $|lambda(alpha)| <= 1$.

Имеем:
$
  abs(lambda(alpha))
  = 1 / abs(1 - r + r e^(i alpha))
  = 1 / abs(1 - r + r (cos alpha + i sin alpha))
  = \ =
  1 / sqrt((1 - r + r cos alpha)^2 + (r sin alpha)^2)
  = 1 / sqrt((1 - r)^2 + 2r(1 - r)cos alpha + r^2)
$

Для устойчивости нужно $|lambda(alpha)| <= 1$, что означает:
$
  sqrt((1 - r)^2 + 2r(1 - r)cos alpha + r^2) >= 1
$

Минимальное значение знаменателя достигается при $cos alpha = -1$ (если $1 - r > 0$):
$
  sqrt((1 - r - r)^2) = |1 - 2r|
$

Для устойчивости нужно $|1 - 2r| >= 1$. Это выполняется при $r <= 0$ или $r >= 1$.

Поскольку $r = (7 tau) / h > 0$, условие устойчивости: $r >= 1$, то есть $(7 tau) / h >= 1$ или $tau >= h / 7$.

Схема условно устойчива при $tau >= h / 7$.

#enum(
  numbering: it => [*Ответ:*],
  [
    Схема обладает аппроксимацией первого порядка по времени и пространству, является условно устойчивой при $tau >= h / 7$, является сходящейся с первым порядком при условии $tau >= h / 7$.
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
$
  L u = cases(
    (diff u) / (diff t) - 7 (diff u) / (diff x) &comma quad x in RR comma space t > 0,
    u(x comma 0) comma &quad x in RR comma space t = 0
  )
$
$
  f = cases(
    0 &comma quad x in RR comma space t > 0,
    f(x) &comma quad x in RR comma space t = 0
  )
$

*Разностный оператор и правая часть задачи:*
$
  L_h u^((h)) = cases(
    (u_m^(p+1) - u_m^p) / tau - 7 (u_m^p - u_(m-1)^p) / h comma &quad m in ZZ comma space p = seq(0, 1, [T/tau] - 1) semi,
    u_m^0 comma &quad m in ZZ
  )
$
$
  f^((h)) = cases(
    0 &comma quad m in ZZ comma space p = seq(0, 1, [T/tau] - 1) semi,
    f(m h) &comma quad m in ZZ
  )
$

#grid(
  columns: (1fr, 1fr),
  align: center+horizon,
  [*Шаблон разностной схемы:*],
cetz.canvas(
  length: 1.5cm,
  {
    import cetz.draw: *

    // Выделяем активные точки схемы для (m,p)
    let m = 1
    let p = 1
    circle((m, p), radius: 0.05, fill: black)
    content((m, p + 0.3), text(size: 8pt, $(m, p)$))
    circle((m, p - 1), radius: 0.05, fill: black)
    content((m + 0.6, p - 1), text(size: 8pt, $(m, p - 1)$))
    circle((m - 1, p), radius: 0.05, fill: black)
    content((m - 1, p + 0.3), text(size: 8pt, $(m - 1, p)$))

    // Соединяем линиями
    line((m, p - 1), (m, p), stroke: gray)
    line((m - 1, p), (m, p), stroke: gray)
  },
)
)

Для аппроксимации частной производной по пространству применяется левая конечная разность, она имеет первый порядок аппроксимации. Для аппроксимации частной производной по времени применяется правая конечная разность, она имеет первый порядок аппроксимации.

Начальные условия задаются точно. Таким образом, ошибка аппроксимации схемы является величиной $O(h) + O(tau)$.

*Погрешность аппроксимации:*
$
  L_h [u]_h = f^(h) + delta f(h)
$
где $delta f(h) = cases(O(tau + h) &comma quad m in ZZ comma space p >= 1, 0 &comma quad m in ZZ comma space p = 0)$

*Исследование на устойчивость.*

Применим спектральный признак устойчивости Неймана.
Подставим выражение $U_m^p = lambda^p e^(i alpha m)$
в однородное разностное уравнение:
$
  (lambda^p e^(i alpha m) - lambda^(p - 1) e^(i alpha m)) / tau - 7 (lambda^p e^(i alpha m) - lambda^p e^(i alpha (m - 1))) / h = 0
$

Вынесем общий множитель $lambda^(p - 1) e^(i alpha m)$ за скобки:
$
  lambda^(p - 1) e^(i alpha m) [(lambda - 1) / tau - 7 lambda (1 - e^(-i alpha)) / h] = 0
$

Обозначим $r = (7 tau) / h = "const"$ и выразим $lambda$:
$
  (lambda - 1) / tau = 7 lambda (1 - e^(-i alpha)) / h
$
$
  lambda - 1 = r lambda (1 - e^(-i alpha))
$
$
  lambda (1 - r (1 - e^(-i alpha))) = 1
$
$
  lambda(alpha) = 1 / (1 - r + r e^(-i alpha))
$

В данной задаче спектр не зависит от $tau$.
В этом случае необходимое спектральное условие Неймана равносильно требованию,
чтобы спектр $lambda(alpha)$ лежал в единичном круге: $|lambda(alpha)| <= 1$.

Имеем:
$
  abs(lambda(alpha))
  = 1 / abs(1 - r + r e^(-i alpha))
  = 1 / abs(1 - r + r (cos alpha - i sin alpha))
  = \ =
  1 / sqrt((1 - r + r cos alpha)^2 + (r sin alpha)^2)
  = 1 / sqrt((1 - r)^2 + 2r(1 - r)cos alpha + r^2)
$

Для устойчивости нужно $|lambda(alpha)| <= 1$, что означает:
$
  sqrt((1 - r)^2 + 2r(1 - r)cos alpha + r^2) >= 1
$

Минимальное значение знаменателя достигается при $cos alpha = -1$ (если $1 - r > 0$):
$
  sqrt((1 - r - r)^2) = |1 - 2r|
$

Для устойчивости нужно $|1 - 2r| >= 1$. Это выполняется при $r <= 0$ или $r >= 1$.

Поскольку $r = (7 tau) / h > 0$, условие устойчивости: $r >= 1$, то есть $(7 tau) / h >= 1$ или $tau >= h / 7$.

Схема условно устойчива при $tau >= h / 7$.

#enum(
  numbering: it => [*Ответ:*],
  [
    Схема обладает аппроксимацией первого порядка по времени и пространству, является условно устойчивой при $tau >= h / 7$, является сходящейся с первым порядком при условии $tau >= h / 7$.
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
$
  L u = cases(
    (diff u) / (diff t) - 7 (diff u) / (diff x) &comma quad x in RR comma space t > 0,
    u(x comma 0) comma &quad x in RR comma space t = 0
  )
$
$
  f = cases(
    0 &comma quad x in RR comma space t > 0,
    f(x) &comma quad x in RR comma space t = 0
  )
$

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
  align: center+horizon,
cetz.canvas(
  length: 1.5cm,
  {
    import cetz.draw: *

    // Выделяем активные точки схемы для (m,p)
    let m = 1
    let p = 1
    circle((m, p), radius: 0.05, fill: black)
    content((m + 0.6, p), text(size: 8pt, $(m, p)$))
    circle((m, p + 1), radius: 0.05, fill: black)
    content((m + 0.6, p + 1), text(size: 8pt, $(m, p + 1)$))
    circle((m - 1, p), radius: 0.05, fill: black)
    content((m - 1, p + 0.3), text(size: 8pt, $(m - 1, p)$))

    // Соединяем линиями
    line((m, p), (m, p + 1), stroke: gray)
    line((m - 1, p), (m, p), stroke: gray)
  },
)
)

Для аппроксимации частной производной по пространству применяется левая конечная разность, она имеет первый порядок аппроксимации. Для аппроксимации частной производной по времени применяется правая конечная разность, она имеет первый порядок аппроксимации.

Начальные условия задаются точно. Таким образом, ошибка аппроксимации схемы является величиной $O(h) + O(tau)$.

*Погрешность аппроксимации:*
$
  L_h [u]_h = f^(h) + delta f(h)
$
где $delta f(h) = cases(O(tau + h) &comma quad m in ZZ comma space p >= 0, 0 &comma quad m in ZZ comma space p = 0)$

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

Обозначим $r = (7 tau) / h = "const"$ и выразим $lambda$:
$
  (lambda - 1) / tau = 7 (1 - e^(-i alpha)) / h
$
$
  lambda - 1 = r (1 - e^(-i alpha))
$
$
  lambda(alpha) = 1 + r (1 - e^(-i alpha)) = 1 + r - r e^(-i alpha)
$

В данной задаче спектр не зависит от $tau$.
В этом случае необходимое спектральное условие Неймана равносильно требованию,
чтобы спектр $lambda(alpha)$ лежал в единичном круге: $|lambda(alpha)| <= 1$.

Имеем:
$
  |lambda(alpha)| = |1 + r - r e^(-i alpha)| = |1 + r - r (cos alpha - i sin alpha)|
$
$
  = sqrt((1 + r - r cos alpha)^2 + (r sin alpha)^2) = sqrt((1 + r)^2 - 2r(1 + r)cos alpha + r^2)
$

Спектр представляет собой окружность с центром в точке $(1 + r, 0)$ и радиусом $r$. Максимальное значение $|lambda(alpha)|$ достигается при $cos alpha = -1$:
$
  |lambda(alpha)|_max = sqrt((1 + r + r)^2) = 1 + 2r
$

Для устойчивости нужно $|lambda(alpha)| <= 1$, что означает:
$
  1 + 2r <= 1 quad => quad r <= 0
$

Поскольку $r = (7 tau) / h > 0$, это условие никогда не выполняется.

Схема неустойчива при любых значениях $tau$ и $h$.

#enum(
  numbering: it => [*Ответ:*],
  [
    Схема обладает аппроксимацией первого порядка по времени и пространству, является неустойчивой при любых значениях параметров, не является сходящейся.
  ],
)
