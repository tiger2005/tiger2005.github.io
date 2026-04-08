#import "../../../config.typ": *
#import "@preview/cetz:0.4.2"

#show: template-post.with(
  title: "Natural Number Game 第五部分 / 幂世界",
  description: "本文是 Natural Number Game 的第五部分，主要介绍了 Lean 中的指数相关定理的证明，包括零的零次幂、任何数的一次幂、乘积的幂次等定理。",
  tags: ("数论", "Lean"),
  category: "Natural Number Game 合集",
  date: datetime(year: 2026, month: 4, day: 8)
)

#quote[
  Natural Number Game 是一个基于 Lean 4 开发的游戏，通过交互式定理证明工具，让玩家尝试证明在自然数系统上的加法、乘法、指数相关的定理。游戏的目标是通过证明各种定理来解锁新的关卡和挑战，逐步深入理解自然数的性质和相关的数学概念。你可以在 #link("https://adam.math.hhu.de/#/g/leanprover-community/nng4")[这里] 游玩 Natural Number Game。

  这个世界的前置条件是通过 #link("/posts/natural_number_game/world3/")[乘法世界] 的所有关卡。
]

Lean 通过如下两个定理来定义自然数上的指数：

- ```lean pow_zero (a : ℕ) : a ^ 0 = 1```（零次幂）
- ```lean pow_succ (a b : ℕ) : a ^ succ b = a ^ b * a```（后继次幂）

在这个世界中，我们需要将上述定理结合已知的加法和乘法相关定理，证明指数的相关定理。*这个世界的最后一关颇具挑战性。*

= 关卡 1

#note(title: [`zero_pow_zero`（零的零次幂）])[
  *定理* `zero_pow_zero`：$0^0 = 1$。

  ```lean
  theorem zero_pow_zero : (0 : ℕ) ^ 0 = 1 := by
  ```
]

虽然在数学中，零的零次幂的定义存在争议，但在 Lean 中，我们通过 `pow_zero` 定理直接得出 `0^0 = 1`。完整的代码如下：

```lean
exact pow_zero 0
```

= 关卡 2

#note(title: [`zero_pow_succ`（零的后继次幂）])[
  *定理* `zero_pow_succ`：对于所有自然数 $m$，$0^("succ"(m)) = 0$。

  ```lean
  theorem zero_pow_succ (m : ℕ) : (0 : ℕ) ^ (succ m) = 0 := by
  ```
]

直接使用 `pow_succ` 定理将目标重写为 `0^m * 0`，然后使用 `mul_zero` 定理将 `0^m * 0` 替换为 `0`，完成证明。完整的代码如下：

```lean
rw [pow_succ, mul_zero]
rfl
```

= 关卡 3

#note(title: [`pow_one`（任何数的一次幂）])[
  *定理* `pow_one`：对于所有自然数 $a$，$a^1 = a$。

  ```lean
  theorem pow_one (a : ℕ) : a ^ 1 = a := by
  ```
]

将 `1` 重写为 `succ 0` 之后，使用 `pow_succ` 定理将目标重写为 `a^0 * a`，然后使用 `pow_zero` 定理将 `a^0` 替换为 `1`，最后使用 `one_mul` 定理将 `1 * a` 替换为 `a`，完成证明。完整的代码如下：

```lean
rw [one_eq_succ_zero, pow_succ, pow_zero, one_mul]
rfl
```

= 关卡 4

#note(title: [`one_pow`（一的幂次）])[
  *定理* `one_pow`：对于所有自然数 $m$，$1^m = 1$。

  ```lean
  theorem one_pow (m : ℕ) : (1 : ℕ) ^ m = 1 := by
  ```
]

不难想到 $1^("succ" m)$ 可以使用 $1^m times 1$ 表示，因此使用归纳法来证明这个定理是非常自然的。`m` 等于 `0` 的情况可以直接使用 `pow_zero` 定理来证明，而 `m` 是自然数 `d` 的后继的情况（也就是要使用 $1^d = 1$ 证明 $1^("succ" d) = 1$），只需要使用 `pow_succ` 定理将目标重写为 $1^d times 1$，然后使用归纳假设 `hd` 将 $1^d$ 替换为 $1$，最后使用 `one_mul` 定理将 $1 times 1$ 替换为 $1$，完成证明。完整的代码如下：

```lean
induction m with d hd
exact pow_zero 1
rw [pow_succ, hd, one_mul]
rfl
```

= 关卡 5

#note(title: [`pow_two`（任何数的二次幂）])[
  *定理* `pow_two`：对于所有自然数 $a$，$a^2 = a times a$。

  ```lean
  theorem pow_two (a : ℕ) : a ^ 2 = a * a := by
  ```
]

使用一次幂可以轻松证明二次幂，只需要先将 `2` 重写为 `succ 1`，然后使用 `pow_succ` 定理将目标重写为 $a^1 times a$，最后使用 `pow_one` 定理将 $a^1$ 替换为 $a$，完成证明。完整的代码如下：

```lean
rw [two_eq_succ_one, pow_succ, pow_one]
rfl
```

= 关卡 6

