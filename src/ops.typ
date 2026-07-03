// Operation registry: the single place where each operation's semantics
// live. One entry glues together what Typst normally splits between
// `calc.sin` (computation) and `sin` (math-mode rendering):
//
//   arity       — number of arguments
//   prec        — rendering precedence (higher binds tighter):
//                 1 add/sub, 1.5 neg, 2 mul/div, 3 pow, 4 function call, 5 atom
//   eval-float  — float implementation, (..float) => float
//   eval-exact  — exact implementation over peano mpq, or `none` if the
//                 operation has no exact form (then evaluation of that
//                 subtree falls back to floats)
//   render      — (args, rec) => content, where `rec(child, min-prec)`
//                 renders a child node, parenthesizing it when its
//                 precedence is below `min-prec`; when omitted, the
//                 operation renders as `name(arg, ...)`
//   diff        — optional derivative rule, see diff.typ
//
// The registry is an immutable dictionary; `register-op` returns an
// extended copy which can be passed to evaluate/render/reduce via their
// `ops:` argument.

#import "numbers.typ": is-mpq, mpq, mpz, mpq-to-float

#let is-negative(v) = {
  if is-mpq(v) { mpq.cmp(v, mpq.from(0)) < 0 } else { v < 0 }
}

#let negate(v) = if is-mpq(v) { mpq.neg(v) } else { -v }

/// Convert an integer-valued mpq into a Typst int (for exact `pow`).
#let exact-int(p) = {
  assert(
    mpz.to-str(mpq.den(p)) == "1",
    message: "exponent must be an integer in exact mode",
  )
  int(mpz.to-str(mpq.num(p, signed: true)))
}

/// Exact integer power of an mpq by square-and-multiply over mpq.mul,
/// independent of the plugin's own pow entry point.
#let exact-pow(a, p) = {
  let n = exact-int(p)
  if n == 0 { return mpq.from(1) }
  let base = if n < 0 { mpq.reci(a) } else { a }
  let n = calc.abs(n)
  let result = mpq.from(1)
  let cur = base
  while n > 0 {
    if calc.rem(n, 2) == 1 { result = mpq.mul(result, cur) }
    n = int((n - calc.rem(n, 2)) / 2)
    if n > 0 { cur = mpq.mul(cur, cur) }
  }
  result
}

// Rendering helpers. `$...$.body` extracts embeddable math content.
#let parens(c) = $lr((#c))$.body

/// True when the rendered form of `node` starts with a letter-like glyph,
/// so a preceding numeric coefficient can be juxtaposed (2x, 2sin(x)).
#let letterish(node) = {
  if node.kind == "sym" { return true }
  if node.kind != "call" { return false }
  if node.op == "pow" { return letterish(node.args.first()) }
  if node.op in ("sqrt", "root") { return true }
  // infix/prefix operators start with a number or a sign, named
  // functions render as `name(...)` and start with a letter
  node.op not in ("add", "sub", "mul", "div", "neg", "abs")
}

/// True when the rendered form of `node` is a bare number (so a following
/// juxtaposition would be ambiguous and needs an explicit dot).
#let numberish(node) = node.kind == "num"

#let operations = (
  add: (
    arity: 2,
    prec: 1,
    eval-float: (a, b) => a + b,
    eval-exact: (a, b) => mpq.add(a, b),
    render: (args, rec) => {
      let (a, b) = args
      // render `a + (-b)` as `a - b`
      if b.kind == "call" and b.op == "neg" {
        $#rec(a, 1) - #rec(b.args.first(), 2)$.body
      } else if b.kind == "num" and is-negative(b.value) {
        $#rec(a, 1) - #rec((kind: "num", value: negate(b.value)), 2)$.body
      } else {
        $#rec(a, 1) + #rec(b, 1.5)$.body
      }
    },
  ),
  sub: (
    arity: 2,
    prec: 1,
    eval-float: (a, b) => a - b,
    eval-exact: (a, b) => mpq.sub(a, b),
    render: (args, rec) => $#rec(args.first(), 1) - #rec(args.last(), 2)$.body,
  ),
  mul: (
    arity: 2,
    prec: 2,
    eval-float: (a, b) => a * b,
    eval-exact: (a, b) => mpq.mul(a, b),
    render: (args, rec) => {
      let (a, b) = args
      let (ca, cb) = (rec(a, 2), rec(b, 2.5))
      // 2x, 2sin(x), x y — juxtapose; 2·3, x·2, (…)·(…) — explicit dot
      if letterish(b) or (a.kind == "sym" and not numberish(b)) {
        $#ca #cb$.body
      } else {
        $#ca dot #cb$.body
      }
    },
  ),
  div: (
    arity: 2,
    prec: 2,
    eval-float: (a, b) => a / b,
    eval-exact: (a, b) => mpq.div(a, b),
    // a fraction is visually self-delimiting: children never need parens
    render: (args, rec) => math.frac(rec(args.first(), 0), rec(args.last(), 0)),
  ),
  neg: (
    arity: 1,
    prec: 1.5,
    eval-float: a => -a,
    eval-exact: a => mpq.neg(a),
    render: (args, rec) => $-#rec(args.first(), 2)$.body,
  ),
  pow: (
    arity: 2,
    prec: 3,
    eval-float: (a, b) => calc.pow(a, b),
    eval-exact: (a, b) => exact-pow(a, b),
    render: (args, rec) => math.attach(rec(args.first(), 4), t: rec(args.last(), 0)),
  ),
  sqrt: (
    arity: 1,
    prec: 4,
    eval-float: a => calc.sqrt(a),
    eval-exact: none,
    render: (args, rec) => math.sqrt(rec(args.first(), 0)),
  ),
  root: (
    // args: (index, radicand)
    arity: 2,
    prec: 4,
    eval-float: (idx, x) => calc.root(x, int(idx)),
    eval-exact: none,
    render: (args, rec) => math.root(rec(args.first(), 0), rec(args.last(), 0)),
  ),
  abs: (
    arity: 1,
    prec: 4,
    eval-float: a => calc.abs(a),
    eval-exact: a => mpq.abs(a),
    render: (args, rec) => $lr(|#rec(args.first(), 0)|)$.body,
  ),
  sin: (arity: 1, prec: 4, eval-float: a => calc.sin(a), eval-exact: none),
  cos: (arity: 1, prec: 4, eval-float: a => calc.cos(a), eval-exact: none),
  tan: (arity: 1, prec: 4, eval-float: a => calc.tan(a), eval-exact: none),
  ln: (arity: 1, prec: 4, eval-float: a => calc.ln(a), eval-exact: none),
  log: (arity: 1, prec: 4, eval-float: a => calc.log(a), eval-exact: none),
  exp: (
    arity: 1,
    prec: 4,
    eval-float: a => calc.exp(a),
    eval-exact: none,
    render: (args, rec) => math.attach($e$.body, t: rec(args.first(), 0)),
  ),
)

/// Return a copy of `ops` extended (or overridden) with a new operation.
#let register-op(ops, name, entry) = {
  let defaults = (arity: 1, prec: 4, eval-float: none, eval-exact: none)
  ops + ((name): defaults + entry)
}
