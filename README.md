# numerica

A homoiconic expression core + numerical-methods library in Typst:
one expression tree is evaluated (exactly over ℚ via a vendored
[peano](https://github.com/F1uctus/peano_typ) fork, or in floats),
rendered as math, reduced step by step with explanations, and
differentiated symbolically. Worksheets below state a problem as
data and generate the full worked solution.

```typst
#import "../src/lib.typ": *
#let f = from-math($f(x) = x^3 - 3 x^2 + 6 x - 5$)
#show-reduction(f, ctx: (x: 3), lang: "ru")   // full chain to f(3) = 13
#let df = d(f, "x")                           // 3x² − 6x + 6
#newton-history(f, 1, iterations: 5)          // exact ℚ iterations
```

Build: `typst compile worksheets/hw01.typ --root . --package-path packages`

## Worksheets

PDFs are attached to the
[latest workflow run](https://github.com/F1uctus/typst-numerica/actions/workflows/render.yml).
Each worksheet carries its title in a `<preview-title>` label; the pages below
are rendered by
[typst-readme-preview](https://github.com/F1uctus/typst-readme-preview) and
follow the GitHub theme.

<!-- preview:begin -->
<!-- preview:end -->
