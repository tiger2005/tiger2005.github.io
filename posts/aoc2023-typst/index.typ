#import "../../config.typ": *
#import "@preview/cetz:0.4.2"

#show: template-post.with(
  title: "使用 Typst 完成 Advent of Code 2023 之后，我学到了什么？",
  description: "本文是我在使用 Typst 完成 Advent of Code 2023 之后的一些心得和体会。在这篇文章中，我将分析 Typst 在编写算法竞赛题目方面的局限性，并分享一些有趣的实现细节。",
  tags: ("Typst", ),
  category: "Natural Number Game 合集",
  date: datetime(year: 2026, month: 4, day: 13)
)

在前两天（准确来说，是 2026 年 4 月 11 日和 4 月 12 日），我在 B 站上进行了人生中第一次个人账号直播。在直播中，我使用 Typst 完成了 #link("https://adventofcode.com/2023")[Advent of Code 2023] 的所有题目，没有调用任何外部工具，没有使用硬编码将答案直接写在代码里，而是完全按照题目的要求来编写代码并得到正确的答案。

在这篇文章中，我将会借助本次直播的心得，简单分析 Typst 在完成算法竞赛题目层面可能遇到的困难，并且分享一些比较有趣的实现。

#quote[
  你可以在 #link("https://github.com/tiger2005/AoC2023-Typst")[这个仓库] 查看所有题目对应的 Typst 代码。

  另外，你也可以在 #link("https://space.bilibili.com/350620554")[我的 B 站账号] 上查看所有直播回放。
]

= Typst 在编程时的局限性

作为一门排版语言，Typst 实际上并不专注于编写高性能算法，而是在适量的代码辅助下，对页面元素或外部资源进行分析和调整，从而生成美观、精确、易于调整的编译产物。另外，Typst 还支持 `watch` 功能，也即在修改源代码后进行增量编译，并实时提供预览结果。

在算法竞赛层面，Typst 有四个比较棘手的特性：

- Typst 要求 `while` 循环的执行次数不能超过 10000 次。`for..in` 语法并不会受到循环次数的限制，不过考虑到创建 `range` 进行枚举依然需要一定的内存开销，因此在某些情况下使用 `while` 还是很有必要的。
- Typst 要求递归函数的深度不能超过 80 层。这个要求对于某些图论算法来说是致命的，主要影响需要深度优先搜索的算法。在实际实现时，可能需要通过一些策略将其转化为广度优先搜索，或者直接通过栈模拟的方式进行。
- Typst 在执行函数体时，外部变量都是只读变量（如果你熟悉 C++ 中 lambda 函数的概念，可以认为所有函数的捕获都是值捕获）。这会严重影响一些算法的可行性，并促使我们通过无函数的策略实现它们。上述两个特性相互结合，共同导致了一些题目的实现难度大大增加。
- Typst 的数据结构相对简单，并且在设计上不存在引用的概念。加上 Typst 自身的内存管理机制，这使得我们在实现一些算法时需要格外注意内存的使用情况，尤其是在处理大量数据或需要频繁修改数据结构的算法时。

在上述的四个特性中，前三个特性和 Typst 的底层逻辑相对独立，而最后一个则与 Typst 中数据结构的设计密切相关。因此，为了更好的理解 Typst 在算法实现方面的局限性，我们还需要简单了解一下 Typst 的数据结构设计。

= Typst 的数据结构

Typst 原生支持如下的数据结构：

=== 基础数据类型
- `none`：空类型，表示没有值。
- `int`：整数类型，用于存储整数数据。
- `float`：浮点数类型，用于存储小数数据。
- `bool`：布尔类型，用于存储真或假的值。
- `decimal`：十进制数类型，用于存储高精度的小数数据。

=== 复合数据类型
- `bytes`：字节类型，用于存储二进制数据。
- `str`：字符串类型，用于存储文本数据。
- `array`：数组类型，用于存储有序的元素集合。
- `dict`：字典类型，用于存储键值对集合。

=== 其他数据类型
- `function`：函数类型，用于定义可调用的代码块。
- `regex`：正则表达式类型，用于定义和匹配字符串模式。
- `module`：模块类型，用于组织和封装代码。
  - `std`：标准库模块，是所有内置函数和数据结构的集合。
  - `calc`：计算模块，提供了数学计算相关的函数。
