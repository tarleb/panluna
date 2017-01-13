local panluna = require "panluna"
setmetatable(_G, {__index = panluna})

return Doc(
  {},
  List[Block]{
    Para(
      List[Inline]{
        Str("Hello")
      }
    )
  }
)
