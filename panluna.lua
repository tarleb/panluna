-- Copyright © 2024 Albert Krewinkel. Released under MIT license.
-- See the file LICENSE in the source for details.

--- Lunamark writer that produces a Pandoc document.
local M = {}

local pandoc = require 'pandoc'
local utils = require 'pandoc.utils'
local List = require 'pandoc.List'
local pdtype = utils.type

--- Pandoc element representing a space character.
-- Calling pandoc functions is computationally expensive, so calling it just
-- once should improve performance.
local Space = pandoc.Inlines{pandoc.Space()}

--
-- Functional programming helpers
--

--- Partially apply an argument
local function papply (fn, arg)
  return function(...) return fn(arg, ...) end
end

--- Flip the first and second parameter of a function.
local function flip (fn)
  return function (arg1, arg2, ...)
    return fn(arg2, arg1, ...)
  end
end

--- Compose two functions into a new function by chaining them together.
local function compose(fn1, fn2)
  return function (...)
    return fn1(fn2(...))
  end
end

--- Returns a new function that applies `fn` to all elements in a list.
local map = function (fn)
  return papply(flip(List.map), fn)
end

--- Turns a rope into a list.
local function unrope (rope)
    local typ = type(rope)
    if typ == 'string' then
      return rope == '' and List {} or List{pandoc.Str(rope)}
    elseif typ == 'table' then
      local result = List{}
      for _, item in ipairs(List.map(rope, unrope)) do
        result:extend(item)
      end
      return result
    elseif typ == 'function' then
      return unrope(rope())
    else
      return List{rope}
    end
end

local unrope_args = function (fn)
  return function (args, ...)
    return fn(unrope(args), ...)
  end
end

local  function make_rope_creator (constr)
  return function (fn)
    return function (...)
      local args = {...}
      return function ()
        return constr(fn(table.unpack(args)))
      end
    end
  end
end

local I = make_rope_creator(pandoc.Inlines)
local Ic = compose(I, unrope_args)

local B = make_rope_creator(pandoc.Blocks)
local Bc = compose(B, unrope_args)

local function to_deflist_items (items)
  return List.map(
    items,
    function (item)
      local term = unrope(item.term)
      local def = List(item.definitions):map(unrope)
      return {term, def}
    end)
end

local function task_items (rawitems)
  local items = List{}
  for _, item in ipairs(rawitems) do
    local marker = item[1] == '[ ]' and {"☐"} .. Space or {"☒"} .. Space
    local content = unrope(item[2])
    if content[1] and (content[1].t == 'Para' or content[1].t == 'Plain') then
      content[1].content = marker .. content[1].content
    else
      List.insert(content, 1, pandoc.Plain(marker))
    end
    items:insert(content)
  end
  return items
end

local function to_pandoc_alignment (align)
  if align == 'd' then
    return 'AlignDefault'
  elseif align == 'l' then
    return 'AlignLeft'
  elseif align == 'c' then
    return 'AlignCenter'
  elseif align == 'r' then
    return 'AlignRight'
  else
    warn('unknown alignment ', align, ', using default alignment.')
    return 'AlignDefault'
  end
end
local function make_table (rows, caption)
  local aligns = List(table.remove(rows, 2)):map(to_pandoc_alignment)
  local headers = table.remove(rows, 1)
  return utils.from_simple_table(
    pandoc.SimpleTable(caption or {}, aligns, {}, headers, rows)
  )
end

local function to_pandoc_cite (text_cites)
  return function (cite)
    local ct = text_cites and 'AuthorInText' or 'NormalCitation'
    return pandoc.Citation(
      cite.name,
      cite.suppress_author and 'SuppressAuthor' or ct,
      unrope(cite.prenote),
      unrope(cite.postnote)
    )
  end
end
local function make_citations (text_cites, cites)
  local pdcites = List(cites):map(to_pandoc_cite(text_cites))
  return pandoc.Cite('placeholder', pdcites)
end

