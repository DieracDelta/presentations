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

#slide(title: "Abbreviated Pitch" )[
  - Compile C to a subset of Rust (RustLight)
    - Memory model
    - Borrow checking
    - Operational semantics
  - LLMs
  - Proposer's day registration
]

#slide(title: "This week")[
  - Literature
    - goto 🚧
    - Aeneas 🚧
  - Initialization (miri, rust-internals)
  - Minor technical improvements
]

#slide(title: "Next week")[
  - Slides
    - Aeneas
    - goto
  - Implementation: goto
]

// #slide(title: "Aside on Aeneas")[
//   #image("./ss.png")
// ]
