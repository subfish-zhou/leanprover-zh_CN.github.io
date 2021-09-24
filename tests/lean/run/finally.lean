def checkM (b : IO Bool) : IO Unit :=
unless (← b) do throw $ IO.userError "failed"

abbrev M := ExceptT String $ StateRefT Nat IO

def f1 : M Nat :=
throw "error 1"

def f2 : M Nat :=
throwThe IO.Error $ IO.userError "error 2"

def tst1 : M Nat := do
try
  try f1 finally set 100; IO.println "finisher executed"
catch _ =>
  get

def checkE {α ε : Type} [BEq α] (x : IO (Except ε α)) (expected : α) : IO Unit := do
let r ← x;
match r with
| Except.ok a    => unless a == expected do throw $ IO.userError "unexpected result"
| Except.error _ => throw $ IO.userError "unexpected error"

#eval (tst1.run).run' 0

#eval checkE ((tst1.run).run' 0) 100

def tst2 : M Nat :=
tryCatchThe IO.Error
  (tryFinally f2 (do set 100; IO.println "finisher executed"))
  (fun _ => get)

#eval (tst2.run).run' 0

#eval checkE ((tst2.run).run' 0) 100

def tst3 : M Nat :=
tryCatchThe IO.Error
  (tryFinally
    (tryFinally f1 (do set 100; IO.println "inner finisher executed"; discard $ f2; pure ()))
    (do modify Nat.succ; IO.println "outer finisher executed"))
  (fun _ => get)

#eval (tst3.run).run' 0

#eval checkE ((tst3.run).run' 0) 101

def tst4 : M Nat := do
let a ← tryFinally
     (tryFinally (pure 42) (do set 100; IO.println "inner finisher executed"; pure ()))
     (do modify Nat.succ; IO.println "outer finisher executed");
let s ← get;
pure (a + s)

#eval (tst4.run).run' 0

#eval checkE ((tst4.run).run' 0) 143

def tst5 : M Nat := do
let (a, _) ← tryFinally' (pure 42) (fun a? => do IO.println ("finalizer received: " ++ toString a?));
pure a

#eval (tst5.run).run' 0

def tst6 : M Nat := do
let (a, _) ← tryFinally' f2 (fun a? => do IO.println ("finalizer received: " ++ toString a?));
pure a

def tst7 : IO Unit :=
tryCatchThe IO.Error (do discard $ (tst6.run).run' 0; pure ()) (fun _ => IO.println "failed as expected")

#eval tst7