- 还有其他的一些类型，例如 `arguments`、`datetime` 等等，考虑到它们在算法实现中的使用频率较低，这里就不再赘述了。

在上述数据结构中，一部分基础类型可以通过 Rust 内置的类型直接映射到 Typst 中，例如 `int`、`float`、`bool`（它们分别对应了 Rust 中的 `i64`、`f64`、`bool`）。而其他一些类型则是通过更为复杂的结构体实现的。例如：

- `decimal` 的底层实现是：

  ```rust
  pub struct Decimal(rust_decimal::Decimal);
  ```

  可以看到，`decimal` 是通过一个 Rust 结构体来封装 `rust_decimal::Decimal` 类型实现的。这个库实际上是一个用于金融计算的高精度十进制数库，提供了比 `f64` 更高的精度和更好的舍入控制。
- `array` 的底层实现是：

  ```rust
  pub struct Array(EcoVec<Value>);
  ```

  可以看到，`array` 是通过一个 Rust 结构体来封装 `EcoVec<Value>` 类型实现的。`EcoVec` 是一个支持写时复制（copy-on-write）的动态数组类型，通过引用计数和内部共享来优化内存使用和性能。
- `dict` 的底层实现是：

  ```rust
  pub struct Dict(Arc<IndexMap<Str, Value, FxBuildHasher>>);
  ```

  可以看到，`dict` 是通过一个 Rust 结构体来封装 `Arc<IndexMap<Str, Value, FxBuildHasher>>` 类型实现的。`IndexMap` 是一个基于哈希表的数据结构，提供了键值对的存储和快速访问，而 `Arc` 则是一个线程安全的引用计数智能指针，用于共享数据。

  需要注意的是，在枚举 Typst 中的 `dict` 时，其顺序实际上是键值对被加入字典的顺序，而不是按照键的字典序进行排序的。另外，项字典加入和查询的时间复杂度都是 $cal(O) (1)$ 的，而在删除时的时间复杂度是 $cal(O) ("size")$ 的。

尽管 Typst 在底层通过引用计数和写时复制，在一定程度上挽回了性能的损失，但在算法实现层面，我们依然需要注意 `array` 等数据结构的使用方法。考虑如下函数：

```typ
#{
  let s(arr) = {
    return arr.sum()
  }

  let f(arr) = {
    arr.at(0) = 1
    return arr
  }
}
```

此时函数 `s` 由于只是对 `arr` 进行求和，并没有修改 `arr` 的内容，因此在调用时会直接共享 `arr` 的数据，而不会产生新的内存开销。而函数 `f` 则会修改 `arr` 的内容，因此在调用时会创建一个新的 `array`，并将原来的数据复制到新的 `array` 中，然后再进行修改。这就导致了函数 `f` 的性能可能会受到较大的影响，尤其是在处理大型数组时。

因此，在具体的算法实现中，我们需要尽量避免对 `array` 进行修改，在修改时也尽可能减少可能带来的复制操作。这一点在后续的实现中会有一些比较有趣的例子，我们会在后续的文章中进行分享。

= 如何处理 Typst 带来的困难？

面对 Typst 在算法实现方面的局限性，我们可以通过一些策略来克服这些困难：

- 对于循环次数的限制，可以通过嵌套多次循环来实现更大的循环次数，例如：

  ```typ
  #{
    while cond {
      let remain = 9999
      while cond and remain > 0 {
        remain -= 1
        // ...
      }
    }
  }
  ```
- 对于递归深度的限制，可以通过将递归转化为迭代的方式来实现，例如：

  ```typ
  #{
    let path = ((start, 0))
    while path.len() > 0 {
      let (node, index) = path.pop()
      // ...
      path.push((node, index + 1))
      path.push((neighbor, 0))
      // ...
    }
  }
  ```
- 对于函数体内外部变量的只读限制，需要我们手动规避函数体内修改变量的需求。一种可行的方式是将修改需求通过返回值传递到外界，而另一种可行的方案则是直接不使用函数，不过这一种方案可能会导致代码的可读性和可维护性下降，因此需要根据具体情况进行权衡。

- 对于数据结构的限制，我们需要尽量避免对 `array` 进行修改，在修改时也尽可能减少可能带来的复制操作（例如在非必要的情况下对某一个数组产生副本，并进行修改）。

