#import "../../../config.typ": *
#import "@preview/cetz:0.4.2"

#show: template-post.with(
  title: "快速求解矩阵链乘积的精确算法：Hu-Shing 算法 第二部分",
  description: "本文主要讲解 Hu-Shing 算法的第二部分内容，包含单调基础多边形上的线性算法，以及推广得到的一般多边形算法。",
  tags: ("矩阵链乘积问题",),
  category: "Hu-Shing 算法合集",
  date: datetime(year: 2026, month: 3, day: 29)
)

= 引言

本文将会延续之前的讨论，介绍 Hu-Shing 算法的第二部分内容 #cite(label("doi:10.1137/0213017"))。建议读者在阅读本文之前先阅读#link("/posts/mcop/pt1/")[第一部分]，以便更好地理解本文中的内容。

在第一部分 #cite(label("doi:10.1137/0211028")) 中，我们定义了矩阵链乘积问题（MCOP）以及相关的概念，并且介绍了最优划分的一些基础性质。在最后，还介绍了一个重要的概念：潜在水平弧。潜在水平弧是最小划分中水平弧的一种特殊类型，它满足一些特定的性质，这些性质对于后续算法的设计至关重要。实际上，最终的最小划分可以通过选取若干潜在水平弧，并在剩余部分添加竖直弧来构造出来。本文主要讲述如何完成这个过程。

= 扇形划分

存在一种特殊的划分：在所有点和最小点之间都有连边时，就得到了一个类似于扇形的划分。将这种划分记作

$ "Fan"(w_1 | w_2, ... w_n) = w_1 w_2 w_3 + w_1 w_3 w_4 + ... + w_1 w_(n-1) w_n $

并称最小点 $V_1$ 为这个扇形划分的中心。

#figure(
  auto-frame(
    cetz.canvas({
      import cetz.draw: *
      // 六边形的点位置
      let positions = ()
      for i in range(0, 360, step: 60) {
        let d = i * 1deg - 90deg
        positions.push(((4 * calc.cos(d), 4 * calc.sin(d))))
      }

      // 绘制划分的弧
      stroke((dash: "dashed"))
      line(positions.at(0), positions.at(2))
      line(positions.at(0), positions.at(3))
      line(positions.at(0), positions.at(4))

      // 绘制六边形的边
      stroke((dash: "solid"))
      for i in range(6) {
        let start = positions.at(i)
        let end = positions.at(calc.rem(i + 1, 6))
        line(start, end)
      }

      // 绘制六边形的点和权值
      for i in range(6) {
        let pos = positions.at(i)
        fill(gray.lighten(50%))
        circle(pos, radius: 0.6, name: "circle" + str(i))
        content("circle" + str(i), $w_(#{i + 1})$)
        content((1.3 * pos.at(0), 1.3 * pos.at(1)), $V_(#{i + 1})$)
      }
    })
  ),
  caption: [$"Fan"(w_1 | w_2, ... w_6)$ 对应的划分示例]
)

实际上，扇形划分是一类较为优秀的划分形式。接下来将会用一个定理来说明这一点：

#note(title: "扇形划分")[
*命题*：如果一个多边形的最小划分中没有水平弧，那么这个最小划分就是扇形划分。#footnote[原论文 #cite(label("doi:10.1137/0213017")) 给出的证明实际上是错误的，在 2019 年的一篇论文 #cite(label("doi:10.1137/18M1195401")) 中提供了正确的证明。]

*证明*：不难发现，扇形划分实际上是所有划分中字典序最小的一个，因此只需要证明扇形划分同时也是最优划分。

假设这个多边形的最小划分并不是扇形划分，则必存在三个顶点 $V_i, V_j, V_k$，使得三角形 $V_1 - V_i - V_j$ 和 $V_i - V_j - V_k$ 都在最小划分中。由于原多边形已被最小划分，那么显然的，此时子多边形 $V_1 - V_i - ... - V_k - ... - V_j$ 也必须是最小划分。

#figure(
  auto-frame(
    cetz.canvas({
      import cetz.draw: *
      // 六边形的点位置
      let positions = ()
      for i in range(0, 360, step: 30) {
        let d = i * 1deg - 90deg
        positions.push(((4 * calc.cos(d), 4 * calc.sin(d))))
      }
      
      fill(gray.lighten(50%))
      line(
        positions.at(0), positions.at(2), positions.at(3), positions.at(4), positions.at(5), positions.at(6), positions.at(7), positions.at(8),
        close: true,
      )

      // 绘制划分的弧
      stroke((dash: "dashed"))
      line(positions.at(2), positions.at(8))
      line(positions.at(2), positions.at(5))
      line(positions.at(5), positions.at(8))

      // 绘制六边形的边
      stroke((dash: "solid"))
      for i in range(12) {
        let start = positions.at(i)
        let end = positions.at(calc.rem(i + 1, 12))
        line(start, end)
      }

      // 绘制六边形的点和权值
      for i in range(12) {
        let pos = positions.at(i)
        fill(gray.lighten(50%))
        circle(pos, radius: 0.6, name: "circle" + str(i))
      }

      content(positions.at(0), $V_1$)
      content(positions.at(8), $V_i$)
      content(positions.at(5), $V_k$)
      content(positions.at(2), $V_j$)
    })
  ),
  caption: [图中阴影部分对应子多边形 $V_1 - V_i - ... - V_k - ... - V_j$]
)

考虑到最小划分中必然出现边 $V_1 V_2$ 和 $V_2 V_3$，因此 $V_i$ 和 $V_j$ 中必然有一个是子多边形第二小的点，另一个是第三小的点。无论哪种情况，都可以得到对于 $V_i$ 和 $V_j$ 之间的任意一个点 $V_m$，都有 $V_1 < V_i < V_j < V_m$ 或者 $V_1 < V_j < V_i < V_m$，这就说明了 $V_i V_j$ 是一条潜在水平弧，与假设矛盾。$qed$
]

= 单调基础多边形

在正式讨论通用做法之前，需要解决一个子问题：单调多边形。具体的，定义一个点是*局部最大值*，当且仅当它大于两个与它相邻的点。同理定义*局部最小值*。定义一个多边形是*单调多边形*，当且仅当其恰好包含一个局部最大值和一个局部最小值。更具体的，我们只需要讨论*单调基础多边形*的情况。

在下面的图例中，一般会将值较大的点放在上方。下面的图例展示了一个单调基础多边形的示例，并标注了其中的潜在水平弧：

#figure(
  auto-frame(
    cetz.canvas({
      import cetz.draw: *
      // 六边形的点位置
      let positions = ()
      for i in range(0, 360, step: 45) {
        let d = i * 1deg - 90deg
        positions.push(((3 * calc.cos(d), 4 * calc.sin(d))))
      }

      // 绘制划分的弧
      stroke((dash: "dashed"))
      line(positions.at(3), positions.at(5))
      line(positions.at(3), positions.at(6))
      line(positions.at(2), positions.at(6))
      line(positions.at(1), positions.at(6))
      line(positions.at(1), positions.at(7))

      // 绘制六边形的边
      stroke((dash: "solid"))
      for i in range(8) {
        let start = positions.at(i)
        let end = positions.at(calc.rem(i + 1, 8))
        line(start, end)
      }

      // 绘制六边形的点和权值
      for i in range(8) {
        let pos = positions.at(i)
        fill(gray.lighten(50%))
        circle(pos, radius: 0.6, name: "circle" + str(i))
      }

      content(positions.at(0), $V_1$)
      content(positions.at(1), $V_2$)
      content(positions.at(7), $V_3$)
      content(positions.at(4), $V_m$)
    })
  ),
  caption: [单调基础多边形的示例，其中 $V_m$ 是最大点，虚线部分是潜在水平弧]
)

