what does the problem entail
what is the correctness statement
what is 80% C compiled to unsafe + safe rust -- be precise on what this means. What does this entail, what is the implication of this?

Mirror compcerto's definition for correctness. Come back with this

this is tied to the type system you use for minirust (I think he meant RustLight).

If we just have raw pointers, stack heap etc how does each work

"zoom in to have more precise problem definition, challenges"

compare with IR I use, (comparison)
IR:
- primitive types
- string => b"blah"
- functions:
  - purely syntactic (ignoring variadics)
- data
  - unions and structs are the same
- CF
  - syntactic only
  - switch => loops + conditionals
  - goto => loops + conditionals
- pointers: at this point basically the same for now.
- program basically the same

paths forward for my modifications for compcert:

- finish IR definition (program, function)
- finish translation of statement
  - switch
  - goto
  - pointer (same)
- get pretty printing working properly

paths forward for slides:
- copy paste IR into slides (tomorrow)
- precise correctness statement (today)
- memory model: same as C
  - strawman is the same as compcert: don't distinguish between between stack and heap. Just have blocks for now. Pointers are treated the same (?)
  - make a slide on this...? mention nominal compcert




what subset of rust to pick

how are we going to do the translation



fuzzer + translation or LLM

- challenges
  - understanding compcert reps of stuff and why they're needed
- what I've been working on
  - literature review rabbit hole compcertso, comcperto, nominal compcert, compcert's various papers
  - still messing around with the translation. A lot of it is the learning curve related to using compcert. Should have something we can run on examples by mid next week
  - thinking about questions from last week
- lot of details that I thought would be easy but require a bit of thought
  - translation of simpler statements
  - translation of trivial-ish operations (globals etc)
- wrt problem statement
  - spent some time staring at compcerto. Don't have too many take aways
  - we can copy semantic preservation. Is that enough? Do we need more?
  - 80%/20% split. Maybe some of the functions we don't translate or don't support. Translate the pieces of the program that we *can* translate. For those we *can't*, have the user write the rustlight code, prove the correctness theorem. Or we have the user rewrite those sections in a way we can understand. Or we have the user rewrite those sections in a way we can understand.
  - Translation slides coming next week. Just ran out of time
- wrt IRs from rust
  - to be usable we need something we can pass into rustc
  - rustc doesn't take in (HIR, THIR, MIR)
  - would need to do extra lifting step
  - doesn't quite match the way compcert does things. Compcert has a list of used types. By the time the type resolution is done (e.g. THIR), we're moved on


