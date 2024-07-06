``` {#options .lua}
return {
  line_blocks = true,
}
```

``` {#input .markdown}
| Frühling lässt sein blaues Band
| Wieder flattern durch die Lüfte;
| Süße, wohlbekannte Düfte
| Streifen ahnungsvoll das Land.
| Veilchen träumen schon,
| Wollen balde kommen.
| - Horch, von fern ein leiser Harfenton!
|    Frühling, ja du bist's!
| Dich hab ich vernommen!
```

``` {#output .haskell}
[ LineBlock
    [ [ Str "Fr\252hling"
      , Space
      , Str "l\228sst"
      , Space
      , Str "sein"
      , Space
      , Str "blaues"
      , Space
      , Str "Band"
      ]
    , [ Str "Wieder"
      , Space
      , Str "flattern"
      , Space
      , Str "durch"
      , Space
      , Str "die"
      , Space
      , Str "L\252fte;"
      ]
    , [ Str "S\252\223e,"
      , Space
      , Str "wohlbekannte"
      , Space
      , Str "D\252fte"
      ]
    , [ Str "Streifen"
      , Space
      , Str "ahnungsvoll"
      , Space
      , Str "das"
      , Space
      , Str "Land."
      ]
    , [ Str "Veilchen"
      , Space
      , Str "tr\228umen"
      , Space
      , Str "schon,"
      ]
    , [ Str "Wollen"
      , Space
      , Str "balde"
      , Space
      , Str "kommen."
      ]
    , [ Str "-"
      , Space
      , Str "Horch,"
      , Space
      , Str "von"
      , Space
      , Str "fern"
      , Space
      , Str "ein"
      , Space
      , Str "leiser"
      , Space
      , Str "Harfenton"
      , Str "!"
      ]
    , [ Str "\160\160\160Fr\252hling,"
      , Space
      , Str "ja"
      , Space
      , Str "du"
      , Space
      , Str "bist's"
      , Str "!"
      ]
    , [ Str "Dich"
      , Space
      , Str "hab"
      , Space
      , Str "ich"
      , Space
      , Str "vernommen"
      , Str "!"
      ]
    ]
]
```
