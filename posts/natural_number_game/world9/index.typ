#import "../../../config.typ": *
#import "@preview/cetz:0.4.2"

#show: template-post.with(
  title: "Natural Number Game 第九部分 / 高级乘法世界",
  description: "本文介绍了 Natural Number Game 中的第九部分，主要涉及一些更复杂的乘法定理，例如乘法消去律等。",
  tags: ("数论", "Lean"),
  category: "Natural Number Game 合集",
  date: datetime(year: 2026, month: 4, day: 8)
)

#quote[
  Natural Number Game 是一个基于 Lean 4 开发的游戏，通过交互式定理证明工具，让玩家尝试证明在自然数系统上的加法、乘法、指数相关的定理。游戏的目标是通过证明各种定理来解锁新的关卡和挑战，逐步深入理解自然数的性质和相关的数学概念。你可以在 #link("https://adam.math.hhu.de/#/g/leanprover-community/nng4")[这里] 游玩 Natural Number Game。

  这个世界的前置条件是通过 #link("/posts/natural_number_game/world3/")[乘法世界] 和 #link("/posts/natural_number_game/world8/")[≤ 世界] 的所有关卡。
]

在高级加法中，我们证明了一些更复杂的加法定理，例如加法消去律等。在这个世界中，我们将继续深入，证明一些更复杂的乘法定理，例如乘法消去律等，并在未来为更难的目标做准备。

= 关卡 1

#note(title: [`mul_le_mul_right`（乘法的右单调性）])[
  *定理* `mul_le_mul_right`：如果 $a <= b$，则 $a times t <= b times t$。

  ```lean
  theorem mul_le_mul_right (a b t : ℕ) (h : a ≤ b) : a * t ≤ b * t := by
  ```
]

首先令 `b = a + d`，随后发现 `b * t = (a + d) * t = a * t + d * t`，因此直接 `use d * t` 即可证明。完整的代码如下：

```lean
cases h with d hd
use d * t
rw [hd, add_mul]
rfl
```

= 关卡 2

#note(title: [`mul_left_ne_zero`（乘法的左非零性）])[
  *定理* `mul_left_ne_zero`：如果 $a times b != 0$，则 $b != 0$。

  ```lean
  theorem mul_left_ne_zero (a b : ℕ) (h : a * b ≠ 0) : b ≠ 0 := by
  ```
]

从逆否的角度来看，如果 `b = 0`，则 `a * b = a * 0 = 0`，即可完成证明。完整的代码如下：

```lean
contrapose! h
rw [h, mul_zero]
rfl
```

= 关卡 3

#note(title: [`eq_succ_of_ne_zero`（非零数的后继表示）])[
  *定理* `eq_succ_of_ne_zero`：如果 $a$ 是一个非零自然数，则存在一个自然数 $n$ 使得 $a = "succ"(n)$。

  ```lean
  theorem eq_succ_of_ne_zero (a : ℕ) (ha : a ≠ 0) : ∃ n, a = succ n := by
  ```
]

对 `a` 进行分类讨论。在 `a = 0` 的情况下，不难发现假设命题出现矛盾，此时可以使用 `tauto` 策略来完成证明。在 `a = succ n` 的情况下，直接 `use n` 即可完成证明。完整的代码如下：

```lean
cases a with n
tauto
use n
rfl
```

= 关卡 4


#note(title: [`one_le_of_ne_zero`（非零数不小于 1）])[
  *定理* `one_le_of_ne_zero`：如果 $a$ 是一个非零自然数，则 $1 ≤ a$。

  ```lean
  theorem one_le_of_ne_zero (a : ℕ) (ha : a ≠ 0) : 1 ≤ a := by
  ```
]

利用上一个定理 `eq_succ_of_ne_zero`，我们可以得到一个自然数 `n` 使得 `a = succ n`。随后，使用 `use n` 将目标 `1 ≤ a` 转化为 `a = 1 + n`，最后使用 `succ_eq_add_one` 定理来完成证明。完整的代码如下：

```lean
apply eq_succ_of_ne_zero at ha
cases ha with n
use n
rw [h, succ_eq_add_one, add_comm]
rfl
```

= 关卡 5

#note(title: [`le_mul_right`（乘法结果不小于自身）])[
  *定理* `le_mul_right`：如果 $a times b != 0$，则 $a <= a times b$。

  ```lean
  theorem le_mul_right (a b : ℕ) (h : a * b ≠ 0) : a ≤ a * b := by
  ```
]

首先使用 `mul_left_ne_zero` 定理得到 `b ≠ 0`，随后使用 `one_le_of_ne_zero` 定理得到 `1 ≤ b`。最后使用 `mul_le_mul_right` 定理得到 `a ≤ a * b`。完整的代码如下：

```lean
apply mul_left_ne_zero at h
apply one_le_of_ne_zero at h
apply mul_le_mul_right 1 b a at h
rw [one_mul, mul_comm] at h
exact h
```

= 关卡 6

#note(title: [`mul_right_eq_one`（乘法恒一律）])[
  *定理* `mul_right_eq_one`：如果 $x times y = 1$，则 $x=1$。

  ```lean
  theorem mul_right_eq_one (x y : ℕ) (h : x * y = 1) : x = 1 := by
  ```
]

