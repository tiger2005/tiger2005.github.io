#import "../../config.typ": *
#let posts = query-posts()

#let tags = (:)
#let categories = (:)

#for post in posts [
  #for tag in post.tags [
    #tags.insert(tag, true)
  ]

  #if post.category != "" [
    #categories.insert(post.category, true)
  ]
]

#show: template-page.with(
  title: "关于",
  description: "关于页面",
)

#render-page-breadcrumb(items: (("/", "首页"),))

= 关于

这是 Typst Blog 的基础信息页。

- 文章数量：#posts.len()
- 标签数量：#tags.keys().len()
- 分类数量：#categories.keys().len()

许可与版权说明：

本模板在视觉与实现上参考了以下公开项目与资源：

- Carbon Design System（界面设计系统）
- IBM Plex Mono（字体）
- IBM Plex Sans SC（字体）
- #link("https://github.com/Yousa-Mirage/Tufted-Blog-Template")[Tufted Blog Template]

相关名称、设计系统与字体的版权归其各自权利人所有；
本项目仅在其许可条款允许范围内进行参考与使用。