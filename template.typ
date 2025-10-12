// Some definitions presupposed by pandoc's typst output.
#let blockquote(body) = [
  #set text( size: 0.92em )
  #block(inset: (left: 1.5em, top: 0.2em, bottom: 0.2em))[#body]
]

#let horizontalrule = line(start: (25%,0%), end: (75%,0%))

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms: it => {
  it.children
    .map(child => [
      #strong[#child.term]
      #block(inset: (left: 1.5em, top: -0.4em))[#child.description]
      ])
    .join()
}

// Some quarto-specific definitions.

#show raw.where(block: true): set block(
    fill: luma(230),
    width: 100%,
    inset: 8pt,
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let d = (:)
  let fields = old_block.fields()
  fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.abs
  }
  return block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == str {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == content {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

// Subfloats
// This is a technique that we adapted from https://github.com/tingerrr/subpar/
#let quartosubfloatcounter = counter("quartosubfloatcounter")

#let quarto_super(
  kind: str,
  caption: none,
  label: none,
  supplement: str,
  position: none,
  subrefnumbering: "1a",
  subcapnumbering: "(a)",
  body,
) = {
  context {
    let figcounter = counter(figure.where(kind: kind))
    let n-super = figcounter.get().first() + 1
    set figure.caption(position: position)
    [#figure(
      kind: kind,
      supplement: supplement,
      caption: caption,
      {
        show figure.where(kind: kind): set figure(numbering: _ => numbering(subrefnumbering, n-super, quartosubfloatcounter.get().first() + 1))
        show figure.where(kind: kind): set figure.caption(position: position)

        show figure: it => {
          let num = numbering(subcapnumbering, n-super, quartosubfloatcounter.get().first() + 1)
          show figure.caption: it => {
            num.slice(2) // I don't understand why the numbering contains output that it really shouldn't, but this fixes it shrug?
            [ ]
            it.body
          }

          quartosubfloatcounter.step()
          it
          counter(figure.where(kind: it.kind)).update(n => n - 1)
        }

        quartosubfloatcounter.update(0)
        body
      }
    )#label]
  }
}

// callout rendering
// this is a figure show rule because callouts are crossreferenceable
#show figure: it => {
  if type(it.kind) != str {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let old_title = old_title_block.body.body.children.at(2)

  // TODO use custom separator if available
  let new_title = if empty(old_title) {
    [#kind #it.counter.display()]
  } else {
    [#kind #it.counter.display(): #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block, 
    block_with_new_content(
      old_title_block.body, 
      old_title_block.body.body.children.at(0) +
      old_title_block.body.body.children.at(1) +
      new_title))

  block_with_new_content(old_callout,
    block(below: 0pt, new_title_block) +
    old_callout.body.children.at(1))
}

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black, body_background_color: white) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color, 
        width: 100%, 
        inset: 8pt)[#text(icon_color, weight: 900)[#icon] #title]) +
      if(body != []){
        block(
          inset: 1pt, 
          width: 100%, 
          block(fill: body_background_color, width: 100%, inset: 8pt, body))
      }
    )
}

#import "@preview/touying:0.6.1": *
#import "@preview/fontawesome:0.5.0": *
#import "@preview/ctheorems:1.1.3": *
#import "@preview/cades:0.3.0": qr-code
#import "@preview/mitex:0.2.5": *
// Helper function to handle hex colors and Typst color functions
#let parse-color(color-str) = {
  if color-str.starts-with("\\#") {
    rgb(color-str.slice(2))
  } else if color-str.starts-with("#") {
    rgb(color-str.slice(1))
  } else if color-str.starts-with("luma(") or color-str.starts-with("rgb(") or color-str.starts-with("color.") {
    // Handle Typst color functions - evaluate them directly
    eval(color-str)
  } else {
    // Assume it's a literal color name or other valid Typst color
    eval(color-str)
  }
}

#let new-section-slide(self: none, body)  = touying-slide-wrapper(self => {
  let main-body = {
    set align(left + horizon)
    set text(size: 2em, fill: self.colors.primary, weight: "bold", font: self.store.font-family-heading)
    utils.display-current-heading(level: 1)
  }
  self = utils.merge-dicts(
    self,
    config-page(margin: (left: 2em, top: -0.25em)),
  )
  touying-slide(self: self, main-body)
})


// Fix math after items
//  See https://github.com/typst/typst/issues/529
#show math.equation.where(block: true): eq => {
  block(width: 100%,align(center, $eq$))
}

#let slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  // set page
  let header(self) = {
    set align(top)
    show: components.cell.with(inset: (x: 1.2em, top: 1.0em))
    set text(
      size: 1.4em,
      fill: self.colors.neutral-darkest,
      weight: self.store.font-weight-heading,
      font: self.store.font-family-heading,
    )
    utils.call-or-display(self, self.store.header)
  }
  let footer(self) = {
    set align(bottom)
    show: pad.with(.4em)
    set text(fill: self.colors.neutral-darkest, size: .7em)
    utils.call-or-display(self, self.store.footer)
    h(1fr)
    context utils.slide-counter.display() + "/" + utils.last-slide-number
  }

  // Set the slide
  let slide-background = if self.store.background-image != none {
    image(self.store.background-image, width: 100%, height: 100%)
  } else if self.store.background-color != none {
    rect(width: 100%, height: 100%, fill: self.store.background-color)
  } else {
    none
  }

  let self = utils.merge-dicts(
    self,
    config-page(
      header: header,
      footer: footer,
      background: slide-background,
    ),
  )
  touying-slide(self: self, config: config, repeat: repeat, setting: setting, composer: composer, ..bodies)
})


