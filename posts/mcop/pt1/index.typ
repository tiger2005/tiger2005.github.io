#import "../../../config.typ": *
#import "@preview/cetz:0.4.2"

#show: template-post.with(
  title: "快速求解矩阵链乘积的精确算法：Hu-Shing 算法 第一部分",
  description: "本文主要讲解 Hu-Shing 算法的第一部分内容，包含如何将矩阵链乘积问题转化为一个凸多边形划分问题，以及最优划分的一些基础性质。",
  tags: ("矩阵链乘积问题",),
  category: "Hu-Shing 算法合集",
  date: datetime(year: 2026, month: 3, day: 25)
)

= 引入

*Hu-Shing 算法* 是一个能够快速解决矩阵链乘积（或矩阵链排序问题，MCOP）的算法。在这项研究成果之前，A. K. Chandra 就已经提出在 $cal(O)(n)$ 的时间复杂度下计算处近似解的算法（具体而言，近似解的代价不超过最优解代价的两倍），而这一算法被 F. Y. Chin 进一步优化，在同样的时间复杂度内达到了更低的近似比。在论文 #cite(label("doi:10.1137/0211028")) 和 #cite(label("doi:10.1137/0213017")) 中，T. C. Hu 和 M. T. Shing 两人提出了一个在 $cal(O)(n log n)$ 的时间复杂度下计算精确解的算法。本文主要根据原论文的思路，逐步讲述这个算法是如何工作的。

下面是对 MCOP 问题的介绍：

#note(title: "矩阵链乘积问题 / MCOP")[

下式将 $n - 1$ 个矩阵相乘，最终得到一个矩阵：

$ M = M_1 times M_2 times dots.c times M_(n-1) $

假设 $M_i$ 是一个 $w_i$ 行 $w_(i+1)$ 列的矩阵。考虑到矩阵乘法满足结合律，那么任意改变乘法的顺序得到的最终矩阵必然相同，而运算次数却不尽相同。该问题的目的是找到一个最优的乘法策略，满足在该策略下进行矩阵乘法所需操作数最少。在这里，假设对 $p times q$ 的矩阵和 $q times r$ 的矩阵进行乘法所需的操作数是 $p q r$。
]

本文主要讲解 Hu-Shing 算法的第一部分内容，第二部分内容将会在后续的文章中介绍。

= 图论模型

实际上，MCOP 可以转化为一个更容易研究的凸多边形划分问题。对于一个包含 $n$ 个节点的凸多边形（下简称 $n$ 边形），其外围的 $n$ 条边被称为*侧边*，在其内部将两个不相邻的节点以线段相连（称这类线段为*弧*）。在连接了 $n-3$ 条两两不在中间相交的弧后，这个凸多边形就被分成了 $n-2$ 个三角形（称这样的方案为*划分*），而对应的方案数就是卡特兰数。不妨按照某种顺序将点记为 $V_1, V_2, ..., V_n$，并且在 $V_i$ 处设立一个权值 $w_i$。

随后，可以按照如下方式计算一个划分的代价：

- 对划分出的每个三角形，假设其连接了权值分别为 $x, y, z$ 的三个节点，那么其代价为 $x y z$。
- 一个划分的代价就是所有三角形的代价和。

以下是对六边形的一种划分：

