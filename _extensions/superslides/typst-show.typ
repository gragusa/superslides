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
  $if(emph-color)$
    emph-color: parse-color("$emph-color$"),
  $endif$
  $if(emph-weight)$
    emph-weight: "$emph-weight$",
  $endif$
  $if(emph-style)$
    emph-style: "$emph-style$",
  $endif$
  $if(bold-emph-weight)$
    bold-emph-weight: "$bold-emph-weight$",
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
    font-color-heading: parse-color("$font-color-heading$"),
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
    theorem-package: "theorion",
  $endif$
  $if(theorem-lang)$
    theorem-lang: "$theorem-lang$",
  $endif$
  $if(theorem-numbering)$
    theorem-numbering: $theorem-numbering$,
  $endif$
  $if(theorem-fill)$
    theorem-fill: parse-color("$theorem-fill$"),
  $endif$
  $if(definition-fill)$
    definition-fill: parse-color("$definition-fill$"),
  $endif$
  $if(example-fill)$
    example-fill: parse-color("$example-fill$"),
  $endif$
  $if(remark-fill)$
    remark-fill: parse-color("$remark-fill$"),
  $endif$
)




// Dynamic theorem setup based on YAML - colors generated from primary-color

// Determine which theorem package to use
#let _theorem_package = "$if(theorem-package)$$theorem-package$$else$theorion$endif$"

// --- ctheorems import (for fallback) ---
#import "@preview/ctheorems:1.1.3": *

// --- theorion rainbow theme import ---
#import "@preview/theorion:0.4.1": cosmos
#import cosmos.rainbow: *

// Inline translations (used by ctheorems fallback)
#let translations-variants = (
  "theorem": ("en": "Theorem", "ca": "Teorema", "de": "Satz", "fr": "Théorème", "es": "Teorema", "it": "Teorema"),
  "assumption": ("en": "Assumption", "ca": "Hipòtesi", "de": "Annahme", "fr": "Hypothèse", "es": "Hipótesis", "it": "Assunzione"),
  "proposition": ("en": "Proposition", "ca": "Proposició", "de": "Proposition", "fr": "Proposition", "es": "Proposición", "it": "Proposizione"),
  "lemma": ("en": "Lemma", "ca": "Lema", "de": "Lemma", "fr": "Lemme", "es": "Lema", "it": "Lemma"),
  "corollary": ("en": "Corollary", "ca": "Coroŀlari", "de": "Korollar", "fr": "Corollaire", "es": "Corolario", "it": "Corollario"),
  "definition": ("en": "Definition", "ca": "Definició", "de": "Definition", "fr": "Définition", "es": "Definición", "it": "Definizione"),
  "example": ("en": "Example", "ca": "Exemple", "de": "Beispiel", "fr": "Exemple", "es": "Ejemplo", "it": "Esempio"),
  "remark": ("en": "Remark", "ca": "Observació", "de": "Bemerkung", "fr": "Remarque", "es": "Observación", "it": "Osservazione"),
  "note": ("en": "Note", "ca": "Nota", "de": "Notiz", "fr": "Note", "es": "Nota", "it": "Nota"),
  "exercise": ("en": "Exercise", "ca": "Exercici", "de": "Übung", "fr": "Exercice", "es": "Ejercicio", "it": "Esercizio"),
  "algorithm": ("en": "Algorithm", "ca": "Algorisme", "de": "Algorithmus", "fr": "Algorithme", "es": "Algoritmo", "it": "Algoritmo"),
  "claim": ("en": "Claim", "ca": "Afirmació", "de": "Behauptung", "fr": "Assertion", "es": "Afirmación", "it": "Affermazione"),
  "conjecture": ("en": "Conjecture", "ca": "Conjectura", "de": "Vermutung", "fr": "Conjecture", "es": "Conjetura", "it": "Congettura"),
  "solution": ("en": "Solution", "ca": "Solució", "de": "Lösung", "fr": "Solution", "es": "Solución", "it": "Soluzione"),
  "axiom": ("en": "Axiom", "ca": "Axioma", "de": "Axiom", "fr": "Axiome", "es": "Axioma", "it": "Assioma"),
  "proof": ("en": "Proof", "ca": "Demostració", "de": "Beweis", "fr": "Démonstration", "es": "Demostración", "it": "Dimostrazione"),
  "proof-of": ("en": "Proof of", "ca": "Demostració del", "de": "Beweis von", "fr": "Démonstration du", "es": "Demostración del", "it": "Dimostrazione di"),
)

