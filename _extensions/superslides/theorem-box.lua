-- Theorem-box filter for Quarto
-- Converts ::: {.theorem} divs to Typst theorem function calls

-- Define the theorem environments we support
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

    if not theorem_type then
        return nil
    end

    print("DEBUG: Processing " .. theorem_type .. " div")
    print("DEBUG: Number of content elements: " .. #el.content)

    -- Extract title if present (from heading)
    local title, content = extractTitle(el.content)

    -- Start building the Typst output
    local blocks = pandoc.List()

    -- Create the theorem function call
    blocks:insert(pandoc.RawBlock('typst', '#' .. theorem_type .. '['))

    -- Add title if present as the first line
    if title then
        blocks:insert(pandoc.RawBlock('typst', '*' .. title .. '*'))
        blocks:insert(pandoc.RawBlock('typst', ''))
        blocks:insert(pandoc.RawBlock('typst', ''))
    end

    -- Process content
    if #content > 0 then
        -- Add content directly
        blocks:extend(content)
    end

    -- Close the theorem
    blocks:insert(pandoc.RawBlock('typst', ']'))

    return blocks
end

-- Return the filter
return {
    {
        Div = function(el)
            if quarto.doc.is_format("typst") then
                return processTheoremDiv(el)
            end
        end
    }
}