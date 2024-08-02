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
  title: "Slides - 8/02",
)

#slide(title: "Table of contents")[
  #metropolis-outline
]

#new-section-slide([Pitch + Plan])

#slide(title: "Abbreviated Pitch" )[
  - Compile C to Rust
  - Improve on C2Rust flaws
  - Guarantee that Rust code matches or improves on behavior of C code
  - Formalize
    - Semantics, Memory Model of small subset of Rust
    - Lifting from unsafe to safe Rust
  - An aside: DARPA TRACTOR
]

#slide(title: "Plan - This week (impl)")[
  #set text(font: font, weight: wt, size: 18pt)
  - formatter fix
  - Syntactic
    - structs unions
    - \_Alignas keyword
    - compiler builtins: alignof, sizeof
    - loops
    - internal function calls
    - nested switch
    - rudimentary pointer operations
      - deref
      - ref
  - pay off some tech debt
]

#slide(title: "Plan - WIP this week (impl)")[
  - WIP
    - volatile
    - more complex data structures (bitfields/VLA)
    - gotos
    - testing
]


#slide(title: "Plan - Next week")[
  - technical:
    - CFRust
      - WIP items
      - modules + imports
      - more builtins
    - introduce RustLight IR
  - theory: work on memory model
]

#new-section-slide([Memory Model])

#slide(title: "Uninitialized structs")[
  #set text(font: font, weight: wt, size: 22pt)
  #codeblock(
    ```C
    struct ExampleStruct {
      int a;
      float b;
      char c;
    };

    fn example(){
      struct ExampleStruct example_struct;
      example_struct.a = 5;
      example_struct.b = 0.5f;
      example_struct.c = '5';
    }
    ```
  )
]

#slide(title: "Uninitialized structs")[
  #set text(font: font, weight: wt, size: 18pt)
  #codeblock(
    ```rust
    #[repr(C)]
    struct ExampleStruct {
      a : libc::c_int,
      b : libc::c_float,
      c : libc::c_schar,
    }

    fn example(){
      let mut example_struct: ExampleStruct;
      example_struct.a = 5;
      example_struct.b = 0.5;
      example_struct.c = 5;
    }
    ```
  )
]

#slide(title: "Uninitialized structs")[
#set text(font: font, weight: wt, size: 15pt)
```
  error[E0381]: partially assigned binding `example_struct` isn't fully initialized
  --> src/lib.rs:10:7
   |
9  |       let mut example_struct: ExampleStruct;
   |           ------------------ binding declared here but left uninitialized
10 |       example_struct.a = 5;
   |       ^^^^^^^^^^^^^^^^^^^^ `example_struct` partially assigned here but it isn't fully initialized
   |
   = help: partial initialization isn't supported, fully initialize the binding with a default value and mutate it, or use `std::mem::MaybeUninit`
```
]

#slide(title: "MaybeUninit Example")[
  #set text(font: font, weight: wt, size: 13pt)
  ```rust
    use std::mem::MaybeUninit;
    use std::ptr::addr_of_mut;

    #[derive(Debug, PartialEq)]
    pub struct Foo {
        a: u8,
        b: u8,
    }

    let foo = {
        let mut uninit: MaybeUninit<Foo> = MaybeUninit::uninit();
        let ptr = uninit.as_mut_ptr();

        unsafe { addr_of_mut!((*ptr).name).write(1); }

        unsafe { addr_of_mut!((*ptr).list).write(2); }

        unsafe { uninit.assume_init() }
    };
  ```

]

#slide(title: "Solutions")[
  - C2Rust style: initialize to 0
  - `std::mem::MaybeUninit`
    - "MaybeUninit<T> is guaranteed to have the same size, alignment, and ABI as T" -- man page
]


#slide(title: "Volatile reads and writes")[
//https://doc.rust-lang.org/core/ptr/fn.read_volatile.html
  - Rust analogue:
    - `std::ptr::read_volatile`
    - `std::ptr::write_volatile`
  - Not defined by Rust other than "C11’s definition of volatile"

]

#slide(title: "RustLight types")[
  - Model compiler intrinsics like `sizeof(T | exp)` and `alignof(T | exp)`
  - Support turbofish `std::mem::sizeof::<T>()`
]
