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

  // Showybox color customization ----------------------------------------------
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
)

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

