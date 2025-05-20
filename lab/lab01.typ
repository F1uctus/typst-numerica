#import "@preview/numty:0.0.5" as nt

#let SURNAME_NAME = "Никитин Илья"
#let UNN_GROUP = "3822Б1МА1"

// В Typst возможно изменять условия задач,
// и сразу же видеть пересчитанные результаты
// на странице документа.
//
// Далее даны примеры условий задач.
//
// Чтобы пересчитать результаты, нужно убрать
// знаки комментария (//) у интересующего примера,
// и закомментировать остальные примеры.


// Пример 1.
// #let f1 = (0.5, -3)
// #let dim = f1.len()
// #let A1 = (
//   (3, 1.5),
//   (1, 3),
// )
// #let x01 = (0, 0)


// Пример 2.
#let f1 = (1, 2, 3)
#let dim = f1.len()
#let A1 = range(dim).map(
  // Диагональное преобладание
  row => range(dim).map(col => if row == col { 10 } else { 1 }),
)
#let x01 = (0, 0, 0)

// Моя реализация методов Якоби и Зейделя дана ниже.

/// Рассматриваемые в задачах точности.
#let EPS = (1e-3, 1e-4, 1e-5)

/// Общее ограничение на количество итераций.
#let ITER_LIMIT = 1234

/// Упрощённая функция округления, используется
/// только для вывода результатов.
#let round(x) = calc.round(x, digits: 13)


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

/// $L^∞$ норма матрицы или вектора.
#let linf-norm(x) = {
  if x.len() == 0 { return 0 }
  if type(x.at(0)) == array {
    // Матрица
    return calc.max(..x.map(row => row.map(calc.abs).sum()))
  }
  // Вектор
  calc.max(..x.map(calc.abs))
}

/// Норма, используемая во всех задачах.
#let mynorm = linf-norm

/// Метод Якоби.
/// - alpha (array): Матрица $alpha$.
/// - beta (array): Вектор $beta$.
/// - eps (float): Точность.
/// - x0 (array): Начальное приближение.
/// - norm (function): Норма.
/// - max-iters (int): Ограничение на количество итераций.
#let jacobi(alpha, beta, eps, x0, norm: mynorm, max-iters: ITER_LIMIT) = {
  // Размерность задачи
  let dim = alpha.len()

  // Норма матрицы
  let alpha_norm = norm(alpha)

  // ε₁ = (1 - ‖α‖) / ‖α‖ * ε
  let eps1 = if alpha_norm == 0 { eps } else { (1 - alpha_norm) / alpha_norm * eps }

  // Список предыдущих приближений
  let history = (x0,)
  while history.len() <= max-iters {
    let x_prev = history.at(-1)

    // Шаг итерационного процесса
    let x = range(dim).map(i => (
      beta.at(i) + nt.dot(alpha.at(i), x_prev)
    ))

    // Критерий окончания итерационного процесса
    // ‖x^(i+1) - x^i‖ < ε₁
    if norm(nt.sub(x, x_prev)) < eps1 {
      break
    }

    history.push(x)
  }
  history
}

/// Метод Зейделя.
/// - alpha (array): Матрица $alpha$.
/// - beta (array): Вектор $beta$.
/// - eps (float): Точность.
/// - x0 (array): Начальное приближение.
/// - norm (function): Норма.
/// - max-iters (int): Ограничение на количество итераций.
#let seidel(alpha, beta, eps, x0, norm: mynorm, max-iters: ITER_LIMIT) = {
  // Размерность задачи
  let dim = alpha.len()

  // Норма матрицы
  let alpha_norm = norm(alpha)

  // ε₁ = (1 - ‖α‖) / ‖α‖ * ε
  let eps1 = if alpha_norm == 0 { eps } else { (1 - alpha_norm) / alpha_norm * eps }

  // Список предыдущих приближений
  let history = (x0,)
  while history.len() <= max-iters {
    let x_prev = history.at(-1)

    // Шаг итерационного процесса
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

    // Критерий окончания итерационного процесса
    // ‖x^(i+1) - x^i‖ < ε₁
    if norm(nt.sub(x, x_prev)) < eps1 {
      break
    }

    history.push(x)
  }
  history
}

/// Преобразование матрицы $A$ и вектора $f$ к виду, удобному для итераций:
/// $ x^(k+1) = beta + alpha x^k $.
/// - A (array): Матрица $A$.
/// - f (array): Вектор $f$.
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


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

