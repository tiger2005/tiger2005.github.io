#import "../../../config.typ": *
#import "@preview/cetz:0.4.2"

#show: template-post.with(
  title: "Natural Number Game 第八部分 / ≤ 世界",
  description: "本文介绍了 Natural Number Game 中的第八部分，主要涉及自然数上的不等关系 ≤ 的一些基本定理，例如反身律、传递律、全序等。",
  tags: ("数论", "Lean"),
  category: "Natural Number Game 合集",
  date: datetime(year: 2026, month: 4, day: 8)
)

#quote[
  Natural Number Game 是一个基于 Lean 4 开发的游戏，通过交互式定理证明工具，让玩家尝试证明在自然数系统上的加法、乘法、指数相关的定理。游戏的目标是通过证明各种定理来解锁新的关卡和挑战，逐步深入理解自然数的性质和相关的数学概念。你可以在 #link("https://adam.math.hhu.de/#/g/leanprover-community/nng4")[这里] 游玩 Natural Number Game。

  这个世界的前置条件是通过 #link("/posts/natural_number_game/world7/")[高级加法世界] 的所有关卡。
]

在 Lean 中，`a ≤ b` 的定义是存在一个自然数 `c` 使得 `b = a + c`。在这个世界中，我们将证明一些关于 `≤` 的反身律、传递律等定理，并将其和加法、乘法相互作用。

= 关卡 1

#note(title: [`use` 策略])[
  *定理* `le_refl`：如果 $x$ 是数字，那么 $x <= x$。

  ```lean
  theorem le_refl (x : ℕ) : x ≤ x := by
  ```
]

在 Lean 中，考虑到 `x ≤ x` 本质上是一个存在性命题，则可以使用 `use c` 来对应选择一个具体的值。在这个定理中，我们可以使用 `use 0`，将目标 `x ≤ x` 转化为 `x = x + 0`，然后使用 `add_zero` 定理来证明。完整的代码如下：

```lean
use 0
rw [add_zero]
rfl
```

= 关卡 2

#note(title: [0 ≤ x])[
  *定理* `zero_le`：如果 $x$ 是自然数，则 $0 ≤ x$。

  ```lean
  theorem zero_le (x : ℕ) : 0 ≤ x := by
  ```
]

使用 `use x` 将目标 `0 ≤ x` 转化为 `x = 0 + x`，然后使用 `zero_add` 定理来证明。完整的代码如下：

```lean
use x
rw [zero_add]
rfl
```

= 关卡 3

#note(title: [x ≤ succ x])[
  *定理* `le_succ_self`：如果 $x$ 是自然数，则 $x ≤ "succ"(x)$。

  ```lean
  theorem le_succ_self (x : ℕ) : x ≤ succ x := by
  ```
]

使用 `use 1` 将目标 `x ≤ succ x` 转化为 `succ x = x + 1`，然后使用 `succ_eq_add_one` 定理来证明。完整的代码如下：

```lean
use 1
exact succ_eq_add_one x
```

= 关卡 4

#note(title: [x ≤ y 且 y ≤ z 意味着 x ≤ z])[
  *定理* `le_trans`：如果 $x ≤ y$ 且 $y ≤ z$，那么 $x ≤ z$。

  ```lean
  theorem le_trans (x y z : ℕ) (hxy : x ≤ y) (hyz : y ≤ z) : x ≤ z := by
  ```
]

此时存在性命题出现在假设中，在 Lean 的体系下需要使用 `cases` 来进行分类讨论。对于 `hxy : x ≤ y`，我们可以使用 `cases hxy with a ha` 来得到一个具体的自然数 `a` 和一个等式 `ha : y = x + a`。同样地，对于 `hyz : y ≤ z`，我们可以使用 `cases hyz with b hb` 来得到一个具体的自然数 `b` 和一个等式 `hb : z = y + b`。

随后，将它们组合起来得到 `z = x + (a + b)`，最后使用 `use a + b` 将目标 `x ≤ z` 转化为 `z = x + (a + b)` 即可证明。完整的代码如下：

```lean
cases hxy with a ha
cases hyz with b hb
use a + b
rw [ha, add_assoc] at hb
exact hb
```

（注：在上述定理的支撑下，我们证明了 `≤` 是 `ℕ` 上的一个预序。）

= 关卡 5

#note(title: [x ≤ 0 → x = 0])[
  *定理* `le_zero`：如果 $x ≤ 0$，那么 $x=0$。

  ```lean
  theorem le_zero (x : ℕ) (hx : x ≤ 0) : x = 0 := by
  ```
]

使用 `cases hx with a ha` 来得到一个具体的自然数 `a` 和一个等式 `ha : 0 = x + a`。注意到我们已经证明了 `x + a = 0` 的定理，因此可以直接使用之前证明的 `add_right_eq_zero` 定理来证明。完整的代码如下：

```lean
cases hx with a ha
symm at ha
exact add_right_eq_zero x a ha
```

= 关卡 6

#note(title: [x ≤ y 且 y ≤ x 意味着 x = y])[
  *定理* `le_antisymm`：如果 $x ≤ y$ 且 $y ≤ x$，则 $x=y$。

  ```lean
  theorem le_antisymm (x y : ℕ) (hxy : x ≤ y) (hyx : y ≤ x) : x = y := by
  ```
]

使用 `cases hxy with a ha` 来得到一个具体的自然数 `a` 和一个等式 `ha : y = x + a`。同样地，使用 `cases hyx with b hb` 来得到一个具体的自然数 `b` 和一个等式 `hb : x = y + b`。