#note(title: [`pow_add`（指数加法）])[
  *定理* `pow_add`：对于所有自然数 $a$、$m$、$n$，我们有 $a^(m+n) = a^m times a^n$。

  ```lean
  theorem pow_add (a m n : ℕ) : a ^ (m + n) = a ^ m * a ^ n := by
  ```
]

依然考虑使用归纳法来证明这个定理。这里我们选择对 `n` 进行归纳证明。`n` 等于 `0` 的情况十分简单，而对于 `n` 是自然数 `d` 的后继的情况，我们需要使用 `pow_succ` 定理将目标重写为 $a^(m + "succ" d) = a^m times a^("succ" d)$，随后将 `succ` 全部转化为 `a` 的乘积，最后使用归纳假设 `hd` 将 $a^m times a^d$ 替换为 $a^(m + d)$，稍作整理即可完成证明。完整的代码如下：

```lean
induction n with d hd
rw [add_zero, pow_zero, mul_one]
rfl
rw [add_succ, pow_succ, hd, pow_succ, mul_assoc]
rfl
```

= 关卡 7

#note(title: [`mul_pow`（乘积的幂次）])[
  *定理* `mul_pow`：对于所有的自然数 $a$、$b$、$n$，我们有 $(a times b)^n = a^n times b^n$。

  ```lean
  theorem mul_pow (a b n : ℕ) : (a * b) ^ n = a ^ n * b ^ n := by
  ```
]

依旧对 `n` 进行归纳证明。`n` 等于 `0` 的情况十分简单，而对于 `n` 是自然数 `d` 的后继的情况，我们需要使用 `pow_succ` 定理将目标重写为 $(a times b)^d times (a times b) = (a^d times a) times (b^d times b)$，随后使用归纳假设 `hd` 将 $(a times b)^d$ 替换为 $a^d times b^d$，稍作整理即可完成证明。完整的代码如下：

```lean
induction n with d hd
rw [pow_zero, pow_zero, pow_zero, mul_one]
rfl
rw [pow_succ, pow_succ, pow_succ, hd, ← mul_assoc, ← mul_assoc, mul_assoc (a^d) (b^d) a, mul_comm (b^d) a, ← mul_assoc]
rfl
```

（注：如果不追求最少行数的话，可以使用 `nth_write` 指定需要重写的项。）

= 关卡 8

#note(title: [`pow_pow`（幂的幂次）])[
  *定理* `pow_pow`：对于所有自然数 $a$、$m$、$n$，我们有 $(a^m)^n = a^(m times n)$。

  ```lean
  theorem pow_pow (a m n : ℕ) : (a ^ m) ^ n = a ^ (m * n) := by
  ```
]

对 `n` 使用归纳法即可轻松证明。`n` 等于 `0` 的情况十分简单，而对于 `n` 是自然数 `d` 的后继的情况，我们需要使用 `pow_succ` 定理将目标重写为 $(a^m)^d times a^m$，随后使用归纳假设 `hd` 将 $(a^m)^d$ 替换为 $a^(m times d)$，稍作整理即可完成证明。完整的代码如下：

```lean
induction n with d hd
rw [pow_zero, mul_zero, pow_zero]
rfl
rw [pow_succ, hd, mul_succ, pow_add]
rfl
```

= 关卡 9

#note(title: [`add_sq`（和的平方）])[
  *定理* `add_sq`：对于所有自然数 $a$ 和 $b$，我们有 $(a+b)^2 = a^2 + b^2 + 2 times a times b$。

  ```lean
  theorem add_sq (a b : ℕ) : (a + b) ^ 2 = a ^ 2 + b ^ 2 + 2 * a * b := by
  ```
]

使用前面证明的定理，不断利用 `pow_two` 展开平方项，然后使用乘法和加法的基本性质进行调整即可完成证明。使用了 12 次重写的方案对应的代码如下：

```lean
rw [mul_assoc, two_mul, pow_two, pow_two, pow_two, mul_add, add_mul, add_mul, mul_comm b a, <- add_assoc, add_assoc (a*a) (a*b) (a*b), add_right_comm]
rfl
```

= 关卡 10

#note(title: [费马大定理])[
  *目标*：对于所有自然数 $a$、$b$、$c$ 和 $n$，我们有 $(a+1)^(n+3) + (b+1)^(n+3) != (c+1)^(n+3)$。

  ```lean
  example (a b c n : ℕ) : (a + 1) ^ (n + 3) + (b + 1) ^ (n + 3) ≠ (c + 1) ^ (n + 3) := by
  ```
]

希望有生之年能看到这道题目被 Lean 解决的时刻。下面引用一段游戏中的提示：

#quote[
  这一关表面上看起来像我们见过的其他关卡，但人类已知的最短解法也将转化为数百万行的 Lean 代码。
  
  这个游戏的作者，Kevin Buzzard，正在将 Wiles 和 Taylor 的证明翻译成 Lean，尽管这项任务将花费许多年。
]

（注：你可以在 #link("https://github.com/ImperialCollegeLondon/FLT")[这个仓库] 查看目前的进展。）