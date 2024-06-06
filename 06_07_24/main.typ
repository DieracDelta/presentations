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
  - Run RustLight through the Rust compiler
  - RustLight operational semantics serve as a "Rust Spec"
  - Improve on C2Rust
]

#new-section-slide([Building bigger projects])

#slide(title: "Compilation Information")[
  - In c2rust bear/ninja/intercept-build used to determine locations of includes
  - Python used to connect files
]

#slide(title: "Headers")[
  #set text(font: font, weight: wt, size: 20pt)
  - General structure of file mirrors C
  - Ugly
  ```rust
  pub mod my_header {
    extern "C" {
      pub type ..;
      pub fn ..;
    }
  }
  // more headers

  // code if C file

  ```
]

#slide(title: "Using Variadics")[
  #set text(font: font, weight: wt, size: 15pt)
  #side-by-side_dup[
    #codeblock(
      ```C
        #include <stdio.h>

        void example() {
          printf("Hello world %d", 5);
        }
      ```
    )
  ][
    #set text(font: font, weight: wt, size: 10pt)
    #codeblock(
      ```rust
      extern "C" {
          fn printf(_: *const libc::c_char, _: ...) -> libc::c_int;
      }
      #[no_mangle]
      pub unsafe extern "C" fn example() {
          printf(
            b"Hello world %d\0" as *const u8 as *const libc::c_char,
            5 as libc::c_int
          );
      }
      ```
    )
  ]
]

#slide(title: "Variadics")[
  - Stable Rust can call variadics and link to them
  - Stable Rust *cannot* generate variadic functions
  - Nightly Rust comes with `#![feature(c_variadic)]`
  - Variadics compliant with x86_64-linux ABI
  - `#![feature(c_variadic)]` is used to enable `VaList`
]

#slide(title: "Variadics Rust")[
  #set text(font: font, weight: wt, size: 15pt)
  #codeblock(
    ```rust
      /// The argument list of a C-compatible variadic function, corresponding to the
      /// underlying C `va_list`. Opaque.
      pub struct VaList<'a> { /* fields omitted */ }

      // Note: the lifetime on VaList is invariant
      impl<'a> VaList<'a> {
          /// Extract the next argument from the argument list. T must have a type
          /// usable in an FFI interface.
          pub unsafe fn arg<T>(&mut self) -> T;

          /// Copy the argument list. Destroys the copy after the closure returns.
          pub fn copy<'ret, F, T>(&self, F) -> T
          where
              F: for<'copy> FnOnce(VaList<'copy>) -> T, T: 'ret;
      }
    ```

    )

  ]

#slide(title: "Extern types")[
  #set text(font: font, weight: wt, size: 20.5pt)
  #codeblock(
  ```rust
    typedef struct ExampleS ExampleS;
    typedef union ExampleU ExampleU;
    struct ExampleS* createExample(ExampleU* ex);

    int main() {
        struct ExampleS *myExample = createExample((ExampleU*) 0x0);
        return 0;
    }

    struct ExampleS* createExample(ExampleU* ex) {
        return (struct ExampleS *) 0x0;
    }
  ```
  )
]
#slide(title: "Extern types")[
  #set text(font: font, weight: wt, size: 15pt)
  #codeblock(
  ```rust
    use ::libc;
    extern "C" {
        pub type ExampleS;
        pub type ExampleU;
    }
    unsafe fn main_0() -> libc::c_int {
        let mut myExample: *mut ExampleS = createExample(0 as *mut ExampleU);
        return 0 as libc::c_int;
    }
    #[no_mangle]
    pub unsafe extern "C" fn createExample(mut ex: *mut ExampleU) -> *mut ExampleS {
        return 0 as *mut ExampleS;
    }
    pub fn main() {
        unsafe { ::std::process::exit(main_0() as i32) }
    }
  ```
  )
]

#slide(title: "Extern types")[
  - Rust guarantees that all types have a way to obtain size.
  - Static types can determine this at compile time (e.g. sizeof)
  - Dynamically Sized Types (DST) carry size metadata at runtime (size_of_val)
  - *Not stabilized*
]


// #slide(title: "Aliasing")[
//
// ]

#slide(title: "Borrow Checking Modeling and Thoughts")[
  #set text(font: font, weight: wt, size: 12pt)
  - RL Programs $subset$ Rust Programs
  - RL lifetime reasoning must be at least as strict as Borrow Checker
  - "strict" meaning that
    1) only model *mut and *const pointers
    2) only model *some* lifetime cases
  - Model borrow checking semantics s.t. stricter than the borrow checker
    - Can ignore special (weird) cases like Two Phase Borrow
    - Can reduce scope significantly
      - Only model `*const` `*mut`
      - Don't support implicit borrows
  - Open question: is this enough? Some sort of proof that this *actually* maps onto rust semantics (for which a spec does not exist)
  - Longer term, would need to expand on this to support other pointer types etc
]

// disclaimer: no longer relevant to understand, really
#new-section-slide([Two Phase Borrow])

#slide(title: "Two-phase borrow (Case 1)")[

  ```rust
    let mut v = Vec::new();
    v.push(v.len());
  ```
]

#slide(title: "Two-phase borrow (Simple Example)")[
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
        //temp1 treated as shared pointer to v. temp1 in "Reserved" phase
        let temp3 = &v;
        // temp3 treated as shared pointer to v.
        let temp2 = Vec::len(temp3);
        drop(temp3);
        // temp2 becomes mutable pointer, no longer "Reserved", becomes "Active"
        Vec::push(temp1, temp2);
      ```
    )
  ]
  // TODO MIR
]

// #new-section-slide([Tree Borrows])

// #slide(title: "Tree Borrows")[
//   Each pointer is a state machine that is either:
//   - Reserved
//   - Active
//   - Disabled
//   - Frozen
// ]

//
