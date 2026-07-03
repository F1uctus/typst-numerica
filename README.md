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

> Note: PDFs are available in the [latest workflow run](https://github.com/F1uctus/typst-numerica/actions/runs/28634244493)

### worksheets

<details open>
<summary><b>worksheets/cw01.typ</b></summary>

![Preview](https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/worksheets_cw01-preview.svg)

> [Download PDF](worksheets/cw01.pdf)
</details>

<details open>
<summary><b>worksheets/hw01.typ</b></summary>

![Preview](https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/worksheets_hw01-preview.svg)

> [Download PDF](worksheets/hw01.pdf)
</details>

<details open>
<summary><b>worksheets/hw02.typ</b></summary>

![Preview](https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/worksheets_hw02-preview.svg)

> [Download PDF](worksheets/hw02.pdf)
</details>

<details open>
<summary><b>worksheets/hw03.typ</b></summary>

![Preview](https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/worksheets_hw03-preview.svg)

> [Download PDF](worksheets/hw03.pdf)
</details>

<details open>
<summary><b>worksheets/hw04.typ</b></summary>

![Preview](https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/worksheets_hw04-preview.svg)

> [Download PDF](worksheets/hw04.pdf)
</details>

<details open>
<summary><b>worksheets/hw05.typ</b></summary>

![Preview](https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/worksheets_hw05-preview.svg)

> [Download PDF](worksheets/hw05.pdf)
</details>

<details open>
<summary><b>worksheets/hw06.typ</b></summary>

![Preview](https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/worksheets_hw06-preview.svg)

> [Download PDF](worksheets/hw06.pdf)
</details>

<details open>
<summary><b>worksheets/hw07.typ</b></summary>

![Preview](https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/worksheets_hw07-preview.svg)

> [Download PDF](worksheets/hw07.pdf)
</details>

<details open>
<summary><b>worksheets/hw08.typ</b></summary>

![Preview](https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/worksheets_hw08-preview.svg)

> [Download PDF](worksheets/hw08.pdf)
</details>

<details open>
<summary><b>worksheets/hw09.typ</b></summary>

![Preview](https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/worksheets_hw09-preview.svg)

> [Download PDF](worksheets/hw09.pdf)
</details>

<details open>
<summary><b>worksheets/hw10.typ</b></summary>

![Preview](https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/worksheets_hw10-preview.svg)

> [Download PDF](worksheets/hw10.pdf)
</details>

<details open>
<summary><b>worksheets/hw11.typ</b></summary>

![Preview](https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/worksheets_hw11-preview.svg)

> [Download PDF](worksheets/hw11.pdf)
</details>

<details open>
<summary><b>worksheets/hw12.typ</b></summary>

![Preview](https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/worksheets_hw12-preview.svg)

> [Download PDF](worksheets/hw12.pdf)
</details>

<details open>
<summary><b>worksheets/hw13.typ</b></summary>

![Preview](https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/worksheets_hw13-preview.svg)

> [Download PDF](worksheets/hw13.pdf)
</details>

### worksheets/lab

<details open>
<summary><b>worksheets/lab/lab01.typ</b></summary>

![Preview](https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/worksheets_lab_lab01-preview.svg)

> [Download PDF](worksheets/lab/lab01.pdf)
</details>

<details open>
<summary><b>worksheets/lab/lab02.typ</b></summary>

![Preview](https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/worksheets_lab_lab02-preview.svg)

> [Download PDF](worksheets/lab/lab02.pdf)
</details>

<details open>
<summary><b>worksheets/lab/lab03.typ</b></summary>

![Preview](https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/worksheets_lab_lab03-preview.svg)

> [Download PDF](worksheets/lab/lab03.pdf)
</details>

<details open>
<summary><b>worksheets/lab/lab04.typ</b></summary>

![Preview](https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/worksheets_lab_lab04-preview.svg)

> [Download PDF](worksheets/lab/lab04.pdf)
</details>

<details open>
<summary><b>worksheets/lab/lab05.typ</b></summary>

![Preview](https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/worksheets_lab_lab05-preview.svg)

> [Download PDF](worksheets/lab/lab05.pdf)
</details>

