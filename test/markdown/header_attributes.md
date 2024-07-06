``` {#options .lua}
return {
  header_attributes = true,
}
```

``` {#input .markdown}
# Prelude {.unnumbered}

Thanks everyone!

# Introduction {#intro}

# Methods
```

``` {#output .haskell}
[ Header 1 ( "" , [ "unnumbered" ] , [] ) [ Str "Prelude" ]
, Para [ Str "Thanks" , Space , Str "everyone" , Str "!" ]
, Header 1 ( "intro" , [] , [] ) [ Str "Introduction" ]
, Header 1 ( "" , [] , [] ) [ Str "Methods" ]
]
```