考虑到潜在水平弧互不相交，那么可以定义潜在水平弧之间的上下关系。更具体地说，称一条潜在水平弧在令一条潜在水平弧的上方，当且仅当前者的上多边形被后者的上多边形包含。对于单调基础多边形，潜在水平弧之间的上下关系形成了链式结构。

在单调基础多边形中，可以选择两条潜在水平弧 $V_i V_j$ 和 $V_p V_q$，满足 $V_p V_q$ 在 $V_i V_j$ 的上方。此时，可以定义上界为 $V_p V_q$，下界为 $V_i V_j$ 的子多边形，简称为 $V_i V_j$ 和 $V_p V_q$ 之间的子多边形，如下图所示：

#figure(
  auto-frame(
    cetz.canvas({
      import cetz.draw: *
      // 六边形的点位置
      let positions = ()
      for i in range(0, 360, step: 45) {
        let d = i * 1deg - 90deg
        positions.push(((3 * calc.cos(d), 4 * calc.sin(d))))
      }

      fill(gray.lighten(50%))
      line(
        positions.at(1), positions.at(2), positions.at(3), positions.at(6), positions.at(7),
        close: true,
      )

      // 绘制划分的弧
      stroke((dash: "dashed"))
      line(positions.at(3), positions.at(5))
      line(positions.at(3), positions.at(6))
      line(positions.at(2), positions.at(6))
      line(positions.at(1), positions.at(6))
      line(positions.at(1), positions.at(7))

      // 绘制六边形的边
      stroke((dash: "solid"))
      for i in range(8) {
        let start = positions.at(i)
        let end = positions.at(calc.rem(i + 1, 8))
        line(start, end)
      }

      // 绘制六边形的点和权值
      for i in range(8) {
        let pos = positions.at(i)
        fill(gray.lighten(50%))
        circle(pos, radius: 0.6, name: "circle" + str(i))
      }

      content(positions.at(0), $V_1$)
      content(positions.at(1), $V_j$)
      content(positions.at(7), $V_i$)
      content(positions.at(3), $V_q$)
      content(positions.at(6), $V_p$)
      content(positions.at(4), $V_m$)
    })
  ),
  caption: [潜在水平弧 $V_i V_j$ 和 $V_p V_q$ 以及它们之间的子多边形]
)

不难发现，通过上述方法生成的子多边形也总是一个单调基础多边形。与此同时，如果原多边形中某一条潜在水平弧被包含在子多边形中（不作为侧边出现），那么该弧也一定是子多边形中的潜在水平弧。

将 $V_1 V_1$ 和 $V_m V_m$ 视为两条退化的潜在水平弧，那么最终的最小划分就可以通过选取若干条潜在水平弧，随后在相邻两个水平弧之间的子多边形使用扇形划分得到。

接下来，按照划分包含的水平弧数量将所有划分进行分组，其中不包含水平弧数量的划分对应的组为 $H_0$，包含一条水平弧的划分对应的组为 $H_1$，以此类推。

首先，$H_0$ 只包含 $"Fan"(w_1 | w_2, ..., w_3)$ 一种划分。而对于 $H_1$，只需要枚举最终选取的潜在水平弧，并计算在上下两部分使用扇形划分得到的代价即可。

接下来，选择一条潜在水平弧 $V_i V_j$（$i < j$），并与扇形划分进行比较：

#figure(
  grid(
    columns: 2,
    auto-frame(
      cetz.canvas({
        import cetz.draw: *
        // 六边形的点位置
        let positions = ()
        for i in range(10) {
          let d = i / 10 * 360deg - 90deg
          positions.push(((4 * calc.cos(d), 5 * calc.sin(d))))
        }

        fill(gray.lighten(50%))
        line(
          positions.at(0), positions.at(2), positions.at(3), positions.at(4),
          positions.at(5), positions.at(6), positions.at(7), positions.at(8), 
          close: true,
        )

        // 绘制划分的弧
        stroke((dash: "dashed"))
        line(positions.at(0), positions.at(2))
        line(positions.at(0), positions.at(8))
        line(positions.at(2), positions.at(8))
        line(positions.at(3), positions.at(8))
        line(positions.at(4), positions.at(8))
        line(positions.at(5), positions.at(8))
        line(positions.at(6), positions.at(8))

        stroke((dash: "solid"))
        for i in range(10) {
          let start = positions.at(i)
          let end = positions.at(calc.rem(i + 1, 10))
          line(start, end)
        }

        for i in range(10) {
          let pos = positions.at(i)
          fill(gray.lighten(50%))
          circle(pos, radius: 0.6, name: "circle" + str(i))
        }

        content(positions.at(0), $V_1$)
        content(positions.at(7), $V_p$)
        content(positions.at(6), $V_q$)
        content(positions.at(5), $V_m$)
        content(positions.at(4), $V_r$)
        content(positions.at(3), $V_s$)
        content(positions.at(2), $V_j$)
        content(positions.at(8), $V_i$)
      })
    ),

    auto-frame(
      cetz.canvas({
        import cetz.draw: *
        // 六边形的点位置
        let positions = ()
        for i in range(10) {
          let d = i / 10 * 360deg - 90deg
          positions.push(((4 * calc.cos(d), 5 * calc.sin(d))))
        }

        fill(gray.lighten(50%))
        line(
          positions.at(0), positions.at(2), positions.at(3), positions.at(4),
          positions.at(5), positions.at(6), positions.at(7), positions.at(8), 
          close: true,
        )

        // 绘制划分的弧
        stroke((dash: "dashed"))
        line(positions.at(0), positions.at(2))
        line(positions.at(0), positions.at(3))
        line(positions.at(0), positions.at(4))
        line(positions.at(0), positions.at(5))
        line(positions.at(0), positions.at(6))
        line(positions.at(0), positions.at(7))
        line(positions.at(0), positions.at(8))

        stroke((dash: "solid"))
        for i in range(10) {
          let start = positions.at(i)
          let end = positions.at(calc.rem(i + 1, 10))
          line(start, end)
        }

        for i in range(10) {
          let pos = positions.at(i)
          fill(gray.lighten(50%))
          circle(pos, radius: 0.6, name: "circle" + str(i))
        }

        content(positions.at(0), $V_1$)
        content(positions.at(7), $V_p$)
        content(positions.at(6), $V_q$)
        content(positions.at(5), $V_m$)
        content(positions.at(4), $V_r$)
        content(positions.at(3), $V_s$)
        content(positions.at(2), $V_j$)
        content(positions.at(8), $V_i$)
      })
    )
  ),
  caption: [左图展示了选取潜在水平弧 $V_i V_j$ 后的划分示例，右图展示了扇形划分的示例]
)

