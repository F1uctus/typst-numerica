// Core tests: AST construction, evaluation (float and exact), rendering.
// Compile with: typst compile tests/core.typ --root . --package-path packages

#import "../src/lib.typ": *

// --- AST construction and coercion -----------------------------------

#let x = sym("x")
#let e1 = add(mul(2, x), 5) // 2x + 5
#assert.eq(e1.kind, "call")
#assert.eq(e1.op, "add")
#assert.eq(e1.args.first().op, "mul")
#assert.eq(e1.args.first().args.first(), num(2))
#assert.eq(to-expr("y"), sym("y"))
// structural equality is plain dictionary equality
#assert.eq(add(mul(2, x), 5), e1)

// --- float evaluation -------------------------------------------------

#assert.eq(evaluate(e1, ctx: (x: 3), mode: "float"), 11.0)
#assert.eq(evaluate(pow(x, 2), ctx: (x: 4), mode: "float"), 16.0)
#assert.eq(evaluate(func("sqrt", 16), mode: "float"), 4.0)
#assert.eq(evaluate(func("sin", 0), mode: "float"), 0.0)
#assert.eq(evaluate(neg(div(1, 2)), mode: "float"), -0.5)
// ctx values may be expressions themselves
#assert.eq(evaluate(x, ctx: (x: add(1, 1)), mode: "float"), 2.0)

// --- exact evaluation -------------------------------------------------

// 1/3 + 1/6 = 1/2
#assert.eq(mpq.to-str(evaluate(add(div(1, 3), div(1, 6)))), "1/2")
// (2/3)^3 = 8/27
#assert.eq(mpq.to-str(evaluate(pow(div(2, 3), 3))), "8/27")
// hw03: f(x) = x^3 - 3x^2 + 6x - 5 at x = 4/3 gives exactly 1/27
#let f = sub(add(sub(pow(x, 3), mul(3, pow(x, 2))), mul(6, x)), 5)
#assert.eq(mpq.to-str(evaluate(f, ctx: (x: div(4, 3)))), "1/27")
// integers stay exact (peano prints the typographic minus U+2212)
#assert.eq(mpq.to-str(evaluate(f, ctx: (x: 1))), "\u{2212}1")
// an operation without an exact form degrades the subtree to float
#assert.eq(evaluate(func("sqrt", 16)), 4.0)
// decimals convert exactly: 0.2 = 1/5
#assert.eq(mpq.to-str(evaluate(num(decimal("0.2")))), "1/5")

// --- exact decimal expansion ------------------------------------------

#assert.eq(mpq-to-decimal-str(evaluate(div(1, 3)), digits: 5), "0.33333")
#assert.eq(mpq-to-decimal-str(evaluate(div(2, 3)), digits: 5), "0.66667")
#assert.eq(mpq-to-decimal-str(evaluate(neg(div(119, 90))), digits: 6), "-1.322222")
#assert.eq(round-num(evaluate(div(119, 90)), digits: 3), 1.322)

// --- float <-> exact bridging -----------------------------------------

#assert.eq(to-float-num(evaluate(div(1, 4))), 0.25)
#assert(calc.abs(mpq-to-float(evaluate(div(1, 3))) - 0.333333333) < 1e-8)

// --- rendering (structural spot checks + visual page) ------------------

// numbers and symbols
#assert.eq(repr(render(num(2))), repr($#("2")$.body))
// pow renders via attach
#assert(repr(render(pow(x, 2))).contains("attach"))
// div renders via frac
#assert(repr(render(div(1, 3))).contains("frac"))

#set page(width: 16cm, height: auto, margin: 1cm)

= Core rendering samples

$ #render(e1) = "2x + 5" $
$ #render(f) = "x^3 - 3x^2 + 6x - 5" $
$ #render(sub(x, add(sym("y"), 1))) = "x - (y + 1)" $
$ #render(mul(2, add(x, 1))) = "2 dot (x + 1)" $
$ #render(mul(2, func("sin", x))) = "2 sin(x)" $
$ #render(pow(neg(num(2)), 3)) = "(-2)^3" $
$ #render(pow(x, div(1, 2))) = "x^(1/2)" $
$ #render(add(x, num(-3))) = "x + (-3)" $
$ #render(func("root", 3, add(x, 1))) = "cube root" $
$ #render(div(add(x, 1), sub(x, 1))) = "(x+1)/(x-1) as frac" $
$ #render(num(evaluate(div(119, 90)))) = "119/90 as mpq" $
$ #render(sym("alpha")) = "alpha" $
$ #render(sym("x_1")) = "x sub 1" $

All core assertions passed.
