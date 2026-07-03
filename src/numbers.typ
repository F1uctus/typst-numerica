// Number-domain helpers bridging Typst's int/float/decimal and peano's
// arbitrary-precision rationals (mpq). The exact evaluation domain is mpq;
// the approximate domain is float.

#import "@preview/peano:0.2.3": number
#let mpq = number.mp.mpq
#let mpz = number.mp.mpz

#let is-mpq(v) = type(v) == dictionary and mpq.is_(v)
#let is-plain-number(v) = type(v) in (int, float, decimal)
#let is-number(v) = is-plain-number(v) or is-mpq(v)

/// Convert a decimal (or a decimal string like "-1.25") to an exact mpq.
#let decimal-str-to-mpq(s) = {
  let parts = s.split(".")
  if parts.len() == 1 {
    mpq.from(s)
  } else {
    let (int-part, frac-part) = parts
    let den = "1" + "0" * frac-part.len()
    let sign = if int-part.starts-with("-") { "-" } else { "" }
    let int-digits = int-part.trim("-", at: start)
    mpq.from(sign + int-digits + frac-part + "/" + den)
  }
}

/// Coerce a value into the exact (mpq) domain.
/// Floats are rejected: they carry no exact meaning.
#let to-exact(v) = {
  if is-mpq(v) {
    v
  } else if type(v) == int {
    mpq.from(v)
  } else if type(v) == decimal {
    decimal-str-to-mpq(str(v))
  } else if type(v) == str {
    mpq.from(v)
  } else if type(v) == float {
    panic("cannot use a float in exact mode; pass an int, decimal or rational instead: " + repr(v))
  } else {
    panic("not a number: " + repr(v))
  }
}

/// Split a leading sign off a peano number string. peano prints the
/// typographic minus U+2212, so accept both it and the ASCII hyphen.
#let split-sign(s) = {
  if s.starts-with("-") {
    (negative: true, digits: s.slice(1))
  } else if s.starts-with("\u{2212}") {
    (negative: true, digits: s.slice("\u{2212}".len()))
  } else {
    (negative: false, digits: s)
  }
}

/// Approximate an arbitrarily large mp integer as a float.
#let mpz-to-float(z) = {
  let (negative, digits) = split-sign(mpz.to-str(z))
  let head = digits.slice(0, calc.min(17, digits.len()))
  let v = float(head) * calc.pow(10.0, digits.len() - head.len())
  if negative { -v } else { v }
}

/// Approximate an mpq as a float. Works via the exponent difference of
/// the numerator and denominator, so it survives fractions whose parts
/// individually overflow a float (hundreds of digits) as long as the
/// ratio itself is representable.
#let mpq-to-float(x) = {
  let c = mpq.cmp(x, mpq.from(0))
  if c == 0 { return 0.0 }
  let ax = mpq.abs(x)
  let ns = mpz.to-str(mpq.num(ax))
  let ds = mpz.to-str(mpq.den(ax))
  let head(s) = float(s.slice(0, calc.min(17, s.len())))
  let scale(s) = s.len() - calc.min(17, s.len())
  let v = head(ns) / head(ds) * calc.pow(10.0, scale(ns) - scale(ds))
  if c < 0 { -v } else { v }
}

/// Coerce a value into the float domain.
#let to-float-num(v) = {
  if type(v) in (int, float, decimal) {
    float(v)
  } else if is-mpq(v) {
    mpq-to-float(v)
  } else {
    panic("not a number: " + repr(v))
  }
}

/// Exact decimal expansion of an mpq, truncated to `digits` fractional
/// digits (round-half-up on the last digit). Returns a string.
/// Unlike float conversion this is exact at any magnitude, which matters
/// when counting correct significant digits of an approximation.
#let mpq-to-decimal-str(x, digits: 20) = {
  let sign = if mpq.cmp(x, mpq.from(0)) < 0 { "-" } else { "" }
  let ax = mpq.abs(x)
  // floor(|x| * 10^digits + 1/2) gives half-up rounding of the last digit;
  // mpq.floor returns an mp integer directly
  let scale = mpq.from("1" + "0" * digits)
  let scaled = mpq.floor(mpq.add(mpq.mul(ax, scale), mpq.from("1/2")))
  let s = mpz.to-str(scaled)
  if s.len() <= digits { s = "0" * (digits - s.len() + 1) + s }
  let int-part = s.slice(0, s.len() - digits)
  let frac-part = s.slice(s.len() - digits)
  if digits == 0 { sign + int-part } else { sign + int-part + "." + frac-part }
}

/// Round any supported number for display purposes.
/// Exact values stay exact only in the string sense; use for output only.
#let round-num(v, digits: 3) = {
  if is-mpq(v) {
    float(mpq-to-decimal-str(v, digits: digits))
  } else if type(v) == decimal {
    calc.round(v, digits: digits)
  } else {
    calc.round(float(v), digits: digits)
  }
}
