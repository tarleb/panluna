local reader = require 'lunamark.reader.markdown'
local pandoc = require 'pandoc'

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

local I = function(fn)
  return function(...)
    return pandoc.Inlines{fn(...)}
  end
end

local Ic = function (fn)
  return I(concat_args(fn))
end

local B = function(fn)
  return function(...)
    return pandoc.Blocks{fn(...)}
  end
end

local Bc = function (fn)
  return B(concat_args(fn))
end

local Space = pandoc.Space()

local constant = function (c)
  return function () return pandoc.Inlines{pandoc.Str(c)} end
end

--- Partially apply an argument
local function partap (fn, arg)
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

local function is_not_empty (item)
  return type(item) ~= 'table' or next(item)
end

local to_deflist_items = partap(
  flip(pandoc.List.map),
  function (item)
    return {concat(item.term), concat(item.definitions):filter(is_not_empty)}
  end
)

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
  return pandoc.utils.from_simple_table(
    pandoc.SimpleTable(caption or {}, aligns, {}, headers, rows)
  )
end

local metadata = {}

local writer = {
  ['start_document'] = function ()
    return {}
  end,
  ['stop_document'] = function ()
    return {}
  end,
  ['get_metadata'] = function ()
    return metadata
  end,
  ['rope_to_output'] = function (result)
    return result[2]
  end,
  ['blockquote'] = Bc(pandoc.BlockQuote),
  ['bulletlist'] = Bc(pandoc.BulletList),
  ['code'] = I(pandoc.Code),
  ['definitionlist'] = B(compose(pandoc.DefinitionList, to_deflist_items)),
  ['display_html'] = B(partap(pandoc.RawBlock, 'html')),
  ['div'] = B(concat_args(pandoc.Div)),
  ['doublequoted'] = Ic(partap(pandoc.Quoted, 'DoubleQuote')),
  ['ellipsis'] = constant '…',
  ['emphasis'] = Ic(pandoc.Emph),
  ['fenced_code'] = function(c,i) return B(pandoc.CodeBlock)(c, {class=i[1].text}) end,
  ['header'] = Bc(flip(pandoc.Header)),
  ['hrule'] = B(pandoc.HorizontalRule),
  ['image'] = Ic(pandoc.Image),
  ['inline_html'] = I(partap(pandoc.RawInline, 'html')),
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
  ['singlequoted'] = Ic(partap(pandoc.Quoted, 'SingleQuote')),
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

function Reader (inputs, opts)
  local options = {
    bracketed_spans = true,
    definition_lists = true,
    fenced_code_blocks = true,
    fenced_divs = true,
    inline_notes = true,
    line_blocks = true,
    notes = true,
    pipe_tables = true,
    raw_attribute = true,
    smart = true,
    strikeout = true,
    superscript = true,
    subscript = true,
    task_list = true,
  }
  local parser = reader.new(writer, options)
  local result = parser(tostring(inputs))
  local blocks = concat(result)
  return pandoc.Pandoc(blocks)
end
