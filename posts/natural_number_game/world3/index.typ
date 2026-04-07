#import "../../../config.typ": *
#import "@preview/cetz:0.4.2"

#show: template-post.with(
  title: "Natural Number Game 第三部分 / 乘法世界",
  description: "本文是 Natural Number Game 的第三部分，主要介绍了 Lean 中的乘法相关定理的证明，包括乘法的交换律、结合律，以及乘法对于加法满足的分配律等定理。",
  tags: ("数论", "Lean"),
  category: "Natural Number Game 合集",
  date: datetime(year: 2026, month: 4, day: 7)
)

#quote[
  Natural Number Game 是一个基于 Lean 4 开发的游戏，通过交互式定理证明工具，让玩家尝试证明在自然数系统上的加法、乘法、指数相关的定理。游戏的目标是通过证明各种定理来解锁新的关卡和挑战，逐步深入理解自然数的性质和相关的数学概念。你可以在 #link("https://adam.math.hhu.de/#/g/leanprover-community/nng4")[这里] 游玩 Natural Number Game。

  这个世界的前置条件是通过 #link("/posts/natural_number_game/world2/")[加法世界] 的所有关卡。
]

Lean 通过如下两个定理来定义自然数上的乘法：

- ```lean mul_zero a : a * 0 = 0```（乘零）
- ```lean mul_succ a d : a * succ d = a * d + a```（乘后继）

在这个世界中，我们需要将上述定理结合在加法世界得到的定理，证明乘法的交换律、结合律，以及乘法对于加法满足的分配律等定理。

= 关卡 1

#note(title: [`mul_one`（乘一）])[
  *定理* `mul_one`：对于任何自然数 $m$，我们有 $m times 1 = m$。

  ```lean
  theorem mul_one (m : ℕ) : m * 1 = m := by
  ```
]

使用 `1` 的定义，我们可以将 `m * 1` 转换为 `m * 0 + m`，然后使用 `mul_zero` 定理将 `m * 0` 替换为 `0`，最后使用 `zero_add` 定理将 `0 + m` 替换为 `m`，从而完成证明。完整的代码如下：

```lean
rw [one_eq_succ_zero, mul_succ, mul_zero, zero_add]
rfl
```

= 关卡 2

#note(title: [`zero_mul`（零乘）])[
  *定理* `zero_mul`：对于所有自然数 $m$，我们有 $0 times m = 0$。

  ```lean
  theorem zero_mul (m : ℕ) : 0 * m = 0 := by
  ```
]

不妨通过归纳法来证明这个定理。`m` 等于 `0` 的情况可以直接使用 `mul_zero` 定理来证明，而 `m` 是自然数 `d` 的后继的情况（也就是要证明 `0 * succ d = 0`）：

- 先使用 `mul_succ` 定理将目标重写为 `0 * d + 0`；
- 然后使用归纳假设 `hd` 将内部的 `0 * d` 替换为 `0`，此时目标的左侧为 `0 + 0`；
- 最后使用 `add_zero` 定理将 `0 + 0` 替换为 `0`，完成证明。

完整的代码如下：

```lean
induction m with d hd
rw [mul_zero]
rfl
rw [mul_succ, hd, add_zero]
rfl
```

= 关卡 3

#note(title: [`succ_mul`（后继乘）])[
  *定理* `succ_mul`：对于所有自然数 $a$ 和 $b$，我们有 $"succ"(a) times b = a times b + b$。

  ```lean
  theorem succ_mul (a b : ℕ) : succ a * b = a * b + b := by
  ```
]

考虑到我们可以正确处理乘后继的情况（`mul_succ`），我们只需要对 `b` 进行归纳证明即可。`b` 等于 `0` 的情况可以直接使用 `mul_zero` 定理来证明，而 `b` 是自然数 `d` 的后继的情况（也就是要证明 `succ a * succ d = a * succ d + succ d`）：

- 先使用 `mul_succ` 定理将目标重写为 `succ a * d + succ a = a * succ d + succ d`；
- 然后利用归纳假设 `hd` 将内部的 `succ a * d` 替换为 `a * d + d`，此时目标的左侧为 `a * d + d + succ a`；
- 最后，先使用 `add_assoc` 定理将左侧的括号重新组合为 `a * d + (d + succ a)`，再通过 `add_succ` 与 `← succ_add` 将 `d + succ a` 转换为 `succ (d + a)`，对和式稍作调整即可完成证明。

完整的代码如下：

```lean
induction b with d hd
rw [add_zero, mul_zero, mul_zero]
rfl
rw [mul_succ, mul_succ, hd, add_assoc, add_succ, <- succ_add, add_right_comm, <- add_assoc]
rfl
```

（注：上述代码实际上较为复杂，不过在【算法世界】中介绍的 `simp_add` 策略可以自动整合和式并得到正确的结果，其具体行为请参考【算法世界】的相关关卡。）

= 关卡 4

#note(title: [`mul_comm`（乘法交换律）])[
  *定理* `mul_comm`：乘法是可交换的。

  ```lean
  theorem mul_comm (a b : ℕ) : a * b = b * a := by
  ```
]

