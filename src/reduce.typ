// Single-step reduction engine: evaluate an expression the way a person
// would on paper, one visible action per step, keeping the full chain.
//
// A step is either
//   - a substitution: one variable (or all of them) replaced by its value,
//   - an arithmetic action: the leftmost-innermost operation whose
//     arguments are all plain numbers is carried out.
//
// The trace of steps drives show-reduction, which typesets the classic
//   2x + 5 = 2·3 + 5 = 6 + 5 = 11
// chain with a short explanation next to every step.

#import "numbers.typ": is-mpq, mpq, to-exact, to-float-num
#import "ast.typ": is-num, num, sym, to-expr
#import "ops.typ": operations
#import "render.typ": render
#import "linalg.typ": expand-matrix-call, mat-map
#import "theme.typ": theme

#let strings = (
  en: (
    substitute: "substitute",
    compute: "compute",
    expand-product: "expand the product",
    expand-elementwise: "act elementwise",
    expand-scale: "scale the elements",
  ),
  ru: (
    substitute: "подставляем",
    compute: "вычисляем",
    expand-product: "раскрываем произведение",
    expand-elementwise: "действуем поэлементно",
    expand-scale: "умножаем поэлементно",
  ),
)

/// Fold literal fraction and negation nodes into plain numeric values, so
/// that `div(4, 3)` and the mpq value 4/3 — which render identically —
/// do not produce a visually empty "compute 4/3 = 4/3" step.
/// Only exact-representable literals are folded; floats are left alone.
#let fold-literals(e, mode) = {
  if e.kind == "matrix" { return mat-map(e, el => fold-literals(el, mode)) }
  if e.kind != "call" { return e }
  let args = e.args.map(a => fold-literals(a, mode))
  let exactable(a) = a.kind == "num" and type(a.value) != float
  if mode == "exact" and e.op == "div" and args.all(exactable) {
    num(mpq.div(to-exact(args.first().value), to-exact(args.last().value)))
  } else if mode == "exact" and e.op == "neg" and args.all(exactable) {
    num(mpq.neg(to-exact(args.first().value)))
  } else {
    (kind: "call", op: e.op, args: args)
  }
}

/// Find the name of the leftmost symbol that has a binding in `ctx`.
#let find-bound-var(e, ctx) = {
  if e.kind == "sym" {
    if e.name in ctx { e.name } else { none }
  } else if e.kind == "call" {
    for a in e.args {
      let found = find-bound-var(a, ctx)
      if found != none { return found }
    }
    none
  } else if e.kind == "matrix" {
    for r in e.rows {
      for el in r {
        let found = find-bound-var(el, ctx)
        if found != none { return found }
      }
    }
    none
  } else {
    none
  }
}

/// Replace every occurrence of symbol `name` with `value` (an expression).
#let substitute(e, name, value) = {
  if e.kind == "sym" and e.name == name {
    value
  } else if e.kind == "call" {
    (kind: "call", op: e.op, args: e.args.map(a => substitute(a, name, value)))
  } else if e.kind == "matrix" {
    mat-map(e, el => substitute(el, name, value))
  } else {
    e
  }
}

/// Apply one operation over plain numeric arguments.
#let apply-op(entry, args, mode) = {
  let vals = args.map(a => a.value)
  if (
    mode == "exact" and entry.eval-exact != none and vals.all(v => type(v) != float)
  ) {
    (entry.eval-exact)(..vals.map(to-exact))
  } else {
    (entry.eval-float)(..vals.map(to-float-num))
  }
}

/// Perform the leftmost-innermost arithmetic action.
/// Returns (expr, changed, done) where `done` describes the action:
/// (from, to) for a scalar computation, (action: str) for a structural
/// matrix expansion.
#let arith-step(e, mode, ops) = {
  if e.kind == "matrix" {
    // reduce the leftmost reducible element
    for (i, r) in e.rows.enumerate() {
      for (j, el) in r.enumerate() {
        let res = arith-step(el, mode, ops)
        if res.changed {
          let rows = e.rows
          rows.at(i).at(j) = res.expr
          return (expr: (kind: "matrix", rows: rows), changed: true, done: res.done)
        }
      }
    }
    return (expr: e, changed: false, done: none)
  }
  if e.kind != "call" {
    return (expr: e, changed: false, done: none)
  }
  // try to reduce an argument first (innermost)
  for (k, a) in e.args.enumerate() {
    let r = arith-step(a, mode, ops)
    if r.changed {
      let args = e.args
      args.at(k) = r.expr
      return (expr: (kind: "call", op: e.op, args: args), changed: true, done: r.done)
    }
  }
  // structural matrix expansion: product → sum-of-products elements, ...
  let ex = expand-matrix-call(e)
  if ex != none {
    return (expr: ex.expr, changed: true, done: (action: ex.action))
  }
  // all arguments are irreducible; carry the operation out if they are numbers
  if e.args.all(is-num) {
    assert(e.op in ops, message: "unknown operation: " + e.op)
    let before = e
    let value = apply-op(ops.at(e.op), e.args, mode)
    return (expr: num(value), changed: true, done: (from: before, to: num(value)))
  }
  (expr: e, changed: false, done: none)
}

