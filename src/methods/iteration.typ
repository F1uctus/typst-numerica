// Iterative solvers for linear systems in fixed-point form
//   x^(k+1) = α x^(k) + β
// (Jacobi) and the Gauss–Seidel variant that reuses already-updated
// components. Every function returns data and/or display-ready content,
// so a worksheet is just: problem data → these calls.

#import "@preview/cetz:0.5.2"
#import "@preview/cetz-plot:0.1.4": plot

#import "../numbers.typ": is-mpq, mpq, mpz, round-num, to-exact, to-float-num
#import "../ast.typ": add, div, mul, num, pow, sub, sym, to-expr
#import "../ops.typ": operations
#import "../eval.typ": evaluate
#import "../linalg.typ": is-matrix, mat-of, vec-of
#import "../render.typ": render, render-num
#import "../reduce.typ": show-reduction
#import "../diff.typ": simplify
#import "../theme.typ": theme, themed-axes-grid, themed-plot-base

// --- input normalization ---------------------------------------------------

/// Accept a matrix node, an array of rows, or a flat array (column vector)
/// and return a matrix expression node.
#let as-matrix-node(v) = {
  if is-matrix(v) { return v }
  assert(type(v) == array, message: "expected a matrix, an array of rows, or a flat array")
  if v.all(r => type(r) == array) { mat-of(..v) } else { vec-of(..v) }
}

// --- iteration histories -----------------------------------------------------

/// Run `iterations` steps of the fixed-point iteration and return the
/// history ((x1, x2, ...), ...) as flat arrays of numbers, x^(0) first.
///
/// - method: "jacobi" uses only the previous iterate;
///   "seidel" (Gauss–Seidel) reuses components already updated this step.
#let iteration-history(
  alpha,
  beta,
  x0,
  iterations: 5,
  method: "jacobi",
  mode: "exact",
  ops: operations,
) = {
  assert(method in ("jacobi", "seidel"), message: "method must be \"jacobi\" or \"seidel\"")
  let alpha = as-matrix-node(alpha)
  let beta = as-matrix-node(beta)
  let x0 = as-matrix-node(x0)
  let n = alpha.rows.len()
  let ev(e, ctx) = evaluate(e, ctx: ctx, mode: mode, ops: ops)
  // current iterate as a flat array of numbers
  let cur = x0.rows.map(r => ev(r.first(), (:)))
  let history = (cur,)
  let step-expr = add(mul(sym("alpha"), sym("x")), sym("beta"))
  for _ in range(iterations) {
    if method == "jacobi" {
      let x-node = vec-of(..cur.map(num))
      let next = ev(step-expr, (alpha: alpha, x: x-node, beta: beta))
      cur = next.mrows.map(r => r.first())
    } else {
      let next = cur
      for i in range(n) {
        // x_i' = Σ_j α_ij · (already-updated x_j for j < i) + β_i
        let terms = range(n).map(j => mul(alpha.rows.at(i).at(j), num(next.at(j))))
        let row-expr = add(..terms, beta.rows.at(i).first())
        next.at(i) = ev(row-expr, (:))
      }
      cur = next
    }
    history.push(cur)
  }
  history
}

// --- fixed-point form ---------------------------------------------------------

/// Derive the fixed-point form x = αx + β from the system A·x = f by
/// solving row i for x_i: α_ij = −A_ij/A_ii (j ≠ i), β_i = f_i/A_ii.
/// Returns (alpha: matrix node, beta: vector node) with exact entries.
#let fixed-point-form(A, f, mode: "exact", ops: operations) = {
  let A = as-matrix-node(A)
  let f = as-matrix-node(f)
  let n = A.rows.len()
  let ev(e) = num(evaluate(e, mode: mode, ops: ops))
  let alpha = range(n).map(i => range(n).map(j => {
    if i == j { num(0) } else { ev(sub(num(0), div(A.rows.at(i).at(j), A.rows.at(i).at(i)))) }
  }))
  let beta = range(n).map(i => (ev(div(f.rows.at(i).first(), A.rows.at(i).at(i))),))
  (alpha: (kind: "matrix", rows: alpha), beta: (kind: "matrix", rows: beta))
}

/// Typeset the fixed-point system as cases: x_i = Σ α_ij x_j + β_i.
#let show-fixed-point-system(alpha, beta, var-name: "x") = {
  let n = alpha.rows.len()
  let x(j) = sym(var-name + "_" + str(j + 1))
  let rows = range(n).map(i => {
    let rhs = simplify(add(..range(n).map(j => mul(alpha.rows.at(i).at(j), x(j))), beta.rows.at(i).first()))
    $#render(x(i)) = #render(rhs)$
  })
  math.cases(..rows)
}

