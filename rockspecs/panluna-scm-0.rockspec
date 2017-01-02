package = "panluna"
version = "scm-0"

source = {
  url = "git://github.com/tarleb/panluna"
}

description = {
  summary = "A library writing pandoc filters in lua ",
  homepage = "https://github.com/tarleb/panluna",
  license = "ISC",
}

dependencies = {
  "lua >= 5.1",
}

build = {
  type = "builtin",
  modules = {
    panluna = "src/panluna.lua",
  },
}