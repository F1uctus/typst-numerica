// Symbolic differentiation and expression simplification.
//
// d(expr, "x") applies the textbook rules (linearity, product, quotient,
// power, chain rule for the registered elementary functions) and then
// runs simplify() so the result looks like what one would write by hand:
// d/dx (x^3 - 3x^2 + 6x - 5) gives 3x^2 - 6x + 6, not a tree of zeros.

#import "numbers.typ": is-mpq, mpq, mpz, to-exact
#import "ast.typ": add, call, div, func, is-num, mul, neg, num, pow, sub, sym, to-expr
#import "ops.typ": operations, exact-pow

// --- numeric helpers on `num` node values -------------------------------

#let num-is(e, k) = {
  if e.kind != "num" { return false }
  let v = e.value
  if is-mpq(v) { mpq.eq(v, mpq.from(k)) } else if type(v) == float { v == float(k) } else { v == k }
}

/// Exact arithmetic on literal values, preferring to keep ints as ints.
#let lit(op, a, b) = {
  if type(a) == int and type(b) == int and op != "div" {
    if op == "add" { a + b } else if op == "sub" { a - b } else if op == "mul" { a * b } else if op == "pow" { calc.pow(a, b) }
  } else if type(a) == float or type(b) == float {
    if op == "add" { a + b } else if op == "sub" { a - b } else if op == "mul" { a * b } else if op == "div" { a / b } else if op == "pow" { calc.pow(a, b) }
  } else {
    let (qa, qb) = (to-exact(a), to-exact(b))
    let r = if op == "add" { mpq.add(qa, qb) } else if op == "sub" { mpq.sub(qa, qb) } else if op == "mul" { mpq.mul(qa, qb) } else if op == "div" { mpq.div(qa, qb) } else if op == "pow" { exact-pow(qa, qb) }
    // materialize small integers back into ints for clean display
    if mpz.to-str(mpq.den(r)) == "1" {
      let s = mpz.to-str(mpq.num(r, signed: true)).replace("\u{2212}", "-")
      if s.len() < 18 { int(s) } else { r }
    } else {
      r
    }
  }
}

// --- simplification ------------------------------------------------------

/// One bottom-up simplification pass.
#let simplify-pass(e) = {
  if e.kind != "call" { return e }
  let args = e.args.map(simplify-pass)
  let (op) = (e.op)
  let node = (kind: "call", op: op, args: args)
  let foldable = op in ("add", "sub", "mul", "div", "pow", "neg") and args.all(a => a.kind == "num" and type(a.value) != float)
  if foldable {
    if op == "neg" {
      return num(lit("sub", 0, args.first().value))
    }
    // keep literal fractions of ints as div nodes only if inexact division
    if op != "div" or num-is(args.last(), 1) or (type(args.first().value) != int or type(args.last().value) != int) {
      return num(lit(op, args.first().value, args.last().value))
    }
  }
  if op == "add" {
    if num-is(args.first(), 0) { return args.last() }
    if num-is(args.last(), 0) { return args.first() }
  } else if op == "sub" {
    if num-is(args.last(), 0) { return args.first() }
    if num-is(args.first(), 0) { return neg(args.last()) }
  } else if op == "mul" {
    let (a, b) = args
    if num-is(a, 0) or num-is(b, 0) { return num(0) }
    if num-is(a, 1) { return b }
    if num-is(b, 1) { return a }
    if num-is(a, -1) { return neg(b) }
    if num-is(b, -1) { return neg(a) }
    // put a numeric coefficient first and merge nested coefficients:
    // x·3 → 3x, 3·(2·x) → 6x
    if b.kind == "num" and a.kind != "num" { (a, b) = (b, a) }
    if (
      a.kind == "num" and b.kind == "call" and b.op == "mul" and b.args.first().kind == "num"
      and type(a.value) != float and type(b.args.first().value) != float
    ) {
      return (
        kind: "call",
        op: "mul",
        args: (num(lit("mul", a.value, b.args.first().value)), b.args.last()),
      )
    }
    return (kind: "call", op: "mul", args: (a, b))
  } else if op == "div" {
    if num-is(args.last(), 1) { return args.first() }
    if num-is(args.first(), 0) { return num(0) }
  } else if op == "pow" {
    if num-is(args.last(), 1) { return args.first() }
    if num-is(args.last(), 0) { return num(1) }
  } else if op == "neg" {
    if args.first().kind == "call" and args.first().op == "neg" {
      return args.first().args.first()
    }
  }
  node
}

