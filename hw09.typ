#import "@preview/cetz:0.3.4"
#import "@preview/cetz-plot:0.1.1": plot, chart
#import "@preview/physica:0.9.5": *
#import "@preview/showybox:2.0.4": showybox


#let SURNAME_NAME = "Никитин Илья"
#let UNN_GROUP = "3822Б1МА1"
#let n = 21


#set page(
  paper: "a4",
  margin: (top: 3em, rest: 0.8cm),
  numbering: "1 / 1",
  header: [
    ДЗ.09. Решение разностных уравнений.
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
#set table(
  align: horizon + center,
  stroke: gray + 0.2mm,
)
#set par(justify: true)

#let round(x) = calc.round(x, digits: 4)
#let tick-fmt(v) = {
  set text(size: 9pt)
  v
}
#let big(formula) = $lr(#formula, size: #175%)$

#let tasks = counter("tasks-counter")
#tasks.step()

#let exercises = counter("exercises-counter")

//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
=== Задание 1
Найти общее решение однородных разностных уравнений:

#let exercise-hom-diff-eq(
  setup-eq: none,
  char-eq: none,
  solution: none,
  answer: none,
) = context {
  exercises.step()
  showybox(
    frame: (inset: 4pt, thickness: 0.1pt),
    breakable: true,
    grid(
      columns: (auto, 1fr),
      rows: 3,
      inset: 5pt,
      align(right + horizon)[*
        №
        #(context tasks.display()).#(context exercises.display())
        *],
      [
        #show math.frac: it => $it.num slash it.denom$
        #block($#setup-eq.$)
      ],
      align(right + horizon)[*Решение.*], [
        Характеристическое уравнение:
        #char-eq.
      ], grid.cell(colspan: 2)[
        #solution
      ],
      align(right + horizon)[*Ответ:*], [
        #show math.frac: it => $it.num slash it.denom$
        #block($#answer.$)
      ]
    ),
  )
}

#exercise-hom-diff-eq(
  setup-eq: $ y_(k+2) - 9y_(k+1) + 20y_k = 0 $,
  char-eq: $lambda^2 - 9 lambda + 20 = 0$,
  solution: [
    $
      D = 9^2 - 4 dot 1 dot 20 = 81 - 80 = 1,
      quad lambda_(1,2) = frac(9 plus.minus sqrt(1), 2) = frac(9 plus.minus 1, 2)
      quad ==>
      quad lambda_1 = frac(9 + 1, 2) = 5,
      quad lambda_2 = frac(9 - 1, 2) = 4.
    $
  ],
  answer: $ y_k = C_1 dot 5^k + C_2 dot 4^k $,
)

#exercise-hom-diff-eq(
  setup-eq: $ y_(k+2) - 6y_(k+1) + 9y_k = 0 $,
  char-eq: $lambda^2 - 6 lambda + 9 = 0$,
  solution: [
    $
      D = 6^2 - 4 dot 1 dot 9 = 36 - 36 = 0
      quad ==>
      quad lambda_(1,2) = frac(6, 2) = 3.
    $
  ],
  answer: $ y_k = (C_1 + C_2 k) dot 3^k $,
)

#exercise-hom-diff-eq(
  setup-eq: $ y_(k+2) - 9y_(k+1) + 20y_k = 0 $,
  char-eq: $lambda^2 - 9 lambda + 20 = 0$,
  solution: [
    $
      D = 9^2 - 4 dot 1 dot 20 = 81 - 80 = 1,
      quad lambda_(1,2) = frac(9 plus.minus sqrt(1), 2) = frac(9 plus.minus 1, 2)
      quad ==>
      quad lambda_1 = frac(9 + 1, 2) = 5,
      quad lambda_2 = frac(9 - 1, 2) = 4.
    $
  ],
  answer: $ y_k = C_1 dot 5^k + C_2 dot 4^k $,
)

#exercise-hom-diff-eq(
  setup-eq: $ y_(k+2) - 6y_(k+1) + 9y_k = 0 $,
  char-eq: $lambda^2 - 6 lambda + 9 = 0$,
  solution: [
    $
      D = 6^2 - 4 dot 1 dot 9 = 36 - 36 = 0
      quad ==>
      quad lambda_(1,2) = frac(6, 2) = 3.
    $
  ],
  answer: $ y_k = (C_1 + C_2 k) dot 3^k $,
)