#let superslides-theme(
  aspect-ratio: "16-9",
  handout: false,
  header: utils.display-current-heading(level: 2),
  footer: [],
  font-size: 18pt,
  font-family-heading: ("Roboto"),
  font-family-body: ("Roboto"),
  font-family-math: none,
  font-weight-heading: "regular",
  font-weight-body: "regular",
  font-weight-title: "light",
  font-weight-subtitle: "light",
  font-size-title: 1.4em,
  font-size-subtitle: 1em,

  // Simplified color system - only 3 colors needed
  text-color: parse-color("#131516"),      // Body text color
  primary-color: parse-color("#107895"),   // Main accent color
  secondary-color: parse-color("#9a2515"), // Secondary accent color
  strong-weight: "regular",

  raw-font-size: 15pt,  // Code block font size
  raw-inline-size: none,  // Separate size for inline code (if none, uses body font size)
  raw-inset: 8pt,  // Inset for raw code blocks
  // List customization options
  list-indent: 1em,  // Indentation for list items
  list-marker-1: "▶",  // First level list marker (triangle.filled symbol)
  list-marker-2: "▷",  // Second level list marker (triangle symbol)
  list-marker-3: "•",  // Third level list marker (bullet)
  // Background options
  background-image: none,
  background-color: none,
  // Title page options
  logo-path: none,  // Set to none by default to avoid missing file errors
  title-compact: false,
  qr-code-url: none,
  qr-code-title: "QR Code",
  qr-code-size: 5cm,  // Size of QR code on title page
  qr-code-button-color: none,  // Color for QR code button (defaults to accent color)
  last-updated-text: "Versione:",
  // Custom title slide typography
  title-font: none,     // Custom title font (if none, uses font-family-heading)
  title-size: 36pt,     // Title font size
  title-weight: "bold", // Title font weight
  subtitle-font: none,  // Custom subtitle font (if none, uses font-family-body)
  subtitle-size: 24pt,  // Subtitle font size
  subtitle-weight: "regular", // Subtitle font weight
  author-size: 18pt,    // Author info font size
  date-size: 16pt,      // Date font size
  updates-link: none,   // Link for last updated button
  // Author styling options
  affiliation-color: none,  // Color for affiliation text
  affiliation-style: none,  // Style for affiliation text (italic, normal)
  affiliation-weight: none, // Weight for affiliation text
  email-color: none,        // Color for email text
  // Language support
  lang: "en",              // Language for last updated text

  // Global box settings (no individual colors - generated from primary/secondary)
  box-border-thickness: 1pt,
  box-border-radius: 4pt,
  box-shadow: none,
  box-title-font-size: none,
  box-title-font-weight: "bold",
  box-body-font-size: none,
  box-body-font-weight: "regular",
  box-spacing-above: 1em,
  box-spacing-below: 1em,
  box-padding: 8pt,

  // Theorem system configuration (colors auto-generated from primary-color)
  theorem-package: "ctheorems",  // "ctheorems" or "theorion"
  theorem-lang: "it",
  theorem-numbering: false,
  ..args,
  body,
) = {
  set text(size: font-size, font: font-family-body, fill: text-color,
           weight: font-weight-body)


if font-family-math != none {
  show math.equation: set text(font: font-family-math)
}



  // Configure raw text styling for all code blocks
  show raw.where(block: true): it => {
    // Regular code blocks get normal styling
    set text(size: raw-font-size)
    set block(inset: raw-inset, fill: luma(245), radius: 2pt)
    it
  }

  // Inline code uses raw-inline-size if specified, otherwise uses body font size
  show raw.where(block: false): set text(
    size: if raw-inline-size != none { raw-inline-size } else { font-size }
  )

  // Strong/bold text styling (uses secondary color)
  show strong: it => text(
    fill: secondary-color,
    weight: strong-weight,
    it.body
  )

  show: touying-slides.with(

    config-page(
      paper: "presentation-" + aspect-ratio,
      margin: (top: 4em, bottom: 1.5em, x: 2em),
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
      slide-level: 2,        // ## creates new slides
      section-level: 1,      // # creates section slides
      handout: handout,
      enable-frozen-states-and-counters: false,
      // https://github.com/touying-typ/touying/issues/72
      show-hide-set-list-marker-none: true,
      show-strong-with-alert: false
    ),
    config-methods(
      init: (self: none, body) => {
        show link: set text(fill: self.colors.primary)

        // Unordered List with customizable markers and indent
        set list(
          indent: list-indent,
          marker: (text(fill: self.colors.primary)[#list-marker-1],
                   text(fill: self.colors.primary)[#list-marker-2],
                   text(fill: self.colors.primary)[#list-marker-3]),
        )
        // Ordered List
        set enum(
          indent: list-indent,
          full: true, // necessary to receive all numbers at once, so we can know which level we are at
          numbering: (..nums) => {
            let nums = nums.pos()
            let num = nums.last()
            let level = nums.len()

            // format for current level
            let format = ("1.", "i.", "a.").at(calc.min(2, level - 1))
            let result = numbering(format, num)
            text(fill: self.colors.primary, result)
          }
        )
        // Slide Subtitle
        show heading.where(level: 3): title => {
          set text(
            size: 1.1em,
            fill: self.colors.primary,
            font: font-family-body,
            weight: "regular",
            style: "normal",
          )
          block(inset: (top: -0.5em, bottom: 0.25em))[#title]
        }

        // Level 4 headings - italic instead of bold
        show heading.where(level: 4): title => {
          set text(
            size: 1em,
            fill: text-color,
            font: font-family-body,
            weight: "regular",
            style: "italic",
          )
          block(inset: (top: 0.25em, bottom: 0.25em))[#title]
        }

        // Table styling - clean design for markdown tables
        show table: it => {
          set table(
            stroke: (x, y) => {
              // Top border for header row
              if y == 0 { (top: 2pt + self.colors.primary, bottom: 1pt + self.colors.primary) }
              // Bottom border for last row
              else if y == it.rows.len() - 1 { (bottom: 0.5pt + self.colors.primary.lighten(50%)) }
              // No other borders
              else { none }
            },
            inset: 8pt,
            fill: (x, y) => {
              // Header row background
              if y == 0 { self.colors.primary.lighten(90%) }
              // Alternating row colors
              else if calc.odd(y) { self.colors.primary.lighten(97%) }
              else { white }
            }
          )

          block(above: 1em, below: 1em, it)
        }

        set bibliography(title: none)

        body
      },
      alert: (self: none, it) => text(fill: self.colors.secondary, weight: "bold", it),
    ),
    config-colors(
      primary: primary-color,
      secondary: secondary-color,
      neutral-lightest: rgb("#ffffff"),
      neutral-darkest: text-color,
    ),
    // save the variables for later use
    config-store(
      header: header,
      footer: footer,
      font-family-heading: font-family-heading,
      font-family-body: font-family-body,
      font-size-title: font-size-title,
      font-size-subtitle: font-size-subtitle,
      font-weight-heading: font-weight-heading,
      font-weight-title: font-weight-title,
      font-weight-subtitle: font-weight-subtitle,
      background-image: background-image,
      background-color: background-color,
      logo-path: logo-path,
      title-compact: title-compact,
      qr-code-url: qr-code-url,
      qr-code-title: qr-code-title,
      qr-code-size: qr-code-size,
      qr-code-button-color: qr-code-button-color,
      last-updated-text: last-updated-text,
      // Simplified color system
      primary-color: primary-color,
      secondary-color: secondary-color,
      // Box configuration
      box-border-thickness: box-border-thickness,
      box-border-radius: box-border-radius,
      box-shadow: box-shadow,
      box-title-font-size: box-title-font-size,
      box-title-font-weight: box-title-font-weight,
      box-body-font-size: box-body-font-size,
      box-body-font-weight: box-body-font-weight,
      box-spacing-above: box-spacing-above,
      box-spacing-below: box-spacing-below,
      box-padding: box-padding,
      title-font: title-font,
      title-size: title-size,
      title-weight: title-weight,
      subtitle-font: subtitle-font,
      subtitle-size: subtitle-size,
      subtitle-weight: subtitle-weight,
      author-size: author-size,
      date-size: date-size,
      updates-link: updates-link,
      affiliation-color: affiliation-color,
      affiliation-style: affiliation-style,
      affiliation-weight: affiliation-weight,
      email-color: email-color,
      lang: lang,
      // Theorem configuration (colors auto-generated from primary-color)
      theorem-package: theorem-package,
      theorem-lang: theorem-lang,
      theorem-numbering: theorem-numbering,
      ..args,
    ),
  )

  body
}

#let title-slide(
  ..args,
) = touying-slide-wrapper(self => {
  let info = self.info + args.named()

  let body = {
    set align(left + top)

    // Logo at the top left if provided
    if self.store.logo-path != none {
      block(
        inset: (bottom: 2em),
        image(self.store.logo-path, width: 4cm)
      )
    }

    // Title - Left aligned, all caps, customizable font
    block(
      inset: (bottom: 0.1em),
      text(
        size: if self.store.title-size != none { self.store.title-size } else { 36pt },
        fill: self.colors.neutral-darkest,
        weight: if self.store.title-weight != none { self.store.title-weight } else { "bold" },
        font: if self.store.title-font != none { (self.store.title-font,) } else { self.store.font-family-heading },
        upper(info.title)
      )
    )

    // Subtitle - Left aligned underneath title
    if info.subtitle != none {
      block(
        inset: (bottom: 2em),
        text(
          size: if self.store.subtitle-size != none { self.store.subtitle-size } else { 24pt },
          fill: self.colors.neutral-darkest,
          weight: if self.store.subtitle-weight != none { self.store.subtitle-weight } else { "regular" },
          font: if self.store.subtitle-font != none { (self.store.subtitle-font,) } else { self.store.font-family-body },
          info.subtitle
        )
      )
    }

    // Authors section - Conditional handling for single vs multiple authors
    if info.authors != none {
      block(
        inset: (bottom: 1.5em),
        {
          if info.authors.len() == 1 {
            // Single author - show full details with ORCID icon
            let author = info.authors.at(0)

            // Author name with ORCID icon if available
            text(
              size: if self.store.author-size != none { self.store.author-size } else { 18pt },
              fill: self.colors.neutral-darkest,
              weight: "medium",
              author.name
            )

            // ORCID icon next to name
            if author.orcid != none {
              h(0.3em)
              let orcid-id = repr(author.orcid).trim("\"")
              let orcid-url = "https://orcid.org/" + orcid-id
              link(orcid-url.replace("\\/", "/"))[
                #text(
                  size: if self.store.author-size != none { self.store.author-size } else { 18pt },
                  fill: rgb("A6CE39")
                )[#fa-icon("orcid")]
              ]
            }

            if author.affiliation != none {
              linebreak()
              text(
                size: 16pt,
                fill: if self.store.affiliation-color != none { self.store.affiliation-color } else { self.colors.primary },
                style: if self.store.affiliation-style != none { self.store.affiliation-style } else { "italic" },
                weight: if self.store.affiliation-weight != none { self.store.affiliation-weight } else { "regular" },
                author.affiliation
              )
            }

            if author.email != none {
              linebreak()
              let email-addr = repr(author.email).trim("\"")
              let email-url = "mailto:" + email-addr
              link(email-url.replace("\\/", "/"))[
                #text(
                  size: 14pt,
                  fill: if self.store.email-color != none { self.store.email-color } else { self.colors.primary }
                )[#author.email]
              ]
            }
          } else {
            // Multiple authors - show names only
            for (i, author) in info.authors.enumerate() {
              text(
                size: if self.store.author-size != none { self.store.author-size } else { 18pt },
                fill: self.colors.neutral-darkest,
                weight: "medium",
                author.name
              )

              if i < info.authors.len() - 1 {
                text(", ")
              }
            }
          }
        }
      )
    }

    // Date section
    if info.date != none {
      block(
        inset: (bottom: 2em),
        text(
          size: if self.store.date-size != none { self.store.date-size } else { 16pt },
          fill: self.colors.primary,
          weight: "medium",
          if type(info.date) == datetime {
            info.date.display(self.datetime-format)
          } else {
            info.date
          }
        )
      )
    }

    // Push to bottom for QR code and last updated
    v(1fr)

    // Bottom section with absolute positioning
    place(
      left + bottom,
      dx: 0pt,
      dy: 0pt,
      // Last updated as button with link (if provided) - left side
      if info.date != none {
        // Language-aware last updated text
        let last-updated-text = if self.store.lang == "it" {
          "Aggiornato al:"
        } else {
          "Last updated:"
        }

        block[
          #if self.store.updates-link != none {
            link(self.store.updates-link.replace("\\/", "/"))[
              #box(
                inset: 8pt,
                radius: 4pt,
                fill: self.colors.primary,
                text(
                  size: 12pt,
                  fill: white,
                  weight: "medium"
                )[#last-updated-text #info.date]
              )
            ]
          } else {
            text(
              size: 12pt,
              fill: self.colors.primary,
              style: "italic"
            )[#last-updated-text #info.date]
          }
        ]
      }
    )

    place(
      right + bottom,
      dx: 0pt,
      dy: 0pt,
      // QR Code in bottom right corner
      if self.store.qr-code-url != none {
        align(center)[
          #qr-code(self.store.qr-code-url.replace("\\/", "/"), width: self.store.qr-code-size)
          #if self.store.qr-code-title != none {
            v(-1.5em)
            link(self.store.qr-code-url.replace("\\/", "/"))[
              #box(
                width: self.store.qr-code-size,
                inset: 4pt,
                radius: 2pt,
                fill: if self.store.qr-code-button-color != none { self.store.qr-code-button-color } else { self.colors.primary },
                align(center)[
                  #text(
                    size: 8pt,
                    fill: white,
                    font: self.store.font-family-body,
                    weight: "medium"
                  )[#self.store.qr-code-title]
                ]
              )
            ]
          }
        ]
      }
    )
  }

  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(margin: (top: 3em, bottom: 2em, x: 3em))
  )
  touying-slide(self: self, body)
})




// Custom Functions
#let fg = (fill: rgb("e64173"), it) => text(fill: fill, it)
#let bg = (fill: rgb("abcdef88"), it) => highlight(
    fill: rgb("abcdef88"),
    radius: 1pt,
    extent: .2em,
    stroke: white,
    top-edge: 1em,
    bottom-edge: -.3em,
    it
  )
#let _button(self: none, it, url: none) = {
  let button_content = box(inset: 5pt,
      radius: 3pt,
      fill: self.colors.primary)[
    #set text(size: 0.5em, fill: white)
    #sym.triangle.filled.r
    #it
  ]

  // If URL is provided, make it clickable
  if url != none {
    link(url)[#button_content]
  } else {
    button_content
  }
}

#let button(it, url: none) = touying-fn-wrapper(_button.with(it, url: url))

// Text scaling functions for font size classes
#let text-scale-tiny(body) = {
  set text(size: 0.6em)
  body
}

