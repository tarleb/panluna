local panluna = require "panluna"
setmetatable(_G, {__index = panluna})

return Doc:new(
  {},
  List:make_subtype(Block):new{
    Para:new(
      List:make_subtype(Inline):new{
        Str:new("Hello")
      }
    )
  }
)
