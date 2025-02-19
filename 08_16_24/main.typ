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
  title: "Slides - 8/16",
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
]

#new-section-slide([Plan])

#slide(title: "This week")[
  - review concrat
  - multi-file translation
]

#slide(title: "Next week")[
  - slides on aeneas
  - complete multi-file translation
]

#slide(title: "C2Rust")[
  - Fed `compile_commands.json`
  - Copy-paste of header types into each corresponding C file
  - Externally link against function declarations and globals
    - Broken with recent rust toolchains
  - Difficult to understand/unnecessary
]

#slide(title: "Underlying difference")[
  - C2Rust: compiled together, linked at crate level
  - GCC: compiled separately into object files, then linked together
]

#slide(title: "Laertes")[
  - Deduplication pass (ResolveImports) after C2Rust transpilation
  - Data structure location arbitrary
  - Does not detect executables
]

#slide(title: "Conceptual design")[
#set text(font: font, weight: wt, size: 22pt)
  - Direction 1:
    - Exactly match C
    - Workspace with crate (separate compilation unit) per object file
    - Exactly follow `compile_commands.json`
    - Shim outside compcert
  - Direction 2:
    - Follow prior work, (not faithful to C)
    - Compile directly within crate as Laertes does
    - Maintain distinction between header and c file
    - Shim within compcert
  - In both cases:
    - support executables
    - process `compile-commands.json`
]

// #new-section-slide([Borrow checking via symbolic semantics])
//
// #slide(title: "Review: Aeneas")[
//   - Low Level Borrow Calculus - modeled after MIR
//   - Value based. No memory, addresses, pointer arithmetic
//   - Ownership is Oxide style: modeled via regions, loans instead of semantic lifetimes
//   - Aeneas workflow: LLBC -> lambda calculus -> itp (F\* or coq)
// ]
//
// #slide(title: "Review: Aeneas")[
//   - Limitations
//     - No unsafe
//     - No interior mutability
//   - Pros
//     - LLBC semantics are intuitive
// ]
//
// #slide(title: "Example of LLBC semantics")[
//   ```rust
//   let mut x = 0;
//   // x -> 0
//   let mut px = &mut x;
//   // x -> loan_mut l
//   // px -> borrow_mut l 0
//   let ppx = &mut px;
//   // x -> loan_mut l
//   // px -> borrow_mut l'
//   // ppx -> borrow_mut l' (borrow_mut l 0)
//   ```
//
// ]
//
// #slide(title: "Symbolic Semantics for LLB")[
//
// ]
//
// #new-section-slide([Switch statement])
//
// #slide(title: "Existing literature")[
//   - Relooper
//     - Pros
//     - Cons
//   -

// ]

