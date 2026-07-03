// numerica — homoiconic expression core + numerical methods.
//
// An expression is a tree of plain Typst dictionaries. The same tree can be:
//   evaluate()     — computed (exactly via peano ℚ, or approximately via calc),
//   render()       — rendered as math content,
//   reduce-trace() — reduced one step at a time, with explanations,
//   d()            — differentiated symbolically.

#import "ast.typ": *
#import "ops.typ": operations, register-op
#import "eval.typ": evaluate
#import "render.typ": render, render-num, render-sym
#import "parse.typ": from-math
#import "reduce.typ": reduce-step, reduce-trace, show-reduction, substitute
#import "diff.typ": d, simplify
#import "linalg.typ": is-matrix, is-matrix-value, mat-of, vec-of, mat-map, matrix-value
#import "methods/roots.typ": (
  newton-history,
  show-newton-iterations,
  fourier-condition,
  newton-error,
  render-q,
  render-sci,
  iter-sym,
)
#import "methods/iteration.typ": (
  iteration-history,
  fixed-point-form,
  show-fixed-point-system,
  convergence-criterion,
  show-iteration-table,
  show-iteration-plot,
  system-lines,
)
#import "numbers.typ": (
  mpq,
  mpz,
  is-mpq,
  to-exact,
  to-float-num,
  mpq-to-float,
  mpq-to-decimal-str,
  round-num,
)
