#import "../../../config.typ": *
#import "@preview/cetz:0.4.2"

#show: template-post.with(
  title: "Natural Number Game 第七部分 / 高级加法世界",
  description: "本文介绍了 Natural Number Game 中的第七部分，主要涉及一些更复杂的加法定理，例如消去律等。",
  tags: ("数论", "Lean"),
  category: "Natural Number Game 合集",
  date: datetime(year: 2026, month: 4, day: 8)
)

#quote[
  Natural Number Game 是一个基于 Lean 4 开发的游戏，通过交互式定理证明工具，让玩家尝试证明在自然数系统上的加法、乘法、指数相关的定理。游戏的目标是通过证明各种定理来解锁新的关卡和挑战，逐步深入理解自然数的性质和相关的数学概念。你可以在 #link("https://adam.math.hhu.de/#/g/leanprover-community/nng4")[这里] 游玩 Natural Number Game。

  这个世界的前置条件是通过 #link("/posts/natural_number_game/world4/")[蕴含世界] 的所有关卡。
]

在加法世界中，我们已经证明了一些基础的定理，例如加法满足的交换律和结合律等。在这个世界中，则需要证明一些更复杂的定理，例如消去律等。

= 关卡 1

#note(title: [`add_right_cancel`（加法的右消去律）])[
  *定理* `add_right_cancel`：$a+n=b+n => a=b$。

  ```lean
  theorem add_right_cancel (a b n : ℕ) : a + n = b + n → a = b := by
  ```
]

对 `n` 进行归纳。如果 `n` 是零，那么等式两边的 `n` 都为零，直接得出 `a = b`。如果 `n` 是 `succ d`，则只需要利用 `add_succ` 移动并消除 `succ`，然后使用归纳假设即可证明。完整的代码如下：

```lean
induction n with d hd
intro h
rw [add_zero, add_zero] at h
exact h
intro h
rw [add_succ, add_succ] at h
apply succ_inj at h
apply hd at h
exact h
```

= 关卡 2

#note(title: [`add_left_cancel`（加法的左消去律）])[
  *定理* `add_left_cancel`：$n+a=n+b => a=b$。

  ```lean
  theorem add_left_cancel (a b n : ℕ) : n + a = n + b → a = b := by
  ```
]

使用加法的交换律将等式两边的 `n` 移动到等式的右侧，然后使用之前证明的 `add_right_cancel` 定理即可证明。完整的代码如下：

```lean
rw [add_comm n a, add_comm n b]
exact add_right_cancel a b n
```

= 关卡 3

#note(title: [`add_left_eq_self`（左加法恒等律）])[
  *定理* `add_left_eq_self`：$x+y=y => x=0$。

  ```lean
  theorem add_left_eq_self (x y : ℕ) : x + y = y → x = 0 := by
  ```
]

只需要使用逆向的 `zero_add` 将等式右侧的 `y` 替换为 `0 + y`，然后使用之前证明的 `add_right_cancel` 定理即可证明。完整的代码如下：

```lean
nth_rewrite 2 [← zero_add y]
exact add_right_cancel x 0 y
```

= 关卡 4

#note(title: [`add_right_eq_self`（右加法恒等律）])[
  *定理* `add_right_eq_self`：$x+y=x => y=0$。

  ```lean
  theorem add_right_eq_self (x y : ℕ) : x + y = x → y = 0 := by
  ```
]

只需要使用逆向的 `add_zero` 将等式右侧的 `x` 替换为 `x + 0`，然后使用之前证明的 `add_left_cancel` 定理即可证明。完整的代码如下：

```lean
nth_rewrite 2 [← add_zero x]
exact add_left_cancel y 0 x
```

（注：也可以使用交换律交换等式左侧，然后使用 `add_left_eq_self`。）

= 关卡 5

#note(title: [`add_right_eq_zero`（右加法恒零律）])[
  *定理* `add_right_eq_zero`：如果 $a+b=0$ 那么 $a=0$。

  ```lean
  theorem add_right_eq_zero (a b : ℕ) : a + b = 0 → a = 0 := by
  ```
]

在 Lean 中，可以使用 `cases` 进行分类讨论。对于这个定理，我们需要对 `b` 进行分类讨论：

- 如果 `b` 是零，那么等式两边的 `b` 都为零，直接得出 `a = 0`。
- 如果 `b` 是 `succ d`，则等式左侧的 `a + b` 可以重写为 `a + succ d`，然后使用 `add_succ` 将其重写为 `succ (a + d)`，这与等式右侧的零不相等，因此这种情况不可能发生。

完整的代码如下：

```lean
cases b with d
intro h
rw [add_zero] at h
exact h
intro h
rw [add_succ] at h
apply succ_ne_zero at h
trivial
```

= 关卡 6

#note(title: [`add_left_eq_zero`（左加法恒零律）])[
  *定理* `add_left_eq_zero`：如果 $a+b=0$ 那么 $b=0$。

  ```lean
  theorem add_left_eq_zero (a b : ℕ) : a + b = 0 → b = 0 := by
  ```
]

只需要使用加法的交换律将等式两边的 `a` 移动到等式的右侧，然后使用之前证明的 `add_right_eq_zero` 定理即可证明。完整的代码如下：

```lean
rw [add_comm a b]
exact add_right_eq_zero b a
```