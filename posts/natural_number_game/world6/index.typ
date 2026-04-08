#import "../../../config.typ": *
#import "@preview/cetz:0.4.2"

#show: template-post.with(
  title: "Natural Number Game 第六部分 / 算法世界",
  description: "本文是 Natural Number Game 的第六部分，主要介绍了 Lean 中的算法相关定理的证明，包括和式整理、前驱数、自然数的比较等定理。",
  tags: ("数论", "Lean"),
  category: "Natural Number Game 合集",
  date: datetime(year: 2026, month: 4, day: 8)
)

#quote[
  Natural Number Game 是一个基于 Lean 4 开发的游戏，通过交互式定理证明工具，让玩家尝试证明在自然数系统上的加法、乘法、指数相关的定理。游戏的目标是通过证明各种定理来解锁新的关卡和挑战，逐步深入理解自然数的性质和相关的数学概念。你可以在 #link("https://adam.math.hhu.de/#/g/leanprover-community/nng4")[这里] 游玩 Natural Number Game。

  这个世界的前置条件是通过 #link("/posts/natural_number_game/world4/")[蕴含世界] 的所有关卡。
]

像 $2+2=4$ 和 $a+b+c+d+e=e+d+c+b+a$ 这样的证明如果手工完成会非常繁琐。不过在 Lean 中，可以通过一些自动化策略简化证明过程。

= 关卡 1

#note(title: [`add_left_comm`（加法的左交换律）])[
  *定理* `add_left_comm`：如果 $a$、$b$、$c$ 是自然数，那么 $a+(b+c)=b+(a+c)$。

  ```lean
  theorem add_left_comm (a b c : ℕ) : a + (b + c) = b + (a + c) := by
  ```
]

在之前或者之后的关卡中，你可能需要使用这个定理交换加法中的项，而如果每一次都需要手动证明这个定理会非常麻烦。这个定理就是为了简化证明过程而引入的。至于定理的证明，只需要使用结合律和交换律即可。完整的代码如下：

```lean
rw [← add_assoc, add_comm a b, add_assoc]
rfl
```

= 关卡 2

#note(title: [让生活更轻松])[
  目标：如果 $a$、$b$、$c$、$d$ 是自然数，我们有 $(a+b)+(c+d)=((a+c)+d)+b$。

  ```lean
  theorem add_left_comm4 (a b c d : ℕ) : a + b + (c + d) = a + c + d + b := by
  ```
]

为了证明这个定理，我们需要使用之前证明的 `add_left_comm` 定理来交换加法中的项：

- 首先，将等式左侧的加法重新组合为 $a+(b+(c+d))$。
- 然后，使用 `add_left_comm` 定理将 $a+(b+(c+d))$ 重写为 $a+(c+(b+d))$。
- 最后，使用 `add_comm` 定理将 $a+(c+(b+d))$ 重写为 $a+c+(d+b)$，用结合律对括号稍作整理即证。

完整的代码如下：

```lean
rw [add_assoc, add_left_comm b, add_comm b d, add_assoc, add_assoc]
rfl
```

= 关卡 3

#note(title: [让生活变得简单])[
  目标：如果 $a$、$b$、……、$h$ 是自然数，我们有 $(d+f)+(h+(a+c))+(g+e+b)=a+b+c+d+e+f+g+h$。

  ```lean
  example (a b c d e f g h : ℕ) : (d + f) + (h + (a + c)) + (g + e + b) = a + b + c + d + e + f + g + h := by
  ```
]

Lean 的简化器 `simp` 是加强版的 `rw`，它会自动使用之前证明的定理来简化表达式。对于这个定理，我们只需要使用 `simp` 就可以完成证明。完整的代码如下：

```lean
simp only [add_assoc, add_left_comm, add_comm]
```

= 关卡 4

#note(title: [最简单的方法])[
  目标：如果 $a$、$b$、……、$h$ 是自然数，我们有 $(d+f)+(h+(a+c))+(g+e+b)=a+b+c+d+e+f+g+h$。

  ```lean
  example (a b c d e f g h : ℕ) : (d + f) + (h + (a + c)) + (g + e + b) = a + b + c + d + e + f + g + h := by
  ```
]

我们在 Lean 中通过如下代码加入一个新的策略 `simp_add`：

```lean
macro "simp_add" : tactic => `(tactic|(
  simp only [add_assoc, add_left_comm, add_comm]))
