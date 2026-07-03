// Copyright (C) 2026 Ilya I. Nikitin <ilya.i.nikitin@proton.me>
// SPDX-License-Identifier: GPL-3.0-or-later
//
// -> func/special.typ
/// Special mathematic functions.

#import "init.typ": (
  define-func-with-complex,
  define-func-2-with-complex,
  define-func-2,
)
#import "../init.typ": real-funcs, convert-wasm-func

#let real-unary(name) = {
  let f = real-funcs.at(name)
  x => f(x)
}

/// The #link("https://en.wikipedia.org/wiki/Gamma_function")[$Gamma$ function],
/// defined by $Gamma(z) = integral_0^oo t^(z - 1) upright(e)^(-t) dif t$.
#let /*pub*/ gamma = define-func-with-complex("gamma")

/// The #link("https://en.wikipedia.org/wiki/Digamma_function")[digamma function],
/// which is the derivative of the logarithm of $Gamma$ function
/// $psi(z) = dif/(dif z) ln Gamma(z) = (Gamma'(z))/(Gamma(z))$.
#let /*pub*/ digamma = define-func-with-complex("digamma")

/// same as `digamma`
#let /*pub*/ psi = digamma

/// The #link("https://en.wikipedia.org/wiki/Error_function")[Gauss error function],
/// defined by $erf z = 2/sqrt(pi) integral_0^z e^(-t^2) dif t$
#let /*pub*/ erf = define-func-with-complex("erf")

/// Complementary error function $erfc(z) = 1 - erf(z)$.
#let /*pub*/ erfc = real-unary("erfc")

/// Imaginary error function $erfi(z)$.
#let /*pub*/ erfi = real-unary("erfi")

/// #link("https://en.wikipedia.org/wiki/Riemann_zeta_function")[Riemann's $zeta$ function]
/// defined by $zeta(s) = sum_(n = 1)^oo 1/(n^s)$ for $Re s > 1$ and its analytic continuation otherwise.
#let /*pub*/ zeta = define-func-with-complex("zeta")

/// The #link("https://en.wikipedia.org/wiki/Beta_function")[$Beta$ function],
/// defined by $Beta(z_1, z_2) = integral_0^1 t^(z_1 - 1) (1 - t)^(z_2 - 1) dif t$.
/// Equals to $(Gamma(z_1) Gamma(z_2))/(Gamma(z_1 + z_2))$
#let /*pub*/ beta = define-func-2-with-complex("beta")

/// Natural logarithm of the absolute value of the gamma function.
#let /*pub*/ gammaln = real-unary("gammaln")

/// Regularized lower incomplete gamma function $P(a, x) = gamma(a, x) / Gamma(a)$.
#let /*pub*/ gammainc = define-func-2("gammainc")

#let /*pub*/ airy-ai = define-func-with-complex("airy_ai")
#let /*pub*/ airy-bi = define-func-with-complex("airy_bi")
#let /*pub*/ lambert-w(x) = (real-funcs.lambert_w)(x)

// Euler's $gamma$ constant. Equals to $lim_(n -> oo) ((sum_(k = 1)^(n) 1/n) - ln n)$
#let /*pub*/ euler-gamma = -digamma(1)

#let /*pub*/ bessel-j(n, x) = {
  (real-funcs.bessel_jn)(n, x)
}

#let /*pub*/ bessel-y(n, x) = {
  (real-funcs.bessel_yn)(n, x)
}

/// Bessel function of the first kind, order 0.
#let /*pub*/ bessel-j0 = real-unary("bessel_j0")

/// Bessel function of the first kind, order 1.
#let /*pub*/ bessel-j1 = real-unary("bessel_j1")

/// Modified Bessel function of the first kind, order 0.
#let /*pub*/ bessel-i0 = real-unary("bessel_i0")

/// Modified Bessel function of the first kind, order 1.
#let /*pub*/ bessel-i1 = real-unary("bessel_i1")

/// Modified Bessel function of the second kind, order 0.
#let /*pub*/ bessel-k0 = real-unary("bessel_k0")

/// Modified Bessel function of the second kind, order 1.
#let /*pub*/ bessel-k1 = real-unary("bessel_k1")

// Fresnel integrals

/// Fresnel sine integral $S(x)$.
#let /*pub*/ fresnel-s = real-unary("fresnel_s")

/// Fresnel cosine integral $C(x)$.
#let /*pub*/ fresnel-c = real-unary("fresnel_c")

/// Both Fresnel integrals as `(s: S(x), c: C(x))`.
#let /*pub*/ fresnel(x) = (s: fresnel-s(x), c: fresnel-c(x))

// Elliptic integrals and Jacobi elliptic functions

/// Complete elliptic integral of the first kind $K(m)$.
#let /*pub*/ elliptic-k = real-unary("elliptic_k")

/// Complete elliptic integral of the second kind $E(m)$.
#let /*pub*/ elliptic-e = real-unary("elliptic_e")

/// Incomplete elliptic integral of the first kind $F(phi, m)$.
#let /*pub*/ elliptic-f = define-func-2("elliptic_f")

/// Incomplete elliptic integral of the second kind $E(phi, m)$.
#let /*pub*/ elliptic-e-inc = define-func-2("elliptic_e_inc")

/// Jacobi elliptic function $sn(u, m)$.
#let /*pub*/ jacobi-sn = define-func-2("jacobi_sn")

/// Jacobi elliptic function $cn(u, m)$.
#let /*pub*/ jacobi-cn = define-func-2("jacobi_cn")

/// Jacobi elliptic function $dn(u, m)$.
#let /*pub*/ jacobi-dn = define-func-2("jacobi_dn")

/// All three Jacobi elliptic functions as `(sn: ..., cn: ..., dn: ...)`.
#let /*pub*/ elliptic-j(u, m) = (
  sn: jacobi-sn(u, m),
  cn: jacobi-cn(u, m),
  dn: jacobi-dn(u, m),
)

// Kelvin functions

/// Kelvin function $ber(x)$.
#let /*pub*/ kelvin-ber = real-unary("kelvin_ber")

/// Kelvin function $bei(x)$.
#let /*pub*/ kelvin-bei = real-unary("kelvin_bei")

/// Kelvin function $ker(x)$.
#let /*pub*/ kelvin-ker = real-unary("kelvin_ker")

/// Kelvin function $kei(x)$.
#let /*pub*/ kelvin-kei = real-unary("kelvin_kei")

// Hypergeometric functions

/// Gaussian hypergeometric function $_2F_1(a, b; c; z)$.
#let /*pub*/ hyp-2f1(a, b, c, z) = {
  (convert-wasm-func("hyp2f1", (float, float, float, float), float))(a, b, c, z)
}

/// Confluent hypergeometric function $_1F_1(a; b; z)$.
#let /*pub*/ hyp-1f1(a, b, z) = {
  (convert-wasm-func("hyp1f1", (float, float, float), float))(a, b, z)
}

/// Confluent hypergeometric limit function $_0F_1(a; z)$.
#let /*pub*/ hyp-0f1(a, z) = {
  (convert-wasm-func("hyp0f1", (float, float), float))(a, z)
}
