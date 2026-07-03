// Rendering an expression tree back into Typst math content.
//
// Parenthesization is precedence-driven: every operation renders its
// children through `rec(child, min-prec)`, and a child whose own
// precedence is below `min-prec` gets wrapped in parentheses.

#import "numbers.typ": is-mpq, mpq, mpz, round-num
#import "ast.typ": to-expr
#import "ops.typ": operations, parens

#let atom-prec = 5

#let is-negative-num(v) = {
  if is-mpq(v) { mpq.cmp(v, mpq.from(0)) < 0 } else { v < 0 }
}

/// Rendering precedence of a numeric literal: a negative number binds like
/// a sum (it needs parens almost everywhere), a fraction binds like a
/// division, anything else is an atom.
#let num-prec(v) = {
  if is-negative-num(v) {
    1
  } else if is-mpq(v) and mpz.to-str(mpq.den(v)) != "1" {
    2
  } else {
    atom-prec
  }
}

/// Render a numeric value as math content.
/// `digits: auto` keeps the value as-is; an int rounds floats for display.
#let render-num(v, digits: auto) = {
  if is-mpq(v) {
    mpq.to-math(v)
  } else if type(v) == float and digits != auto {
    let r = calc.round(v, digits: digits)
    // collapse -0.0 and integral floats for display
    if r == calc.trunc(r) { $#str(int(r))$.body } else { $#str(r)$.body }
  } else {
    $#str(v)$.body
  }
}

/// Render a symbol name through math-mode evaluation, so names like
/// "alpha" or "x_1" display as α and x₁.
#let render-sym(name) = eval(name, mode: "math")

/// Render `expr` as embeddable math content: `$#render(e)$`.
#let render(expr, ops: operations, digits: auto) = {
  // recursive worker returning (content, prec)
  let impl(e, impl) = {
    let e = to-expr(e)
    if e.kind == "num" {
      (body: render-num(e.value, digits: digits), prec: num-prec(e.value))
    } else if e.kind == "sym" {
      (body: render-sym(e.name), prec: atom-prec)
    } else if e.kind == "matrix" {
      let cells = e.rows.map(r => r.map(el => impl(el, impl).body))
      let body = if cells.first().len() == 1 {
        math.vec(..cells.map(r => r.first()))
      } else {
        math.mat(..cells)
      }
      (body: body, prec: atom-prec)
    } else if e.kind == "call" {
      assert(e.op in ops, message: "unknown operation: " + e.op)
      let entry = ops.at(e.op)
      let rec(child, min-prec) = {
        let r = impl(child, impl)
        if r.prec < min-prec { parens(r.body) } else { r.body }
      }
      let body = if "render" in entry and entry.render != none {
        (entry.render)(e.args, rec)
      } else {
        // default: name(arg, ...)
        let args = e.args.map(a => rec(a, 0))
        $#math.op(e.op) #parens(args.join($,$.body))$.body
      }
      (body: body, prec: entry.at("prec", default: 4))
    } else {
      panic("cannot render node of kind: " + e.kind)
    }
  }
  impl(to-expr(expr), impl).body
}