local function unrope_metadata (tbl)
  if type(tbl) == 'table' and tbl[1] then
    if pdtype(tbl[1]) == 'Inlines' or pdtype(tbl[1]) == 'string' then
      return pandoc.Inlines(unrope(tbl))
    elseif pdtype(tbl[1]) == 'Blocks' then
      return pandoc.Blocks(unrope(tbl))
    elseif type(tbl[1]) == 'function' then
      local eval = function (x) return type(x) == 'function' and x() or x end
      local evaled = List.map(tbl, eval)
      return unrope_metadata(evaled)
    else
      return List.map(tbl, unrope_metadata)
    end
  elseif type(tbl) == 'table' then
    for key, value in pairs(tbl) do
      tbl[key] = unrope_metadata(value)
    end
    return tbl
  elseif type(tbl) == 'function' then
    return unrope_metadata(tbl())
  else
    return tbl
  end
end

--- Creates an Attr object from a programming language specifier.
local function lang_to_attr (lang)
  return {"", {utils.stringify(lang)}}
end

--- Convert paragraphs to plain elements
local function para_to_plain (blk)
  if blk.t == 'Para' then
    return pandoc.Plain(blk.content)
  else
    return blk
  end
end

--- The identity function; simply returns its arguments.
local function identity (...)
  return ...
end

local function orderedlist (items, tight, start, numstyle, delim)
  delim = delim == 'Default' and 'DefaultDelim' or delim
  return pandoc.OrderedList(
    List.map(items, unrope):map(tight and para_to_plain or identity),
    pandoc.ListAttributes(start, numstyle, delim)
  )
end

function M.new ()
  local metadata = {}
  local writer = {
    ['start_document'] = function ()
      return {}
    end,
    ['stop_document']  = function () return nil end,
    ['get_metadata']   = function ()
      return unrope_metadata(metadata)
    end,
    ['set_metadata']   = function (key, value)
      metadata[key] = value
    end,
    ['rope_to_output'] = function (result)
      local blocks = unrope(result[2])
      return blocks, metadata
    end,

    -- Inline and block elements
    ['blockquote']     = Bc(pandoc.BlockQuote),
    ['bulletlist']     = B(compose(pandoc.BulletList, map(unrope))),
    ['citation']       = function(x) return x end,
    ['citations']      = I(make_citations),
    ['code']           = I(pandoc.Code),
    ['definitionlist'] = B(compose(pandoc.DefinitionList, to_deflist_items)),
    ['display_html']   = B(papply(pandoc.RawBlock, 'html')),
    ['div']            = Bc(pandoc.Div),
    ['doublequoted']   = Ic(papply(pandoc.Quoted, 'DoubleQuote')),
    ['ellipsis']       = '…',
    ['emphasis']       = Ic(pandoc.Emph),
    ['fenced_code']    = B(compose(flip(pandoc.CodeBlock), lang_to_attr)),
    ['header']         = Bc(flip(pandoc.Header)),
    ['hrule']          = B(pandoc.HorizontalRule),
    ['image']          = Ic(pandoc.Image),
    ['inline_html']    = I(papply(pandoc.RawInline, 'html')),
    ['interblocksep']  = pandoc.Blocks{},
    ['link']           = Ic(pandoc.Link),
    ['lineblock']      = Bc(pandoc.LineBlock),
    ['linebreak']      = I(pandoc.LineBreak),
    ['mdash']          = '—',
    ['nbsp']           = ' ',
    ['ndash']          = '–',
    ['note']           = Ic(pandoc.Note),
    ['orderedlist']    = B(orderedlist),
    ['paragraph']      = Bc(pandoc.Para),
    ['plain']          = Bc(pandoc.Plain),
    ['rawinline']      = I(flip(pandoc.RawInline)),
    ['singlequoted']   = Ic(papply(pandoc.Quoted, 'SingleQuote')),
    ['space']          = function () return Space end,
    ['span']           = Ic(pandoc.Span),
    ['strikeout']      = Ic(pandoc.Strikeout),
    ['string']         = function (s) return s end,
    ['strong']         = Ic(pandoc.Strong),
    ['subscript']      = Ic(pandoc.Subscript),
    ['superscript']    = Ic(pandoc.Superscript),
    ['table']          = B(make_table),
    ['tasklist']       = B(compose(pandoc.BulletList, task_items)),
    ['verbatim']       = B(pandoc.CodeBlock),
  }

  return writer
end

return M