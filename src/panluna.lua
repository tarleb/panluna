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

--- Base type.
local Type = {}
--- Create an instance of the type.
function Type:new(o)
  setmetatable(o, self)
  self.__index = self
  return o
end
--- Create a subtype.
function Type:make_subtype(tag, fields)
  local t = Type:new{tag = tag, fields = (fields or {})}
  setmetatable(t, self)
  self.__index = self
  return t
end
--- create constructors from definitions
function Type:generate_constructors(definitions)
  -- safe self, as we'll use it to refer to a different object later.
  local data_type = self
  data_type.constructors = data_type.constructors or {}
  for name, fields in pairs(definitions) do
    local constructor = data_type:make_subtype(name, fields)
    -- FIXME: checking fields on every invokation is inefficient
    function constructor:new(...)
      local res = data_type:new{}
      setmetatable(res, self)
      self.__index = self
      if next(fields) ~= nil then
        local args = {...}
        if #self.fields == 0 then
          attr_name, attr_type = next(fields)
          res[1] = attr_type:new(args[1])
        else
          for i, field_def in ipairs(fields) do
            attr_name, attr_type = next(field_def)
            res[i] = attr_type:new(args[i])
          end
        end
      end
      return res
    end
    data_type[name] = constructor
    data_type.constructors[name] = constructor
  end
end

--- Class for normal text / strings.
local Text = Type:make_subtype "Text"
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

local Attributes = Type:make_subtype "Attributes"
function Attributes:from_json_structure(t)
  return self:new{identifier = t[1], classes = t[2], key_values = t[3]}
end
function Attributes:to_json_structure()
  return {self.identifier, self.classes, self.key_values}
end


--- A list of a specific type.
local List = Type:make_subtype "List"
function List.__call(t, ...)
  return t:new(...)
end
function List:make_subtype(item_type)
  local mt = getmetatable(self)
  local list_type = mt:make_subtype("List[" .. item_type.tag .. "]")
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


--- Document element
local Element = Type:make_subtype "Element"
--- Convert to JSON structure
function Element:to_json_structure()
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
function Element:from_json_structure(x)
  local element_type = self.constructors[x.t]
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

--- Block elements
local Block = Element:make_subtype "Block"
Block.__call = function (t, ...) return t:new(...) end
--- Inline elements
local Inline = Element:make_subtype "Inline"
Inline.__call = function (t, ...) return t:new(...) end

--- List of blocks
List[Block] = List:make_subtype(Block)
--- List of inlines
List[Inline] = List:make_subtype(Inline)

Block:generate_constructors{
  Div            = {{attributes = Attributes}, {content = List[Block]}},
  HorizontalRule = {},
  Para           = {content = List[Inline]},
  Plain          = {content = List[Inline]},
}

Inline:generate_constructors{
  Emph        = {content = List[Inline]},
  LineBreak   = {},
  SmallCaps   = {content = List[Inline]},
  SoftBreak   = {},
  Space       = {},
  Span        = {{attributes = Attributes}, {content = List[Inline]}},
  Str         = {content = Text},
  Strikeout   = {content = List[Inline]},
  Strong      = {content = List[Inline]},
  Subscript   = {content = List[Inline]},
  Superscript = {content = List[Inline]},
}

local Doc = Type:make_subtype "Doc"
setmetatable(Doc, {
  __call = function (t, meta, body, vrsn) return t:new(meta, body, vrsn) end
})
function Doc:new(meta, body, version)
  local t = {
    meta = meta,
    blocks = body,
    ["pandoc-api-version"] = version or {1,17,0,4}
  }
  setmetatable(t, self)
  self.__index = self
  return t
end
function Doc:from_json_structure(t)
  return Doc:new(
    t.meta,
    List[Block]:from_json_structure(t.blocks),
    t['pandoc-api-version']
  )
end
function Doc:to_json_structure()
  return {
    meta = self.meta,
    blocks = self.blocks:to_json_structure(),
    ["pandoc-api-version"] = self["pandoc-api-version"]
  }
end

-- Return everything that should be exported from the module
local M = {
  _version = _version,     -- module version
  Attributes = Attributes, -- Element attributes
  Block = Block,
  Doc = Doc,
  Inline = Inline,
  List = List,
  Text = Text,
}

-- Include constructors
for k, v in pairs(Inline.constructors) do
  M[k] = v
end
for k, v in pairs(Block.constructors) do
  M[k] = v
end

return M
