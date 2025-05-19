#import "@preview/cetz:0.3.4"
#import "@preview/cetz-plot:0.1.1": plot, chart
#import "@preview/numty:0.0.5" as nt

#let SURNAME_NAME = "Никитин Илья"
#let UNN_GROUP = "3822Б1МА1"

#let double-line = block(width: 100%)[
  #block(spacing: 0pt, line(length: 100%))
  #v(2.5pt)
  #block(spacing: 0pt, line(length: 100%))
]

#set page(
  height: auto,
  width: auto,
  margin: (top: 3em, rest: 0.5cm),
  header: [
    ЛР.01.
    #h(1fr)
    #SURNAME_NAME,
    #h(1pt)
    #UNN_GROUP
  ],
)
#set par(justify: true)
#show par: it => align(center, it)
#set table(stroke: 0.3pt)
#show heading: it => align(center, it)
#show heading.where(level: 2): it => align(
  center,
  grid(
    columns: (10em, auto, 10em),
    align: horizon + center,
    column-gutter: 5pt,
    double-line, it.body, double-line,
  ),
)
#show table.cell.where(x: 0): strong
#show table.cell.where(y: 0): strong


//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

#let ITER_LIMIT = 1234

#let round(x) = calc.round(x, digits: 13)

#let det(A) = {
  let dim = A.len()
  if dim == 0 { return 0 }
  if dim == 1 { return A.at(0).at(0) }
  let res = 0
  for i in range(dim) {
    let minor = range(dim).filter(j => j != i).map(j => 
      range(dim).filter(k => k != 0).map(k => A.at(j).at(k))
    )
    res += calc.pow(-1, i) * A.at(0).at(i) * det(minor)
  }
  return res
}


#let l2-norm(x) = {
  if x.len() == 0 { return 0 }
  if type(x.at(0)) == array {
    // Матрица
    let ATA = nt.matmul(nt.transpose(x), x)
    let dim = ATA.len()
    let v = range(dim).map(_ => 1.0)
    let lambda = 0.0
    let prev_lambda = float.inf
    let max_iters = 100
    let iter = 0
    while calc.abs(lambda - prev_lambda) > 1e-10 and iter < max_iters {
      prev_lambda = lambda
      v = nt.matmul(ATA, nt.c(..v)).flatten()
      lambda = calc.sqrt(nt.dot(v, v))
      if lambda == 0 {
        return 0
      }
      v = v.map(x => x / lambda)
      iter += 1
    }
    return calc.sqrt(lambda)
  }
  // Вектор
  calc.sqrt(x.map(x => x * x).sum())
}

// $L^∞$ норма матрицы или вектора
#let linf-norm(x) = {
  if x.len() == 0 { return 0 }
  if type(x.at(0)) == array {
    // Матрица
    return calc.max(..x.map(row => row.map(calc.abs).sum()))
  }
  // Вектор
  calc.max(..x.map(calc.abs))
}

#let mynorm = linf-norm

// Метод Якоби
#let jacobi(alpha, beta, eps, x0, norm: mynorm, max-iters: ITER_LIMIT) = {
  let dim = alpha.len()
  let alpha_norm = norm(alpha)
  let eps1 = if alpha_norm == 0 { eps } else { (1 - alpha_norm) / alpha_norm * eps }
  let history = (x0,)
  while history.len() <= max-iters {
    let x_prev = history.at(-1)
    let x = range(dim).map(i => (
      beta.at(i) + nt.dot(alpha.at(i), x_prev)
    ))
    if norm(nt.sub(x, x_prev)) < eps1 {
      break
    }
    history.push(x)
  }
  history
}

// Метод Зейделя
#let seidel(alpha, beta, eps, x0, norm: mynorm, max-iters: ITER_LIMIT) = {
  let dim = alpha.len()
  let alpha_norm = norm(alpha)
  let eps1 = if alpha_norm == 0 { eps } else { (1 - alpha_norm) / alpha_norm * eps }
  let history = (x0,)
  while history.len() <= max-iters {
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
    if norm(nt.sub(x, x_prev)) < eps1 {
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


//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

== Задание 1 + 3

Написать программу, реализующую метод Якоби решения СЛАУ
$x = beta + alpha x$ в приращениях.
\
Найти решение СЛАУ с заданной точностью
$epsilon thick (epsilon = 10^(-3), 10^(-4), 10^(-5))$.
\
Для каждого значения точности вывести количество итераций.
\
Критерий окончания итерационного процесса:
$norm(x^(i+1) - x^i) < epsilon_1,
  quad epsilon_1
  = display((1 - norm(alpha)) / norm(alpha) epsilon).$

#let f1 = (1, 2, 3)
#let dim = f1.len()
#let A1 = range(dim).map(
  //
  row => range(dim).map(col => if row == col { 10 } else { 1 }),
)
#let x01 = (0, 0, 0)

// #let f1 = (0.5, -3)
// #let dim = f1.len()
// #let A1 = (
//   (3, 1.5),
//   (1, 3),
// )
// #let x01 = (0, 0)

#let EPS = (1e-3, 1e-4, 1e-5)

// Приведение системы к виду $x = beta + alpha x$
#let (alpha1, beta1) = prepare-system(A1, f1)

$
  A = #nt.print(A1),
quad f = #nt.print(f1),
quad alpha = #nt.print(alpha1),
quad beta = #nt.print(beta1).
$

#let tabulate(epsilons, history) = {
  let height = calc.max(..history.map(h => h.len()))
  align(
    center,
    table(
      columns: (auto, auto, auto, auto),
      inset: 1em,
      align: (center + horizon),
      $№$,
      ..epsilons.map(eps => $epsilon = eps$),
      ..range(height)
        .map(ht => (
          ($#(ht + 1)$,)
            + history.map(h => align(center + horizon)[
              #if h.len() <= ht {
                none
              } else {
                table.cell(colspan: 3, nt.print(h.at(ht).map(round)))
              }])
        ))
        .filter(x => x != none)
        .flatten()
    ),
  )
}