可以发现，二者仅在阴影部分多边形上出现差异，其中左侧选择以 $V_i$ 为中心的扇形划分，而右侧选择以 $V_1$ 为中心的扇形划分。

为方便起见，使用记号 $(w_i : w_j)$ 表示 $V_i$ 到 $V_j$ 的两条路径中不包含 $V_1$ 的一侧对应的相邻乘积和（在上面的例子中对应为 $w_i w_p + w_p w_q + ... + w_s w_j$），那么

$
  "Fan"(w_i | w_p, w_q, ..., w_j, w_1) &= w_i ((w_i : w_j) - w_i w_p) + w_1 w_i w_j\
  "Fan"(w_1 | w_i, w_p, w_q, ..., w_j) &= w_1 (w_i : w_j)
$

因此，为了让选择潜在水平弧 $V_i V_j$ 的划分优于扇形划分，需要满足：

$
  w_i ((w_i : w_j) - w_i w_p) + w_1 w_i w_j < w_1 (w_i : w_j)
$

整理后可以得到

$
  (w_i ((w_i : w_j) - w_i w_p)) / ((w_i : w_j) - w_i w_j) < w_1
$

可以发现，左侧的值（定义为*支持权*）实际上只和 $i, j$ 有关，而右侧的值则是一个常数。称一个潜在水平弧 $V_i V_j$ 是*优越的*，当且仅当上述不等式成立。另外，上述定义也可以迁移到子多边形上，不过需要进行如下调整：

- 支持权的分子需要替换成 $V_i V_j$ 以上部分的子多边形的最小代价；
- 支持权的分母中 $(w_i, w_j)$ 需要调整为“$V_i$ 和 $V_j$ 的路径中不包含最小值的一侧对应的相邻乘积和”，这实际上可以通过将两个分母形式的值相减得到；
- 不等式右侧的 $w_1$ 需要调整为子多边形的最小点权；

为方便起见，使用 $h_i$ 序列表示一个潜在水平弧，在上边界为 $h_x$ 的多边形中，一条潜在水平弧 $h_y$ 的*支持权*可以被表示为

$
  S(h_y \\ h_x) = (C(h_x, h_y)) / (U(h_y) - U(h_x))
$

其中

- $C(h_x, h_y)$ 表示 $h_x$ 和 $h_y$ 之间的子多边形的最小代价；
- $U(V_i V_j) = (w_i : w_j) - w_i w_j$。

关于为什么分母可以通过相减得到，可以参考以下图例：

#figure(
  grid(
    columns: 3,
    auto-frame(
      cetz.canvas({
        import cetz.draw: *
        // 六边形的点位置
        let positions = ()
        for i in range(10) {
          let d = i / 10 * 360deg - 90deg
          positions.push(((3 * calc.cos(d), 4 * calc.sin(d))))
        }

        stroke(black)
        stroke((dash: "solid"))
        for i in range(10) {
          let start = positions.at(i)
          let end = positions.at(calc.rem(i + 1, 10))
          line(start, end)
        }

        stroke(red)
        stroke(3pt)
        line(positions.at(2), positions.at(3))
        line(positions.at(3), positions.at(4))
        line(positions.at(4), positions.at(5))
        line(positions.at(5), positions.at(6))
        line(positions.at(6), positions.at(7))
        line(positions.at(7), positions.at(8))
        line(positions.at(8), positions.at(9))

        stroke(blue)
        stroke((dash: "dashed"))
        line(positions.at(2), positions.at(9))
        
        stroke((dash: "solid"))
        stroke(black)
        stroke(1pt)
        for i in range(10) {
          let pos = positions.at(i)
          fill(gray.lighten(50%))
          circle(pos, radius: 0.6, name: "circle" + str(i))
        }

        content(positions.at(7), $V_p$)
        content(positions.at(3), $V_q$)
        content(positions.at(2), $V_j$)
        content(positions.at(9), $V_i$)
      })
    ),

    auto-frame(
      cetz.canvas({
        import cetz.draw: *
        // 六边形的点位置
        let positions = ()
        for i in range(10) {
          let d = i / 10 * 360deg - 90deg
          positions.push(((3 * calc.cos(d), 4 * calc.sin(d))))
        }

        stroke(black)
        stroke((dash: "solid"))
        for i in range(10) {
          if (i > 2 and i < 7) {
            continue
          }
          let start = positions.at(i)
          let end = positions.at(calc.rem(i + 1, 10))
          line(start, end)
        }

        stroke(red)
        stroke(3pt)
        line(positions.at(3), positions.at(7))

        stroke(blue)
        stroke((dash: "dashed"))
        line(positions.at(3), positions.at(4))
        line(positions.at(4), positions.at(5))
        line(positions.at(5), positions.at(6))
        line(positions.at(6), positions.at(7))
        
        stroke((dash: "solid"))
        stroke(black)
        stroke(1pt)
        for i in range(10) {
          let pos = positions.at(i)
          fill(gray.lighten(50%))
          circle(pos, radius: 0.6, name: "circle" + str(i))
        }

        content(positions.at(7), $V_p$)
        content(positions.at(3), $V_q$)
        content(positions.at(2), $V_j$)
        content(positions.at(9), $V_i$)
      })
    ),

    auto-frame(
      cetz.canvas({
        import cetz.draw: *
        // 六边形的点位置
        let positions = ()
        for i in range(10) {
          let d = i / 10 * 360deg - 90deg
          positions.push(((3 * calc.cos(d), 4 * calc.sin(d))))
        }

        stroke(black)
        stroke((dash: "solid"))
        for i in range(10) {
          let start = positions.at(i)
          let end = positions.at(calc.rem(i + 1, 10))
          line(start, end)
        }

        stroke(red)
        stroke(3pt)
        line(positions.at(2), positions.at(3))
        line(positions.at(3), positions.at(7))
        line(positions.at(7), positions.at(8))
        line(positions.at(8), positions.at(9))

        stroke(blue)
        stroke((dash: "dashed"))
        line(positions.at(2), positions.at(9))
        
        stroke((dash: "solid"))
        stroke(black)
        stroke(1pt)
        for i in range(10) {
          let pos = positions.at(i)
          fill(gray.lighten(50%))
          circle(pos, radius: 0.6, name: "circle" + str(i))
        }

        content(positions.at(7), $V_p$)
        content(positions.at(3), $V_q$)
        content(positions.at(2), $V_j$)
        content(positions.at(9), $V_i$)
      })
    ),

    
  ),
  caption: [潜在水平弧 $V_i V_j$ 的两侧路径中不包含 $V_1$ 的一侧对应的分母系数可以通过相减得到。图中左侧展示了 $U(V_i V_j)$，中间展示了 $- U(V_p V_q)$，右侧展示了两者相加得到的结果。红色粗实线表示正贡献，而蓝色粗虚线表示负贡献。]
)

