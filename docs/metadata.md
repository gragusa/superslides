# Superslides Metadata Reference

Superslides accepts configuration from two sources:

1. The Quarto document front‑matter (the `format: superslides-typst:` block in your `.qmd` file)
2. An optional brand file (typically `brand.yml`) that Quarto exposes to the template as `brand.*`

Document-level settings always win. When a value is omitted in the document, Superslides looks for the same value in the brand file; if that is also absent it falls back to a internal default (listed below).


## Document Front-Matter Keys

### Core rendering

| Key | Type | Default | Notes |
| --- | --- | --- | --- |
| `keep-typ` | bool | `false` | Preserve the generated `.typ` file |
| `handout` | bool | `false` | Enable Touying handout mode |
| `fig-width`, `fig-height` | number | Quarto default | Standard slide image size |

### Global typography

| Key | Type | Default (after fallbacks) | Brand fallback |
| --- | --- | --- | --- |
| `fontsize` | length | brand.typography.base.size → `24pt` | `brand.typography.base.size` |
| `mainfont` / `font-family-body` | string | brand.typography.base.family → `"Inter"` | `brand.typography.base.family` |
| `sansfont` / `font-family-heading` | string | brand.typography.headings.family → `"Oswald"` | `brand.typography.headings.family` |
| `font-family-math` | string | *unset* | — |
| `font-weight-body` | string | brand.typography.base.weight → `"regular"` | `brand.typography.base.weight` |
| `font-weight-heading` | string | brand.typography.headings.weight → `"medium"` | `brand.typography.headings.weight` |
| `strong-weight` | string | `"medium"` | — |
| `font-size-heading` | length | brand.typography.headings.size | `brand.typography.headings.size` |
| `text-color` | color | `#040404` | `brand.color.foreground` |

### Code blocks & lists

| Key | Default | Notes |
| --- | --- | --- |
| `raw-font-size` | `18pt` | Touying `show raw` block size |
| `raw-inline-size` | document font size | Inline code |
| `raw-inset` | `8pt` | Block code padding |
| `list-indent` | `0.6em` | Applies to ordered and unordered lists |
| `list-marker-1/2/3` | `"•"`, `"◦"`, `"▪"` | Custom bullet symbols |

### Colour palette

| Key | Default | Brand fallback |
| --- | --- | --- |
| `primary-color` | `#333399` | `brand.color.primary` |
| `secondary-color` | `#c8102e` | `brand.color.secondary` |

### Background & layout

| Key | Default | Notes |
| --- | --- | --- |
| `background-image` | none | Path to background asset |
| `background-color` | none | Slide background fill |
| `header` / `footer` | none | Content displayed via Touying header/footer hooks |
| `title-compact` | `false` | Removes spacing above title slide |
| `handout` | `false` | Repeat — toggles Touying handout mode |

### Title slide typography

| Key | Default | Brand fallback |
| --- | --- | --- |
| `font-family-title` / `title-font` | heading family | `brand.superslides.title.family` |
| `font-size-title` / `title-size` | `1.5em` | `brand.superslides.title.size` |
| `font-weight-title` / `title-weight` | `"regular"` | `brand.superslides.title.weight` |
| `text-color-title` / `font-color-title` | `#131516` | `brand.superslides.title.color` |
| `font-family-subtitle` / `subtitle-font` | body family | `brand.superslides.subtitle.family` |
| `font-size-subtitle` / `subtitle-size` | `1.5em` | `brand.superslides.subtitle.size` |
| `font-weight-subtitle` / `subtitle-weight` | `"regular"` | `brand.superslides.subtitle.weight` |
| `text-color-subtitle` / `font-color-subtitle` | `#131516` | `brand.superslides.subtitle.color` |
| `font-family-author` | body family | `brand.superslides.author.family` |
| `font-size-author` | `1em` | `brand.superslides.author.size` |
| `font-weight-author` | `"medium"` | `brand.superslides.author.weight` |
| `font-color-author` | `#131516` | `brand.superslides.author.color` |
| `font-family-affiliation` | body family | `brand.superslides.affiliation.family` |
| `font-size-affiliation` | `0.9em` | `brand.superslides.affiliation.size` |
| `font-weight-affiliation` | `"regular"` | `brand.superslides.affiliation.weight` |
| `font-style-affiliation` | `"italic"` | — (`brand.superslides.affiliation.style`) |
| `font-color-affiliation` | `#707070` | `brand.superslides.affiliation.color` |
| `font-family-date` | body family | `brand.superslides.date.family` |
| `font-size-date` | `1em` | `brand.superslides.date.size` |
| `font-weight-date` | `"medium"` | `brand.superslides.date.weight` |
| `font-style-date` | `"normal"` | `brand.superslides.date.style` |
| `font-color-date` | `#131516` | `brand.superslides.date.color` |
| `font-color-heading` | `#333399` | `brand.superslides.heading.color` |
| `email-color` | `#CD853F` | — |
| `lang` | `"en"` | Affects the “Last updated” label (`"Aggiornato al:"` in `"it"`) |

