// Matrix/vector tests: numeric evaluation, structural expansion in the
// reduction engine, rendering — reproducing the hw01 Jacobi iteration.
// Compile with: typst compile tests/linalg.typ --root . --package-path packages

#import "../src/lib.typ": *

// hw01, task 1: α = ((0, −1.5), (0.5, 0)), β = (0.5, 1.5), x⁰ = (21, 24)
#let alpha = mat-of((0, decimal("-1.5")), (decimal("0.5"), 0))
#let beta = vec-of(decimal("0.5"), decimal("1.5"))
#let x0 = vec-of(21, 24)

// --- numeric evaluation: x¹ = α·x⁰ + β ----------------------------------

#let step(x) = evaluate(add(mul(alpha, sym("x")), beta), ctx: (x: x))
#let as-floats(mv) = mv.mrows.map(r => r.map(to-float-num))

#let x1 = step(x0)
#assert.eq(as-floats(x1), ((-35.5,), (12.0,)))

// iterate the way solve-jacobi did in the old hw01 and check the history
#let history = (x0,)
#let cur = evaluate(x0)
#for _ in range(5) {
  cur = evaluate(add(mul(alpha, sym("x")), beta), ctx: (x: (kind: "matrix", rows: cur.mrows.map(r => r.map(num)))))
}
// x⁵ computed by hand: (−20.40625, 7.1875)
#assert.eq(as-floats(cur), ((-20.40625,), (7.1875,)))

// --- full reduction with matrices -----------------------------------------

#let expr = add(mul(alpha, sym("x")), beta)
#let trace = reduce-trace(expr, ctx: (x: x0))
#let kinds = trace.map(s => s.kind)
#assert.eq(kinds.first(), "substitute")
#assert(kinds.contains("expand"))
// the final expression is a fully numeric vector
#let final = trace.last().expr
#assert(is-matrix(final))
#assert(final.rows.flatten().all(is-num))
#assert.eq(final.rows.map(r => r.map(el => to-float-num(el.value))), ((-35.5,), (12.0,)))

#set page(width: 18cm, height: auto, margin: 1cm)

= Jacobi iteration, one full step

#show-reduction(expr, ctx: (x: x0), lang: "ru")

All linear-algebra assertions passed.
