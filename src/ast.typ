// Expression tree: plain Typst dictionaries, in the spirit of S-expressions.
//
// Node kinds:
//   (kind: "num",  value: int | float | decimal | mpq)
//   (kind: "sym",  name: str)
//   (kind: "call", op: str, args: (expr, ...))
//
// Everything else (operator semantics, rendering, derivatives) lives in the
// operation registry (ops.typ), keyed by the "op" field.

#import "numbers.typ": is-number

#let is-expr(v) = type(v) == dictionary and "kind" in v
#let is-num(v) = is-expr(v) and v.kind == "num"
#let is-sym(v) = is-expr(v) and v.kind == "sym"
#let is-call(v, op: none) = {
  is-expr(v) and v.kind == "call" and (op == none or v.op == op)
}

#let num(v) = (kind: "num", value: v)
#let sym(name) = (kind: "sym", name: name)

/// Coerce a bare value into an expression node:
/// numbers become `num` nodes, strings become `sym` nodes.
#let to-expr(v) = {
  if is-expr(v) {
    v
  } else if is-number(v) {
    num(v)
  } else if type(v) == str {
    sym(v)
  } else {
    panic("cannot coerce to an expression: " + repr(v))
  }
}

#let call(op, ..args) = (kind: "call", op: op, args: args.pos().map(to-expr))

/// Left-fold a variadic list into nested binary calls.
#let fold-binary(op, args) = {
  let args = args.map(to-expr)
  assert(args.len() >= 2, message: op + " needs at least two arguments")
  let acc = args.first()
  for x in args.slice(1) { acc = call(op, acc, x) }
  acc
}

#let add(..xs) = fold-binary("add", xs.pos())
#let sub(a, b) = call("sub", a, b)
#let mul(..xs) = fold-binary("mul", xs.pos())
#let div(a, b) = call("div", a, b)
#let pow(a, b) = call("pow", a, b)
#let neg(x) = call("neg", x)

/// A named function application, e.g. `func("sin", sym("x"))`.
#let func(name, ..args) = call(name, ..args.pos())
