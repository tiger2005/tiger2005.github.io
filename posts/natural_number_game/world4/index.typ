#import "../../../config.typ": *
#import "@preview/cetz:0.4.2"

#show: template-post.with(
  title: "Natural Number Game 第四部分 / 蕴含世界",
  description: "本文是 Natural Number Game 的第四部分，主要介绍了 Lean 中的蕴含逻辑相关定理的证明，包括 exact 和 apply 策略的使用，以及如何在 Lean 中处理蕴含关系等定理。",
  tags: ("数论", "Lean"),
  category: "Natural Number Game 合集",
  date: datetime(year: 2026, month: 4, day: 7)
)

#quote[
  Natural Number Game 是一个基于 Lean 4 开发的游戏，通过交互式定理证明工具，让玩家尝试证明在自然数系统上的加法、乘法、指数相关的定理。游戏的目标是通过证明各种定理来解锁新的关卡和挑战，逐步深入理解自然数的性质和相关的数学概念。你可以在 #link("https://adam.math.hhu.de/#/g/leanprover-community/nng4")[这里] 游玩 Natural Number Game。

  这个世界的前置条件是通过 #link("/posts/natural_number_game/world2/")[加法世界] 的所有关卡。
]

蕴含是逻辑中的一个重要概念，表示如果前提成立，那么结论也必须成立。在 Lean 中，存在一些为蕴含逻辑设计的策略，例如 `intro` 和 `apply`，它们可以帮助我们在证明过程中处理蕴含关系，并使用和蕴含关系相关的定理。

= 关卡 1

#note(title: [`exact` 策略])[
  目标：假设 $x+y=37$ 和 $3x+z=42$，我们有 $x+y=37$。

  ```lean
  example (x y z : ℕ) (h1 : x + y = 37) (h2 : 3 * x + z = 42) : x + y = 37 := by
  ```
]

如果目标已经在推导过程中出现在某一个假设中，则可以使用 `exact` 策略来直接完成证明。在这个例子中，目标 `x + y = 37` 已经在假设 `h1` 中出现了，因此我们可以直接使用 `exact h1` 来完成证明。完整的代码如下：

```lean
exact h1
```

= 关卡 2

#note(title: [`exact` 练习])[
  目标：假设 $0+x=(0+y)+2$，我们有 $x=y+2$。

  ```lean
  example (x y : ℕ) (h : 0 + x = 0 + y + 2) : x = y + 2 := by
  ```
]

重写目标相对比较困难，不妨使用 `rw [...] at h` 语法来重写假设 `h`，将其中的 `0 + x` 替换为 `x`，以及将 `0 + y` 替换为 `y`，从而得到 `h : x = y + 2`。此时目标已经在假设中出现了，我们就可以使用 `exact h` 来完成证明。完整的代码如下：

```lean
repeat rw [zero_add] at h
exact h
```

= 关卡 3

#note(title: [`apply` 策略])[
  目标：假设 $x=37$ 和 $x=37 => y=42$，我们有 $y=42$。

  ```lean
  example (x y : ℕ) (h1 : x = 37) (h2 : x = 37 → y = 42) : y = 42 := by
  ```
]

Lean 使用 `apply` 策略进行蕴含推导。如果一个蕴含假设的前提已经在另一个假设中出现了，那么我们就可以使用 `apply` 策略将蕴含假设应用到另一个假设上，从而得到结论。在这个例子中，蕴含假设 `h2` 的前提 `x = 37` 已经在假设 `h1` 中出现了，因此我们可以使用 `apply h2 at h1` 来完成证明。完整的代码如下：

```lean
apply h2 at h1
exact h1
```

= 关卡 4

#note(title: [`succ_inj`：“后继数”是一个单射])[
  目标：如果 $x+1=4$ 则 $x=3$。

  ```lean
  example (x : ℕ) (h : x + 1 = 4) : x = 3 := by
  ```
]

皮亚诺公理告诉我们，`succ a = succ b` 可以推导出 `a = b`，也就是说，后继数是一个单射。在 Lean 中，这一公理被表示为 `succ_inj` 定理。在这个例子中，我们可以先将目标转化为 `succ x = succ 3`，然后使用 `succ_inj` 定理将其转化为 `x = 3`，从而完成证明。完整的代码如下：

```lean
rw [← succ_eq_add_one, four_eq_succ_three] at h
apply succ_inj at h
exact h
```

= 关卡 5

#note(title: [逆向证明])[
  目标：如果 $x+1=4$ 则 $x=3$。

  ```lean
  example (x : ℕ) (h : x + 1 = 4) : x = 3 := by
  ```
]

