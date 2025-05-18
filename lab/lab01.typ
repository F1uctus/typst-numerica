#import "@preview/cetz:0.3.4"
#import "@preview/cetz-plot:0.1.1": plot, chart
#import "@preview/diverential:0.2.0": dvpc
#import "@preview/physica:0.9.5": dv, pdv, evaluated
#import "@preview/numty:0.0.5" as nt
#import "@preview/zero:0.3.3": num

#let SURNAME_NAME = "Никитин Илья"
#let UNN_GROUP = "3822Б1МА1"
#let n = 21
#let PLOT_SCALE = 6.5
#let ITERATIONS = 5
#let PREC = 3

#let double-line = block(width: 100%)[
  #block(spacing: 0pt, line(length: 100%))
  #v(2.5pt)
  #block(spacing: 0pt, line(length: 100%))
]

#set page(
  height: auto,
  margin: (top: 3em, rest: 0.5cm),
  header: [
    ЛР.01.
    #h(1fr)
    $n = #n$,
    #h(1pt)
    #SURNAME_NAME,
    #h(1pt)
    #UNN_GROUP
  ],
)
#set par(justify: true)
#show heading.where(level: 2): it => grid(
  columns: (1fr, auto, 1fr),
  align: horizon + center,
  column-gutter: 5pt,
  double-line, it.body, double-line,
)
#show table.cell.where(x: 0): strong

//////////////////////////////////////////////////

// Норма матрицы или вектора
#let mathnorm(mat) = {
  if mat.len() == 0 {
    return 0
  }
  let max = 0.0
  if type(mat.at(0)) == array {
    // Матрица
    for row in mat {
      let sum = 0
      for val in row {
        sum += calc.abs(val)
      }
      max = calc.max(max, sum)
    }
    return max
  }
  // Вектор
  for v in mat {
    if not v.is-nan() {
      max = calc.max(max, calc.abs(v))
    }
  }
  max
}

// Метод Якоби
#let jacobi(alpha, beta, eps, x0, max-iterations: 5) = {
  let dim = alpha.len()
  let alpha_norm = mathnorm(alpha)
  let eps1 = (1 - alpha_norm) / alpha_norm * eps
  let history = (x0,)
  while history.len() <= max-iterations {
    let x_prev = history.at(-1)
    let x = range(dim).map(i => (
      beta.at(i) + nt.dot(alpha.at(i), x_prev)
    ))
    if mathnorm(nt.sub(x, x_prev)) < eps1 {
      break
    }
    history.push(x)
  }
  history
}

// Метод Зейделя
#let seidel(alpha, beta, eps, x0, max-iterations: 5) = {
  let dim = alpha.len()
  let alpha_norm = mathnorm(alpha)
  let eps1 = (1 - alpha_norm) / alpha_norm * eps
  let history = (x0,)
  while history.len() <= max-iterations {
    let x_prev = history.at(-1)
    let x = ()
    for i in range(dim) {
      let delta = beta.at(i)
      for j in range(dim) {
        if j < i {
          delta += alpha.at(i).at(j) * x.at(j)
        } else if j >= i {
          delta += alpha.at(i).at(j) * x_prev.at(j)
        }
      }
      x.push(delta)
    }
    if mathnorm(nt.sub(x, x_prev)) < eps1 {
      break
    }
    history.push(x)
  }
  history
}

// Преобразование матрицы $A$ и вектора $f$
// в систему вида $x = beta + alpha x$
#let prepare-system(A, f) = {
  let dim = A.len()
  let alpha = ((),) * dim
  let beta = ()
  for i in range(dim) {
    let aii = A.at(i).at(i)
    beta.push(f.at(i) / aii)
    for j in range(dim) {
      if i == j {
        alpha.at(i).push(0)
      } else {
        alpha.at(i).push(-A.at(i).at(j) / aii)
      }
    }
  }
  (alpha, beta)
}

//////////////////////////////////////////////////

== Задание 1

Написать программу, реализующую метод Якоби решения СЛАУ $x = beta + alpha x$
в приращениях. Найти решение СЛАУ с заданной точностью
$epsilon thick (epsilon = 10^(-3), 10^(-4), 10^(-5))$.
Для каждого значения точности вывести количество итераций.
Критерий окончания итерационного процесса:
$norm(x^(i+1) - x^i) < epsilon_1,
  quad epsilon_1
  = display((1 - norm(alpha)) / norm(alpha) epsilon).$

#let A1 = range(5).map(row => range(5).map(col => if row == col { 10 } else { 1 }))
#let f1 = (1, 2, 3, 4, 5)
#let x01 = (0, 0, 0, 0, 0)

// #let A1 = (
//   (1, 1.5),
//   (1, -2),
// )
// #let f1 = (0.5, -3)
// #let x01 = (0, 0)

#let EPS = (1e-3, 1e-4, 1e-5)
#let MAX_ITER = 5000

