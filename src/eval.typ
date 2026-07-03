// Full evaluation of an expression tree.

#import "numbers.typ": is-mpq, to-exact, to-float-num
#import "ast.typ": to-expr
#import "ops.typ": operations
#import "linalg.typ": is-matrix-value, matrix-value, mv-apply

/// Evaluate `expr` to a number, or to (mrows: ...) for matrix results.
///
/// - ctx:  dictionary of variable values, e.g. `(x: 3)`. Values may be
///   ints, floats, decimals, mpq rationals, or expression nodes
///   (including matrix nodes).
/// - mode: "exact" computes over peano mpq rationals; "float" over floats.
///   In exact mode a subtree rooted at an operation with no exact form
///   (e.g. sin) is computed in floats, and the float result propagates
///   upward — so the overall result is an mpq only if every operation on
///   the path had an exact implementation.
/// - ops:  operation registry (see ops.typ).
#let evaluate(expr, ctx: (:), mode: "exact", ops: operations) = {
  assert(mode in ("exact", "float"), message: "mode must be \"exact\" or \"float\"")
  let e = to-expr(expr)
  if e.kind == "num" {
    if mode == "exact" { to-exact(e.value) } else { to-float-num(e.value) }
  } else if e.kind == "sym" {
    assert(e.name in ctx, message: "unbound variable: " + e.name)
    evaluate(to-expr(ctx.at(e.name)), ctx: ctx, mode: mode, ops: ops)
  } else if e.kind == "matrix" {
    matrix-value(e.rows.map(r => r.map(el => evaluate(el, ctx: ctx, mode: mode, ops: ops))))
  } else if e.kind == "call" {
    assert(e.op in ops, message: "unknown operation: " + e.op)
    let entry = ops.at(e.op)
    let vals = e.args.map(a => evaluate(a, ctx: ctx, mode: mode, ops: ops))
    if vals.any(is-matrix-value) {
      let scalar-op(op, a, b) = {
        let entry = ops.at(op)
        let vals = if op == "neg" { (a,) } else { (a, b) }
        if mode == "exact" and entry.eval-exact != none and vals.all(v => type(v) != float) {
          (entry.eval-exact)(..vals.map(to-exact))
        } else {
          (entry.eval-float)(..vals.map(to-float-num))
        }
      }
      mv-apply(e.op, vals, scalar-op)
    } else if (
      mode == "exact" and entry.eval-exact != none and vals.all(v => not (type(v) == float))
    ) {
      (entry.eval-exact)(..vals)
    } else {
      (entry.eval-float)(..vals.map(to-float-num))
    }
  } else {
    panic("cannot evaluate node of kind: " + e.kind)
  }
}
