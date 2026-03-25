#import "../../config.typ": *
#let posts = query-posts()

#let tag-counts = (:)
#for post in posts [
  #for tag in post.tags [
    #let current = tag-counts.at(tag, default: 0)
    #tag-counts.insert(tag, current + 1)
  ]
]

#let all-tags = tag-counts.keys().sorted()
#let sorted-tags = all-tags.sorted(key: tag => (-tag-counts.at(tag, default: 0), tag))

#show: template-page.with(
  title: "标签",
  description: "标签页面",
)

#render-page-breadcrumb(items: (("/", "首页"),))

= 所有标签

#if all-tags.len() == 0 [
  #html.div(class: "error-block", {
    "暂无标签"
  })
] else [
  #html.div(class: "tag-cards-grid", {
    for tag in sorted-tags {
      let count = tag-counts.at(tag, default: 0)
      render-tag-card(tag, count, href: "/tags/" + query-tag-slug-of(tag) + "/")
    }
  })
]