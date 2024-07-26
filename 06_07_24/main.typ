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
  title: "Slides - 6/7",
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

#new-section-slide([Variadics])

#slide(title: "Refresher: Variadics in C")[
  - `printf(...)`  - Syntax
  - `va_list` - informally pointer to info about next argument
    - `typedef __builtin_va_list va_list;`
    - `typedef __va_list_tag __builtin_va_list[1]`
  - `va_start(va_list l, last_arg)` - `l` initialized with info about first arg
  - `va_end(va_list l)` - deallocates l? Spec doesn't say.
  - `t va_arg(va_list l, t)` - returns next argument
  - `va_copy(va_list l, va_list l')` - copies `l` into `l'`
]

#slide(title: "va_list c99 spec")[
  #image("./spec.png")

]
// TODO maybe put spec in

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
#slide(title: "Variadics - Example - C")[
  #set text(font: font, weight: wt, size: 14pt)
  #codeblock(
    ```c
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

#slide(title: "Variadics - `/VaList(Impl)?/`")[
  - `'a` : how long `VaList` lives
  - `'f` : how long underlying `VaListImpl` lives. Always entire function
  #codeblock(
  ```rust
    pub struct VaList<'a, 'f: 'a> {
        inner: &'a mut VaListImpl<'f>,
    }
  ```
)
]

#slide(title: "Variadics - Map")[
  #set text(font: font, weight: wt, size: 18pt)
  #table(
    columns: 2,
    [C], [Rust],
    [`__va_list_tag[1]`], [`std::ffi::VaList<'a, 'f> where 'f : 'a`],
    [`__va_list_tag*`], [`std::ffi::VaListImpl<'f>`],
    [`va_start(l, last_arg)`], [`l.clone()`],
    [`va_arg(l, t)`], [`l.arg::<T: VaArgSafe>()`],
    [`va_copy(a, b)`], [`let b = a.clone()`],
    [`va_end()`], [`Drop::drop()`],
  )


]


#slide(title: "Variadics - Lifetimes prevent Misuse")[
  #set text(font: font, weight: wt, size: 20pt)
  #codeblock(
  ```rust
    pub unsafe extern fn foo<'a>(mut ap: ...) -> VaListImpl<'a> {
        // `VaListImpl` would escape
        ap
    }

  ```
    // /// misuse
    // fn bar<'a, 'f, 'g: 'f>(ap: &mut VaList<'a, 'f>, aq: VaList<'a, 'g>) {
    //     // Incompatible types
    //     *ap = aq;
    // }
  )
]

#slide(title: "Variadics - Rust Caveats")[
  - Stable Rust can call variadics and link to them
  - Stable Rust *cannot* generate variadic functions
  - Nightly Rust (described above) come from `#![feature(c_variadic)]`
  - Variadics compliant with x86_64-linux ABI, not so stable with other ABIs
  - nightly feature `#![feature(c_variadic)]`
]

#new-section-slide([Forward Declaration])

#slide(title: "Forward Declarations - C")[
  #set text(font: font, weight: wt, size: 18pt)
  #codeblock(
  ```rust
    // linker resolves
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
#slide(title: "Forward Declarations - Rust")[
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

#slide(title: "Forward Declaration - Extern Type")[
  - Rust guarantees that all types have a way to obtain size.
  - Static types can determine this at compile time (e.g. size_of)
  - Dynamically Sized Types (DST) carry size metadata at runtime (size_of_val)
  - *Not stabilized*
]

#new-section-slide([Borrow Checking])

#slide(title: "Borrow Checking Modeling and Thoughts")[
  #set text(font: font, weight: wt, size: 17pt)
  - RL Programs $subset$ Rust Programs
  - All RL programs must be accepted by borrow checker.
  - Not all accepted by borrow checker programs need to be modeled by RL.
  - Model borrow checking semantics s.t. stricter than the borrow checker
    - Can ignore complicated edge cases like Two Phase Borrow
    - Can reduce scope significantly
      - Only model `*const` `*mut`
      - By definition drop edge cases
  - Open question: is this enough? How to show this *actually* maps onto rust semantics (for which a spec does not exist)
  - Longer term, would need to expand on this to support other pointer types. How to model `&`?
]

// disclaimer: no longer relevant to understand, really
#new-section-slide([Two Phase Borrow])

#slide(title: "Two-phase Borrow Intuition")[
  - `&mut` when borrowed implicitly #emph("Reserved") until used to mutate, at which point becomes #emph("Active")
  - While #emph("Reserved"), is treated as a shared (immutable) pointer
  - While #emph("Active"), is treated as mutable pointer
]

#slide(title: "Two-phase Borrow (Implicit Mutable Borrow)")[

  #side-by-side_dup[
    ✔️
    ```rust
      let mut v = Vec::new();
      v.push(v.len());
    ```
  ][
    ❌

    ```rust
      let mut v = Vec::new();
      let v_ptr = &mut v;
      let v_len = v.len();
      v_ptr.push(v_len);
    ```
  ]
  // https://play.rust-lang.org/?version=stable&mode=debug&edition=2021&gist=394ce5a86466a3d003fe1d841464c940
]

#slide(title: "Two-phase Borrow (Implicit Mutable Borrow)")[
  #set text(font: font, weight: wt, size: 15pt)
  #side-by-side_dup[
    Source Code:\
    #codeblock(
      ```rust
        let mut v = Vec::new();
        v.push(v.len());
      ```
    )
  ][
    Source Code with implicit behavior made explicit:
    #codeblock(
      ```rust
        let mut v = Vec::new();
        // no pointers
        let temp1 = &mut v;
        //temp1 treated as shared pointer to v. temp1: "Reserved"
        let temp3 = &v;
        // temp3 treated as shared pointer to v.
        let temp2 = Vec::len(temp3);
        drop(temp3);
        // temp1: "Active"
        Vec::push(temp1, temp2);
      ```
    )
  ]
]

#slide(title: "Two-phase Borrow (Implicit Reborrow)")[
  #set text(font: font, weight: wt, size: 14pt)
  #side-by-side_dup[
    Source Code:\
    #codeblock(
      ```rust
        let r = &mut Vec::from([0]);
        std::mem::replace(
          /*implicit reborrow: &mut * */ r,
          vec![1, r.len()]
        );
      ```
    )
  ][
    Source Code with implicit behavior made explicit:
    #codeblock(
      ```rust
        let mut temp_vec = Vec::from([0]); // line 1
        let r = &mut temp_vec; // line 1
        // r: "Active"
        let temp1 = &mut *r; // line 3
        // r: "Suspended", temp1: "Reserved" because implicit borrow
        let temp3 = &*r; // line 4
        // temp3: shared pointer
        let r_len : int = Vec::len(temp3); // line 4
        let temp4 = vec![1, r_len]; // line 4
        // r: "Suspended", temp1: "Active" because implicit borrow
        std::mem::replace(temp1, temp4);
      ```
    )
  ]
]

#new-section-slide([Building bigger projects (tmux)])

#slide(title: "Compilation Information")[
  - In c2rust bear/ninja/intercept-build used to determine locations of included headers
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