特别地，将 $h_m = V_m V_m$ 和 $h_0 = V_1 V_1$ 分别视为两个退化的潜在水平弧，同时约定 $U(h_m) = 0$，这样就可以将 $S$ 函数的定义推广到所有情况。另外，定义 $W_i$ 表示 $h_i$ 两个端点的权值中较小的一个。

在使用支持权时需要注意：如果要通过“比较支持权和最小点权”判断在某个子多边形内是否应该添加某一条潜在水平弧作为最靠下的水平弧时，对应比较的是对整个子多边形的扇形划分，而非最小划分。

关于支持权，还存在一个重要的不等式：

#note(title: "支持权不等式")[
*命题*：在单调多边形中，对于一条潜在水平弧 $h_y$，以及任意一个在 $h_y$ 上方的潜在水平弧 $h_x$，都有 $S(h_y \\ h_x) < W_y$。

*证明*：考虑到

$
  S(h_y \\ h_x) = (C(h_x, h_y)) / (U(h_y) - U(h_x))
$

其中 $C(h_x, h_y)$ 表示 $h_x$ 和 $h_y$ 之间的子多边形的最小代价，因此其不大于在子多边形内使用扇形划分的代价。假设 $h_x = V_p V_q$，$h_y = V_i V_j$（$V_i < V_j$，此时有 $w_i = W_y$），且 $V_i$ 的邻居中靠近最大值的一个是 $V_p$，则在子多边形内使用扇形划分的代价为

$
  "Fan"(w_i | w_p, ..., w_j) = w_i ((w_i : w_j) - (w_p : w_q) + w_p w_q - w_i w_p)
$

根据潜在水平弧的定义，有 $w_p > w_j$，因此有

$
  &(w_i : w_j) - (w_p : w_q) + w_p w_q - w_i w_p\
  < & (w_i : w_j) - (w_p : w_q) + w_p w_q - w_i w_j\
  = & ((w_i : w_j) - w_i w_j) - ((w_p : w_q) - w_p w_q)\
  = & U(h_y) - U(h_x)
$

因此

$
  S(h_y \\ h_x) = (C(h_x, h_y)) / (U(h_y) - U(h_x)) < (w_i (U(h_y) - U(h_x))) / (U(h_y) - U(h_x)) = w_i = W_y
$

证毕。$qed$
]

接下来，需要考虑最小划分中水平弧选取的“依赖关系”。具体地，可以对每一条潜在水平弧 $h_i$ 定义其*顶弧* $h_k$，满足：

- 如果 $h_i = h_m$，也即最高且退化的潜在水平弧，那么 $h_k = h_m$；
- 否则，$h_k$ 是满足如下条件的潜在水平弧中最靠下的一个：
  + $h_k$ 在 $h_i$ 的上方；
  + $S(h_i \\ h_k) > S(h_k \\ u_k)$（这里 $u_k$ 是 $h_k$ 的顶弧）。

在下面的一些场景中，使用 $u_j$ 表示 $h_j$ 的顶弧。

继续定义 $h_i$ 是 $h_j$ 的一个*父弧*，当且仅当 $h_i$ 是满足上述条件的潜在水平弧中最靠上的一个：

- $h_i$ 在 $h_j$ 的下方；
- $S(h_j \\ u_j) < W_i$（这里 $u_j$ 是 $h_j$ 的顶弧）；
- $S(h_i \\ h_j) <= S(h_j \\ u_j)$，也即 $h_j$ 不是 $h_i$ 的顶弧。

通过观察可以得到顶弧和祖先关系对应的结构性质：

- 父子关系将所有潜在水平弧连接成若干棵树；
- 父子关系本质上等价于“顶弧盒”的嵌套关系。更具体地说，如果 $h_i$ 是 $h_j$ 的父弧，那么 $h_j$ 的顶弧 $u_j$ 必然在 $h_i$ 和 $h_j$ 之间，并且 $h_i$ 的顶弧 $u_i$ 必然在 $u_j$ 的上方，这样就会让 $u_j$ 和 $h_j$ 之间的“顶弧盒”被 $h_i$ 和 $u_i$ 之间的“顶弧盒”所包含。
- “顶弧盒”之间不会出现部分重叠的情况，要么一个包含另一个，要么二者完全不相交。

关于上述性质的具体证明不会展开。接下来，需要证明两个重要的定理：

#note(title: "顶弧的依赖性")[
*命题*：在单调多边形中，对于一条潜在水平弧 $h_i$，如下两个命题成立：

- 对任意一个在 $h_i$ 和 $u_i$ 之间的潜在水平弧 $h_j$，如果 $h_i$ 没有出现在最小划分中，那么 $h_j$ 也不会出现在最小划分中；
- 如果 $h_i$ 在最小划分中，那么 $u_i$ 也在最小划分中。

*证明*：使用反证法。假设最高的违反上述命题的潜在水平弧为 $h_i$。

首先讨论其违反第一个条件的情况。

#quote[
#figure(
  auto-frame(
    cetz.canvas({
      import cetz.draw: *
      // 六边形的点位置
      let positions = ()
      for i in range(10) {
        let d = i / 10 * 360deg - 90deg
        positions.push(((3 * calc.cos(d), 4 * calc.sin(d))))
      }

      stroke(black)
      stroke((dash: "solid"))
      for i in range(10) {
        let start = positions.at(i)
        let end = positions.at(calc.rem(i + 1, 10))
        line(start, end)
      }

      stroke((dash: "dashed"))
      line(positions.at(1), positions.at(9), name: "line1")
      content(("line1.start", 50%, "line1.end"), $h_i$, anchor: "south", padding: .1)

      stroke((dash: "solid"))
      line(positions.at(2), positions.at(8), name: "line2")
      content(("line2.start", 50%, "line2.end"), $h_j$, anchor: "south", padding: .1)

      stroke((dash: "solid"))
      line(positions.at(3), positions.at(7), name: "line3")
      content(("line3.start", 50%, "line3.end"), $u_j$, anchor: "north", padding: .1)

      stroke((dash: "dashed"))
      line(positions.at(4), positions.at(6), name: "line4")
      content(("line4.start", 50%, "line4.end"), $u_i$, anchor: "north", padding: .1)
      
      stroke((dash: "solid"))
      stroke(black)
      stroke(1pt)
      for i in range(10) {
        let pos = positions.at(i)
        fill(gray.lighten(50%))
        circle(pos, radius: 0.6, name: "circle" + str(i))
      }
    })
  ),
  caption: [潜在水平弧 $h_i$、$h_j$、$u_j$ 和 $u_i$ 的一种可能的相对位置示例]
)

