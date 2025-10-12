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
  block(width: 100%,align(center, $$eq$$))
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