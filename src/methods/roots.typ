// Newton's method for f(x) = 0, worked the way it is written by hand:
// derivatives are taken symbolically from the same expression tree, the
// iterations run in exact rational arithmetic (the fractions can grow
// arbitrarily large), and every display is generated from the data.

#import "@preview/cetz:0.3.4"
#import "@preview/cetz-plot:0.1.1": plot

#import "../numbers.typ": is-mpq, mpq, mpz, mpq-to-decimal-str, round-num, to-exact, to-float-num
#import "../ast.typ": div, num, sub, sym, to-expr
#import "../ops.typ": operations
#import "../eval.typ": evaluate
#import "../render.typ": render, render-num
#import "../diff.typ": d
#import "../theme.typ": theme, themed-axes, themed-axes-grid, themed-stroke

// --- iteration ----------------------------------------------------------------

/// Newton iterations x_{k+1} = x_k − f(x_k)/f'(x_k), exact by default.
/// Returns (history: (x0, x1, ...), df: expr). Pass `df` to reuse an
/// already-computed derivative expression.
#let newton-history(
  f,
  x0,
  iterations: 5,
  var: "x",
  mode: "exact",
  ops: operations,
  df: auto,
) = {
  let f = to-expr(f)
  let df = if df == auto { d(f, var, ops: ops) } else { df }
  let at(e, v) = {
    let ctx = (:)
    ctx.insert(var, num(v))
    evaluate(e, ctx: ctx, mode: mode, ops: ops)
  }
  let cur = evaluate(to-expr(x0), mode: mode, ops: ops)
  let history = (cur,)
  for _ in range(iterations) {
    let f-v = at(f, cur)
    let df-v = at(df, cur)
    cur = evaluate(sub(num(cur), div(num(f-v), num(df-v))), mode: mode, ops: ops)
    history.push(cur)
  }
  (history: history, df: df)
}

// --- display helpers -----------------------------------------------------------

/// Group the digits of an integer string by threes: "1234567" → "1 234 567".
#let group-digits(s) = {
  let out = ""
  for (i, ch) in s.clusters().enumerate() {
    if i > 0 and calc.rem(s.len() - i, 3) == 0 { out += " " }
    out += ch
  }
  out
}

/// Render an exact rational with digit grouping in the numerator and the
/// denominator. The fraction is forced to display style so it stays
/// readable when nested inside another fraction.
#let render-q(v, group: true) = {
  let v = to-exact(v)
  let negative = mpq.cmp(v, mpq.from(0)) < 0
  let a = mpq.abs(v)
  let n = mpz.to-str(mpq.num(a))
  let dd = mpz.to-str(mpq.den(a))
  let fmt(s) = if group { group-digits(s) } else { s }
  let body = if dd == "1" {
    $#fmt(n)$.body
  } else {
    math.display(math.frac($#fmt(n)$.body, $#fmt(dd)$.body))
  }
  if negative { $-#body$.body } else { body }
}

/// x with an upright parenthesized superscript: x^(3).
#let iter-sym(var, k) = math.attach(eval(var, mode: "math"), t: [(#str(k))])

/// A float in scientific notation as math content: 2.11·10⁻³⁹.
#let render-sci(v, digits: 3) = {
  if v == 0 { return $0$.body }
  let e = calc.floor(calc.log(calc.abs(v), base: 10))
  let mant = calc.round(v / calc.pow(10.0, e), digits: digits)
  $#str(mant) dot 10^#str(e)$.body
}

/// The worked Newton chain, one iteration per display equation:
///   x^(k) = x^(k−1) − f(x^(k−1))/f'(x^(k−1)) = … = … ≈ …
/// From `split-from` on, an iteration is typeset as three lines (scheme,
/// substitution, result) so the exact fractions keep a readable size; an
/// exact result whose numerator or denominator exceeds `result-digits`
/// digits is elided in favor of the decimal approximation alone.
#let show-newton-iterations(
  f,
  history,
  var: "x",
  df: auto,
  mode: "exact",
  ops: operations,
  approx-digits: 5,
  split-from: 5,
  result-digits: 40,
  sizes: (1em, 1em, 1em, 0.9em, 0.9em),
) = {
  let f = to-expr(f)
  let df = if df == auto { d(f, var, ops: ops) } else { df }
  let at(e, v) = {
    let ctx = (:)
    ctx.insert(var, num(v))
    evaluate(e, ctx: ctx, mode: mode, ops: ops)
  }
  let digit-count(v) = {
    let a = mpq.abs(to-exact(v))
    calc.max(mpz.to-str(mpq.num(a)).len(), mpz.to-str(mpq.den(a)).len())
  }
  for k in range(1, history.len()) {
    let x-prev = history.at(k - 1)
    let x-next = history.at(k)
    let f-v = at(f, x-prev)
    let df-v = at(df, x-prev)
    let size = sizes.at(calc.min(k - 1, sizes.len() - 1))
    let scheme = $#iter-sym(var, k) = #iter-sym(var, k - 1) - frac(f(#iter-sym(var, k - 1)), f'(#iter-sym(var, k - 1)))$
    let substituted = $#render-q(x-prev) - frac(#render-q(f-v), #render-q(df-v))$
    let approx = $approx #str(round-num(x-next, digits: approx-digits))$
    let outcome = if digit-count(x-next) <= result-digits {
      $= #render-q(x-next) #approx.body$
    } else {
      approx
    }
    set text(size: size)
    if k < split-from {
      $ #scheme.body = #substituted.body #outcome.body thick, $
    } else {
      $ #scheme.body = $
      $ = #substituted.body $
      $ #outcome.body thick, $
    }
  }
}