#let text-scale-small(body) = {
  set text(size: 0.8em)
  body
}

#let text-scale-smaller(body) = {
  set text(size: 0.8em)
  body
}

#let text-scale-large(body) = {
  set text(size: 1.2em)
  body
}

#let text-scale-larger(body) = {
  set text(size: 1.2em)
  body
}

#let text-scale-huge(body) = {
  set text(size: 1.5em)
  body
}

#show emph: it => {
  set text(fill: black, style: "italic")
  it
}
#import "@preview/ctheorems:1.1.3": *
#show: thmrules
#let theorem = thmbox("theorem", "Theorem")
#let lemma = thmbox("lemma", "Lemma")
#let definition = thmbox("definition", "Definition")

#set page(
  paper: "us-letter",
  margin: (x: 1.25in, y: 1.25in),
  numbering: "1",
)

// Helper function to handle hex colors and Typst color functions
#let parse-color(color-str) = {
  if color-str.starts-with("\\#") {
    rgb(color-str.slice(2))
  } else if color-str.starts-with("#") {
    rgb(color-str.slice(1))
  } else if color-str.starts-with("luma(") or color-str.starts-with("rgb(") or color-str.starts-with("color.") {
    // Handle Typst color functions - evaluate them directly
    eval(color-str)
  } else {
    // Assume it's a literal color name or other valid Typst color
    eval(color-str)
  }
}

