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

<details open>
<summary><b>КР.01. Работа над ошибками. Вариант 17.</b></summary>

<picture>
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/cw01-light-page-1.svg">
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/cw01-dark-page-1.svg">
  <img alt="Page 1" src="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/cw01-light-page-1.svg">
</picture>

<picture>
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/cw01-light-page-2.svg">
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/cw01-dark-page-2.svg">
  <img alt="Page 2" src="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/cw01-light-page-2.svg">
</picture>

<picture>
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/cw01-light-page-3.svg">
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/cw01-dark-page-3.svg">
  <img alt="Page 3" src="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/cw01-light-page-3.svg">
</picture>

<picture>
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/cw01-light-page-4.svg">
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/cw01-dark-page-4.svg">
  <img alt="Page 4" src="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/cw01-light-page-4.svg">
</picture>

<picture>
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/cw01-light-page-5.svg">
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/cw01-dark-page-5.svg">
  <img alt="Page 5" src="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/cw01-light-page-5.svg">
</picture>

</details>

<details open>
<summary><b>ДЗ.01. Геометрическая интепретация метода Якоби и метода Зейделя.</b></summary>

<picture>
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw01-light-page-1.svg">
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw01-dark-page-1.svg">
  <img alt="Page 1" src="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw01-light-page-1.svg">
</picture>

<picture>
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw01-light-page-2.svg">
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw01-dark-page-2.svg">
  <img alt="Page 2" src="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw01-light-page-2.svg">
</picture>

</details>

<details open>
<summary><b>ДЗ.02. Численные методы решения нелинейных уравнений.</b></summary>

<picture>
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw02-light-page-1.svg">
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw02-dark-page-1.svg">
  <img alt="Page 1" src="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw02-light-page-1.svg">
</picture>

<picture>
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw02-light-page-2.svg">
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw02-dark-page-2.svg">
  <img alt="Page 2" src="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw02-light-page-2.svg">
</picture>

<picture>
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw02-light-page-3.svg">
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw02-dark-page-3.svg">
  <img alt="Page 3" src="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw02-light-page-3.svg">
</picture>

</details>

<details open>
<summary><b>ДЗ.03. Численные методы решения нелинейных уравнений.</b></summary>

<picture>
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw03-light-page-1.svg">
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw03-dark-page-1.svg">
  <img alt="Page 1" src="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw03-light-page-1.svg">
</picture>

</details>

<details open>
<summary><b>ДЗ.04. Численные методы решения нелинейных уравнений.</b></summary>

<picture>
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw04-light-page-1.svg">
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw04-dark-page-1.svg">
  <img alt="Page 1" src="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw04-light-page-1.svg">
</picture>

<picture>
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw04-light-page-2.svg">
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw04-dark-page-2.svg">
  <img alt="Page 2" src="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw04-light-page-2.svg">
</picture>

</details>

<details open>
<summary><b>ДЗ.05. Метод Ньютона для решения систем нелинейных уравнений.</b></summary>

<picture>
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw05-light-page-1.svg">
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw05-dark-page-1.svg">
  <img alt="Page 1" src="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw05-light-page-1.svg">
</picture>

<picture>
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw05-light-page-2.svg">
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw05-dark-page-2.svg">
  <img alt="Page 2" src="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw05-light-page-2.svg">
</picture>

</details>

<details open>
<summary><b>ДЗ.06. М. Эйлера и его модификации решения з. Коши для ОДУ 1 порядка.</b></summary>

<picture>
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw06-light-page-1.svg">
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw06-dark-page-1.svg">
  <img alt="Page 1" src="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw06-light-page-1.svg">
</picture>

<picture>
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw06-light-page-2.svg">
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw06-dark-page-2.svg">
  <img alt="Page 2" src="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw06-light-page-2.svg">
</picture>

<picture>
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw06-light-page-3.svg">
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw06-dark-page-3.svg">
  <img alt="Page 3" src="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw06-light-page-3.svg">
</picture>

<picture>
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw06-light-page-4.svg">
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw06-dark-page-4.svg">
  <img alt="Page 4" src="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw06-light-page-4.svg">
</picture>

</details>

<details open>
<summary><b>ДЗ.07. Геометрическая интерпретация метода Эйлера и его модификаций.</b></summary>

<picture>
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw07-light-page-1.svg">
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw07-dark-page-1.svg">
  <img alt="Page 1" src="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw07-light-page-1.svg">
</picture>

<picture>
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw07-light-page-2.svg">
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw07-dark-page-2.svg">
  <img alt="Page 2" src="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw07-light-page-2.svg">
</picture>

<picture>
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw07-light-page-3.svg">
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw07-dark-page-3.svg">
  <img alt="Page 3" src="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw07-light-page-3.svg">
</picture>

</details>

<details open>
<summary><b>ДЗ.08. Метод Рунге-Кутты 4 порядка точности для решения ОДУ 1 порядка.</b></summary>

<picture>
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw08-light-page-1.svg">
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw08-dark-page-1.svg">
  <img alt="Page 1" src="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw08-light-page-1.svg">
</picture>

</details>

<details open>
<summary><b>ДЗ.09. Решение разностных уравнений.</b></summary>

<picture>
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw09-light-page-1.svg">
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw09-dark-page-1.svg">
  <img alt="Page 1" src="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw09-light-page-1.svg">
</picture>

<picture>
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw09-light-page-2.svg">
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw09-dark-page-2.svg">
  <img alt="Page 2" src="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw09-light-page-2.svg">
</picture>

<picture>
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw09-light-page-3.svg">
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw09-dark-page-3.svg">
  <img alt="Page 3" src="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw09-light-page-3.svg">
