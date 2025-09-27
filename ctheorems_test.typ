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

// Enhanced theorem environment configuration function
#let setup-theorems(self) = {
  // Define theorem titles for different languages
  let theorem-titles = (
    "it": (
      "theorem": "Teorema",
      "proposition": "Proposizione",
      "lemma": "Lemma",
      "corollary": "Corollario",
      "conjecture": "Congettura",
      "definition": "Definizione",
      "example": "Esempio",
      "exercise": "Esercizio",
      "solution": "Soluzione",
      "assumption": "Assunzione",
      "remark": "Osservazione",
      "proof": "Dimostrazione"
    ),
    "en": (
      "theorem": "Theorem",
      "proposition": "Proposition",
      "lemma": "Lemma",
      "corollary": "Corollary",
      "conjecture": "Conjecture",
      "definition": "Definition",
      "example": "Example",
      "exercise": "Exercise",
      "solution": "Solution",
      "assumption": "Assumption",
      "remark": "Remark",
      "proof": "Proof"
    )
  )

  // Get colors from YAML configuration
  let theorem-colors = (
    "theorem": parse-color(self.store.theorem-color),
    "proposition": parse-color(self.store.proposition-color),
    "lemma": parse-color(self.store.lemma-color),
    "corollary": parse-color(self.store.corollary-color),
    "conjecture": parse-color(self.store.conjecture-color),
    "definition": parse-color(self.store.definition-color),
    "example": parse-color(self.store.example-color),
    "exercise": parse-color(self.store.exercise-color),
    "solution": parse-color(self.store.solution-color),
    "assumption": parse-color(self.store.assumption-color),
    "remark": parse-color(self.store.remark-color),
  )

  let titles = theorem-titles.at(self.store.theorem-lang, default: theorem-titles.at("it"))
  let numbering-setting = if self.store.theorem-numbering { "1.1" } else { none }

  // Choose package and setup globally accessible theorem functions
  if self.store.theorem-package == "theorion" {
    // Theorion setup - not implemented yet
    none
  } else {
    // ctheorems setup (default) - this needs to be in include-before-body
    none
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
  // Showybox customization options
  // Color settings
  simplebox-color: none,
  warningbox-color: none,
  infobox-color: none,
  alert-color: none,        // Alert text color (for bold/strong text)

  // Global box settings
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

  // Individual box type overrides
  simplebox-thickness: none,
  simplebox-radius: none,
  warningbox-thickness: none,
  warningbox-radius: none,
  infobox-thickness: none,
  infobox-radius: none,
  // Theorem system configuration
  theorem-package: "ctheorems",  // "ctheorems" or "theorion"
  theorem-lang: "it",
  theorem-numbering: false,
  theorem-font-size: none,
  theorem-title-weight: "bold",
  theorem-body-weight: "regular",

  // Individual theorem type colors
  theorem-color: "#E9E5F3",
  theorem-border: none,
  lemma-color: "#F3E9E5",
  lemma-border: none,
  corollary-color: "#F8F0E8",
  corollary-border: none,
  proposition-color: "#E5F3E9",
  proposition-border: none,
  conjecture-color: "#F3F8F0",
  conjecture-border: none,
  definition-color: "#E0EDF4",
  definition-border: none,
  example-color: "#F0F8E6",
  example-border: none,
  exercise-color: "#E0EDF4",
  exercise-border: none,
  solution-color: "#F5F0F8",
  solution-border: none,
  remark-color: "#F0F8F5",
  remark-border: none,
  assumption-color: "#F5F0F8",
  assumption-border: none,

  // Global theorem styling
  theorem-border-thickness: "1pt",
  theorem-border-radius: "4pt",
  theorem-title-font-size: "1.1em",
  theorem-title-font-weight: "bold",
  theorem-body-font-size: "1.0em",
  theorem-body-font-weight: "regular",
  theorem-padding: "8pt",
  theorem-spacing: "1em",
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

  // Strong/bold text styling - handled by Touying's alert system when show-strong-with-alert: true
  // show strong: it => text(
  //   fill: if alert-color != none { alert-color } else { color-accent2 },
  //   weight: "bold",
  //   it.body
  // )
  
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
      show-strong-with-alert: true
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
      // Enhanced box configuration
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
      simplebox-thickness: simplebox-thickness,
      simplebox-radius: simplebox-radius,
      warningbox-thickness: warningbox-thickness,
      warningbox-radius: warningbox-radius,
      infobox-thickness: infobox-thickness,
      infobox-radius: infobox-radius,
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
      // Theorem configuration
      theorem-package: theorem-package,
      theorem-lang: theorem-lang,
      theorem-numbering: theorem-numbering,
      theorem-font-size: theorem-font-size,
      theorem-title-weight: theorem-title-weight,
      theorem-body-weight: theorem-body-weight,
      theorem-color: theorem-color,
      theorem-border: theorem-border,
      lemma-color: lemma-color,
      lemma-border: lemma-border,
      corollary-color: corollary-color,
      corollary-border: corollary-border,
      proposition-color: proposition-color,
      proposition-border: proposition-border,
      conjecture-color: conjecture-color,
      conjecture-border: conjecture-border,
      definition-color: definition-color,
      definition-border: definition-border,
      example-color: example-color,
      example-border: example-border,
      exercise-color: exercise-color,
      exercise-border: exercise-border,
      solution-color: solution-color,
      solution-border: solution-border,
      remark-color: remark-color,
      remark-border: remark-border,
      assumption-color: assumption-color,
      assumption-border: assumption-border,
      theorem-border-thickness: theorem-border-thickness,
      theorem-border-radius: theorem-border-radius,
      theorem-title-font-size: theorem-title-font-size,
      theorem-title-font-weight: theorem-title-font-weight,
      theorem-body-font-size: theorem-body-font-size,
      theorem-body-font-weight: theorem-body-font-weight,
      theorem-padding: theorem-padding,
      theorem-spacing: theorem-spacing,
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
#import "@preview/ctheorems:1.1.3": *
#show: thmrules
#let theorem = thmbox("theorem", "Theorem")
#let lemma = thmbox("lemma", "Lemma")

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
                
  // List customization --------------------------------------------------------
        
  // Colors --------------------------------------------------------------------
      
  // Background ----------------------------------------------------------------
      // Title slide ---------------------------------------------------------------
                                  
  // Title page customization --------------------------------------------------
              
  // Showybox customization -----------------------------------------------------
  // Color settings
        
  // Border and appearance settings
      
  // Typography settings
        
  // Spacing settings
      
  // Individual box type overrides
            
  // Theorem configuration -----------------------------------------------------
      theorem-package: "ctheorems",
        theorem-lang: "en",
        theorem-numbering: true,
        
  // Individual theorem type colors
      theorem-color: "FFE5E5",
          lemma-color: "E5FFE5",
                                          assumption-color: "E5E5FF",
    
  // Global theorem styling
                )