假设 $h_i$ 不出现在最小划分中，而在 $u_i$ 和 $h_i$ 之间存在一条潜在水平弧 $h_j$ 出现在最小划分中，并假设 $h_j$ 是所有满足条件的潜在水平弧中最靠下的一个。根据假设，$h_j$ 满足第一个条件，因此其顶弧 $u_j$ 也必须出现在最小划分中。根据 $h_i$ 的顶弧的定义，有 $S(h_i \\ h_j) <= S(h_j \\ u_j)$。

假设在最小划分中，在 $h_i$ 下方且最靠上的水平弧为 $h_k$。考虑到在 $h_j$ 和 $h_k$ 之间的子多边形的最小划分中没有水平弧，根据支持权的性质有：

$
  S(h_i \\ h_j) >= W_k
$

然而，$h_j$ 同时也满足第二个条件，因此 $h_j$ 和 $u_j$ 之间的子多边形中没有水平弧。因此，在 $u_j$ 和 $h_k$ 之间的子多边形中，最小划分仅包含 $h_j$ 一条水平弧。根据支持权的性质有：

$
  S(h_j \\ u_j) < W_k
$

整理上述三个不等式即可推出矛盾。
]

因此，$h_i$ 不存在于最小划分中时，在 $h_i$ 和 $u_i$ 之间的潜在水平弧也不存在于最小划分中。接下来讨论其违反第二个条件的情况。

#quote[
#figure(
  grid(
    columns: 3,
    auto-frame(
      cetz.canvas({
        import cetz.draw: *
        // 六边形的点位置
        let positions = ()
        for i in range(10) {
          let d = i / 10 * 360deg - 90deg
          positions.push(((3 * calc.cos(d), 4 * calc.sin(d))))
        }

        stroke(black)
        stroke((dash: "solid"))
        for i in range(10) {
          let start = positions.at(i)
          let end = positions.at(calc.rem(i + 1, 10))
          line(start, end)
        }

        stroke((dash: "solid"))
        line(positions.at(1), positions.at(9), name: "line1")
        content(("line1.start", 50%, "line1.end"), $h_i$, anchor: "south", padding: .1)

        stroke((dash: "dashed"))
        line(positions.at(2), positions.at(8), name: "line2")
        content(("line2.start", 50%, "line2.end"), $h_k$, anchor: "south", padding: .1)

        stroke((dash: "solid"))
        line(positions.at(3), positions.at(7), name: "line3")
        content(("line3.start", 50%, "line3.end"), $h_c = u_k$, anchor: "south", padding: .1)
        
        stroke((dash: "solid"))
        stroke(black)
        stroke(1pt)
        for i in range(10) {
          let pos = positions.at(i)
          fill(gray.lighten(50%))
          circle(pos, radius: 0.6, name: "circle" + str(i))
        }
      })
    ),
    auto-frame(
      cetz.canvas({
        import cetz.draw: *
        // 六边形的点位置
        let positions = ()
        for i in range(10) {
          let d = i / 10 * 360deg - 90deg
          positions.push(((3 * calc.cos(d), 4 * calc.sin(d))))
        }

        stroke(black)
        stroke((dash: "solid"))
        for i in range(10) {
          let start = positions.at(i)
          let end = positions.at(calc.rem(i + 1, 10))
          line(start, end)
        }

        stroke((dash: "solid"))
        line(positions.at(1), positions.at(9), name: "line1")
        content(("line1.start", 50%, "line1.end"), $h_i$, anchor: "south", padding: .1)

        stroke((dash: "dashed"))
        line(positions.at(2), positions.at(8), name: "line2")
        content(("line2.start", 50%, "line2.end"), $h_k$, anchor: "south", padding: .1)

        stroke((dash: "dashed"))
        line(positions.at(3), positions.at(7), name: "line3")
        content(("line3.start", 50%, "line3.end"), $u_k$, anchor: "north", padding: .1)

        stroke((dash: "solid"))
        line(positions.at(4), positions.at(6), name: "line4")
        content(("line4.start", 50%, "line4.end"), $h_c$, anchor: "north", padding: .1)
        
        stroke((dash: "solid"))
        stroke(black)
        stroke(1pt)
        for i in range(10) {
          let pos = positions.at(i)
          fill(gray.lighten(50%))
          circle(pos, radius: 0.6, name: "circle" + str(i))
        }
      })
    ),
    auto-frame(
      cetz.canvas({
        import cetz.draw: *
        // 六边形的点位置
        let positions = ()
        for i in range(10) {
          let d = i / 10 * 360deg - 90deg
          positions.push(((3 * calc.cos(d), 4 * calc.sin(d))))
        }

        stroke(black)
        stroke((dash: "solid"))
        for i in range(10) {
          let start = positions.at(i)
          let end = positions.at(calc.rem(i + 1, 10))
          line(start, end)
        }

        stroke((dash: "solid"))
        line(positions.at(1), positions.at(9), name: "line1")
        content(("line1.start", 50%, "line1.end"), $h_i$, anchor: "south", padding: .1)

        stroke((dash: "solid"))
        line(positions.at(2), positions.at(8), name: "line2")
        content(("line2.start", 50%, "line2.end"), $h_c$, anchor: "south", padding: .1)

        stroke((dash: "dashed"))
        line(positions.at(3), positions.at(7), name: "line3")
        content(("line3.start", 50%, "line3.end"), $h_k$, anchor: "north", padding: .1)

        stroke((dash: "dashed"))
        line(positions.at(4), positions.at(6), name: "line4")
        content(("line4.start", 50%, "line4.end"), $u_k$, anchor: "north", padding: .1)
        
        stroke((dash: "solid"))
        stroke(black)
        stroke(1pt)
        for i in range(10) {
          let pos = positions.at(i)
          fill(gray.lighten(50%))
          circle(pos, radius: 0.6, name: "circle" + str(i))
        }
      })
    ),
  ),
  caption: [潜在水平弧 $h_i$、$h_k$、$u_k$ 和 $h_c$ 的一些可能的相对位置示例，分别对应了下面讨论的若干情况]
)

此时 $h_i$ 出现在最小划分中，而它的顶弧 $h_k$ 不存在于最小划分中。假设在最小划分中，出现在 $h_i$ 上方且最靠近 $h_i$ 的水平弧为 $h_c$，根据假设，其顶弧 $u_c$ 也出现在最小划分中。首先，根据支持权不等式可以得到

