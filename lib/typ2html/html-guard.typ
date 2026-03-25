#let wants-html() = {
  "target" in dictionary(std) and target() == "html"
}

#let html-guard(render, fallback: () => {}) = context {
  if wants-html() {
    render()
  } else {
    fallback()
  }
}