// --- convergence criterion (2×2) ---------------------------------------------

/// Extract an exact small integer from an mpq, or none.
#let mpq-small-int(v) = {
  if mpz.to-str(mpq.den(v)) != "1" { return none }
  let s = mpz.to-str(mpq.num(v, signed: true)).replace("\u{2212}", "-")
  if s.len() < 18 { int(s) } else { none }
}

/// √ of an exact non-negative rational, rendered nicely:
/// perfect squares collapse, √(a/b²) becomes √a/b.
/// Returns (body: content, value: float).
#let pretty-sqrt(v) = {
  let value = calc.sqrt(to-float-num(v))
  let q = to-exact(v)
  let (n, d) = (mpq-small-int(mpq.from(mpq.num(q))), mpq-small-int(mpq.from(mpq.den(q))))
  let int-sqrt(k) = {
    if k == none { return none }
    let s = calc.floor(calc.sqrt(float(k)) + 0.5)
    if s * s == k { s } else { none }
  }
  let (sn, sd) = (int-sqrt(n), int-sqrt(d))
  let body = if sn != none and sd != none {
    render(num(mpq.div(mpq.from(sn), mpq.from(sd))))
  } else if sd != none and n != none {
    if sd == 1 { $sqrt(#str(n))$.body } else { $sqrt(#str(n)) / #str(sd)$.body }
  } else {
    $sqrt(#render(num(q)))$.body
  }
  (body: body, value: value)
}

/// Convergence criterion for a 2×2 iteration matrix α: the eigenvalues of
/// α must lie inside the unit circle. Returns
///   (converges: bool, moduli: (float, float), content: content)
/// where content typesets the `det(α − λE) = 0` derivation and the
/// eigenvalue moduli, like the classic worked check.
#let convergence-criterion(alpha, mode: "exact", ops: operations, digits: 3) = {
  let alpha = as-matrix-node(alpha)
  assert(
    alpha.rows.len() == 2 and alpha.rows.first().len() == 2,
    message: "the criterion is implemented for 2×2 matrices",
  )
  // hyphenated local names cannot shadow math identifiers (`det`, `tr`)
  // inside the content template below
  let ev(e) = evaluate(e, mode: mode, ops: ops)
  let (a, b) = alpha.rows.first()
  let (c, dd) = alpha.rows.last()
  let tr-v = ev(add(a, dd))
  let det-v = ev(sub(mul(a, dd), mul(b, c)))
  let disc = ev(sub(mul(num(tr-v), num(tr-v)), mul(num(4), num(det-v))))
  let lam = sym("lambda")
  let char-mat = mat-of(
    (simplify(sub(a, lam)), b),
    (c, simplify(sub(dd, lam))),
  )
  // characteristic polynomial λ² − tr·λ + det; zero terms vanish
  let char-poly = simplify(add(sub(pow(lam, 2), mul(num(tr-v), lam)), num(det-v)))
  let complex = if is-mpq(disc) { mpq.cmp(disc, mpq.from(0)) < 0 } else { disc < 0 }
  let result = if complex {
    // λ = tr/2 ± √(−disc/4)·i and |λ|² = det
    let modulus = pretty-sqrt(det-v)
    let imag-sq = ev(div(sub(num(0), num(disc)), 4))
    let imag = if to-float-num(imag-sq) == 1.0 {
      $i$.body
    } else {
      $#pretty-sqrt(imag-sq).body i$.body
    }
    let lambda-body = if to-float-num(tr-v) == 0.0 {
      $plus.minus #imag$.body
    } else {
      $#render(num(tr-v), digits: digits) / 2 plus.minus #imag$.body
    }
    (moduli: (modulus.value, modulus.value), lambda-body: lambda-body, moduli-body: modulus.body)
  } else {
    let sq = calc.sqrt(to-float-num(disc))
    let l1 = (to-float-num(tr-v) + sq) / 2
    let l2 = (to-float-num(tr-v) - sq) / 2
    let fmt(v) = str(round-num(v, digits: digits))
    (
      moduli: (calc.abs(l1), calc.abs(l2)),
      lambda-body: $#fmt(l1), #fmt(l2)$.body,
      moduli-body: $#fmt(calc.max(calc.abs(l1), calc.abs(l2)))$.body,
    )
  }
  let worst = calc.max(..result.moduli)
  let rel = if worst < 1 { $<$ } else if worst == 1 { $=$ } else { $>$ }
  let content = $
    det #render(char-mat) = #render(char-poly) = 0 ==>
    abs(lambda_(1,2)) = abs(#result.lambda-body) = #result.moduli-body #rel 1 .
  $
  (converges: worst < 1, moduli: result.moduli, content: content)
}

// --- displays -----------------------------------------------------------------

/// The classic iteration table: one column per step, one row per component.
#let show-iteration-table(history, digits: 3, var-name: "x") = {
  let n = history.first().len()
  let fmt(v) = str(round-num(v, digits: digits))
  show table.cell.where(x: 0): strong
  align(
    center,
    table(
      columns: (1fr,) * (history.len() + 1),
      stroke: theme.stroke-muted + 0.2mm,
      align: horizon + center,
      $k$, ..range(history.len()).map(str).map(math.equation),
      ..range(n)
        .map(i => (
          math.equation(eval(var-name + "_" + str(i + 1), mode: "math")),
          ..history.map(x => fmt(x.at(i))),
        ))
        .flatten(),
    ),
  )
}

/// For a 2×2 system A·x = f, the two lines x₂(x₁) it defines on the plane.
#let system-lines(A, f) = {
  let A = A.map(r => r.map(float))
  let f = f.map(float)
  range(2).map(i => x => (f.at(i) - A.at(i).first() * x) / A.at(i).last())
}

