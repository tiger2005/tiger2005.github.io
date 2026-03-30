#import "html-guard.typ": html-guard

#let template-math(content) = {
  show math.equation.where(block: false): it => {
    html-guard(() => html.span(role: "math", {
      show math.equation: set text(16pt)
      html.frame(it)
    }), fallback: () => it)
  }

  show math.equation.where(block: true): it => {
    html-guard(() => html.figure(role: "math", {
      show math.equation: set text(16pt)
      html.frame(it)
    }), fallback: () => it)
  }

  content
}

#let auto-frame(disable-filter: false, content) = html-guard(
  () => html.div(class: "auto-frame " + if disable-filter { "disable-filter" } else { "" }, {
    html.frame(content)
  }),
  fallback: () => content
)