#exercise-hom-diff-eq(
  setup-eq: $ y_(k+2) - y_(k+1) + y_k = 0 $,
  char-eq: $lambda^2 - lambda + 1 = 0$,
  solution: [
    $
      D = 1^2 - 4 dot 1 dot 1 = 1 - 4 = -3
      quad ==>
      quad lambda_(1,2) = frac(1 plus.minus i sqrt(3), 2),
      \ rho = |lambda| = sqrt((frac(1, 2))^2 + (frac(sqrt(3), 2))^2)
      = 1,
      quad cos phi = frac(1 slash 2, rho) = frac(1, 2),
      quad sin phi = frac(sqrt(3) slash 2, rho) = frac(sqrt(3), 2)
      quad ==> quad phi = frac(pi, 3).
    $
  ],
  answer: $ y_k = C_1 cos(pi k slash 3) + C_2 sin(pi k slash 3) $,
)

#exercise-hom-diff-eq(
  setup-eq: $ y_(k+2) - 6y_(k+1) + 5y_k = 0 $,
  char-eq: $lambda^2 - 6 lambda + 5 = 0$,
  solution: [
    $
      D = 6^2 - 4 dot 1 dot 5 = 36 - 20 = 16,
      quad lambda_(1,2) = frac(6 plus.minus sqrt(16), 2) = frac(6 plus.minus 4, 2)
      quad ==>
      quad lambda_1 = frac(6 + 4, 2) = 5,
      quad lambda_2 = frac(6 - 4, 2) = 1.
    $
  ],
  answer: $ y_k = C_1 dot 5^k + C_2 $,
)

#pagebreak()

#exercise-hom-diff-eq(
  setup-eq: $ y_(k+2) - 5y_(k+1) + 2y_k = 0 $,
  char-eq: $lambda^2 - 5 lambda + 2 = 0$,
  solution: [
    $
      D = 5^2 - 4 dot 1 dot 2 = 25 - 8 = 17,
      quad lambda_(1,2) = frac(5 plus.minus sqrt(17), 2)
      quad ==>
      quad lambda_1 = frac(5 + sqrt(17), 2),
      quad lambda_2 = frac(5 - sqrt(17), 2).
    $
  ],
  answer: $ y_k = C_1 dot (frac(5 + sqrt(17), 2))^k + C_2 dot (frac(5 - sqrt(17), 2))^k $,
)

#exercise-hom-diff-eq(
  setup-eq: $ y_(k+2) - 3y_(k+1) + 9y_k = 0 $,
  char-eq: $lambda^2 - 3 lambda + 9 = 0$,
  solution: [
    $
      D = 3^2 - 4 dot 1 dot 9 = 9 - 36 = -27,
      quad lambda_(1,2) = frac(3 plus.minus i sqrt(27), 2)
      = frac(3 plus.minus 3i sqrt(3), 2)
      = frac(3, 2) plus.minus frac(3sqrt(3), 2)i,
      \ rho = |lambda| = sqrt((frac(3, 2))^2 + (frac(3sqrt(3), 2))^2)
      = 3,
      quad cos phi = frac(3 slash 2, rho) = frac(1, 2),
      quad sin phi = frac(3sqrt(3) slash 2, rho) = frac(sqrt(3), 2),
      quad ==> quad phi = frac(pi, 3).
    $
  ],
  answer: $ y_k = 3^k (C_1 cos(pi k slash 3) + C_2 sin(pi k slash 3)) $,
)

//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
=== Задание 2
#tasks.step()
#exercises.update(0)
Найти общее решение неоднородных разностных уравнений:

#exercise-hom-diff-eq(
  setup-eq: $ y_(k+1) - 2y_k + y_(k-1) = 5k + 2 $,
  char-eq: $lambda^2 - 2lambda + 1 = 0$,
  solution: [
    #show math.frac: it => $it.num slash it.denom$

    Корни: $lambda = 1$ кратности 2.

    $
      "Общее решение однородного уравнения"
      y_k^o = (C_1 + C_2k) dot 1^k = C_1 + C_2k.
    $

    Поскольку $mu = 1$ -- корень кратности 2,
    частное решение ищем в виде
    $y_k^* = 1^k k^2 (A k + B) = A k^3 + B k^2.$

    Подставим в исходное уравнение:
    $
      A(k+1)^3 + B(k+1)^2 - 2(A k^3 + B k^2) + A (k-1)^3 + B (k-1)
      = 5k + 2.
    $

    Раскроем скобки и приведем подобные:
    $
      &quad A(k^3 + 3k^2 + 3k + 1) + B(k^2 + 2k + 1) - 2A k^3 - 2B k^2
      + A(k^3 - 3k^2 + 3k - 1) + B(k^2 - 2k + 1)
      = \ &= A k^3 + 3A k^2 + 3A k + A + B k^2 + 2B k + B - 2A k^3 - 2B k^2
      + A k^3 - 3A k^2 + 3A k - A + B k^2 - 2B k + B
      = \ &= (A - 2A + A)k^3 + (3A + B - 2B - 3A + B)k^2
      + (3A + 2B + 3A - 2B)k + A + B - A + B
      = \ &= (3A + B - 2B - 3A + B)k^2 + 6A k + 2B
      = \ &= 6A k + 2B = 5k + 2.
    $

    $
      "Частное решение" y_k^* = (5 / 6)k^3 + k^2
      quad <== quad
      cases(
        6A = 5 &==> A = 5 / 6,
        2B = 2 &==> B = 1,
      )
    $
  ],
  answer: $
    y_k = C_1 + C_2k + (5 / 6)k^3 + k^2
  $,
)