/// Geometric interpretation: the system's lines and the iteration path.
/// `history` is an iteration history of 2-component vectors.
#let show-iteration-plot(history, lines, size: 6.5, tick-size: 8pt) = {
  let points = history.map(x => (to-float-num(x.first()), to-float-num(x.last())))
  let point-id(p) = p.map(v => calc.round(v, digits: 4)).map(str).map(s => s.replace(".", "_")).join()
  let plot-name = "plt" + points.map(((x, y)) => str(int(x)) + str(int(y))).join()
  let min-x = calc.min(..points.map(((x, _)) => x))
  let max-x = calc.max(..points.map(((x, _)) => x))
  let tick-fmt(v) = {
    set text(size: tick-size)
    v
  }
  align(
    center,
    cetz.canvas({
      cetz.draw.set-style(
        axes: themed-axes-grid,
      )
      plot.plot(
        plot-style: themed-plot-base,
        name: plot-name,
        size: (size, size),
        x-label: $x_1$,
        y-label: $x_2$,
        axis-style: "school-book",
        x-format: tick-fmt,
        y-format: tick-fmt,
        {
          for (i, l) in lines.enumerate() {
            plot.add(l, domain: (min-x, max-x))
            plot.add-anchor("l" + str(i + 1), (max-x, l(max-x)))
          }
          plot.add(
            points,
            mark: "o",
            mark-size: 0.1,
            style: (stroke: (paint: theme.plot-stroke, dash: "dotted", thickness: 0.2mm)),
            mark-style: (stroke: none, fill: theme.text),
          )
          for (k, p) in points.enumerate() {
            plot.add-anchor("x" + str(k), p)
            plot.add-anchor("x_" + point-id(p), p)
          }
        },
      )
      cetz.draw.content(plot-name + ".l1", $l_1$, anchor: "north-east")
      cetz.draw.content(plot-name + ".l2", $l_2$, anchor: "south-east")
      for i in range(points.len() - 1) {
        cetz.draw.line(
          plot-name + ".x" + str(i),
          plot-name + ".x" + str(i + 1),
          stroke: (paint: theme.plot-stroke, dash: "dashed", thickness: 0.2mm),
        )
        cetz.draw.rect(
          plot-name + ".x" + str(i),
          plot-name + ".x" + str(i + 1),
          stroke: (paint: theme.plot-stroke, dash: "dotted", thickness: 0.2mm),
        )
      }
      // points that coincide after rounding share one merged label
      let labels = (:)
      for (k, p) in points.enumerate() {
        let (key, val) = (point-id(p), str(k))
        if key in labels {
          labels.at(key).push(val)
        } else {
          labels.insert(key, (val,))
        }
      }
      for (anchor, texts) in labels {
        cetz.draw.content(
          plot-name + ".x_" + anchor,
          eval(mode: "math", "x_(" + texts.intersperse(";").join() + ")"),
          anchor: "north-east",
          padding: 0,
        )
      }
    }),
  )
}