$
  S(h_i \\ h_k) < W_i
$

随后，注意到 $u_c$ 和 $h_i$ 之间的子多边形的最小划分中存在水平弧 $h_c$，根据支持权的性质有：

$
  S(h_c \\ u_c) < W_i
$

（注：这里能够沿用支持权，是因为在 $h_c$ 未被选中的前提下，$u_c$ 和 $h_i$ 的子多边形中没有能被选中的水平弧，因此最小划分是扇形划分，导致上述优越性不等式能够沿用。）

接下来，需要根据上述两个不等式得到：总存在一种更优的划分。

1. 如果 $h_c$ 是 $h_k$ 的顶弧，根据顶弧定义有

  $
    S(h_k \\ h_c) < S(h_i \\ h_k) < W_i
  $

  因此，在 $h_i$ 和 $h_c$ 之间的子多边形中，选择 $h_k$ 以及其上方的最优化分，可以得到一个比在 $h_i$ 和 $h_c$ 之间使用扇形划分更优的划分。

2. 否则，$h_c$ 不是 $h_k$ 的顶弧，进一步分类讨论：
  - 如果 $h_c$ 的父弧 $f_c$ 存在于 $h_i$ 和 $h_c$ 之间，那么根据父子关系的定义有

    $
      S(f_c \\ h_c) <= S(h_c \\ u_c) < W_i
    $

    因此，在 $h_i$ 和 $h_c$ 之间的子多边形中，选择 $f_c$ 以及其上方的最优化分，可以得到一个比在 $h_i$ 和 $h_c$ 之间使用扇形划分更优的划分。
  - 否则，$h_c$ 的父弧不在 $h_i$ 和 $h_c$ 之间，此时可以证明 $h_c$ 不会出现在 $h_k$ 之下（因为 $h_i$ 满足了作为 $h_c$ 父弧的前置条件）。在这一个前提下，从 $h_k$ 开始不断访问，直到访问到 $h_c$，可以得到一条潜在水平弧链 $h_k, h_(a_1) = u_k, h_(a_2), ..., h_(a_r), h_c$，满足 $h_(a_1)$ 是 $h_k$ 的顶弧，$h_(a_2)$ 是 $h_(a_1)$ 的顶弧，以此类推，$h_c$ 是 $h_(a_r)$ 的顶弧。在访问过程中不可能跳过 $h_c$，否则就会存在一条潜在水平弧违背第一个条件。

    根据顶弧的定义，可以得到如下不等式：

    $
      S(h_(a_r) \\ h_c) < S(h_(a_(r-1)) \\ h_(a_r)) < ... < S(h_k \\ u_k) < S(h_i \\ h_k) < W_i
    $

    因此，在 $h_i$ 和 $h_c$ 之间的子多边形中，选择 $h_(a_r)$ 以及其上方的最优化分，可以得到一个比在 $h_i$ 和 $h_c$ 之间使用扇形划分更优的划分。
]

因此，如果 $h_i$ 出现在最小划分中，那么 $u_i$ 也出现在最小划分中。证毕。$qed$
]

在讨论完顶弧的性质之后，接下来需要讨论父子关系的性质：

#note(title: "父子关系的依赖性")[
*命题*：在单调多边形中，对于一条潜在水平弧，其任意一个子弧出现在最小划分中，当且仅当这条水平弧也出现在最小划分中。

*证明*：首先证明：任意一个子弧的出现可以推导出父弧的出现。使用反证法。假设存在一个子弧 $h_i$ 并未出现在最小划分中，而存在一条子弧 $h_j$ 出现在最小划分中。假设 $h_i$ 是所有满足上述条件的潜在水平弧中最高的一个，并且令 $h_j$ 是所有出现的子弧中最低的一个，并另外假设在最小划分中，$h_i$ 下方且最靠近 $h_i$ 的水平弧为 $h_k$。

此时在 $h_j$ 和 $h_k$ 之间的子多边形的最小划分必然是扇形划分，又考虑到 $h_j$ 的顶弧 $u_j$ 也出现在最小划分中，因此在 $u_j$ 和 $h_k$ 之间的子多边形中，最小划分仅包含 $h_j$ 一条水平弧。根据支持权的性质有：

$
  S(h_j \\ u_j) < W_k
$

又根据父子关系的定义有

$
  S(h_i \\ h_j) <= S(h_j \\ u_j) < W_k
$

那么在 $h_j$ 和 $h_k$ 之间的子多边形中，选择 $h_i$ 以及其上方的最优化分，可以得到一个比在 $h_j$ 和 $h_k$ 之间使用扇形划分更优的划分，从而得到矛盾。

接下来证明：父弧的出现可以推导出任意一个子弧的出现。使用反证法。假设存在一个弧 $h_j$ 没有出现在最小划分中，而它的父弧 $h_i$ 出现在最小划分中。假设 $h_j$ 是所有满足上述条件的潜在水平弧中最高的一个。

同样使用反证法。不妨假设 $h_k$ 是最高的潜在水平弧，满足其自身没有出现在最小划分中，而其父弧 $h_j$ 出现在最小划分中。假设在最小划分中，在 $h_k$ 上方且最靠近 $h_k$ 的水平弧为 $h_c$，在 $h_k$ 下方且最靠近 $h_k$ 的水平弧为 $h_b$。此时 $h_c$ 和 $h_b$ 之间的子多边形的最小划分是扇形划分，并且根据假设，$h_c$ 必然是 $h_k$ 的顶弧（否则，$h_c$ 回事 $h_k$ 的一个后代，从而通过定理的前半部分得到 $h_k$ 出现在最小划分中）。考虑到 $h_b$ 不低于 $h_j$，因此

$
  W_b >= W_j > S(h_k \\ h_c)
$

因此，在 $h_b$ 和 $h_c$ 之间的子多边形中，选择 $h_k$ 以及其上方的最优化分，可以得到一个比在 $h_b$ 和 $h_c$ 之间使用扇形划分更优的划分，从而得到矛盾。证毕。$qed$
]

因此，在父子关系形成的树结构中，同属于一棵树的潜在水平弧要么全部出现在最小划分中，要么全部不出现在最小划分中。为了确认某一棵树中的潜在水平弧是否出现在最小划分中，需要证明一个比较显然的命题：

#note(title: "父弧的支持权比较")[
*命题*：在单调多边形中，对于两个潜在水平弧 $h_i$ 和 $h_j$（$h_j$ 在 $h_i$ 的上方），如果在 $h_j$ 和 $h_n$ 之间的子多边形的最小划分是扇形划分，并且满足 $S(h_j \\ u_j) >= W_i$，那么在以不低于 $h_n$ 的潜在水平弧为上边沿，不高于 $h_i$ 的潜在水平弧为下边沿约束得来的多边形中，$h_j$ 不会出现在其最小划分中。

