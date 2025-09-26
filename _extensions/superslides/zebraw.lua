-- zebraw.lua - Filter for enhanced code blocks using zebraw package

local use_zebraw = false
local zebraw_font_size = "10pt"
local zebraw_comment_flag = "##"
local zebraw_comment_color = "blue"

-- Function to read metadata and check if zebraw is enabled
function Meta(meta)
  if quarto.doc.is_format("typst") then
    use_zebraw = meta['use-zebraw'] and meta['use-zebraw']

    -- Read zebraw configuration from YAML
    if meta['zebraw-font-size'] then
      zebraw_font_size = pandoc.utils.stringify(meta['zebraw-font-size']) .. "pt"
    end


    if meta['zebraw-comment-flag'] then
      zebraw_comment_flag = pandoc.utils.stringify(meta['zebraw-comment-flag'])
    end

    if meta['zebraw-comment-color'] then
      zebraw_comment_color = pandoc.utils.stringify(meta['zebraw-comment-color'])
    end

    if use_zebraw then
      quarto.log.output("Zebraw code blocks enabled with font-size: " .. zebraw_font_size)
    end
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

  -- Add comment font styling for mathematical annotations (use theme color)
  if not attr["comment-font-args"] and #highlight_parts > 0 then
    -- Format color properly for Typst
    local color_value = zebraw_comment_color
    if not string.match(color_value, "^rgb") then
      color_value = 'rgb("' .. color_value .. '")'
    end
    table.insert(options, 'comment-font-args: (fill: ' .. color_value .. ', style: "italic")')
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

-- Function to process code blocks when zebraw is enabled
function CodeBlock(el)
  if quarto.doc.is_format("typst") and use_zebraw then
    local code_content = el.text
    local language = el.classes[1] or ""

    -- Extract zebraw options from attributes
    local zebraw_options = extract_zebraw_options(el.attr.attributes)

    -- Build the zebraw code block
    local zebraw_code = "#zebraw("

    if zebraw_options ~= "" then
      zebraw_code = zebraw_code .. zebraw_options .. ",\n"
    end

    zebraw_code = zebraw_code .. "```" .. language .. "\n" .. code_content .. "\n```\n)"

    -- No wrapper needed - global show raw rule in typst-template.typ handles font size and line spacing

    return pandoc.RawBlock('typst', zebraw_code)
  end

  return el
end

-- Return the filter functions
return {
  { Meta = Meta },
  { CodeBlock = CodeBlock }
}