有了 `succ_mul` 和 `mul_succ` 定理，只需要使用归纳法即可证明这个定理了（因为归纳步骤中 `a * succ d` 和 `succ d * a` 可以通过这两个对称的定理转化为相同的形式）。这里我们选择对 `b` 进行归纳证明：

```lean
induction b with d hd
rw [mul_zero, zero_mul]
rfl
rw [mul_succ, succ_mul, hd]
rfl
```

= 关卡 5

#note(title: [`one_mul`（乘一）])[
  *定理* `one_mul`：对于任何自然数 $m$，我们有 $1 times m = m$。

  ```lean
  theorem one_mul (m : ℕ) : 1 * m = m := by
  ```
]

使用乘法交换律将左侧的 `1 * m` 转换为 `m * 1`，然后使用 `mul_one` 即可证明。完整的代码如下：

```lean
rw [mul_comm, mul_one]
rfl
```

= 关卡 6

#note(title: [`two_mul`（二乘）])[
  *定理* `two_mul`：对于任何自然数 $m$，我们有 $2 times m = m + m$。

  ```lean
  theorem two_mul (m : ℕ) : 2 * m = m + m := by
  ```
]

将 `2` 重写为 `succ 1` 之后，结合 `succ_mul` 和 `one_mul` 定理即可证明。完整的代码如下：

```lean
rw [two_eq_succ_one, succ_mul, one_mul]
rfl
```

= 关卡 7

#note(title: [`mul_add`（乘法左分配律）])[
  *定理* `mul_add`：乘法对左边的加法具有分配性。 换句话说，对于所有自然数 $a$、$b$ 和 $c$，我们有 $a times (b+c)=a times b+a times c$。

  ```lean
  theorem mul_add (a b c : ℕ) : a * (b + c) = a * b + a * c := by
  ```
]

最直观的方式是使用归纳法，但是在这个定理的证明上，三个变量作为参数对应的证明步骤存在较大差异。其中，以 `c` 为变量的归纳证明相对来说更为简单一些，因此我们选择对 `c` 进行归纳证明。`c` 等于 `0` 的情况十分简单，接下来主要讨论 `c` 是自然数 `d` 的后继的情况（也就是要证明 `a * (b + succ d) = a * b + a * succ d`）：

+ 先使用 `add_succ` 定理将目标重写为 `a * succ (b + d) = a * b + a * succ d`；
+ 然后使用 `mul_succ` 定理将目标重写为 `a * (b + d) + a = a * b + a * succ d`；
+ 接下来，利用归纳假设 `hd` 将内部的 `a * (b + d)` 替换为 `a * b + a * d`，此时目标的左侧为 `a * b + a * d + a`；
+ 最后，使用 `mul_succ` 定理将右侧的 `a * succ d` 转换为 `a * d + a`，对和式稍作调整即可完成证明。

完整的代码如下：

```lean
induction c with d hd
rw [mul_zero, add_zero, add_zero]
rfl
rw [add_succ, mul_succ, hd, mul_succ, add_assoc]
rfl
```

= 关卡 8

#note(title: [`add_mul`（乘法右分配律）])[
  *定理* `add_mul`：加法和乘法有分配律。换句话说，对于所有自然数 $a$、$b$ 和 $c$，我们有 $(a+b) times c = a times c + b times c$。

  ```lean
  theorem add_mul (a b c : ℕ) : (a + b) * c = a * c + b * c := by
  ```
]

除了使用归纳法之外，我们还可以使用前面证明的定理，结合乘法的结合律完成证明。完整的代码如下：

```lean
rw [mul_comm, mul_add, mul_comm c a, mul_comm c b]
rfl
```

= 关卡 9

#note(title: [`mul_assoc`（乘法结合律）])[
  *定理* `mul_assoc`：乘法服从结合律。 换句话说，对于所有自然数 $a$、$b$ 和 $c$，我们有 $(a times b) times c=a times (b times c)$。

  ```lean
  theorem mul_assoc (a b c : ℕ) : (a * b) * c = a * (b * c) := by
  ```
]

依旧使用归纳法，这里我们选择对 `c` 进行归纳证明。`c` 等于 `0` 的情况十分简单，接下来主要讨论 `c` 是自然数 `d` 的后继的情况（也就是要证明 `(a * b) * succ d = a * (b * succ d)`）：

- 先使用 `mul_succ` 定理将目标重写为 `(a * b) * d + a * b = a * (b * d + b)`；
- 然后利用归纳假设 `hd` 将内部的 `(a * b) * d` 替换为 `a * (b * d)`，此时目标的左侧为 `a * (b * d) + a * b`；
- 最后，使用 `mul_add` 定理将右侧的 `a * (b * d + b)` 转换为 `a * (b * d) + a * b`，完成证明。

完整的代码如下：

```lean
induction c with d hd
repeat rw [mul_zero]
rfl
rw [mul_succ, mul_succ, hd, mul_add]
rfl
```

（注：在上述定理的支撑下，我们就证明了自然数是一个交换半环。）