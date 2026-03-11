-- expand-macros.lua
-- Pre-quarto Lua filter that expands custom LaTeX commands from definition.tex
-- into primitive LaTeX that Pandoc's Typst writer understands.
-- Only active for Typst output.

--------------------------------------------------------------------
-- A. Simple substitutions (no arguments)
--------------------------------------------------------------------
local simple = {}

-- Real numbers, natural numbers
simple["\\R"] = "\\mathbb{R}"
simple["\\N"] = "\\mathbb{N}"

-- Calligraphic letters \calA..\calZ
for i = 0, 25 do
  local letter = string.char(65 + i)
  simple["\\cal" .. letter] = "\\mathcal{" .. letter .. "}"
end

-- Bold uppercase matrices \mA..\mZ
for i = 0, 25 do
  local letter = string.char(65 + i)
  simple["\\m" .. letter] = "\\mathbf{" .. letter .. "}"
end

-- Bold lowercase vectors \va..\vz
for i = 0, 25 do
  local letter = string.char(97 + i)
  simple["\\v" .. letter] = "\\mathbf{" .. letter .. "}"
end

-- Bold Greek vectors
local greek_letters = {
  "alpha", "beta", "gamma", "delta", "epsilon", "varepsilon",
  "zeta", "eta", "theta", "iota", "kappa", "lambda",
  "mu", "nu", "xi", "pi", "rho", "sigma",
  "tau", "upsilon", "phi", "chi", "psi", "omega"
}
for _, g in ipairs(greek_letters) do
  simple["\\v" .. g] = "\\boldsymbol{\\" .. g .. "}"
end

-- Special bold symbols
simple["\\mSigma"] = "\\boldsymbol{\\Sigma}"
simple["\\mtheta"] = "\\boldsymbol{\\theta}"
simple["\\vzero"] = "\\mathbf{0}"

-- Convergence symbols
simple["\\pto"] = "\\stackrel{p}{\\longrightarrow}"
simple["\\dto"] = "\\stackrel{d}{\\longrightarrow}"

-- IID, NID, asymptotic distribution
simple["\\simiid"] = "\\overset{\\text{iid}}{\\sim}"
simple["\\simnid"] = "\\overset{\\text{nid}}{\\sim}"
simple["\\sima"] = "\\overset{\\text{a}}{\\sim}"

-- Independence — use Unicode ⫫ (U+2AEB DOUBLE UP TACK) to avoid
-- broken \!\!\! negative-space expansion in Pandoc's Typst writer.
-- Use pandoc.utils.stringify-safe UTF-8 literal.
simple["\\indep"] = "⫫"
-- \nindep: U+2AEB + U+0338 (combining long solidus overlay)
simple["\\nindep"] = "⫫̸"

-- Summation shorthands
simple["\\sumin"] = "\\sum_{i=1}^{n}"
simple["\\sumg"] = "\\sum_{g=1}^{G}"

-- Misc operators
simple["\\vect"] = "\\mathrm{vec}"
simple["\\Normal"] = "\\mathcal{N}"
simple["\\Uniform"] = "\\mathcal{U}"
simple["\\boldone"] = "\\mathbb{1}"

-- Math operators (DeclareMathOperator equivalents)
simple["\\argmin"] = "\\operatorname*{arg\\,min}"
simple["\\argmax"] = "\\operatorname*{arg\\,max}"
simple["\\sign"] = "\\operatorname{sign}"
simple["\\trace"] = "\\operatorname{Tr}"
simple["\\determinant"] = "\\operatorname{det}"
simple["\\Real"] = "\\operatorname{Re}"
simple["\\Imag"] = "\\operatorname{Im}"
simple["\\nil"] = "\\operatorname{nil}"
simple["\\Dirichlet"] = "\\operatorname{Dir}"
simple["\\atantwo"] = "\\operatorname{atan2}"

-- \given standalone (when not inside a conditional command)
simple["\\given"] = "\\,|\\,"

-- \ped and \ap are handled in the operator section since they take arguments

