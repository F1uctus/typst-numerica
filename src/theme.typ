#let preview-args = json(bytes(sys.inputs.at("x-preview", default: "{}")))
#let preview-theme = preview-args.at("theme", default: "light")

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
