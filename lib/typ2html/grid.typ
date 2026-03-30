#import "html-guard.typ": html-guard

#let template-grids(content) = {
  show grid: it => html-guard(() => {
    let columns = if type(it.columns) == int {
      it.columns
    } else if type(it.columns) == array {
      it.columns.len()
    } else {
      1
    }

    html.elem(
      "div",
      attrs: (
        class: "html-auto-grid",
        style: "grid-template-columns: repeat(" + str(columns) + ", 1fr)",
      )
    )[
      #for elem in it.children {
        elem
      }
    ]
  }, fallback: () => it)

  show grid.cell: it => html-guard(() => {
    html.elem(
      "div",
      attrs: (
        class: "html-auto-grid-cell"
      )
    )[
      #it.body
    ]
  }, fallback: () => it)
  
  content
}