// Helper function for simple sequential numbering
#let unary(.., last) = last

// Dynamic theorem setup based on YAML
// Current implementation: ctheorems package (theorion support planned)
#show: thmrules
// Setup theorem environments with YAML configuration
#let theorem = thmbox("theorem", if "en" == "en" { "Theorem" } else { "Teorema" }, fill: rgb("#FFE5E5")).with(numbering: unary)
#let proposition = thmbox("proposition", if "en" == "en" { "Proposition" } else { "Proposizione" }, fill: rgb("#E5F3E9")).with(numbering: unary)
#let lemma = thmbox("lemma", if "en" == "en" { "Lemma" } else { "Lemma" }, fill: rgb("#E5FFE5")).with(numbering: unary)
#let corollary = thmbox("corollary", if "en" == "en" { "Corollary" } else { "Corollario" }, fill: rgb("#F8F0E8")).with(numbering: unary)
#let conjecture = thmbox("conjecture", if "en" == "en" { "Conjecture" } else { "Congettura" }, fill: rgb("#F3F8F0")).with(numbering: unary)
#let definition = thmbox("definition", if "en" == "en" { "Definition" } else { "Definizione" }, fill: rgb("#E0EDF4")).with(numbering: unary)
#let example = thmbox("example", if "en" == "en" { "Example" } else { "Esempio" }, fill: rgb("#F0F8E6")).with(numbering: unary)
#let exercise = thmbox("exercise", if "en" == "en" { "Exercise" } else { "Esercizio" }, fill: rgb("#E0EDF4")).with(numbering: unary)
#let solution = thmbox("solution", if "en" == "en" { "Solution" } else { "Soluzione" }, fill: rgb("#F5F0F8")).with(numbering: unary)
#let assumption = thmbox("assumption", if "en" == "en" { "Assumption" } else { "Assunzione" }, fill: rgb("#E5E5FF")).with(numbering: unary)
#let remark = thmbox("remark", if "en" == "en" { "Remark" } else { "Osservazione" }, fill: rgb("#F0F8F5")).with(numbering: unary)
#let proof = thmbox("proof", if "en" == "en" { "Proof" } else { "Dimostrazione" }, fill: rgb("#F8F5F0")).with(numbering: none)

#title-slide(
  title: [ctheorems Test],
  subtitle: [],
  authors: (
      ),
  date: [],
  lecture-date: [],
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

= ctheorems Package Test
<ctheorems-package-test>
== Basic Theorem
<basic-theorem>
#theorem("Main Result")[
Every positive integer can be written as a sum of distinct powers of 2.

] <thm-main>
== Supporting Lemma
<supporting-lemma>
#lemma("Binary Representation")[
Any positive integer has a unique binary representation.

] <lem-binary>
---
#emph[Testing ctheorems with sequential numbering (1, 2, 3…)]
