local mdreader = require 'lunamark.reader.markdown'
local panluna = require 'panluna'
local pandoc = require 'pandoc'
local lpeg = require 'lpeg'
lpeg.locale(lpeg)  -- adds locale entries, e.g., alnum

local shortcode_start = lpeg.P('{{<') * lpeg.space^0
local shortcode_end = lpeg.space^0 * lpeg.P('>}}')
local shortcode_content = (1 - shortcode_end)^1
local shortcode
  = shortcode_start
  * lpeg.C(shortcode_content)
  * shortcode_end
  / function (content)
    return pandoc.Inlines(pandoc.Code(content, {class='shortcode'}))
  end

-- Supported extensions
Extensions = panluna.Extensions

function Reader (inputs, opts)
  local options = panluna.to_lunamark_options(opts)

  options.alter_syntax = function (syntax)
    -- Try the shortcode parser first
    syntax.Inline = shortcode + syntax.Inline
    return syntax
  end

  local parser = mdreader.new(panluna.new(), options)
  local blocks, meta = parser(tostring(inputs))
  return pandoc.Pandoc(blocks, meta)
end