#figure(
  auto-frame(
    cetz.canvas({
      import cetz.draw: *
      // 六边形的点位置
      let positions = ()
      for i in range(0, 360, step: 60) {
        let d = i * 1deg - 60deg
        positions.push(((4 * calc.cos(d), 4 * calc.sin(d))))
      }

      // 绘制划分的弧
      stroke((dash: "dashed"))
      line(positions.at(0), positions.at(2))
      line(positions.at(2), positions.at(5))
      line(positions.at(5), positions.at(3))

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
  caption: [一种六边形的划分示例，对应的代价为 $w_1 w_2 w_3 + w_1 w_3 w_6 + w_3 w_4 w_6 + w_4 w_5 w_6$]
)

在完成凸多边形划分的定义后，首先需要定义以下操作：

#note(title: "凸多边形的“收缩”")[
*命题*：对于一个 $n$（$n >= 4$）边形，其任意划分中总是存在至少两个三角形，满足三角形的两条边都是该 $n$ 边形上的侧边。

*证明*：由于 $n >= 4$，不难发现任意三角形的三条边不可能都是 $n$ 边形上的侧边。又由于划分出的三角形数量为 $n - 2$，而多边形的侧边有 $n$ 条，使用抽屉原理即可证明。$qed$

在上述命题的基础上，可以定义*收缩*操作：对于一个 $n$ 边形的划分，找到一个满足上述命题且*不包含侧边 $V_1 V_n$ *的三角形（因为有至少两个三角形满足上述命题，所以总能找到一个不包含侧边 $V_1 V_n$ 的三角形），设为 $A - B - C$，其中 $A, B, C$ 是多边形上的顶点，并且 $A B, B C$ 都是多边形上的侧边。随后，删除 $B$ 以及与 $B$ 相连的两条边 $A B, B C$，并且添加一条边 $A C$，得到一个 $n - 1$ 边形对应的划分。收缩操作在得到三角形时停止，此时这个三角形包含了侧边 $V_1 V_n$。
]

通过上述结论可以发现：凸多边形的“收缩”等价于某一种链乘积的策略。具体而言：

- 收缩过程中凸多边形的侧边中，$V_1 V_n$ 象征最终产物，而其余侧边则象征目前需要合并的中间产物。
- 在每次选择三角形删除时，相当于选择了一个合并策略，其中被删除的两条侧边代表被用于相乘的两个矩阵，而被添加的边代表了相乘后得到的新矩阵。
- 由于每次收缩操作都会产生一个三角形，而每个三角形的代价又等价于一次矩阵乘法的代价，因此一个划分的代价也就等价于一个链乘积策略的代价。

因此，本道题目的目标就从矩阵链乘积问题转化为了寻找一个*正整数权值*凸多边形的*最优划分*。更严谨地说，定义一个凸多边形的划分为*最优划分*，当且仅当这个划分的代价是所有可能的划分中代价的最小值。

= 划分的基础性质

这一部分主要包含最优划分的一些基础性质，这些性质对于后续算法的设计至关重要。

首先需要明确：$V_i$ 的编号顺序在凸多边形的划分中并不重要，因此可以任意对 $n$ 个点进行编号。下文中将会按照权值从小到大的顺序对点进行编号，即 $w_1 <= w_2 <= ... <= w_n$。

为方便叙述，定义两个点之间的大小关系为： $V_i < V_j$ 当且仅当 $i < j$，其中*蕴含了 $w_i <= w_j$*。另外，定义弧 $V_i V_j$（$i < j$）在字典序上小于弧 $V_k V_l$（$k < l$），当且仅当 $i < k$ 或者 $i = k$ 且 $j < l$。

在此基础上，可以定义两个划分之间的字典序关系：将两个划分中的所有弧按字典序升序排列，比较两个划分的弧序列，找到第一个不同的弧，若该弧在第一个划分中小于在第二个划分中，则认为第一个划分小于第二个划分。在字典序的基础上，可以进一步定义唯一的*最小划分*：如果一个划分在所有最优划分中是字典序最小的，那么称其为最小划分。不难发现，一个最小划分在去掉一部分靠外的三角形后，得到的划分仍然是一个最小划分。

另外，为了方面下面的数学推导，还需要定义一些符号：

- $T_(i j k)$ 表示三角形 $V_i - V_j - V_k$ 的划分代价，即 $w_i w_j w_k$。
- $C(w_1, w_2, ..., w_n)$ 表示权值为 $w_1, w_2, ..., w_n$ 的凸多边形的最优划分代价。

接下来需要证明一个非常重要的性质：

#note(title: "最小划分的性质")[
*命题*：一个 $n$ 边形的最小划分总是包含 $V_1 V_2$ 和 $V_1 V_3$ 两条边（可以是侧边或者弧）。

*证明*：使用归纳法。不难发现上述命题在三角形和四边形上均成立。考虑证明 $n >= 5$ 时，若对任意 $3 <= k < n$，都满足上述命题在 $k$ 边形划分中成立，那么上述命题在 $n$ 边形划分中也成立。

根据前文的命题，任意一个 $n$ 边形的划分中都存在至少两个三角形，满足三角形的两条边都是该 $n$ 边形上的侧边。不妨假设在*最小划分*中，这两个三角形中两个侧边相交的点分别为 $V_i$ 和 $V_j$，那么根据划分性质，它们的度数都是 $2$。接下来，假设 $i < j$，并进行讨论：

- 如果 $j > 3$，那么直接将 $V_j$ 和它的邻边删除，在剩余的 $n - 1$ 边形中，最小的三个点分别是 $V_1, V_2, V_3$，根据归纳假设，$n - 1$ 边形的最小划分包含 $V_1 V_2$ 和 $V_1 V_3$，因此可以得到 $n$ 边形的最小划分也包含 $V_1 V_2$ 和 $V_1 V_3$；

- 如果 $i = 2$，$j = 3$，先将 $V_i$ 和它的邻边删除，在剩余的 $n - 1$ 边形中，最小的三个点分别是 $V_1, V_3, V_4$，因此根据归纳假设，最小划分中包含 $V_1 V_3$；同理，将 $V_j$ 和它的邻边删除，在剩余的 $n - 1$ 边形中，最小的三个点分别是 $V_1, V_2, V_4$，因此根据归纳假设，最小划分中包含 $V_1 V_2$；

- 如果 $i = 1$，$j = 2$，通过移走 $V_i$，可以得到一个 $n - 1$ 边形，在该边形的最小划分中包含 $V_1 V_3$ 和 $V_1 V_4$；同理，通过移走 $V_j$，可以得到一个 $n - 1$ 边形，在该边形的最小划分中包含 $V_2 V_3$ 和 $V_2 V_4$。

  此时可以发现，$V_1$ 与 $V_2$ 同时向 $V_3$、$V_4$ 连接，而 $V_1$ 与 $V_2$ 的邻边都是多边形的侧边，那么 $V_1$ 与 $V_2$ 同时和 $V_3$、$V_4$ 相邻，因此它们将直接构成一个四边形，和 $n >= 5$ 的假设矛盾。这就证明了 $i = 1$，$j = 2$ 的情况不可能发生；

- 如果 $i = 1$，$j = 3$，同理可以得到 $V_2$ 和 $V_1$、$V_3$ 相邻，又因为 $V_1$ 与 $V_3$ 的邻边都是多边形的侧边，不妨假设它们形成了如下结构：

  #figure(
    auto-frame(
      cetz.canvas({
        import cetz.draw: *
        // 八边形的点位置
        let positions = ()
        for i in range(0, 360, step: 30) {
          let d = i * 1deg - 180deg
          positions.push(((5 * calc.cos(d), 5 * calc.sin(d))))
        }

        stroke((dash: "dashed"))
        line(positions.at(1), positions.at(3))
        line(positions.at(3), positions.at(5))

        stroke((dash: "solid"))
        for i in range(6) {
          let start = positions.at(i)
          let end = positions.at(calc.rem(i + 1, 8))
          line(start, end)
        }

        // 顺序是 p - 1 - 2 - 3 - q
        fill(gray.lighten(50%))
        let pos = positions.at(1)
        circle(pos, radius: 0.5, name: "circle1")
        content("circle1", $w_p$)
        content((1.2 * pos.at(0), 1.2 * pos.at(1)), $V_p$)

        pos = positions.at(2)
        circle(pos, radius: 0.5, name: "circle2")
        content("circle2", $w_1$)
        content((1.2 * pos.at(0), 1.2 * pos.at(1)), $V_1$)

        pos = positions.at(3)
        circle(pos, radius: 0.5, name: "circle3")
        content("circle3", $w_2$)
        content((1.2 * pos.at(0), 1.2 * pos.at(1)), $V_2$)

        pos = positions.at(4)
        circle(pos, radius: 0.5, name: "circle4")
        content("circle4", $w_3$)
        content((1.2 * pos.at(0), 1.2 * pos.at(1)), $V_3$)

        pos = positions.at(5)
        circle(pos, radius: 0.5, name: "circle5")
        content("circle5", $w_q$)
        content((1.2 * pos.at(0), 1.2 * pos.at(1)), $V_q$)
      })
    ),
    caption: [一种可能的结构示例，其中 $p, q >= 4$，剩余的点在此略去]
  )

  将三角形 $V_1 - V_2 - V_p$ 删除，可以得到上述结构的最小划分代价为

  $
    T_(1 2 p) + C(w_2, w_3, w_q, ..., w_p)
  $

  接下来，考虑另一种结构：

  #figure(
    auto-frame(
      cetz.canvas({
        import cetz.draw: *
        let positions = ()
        for i in range(0, 360, step: 30) {
          let d = i * 1deg - 180deg
          positions.push(((5 * calc.cos(d), 5 * calc.sin(d))))
        }

        stroke((dash: "dashed"))
        line(positions.at(2), positions.at(4))

        stroke((dash: "solid"))
        for i in range(6) {
          let start = positions.at(i)
          let end = positions.at(calc.rem(i + 1, 8))
          line(start, end)
        }

        // 顺序是 p - 1 - 2 - 3 - q
        fill(gray.lighten(50%))
        let pos = positions.at(1)
        circle(pos, radius: 0.5, name: "circle1")
        content("circle1", $w_p$)
        content((1.2 * pos.at(0), 1.2 * pos.at(1)), $V_p$)

        pos = positions.at(2)
        circle(pos, radius: 0.5, name: "circle2")
        content("circle2", $w_1$)
        content((1.2 * pos.at(0), 1.2 * pos.at(1)), $V_1$)

        pos = positions.at(3)
        circle(pos, radius: 0.5, name: "circle3")
        content("circle3", $w_2$)
        content((1.2 * pos.at(0), 1.2 * pos.at(1)), $V_2$)

        pos = positions.at(4)
        circle(pos, radius: 0.5, name: "circle4")
        content("circle4", $w_3$)
        content((1.2 * pos.at(0), 1.2 * pos.at(1)), $V_3$)

        pos = positions.at(5)
        circle(pos, radius: 0.5, name: "circle5")
        content("circle5", $w_q$)
        content((1.2 * pos.at(0), 1.2 * pos.at(1)), $V_q$)
      })
    ),
    caption: [另一种可能的结构示例，其中 $p, q >= 4$，剩余的点在此略去]
  )

  将三角形 $V_1 - V_2 - V_3$ 删除，可以得到上述结构的最小划分代价为

  $
    T_(1 2 3) + C(w_1, w_3, w_q, ..., w_p)
  $

  此时可以发现：$T_(1 2 3) <= T_(1 2 p)$，并且由于剩余的 $n - 1$ 边形中恰好只有一个位置的点权发生了变化，不难得到
  
  $ C(w_1, w_3, w_q, ..., w_p) <= C(w_2, w_3, w_q, ..., w_p) $
  
  因此上述结构的最小划分代价不大于前一种结构的最小划分代价，并且字典序更小，与最小划分的定义矛盾。这就证明了 $i = 1$，$j = 3$ 的情况不可能发生。