#exercise-hom-diff-eq(
  setup-eq: $ y_(k+1) + y_(k-1) = cos(pi k / 2) $,
  char-eq: $lambda^2 + 1 = 0$,
  solution: [
    #show math.frac: it => $it.num slash it.denom$

    Корни: $lambda_(1,2) = plus.minus i.$

    $
      "Общее решение однородного уравнения"
      y_k^o = C_1 cos(pi k / 2) + C_2 sin(pi k / 2).
    $

    Правая часть $f_k = cos(pi k / 2)$.
    Ищем частное решение в виде $y_k^* = k(A cos(pi k / 2) + B sin(pi k / 2))$.

    Подставим в исходное уравнение:
    $
      (k+1)(A cos((k+1) pi / 2) + B sin((k+1) pi / 2))
      + (k-1)(A cos((k-1) pi / 2) + B sin((k-1) pi / 2)).
    $

    Подставим известные тригонометрические выражения:
    $
      cos((k+1) pi / 2) = -sin(pi k / 2),
      &quad sin((k+1) pi / 2) = cos(pi k / 2),
      \ cos((k-1) pi / 2) = sin(pi k / 2),
      &quad sin((k-1) pi / 2) = -cos(pi k / 2).
    $

    $
      &quad
      (k+1)(-A sin(pi k / 2) + B cos(pi k / 2))
      + (k-1)(A sin(pi k / 2) - B cos(pi k / 2))
      = \ &=
      -(k+1)A sin(pi k / 2) + (k+1)B cos(pi k / 2)
      + (k-1)A sin(pi k / 2) - (k-1)B cos(pi k / 2)
      = \ &=
      (-(k+1) + (k-1))A sin(pi k / 2)
      + ((k+1) - (k-1))B cos(pi k / 2)
      = \ &=
      -2A sin(pi k / 2) + 2B cos(pi k / 2)
      = cos(pi k / 2).
    $

    $
      "Частное решение" y_k^* = (k / 2) sin(pi k / 2)
      quad <== quad
      cases(
        2B = 1 &==> B = 1 / 2,
        -2A = 0 &==> A = 0
      )
    $
  ],
  answer: $
    y_k = C_1 cos(pi k / 2) + C_2 sin(pi k / 2) + (k / 2) sin(pi k / 2)
  $,
)

#exercise-hom-diff-eq(
  setup-eq: $ -y_(k+1) + y_(k-1) = cos(pi k / 2) $,
  char-eq: $-lambda^2 + 1 = 0$,
  solution: [
    #show math.frac: it => $it.num slash it.denom$

    Корни: $lambda_(1,2) = plus.minus 1$.

    $
      "Общее решение однородного уравнения"
      y_k^o = C_1 1^k + C_2 (-1)^k = C_1 + C_2 (-1)^k.
    $

    Правая часть $f_k = cos(pi k / 2)$.
    Частное решение ищем в виде
    $y_k^* = A cos(pi k / 2) + B sin(pi k / 2).$

    Подставим в исходное уравнение:
    $
      -(A cos((k+1) pi / 2) + B sin((k+1) pi / 2))
      + (A cos((k-1) pi / 2) + B sin((k-1) pi / 2))
      = cos(pi k / 2).
    $

    Подставим известные тригонометрические выражения:
    $
      cos((k+1) pi / 2) = -sin(pi k / 2),
      &quad sin((k+1) pi / 2) = cos(pi k / 2),
      \ cos((k-1) pi / 2) = sin(pi k / 2),
      &quad sin((k-1) pi / 2) = -cos(pi k / 2).
    $
    $
      &quad
      -(-A sin(pi k / 2) + B cos(pi k / 2)) + (A sin(pi k / 2) - B cos(pi k / 2))
      = \ &=
      A sin(pi k / 2) - B cos(pi k / 2) + A sin(pi k / 2) - B cos(pi k / 2)
      = \ &=
      2A sin(pi k / 2) - 2B cos(pi k / 2) = cos(pi k / 2),
    $

    $
      "Частное решение" y_k^* = -(1 / 2) sin(pi k / 2)
      quad <== quad
      cases(
        -2B = 1 &==> B = -1 / 2,
        2A = 0 &==> A = 0
      )
    $
  ],
  answer: $ y_k = C_1 + C_2 (-1)^k - (1 / 2) sin(pi k / 2) $,
)

