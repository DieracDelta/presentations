#import "polylux/polylux.typ": *
#import themes.metropolis: *
#import "common.typ": *

#show: metropolis-theme.with(
  footer: [#logic.logical-slide.display() / #utils.last-slide-number]
)

#set text(font: font, weight: wt, size: 25pt)
// #show math.equation: set text(font: "Fira Math")
#set strong(delta: 100)
#set par(justify: true)

#title-slide(
  author: [Justin Restivo],
  title: "Slides - 8/09",
)

#slide(title: "Table of contents")[
  #metropolis-outline
]

#new-section-slide([Pitch])

#slide(title: "Abbreviated Pitch" )[
  - Compile C to Rust
  - Improve on C2Rust flaws
  - Guarantee that Rust code matches or improves on behavior of C code
  - Formalize
    - Semantics, borrow checking, memory model of small subset of Rust
    - Lifting from unsafe to safe Rust with already-defined semantics
  - Thoughts on LLMs + Proposer's day registration
]

#new-section-slide([Plan])

#slide(title: "Plan - This week")[
  #set text(font: font, weight: wt, size: 18pt)
  - reject volatile keyword from C  ✅
  - goto
  - more builtins
  - Literature review: aeneas, cf literature
  - testing
  - triple check initialization (TODO post on rust internals)
  - think about ideas for proposal
]

#slide(title: "Plan - WIP this week (impl)")[
]

#new-section-slide([Plan])


#slide(title: "Plan - Next week")[
  - technical:
    - CFRust
      - WIP items
      - modules + imports
      - more builtins
    - introduce RustLight IR
  - theory: work on memory model
]

#new-section-slide([Borrow checking via symbolic semantics])

#slide(title: "Review: Aeneas")[
  - Low Level Borrow Calculus - modeled after MIR
  - Value based. No memory, addresses, pointer arithmetic
  - Ownership is Oxide style: modeled via regions, loans instead of semantic lifetimes
  - Aeneas workflow: LLBC -> lambda calculus -> itp (F\* or coq)
]

#slide(title: "Review: Aeneas")[
  - Limitations
    - No unsafe
    - No interior mutability
  - Pros
    - LLBC semantics are intuitive
]

#slide(title: "Example of LLBC semantics")[
  ```rust
  let mut x = 0;
  // x -> 0
  let mut px = &mut x;
  // x -> loan_mut l
  // px -> borrow_mut l 0
  let ppx = &mut px;
  // x -> loan_mut l
  // px -> borrow_mut l'
  // ppx -> borrow_mut l' (borrow_mut l 0)
  ```

]

#slide(title: "Symbolic Semantics for LLB")[

]

#new-section-slide([Switch statement])

#slide(title: "Existing literature")[
  - Relooper
    - Pros
    - Cons
  -

]