综上所述，最小划分中必然包含 $V_1 V_2$ 和 $V_1 V_3$ 两条边。$qed$
]

随后注意到：如果一个多边形中边 $V_1 V_2$ 是一个弧，那么这个弧就可以将多边形分为两个部分，而每个部分分别对应了一个子问题。整个过程会一直持续到 $V_1 V_2$ 和 $V_1 V_3$ 都是侧边为止，此时称满足这个条件的多边形为*基础多边形*。

对于基础多边形，不妨考虑边 $V_2 V_3$ 是否存在，此时如果 $V_2 V_3$ 存在，就可以将三角形 $V_1 - V_2 - V_3$ 删除，得到一个 $n - 1$ 边形。首先可以发现如下事实：

#note(title: "基础多边形的性质")[
*命题*：一个基础多边形的最小划分中必然包含边 $V_2 V_3$ 或边 $V_1 V_4$（可以是侧边或者弧）。

*证明*：不妨考虑 $V_2 V_3$ 没有出现在最小划分的情况，不难发现有 $V_1$ 除了 $V_2$、$V_3$ 之外，还向某一个点 $V_p$ 连接了一条弧。此时如果 $V_p$ 是 $V_4$，那么上述命题得证；否则，考虑使用弧 $V_1 V_p$ 将多边形分为两部分，其中 $V_2$ 和 $V_3$ 在不同的部分中，此时无论 $V_4$ 落在哪一部分，它都必然是对应多边形中第三小的点，因此总会有 $V_1$ 向 $V_4$ 连接一条边。$qed$