#exercise-hom-diff-eq(
  setup-eq: $ y_(k+1) + y_k - 2y_(k-1) = 6 $,
  char-eq: $lambda^2 + lambda - 2 = 0$,
  solution: [
    Корни: $lambda_1 = -2, lambda_2 = 1$.

    $
      "Общее решение однородного уравнения"
      y_k^o = C_1 (-2)^k + C_2 1^k = C_1 (-2)^k + C_2.
    $

    Правая часть имеет вид $f_k = 6 * 1^k = P_0(k) mu^k.$
    Поскольку $mu = 1$ -- корень кратности 1,
    $y_k^* = A k$.

    Подставим в исходное уравнение:
    $
      A(k+1) + A k - 2A(k-1)
      = A k + A + A k - 2A k + 2A
      = 3A
      = 6
      ==> A = 2
    $

    $ "Частное решение" y_k^* = 2k. $
  ],
  answer: $ y_k = C_1 (-2)^k + C_2 + 2k $,
)

#exercise-hom-diff-eq(
  setup-eq: $ y_(k+1) + 2y_k - 3y_(k-1) = 64 * 5^k $,
  char-eq: $lambda^2 + 2lambda - 3 = 0$,
  solution: [
    Корни: $lambda_1 = -3, lambda_2 = 1$

    $
      "Общее решение однородного уравнения"
      y_k^o = C_1 (-3)^k + C_2 1^k = C_1 (-3)^k + C_2
    $

    Правая часть имеет вид $f_k = 64 * 5^k = P_0(k) mu^k.$
    \
    Поскольку $mu = 5$ -- не корень характеристического уравнения,
    $y_k^* = A * 5^k$.

    Подставим в исходное уравнение:
    $
      A * 5^(k+1) + 2A * 5^k - 3A * 5^(k-1)
      = A * 5^k * 5 + 2A * 5^k - 3A * 5^k / 5
      = A * 5^k * 5 + 2A * 5^k - 3A * 5^k / 5
      = 64 * 5^k,
    $
    $
      5A + 2A - (3A) / 5
      = (25A + 10A - 3A) / 5
      = 32A slash 5 = 64
      quad ==> quad
      A = 64 * 5 / 32 = 10.
    $

    $ "Частное решение" y_k^* = 10 * 5^k $
  ],
  answer: $ y_k = C_1 (-3)^k + C_2 + 10 * 5^k $,
)

#exercise-hom-diff-eq(
  setup-eq: $ y_(k+1) - 7y_k + 10y_(k-1) = 4 * 6^k $,
  char-eq: $lambda^2 - 7lambda + 10 = 0$,
  solution: [
    #show math.frac: it => $it.num slash it.denom$

    Корни: $lambda_1 = 5, lambda_2 = 2$

    $ "Общее решение однородного уравнения" y_k^o = C_1 5^k + C_2 2^k $

    Правая часть имеет вид $f_k = 4 * 6^k = P_0(k) mu^k.$
    \
    Поскольку $mu = 6$ -- не корень характеристического уравнения,
    $y_k^* = A * 6^k$.

    Подставим в исходное уравнение:
    $
      A * 6^(k+1) - 7A * 6^k + 10A * 6^(k-1)
      = A * 6^k * 6 - 7A * 6^k + 10A * 6^k / 6 = 4 * 6^k
    $
    $
      6A - 7A + (10A) / 6
      = (4A) / 6 = 4
      quad ==> quad
      A = 6.
    $

    $ "Частное решение" y_k^* = 6 * 6^k. $
  ],
  answer: $ y_k = C_1 5^k + C_2 2^k + 6 * 6^k $,
)

