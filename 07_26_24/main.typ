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
  title: "Slides - 7/12",
)

#slide(title: "Table of contents")[
  #metropolis-outline
]

#new-section-slide([Pitch])

#slide(title: "Abbreviated Pitch" )[
  - Compile C to Rust
  - Improve on C2Rust flaws
  - Guarantee that Rust code matches or improves on behavior of C code
  - Provide formalization of lifting literature
]

#slide(title: "Plan")[
  - This week: switch statement works
  - Next week:
    - technical:
      - nested switch (minor tweak)
      - fix formatter
      - gotos
      - testing
      - code cleanup
    - Proposition for memory model
  - Two weeks:
    - RustLight design
]

#slide(title: "Switch statement details")[
  - c2rust: many match statements
  - improvement (in theory):
    - s/repeats/loop
  - problem: temporary variables (assumed not canonical)
  - solution: nominal compcert?
]

//#slide(title: "Memory Model options")[
//  - Strawman: match compcert
//  - Should this change?
//    - Rust structs: matches C
//    - Calling convention: matches C
//]

//#slide(title: "Precise Problem Statement: The 80%")[
//  - Happy path overall correctness theorem:
//  $
//  forall "c_prog", "rl_prog". C_"COMPCERT" \(p) = r arrow.r.double "sem"\("c_prog") lt.curly.eq "sem"\("rl_prog")
//  $
//
//  Go through IRs:
//  $
//  forall "c_prog", "rl_prog". C_"COMPCERT" \(p) = r arrow.r.double "sem"\("c_prog") lt.curly.eq "sem"\("rl_prog")
//  $
//]

#slide(title: "Precise Problem Statement: The 20%")[
  In the case we can't

]


#new-section-slide([Implementation])

#new-section-slide([Comparison to Rust IRs])
