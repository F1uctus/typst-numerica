// from-math: parse Typst math content into an expression tree.
//
// Works on the *content* structure of a math block (typst 0.15):
//   symbol   — single letters, greek letters and operator glyphs (.text)
//   text     — digit runs like "119" or "1.5" and multi-letter words (.text)
//   op       — named operators like sin, ln (.text)
//   attach   — sub/superscripts (.base, .t, .b)
//   frac     — fractions (.num, .denom)
//   root     — roots (.index, .radicand)
//   lr       — delimited groups (.body includes the delimiter symbols)
//   sequence — juxtaposition (.children)
//
// Supported input: + − ⋅ × / implicit multiplication, powers, subscripts
// (folded into the symbol name: x_1), fractions, roots, |...| for abs,
// registered function names, parentheses, and an optional top-level `=`
// (everything left of the first `=` is discarded, so `$f(x) = x^2$`
// parses to the body `x^2`).

#import "ast.typ": add, call, div, func, mul, neg, num, pow, sub, sym
#import "ops.typ": operations

#let add-chars = ("+", "-", "\u{2212}")
#let mul-chars = ("\u{22C5}", "\u{00D7}", "*", "\u{2217}")
#let div-chars = ("/", "\u{2215}", "\u{2044}")

#let elem-name(c) = repr(c.func())

/// Parse a text token into a number node value.
#let parse-number(s) = {
  if s.contains(".") { decimal(s) } else { int(s) }
}

/// Is this token an operand (so adjacency means implicit multiplication)?
#let is-operand(tok) = tok.t in ("num", "sym", "func", "atom", "group")

// --- recursive-descent parser over the token list ----------------------
// Each function takes (tokens, i) and returns (node: expr, i: next index).

#let p-primary(tokens, i, ops) = {
  assert(i < tokens.len(), message: "unexpected end of math expression")
  let tok = tokens.at(i)
  if tok.t == "num" {
    (node: num(tok.v), i: i + 1)
  } else if tok.t == "sym" {
    (node: sym(tok.name), i: i + 1)
  } else if tok.t == "atom" {
    (node: tok.node, i: i + 1)
  } else if tok.t == "group" {
    assert(tok.args.len() == 1, message: "unexpected comma in a parenthesized group")
    (node: tok.args.first(), i: i + 1)
  } else if tok.t == "func" {
    // function application: name(args) or name atom
    assert(i + 1 < tokens.len(), message: "function `" + tok.name + "` is missing its argument")
    let next = tokens.at(i + 1)
    if next.t == "group" {
      (node: func(tok.name, ..next.args), i: i + 2)
    } else {
      let r = p-primary(tokens, i + 1, ops)
      (node: func(tok.name, r.node), i: r.i)
    }
  } else {
    panic("unexpected token in math expression: " + repr(tok))
  }
}

#let p-unary(tokens, i, ops) = {
  if i < tokens.len() and tokens.at(i).t == "op" and tokens.at(i).ch in add-chars {
    let ch = tokens.at(i).ch
    let r = p-unary(tokens, i + 1, ops)
    if ch == "+" { r } else { (node: neg(r.node), i: r.i) }
  } else {
    p-primary(tokens, i, ops)
  }
}

#let p-product(tokens, i, ops) = {
  let r = p-unary(tokens, i, ops)
  let node = r.node
  let i = r.i
  while i < tokens.len() {
    let tok = tokens.at(i)
    if tok.t == "op" and tok.ch in mul-chars {
      let rhs = p-unary(tokens, i + 1, ops)
      node = mul(node, rhs.node)
      i = rhs.i
    } else if tok.t == "op" and tok.ch in div-chars {
      let rhs = p-unary(tokens, i + 1, ops)
      node = div(node, rhs.node)
      i = rhs.i
    } else if is-operand(tok) {
      // implicit multiplication by juxtaposition: 2x, 2 sin(x)
      let rhs = p-unary(tokens, i, ops)
      node = mul(node, rhs.node)
      i = rhs.i
    } else {
      break
    }
  }
  (node: node, i: i)
}

