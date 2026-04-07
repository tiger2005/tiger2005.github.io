#import "../../../config.typ": *
#import "@preview/cetz:0.4.2"

#show: template-post.with(
  title: "Natural Number Game 第一部分 / 教程世界",
  description: "本文是 Natural Number Game 的第一部分，主要介绍了 Lean 中的基本证明策略，包括 rfl 和 rw 等，并在最终证明了 2 + 2 = 4。",
  tags: ("数论", "Lean"),
  category: "Natural Number Game 合集",
  date: datetime(year: 2026, month: 4, day: 7)
)

#quote[
  Natural Number Game 是一个基于 Lean 4 开发的游戏，通过交互式定理证明工具，让玩家尝试证明在自然数系统上的加法、乘法、指数相关的定理。游戏的目标是通过证明各种定理来解锁新的关卡和挑战，逐步深入理解自然数的性质和相关的数学概念。你可以在 #link("https://adam.math.hhu.de/#/g/leanprover-community/nng4")[这里] 游玩 Natural Number Game。
]

在教程世界中，我们需要掌握证明定理的初步技能，并在最终证明 `2 + 2 = 4` 这一定理。解决这些谜题并证明定理的过程中，我们需要使用一种名为*策略*的强大工具。证明定理的关键在于准确地应用这些策略。

考虑到这个世界的内容对后面的关卡非常重要，我们将详细介绍每个关卡使用到的策略。在后续的世界中，则不会再详细介绍新的策略，而是着重于解释证明的思路和方法。

= 关卡 1

#note(title: [`rfl` 策略])[
  目标：如果 $x$ 和 $q$ 是任意自然数，那么 $37 x + q = 37 x + q$。

  ```lean 
  example (x q : ℕ) : 37 * x + q = 37 * x + q := by
  ```
]

`rfl`（Reflexivity，自反性）证明形如 `X = X` 的目标。它是 Lean 系统中的一个*策略*（可以认为是系统内置的处理方法），当目标的两边完全相同，或者可以通过简化得到相同的表达式时，`rfl` 就可以直接证明该目标。

在这个关卡中，我们的目标是证明 `37 * x + q = 37 * x + q`。由于两边完全相同，我们可以直接使用 `rfl` 策略来完成证明：

```lean
rfl
```

= 关卡 2

#note(title: [`rw` 策略])[
  目标：如果 $x$ 和 $y$ 是自然数，并且 $y = x + 7$，那么 $2y = 2(x + 7)$。

  ```lean 
  example (x y : ℕ) (h : y = x + 7) : 2 * y = 2 * (x + 7) := by
  ```
]

`rw`（Rewrite，重写）策略允许我们根据已知的等式来替换证明目标中的表达式。更具体地说，如果存在一个等式 `h : A = B`，我们可以使用 `rw [h]` 来将目标中第一个出现的 `A` 替换为 `B`。这个等式可以是已经证明的目标（例如上一题中的 `example`，以及后续关卡解锁的定理），也可以是我们在证明过程中引入的假设。

在这个关卡中，我们有一个*假设* `h : y = x + 7`，此时可以使用 `rw` 策略将目标中的 `y` 替换为 `x + 7`：

```lean
rw [h]
```

此时的证明目标会变成 `2 * (x + 7) = 2 * (x + 7)`，接下来我们可以使用 `rfl` 策略来完成证明。完整的代码如下：

```lean
rw [h]
rfl
```

#warning(title: [`rw` 策略的变体])[
- ```lean rw [← h]``` 逆向重写，寻找等式的右边并重写为左边。
- ```lean rw [h1, h2]``` 执行一系列重写。
- ```lean rw [h] at h2``` 只在假设 `h2` 中进行重写。
- ```lean rw [h] at h1 h2 ⊢``` 在两个假设和目标中进行重写（使用 `⊢` 代表目标）。
- ```lean repeat rw [add_zero]``` 将会不断进行重写，直到没有更多的匹配为止。
- ```lean nth_rewrite 2 [h]``` 只会重写目标中第二个满足条件的位置。
]

= 关卡 3

#note(title: [数字])[
  目标：$2$ 是 $0$ 之后再之后的数字。

  ```lean
  example : 2 = succ (succ 0) := by
  ```
]

在 Lean 中，自然数的定义基于两个简单的规则：

- `0` 被认为是一个自然数。
- 如果 `n` 是一个自然数，那么 `n` 的后继数 `succ n` 也是一个自然数。

这里将 `1` 定义为 `succ 0`，而 `2` 定义为 `succ 1`。它们分别对应了两个等式：

- ```lean one_eq_succ_zero : 1 = succ 0```
- ```lean two_eq_succ_one : 2 = succ 1```

同理还有 ```lean three_eq_succ_two``` 和 ```lean four_eq_succ_three``` 等等。

