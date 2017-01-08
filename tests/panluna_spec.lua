--[[
Panluna test suite

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
package.path = package.path .. ";../src/?.lua"
panluna = require "panluna"

local List = panluna.List

describe("Panluna", function()
  it("exists and has a version", function()
    assert.truthy(panluna._version)
  end)

  describe("Basic data types", function()
    describe("Text", function()
      it("is converted to a normal string for JSON", function()
        assert.is.equal("Hello, World", Text:new("Hello, World"):to_json_structure())
      end)
    end)
  end)

  describe("Inline elements", function()
    local Inline = panluna.Inline
    it("has a definition for inlines", function()
      assert.truthy(Inline.definitions)
    end)

    describe("Nullary constructors", function()
      local nullary_constructors = {
        LineBreak = Inline.definitions.LineBreak,
        SoftBreak = Inline.definitions.SoftBreak,
        Space     = Inline.definitions.Space,
      }
      for tag, constructor in pairs(nullary_constructors) do
        describe(tag, function()
          it("is tagged correctly", function()
            assert.equal(tag, constructor.tag)
          end)
          it("can be converted to a JSON-like structure", function()
            assert.is.same({t = tag}, constructor:new():to_json_structure())
          end)
          it("can be initialized from a JSON-like structure", function()
            assert.is.same(constructor:new(), Inline:from_json_structure{t =  tag })
          end)
        end)
      end
    end)


    describe("Simple wrappers", function()
      local simple_wrappers = {
        Emph        = Inline.definitions.Emph,
        SmallCaps   = Inline.definitions.SmallCaps,
        Strikeout   = Inline.definitions.Strikeout,
        Strong      = Inline.definitions.Strong,
        Subscript   = Inline.definitions.Subscript,
        Superscript = Inline.definitions.Superscript,
      }
      local inlines = {
        Inline.definitions.Str:new("Hello"),
        Inline.definitions.Space:new(),
        Inline.definitions.Str:new("World!")
      }
      local inlines_json = {
        {t = "Str", c = "Hello"},
        {t = "Space"},
        {t = "Str", c = "World!"}
      }
      for tag, constructor in pairs(simple_wrappers) do
        local test_inline = constructor:new(inlines)
        local test_json = {t = tag, c = inlines_json}
        describe(tag, function()
          it("is tagged correctly", function()
            assert.equal(tag, constructor.tag)
          end)
          it("can be converted to a JSON-like structure", function()
            assert.is.same(test_json, test_inline:to_json_structure())
          end)
          it("can be initialized from a JSON-like structure", function()
            assert.is.same(test_inline, Inline:from_json_structure(test_json))
          end)
        end)
      end
    end)
  end)
end)
