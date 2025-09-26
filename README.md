# Superslides

**Enhanced Typst presentation format for Quarto with advanced features**

Superslides is a powerful Quarto extension that creates beautiful, professional presentations using Typst with [Touying](https://github.com/touying-typ/touying). It offers advanced features like enhanced code blocks, interactive elements, and comprehensive customization options.

## ✨ Key Features

- 🎨 **Professional Title Slides** - Left-aligned layout with ORCID integration
- 🔗 **Interactive Elements** - Clickable QR codes, email links, and update buttons
- 📝 **Enhanced Code Blocks** - Zebraw integration for mathematical annotations
- 🎯 **Complete Customization** - 40+ YAML parameters for typography, colors, and layout
- 🌐 **Multi-language Support** - English/Italian interface text
- 🏢 **Brand Integration** - Organizational branding and color schemes
- 📱 **Responsive Design** - Optimized for presentation and handout modes

## 🚀 Quick Start

### Installation

```bash
quarto use template gragusa/superslides
```

Or install in an existing project:

```bash
quarto add gragusa/superslides
```

### Basic Usage

Create a `.qmd` file with the Superslides format:

```yaml
---
title: "My Presentation"
subtitle: "Enhanced with Superslides"
authors:
  - name: "Your Name"
    affiliation: "Your Institution"
    email: "your.email@example.com"
    orcid: "0000-0000-0000-0000"
date: today

format:
  superslides-typst:
    # Enable enhanced code blocks
    use-zebraw: true

    # Customize colors
    accent: "2E8B57"
    accent2: "CD853F"

    # Add QR code
    qr-code-url: "https://your-slides-url.com"
    qr-code-title: "View Online"
---

## Introduction

Your content here...
```

## 🎨 Title Slide Features

### Left-Aligned Design
- **Title**: All caps, customizable font and size
- **Subtitle**: Positioned beneath title
- **Authors**: Single author shows full details, multiple authors show names only

### Interactive Elements
- **ORCID Icons**: Clickable green icons linking to profiles
- **Email Links**: Clickable mailto links with custom styling
- **QR Codes**: Bottom-right corner with clickable button
- **Update Button**: Bottom-left corner linking to release notes

### Author Information Display

**Single Author** (shows full details):
```yaml
authors:
  - name: "Dr. Giuseppe Ragusa"
    affiliation: "Luiss University"
    email: "gragusa@luiss.it"
    orcid: "0000-0002-1234-5678"
```

**Multiple Authors** (shows names only):
```yaml
authors:
  - name: "Dr. Giuseppe Ragusa"
  - name: "Dr. Jane Smith"
  - name: "Prof. John Doe"
```

## 📝 Enhanced Code Blocks

### Zebraw Enhanced Code Blocks
Enable mathematical annotations and enhanced formatting:

```yaml
format:
  superslides-typst:
    use-zebraw: true
    zebraw-font-size: 12
    zebraw-comment-flag: "##"
    zebraw-comment-color: "2E8B57"
```

Example usage:
````markdown
```python
def calculate_area(radius):
    pi = 3.14159          ## Mathematical constant π
    area = pi * r²        ## Area formula A = πr²
    return area           ## Return result
```
````

## 🎯 Complete Configuration Reference

### Typography Settings
```yaml
format:
  superslides-typst:
    # Basic typography
    fontsize: 18pt
    mainfont: "Inter"
    sansfont: "Inter"
    font-weight-heading: "light"
    font-weight-body: "regular"

    # Title slide typography
    title-font: "Roboto"
    title-size: 42
    title-weight: "bold"
    subtitle-font: "Inter"
    subtitle-size: 28
    subtitle-weight: "regular"
    author-size: 20
    date-size: 18
```

### Color Scheme (3-Color System)
```yaml
format:
  superslides-typst:
    # Primary colors
    jet: "2C3E50"          # Main text color
    accent: "2E8B57"       # Primary accent (headings, links, buttons)
    accent2: "CD853F"      # Secondary accent (highlights, warnings)

    # Author styling colors
    affiliation-color: "2E8B57"
    affiliation-style: "italic"
    email-color: "CD853F"
```

### Interactive Elements
```yaml
format:
  superslides-typst:
    # QR Code
    qr-code-url: "https://your-site.com"
    qr-code-title: "View Online"
    qr-code-size: 4cm
    qr-code-button-color: "2E8B57"

    # Updates functionality
    updates-link: "https://github.com/user/repo/releases"

    # Language
    lang: "en"  # or "it" for Italian
```

### Code Block Configuration
```yaml
format:
  superslides-typst:
    # Standard code blocks
    raw-font-size: 15
    raw-inline-size: 14
    raw-inset: 8

    # Enhanced zebraw code blocks
    use-zebraw: true
    zebraw-font-size: 12
    zebraw-comment-flag: "##"
    zebraw-comment-color: "2E8B57"
```

## 🏢 Brand Integration

Create a `_brand.yml` file for organizational consistency:

```yaml
brand:
  color:
    primary: "#2E8B57"      # Your brand primary color
    secondary: "#CD853F"    # Your brand secondary color
    foreground: "#2C3E50"   # Main text color

  typography:
    base:
      family: "Inter"
      size: "18pt"
      weight: 400
    headings:
      family: "Inter"
      weight: 300
```

Settings in `_brand.yml` are automatically inherited by all presentations.

## 📚 Examples

### Academic Presentation
```yaml
---
title: "Research Findings"
subtitle: "Data Analysis and Results"
authors:
  - name: "Dr. Research Scholar"
    affiliation: "University Name"
    email: "scholar@university.edu"
    orcid: "0000-0000-0000-0000"

format:
  superslides-typst:
    use-zebraw: true
    accent: "1f4e79"
    qr-code-url: "https://research-project.com"
    lang: "en"
---
```

## 🛠️ Advanced Features

### Multi-language Support
- Set `lang: "it"` for Italian interface
- Automatic translation of "Last updated" text

### URL Handling
- Automatic URL escaping fixes
- Clickable email addresses
- ORCID profile integration
- QR code and update button functionality

### Typography System
- Font family control for headings and body
- Weight and size customization
- Consistent scaling system

## 📖 Documentation

### Parameter Priority
1. **Document YAML** (highest priority)
2. **Project `_quarto.yml`**
3. **Brand `_brand.yml`**
4. **Template defaults** (lowest priority)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues, feature requests, or pull requests.

## 🙏 Acknowledgments

- Built on [Touying](https://github.com/touying-typ/touying) presentation framework
- Enhanced code blocks powered by [Zebraw](https://github.com/typst/packages/tree/main/packages/preview/zebraw)
- QR code generation using [Cades](https://github.com/typst/packages/tree/main/packages/preview/cades)
- Icons provided by [FontAwesome](https://github.com/typst/packages/tree/main/packages/preview/fontawesome)

---

Made with ❤️ for the Quarto and Typst communities