将二者结合起来，我们可以得到 `x = x + (a + b)`，然后使用之前证明的 `add_left_eq_self` 定理来证明。完整的代码如下：

```lean
cases hxy with a ha
cases hyx with b hb
rw [hb] at ha
symm at ha
rw [add_assoc] at ha
apply add_right_eq_self at ha
apply add_right_eq_zero at ha
rw [ha, add_zero] at hb
exact hb
```

（注：在上述定理的支撑下，我们证明了 `≤` 是 `ℕ` 上的一个偏序。本世界最终的目标是证明 `≤` 是 `ℕ` 上的一个全序。）

= 关卡 7

#note(title: [处理 `or`])[
  目标：如果 $x=37$ 或 $y=42$，那么 $y=42$ 或 $x=37$。

  ```lean
  example (x y : ℕ) (h : x = 37 ∨ y = 42) : y = 42 ∨ x = 37 := by
  ```
]

首先，对于假设中的 `or`，我们可以使用 `cases h with h1 h2` 来进行分类讨论，其中 `h1 : x = 37` 和 `h2 : y = 42` 分别对应假设中的两个情况。

其次，对于目标中的 `or`，我们只需要证明左右两部分中的任意一个即可。对于 `h1 : x = 37`，我们可以直接使用 `right` 策略来证明目标中的右侧；对于 `h2 : y = 42`，我们可以直接使用 `left` 策略来证明目标中的左侧。完整的代码如下：

```lean
cases h with h1 h2
right
exact h1
left
exact h2
```

= 关卡 8

#note(title: [x ≤ y 或 y ≤ x])[
  *定理* `le_total`：如果 $x$ 和 $y$ 是自然数，则 $x≤y$ 或 $y≤x$。

  ```lean
  theorem le_total (x y : ℕ) : x ≤ y ∨ y ≤ x := by
  ```
]

这里需要使用归纳法进行证明。对于 `y` 的归纳，我们需要证明两个子目标：

- 当 `y` 是零时，证明 `x ≤ 0` 或 `0 ≤ x`。
- 已知 `x ≤ d` 或 `d ≤ x`，证明 `x ≤ succ d` 或 `succ d ≤ x`。

第一个目标是显然的，而对于第二个目标，则需要进一步进行分类讨论：

- 如果 `x ≤ d`，则直接使用 `left` 策略来证明 `x ≤ succ d`。
- 如果 `d ≤ x`，令 `x = d + a`，则需要使用 `cases` 来进行分类讨论：
  - 如果 `a` 是零，那么 `x = d`，证明 `succ d ≤ x` 即可；
  - 如果 `a` 是 `succ b`，则 `x = d + succ b`，使用 `add_succ` 将其重写为 `succ (d + b)`，证明 `succ d ≤ x` 即可。

完整的代码如下：

```lean
induction y with d hd
right
exact zero_le x
cases hd with h1 h2
left
exact le_trans x d (succ d) h1 (le_succ_self d)
cases h2 with a ha
cases a with b
left
rw [ha, add_zero]
exact le_succ_self d
right
use b
rw [ha, add_succ, succ_add]
rfl
```

= 关卡 9

#note(title: [succ x ≤ succ y → x ≤ y])[
  *定理* `succ_le_succ`：如果 $"succ"(x)≤"succ"(y)$，那么 $x≤y$。

  ```lean
  theorem succ_le_succ (x y : ℕ) (hx : succ x ≤ succ y) : x ≤ y := by
  ```
]

使用 `cases hx with d hd` 来得到一个具体的自然数 `d` 和一个等式 `hd : succ y = succ x + d`。注意到 `succ x + d` 可以使用 `add_succ` 重写为 `succ (x + d)`，因此我们可以得到 `succ y = succ (x + d)`。使用 `succ_inj` 定理可以得出 `y = x + d`，最后使用 `use d` 将目标 `x ≤ y` 转化为 `y = x + d` 即可证明。完整的代码如下：

```lean
cases hx with d hd
use d
rw [succ_add] at hd
apply succ_inj at hd
exact hd
```

= 关卡 10

#note(title: [x ≤ 1])[
  *定理* `le_one`：如果 $x≤1$，那么 $x=0$ 或 $x=1$。

  ```lean
  theorem le_one (x : ℕ) (hx : x ≤ 1) : x = 0 ∨ x = 1 := by
  ```
]

在对 `x` 分类讨论后，只需证明 `x` 是一个后继数时必然有 `x = 1`。令 `x = succ y`，通过 `succ y ≤ 1` 证明 `y = 0` 即可。完整的代码如下：

```lean
cases x with y
trivial
rw [one_eq_succ_zero] at hx
apply succ_le_succ at hx
apply le_zero at hx
right
rw [hx, one_eq_succ_zero]
rfl
```

= 关卡 11

#note(title: [x ≤ 2])[
  *定理* `le_two`：如果 $x≤2$，那么 $x=0$ 或 $x=1$ 或 $x=2$。

  ```lean
  theorem le_two (x : ℕ) (hx : x ≤ 2) : x = 0 ∨ x = 1 ∨ x = 2 := by
  ```
]

依然对 `x` 分类讨论，在 `x = succ y` 的情况下，证明 `y ≤ 1`，随后使用上一个定理的结论即可。完整的代码如下：

```lean
cases x with y
trivial
rw [two_eq_succ_one] at hx
apply succ_le_succ at hx
apply le_one at hx
right
cases hx with h1 h2
left
rw [h1, one_eq_succ_zero]
rfl
right
rw [h2, two_eq_succ_one]
rfl
```