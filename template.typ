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
#import "@preview/ctheorems:1.1.0": *
#import "@preview/cades:0.3.0": qr-code

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
    set text(size: 3em, fill: self.colors.primary, weight: "bold", font: self.store.font-family-heading)
    utils.display-current-heading(level: 1)
  }
  self = utils.merge-dicts(
    self,
    config-page(margin: (left: 2em, top: -0.25em)),
  ) 
  touying-slide(self: self, main-body)
})

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
    show: components.cell.with(inset: (x: 2em, top: 1.5em))
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
    context utils.slide-counter.display() + " : " + utils.last-slide-number
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
  font-weight-heading: "regular",
  font-weight-body: "regular",
  font-weight-title: "light",
  font-weight-subtitle: "light",
  font-size-title: 1.4em,
  font-size-subtitle: 1em,
  color-jet: parse-color("#131516"),
  color-accent: parse-color("#107895"),
  color-accent2: parse-color("#9a2515"),
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
  // Showybox color options
  simplebox-color: none,
  warningbox-color: none,
  infobox-color: none,
  // Alert text color (for bold/strong text)
  alert-color: none,
  ..args,
  body,
) = {
  set text(size: font-size, font: font-family-body, fill: color-jet,
           weight: font-weight-body)

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

  // Strong/bold text styling - applied globally to override any theme defaults
  show strong: it => text(
    fill: if alert-color != none { alert-color } else { color-accent2 },
    weight: "bold",
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
      enable-frozen-states-and-counters: false, // https://github.com/touying-typ/touying/issues/72
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
            weight: "light",
            style: "italic",
          )
          block(inset: (top: -0.5em, bottom: 0.25em))[#title]
        }

        set bibliography(title: none)

        body
      },
      alert: (self: none, it) => text(fill: if alert-color != none { alert-color } else { self.colors.secondary }, weight: "bold", it),
    ),
    config-colors(
      primary: color-accent,
      secondary: color-accent2,
      neutral-lightest: rgb("#ffffff"),
      neutral-darkest: color-jet,
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
      simplebox-color: simplebox-color,
      warningbox-color: warningbox-color,
      infobox-color: infobox-color,
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
      alert-color: alert-color,
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
    if info.lecture-date != none {
      block(
        inset: (bottom: 2em),
        text(
          size: if self.store.date-size != none { self.store.date-size } else { 16pt },
          fill: self.colors.primary,
          weight: "medium",
          if type(info.lecture-date) == datetime {
            info.lecture-date.display(self.datetime-format)
          } else {
            info.lecture-date
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
    text(blue, it.body)
}

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
        font-family-heading: ("Roboto",),
        font-family-body: ("Roboto",),
        font-weight-heading: "regular",
        font-weight-body: "regular",
        raw-font-size: 14pt,
        raw-inline-size: 22pt,
        raw-inset: 8pt,
  
  // List customization --------------------------------------------------------
      list-indent: 0.6em,
        list-marker-1: "•",
        list-marker-2: "◦",
        list-marker-3: "▪",
  
  // Colors --------------------------------------------------------------------
      color-jet: parse-color("\#404040"),
        color-accent: parse-color("\#2836A6"),
        color-accent2: parse-color("\#004494"),
  
  // Background ----------------------------------------------------------------
      // Title slide ---------------------------------------------------------------
      title-font: "Roboto",
        title-size: 42pt,
        title-weight: "bold",
        subtitle-font: "Roboto",
        subtitle-size: 30pt,
        subtitle-weight: "regular",
        author-size: 20pt,
        date-size: 18pt,
              updates-link: "https:\/\/github.com/gragusa/superslides/releases",
        affiliation-color: parse-color("\#707070"),
        affiliation-style: "italic",
          email-color: parse-color("\#CD853F"),
        lang: "en",
  
  // Title page customization --------------------------------------------------
          qr-code-url: "https:\/\/github.com/gragusa/superslides",
        qr-code-title: "View Source",
        qr-code-size: 4cm,
        qr-code-button-color: parse-color("\#404040"),
    
  // Showybox color customization ----------------------------------------------
            alert-color: parse-color("\#FF6B35"),
  )

#title-slide(
  title: [Superslides Template],
  subtitle: [Super features demo],
  authors: (
                    ( name: [Giuseppe Ragusa],
            affiliation: [Luiss University],
            email: [],
            orcid: []),
            ),
  date: [2025-09-26],
  lecture-date: [September 26, 2025],
  web: [],
  icon: []
)

#show: thmrules
#let example = thmbox("example", "Esempio", fill: rgb("#F0F8E6")).with(numbering: none)
#let theorem = thmbox("theorem", "Teorema", fill: rgb("#E9E5F3")).with(numbering: none)
#let exercise = thmbox("exercise", "Esercizio", fill: rgb("#E0EDF4")).with(numbering: none)
#let definition = thmbox("definition", "Definizione", fill: rgb("#E0EDF4")).with(numbering: none)
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
Welcome to #strong[Superslides];! This template demonstrates:

- Enhanced Typst presentations with Touying
- Professional title slides with interactive elements
- Advanced code blocks with zebraw integration
- Complete customization through YAML parameters

== Features Overview
<features-overview>
#strong[Key capabilities:]

- 🎨 Professional title slides with left-aligned layout
- 🔗 Interactive QR codes and clickable links
- 📝 Enhanced code blocks with mathematical annotations
- 🎯 40+ YAML parameters for customization
- 🌐 Multi-language support (English/Italian)

== Typography
<typography>
Standard markdown formatting works as expected:

- #emph[emphasis]
- #strong[bold]
- #strong[#emph[bold emphasis];]
- #strike[strikethrough]
- `inline code`
- #alert()[alert]

== Code Blocks
<code-blocks>
Superslides supports standard code blocks with proper syntax highlighting and customizable formatting.

```r
plot(rnorm(10))
```

#box(image("template_files/figure-typst/unnamed-chunk-1-1.svg"))

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

== More Information
<more-information>
Learn more about creating custom Typst templates:

#link("https://quarto.org/docs/prerelease/1.4/typst.html#custom-formats")