= 一些有趣的实现

== 中国剩余定理

在第 8 题中，需要解决一个在字符集为 `{L, R}` 的自动机上进行转移模拟的问题。在第二部分中，我们被给出六个起点、六个终点和一个不断循环的转移规则，需要计算出从起点开始同时转移，在最终同时达到六个终点的最小时间。

实际上，Advent of Code 给出的数据总是存在一定的特殊性，例如在这道题中，每个起点实际上只能到达一个终点，并且每个终点也只能由一个起点到达。这就允许我们将原问题拆分成六个独立的子问题来进行求解。每个子问题的求解可以通过暴力模拟来完成，得到一个关于时间 $t$ 的同余方程。最终，我们需要通过中国剩余定理来求解这六个同余方程，从而得到最终的答案。以下是第 8 题中第二部分的完整代码：

```typ
#import "../../utils.typ": *

#let solve-part2() = {
  let input = read("./in").trim().split("\n").map(s => s.trim())

  let moves = input.at(0)
  let n = input.len() - 2
  let movel = (:)
  let mover = (:)
  let middle = (:)
  let next = (:)

  let reg = regex("([0-9A-Z]{3}) = \(([0-9A-Z]{3}), ([0-9A-Z]{3})\)")
  for nodes in input.slice(2) {
    let (p, l, r) = nodes.match(reg).captures
    movel.insert(p, l)
    mover.insert(p, r)
  }

  for ele in movel.keys() {
    let current = ele
    let i = 0
    let met = ()
    while i != moves.len() {
      current = if moves.at(i) == "L" {
        movel.at(current)
      } else {
        mover.at(current)
      }
      i = i + 1
      if (current.ends-with("Z")) {
        met.push((current, i))
      }
    }
    middle.insert(ele, met)
    next.insert(ele, current)
  }

  let first-two-meet(a, b) = {
    let meets = ()
    for i in range(2 * n) {
      if (meets.len() >= 2) {
        break
      }
      let v = middle.at(a)
      for ele in v {
        if ele.at(0) == b {
          meets.push(moves.len() * i + ele.at(1))
        }
      }
      a = next.at(a)
    }
    return meets.slice(0, calc.min(meets.len(), 2))
  }

  let S = movel.keys().filter(x => x.ends-with("A"))
  let T = movel.keys().filter(x => x.ends-with("Z"))

  let A = 1
  let B = 1

  let euclid(a, b) = {
    if (b == 0) {
      return (a, 1, 0)
    }
    let (gcd, y, x) = euclid(b, calc.rem(a, b))
    y -= x * calc.floor(a / b)
    return (gcd, x, y)
  }

  for u in S {
    for v in T {
      if (first-two-meet(u, v).len() != 0) {
        let (C, D) = first-two-meet(u, v)
        D -= C
        let (g, x, y) = euclid(B, D)
        let num = calc.rem(C - A, D)
        if (num < 0) {
          num += D
        }
        num = calc.floor(num / g)
        B = calc.floor(B / g)
        D = calc.floor(D / g)
        x = calc.rem(x * num, D)
        if (x < 0) {
          x += D
        }

        A = A + (B * g) * x
        B = B * D * g
      }
    }
  }

  print(A)
}
```

（注：在完成上述代码之后，我才发现每一个子问题中的限制恰好都是诸如“$t$ 是某一个整数的倍数”的类型，所以直接用 `calc.lcm` 合并答案即可。）

== 手写堆

在第 17 题中，我们需要在一个二维网格中进行路径搜索，其中每个格子存在一个权值，并且对路径选取存在一些限制条件。为了解决这个问题，除了通过建立分层图解决限制条件之外，我们还需要在这个分层图上跑 Dijkstra 算法来找到最短路径。

考虑到 Typst 中没有内置的优先队列数据结构，我们需要手动实现一个堆来满足 Dijkstra 算法的需求。这个时候就会存在一个需要注意的设计细节。如果通过 `hpush(heap, ele)` 和 `hpop(heap)` 函数封装堆的插入和删除操作，那么在每次调用 `hpush` 和 `hpop` 时，都会产生一个新的 `array`，并将原来的数据复制到新的 `array` 中，这会导致性能的严重下降。在实际运行中，带封装的代码成功把我的电脑内存吃满了，导致直播不得不中断（这也是直播回放中第二部分分作两次的原因）。