--------------------------------------------------------------------
-- Helper: find matching closing brace for a { at position pos
--------------------------------------------------------------------
local function find_matching_brace(s, pos)
  if s:sub(pos, pos) ~= "{" then return nil end
  local depth = 0
  for i = pos, #s do
    local c = s:sub(i, i)
    if c == "{" then
      depth = depth + 1
    elseif c == "}" then
      depth = depth - 1
      if depth == 0 then
        return i
      end
    end
  end
  return nil
end

--------------------------------------------------------------------
-- B. Paired delimiter commands (one {arg}, optional *)
-- \cmd*{x} -> \left<open>x\right<close>
-- \cmd{x}  -> <open>x<close>
--------------------------------------------------------------------
local delimiters = {
  -- {command_name, open_nostar, close_nostar, open_star, close_star}
  {"\\paren",         "(",           ")",           "\\left(",        "\\right)"},
  {"\\brock",         "[",           "]",           "\\left[",        "\\right]"},
  {"\\curly",         "\\{",         "\\}",         "\\left\\{",      "\\right\\}"},
  {"\\norm",          "\\lVert ",    "\\rVert ",    "\\left\\lVert ", "\\right\\rVert "},
  {"\\abs",           "\\lvert ",    "\\rvert ",    "\\left\\lvert ", "\\right\\rvert "},
  {"\\anglebrackets", "\\langle ",   "\\rangle ",   "\\left\\langle ","\\right\\rangle "},
  {"\\ceil",          "\\lceil ",    "\\rceil ",    "\\left\\lceil ", "\\right\\rceil "},
  {"\\floor",         "\\lfloor ",   "\\rfloor ",   "\\left\\lfloor ","\\right\\rfloor "},
  {"\\card",          "|",           "|",           "\\left|",        "\\right|"},
}

--------------------------------------------------------------------
-- C. Operator+delimiter commands (prefix + delimiters, with \given)
-- \cmd*{x} -> <prefix>\left<open>x\right<close>
-- For conditional commands, \given inside the arg is replaced with \,\middle|\,
--------------------------------------------------------------------
local operators = {
  -- {cmd_name, prefix, open_nostar, close_nostar, open_star, close_star, has_given}
  {"\\E",     "\\mathbb{E}",                "(", ")", "\\left(", "\\right)", false},
  {"\\Eb",    "\\mathbb{E}",                "[", "]", "\\left[", "\\right]", false},
  {"\\Ec",    "\\mathbb{E}",                "\\{", "\\}", "\\left\\{", "\\right\\}", false},
  {"\\Ea",    "\\mathbb{E}",                "\\lvert ", "\\rvert ", "\\left\\lvert ", "\\right\\rvert ", false},
  {"\\var",   "\\mathbb{V}\\mathrm{ar}",    "(", ")", "\\left(", "\\right)", false},
  {"\\varb",  "\\mathbb{V}\\mathrm{ar}",    "[", "]", "\\left[", "\\right]", false},
  {"\\varc",  "\\mathbb{V}\\mathrm{ar}",    "\\{", "\\}", "\\left\\{", "\\right\\}", false},
  {"\\avar",  "a\\mathbb{V}\\mathrm{ar}",   "(", ")", "\\left(", "\\right)", false},
  {"\\avarb", "a\\mathbb{V}\\mathrm{ar}",   "[", "]", "\\left[", "\\right]", false},
  {"\\avarc", "a\\mathbb{V}\\mathrm{ar}",   "\\{", "\\}", "\\left\\{", "\\right\\}", false},
  {"\\cov",   "\\mathbb{C}\\mathrm{ov}",    "(", ")", "\\left(", "\\right)", false},
  {"\\covb",  "\\mathbb{C}\\mathrm{ov}",    "[", "]", "\\left[", "\\right]", false},
  {"\\covc",  "\\mathbb{C}\\mathrm{ov}",    "\\{", "\\}", "\\left\\{", "\\right\\}", false},
  {"\\cor",   "\\mathbb{C}\\mathrm{or}",    "(", ")", "\\left(", "\\right)", false},
  {"\\corb",  "\\mathbb{C}\\mathrm{or}",    "[", "]", "\\left[", "\\right]", false},
  {"\\corc",  "\\mathbb{C}\\mathrm{or}",    "\\{", "\\}", "\\left\\{", "\\right\\}", false},
  {"\\CE",    "\\mathbb{E}",                "(", ")", "\\left(", "\\right)", true},
  {"\\CEb",   "\\mathbb{E}",                "[", "]", "\\left[", "\\right]", true},
  {"\\LP",    "\\mathbb{P}",                "(", ")", "\\left(", "\\right)", true},
  {"\\LPb",   "\\mathbb{P}",                "[", "]", "\\left[", "\\right]", true},
  {"\\Prob",  "\\mathbb{P}\\mathrm{r}",     "(", ")", "\\left(", "\\right)", true},
}

--------------------------------------------------------------------
-- Build sorted command lists (longest first to avoid partial matches)
--------------------------------------------------------------------

-- Collect all simple command names, sorted longest first
local simple_keys = {}
for k, _ in pairs(simple) do
  table.insert(simple_keys, k)
end
table.sort(simple_keys, function(a, b) return #a > #b end)

-- Sort delimiter commands longest first
table.sort(delimiters, function(a, b) return #a[1] > #b[1] end)

-- Sort operator commands longest first
table.sort(operators, function(a, b) return #a[1] > #b[1] end)

--------------------------------------------------------------------
-- Escape a command name for use in Lua pattern matching
--------------------------------------------------------------------
local function escape_pattern(s)
  return s:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
end

--------------------------------------------------------------------
-- Check if character at position is a letter (would continue the cmd name)
--------------------------------------------------------------------
local function is_letter(s, pos)
  if pos > #s then return false end
  local c = s:byte(pos)
  return (c >= 65 and c <= 90) or (c >= 97 and c <= 122)
end

--------------------------------------------------------------------
-- Process operator/delimiter commands with {arg} and optional *
-- Returns the modified string and whether any replacement was made
--------------------------------------------------------------------
local function expand_operators(s)
  local changed = false

  for _, op in ipairs(operators) do
    local cmd = op[1]
    local prefix = op[2]
    local open_ns, close_ns = op[3], op[4]
    local open_s, close_s = op[5], op[6]
    local has_given = op[7]

    local pat = escape_pattern(cmd)
    local pos = 1

    while pos <= #s do
      local start_pos = s:find(pat, pos)
      if not start_pos then break end

      -- Make sure we're not matching a longer command
      -- e.g., \E should not match inside \Eb
      local after_cmd = start_pos + #cmd
      if is_letter(s, after_cmd) then
        pos = after_cmd
      else
        -- Check for star
        local starred = false
        local brace_start = after_cmd
        if s:sub(after_cmd, after_cmd) == "*" then
          starred = true
          brace_start = after_cmd + 1
        end

        -- Find the {arg}
        if s:sub(brace_start, brace_start) == "{" then
          local brace_end = find_matching_brace(s, brace_start)
          if brace_end then
            local arg = s:sub(brace_start + 1, brace_end - 1)

            -- Replace \given inside the arg for conditional commands
            if has_given then
              if starred then
                arg = arg:gsub("\\given", "\\,\\middle|\\,")
              else
                arg = arg:gsub("\\given", "\\,|\\,")
              end
            end

            local replacement
            if starred then
              replacement = prefix .. open_s .. arg .. close_s
            else
              replacement = prefix .. open_ns .. arg .. close_ns
            end

            s = s:sub(1, start_pos - 1) .. replacement .. s:sub(brace_end + 1)
            changed = true
            pos = start_pos + #replacement
          else
            pos = brace_start + 1
          end
        else
          -- No brace follows: this might be \Normal or similar used without args
          -- For operators like \Normal, \sign etc. that can appear without braces,
          -- we skip if no brace found
          pos = after_cmd
        end
      end
    end
  end

  -- Process delimiter commands
  for _, d in ipairs(delimiters) do
    local cmd = d[1]
    local open_ns, close_ns = d[2], d[3]
    local open_s, close_s = d[4], d[5]

    local pat = escape_pattern(cmd)
    local pos = 1

    while pos <= #s do
      local start_pos = s:find(pat, pos)
      if not start_pos then break end

      local after_cmd = start_pos + #cmd
      if is_letter(s, after_cmd) then
        pos = after_cmd
      else
        local starred = false
        local brace_start = after_cmd
        if s:sub(after_cmd, after_cmd) == "*" then
          starred = true
          brace_start = after_cmd + 1
        end

        if s:sub(brace_start, brace_start) == "{" then
          local brace_end = find_matching_brace(s, brace_start)
          if brace_end then
            local arg = s:sub(brace_start + 1, brace_end - 1)
            local replacement
            if starred then
              replacement = open_s .. arg .. close_s
            else
              replacement = open_ns .. arg .. close_ns
            end
            s = s:sub(1, start_pos - 1) .. replacement .. s:sub(brace_end + 1)
            changed = true
            pos = start_pos + #replacement
          else
            pos = brace_start + 1
          end
        else
          pos = after_cmd
        end
      end
    end
  end

  return s, changed
end

--------------------------------------------------------------------
-- Process simple substitutions
-- Returns the modified string and whether any replacement was made
--------------------------------------------------------------------
local function expand_simple(s)
  local changed = false

  for _, cmd in ipairs(simple_keys) do
    local pat = escape_pattern(cmd)
    local pos = 1

    while pos <= #s do
      local start_pos = s:find(pat, pos)
      if not start_pos then break end

      -- Ensure we don't match inside a longer command name
      local after_cmd = start_pos + #cmd
      if is_letter(s, after_cmd) then
        pos = after_cmd
      else
        local replacement = simple[cmd]
        s = s:sub(1, start_pos - 1) .. replacement .. s:sub(after_cmd)
        changed = true
        pos = start_pos + #replacement
      end
    end
  end

  return s, changed
end

--------------------------------------------------------------------
-- Handle \ped{arg} and \ap{arg}
--------------------------------------------------------------------
local function expand_ped_ap(s)
  local changed = false

  for _, cmd_info in ipairs({
    {"\\ped", "_{\\mathrm{", "}}"},
    {"\\ap",  "^{\\mathrm{", "}}"},
  }) do
    local cmd, open, close = cmd_info[1], cmd_info[2], cmd_info[3]
    local pat = escape_pattern(cmd)
    local pos = 1

    while pos <= #s do
      local start_pos = s:find(pat, pos)
      if not start_pos then break end

      local after_cmd = start_pos + #cmd
      if is_letter(s, after_cmd) then
        pos = after_cmd
      elseif s:sub(after_cmd, after_cmd) == "{" then
        local brace_end = find_matching_brace(s, after_cmd)
        if brace_end then
          local arg = s:sub(after_cmd + 1, brace_end - 1)
          local replacement = open .. arg .. close
          s = s:sub(1, start_pos - 1) .. replacement .. s:sub(brace_end + 1)
          changed = true
          pos = start_pos + #replacement
        else
          pos = after_cmd + 1
        end
      else
        pos = after_cmd
      end
    end
  end

  return s, changed
end

--------------------------------------------------------------------
-- Main expansion: iterate until no more custom commands remain
--------------------------------------------------------------------
local function expand_all(s)
  local max_iterations = 20  -- safety limit for nested commands
  for _ = 1, max_iterations do
    local changed = false
    local c1, c2, c3

    s, c1 = expand_operators(s)
    s, c2 = expand_simple(s)
    s, c3 = expand_ped_ap(s)

    changed = c1 or c2 or c3
    if not changed then break end
  end
  return s
end

--------------------------------------------------------------------
-- Pandoc filter: walk Math elements and expand macros
--------------------------------------------------------------------
function Math(el)
  if quarto == nil or not quarto.doc.is_format("typst") then
    return nil
  end

  local expanded = expand_all(el.text)
  if expanded ~= el.text then
    return pandoc.Math(el.mathtype, expanded)
  end
  return nil
end

return {{Math = Math}}
