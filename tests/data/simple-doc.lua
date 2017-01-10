local panluna = require "panluna"
setmetatable(_G, {__index = panluna})

return Doc:new(
  {},
  List(Block):new{
    Para:new(
      List(Inline):new{
        Str:new("Hello")
      }
    )
  }
)