#grid(
  columns: 2,
  gutter: 2em,
  [
    === Метод Якоби
    #tabulate(
      EPS,
      EPS.map(eps => jacobi(alpha1, beta1, eps, x01)),
    )
  ],
  [
    === Метод Зейделя
    #tabulate(
      EPS,
      EPS.map(eps => seidel(alpha1, beta1, eps, x01)),
    )
  ],
)

#let xe = seidel(alpha1, beta1, 10e-100, x01).at(-1)

//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

#pagebreak(weak: true)

#let estimate-f = $
  norm(x^k - x)
  <= norm(alpha)^k / (1 - norm(alpha)) norm(beta)
$

== Задание 2 + 3

Корректировать элементы матрицы А, постепенно уходя от
диагонального преобладания.
После каждой корректировки пересчитывать правую часть СЛАУ.
Добиться, чтобы количество итераций было около 1000.
В итоге будет получена СЛАУ $A^* x = f^*$.
\
Для исходной СЛАУ и каждого варианта корректировки вычислить и
сравнить абсолютную погрешность и оценку погрешности
$Delta = display(#estimate-f).$
Сравнить нормы матриц $A$ и $A^*$.
$x = #nt.print(xe)$

#let alpha-mat = $
  mat(..#range(dim).map(
    row => range(dim).map(col => if row == col {
      $0$
    } else {
      $c$
    })
  ))
$

#let error-bound(a, b, k, n: mynorm) = (
  calc.pow(n(a), k - 1) / (1 - n(a)) * n(b)
)

#let A2 = A1
#let f2 = f1
#let (alpha2, beta2) = prepare-system(A2, f2)
#let alpha2-norm = mynorm(alpha2)
#let beta2-norm = mynorm(beta2)

#let rows = ()
#let iterations = 0
#let mod-num = 0
#let corr = 0.07
#while iterations < 1000 {
  let k = alpha2.at(0).at(1)
  let jacobi-history = jacobi(alpha2, beta2, EPS.at(-1), x01)
  let seidel-history = seidel(alpha2, beta2, EPS.at(-1), x01)
  let j-err-bound = error-bound(
    alpha2,
    beta2,
    jacobi-history.len(),
  )
  let s-err-bound = error-bound(
    alpha2,
    beta2,
    seidel-history.len(),
  )
  let j-delta = mynorm(nt.sub(xe, jacobi-history.at(-1)))
  let s-delta = mynorm(nt.sub(xe, seidel-history.at(-1)))
  rows.push(
    (
      mod-num,
      A2.flatten().map(round).chunks(dim),
      mynorm(A2),
      f2.map(round),
      if str(k).len() > 10 {
        $display(#alpha-mat), \ c = #k$
      } else {
        alpha2
      },
      alpha2-norm,
      beta2.map(round),
      beta2-norm,
      jacobi-history.len(),
      jacobi-history.at(-1),
      table.cell(fill: if j-delta <= j-err-bound { green } else { red }.transparentize(90%))[
        $&#j-delta <= \ <= &#j-err-bound$
      ],
      seidel-history.len(),
      seidel-history.at(-1),
      table.cell(fill: if s-delta <= s-err-bound { green } else { red }.transparentize(90%))[
        $&#s-delta <= \ <= &#s-err-bound$
      ],
    ).map(x => if type(x) == content {
      x
    } else if type(x) == float {
      $#round(x)$
    } else {
      nt.print(x)
    }),
  )

  // Корректировка матрицы
  A2 = A2
    .enumerate()
    .map(((i, a)) => a //
      .enumerate()
      .map(((j, b)) => if i == j { b - corr } else { b + corr }))

  // Пересчёт правой части
  f2 = nt.matmul(A2, nt.c(..xe)).flatten()

  // Пересчёт системы
  (alpha2, beta2) = prepare-system(A2, f2)

  alpha2-norm = mynorm(alpha2)
  beta2-norm = mynorm(beta2)
  if alpha2-norm == 1 {
    error-bound = (a, b) => float.inf
  }
  iterations = calc.max(seidel-history.len(), jacobi-history.len())
  mod-num += 1
}

#table(
  columns: (auto,) * 14,
  align: center + horizon,
  $m$,
  $А^*_m$,
  $norm(A^*_m)$,
  $f^*_m$,
  $alpha^*_m$,
  $norm(alpha^*_m)$,
  $beta^*_m$,
  $norm(beta^*_m)$,
  [$k$, \ Якоби],
  [$x^k$, Якоби],
  estimate-f,
  [$k$, \ Зейделя],
  [$x^k$, Зейделя],
  estimate-f,
  ..rows.flatten()
)

//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

#pagebreak(weak: true)
#set page(width: 50em, height: auto)

== Задание 3

Модифицировать программную реализацию итерационного процесса
метода Якоби, чтобы получилась программная реализация итерационного
процесса метода Зейделя решения СЛАУ в приращениях. Сколько
итераций требуется для решения с заданной точностью ε
СЛАУ $A x = f$ и СЛАУ $A^* x = f^*$ методом Зейделя?

*Ответ* приведён в таблицах.
