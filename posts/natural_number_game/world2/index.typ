#import "../../../config.typ": *
#import "@preview/cetz:0.4.2"

#show: template-post.with(
  title: "Natural Number Game 第二部分 / 加法世界",
  description: "本文是 Natural Number Game 的第二部分，主要介绍了 Lean 中的归纳法证明策略，并通过一系列关卡证明了加法的交换律与结合律等定理。",
  tags: ("数论", "Lean"),
  category: "Natural Number Game 合集",
  date: datetime(year: 2026, month: 4, day: 7)
)

#quote[
  Natural Number Game 是一个基于 Lean 4 开发的游戏，通过交互式定理证明工具，让玩家尝试证明在自然数系统上的加法、乘法、指数相关的定理。游戏的目标是通过证明各种定理来解锁新的关卡和挑战，逐步深入理解自然数的性质和相关的数学概念。你可以在 #link("https://adam.math.hhu.de/#/g/leanprover-community/nng4")[这里] 游玩 Natural Number Game。

  这个世界的前置条件是通过 #link("/posts/natural_number_game/world1/")[教程世界] 的所有关卡。
]

在这个世界中，我们主要学习如何在 Lean 中使用归纳法（`induction`）策略，并在最终证明加法的交换律与结合律。

= 关卡 1

#note(title: [`zero_add`（零加）])[
  *定理* `zero_add`：对于所有自然数 $n$，我们有 $0 + n = n$。

  ```lean
  theorem zero_add (n : ℕ) : 0 + n = n := by
  ```
]

在教程关卡中，我们已经知道如何处理加零的情况（`add_zero`），以及加后继的情况（`add_succ`）。为了证明零加上一个自然数等于该自然数，我们可以使用归纳法来证明这个定理。

在 Lean 中，可以使用 ```lean induction n with d hd``` 来对自然数 `n` 进行归纳证明。这里，`d` 是 `n` 的前一个自然数，而 `hd` 是归纳假设。随后，原问题会被拆分成两个子问题：

- 当 `n` 是零时，我们需要证明 `0 + 0 = 0`。
- 当 `n` 是自然数 `d` 的后继时，根据归纳假设 `hd : 0 + d = d`，我们需要证明 `0 + succ d = succ d`。

第一个子问题只需要使用 `add_zero` 定理来完成证明，而第二个子问题则需要先使用 `add_succ` 定理将 `0 + succ d` 转换为 `succ (0 + d)`，然后利用归纳假设 `hd` 将内部的 `0 + d` 替换为 `d`。

在 Lean 中使用归纳法时，需要按顺序将二者的证明都写出来，从而完成整个定理的证明。完整的代码如下：

```lean
induction n with d hd
rw [add_zero]
rfl
rw [add_succ, hd]
rfl
```

= 关卡 2

#note(title: [`succ_add`（后继加）])[
  *定理* `succ_add`：对于所有自然数 $a$ 和 $b$，我们有 $"succ"(a) + b = "succ"(a + b)$。

  ```lean
  theorem succ_add (a b : ℕ) : succ a + b = succ (a + b) := by
  ```
]

这里，只需要对 `b` 进行归纳证明即可。`b` 等于 `0` 的情况可以直接使用 `add_zero` 定理来证明，而 `b` 是自然数 `d` 的后继的情况（也就是要证明 `succ (succ a + d) = succ (succ (a + d))`）：

+ 先使用 `add_succ` 定理将 `succ a + succ d` 转换为 `succ (succ a + d)`；
+ 然后利用归纳假设 `hd` 将内部的 `succ a + d` 替换为 `succ (a + d)`，此时目标的左侧为 `succ (succ (a + d))`；
+ 最后再次使用 `add_succ` 定理将右侧也转换为 `succ (succ (a + d))`。

完整的代码如下：

```lean
induction b with d hd
repeat rw [add_zero]
rfl
rw [add_succ, hd, add_succ]
rfl
```

= 关卡 3

#note(title: [`add_comm`（加法交换律）])[
  *定理* `add_comm`：在自然数集上，加法是可交换的。 换句话说，如果 $a$ 和 $b$ 是任意自然数，那么 $a + b = b + a$。

  ```lean
  theorem add_comm (a b : ℕ) : a + b = b + a := by
  ```
]

前面的定理已经能让我们轻松证明这个定理了，这里只需要任选 `a` 或 `b` 进行归纳证明即可。这里我们选择对 `b` 进行归纳证明：

```lean
induction b with d hd
rw [add_zero, zero_add]
rfl
rw [add_succ, hd, succ_add]
rfl
```

= 关卡 4

#note(title: [`add_assoc`（加法结合律）])[
  *定理* `add_assoc`：在自然数集上，加法服从结合律。 换句话说，如果 $a$，$b$ 和 $c$ 是任意自然数，我们有 $(a + b) + c = a + (b + c)$。

  ```lean
  theorem add_assoc (a b c : ℕ) : a + b + c = a + (b + c) := by
  ```
]

此时依然任选 `a`、`b` 或 `c` 进行归纳证明即可。在证明归纳步骤时，不断使用已有的定理来重写目标，最终将目标简化为 `succ (...) = succ (...)`，使用 `rfl` 来完成证明。以下给出了对 `c` 进行归纳证明的完整代码：

```lean
induction c with d hd
rw [add_zero, add_zero]
rfl
rw [add_succ, add_succ, add_succ, hd]
rfl
```

（注：在上述定理的支撑下，我们就证明了自然数是一个加法交换幺半群。）

= 关卡 5

#note(title: [`add_right_comm`（加法右交换律）])[
  *定理* `add_right_comm`：如果 $a$，$b$ 和 $c$ 是任意自然数，我们有 $(a + b) + c = (a + c) + b$。

  ```lean
  theorem add_right_comm (a b c : ℕ) : a + b + c = a + c + b := by
  ```
]

这个定理主要是为了解决使用加法交换律时无法快速交换后两个数字的问题。为了证明这个定理，可以先分别使用结合律将目标的两侧重写为 `a + (b + c)` 和 `a + (c + b)`，然后使用加法交换律将 `c + b` 替换为 `b + c`。完整的代码如下：

```lean
rw [add_assoc, add_assoc, add_comm b c]
rfl
```