#show: superslides-theme.with(
  aspect-ratio: "16-9",
    // Typography ---------------------------------------------------------------
      font-size: 24pt,
        font-family-heading: ("Inter",),
        font-family-body: ("Inter",),
          font-weight-heading: "medium",
        font-weight-body: "regular",
        strong-weight: "medium",
        raw-font-size: 14pt,
        raw-inline-size: 22pt,
        raw-inset: 8pt,
  
  // List customization --------------------------------------------------------
      list-indent: 0.6em,
        list-marker-1: "•",
        list-marker-2: "◦",
        list-marker-3: "▪",
  
  // Simplified 3-color system -------------------------------------------------
      text-color: parse-color("\#131516"),
        primary-color: parse-color("\#107895"),
        secondary-color: parse-color("\#9a2515"),
  
  // Background ----------------------------------------------------------------
      // Title slide ---------------------------------------------------------------
      title-font: "Inter",
        title-size: 1.6em,
        title-weight: "bold",
        subtitle-font: "Inter",
        subtitle-size: 1.3em,
        subtitle-weight: "regular",
        author-size: 1.0em,
        date-size: 0.8em,
        font-weight-title: "light",
        font-size-title: 1.4em,
        font-size-subtitle: 1em,
        updates-link: "https:\/\/github.com/gragusa/superslides/releases",
        affiliation-color: parse-color("\#707070"),
        affiliation-style: "italic",
        affiliation-weight: "regular",
        email-color: parse-color("\#CD853F"),
        lang: "en",
  
  // Title page customization --------------------------------------------------
              qr-code-url: "https:\/\/github.com/gragusa/superslides",
        qr-code-title: "View Source",
        qr-code-size: 4cm,
        qr-code-button-color: parse-color("\#404040"),
        last-updated-text: "Last updated:",
  
  // Showybox customization (colors auto-generated from primary/secondary) ----
  // Border and appearance settings
      box-border-thickness: 1pt,
        box-border-radius: 6pt,
        box-shadow: none,
  
  // Typography settings
      box-title-font-size: 1.1em,
        box-title-font-weight: "bold",
        box-body-font-size: 1em,
        box-body-font-weight: "regular",
  
  // Spacing settings
      box-spacing-above: 1em,
        box-spacing-below: 1em,
        box-padding: 8pt,
  
  // Theorem configuration (colors auto-generated from primary-color) ---------
      theorem-package: "ctheorems",
        theorem-lang: "en",
        theorem-numbering: true,
  )




