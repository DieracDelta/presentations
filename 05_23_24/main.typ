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

#slide(title: "Types")[
  - Types match using glibc types
  - Some UB like addition overflow match Compcert C
  - For pointers only use `*mut`
]

#slide(title: "Calling convention")[
  Calling convention: `extern "C"` or `extern "sysv64"`
]


#slide(title: "Globals + Statics")[
  #set text(font: font, weight: wt, size: 15pt)
  #side-by-side_dup[
    #underline("C Lang")
    #codeblock(
    ```C
      static int global_counter = 0;
      const int data = 0;

      void increment_counter() {
          static int inner = 2;
          global_counter += data + inner;
      }

    ```
    )

  ][
    #underline("Rust Lang")
    #codeblock(
    ```rust
    static mut global_counter: c_int = 0;
    #[no_mangle]
    pub static mut data: c_int = 0;

    #[no_mangle]
    pub unsafe extern "C" fn increment_counter() {
        static mut inner: c_int = 2 as c_int;
        global_counter += data + inner;
    }
    ```
    )
  ]
]

#slide(title: "Struct")[
  #set text(font: font, weight: wt, size: 15pt)
  #side-by-side_dup[
    #underline("C Lang")
    #codeblock(
    ```C
      struct LinkedList {
        int size;
        struct LinkedList* next;
        int data[];
      };

    ```
  )

  ][
    #underline("Rust Lang")
    #codeblock(
    ```rust
      #[derive(Copy, Clone)]
      #[repr(C)]
      pub struct LinkedList {
          pub size: c_int,
          pub next: *mut LinkedList,
          pub data: [c_int; 0],
      }
    ```
  )
  ]

]

#slide(title: "Union")[
  #set text(font: font, weight: wt, size: 15pt)
  #side-by-side_dup[
    #underline("C Lang")
    #codeblock(
    ```C
    union Data {
      int i;
      float f;
    };
    ```
  )
  ][
    #underline("Rust Lang")
    #codeblock(
    ```rust
    #[derive(Copy, Clone)]
    #[repr(C)]
    pub union Data {
      pub i: c_int,
      pub f: c_float,
    }
    ```
  )
  ]

]

#slide(title: "Loops")[
  #set text(font: font, weight: wt, size: 15pt)
  #side-by-side_dup[
    #underline("C Lang")
    #codeblock(
    ```C
      int main() {
          int i = 1;

          while (i <= 10) {
              i++;
          }

          return 0;
      }

    ```
  )

  ][
    #underline("Rust Lang")
    #codeblock(
    ```rust
      unsafe fn main_0() -> c_int {
          let mut i: c_int = 1 as c_int;
          i = 0 as c_int;
          while i < 5 as c_int {
              i += 1;
              i;
              i += 1;
              i;
          }
          return 0 as c_int;
      }

    ```
  )
  ]
]

#slide(title: "Switch")[
  #set text(font: font, weight: wt, size: 9pt)
  #side-by-side_dup[
    #underline("C Lang")
    #codeblock(
    ```C
      void copy_mod(char *to, const char *from, int count) {
          int n = (count + 2) / 3;

          switch (count % 3) {
              case 0:        *to++ = *from++;
              case 2:        *to++ = *from++;
              case 1:        *to++ = *from++;
          }
      }

    ```
  )

  ][
    #underline("Rust Lang")
    ```rust
      #[no_mangle]
      pub unsafe extern "C" fn copy_mod(
          mut to: *mut c_char,
          mut from: *const c_char,
          mut count: c_int,
      ) {
          let mut n: c_int = (count + 2 as c_int) / 3 as c_int;
          let mut current_block_2: u64;
          match count % 3 as c_int {
              0 => {
                  let fresh0 = from;
                  from = from.offset(1);
                  let fresh1 = to;
                  to = to.offset(1);
                  *fresh1 = *fresh0;
                  current_block_2 = 3977108684013665309;
              }
              2 => {
                  current_block_2 = 3977108684013665309;
              }
              1 => {
                  current_block_2 = 12446396083632624885;
              }
              _ => {
                  current_block_2 = 715039052867723359;
              }
          }
          match current_block_2 {
              3977108684013665309 => {
                  let fresh2 = from;
                  from = from.offset(1);
                  let fresh3 = to;
                  to = to.offset(1);
                  *fresh3 = *fresh2;
                  current_block_2 = 12446396083632624885;
              }
              _ => {}
          }
          match current_block_2 {
              12446396083632624885 => {
                  let fresh4 = from;
                  from = from.offset(1);
                  let fresh5 = to;
                  to = to.offset(1);
                  *fresh5 = *fresh4;
              }
              _ => {}
          };
      }

    ```
  ]

]

