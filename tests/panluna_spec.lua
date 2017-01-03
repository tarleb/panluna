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

describe("Panluna library for pandoc filters in lua", function()
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

    describe("LineBreak", function()
      local LineBreak = Inline.definitions.LineBreak
      it("is defined", function()
        assert.truthy(LineBreak)
      end)
      it("is tagged correctly", function()
        assert.equal("LineBreak", LineBreak.tag)
      end)
      it("can be converted to a JSON-like structure", function()
        assert.is.same({t = "LineBreak"}, LineBreak:new():to_json_structure())
      end)
      it("can be initialized from a JSON-like structure", function()
        assert.is.same(LineBreak:new(), Inline.from_json_structure{t = "LineBreak"})
      end)
    end)

    describe("SoftBreak", function()
      local SoftBreak = Inline.definitions.SoftBreak
      it("is defined", function()
        assert.truthy(SoftBreak)
      end)
      it("is tagged correctly", function()
        assert.equal("SoftBreak", SoftBreak.tag)
      end)
      it("can be converted to a JSON-like structure", function()
        assert.is.same({t = "SoftBreak"}, SoftBreak:new():to_json_structure())
      end)
      it("can be initialized from a JSON-like structure", function()
        assert.is.same(SoftBreak:new(), Inline.from_json_structure{t = "SoftBreak"})
      end)
    end)

    describe("Space", function()
      local Space = Inline.definitions.Space
      it("is defined", function()
        assert.truthy(Space)
      end)
      it("is tagged correctly", function()
        assert.equal("Space", Space.tag)
      end)
      it("can be converted to a JSON-like structure", function()
        assert.is.same({t = "Space"}, Space:new():to_json_structure())
      end)
      it("can be initialized from a JSON-like structure", function()
        assert.is.same(Space:new(), Inline.from_json_structure{t = "Space"})
      end)
    end)

    describe("Str", function()
      local Str = Inline.definitions.Str
      it("is defined", function()
        assert.truthy(Str)
      end)
      it("can be converted to a JSON-like structure", function()
        assert.is.same({t = "Str", c = "Hello"}, Str:new("Hello"):to_json_structure())
      end)
      it("can be initialized from a JSON-like structure", function()
           assert.is.same(Str:new("Hello"),
                          Inline.from_json_structure{t = "Str", c = "Hello"})
      end)
    end)
  end)
end)