首先使用 `le_mul_right` 定理得到 `x ≤ x * y`，随后将等式右侧的 `1` 替换为 `x * y`，最后使用之前证明的 `le_one_iff` 定理来完成证明。

考虑到 `le_mul_right x y` 依赖于 `x * y ≠ 0`，在 Lean 系统中可以使用 `have` 引入一个假设 `h1 : x * y ≠ 0`，然后通过已有的假设 `h` 来证明 `h1`。完整的代码如下：

```lean
have h1 : x * y ≠ 0
rw [h]
trivial
apply le_mul_right at h1
rw [h] at h1
apply le_one at h1
cases h1 with hzero hone
rw [hzero, zero_mul, one_eq_succ_zero] at h
apply zero_ne_succ at h
tauto
exact hone
```

= 关卡 7

#note(title: [`mul_ne_zero`（乘法非零律）])[
  *定理* `mul_ne_zero`：如果 $a$ 和 $b$ 都是非零自然数，则 $a times b != 0$。

  ```lean
  theorem mul_ne_zero (a b : ℕ) (ha : a ≠ 0) (hb : b ≠ 0) : a * b ≠ 0 := by
  ```
]

首先，令 `a = succ m` 和 `b = succ n`，随后将 `a * b` 重写为 `(succ m) * (succ n)`，并证明它是某个数的后继即可。完整的代码如下：

```lean
apply eq_succ_of_ne_zero at ha
apply eq_succ_of_ne_zero at hb
cases ha with m hm
cases hb with n hn
rw [hm, hn, mul_succ, succ_mul, add_succ]
exact succ_ne_zero (m * n + n + m)
```

= 关卡 8

#note(title: [`mul_eq_zero`（乘法恒零律）])[
  *定理* `mul_eq_zero`：如果 $a times b = 0$，则 $a=0$ 或 $b=0$。

  ```lean
  theorem mul_eq_zero (a b : ℕ) (h : a * b = 0) : a = 0 ∨ b = 0 := by
  ```
]

首先使用 `contrapose! h` 将目标转化为 `a ≠ 0 ∧ b ≠ 0 → a * b ≠ 0`，随后使用之前证明的 `mul_ne_zero` 定理来完成证明。完整的代码如下：

```lean
contrapose! h
cases h with h1 h2
exact mul_ne_zero a b h1 h2
```

另外，也可以使用 `tauto` 策略来完成证明：

```lean
have h2 := mul_ne_zero a b
tauto
```

= 关卡 9

#note(title: [`mul_left_cancel`（乘法左消去律）])[
  *定理* `mul_left_cancel`：如果 $a$ 是一个非零自然数，并且 $a times b = a times c$，则 $b=c$。

  ```lean
  theorem mul_left_cancel (a b c : ℕ) (ha : a ≠ 0) (h : a * b = a * c) : b = c := by
  ```
]

为了证明这个定理，需要引入一个全新的语法：`induction b with d hd generalizing c`。这个语法的作用是对 `b` 进行归纳，同时将 `c` 作为一个通用变量来处理。对于 `b` 的归纳，我们需要证明两个子目标：

- 当 `b` 是零时，证明 `c = 0`。
- 当 `b = succ d` 时，已知“对于任意 `c`，如果 `a * d = a * c`，则 `d = c`”，以及 `a * succ d = a * c`，证明 `succ d = c`。不难发现，证明这个命题等价于说：“对于任意 `c`，如果 `a * succ d = a * c`，则 `succ d = c`”，恰好满足归纳步骤的要求。

为了证明第二个目标，首先讨论 `c` 不为 `0`，并且令 `c = succ e`，随后将 `a * succ d = a * succ e` 重写为 `a * d + a = a * e + a`，并得到 `d = e`，从而完成证明。完整的代码如下：

```lean
induction b with d hd generalizing c
rw [mul_zero] at h
symm at h
apply mul_eq_zero at h
tauto
cases c with e
rw [mul_zero] at h
apply mul_eq_zero at h
tauto
rw [mul_succ, mul_succ] at h
apply add_right_cancel at h
apply hd at h
rw [h]
rfl
```

= 关卡 10

#note(title: [`mul_right_eq_self`（乘法恒等律）])[
  *定理* `mul_right_eq_self`：如果 $a$ 是一个非零自然数，并且 $a times b = a$，则 $b=1$。

  ```lean
  theorem mul_right_eq_self (a b : ℕ) (ha : a ≠ 0) (h : a * b = a) : b = 1 := by
  ```
]

实际上，只需要将假设表示成 `a * b = a * 1`，然后使用之前证明的 `mul_left_cancel` 定理即可完成证明。完整的代码如下：

```lean
nth_rewrite 2 [← mul_one a] at h
exact mul_left_cancel a b 1 ha h
```

#success(title: [恭喜你！])[
  你已经完成了 Natural Number Game 的第九部分，证明了一些更复杂的乘法定理，例如乘法消去律等。截至 2026 年 4 月 8 日，这就是 Natural Number Game 中最后一个世界的关卡了！
]