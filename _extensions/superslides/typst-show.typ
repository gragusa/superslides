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

// =============================================================================
// Set document language EARLY
// =============================================================================
$if(lang)$
#set text(lang: "$lang$")
$endif$

// =============================================================================
// Theorem system — uses ctheorems (injected by Quarto) styled like theorion rainbow
// =============================================================================
// Quarto already injects:  #import "@preview/ctheorems:1.1.3": *
//                          #show: thmrules
// We just define the environments with rainbow-like appearance.

// --- i18n helper ---
#let _thm-translations = (
  "theorem": (en: "Theorem", it: "Teorema", de: "Satz", fr: "Théorème", es: "Teorema", ca: "Teorema"),
  "lemma": (en: "Lemma", it: "Lemma", de: "Lemma", fr: "Lemme", es: "Lema", ca: "Lema"),
  "proposition": (en: "Proposition", it: "Proposizione", de: "Proposition", fr: "Proposition", es: "Proposición", ca: "Proposició"),
  "corollary": (en: "Corollary", it: "Corollario", de: "Korollar", fr: "Corollaire", es: "Corolario", ca: "Coroŀlari"),
  "conjecture": (en: "Conjecture", it: "Congettura", de: "Vermutung", fr: "Conjecture", es: "Conjetura", ca: "Conjectura"),
  "definition": (en: "Definition", it: "Definizione", de: "Definition", fr: "Définition", es: "Definición", ca: "Definició"),
  "assumption": (en: "Assumption", it: "Assunzione", de: "Annahme", fr: "Hypothèse", es: "Hipótesis", ca: "Hipòtesi"),
  "example": (en: "Example", it: "Esempio", de: "Beispiel", fr: "Exemple", es: "Ejemplo", ca: "Exemple"),
  "exercise": (en: "Exercise", it: "Esercizio", de: "Übung", fr: "Exercice", es: "Ejercicio", ca: "Exercici"),
  "remark": (en: "Remark", it: "Osservazione", de: "Bemerkung", fr: "Remarque", es: "Observación", ca: "Observació"),
  "solution": (en: "Solution", it: "Soluzione", de: "Lösung", fr: "Solution", es: "Solución", ca: "Solució"),
  "proof": (en: "Proof", it: "Dimostrazione", de: "Beweis", fr: "Démonstration", es: "Demostración", ca: "Demostració"),
  "axiom": (en: "Axiom", it: "Assioma", de: "Axiom", fr: "Axiome", es: "Axioma", ca: "Axioma"),
)

$if(lang)$
#let _thm-name(key) = _thm-translations.at(key).at("$lang$", default: _thm-translations.at(key).at("en"))
$else$
#let _thm-name(key) = _thm-translations.at(key).at("en")
$endif$

// --- Rainbow-styled thmbox: colored left border, colored bold title ---
#let rainbow-thmbox(identifier, color, base: none, base_level: none) = thmbox(
  identifier,
  _thm-name(identifier),
  stroke: (left: 0.25em + color),
  fill: none,
  inset: (left: 1em, top: 0.75em, bottom: 0.75em, right: 1em),
  radius: 0em,
  padding: (top: 0.3em, bottom: 0.3em),
  titlefmt: title => strong(text(fill: color, title)),
  separator: [\ ],
  base: base,
  base_level: base_level,
)

// --- Color definitions ---
// YAML overrides via theorem-fill, definition-fill, etc.
// Defaults match theorion's cosmos/rainbow palette (each environment has its own color).
#let superslides-primary = parse-color("$if(primary-color)$$primary-color$$elseif(brand.color.primary)$$brand.color.primary$$else$#333399$endif$")
#let superslides-secondary = parse-color("$if(secondary-color)$$secondary-color$$elseif(brand.color.secondary)$$brand.color.secondary$$else$#c8102e$endif$")

// Per-environment colors — rainbow defaults, overridable via YAML
#let _clr-theorem     = $if(theorem-fill)$parse-theme-color("$theorem-fill$", superslides-primary, superslides-secondary)$else$red.darken(20%)$endif$
#let _clr-lemma       = $if(theorem-fill)$parse-theme-color("$theorem-fill$", superslides-primary, superslides-secondary)$else$teal.darken(10%)$endif$
#let _clr-proposition  = $if(theorem-fill)$parse-theme-color("$theorem-fill$", superslides-primary, superslides-secondary)$else$blue.darken(10%)$endif$
#let _clr-corollary   = $if(theorem-fill)$parse-theme-color("$theorem-fill$", superslides-primary, superslides-secondary)$else$fuchsia.darken(10%)$endif$
#let _clr-conjecture  = $if(theorem-fill)$parse-theme-color("$theorem-fill$", superslides-primary, superslides-secondary)$else$navy.darken(10%)$endif$
#let _clr-definition  = $if(definition-fill)$parse-theme-color("$definition-fill$", superslides-primary, superslides-secondary)$else$orange$endif$
#let _clr-assumption  = $if(definition-fill)$parse-theme-color("$definition-fill$", superslides-primary, superslides-secondary)$else$purple.darken(10%)$endif$
#let _clr-axiom       = green.darken(20%)
#let _clr-example     = $if(example-fill)$parse-theme-color("$example-fill$", superslides-primary, superslides-secondary)$else$green.darken(10%)$endif$
#let _clr-exercise    = $if(exercise-fill)$parse-theme-color("$exercise-fill$", superslides-primary, superslides-secondary)$else$olive.darken(10%)$endif$
#let _clr-remark      = $if(remark-fill)$parse-theme-color("$remark-fill$", superslides-primary, superslides-secondary)$else$gray.darken(20%)$endif$
#let _clr-solution    = teal.darken(10%)