```

这个策略可以自动使用所有和加法相关的定理，从而整理和式。对于这个定理，我们只需要使用 `simp_add` 就可以完成证明。完整的代码如下：

```lean
simp_add
```

= 关卡 5

#note(title: [`pred`])[
  目标：如果 $"succ"(a)="succ"(b)$，那么 $a=b$。

  ```lean
  example (a b : ℕ) (h : ) : a = b := by
  ```
]

*这个定理的本质是 `succ_inj`，因此 `succ_inj` 在这个关卡中不可用。*

Lean 除了给出后继数 `succ` 以外，还给出一个前驱数 `pred`，它通过如下两个定理证明：

- `pred 0 := 37`（这本质上是在说 `0` 的前驱是没有定义的）
- `pred_succ (n : ℕ) : pred (succ n) = n`（后继数的前驱等于自身）

在这个定理中，先使用逆向的 `pred_succ` 定理将目标重写为 `pred (succ a) = pred (succ b)`，随后使用假设将左右两侧的 `pred` 内部重写为相同的数，即可完成证明。完整的代码如下：

```lean
rw [← pred_succ a, ← pred_succ b, h]
rfl
```

= 关卡 6

#note(title: [`is_zero`])[
  *定理* `succ_ne_zero`：$"succ"(a)≠0$。

  ```lean
  example (a : ℕ) : succ a ≠ 0 := by
  ```
]

在 Lean 中可以这样定义一个 `is_zero` 函数：

- ```lean is_zero 0 := True```
- ```lean is_zero (succ n) := False```

通过这个定义，还可以给出两个定理：

- ```lean is_zero_zero : is_zero 0 = True```
- ```lean is_zero_succ (n : ℕ) : is_zero (succ n) = False```

在这个定理中，首先需要使用 `intro` 策略引入一个假设 `h`，随后使用逆向的 `is_zero_succ` 将目标 `False` 重写为 `is_zero (succ a)`，最后使用 `h` 将 `succ a` 替换成 `0`，得到 `is_zero 0`。最后使用 `is_zero_zero` 将 `is_zero 0` 重写为 `True`，完成证明。

这里需要注意，如果目标是 `True`，则说明结论在任何情况下都成立，此时需要使用 `trivial` 策略完成证明。完整的代码如下：

```lean
intro h
rw [← is_zero_succ a, h, is_zero_zero]
trivial
```

当然，你也可以使用之前在证明 $0 != 1$ 时给出的 `zero_ne_succ` 定理来证明这个定理：

```lean
symm
exact zero_ne_succ a
```

= 关卡 7

#note(title: [用于证明等价的算法])[
  *定理* `succ_ne_succ`：如果 $a≠b$，那么 $"succ"(a)≠"succ"(b)$。

  ```lean
  theorem succ_ne_succ (m n : ℕ) (h : m ≠ n) : succ m ≠ succ n := by
  ```
]

从逆否命题的角度来看，这个定理等价于 `succ_inj` 定理。在 Lean 中，可以使用 `contrapose! h` 将定理重写为其逆否命题，此时假设 `h` 为 `succ m = succ n`，而目标为 `m = n`。完整的代码如下：

```lean
contrapose! h
apply succ_inj at h
exact h
```

= 关卡 8

#note(title: [`decide`])[
  目标：$20+20=40$。

  ```lean
  example : (20 : ℕ) + 20 = 40 := by
  ```
]

为了比较两个自然数，可以使用如下 Lean 代码：

```lean
instance instDecidableEq : DecidableEq ℕ
| 0, 0 => isTrue <| by
  show 0 = 0
  rfl
| succ m, 0 => isFalse <| by
  show succ m ≠ 0
  exact succ_ne_zero m
| 0, succ n => isFalse <| by
  show 0 ≠ succ n
  exact zero_ne_succ n
| succ m, succ n =>
  match instDecidableEq m n with
  | isTrue (h : m = n) => isTrue <| by
    show succ m = succ n
    rw [h]
    rfl
  | isFalse (h : m ≠ n) => isFalse <| by
    show succ m ≠ succ n
    exact succ_ne_succ m n h
```

在游戏中，如果可以找到一种算法来解决目标（在这个游戏中就是上面给出的算法），则可以直接使用 `decide` 策略来完成证明。完整的代码如下：

```lean
decide
```

= 关卡 9

#note(title: [还是 `decide`])[
  目标：$2+2≠5$。

  ```lean
  example : (2 : ℕ) + 2 ≠ 5 := by
  ```
]

同样地，我们也可以使用 `decide` 策略来完成证明。完整的代码如下：

```lean
decide
```