variable (u w x x' y y' z : Nat) (p : Nat â Prop)

example (hâ : x + 0 = x') (hâ : y + 0 = y')
        : x + y + 0 = x' + y' := by
  simp at *
  simp [*]
