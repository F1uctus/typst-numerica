
#let SURNAME_NAME = "Никитин Илья"
#let UNN_GROUP = "3822Б1МА1"
#let n = 21

#set page(
  paper: "a4",
  margin: (top: 3em, rest: 1cm),
  numbering: "1 / 1",
  header: [
    ЛР.05. Метод стрельбы.
    #h(1fr)
    #eval(mode: "math", "n = " + repr(n))
    #h(1fr)
    #SURNAME_NAME, #UNN_GROUP
  ]
)

$
\  y'' - y' = 1,
\  y(-1) = e - 1,
\  y(0) = 0
$

Аналитическое решение:
$
\  y = e^(-x) - 1
$