// Dynamic theorem setup based on YAML - colors generated from primary-color
#import "@preview/ctheorems:1.1.3": *
#show: thmrules

#import "_extensions/superslides/translations.typ"
#import "_extensions/superslides/colors.typ"
// Helper function for simple sequential numbering
  #let unary(.., last) = last

#let theorem = thmbox(
  "theorem",
  translations.variant("theorem"),
  fill: parse-color("\#107895").lighten(80%)
).with(
  numbering: unary
)

#let lemma = thmbox(
  "lemma",
  translations.variant("lemma"),
  fill: parse-color("\#107895").lighten(80%)
).with(
  numbering: unary)

#let proposition = thmbox(
  "proposition",
  translations.variant("proposition"),
  fill: parse-color("\#107895").lighten(80%)
).with(
  numbering: unary)

#let corollary = thmbox(
  "corollary",
  translations.variant("corollary"),
  fill: parse-color("\#107895").lighten(80%)
).with(
  numbering: unary)

#let definition = thmbox(
  "definition",
  translations.variant("definition"),
  fill: parse-color("\#107895").lighten(90%)
).with(
  numbering: unary)

#let example = thmbox(
  "example",
  translations.variant("example"),
  fill: parse-color("\#107895").lighten(90%)
).with(
  numbering: unary)

#let assumption = thmbox(
  "assumption",
  translations.variant("assumption"),
  fill: parse-color("\#107895").lighten(90%)
).with(
  numbering: unary)


#set table(
  stroke: none,
  // fill: (x, y) =>
  //   if calc.odd(x) and y>0 { luma(240) }
  //   else { white },
  row-gutter: 0.0em,
  inset: (right: 1.5em),
)

#show table.cell: set text(size: 0.8em)
#show table.cell.where(y: 0): strong

#title-slide(
  title: [Superslides Template],
  subtitle: [Super features demo],
  authors: (
                    ( name: [Giuseppe Ragusa],
            affiliation: [Sapienza University of Rome],
            email: [],
            orcid: []),
            ),
  date: [2025-09-26],
  update-date: [October 1, 2025],
  web: [],
  icon: []
)
#import "@preview/colorful-boxes:1.4.3": *
#let bluebox(body) = {
  outline-colorbox(
    color: "blue",
    title: "Sommario"
  )[#body]}
#import "@preview/showybox:2.0.4": showybox
#import "@preview/cades:0.3.0": qr-code
#let highlightbox(body) = {
showybox(
frame: (
  border-color: blue,
  title-color: blue.lighten(30%),
  body-color: blue.lighten(95%),
  footer-color: blue.lighten(80%)
))[#body]}

= Getting Started
<getting-started>
== Introduction
<introduction>
#showybox(
  below: 1em,
  body_style: (
    weight: "regular",
    size: 1em
  ),
  above: 1em,
  frame: (
    border-color: rgb("#107895"),
    title-color: rgb("#107895").darken(10%),
    body-color: rgb("#107895").lighten(90%),
    footer-color: rgb("#107895").lighten(80%),
    thickness: 1pt,
    radius: 6pt
  ),
  sep: (
    thickness: 8pt
  ),
  title_style: (
    weight: "bold",
    size: 1.1em
  ),
  shadow: none,
)[
Welcome to #strong[Superslides];! This template demonstrates:

- Enhanced Typst presentations with Touying
- Professional title slides with interactive elements
- Advanced code blocks with zebraw integration
- Simple 3-color customization system

$ Y_t = A_1 Y_(t - 1) + E_t arrow.r integral f (x) d x $

]
== Math
<math>
$ Y_i = X_i beta + u_i \, quad i = 1 \, dots.h \, n $

== Features Overview
<features-overview>
=== Key capabilities
<key-capabilities>
- 🎨 Professional title slides with left-aligned layout
- 🔗 Interactive QR codes and clickable links
- 📝 Enhanced code blocks with mathematical annotations
- 🎯 Simple 3-color palette system
- 🌐 Multi-language support (English/Italian)

==== Note: This is a fourth level header `====`
<note-this-is-a-fourth-level-header>
== Typography
<typography>
Standard markdown formatting works as expected:

- #emph[emphasis] (`_emphasis_`)
- #strong[bold] (`**bold**`)
- #strong[#emph[bold emphasis];] (`**_bold emphasis_**`)
- #strike[strikethrough] (`~~strikethrough~~`)
- #alert()[alert] (`[alert]{.alert}`)
- strong (`[strong]{.strong}`)

== Code Blocks
<code-blocks>
#block[
```r
plot(rnorm(10))
```

]
#grid(
columns: (1fr), gutter: 1em, rows: 1,
  rect(stroke: none, width: 100%)[
#align(center)[#box(image("template_files/figure-typst/unnamed-chunk-1-1.svg"))]
],
)
== 
<section>
#block[
```python
import matplotlib.pyplot as plt
plt.plot([1,23,2,4])
plt.show()
plt.plot([8,65,23,90])
plt.show()
```

]
#grid(
columns: (1fr, 1fr), gutter: 1em, rows: 1,
  rect(stroke: none, width: 100%)[
#figure(image("template_files/figure-typst/unnamed-chunk-2-1.svg", width: 100.0%),
  caption: [
    Line Plot 1
  ]
)

],
  rect(stroke: none, width: 100%)[
#figure(image("template_files/figure-typst/unnamed-chunk-2-2.svg", width: 100.0%),
  caption: [
    Line Plot 2
  ]
)

],
)
== Code Block Configuration
<code-block-configuration>
You can control code block appearance through YAML parameters:

- `raw-font-size: 20pt` - Font size for code blocks
- `raw-inline-size: 20pt` - Font size for inline code
- `raw-inset: 2pt` - Padding around code blocks

== Python Example
<python-example>
```python
def quadratic_formula(a, b, c):
    """Solve quadratic equation ax² + bx + c = 0"""
    discriminant = b**2 - 4*a*c

    if discriminant < 0:
        return None  # No real solutions
    elif discriminant == 0:
        return -b / (2*a)  # One solution
    else:
        sqrt_d = discriminant**0.5
        x1 = (-b + sqrt_d) / (2*a)
        x2 = (-b - sqrt_d) / (2*a)
        return x1, x2
```

== R Statistical Analysis
<r-statistical-analysis>
```r
calculate_statistics <- function(data) {
    n <- length(data)
    mean_x <- sum(data) / n
    variance <- sum((data - mean_x)^2) / (n-1)
    std_dev <- sqrt(variance)
    se <- std_dev / sqrt(n)

    return(list(
        mean = mean_x,
        variance = variance,
        std_dev = std_dev,
        std_error = se
    ))
}
```

== Julia Mathematical Functions
<julia-mathematical-functions>
```julia
function fibonacci(n)
    if n <= 1
        return n
    else
        return fibonacci(n-1) + fibonacci(n-2)
    end
end
```

== Inline Code
<inline-code>
You can also use `inline code` within text. The font size is controlled by the `raw-inline-size` parameter.

= Table
<table>
== Table using R
<table-using-r>
```r
library(tinytable)
## fontsize is in em
tt(head(iris))|> style_tt(fontsize=0.8) |> theme_striped()
```

#figure([
#show figure: set block(breakable: true)

#block[ // start block

  #let style-dict = (
    // tinytable style-dict after
    "0_0": 0, "2_0": 0, "4_0": 0, "6_0": 0, "0_1": 0, "2_1": 0, "4_1": 0, "6_1": 0, "0_2": 0, "2_2": 0, "4_2": 0, "6_2": 0, "0_3": 0, "2_3": 0, "4_3": 0, "6_3": 0, "0_4": 0, "2_4": 0, "4_4": 0, "6_4": 0, "1_0": 1, "3_0": 1, "5_0": 1, "1_1": 1, "3_1": 1, "5_1": 1, "1_2": 1, "3_2": 1, "5_2": 1, "1_3": 1, "3_3": 1, "5_3": 1, "1_4": 1, "3_4": 1, "5_4": 1
  )

  #let style-array = ( 
    // tinytable cell style after
    (fontsize: 0.8em,),
    (fontsize: 0.8em, background: rgb("#ededed"),),
  )

  // Helper function to get cell style
  #let get-style(x, y) = {
    let key = str(y) + "_" + str(x)
    if key in style-dict { style-array.at(style-dict.at(key)) } else { none }
  }

  // tinytable align-default-array before
  #let align-default-array = ( left, left, left, left, left, ) // tinytable align-default-array here
  #show table.cell: it => {
    if style-array.len() == 0 { return it }
    
    let style = get-style(it.x, it.y)
    if style == none { return it }
    
    let tmp = it
    if ("fontsize" in style) { tmp = text(size: style.fontsize, tmp) }
    if ("color" in style) { tmp = text(fill: style.color, tmp) }
    if ("indent" in style) { tmp = pad(left: style.indent, tmp) }
    if ("underline" in style) { tmp = underline(tmp) }
    if ("italic" in style) { tmp = emph(tmp) }
    if ("bold" in style) { tmp = strong(tmp) }
    if ("mono" in style) { tmp = math.mono(tmp) }
    if ("strikeout" in style) { tmp = strike(tmp) }
    tmp
  }

  #align(center, [

  #table( // tinytable table start
    columns: (auto, auto, auto, auto, auto),
    stroke: none,
    rows: auto,
    align: (x, y) => {
      let style = get-style(x, y)
      if style != none and "align" in style { style.align } else { left }
    },
    fill: (x, y) => {
      let style = get-style(x, y)
      if style != none and "background" in style { style.background }
    },
 table.hline(y: 1, start: 0, end: 5, stroke: 0.05em + black),
 table.hline(y: 7, start: 0, end: 5, stroke: 0.1em + black),
 table.hline(y: 0, start: 0, end: 5, stroke: 0.1em + black),
 table.hline(y: 7, start: 0, end: 5, stroke: 0.1em + rgb("#d3d8dc")),
 table.hline(y: 0, start: 0, end: 5, stroke: 0.1em + rgb("#d3d8dc")), table.hline(y: 1, start: 0, end: 5, stroke: 0.1em + rgb("#d3d8dc")),
    // tinytable lines before

    // tinytable header start
    table.header(
      repeat: true,
[Sepal.Length], [Sepal.Width], [Petal.Length], [Petal.Width], [Species],
    ),
    // tinytable header end

    // tinytable cell content after