</picture>

<picture>
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw09-light-page-4.svg">
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw09-dark-page-4.svg">
  <img alt="Page 4" src="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw09-light-page-4.svg">
</picture>

<picture>
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw09-light-page-5.svg">
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw09-dark-page-5.svg">
  <img alt="Page 5" src="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw09-light-page-5.svg">
</picture>

</details>

<details open>
<summary><b>ДЗ.10. Построение разностной схемы краевой задачи для ЛОДУ 2 порядка.</b></summary>

<picture>
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw10-light-page-1.svg">
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw10-dark-page-1.svg">
  <img alt="Page 1" src="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw10-light-page-1.svg">
</picture>

<picture>
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw10-light-page-2.svg">
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw10-dark-page-2.svg">
  <img alt="Page 2" src="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw10-light-page-2.svg">
</picture>

<picture>
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw10-light-page-3.svg">
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw10-dark-page-3.svg">
  <img alt="Page 3" src="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw10-light-page-3.svg">
</picture>

</details>

<details open>
<summary><b>ДЗ.11. Исследование аппроксимации и устойчивости разностных схем для ЗК.</b></summary>

<picture>
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw11-light-page-1.svg">
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw11-dark-page-1.svg">
  <img alt="Page 1" src="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw11-light-page-1.svg">
</picture>

<picture>
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw11-light-page-2.svg">
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw11-dark-page-2.svg">
  <img alt="Page 2" src="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw11-light-page-2.svg">
</picture>

</details>

<details open>
<summary><b>ДЗ.12. Построение и исследование разностных схем для ОДУ.</b></summary>

<picture>
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw12-light-page-1.svg">
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw12-dark-page-1.svg">
  <img alt="Page 1" src="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw12-light-page-1.svg">
</picture>

<picture>
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw12-light-page-2.svg">
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw12-dark-page-2.svg">
  <img alt="Page 2" src="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw12-light-page-2.svg">
</picture>

</details>

<details open>
<summary><b>ДЗ.13. Метод конечных разностей для уравнений в частных производных.</b></summary>

<picture>
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw13-light-page-1.svg">
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw13-dark-page-1.svg">
  <img alt="Page 1" src="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw13-light-page-1.svg">
</picture>

<picture>
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw13-light-page-2.svg">
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw13-dark-page-2.svg">
  <img alt="Page 2" src="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw13-light-page-2.svg">
</picture>

<picture>
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw13-light-page-3.svg">
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw13-dark-page-3.svg">
  <img alt="Page 3" src="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw13-light-page-3.svg">
</picture>

<picture>
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw13-light-page-4.svg">
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw13-dark-page-4.svg">
  <img alt="Page 4" src="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw13-light-page-4.svg">
</picture>

<picture>
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw13-light-page-5.svg">
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw13-dark-page-5.svg">
  <img alt="Page 5" src="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/hw13-light-page-5.svg">
</picture>

</details>

<details open>
<summary><b>ЛР.01.</b></summary>

<picture>
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/lab01-light-page-1.svg">
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/lab01-dark-page-1.svg">
  <img alt="Page 1" src="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/lab01-light-page-1.svg">
</picture>

<picture>
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/lab01-light-page-2.svg">
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/lab01-dark-page-2.svg">
  <img alt="Page 2" src="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/lab01-light-page-2.svg">
</picture>

<picture>
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/lab01-light-page-3.svg">
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/lab01-dark-page-3.svg">
  <img alt="Page 3" src="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/lab01-light-page-3.svg">
</picture>

</details>

<details open>
<summary><b>ЛР.02.</b></summary>

<picture>
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/lab02-light-page-1.svg">
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/lab02-dark-page-1.svg">
  <img alt="Page 1" src="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/lab02-light-page-1.svg">
</picture>

</details>

<details open>
<summary><b>ЛР.03.</b></summary>

<picture>
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/lab03-light-page-1.svg">
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/lab03-dark-page-1.svg">
  <img alt="Page 1" src="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/lab03-light-page-1.svg">
</picture>

<picture>
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/lab03-light-page-2.svg">
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/lab03-dark-page-2.svg">
  <img alt="Page 2" src="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/lab03-light-page-2.svg">
</picture>

<picture>
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/lab03-light-page-3.svg">
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/lab03-dark-page-3.svg">
  <img alt="Page 3" src="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/lab03-light-page-3.svg">
</picture>

<picture>
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/lab03-light-page-4.svg">
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/lab03-dark-page-4.svg">
  <img alt="Page 4" src="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/lab03-light-page-4.svg">
</picture>

<picture>
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/lab03-light-page-5.svg">
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/lab03-dark-page-5.svg">
  <img alt="Page 5" src="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/lab03-light-page-5.svg">
</picture>

</details>

<details open>
<summary><b>ЛР.04.</b></summary>

<picture>
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/lab04-light-page-1.svg">
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/lab04-dark-page-1.svg">
  <img alt="Page 1" src="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/lab04-light-page-1.svg">
</picture>

<picture>
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/lab04-light-page-2.svg">
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/lab04-dark-page-2.svg">
  <img alt="Page 2" src="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/lab04-light-page-2.svg">
</picture>

</details>

<details open>
<summary><b>ЛР.05.</b></summary>

<picture>
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/lab05-light-page-1.svg">
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/lab05-dark-page-1.svg">
  <img alt="Page 1" src="https://raw.githubusercontent.com/F1uctus/typst-numerica/previews/lab05-light-page-1.svg">
</picture>

</details>

<!-- preview:end -->