在上述命题的基础上，可以进一步定义下面的命题：

*命题*：对于一个基础多边形的最优划分，如果边 $V_2 V_3$ 出现，那么必然有

$
  1/w_1 + 1/w_4 <= 1/w_2 + 1/w_3
$

*证明*：如果边 $V_2 V_3$ 出现，那么可以将三角形 $V_1 - V_2 - V_3$ 删除，得到一个 $n - 1$ 边形，在该边形的最小划分中包含边 $V_2 V_4$。如果这条边是弧，则可以使用弧 $V_2 V_4$ 将多边形分为两部分，其中 $V_1$、$V_2$、$V_3$ 和 $V_4$ 都落在同一部分，形成一个子问题。因此，在下述讨论中总是假设边 $V_2 V_4$ 是侧边。

此时考虑下面两种结构：

#figure(
  grid(columns: 2, gutter: 8pt, {
      auto-frame(
        cetz.canvas({
          import cetz.draw: *
          let positions = ()
          for i in range(0, 360, step: 30) {
            let d = i * 1deg - 180deg
            positions.push(((5 * calc.cos(d), 5 * calc.sin(d))))
          }

          stroke((dash: "dashed"))
          line(positions.at(2), positions.at(4))

          stroke((dash: "solid"))
          for i in range(5) {
            let start = positions.at(i)
            let end = positions.at(calc.rem(i + 1, 8))
            line(start, end)
          }

          // 顺序是 4 - 2 - 1 - 3
          fill(gray.lighten(50%))
          let pos = positions.at(1)
          circle(pos, radius: 0.5, name: "circle1")
          content("circle1", $w_4$)
          content((1.2 * pos.at(0), 1.2 * pos.at(1)), $V_4$)

          pos = positions.at(2)
          circle(pos, radius: 0.5, name: "circle2")
          content("circle2", $w_2$)
          content((1.2 * pos.at(0), 1.2 * pos.at(1)), $V_2$)

          pos = positions.at(3)
          circle(pos, radius: 0.5, name: "circle3")
          content("circle3", $w_1$)
          content((1.2 * pos.at(0), 1.2 * pos.at(1)), $V_1$)

          pos = positions.at(4)
          circle(pos, radius: 0.5, name: "circle4")
          content("circle4", $w_3$)
          content((1.2 * pos.at(0), 1.2 * pos.at(1)), $V_3$)
        })
      )
    }, {
      auto-frame(
        cetz.canvas({
          import cetz.draw: *
          let positions = ()
          for i in range(0, 360, step: 30) {
            let d = i * 1deg - 180deg
            positions.push(((5 * calc.cos(d), 5 * calc.sin(d))))
          }

          stroke((dash: "dashed"))
          line(positions.at(1), positions.at(3))

          stroke((dash: "solid"))
          for i in range(5) {
            let start = positions.at(i)
            let end = positions.at(calc.rem(i + 1, 8))
            line(start, end)
          }

          // 顺序是 4 - 2 - 1 - 3
          fill(gray.lighten(50%))
          let pos = positions.at(1)
          circle(pos, radius: 0.5, name: "circle1")
          content("circle1", $w_4$)
          content((1.2 * pos.at(0), 1.2 * pos.at(1)), $V_4$)

          pos = positions.at(2)
          circle(pos, radius: 0.5, name: "circle2")
          content("circle2", $w_2$)
          content((1.2 * pos.at(0), 1.2 * pos.at(1)), $V_2$)

          pos = positions.at(3)
          circle(pos, radius: 0.5, name: "circle3")
          content("circle3", $w_1$)
          content((1.2 * pos.at(0), 1.2 * pos.at(1)), $V_1$)

          pos = positions.at(4)
          circle(pos, radius: 0.5, name: "circle4")
          content("circle4", $w_3$)
          content((1.2 * pos.at(0), 1.2 * pos.at(1)), $V_3$)
        })
      )
    }
  )
)

