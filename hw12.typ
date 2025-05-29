#import "@preview/cetz:0.3.4"
#import "@preview/cetz-plot:0.1.1": plot, chart
#import "@preview/physica:0.9.5": *
#import "@preview/showybox:2.0.4": showybox
#import "@preview/fletcher:0.5.7": diagram, node, edge


#let SURNAME_NAME = "Никитин Илья"
#let UNN_GROUP = "3822Б1МА1"
#let n = 21


#set page(
  paper: "a4",
  margin: (top: 3em, rest: 0.8cm),
  numbering: "1 / 1",
  header: [
    ДЗ.12. Построение и исследование разностных схем для ОДУ.
    #h(1fr)
    #eval(mode: "math", "n = " + repr(n))
    #h(1fr)
    #SURNAME_NAME, #UNN_GROUP
  ],
)
#let double-line = [
  #block(spacing: 0pt, line(length: 100%))
  #v(2.5pt)
  #block(spacing: 0pt, line(length: 100%))
]
#show heading: it => grid(
  columns: (1fr, auto, 1fr),
  align: horizon + center,
  column-gutter: 5pt,
  double-line, it.body, double-line,
)
#set par(justify: true, first-line-indent: 2em)
#set math.cases(gap: 8pt)
#let cases(..children) = math.cases(..children.pos().map(math.display))
#let hl(eqtn) = rect(
  stroke: gray,
  inset: (top: 10pt, bottom: 10pt, left: 5pt, right: 5pt),
  $display(eqtn.body)$,
)

#let double-line = [
  #block(spacing: 0pt, line(length: 100%))
  #v(2.5pt)
  #block(spacing: 0pt, line(length: 100%))
]


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

=== Задание 1

Для уравнения $y' = f(x, y)$ построить разностную схему
$
  (y_k - y_(k - 2)) / (2 h) = a_1 f_k + a_0 f_(k - 1) + a_(-1) f_(k - 2)
$
с наивысшим порядком аппроксимации на решении. Определить этот порядок.

*Решение.*

Разложим в ряд Тейлора $y_(k - 2)$ вокруг точки $x_k$:
$
  y_(k - 2) = y_k - 2h y'_k + (4h^2) / 2 y''_k - (8h^3) / 6 y'''_k + (16h^4) / 24 y''''_k + O(h^5),
$

Тогда левая часть:
$
  (y_k - y_(k - 2)) / (2 h)
  = 1 / (2h) (y_k - y_k + 2h y'_k - 2h^2 y''_k + (4h^3) / 3 y'''_k - (2h^4) / 3 y''''_k + O(h^5))
  = y'_k - h y''_k + (2h^2) / 3 y'''_k - h^3 / 3 y''''_k + O(h^4).
$

Теперь разложим правую часть:
$
  f_k = y'_k,
  quad
  f_(k-1) = y'_(k-1) = y'_k - h y''_k + h^2 / 2 y'''_k - h^3 / 6 y''''_k + O(h^4),
  quad
  f_(k-2) = y'_(k-2) = y'_k - 2h y''_k + 2h^2 y'''_k - (4h^3) / 3 y''''_k + O(h^4).
$

Подставим в правую часть:
$
  a_1 y'_k + a_0 (y'_k - h y''_k + h^2 / 2 y'''_k - h^3 / 6 y''''_k)
  + a_(-1) (y'_k - 2h y''_k + 2h^2 y'''_k - (4h^3) / 3 y''''_k) + O(h^4)
  = \ =
  (a_1 + a_0 + a_(-1)) y'_k + (-a_0 - 2a_(-1)) h y''_k + (a_0 / 2 + 2a_(-1)) h^2 y'''_k
  + (-a_0 / 6 - 4a_(-1) / 3) h^3 y''''_k + O(h^4).
$

Приравнивая коэффициенты при одинаковых производных в левой и правой частях, получаем систему:

$
  cases(
    a_1 + a_0 + a_(-1) = 1 &quad "(коэффициент при " y'_k ")",
    -a_0 - 2a_(-1) = -1 &quad "(коэффициент при " h y''_k ")",
    a_0/2 + 2a_(-1) = 2/3 &quad "(коэффициент при " h^2 y'''_k ")",
  )
