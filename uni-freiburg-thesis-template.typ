#import "uni-freiburg-thesis-lib.typ": *

/*
Re-export functionality to be accessible via the public API
*/
#let todo = todo
#let todo-missing = todo-missing
#let todo-check = todo-check
#let todo-revise = todo-revise
#let todo-citation = todo-citation
#let todo-language = todo-language
#let todo-question = todo-question
#let todo-note = todo-note

#let unnumbered-chapter = unnumbered-chapter
#let sidenote = sidenote
#let algorithm = algorithm
#let important = important
#let definition = definition
#let theorem = theorem
#let default-sections = (
    (size: 14pt, weight: "bold", space_before: 35pt, space_after: 20pt, style: none), // section
    (size: 12pt, weight: "bold", space_before: 25pt, space_after: 16pt, style: none), // subsection
    (size: 12pt, weight: "bold", space_before: 20pt, space_after: 16pt, style: none)  // subsubsection
)

#let ie = ie
#let eg = eg
#let cf = cf
#let etal = etal

#let citep = citep
#let citet = citet

/*
This is the main function to setup a thesis
*/
#let thesis(
  // Metadata
  title: "Thesis Title",
  author: "Author Name",
  email: "",
  immatriculation: "",
  jury: (),
  department: "Department of Mathematics and Computer Science",
  faculty: "Faculty of Science, University of Basel",
  research-group: "",
  website: "",
  thesis-type: "Bachelor Thesis",
  date: datetime.today(),
  language: "en",
  title-language: auto, // language of the title page; `auto` follows `language`

  // Pass your own fonts
  body-font: default-fonts.body,
  sans-font: default-fonts.sans,
  mono-font: default-fonts.mono,

  // Font sizes - individual parameters
  body-size: 11pt,
  mono-size: 11pt,
  footnote-size: 11pt,
  header-size: 11pt,

  // Page & book layout
  two-sided: true,        // mirror margins on odd/even pages (book layout)
  margin-top: 3.5cm,
  margin-bottom: 3.5cm,
  margin-inner: 3cm,      // binding (inner) margin
  margin-outer: 5.5cm,    // outer margin — also hosts the side notes
  binding: auto,          // spine side: auto (from language), left, or right

  // Side notes (footnotes typeset in the outer margin)
  sidenote-size: 9pt,  
  sidenote-gap: 7mm,   // gap between the text body and the note
  sidenote-edge: 10mm,  // gap between the note and the outer page edge

  // Heading sizes - individual parameters
  chapter-number-size: 100pt,  // chapter number, now shown in the outer margin
  chapter-title-size: 24pt,

  sections: default-sections, // make default a variable, such that individual entries of array can be modified
  default-section: (size: 12pt, weight: "bold", space_before: 20pt, space_after: 16pt,  style: none),

  // Font weights - new parameters
  chapter-number-weight: "bold",
  chapter-title-weight: "bold",

  // Custom text styling functions - optional overrides
  // These allow complete control over text styling if provided
  body-text-style: none,           // Custom function for body text
  mono-text-style: none,           // Custom function for mono/code text
  chapter-number-style: none,      // Custom function for chapter numbers
  chapter-title-style: none,       // Custom function for chapter titles

  logo: auto, // options: auto | none | path | image-element
  logo-width: 50%,

  // Decorative university seal on the title page (background graphic)
  seal: auto,        // options: auto | none | path | image-element
  seal-width: 17cm,
  seal-dx: 8.3cm,    // horizontal offset (lets the seal bleed off the right edge)
  seal-dy: 3.1cm,    // vertical offset from the page center
  seal-opacity: 18%, // how visible the seal is (0% = invisible, 100% = solid)

  // compile mode
  draft: true,        // displays todos
  colored: false,      // Use colors for definitions, theorems, etc.

  // Content
  abstract: [],        // abstract in the document language (`language`)
  abstract-en: none,   // English abstract  -> "Abstract"
  abstract-de: none,   // German abstract   -> "Zusammenfassung"
  acknowledgments: none,
  chapters: (),
  appendices: (),
  bibliography-content: none,
  body,
) = {

  // Set the configuration states (add this at the beginning)
  thesis-draft-state.update(draft)
  thesis-color-state.update(colored)
  set document(title: title, author: author)

  // Physical page width (A4). Used to push the section numbers and side notes
  // into the outer margin. Keep in sync with the page `paper` below.
  let page-width = 21cm

  // Make the side-note geometry available to the `sidenote` function so the
  // note width always matches the configured outer margin.
  sidenote-config.update((
    page-width: page-width,
    margin: margin-outer,
    gap: sidenote-gap,
    edge: sidenote-edge,
    size: sidenote-size,
    numbering: "1",
  ))

  // Mirrored (book) margins when two-sided: the inner margin is the binding
  // side and the outer margin (which hosts the side notes) is wider. Typst
  // automatically flips `inside`/`outside` on odd vs. even pages. A one-sided
  // document keeps the notes on the right.
  let page-margin = if two-sided {
    (top: margin-top, bottom: margin-bottom, inside: margin-inner, outside: margin-outer)
  } else {
    (top: margin-top, bottom: margin-bottom, left: margin-inner, right: margin-outer)
  }

  // The title page is centred, so it uses symmetric left/right margins (the
  // average of the inner and outer margins) instead of the mirrored book ones.
  let symmetric-margin = (
    top: margin-top,
    bottom: margin-bottom,
    x: (margin-inner + margin-outer) / 2,
  )

  // Page setup - matches LaTeX template exactly
  set page(
     paper: "a4",
     margin: page-margin,
     binding: binding,
     header: context {
       let pg = counter(page).get().first()
       if pg > 1 {
         // Chapter-opening pages carry the page number in the footer instead,
         // so they get no running header.
         let on-chapter-page = query(heading.where(level: 1)).any(h =>
           h.location().page() == here().page()
         )

         if not on-chapter-page {
           set text(size: header-size, font: body-font)  // body colour, not gray

           let body-width = page-width - margin-inner - margin-outer
           let recto = if two-sided { calc.odd(pg) } else { true }

           let headings = query(heading.where(level: 1).before(here()))
           let chapter = if headings.len() > 0 { headings.last() } else { none }

           // Verso (left): chapter number + title. Recto (right): the current
           // section title, or nothing if the chapter has no section yet.
           let header-text = if not recto {
             if chapter != none {
               smallcaps(chapter.body)
             } else { [] }
           } else {
             let section-headings = query(heading.where(level: 2).before(here()))
             if section-headings.len() > 0 and chapter != none and (
               counter(heading).at(section-headings.last().location()).first()
                 == counter(heading).at(chapter.location()).first()
             ) {
               let title = smallcaps(section-headings.last().body)
               if chapter.numbering != none {
                 [#numbering("1.1", ..counter(heading).at(section-headings.last().location())) #h(0.6em) #title]
               } else { title }
             } else { [] }
           }

           // The page number sits out in the external margin; the header text is
           // aligned to the external edge of the text block.
           let page-no = counter(page).display()
           block(width: 100%, {
             if recto {
               place(top + left, dx: body-width + sidenote-gap, page-no)
               align(right, header-text)
             } else {
               place(top + right, dx: -(body-width + sidenote-gap), page-no)
               align(left, header-text)
             }
           })
         }
       }
     },
     footer: context {
       let pg = counter(page).get().first()
       let on-chapter-page = query(heading.where(level: 1)).any(h =>
         h.location().page() == here().page()
       )
       // On chapter-opening pages the page number sits at the bottom, in the
       // external margin (lower outer corner).
       if pg > 1 and on-chapter-page {
         set text(size: header-size, font: body-font)
         let body-width = page-width - margin-inner - margin-outer
         let recto = if two-sided { calc.odd(pg) } else { true }
         let page-no = counter(page).display()
         if recto {
           place(top + left, dx: body-width + sidenote-gap, page-no)
         } else {
           place(top + right, dx: -(body-width + sidenote-gap), page-no)
         }
       }
     }
   )

  // Typography - apply default settings first
  set text(
    font: body-font,
    size: body-size,
    lang: language
  )

  show raw: set text(
    font: mono-font,
    size: mono-size,
    lang: language
  )

  // Apply custom styling if provided (this will override the defaults)
  if body-text-style != none {
    show: body-text-style
  }

  if mono-text-style != none {
    show raw: mono-text-style
  }

  // Paragraph settings - matching LaTeX
  set par(
    justify: true,
    leading: 0.65em * 1.5,  // 1.5 line spacing
    first-line-indent: 0pt,  // No indent as in LaTeX
  )

  // Footnote settings
  set footnote.entry(
    separator: line(length: 30%, stroke: 0.5pt),
    gap: 0.65em,
  )

  show footnote.entry: it => {
    set text(size: footnote-size)
    it
  }

  // Short prose-citation syntax: `@key[t]` renders the textual form
  // ("Turing [1]", like LaTeX \citet) while plain `@key` stays "[1]" (\citep).
  // The `[t]` is a sentinel supplement; for a prose citation that also needs a
  // real supplement (e.g. a page), use `#citet` / `#cite(..., supplement: ...)`.
  show ref: it => {
    if it.supplement == [t] {
      cite(it.target, form: "prose")
    } else {
      it
    }
  }

  set heading(numbering: (..nums) => {
    let level = nums.pos().len()
    if level == 1 {
      // Chapter: no dot
      numbering("1", ..nums)
    } else  {
      // Sections and subsections: with dots
      numbering("1.", ..nums)
    }
  })

  // Equation numbering
  set math.equation(numbering: "1.")

  show heading: it => {
    // Chapter style: the number sits in the OUTER margin, bottom-aligned with
    // the title baseline; the title is left-aligned; and a separator rule runs
    // the full width *below* the title.
    if it.level == 1 {
      pagebreak(weak: true)
      v(50pt)

      let number = counter(heading).display()
      let body-width = page-width - margin-inner - margin-outer

      context {
        // Accent colour for the margin number and the rule: Freiburg blue when
        // colored, gray otherwise.
        let accent = if thesis-color-state.get() { freiburg-blue } else { rgb(120, 120, 120) }
        let recto = if two-sided { calc.odd(here().page()) } else { true }

        block(breakable: false, width: 100%, {
          // `bottom-edge: "baseline"` makes both the title block and the number
          // measure down to their baselines, so bottom-aligning the placed
          // number lands its baseline exactly on the title's baseline.
          set text(bottom-edge: "baseline")

          // Chapter number in the outer margin, bottom-aligned with the title.
          if it.numbering != none {
            let num-label = if chapter-number-style != none {
              chapter-number-style(number)
            } else {
              text(size: chapter-number-size, font: sans-font, weight: chapter-number-weight, fill: accent, number)
            }
            if recto {
              place(bottom + left, dx: body-width + sidenote-gap, num-label)
            } else {
              place(bottom + right, dx: -(body-width + sidenote-gap), num-label)
            }
          }

          // Title, left-aligned.
          if chapter-title-style != none {
            chapter-title-style(it.body)
          } else {
            text(size: chapter-title-size, font: sans-font, weight: chapter-title-weight, it.body)
          }
        })

        // Separator rule below the title.
        v(12pt)
        line(length: 100%, stroke: 1pt + accent)
      }
      v(30pt)
    } else {
      // Section style
      let index = it.level - 2
      let section
      if sections.len() >= index {
        section = default-section
      } else {
        section = sections.at(index)
      }

      v(section.space_before, weak:true)
      block(breakable: false)[
        #if section.style != none {
          section.style(counter(heading).display() + " " + it.body)
        } else {
          text(size: section.size, font: sans-font, weight: section.weight)[
            #counter(heading).display() #it.body
          ]
        }
      ]
      v(section.space_after, weak: true)  // Space after section - matching paragraph spacing
    }
  }

  // Title page - matching LaTeX layout
  // The title page can use its own language (e.g. German front matter for an
  // otherwise English thesis); `auto` falls back to the document language.
  let title-lang = if title-language == auto { language } else { title-language }
  // Use symmetric margins for the title page only (restored after it).
  set page(margin: symmetric-margin)
  align(center)[
    // Decorative university seal, bleeding off the right edge of the page.
    // Placed first so the title-page text renders on top of it.
    #if seal != none [
      #let seal-img = if seal == auto {
        image("assets/template/logo-freiburg/Uni_Siegel.svg", width: seal-width)
      } else if type(seal) == "string" {
        image(seal, width: seal-width)
      } else {
        // Assume it's already an image element
        seal
      }
      // Fade the seal into a watermark by overlaying a translucent white layer,
      // so the title-page text stays legible. The wrapping box is given the
      // seal's exact measured size so the overlay's `height: 100%` resolves to
      // the full image height (an auto-height box would only fade the top part).
      #place(right + horizon, dx: seal-dx, dy: seal-dy, context {
        let size = measure(seal-img)
        box(width: size.width, height: size.height)[
          #seal-img
          #place(
            top + left,
            rect(width: 100%, height: 100%, fill: white.transparentize(seal-opacity)),
          )
        ]
      })
    ]

    // Automatically select logo based on language
    #if logo != none [
      #let logo-to-use = if logo == auto {
        image("assets/template/logo-freiburg/20221026-UFR-wortmarke-grundform_Blau_RGB.svg", width: logo-width)
      } else {
        // User provided logo
        if type(logo) == "string" {
          image(logo, width: logo-width)
        } else {
          // Assume it's already an image element
          logo
        }
      }
      #place(top + left, logo-to-use)
    ]

    #if draft [
      #place(top + right,
        rect(
          fill: red.lighten(90%),
          stroke: red,
          inset: 10pt,
        )[
          #text(size: 11pt, fill: red, weight: "bold")[DRAFT VERSION] \
          #text(size: 9pt, fill: red)[
            #datetime.today().display("[day].[month].[year]")
          ]
        ]
      )
    ]

    #v(4cm)

    #text(size: 24pt, font: sans-font, weight: "bold")[#title]

    #v(0.5cm)
    #text(size: 11pt, weight: "bold")[#thesis-type]

    #v(1cm)

    #text()[
      #if title-lang == "en" [presented by] else [präsentiert von]
    ]

    #v(1cm)
    
    #text(size: 11pt)[
      #text(weight: "bold", size: 15pt)[#author] \
      #email \
      #if immatriculation != "" [
        #immatriculation
      ]
    ]
    
    #v(1.5cm)

    #text(size: 11pt)[
      #if research-group != "" [
        #research-group \
      ]
      #department \
      #faculty \

      #if website != "" [
        #website \
      ]
    ]

    #if jury.len() > 0 [
      #v(1.5cm)
      #text(size: 11pt, weight: "bold")[#if title-lang == "en" [Jury] else [Prüfungskommission]]
      #set text(size: 11pt)
      #grid(
        columns: (auto, auto),
        column-gutter: 1.2em,
        row-gutter: 0.75em,
        align: (right, left),
        ..jury
          .map(((role, person)) => ([#role:], strong(person)))
          .flatten()
      )
    ]

    #v(1fr)

    #text(size: 11pt, lang: title-lang)[
      // Typst's `[month repr:long]` is English-only, so format German manually.
      #if title-lang == "en" {
        date.display("[month repr:long] [day], [year]")
      } else {
        let months-de = (
          "Januar", "Februar", "März", "April", "Mai", "Juni",
          "Juli", "August", "September", "Oktober", "November", "Dezember",
        )
        [#str(date.day()). #months-de.at(date.month() - 1) #str(date.year())]
      }
    ]
  ]

  // Restore the mirrored book margins for the rest of the document.
  set page(margin: page-margin)

  // Acknowledgments
  if acknowledgments != none {
    pagebreak()
    unnumbered-chapter[
      #if language == "en" [Acknowledgments] else [Danksagung]
    ]
    acknowledgments
  }
  
  // Abstract(s) - English ("Abstract") and/or German ("Zusammenfassung").
  // `abstract` is treated as the abstract in the document language, so existing
  // single-language usage keeps working; `abstract-en` / `abstract-de` override.
  let abstract-en = if abstract-en != none { abstract-en } else if language == "en" { abstract } else { none }
  let abstract-de = if abstract-de != none { abstract-de } else if language == "de" { abstract } else { none }

  let abstract-entries = (
    ("en", "Abstract", abstract-en),
    ("de", "Zusammenfassung", abstract-de),
  )
  // Show the abstract in the document language first.
  if language == "de" { abstract-entries = abstract-entries.rev() }

  for (lang, heading, content) in abstract-entries {
    if content != none and content != [] {
      pagebreak()
      unnumbered-chapter[#heading]
      text(lang: lang, content)
    }
  }

  // Table of contents
  pagebreak()
  unnumbered-chapter[
    #if language == "en" [Table of Contents] else [Inhaltsverzeichnis]
  ]

  outline(indent: auto, title: none)

  // Main content chapters
  pagebreak()
  for chapter-content in chapters {
    chapter-content
  }

  // Additional body content
  body

  // Bibliography
  if bibliography-content != none {
    pagebreak()
    unnumbered-chapter[
      #if language == "en" [Bibliography] else [Literaturverzeichnis]
    ]
    bibliography-content
  }

  // Appendices
  if appendices.len() > 0 {
    pagebreak()
    set heading(numbering: (..nums) => {
      let level = nums.pos().len()
      if level == 1 {
        // Appendix chapters: no dot
        numbering("A", ..nums)
      } else if level <= 3 {
        // Appendix sections and subsections: with dots
        numbering("A.1", ..nums)
      }
      // Level 4 and deeper: no numbering
    })
    counter(heading).update(0)

    for appendix-content in appendices {
      appendix-content
    }
  }
}