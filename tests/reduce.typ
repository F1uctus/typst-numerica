// Reduction engine tests: step kinds, final values, trace shapes.
// Compile with: typst compile tests/reduce.typ --root . --package-path packages

#import "../src/lib.typ": *

#let x = sym("x")

// --- 2x + 5 at x = 3: substitute, then two computes ----------------------

#let trace = reduce-trace(from-math($2 x + 5$), ctx: (x: 3))
#assert.eq(trace.len(), 3)
#assert.eq(trace.map(s => s.kind), ("substitute", "compute", "compute"))
// intermediate shapes: 2·3 + 5 → 6 + 5 → 11
#assert.eq(trace.at(0).expr, add(mul(2, 3), 5))
#assert.eq(trace.at(1).expr.args.first().kind, "num")
#let final = trace.last().expr
#assert(is-num(final))
#assert.eq(mpq.to-str(final.value), "11")

// --- substitution granularity ---------------------------------------------

// "var": every occurrence of one variable in one step
#let t2 = reduce-trace(from-math($x^2 + x + y$), ctx: (x: 2, y: 5))
#assert.eq(t2.map(s => s.kind).filter(k => k == "substitute").len(), 2)

// "all": one big substitution step
#let t3 = reduce-trace(from-math($x^2 + x + y$), ctx: (x: 2, y: 5), subst: "all")
#assert.eq(t3.map(s => s.kind).filter(k => k == "substitute").len(), 1)
#assert.eq(mpq.to-str(t3.last().expr.value), "11")

// --- exact arithmetic in the trace ----------------------------------------

// hw03 Newton step at x = 4/3: f(x)/f'(x) stays exact all the way
#let f-over-df = from-math($(x^3 - 3 x^2 + 6 x - 5) / (3 x^2 - 6 x + 6)$)
#let t4 = reduce-trace(f-over-df, ctx: (x: div(4, 3)))
#assert.eq(mpq.to-str(t4.last().expr.value), "1/90")

// float mode
#let t5 = reduce-trace(from-math($2 x + 5$), ctx: (x: 3), mode: "float")
#assert.eq(t5.last().expr.value, 11.0)

// an already-reduced expression yields an empty trace
#assert.eq(reduce-trace(num(42)).len(), 0)

// --- rendered chains -------------------------------------------------------

#set page(width: 18cm, height: auto, margin: 1cm)

= Full reduction, English

#show-reduction(from-math($2 x + 5$), ctx: (x: 3))

= Full reduction, Russian, exact fractions

#show-reduction(f-over-df, ctx: (x: div(4, 3)), lang: "ru")

= Substitute-all, compact

#show-reduction(
  from-math($x^2 + x + y$),
  ctx: (x: 2, y: 5),
  subst: "all",
  compact: true,
  lang: "ru",
)

All reduction assertions passed.
