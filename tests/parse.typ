// Parser tests: from-math round-trips against hand-built trees,
// plus evaluation of parsed expressions.
// Compile with: typst compile tests/parse.typ --root . --package-path packages

#import "../src/lib.typ": *

#let x = sym("x")

// --- structural equality with hand-built trees --------------------------

#assert.eq(from-math($2 x + 5$), add(mul(2, x), 5))
#assert.eq(from-math($x^2$), pow(x, 2))
#assert.eq(from-math($x^2 - 2 x$), sub(pow(x, 2), mul(2, x)))
#assert.eq(from-math($119/90$), div(num(119), num(90)))
#assert.eq(from-math($2 dot (x + 1)$), mul(2, add(x, 1)))
#assert.eq(from-math($sin(x)$), func("sin", x))
#assert.eq(from-math($2 sin(x) cos(x)$), mul(mul(2, func("sin", x)), func("cos", x)))
#assert.eq(from-math($sqrt(x + 1)$), func("sqrt", add(x, 1)))
#assert.eq(from-math($root(3, x)$), func("root", 3, x))
#assert.eq(from-math($abs(x - 1)$), func("abs", sub(x, 1)))
#assert.eq(from-math($-5 + x$), add(neg(num(5)), x))
#assert.eq(from-math($x_1 + x_2$), add(sym("x_1"), sym("x_2")))
#assert.eq(from-math($x_2^3$), pow(sym("x_2"), 3))
#assert.eq(from-math($alpha beta$), mul(sym("α"), sym("β")))
#assert.eq(from-math($1.5 x$), mul(num(decimal("1.5")), x))
#assert.eq(from-math($(x + 1) / (x - 1)$), div(add(x, 1), sub(x, 1)))

// a function written naturally with a defining `=`
#let f = from-math($f(x) = x^3 - 3 x^2 + 6 x - 5$)
#assert.eq(f, sub(add(sub(pow(x, 3), mul(3, pow(x, 2))), mul(6, x)), 5))

// --- parsed trees evaluate correctly ------------------------------------

#assert.eq(mpq.to-str(evaluate(f, ctx: (x: div(4, 3)))), "1/27")
#assert.eq(evaluate(from-math($2 x + 5$), ctx: (x: 3), mode: "float"), 11.0)
#assert.eq(evaluate(from-math($sin(x)^2 + cos(x)^2$), ctx: (x: 0.7), mode: "float"), 1.0)
#assert.eq(evaluate(from-math($(1 + 1/3) dot 3/4$)), evaluate(num(1)))

// operator precedence: 2 + 3 * 4 = 14, not 20
#assert.eq(evaluate(from-math($2 + 3 dot 4$), mode: "float"), 14.0)
// unary minus binds tighter than addition: -(2) + 3
#assert.eq(evaluate(from-math($-2 + 3$), mode: "float"), 1.0)
// but applies to whole products: -2 x at x=3 is -6
#assert.eq(evaluate(from-math($-2 x$), ctx: (x: 3), mode: "float"), -6.0)

// --- custom function registration ----------------------------------------

#let my-ops = register-op(
  operations,
  "sinc",
  (
    arity: 1,
    prec: 4,
    eval-float: a => if a == 0.0 { 1.0 } else { calc.sin(a) / a },
  ),
)
#let g = from-math($3 sinc(x)$, ops: my-ops)
#assert.eq(g, mul(3, func("sinc", x)))
#assert.eq(evaluate(g, ctx: (x: 0), mode: "float", ops: my-ops), 3.0)

#set page(width: 16cm, height: auto, margin: 1cm)

= Parse → render round-trip samples

$ #render(from-math($2 x + 5$)) $
$ #render(from-math($x^3 - 3 x^2 + 6 x - 5$)) $
$ #render(from-math($(x + 1) / (x - 1) + sqrt(x + 1)$)) $
$ #render(from-math($2 sin(x) cos(x) - abs(x - 1)$)) $
$ #render(from-math($x_1 + x_2^3 - alpha$)) $

All parser assertions passed.
