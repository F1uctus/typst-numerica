// Smoke test for the vendored peano fork (packages/preview/peano/0.2.3).
// Compile with: typst compile tests/peano-vendored.typ --root . --package-path packages

#import "@preview/peano:0.2.3": q, number

// q (pure-Typst rationals): 1/3 + 1/6 = 1/2
#let s = q.add(q.from(1, 3), q.from(1, 6))
#assert.eq(q.to-str(s), "1/2")

// mpq (wasm, arbitrary precision): a numerator far beyond int64,
// taken from the hw03 Newton iteration values.
#let big = number.mp.mpq.from(
  "2335074300375426691686978882286804543426320503/197477545403677695951384253696524653291868024479037000",
)
#let doubled = number.mp.mpq.mul(big, number.mp.mpq.from("2"))
#assert.eq(
  number.mp.mpq.to-str(doubled),
  "2335074300375426691686978882286804543426320503/98738772701838847975692126848262326645934012239518500",
)

All peano smoke tests passed.
