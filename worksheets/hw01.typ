#import "../src/lib.typ": *

#let SURNAME_NAME = "Никитин Илья"
#let UNN_GROUP = "3822Б1МА1"
#let n = 21
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

#show heading: it => box(inset: (bottom: 1mm))[
  #grid(
    columns: (1fr, auto, 1fr),
    align: horizon + center,
    column-gutter: 5pt,
    line(length: 100%), it.body, line(length: 100%),
  )
]

#let task(A, f, x0, detailed: false) = {
  let (alpha: al, beta: be) = fixed-point-form(A, f)

  $A = #render(mat-of(..A)), quad f = #render(vec-of(..f)), quad x^"(0)" = #render(vec-of(..x0)).$

  $
    #show-fixed-point-system(al, be), thick
    alpha = #render(al), thick
    beta = #render(be).
  $

  let criterion = convergence-criterion(al)
  [Критерий сходимости МПИ #if criterion.converges [*выполняется*] else [*не выполняется*]:]
  box(
    height: 4em,
    align(horizon + center, criterion.content),
  )

  let lines = system-lines(A.map(r => r.map(float)), f.map(float))

  [Метод Якоби:]
  $quad bold(x)^"(k+1)" = alpha bold(x)^"(k)" + beta,$

  let jacobi = iteration-history(al, be, x0, iterations: ITERATIONS)
  if detailed [
    Первая итерация полностью:
    #show-reduction(
      add(mul(al, sym("x")), be),
      ctx: (x: vec-of(..x0)),
      lang: "ru",
      compact: true,
      digits: PREC,
    )
  ]
  show-iteration-table(jacobi, digits: PREC)
  show-iteration-plot(jacobi, lines)

  [Метод Гаусса-Зейделя:]
  $quad bold(x)^"(k+1)" = alpha vec(x_1^"(k+1)", x_2^"(k)") + beta,$

  let seidel = iteration-history(al, be, x0, iterations: ITERATIONS, method: "seidel")
  show-iteration-table(seidel, digits: PREC)
  show-iteration-plot(seidel, lines)
}

//////////////////////////////////////////////////
=== Задание 1
#task(
  ((1, decimal("1.5")), (1, -2)),
  (decimal("0.5"), -3),
  (n, n + 3),
  detailed: false,
)

//////////////////////////////////////////////////
#colbreak()
=== Задание 2
#task(
  ((3, 2), (3, -2)),
  (-1, -5),
  (n, n + 4),
)

//////////////////////////////////////////////////
#pagebreak()
=== Задание 1 (обращённый порядок уравнений)
#task(
  ((1, -2), (1, decimal("1.5"))),
  (-3, decimal("0.5")),
  (n, n + 3),
)

//////////////////////////////////////////////////
#colbreak()
=== Задание 2 (обращённый порядок уравнений)
#task(
  ((3, -2), (3, 2)),
  (-5, -1),
  (n, n + 4),
)
