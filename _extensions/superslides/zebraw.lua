-- zebraw.lua - Filter for enhanced code blocks using zebraw package

local use_zebraw = false
local zebraw_font_size = "10pt"
local zebraw_comment_flag = "##"
local zebraw_comment_color = "blue"
local zebraw_comment_style = "italic"
local zebraw_numbering = true
local zebraw_highlight_color = "luma(245)"
local zebraw_background_color = "luma(245)"
local zebraw_lang = "true"  -- true/false or custom string
local zebraw_lang_color = nil  -- nil means use default (superslides-primary)
local zebraw_lang_font_args = nil  -- nil means use default (fill: white, weight: "bold")

local function get_option(meta, key)
  if meta[key] ~= nil then
    return meta[key]
  end
  if meta.format and meta.format["superslides-typst"] and meta.format["superslides-typst"][key] ~= nil then
    return meta.format["superslides-typst"][key]
  end
  return nil
end

local function meta_to_bool(value)
  if value == nil then
    return nil
  end
  if type(value) == "boolean" then
    return value
  end
  local str = pandoc.utils.stringify(value)
  if str == "true" then
    return true
  elseif str == "false" then
    return false
  end
  return nil
end

-- Helper function to replace smart/curly quotes with straight quotes
-- Pandoc converts "..." to \u201c...\u201d before Lua sees the string
local function straighten_quotes(str)
  if not str then return str end
  str = str:gsub("\u{201c}", '"')  -- left double
  str = str:gsub("\u{201d}", '"')  -- right double
  str = str:gsub("\u{2018}", "'")  -- left single
  str = str:gsub("\u{2019}", "'")  -- right single
  return str
end

-- Function to read metadata and check if zebraw is enabled
function Meta(meta)
  if quarto.doc.is_format("typst") then
    local use_zebraw_meta = get_option(meta, 'use-zebraw')
    local use_zebraw_value = meta_to_bool(use_zebraw_meta)
    if use_zebraw_value ~= nil then
      use_zebraw = use_zebraw_value
    end

    -- Read zebraw configuration from YAML
    local zebraw_font_size_meta = get_option(meta, 'zebraw-font-size')
    if zebraw_font_size_meta then
      local val_str = pandoc.utils.stringify(zebraw_font_size_meta)
      -- Add 'pt' suffix if not present
      if not string.match(val_str, "pt$") and not string.match(val_str, "em$") then
        val_str = val_str .. "pt"
      end
      zebraw_font_size = val_str
    end

    local zebraw_comment_flag_meta = get_option(meta, 'zebraw-comment-flag')
    if zebraw_comment_flag_meta then
      zebraw_comment_flag = straighten_quotes(pandoc.utils.stringify(zebraw_comment_flag_meta))
    end

    local zebraw_comment_color_meta = get_option(meta, 'zebraw-comment-color')
    if zebraw_comment_color_meta then
      zebraw_comment_color = pandoc.utils.stringify(zebraw_comment_color_meta)
    end

    local zebraw_comment_style_meta = get_option(meta, 'zebraw-comment-style')
    if zebraw_comment_style_meta then
      zebraw_comment_style = straighten_quotes(pandoc.utils.stringify(zebraw_comment_style_meta))
    end

    local zebraw_numbering_meta = get_option(meta, 'zebraw-numbering')
    local zebraw_numbering_value = meta_to_bool(zebraw_numbering_meta)
    if zebraw_numbering_value ~= nil then
      zebraw_numbering = zebraw_numbering_value
    end

    local zebraw_highlight_color_meta = get_option(meta, 'zebraw-highlight-color')
    if zebraw_highlight_color_meta then
      zebraw_highlight_color = pandoc.utils.stringify(zebraw_highlight_color_meta)
    end

    local zebraw_background_color_meta = get_option(meta, 'zebraw-background-color')
    if zebraw_background_color_meta then
      zebraw_background_color = pandoc.utils.stringify(zebraw_background_color_meta)
    end

    local zebraw_lang_meta = get_option(meta, 'zebraw-lang')
    if zebraw_lang_meta then
      zebraw_lang = pandoc.utils.stringify(zebraw_lang_meta)
    end

    local zebraw_lang_color_meta = get_option(meta, 'zebraw-lang-color')
    if zebraw_lang_color_meta then
      zebraw_lang_color = pandoc.utils.stringify(zebraw_lang_color_meta)
    end

    local zebraw_lang_font_args_meta = get_option(meta, 'zebraw-lang-font-args')
    if zebraw_lang_font_args_meta then
      zebraw_lang_font_args = straighten_quotes(pandoc.utils.stringify(zebraw_lang_font_args_meta))
    end

    if use_zebraw then
      quarto.log.output("Zebraw code blocks enabled with font-size: " .. zebraw_font_size)
    end
  end
