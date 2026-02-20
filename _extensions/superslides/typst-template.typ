#import "@preview/touying:0.6.1": *
#import "@preview/fontawesome:0.6.0": *
#import "@preview/cades:0.3.1": qr-code
#import "@preview/mitex:0.2.6": *
#import "@preview/theorion:0.4.1": *
#import "@preview/colorful-boxes:1.4.3": *
#import "@preview/showybox:2.0.4": showybox
#import "@preview/zebraw:0.6.1": *

#let bluebox(body) = {
  outline-colorbox(
    color: "blue",
    title: "Sommario"
  )[#body]
}

#let highlightbox(body) = {
  showybox(
    frame: (
      border-color: blue,
      title-color: blue.lighten(30%),
      body-color: blue.lighten(95%),
      footer-color: blue.lighten(80%)
    )
  )[#body]
}
// Helper function to handle hex colors and Typst color functions
#let is-hex-color(s) = {
  // Check if string is a valid hex color (6 or 8 characters, all hex digits)
  let len = s.len()
  if len != 6 and len != 8 {
    return false
  }
  let hex-chars = "0123456789abcdefABCDEF"
  for c in s {
    if not hex-chars.contains(c) {
      return false
    }
  }
  return true
}

#let parse-color(color-str) = {
  if color-str.starts-with("\\#") {
    rgb(color-str.slice(2))
  } else if color-str.starts-with("#") {
    rgb(color-str.slice(1))
  } else if color-str.starts-with("luma(") or color-str.starts-with("rgb(") or color-str.starts-with("color.") {
    // Handle Typst color functions - evaluate them directly
    eval(color-str)
  } else if is-hex-color(color-str) {
    // Handle hex color without # prefix (6 or 8 hex digits)
    rgb(color-str)
  } else {
    // Assume it's a literal color name or other valid Typst color
    eval(color-str)
  }
}

