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
  $if(handout)$
    handout: true,
  $endif$
  // Typography ---------------------------------------------------------------
  $if(fontsize)$
    font-size: $fontsize$,
  $elseif(brand.typography.base.size)$
    font-size: $brand.typography.base.size$,
  $endif$
  $if(sansfont)$
    font-family-heading: ("$sansfont$",),
  $elseif(font-family-heading)$
    font-family-heading: ("$font-family-heading$",),
  $elseif(brand.typography.headings.family)$
    font-family-heading: ("$brand.typography.headings.family$",),
  $endif$
  $if(mainfont)$
    font-family-body: ("$mainfont$",),
  $elseif(font-family-body)$
    font-family-body: ("$font-family-body$",),
  $elseif(brand.typography.base.family)$
    font-family-body: ("$brand.typography.base.family$",),
  $endif$
  $if(font-family-math)$
    font-family-math: "$font-family-math$",
  $endif$
  $if(font-weight-heading)$
    font-weight-heading: "$font-weight-heading$",
  $elseif(brand.typography.headings.weight)$
    font-weight-heading: $brand.typography.headings.weight$,
  $endif$
  $if(font-weight-body)$
    font-weight-body: "$font-weight-body$",
  $elseif(brand.typography.base.weight)$
    font-weight-body: $brand.typography.base.weight$,
  $endif$
  $if(strong-weight)$
    strong-weight: "$strong-weight$",
  $endif$
  $if(raw-font-size)$
    raw-font-size: $raw-font-size$,
  $endif$
  $if(raw-inline-size)$
    raw-inline-size: $raw-inline-size$,
  $endif$
  $if(raw-inset)$
    raw-inset: $raw-inset$,
  $endif$

  // List customization --------------------------------------------------------
  $if(list-indent)$
    list-indent: $list-indent$,
  $endif$
  $if(list-marker-1)$
    list-marker-1: "$list-marker-1$",
  $endif$
  $if(list-marker-2)$
    list-marker-2: "$list-marker-2$",
  $endif$
  $if(list-marker-3)$
    list-marker-3: "$list-marker-3$",
  $endif$

  // Simplified 3-color system -------------------------------------------------
  $if(text-color)$
    text-color: parse-color("$text-color$"),
  $elseif(brand.color.foreground)$
    text-color: parse-color("$brand.color.foreground$"),
  $else$
    text-color: parse-color("#040404"),
  $endif$
  $if(primary-color)$
    primary-color: parse-color("$primary-color$"),
  $elseif(brand.color.primary)$
    primary-color: parse-color("$brand.color.primary$"),
  $else$
    primary-color: parse-color("#333399"),
  $endif$
  $if(secondary-color)$
    secondary-color: parse-color("$secondary-color$"),
  $elseif(brand.color.secondary)$
    secondary-color: parse-color("$brand.color.secondary$"),
  $else$
    secondary-color: parse-color("#c8102e"),
  $endif$

  // Background ----------------------------------------------------------------
  $if(background-image)$
    background-image: "$background-image$",
  $endif$
  $if(background-color)$
    background-color: parse-color("$background-color$"),
  $endif$
  // Title slide ---------------------------------------------------------------
  $if(font-family-title)$
    font-family-title: "$font-family-title$",
    title-font: "$font-family-title$",
  $elseif(title-font)$
    font-family-title: "$title-font$",
  $elseif(brand.superslides.title.family)$
    font-family-title: "$brand.superslides.title.family$",
  $endif$
  $if(font-size-title)$
    font-size-title: $font-size-title$,
  $elseif(brand.superslides.title.size)$
    font-size-title: $brand.superslides.title.size$,
  $endif$
  $if(font-weight-title)$
    font-weight-title: "$font-weight-title$",
  $elseif(brand.superslides.title.weight)$
    font-weight-title: $brand.superslides.title.weight$,
  $endif$
  $if(text-color-title)$
    text-color-title: parse-color("$text-color-title$"),
  $elseif(brand.superslides.title.color)$
    text-color-title: parse-color("$brand.superslides.title.color$"),
  $endif$
  $if(font-family-subtitle)$
    font-family-subtitle: "$font-family-subtitle$",
  $elseif(brand.superslides.subtitle.family)$
    font-family-subtitle: "$brand.superslides.subtitle.family$",
  $endif$
  $if(font-size-subtitle)$
    font-size-subtitle: $font-size-subtitle$,
  $elseif(brand.superlides.subtitle.size)$
    font-size-subtitle: $brand.superlides.subtitle.size$,
  $endif$
  $if(font-weight-subtitle)$
    font-weight-subtitle: "$font-weight-subtitle$",
  $elseif(brand.superlides.subtitle.weight)$
    font-weight-subtitle: $brand.superlides.subtitle.weight$,
  $endif$
  $if(font-color-title)$
    font-color-title: parse-color("$font-color-title$"),
  $elseif(brand.superslides.title.color)$
    font-color-title: parse-color("$brand.superslides.title.color$"),
  $endif$
  $if(font-color-subtitle)$
    font-color-subtitle: parse-color("$font-color-subtitle$"),
  $elseif(brand.superslides.subtitle.color)$
    font-color-subtitle: parse-color("$brand.superlides.subtitle.color$"),
  $endif$
  $if(font-family-author)$
    font-family-author: "$font-family-author$",
  $elseif(brand.superlides.author.family)$
    font-family-author: "$brand.superlides.author.family$",
  $endif$
  $if(font-size-author)$
    font-size-author: $font-size-author$,
  $elseif(brand.superslides.author.size)$
    font-size-author: $brand.superslides.author.size$,
  $endif$
  $if(font-weight-author)$
    font-weight-author: "$font-weight-author$",
  $elseif(brand.superslides.author.weight)$
    font-weight-author: $brand.superslides.author.weight$,
  $endif$
  $if(font-color-author)$
    font-color-author: parse-color("$font-color-author$"),
  $elseif(brand.superslides.author.color)$
    font-color-author: parse-color("$brand.superslides.author.color$"),
  $endif$
  $if(font-family-affiliation)$
    font-family-affiliation: "$font-family-affiliation$",
  $elseif(brand.superslides.affiliation.family)$
    font-family-affiliation: "$brand.superslides.affiliation.family$",
  $endif$
  $if(font-size-affiliation)$
    font-size-affiliation: $font-size-affiliation$,
  $elseif(brand.superslides.affiliation.size)$
    font-size-affiliation: $brand.superslides.affiliation.size$,
  $endif$
  $if(font-weight-affiliation)$
    font-weight-affiliation: "$font-weight-affiliation$",
  $elseif(brand.superslides.affiliation.weight)$
    font-weight-affiliation: $brand.superslides.affiliation.weight$,
  $endif$
  $if(font-color-affiliation)$
    font-color-affiliation: parse-color("$font-color-affiliation$"),
  $elseif(brand.superslides.affiliation.color)$
    font-color-affiliation: parse-color("$brand.superslides.affiliation.color$"),
  $endif$
  $if(font-color-heading)$
    font-color-heading: parse-color("$font-color-heading$")
  $elseif(brand.superslides.heading.color)$
    font-color-heading: parse-color("$brand.superslides.heading.color$"),
  $else$
    font-color-heading: parse-color("#333399"),
  $endif$
  $if(font-family-date)$
    font-family-date: "$font-family-date$",
  $elseif(brand.superslides.date.family)$
    font-family-date: "$brand.superslides.date.family$",
  $endif$
  $if(font-size-date)$
    font-size-date: $font-size-date$,
  $elseif(brand.superslides.date.size)$
    font-size-date: $brand.superslides.date.size$,
  $endif$
  $if(font-weight-date)$
    font-weight-date: "$font-weight-date$",
  $elseif(brand.superlides.date.weight)$
    font-weight-date: $brand.superlides.date.weight$,
  $endif$
  $if(font-color-date)$
    font-color-date: parse-color("$font-color-date$"),
  $elseif(brand.superslides.date.color)$
    font-color-date: parse-color("$brand.superslides.date.color$"),
  $else$
    font-color-date: parse-color("#131516"),
  $endif$
  $if(font-style-date)$
    font-style-date: "$font-style-date$",
  $elseif(brand.superslides.date.style)$
    font-style-date: "$brand.superslides.date.style$",
  $endif$
  $if(font-size-heading)$
    font-size-heading: $font-size-heading$,
  $elseif(brand.typography.headings.size)$
    font-size-heading: $brand.typography.headings.size$,
  $endif$

  $if(updates-link)$
    updates-link: "$updates-link$",
  $else$
    updates-link: "",
  $endif$
  $if(email-color)$
    email-color: parse-color("$email-color$"),
  $endif$
  $if(lang)$
    lang: "$lang$",
  $endif$

  // Title page customization --------------------------------------------------
  $if(logo-path)$
    logo-path: "$logo-path$",
  $endif$
  $if(title-compact)$
    title-compact: $title-compact$,
  $endif$
  $if(header)$
    header: "$header$",
  $endif$
  $if(footer)$
    footer: "$footer$",
  $endif$
  $if(qr-code-url)$
    qr-code-url: "$qr-code-url$",
  $endif$
  $if(qr-code-title)$
    qr-code-title: "$qr-code-title$",
  $endif$
  $if(qr-code-size)$
    qr-code-size: $qr-code-size$,
  $endif$
  $if(qr-code-button-color)$
    qr-code-button-color: parse-color("$qr-code-button-color$"),
  $endif$
  $if(last-updated-text)$
    last-updated-text: "$last-updated-text$",
  $else$
    last-updated-text: "Updated:",
  $endif$

  // Showybox customization (colors auto-generated from primary/secondary) ----
  // Border and appearance settings
  // $if(box-border-thickness)$
  //   box-border-thickness: $box-border-thickness$,
  // $endif$
  // $if(box-border-radius)$
  //   box-border-radius: $box-border-radius$,
  // $endif$
  // $if(box-shadow)$
  //   box-shadow: $box-shadow$,
  // $endif$

  // // Typography settings
  // $if(box-title-font-size)$
  //   box-title-font-size: $box-title-font-size$,
  // $endif$
  // $if(box-title-font-weight)$
  //   box-title-font-weight: "$box-title-font-weight$",
  // $endif$
  // $if(box-body-font-size)$
  //   box-body-font-size: $box-body-font-size$,
  // $endif$
  // $if(box-body-font-weight)$
  //   box-body-font-weight: "$box-body-font-weight$",
  // $endif$

  // // Spacing settings
  // $if(box-spacing-above)$
  //   box-spacing-above: $box-spacing-above$,
  // $endif$
  // $if(box-spacing-below)$
  //   box-spacing-below: $box-spacing-below$,
  // $endif$
  // $if(box-padding)$
  //   box-padding: $box-padding$,
  // $endif$

  // Theorem configuration (colors auto-generated from primary-color) ---------
  $if(theorem-package)$
    theorem-package: "$theorem-package$",
  $else$
    theorem-package: "ctheorems",
  $endif$
  $if(theorem-lang)$
    theorem-lang: "$theorem-lang$",
  $endif$
  $if(theorem-numbering)$
    theorem-numbering: $theorem-numbering$,
  $endif$
)




