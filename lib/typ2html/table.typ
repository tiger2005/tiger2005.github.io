#import "html-guard.typ": html-guard

#let template-table(content) = {
  show table: it => html-guard(() => {
    html.div(class: "table-scroll", {
      it
    })
  }, fallback: () => it)

  content
}