// Тема берётся из того же имени, по которому браузер выбирает <source>:
// typst-readme-preview передаёт `--input prefers-color-scheme=<значение>`.
#let preview-theme = sys.inputs.at("prefers-color-scheme", default: "light")

#let theme = (
  text: black,
  bg: white,
  stroke: black,
  stroke-muted: gray,
  plot-stroke: gray,
)
#if preview-theme == "dark" {
  theme.text = rgb("#ecd1d7")
  theme.bg = rgb("#18130b")
  theme.stroke = rgb("#abb2bf")
  theme.stroke-muted = rgb("#5c6370")
  theme.plot-stroke = rgb("#5c6370")
}

#let themed-legend = (
  stroke: none,
  fill: theme.bg,
)

#let themed-axes = (
  stroke: (paint: theme.plot-stroke, dash: "dotted"),
  tick: (stroke: theme.plot-stroke + .5pt),
)

#let themed-axes-grid = (
  stroke: (paint: theme.plot-stroke, dash: "solid", thickness: 0.15mm),
  tick: (stroke: theme.plot-stroke + .5pt),
  grid: (
    stroke: (paint: theme.stroke-muted.darken(30%), thickness: 0.25pt),
  ),
  minor-grid: (
    stroke: (paint: theme.stroke-muted.darken(40%), thickness: 0.15pt),
  ),
)

#let themed-plot-base = (
  stroke: (paint: theme.stroke, thickness: 0.5pt),
)

#let themed-line-solid = (stroke: (paint: theme.stroke, thickness: 0.5pt))
#let themed-line-dashed = (stroke: (paint: theme.stroke, thickness: 0.5pt, dash: "dashed"))
#let themed-line-dotted = (stroke: (paint: theme.stroke, thickness: 0.5pt, dash: "dotted"))

#let themed-stroke(dash) = if dash == "solid" {
  themed-line-solid
} else if dash == "dashed" {
  themed-line-dashed
} else if dash == "dotted" {
  themed-line-dotted
} else {
  (stroke: (dash: dash))
}

#let themed-showybox-frame = (
  inset: 4pt,
  thickness: 0.1pt,
  border-color: theme.stroke-muted,
  body-color: theme.bg,
)

#let themed-showybox-body = (
  color: theme.text,
)
