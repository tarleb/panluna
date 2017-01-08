--[[
panluna.lua

Copyright (c) 2017 Albert Krewinkel

Permission to use, copy, modify, and/or distribute this software for any purpose
with or without fee is hereby granted, provided that the above copyright notice
and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS
OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF
THIS SOFTWARE.
]]
local _version = "0.0.1"

--- Meta type, used to construct types.
local MetaType = {}
MetaType.__index = MetaType
MetaType.__call =  function (ty, tag, ...)
  return ty:create_subtype(tag, ...)
end
--- Create an instance of the type.
function MetaType:new(o)
  setmetatable(o, self)
  self.__index = self
  return o
end
--- Create a subtype.
function MetaType:create_subtype(tag, fields)
  local t = {tag = tag, fields = (fields or {})}
  setmetatable(t, self)
  self.__call = MetaType.__call
  self.__index = self
  return t
end

--- Base type.
local Type = MetaType:new{}

--- Class for normal text / strings.
local Text = Type "Text"
function Text:new(s)
  local t = {value = s}
  setmetatable(t, self)
  self.__index = self
  return t
end
function Text:from_json_structure(s)
  assert(type(s) == "string", "String expected as value of type 'Text'")
  return Text:new(s)
end
function Text:to_json_structure()
  return self.value
end

local Attributes = Type("Attributes")
function Attributes:from_json_structure(t)
  return self:new{identifier = t[1], classes = t[2], key_values = t[3]}
end
function Attributes:to_json_structure()
  return {self.identifier, self.classes, self.key_values}
end


--- A list of a specific type.
local List = Type "List"
function List:create_subtype(item_type, ...)
  local mt = getmetatable(self)
  local list_type = mt:create_subtype("List(" .. item_type.tag .. ")", ...)
  list_type.item_type = item_type
  setmetatable(list_type, self)
  self.__index = self
  return list_type
end
function List:from_json_structure(s)
  local res = {}
  for _, v in ipairs(s) do
    res[#res + 1] = self.item_type:from_json_structure(v)
  end
  return self:new(res)
end
function List:to_json_structure()
  local res = {}
  for i, v in ipairs(self) do
    res[i] = v:to_json_structure()
  end
  return res
end

-- Inline elements
local Inline = Type "Inline"
local Inlines = List(Inline)

--- Convert to JSON structure
function Inline:to_json_structure()
  if next(self) == nil then
    return {t = self.tag}
  elseif #self.fields == 0 then
    return {t = self.tag, c = self[1]:to_json_structure()}
  else
    c = {}
    for i, field_value in ipairs(self) do
      c[i] = field_value:to_json_structure()
    end
    return {t = self.tag, c = c}
  end
end

-- Initialize from JSON structure
function Inline:from_json_structure(x)
  local element_type = Inline.definitions[x.t]
  local element_content = x.c
  local fields = element_type.fields
  if type(element_content) ~= "table" or next(fields) == nil then
    return element_type:new(element_content)
  else
    if #fields == 0 then
      attr_name, attr_type = next(fields)
      res = attr_type:from_json_structure(element_content)
      return element_type:new(res)
    else
      local res = {}
      for i, field_def in ipairs(fields) do
        attr_name, attr_type = next(field_def)
        res[i] = attr_type:from_json_structure(element_content[i])
      end
      return element_type:new(unpack(res))
    end
  end
end

Inline.definitions = {
  Emph        = Inline("Emph",        {content = Inlines}),
  LineBreak   = Inline "LineBreak",
  SmallCaps   = Inline("SmallCaps",   {content = Inlines}),
  SoftBreak   = Inline "SoftBreak",
  Space       = Inline "Space",
  Span        = Inline("Span",        {{attributes = Attributes},
                                       {content = Inlines}}),
  Str         = Inline("Str",         {content = Text}),
  Strikeout   = Inline("Strikeout",   {content = Inlines}),
  Strong      = Inline("Strong",      {content = Inlines}),
  Subscript   = Inline("Subscript",   {content = Inlines}),
  Superscript = Inline("Superscript", {content = Inlines})
}

-- add constructors
for _, v in pairs(Inline.definitions) do
  function v:new(...)
    local res = Inline:new{}
    setmetatable(res, self)
    self.__index = self
    if next(self.fields) ~= nil then
      if #self.fields == 0 then
        attr_name, attr_type = next(self.fields)
        res[1] = attr_type:new(...)
      else
        local args = {...}
        for i, field_def in ipairs(self.fields) do
          attr_name, attr_type = next(field_def)
          res[i] = attr_type:new(args[i])
        end
      end
    end
    return res
  end
end

-- Return everything that should be exported from the module
return {
  _version = _version,
  Attributes = Attributes,
  Inline = Inline,
  Inlines = Inlines,
  List = List,
  Text = Text,
}