#let translations-variant(key) = {
  let lang-dict = translations-variants.at(key, default: key)
  return if type(lang-dict) == str {
    lang-dict
  } else {
    context lang-dict.at(text.lang, default: lang-dict.at("en", default: key))
  }
}

#let superslides-primary = parse-color("$if(primary-color)$$primary-color$$elseif(brand.color.primary)$$brand.color.primary$$else$#333399$endif$")

// Theorem fill colors (customizable via YAML, defaults to primary-color lightened)
#let theorem-fill-color = $if(theorem-fill)$parse-color("$theorem-fill$")$else$superslides-primary.lighten(80%)$endif$
#let definition-fill-color = $if(definition-fill)$parse-color("$definition-fill$")$else$superslides-primary.lighten(75%)$endif$
#let example-fill-color = $if(example-fill)$parse-color("$example-fill$")$else$superslides-primary.lighten(75%)$endif$
#let remark-fill-color = $if(remark-fill)$parse-color("$remark-fill$")$else$superslides-primary.lighten(75%)$endif$

// --- Save theorion rainbow versions before they get shadowed ---
// Rainbow environments: theorem, lemma, proposition, corollary, conjecture,
//                       definition, assumption (each has its own rainbow color)
// Default environments: example, exercise, remark, solution (simpler styling)
$if(theorem-numbering)$
// Numbered theorion environments (default)
#let _th_theorem = $if(theorem-fill)$theorem.with(fill: theorem-fill-color)$else$theorem$endif$
#let _th_lemma = $if(theorem-fill)$lemma.with(fill: theorem-fill-color)$else$lemma$endif$
#let _th_proposition = $if(theorem-fill)$proposition.with(fill: theorem-fill-color)$else$proposition$endif$
#let _th_corollary = $if(theorem-fill)$corollary.with(fill: theorem-fill-color)$else$corollary$endif$
#let _th_conjecture = $if(theorem-fill)$conjecture.with(fill: theorem-fill-color)$else$conjecture$endif$
#let _th_definition = $if(definition-fill)$definition.with(fill: definition-fill-color)$else$definition$endif$
#let _th_assumption = $if(definition-fill)$assumption.with(fill: definition-fill-color)$else$assumption$endif$
$else$
// Unnumbered theorion environments (use -box variants)
#let _th_theorem = $if(theorem-fill)$theorem-box.with(fill: theorem-fill-color)$else$theorem-box$endif$
#let _th_lemma = $if(theorem-fill)$lemma-box.with(fill: theorem-fill-color)$else$lemma-box$endif$
#let _th_proposition = $if(theorem-fill)$proposition-box.with(fill: theorem-fill-color)$else$proposition-box$endif$
#let _th_corollary = $if(theorem-fill)$corollary-box.with(fill: theorem-fill-color)$else$corollary-box$endif$
#let _th_conjecture = $if(theorem-fill)$conjecture-box.with(fill: theorem-fill-color)$else$conjecture-box$endif$
#let _th_definition = $if(definition-fill)$definition-box.with(fill: definition-fill-color)$else$definition-box$endif$
#let _th_assumption = $if(definition-fill)$assumption-box.with(fill: definition-fill-color)$else$assumption-box$endif$
$endif$
// Default-cosmos environments (same API for numbered/unnumbered)
#let _th_example = example
#let _th_exercise = exercise
#let _th_remark = remark
#let _th_solution = solution