此时，左侧结构的最小划分代价为

$
  T_(1 2 3) + C(w_2, w_3, ..., w_4)
$

而右侧结构的最小划分代价为

$
  T_(1 2 4) + C(w_1, w_3, ..., w_4)
$

需要注意到，$C(w_1, w_3, ..., w_4)$ 不会劣于在 $C(w_2, w_3, ..., w_4)$ 的构造中将 $w_2$ 替换为 $w_1$，因此有

$
  C(w_1, w_3, ..., w_4) <= C(w_2, w_3, ..., w_4) - T_(2 3 4) + T_(1 3 4)
$

因此，如果在上述多边形中选择 $V_2 V_3$ 而非 $V_1 V_4$，则有

$
  T_(1 2 3) + C(w_2, w_3, ..., w_4) &<= T_(1 2 4) + C(w_1, w_3, ..., w_4)\
    &<= T_(1 2 4) + C(w_2, w_3, ..., w_4) - T_(2 3 4) + T_(1 3 4)
$

最后即可得到

$
  T_(1 2 3) + T_(2 3 4) &<= T_(1 2 4) + T_(1 3 4)\
  w_1 w_2 w_3 + w_2 w_3 w_4 &<= w_1 w_2 w_4 + w_1 w_3 w_4\
  1/w_1 + 1/w_4 &<= 1/w_2 + 1/w_3
$

