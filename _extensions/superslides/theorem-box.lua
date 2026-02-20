-- Theorem-box filter for Quarto
-- Converts ::: {.theorem} divs to Typst theorem function calls
-- Supports both theorion (default) and ctheorems packages

-- Define the theorem environments we support (class-based)
local theorem_environments = {
  "theorem",
  "proposition",
  "lemma",
  "corollary",
  "conjecture",
  "definition",
  "example",
  "exercise",
  "assumption",
  "remark",
  "proof"
}

-- Quarto cross-reference ID prefixes mapped to theorem types
-- See: https://quarto.org/docs/authoring/cross-references.html#theorems-and-proofs
local id_prefix_map = {
  ["thm"] = "theorem",
  ["lem"] = "lemma",
  ["cor"] = "corollary",
  ["prp"] = "proposition",
  ["cnj"] = "conjecture",
  ["def"] = "definition",
  ["exm"] = "example",
  ["exr"] = "exercise",
  ["sol"] = "solution",
  ["rem"] = "remark",
  ["asm"] = "assumption"
}

-- Detect theorem package from document metadata
local theorem_package = "theorion"  -- default

local function readMeta(meta)
    if meta["theorem-package"] then
        theorem_package = pandoc.utils.stringify(meta["theorem-package"])
    end
end

-- Helper function to extract title from content
local function extractTitle(content)
    if #content > 0 and content[1].t == "Header" then
        local header = content[1]
        local title = pandoc.utils.stringify(header.content)
        -- Remove the header from content
        local newContent = pandoc.List()
        for i = 2, #content do
            newContent:insert(content[i])
        end
        return title, newContent
    end
    return nil, content
end

-- Helper function to get theorem type from ID prefix (e.g., "exr-one" -> "exercise")
local function getTheoremTypeFromId(identifier)
    if not identifier or identifier == "" then
        return nil
    end
    -- Extract prefix before first hyphen
    local prefix = identifier:match("^([^-]+)")
    if prefix and id_prefix_map[prefix] then
        return id_prefix_map[prefix]
    end
    return nil
end

-- Main function to process theorem divs
local function processTheoremDiv(el)
    -- Check if this div has one of our theorem classes
    local theorem_type = nil
    for _, env in ipairs(theorem_environments) do
        if el.classes:includes(env) then
            theorem_type = env
            break
        end
    end

    -- If not found by class, try to detect from ID prefix (Quarto cross-ref style)
    if not theorem_type then
        theorem_type = getTheoremTypeFromId(el.identifier)
    end

    if not theorem_type then
        return nil
    end

    -- Extract title if present (from heading)
    local title, content = extractTitle(el.content)

    -- Get label from div identifier
    local label = el.identifier and el.identifier ~= "" and el.identifier or nil

    -- Start building the Typst output
    local blocks = pandoc.List()

    -- Create the theorem function call with title as parameter
    -- ctheorems uses positional title: #theorem("Title")[content]
    -- theorion uses named title:      #theorem(title: "Title")[content]
    if title then
        if theorem_package == "ctheorems" then
            blocks:insert(pandoc.RawBlock('typst', '#' .. theorem_type .. '("' .. title .. '")['))
        else
            blocks:insert(pandoc.RawBlock('typst', '#' .. theorem_type .. '(title: "' .. title .. '")['))
        end
    else
        blocks:insert(pandoc.RawBlock('typst', '#' .. theorem_type .. '['))
    end

    -- Process content
    if #content > 0 then
        -- Add content directly
        blocks:extend(content)
    end

    -- Close the theorem with label if present
    if label then
        blocks:insert(pandoc.RawBlock('typst', '] <' .. label .. '>'))
    else
        blocks:insert(pandoc.RawBlock('typst', ']'))
    end

    return blocks
end

-- Return the filter
return {
    {
        Meta = readMeta
    },
    {
        Div = function(el)
            if quarto.doc.is_format("typst") then
                return processTheoremDiv(el)
            end
        end
    }
}