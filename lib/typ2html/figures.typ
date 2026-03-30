#import "html-guard.typ": html-guard

#let template-figures(content) = {
  show figure: it => html-guard(() => {
    html.figure(
      class: "html-auto-figure",
      {
        it.body
        it.caption
      }
    )
  }, fallback: () => it)

  content
}