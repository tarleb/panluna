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
setmetatable(_G, {__index = panluna})

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
        attr = Attributes:new{
          identifier = "TEST",
          classes = {"foo", "bar"},
          key_values = {key1 = "value1"}
        }
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
    local inlines = {
      Str:new("Hello"),
      Space:new(),
      Str:new("World!")
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
      LineBreak = LineBreak,
      SoftBreak = SoftBreak,
      Space     = Space,
    }
    for tag, constructor in pairs(nullary_constructors) do
      describe(tag, function()
        local test_inline
        it("is tagged correctly", function()
          assert.equal(tag, constructor.tag)
        end)
        it("can be instantiated", function()
          test_inline = constructor:new()
        end)
        it("can be used as a function", function()
          assert.is.same(test_inline, constructor())
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
      Emph        = Emph,
      SmallCaps   = SmallCaps,
      Strikeout   = Strikeout,
      Strong      = Strong,
      Subscript   = Subscript,
      Superscript = Superscript,
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
        it("can be used as a function", function()
          assert.is.same(test_inline, constructor(inlines))
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
    describe("Span", function()
      local test_attr = Attributes:new{
        identifier = "TEST",
        classes = {"foo", "bar"},
        key_values = {key1 = value1}
      }
      local test_attr_json = {"TEST", {"foo", "bar"}, {key1 = value1}}
      local test_json = {t = "Span", c = {test_attr_json, inlines_json}}
      local test_span
      it("is tagged correctly", function()
        assert.equal("Span", Span.tag)
      end)
      it("can be instantiated", function()
        test_span = Span:new(test_attr, inlines)
      end)
      it("can be used as a function", function()
        test_span = Span(test_attr, inlines)
      end)
      it("can be converted to a JSON-like structure", function()
        assert.is.same(test_json, test_span:to_json_structure())
      end)
      it("can be initialized from a JSON-like structure", function()
        assert.is.same(test_span, Inline:from_json_structure(test_json))
      end)
    end)

    --
    -- Code
    --
    describe("Code", function()
      local test_attr = panluna.Attributes:new{identifier = "TEST",
                                               classes = {"foo", "bar"},
                                               key_values = {key1 = value1}}
      local test_attr_json = {"TEST", {"foo", "bar"}, {key1 = value1}}
      local test_code_string = "Line 1\nLine 2\n\Line 4\n"
      local test_json = {t = "Code", c = {test_attr_json, test_code_string}}
      local test_code
      it("is tagged correctly", function()
        assert.equal("Code", Code.tag)
      end)
      it("can be instantiated", function()
        test_code = Code:new(test_attr, Text:new(test_code_string))
      end)
      it("can be used as a function", function()
        assert.is.same(test_code, Code(test_attr, Text:new(test_code_string)))
      end)
      it("can be converted to a JSON-like structure", function()
        assert.is.same(test_json, test_code:to_json_structure())
      end)
      it("can be initialized from a JSON-like structure", function()
        assert.is.same(test_code, Inline:from_json_structure(test_json))
      end)
    end)
  end)

  describe("block element", function()
    local Block = panluna.Block
    local Inline = panluna.Inline
    local inlines = List[Inline]:new{
      Inline.constructors.Str:new("Hello"),
      Inline.constructors.Space:new(),
      Inline.constructors.Str:new("World!")
    }
    local inlines_json = {
      {t = "Str", c = "Hello"},
      {t = "Space"},
      {t = "Str", c = "World!"}
    }

    describe("HorizontalRule", function()
      local HorizontalRule = Block.constructors.HorizontalRule
      local test_json = {t = "HorizontalRule"}
      local test_block
      it("is tagged correctly", function()
        assert.equal("HorizontalRule", HorizontalRule.tag)
      end)
      it("can be instantiated", function()
        test_block = HorizontalRule:new()
      end)
      it("can be used as a function", function()
        assert.is.same(test_block, HorizontalRule())
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
      Para        = Block.constructors.Para,
      Plain       = Block.constructors.Plain,
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
        it("can be used as a function", function()
          assert.is.same(test_block, constructor(inlines))
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
    local Div = Block.constructors.Div
    describe("Div", function()
      local test_attr      = panluna.Attributes:new{identifier = "TEST",
                                                    classes = {"foo", "bar"},
                                                    key_values = {key1 = val1}}
      local test_attr_json = {"TEST", {"foo", "bar"}, {key1 = val1}}
      local blocks         = {Block.constructors.Para:new(inlines)}
      local blocks_json    = {{t = "Para", c = inlines_json}}
      local test_json      = {t = "Div", c = {test_attr_json, blocks_json}}
      local test_div
      it("is tagged correctly", function()
        assert.equal("Div", Div.tag)
      end)
      it("can be instantiated", function()
        test_div = Block.constructors.Div:new(test_attr, blocks)
      end)
      it("can be used as a function", function()
        assert.is.same(test_div, Div(test_attr, blocks))
      end)
      it("can be converted to a JSON-like structure", function()
        assert.is.same(test_json, test_div:to_json_structure())
      end)
      it("can be initialized from a JSON-like structure", function()
        assert.is.same(test_div, Block:from_json_structure(test_json))
      end)
    end)

    --
    -- Code Block
    --
    describe("CodeBlock", function()
      local test_attr = panluna.Attributes:new{identifier = "TEST",
                                               classes = {"foo", "bar"},
                                               key_values = {key1 = value1}}
      local test_attr_json = {"TEST", {"foo", "bar"}, {key1 = value1}}
      local test_code_string = "Line 1\nLine 2\n\Line 4\n"
      local test_json = {t = "CodeBlock", c = {test_attr_json, test_code_string}}
      local test_code
      it("is tagged correctly", function()
        assert.equal("CodeBlock", CodeBlock.tag)
      end)
      it("can be instantiated", function()
        test_code = CodeBlock:new(test_attr, Text:new(test_code_string))
      end)
      it("can be used as a function", function()
        assert.is.same(test_code, CodeBlock(test_attr, Text:new(test_code_string)))
      end)
      it("can be converted to a JSON-like structure", function()
        assert.is.same(test_json, test_code:to_json_structure())
      end)
      it("can be initialized from a JSON-like structure", function()
        assert.is.same(test_code, Block:from_json_structure(test_json))
      end)
    end)
  end)

  describe("Doc", function ()
    local Doc = panluna.Doc
    local Para = Block.constructors.Para
    local test_inlines = List[Inline]:new{Inline.constructors.Str:new("Moin")}
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
      test_doc = Doc:new({}, List[Block]:new{Para:new(test_inlines)})
    end)
    it("can be converted to a JSON-like structure", function()
      assert.is.same(test_json, test_doc:to_json_structure())
    end)
    it("can be initialized from a JSON-like structure", function()
      assert.is.same(test_doc, Doc:from_json_structure(test_json))
    end)
  end)
end)
