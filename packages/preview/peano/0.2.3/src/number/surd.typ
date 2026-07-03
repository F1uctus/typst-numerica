// Copyright (C) 2026 Ilya I. Nikitin <ilya.i.nikitin@proton.me>
// SPDX-License-Identifier: GPL-3.0-or-later

#import "rational.typ"
#let q = rational

#let int-sqrt(n) = {
  let s = calc.floor(calc.sqrt(n + 0.0))
  if s * s == n { s } else { none }
}

#let rat-sqrt(val) = {
  let num = q.num(q.from(val))
  let den = q.den(q.from(val))
  let sn = int-sqrt(num)
  let sd = int-sqrt(den)
  if sn != none and sd != none { q.from(sn, sd) } else { none }
}

#let rat(kind: "rat", val: none, base: none, coef: none, rad: none, card: none) = (
  kind: kind,
  val: val,
  base: base,
  coef: coef,
  rad: rad,
  card: card,
)

#let from-rat(val) = rat(kind: "rat", val: q.from(val))

#let from-sqrt(base, coef, rad) = {
  let base = q.from(base)
  let coef = q.from(coef)
  let rad = q.from(rad)
  let simplified = rat-sqrt(rad)
  if simplified != none {
    from-rat(q.add(base, q.mul(coef, simplified)))
  } else if q.num(rad) == 0 {
    from-rat(base)
  } else {
    rat(kind: "surd", base: base, coef: coef, rad: rad)
  }
}

#let from-quadratic(tr, det) = {
  let tr = q.from(tr)
  let det = q.from(det)
  let half-tr = q.div(tr, 2)
  let disc = q.sub(q.mul(tr, tr), q.mul(4, det))
  let half = q.from(1, 2)
  (
    from-sqrt(half-tr, half, disc),
    from-sqrt(half-tr, q.neg(half), disc),
  )
}

#let depressed-cubic(a, b, c) = {
  let a = q.from(a)
  let b = q.from(b)
  let c = q.from(c)
  let a3 = q.div(a, 3)
  let a2 = q.mul(a, a)
  let p = q.sub(b, q.div(a2, 3))
  let qv = q.add(
    q.sub(q.div(q.mul(2, q.mul(a, a2)), 27), q.div(q.mul(a, b), 3)),
    c,
  )
  (a3, p, qv)
}

#let from-cubic(a, b, c) = {
  let (shift, p, qv) = depressed-cubic(a, b, c)
  range(3).map(k => rat(
    kind: "cardano",
    card: (shift: shift, p: p, q: qv, k: k),
  ))
}

#let cardano-float(p, qv) = {
  let pf = q.to-float(p)
  let qf = q.to-float(qv)
  let delta = calc.pow(qf / 2, 2) + calc.pow(pf / 3, 3)
  let u = calc.pow(-qf / 2 + calc.sqrt(delta), 1 / 3.0)
  let v = calc.pow(-qf / 2 - calc.sqrt(delta), 1 / 3.0)
  (u, v, delta)
}

#let to-float(s) = {
  if s.kind == "rat" {
    q.to-float(s.val)
  } else if s.kind == "surd" {
    q.to-float(s.base) + q.to-float(s.coef) * calc.sqrt(q.to-float(s.rad))
  } else {
    let c = s.card
    let (u, v, delta) = cardano-float(c.p, c.q)
    let w-re = calc.cos(2 * calc.pi * c.k / 3)
    let w-im = calc.sin(2 * calc.pi * c.k / 3)
    let t = 2 * u * w-re
    q.to-float(c.shift) + t
  }
}

#let to-math(s) = {
  if s.kind == "rat" {
    q.to-math(s.val)
  } else if s.kind == "surd" {
    $ #q.to-math(s.base) + #q.to-math(s.coef) sqrt(#q.to-math(s.rad)) $
  } else {
    let c = s.card
    let k = c.k
    $ #q.to-math(c.shift) + omega_#k root(3, - #q.to-math(q.div(c.q, 2)) + sqrt((#q.to-math(q.div(c.q, 2)))^2 + (#q.to-math(q.div(c.p, 3)))^3)) $
  }
}
