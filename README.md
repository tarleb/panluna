pandoc-lunamark
===============

A [custom Lua reader] for pandoc that uses the [lunamark] LPeg Markdown
parser.

Usage
-----

Call pandoc with

    pandoc --from=lunamark-reader.lua ...

to use lunamark as a parser.

Dependencies
------------

Install *lunamark* with

    luarocks install --local lunamark

Make sure that the `LUA_PATH` variable is set appropriately. E.g., run

    eval $(luarocks path)

to set the paths.

[custom Lua reader]: https://pandoc.org/custom-readers
[lunamark]: https://jgm.github.io/lunamark/