// Общие установки форматирования документа.
#set page(
  height: auto,
  width: auto,
  margin: (top: 3em, rest: 0.5cm),
  header: [ЛР.01. #h(1fr) #SURNAME_NAME, #h(1pt) #UNN_GROUP],
)
#let double-line = [
  #block(spacing: 0pt, line(length: 100%))
  #v(2.5pt)
  #block(spacing: 0pt, line(length: 100%))
]
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
#set par(justify: true)
#show par: it => align(center, it)
#set table(stroke: 0.3pt)
#show table.cell.where(x: 0): strong
#show table.cell.where(y: 0): strong
#let cell-highlight(x, it) = table.cell(
  fill: if x { green } else { red }.transparentize(90%),
  it,
)


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

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

// Точное решение
#let xe = seidel(alpha1, beta1, 10e-28, x01).at(-1)


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

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

// Условия задачи
#let A2 = A1
#let f2 = f1
#let (alpha2, beta2) = prepare-system(A2, f2)
#let alpha2-norm = mynorm(alpha2)
#let beta2-norm = mynorm(beta2)

/// Строки таблицы
#let rows = ()

/// Количество итераций
#let iterations = 0

/// Номер модификации
#let mod-num = 0

/// Коэффициент шаговой корректировки
#let corr = 0.07

/// История итераций для метода Якоби
#let j-history = ()

/// История итераций для метода Зейделя
#let s-history = ()

#while iterations < 1010 {
  j-history = jacobi(alpha2, beta2, EPS.at(-1), x01)
  let j-err-bound = error-bound(alpha2, beta2, j-history.len())
  let j-delta = mynorm(nt.sub(xe, j-history.at(-1)))

  s-history = seidel(alpha2, beta2, EPS.at(-1), x01)
  let s-err-bound = error-bound(alpha2, beta2, s-history.len())
  let s-delta = mynorm(nt.sub(xe, s-history.at(-1)))

  let k = alpha2.at(0).at(1)
  rows.push((
    num: mod-num,
    A: nt.print(A2.flatten().map(round).chunks(dim)),
    A-norm: mynorm(A2),
    f: nt.print(f2.map(round)),
    alpha: if str(k).len() > 10 {
      // Если элементы матрицы имеют большое количество знаков,
      // то выводим матрицу в общем виде
      $display(#alpha-mat), \ c = #k$
    } else {
      // Иначе выводим матрицу полностью
      nt.print(alpha2)
    },
    alpha-norm: alpha2-norm,
    beta: nt.print(beta2.map(round)),
    beta-norm: beta2-norm,
    jacobi-iters: if j-history.len() == ITER_LIMIT + 1 { $> #j-history.len()$ } else { j-history.len() },
    jacobi-x: nt.print(j-history.at(-1).map(round)),
    jacobi-check: cell-highlight(j-delta <= j-err-bound, $&#j-delta <= \ <= &#j-err-bound$),
    seidel-iters: if s-history.len() == ITER_LIMIT + 1 { $> #s-history.len()$ } else { s-history.len() },
    seidel-x: nt.print(s-history.at(-1).map(round)),
    seidel-check: cell-highlight(s-delta <= s-err-bound, $&#s-delta <= \ <= &#s-err-bound$),
  ))

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

  // Пересчёт норм
  alpha2-norm = mynorm(alpha2)
  beta2-norm = mynorm(beta2)
  if alpha2-norm == 1 {
    error-bound = (a, b) => float.inf
  }

  iterations = calc.max(s-history.len(), j-history.len())
  mod-num += 1
}

#table(
  columns: (auto,) * rows.at(0).len(),
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
  ..rows
    .map(r => r.values())
    .flatten()
    .map((
      x => if type(x) == content {
        x
      } else if type(x) == float {
        $#round(x)$
      } else {
        nt.print(x)
      }
    ))
)

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

#pagebreak(weak: true)
#set page(width: 50em, height: auto)

== Задание 3

Модифицировать программную реализацию итерационного процесса
метода Якоби, чтобы получилась программная реализация итерационного
процесса метода Зейделя решения СЛАУ в приращениях. Сколько
итераций требуется для решения с заданной точностью ε
СЛАУ $A x = f$ и СЛАУ $A^* x = f^*$ методом Зейделя?

*Ответ* приведён в таблицах. В наихудших рассматриваемых случаях
для метода Зейделя требуется кратно меньше итераций,
чем для метода Якоби. Если сравнивать количества итераций
в сумме для модификаций, то получим:
$
  (sum_k N^j_k) slash (sum_k N^s_k)
  = #(rows.slice(0, -1).map(r => r.jacobi-iters).sum() / rows.slice(0, -1).map(r => r.seidel-iters).sum())
$

