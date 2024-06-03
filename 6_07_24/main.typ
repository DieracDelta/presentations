#import "polylux/polylux.typ": *
#import themes.metropolis: *

#show: metropolis-theme.with(
  footer: [#logic.logical-slide.display() / #utils.last-slide-number]
)

#let codeblock(body, caption: none, lineNum:true) = {
    if lineNum {
      show raw.where(block:true): it =>{
        set par(justify: false)
        block(fill: luma(240),inset: 0.3em,radius: 0.3em,
          // grid size: N*2
          grid(
            columns: 2,
            align: left+top,
            column-gutter: 0.5em,
            stroke: (x,y) => if x==0 {( right: (paint:gray, dash:"densely-dashed") )},
            inset: 0.3em,
            ..it.lines.map((line) => (str(line.number), line.body)).flatten()
          )
        )
      }
      figure(body, caption: caption, kind: "code", supplement: "Code")
    }
    else{
      figure(body, caption: caption, kind: "code", supplement: "Code")
    }
  }

#let font = "Fira Code Regular Nerd Font Complete"
#let wt = "light"

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

#new-section-slide([High Level Idea])

#slide(title: "Pitch")[
  - Compile C to a #alert[unsafe subset] of Rust (“RustLight”)
  #uncover((2, 3, 4))[- Run RustLight through the Rust compiler]
  #uncover((3, 4))[- RustLight operational semantics serve as a "Rust Spec"]
  #uncover(4)[- Improve on C2Rust]
]

#new-section-slide([Translation Intuition (C2Rust)])

#slide(title: "Translation Intuition")[
  - Run through examples from C2Rust
]

#let side-by-side_dup(columns: none, gutter: 1em, ..bodies) = {
  let bodies = bodies.pos()
  let columns = if columns ==  none { (1fr,) * bodies.len() } else { columns }
  if columns.len() != bodies.len() {
    panic("number of columns must match number of content arguments")
  }

  grid(columns: columns, gutter: gutter, align: top, ..bodies)
}

#slide(title: "Existing Work")[
  #set text(font: font, weight: wt, size: 15pt)
  #table(
    columns: 6,
    [*Work*], [*Supports NLL*], [*Supports TPB*], [*Is Source Level*], [*Strictness wrt BC*], [*Models Unsafe*],
    [RustBelt], [Mostly], [No], [No], [Not Strict Enough], [Yes],
    [Oxide], [No], [No], [Yes], [Too strict],  [No],
    [KRust], [No], [No], [Yes], [Too strict], [No],
    [Stack Borrows], [Yes], [Yes], [Yes], [Too Strict], [Yes],
    [Tree Borrows], [Yes], [Yes], [Yes], [Slightly Too Strict], [Yes],
  )
]

#slide(title: "Two-phase borrow (Case 1)")[

  ```rust
    // pub fn push(&mut self, value: T)
    fn main() {
    }
  ```
  (Credit: Rustc dev)
  // https://rustc-dev-guide.rust-lang.org/borrow_check/two_phase_borrows.html
]

#slide(title: "Two-phase borrow (Case 2)")[

  ```rust
  ```
  (Credit: Rustc dev)
  // https://rustc-dev-guide.rust-lang.org/borrow_check/two_phase_borrows.html
]


#slide(title: "Tree Borrows")[
  Each pointer is a state machine that is either:
  - Reserved
  - Active
  - Disabled
  - Frozen
]

//