#slide(title: "Goto")[
  #set text(font: font, weight: wt, size: 10pt)
  #side-by-side_dup[
    #underline("C Lang")
    #codeblock(
    ```C
      int sample(int a) {
          int result = 0;

          if (a == 1) {
              goto answer_1;
          } else if (a == 2) {
              goto answer_2;
          }

      answer_1:
          result = 1;
          goto end;

      answer_2:
          result = 2;
          goto end;

      end:
          return result;
      }
    ```
    )

  ][
    #underline("Rust Lang")
    #codeblock(
    ```rust
      #[no_mangle]
      pub unsafe extern "C" fn sample(mut a: c_int) -> c_int {
          let mut current_block: u64;
          let mut result: c_int = 0 as c_int;
          if a == 1 as c_int {
              current_block = 710105030588991595;
          } else if a == 2 as c_int {
              result = 2 as c_int;
              current_block = 2013428324500076459;
          } else {
              current_block = 710105030588991595;
          }
          match current_block {
              710105030588991595 => {
                  result = 1 as c_int;
              }
              _ => {}
          }
          return result;
      }

    ```
  )
  ]

]

#slide(title: "Duff's Device")[
  #set text(font: font, weight: wt, size: 8pt)
  #side-by-side_dup[
    #underline("C Lang")
    #codeblock(
    ```C
      void duffsDevice(char *to, const char *from, int count) {
          int n = (count + 2) / 3;

          switch (count % 3) {
              case 0: do {   *to++ = *from++;
              case 2:        *to++ = *from++;
              case 1:        *to++ = *from++;
                        } while (--n > 0);
          }
      }
    ```
  )

  ][
    #underline("Rust Lang")
    ```rust
#[no_mangle]
pub unsafe extern "C" fn duffsDevice( mut to: *mut c_char, mut from: *const c_char, mut count: c_int) {
    let mut n: c_int = (count + 2 as c_int) / 3 as c_int;
    let mut current_block_2: u64;
    match count % 3 as c_int {
        0 => {
            current_block_2 = 12237857397564741460;
        }
        2 => {
            current_block_2 = 11244789108393354615;
        }
        1 => {
            current_block_2 = 6256153909998011048;
        }
        _ => {
            current_block_2 = 11875828834189669668;
        }
    }
    loop {
        match current_block_2 {
            11875828834189669668 => {
                return;
            }
            12237857397564741460 => {
                let fresh0 = from;
                from = from.offset(1);
                let fresh1 = to;
                to = to.offset(1);
                *fresh1 = *fresh0;
                current_block_2 = 11244789108393354615;
            }
            11244789108393354615 => {
                let fresh2 = from;
                from = from.offset(1);
                let fresh3 = to;
                to = to.offset(1);
                *fresh3 = *fresh2;
                current_block_2 = 6256153909998011048;
            }
            _ => {
                let fresh4 = from;
                from = from.offset(1);
                let fresh5 = to;
                to = to.offset(1);
                *fresh5 = *fresh4;
                n -= 1;
                if n > 0 as c_int {
                    current_block_2 = 12237857397564741460;
                } else {
                    current_block_2 = 11875828834189669668;
                }
            }
        }
    };
}
    ```
  ]

]

#new-section-slide([Lifetimes & Existing Work])

#slide(title: "Lifetimes")[
  - Claim: Use one pointer type `*mut`
  - Need to prove RustLight lifetime semantics matches with Rust
]

#slide(title: "Non-lexical Lifetimes")[
  #codeblock(
  ```Rust
    fn main() {
        let mut scores = vec![1, 2, 3];
        let score = &scores[0];
        scores.push(4);
    }
  ```
)
  (Credit: SO)
// https://stackoverflow.com/questions/50251487/what-are-non-lexical-lifetimes
]

#slide(title: "Existing Work")[
  #set text(font: font, weight: wt, size: 15pt)
  #table(
    columns: 6,
    [*Work*], [*Supports NLL*], [*Supports TPB*], [*Is Source Level*], [*Strictness wrt BC*], [*Models Unsafe*],
    [RustBelt], [Mostly], [No], [No], [Not Strict Enough], [Yes],
    [Oxide], [No], [No], [Yes], [Too strict],  [No],
    [K], [No], [No], [Yes], [Too strict], [No],
    [Stack Borrows], [Yes], [Yes], [Yes], [Too Strict], [Yes],
    [Tree Borrows], [Yes], [Yes], [Yes], [Slightly Too Strict], [Yes],
  )
]



#slide(title: "Two-phase borrow")[

  ```rust
    // pub fn push(&mut self, value: T)
    fn main() {
      let mut v = Vec::new();
      v.push(v.len());
      let r = &mut Vec::new();
      Vec::push(r, r.len());
    }
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