这样就完成了该命题的证明。$qed$
]

= 水平弧

不妨从划分的稳定性入手，研究在什么情况下仅通过切换一条边无法得到更优秀的划分。

#note(title: "划分的稳定性")[
*命题*：对于一个多边形的*最优划分*，考虑其中的一个四边形 $V_a - V_b - V_c - V_d$，其中 $V_a V_c$ 是划分中的一条弧，那么必然满足

$
  1/w_a + 1/w_c >= 1/w_b + 1/w_d
$

（在等号不成立时，在这个四边形内部必须连接 $V_a V_c$。）

*证明*：在四边形内部考虑两种划分方式：一种是使用弧 $V_a V_c$，另一种是使用弧 $V_b V_d$。如果在最小划分中选择了 $V_a V_c$，对应的内部代价为

$
  T_(a b c) + T_(a c d) = w_a w_b w_c + w_a w_c w_d
$

而如果选择了 $V_b V_d$，对应的内部代价为

$
  T_(a b d) + T_(b c d) = w_a w_b w_d + w_b w_c w_d
$

因此，如果在最小划分中选择了 $V_a V_c$，则有

$
  w_a w_b w_c + w_a w_c w_d &<= w_a w_b w_d + w_b w_c w_d\
  1/w_a + 1/w_c &>= 1/w_b + 1/w_d
$

这样就完成了该命题的证明。$qed$
]

上面的命题告诉我们：对于一个最优划分，不可能存在一个四边形，使得在该四边形的两种划分方式中，代价更高的划分方式出现在最优划分中。此时就称满足上述条件的划分为*稳定划分*。不难发现，最优划分一定是稳定划分，但稳定划分不一定是最优划分。下面是一个稳定划分但非最优划分的示例：

