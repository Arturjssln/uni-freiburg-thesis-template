// Utility functions provided by this template.

#let thesis-draft-state = state("thesis-draft", true)
#let thesis-color-state = state("thesis-color", true)

#let freiburg-blue = rgb("#344A9A")

// Body and sans fonts are bundled in assets/fonts (Source Serif 4 / Source
// Sans 3). Compile with `--font-path assets/fonts` so Typst can find them.
#let default-fonts = (
  body: ("Source Serif 4", "Libertinus Serif"),       // ~ Times New Roman
  sans: ("Source Sans 3", "Libertinus Serif"),        // ~ Arial
  mono: ("DejaVu Sans Mono",),                        // ~ Courier New
)


// === TODO FUNCTIONS ===
#let todo(content, color: red) = {
  rect(
    fill: color.lighten(80%),
    stroke: color,
    radius: 3pt,
    inset: 5pt,
    width: 100%,
  )[*TODO:* #content]
}

#let todo-missing(content) = todo(content, color: rgb(204, 0, 204))
#let todo-check(content) = todo(content, color: rgb(204, 0, 0))
#let todo-revise(content) = todo(content, color: rgb(204, 102, 0))
#let todo-citation(content) = todo(content, color: rgb(204, 204, 0))
#let todo-language(content) = todo(content, color: rgb(102, 102, 204))
#let todo-question(content) = todo(content, color: rgb(0, 204, 0))
#let todo-note(content) = todo(content, color: rgb(51, 51, 51))

// === LAYOUT HELPERS ===
#let unnumbered-chapter(body) = {
  heading(level: 1, numbering: none, outlined: false, body)
}

// === CUSTOM FIGURE TYPES ===
#let algorithm(content, caption: none) = {
  figure(
    align(left)[
      #rect(
        width: 100%,
        stroke: 0.5pt + gray,
        inset: 10pt,
        content
      )
    ],
    caption: caption,
    supplement: "Algorithm",
  )
}

// === HIGHLIGHTING ===
#let important(content) = context {
  if thesis-color-state.get() {
    highlight(fill: yellow.lighten(60%), content)
  } else {
    emph(content)  // italic in non-colored mode
  }
}

// === CUSTOM BOXES ===
#let definition(title: "Definition", content) = context {
  if thesis-color-state.get() {
    rect(
      width: 100%,
      stroke: freiburg-blue,
      radius: 3pt,
      inset: 10pt,
    )[
      #text(weight: "bold", fill: blue)[#title.] #content
    ]
  } else {
    rect(
      width: 100%,
      stroke: 0.5pt + gray,
      radius: 0pt,
      inset: 10pt,
    )[
      #text(weight: "bold")[#title.] #content
    ]
  }
}

#let theorem(title: "Theorem", content) = context {
  if thesis-color-state.get() {
    rect(
      width: 100%,
      stroke: green.darken(20%),
      radius: 3pt,
      inset: 10pt,
    )[
      #text(weight: "bold", fill: green.darken(20%))[#title.] #content
    ]
  } else {
    rect(
      width: 100%,
      stroke: 0.5pt + gray,
      radius: 0pt,
      inset: 10pt,
    )[
      #text(weight: "bold")[#title.] #content
    ]
  }
}

// === SIDE NOTES (margin "footnotes") ===
// Footnote-style notes that are typeset in the OUTER margin of the page
// instead of at the bottom: the right margin on odd (recto) pages and the
// left margin on even (verso) pages. This only makes sense in a two-sided
// (book) layout with a generous outer margin.
//
// `thesis()` injects the geometry via the state below so the note width
// always matches the configured outer margin. The function itself stays
// self-contained so it can be exported and called from anywhere.
#let sidenote-config = state("thesis-sidenote-config", (
  page-width: 210mm,  // physical page width (used to locate the outer margin)
  margin: 45mm,       // width of the outer margin (where notes live)
  gap: 5mm,           // horizontal gap between the text body and the note
  edge: 2mm,          // gap between the note and the outer page edge
  size: 8pt,          // font size of the note text
  numbering: "1",     // marker numbering pattern (only used when numbered)
))

#let sidenote-counter = counter("thesis-sidenote")

// Render a note in the outer margin.
//   numbered: add an automatically-numbered superscript marker (off by default)
//   dy:       nudge the note up/down to avoid collisions with nearby notes
#let sidenote(body, numbered: false, dy: 0pt) = {
  // Step the marker counter in document flow so the in-text marker and the
  // margin note always display the same number.
  if numbered { sidenote-counter.step() }
  context {
    let cfg = sidenote-config.get()
    let recto = calc.odd(here().page())
    let pos = here().position()  // physical position of the call site
    // The note spans the outer margin minus the body-side gap and the
    // outer-edge padding (`edge`).
    let note-width = cfg.margin - cfg.gap - cfg.edge

    // Optional in-text superscript marker.
    let marker = super(numbering(cfg.numbering, ..sidenote-counter.get()))
    if numbered { marker }

    // The note itself: smaller, tighter leading. The clean (flush) edge faces
    // the text body — left-aligned in the right margin, right-aligned in the
    // left margin — so the ragged edge always points to the outer page edge.
    let note-align = if recto { left } else { right }
    let note-body = {
      set text(size: cfg.size)
      set par(justify: false, leading: 0.5em, first-line-indent: 0pt)
      align(note-align, {
        if numbered { marker + h(0.35em) }
        body
      })
    }

    // Physical x of the note's left edge, inside the OUTER margin: the right
    // margin on recto pages, the left margin on verso pages.
    let target-x = if recto { cfg.page-width - cfg.margin + cfg.gap } else { cfg.edge }

    // Wrap the placement in a zero-size inline box so it does NOT break the
    // surrounding paragraph (a bare `place` is block-level and would). The
    // box sits at the call site, so we offset from the call site's physical
    // position to reach the margin and line the note up with the current line.
    box(place(
      top + left,
      dx: target-x - pos.x,
      dy: dy,
      box(width: note-width, note-body),
    ))
  }
}

// === CITATIONS ===
// LaTeX-style citation helpers mirroring natbib:
//   citep(<key>) -> "[1]"            (parenthetical / numeric — like \citep)
//   citet(<key>) -> "Turing [1]"     (textual prose form — like \citet)
// Accepts a label (`<key>`) or several: #citep(<a>, <b>).
#let citep(..keys) = keys.pos().map(k => cite(k)).join()
#let citet(..keys) = keys.pos().map(k => cite(k, form: "prose")).join()

// === ABBREVIATIONS ===
// Common abbreviations used throughout the thesis
#let ie = [_i.e._]
#let eg = [_e.g._]
#let cf = [_cf._]
#let etal = [_et al._]
