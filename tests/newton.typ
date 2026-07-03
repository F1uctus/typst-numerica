// Newton's method tests for f(x) = x³ − 3x² + 6x − 5 on [1, 2].
// Compile with: typst compile tests/newton.typ --root . --package-path packages

#import "../src/lib.typ": *

#let f = from-math($f(x) = x^3 - 3 x^2 + 6 x - 5$)
#let nh = newton-history(f, 1, iterations: 5)
#let h = nh.history

// exact iteration values, cross-checked with Python's fractions module
#assert.eq(mpq.to-str(h.at(1)), "4/3")
#assert.eq(mpq.to-str(h.at(2)), "119/90")
#assert.eq(mpq.to-str(h.at(3)), "1595924/1207035")
#assert.eq(
  mpq.to-str(h.at(4)),
  "7699542416226594943/5823345712677348330",
)

// intermediate values of the chain
#assert.eq(mpq.to-str(evaluate(f, ctx: (x: h.at(2)))), "89/729000")
#assert.eq(
  mpq.to-str(evaluate(f, ctx: (x: h.at(3)))),
  "2310468569/1758569716580767875",
)
#assert.eq(
  mpq.to-str(evaluate(nh.df, ctx: (x: h.at(3)))),
  "1608168145546/485644497075",
)

// exact decimal expansion of x5 (cross-checked with Python's decimal)
#assert.eq(
  mpq-to-decimal-str(h.at(5), digits: 23),
  "1.32218535462608559291147",
)

// Fourier condition on [1, 2]
#let fc = fourier-condition(f, 1, 2)
#assert(fc.ok)
#assert.eq(fc.x0, 2) // f(2) > 0 and f'' ≥ 0 on the interval
#assert.eq(fc.df, from-math($3 x^2 - 6 x + 6$))

// error estimate: m = 3, M = 6, so Δ = |x5 − x4|² ≈ 2.1e−39
#let err = newton-error(f, 1, 2, h)
#assert.eq(err.m, 3.0)
#assert.eq(err.em, 6.0)
#assert(err.delta < 1e-38 and err.delta > 1e-40)
// x5 agrees with the root far beyond the 30-digit comparison window
#assert(err.digits >= 25, message: "got " + str(err.digits) + " digits")

#set page(width: 20cm, height: auto, margin: 1cm)

= Newton chain (generated)

#show-newton-iterations(f, h, df: nh.df)

= Fourier condition table

#fc.content

All Newton assertions passed (digits: #err.digits, delta: #err.delta).
