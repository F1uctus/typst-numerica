#import "@preview/cetz:0.3.4"
#import "@preview/cetz-plot:0.1.1": plot, chart
#import "@preview/diverential:0.2.0": *
#import "@preview/numty:0.0.5" as nt


#let SURNAME_NAME = "Никитин Илья"
#let UNN_GROUP = "3822Б1МА1"
#let n = 21


#set page(
  paper: "a4",
  margin: (top: 3em, bottom: 1cm, rest: 0.5cm),
  numbering: "1 / 1",
  header: [
    ДЗ.05. Метод Ньютона для решения систем нелинейных уравнений.
    #h(1fr)
    #eval(mode: "math", "n = " + str(n))
    #h(1fr)
    #SURNAME_NAME, #UNN_GROUP
  ],
)
#show heading: it => grid(
  columns: (1fr, auto, 1fr),
  align: horizon + center,
  column-gutter: 5pt,
  line(length: 100%),
  it.body,
  line(length: 100%),
)
#set table(
  align: horizon + center,
  stroke: gray + 0.2mm,
)
#set par(justify: true)

#show table.cell.where(x: 0): strong

#let PRECISION = 5
#let kth(x, ..k) = $#x^lr(paren.l #if k.pos().len() > 0 {k.pos().join(",")} else {$k$} paren.r)$
#let raw-vec(x) = eval(mode: "math", "vec(" + x.flatten().map(a => calc.round(a, digits: PRECISION)).map(str).join(",") + ")")
#let round(x) = str(if type(x) == float { calc.round(x, digits: 3) } else { x })
#let tick-fmt(v) = { set text(size: 9pt); v }
#let ol(x) = $overline(#x)$
#let jac-eval(J, x, dim: 2) = J.flatten().map(f => f(x)).chunks(dim)
#let evalm(f) = eval(mode: "math", f)
#let INDENT_ITER_EQ = 4em


Решить системы уравнений с заданным начальным приближением.