#grid(
  columns: 2,
  figure(
    auto-frame(
      cetz.canvas({
        import cetz.draw: *
        let positions = ()
        for i in range(0, 360, step: 72) {
          let d = i * 1deg - 18deg
          positions.push(((3 * calc.cos(d), 3 * calc.sin(d))))
        }

        let numbers = (12, 40, 25, 11, 10)

        // 绘制划分的弧
        stroke((dash: "dashed"))
        line(positions.at(1), positions.at(4))
        line(positions.at(2), positions.at(4))

        stroke((dash: "solid"))
        for i in range(5) {
          let start = positions.at(i)
          let end = positions.at(calc.rem(i + 1, 5))
          line(start, end)
        }

        for i in range(5) {
          let pos = positions.at(i)
          fill(gray.lighten(50%))
          circle(pos, radius: 0.6, name: "circle" + str(i))
          content("circle" + str(i), $#numbers.at(i)$)
        }
      })
    ),
    caption: [五边形的一种稳定划分]
  ),
  figure(
    auto-frame(
      cetz.canvas({
        import cetz.draw: *
        let positions = ()
        for i in range(0, 360, step: 72) {
          let d = i * 1deg - 18deg
          positions.push(((3 * calc.cos(d), 3 * calc.sin(d))))
        }

        let numbers = (12, 40, 25, 11, 10)

        // 绘制划分的弧
        stroke((dash: "dashed"))
        line(positions.at(0), positions.at(2))
        line(positions.at(0), positions.at(3))

        stroke((dash: "solid"))
        for i in range(5) {
          let start = positions.at(i)
          let end = positions.at(calc.rem(i + 1, 5))
          line(start, end)
        }

        for i in range(5) {
          let pos = positions.at(i)
          fill(gray.lighten(50%))
          circle(pos, radius: 0.6, name: "circle" + str(i))
          content("circle" + str(i), $#numbers.at(i)$)
        }
      })
    ),
    caption: [五边形的最优划分]
  )
)

接下来，考虑划分中的一条弧 $V_a V_c$（$a < c$），假设其所在的四边形为 $V_a - V_b - V_c - V_d$（$b < d$），那么：

- 如果满足 $w_a < w_b$ 或 $w_a = w_b and w_c <= w_d$，则称 $V_a V_c$ 是*竖直*的；
- 如果满足 $w_a > w_b and w_c < w_d$，则称 $V_a V_c$ 是*水平*的。

不难发现，在四边形内部，如果一个弧不满足上述两个条件，那么必然会有 $1/w_a + 1/w_c < 1/w_b + 1/w_d$，则根据前面的分析，这条弧不可能出现在一个稳定划分中。

使用如下图片可以更直观的看出竖直弧和水平弧的定义，其中点越靠上，代表的权值越大：

#grid(
  columns: 2,
  figure(
    auto-frame(
      cetz.canvas({
        import cetz.draw: *
        let positions = ((0, 0), (3, 2), (1, 5), (-2, 3))
        let numbers = ($w_a$, $w_b$, $w_c$, $w_d$)

        // 绘制划分的弧
        stroke((dash: "dashed"))
        line(positions.at(0), positions.at(2))

        stroke((dash: "solid"))
        for i in range(4) {
          let start = positions.at(i)
          let end = positions.at(calc.rem(i + 1, 4))
          line(start, end)
        }

        for i in range(4) {
          let pos = positions.at(i)
          fill(gray.lighten(50%))
          circle(pos, radius: 0.6, name: "circle" + str(i))
          content("circle" + str(i), $#numbers.at(i)$)
        }
      })
    ),
    caption: [竖直弧的示例]
  ),
  figure(
    auto-frame(
      cetz.canvas({
        import cetz.draw: *
        let positions = ((0, 0), (3, 2), (1, 5), (-2, 3))
        let numbers = ($w_b$, $w_a$, $w_d$, $w_c$)
        
        // 绘制划分的弧
        stroke((dash: "dashed"))
        line(positions.at(1), positions.at(3))

        stroke((dash: "solid"))
        for i in range(4) {
          let start = positions.at(i)
          let end = positions.at(calc.rem(i + 1, 4))
          line(start, end)
        }

        for i in range(4) {
          let pos = positions.at(i)
          fill(gray.lighten(50%))
          circle(pos, radius: 0.6, name: "circle" + str(i))
          content("circle" + str(i), $#numbers.at(i)$)
        }
      })
    ),
    caption: [水平弧的示例]
  )
)

在接下来的部分中，我们主要将研究对象集中在水平弧上。

#note(title: "水平弧的存在条件")[
*命题*：对于多边形上任意两个不相邻的点 $V_a, V_c$，设 $V_b$ 是 $V_a V_c$ 一侧中权值最小的点，$V_d$ 是另一侧中权值最小的点。假设 $a < c, b < d$。那么在最小划分中，$V_a - V_c$ 作为水平弧存在的必要条件是：

$
  w_b < w_a <= w_c < w_d
$

#figure(
  auto-frame(
    cetz.canvas({
      import cetz.draw: *
      let ang = (10deg, 160deg, 190deg, 270deg)
      let numbers = ($w_c$, $w_d$, $w_a$, $w_b$)

      stroke((dash: "dashed"))
      circle((0, 0), radius: 4)
      line((4 * calc.cos(ang.at(0)), 4 * calc.sin(ang.at(0))), (4 * calc.cos(ang.at(2)), 4 * calc.sin(ang.at(2))))
    
      stroke((dash: "solid"))

      for i in range(4) {
        let pos = (4 * calc.cos(ang.at(i)), 4 * calc.sin(ang.at(i)))
        fill(gray.lighten(50%))
        circle(pos, radius: 0.6, name: "circle" + str(i))
        content("circle" + str(i), $#numbers.at(i)$)
      }
    })
  ),
  caption: [上述命题的图例]
)

*证明*：不难发现 $b = 1$，且 $w_a != w_1$。

如果 $a > 3$，根据前述推论，$V_1 - V_2$ 和 $V_1 - V_3$ 必然存在，并将原多边形分割为若干子多边形。如果 $V_a$ 和 $V_c$ 被分开，则该弧无法形成；否则，递归在包含 $V_a, V_c$ 的子多边形中继续上述过程，直到进入基础多边形。

在基础多边形中，根据前述定理，必有 $V_2 - V_3$ 或 $V_1 - V_4$ 存在。若 $V_2 - V_3$ 存在，则划分中存在三角形 $V_1 - V_2 - V_3$，可去除 $V_1$ 并递归；若 $V_1 - V_4$ 存在，则继续分割。如此递归，直到出现以下两种情况：

- $V_a$ 和 $V_c$ 被分开，无法形成水平弧；
- $V_a$ 和 $V_c$ 分别成为某基础多边形中的第二小和第三小的点，此时下一个操作必然是将二者相连或分开。设该多边形最小点为 $V_m$，要使 $V_a - V_c$ 作为水平弧存在，需满足 $w_m < w_a$。

回顾基础多边形的性质，有：

$
1 / w_a + 1 / w_c >= 1 / w_m + 1 / w_d
$

由于 $w_m < w_a$，可推出 $w_c > w_d$，即 $w_a <= w_c < w_d$。

综上，$V_a V_c$ 作为水平弧存在的必要条件为 $w_b < w_a <= w_c < w_d$。$qed$

将上述命题进行弱化后，可以得到水平弧在最小划分中的必要条件是：

$ V_y < V_x < V_z < V_w $
]

实际上，上面的推论有一个更加直观的解释。对于一个水平弧，若想让这个弧出现在最小划分中，那么该弧一侧的所有点都要同时大于两个端点，而另一侧需要包含 $V_1$（此时还需要保证 $w_1$ 小于两个端点的权值）。称前者形成的子多边形为*上多边形*，而后者为*下多边形*。另外，称满足上述性质的弧为*潜在水平弧*。显然，最小划分中的所有水平弧只会是潜在水平弧。

这样，我们就可以做足准备，可以开始证明这一部分的核心定理了：

#note(title: "潜在水平弧是互相兼容的")[
*命题*：对于一个多边形上的任意两个潜在水平弧，都满足它们不会在非端点处相交。

#figure(
  auto-frame(
    cetz.canvas({
      import cetz.draw: *
      let ang = (10deg, 160deg, 190deg, 270deg, 230deg, 60deg)
      let numbers = ($w_c$, $w_d$, $w_a$, $w_b$, $w_p$, $w_q$)

      stroke((dash: "dashed"))
      circle((0, 0), radius: 4)
      line((4 * calc.cos(ang.at(0)), 4 * calc.sin(ang.at(0))), (4 * calc.cos(ang.at(2)), 4 * calc.sin(ang.at(2))))
      line((4 * calc.cos(ang.at(4)), 4 * calc.sin(ang.at(4))), (4 * calc.cos(ang.at(5)), 4 * calc.sin(ang.at(5))))
    
      stroke((dash: "solid"))

      for i in range(6) {
        let pos = (4 * calc.cos(ang.at(i)), 4 * calc.sin(ang.at(i)))
        fill(gray.lighten(50%))
        circle(pos, radius: 0.6, name: "circle" + str(i))
        content("circle" + str(i), $#numbers.at(i)$)
      }
    })
  ),
  caption: [上述命题的图例]
)

*证明*：沿用前一个命题中对 $V_a, V_b, V_c, V_d$ 的定义。现在，假设存在另一条潜在水平弧 $V_p V_q$，其中 $p < q$，并且 $V_p$ 和 $V_q$ 分别位于 $V_a V_c$ 的两侧，如上图所示。

根据潜在水平弧的定义，我们有：

$
  V_a < V_c < V_d <= V_q
$

接下来，从 $V_p V_q$ 的角度考虑，注意到这条潜在水平弧的一侧需要满足所有点都大于 $V_q$，而 $V_a$ 和 $V_c$ 都小于 $V_q$，矛盾。因此，不存在在非端点处相交的潜在水平弧。$qed$
]

