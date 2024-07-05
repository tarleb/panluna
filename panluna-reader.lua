local reader = require 'lunamark.reader.markdown'
local writer = require 'panluna'
local pandoc = require 'pandoc'

function Reader (inputs, opts)
  local options = {
    bracketed_spans = true,
    citations = true,
    definition_lists = true,
    escaped_line_breaks = true,
    fenced_code_blocks = true,
    fenced_divs = true,
    inline_notes = true,
    line_blocks = true,
    notes = false,
    pandoc_title_blocks = true,
    pipe_tables = true,
    raw_attribute = true,
    smart = true,
    strikeout = true,
    superscript = true,
    subscript = true,
    task_list = true,
  }
  local parser = reader.new(writer.new(), options)
  local blocks, meta = parser(tostring(inputs))
  return pandoc.Pandoc(blocks, meta)
end