#exercise-hom-diff-eq(
  setup-eq: $ y_(k+1) - 3y_k + 2y_(k-1) = 1 $,
  char-eq: $lambda^2 - 3lambda + 2 = 0$,
  solution: [
    Корни: $lambda_1 = 2, lambda_2 = 1$

    $
      "Общее решение однородного уравнения"
      y_k^o = C_1 2^k + C_2 1^k = C_1 2^k + C_2
    $

    Правая часть $f_k = 1$.
    Поскольку $mu = 1$ -- корень характеристического уравнения,
    $y_k^* = A k$.

    Подставим в исходное уравнение:
    $
      A(k+1) - 3A k + 2A(k-1)
      = A k + A - 3A k + 2A k - 2A
      = 0k + (A - 2A)
      = -A = 1
      quad ==> quad
      A = -1.
    $

    $ "Частное решение" y_k^* = -k. $
  ],
  answer: $ y_k = C_1 2^k + C_2 - k $,
)

#pagebreak()

#exercise-hom-diff-eq(
  setup-eq: $ y_(k+1) - 3y_k + 2y_(k-1) = 5^k $,
  char-eq: $lambda^2 - 3lambda + 2 = 0$,
  solution: [
    Корни: $lambda_1 = 2, lambda_2 = 1$

    $
      "Общее решение однородного уравнения"
      y_k^o = C_1 2^k + C_2 1^k = C_1 2^k + C_2
    $

    Правая часть имеет вид $f_k = 5^k = mu^k$.
    Поскольку $mu = 5$ -- не корень характеристического уравнения,
    $y_k^* = 5^k A$.

    Подставим в исходное уравнение:
    $
      A * 5^(k+1) - 3A * 5^k + 2A * 5^(k-1)
      = A * 5^k * 5 - 3A * 5^k + 2A * 5^k / 5 = 5^k,
    $
    $
      5A - 3A + (2A) / 5
      = (25A - 15A + 2A) / 5
      = (12A) / 5 = 1
      quad ==> quad
      A = 5 slash 12.
    $

    $ "Частное решение" y_k^* = (5 slash 12) * 5^k. $
  ],
  answer: $ y_k = C_1 2^k + C_2 + (5 / 12) * 5^k $,
)
#exercise-hom-diff-eq(
  setup-eq: $ y_(k+1) - sqrt(2) y_k + y_(k-1) = sin(pi k / 2) $,
  char-eq: $lambda^2 - sqrt(2)lambda + 1 = 0$,
  solution: [
    Корни $lambda_(1,2) = (sqrt(2) +- sqrt(2-4)) / 2
    = (sqrt(2) +- sqrt(-2)) / 2
    = (sqrt(2) +- i sqrt(2)) / 2
    quad ==>
    quad lambda_1 = (sqrt(2) + i sqrt(2)) / 2
    = e^(i pi / 4),
    quad lambda_2 = (sqrt(2) - i sqrt(2)) / 2
    = e^(-i pi / 4).$

    #show math.frac: it => $it.num slash it.denom$

    $
      "Общее решение однородного уравнения"
      y_k^o = C_1 cos(pi k / 4) + C_2 sin(pi k / 4)
    $

    Правая часть $f_k = sin(pi k / 2)$.
    Частное решение ищем в виде $y_k^* = A cos(pi k / 2) + B sin(pi k / 2)$.

    Подставим в исходное уравнение:
    $
      A cos((k+1) pi / 2) + B sin((k+1) pi / 2)
      - sqrt(2)(A cos(pi k / 2) + B sin(pi k / 2))
      + A cos((k-1) pi / 2) + B sin((k-1) pi / 2).
    $

    Подставим известные тригонометрические выражения:
    $
      cos((k+1) pi / 2) = -sin(pi k / 2),
      quad sin((k+1) pi / 2) &= cos(pi k / 2),
      \ cos((k-1) pi / 2) = sin(pi k / 2),
      quad sin((k-1) pi / 2) &= -cos(pi k / 2),
    $
    $
      -A sin(pi k / 2) + B cos(pi k / 2)
      - sqrt(2)(A cos(pi k / 2)+ B sin(pi k / 2))
      + A sin(pi k / 2) - B cos(pi k / 2)
      = \ = -sqrt(2)A cos(pi k / 2) - sqrt(2)B sin(pi k / 2)
      = sin(pi k / 2).
    $

    $
      "Частное решение" y_k^* = -sqrt(2) / 2 sin(pi k / 2)
      quad <== quad
      cases(
        -sqrt(2)A = 0 &==> A = 0,
        -sqrt(2)B = 1 &==> B = -1 / sqrt(2) = -sqrt(2) / 2,
      )
    $
  ],
  answer: $
    y_k = C_1 cos(pi k / 4) + C_2 sin(pi k / 4) - sqrt(2) / 2 sin(pi k / 2)
  $,
)
