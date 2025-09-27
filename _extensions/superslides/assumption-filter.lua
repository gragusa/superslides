-- Assumption filter for Quarto
-- Converts assumption figures back to theorem calls

quarto.log.output("LOADING: assumption-filter.lua")

-- Simple post-processor to handle assumptions after Pandoc processing
local function post_process_typst(doc)
    if not quarto.doc.is_format("typst") then
        return doc
    end

    quarto.log.output("DEBUG: Post-processing document for assumptions")

    -- We'll use a document walker to find and replace assumption figures
    local function replace_assumption_figures(el)
        if el.t == "RawBlock" and el.format == "typst" then
            -- Look for assumption figures in the raw Typst content
            local text = el.text
            if text:match("quarto%-float%-ass") then
                quarto.log.output("DEBUG: Found assumption figure in raw block")
                quarto.log.output("DEBUG: Original text: " .. text:sub(1, 300))

                -- Replace assumption figures with theorem calls
                local converted = text:gsub(
                    "#figure%(%[\n?=== ([^\n]+)\n<[^>]+>\n%], caption: figure%.caption%(\nposition: [^,]+, \n%[\n([^%]]+)\n%]%), \nkind: \"quarto%-float%-ass\", \nsupplement: \"Assumption\", \n%)\n<([^>]+)>",
                    function(title, caption, label)
                        quarto.log.output("DEBUG: Converting assumption - Title: " .. title .. ", Label: " .. label)
                        return "#assumption[*" .. title .. "*\n\n" .. caption .. "] <" .. label .. ">"
                    end
                )

                if converted ~= text then
                    quarto.log.output("DEBUG: Successfully converted assumption!")
                    return pandoc.RawBlock('typst', converted)
                end
            end
        end
        return el
    end

    return doc:walk({
        RawBlock = replace_assumption_figures
    })
end

-- Return the filter
return {
    { Pandoc = post_process_typst }
}