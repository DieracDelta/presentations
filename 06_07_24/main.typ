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

#slide(title: "Refresher: Vardiadics in C")[
  - `va_list` - informally pointer to the next argument
    - `typedef __builtin_va_list va_list;`
    - `typedef __va_list_tag __builtin_va_list[1]`
  - `va_start(va_list l, last_arg)` - `l` initialized with first arg
  - `va_end(va_list l)` - deallocates l
  - `va_arg(va_list l, t)` - returns next argument
  - `va_copy(va_list l, va_list l')` - copies `l` into `l'`
]

#slide(title: "Using Variadics")[
  #set text(font: font, weight: wt, size: 18pt)
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
    #set text(font: font, weight: wt, size: 16pt)
    #codeblock(
      ```rust
      extern "C" {
          fn printf(
              _: *const libc::c_char,
              _: ...
          ) -> libc::c_int;
      }
      #[no_mangle]
      pub unsafe extern "C" fn example() {
          printf(
            b"Hello world %d\0"
              as *const u8
              as *const libc::c_char,
            5 as libc::c_int
          );
      }
      ```
    )
  ]
]

#slide(title: "Variadics - Map")[
  #set text(font: font, weight: wt, size: 18pt)
  #table(
    columns: 2,
    [C], [Rust],
    [`__va_list_tag[1]`], [`std::ffi::VaList<'a, 'f> where 'f : 'a`],
    [`__va_list_tag*`], [`std::ffi::VaListImpl<'f>`],
    [`va_start(l, last_arg)`], [`l.clone()`],
    [`va_arg(l, t)`], [``],
    [`va_end`], [`drop`],
    [`va_copy`], [`clone`],
  )


]

#slide(title: "Variadics - Rust Caveats")[
  - Stable Rust can call variadics and link to them
  - Stable Rust *cannot* generate variadic functions
  - Nightly Rust (described above) come from `#![feature(c_variadic)]`
  - Variadics compliant with x86_64-linux ABI, not so stable with other ABIs
  - nightly feature `#![feature(c_variadic)]`
]

#slide(title: "Variadics - Interface ")[
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

#slide(title: "Variadics - Example - C")[
  #set text(font: font, weight: wt, size: 14pt)
  #codeblock(
    ```c
    #include <stdio.h>
    #include <stdarg.h>

    int sum(int count, ...);

    int sum(int count, ...) {
        int total = 0;
        va_list args;
        va_start(args, count);

        for (int i = 0; i < count; i++) {
            total += va_arg(args, int);
        }

        va_end(args);
        return total;
    }
    ```
    )
  ]

#slide(title: "Variadics - Example - Rust")[
  #set text(font: font, weight: wt, size: 14pt)
  #side-by-side_dup[
    #codeblock(
    ```c
      #include <stdio.h>
      #include <stdarg.h>

      int sum(int count, ...);

      int sum(int count, ...) {
          int total = 0;
          va_list args;
          va_start(args, count);

          for (int i = 0; i < count; i++) {
              total += va_arg(args, int);
          }

          va_end(args);
          return total;
      }
    ```
    )
  ][
    #codeblock(
      ```rust
      #[no_mangle]
      pub unsafe extern "C" fn sum(
        mut count: libc::c_int,
        mut args: ...
      ) -> libc::c_int {
          let mut total: libc::c_int = 0
            as libc::c_int;
          let mut args_0: ::core::ffi::VaListImpl;
          args_0 = args.clone();
          let mut i: libc::c_int = 0
            as libc::c_int;
          while i < count {
              total += args_0.arg::<libc::c_int>();
              i += 1;
              i;
          }
          return total;
      }
      ```
      )

  ]
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