*证明*：使用反证法。假设 $h_j$ 出现在以不低于 $h_n$ 的潜在水平弧为上边沿，不高于 $h_i$ 的潜在水平弧为下边沿约束得来的多边形的最小划分中。假设 $h_j$ 是所有满足上述条件的潜在水平弧中最高的一个，并且令 $h_b$ 是所有出现在最小划分中且在 $h_i$ 下方的潜在水平弧中最高的一个。此时，在 $h_i$ 和 $h_j$ 之间的潜在水平弧都不出现在最小划分中，因此 $h_b$ 不高于 $h_i$，则

$
  W_b <= W_i <= S(h_j \\ u_j)
$

又因为 $h_j$ 和 $h_b$ 之间的子多边形的最小划分是扇形划分，因此在 $h_j$ 和 $h_b$ 之间的子多边形中，不选择 $h_j$ 以及其上方的最小划分会比选择 $h_j$ 以及其上方的最小划分更优，从而得到矛盾。证毕。$qed$
]

根据上面给出的所有讨论，我们在最后给出一个线性时间求解单调多边形的最小划分的算法：

#success(title: "单调多边形最小划分算法")[
+ 通过第一部分给出的算法得到所有潜在水平弧，此时它们默认是从高到低排列的。
+ 从高到低枚举潜在水平弧，假设当前枚举到的潜在水平弧是 $h_j$，其上方最靠近 $h_j$ 的潜在水平弧为 $h_k$（使用栈维护），而其下方最靠近 $h_j$ 的潜在水平弧为 $h_i$。此时，假设算法已经得到了 $h_j$ 的上多边形对应的最小划分，并计算出了其中所有潜在水平弧的顶弧。

  首先需要确认 $h_j$ 的顶弧和子弧。不断将 $S(h_j \\ h_k)$ 和 $S(h_k \\ u_k)$ 比较，如果 $S(h_j \\ h_k) > S(h_k \\ u_k)$，则 $h_k$ 是 $h_j$ 的一个顶弧；否则，$h_k$ 是 $h_j$ 的一个子弧。此时：

  - 如果 $h_k$ 是 $h_j$ 的子弧，则将 $h_k$ 出栈，并将 $h_k$ 更新为新的 $h_j$ 的上方最靠近 $h_j$ 的潜在水平弧，继续比较，直到 $S(h_j \\ h_k) > S(h_k \\ u_k)$ 或者 $h_k$ 不存在为止。

  #quote[
    此时，新的潜在水平弧一定是 $h_k$ 的顶弧，为了在已知 $S(h_j \\ h_k)$ 和 $S(h_k \\ u_k)$ 的情况计算 $S(h_j \\ u_k)$，根据支持权的定义可以发现，在当前场景下，$S(h_J \\ u_k)$ 的分子和分母都可以通过 $S(h_j \\ h_k)$ 和 $S(h_k \\ u_k)$ 的分子分母相加得到，因此可以做到在 $O(1)$ 的时间内计算出 $S(h_j \\ u_k)$，也就是新的 $S(h_j \\ h_k)$。
  ]

  - 如果 $h_k$ 是 $h_j$ 的顶弧，则进入下一步。

  在完成上述处理后，先将 $h_j$ 入栈，然后，需要根据 $S(h_j \\ u_j)$ 和 $W_i$ 的比较结果来判断 $h_j$ 是否出现在最小划分中：

  - 如果 $S(h_j \\ u_j) >= W_i$，则 $h_j$ 不出现在最小划分中。此时需要将其出栈，并将 $h_j$ 替换为栈顶的潜在水平弧，继续比较，直到 $S(h_j \\ u_j) < W_i$ 或者 $h_j$ 不存在为止。

  - 否则，$h_j$ 出现在最小划分中，无需进行额外处理。

+ 重复上述流程，直到枚举完所有潜在水平弧为止，此时栈中剩余的潜在水平弧和对应的后代即为最小划分中的水平弧。在实现中，可以通过访问顶弧得到需要保留的潜在水平弧。
]

在上述算法中，栈内维护的实际上是顶弧的链接关系，同时一条潜在水平弧的所有后代由于和它共同出现或不出现，因此被合并到了一起。对于每一条潜在水平弧，最多被入栈和出栈一次，因此算法的时间复杂度为 $cal(O) (n)$。

= 普通多边形

接下来，需要将上述理论推广到普通多边形中。在普通多边形中，虽然不能像单调多边形一样形成链式的潜在水平弧结构，但通过类似的方式，可以推广成一种类似树的结构。

#figure(
  grid(
    columns: 2,
    auto-frame(
      cetz.canvas({
        import cetz.draw: *
        // 六边形的点位置
        let positions = ()
        for i in range(12) {
          let d = i / 12 * 360deg - 90deg
          positions.push(((4 * calc.cos(d), 4 * calc.sin(d))))
        }

        stroke(black)
        stroke((dash: "solid"))
        for i in range(12) {
          let start = positions.at(i)
          let end = positions.at(calc.rem(i + 1, 12))
          line(start, end)
        }

        stroke((dash: "dashed"))
        line(positions.at(1), positions.at(11))
        line(positions.at(2), positions.at(10))
        line(positions.at(2), positions.at(6))
        line(positions.at(3), positions.at(5))
        line(positions.at(6), positions.at(10))
        line(positions.at(7), positions.at(9))

        stroke((dash: "solid"))

        let names = (
          $V_1$, $V_3$, $V_5$, $V_8$, $V_11$, $V_9$,
          $V_6$, $V_10$, $V_12$, $V_7$, $V_4$, $V_2$
        )

        for i in range(12) {
          let pos = positions.at(i)
          fill(gray.lighten(50%))
          circle(pos, radius: 0.6, name: "circle" + str(i))
          content(pos, names.at(i))
        }
      })
    ), auto-frame(
      cetz.canvas({
        import cetz.draw: *
        // 六边形的点位置
        let positions = (
          (0, -1),
          (2, 0.5),
          (3.5, 2),
          (4.5, 4),
          (3.5, 7),
          (1.5, 6),
          (0, 4),
          (-1.5, 6),
          (-3.5, 7),
          (-4.5, 4),
          (-3.5, 2),
          (-2, 0.5)
        )

        stroke(black)
        stroke((dash: "solid"))
        for i in range(12) {
          let start = positions.at(i)
          let end = positions.at(calc.rem(i + 1, 12))
          line(start, end)
        }

        stroke((dash: "dashed"))
        line(positions.at(1), positions.at(11))
        line(positions.at(2), positions.at(10))
        line(positions.at(2), positions.at(6))
        line(positions.at(3), positions.at(5))
        line(positions.at(6), positions.at(10))
        line(positions.at(7), positions.at(9))

        stroke((dash: "solid"))

        let names = (
          $V_1$, $V_3$, $V_5$, $V_8$, $V_11$, $V_9$,
          $V_6$, $V_10$, $V_12$, $V_7$, $V_4$, $V_2$
        )

        for i in range(12) {
          let pos = positions.at(i)
          fill(gray.lighten(50%))
          circle(pos, radius: 0.6, name: "circle" + str(i))
          content(pos, names.at(i))
        }
      })
    )
  ),
  caption: [左侧展示了一个普通多边形的示例，右侧展示了其潜在水平弧的树状结构示例。]
)


