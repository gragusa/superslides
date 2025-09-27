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
  $elseif(brand.typography.headings.family)$
    font-family-heading: ("$brand.typography.headings.family$",),
  $endif$
  $if(mainfont)$
    font-family-body: ("$mainfont$",),
  $elseif(brand.typography.base.family)$
    font-family-body: ("$brand.typography.base.family$",),
  $endif$
  $if(font-weight-heading)$
    font-weight-heading: "$font-weight-heading$",
  $elseif(brand.typography.headings.weight)$
    font-weight-heading: $brand.typography.headings.weight$,
  $endif$
  $if(font-weight-body)$
    font-weight-body: "$font-weight-body$",
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

  // Colors --------------------------------------------------------------------
  $if(jet)$
    color-jet: parse-color("$jet$"),
  $elseif(brand.color.foreground)$
    color-jet: parse-color("$brand.color.foreground$"),
  $endif$
  $if(accent)$
    color-accent: parse-color("$accent$"),
  $elseif(brand.color.primary)$
    color-accent: parse-color("$brand.color.primary$"),
  $endif$
  $if(accent2)$
    color-accent2: parse-color("$accent2$"),
  $elseif(brand.color.secondary)$
    color-accent2: parse-color("$brand.color.secondary$"),
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
    font-weight-title: $font-weight-title$,
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

  // Showybox customization -----------------------------------------------------
  // Color settings
  $if(simplebox-color)$
    simplebox-color: parse-color("$simplebox-color$"),
  $endif$
  $if(warningbox-color)$
    warningbox-color: parse-color("$warningbox-color$"),
  $endif$
  $if(infobox-color)$
    infobox-color: parse-color("$infobox-color$"),
  $endif$
  $if(alert-color)$
    alert-color: parse-color("$alert-color$"),
  $endif$

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

  // Individual box type overrides
  $if(simplebox-thickness)$
    simplebox-thickness: $simplebox-thickness$,
  $endif$
  $if(simplebox-radius)$
    simplebox-radius: $simplebox-radius$,
  $endif$
  $if(warningbox-thickness)$
    warningbox-thickness: $warningbox-thickness$,
  $endif$
  $if(warningbox-radius)$
    warningbox-radius: $warningbox-radius$,
  $endif$
  $if(infobox-thickness)$
    infobox-thickness: $infobox-thickness$,
  $endif$
  $if(infobox-radius)$
    infobox-radius: $infobox-radius$,
  $endif$

  // Theorem configuration -----------------------------------------------------
  $if(theorem-package)$
    theorem-package: "$theorem-package$",
  $endif$
  $if(theorem-lang)$
    theorem-lang: "$theorem-lang$",
  $endif$
  $if(theorem-numbering)$
    theorem-numbering: $theorem-numbering$,
  $endif$
  $if(theorem-font-size)$
    theorem-font-size: $theorem-font-size$,
  $endif$
  $if(theorem-title-weight)$
    theorem-title-weight: "$theorem-title-weight$",
  $endif$
  $if(theorem-body-weight)$
    theorem-body-weight: "$theorem-body-weight$",
  $endif$

  // Individual theorem type colors
  $if(theorem-color)$
    theorem-color: "$theorem-color$",
  $endif$
  $if(theorem-border)$
    theorem-border: "$theorem-border$",
  $endif$
  $if(lemma-color)$
    lemma-color: "$lemma-color$",
  $endif$
  $if(lemma-border)$
    lemma-border: "$lemma-border$",
  $endif$
  $if(corollary-color)$
    corollary-color: "$corollary-color$",
  $endif$
  $if(corollary-border)$
    corollary-border: "$corollary-border$",
  $endif$
  $if(proposition-color)$
    proposition-color: "$proposition-color$",
  $endif$
  $if(proposition-border)$
    proposition-border: "$proposition-border$",
  $endif$
  $if(conjecture-color)$
    conjecture-color: "$conjecture-color$",
  $endif$
  $if(conjecture-border)$
    conjecture-border: "$conjecture-border$",
  $endif$
  $if(definition-color)$
    definition-color: "$definition-color$",
  $endif$
  $if(definition-border)$
    definition-border: "$definition-border$",
  $endif$
  $if(example-color)$
    example-color: "$example-color$",
  $endif$
  $if(example-border)$
    example-border: "$example-border$",
  $endif$
  $if(exercise-color)$
    exercise-color: "$exercise-color$",
  $endif$
  $if(exercise-border)$
    exercise-border: "$exercise-border$",
  $endif$
  $if(solution-color)$
    solution-color: "$solution-color$",
  $endif$
  $if(solution-border)$
    solution-border: "$solution-border$",
  $endif$
  $if(remark-color)$
    remark-color: "$remark-color$",
  $endif$
  $if(remark-border)$
    remark-border: "$remark-border$",
  $endif$
  $if(assumption-color)$
    assumption-color: "$assumption-color$",
  $endif$
  $if(assumption-border)$
    assumption-border: "$assumption-border$",
  $endif$

  // Global theorem styling
  $if(theorem-border-thickness)$
    theorem-border-thickness: "$theorem-border-thickness$",
  $endif$
  $if(theorem-border-radius)$
    theorem-border-radius: "$theorem-border-radius$",
  $endif$
  $if(theorem-title-font-size)$
    theorem-title-font-size: "$theorem-title-font-size$",
  $endif$
  $if(theorem-title-font-weight)$
    theorem-title-font-weight: "$theorem-title-font-weight$",
  $endif$
  $if(theorem-body-font-size)$
    theorem-body-font-size: "$theorem-body-font-size$",
  $endif$
  $if(theorem-body-font-weight)$
    theorem-body-font-weight: "$theorem-body-font-weight$",
  $endif$
  $if(theorem-padding)$
    theorem-padding: "$theorem-padding$",
  $endif$
  $if(theorem-spacing)$
    theorem-spacing: "$theorem-spacing$",
  $endif$
)