// Решение системы
#let (alpha1, beta1) = prepare-system(A1, f1)

$
  A = #nt.print(A1),
quad f = #nt.print(f1),
quad alpha = #nt.print(alpha1),
quad beta = #nt.print(beta1).
$

#let tabulate(epsilons, history) = {
  let height = calc.max(..history.map(h => h.len()))
  table(
    columns: (auto, 1fr, 1fr, 1fr),
    inset: 1em,
    stroke: 1pt,
    align: (center + horizon),
    $№$,
    ..epsilons.map(eps => $epsilon = eps$),
    ..range(height)
      .map(ht => (
        ($#(ht + 1)$,)
          + history.map(h => align(center + horizon)[
            #if h.len() <= ht {
              []
            } else {
              nt.print(h.at(ht).map(x => calc.round(x, digits: 14)))
            }])
      ))
      .flatten()
  )
}

=== Метод Якоби дукоби бууум

#tabulate(
  EPS,
  EPS.map(eps => jacobi(
    alpha1,
    beta1,
    eps,
    x01,
    max-iterations: MAX_ITER,
  )),
)

=== Метод Зейделя

#tabulate(
  EPS,
  EPS.map(eps => seidel(
    alpha1,
    beta1,
    eps,
    x01,
    max-iterations: MAX_ITER,
  )),
)

== Задание 2

Корректировать элементы матрицы А, постепенно уходя от
диагонального преобладания. После каждой корректировки пересчитывать
правую часть СЛАУ. Добиться, чтобы количество итераций было около 1000.
В итоге будет получена СЛАУ $A^* x = f^*$.
Для исходной СЛАУ и каждого варианта корректировки вычислить и
сравнить абсолютную погрешность и оценку погрешности
$Delta = norm(x^k - x)
  <= display(norm(alpha)^(k+1) / (1 - norm(alpha)) norm(b)).$
Сравнить нормы матриц $A$ и $A^*$.

#let A2-mod = A1
#let f2-mod = f1
#let (alpha2-mod, beta2-mod) = prepare-system(A2-mod, f2-mod)
#let results = (
  (
    $A$,
    nt.print(A2-mod),
    nt.print(f2-mod),
    nt.print(mathnorm(A2-mod)),
    nt.print(alpha2-mod),
    nt.print(beta2-mod),
    $#jacobi(alpha1, beta1, EPS.at(0), x01, max-iterations: MAX_ITER).len()$,
    $#seidel(alpha1, beta1, EPS.at(0), x01, max-iterations: MAX_ITER).len()$,
  ),
)

#let target-iters = 1000
#let iterations = 0
#let mod-num = 0
#while iterations < target-iters {
  A2-mod = A2-mod
    .enumerate()
    .map(aa => aa
      .at(1)
      .enumerate()
      .map(bb => calc.round(if aa.at(0) == bb.at(0) { bb.at(1) - 0.1 } else { bb.at(1) + 0.1 }, digits: 14)))
  f2-mod = nt.matmul(A2-mod, nt.c(..f1)).flatten()

  (alpha2-mod, beta2-mod) = prepare-system(A2-mod, f2-mod)

  let jacobi_result = jacobi(
    alpha2-mod,
    beta2-mod,
    EPS.at(0),
    x01,
    max-iterations: MAX_ITER,
  )

  let seidel_result = seidel(
    alpha2-mod,
    beta2-mod,
    EPS.at(0),
    x01,
    max-iterations: MAX_ITER,
  )

  iterations = jacobi_result.len()

  mod-num += 1
  results.push((
    $A^*_#mod-num$,
    $inline(#nt.print(A2-mod))$,
    $inline(#nt.print(f2-mod.map(x => calc.round(x, digits: 10))))$,
    $inline(#nt.print(calc.round(mathnorm(A2-mod), digits: 14)))$,
    $inline(#nt.print(alpha2-mod.flatten().map(x => calc.round(x, digits: 10)).chunks(5)))$,
    $inline(#nt.print(beta2-mod))$,
    $#jacobi(alpha2-mod, beta2-mod, EPS.at(0), x01, max-iterations: MAX_ITER).len()$,
    $#seidel(alpha2-mod, beta2-mod, EPS.at(0), x01, max-iterations: MAX_ITER).len()$,
  ))
}

#table(
  columns: (auto, auto, auto, auto, auto, auto, auto, auto),
  align: center + horizon,
  [*\#*], $А^*_n$, $f^*_n$, $norm(A^*_n)$, $alpha^*_n$, $beta^*_n$, [*Итераций \ Якоби*], [*Итераций \ Зейделя*],
  ..results.flatten()
)

// Модифицировать программную реализацию итерационного процесса
// метода Якоби, чтобы получилась программная реализация итерационного
// процесса метода Зейделя решения СЛАУ в приращениях. Сколько
// итераций требуется для решения с заданной точностью ε
// СЛАУ A x = f и СЛАУ A^* x = f^* методом Зейделя?
