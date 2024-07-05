``` {#options .lua}
return {
  definition_lists = true,
}
```

``` {#input}
foo

:   bar

quux

:   quuz
```

``` {#output .haskell}
[ DefinitionList
    [ ( [ Str "foo" ] , [ [ Para [ Str "bar" ] ] ] )
    , ( [ Str "quux" ] , [ [ Para [ Str "quuz" ] ] ] )
    ]
]
```
