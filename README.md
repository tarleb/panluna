panluna
========

A library to create customized, [lunamark][]-based Markdown
parsers for [pandoc][].

The [lunamark][] project provides an extensible Markdown parser
written with [LPeg][], a fast, efficient, and easy to use parsing
library for [Lua][]. [Pandoc][], the universal document converter,
contains it's own Lua interpreter and can be extended in various
ways via Lua. This project allows to harness the *extensibility*
of lunamark, while still using the full power of pandoc.

The library is intended to be used in a [custom Lua reader][] in
combination with the `lunamark` library. Lunamark normally takes a
writer that creates strings from the parse results. However, the
library is flexible, and the writer doesn't necessarily have to
produce a string. Panluna provides a writer that produces pandoc
blocks and metadata instead of strings.

Installation
------------

An easy way to install the library is via [luarocks][], the
package manager for Lua.

```sh
luarocks install --local panluna
```

In addition, it may also be necessary to run `eval "$(luarocks
path)"` to set the environment variables to the correct values.

[luarocks]: https://luarocks.org/

Usage
-----

A basic custom Lua reader using panluna can look like this:

``` lua
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
```

Save it to a file `panluna-reader.lua` and call pandoc with

    pandoc --from=panluna-reader.lua ...

to use lunamark as a parser.

Customizing
-----------

The Markdown parser can be extended with custom syntax. As an
example, let's extend the parser such that [Quarto][]-style
[shortcodes][] `{{< text >}}` are read as code with class
`shortcode`, i.e., like `` `text`{.shortcode} ``.

For that we define an LPeg pattern `shortcode` and update the
syntax table to check for this pattern before trying any other
inline elements.

Lunamark allow to update the parser definitions via the
`alter_syntax` option. It must be set to a function that modifies
the table of LPeg syntax parsers.

``` lua
local mdreader = require 'lunamark.reader.markdown'
local panluna = require 'panluna'
local pandoc = require 'pandoc'
local lpeg = require 'lpeg'
lpeg.locale(lpeg)  -- adds locale entries, e.g., lpeg.space

local shortcode_start   = lpeg.P('{{<') * lpeg.space^0
local shortcode_end     = lpeg.space^0 * lpeg.P('>}}')
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
    -- Try the glossary item parser first
    syntax.Inline = shortcode + lpeg.V'Inline'
    return syntax
  end

  local parser = mdreader.new(panluna.new(), options)
  local blocks, meta = parser(tostring(inputs))
  return pandoc.Pandoc(blocks, meta)
end
```

[Quarto]: https://quarto.org/
[shortcodes]: https://quarto.org/docs/extensions/shortcodes.html


Example: Glossary terms
-----------------------

For a more involved example, we'll modify the parser such that
`%word` is parsed as a way a glossary word and `%[glossary term]`
as a glossary term.  Since pandoc has no concept of glossary
items, we'll use `Span` elements with class `glossary` as the
parse result.

This syntax overlaps with other Markdown syntax, such as reference
links, which makes it impossible to implement this syntax
extensions in a pandoc Lua filter, as important information might
already be lost at that stage.

``` lua
local mdreader = require 'lunamark.reader.markdown'
local panluna = require 'panluna'
local pandoc = require 'pandoc'
local lpeg = require 'lpeg'
lpeg.locale(lpeg)  -- adds locale entries, e.g., alnum

-- LPeg pattern for glossary words, e.g. `%word`
local glossary_word
  = lpeg.P'%'                  -- literal `%`
  * lpeg.C(lpeg.alnum^1)       -- one or more letters

-- LPeg pattern for glossary terms, e.g. `%[markup language]`
local glossary_term
  = lpeg.P'%['                 -- literal string `%[`
  * lpeg.C((1 - lpeg.P']')^1)  -- any string that doesn't contain `]`
  * lpeg.P']'                  -- literal string `]`

--- Creates a `glossary` pandoc Span
--
-- The result must be wrapped in `pandoc.Inlines` for technical
-- reasons.
local create_glossary_span = function (content)
  local attr = pandoc.Attr{class='glossar'}
  return pandoc.Inlines(pandoc.Span(content, attr))
end

-- Pattern for glossary words or terms; returns a pandoc span
local glossary_item = (glossary_term + glossary_word)
  / create_glossary_span

-- Supported extensions
Extensions = panluna.Extensions

function Reader (inputs, opts)
  local options = panluna.to_lunamark_options(opts)

  options.alter_syntax = function (syntax)
    -- Try the glossary item parser first
    syntax.Inline = glossary_item + syntax.Inline
    return syntax
  end

  local parser = mdreader.new(panluna.new(), options)
  local blocks, meta = parser(tostring(inputs))
  return pandoc.Pandoc(blocks, meta)
end
```

Extended example
----------------

The glossary parsing above has some minor flaws. For example, it
doesn't allow to use Markdown syntax in glossary terms. Both the
`glossary_term` pattern and the `create_glossary_span` function
must be updated to fix this.

Updating the `glossary_term` pattern is relatively
straight-forward. Instead of single characters, we look for
`lpeg.V'Inline'` patterns, which are defined by lunamark. The
capture must now be a table capture `lpeg.Ct`.

``` lua
-- LPeg pattern for glossary terms, e.g. `%[markup language]`
local glossary_term
  = lpeg.P'%['
  * lpeg.Ct((lpeg.V'Inline' - lpeg.P']')^1)
  * lpeg.P']'
```

The `Inline` patterns return a structure called a "rope", which
can be used to delay evaluation of some functions. This matters,
for example, when dealing with reference links, where the
reference definition might not be defined by the time the link is
parsed. Therefore, we must "unrope" the content, while also
wrapping the result in an additional function to ensure delayed
evaluation.

``` lua
local create_glossary_span = function (content)
  -- extra function wrap to ensure delayed evaluation
  return function ()
    local attr = pandoc.Attr{class='glossar'}
    local content = panluna.unrope(content)
    return pandoc.Inlines(pandoc.Span(content, attr))
  end
end
```

[lunamark]: https://jgm.github.io/lunamark/
[pandoc]: https://pandoc.org/
[lpeg]: https://www.inf.puc-rio.br/~roberto/lpeg/
[Lua]: https://lua.org/
[custom Lua reader]: https://pandoc.org/custom-readers