[5.1], [3.5], [1.4], [0.2], [setosa],
[4.9], [3.0], [1.4], [0.2], [setosa],
[4.7], [3.2], [1.3], [0.2], [setosa],
[4.6], [3.1], [1.5], [0.2], [setosa],
[5.0], [3.6], [1.4], [0.2], [setosa],
[5.4], [3.9], [1.7], [0.4], [setosa],

    // tinytable footer after

  ) // end table

  ]) // end align

] // end block
], caption: figure.caption(
position: bottom, 
[
First few rows of the iris dataset.
]), 
kind: "quarto-float-tbl", 
supplement: "Table", 
)
<tbl-iris>


== Table using R with math
<table-using-r-with-math>
#block[
```r
library(tinytable)

theme_mitex <- function(x, ...) {
    fn <- function(table) {
        if (isTRUE(table@output == "typst")) {
          table@table_string <- gsub("\\$(.*?)\\$", "#mitex(`\\1`)", table@table_string)
        }
        return(table)
    }
    x <- style_tt(x, finalize = fn)
    x <- theme_striped(x)
    return(x)
}

options(tinytable_html_mathjax = TRUE)
options(tinytable_tt_theme = theme_mitex)
```

]
```r
data.frame(Math = c("$\\alpha$", "$a_{it}$", "$e^{i\\pi} + 1 = 0$")) |>
  tt()
```

#show figure: set block(breakable: true)

#block[ // start block

  #let style-dict = (
    // tinytable style-dict after
    "1_0": 0, "3_0": 0
  )

  #let style-array = ( 
    // tinytable cell style after
    (background: rgb("#ededed"),),
  )

  // Helper function to get cell style
  #let get-style(x, y) = {
    let key = str(y) + "_" + str(x)
    if key in style-dict { style-array.at(style-dict.at(key)) } else { none }
  }

  // tinytable align-default-array before
  #let align-default-array = ( left, ) // tinytable align-default-array here
  #show table.cell: it => {
    if style-array.len() == 0 { return it }
    
    let style = get-style(it.x, it.y)
    if style == none { return it }
    
    let tmp = it
    if ("fontsize" in style) { tmp = text(size: style.fontsize, tmp) }
    if ("color" in style) { tmp = text(fill: style.color, tmp) }
    if ("indent" in style) { tmp = pad(left: style.indent, tmp) }
    if ("underline" in style) { tmp = underline(tmp) }
    if ("italic" in style) { tmp = emph(tmp) }
    if ("bold" in style) { tmp = strong(tmp) }
    if ("mono" in style) { tmp = math.mono(tmp) }
    if ("strikeout" in style) { tmp = strike(tmp) }
    tmp
  }

  #align(center, [

  #table( // tinytable table start
    columns: (auto),
    stroke: none,
    rows: auto,
    align: (x, y) => {
      let style = get-style(x, y)
      if style != none and "align" in style { style.align } else { left }
    },
    fill: (x, y) => {
      let style = get-style(x, y)
      if style != none and "background" in style { style.background }
    },
 table.hline(y: 4, start: 0, end: 1, stroke: 0.1em + rgb("#d3d8dc")),
 table.hline(y: 0, start: 0, end: 1, stroke: 0.1em + rgb("#d3d8dc")), table.hline(y: 1, start: 0, end: 1, stroke: 0.1em + rgb("#d3d8dc")),
    // tinytable lines before

    // tinytable header start
    table.header(
      repeat: true,
[Math],
    ),
    // tinytable header end

    // tinytable cell content after
[#mitex(`\alpha`)],
[#mitex(`a_{it}`)],
[#mitex(`e^{i\pi} + 1 = 0`)],

    // tinytable footer after

  ) // end table

  ]) // end align

] // end block
= Box and Theorem Systems
<box-and-theorem-systems>
== Current Showybox System
<current-showybox-system>
Superslides supports two types of showyboxes via the `::: {.classname}` syntax, with colors automatically generated from your primary and secondary colors:

== Simplebox
<simplebox>
#strong[Code:]

```markdown
::: {.simplebox}
## Simple Information
This is a simple information box
with blue styling.
:::
```

#strong[Result:]

#showybox(
  title: "Simple Information",
  below: 1em,
  body_style: (
    weight: "regular",
    size: 1em
  ),
  above: 1em,
  frame: (
    border-color: rgb("#107895"),
    title-color: rgb("#107895").darken(10%),
    body-color: rgb("#107895").lighten(90%),
    footer-color: rgb("#107895").lighten(80%),
    thickness: 1pt,
    radius: 6pt
  ),
  sep: (
    thickness: 8pt
  ),
  title_style: (
    weight: "bold",
    size: 1.1em
  ),
  shadow: none,
)[
This is a simple information box with blue styling.

]
== 
<section-1>
```
::: {.warningbox}
### Warning
This is a warning box with
red styling for alerts.
:::
```

