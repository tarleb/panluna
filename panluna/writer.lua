-- Copyright © 2024 Albert Krewinkel. Released under MIT license.
-- See the file LICENSE in the source for details.

--- Lunamark writer that produces a Pandoc document.
local M = {}

local pandoc = require 'pandoc'
local utils = require 'pandoc.utils'

--- Pandoc element representing a space character.
-- Calling pandoc functions is computationally expensive, so calling it just
-- once should improve performance.
local Space = pandoc.Space()

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
  return papply(flip(pandoc.List.map), fn)
end


local concat = function (list)
  if type(list) ~= 'table' or not next(list) then
    return {}
  end

  local mt = type(getmetatable(list[1])) == 'table' and getmetatable(list[1])
  local result = setmetatable({}, mt or pandoc.List)
  for _, item in ipairs(list) do
    if type(item) ~= 'string' then
      result:extend(item)
    end
  end
  return result
end

local concat_args = function (fn)
  return function (args, ...)
    return fn(concat(args), ...)
  end
end

local I = papply(compose, pandoc.Inlines)
local Ic = function (fn)
  return I(concat_args(fn))
end

local B = papply(compose, pandoc.Blocks)
local Bc = function (fn)
  return B(concat_args(fn))
end

local constant = function (c)
  return function () return pandoc.Inlines{pandoc.Str(c)} end
end

local function to_deflist_items (items)
  return pandoc.List.map(
    items,
    function (item)
      local term = concat(item.term)
      local def = pandoc.List(item.definitions):map(concat)
      return {term, def}
    end)
end

local function task_items (rawitems)
  local items = pandoc.List{}
  for _, item in ipairs(rawitems) do
    local marker = item[1] == '[ ]' and {"☐", Space} or {"☒", Space}
    local content = concat(item[2])
    if content[1] and (content[1].t == 'Para' or content[1].t == 'Plain') then
      content[1].content = marker .. content[1].content
    else
      pandoc.List.insert(content, 1, pandoc.Plain(marker))
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
  local aligns = pandoc.List(table.remove(rows, 2)):map(to_pandoc_alignment)
  local headers = table.remove(rows, 1)
  return utils.from_simple_table(
    pandoc.SimpleTable(caption or {}, aligns, {}, headers, rows)
  )
end

--- Creates an Attr object from a programming language specifier.
local function lang_to_attr (lang)
  return {"", {utils.stringify(lang)}}
end

function M.new ()
  local metadata = {}
  local writer = {
    ['start_document'] = function ()
      metadata = {}
      return nil
    end,
    ['stop_document'] = function () return nil end,
    ['get_metadata'] = function ()
      return metadata
    end,
    ['rope_to_output'] = function (result)
      local blocks = concat(result[2])
      return blocks
    end,
    ['blockquote'] = Bc(pandoc.BlockQuote),
    ['bulletlist'] = B(compose(pandoc.BulletList, map(concat))),
    ['code'] = I(pandoc.Code),
    ['definitionlist'] = B(compose(pandoc.DefinitionList, to_deflist_items)),
    ['display_html'] = B(papply(pandoc.RawBlock, 'html')),
    ['div'] = B(concat_args(pandoc.Div)),
    ['doublequoted'] = Ic(papply(pandoc.Quoted, 'DoubleQuote')),
    ['ellipsis'] = constant '…',
    ['emphasis'] = Ic(pandoc.Emph),
    ['fenced_code'] = B(compose(flip(pandoc.CodeBlock), lang_to_attr)),
    ['header'] = Bc(flip(pandoc.Header)),
    ['hrule'] = B(pandoc.HorizontalRule),
    ['image'] = Ic(pandoc.Image),
    ['inline_html'] = I(papply(pandoc.RawInline, 'html')),
    ['interblocksep'] = pandoc.Blocks{},
    ['link'] = Ic(pandoc.Link),
    ['lineblock'] = Bc(pandoc.LineBlock),
    ['linebreak'] = I(pandoc.LineBreak),
    ['mdash'] = constant '—',
    ['nbsp'] = I(pandoc.SoftBreak),
    ['ndash'] = constant '–',
    ['note'] = Ic(pandoc.Note),
    ['paragraph'] = B(concat_args(pandoc.Para)),
    ['plain'] = Bc(pandoc.Plain),
    ['rawinline'] = I(flip(pandoc.RawInline)),
    ['singlequoted'] = Ic(papply(pandoc.Quoted, 'SingleQuote')),
    ['space'] = I(pandoc.Space),
    ['span'] = Ic(pandoc.Span),
    ['strikeout'] = Ic(pandoc.Strikeout),
    ['string'] = I(pandoc.Str),
    ['strong'] = Ic(pandoc.Strong),
    ['subscript'] = Ic(pandoc.Subscript),
    ['superscript'] = Ic(pandoc.Superscript),
    ['table'] = B(make_table),
    ['tasklist'] = B(compose(pandoc.BulletList, task_items)),
    ['verbatim'] = B(pandoc.CodeBlock),
  }

  return writer
end

return M
