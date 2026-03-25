#import "html-guard.typ": html-guard

#let render-page-breadcrumb(items: ()) = {
  html-guard(() => {
    html.elem("nav", attrs: (
      class: "page-breadcrumb page-breadcrumb-md",
      "aria-label": "Breadcrumb",
    ), {
      html.ol(class: "page-breadcrumb-list", {
        for i in range(items.len()) {
          let item = items.at(i)
          let href = str(item.at(0))
          let label = str(item.at(1))

          html.li(class: "page-breadcrumb-item", {
            html.a(class: "page-breadcrumb-link", href: href, label)
          })

          html.li(class: "page-breadcrumb-separator", "/")
        }
      })
    })
  })
}
