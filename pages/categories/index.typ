#import "../../config.typ": *
#let posts = query-posts()
#let slugs = query-slugs()
#let category-slugs = slugs.at("categories", default: (:))
#let category-slug-of(value) = str(category-slugs.at(value, default: value))

#let category-counts = (:)
#for post in posts [
  #if post.category != "" [
    #let current = category-counts.at(post.category, default: 0)
    #category-counts.insert(post.category, current + 1)
  ]
]

#let all-categories = category-counts.keys().sorted()

#show: template-page.with(
  title: "分类",
  description: "分类页面",
)

#render-page-breadcrumb(items: (("/", "首页"),))

= 所有分类

#if all-categories.len() == 0 [
  #html.div(class: "error-block", {
    "暂无分类"
  })
] else [
  #html.div(class: "category-list", {
    for category in all-categories {
      let count = category-counts.at(category, default: 0)

      html.a(class: "category-list-item", href: "/categories/" + category-slug-of(category) + "/", {
        html.div(class: "category-tree-row", {
          html.div(class: "category-tree-left", {
            html.span(class: "category-tree-icon")
            html.span(class: "category-list-name", category)
          })
          html.div(class: "category-list-meta", {
            html.span(str(count) + " 篇")
          })
        })
      })
    }
  })
]