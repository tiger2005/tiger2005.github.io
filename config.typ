#import "lib/typ2html/typ2html.typ" : *
#import "lib/typ2html/sys-input.typ" : query-input

#let current-file-type = str(query-input("file-type", default: "pages"))
#let current-page-path = str(query-input("page-path", default: "")).trim("/")
#let current-source-prefix = if current-file-type == "posts" { "posts" } else { "pages" }
#let current-source-path = if current-page-path == "" {
  current-source-prefix
} else {
  current-source-prefix + "/" + current-page-path
} + "/index.typ"

#let footer-content = html.div(
  class: "footer-content",
  {
    html.div(class: "footer-flex-outer", {
      html.div(class: "footer-flex-block", {
        html.div(
          link("https://www.luogu.com.cn/user/60864")[洛谷]
        )
        html.div(
          link("https://codeforces.com/profile/tiger2005")[Codeforces]
        )
        html.div(
          link("https://atcoder.jp/users/tiger2005")[AtCoder]
        )
        html.div(
          link("https://loj.ac/u/tiger2005")[LibreOJ]
        )
        html.div(
          link("https://uoj.ac/user/profile/tiger2005")[UOJ]
        )
      })
      html.div(class: "footer-flex-block", {
        html.div(
          link("https://github.com/tiger2005")[GitHub]
        )
        html.div(
          link("https://www.zhihu.com/people/tiger2005")[知乎]
        )
        html.div(
          link("https://space.bilibili.com/350620554")[B 站]
        )
        html.div(
          link("https://osu.ppy.sh/users/16296188")[osu!]
        )
      })
    })
    html.div(class: "footer-flex-block", {
      html.div({
        "本页由 "
        link("https://typst.app/")[Typst]
        " 于 " + datetime.today().display("[year] 年 [month padding:none] 月 [day padding:none] 日") + "生成。"
      })
      html.div({
        "本博客使用 "
        link("https://github.com/tiger2005/carbon-typst-blog")[Carbon Typst Blog]
        " 搭建。"
      })
      html.div({
        "本页面被访问了 "
        link("https://vercount.one/", {
          html.span(id: "vercount_value_page_pv", "...")
        })
        " 次。"
      })
      html.div(
        link("https://github.com/tiger2005/tiger2005.github.io/blob/master/" + current-source-path)[查看本页源代码]
      )
      html.div(
        link("/rss.xml")[RSS 订阅]
      )
    })
  }
)

#let tag-options = (
  "矩阵链乘积问题": ("preset": "blue", "icon": "/assets/icons/data-bin.svg"),
  "图论": ("preset": "cyan", "icon": "/assets/icons/concept.svg"),
  "数据结构": ("preset": "teal", "icon": "/assets/icons/parent-child.svg"),
  "数论": ("preset": "purple", "icon": "/assets/icons/calculation.svg"),
  "动态规划": ("preset": "magenta", "icon": "/assets/icons/app-connectivity.svg"),
  "线性代数": ("preset": "red", "icon": "/assets/icons/matrix.svg"),
  "字符串": ("preset": "green", "icon": "/assets/icons/array--strings.svg"),
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