//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
#{
  let f1-formula = "x - " + str(n)
  let f1(x, y) = eval(f1-formula.replace("x", str(x)).replace("y", str(y)))
  let f2-formula = "x + 2 * " + str(n) + " * y - 1"
  let f2(x, y) = eval(f2-formula.replace("x", str(x)).replace("y", str(y)))
  let x = ((3, 3),)

  [=== Задание 1]
  
  $ cases(
      x = #n comma,
      #(2*n) y + x = 1 comma
    )
  quad kth(ol(x), 0) = #raw-vec(x.at(0))
  ==> cases(
    f_1(x, y) = x - #n = 0 comma,
    f_2(x, y) = x + #(2*n) y - 1 = 0 comma
  )
  quad ol(x) := vec(x, y),
  quad ol(F)(ol(x)) := vec(f_1(x, y), f_2(x, y)) = 0. $
  
  let Fx0 = (f1(..x.at(0)), f2(..x.at(0)))
  $ ol(F)(kth(ol(x)))
  := vec(f_1(kth(x), kth(y)), f_2(kth(x), kth(y)))
  ==> ol(F)(kth(ol(x), 0))
  = vec(f_1(kth(x, 0), kth(y, 0)), f_2(kth(x, 0), kth(y, 0)))
  = vec(
      #evalm(f1-formula.replace("x", str(x.at(0).at(0)))),
      #evalm(f2-formula.replace("x", str(x.at(0).at(0))).replace("y", str(x.at(0).at(1))))
    )
  = #raw-vec(Fx0). $
  
  let j = ((1, 0), (1, 42))
  let jdet = nt.det(j)
  $ J(ol(x)) = mat(
    dvpc(f_1(x, y), x), dvpc(f_1(x, y), y);
    dvpc(f_2(x, y), x), dvpc(f_2(x, y), y);
  )
  eq.triple mat(..#j) - "не зависит от" ol(x), 
  quad det(J) = jdet != 0
  thick => thick exists J^(-1). $
  
  let jadj = ((42,0), (-1,1))
  let Jinv = $1/#jdet mat(42, 0; -1, 1)$
  let jinv = nt.mult(1/jdet, jadj)
  $ J^(-1)(ol(x)) = 1 / det(J) mat(a_22, -a_12; -a_21, a_11)
  = Jinv. $
  
  let jadjFx0 = nt.matmul(jadj, nt.c(..Fx0)).flatten()
  x.push(nt.mult(1/jdet, nt.sub(nt.mult(jdet, x.at(0)), jadjFx0)))

  let y = "-10 / 21"
  [Применим формулу метода Ньютона для системы уравнений:]
  $quad kth(ol(x), k+1) = kth(ol(x)) - J^(-1)(kth(ol(x))) ol(F)(kth(ol(x))) : $

  block(inset: (left: INDENT_ITER_EQ))[
    $ vec(kth(x, 1), kth(y, 1))
    = #raw-vec(x.at(0)) - Jinv #raw-vec(Fx0)
    = #raw-vec(x.at(0)) - 1/#jdet #raw-vec(jadjFx0)
    = 1/#jdet #raw-vec(nt.sub(nt.mult(jdet, x.at(0)), jadjFx0))
    = vec(21, #evalm(y)), $
  ]
  
  block(inset: (left: INDENT_ITER_EQ))[
    $ ol(F)(kth(ol(x), 1))
    = vec(f_1(kth(x, 1), kth(y, 1)), f_2(kth(x, 1), kth(y, 1)))
    = vec(
        #evalm(f1-formula.replace("x", str(x.at(1).at(0)))),
        #evalm(f2-formula.replace("x", str(x.at(1).at(0))).replace("y", y))
      )
    = vec(#str(f1(..x.at(1))), #str(f2(..x.at(1)))). $
  ]
 
  assert.eq(x.at(1).at(0), 21)
  assert.eq(x.at(1).at(1), eval(y))

  [
    #set enum(numbering: it => strong[Ответ:])
    + Точное решение системы: $x = #x.at(1).at(0), y = -10 slash 21. $
  ]
}

//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
#{
  let f1-formula = "x - " + str(n)
  let f1(x, y) = eval(f1-formula.replace("x", str(x)).replace("y", str(y)))
  let f2-formula = "x*x + 2 * " + str(n) + " * y - 1"
  let f2(x, y) = eval(f2-formula.replace("x", str(x)).replace("y", str(y)))
  let x = ((3, 3),)

  [=== Задание 2]
  
  $ cases(
      x = #n comma,
      #(2*n) y + x^2 = 1 comma
    )
  quad kth(ol(x), 0) = #raw-vec(x.at(0))
  quad ==> quad cases(
    f_1(x, y) = x - #n = 0 comma,
    f_2(x, y) = x^2 + #(2*n) y - 1 = 0.
  ) $

  let jdet = 42
  let Fx = (f1(..x.at(0)), f2(..x.at(0)))
  $ ol(F)(kth(ol(x), 0))
  = vec(f_1(kth(x, 0), kth(y, 0)), f_2(kth(x, 0), kth(y, 0)))
  = vec(
      #evalm(f1-formula.replace("x", str(x.at(0).at(0)))),
      #evalm(f2-formula.replace("x", str(x.at(0).at(0))).replace("y", str(x.at(0).at(1))))
    )
  = #raw-vec(Fx). $
  
  $ J(ol(x)) = mat(
    dvpc(f_1(x, y), x), dvpc(f_1(x, y), y);
    dvpc(f_2(x, y), x), dvpc(f_2(x, y), y);
  )
  = mat(1, 0; 2x, 42), 
  quad det(J) = jdet != 0
  thick => thick exists J^(-1). $

  let jadj = ((x => 42, x => 0), (x => -2 * x.at(0), x => 1))
  $ J^(-1)(ol(x)) = 1 / det(J) mat(a_22, -a_12; -a_21, a_11)
  = 1/#jdet mat(42, 0; -2x, 1). $

  [Применим формулу метода Ньютона для системы уравнений:]
  $quad kth(ol(x), k+1) = kth(ol(x)) - J^(-1)(kth(ol(x))) ol(F)(kth(ol(x))) : $

  let y-exact = ("3", "-58 / 21", "-220 / 21")
  let k = 1
  while Fx != (0, 0) {
    let jadjx = jac-eval(jadj, x.at(k - 1))
    let jadjFx = nt.matmul(jadjx, nt.c(..Fx)).flatten()
    x.push(nt.mult(1/jdet, nt.sub(nt.mult(jdet, x.at(k - 1)), jadjFx)))

    block(inset: (left: INDENT_ITER_EQ))[
      $ vec(kth(x, #k), kth(y, #k))
      = vec(#str(x.at(k - 1).at(0)), #evalm(y-exact.at(k - 1))) - 1/#jdet mat(..#jadjx) #raw-vec(Fx)
      = vec(#str(x.at(k - 1).at(0)), #evalm(y-exact.at(k - 1))) - 1/#jdet #raw-vec(jadjFx)
      = 1/#jdet #raw-vec(nt.sub(nt.mult(jdet, x.at(k - 1)), jadjFx))
      = vec(#str(x.at(k).at(0)), #evalm(y-exact.at(k))), $
    ]

    block(inset: (left: INDENT_ITER_EQ))[
      $ ol(F)(kth(ol(x), #k))
      = vec(f_1(kth(x, #k), kth(y, #k)), f_2(kth(x, #k), kth(y, #k)))
      = vec(
          #evalm(f1-formula.replace("x", str(x.at(k).at(0)))),
          #evalm(f2-formula.replace("x", str(x.at(k).at(0))).replace("y", y-exact.at(k)))
        )
      = vec(#str(f1(..x.at(k))), #str(f2(..x.at(k)))). $
    ]

    assert.eq(x.at(k).at(0), 21)
    assert.eq(x.at(k).at(1), eval(y-exact.at(k)))

    k += 1
    Fx = (f1(..x.at(-1)), f2(..x.at(-1)))
  }

  [
    #set enum(numbering: it => strong[Ответ:])
    + Точное решение системы: $x = #x.at(-1).at(0), y = #evalm(y-exact.at(-1)). $
  ]
}


//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
#pagebreak()
#{
  let f1-formula(x: "x", y: "y", fmt: str) = fmt(x) + " - " + fmt(n) + " * " + fmt(y)
  let f1(x, y) = eval(f1-formula(x: x, y: y))
  let f2-formula(x: "x", y: "y", fmt: str) = fmt(x) + "*" + fmt(x) + " + 2 * " + fmt(n) + " * " + fmt(y) + " - 1"
  let f2(x, y) = eval(f2-formula(x: x, y: y))
  let x = ((1, 1),)

  [=== Задание 3]
  
  $ cases(
      x = #n y,
      #(2*n) y + x^2 = 1
    ),
  quad x^"(0)" = #raw-vec(x.at(0)),
  quad ==> quad cases(
    f_1(x, y) = x - #n y = 0 comma,
    f_2(x, y) = x^2 + #(2*n) y - 1 = 0.
  ) $

  let jdet-f(x: "x", fmt: str) = "42 * (" + fmt(x) + " + 1)"
  let jdet(p, fmt) = eval(jdet-f(x: p.at(0), fmt: fmt))
  let Fx = (f1(..x.at(0)), f2(..x.at(0)))
  $ ol(F)(kth(ol(x), 0))
  = vec(f_1(kth(x, 0), kth(y, 0)), f_2(kth(x, 0), kth(y, 0)))
  = vec(
      #evalm(f1-formula(x: x.at(0).at(0), y: x.at(0).at(1))),
      #evalm(f2-formula(x: x.at(0).at(0), y: x.at(0).at(1)))
    )
  = #raw-vec(Fx). $
  
  $ J(ol(x)) = mat(
    dvpc(f_1(x, y), x), dvpc(f_1(x, y), y);
    dvpc(f_2(x, y), x), dvpc(f_2(x, y), y);
  )
  = mat(1, -21; 2x, 42), 
  quad det(J) = #evalm(jdet-f()) != 0
  thick => thick exists J^(-1). $

  let jadj = ((x => 42, x => 21), (x => -2 * x.at(0), x => 1))
  $ J^(-1)(ol(x)) = 1 / det(J) mat(a_22, -a_12; -a_21, a_11)
  = 1/#evalm(jdet-f()) mat(42, 21; -2x, 1). $

  [Применим формулу метода Ньютона для системы уравнений:]
  $quad kth(ol(x), k+1) = kth(ol(x)) - J^(-1)(kth(ol(x))) ol(F)(kth(ol(x))) : $

  let k = 1
  while k < 2 or x.at(-2).map(x => calc.round(x, digits: PRECISION)) != x.at(-1).map(x => calc.round(x, digits: PRECISION)) {
    let jadjx = jac-eval(jadj, x.at(k - 1))
    let jadjFx = nt.matmul(jadjx, nt.c(..Fx)).flatten()
    x.push(nt.mult(1/jdet(x.at(k - 1), str), nt.sub(nt.mult(jdet(x.at(k - 1), str), x.at(k - 1)), jadjFx)))

    show math.equation: set text(size: 0.92em)

    block[
      $ vec(kth(x, #k), kth(y, #k))
      approx #raw-vec(x.at(k - 1)) - 1/#jdet(x.at(k - 1), round) mat(..#jadjx.flatten().map(round).chunks(2)) #raw-vec(Fx)
      approx #raw-vec(x.at(k - 1)) - 1/#jdet(x.at(k - 1), round) #raw-vec(jadjFx)
      approx 1/#jdet(x.at(k - 1), round) #raw-vec(nt.sub(nt.mult(jdet(x.at(k - 1), round), x.at(k - 1)), jadjFx))
      approx #raw-vec(x.at(k).map(x => calc.round(x, digits: PRECISION)).map(float)), $
    ]

    block[
      $ ol(F)(kth(ol(x), #k))
      approx vec(
          #evalm(f1-formula(x: x.at(k).at(0), y: x.at(k).at(1), fmt: round)),
          #evalm(f2-formula(x: x.at(k).at(0), y: x.at(k).at(1), fmt: round))
        )
      approx vec(#str(f1(..x.at(k))), #str(f2(..x.at(k)))). $
    ]

    k += 1
    Fx = (f1(..x.at(-1)), f2(..x.at(-1)))
  }

  [
    Получили $kth(x, #(x.len() - 2)) = kth(x, #(x.len() - 1)) $.

    #show math.equation: set text(size: 0.832757em)
    #set enum(numbering: it => strong[Ответ:])
    + Для системы получена последовательность приближений: \ \
      #for (k, v) in x.enumerate() {
        $display(vec(
          kth(x, #k) #if str(v.at(0)).len() > 15 {$approx$} else {$=$} #calc.round(v.at(0), digits: PRECISION),
          kth(y, #k) #if str(v.at(0)).len() > 15 {$approx$} else {$=$} #calc.round(v.at(1), digits: PRECISION)
        )) #if k + 1 == x.len() {"."} else {","} quad$
      }
  ]
}