// --- Theorem environments (rainbow-styled via ctheorems) ---
$if(theorem-numbering)$
#let theorem     = rainbow-thmbox("theorem",     _clr-theorem,     base: none)
#let lemma       = rainbow-thmbox("lemma",       _clr-lemma,       base: none)
#let proposition = rainbow-thmbox("proposition", _clr-proposition, base: none)
#let corollary   = rainbow-thmbox("corollary",   _clr-corollary,   base: none)
#let conjecture  = rainbow-thmbox("conjecture",  _clr-conjecture,  base: none)
#let definition  = rainbow-thmbox("definition",  _clr-definition,  base: none)
#let assumption  = rainbow-thmbox("assumption",  _clr-assumption,  base: none)
#let axiom       = rainbow-thmbox("axiom",       _clr-axiom,       base: none)
#let example     = rainbow-thmbox("example",     _clr-example,     base: none)
#let exercise    = rainbow-thmbox("exercise",    _clr-exercise,    base: none)
#let remark      = rainbow-thmbox("remark",      _clr-remark,      base: none)
#let solution    = rainbow-thmbox("solution",    _clr-solution,    base: none)
#let proof       = thmproof("proof", _thm-name("proof"))
$else$
#let theorem     = rainbow-thmbox("theorem",     _clr-theorem,     base: none).with(numbering: none)
#let lemma       = rainbow-thmbox("lemma",       _clr-lemma,       base: none).with(numbering: none)
#let proposition = rainbow-thmbox("proposition", _clr-proposition, base: none).with(numbering: none)
#let corollary   = rainbow-thmbox("corollary",   _clr-corollary,   base: none).with(numbering: none)
#let conjecture  = rainbow-thmbox("conjecture",  _clr-conjecture,  base: none).with(numbering: none)
#let definition  = rainbow-thmbox("definition",  _clr-definition,  base: none).with(numbering: none)
#let assumption  = rainbow-thmbox("assumption",  _clr-assumption,  base: none).with(numbering: none)
#let axiom       = rainbow-thmbox("axiom",       _clr-axiom,       base: none).with(numbering: none)
#let example     = rainbow-thmbox("example",     _clr-example,     base: none).with(numbering: none)
#let exercise    = rainbow-thmbox("exercise",    _clr-exercise,    base: none).with(numbering: none)
#let remark      = rainbow-thmbox("remark",      _clr-remark,      base: none).with(numbering: none)
#let solution    = rainbow-thmbox("solution",    _clr-solution,    base: none).with(numbering: none)
#let proof       = thmproof("proof", _thm-name("proof"))
$endif$

// =============================================================================
// Touying presentation theme (INNER — processes body first, splits into slides)
// =============================================================================
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
  $if(heading-inset-top)$
    heading-inset-top: $heading-inset-top$,
  $endif$
  $if(heading-inset-bottom)$
    heading-inset-bottom: $heading-inset-bottom$,
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
  $if(logo-width)$
    logo-width: $logo-width$,
  $endif$
  $if(logo-align)$
    logo-align: $logo-align$,
  $endif$
  $if(logo-inset-top)$
    logo-inset-top: $logo-inset-top$,
  $endif$
  $if(logo-inset-bottom)$
    logo-inset-bottom: $logo-inset-bottom$,
  $endif$
  $if(logo-inset-left)$
    logo-inset-left: $logo-inset-left$,
  $endif$
  $if(logo-inset-right)$
    logo-inset-right: $logo-inset-right$,
  $endif$
  $if(title-compact)$
    title-compact: $title-compact$,
  $endif$
  $if(header)$
    header: [$header$],
  $endif$
  $if(footer)$
    footer: [$footer$],
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

  // Theorem configuration (passed to theme for potential use) -----------------
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
  $if(theorem-fill)$
    theorem-fill: "$theorem-fill$",
  $endif$
  $if(definition-fill)$
    definition-fill: "$definition-fill$",
  $endif$
  $if(example-fill)$
    example-fill: "$example-fill$",
  $endif$
  $if(remark-fill)$
    remark-fill: "$remark-fill$",
  $endif$
)

// When zebraw is active, neutralize Quarto's default raw block styling
$if(use-zebraw)$
#show raw.where(block: true): set block(fill: none, inset: 0pt, radius: 0pt, width: auto)
$endif$

// Enable equation numbering only for labeled equations.
#set math.equation(numbering: "(1)")
#show math.equation.where(numbering: "(1)"): it => {
  if it.has("label") { it }
  else { math.equation(it.body, block: it.block, numbering: none, supplement: it.supplement) }
}

#set table(
  stroke: none,
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
