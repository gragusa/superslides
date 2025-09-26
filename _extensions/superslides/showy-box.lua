-- Add a test at the very beginning to confirm filter is running
-- print("DEBUG: SHOWYBOX FILTER LOADED AND RUNNING")

-- Showybox filter for Quarto

-- Helper function to properly format values for Typst
local function formatValue(value)
    print("DEBUG: formatValue input: '" .. value .. "'")
    
    -- Clean up escaped characters first
    local clean_value = value:gsub("\\%%", "%%"):gsub("\\%(", "("):gsub("\\%)", ")")
    
    -- Pattern: object.method(args) - already formatted
    if clean_value:match("^%s*([%a_][%w_]*)%.([%a_][%w_]*)%((.-)%)%s*$") then
        print("DEBUG: Already has parentheses: " .. clean_value)
        return clean_value
    end
    
    -- Pattern: object.methodNUM% - needs parentheses
    -- This is the tricky case: we need to separate method name from number
    local obj, method_and_num = clean_value:match("^%s*([%a_][%w_]*)%.([%a_][%w_]*%d+%%)%s*$")
    if obj and method_and_num then
        -- Now separate the method name from the number
        local method, num = method_and_num:match("^([%a_]+)(%d+%%)$")
        if method and num then
            local result = obj .. "." .. method .. "(" .. num .. ")"
            print("DEBUG: Converted " .. clean_value .. " to " .. result)
            return result
        end
    end
    
    -- Check if it's a number, measurement, command, or RGB expression
    if tonumber(clean_value) or
       clean_value:match("^%d+[%a]+$") or
       clean_value:match("^#") or
       clean_value:match("^rgb%b()") or                    -- rgb() functions
       clean_value:match("rgb%b\"\"%.") then               -- rgb("color").method() patterns
        print("DEBUG: Returning as-is: " .. clean_value)
        return clean_value
    -- Special case: known font weight values that need quoting
    elseif clean_value == "bold" or clean_value == "regular" or clean_value == "light" or
           clean_value == "medium" or clean_value == "thin" or clean_value == "black" then
        local quoted = '"' .. clean_value .. '"'
        print("DEBUG: Quoted font weight: " .. quoted)
        return quoted
    -- Check if it's a color name or other Typst identifier
    elseif clean_value:match("^[%a_][%w_]*$") then
        -- Common Typst color names don't need quoting
        if clean_value == "white" or clean_value == "black" or clean_value == "red" or
           clean_value == "green" or clean_value == "blue" or clean_value == "yellow" or
           clean_value == "purple" or clean_value == "orange" or clean_value == "gray" then
            print("DEBUG: Color name, returning as-is: " .. clean_value)
            return clean_value
        else
            -- Unknown identifier, quote it to be safe
            local quoted = '"' .. clean_value .. '"'
            print("DEBUG: Unknown identifier, quoted: " .. quoted)
            return quoted
        end
    else
        -- It's a string, quote it
        local quoted = '"' .. clean_value:gsub('"', '\\"') .. '"'
        print("DEBUG: Quoted string: " .. quoted)
        return quoted
    end
end

-- Helper function to parse attribute values into proper Typst format
local function parseAttributeValue(value)
    print("DEBUG: Parsing value: " .. tostring(value))
    
    -- Remove escaped characters from value
    value = value:gsub("\\%%", "%%")
    
    -- If the value contains key-value pairs, parse as dictionary
    if value:match("[^:]+:%s*[^,]+") then
        print("DEBUG: Detected dictionary format")
        local dict_items = {}
        
        -- Parse key-value pairs
        local items = {}
        local current = ""
        local parens = 0
        
        -- Split by comma but respect parentheses
        for i = 1, #value do
            local char = value:sub(i, i)
            if char == "(" then
                parens = parens + 1
            elseif char == ")" then
                parens = parens - 1
            elseif char == "," and parens == 0 then
                table.insert(items, current:match("^%s*(.-)%s*$"))
                current = ""
            else
                current = current .. char
            end
        end
        if current ~= "" then
            table.insert(items, current:match("^%s*(.-)%s*$"))
        end
        
        -- Parse each key-value pair
        for _, item in ipairs(items) do
            local key, val = item:match("([^:]+):%s*(.+)")
            if key and val then
                key = key:match("^%s*(.-)%s*$")
                val = val:match("^%s*(.-)%s*$")
                -- Convert dash to underscore in keys
                -- key = key:gsub("-", "_")
                table.insert(dict_items, "    " .. key .. ": " .. formatValue(val))
            end
        end
        
        -- Return as Typst dictionary
        return "(\n" .. table.concat(dict_items, ",\n") .. "\n  )"
    else
        -- Return simple value
        return formatValue(value)
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

