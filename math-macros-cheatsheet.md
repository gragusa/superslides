# Math Macros Cheatsheet

Commands provided by `expand-macros.lua`. Use in `$...$` or `$$...$$` math blocks.

## Sets

| Command | Expands to | Renders as |
|---------|-----------|------------|
| `\R` | `\mathbb{R}` | Real numbers |
| `\N` | `\mathbb{N}` | Natural numbers |

## Calligraphic Letters (`\calA` ... `\calZ`)

| Command | Expands to |
|---------|-----------|
| `\calA` | `\mathcal{A}` |
| `\calB` | `\mathcal{B}` |
| ... | ... |
| `\calZ` | `\mathcal{Z}` |

## Bold Uppercase Matrices (`\mA` ... `\mZ`)

| Command | Expands to |
|---------|-----------|
| `\mA` | `\mathbf{A}` |
| `\mB` | `\mathbf{B}` |
| ... | ... |
| `\mZ` | `\mathbf{Z}` |

## Bold Lowercase Vectors (`\va` ... `\vz`)

| Command | Expands to |
|---------|-----------|
| `\va` | `\mathbf{a}` |
| `\vb` | `\mathbf{b}` |
| ... | ... |
| `\vz` | `\mathbf{z}` |

## Bold Greek Vectors

| Command | Expands to |
|---------|-----------|
| `\valpha` | `\boldsymbol{\alpha}` |
| `\vbeta` | `\boldsymbol{\beta}` |
| `\vgamma` | `\boldsymbol{\gamma}` |
| `\vdelta` | `\boldsymbol{\delta}` |
| `\vepsilon` | `\boldsymbol{\epsilon}` |
| `\vvarepsilon` | `\boldsymbol{\varepsilon}` |
| `\vzeta` | `\boldsymbol{\zeta}` |
| `\veta` | `\boldsymbol{\eta}` |
| `\vtheta` | `\boldsymbol{\theta}` |
| `\viota` | `\boldsymbol{\iota}` |
| `\vkappa` | `\boldsymbol{\kappa}` |
| `\vlambda` | `\boldsymbol{\lambda}` |
| `\vmu` | `\boldsymbol{\mu}` |
| `\vnu` | `\boldsymbol{\nu}` |
| `\vxi` | `\boldsymbol{\xi}` |
| `\vpi` | `\boldsymbol{\pi}` |
| `\vrho` | `\boldsymbol{\rho}` |
| `\vsigma` | `\boldsymbol{\sigma}` |
| `\vtau` | `\boldsymbol{\tau}` |
| `\vupsilon` | `\boldsymbol{\upsilon}` |
| `\vphi` | `\boldsymbol{\phi}` |
| `\vchi` | `\boldsymbol{\chi}` |
| `\vpsi` | `\boldsymbol{\psi}` |
| `\vomega` | `\boldsymbol{\omega}` |

## Special Bold Symbols

| Command | Expands to | Renders as |
|---------|-----------|------------|
| `\mSigma` | `\boldsymbol{\Sigma}` | Bold Sigma matrix |
| `\mtheta` | `\boldsymbol{\theta}` | Bold theta vector |
| `\vzero` | `\mathbf{0}` | Bold zero vector |
| `\boldone` | `\mathbb{1}` | Indicator / ones |

## Convergence & Distribution

| Command | Expands to | Renders as |
|---------|-----------|------------|
| `\pto` | `\stackrel{p}{\longrightarrow}` | Convergence in probability |
| `\dto` | `\stackrel{d}{\longrightarrow}` | Convergence in distribution |
| `\simiid` | `\overset{\text{iid}}{\sim}` | iid distributed |
| `\simnid` | `\overset{\text{nid}}{\sim}` | nid distributed |
| `\sima` | `\overset{\text{a}}{\sim}` | Asymptotically distributed |

## Independence

| Command | Renders as |
|---------|------------|
| `\indep` | Independence symbol (double up tack) |
| `\nindep` | Not independent (crossed out) |