至此，这一部分所需要讨论的核心性质已经全部证明了。在本文的最后，给出一个基于上述性质的 $cal(O)(n)$ 寻找潜在水平弧的算法：

#success(title: "寻找潜在水平弧的单次扫描算法")[
从 $V_1$ 开始，沿着顺时针方向游走整个多边形，可以得到一个点的访问序列。此时，计算潜在水平弧实际上等价于在序列上找到所有满足“中间值大于端点值”的子区间。对于这个问题，可以使用单调栈算法计算，以下是具体的步骤：

- 任意选择一个权重最小的位置作为 $V_1$，从 $V_1$ 开始，沿着顺时针方向游走，每到达一个点就尝试将其权重加入到栈中。此时的栈实际上维护了目前凸多边形的一部分外轮廓。

- 假设栈顶元素为 $V_t$，而第二个元素是 $V_(t - 1)$。在尝试把 $V_c$ 压入栈中的时候，只要栈内还有至少两个元素，并且 $w_t > w_c$，就把 $V_c V_(t - 1)$ 列为潜在水平弧并弹出 $V_t$。持续这个过程直到无法弹出新元素之后，再把 $V_c$ 压入栈。整个过程持续到将所有点都访问完为止。
]

不难发现，这个算法实际上维护了一个单调栈，并且整个过程只需要绕着多边形走一圈，因此称这个算法为“单次扫描算法”。这个算法没有直接对点进行重标号，所以相对编号是比较灵活的，同时也避免了排序的复杂度。

#bibliography("../ref.bib")