-- Helper function to extract footer from content
local function extractFooter(content)
    local newContent = pandoc.List()
    local footer = nil
    
    for i, elem in ipairs(content) do
        print("DEBUG: Checking element " .. i .. " type: " .. elem.t)
        
        -- Check for footer div
        if elem.t == "Div" then
            print("DEBUG: Div classes: " .. table.concat(elem.classes, ", "))
            if elem.classes:includes("footer") then
                -- Found footer div, extract its content as string
                footer = pandoc.utils.stringify(elem.content)
                print("DEBUG: Found footer div: " .. footer)
                -- Don't add this div to the new content
            else
                -- Not a footer div, keep it
                newContent:insert(elem)
            end
        -- Check for footer in Para/Plain elements (could contain span with footer class)
        elseif elem.t == "Para" or elem.t == "Plain" then
            local hasFooter = false
            local newInlines = pandoc.List()
            
            -- Check each inline element in the paragraph
            for _, inline in ipairs(elem.content) do
                if inline.t == "Span" and inline.classes:includes("footer") then
                    -- Found footer span
                    footer = pandoc.utils.stringify(inline.content)
                    print("DEBUG: Found footer span: " .. footer)
                    hasFooter = true
                    -- Don't add this span to the new content
                else
                    newInlines:insert(inline)
                end
            end
            
            -- If the paragraph had non-footer content, keep it
            if #newInlines > 0 then
                if elem.t == "Para" then
                    newContent:insert(pandoc.Para(newInlines))
                else
                    newContent:insert(pandoc.Plain(newInlines))
                end
            elseif not hasFooter then
                -- No footer and no other content removed, keep original
                newContent:insert(elem)
            end
        else
            -- Not a div or para/plain, keep it
            newContent:insert(elem)
        end
    end
    
    return footer, newContent
end

-- Define presets for different box types (will be updated with custom colors)
local box_presets = {
    simplebox = {
        frame = "border-color: blue.lighten(80%), title-color: blue.lighten(30%), body-color: blue.lighten(96%), footer-color: blue.lighten(80%), thickness: 1pt"
    },
    warningbox = {
        frame = "border-color: red, title-color: red.lighten(30%), body-color: red.lighten(95%), thickness: 2pt",
        ["title-style"] = "color: white"
    },
    infobox = {
        frame = "border-color: green, title-color: green.lighten(30%), body-color: green.lighten(95%)",
        ["body-style"] = "color: green.darken(20%)"
    }
}

-- Function to update box presets with custom colors from metadata
local function updateBoxPresets(meta)
    if meta["simplebox-color"] then
        local color = pandoc.utils.stringify(meta["simplebox-color"])
        local baseColor = "rgb(\"" .. color .. "\")"
        box_presets.simplebox.frame = "border-color: " .. baseColor .. ".lighten(80%), title-color: " .. baseColor .. ".lighten(30%), body-color: " .. baseColor .. ".lighten(96%), footer-color: " .. baseColor .. ".lighten(80%), thickness: 1pt"
    end

    if meta["warningbox-color"] then
        local color = pandoc.utils.stringify(meta["warningbox-color"])
        local baseColor = "rgb(\"" .. color .. "\")"
        box_presets.warningbox.frame = "border-color: " .. baseColor .. ", title-color: " .. baseColor .. ".lighten(30%), body-color: " .. baseColor .. ".lighten(95%), thickness: 2pt"
    end

    if meta["infobox-color"] then
        local color = pandoc.utils.stringify(meta["infobox-color"])
        local baseColor = "rgb(\"" .. color .. "\")"
        box_presets.infobox.frame = "border-color: " .. baseColor .. ", title-color: " .. baseColor .. ".lighten(30%), body-color: " .. baseColor .. ".lighten(95%)"
        box_presets.infobox["body-style"] = "color: " .. baseColor .. ".darken(20%)"
    end
