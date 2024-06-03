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

#let side-by-side_dup(columns: none, gutter: 1em, ..bodies) = {
  let bodies = bodies.pos()
  let columns = if columns ==  none { (1fr,) * bodies.len() } else { columns }
  if columns.len() != bodies.len() {
    panic("number of columns must match number of content arguments")
  }

  grid(columns: columns, gutter: gutter, align: top, ..bodies)
}