/// One reduction step. Returns (expr, changed, kind, desc):
/// kind is "substitute" or "compute", desc is display-ready content.
///
/// - subst: "var" substitutes one variable per step (all its occurrences);
///   "all" plugs every bound variable in a single step.
#let reduce-step(
  expr,
  ctx: (:),
  mode: "exact",
  ops: operations,
  subst: "var",
  lang: "en",
  digits: auto,
) = {
  let e = to-expr(expr)
  let L = strings.at(lang)
  let value-of(n) = fold-literals(to-expr(ctx.at(n)), mode)
  let name = find-bound-var(e, ctx)
  if name != none {
    let names = if subst == "all" {
      let names = ()
      let n = name
      let cur = e
      while n != none {
        names.push(n)
        cur = substitute(cur, n, value-of(n))
        n = find-bound-var(cur, ctx)
      }
      names
    } else {
      (name,)
    }
    let result = e
    for n in names { result = substitute(result, n, value-of(n)) }
    let desc = names
      .map(n => $#render(sym(n), ops: ops, digits: digits) = #render(value-of(n), ops: ops, digits: digits)$)
      .join([, ])
    return (
      expr: result,
      changed: true,
      kind: "substitute",
      desc: [#L.substitute #desc],
    )
  }
  let r = arith-step(e, mode, ops)
  if r.changed {
    if "action" in r.done {
      return (expr: r.expr, changed: true, kind: "expand", desc: [#L.at(r.done.action)])
    }
    let desc = [
      #L.compute
      $#render(r.done.from, ops: ops, digits: digits) = #render(r.done.to, ops: ops, digits: digits)$
    ]
    return (expr: r.expr, changed: true, kind: "compute", desc: desc)
  }
  (expr: e, changed: false, kind: none, desc: none)
}

/// Reduce to a normal form, recording every step.
/// Returns an array of (expr, kind, desc); the original expression is not
/// included, so an already-reduced expression yields an empty trace.
#let reduce-trace(
  expr,
  ctx: (:),
  mode: "exact",
  ops: operations,
  subst: "var",
  lang: "en",
  digits: auto,
  max-steps: 400,
) = {
  let steps = ()
  // fold literal fractions/negations once, so the source form `4/3` and
  // its numeric value never produce a visually empty step
  let cur = fold-literals(to-expr(expr), mode)
  for _ in range(max-steps) {
    let r = reduce-step(cur, ctx: ctx, mode: mode, ops: ops, subst: subst, lang: lang, digits: digits)
    if not r.changed { return steps }
    // a step that does not change the rendered form (e.g. computing a
    // literal fraction node into its numeric value) is applied silently
    let visible = repr(render(cur, ops: ops, digits: digits)) != repr(render(r.expr, ops: ops, digits: digits))
    if visible {
      steps.push((expr: r.expr, kind: r.kind, desc: r.desc))
    }
    cur = r.expr
  }
  panic("reduction did not terminate after " + str(max-steps) + " steps")
}

/// Typeset the full reduction chain:
///   original
///   = step-1   (explanation)
///   = step-2   (explanation)
///
/// - explain: show per-step explanations in a second column
/// - compact: drop consecutive "compute" explanations, keeping only
///   substitutions annotated (the arithmetic speaks for itself)
#let show-reduction(
  expr,
  ctx: (:),
  mode: "exact",
  ops: operations,
  subst: "var",
  lang: "en",
  digits: auto,
  explain: true,
  compact: false,
  max-steps: 400,
) = {
  let e = fold-literals(to-expr(expr), mode)
  let steps = reduce-trace(
    e,
    ctx: ctx,
    mode: mode,
    ops: ops,
    subst: subst,
    lang: lang,
    digits: digits,
    max-steps: max-steps,
  )
  let rows = ((math.equation(render(e, ops: ops, digits: digits)), []),)
  for s in steps {
    let note = if explain and s.desc != none and not (compact and s.kind == "compute") {
      text(size: 0.8em, fill: theme.stroke-muted.darken(20%), s.desc)
    } else {
      []
    }
    rows.push((math.equation($= #render(s.expr, ops: ops, digits: digits)$.body), note))
  }
  grid(
    columns: 2,
    align: (left + horizon, left + horizon),
    column-gutter: 1.2em,
    row-gutter: 0.7em,
    ..rows.flatten(),
  )
}