// --- Conditional show rule ---
#show: body => {
  if _theorem_package == "ctheorems" {
    {
      show: thmrules
      body
    }
  } else {
    {
      show: show-theorion
      body
    }
  }
}

// --- ctheorems definitions (used when theorem-package == "ctheorems") ---
$if(theorem-numbering)$
#let _ct_theorem = thmbox("theorem", translations-variant("theorem"), fill: theorem-fill-color, base: none)
#let _ct_lemma = thmbox("lemma", translations-variant("lemma"), fill: theorem-fill-color, base: none)
#let _ct_proposition = thmbox("proposition", translations-variant("proposition"), fill: theorem-fill-color, base: none)
#let _ct_corollary = thmbox("corollary", translations-variant("corollary"), fill: theorem-fill-color, base: none)
#let _ct_conjecture = thmbox("conjecture", translations-variant("conjecture"), fill: theorem-fill-color, base: none)
#let _ct_definition = thmbox("definition", translations-variant("definition"), fill: definition-fill-color, base: none)
#let _ct_assumption = thmbox("assumption", translations-variant("assumption"), fill: definition-fill-color, base: none)
#let _ct_example = thmbox("example", translations-variant("example"), fill: example-fill-color, base: none)
#let _ct_exercise = thmbox("exercise", translations-variant("exercise"), fill: example-fill-color, base: none)
#let _ct_remark = thmbox("remark", translations-variant("remark"), fill: remark-fill-color, base: none)
#let _ct_solution = thmbox("solution", translations-variant("solution"), fill: remark-fill-color, base: none)
$else$
#let _ct_theorem = thmbox("theorem", translations-variant("theorem"), fill: theorem-fill-color).with(numbering: none)
#let _ct_lemma = thmbox("lemma", translations-variant("lemma"), fill: theorem-fill-color).with(numbering: none)
#let _ct_proposition = thmbox("proposition", translations-variant("proposition"), fill: theorem-fill-color).with(numbering: none)
#let _ct_corollary = thmbox("corollary", translations-variant("corollary"), fill: theorem-fill-color).with(numbering: none)
#let _ct_conjecture = thmbox("conjecture", translations-variant("conjecture"), fill: theorem-fill-color).with(numbering: none)
#let _ct_definition = thmbox("definition", translations-variant("definition"), fill: definition-fill-color).with(numbering: none)
#let _ct_assumption = thmbox("assumption", translations-variant("assumption"), fill: definition-fill-color).with(numbering: none)
#let _ct_example = thmbox("example", translations-variant("example"), fill: example-fill-color).with(numbering: none)
#let _ct_exercise = thmbox("exercise", translations-variant("exercise"), fill: example-fill-color).with(numbering: none)
#let _ct_remark = thmbox("remark", translations-variant("remark"), fill: remark-fill-color).with(numbering: none)
#let _ct_solution = thmbox("solution", translations-variant("solution"), fill: remark-fill-color).with(numbering: none)
$endif$

// --- Final bindings: select based on theorem package ---
#let theorem = if _theorem_package == "ctheorems" { _ct_theorem } else { _th_theorem }
#let lemma = if _theorem_package == "ctheorems" { _ct_lemma } else { _th_lemma }
#let proposition = if _theorem_package == "ctheorems" { _ct_proposition } else { _th_proposition }
#let corollary = if _theorem_package == "ctheorems" { _ct_corollary } else { _th_corollary }
#let conjecture = if _theorem_package == "ctheorems" { _ct_conjecture } else { _th_conjecture }
#let definition = if _theorem_package == "ctheorems" { _ct_definition } else { _th_definition }
#let assumption = if _theorem_package == "ctheorems" { _ct_assumption } else { _th_assumption }
#let example = if _theorem_package == "ctheorems" { _ct_example } else { _th_example }
#let exercise = if _theorem_package == "ctheorems" { _ct_exercise } else { _th_exercise }
#let remark = if _theorem_package == "ctheorems" { _ct_remark } else { _th_remark }
#let solution = if _theorem_package == "ctheorems" { _ct_solution } else { _th_solution }



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
