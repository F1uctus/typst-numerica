// Matrices and vectors.
//
// Expression side: a "matrix" node holds a rectangular grid of expressions
//   (kind: "matrix", rows: ((expr, ...), ...))
// A vector is a single-column matrix.
//
// Matrix arithmetic reduces *structurally*: multiplying a matrix by a
// vector first expands into a vector of scalar sum-of-product expressions
// (one visible step), after which the scalar engine takes over — exactly
// how the computation is written out by hand.
//
// Value side: evaluate() returns (mrows: ((number, ...), ...)) for matrix
// results, and the helpers below implement plain numeric matrix algebra
// for the methods layer.

#import "numbers.typ": to-exact, to-float-num
#import "ast.typ": add, call, is-num, mul, num, sub, to-expr

// --- constructors and predicates ----------------------------------------

#let is-matrix(v) = type(v) == dictionary and "kind" in v and v.kind == "matrix"

/// Matrix from rows: mat-of((1, 2), (3, 4)).
#let mat-of(..rows) = {
  let rows = rows.pos().map(r => r.map(to-expr))
  assert(rows.len() > 0, message: "matrix must have at least one row")
  assert(
    rows.all(r => r.len() == rows.first().len()),
    message: "matrix rows must have equal lengths",
  )
  (kind: "matrix", rows: rows)
}

/// Column vector: vec-of(1, 2).
#let vec-of(..els) = mat-of(..els.pos().map(e => (e,)))

#let mat-dims(m) = (rows: m.rows.len(), cols: m.rows.first().len())

/// Map a function over all elements of a matrix node.
#let mat-map(m, f) = (kind: "matrix", rows: m.rows.map(r => r.map(f)))

// --- structural expansion (used by the reduction engine) ------------------

/// If `e` is a call that combines matrix operands, rewrite it one
/// structural step (matrix product → sum-of-products elements, matrix sum
/// → elementwise sums, ...). Returns (expr, action) or none.
#let expand-matrix-call(e) = {
  if e.kind != "call" { return none }
  let args = e.args
  if e.op in ("add", "sub") and args.len() == 2 and args.all(is-matrix) {
    let (a, b) = args
    assert(mat-dims(a) == mat-dims(b), message: "matrix dimensions do not match")
    let rows = a
      .rows
      .zip(b.rows)
      .map(((ra, rb)) => ra.zip(rb).map(((x, y)) => call(e.op, x, y)))
    return (expr: (kind: "matrix", rows: rows), action: "expand-elementwise")
  }
  if e.op == "mul" and args.len() == 2 {
    let (a, b) = args
    if is-matrix(a) and is-matrix(b) {
      let (da, db) = (mat-dims(a), mat-dims(b))
      assert(da.cols == db.rows, message: "matrix dimensions do not match for a product")
      let rows = range(da.rows).map(i => range(db.cols).map(j => {
        add(..range(da.cols).map(k => mul(a.rows.at(i).at(k), b.rows.at(k).at(j))))
      }))
      // a 1×1 product collapses to its single scalar expression
      let rows = if da.rows == 1 and db.cols == 1 { rows } else { rows }
      return (expr: (kind: "matrix", rows: rows), action: "expand-product")
    }
    if is-matrix(a) != is-matrix(b) {
      let (m, s) = if is-matrix(a) { (a, b) } else { (b, a) }
      // expand the scalar over the elements only once the scalar itself
      // is a plain number, so it reduces first and reads naturally
      if s.kind == "num" {
        return (expr: mat-map(m, el => mul(s, el)), action: "expand-scale")
      }
      return none
    }
  }
  if e.op == "neg" and args.len() == 1 and is-matrix(args.first()) {
    return (expr: mat-map(args.first(), el => call("neg", el)), action: "expand-elementwise")
  }
  none
}

// --- numeric matrix algebra (for the methods layer) -----------------------

#let is-matrix-value(v) = type(v) == dictionary and "mrows" in v

#let matrix-value(rows) = (mrows: rows)

/// Elementwise numeric coercion of a matrix value.
#let mv-coerce(v, mode) = {
  let coerce = if mode == "exact" { to-exact } else { to-float-num }
  matrix-value(v.mrows.map(r => r.map(coerce)))
}

/// Numeric matrix operations over already-evaluated operands. `scalar-op`
/// carries the scalar semantics: (op-name, a, b) => value.
#let mv-apply(op, vals, scalar-op) = {
  if op in ("add", "sub") {
    let (a, b) = vals
    assert(
      is-matrix-value(a) and is-matrix-value(b),
      message: "matrix " + op + " needs two matrices",
    )
    matrix-value(a.mrows.zip(b.mrows).map(((ra, rb)) => ra.zip(rb).map(((x, y)) => scalar-op(op, x, y))))
  } else if op == "neg" {
    matrix-value(vals.first().mrows.map(r => r.map(x => scalar-op("neg", x, none))))
  } else if op == "mul" {
    let (a, b) = vals
    if is-matrix-value(a) and is-matrix-value(b) {
      let n = b.mrows.len()
      assert(a.mrows.first().len() == n, message: "matrix dimensions do not match for a product")
      matrix-value(a.mrows.map(ra => range(b.mrows.first().len()).map(j => {
        let terms = range(n).map(k => scalar-op("mul", ra.at(k), b.mrows.at(k).at(j)))
        let acc = terms.first()
        for t in terms.slice(1) { acc = scalar-op("add", acc, t) }
        acc
      })))
    } else {
      let (m, s) = if is-matrix-value(a) { (a, b) } else { (b, a) }
      matrix-value(m.mrows.map(r => r.map(x => scalar-op("mul", s, x))))
    }
  } else {
    panic("operation `" + op + "` is not defined for matrices")
  }
}
