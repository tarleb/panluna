--[[
Panluna test suite for pandoc interation

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
local panluna = require "panluna"
local json = require "lunajson"

local Pandoc = {}
function Pandoc:new(input_file, input_format)
  local t = {
    input_file = input_file,
    input_format = input_format,
  }
  setmetatable(t, self)
  self.__index = self
  return t
end
function Pandoc:convert_to(outformat)
  local cmdArgs = {
    "pandoc",
    "--standalone",
    "--from", self.input_format,
    "--to", outformat,
    self.input_file,
  }
  local handle = io.popen(table.concat(cmdArgs, " "), "r")
  local content = handle:read()
  handle:close()
  return content
end
function Pandoc:convert_to_json()
  return self:convert_to("json")
end

function test_json_parsing(test_name)
  it("allows to read " .. test_name:gsub("-", " "), function ()
    local pandoc = Pandoc:new("tests/data/" .. test_name .. ".native", "native")
    local json_string = pandoc:convert_to_json()
    local json_structure = json.decode(json_string)
    local panluna_structure = dofile("tests/data/" .. test_name .. ".lua")
    assert.is.same(
      panluna_structure,
      panluna.Doc:from_json_structure(json_structure)
    )
  end)
end

describe("Pandoc interaction", function()
  test_json_parsing("simple-doc")
end)
