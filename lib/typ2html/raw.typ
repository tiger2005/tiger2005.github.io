#import "html-guard.typ": html-guard

#let template-raw(content) = {
  show raw.where(block: true): it => {
    html-guard(() => {
      let fields = it.fields()
      html.pre(
        html.code(
          class: {
            if fields.lang == none { "language-text" }
            else { "language-" + fields.lang }
          },
          fields.text
        )
      )
    }, fallback: () => it)
  }

  show raw.where(block: false): it => {
    html-guard(() => {
      let fields = it.fields()
      html.code(
        class: {
          if fields.lang == none { "language-text" }
          else { "language-" + fields.lang }
        },
        fields.text
      )
    }, fallback: () => it)
  }
  content
}