#let p-sum(tokens, i, ops) = {
  let r = p-product(tokens, i, ops)
  let node = r.node
  let i = r.i
  while i < tokens.len() and tokens.at(i).t == "op" and tokens.at(i).ch in add-chars {
    let ch = tokens.at(i).ch
    let rhs = p-product(tokens, i + 1, ops)
    node = if ch == "+" { add(node, rhs.node) } else { sub(node, rhs.node) }
    i = rhs.i
  }
  (node: node, i: i)
}

/// Parse a full token list into a single expression.
#let parse-tokens(tokens, ops) = {
  // drop everything left of a top-level `=`
  let eq = tokens.position(t => t.t == "op" and t.ch == "=")
  let tokens = if eq != none { tokens.slice(eq + 1) } else { tokens }
  assert(tokens.len() > 0, message: "empty math expression")
  let r = p-sum(tokens, 0, ops)
  if r.i != tokens.len() {
    panic("could not parse the math expression past token " + repr(tokens.at(r.i)))
  }
  r.node
}

// --- tokenizer ----------------------------------------------------------
// `recurse(content)` parses nested content through the full pipeline.

#let tokenize(c, ops, recurse) = {
  let name = elem-name(c)
  if name == "equation" {
    tokenize(c.body, ops, recurse)
  } else if name == "sequence" {
    c.children.map(ch => tokenize(ch, ops, recurse)).flatten()
  } else if name == "space" or name == "h" or name == "linebreak" {
    ()
  } else if name == "symbol" {
    let ch = c.text
    if ch in add-chars or ch in mul-chars or ch in div-chars or ch in ("=", ",") {
      ((t: "op", ch: ch),)
    } else if ch in ops {
      // single-letter registered function names are rare but possible
      ((t: "func", name: ch),)
    } else {
      ((t: "sym", name: ch),)
    }
  } else if name == "text" {
    let s = c.text
    let first = s.first()
    if first in "0123456789." {
      ((t: "num", v: parse-number(s)),)
    } else if s in ops {
      ((t: "func", name: s),)
    } else {
      ((t: "sym", name: s),)
    }
  } else if name == "op" {
    ((t: "func", name: c.text.text),)
  } else if name == "frac" {
    ((t: "atom", node: div(recurse(c.num), recurse(c.denom))),)
  } else if name == "root" {
    let index = c.fields().at("index", default: none)
    let node = if index == none {
      func("sqrt", recurse(c.radicand))
    } else {
      func("root", recurse(index), recurse(c.radicand))
    }
    ((t: "atom", node: node),)
  } else if name == "attach" {
    let fields = c.fields()
    let base = recurse(c.base)
    let b = fields.at("b", default: none)
    if b != none {
      // fold a subscript into the symbol name: x_1 stays a single symbol
      assert(
        base.kind == "sym",
        message: "subscripts are only supported on plain symbols",
      )
      let sub-expr = recurse(b)
      let suffix = if sub-expr.kind == "sym" {
        sub-expr.name
      } else if sub-expr.kind == "num" {
        str(sub-expr.value)
      } else {
        panic("unsupported subscript on " + base.name)
      }
      base = sym(base.name + "_" + suffix)
    }
    let t = fields.at("t", default: none)
    let node = if t != none { pow(base, recurse(t)) } else { base }
    ((t: "atom", node: node),)
  } else if name == "lr" {
    let children = c.body.children
    let open = children.first().text
    let close = children.last().text
    let inner = children.slice(1, children.len() - 1)
    // split the inner tokens on top-level commas
    let groups = ((),)
    for tok in inner.map(ch => tokenize(ch, ops, recurse)).flatten() {
      if tok.t == "op" and tok.ch == "," {
        groups.push(())
      } else {
        groups.at(-1).push(tok)
      }
    }
    let args = groups.map(g => parse-tokens(g, ops))
    if open == "|" and close == "|" {
      assert(args.len() == 1, message: "unexpected comma inside |...|")
      ((t: "atom", node: func("abs", args.first())),)
    } else {
      ((t: "group", args: args),)
    }
  } else {
    panic("unsupported element in math expression: " + name)
  }
}

/// Parse Typst math content (an equation or its body) into an expression.
///
/// `ops` is consulted to decide whether a name is a function or a symbol,
/// so pass your extended registry here if you registered custom functions.
#let from-math(content, ops: operations) = {
  let recurse(c) = from-math(c, ops: ops)
  parse-tokens(tokenize(content, ops, recurse), ops)
}
