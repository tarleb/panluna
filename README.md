panluna
========

A connector between [lunamark][] and [pandoc][].

The [lunamark][] project provides an extensible Markdown parser
written with [LPeg][], a fast, efficient, and easy to use parsing
library for [Lua][]. [Pandoc][], the universal document converter,
contains it's own Lua interpreter and can be extended in various
ways via Lua, for example with a [custom Lua reader][]. This
project allows to harness the extensibility of lunamark while
still using the full power of pandoc.


Usage
-----

Call pandoc with

    pandoc --from=panluna-reader.lua ...

to use lunamark as a parser.

Dependencies
------------

This project currently ships will all relevant parts of lunamark
included. However, the goal is that lunamark will become an
external dependency that will have to be installed with luarocks
or by other means.

[lunamark]: https://jgm.github.io/lunamark/
[pandoc]: https://pandoc.org/
[lpeg]: https://www.inf.puc-rio.br/~roberto/lpeg/
[Lua]: https://lua.org/
[custom Lua reader]: https://pandoc.org/custom-readers
