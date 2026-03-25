#import "../../config.typ": *
#let posts = query-posts()

#let posts-by-year = (:)
#let years = ()
#for post in posts [
  #let date-parts = post.date.split("-")
  #let year = date-parts.at(0, default: "未知")
  #if not years.contains(year) [
    #years.push(year)
  ]
  #let year-posts = posts-by-year.at(year, default: ())
  #year-posts.push(post)
  #posts-by-year.insert(year, year-posts)
]

#show: template-page.with(
  title: "更新",
  description: "更新页面",
)

#render-page-breadcrumb(items: (("/", "首页"),))

= #{html.div(class: "title-with-icon", {
  html.div(
    class: "tag-title-icon",
    style: "--tag-background:var(--tag-background-gray);--tag-color:var(--tag-color-gray);",
    {
      html.span(style: "mask-image:url(\"/assets/icons/box.svg\");")
    },
  )
  html.div("文章归档")
})}

#if posts.len() == 0 {
  html.div(class: "error-block", {
    "暂无文章"
  })
} else {
  html.div(class: "archive-list", {
    for year-index in range(years.len() - 1, -1, step: -1) {
      let year = years.at(year-index)
      let year-posts = posts-by-year.at(year, default: ())

      html.elem("section", attrs: (class: "archive-year-group",), {
        html.div(class: "archive-year-heading", {
          html.span(class: "archive-year-label", year)
          html.span(class: "archive-year-count", str(year-posts.len()) + " 篇")
        })

        html.div(class: "archive-year-list", {
          for post-index in range(year-posts.len() - 1, -1, step: -1) {
            let post = year-posts.at(post-index)
            let date-parts = post.date.split("-")
            let short-date = if date-parts.len() == 3 {
              date-parts.at(1) + "-" + date-parts.at(2)
            } else {
              post.date
            }

            html.elem("article", attrs: (class: "archive-entry",), {
              html.div(class: "archive-entry-date", {
                short-date
              })
              html.div(class: "archive-entry-main", {
                html.a(class: "archive-entry-link", href: post.url, post.title)
              })
            })
          }
        })
      })
    }
  })
}