因此，在实现堆的过程中，需要直接在原来的 `array` 上进行修改，而没有通过函数封装来进行操作。虽然这会导致代码的可读性和可维护性下降，但在性能方面却有了显著的提升，最终成功地通过了测试用例。以下是第 17 题中第二部分的完整代码：

```typ
#import "../../utils.typ": *

#let solve-part2() = {
  let input = read("./in").trim().split("\n").map(s => s.trim())

  let dir = ((-1, 0), (0, -1), (1, 0), (0, 1))

  input = input.map(line => line.codepoints())
  let n = input.len()
  let m = input.at(0).len()

  let dir = ((-1, 0), (0, -1), (1, 0), (0, 1))

  let dp = ((((1000000000,) * 10,) * 4,) * m,) * n
  dp.at(0).at(1).at(3).at(0) = int(input.at(0).at(1))

  dp.at(1).at(0).at(2).at(0) = int(input.at(1).at(0))

  let heap = ((int(input.at(0).at(1)), 0, 1, 3, 0), (int(input.at(1).at(0)), 1, 0, 2, 0))

  if heap.at(0) > heap.at(1) {
    let temp = heap.at(0)
    heap.at(0) = heap.at(1)
    heap.at(1) = temp
  }
  
  let flag = false
  let ans = 0

  while heap.len() != 0 and not flag {
    let remain = 9999
    while heap.len() != 0 and not flag and remain > 0 {
      remain -= 1
      let ele = heap.at(0)
      if heap.len() == 1 {
        let _ = heap.pop()
      } else {
        heap.at(0) = heap.pop()
        let pos = 1
        while true {
          let lhs = pos * 2
          let rhs = pos * 2 + 1
          let mn = 0
          if lhs > heap.len() {
            break
          } else if rhs > heap.len() {
            mn = lhs
          } else {
            mn = if heap.at(rhs - 1) < heap.at(lhs - 1) {
              rhs
            } else {
              lhs
            }
          }

          if heap.at(pos - 1) > heap.at(mn - 1) {
            let temp = heap.at(mn - 1)
            heap.at(mn - 1) = heap.at(pos - 1)
            heap.at(pos - 1) = temp
            pos = mn
          } else {
            break
          }
        }
      }

      let (w, x, y, d, cnt) = ele

      if x == n - 1 and y == m - 1 and cnt >= 3 {
        ans = w
        flag = true
        break
      }

      for nd in (0, 1, 2, 3) {
        if (calc.rem(d - nd + 4, 4) == 2) {
          continue
        }
        if (d != nd and cnt < 3) {
          continue
        }
        let nx = x + dir.at(nd).at(0)
        let ny = y + dir.at(nd).at(1)

        if nx >= 0 and nx < n and ny >= 0 and ny < m {
          let nc = if (d == nd) { cnt + 1 } else { 0 }
          if nc <= 9 {
            let nw = w + int(input.at(nx).at(ny))
            if (nw < dp.at(nx).at(ny).at(nd).at(nc)) {
              dp.at(nx).at(ny).at(nd).at(nc) = nw
              let ele = (nw, nx, ny, nd, nc)

              heap.push(ele)
              let pos = heap.len()
              while pos != 1 {
                let f = calc.floor(pos / 2)
                if (heap.at(f - 1) > heap.at(pos - 1)) {
                  let temp = heap.at(f - 1)
                  heap.at(f - 1) = heap.at(pos - 1)
                  heap.at(pos - 1) = temp
                  pos = f
                } else {
                  break
                }
              }
            }
          }
        }
      }
    }
  }

  print(ans)
}
```

== 计算几何

在第 24 题中的第二部分中，我们需要解决如下问题：在三维空间中存在一些物体，它们从某个位置开始以某个速度进行匀速运动。我们需要在某一个整点抛出一个新的物体，使得它能够与所有其他物体在某一个时刻相遇。

需要注意到，这个问题可以在两个二维投影上进行求解（例如 $O x y$ 平面和 $O y z$ 平面）。在每一个二维投影上，通过观察可以确认新的物体的速度大概在 $[-500, 500]$ 范围之内，因此可以在暴力枚举速度后，通过叉积得到二元一次方程组，最终通过求解方程组来得到满足条件的时间 $t$。

