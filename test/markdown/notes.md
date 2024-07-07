``` {#options .lua}
return {
  notes = true,
  inline_notes = true,
}
```

``` {#input .markdown}
This summer^[It wasn't very summerly.] was short.

Don't enter.[^1]

[^1]: Or do; I'm a sign, not a cop.
```

``` {#output .haskell}
[ Para
    [ Str "This"
    , Space
    , Str "summer"
    , Note
        [ Plain
            [ Str "It"
            , Space
            , Str "wasn't"
            , Space
            , Str "very"
            , Space
            , Str "summerly."
            ]
        ]
    , Space
    , Str "was"
    , Space
    , Str "short."
    ]
, Para
    [ Str "Don't"
    , Space
    , Str "enter."
    , Note
        [ Para
            [ Str "Or"
            , Space
            , Str "do;"
            , Space
            , Str "I'm"
            , Space
            , Str "a"
            , Space
            , Str "sign,"
            , Space
            , Str "not"
            , Space
            , Str "a"
            , Space
            , Str "cop."
            ]
        ]
    ]
]
```