在这个关卡中，可以用如下步骤来证明：

+ 首先使用 ```lean two_eq_succ_one``` 将 `2` 替换为 `succ 1`，此时的目标是 ```lean succ 1 = succ (succ 0)```；
+ 然后使用 ```lean one_eq_succ_zero``` 将 `1` 替换为 `succ 0`，此时的目标是 ```lean succ (succ 0) = succ (succ 0)```；
+ 最后使用 `rfl` 来完成证明。

完整的代码如下：

```lean
rw [two_eq_succ_one, one_eq_succ_zero]
rfl
```

= 关卡 4

#note(title: [逆向重写])[
  目标：$2$ 是 $0$ 之后再之后的数字。

  ```lean
  example : 2 = succ (succ 0) := by
  ```
]

在 Lean 中，`rw` 策略默认会将目标中的表达式替换为等式的右边，但有时我们需要反过来进行替换。使用 `rw [← h]` 可以实现逆向重写，即将目标中的表达式替换为等式的左边。

在这个关卡中，我们可以直接使用 `rw` 策略的逆向重写功能来证明目标：

```lean
rw [← one_eq_succ_zero, ← two_eq_succ_one]
rfl
```

= 关卡 5

#note(title: [加零])[
  目标：$a + (b + 0) + (c + 0) = a + b + c$。

  ```lean
  example (a b c : ℕ) : a + (b + 0) + (c + 0) = a + b + c := by
  ```
]

引理 `add_zero a` 是 `a + 0 = a` 的证明。实际上，`add_zero` 的功能更像一个函数，其接受一个数字，并返回一个证明，证明该数字加零等于它本身。我们可以使用 `rw [add_zero]` 来将目标中的 `? + 0` 替换为 `?`。

在这个关卡中，只需要不断使用 `add_zero` 重写目标的左侧，就可以将目标简化为 `a + b + c = a + b + c`，然后使用 `rfl` 来完成证明。完整的代码如下：

```lean
repeat rw [add_zero]
rfl
```

= 关卡 6

#note(title: [精准重写])[
  目标：$a + (b + 0) + (c + 0) = a + b + c$。

  ```lean
  example (a b c : ℕ) : a + (b + 0) + (c + 0) = a + b + c := by
  ```
]

在某些情况下，我们可能不想重写目标中的第一个匹配项，而是想重写第二个或第三个匹配项。此时可以使用前面提到的事实：“`add_zero` 的功能更像一个函数”。我们可以使用 `add_zero c` 指定将目标中的 `c + 0` 重写为 `c`，而不是将 `b + 0` 重写为 `b`。

在这个关卡中，如果需要先替换 `c + 0` 后再替换 `b + 0`，可以使用如下代码：

```lean
rw [add_zero c, add_zero b]
rfl
```

= 关卡 7

#note(title: [`add_succ`（加后继）])[
  *定理* `succ_eq_add_one`：对于所有自然数 $a$，我们有 $"succ"(a) = a + 1$。

  ```lean
  theorem succ_eq_add_one n : succ n = n + 1 := by
  ``` 
]

Lean 中的每个数字要么是 $0$ 要么是后继数。我们已经知道如何加 $0$， 我们还需要弄清楚如何添加后继数。

这里需要给出另一个音理 ```lean add_succ x d : x + succ d = succ (x + d)```，它说明了如何将一个数字加上另一个数字的后继数。我们可以使用这个定理来证明 `succ_eq_add_one`：

+ 首先，将 `1` 替换为 `succ 0`，此时的目标是 `succ n = n + succ 0`；
+ 然后使用 `add_succ` 将目标的右侧重写为 `succ (n + 0)`；
+ 最后使用 `add_zero` 将 `n + 0` 替换为 `n`，此时的目标是 `succ n = succ n`，使用 `rfl` 来完成证明。

完整的代码如下：

```lean
rw [one_eq_succ_zero, add_succ, add_zero]
rfl
```

= 关卡 8

#note(title: [2 + 2 = 4])[
  目标：$2 + 2 = 4$。

  ```lean
  example : (2 : ℕ) + 2 = 4 := by
  ```
]

这里存在两个 `2`，在上一个关卡中我们知道如何将一个数加上另一个数的后继，因此这里我们希望将第二个 `2` 替换为 `succ 1`。可以使用 `nth_rewrite 2 [two_eq_succ_one]` 来指定只重写目标中的第二个匹配项。

接下来只需要按部就班，将目标的两侧都改写为 `succ (succ 2))`。完整的代码如下：

```lean
nth_rewrite 2 [two_eq_succ_one]
rw [add_succ, one_eq_succ_zero, add_succ, add_zero, four_eq_succ_three, three_eq_succ_two]
rfl
```