在 Typst 中编写计算几何的代码实际上并不困难，不过个人感觉比较有意思，因此就放上来了。以下是第 24 题中第二部分的完整代码：

```typ
#import "../../utils.typ": *

#let solve-part2() = {
  let input = read("./in").trim().split("\n").map(s => s.trim())
  
  let rays = ()
  
  for line in input {
    let (p, v) = line.split(" @ ").map(c => c.split(", ").map(s => decimal(s.trim())))
    rays.push((p, v))
  }

  let scale(vec, theta) = {
    return (vec.at(0) * theta, vec.at(1) * theta)
  }

  let vec-add(vec1, vec2) = {
    return (
      vec1.at(0) + vec2.at(0),
      vec1.at(1) + vec2.at(1)
    )
  }

  let vec-sub(vec1, vec2) = {
    return (
      vec1.at(0) - vec2.at(0),
      vec1.at(1) - vec2.at(1)
    )
  }

  let dot(vec1, vec2) = {
    return vec1.at(0) * vec2.at(0) + vec1.at(1) * vec2.at(1)
  }

  let cross(vec1, vec2) = {
    return vec1.at(0) * vec2.at(1) - vec1.at(1) * vec2.at(0)
  }

  let B = 500

  let linear-system(l1, l2) = {
    let (a1, b1, c1) = l1
    let (a2, b2, c2) = l2

    if a1 * b2 == a2 * b1 {
      if a1 * c2 == a2 * c1 and b1 * c2 == b2 * c1 {
        return (1, none)
      } else {
        return (-1, none)
      }
    }

    let x = - (c1 * b2 - c2 * b1) / (a1 * b2 - a2 * b1)
    let y = - (c1 * a2 - c2 * a1) / (b1 * a2 - b2 * a1)

    return (0, (x, y))
  }

  let eps = decimal("0.000001")

  let fit(p, l) = {
    let (a, b, c) = l
    let (x, y) = p
    return calc.abs(a * x + b * y + c) < eps
  }

  let solve(rays) = {
    let res = ()

    for v1 in range(-B, B + 1) {
      for v2 in range(-B, B + 1) {
        let cline = none
        let point = none
        let flg = true
        for (p, v) in rays {
          let (a, b) = p
          let (c, d) = v

          let A = v2 - d
          let B = v1 - c
          
          let line = (A, -B, B * b - A * a)
          if point != none {
            if not fit(point, line) {
              flg = false
              break
            }
          } else if cline == none {
            cline = line
          } else {
            let (res, p) = linear-system(cline, line)
            if res == -1 {
              flg = false
              break
            } else if res == 0 {
              point = p
              if calc.abs(calc.round(p.at(0)) - p.at(0)) > eps {
                flg = false
                break
              }

              if calc.abs(calc.round(p.at(1)) - p.at(1)) > eps {
                flg = false
                break
              }
            }
          }
        }

        if point != none and flg {
          let (x, y) = point
          res.push((x, y, v1, v2))
        }
      }
    }
    
    return res
  }

  let plane-xy = rays.map(ray => ray.map(
    e => (e.at(0), e.at(1))
  ))

  let plane-yz = rays.map(ray => ray.map(
    e => (e.at(1), e.at(2))
  ))

  let res1 = solve(plane-xy)
  let res2 = solve(plane-yz)

  assert(res1.len() == 1)
  assert(res2.len() == 1)
  let px = res1.at(0).at(0)
  let py = res1.at(0).at(1)
  let pz = res2.at(0).at(1)
  
  px = int(calc.floor(float(px)))
  py = int(calc.floor(float(py)))
  pz = int(calc.floor(float(pz)))
  
  let ans = px + py + pz
  print(ans)
}
```

== 栈模拟递归版本的 Dinic

在第 25 题中，我们需要对一个无源汇最小割为 $3$ 的网络计算出其最小割得到的两个点集。除了使用经典的随机化算法（随机找一条边缩成一个点，直到整张图只剩下两个点）之外，我们还可以通过 Dinic 算法来求解最小割。考虑到 Typst 中只能支持 80 层的递归深度，我们需要通过栈来模拟递归版本的 Dinic 算法。

