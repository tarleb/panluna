# Pipe tables

``` {#options .lua}
return {
  pipe_tables = true,
}
```

``` {#input .markdown}
|                        |                      |
| ---------------------- | -------------------- |
| **Type**               | `combining`          |
| **Required**           | No                   |
| **Same definition as** | [Name](#Client_Name) |
```

``` {#output .native}
[ Table
    ( "" , [] , [] )
    (Caption Nothing [])
    [ ( AlignDefault , ColWidthDefault )
    , ( AlignDefault , ColWidthDefault )
    ]
    (TableHead
       ( "" , [] , [] )
       [ Row
           ( "" , [] , [] )
           [ Cell
               ( "" , [] , [] ) AlignDefault (RowSpan 1) (ColSpan 1) []
           , Cell
               ( "" , [] , [] ) AlignDefault (RowSpan 1) (ColSpan 1) []
           ]
       ])
    [ TableBody
        ( "" , [] , [] )
        (RowHeadColumns 0)
        []
        [ Row
            ( "" , [] , [] )
            [ Cell
                ( "" , [] , [] )
                AlignDefault
                (RowSpan 1)
                (ColSpan 1)
                [ Plain [ Strong [ Str "Type" ] ] ]
            , Cell
                ( "" , [] , [] )
                AlignDefault
                (RowSpan 1)
                (ColSpan 1)
                [ Plain [ Code ( "" , [] , [] ) "combining" ] ]
            ]
        , Row
            ( "" , [] , [] )
            [ Cell
                ( "" , [] , [] )
                AlignDefault
                (RowSpan 1)
                (ColSpan 1)
                [ Plain [ Strong [ Str "Required" ] ] ]
            , Cell
                ( "" , [] , [] )
                AlignDefault
                (RowSpan 1)
                (ColSpan 1)
                [ Plain [ Str "No" ] ]
            ]
        , Row
            ( "" , [] , [] )
            [ Cell
                ( "" , [] , [] )
                AlignDefault
                (RowSpan 1)
                (ColSpan 1)
                [ Plain
                    [ Strong
                        [ Str "Same"
                        , Space
                        , Str "definition"
                        , Space
                        , Str "as"
                        ]
                    ]
                ]
            , Cell
                ( "" , [] , [] )
                AlignDefault
                (RowSpan 1)
                (ColSpan 1)
                [ Plain
                    [ Link
                        ( "" , [] , [] )
                        [ Str "Name" ]
                        ( "#Client_Name" , "" )
                    ]
                ]
            ]
        ]
    ]
    (TableFoot ( "" , [] , [] ) [])
]
```