对于普通多边形，潜在水平弧的定义和单调多边形中的定义完全相同，不过支持权、顶弧和父子关系的定义需要进行一些调整：

- 支持权的上界参数不再是单一的水平弧，而是由一群*不存在位置上下关系*的潜在水平弧组成的集合。对于一个潜在水平弧 $h_i$，定义 $S(h_i \\ H)$ 表示在 $h_i$ 和 $H$ 之间的子多边形的最小划分中，$h_i$ 的支持权，其中 $H$ 是一个潜在水平弧集合，满足其中任意两个潜在水平弧之间不存在位置上下关系。

  例如，在上述图中，若 $H = {V_7 V_10, V_9 V_8}$，则代表的上界实际上是 $V_7 - V_10 - V_6 - V_9 - V_8$ 对应的链状结构，在以这个链状结构为上边界，以 $h_i$ 为下边界的子多边形中，即可通过前面的定义计算出 $S(h_i \\ H)$。

- 顶弧的定义同样需要调整。对于一个潜在水平弧 $h_i$，其顶弧 $h_k$ 需要满足如下条件：

  - $h_k$ 在 $h_i$ 的上方；
  - $S(h_i \\ h_k) > S(h_k \\ U_k)$；
  - 顶弧之间不存在包含关系，而只能并列；
  - 没有在 $h_k$ 之下且在 $h_i$ 之上的弧同时满足上述性质。

  不难发现，通过上述方法定义的顶弧集是唯一的。另外，对于局部最大值对应的潜在水平弧而言，其顶弧会退化为自身。下面称 $h_i$ 的顶弧集合为 $U_i$（$U$ 函数的定义已经不重要了）。

- 父子关系在此时似乎难以确定，不过万幸的是，一条潜在水平弧下方（也就是上多边形存在包含关系）的弧依然遵循线性排布，因此父弧的定义依然使用，使用父弧定义子弧即可。

通过上述定义，可以得到和单调多边形中完全相同的性质：

- 如果一条潜在水平弧出现在最小划分中，那么它的所有顶弧也出现在最小划分中。
- 一条潜在水平弧的子弧出现在最小划分中，当且仅当这条潜在水平弧也出现在最小划分中。
- 在单调多边形中决定一条潜在水平弧是否出现在最小划分中使用的判定条件同样适用于普通多边形。

在稍加整理后，可以得到在 $cal(O) (n log n)$ 的时间复杂度内求解普通多边形的最小划分的算法：

#success(title: "普通多边形最小划分算法")[
+ 通过第一部分给出的算法得到所有潜在水平弧，此时它们在位置上呈现树状结构；
+ 使用后序遍历顺序（也就是先计算深点再计算浅点）的顺序枚举所有潜在水平弧，假设当前枚举到的潜在水平弧为 $h_j$，在树状结构中在 $h_j$ 上方且最靠近的潜在水平弧集合为 $X$，而在 $h_j$ 下方的潜在水平弧为 $h_i$

  #quote[
    需要注意的是，在之前的算法中，可以使用栈维护上方的潜在水平弧，并潜在维护单调性，但在这一部分中，需要将树状结构中若干个儿子对应的潜在水平弧合并，同时维护单调性，因此需要使用更高级的数据结构，这也对应了本算法的瓶颈。
  ]

  此时，假设算法已经得到了 $h_j$ 的上多边形对应的最小划分，并计算出了其中所有潜在水平弧的顶弧。和之前的算法不同，需要先将 $X$ 中一定不在最小划分中的潜在水平弧删除掉。具体而言：
  
  - 不断从集合 $X$ 中选择使得 $S(h_k \\ U_k)$ 最大的潜在水平弧 $h_k$，此时如果 $S(h_k \\ U_k) >= W_j$，则 $h_k$ 不出现在最小划分中。此时需要将 $h_k$ 从 $X$ 中删除，并将 $h_k$ 的所有顶弧加入到 $X$ 中。重复上述流程，直到 $S(h_k \\ U_k) < W_j$ 或者 $X$ 中没有潜在水平弧为止。

  随后，需要确定 $h_j$ 的顶弧集合。在此时，只需要将 $X$ 中 $h_j$ 的子弧不断删除，并对应补上其水平弧，重复上述流程即可。具体而言：

  - 不断从集合 $X$ 中选择使得 $S(h_k \\ U_k)$ 最大的潜在水平弧 $h_k$，此时如果 $S(h_j \\ U_j) <= S(h_k \\ U_k)$，则 $h_k$ 是 $h_j$ 的一个子弧。此时需要将 $h_k$ 从 $X$ 中删除，同时将 $h_k$ 的所有顶弧加入到 $X$ 中。重复上述流程，直到 $S(h_j \\ U_j) > S(h_k \\ U_k)$ 或者 $X$ 中没有潜在水平弧为止。

  最后，集合 $X$ 就是 $h_j$ 的顶弧集合 $U_j$。

+ 重复上述流程，直到枚举完所有潜在水平弧为止，在构造方案时，需要汇集在上面的步骤中被移出集合 $X$ 的所有潜在水平弧，并对应的在原多边形中移除它们的所有后代。此时，原多边形剩余的部分就是最小划分包含的所有水平弧，剩余部分使用扇形划分即可。

在实现中，存在一种可选方式：使用 $X$ 维护当前潜在水平弧上方的*所有潜在水平弧*，在后续选弧时就不需要再将顶弧加入到 $X$ 中了，而是直接在 $X$ 中进行选择即可。根据顶弧定义的单调性，不难发现取出的潜在水平弧不会是另一个集合内潜在水平弧的顶弧。
]

现在简单论述一下时间复杂度。在枚举到 $h_j$ 时，需要合并若干集合 $X$ 中的潜在水平弧，在合并时需要维护支持权的最大值，并支持删除最大值以及对应的更新。因此，本算法需要一个满足如下需求的数据结构：

- 维护若干集合，进行总共 $cal(O) (n)$ 次插入操作；
- 在集合中，支持查询最大值，以及将最大值删除；
- 支持合并两个集合。

一种经典的实现方法是可并堆，另一种方法则是实现了 Finger Search 的平衡树。无论使用哪种方法，总的时间复杂度均摊下来都是 $cal(O) (n log n)$。

#bibliography("../ref.bib")