这无疑是本次 Advent of Code 中最为复杂的一个实现了，以下是第 25 题的完整代码：

```typ
#import "../../utils.typ": *

#let solve-part1() = {
  let input = read("./in").trim().split("\n").map(s => s.trim())

  let names = ()
  
  for line in input {
    let reg = regex("[a-z]{3}")
    for ele in line.matches(reg) {
      names.push(ele.text)
    }
  }

  names = names.dedup()
  let n = names.len()

  let graph = ()
  let head = (-1,) * n
  let m = 0

  for line in input {
    let (s, ts) = line.split(": ")
    let sid = names.position(e => e == s)

    for ele in ts.split(" ") {
      let tid = names.position(e => e == ele)
      graph.push((tid, 1, head.at(sid)))
      head.at(sid) = m
      m += 1

      graph.push((sid, 0, head.at(tid)))
      head.at(tid) = m
      m += 1

      graph.push((sid, 1, head.at(tid)))
      head.at(tid) = m
      m += 1

      graph.push((tid, 0, head.at(sid)))
      head.at(sid) = m
      m += 1      
    }
  }

  let dinic(graph, head, s, t) = {
    let max-flow = 0

    for _ in range(4) {
      let curr = head
      let vis = (1e9,) * n
      vis.at(s) = 0

      let stk1 = (s,)
      let stk2 = ()

      while stk1.len() + stk2.len() > 0 {
        if stk1.len() == 0 {
          stk1 = stk2.rev()
          stk2 = ()
        }

        let u = stk1.pop()
        let i = head.at(u)

        while i != -1 {
          let (v, w, nxt) = graph.at(i)
          if vis.at(v) == 1e9 and w != 0 {
            vis.at(v) = vis.at(u) + 1
            stk2.push(v)
          }
          i = nxt
        }
      }

      if vis.at(t) == 1e9 {
        break
      }

      let path = ((s, 100000, 0, false),)
      let func-return = 0

      while path.len() > 0 {
        let remain = 9999
        while path.len() > 0 and remain > 0 {
          remain -= 1

          let (node, flow, res, ty) = path.pop()

          if node == t {
            func-return = flow
            continue
          }

          let id = curr.at(node)

          if ty {
            flow -= func-return
            res += func-return
            graph.at(id).at(1) -= func-return
            graph.at(id.bit-xor(1)).at(1) += func-return
            
            id = graph.at(id).at(2)
          }

          let flag = false
          while id != -1 {
            let (v, w, nxt) = graph.at(id)
            curr.at(node) = id
            
            if vis.at(v) == vis.at(node) + 1 and w > 0 {
              path.push((node, flow, res, true))
              path.push((v, calc.min(flow, w), 0, false))
              flag = true
              break
            }

            id = nxt
          }

          if not flag {
            func-return = res
          }
        }
      }

      max-flow += func-return
    }

    let lhs = ()
    let queue = (s,)
    let vis = (false,) * n
    while queue.len() > 0 {
      let x = queue.pop()
      vis.at(x) = true
      lhs.push(x)
      let id = head.at(x)
      while id != -1 {
        let (v, w, nxt) = graph.at(id)
        if w != 0 and not vis.at(v) {
          vis.at(v) = true
          queue.push(v)
        }
        id = nxt
      }
    }

    return (max-flow, lhs)
  }

  let ans = 0
  for i in range(1, n) {
    let (flow, side) = dinic(graph, head, 0, i)
    if flow == 3 {
      let a = side.len()
      let b = n - a
      ans = a * b
      break
    }
  }

  print(ans)
}
```

= 总结

尽管 Typst 在编写算法竞赛题目上存在诸多不便，不过其强大的增量编译和预览的功能，在某种程序上提供了非常好的交互体验。我可以在编写的过程中实时看到代码的运行结果，例如在一些和二维平面相关的题目中，我可以直接在预览中看到字符矩阵的变化，这对于调试和理解算法的运行过程提供了极大的帮助。（这也许是 Typst 写算法竞赛题目唯一的优势？）

总的来说，通过这次 Advent of Code 的经历，我对 Typst 在算法实现方面的局限性有了更深入的理解，并且也学会了一些在 Typst 中编写算法的技巧和策略。希望在未来能够看到 Typst 能够处理更多的算法题目，并且能够在性能方面有更好的表现。