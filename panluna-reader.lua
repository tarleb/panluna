local mdreader = require 'lunamark.reader.markdown'
local pandoc = require 'pandoc'
local panluna = require 'panluna'

Extensions = panluna.Extensions

function Reader (inputs, opts)
  local options = panluna.to_lunamark_options(opts)
  local parser = mdreader.new(panluna.new(), options)
  local blocks, meta = parser(tostring(inputs))
  return pandoc.Pandoc(blocks, meta)
end