### “Last updated” badge

| Key | Default |
| --- | --- |
| `last-updated-text` | `"Updated:"` |
| `updates-link` | `""` (no link) |
| `date-updated` | none (provide in document YAML) |

### QR code block

| Key | Default |
| --- | --- |
| `qr-code-url` | none |
| `qr-code-title` | `"View Source"` |
| `qr-code-size` | `4cm` |
| `qr-code-button-color` | `#404040` |

### Theorem configuration

| Key | Default | Notes |
| --- | --- | --- |
| `theorem-package` | `"ctheorems"` | Can be `"theorion"` |
| `theorem-lang` | `"en"` | |
| `theorem-numbering` | `false` | Enables sequential numbering |

### Lists, callouts, extras

| Key | Default | Notes |
| --- | --- | --- |
| `logo-path` | none | Title slide logo |
| `title-compact` | `false` | Remove extra spacing |
| `header`, `footer` | none | Inline typst or strings |

---

## Brand File Structure

The brand file is optional but lets you centralise styling. Relevant sections:

```yaml
color:
  primary: "#107895"
  secondary: "#9a2515"
  foreground: "#040404"
  palette:
    red: "#FF6F61"

typography:
  base:
    family: "Roboto"
    weight: 400
    size: 1em
    color: foreground
  headings:
    family: "Roboto"
    weight: 600
    size: 1.2em
    color: primary
  link:
    size: 1em
    color: primary
    weight: 400
    decoration: underline

superslides:
  title:
    family: "Roboto"
    weight: 600
    size: 1.5em
    color: primary
  subtitle:
    family: "Roboto"
    weight: 600
    size: 1.5em
    color: foreground
    style: italic
  author:
    family: "Roboto"
    weight: 400
    size: 1em
    color: foreground
  institute:
    family: "Roboto"
    weight: 400
    size: 1em
    color: "#707070"
    style: italic
  date:
    family: typography.base.family
    weight: 400
    size: 1em
    color: foreground
  heading:
    color: primary
  qr-code:
    size: 1.5em
```

Any field under `brand` can be overridden per document by adding the corresponding key in the `.qmd` front matter. If neither is supplied, Superslides falls back to the defaults listed above.

---

## Author metadata

Provide authors in the document front-matter; each author map can include:

| Field | Description |
| --- | --- |
| `name` | Display name |
| `affiliation` or `affiliations` | Single string or list of affiliation objects |
| `email` | Used for the mailto badge |
| `orcid` | ORCID identifier (badge is added automatically) |

Affiliation formatting is governed by the `font-*` keys listed earlier.

---

## Summary

- Use document YAML for per-slide-deck overrides.
- Use `brand.yml` to supply organisation-wide defaults under the `brand.color`, `brand.typography`, and `brand.superslides` namespaces.
- When neither defines a value, Superslides falls back to its built-in palette (`#333399` / `#c8102e`), typography (`Inter`/`Oswald`), and theorem styling.

Drop this file into `docs/metadata.md` (already added) to keep the mapping handy for future decks.
