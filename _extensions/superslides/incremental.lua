function Div(el)
  if quarto.doc.is_format("typst") and el.classes:includes("incremental") then
    local blocks = {}

    for i, item in ipairs(el.content) do
      if item.t == "BulletList" or item.t == "OrderedList" then
        -- Convert the list to individual items with pauses
        for j, list_item in ipairs(item.content) do
          -- Add the list item marker and content
          local item_content = {}

          -- Add bullet/number marker
          if item.t == "BulletList" then
            table.insert(item_content, pandoc.RawInline('typst', '- '))
          else
            table.insert(item_content, pandoc.RawInline('typst', tostring(j) .. '. '))
          end

          -- Add the content of the list item
          for _, block in ipairs(list_item) do
            if block.t == "Plain" or block.t == "Para" then
              for _, inline in ipairs(block.content) do
                table.insert(item_content, inline)
              end
            end
          end

          -- Create paragraph with the item
          table.insert(blocks, pandoc.Para(item_content))

          -- Add pause after each item except the last one
          if j < #item.content then
            table.insert(blocks, pandoc.RawBlock('typst', '#pause'))
          end
        end
      else
        table.insert(blocks, item)
      end
    end

    return pandoc.Div(blocks, el.attr)
  end
end
  