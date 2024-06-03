#import "polylux/polylux.typ": *
#import themes.metropolis: *
#import "common.typ": *

#show: metropolis-theme.with(
  footer: [#logic.logical-slide.display() / #utils.last-slide-number]
)

#set text(font: font, weight: wt, size: 25pt)
#show math.equation: set text(font: "Fira Math")
#set strong(delta: 100)
#set par(justify: true)

#title-slide(
  author: [Justin Restivo],
  title: "Slides - 5/23",
)

#slide(title: "Table of contents")[
  #metropolis-outline
]

#new-section-slide([High Level Idea (Review)])

#slide(title: "Pitch (Review)" )[
  - Compile C to a #alert[unsafe subset] of Rust (“RustLight”)
  #uncover((2, 3, 4))[- Run RustLight through the Rust compiler]
  #uncover((3, 4))[- RustLight operational semantics serve as a "Rust Spec"]
  #uncover(4)[- Improve on C2Rust]
]

#new-section-slide([Couple of Unanswered questions])

#slide(title: "Modules")[
  TODO
]

#slide(title: "Aliasing")[

]

#slide(title: "Borrow Checking Strength")[
  - RL Programs $subset$ Rust Programs
  - RL lifetime reasoning must be at least as strict as Borrow Checker
  - E.g. Okay to model borrow checking semantics s.t. stricter than the borrow checker
    - Can ignore Two Phase Borrow
    - Only use `*mut` pointer
]

// #slide(title: "Existing Work")[
//   #set text(font: font, weight: wt, size: 15pt)
//   #table(
//     columns: 6,
//     [*Work*], [*Supports NLL*], [*Supports TPB*], [*Is Source Level*], [*Strictness wrt BC*], [*Models Unsafe*],
//     [RustBelt], [Mostly], [No], [No], [Not Strict Enough], [Yes],
//     [Oxide], [No], [No], [Yes], [Too strict],  [No],
//     [KRust], [No], [No], [Yes], [Too strict], [No],
//     [Stack Borrows], [Yes], [Yes], [Yes], [Too Strict], [Yes],
//     [Tree Borrows], [Yes], [Yes], [Yes], [Slightly Too Strict], [Yes],
//   )
// ]

// disclaimer: no longer relevant to understand, really
#new-section-slide([Two Phase Borrow])

#slide(title: "Two-phase borrow (Case 1)")[

  ```rust
    let mut v = Vec::new();
    v.push(v.len());
  ```
]

#slide(title: "Two-phase borrow (Case 1)")[
  #set text(font: font, weight: wt, size: 15pt)
  #side-by-side_dup[
    Source Code:\
    #codeblock(
      ```rust
        let mut v = Vec::new();
        // append length of vector to vector
        v.push(v.len());
      ```
    )
  ][
    Source Code with implicit behavior:
    #codeblock(
      ```rust
        let mut v = Vec::new();
        // no pointers
        let temp1 = &mut v;
        //temp1 treated as shared pointer to v. "Reserved" phase
        let temp3 = &v;
        // temp3 treated as shared pointer
        let temp2 = Vec::len(temp3);
        drop(temp3);
        // temp3 becomes mutable pointer
        Vec::push(temp1, temp2);
      ```
    )
  ]
  // TODO MIR
]

#new-section-slide([Tree Borrows])

#slide(title: "Tree Borrows")[
  Each pointer is a state machine that is either:
  - Reserved
  - Active
  - Disabled
  - Frozen
]

//
