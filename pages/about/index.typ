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

#let about-block = (lhs, rhs) => {
  html.div(
    class: "about-block",
    {
      html.div(class: "about-block-lhs", lhs)
      // html.div(class: "about-block-rhs", rhs)
    }
  )
}

#html.div(
  class: "about-block-list",
  {
    about-block(
      [
        = 关于我

        👋 我是 tiger2005，目前是中山大学计算机学院下的一名本科生。

        - 我的小学时光在湛江度过，中学则是在华南师范大学附属中学就读。
        - 我从初一开始接触信息学竞赛，同时逐渐养成一定的开发习惯。这些经历为我后续的学习和发展奠定了坚实的基础。
        - 我的名字来源于小学时期周围同学的称呼。另外，我的头像来自我在初一时完成的折纸作品，头像的初稿则是使用几何画板根据折纸作品绘制的。
        - 目前，我的兴趣主要集中在算法竞赛和个人开发上。我喜欢通过解决算法问题来提升自己的编程能力，同时也热衷于开发一些有趣的项目来实践所学的知识。
      ],
      {

      }
    )

    about-block(
      [
        = 技术栈

        - 在算法竞赛的熏陶下，能够熟练使用不太 Modern 的 C++ 进行编程，熟悉 STL 和一些常用的算法和数据结构。
        - 在实现作业、报告和 PPT 等要求时，使用 Typst 进行排版，能够熟练使用 Typst 的各种功能来创建美观的文档。
        - 在本地开发时，主要使用 Node.js 环境编写脚本。在一些场景下会使用 Python 来进行辅助，例如编写 Sublime Text 的插件。
        - 由于个人开发项目主要集中在前端领域，因此可以熟练使用 HTML、CSS 和 JavaScript 进行开发，并且对一些前端框架（如 React、Vue）有一定的了解。
        - 除此之外，我还可以根据实际开发需求快速掌握一些新的技术和工具，以便更高效地完成项目开发（虽然会在开发完成之后由于过久没有使用而逐渐遗忘）。

        我目前使用 Sublime Text 完成算法竞赛相关的开发，使用 Visual Studio Code 进行个人开发项目的开发。
      ],
      {

      }
    )

    about-block(
      [
        = 竞赛成绩

        我在 2017 年至 2022 年间，主要参加信息学竞赛相关赛事，其中获得过一些奖项，包括：

        - 于 2020 年获得 APIO 2020 的银牌；
        - 于 2021 年获得 WC 2021 的金牌；
        - 于 2021 年获得 NOIP 2021 的一等奖。

        而在 2023 年至今，我主要在线上和线下参加算法竞赛相关的赛事，其中线下赛事除了第 48 届 ICPC EC Final 获得银首之外的 12 场国内区域赛均获得金牌，截至目前总共取得过三次捧杯的成绩：

        - 在第 10 届 CCPC 中国大学生程序设计竞赛重庆站获得冠军；
        - 在第 49 届 ICPC 国际大学生程序设计竞赛亚洲区域赛上海站获得季军；
        - 在第 50 届 ICPC 国际大学生程序设计竞赛亚洲区域赛武汉站获得季军。

        另外，我作为队员参加了第 49 届 ICPC World Finals。
      
        我在线上参加的赛事主要是 Codeforces 上的比赛，在大学期间取得了 Legendary Grandmaster 称号。除此之外，我也在校内的 CTF 比赛（又称为 W4terCTF）中获得一次亚军和一次冠军。
      ],
      {

      }
    )

    about-block(
      [
        = 开源项目

        我在 GitHub 上开源了一些个人项目，其中比较重要的包括：

        - #link("https://github.com/CodeforcesContestHelper/CCHv2")[CodeforcesContestHelper/CCHv2]
        
          从 2021 年暑假开始开发的项目，作为 #link("https://github.com/CodeforcesContestHelper/CodeforcesContestHelper")[CCH] 的升级版本，考虑到兼容性使用 NW.js 进行开发，实现了 Codeforces 相关的功能，例如比赛日历、题目列表、赛时追踪、用户信息等功能。可惜的是，由于 Codeforces 的 API 设计和更新频率，导致维护成本较高，因此在 2024 年停止维护。
        - #link("https://github.com/tiger2005/KeyboardOverlay")[tiger2005/KeyboardOverlay]
        
          在 2022 年暑假前开始开发的项目，旨在练习 Electron 开发。根据个人的审美偏好设计了一个简洁的键盘展示，并提供了高度自定义功能。本项目作为本地项目，其代码功能实际上可以和本地框架分离，可以在 #link("https://tiger2005.github.io/KeyboardOverlay/")[这个链接] 上在线使用。
        - #link("https://github.com/tiger2005/cpp-perf")[tiger2005/cpp-perf]
        
          在 2023 年初开始开发的项目，主要是为了分散高考复习的压力。使用 Node.js 开发，提供了一个命令行工具来分析 C++ 代码的性能瓶颈，在导出为分析报告后，通过内置的网页项目（或者借助 Node.js 启动的本地预览端口）来展示分析报告的内容。
        - #link("https://github.com/tiger2005/algorithm-templates")[tiger2005/algorithm-templates]
        
          在大学期间开始开发的项目，作为本地的 Sublime Text 插件使用。除了包含一些比赛中常用的代码封装之外，还内置了一个通过 Python 编写的 Sublime Text 插件（Template Expand），在编辑器内部通过快捷键快速展开或收起通过头文件引入的代码块，以提高编辑效率。在我更换电脑之前，我的电脑配置让我无法使用 Visual Studio Code 进行线上比赛，因此这个项目的开发和维护对于我的比赛准备来说是非常重要的。这个项目也是我目前仍在使用 Sublime Text 进行算法竞赛的主要原因。
        - #link("https://github.com/tiger2005/carbon-typst-blog")[tiger2005/carbon-typst-blog]
        
          在 2026 年初开始开发的项目，作为这个博客的框架使用。使用 Typst 进行开发，基于 Carbon 设计系统，提供了一个简洁、现代的博客框架，并具有一定的自定义功能。当然，Typst 作为排版语言依然无法做到完整的生产链，因此剩余的脚本和工具主要使用 Node.js 进行开发。

        更多的项目可以在我的 #link("https://github.com/tiger2005")[GitHub 主页] 上找到。
      ],
      {
      }
    )

    // about-block(
    //   [
    //     = 社交媒体
    //   ],
    //   {

    //   }
    // )
  }
)
