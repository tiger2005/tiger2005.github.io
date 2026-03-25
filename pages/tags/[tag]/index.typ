#import "../../../config.typ": * 
#let posts = query-posts()
#let current = query-route-tag()
#let route-page = query-route-page()
#let route-page-size = query-route-page-size(default: 10)

#show: template-page.with(
  title: if current == "" { "标签详情" } else { "标签：" + current },
  description: "标签详情页面",
)

#render-page-breadcrumb(
  items: (("/", "首页"), ("/tags/", "标签")),
)

= #current

#let matched = posts.filter(post => post.tags.any(tag => tag == current))
#let bounds = query-page-bounds(matched.len(), page: route-page, page-size: route-page-size)
#let current-page = int(bounds.at("page", default: 1))
#let total-pages = int(bounds.at("total-pages", default: 1))
#let start-index = int(bounds.at("start-index", default: 0))
#let end-index = int(bounds.at("end-index", default: -1))

#if matched.len() == 0 {
  html.div(class: "error-block", {
    "暂无文章"
  })
} else {
  html.div(class: "posts-grid", {
    for i in range(end-index, start-index - 1, step: -1) {
      let post = matched.at(i)
      let date-parts = post.date.split("-")
      let post-date-text = if date-parts.len() == 3 {
        format-post-date(datetime(
          year: int(date-parts.at(0)),
          month: int(date-parts.at(1)),
          day: int(date-parts.at(2)),
        ))
      } else {
        post.date
      }
      html.elem("div", attrs: (
        class: "post-card",
        "data-post-url": post.url,
      ), {
        html.div(class: "post-title", {
          html.a(class: "post-card-link", href: post.url, post.title)
        })
        html.div(class: "post-description", {
          post.description
        })
        if post.tags.len() != 0 {
          html.div(class: "post-card-tags", {
            for tag in post.tags {
              render-tag-link(tag, href: "/tags/" + query-tag-slug-of(tag) + "/")
            }
          })
        }
        html.div(class: "post-date", {
          post-date-text
        })
      })
    }
  })

  render-pagination-nav(
    "/tags/" + query-tag-slug-of(current) + "/",
    current-page,
    total-pages,
    aria-label: "标签分页",
  )
}