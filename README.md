# Superslides

**Enhanced Typst presentation format for Quarto with advanced features**

Superslides is a Quarto extension that creates beautiful, professional presentations using Typst with [Touying](https://github.com/touying-typ/touying).

It offers advanced features like enhanced code blocks, interactive elements, and comprehensive customization options.

## Quick Start

### Installation

```bash
quarto use template gragusa/superslides
```

Or install in an existing project:

```bash
quarto add gragusa/superslides
```

## External Configuration

Quarto automatically merges an `_metadata.yml` (or `.yaml`) file that lives in the same directory as your document. You can store all your `superslides-typst` options there and keep the slide front matter minimal.

1. Create `_metadata.yml` alongside your `.qmd` (this repo’s root `_metadata.yml` documents every available option):

   ```yaml
   format:
     superslides-typst:
       fontsize: 24pt
       mainfont: "Inter"
       accent: "#2836A6"
       # ...other options...
   ```

2. Keep your `.qmd` tidy—Quarto merges the values from `_metadata.yml` automatically during render. Override any individual option directly in the document only when you need to.

You can copy directly from the bundled `_metadata.yml` at the project root or from the working examples in `examples/template/_metadata.yml` and `examples/comprehensive/_metadata.yml`. In your slide deck front matter, use the standard `date` field for the presentation date and an optional `update-date` field; the title slide only shows the “Last updated” badge when `update-date` is provided.
