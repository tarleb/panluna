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

local Attributes = panluna.Attributes
local Block = panluna.Block
local Blocks = panluna.Blocks
local Inline = panluna.Inline
local Inlines = panluna.Inlines
local List = panluna.List
local Text = panluna.Text

describe("Panluna", function()
  it("exists and has a version", function()
    assert.truthy(panluna._version)
  end)

  describe("data type", function()
    describe("Text", function()
      it("is converted to a normal string for JSON", function()
        assert.is.equal("Hello, World", Text:new("Hello, World"):to_json_structure())
      end)
    end)
    describe("Attributes", function()
      local attr_json = {"TEST", {"foo", "bar"}, {key1 = "value1"}}
      local attr
      it("can be instantiated", function()
        attr = panluna.Attributes:new{identifier = "TEST",
                                      classes = {"foo", "bar"},
                                      key_values = {key1 = "value1"}}
      end)
      it("can be initialized from a JSON-like structure", function()
        assert.is.same(attr, Attributes:from_json_structure(attr_json))
      end)
      it("is converted to a nested list for JSON", function()
        local attr = panluna.Attributes:new{identifier = "TEST",
                                            classes = {"foo", "bar"},
                                            key_values = {key1 = value1}}
        local attr_json = {"TEST", {"foo", "bar"}, {key1 = value1}}
        assert.is.same(attr_json, attr:to_json_structure())
      end)
    end)
  end)

  describe("inline element", function()
    local Inline = panluna.Inline
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

    --
    -- nullary constructors
    --
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

    --
    -- Simple wrappers
    --
    local simple_wrappers = {
      Emph        = Inline.definitions.Emph,
      SmallCaps   = Inline.definitions.SmallCaps,
      Strikeout   = Inline.definitions.Strikeout,
      Strong      = Inline.definitions.Strong,
      Subscript   = Inline.definitions.Subscript,
      Superscript = Inline.definitions.Superscript,
    }
    for tag, constructor in pairs(simple_wrappers) do
      local test_inline
      local test_json = {t = tag, c = inlines_json}
      describe(tag, function()
        it("is tagged correctly", function()
          assert.equal(tag, constructor.tag)
        end)
        it("can be instantiated", function()
          test_inline = constructor:new(inlines)
        end)
        it("can be converted to a JSON-like structure", function()
          assert.is.same(test_json, test_inline:to_json_structure())
        end)
        it("can be initialized from a JSON-like structure", function()
          assert.is.same(test_inline, Inline:from_json_structure(test_json))
        end)
      end)
    end

    --
    -- Span
    --
    local Span = Inline.definitions.Span
    describe("Span", function()
      local test_attr = panluna.Attributes:new{identifier = "TEST",
                                               classes = {"foo", "bar"},
                                               key_values = {key1 = value1}}
      local test_attr_json = {"TEST", {"foo", "bar"}, {key1 = value1}}
      local test_json = {t = "Span", c = {test_attr_json, inlines_json}}
      local test_span
      it("is tagged correctly", function()
        assert.equal("Span", Span.tag)
      end)
      it("can be instantiated", function()
        test_span = Inline.definitions.Span:new(test_attr, inlines)
      end)
      it("can be converted to a JSON-like structure", function()
        assert.is.same(test_json, test_span:to_json_structure())
      end)
      it("can be initialized from a JSON-like structure", function()
        assert.is.same(test_span, Inline:from_json_structure(test_json))
      end)
    end)
  end)

  describe("block element", function()
    local Block = panluna.Block
    local Inline = panluna.Inline
    local inlines = List(Inline):new{
      Inline.definitions.Str:new("Hello"),
      Inline.definitions.Space:new(),
      Inline.definitions.Str:new("World!")
    }
    local inlines_json = {
      {t = "Str", c = "Hello"},
      {t = "Space"},
      {t = "Str", c = "World!"}
    }

    describe("HorizontalRule", function()
      local HorizontalRule = Block.definitions.HorizontalRule
      local test_json = {t = "HorizontalRule"}
      local test_block
      it("is tagged correctly", function()
        assert.equal("HorizontalRule", HorizontalRule.tag)
      end)
      it("can be instantiated", function()
        test_block = HorizontalRule:new()
      end)
      it("can be converted to a JSON-like structure", function()
        assert.is.same(test_json, test_block:to_json_structure())
      end)
      it("can be initialized from a JSON-like structure", function()
        assert.is.same(test_block, Block:from_json_structure(test_json))
      end)
    end)

    --
    -- Simple inline wrappers
    --
    local simple_wrappers = {
      Para        = Block.definitions.Para,
      Plain       = Block.definitions.Plain,
    }
    for tag, constructor in pairs(simple_wrappers) do
      local test_block
      local test_json = {t = tag, c = inlines_json}
      describe(tag, function()
        it("is tagged correctly", function()
          assert.equal(tag, constructor.tag)
        end)
        it("can be instantiated", function()
          test_block = constructor:new(inlines)
        end)
        it("can be converted to a JSON-like structure", function()
          assert.is.same(test_json, test_block:to_json_structure())
        end)
        it("can be initialized from a JSON-like structure", function()
          assert.is.same(test_block, Block:from_json_structure(test_json))
        end)
      end)
    end

    --
    -- Div
    --
    local Div = Block.definitions.Div
    describe("Div", function()
      local test_attr      = panluna.Attributes:new{identifier = "TEST",
                                                    classes = {"foo", "bar"},
                                                    key_values = {key1 = val1}}
      local test_attr_json = {"TEST", {"foo", "bar"}, {key1 = val1}}
      local blocks         = {Block.definitions.Para:new(inlines)}
      local blocks_json    = {{t = "Para", c = inlines_json}}
      local test_json      = {t = "Div", c = {test_attr_json, blocks_json}}
      local test_div
      it("is tagged correctly", function()
        assert.equal("Div", Div.tag)
      end)
      it("can be instantiated", function()
        test_div = Block.definitions.Div:new(test_attr, blocks)
      end)
      it("can be converted to a JSON-like structure", function()
        assert.is.same(test_json, test_div:to_json_structure())
      end)
      it("can be initialized from a JSON-like structure", function()
        assert.is.same(test_div, Block:from_json_structure(test_json))
      end)
    end)
  end)

  describe("Doc", function ()
    local Doc = panluna.Doc
    local Para = Block.definitions.Para
    local test_inlines = Inlines:new{Inline.definitions.Str:new("Moin")}
    local test_blocks_json = {{t = "Para", c = {{t = "Str", c = "Moin"}}}}
    local test_json = {
      meta = {},
      blocks = test_blocks_json,
      ["pandoc-api-version"] = {1,17,0,4},
    }
    local test_doc
    it("is tagged correctly", function()
      assert.equal("Doc", Doc.tag)
    end)
    it("can be instantiated", function()
      test_doc = Doc:new({}, Blocks:new{Para:new(test_inlines)})
    end)
    it("can be converted to a JSON-like structure", function()
      assert.is.same(test_json, test_doc:to_json_structure())
    end)
    it("can be initialized from a JSON-like structure", function()
      assert.is.same(test_doc, Doc:from_json_structure(test_json))
    end)
  end)
end)