// Helper function for simple sequential numbering
#let unary(.., last) = last

// Dynamic theorem setup based on YAML
$if(theorem-package)$
// Current implementation: ctheorems package (theorion support planned)
#show: thmrules
// Setup theorem environments with YAML configuration
$if(theorem-numbering)$
#let theorem = thmbox("theorem", if "$theorem-lang$" == "en" { "Theorem" } else { "Teorema" }, fill: rgb("#$theorem-color$")).with(numbering: unary)
#let proposition = thmbox("proposition", if "$theorem-lang$" == "en" { "Proposition" } else { "Proposizione" }, fill: rgb("$if(proposition-color)$$proposition-color$$else$#E5F3E9$endif$")).with(numbering: unary)
#let lemma = thmbox("lemma", if "$theorem-lang$" == "en" { "Lemma" } else { "Lemma" }, fill: rgb("#$lemma-color$")).with(numbering: unary)
#let corollary = thmbox("corollary", if "$theorem-lang$" == "en" { "Corollary" } else { "Corollario" }, fill: rgb("$if(corollary-color)$$corollary-color$$else$#F8F0E8$endif$")).with(numbering: unary)
#let conjecture = thmbox("conjecture", if "$theorem-lang$" == "en" { "Conjecture" } else { "Congettura" }, fill: rgb("$if(conjecture-color)$$conjecture-color$$else$#F3F8F0$endif$")).with(numbering: unary)
#let definition = thmbox("definition", if "$theorem-lang$" == "en" { "Definition" } else { "Definizione" }, fill: rgb("$if(definition-color)$$definition-color$$else$#E0EDF4$endif$")).with(numbering: unary)
#let example = thmbox("example", if "$theorem-lang$" == "en" { "Example" } else { "Esempio" }, fill: rgb("$if(example-color)$$example-color$$else$#F0F8E6$endif$")).with(numbering: unary)
#let exercise = thmbox("exercise", if "$theorem-lang$" == "en" { "Exercise" } else { "Esercizio" }, fill: rgb("$if(exercise-color)$$exercise-color$$else$#E0EDF4$endif$")).with(numbering: unary)
#let solution = thmbox("solution", if "$theorem-lang$" == "en" { "Solution" } else { "Soluzione" }, fill: rgb("$if(solution-color)$$solution-color$$else$#F5F0F8$endif$")).with(numbering: unary)
#let assumption = thmbox("assumption", if "$theorem-lang$" == "en" { "Assumption" } else { "Assunzione" }, fill: rgb("#$assumption-color$")).with(numbering: unary)
#let remark = thmbox("remark", if "$theorem-lang$" == "en" { "Remark" } else { "Osservazione" }, fill: rgb("$if(remark-color)$$remark-color$$else$#F0F8F5$endif$")).with(numbering: unary)
#let proof = thmbox("proof", if "$theorem-lang$" == "en" { "Proof" } else { "Dimostrazione" }, fill: rgb("$if(remark-color)$$remark-color$$else$#F8F5F0$endif$")).with(numbering: none)
$else$
#let theorem = thmbox("theorem", if "$theorem-lang$" == "en" { "Theorem" } else { "Teorema" }, fill: rgb("#$theorem-color$")).with(numbering: none)
#let proposition = thmbox("proposition", if "$theorem-lang$" == "en" { "Proposition" } else { "Proposizione" }, fill: rgb("$if(proposition-color)$$proposition-color$$else$#E5F3E9$endif$")).with(numbering: none)
#let lemma = thmbox("lemma", if "$theorem-lang$" == "en" { "Lemma" } else { "Lemma" }, fill: rgb("#$lemma-color$")).with(numbering: none)
#let corollary = thmbox("corollary", if "$theorem-lang$" == "en" { "Corollary" } else { "Corollario" }, fill: rgb("$if(corollary-color)$$corollary-color$$else$#F8F0E8$endif$")).with(numbering: none)
#let conjecture = thmbox("conjecture", if "$theorem-lang$" == "en" { "Conjecture" } else { "Congettura" }, fill: rgb("$if(conjecture-color)$$conjecture-color$$else$#F3F8F0$endif$")).with(numbering: none)
#let definition = thmbox("definition", if "$theorem-lang$" == "en" { "Definition" } else { "Definizione" }, fill: rgb("$if(definition-color)$$definition-color$$else$#E0EDF4$endif$")).with(numbering: none)
#let example = thmbox("example", if "$theorem-lang$" == "en" { "Example" } else { "Esempio" }, fill: rgb("$if(example-color)$$example-color$$else$#F0F8E6$endif$")).with(numbering: none)
#let exercise = thmbox("exercise", if "$theorem-lang$" == "en" { "Exercise" } else { "Esercizio" }, fill: rgb("$if(exercise-color)$$exercise-color$$else$#E0EDF4$endif$")).with(numbering: none)
#let solution = thmbox("solution", if "$theorem-lang$" == "en" { "Solution" } else { "Soluzione" }, fill: rgb("$if(solution-color)$$solution-color$$else$#F5F0F8$endif$")).with(numbering: none)
#let assumption = thmbox("assumption", if "$theorem-lang$" == "en" { "Assumption" } else { "Assunzione" }, fill: rgb("#$assumption-color$")).with(numbering: none)
#let remark = thmbox("remark", if "$theorem-lang$" == "en" { "Remark" } else { "Osservazione" }, fill: rgb("$if(remark-color)$$remark-color$$else$#F0F8F5$endif$")).with(numbering: none)
#let proof = thmbox("proof", if "$theorem-lang$" == "en" { "Proof" } else { "Dimostrazione" }, fill: rgb("$if(remark-color)$$remark-color$$else$#F8F5F0$endif$")).with(numbering: none)
$endif$
$endif$

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
  lecture-date: [$lecture-date$],
  web: [$web$],
  icon: [$icon$]
)