#showybox(
  title: "Warning",
  below: 1em,
  body_style: (
    weight: "regular",
    size: 1em
  ),
  above: 1em,
  frame: (
    border-color: rgb("#9a2515"),
    title-color: rgb("#9a2515").darken(10%),
    body-color: rgb("#9a2515").lighten(90%),
    thickness: 1pt,
    radius: 6pt
  ),
  sep: (
    thickness: 8pt
  ),
  title_style: (
    color: white,
    weight: "bold",
    size: 1.1em
  ),
  shadow: none,
)[
This is a warning box with red styling for alerts.

]
= Theorem System
<theorem-system>
Superslides provides a comprehensive theorem system using Quarto's native syntax with beautiful styling.

== Configuration
<configuration>
The theorem system is configured in the YAML header:

```yaml
theorem-package: "ctheorems"      # Package to use
theorem-lang: "en"                # Language: "en" or "it"
theorem-numbering: true           # Sequential numbering (1, 2, 3...)
# Colors automatically generated from primary-color
```

== Basic Theorem
<basic-theorem>
=== Quarto Syntax
<quarto-syntax>
```markdown
::: {#thm-main}
### Fundamental Theorem
Every positive integer can be written as a sum of distinct powers of 2.
:::
```

=== Result
<result>
#theorem("Fundamental Theorem")[
Every positive integer can be written as a sum of distinct powers of 2.

] <thm-main>
== Lemma
<lemma>
=== Quarto Syntax:
<quarto-syntax-1>
```markdown
::: {#lem-binary}
### Binary Representation
Any positive integer has a unique binary representation.
:::
```

=== Result
<result-1>
#lemma("Binary Representation")[
Any positive integer has a unique binary representation.

] <lem-binary>
== Assumption
<assumption>
=== Quarto Syntax
<quarto-syntax-2>
```markdown
::: {#finite .assumption}
### Finiteness
We assume all sets under consideration are finite.
:::
```

=== Result
<result-2>
#assumption("Finiteness")[
We assume all sets under consideration are finite.

] <finite>
== Definition
<definition>
=== Quarto Syntax
<quarto-syntax-3>
```markdown
::: {#def-group}
### Group
A group is a set G with an operation * that satisfies:

- Closure
- Associativity
- Identity element
- Inverse elements
:::
```

=== Result
<result-3>
#definition("Group")[
A group is a set G with an operation \* that satisfies:

- Closure
- Associativity
- Identity element
- Inverse elements

] <def-group>
== Cross-References
<cross-references>
Theorems use Quarto's crossref system with `@label`:

```markdown
The proof follows from @lem-binary to establish @thm-main.
```

#strong[Result:] The proof follows from #ref(<lem-binary>, supplement: [Lemma]) to establish #ref(<thm-main>, supplement: [Theorem]).

For assumptions, use raw Typst syntax `#ref(<label>)`:

```markdown
Under `#ref(<finite>)`{=typst}, the proof follows from @lem-binary.
```

#strong[Result:] Under #ref(<finite>), the proof follows from #ref(<lem-binary>, supplement: [Lemma]).

== 
<section-2>
#v(-3em)

Quarto theorem types plus Assumption are supported:

#table(
  columns: 3,
  align: (auto,auto,auto,),
  table.header([Type], [Environment], [Reference],),
  table.hline(),
  [Theorem], [`::: {#thm-label}`], [`@thm-label`],
  [Lemma], [`::: {#lem-label}`], [`@lem-label`],
  [Corollary], [`::: {#cor-label}`], [`@cor-label`],
  [Proposition], [`::: {#prp-label}`], [`@prp-label`],
  [Conjecture], [`::: {#cnj-label}`], [`@cnj-label`],
  [Definition], [`::: {#def-label}`], [`@def-label`],
  [Example], [`::: {#exm-label}`], [`@exm-label`],
  [Exercise], [`::: {#exr-label}`], [`@exr-label`],
  [Solution], [`::: {#sol-label}`], [`@sol-label`],
  [Remark], [`::: {#rem-label}`], [`@rem-label`],
  [Assumption], [`::: {#label .assumption}`], [`#ref(<label>)`],
)
= YAML Configuration System
<yaml-configuration-system>
== 
<section-3>
#v(-2em)

#strong[Superslides uses a minimal color system with just 3 base colors]

```yaml
# Colors (only 3!)
text-color: "#131516"       # Main text color
primary-color: "#107895"    # Primary accent (used for boxes, theorems)
secondary-color: "#9a2515"  # Secondary accent (used for warnings)
```

#strong[How it works:]

- #strong[Boxes];: Automatically generated from primary (simplebox) and secondary (warningbox)
- #strong[Theorems];: All theorem environments use variations of primary-color
- #strong[Text];: Strong emphasis uses secondary-color

== Theorem Configuration
<theorem-configuration>
```yaml
theorem-package: "ctheorems"     # Package selection
theorem-lang: "en"               # Language: "en" or "it"
theorem-numbering: true          # Sequential numbering (1, 2, 3...)
```

All theorem colors are automatically generated from `primary-color` with different lightness levels:

- Theorem: `primary-color.lighten(90%)`
- Lemma: `primary-color.lighten(90%)`
- Assumption: `primary-color.lighten(90%)`

== Global Box Configuration
<global-box-configuration>
Customize box appearance using these YAML parameters:

```yaml
# Global settings (affect all box types)
box-border-thickness: 1pt        # Border thickness
box-border-radius: 4pt           # Corner radius
box-shadow: none                 # Drop shadow (or "3pt 3pt 8pt gray")
box-title-font-size: 1.0em      # Title font size
box-title-font-weight: "bold"   # Title weight
box-body-font-size: 1.0em       # Body font size
box-body-font-weight: "regular" # Body weight
box-spacing-above: 1em          # Space above
box-spacing-below: 1em          # Space below
box-padding: 8pt                # Internal padding
```

#text-scale-tiny(
)[
These settings apply globally to both simplebox and warningbox, maintaining visual consistency.
]
