``` {#options .lua}
return {
  mark = true,
}
```

``` {#input .markdown}
Mark ==my words==!
```

``` {#output .haskell}
[ Para
    [ Str "Mark"
    , Space
    , Span
        ( "" , [ "mark" ] , [] ) [ Str "my" , Space , Str "words" ]
    , Str "!"
    ]
]
```
