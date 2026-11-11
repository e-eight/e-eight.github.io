-- Run citeproc ourselves (Quarto runs user filters before its own citeproc pass),
-- bold the site owner's name ("S Pal"), and turn the bibliography into a bullet list.
local function bold_owner(inlines)
  for i = 3, #inlines do
    local a, sp, b = inlines[i - 2], inlines[i - 1], inlines[i]
    if a.t == "Str" and a.text == "S" and sp.t == "Space"
        and b.t == "Str" and b.text:match("^Pal[,.]?$") then
      local punct = b.text:match("^Pal([,.]?)$")
      inlines[i - 2] = pandoc.Strong({ pandoc.Str("S"), pandoc.Space(), pandoc.Str("Pal") })
      inlines[i - 1] = pandoc.Str(punct)
      inlines:remove(i)
      return inlines
    end
  end
end

local function refs_as_list(div)
  if div.identifier ~= "refs" then return nil end
  local items = {}
  for _, entry in ipairs(div.content) do
    if entry.t == "Div" then items[#items + 1] = entry.content end
  end
  return pandoc.Div({ pandoc.BulletList(items) }, div.attr)
end

function Pandoc(doc)
  doc = pandoc.utils.citeproc(doc)
  return doc:walk({ Inlines = bold_owner, Div = refs_as_list })
end
