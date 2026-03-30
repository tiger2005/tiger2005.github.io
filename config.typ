#import "lib/typ2html/typ2html.typ" : *

#let footer-content = [
  2026 \~ Present    Carbon Typst Blog
]

#let tag-options = (
  "矩阵链乘积问题": ("preset": "blue", "icon": "/assets/icons/data-bin.svg"),
  "图论": ("preset": "cyan", "icon": "/assets/icons/concept.svg"),
  "数据结构": ("preset": "teal", "icon": "/assets/icons/parent-child.svg"),
  "数论": ("preset": "purple", "icon": "/assets/icons/calculation.svg"),
  "动态规划": ("preset": "magenta", "icon": "/assets/icons/app-connectivity.svg"),
  "线性代数": ("preset": "red", "icon": "/assets/icons/matrix.svg"),
  "模拟费用流": ("preset": "cyan", "icon": "/assets/icons/flow--modeler--reference.svg"),
)

#let render-tag-link = render-tag-link.with(tag-options: tag-options)
#let render-tag-card = render-tag-card.with(tag-options: tag-options)

#let templates = make-templates(
  site-title: "tiger2005 的随笔",
  header-links: (
    "/": "首页",
    "/categories/": "分类",
    "/tags/": "标签",
    "/archive/": "归档",
    "/about/": "关于",
  ),
  title: "Typst Blog",
  lang: "zh",
  footer-content: footer-content,
  tag-options: tag-options,
  custom-css: (
    "/assets/custom.css",
  ),
  custom-script: (
    
  )
)

#let template-page = templates.page
#let template-post(..args) = {
  set page(height: auto, width: 30cm)
  set text(16pt, font: ("IBM Plex Sans SC"), lang: "zh")
  show raw: text.with(font: ("Zed Plex Mono", "IBM Plex Sans SC"))
  show math.equation: set text(16pt)
  set table(inset: 8pt)
  set grid(inset: 8pt)

  (templates.post)(..args)
}