// Dynamic theorem setup based on YAML - colors generated from primary-color

#import "@preview/ctheorems:1.1.3": *
#show: thmrules

#import "_extensions/superslides/translations.typ"
#import "_extensions/superslides/colors.typ"
#let superslides-primary = parse-color("$if(primary-color)$$primary-color$$elseif(brand.color.primary)$$brand.color.primary$$else$#333399$endif$")
// Helper function for simple sequential numbering
$if(theorem-numbering)$
  #let unary(.., last) = last
$else$
  #let unary(.., last) = none
$endif$

#let theorem = thmbox(
  "theorem",
  translations.variant("theorem"),
  fill: superslides-primary.lighten(80%)
).with(
  numbering: unary
)

#let lemma = thmbox(
  "lemma",
  translations.variant("lemma"),
  fill: superslides-primary.lighten(80%)
).with(
  numbering: unary)

#let proposition = thmbox(
  "proposition",
  translations.variant("proposition"),
  fill: superslides-primary.lighten(80%)
).with(
  numbering: unary)

#let corollary = thmbox(
  "corollary",
  translations.variant("corollary"),
  fill: superslides-primary.lighten(80%)
).with(
  numbering: unary)

#let definition = thmbox(
  "definition",
  translations.variant("definition"),
  fill: superslides-primary.lighten(90%)
).with(
  numbering: unary)

#let example = thmbox(
  "example",
  translations.variant("example"),
  fill: superslides-primary.lighten(90%)
).with(
  numbering: unary)

#let assumption = thmbox(
  "assumption",
  translations.variant("assumption"),
  fill: superslides-primary.lighten(90%)
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
  title: [$title$],
  subtitle: [$subtitle$],
  authors: (
    $for(by-author)$
      $if(it.name.literal)$
          ( name: [$it.name.literal$],
            affiliation: [
              $if(it.affiliations)$
                $for(it.affiliations)$$it.name$$sep$, $endfor$
              $elseif(it.affiliation)$
                $it.affiliation$
              $endif$
            ],
            email: [$it.email$],
            orcid: [$it.orcid$]),
      $endif$
    $endfor$
  ),
  date: [$date$],
  date-updated: [
    $if(date-updated)$$date-updated$$else$null$endif$
  ],
  web: [$web$],
  icon: [$icon$]
)
