// Differentiation and simplification tests.
// Compile with: typst compile tests/diff.typ --root . --package-path packages

#import "../src/lib.typ": *

#let x = sym("x")

// --- simplify ---------------------------------------------------------------

#assert.eq(simplify(add(x, 0)), x)
#assert.eq(simplify(mul(1, x)), x)
#assert.eq(simplify(mul(0, x)), num(0))
#assert.eq(simplify(pow(x, 1)), x)
#assert.eq(simplify(neg(neg(x))), x)
#assert.eq(simplify(mul(x, 3)), mul(3, x))
#assert.eq(simplify(mul(3, mul(2, x))), mul(6, x))
#assert.eq(simplify(add(mul(2, 3), 4)), num(10))
// literal integer fractions are kept as fractions, not folded away
#assert.eq(simplify(div(1, 3)), div(1, 3))
#assert.eq(simplify(div(x, 1)), x)

// --- hw03: f(x) = x^3 - 3x^2 + 6x - 5 ---------------------------------------

#let f = from-math($x^3 - 3 x^2 + 6 x - 5$)
#let df = d(f, "x")
#let d2f = d(df, "x")

// f' = 3x^2 - 6x + 6, structurally equal to the parsed expectation
#assert.eq(df, from-math($3 x^2 - 6 x + 6$))
// f'' = 6x - 6
#assert.eq(d2f, from-math($6 x - 6$))

// numeric agreement with the expected derivatives at several points
#let d1f-manual(v) = 3 * v * v - 6 * v + 6
#let d2f-manual(v) = 6 * v - 6
#for v in (1.0, 1.5, 2.0, -0.5) {
  assert(calc.abs(evaluate(df, ctx: (x: v), mode: "float") - d1f-manual(v)) < 1e-12)
  assert(calc.abs(evaluate(d2f, ctx: (x: v), mode: "float") - d2f-manual(v)) < 1e-12)
}

// --- chain rule through elementary functions ---------------------------------

// (sin(x^2))' = cos(x^2)·2x
#let g = d(from-math($sin(x^2)$), "x")
#for v in (0.3, 1.1) {
  assert(calc.abs(evaluate(g, ctx: (x: v), mode: "float") - calc.cos(v * v) * 2 * v) < 1e-12)
}

// (ln(x))' = 1/x, (e^u)' with u = 2x
#assert.eq(d(from-math($ln(x)$), "x"), div(num(1), x))
#let h = d(func("exp", mul(2, x)), "x")
#for v in (0.0, 0.7) {
  assert(calc.abs(evaluate(h, ctx: (x: v), mode: "float") - 2 * calc.exp(2 * v)) < 1e-12)
}

// (sqrt(x))' = 1/(2 sqrt(x))
#let s = d(from-math($sqrt(x)$), "x")
#assert(calc.abs(evaluate(s, ctx: (x: 4), mode: "float") - 0.25) < 1e-12)

// quotient rule: (x/(x+1))' = 1/(x+1)^2
#let q = d(from-math($x / (x + 1)$), "x")
#for v in (0.5, 2.0) {
  assert(calc.abs(evaluate(q, ctx: (x: v), mode: "float") - 1 / calc.pow(v + 1, 2)) < 1e-12)
}

#set page(width: 16cm, height: auto, margin: 1cm)

= Derivatives, rendered

$ f(x) = #render(f) $
$ f'(x) = #render(df) $
$ f''(x) = #render(d2f) $
$ (sin(x^2))' = #render(g) $
$ (x / (x + 1))' = #render(q) $

All differentiation assertions passed.