$

Из второго уравнения: $a_0 = 1 - 2a_(-1)$.

Подставляем в третье:
$
  (1 - 2a_(-1)) / 2 + 2a_(-1) = 2 / 3 quad => quad 1 / 2 - a_(-1) + 2a_(-1) = 2 / 3 quad => quad a_(-1) = 2 / 3 - 1 / 2 = 1 / 6.
$

Тогда:
$a_0 = 1 - 2 dot 1/6 = 1 - 1/3 = 2/3$.
$a_1 = 1 - a_0 - a_(-1) = 1 - 2/3 - 1/6 = 1/6$.

Проверим коэффициент при $h^3 y''''_k$:
$
  -a_0 / 6 - 4a_(-1) / 3 = -(2 / 3) / 6 - 4(1 / 6) / 3 = -1 / 9 - 2 / 9 = -1 / 3.
$

Это совпадает с коэффициентом в левой части, следовательно, схема имеет четвертый порядок аппроксимации.

#enum(
  numbering: it => [*Ответ:*],
  [
    Получена разностная схема четвертого порядка аппроксимации:
    $
      (y_k - y_(k - 2)) / (2 h) = 1 / 6 f_k + 2 / 3 f_(k - 1) + 1 / 6 f_(k - 2).
    $
  ],
)


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

#pagebreak(weak: true)
=== Задание 2

Исследовать устойчивость разностной схемы при $theta in [0, 1]$. Использовать условие корней для однородного разностного уравнения:
$
  theta (y_(k+1) - y_k) / h + (1 - theta) (y_k - y_(k - 1)) / h = f_k.
$

*Решение.*

Рассмотрим однородное уравнение:
$
  theta (y_(k+1) - y_k) / h + (1 - theta) (y_k - y_(k - 1)) / h = 0.
$

Умножим на $h$:
$
  theta (y_(k+1) - y_k) + (1 - theta) (y_k - y_(k - 1))
  = theta y_(k+1) + (1 - 2theta) y_k - (1 - theta) y_(k - 1) = 0.
$

Характеристическое уравнение получаем подстановкой $y_k = r^k$:
$
  theta r^(k+1) + (1 - 2theta) r^k - (1 - theta) r^(k-1) = 0.
$

Сократим на $r^(k-1)$ (при $r != 0$):
$
  theta r^2 + (1 - 2theta) r - (1 - theta) = 0.
$
$
  D = (1 - 2theta)^2 + 4 theta (1 - theta)
  = 1 - 4theta + 4theta^2 + 4theta - 4theta^2
  = 1
  quad ==> quad
  r_(1,2) = (-(1 - 2theta) plus.minus 1) / (2 theta)
  = (2theta - 1 plus.minus 1) / (2 theta),
  \
  r_1 = (2theta - 1 + 1) / (2 theta) = 1,
  quad
  r_2 = (2theta - 1 - 1) / (2 theta)
  = (theta - 1) / theta = 1 - 1 / theta.
$

Условие устойчивости: $|r_i| <= 1$ для всех корней.

Для $r_1 = 1$ условие выполнено.

Для $r_2 = 1 - 1/theta$ требуется:
$
  |1 - 1 / theta| <= 1.
$

При $theta > 0$:
- Если $theta < 1$, то $1/theta > 1$, следовательно $1 - 1/theta < 0$.
- Если $theta = 1$, то $1 - 1/theta = 0$.

Рассмотрим неравенство
$|1 - 1 / theta| <= 1
  quad ==> quad -1 <= 1 - 1 / theta <= 1,
  quad ==> quad -1 / theta <= 0 - "тождественно истинно, и "
  theta >= 1 / 2.$

При $theta < 1/2$ имеем $|r_2| = |1 - 1/theta| > 1$, схема неустойчива.

#enum(
  numbering: it => [*Ответ:*],
  [
    Разностная схема устойчива при $theta in [1/2, 1]$ и неустойчива при $theta in [0, 1/2)$.
  ],
)