## Summation Shorthands

| Command | Expands to |
|---------|-----------|
| `\sumin` | `\sum_{i=1}^{n}` |
| `\sumg` | `\sum_{g=1}^{G}` |

## Subscript / Superscript (roman text)

| Command | Expands to | Example |
|---------|-----------|---------|
| `\ped{text}` | `_{\mathrm{text}}` | `x\ped{ols}` -> subscript "ols" in roman |
| `\ap{text}` | `^{\mathrm{text}}` | `x\ap{iv}` -> superscript "iv" in roman |

## Math Operators

| Command | Renders as |
|---------|------------|
| `\argmin` | arg min (with limits) |
| `\argmax` | arg max (with limits) |
| `\sign` | sign |
| `\trace` | Tr |
| `\determinant` | det |
| `\Real` | Re |
| `\Imag` | Im |
| `\nil` | nil |
| `\Dirichlet` | Dir |
| `\atantwo` | atan2 |

## Distributions

| Command | Expands to |
|---------|-----------|
| `\Normal` | `\mathcal{N}` |
| `\Uniform` | `\mathcal{U}` |

## Paired Delimiters

All delimiter commands accept `{arg}` and an optional `*` for `\left..\right` sizing.

| Command | No star | Star (`*`) |
|---------|---------|------------|
| `\paren{x}` | `(x)` | `\left(x\right)` |
| `\brock{x}` | `[x]` | `\left[x\right]` |
| `\curly{x}` | `\{x\}` | `\left\{x\right\}` |
| `\norm{x}` | `\lVert x\rVert` | `\left\lVert x\right\rVert` |
| `\abs{x}` | `\lvert x\rvert` | `\left\lvert x\right\rvert` |
| `\anglebrackets{x}` | `\langle x\rangle` | `\left\langle x\right\rangle` |
| `\ceil{x}` | `\lceil x\rceil` | `\left\lceil x\right\rceil` |
| `\floor{x}` | `\lfloor x\rfloor` | `\left\lfloor x\right\rfloor` |
| `\card{x}` | `\|x\|` | `\left\|x\right\|` |

## Expectation, Variance, Covariance, Correlation

All accept `{arg}` and optional `*`. Suffixes: (none) = `()`, `b` = `[]`, `c` = `{}`, `a` = `||`.

| Command | Renders as |
|---------|------------|
| `\E{X}` | E(X) |
| `\Eb{X}` | E[X] |
| `\Ec{X}` | E{X} |
| `\Ea{X}` | E\|X\| |
| `\var{X}` | Var(X) |
| `\varb{X}` | Var[X] |
| `\varc{X}` | Var{X} |
| `\avar{X}` | aVar(X) |
| `\avarb{X}` | aVar[X] |
| `\avarc{X}` | aVar{X} |
| `\cov{X,Y}` | Cov(X,Y) |
| `\covb{X,Y}` | Cov[X,Y] |
| `\covc{X,Y}` | Cov{X,Y} |
| `\cor{X,Y}` | Cor(X,Y) |
| `\corb{X,Y}` | Cor[X,Y] |
| `\corc{X,Y}` | Cor{X,Y} |

## Conditional Expectation & Probability

These support `\given` inside the argument, which renders as `|` (or `\middle|` with `*`).

| Command | Example | Renders as |
|---------|---------|------------|
| `\CE{X \given Y}` | `\CE{X \given Y}` | E(X \| Y) |
| `\CEb{X \given Y}` | `\CEb{X \given Y}` | E[X \| Y] |
| `\LP{A \given B}` | `\LP{A \given B}` | P(A \| B) |
| `\LPb{A \given B}` | `\LPb{A \given B}` | P[A \| B] |
| `\Prob{A \given B}` | `\Prob{A \given B}` | Pr(A \| B) |

## Standalone Conditional

| Command | Expands to |
|---------|-----------|
| `\given` | `\,\|\,` (spaced bar, outside conditional commands) |
