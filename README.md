pandoc-lunamark
===============

A [custom Lua reader] for pandoc that uses the [lunamark] LPeg
Markdown parser.

Usage
-----

Call pandoc with

    pandoc --from=lunamark-reader.lua ...

to use lunamark as a parser.

Dependencies
------------

This project currently ships will all relevant parts of lunamark
included. However, the goal is that lunamark will become an
external dependency that will have to be installed with luarocks
or by other means.

[custom Lua reader]: https://pandoc.org/custom-readers
[lunamark]: https://jgm.github.io/lunamark/
