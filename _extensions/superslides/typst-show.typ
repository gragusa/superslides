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
  $endif$
  $if(primary-color)$
    primary-color: parse-color("$primary-color$"),
  $elseif(brand.color.primary)$
    primary-color: parse-color("$brand.color.primary$"),
  $endif$
  $if(secondary-color)$
    secondary-color: parse-color("$secondary-color$"),
  $elseif(brand.color.secondary)$
    secondary-color: parse-color("$brand.color.secondary$"),
  $endif$

  // Background ----------------------------------------------------------------
  $if(background-image)$
    background-image: "$background-image$",
  $endif$
  $if(background-color)$
    background-color: parse-color("$background-color$"),
  $endif$
  // Title slide ---------------------------------------------------------------
  $if(title-font)$
    title-font: "$title-font$",
  $endif$
  $if(title-size)$
    title-size: $title-size$,
  $endif$
  $if(title-weight)$
    title-weight: "$title-weight$",
  $endif$
  $if(subtitle-font)$
    subtitle-font: "$subtitle-font$",
  $endif$
  $if(subtitle-size)$
    subtitle-size: $subtitle-size$,
  $endif$
  $if(subtitle-weight)$
    subtitle-weight: "$subtitle-weight$",
  $endif$
  $if(author-size)$
    author-size: $author-size$,
  $endif$
  $if(date-size)$
    date-size: $date-size$,
  $endif$
  $if(font-weight-title)$
    font-weight-title: "$font-weight-title$",
  $elseif(brand.defaults.clean-typst.title-slide.title.weight)$
    font-weight-title: $brand.defaults.clean-typst.title-slide.title.weight$,
  $endif$
  $if(font-size-title)$
    font-size-title: $font-size-title$,
  $elseif(brand.defaults.clean-typst.title-slide.title.size)$
    font-size-title: $brand.defaults.clean-typst.title-slide.title.size$,
  $endif$
  $if(font-size-subtitle)$
    font-size-subtitle: $font-size-subtitle$,
  $elseif(brand.defaults.clean-typst.title-slide.subtitle.size)$
    font-size-subtitle: $brand.defaults.clean-typst.title-slide.subtitle.size$,
  $endif$
  $if(updates-link)$
    updates-link: "$updates-link$",
  $endif$
  $if(affiliation-color)$
    affiliation-color: parse-color("$affiliation-color$"),
  $endif$
  $if(affiliation-style)$
    affiliation-style: "$affiliation-style$",
  $endif$
  $if(affiliation-weight)$
    affiliation-weight: "$affiliation-weight$",
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
  $endif$

  // Showybox customization (colors auto-generated from primary/secondary) ----
  // Border and appearance settings
  $if(box-border-thickness)$
    box-border-thickness: $box-border-thickness$,
  $endif$
  $if(box-border-radius)$
    box-border-radius: $box-border-radius$,
  $endif$
  $if(box-shadow)$
    box-shadow: $box-shadow$,
  $endif$

  // Typography settings
  $if(box-title-font-size)$
    box-title-font-size: $box-title-font-size$,
  $endif$
  $if(box-title-font-weight)$
    box-title-font-weight: "$box-title-font-weight$",
  $endif$
  $if(box-body-font-size)$
    box-body-font-size: $box-body-font-size$,
  $endif$
  $if(box-body-font-weight)$
    box-body-font-weight: "$box-body-font-weight$",
  $endif$

  // Spacing settings
  $if(box-spacing-above)$
    box-spacing-above: $box-spacing-above$,
  $endif$
  $if(box-spacing-below)$
    box-spacing-below: $box-spacing-below$,
  $endif$
  $if(box-padding)$
    box-padding: $box-padding$,
  $endif$

  // Theorem configuration (colors auto-generated from primary-color) ---------
  $if(theorem-package)$
    theorem-package: "$theorem-package$",
  $endif$
  $if(theorem-lang)$
    theorem-lang: "$theorem-lang$",
  $endif$
  $if(theorem-numbering)$
    theorem-numbering: $theorem-numbering$,
  $endif$
)




// Dynamic theorem setup based on YAML - colors generated from primary-color
$if(theorem-package)$
#import "@preview/ctheorems:1.1.3": *
#show: thmrules

#import "_extensions/superslides/translations.typ"
#import "_extensions/superslides/colors.typ"
// Helper function for simple sequential numbering
$if(theorem-numbering)$
  #let unary(.., last) = last
$else$
  #let unary(.., last) = none
$endif$

#let theorem = thmbox(
  "theorem",
  translations.variant("theorem"),
  fill: parse-color("$primary-color$").lighten(80%)
).with(
  numbering: unary
)

#let lemma = thmbox(
  "lemma",
  translations.variant("lemma"),
  fill: parse-color("$primary-color$").lighten(80%)
).with(
  numbering: unary)

#let proposition = thmbox(
  "proposition",
  translations.variant("proposition"),
  fill: parse-color("$primary-color$").lighten(80%)
).with(
  numbering: unary)

#let corollary = thmbox(
  "corollary",
  translations.variant("corollary"),
  fill: parse-color("$primary-color$").lighten(80%)
).with(
  numbering: unary)

#let definition = thmbox(
  "definition",
  translations.variant("definition"),
  fill: parse-color("$primary-color$").lighten(90%)
).with(
  numbering: unary)

#let example = thmbox(
  "example",
  translations.variant("example"),
  fill: parse-color("$primary-color$").lighten(90%)
).with(
  numbering: unary)

#let assumption = thmbox(
  "assumption",
  translations.variant("assumption"),
  fill: parse-color("$primary-color$").lighten(90%)
).with(
  numbering: unary)

$endif$

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
            affiliation: [$for(it.affiliations)$$it.name$$sep$, $endfor$],
            email: [$it.email$],
            orcid: [$it.orcid$]),
      $endif$
    $endfor$
  ),
  date: [$date$],
  update-date: [$update-date$],
  web: [$web$],
  icon: [$icon$]
)