Lean 允许将蕴含假设应用到目标上，从而进行逆向证明（此时要求目标是蕴含假设的*结论*，应用结果是蕴含假设的*前提*，和在假设中使用的情况相反）。在这个例子中，我们可以先将目标转化为 `succ x = succ 3`，然后使用完全相反的重写策略完成证明。完整的代码如下：

```lean
apply succ_inj
rw [succ_eq_add_one, ← four_eq_succ_three]
exact h
```

= 关卡 6

#note(title: [`intro` 策略])[
  目标：$x = 37 => x = 37$

  ```lean
  example (x : ℕ) : x = 37 → x = 37 := by
  ```
]

前面的部分给出了假设是一个蕴含关系的例子，这里则需要处理目标是一个蕴含关系的情况。对于这种情况，我们可以使用 `intro` 策略来引入一个新的假设（也就是蕴含关系的前提），然后在新的上下文中证明结论。例如，在此处使用 `intro h`，会得到一个新的假设 `h : x = 37`，此时目标变为 `x = 37`，我们就可以直接使用 `exact h` 来完成证明。完整的代码如下：

```lean
intro h
exact h
```

= 关卡 7

#note(title: [`intro` 练习])[
  目标：$x+1=y+1 => x=y$。

  ```lean
  example (x y : ℕ) : x + 1 = y + 1 → x = y := by
  ```
]

只需要将 `x + 1 = y + 1` 作为前提，并使用 `succ_inj` 定理将其转化为 `x = y` 即可完成证明。完整的代码如下：

```lean
intro h
repeat rw [← succ_eq_add_one] at h
apply succ_inj at h
exact h
```

= 关卡 8

#note(title: [矛盾])[
  目标：如果 $x=y$ 且 $x != y$ 那么我们可以推出矛盾。

  ```lean
  example (x y : ℕ) (h1 : x = y) (h2 : x ≠ y) : False := by
  ```
]

Lean 中并没有直接定义“不等于”和“矛盾”的概念，而是通过布尔代数中的 `False` 来表示矛盾。不等于也可以写成一种“矛盾”的形式，例如 `a ≠ b` 可以写成 `a = b → False`。在这个例子中，可以直接使用 `apply h2` 将假设 `h1 : x = y` 应用到 `h2` 上，从而得到 `False`。完整的代码如下：

```lean
apply h2 at h1
exact h1
```

= 关卡 9

#note(title: [`zero_ne_succ`（零不等于后继数）])[
  目标：$0 ≠ 1$。

  ```lean
  theorem zero_ne_one : (0 : ℕ) ≠ 1 := by
  ```
]

根据皮亚诺公理，零不是任何自然数的后继，因此零不等于任何一个后继数。我们可以使用 `zero_ne_succ` 定理来完成证明。在这个例子中，可以使用 `exact zero_ne_succ 0` 得到 `0 ≠ succ 0` 的证明，也可以通过 `apply` 策略，在最后得到 `False → False`，从而完成证明。完整的代码如下：

```lean
rw [one_eq_succ_zero]
exact zero_ne_succ 0
```

= 关卡 10

#note(title: [1 ≠ 0])[
  目标：$1 ≠ 0$。

  ```lean
  theorem one_ne_zero : (1 : ℕ) ≠ 0 := by
  ```
]

考虑到前面已经证明了 `0 ≠ 1`，因此只需要将左右两端互换一下即可完成证明。在 Lean 中，可以使用 `symm` 策略将等式或不等式的两端互换。完整的代码如下：

```lean
symm
exact zero_ne_one
```

= 关卡 11

#note(title: [2 + 2 ≠ 5])[
  目标：$2 + 2 ≠ 5$。

  ```lean
  example : succ (succ 0) + succ (succ 0) ≠ succ (succ (succ (succ (succ 0)))) := by
  ```
]

证明这个问题非常简单，只需将两侧不断通过 `add_succ` 定理展开，最终得到 `succ (succ (succ (succ 0))) ≠ succ (succ (succ (succ (succ 0))))`，在使用 `succ_inj` 消除至 `0 ≠ succ 0` 后就可以使用 `zero_ne_succ` 来完成证明。完整的代码如下：

```lean
intro h
rw [add_succ, add_succ, add_zero] at h
repeat apply succ_inj at h
apply zero_ne_succ at h
exact h
```

（注：考虑到 `succ_inj` 是在等式下使用的，因此需要使用 `intro` 策略提取前提作为假设。）