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

-- Types
local MetaType = {}
-- Create a subtype
MetaType.__call =  function (ty, tag, ...)
  local t = {tag = tag}
  setmetatable(t, ty)
  ty.__index = ty
  return t
end
MetaType.__index = MetaType

local Type = {}
setmetatable(Type, MetaType)
Type.__index = Type
Type.__call = MetaType.__call
-- Create an instance of the type
function Type:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end


-- Text
Text = Type "Text"
function Text:new(s)
  local t = {value = s}
  setmetatable(t, self)
  self.__index = self
  return t
end
function Text.from_json(s)
  assert(type(s) == "string", "String expected as value of type 'Text'")
  return self:new(s)
end
function Text:to_json_structure()
  return self.value
end


-- Inline elements
local Inline = Type "Inline"
Inline.definitions = {
  LineBreak = Inline "LineBreak",
  SoftBreak = Inline "SoftBreak",
  Space     = Inline "Space",
}

-- Convert to JSON structure
function Inline:to_json_structure()
  if next(self) ~= nil then
    return {t = self.tag, c = self}
  else
    return {t = self.tag}
  end
end

-- Initialize from JSON structure
function Inline.from_json_structure(x)
  return Inline.definitions[x.t]:new(x.c)
end


-- Return everything that should be exported from the module
return {
  _version = _version,
  Inline = Inline
}