// --- Fourier (convergence) condition ---------------------------------------------

/// Check the Fourier condition for Newton's method on [a, b]:
/// f(a)·f(b) < 0 and f', f'' of constant sign (sampled at the interval ends).
/// Returns (ok, x0, df, d2f, content) where x0 is the recommended starting
/// point (the end where f and f'' agree in sign) and content is the classic
/// table: a plot of f, f', f'' next to the three conditions.
#let fourier-condition(
  f,
  a,
  b,
  var: "x",
  ops: operations,
  digits: 5,
  plot-size: (8, 3),
  x-tick-step: auto,
  y-tick-step: auto,
  tick-size: 9pt,
) = {
  let f = to-expr(f)
  let df = d(f, var, ops: ops)
  let d2f = d(df, var, ops: ops)
  let at(e, v) = {
    let ctx = (:)
    ctx.insert(var, v)
    evaluate(e, ctx: ctx, mode: "float", ops: ops)
  }
  let (fa, fb) = (at(f, a), at(f, b))
  let (dfa, dfb) = (at(df, a), at(df, b))
  let (d2fa, d2fb) = (at(d2f, a), at(d2f, b))
  let root-separated = fa * fb < 0
  let df-const = dfa * dfb > 0
  // non-strict: a zero of f'' at an isolated interval end is tolerated
  let d2f-const = d2fa * d2fb > 0 or (d2fa * d2fb == 0 and (d2fa != 0 or d2fb != 0))
  let ok = root-separated and df-const and d2f-const
  let d2f-sign = if d2fa != 0 { d2fa } else { d2fb }
  let x0 = if fa * d2f-sign > 0 { a } else { b }
  let fmt(v) = str(round-num(v, digits: digits))
  let rel(v) = if v > 0 { $> 0$ } else if v < 0 { $< 0$ } else { [] }
  let tick-fmt(v) = {
    set text(size: tick-size)
    v
  }
  let fplot = cetz.canvas({
    import plot: *
    cetz.draw.set-style(
      axes: themed-axes-grid,
    )
    plot(
      name: "p",
      size: plot-size,
      x-grid: true,
      x-label: eval(var, mode: "math"),
      x-tick-step: x-tick-step,
      y-grid: true,
      y-label: none,
      y-tick-step: y-tick-step,
      x-format: tick-fmt,
      y-format: tick-fmt,
      {
        add(v => at(f, v), domain: (a, b), style: themed-stroke("solid"))
        add-anchor("f0", (b, fb))
        add(v => at(df, v), domain: (a, b), style: themed-stroke("dashed"))
        add-anchor("f1", (a, dfa))
        add(v => at(d2f, v), domain: (a, b), style: themed-stroke("dotted"))
        add-anchor("f2", (a, d2fa))
      },
    )
    cetz.draw.content("p.f0", $f(#eval(var, mode: "math"))$, anchor: "west", padding: 0.15)
    cetz.draw.content("p.f1", $f'(#eval(var, mode: "math"))$, anchor: "east", padding: 0.5)
    cetz.draw.content("p.f2", $f''(#eval(var, mode: "math"))$, anchor: "east", padding: 0.5)
  })
  let content = table(
    columns: (6fr, 2fr, 3fr),
    align: horizon + center,
    stroke: theme.stroke-muted + 0.2mm,
    table.cell(rowspan: 3, inset: (right: 15pt), fplot),
    $ f(#a) f(#b) < 0 $,
    $
      f(#a) &= #fmt(fa) #rel(fa), \
      f(#b) &= #fmt(fb) #rel(fb).
    $,
    $ limits("sign")_[#a,#b] f' eq.triple "const" $,
    $
      min f' = f'(#a) &= #fmt(dfa) #rel(dfa), \
      max f' = f'(#b) &= #fmt(dfb) #rel(dfb).
    $,
    $ limits("sign")_[#a,#b] f'' eq.triple "const" $,
    $
      min f'' = f''(#a) &= #fmt(d2fa) #rel(d2fa), \
      max f'' = f''(#b) &= #fmt(d2fb) #rel(d2fb).
    $,
  )
  (ok: ok, x0: x0, df: df, d2f: d2f, content: content)
}

// --- error estimate ----------------------------------------------------------------

/// A-posteriori error bound for Newton's method:
///   Δx_n ≤ M/(2m)·|x_n − x_(n−1)|²,
/// with m = min|f'| and M = max|f''| taken at the ends of [a, b].
/// `reference` is an exact (mpq) value of the root used to count correct
/// significant digits — by default it is produced by simply running more
/// Newton iterations (quadratic convergence makes it far more accurate
/// than x_n itself).
#let newton-error(
  f,
  a,
  b,
  history,
  var: "x",
  mode: "exact",
  ops: operations,
  reference: auto,
  extra-iterations: 3,
  max-digits: 30,
) = {
  let f = to-expr(f)
  let df = d(f, var, ops: ops)
  let d2f = d(df, var, ops: ops)
  let at(e, v) = {
    let ctx = (:)
    ctx.insert(var, v)
    evaluate(e, ctx: ctx, mode: "float", ops: ops)
  }
  let m = calc.min(calc.abs(at(df, a)), calc.abs(at(df, b)))
  let em = calc.max(calc.abs(at(d2f, a)), calc.abs(at(d2f, b)))
  let x-n = history.last()
  let x-p = history.at(-2)
  let step = calc.abs(to-float-num(x-n) - to-float-num(x-p))
  // exact |x_n − x_{n−1}|² to avoid float underflow on tiny steps
  let step-sq = if is-mpq(x-n) and is-mpq(x-p) {
    let diff = mpq.sub(x-n, x-p)
    to-float-num(mpq.mul(diff, diff))
  } else {
    step * step
  }
  let delta = em / (2 * m) * step-sq
  let reference = if reference == auto {
    newton-history(f, num(x-n), iterations: extra-iterations, var: var, mode: mode, ops: ops).history.last()
  } else {
    reference
  }
  // count correct fractional digits: largest d where the rounded decimal
  // expansions agree
  let digits = 0
  if is-mpq(x-n) and is-mpq(reference) {
    let k = max-digits
    while k >= 0 {
      if mpq-to-decimal-str(x-n, digits: k) == mpq-to-decimal-str(reference, digits: k) {
        digits = k
        break
      }
      k -= 1
    }
  }
  (m: m, em: em, delta: delta, reference: reference, digits: digits)
}