end

-- Helper function to escape special characters for Typst content brackets [...]
local function escape_typst_content(str)
  if not str then return str end
  str = str:gsub("#", "\\#")
  str = str:gsub("<", "\\<")
  str = str:gsub("@", "\\@")
  str = str:gsub("%$", "\\$")
  return str
end

-- Helper function to escape special characters for Typst strings
local function escape_typst_string(str)
  if not str then return str end
  -- Escape backslashes first (must be done before other escapes)
  str = str:gsub("\\", "\\\\")
  -- Escape double quotes
  str = str:gsub('"', '\\"')
  -- Escape special characters that have meaning in Typst
  str = str:gsub("#", "\\#")  -- Hash for comments/functions
  str = str:gsub("%$", "\\$")  -- Dollar for math mode
  str = str:gsub("@", "\\@")  -- At symbol for references
  str = str:gsub("<", "\\<")  -- Less than for markup
  str = str:gsub(">", "\\>")  -- Greater than for markup
  str = str:gsub("%[", "\\[")  -- Left bracket
  str = str:gsub("%]", "\\]")  -- Right bracket
  str = str:gsub("{", "\\{")  -- Left brace
  str = str:gsub("}", "\\}")  -- Right brace
  return str
end

-- Helper function to detect inline comments in code and extract them
local function extract_inline_comments(code_content, comment_flag)
  local lines = {}
  local highlight_parts = {}

  -- Split code into lines
  for line in code_content:gmatch("[^\r\n]*") do
    table.insert(lines, line)
  end

  -- Look for comment flag patterns in each line
  for line_num, line in ipairs(lines) do
    local comment_pos = line:find(comment_flag, 1, true)
    if comment_pos then
      -- Extract comment text after the flag
      local comment_text = line:sub(comment_pos + #comment_flag):gsub("^%s+", "")
      if comment_text ~= "" then
        table.insert(highlight_parts, "(" .. line_num .. ", [" .. escape_typst_content(comment_text) .. "])")
      end
    end
  end

  return highlight_parts
end

-- Helper function to clean code content by removing inline comments
local function clean_code_content(code_content, comment_flag)
  local lines = {}
  local cleaned_lines = {}

  -- Split code into lines
  for line in code_content:gmatch("[^\r\n]*") do
    table.insert(lines, line)
  end

  -- Clean each line by removing comment flag and everything after it
  for _, line in ipairs(lines) do
    local comment_pos = line:find(comment_flag, 1, true)
    if comment_pos then
      -- Remove comment flag and everything after it, but keep trailing whitespace structure
      local clean_line = line:sub(1, comment_pos - 1):gsub("%s+$", "")
      table.insert(cleaned_lines, clean_line)
    else
      -- Keep line as-is if no comment flag
      table.insert(cleaned_lines, line)
    end
  end

  return table.concat(cleaned_lines, "\n")
end

-- Helper function to process color values
local function process_color(color_str)
  if color_str:match("^#%x%x%x%x%x%x$") then
    -- Hex color: wrap with rgb()
    return 'rgb("' .. color_str .. '")'
  elseif color_str:match("^luma%(") or color_str:match("^rgb%(") or color_str:match("^color%.") then
    -- Typst function: use as-is
    return color_str
  else
    -- Assume it's a literal color name or other valid Typst color
    return color_str
  end
end

-- Helper function to build lang-related zebraw options
local function build_lang_options(options)
  -- Lang: true/false or custom string
  if zebraw_lang == "true" then
    table.insert(options, "lang: true")
  elseif zebraw_lang == "false" then
    table.insert(options, "lang: false")
  else
    table.insert(options, 'lang: [' .. zebraw_lang .. ']')
  end

  -- Lang color: default to superslides-primary (Typst variable)
  if zebraw_lang_color then
    table.insert(options, 'lang-color: ' .. process_color(zebraw_lang_color))
  else
    table.insert(options, 'lang-color: superslides-primary')
  end

  -- Lang font args: default to white bold
  if zebraw_lang_font_args then
    table.insert(options, 'lang-font-args: ' .. zebraw_lang_font_args)
  else
    table.insert(options, 'lang-font-args: (fill: white, weight: "bold")')
  end
end

-- Helper function to extract zebraw options from attributes
local function extract_zebraw_options(attr)
  local options = {}

  -- Handle highlight-lines and zebraw-comments (they both use highlight-lines)
  local highlight_parts = {}

  -- First, check for zebraw-comments (takes priority)
  if attr["zebraw-comments"] then
    -- Parse comment annotations in format: "2:[Math formula], 4:[Another comment]"
    local comments = attr["zebraw-comments"]
    for line_num, comment in comments:gmatch("(%d+):%[([^%]]+)%]") do
      table.insert(highlight_parts, "(" .. line_num .. ", [" .. comment .. "])")
    end
  elseif attr["highlight-lines"] then
    -- Only use simple highlight-lines if no zebraw-comments
    local lines = attr["highlight-lines"]
    -- Convert comma-separated string to array format
    if string.match(lines, ",") then
      local line_array = "(" .. lines .. ")"
      table.insert(options, "highlight-lines: " .. line_array)
    else
      table.insert(options, "highlight-lines: " .. lines)
    end
  end

  -- Add zebraw-comments highlight-lines if we have them
  if #highlight_parts > 0 then
    table.insert(options, "highlight-lines: (" .. table.concat(highlight_parts, ", ") .. ")")
  end

  -- Line numbering
  if attr["numbering"] then
    local numbering = attr["numbering"]
    if numbering == "true" or numbering == "false" then
      table.insert(options, "numbering: " .. numbering)
    else
      table.insert(options, "numbering: " .. numbering)
    end
  else
    -- Default to true for zebraw
    table.insert(options, "numbering: true")
  end

  -- Add default zebraw styling options for better appearance
  -- Reduce padding to make code blocks more compact
  if not attr["inset"] then
    table.insert(options, "inset: (top: 2pt, bottom: 2pt)")  -- Further reduce vertical spacing
  end

  -- Note: zebraw doesn't support text-style parameter for line spacing control

  -- Note: zebraw doesn't have direct line spacing control
  -- Line spacing is controlled through the text-style parameter

  -- Note: zebraw doesn't have a direct font size parameter
  -- Font size is controlled by wrapping zebraw with Typst text styling

  -- Add comment flag for mathematical annotations (use theme default or user override)
  if not attr["comment-flag"] and #highlight_parts > 0 then
    table.insert(options, 'comment-flag: "' .. zebraw_comment_flag .. '"')
  end

  -- Add comment font styling for mathematical annotations (use same color as code)
  if not attr["comment-font-args"] and #highlight_parts > 0 then
    -- Use default text color (same as code) instead of custom color
    table.insert(options, 'comment-font-args: (style: "italic")')
  end

  -- Line range
  if attr["line-range"] then
    -- Handle range format like "5..8"
    local range_str = attr["line-range"]
    if string.match(range_str, "%.%.") then
      -- Convert "5..8" to "(5, 8)"
      local start_line, end_line = range_str:match("(%d+)%.%.(%d+)")
      if start_line and end_line then
        table.insert(options, "line-range: (" .. start_line .. ", " .. end_line .. ")")
      end
    else
      table.insert(options, "line-range: " .. range_str)
    end
  end

  -- Language display
  if attr["lang"] then
    if attr["lang"] == "true" or attr["lang"] == "false" then
      table.insert(options, "lang: " .. attr["lang"])
    else
      table.insert(options, 'lang: "' .. attr["lang"] .. '"')
    end
  end

  -- Indentation guides
  if attr["indentation"] then
    table.insert(options, "indentation: " .. attr["indentation"])
  end

  -- Custom inset/padding
  if attr["inset"] then
    table.insert(options, "inset: " .. attr["inset"])
  end

  return table.concat(options, ", ")
end

-- Helper function to process YAML-style zebraw comments
local function process_yaml_comments(yaml_comments)
  local highlight_parts = {}

  if yaml_comments then
    -- Handle YAML list format from cell metadata
    if type(yaml_comments) == "table" then
      for _, comment in ipairs(yaml_comments) do
        local comment_str = pandoc.utils.stringify(comment)
        -- Parse "line_num:comment text" format
        local line_num, comment_text = comment_str:match("^(%d+):(.+)$")
        if line_num and comment_text then
          comment_text = comment_text:gsub("^%s+", "") -- trim leading spaces
          table.insert(highlight_parts, "(" .. line_num .. ", [" .. escape_typst_content(comment_text) .. "])")
        end
      end
    else
      -- Handle string format as fallback: "1:comment, 2:another comment"
      local comment_str = pandoc.utils.stringify(yaml_comments)
      for line_comment in comment_str:gmatch("([^,]+)") do
        line_comment = line_comment:gsub("^%s+", ""):gsub("%s+$", "") -- trim whitespace
        local line_num, comment_text = line_comment:match("^(%d+):(.+)$")
        if line_num and comment_text then
          comment_text = comment_text:gsub("^%s+", "") -- trim leading spaces
          table.insert(highlight_parts, "(" .. line_num .. ", [" .. escape_typst_content(comment_text) .. "])")
        end
      end
    end
  end

  return highlight_parts
end

-- Function to process code blocks when zebraw is enabled
function CodeBlock(el)
  if quarto.doc.is_format("typst") and use_zebraw then
    local code_content = el.text
    local language = el.classes[1] or ""

    -- Check for inline comments in the code
    local inline_highlight_parts = extract_inline_comments(code_content, zebraw_comment_flag)
    local has_inline_comments = #inline_highlight_parts > 0

    -- Check for zebraw-comment attribute (cell metadata) as fallback
    local yaml_comments = el.attr.attributes["zebraw-comment"]
    local has_yaml_comments = yaml_comments ~= nil

    -- Build zebraw options using YAML configuration
    local options = {}

    -- Numbering
    if zebraw_numbering then
      table.insert(options, "numbering: true")
    else
      table.insert(options, "numbering: false")
    end

    -- Comment styling
    table.insert(options, 'comment-font-args: (style: "' .. zebraw_comment_style .. '")')

    -- Colors
    table.insert(options, 'comment-color: ' .. process_color(zebraw_comment_color))
    table.insert(options, 'highlight-color: ' .. process_color(zebraw_highlight_color))
    table.insert(options, 'background-color: (' .. process_color(zebraw_background_color) .. ', ' .. process_color(zebraw_background_color) .. ')')

    -- Comment flag (use as-is, no escaping needed for comment-flag parameter)
    table.insert(options, 'comment-flag: "' .. zebraw_comment_flag .. '"')

    -- Language tab
    build_lang_options(options)

    -- Handle comments
    if has_inline_comments then
      table.insert(options, "highlight-lines: (" .. table.concat(inline_highlight_parts, ", ") .. ")")
    elseif has_yaml_comments then
      -- Process YAML-style comments from cell metadata
      local yaml_highlight_parts = process_yaml_comments(yaml_comments)
      if #yaml_highlight_parts > 0 then
        table.insert(options, "highlight-lines: (" .. table.concat(yaml_highlight_parts, ", ") .. ")")
      end
    end

    -- Extract other zebraw options from attributes (but skip conflicting ones)
    local additional_options = extract_zebraw_options(el.attr.attributes)
    if additional_options ~= "" then
      -- Only add non-conflicting options
      if not additional_options:match("numbering:") and
         not additional_options:match("comment%-font%-args:") and
         not additional_options:match("comment%-color:") and
         not additional_options:match("highlight%-color:") and
         not additional_options:match("background%-color:") and
         not additional_options:match("comment%-flag:") then
        table.insert(options, additional_options)
      end
    end

    -- Use cleaned code content if we have inline comments
    local final_code_content = code_content
    if has_inline_comments then
      final_code_content = clean_code_content(code_content, zebraw_comment_flag)
    end

    -- Build the zebraw code block
    local zebraw_code = "#{\nset text(size: " .. zebraw_font_size .. ")\n"
    zebraw_code = zebraw_code .. "zebraw(" .. table.concat(options, ", ") .. ",\n"
    zebraw_code = zebraw_code .. "```" .. language .. "\n" .. final_code_content .. "\n```\n)\n}"

    return pandoc.RawBlock('typst', zebraw_code)
  end

  return el
end

-- Function to process Div blocks for zebraw comments
function Div(el)
  if quarto.doc.is_format("typst") and use_zebraw then

    -- Check if this div has zebraw-comments class
    if el.classes:includes("zebraw-comments") then
      -- Find the code block and collect comment text
      local code_block = nil
      local comment_lines = {}

      for i, block in ipairs(el.content) do
        if block.t == "CodeBlock" then
          code_block = block
        elseif block.t == "RawBlock" then
          -- Check if this is already a zebraw block that we should skip
          if not block.text:match("#zebraw") then
            -- Treat as a code block if it's not already processed
            code_block = block
          end
        elseif block.t == "Para" then
          -- Extract comment lines from paragraph content
          local text = pandoc.utils.stringify(block)

          -- The comments are all in one line, separated by number patterns
          -- Pattern: "1:comment text 2:another comment 3:third comment"
          -- We need to split on the pattern where a number follows a space

          -- Use a simpler regex approach to split on \s+\d+: pattern
          local parts = {}
          local current_pos = 1

          while true do
            local next_pos = text:find("%s+%d+:", current_pos + 1)
            if not next_pos then
              -- Add the rest of the text as the last part
              if current_pos <= #text then
                local part = text:sub(current_pos):gsub("^%s+", ""):gsub("%s+$", "")
                if part:match("^%d+:") then
                  table.insert(parts, part)
                end
              end
              break
            else
              -- Add the current part
              local part = text:sub(current_pos, next_pos - 1):gsub("^%s+", ""):gsub("%s+$", "")
              if part:match("^%d+:") then
                table.insert(parts, part)
              end
              current_pos = next_pos
            end
          end

          -- Add all parts to comment_lines
          for _, part in ipairs(parts) do
            table.insert(comment_lines, part)
          end
        end
      end

      if code_block then
        local code_content = code_block.text
        local language = code_block.classes[1] or ""

        -- Process comment lines into highlight parts
        local highlight_parts = {}
        for _, comment_line in ipairs(comment_lines) do
          local line_num, comment_text = comment_line:match("^(%d+):(.+)$")
          if line_num and comment_text then
            comment_text = comment_text:gsub("^%s+", "") -- trim leading spaces
            table.insert(highlight_parts, "(" .. line_num .. ", [" .. escape_typst_content(comment_text) .. "])")
          end
        end


        -- Build zebraw options using same comprehensive set as inline comments
        local options = {}

        -- Numbering
        if zebraw_numbering then
          table.insert(options, "numbering: true")
        else
          table.insert(options, "numbering: false")
        end

        -- Comment styling
        table.insert(options, 'comment-font-args: (style: "' .. zebraw_comment_style .. '")')

        -- Colors
        table.insert(options, 'comment-color: ' .. process_color(zebraw_comment_color))
        table.insert(options, 'highlight-color: ' .. process_color(zebraw_highlight_color))
        table.insert(options, 'background-color: (' .. process_color(zebraw_background_color) .. ', ' .. process_color(zebraw_background_color) .. ')')

        -- Comment flag
        table.insert(options, 'comment-flag: "' .. zebraw_comment_flag .. '"')

        -- Language tab
        build_lang_options(options)

        if #highlight_parts > 0 then
          table.insert(options, "highlight-lines: (" .. table.concat(highlight_parts, ", ") .. ")")
        end

        -- Build the zebraw code block
        local zebraw_code = "#{\nset text(size: " .. zebraw_font_size .. ")\n"
        zebraw_code = zebraw_code .. "zebraw(" .. table.concat(options, ", ") .. ",\n"
        zebraw_code = zebraw_code .. "```" .. language .. "\n" .. code_content .. "\n```\n)\n}"

        return pandoc.RawBlock('typst', zebraw_code)
      end
    end
  end

  return el
end

-- Return the filter functions
return {
  { Meta = Meta },
  { Div = Div },    -- Process Div blocks first to handle zebraw-comments
  { CodeBlock = CodeBlock }
}