/// Simplify to a fixpoint (bounded).
#let simplify(expr) = {
  let cur = to-expr(expr)
  for _ in range(16) {
    let next = simplify-pass(cur)
    if next == cur { return cur }
    cur = next
  }
  cur
}

// --- differentiation ------------------------------------------------------

/// Derivative rules for the built-in operations. Each rule receives the
/// argument list and the list of argument derivatives and returns the
/// (unsimplified) derivative expression.
#let diff-rules = (
  add: (args, dargs) => add(..dargs),
  sub: (args, dargs) => sub(..dargs),
  neg: (args, dargs) => neg(dargs.first()),
  mul: (args, dargs) => {
    let (u, v) = args
    let (du, dv) = dargs
    add(mul(du, v), mul(u, dv))
  },
  div: (args, dargs) => {
    let (u, v) = args
    let (du, dv) = dargs
    div(sub(mul(du, v), mul(u, dv)), pow(v, 2))
  },
  pow: (args, dargs) => {
    let (u, n) = args
    let (du, dn) = dargs
    if n.kind == "num" {
      // n·u^(n−1)·u'
      mul(mul(n, pow(u, num(lit("sub", n.value, 1)))), du)
    } else {
      // u^v · (v'·ln u + v·u'/u)
      mul(pow(u, n), add(mul(dn, func("ln", u)), mul(n, div(du, u))))
    }
  },
  sqrt: (args, dargs) => div(dargs.first(), mul(2, func("sqrt", args.first()))),
  root: (args, dargs) => {
    let (k, u) = args
    assert(k.kind == "num", message: "root index must be a number to differentiate")
    // rewrite as u^(1/k)
    let rule = diff-rules.pow
    rule((u, div(num(1), k)), (dargs.last(), num(0)))
  },
  sin: (args, dargs) => mul(func("cos", args.first()), dargs.first()),
  cos: (args, dargs) => neg(mul(func("sin", args.first()), dargs.first())),
  tan: (args, dargs) => div(dargs.first(), pow(func("cos", args.first()), 2)),
  ln: (args, dargs) => div(dargs.first(), args.first()),
  log: (args, dargs) => div(dargs.first(), mul(args.first(), func("ln", num(10)))),
  exp: (args, dargs) => mul(func("exp", args.first()), dargs.first()),
)

/// Symbolic derivative of `expr` with respect to the variable `var`.
/// Custom operations may provide their own rule via a `diff` entry in the
/// registry, with the same (args, dargs) => expr signature.
#let d(expr, var, ops: operations, simplified: true) = {
  let walk(e) = {
    if e.kind == "num" {
      num(0)
    } else if e.kind == "sym" {
      if e.name == var { num(1) } else { num(0) }
    } else if e.kind == "call" {
      let dargs = e.args.map(walk)
      let rule = if e.op in diff-rules {
        diff-rules.at(e.op)
      } else if e.op in ops and ops.at(e.op).at("diff", default: none) != none {
        ops.at(e.op).diff
      } else {
        panic("no derivative rule for operation: " + e.op)
      }
      rule(e.args, dargs)
    } else {
      panic("cannot differentiate node of kind: " + e.kind)
    }
  }
  let result = walk(to-expr(expr))
  if simplified { simplify(result) } else { result }
}
