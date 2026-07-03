// Copyright (C) 2026 Ilya I. Nikitin <ilya.i.nikitin@proton.me>
// SPDX-License-Identifier: GPL-3.0-or-later
//
/// Specialized number types.

#import "number/rational.typ"
#import "number/complex.typ"
#import "number/mp.typ"
#import "number/mat.typ": to-mat
#import "number/surd.typ": (
  from-rat,
  from-quadratic,
  from-cubic,
  to-math as surd-to-math,
  to-float as surd-to-float,
)

#let q = rational
#let c = complex
#let q-mat = to-mat
#let surd = (
  from-rat: from-rat,
  from-quadratic: from-quadratic,
  from-cubic: from-cubic,
  to-math: surd-to-math,
  to-float: surd-to-float,
)