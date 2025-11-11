-- columns.lua
-- Filter to handle column layouts in Typst slides
-- Converts Quarto column divs to Typst grid structures
-- Supports background colors via bg="#hexcolor" attribute or bg="variable-name"

-- Store metadata for variable resolution
local metadata = {}

-- Capture metadata from document
local function readMetadata(meta)
  metadata = meta
end

-- Resolve color value - either direct hex or variable reference
local function resolveColor(color_value)
  if not color_value then
    return nil
  end

  -- If it starts with #, treat as direct hex color
  if color_value:match("^#") then
    return color_value
  end

  -- Otherwise, try to resolve as variable from metadata
  local var_value = metadata[color_value]
  if var_value then
    return pandoc.utils.stringify(var_value)
  end

  -- If not found in metadata, return original value
  return color_value
end

-- Process divs with .columns class and nested .column divs
local function processColumns(el)
  if not quarto.doc.is_format("typst") then
    return nil
  end

  if not el.classes:includes("columns") then
    return nil
  end

  -- Extract attributes from outer .columns div
  local align_outer = el.attributes["align"]
  local total_width = el.attributes["totalwidth"]

  -- Arrays to store column data
  local column_fractions = {}
  local column_contents = {}
  local column_aligns = {}

  -- Process each child div looking for .column class
  for _, block in ipairs(el.content) do
    if block.t == "Div" and block.classes:includes("column") then
      -- Extract width attribute
      local width = block.attributes["width"]
      local fraction = "auto"

      if width then
        -- Convert percentage to fraction notation (e.g., "40%" -> "40fr")
        local percentage = tonumber(width:match("^(%d+)%%$"))
        if percentage then
          fraction = tostring(percentage) .. "fr"
        else
          -- Keep other units as-is (e.g., "20em", "5cm")
          fraction = width
        end
      end

      table.insert(column_fractions, fraction)

      -- Extract alignment for this column
      local align_inner = block.attributes["align"] or "left"
      table.insert(column_aligns, align_inner)

      -- Extract background color if specified
      local bg_color = block.attributes["bg"]

      -- Convert column content to Typst
      local content = pandoc.write(pandoc.Pandoc(block.content), "typst")
      -- Trim trailing whitespace
      content = content:gsub("%s+$", "")

      -- Apply background color if specified
      if bg_color then
        -- Resolve color (supports both hex colors and variable references)
        local resolved_color = resolveColor(bg_color)
        -- Wrap content in a block with fill color
        content = "#block(fill: rgb(\"" .. resolved_color .. "\"), width: 100%, inset: 0.5em, radius: 0pt)[" .. content .. "]"
      end

      -- Wrap content in brackets for Typst
      table.insert(column_contents, "[" .. content .. "]")
    end
  end

  -- If no columns found, return nil (no transformation)
  if #column_fractions == 0 then
    return nil
  end

  -- Build the Typst grid structure
  local grid_parts = {}
  table.insert(grid_parts, "#grid(")
  table.insert(grid_parts, "  columns: (" .. table.concat(column_fractions, ", ") .. "),")
  table.insert(grid_parts, "  gutter: 1em,")
  table.insert(grid_parts, "  align: (" .. table.concat(column_aligns, ", ") .. "),")
  table.insert(grid_parts, "  " .. table.concat(column_contents, ",\n  "))
  table.insert(grid_parts, ")")

  local result = table.concat(grid_parts, "\n")

  -- Apply optional outer wrappers

  -- Wrap with #block if totalwidth is specified
  if total_width and total_width ~= "textwidth" then
    result = "#block(width: " .. total_width .. ")[\n" .. result .. "\n]"
  end

  -- Wrap with #align if outer alignment is specified
  if align_outer then
    result = "#align(" .. align_outer .. ")[\n" .. result .. "\n]"
  end

  -- Return as a Typst raw block
  return { pandoc.RawBlock("typst", result) }
end

-- Return the filter with two passes:
-- First pass: capture metadata
-- Second pass: process column divs
return {
  { Meta = readMetadata },
  { Div = processColumns }
}