end

-- Main function to process showybox divs
local function processShowybox(el)
    -- Check for any of our box classes
    local box_type = nil
    if el.classes:includes("showy-box") then
        box_type = "showy-box"
    else
        -- Check for preset box types
        for preset_name, _ in pairs(box_presets) do
            if el.classes:includes(preset_name) then
                box_type = preset_name
                break
            end
        end
    end
    
    if not box_type then
        return nil
    end
    
    print("DEBUG: Processing " .. box_type .. " div")
    print("DEBUG: Number of content elements: " .. #el.content)
    
    -- Apply preset attributes if it's a preset box type
    if box_presets[box_type] then
        for attr_name, attr_value in pairs(box_presets[box_type]) do
            if not el.attributes[attr_name] then
                el.attributes[attr_name] = attr_value
                print("DEBUG: Applied preset attribute " .. attr_name .. " = " .. attr_value)
            end
        end
    end
    
    -- Extract title if present
    local title, content = extractTitle(el.content)
    
    -- Extract footer if present  
    local footer, content = extractFooter(content)
    
    -- Start building the Typst output
    local blocks = pandoc.List()
    blocks:insert(pandoc.RawBlock('typst', '#showybox('))
    
    -- List of valid attributes and their mappings
    local attribute_map = {
        ["footer"] = "footer",
        ["frame"] = "frame", 
        ["title-style"] = "title_style",
        ["body-style"] = "body_style",
        ["footer-style"] = "footer_style",
        ["sep"] = "sep",
        ["shadow"] = "shadow",
        ["width"] = "width",
        ["align"] = "align",
        ["breakable"] = "breakable",
        ["spacing"] = "spacing",
        ["above"] = "above",
        ["below"] = "below",
        ["thickness"] = "thickness",
        ["radius"] = "radius",
        ["dash"] = "dash"
    }
    
    -- Process attributes
    local attrs = {}
    
    -- Add title if present
    if title then
        table.insert(attrs, '  title: "' .. title:gsub('"', '\\"') .. '"')
    end
    
    for attr_name, typst_name in pairs(attribute_map) do
        local value = el.attributes[attr_name]
        if value then
            print("DEBUG: Found attribute " .. attr_name .. " = " .. value)
            -- Skip footer attribute if we have a footer element
            if attr_name == "footer" and footer then
                print("DEBUG: Skipping footer attribute because footer element exists")
            else
                local parsedValue = parseAttributeValue(value)
                table.insert(attrs, "  " .. typst_name .. ": " .. parsedValue)
            end
        end
    end
    
    -- Add footer from element if present (overrides attribute)
    if footer then
        print("DEBUG: Adding footer from element: " .. footer)
        table.insert(attrs, '  footer: "' .. footer:gsub('"', '\\"') .. '"')
    end
    
    -- Add attributes to output
    if #attrs > 0 then
        blocks:insert(pandoc.RawBlock('typst', table.concat(attrs, ",\n") .. ","))
    end
    
    -- Add the body content
    blocks:insert(pandoc.RawBlock('typst', ')['))
    
    -- Process content
    if #content > 0 then
        -- Add content directly
        blocks:extend(content)
    end
    
    -- Close the showybox
    blocks:insert(pandoc.RawBlock('typst', ']'))
    
    return blocks
end

-- Return the filter
return {
    {
        Meta = function(meta)
            updateBoxPresets(meta)
        end
    },
    {
        Div = function(el)
            if quarto.doc.is_format("typst") then
                return processShowybox(el)
            end
        end
    }
}
