function appendix()
    return pandoc.RawBlock('typst', '#show: appendix')
end

function pause()
    return pandoc.RawBlock('typst', '#pause')
end

function meanwhile()
    return pandoc.RawBlock('typst', '#meanwhile')
end

function v(args)
    return pandoc.RawBlock('typst', '#v(' .. args[1] .. ')')
end

function button(args, kwargs, meta)
    -- Extract the button text from first argument
    local text = "Button"
    local url = ""

    if args and #args > 0 and args[1] then
        if type(args[1]) == "string" and args[1] ~= "" then
            text = args[1]
        else
            local text_str = pandoc.utils.stringify(args[1])
            if text_str ~= "" then
                text = text_str
            end
        end
    end

    -- Get URL from kwargs - only if provided and not empty
    if kwargs and kwargs.url then
        local url_str = pandoc.utils.stringify(kwargs.url)
        if url_str ~= "" then
            url = url_str
        end
    end

    -- Generate button using the button function from template
    local button_code
    if url ~= "" then
        button_code = '#button("' .. text .. '", url: "' .. url .. '")'
    else
        button_code = '#button("' .. text .. '")'
    end

    return pandoc.RawInline('typst', button_code)
end

function qr(args, kwargs, meta)
    -- Extract arguments with proper defaults and validation
    local url = "https://example.com"  -- Default URL
    local width = "2cm"               -- Default width
    local title = ""                  -- No title by default

    -- Get URL from first argument
    if args and #args > 0 and args[1] then
        if type(args[1]) == "string" and args[1] ~= "" then
            url = args[1]
        else
            local url_str = pandoc.utils.stringify(args[1])
            if url_str ~= "" then
                url = url_str
            end
        end
    end

    -- Get width from kwargs - only if provided and not empty
    if kwargs and kwargs.width then
        local width_str = pandoc.utils.stringify(kwargs.width)
        if width_str ~= "" then
            width = width_str
        end
    end

    -- Get title from kwargs - only if provided and not empty
    if kwargs and kwargs.title then
        local title_str = pandoc.utils.stringify(kwargs.title)
        if title_str ~= "" then
            title = title_str
        end
    end

    -- Build QR code with proper syntax
    local qr_code = '#qr-code("' .. url .. '", width: ' .. width .. ')'

    -- Add title if provided
    if title ~= "" then
        qr_code = qr_code .. '\n#v(-0.2em)\n#text(size: 0.7em, fill: rgb("107895"))[' .. title .. ']'
    end

    return pandoc.RawBlock('typst', qr_code)
end