// Parse a color string that may reference theme colors with operations.
// Supports:  "primary-color lightened 80%", "secondary-color darkened 20%",
//            or any plain color value handled by parse-color.
// Operations: lightened/lighten, darkened/darken, saturated/saturate, desaturated/desaturate
#let parse-theme-color(color-str, primary, secondary) = {
  let parts = color-str.split(" ")
  let base-name = parts.at(0)
  let base = if base-name == "primary" or base-name == "primary-color" {
    primary
  } else if base-name == "secondary" or base-name == "secondary-color" {
    secondary
  } else if parts.len() == 1 {
    return parse-color(color-str)
  } else {
    parse-color(base-name)
  }

  if parts.len() >= 3 {
    let op = parts.at(1)
    let amount = eval(parts.at(2))
    if op == "lightened" or op == "lighten" { base.lighten(amount) }
    else if op == "darkened" or op == "darken" { base.darken(amount) }
    else if op == "saturated" or op == "saturate" { base.saturate(amount) }
    else if op == "desaturated" or op == "desaturate" { base.desaturate(amount) }
    else { base }
  } else {
    base
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


// Display inline math as display-style (large fractions, etc.)
#show math.equation.where(block: false): it => math.display(it)

#let slide(
  title: auto,
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  // set page
  // let header(self) = {
  //   set align(top)
  //   show: components.cell.with(inset: (x: 1.2em, top: 1.0em))
  //   set text(
  //     size: 1.4em,
  //     fill: self.colors.neutral-darkest,
  //     weight: self.store.font-weight-heading,
  //     font: self.store.font-family-heading,
  //   )
  //   utils.call-or-display(self, self.store.header)
  // }

  let header(self) = {
    set std.align(top)
    show: components.cell.with(fill: self.store.background-color, inset: (top: self.store.heading-inset-top, right: 2em, left: 2em, bottom: self.store.heading-inset-bottom))
    set std.align(horizon)
    set text(fill: self.store.font-color-heading,
             weight: "medium",
             size: self.store.font-size-heading,
             font: self.store.font-family-heading)
    //components.left-and-right(
    //  {
        if title != auto {
          utils.fit-to-width(grow: false, 100%, title)
        } else {
          utils.call-or-display(self, self.store.header)
        }
      //},
      //utils.call-or-display(self, self.store.header-right),
      //v(-3em)
    //)
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
  font-size: 20pt,
  font-family-body: ("Roboto"),
  font-weight-body: "regular",

  font-size-heading: 1.75em,
  font-family-heading: ("Oswald"),
  font-weight-heading: "medium",
  font-color-heading: parse-color("#333399"),
  heading-inset-top: 5em,
  heading-inset-bottom: 4.5em,

  font-size-title: 2em,
  font-family-title: ("Roboto"),
  font-weight-title: "regular",
  font-color-title: parse-color("#131516"),

  font-size-subtitle: 1.6em,
  font-family-subtitle: ("Roboto"),
  font-weight-subtitle: "regular",
  font-style-subtitle: "italic",
  font-color-subtitle: parse-color("#131516"),

  font-family-author: ("Roboto"),
  font-size-author: 1.2em,
  font-weight-author: "medium",
  font-color-author: parse-color("#131516"),


  font-family-date: ("Roboto"),
  font-size-date: 1em,
  font-weight-date: "medium",
  font-color-date: parse-color("#131516"),
  font-style-date: "normal",

  font-family-affiliation: ("Roboto"),
  font-size-affiliation: 1em,
  font-weight-affiliation: "regular",
  font-color-affiliation: parse-color("#778899"),
  font-style-affiliation: "italic",

  font-family-email: ("Roboto"),
  font-size-email: 0.8em,
  font-weight-email: "regular",
  font-color-email: parse-color("#101e62"),
  font-style-email: "italic",

  font-family-math: none,

  // Simplified color system - only 3 colors needed
  text-color: parse-color("#040404"),      // Body text color
  primary-color: parse-color("#333399"),   // Main accent color
  secondary-color: parse-color("#c8102e"), // Secondary accent color
  strong-weight: "regular",

  // Emphasis styling (italic text via _text_)
  emph-color: none,  // Color for emphasis (defaults to text-color if none)
  emph-weight: "medium",  // Weight for emphasis
  emph-style: "italic",  // Style for emphasis ("italic" or "normal")

  // Bold-emphasis styling (bold italic via **_text_** or _**text**_)
  bold-emph-weight: "bold",  // Weight for bold emphasis (defaults to "bold")

  raw-font-size: 1em,  // Code block font size
  raw-inline-size: 0.9em,  // Separate size for inline code (if none, uses body font size)
  raw-inset: 8pt,  // Inset for raw code blocks
  // List customization options
  list-indent: 0.6em,
  list-marker-1: "•",
  list-marker-2: "◦",
  list-marker-3: "▪",
  // Background options
  background-image: none,
  background-color: parse-color("#FFFFFF"),
  // Title page options
  logo-path: none,  // Set to none by default to avoid missing file errors
  logo-width: 4cm,
  logo-align: left + bottom,  // Alignment: left/center/right + top/bottom
  logo-inset-top: 0em,
  logo-inset-bottom: 0em,
  logo-inset-left: 0em,
  logo-inset-right: 0em,
  qr-code-url: none,
  qr-code-title: "QR Code",
  qr-code-size: 5cm,  // Size of QR code on title page
  qr-code-button-color: parse-color("#3B3B3B"),  // Color for QR code button (defaults to accent color)
  last-updated-text: "Updated:",
  date-updated: none,  // Date for last updated text (if none, hides it)
  updates-link: none,   // Link for last updated butfont-affiliation-styletyling options
  email-color: none,        // Color for email text
  // Language support
  lang: "en",              // Language for last updated text

  // Global box settings (no individual colors - generated from primary/secondary)
  // box-border-thickness: 1pt,
  // box-border-radius: 4pt,
  // box-shadow: none,
  // box-title-font-size: none,
  // box-title-font-weight: "bold",
  // box-body-font-size: none,
  // box-body-font-weight: "regular",
  // box-spacing-above: 1em,
  // box-spacing-below: 1em,
  // box-padding: 8pt,

  // Theorem system configuration (colors auto-generated from primary-color)
  theorem-package: "theorion",  // "ctheorems" or "theorion"
  theorem-lang: "en",  // "en" or "it"
  theorem-numbering: true,

  // Theorem box colors (defaults to primary-color lightened)
  // theorem-fill: auto uses primary-color.lighten(80%)
  // definition-fill: auto uses primary-color.lighten(90%)
  // example-fill: auto uses primary-color.lighten(90%)
  // remark-fill: auto uses primary-color.lighten(95%)
  theorem-fill: none,      // Fill for theorem, lemma, proposition, corollary, conjecture
  definition-fill: none,   // Fill for definition, assumption
  example-fill: none,      // Fill for example, exercise
  remark-fill: none,       // Fill for remark, solution
  ..args,
  body,
) = {
  set text(size: font-size, font: font-family-body, fill: text-color,
           weight: font-weight-body)


if font-family-math != none {
  show math.equation: set text(font: font-family-math)
}

  // Configure raw text styling for all code blocks
  // When zebraw is enabled, it handles code block styling itself
$if(use-zebraw)$
$else$
  show raw.where(block: true): it => {
    set text(size: raw-font-size)
    block(inset: raw-inset, fill: luma(245), radius: 2pt, width: 100%, it)
  }
$endif$

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

  // Emphasis styling (italic text via _text_)
  // Uses emph-color (defaults to text-color) with medium weight
  // Bold-emphasis (_**text**_ or **_text_**) uses bold-emph-weight
  let emph-fill = if emph-color != none { emph-color } else { text-color }
  show emph: it => {
    // Override strong when nested inside emphasis for bold-emphasis
    show strong: inner => text(
      fill: emph-fill,
      style: emph-style,
      weight: bold-emph-weight,
      inner.body
    )
    text(
      fill: emph-fill,
      style: emph-style,
      weight: emph-weight,
      it.body
    )
  }

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
            size: self.store.font-size-subtitle * 0.75,
            fill: self.colors.primary,
            font: font-family-body,
            weight: "regular",
            style: "normal",
          )
          block(inset: (top: 0.25em, bottom: 0.25em))[#title]
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
      neutral-darkest: rgb("#040404"),
    ),
    // save the variables for later use
    config-store(
      header: header,
      footer: footer,
      font-family-heading: font-family-heading,
      font-family-body: font-family-body,
      font-weight-body: font-weight-body,
      font-size: font-size,
      text-color: text-color,
      background-color: background-color,
      font-size-title: font-size-title,
      font-size-subtitle: font-size-subtitle,
      font-weight-heading: font-weight-heading,
      font-weight-title: font-weight-title,
      font-weight-subtitle: font-weight-subtitle,
      font-color-heading: font-color-heading,
      heading-inset-top: heading-inset-top,
      heading-inset-bottom: heading-inset-bottom,
      font-family-title: font-family-title,
      font-family-subtitle: font-family-subtitle,
      font-color-title: font-color-title,
      font-color-subtitle: font-color-subtitle,
      font-family-author: font-family-author,
      font-size-author: font-size-author,
      font-weight-author: font-weight-author,
      font-color-author: font-color-author,
      font-size-heading: font-size-heading,
      font-family-affiliation: font-family-affiliation,
      font-size-affiliation: font-size-affiliation,
      font-weight-affiliation: font-weight-affiliation,
      font-style-affiliation: font-style-affiliation,
      font-style-subtitle: font-style-subtitle,
      font-color-affiliation: font-color-affiliation,
      font-size-email: font-size-email,
      background-image: background-image,
      logo-path: logo-path,
      logo-width: logo-width,
      logo-align: logo-align,
      logo-inset-top: logo-inset-top,
      logo-inset-bottom: logo-inset-bottom,
      logo-inset-left: logo-inset-left,
      logo-inset-right: logo-inset-right,
      qr-code-url: qr-code-url,
      qr-code-title: qr-code-title,
      qr-code-size: qr-code-size,
      qr-code-button-color: qr-code-button-color,
      last-updated-text: last-updated-text,
      date-updated: date-updated,
      // Simplified color system
      primary-color: primary-color,
      secondary-color: secondary-color,
      // Box configuration
      // box-border-thickness: box-border-thickness,
      // box-border-radius: box-border-radius,
      // box-shadow: box-shadow,
      // box-title-font-size: box-title-font-size,
      // box-title-font-weight: box-title-font-weight,
      // box-body-font-size: box-body-font-size,
      // box-body-font-weight: box-body-font-weight,
      // box-spacing-above: box-spacing-above,
      // box-spacing-below: box-spacing-below,
      // box-padding: box-padding,
      // title-font: if font-family-title != none {
      //   if type(font-family-title) == array { font-family-title.at(0) } else { font-family-title }
      // } else { title-font },
      // subtitle-font: if font-family-subtitle != none {
      //   if type(font-family-subtitle) == array { font-family-subtitle.at(0) } else { font-family-subtitle }
      // } else { subtitle-font },
      // author-size: font-size-author,
      font-family-date: font-family-date,
      font-size-date: font-size-date,
      font-weight-date: font-weight-date,
      font-style-date: font-style-date,
      font-color-date: font-color-date,
      email-color: email-color,
      lang: lang,
      updates-link: updates-link,
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
  let last-updated = info.at("date-updated", default: info.at("update-date", default: none))

  let body = {
    set align(left + top)

    let as-font = (choice, fallback) => if choice != none {
      if type(choice) == array { choice } else { (choice,) }
    } else { fallback }

    // Logo if provided — use place() for absolute positioning
    if self.store.logo-path != none {
      place(
        self.store.logo-align,
        dx: self.store.logo-inset-left - self.store.logo-inset-right,
        dy: self.store.logo-inset-top - self.store.logo-inset-bottom,
        image(self.store.logo-path, width: self.store.logo-width)
      )
    }

    // Title - Left aligned, all caps, customizable font
    block(
      inset: (top: -1em, bottom: 0.0em),
      text(
        size: if self.store.font-size-title != none { self.store.font-size-title } else { 2em },
        fill: if self.store.font-color-title != none { self.store.font-color-title } else { self.colors.neutral-darkest },
        weight: if self.store.font-weight-title != none { self.store.font-weight-title } else { "bold" },
        font: as-font(self.store.font-family-title, self.store.font-family-heading),
        info.title
      )
    )

    // Subtitle - Left aligned underneath title
    if info.subtitle != none {
      block(
        inset: (top: -0.1em, bottom: 1.5em),
        text(
          size: if self.store.font-size-subtitle != none { self.store.font-size-subtitle } else { 0.8em },
          fill: if self.store.font-color-subtitle != none { self.store.font-color-subtitle } else { self.colors.neutral-darkest },
          weight: if self.store.font-weight-subtitle != none { self.store.font-weight-subtitle } else { "regular" },
          font: as-font(self.store.font-family-subtitle, self.store.font-family-body),
          style: if self.store.font-style-subtitle != none { self.store.font-style-subtitle },
          info.subtitle
        )
      )
    }

    // Authors section - Conditional handling for single vs multiple authors
    if info.authors != none {
      block(
        inset: (bottom: 1.5em),
        {
          let show-author = author => block(
            width: 100%,
            {
              set align(left + top)

              text(
                size: if self.store.font-size-author != none { self.store.font-size-author } else { 18pt },
                fill: if self.store.font-color-author != none { self.store.font-color-author } else { self.colors.neutral-darkest },
                weight: if self.store.font-weight-author != none { self.store.font-weight-author } else { "medium" },
                font: as-font(self.store.font-family-author, self.store.font-family-body),
                author.name
              )

              if author.orcid != none {
                h(0.3em)
                let orcid-id = repr(author.orcid).trim("\"")
                let orcid-url = "https://orcid.org/" + orcid-id
                link(orcid-url.replace("\\/", "/"))[
                  #text(
                    size: if self.store.font-size-author != none { self.store.font-size-author } else { 18pt },
                    fill: rgb("A6CE39")
                  )[#fa-icon("orcid")]
                ]
              }

              if author.affiliation != none {
                linebreak()
                text(
                  size: if self.store.font-size-affiliation != none { self.store.font-size-affiliation } else { 0.6em },
                  font: if self.store.font-family-affiliation != none { self.store.font-family-affiliation }
                  else { self.store.font-family-body },
                  style: if self.store.font-style-affiliation != none { self.store.font-style-affiliation } else { "italic" },
                  weight: if self.store.font-weight-affiliation != none { self.store.font-weight-affiliation }
                          else if self.store.font-weight-affiliation != none { self.store.font-weight-affiliation }
                          else { "regular" },
                  fill: if self.store.font-color-affiliation != none { self.store.font-color-affiliation }
                         else { self.colors.neutral-darkest },
                  author.affiliation
                )
              }

              if author.email != none {
                linebreak()
                let email-addr = repr(author.email).trim("\"")
                let email-url = "mailto:" + email-addr
                link(email-url.replace("\\/", "/"))[
                  #text(
                    size: if self.store.font-size-email != none { self.store.font-size-email } else { 0.5em },
                    fill: if self.store.email-color != none { self.store.email-color }
                          else if self.store.font-color-author != none { self.store.font-color-author }
                          else { self.colors.primary },
                    font: as-font(self.store.font-family-author, self.store.font-family-body)
                  )[#author.email]
                ]
              }
            }
          )

          let author-cards = info.authors.map(show-author)

          if info.authors.len() == 1 {
            author-cards.at(0)
          } else {
            let author-columns = calc.max(2, calc.min(info.authors.len(), 3))
            let column-widths = if author-columns == 2 {
              (1fr, 1fr)
            } else {
              (1fr, 1fr, 1fr)
            }
            grid(
              columns: column-widths,
              gutter: 1.2em,
              row-gutter: 0.8em,
              ..author-cards,
            )
          }
        }
      )
    }

    // Date section
    if info.date != none {
      block(
        inset: (bottom: 1em),
        text(
          size: if self.store.font-size-date != none { self.store.font-size-date } else { self.store.font-size },
          fill: if self.store.font-color-date != none { self.store.font-color-date }
                else if self.store.text-color != none { self.store.text-color }
                else { self.colors.neutral-darkest },
          weight: if self.store.font-weight-date != none { self.store.font-weight-date }
                  else if self.store.font-weight-body != none { self.store.font-weight-body }
                  else { "regular" },
          style: if self.store.font-style-date != none { self.store.font-style-date } else { "normal" },
          font: as-font(self.store.font-family-date, self.store.font-family-body),
          info.date
        )
      )
    }

    // Push to bottom for QR code and last updated
    v(1fr)

    // Bottom section with absolute positioning
    place(
      left + bottom,
      dx: 0pt,
      dy: 30pt,
      // Last updated as button with link (if provided) - left side
      if last-updated != none {
        // Language-aware last updated text
        let last-updated-text = if self.store.lang == "it" {
          "Aggiornato al:"
        } else {
          "Updated:"
        }

        let updated-box = box(
            inset: 8pt,
            radius: 4pt,
            fill: luma(210),
            text(
              size: 0.5em,
              fill: luma(90),
              weight: "regular"
            )[
              #last-updated-text
              #h(0.2em)
              #last-updated
            ]
        )

        block[
          #if self.store.updates-link != none and self.store.updates-link != "" {
            link(self.store.updates-link.replace("\\/", "/"))[#updated-box]
          } else {
            updated-box
          }
        ]
      }
    )

    place(
      right + bottom,
      dx: 30pt,
      dy: 30pt,
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
  set text(size: 0.7em)
  body
}

#let text-scale-smallish(body) = {
  set text(size: 0.95em)
  body
}

#let text-scale-small(body) = {
  set text(size: 0.9em)
  body
}

#let text-scale-smaller(body) = {
  set text(size: 0.8em)
  body
}

#let text-scale-large(body) = {
  set text(size: 1.1em)
  body
}

#let text-scale-larger(body) = {
  set text(size: 1.2em)
  body
}

#let text-scale-big(body) = {
  set text(size: 1.3em)
  body
}

#let text-scale-huge(body) = {
  set text(size: 1.4em)
  body
}

