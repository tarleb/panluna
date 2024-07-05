``` {#input .markdown}
1.  item 1
2.  item 2

    1.   nested item 1
    2.   nested item 2
```

``` {#output}
[ OrderedList
    ( 1 , Decimal , DefaultDelim )
    [ [ Para [ Str "item" , Space , Str "1" ] ]
    , [ Para [ Str "item" , Space , Str "2" ]
      , OrderedList
          ( 1 , Decimal , DefaultDelim )
          [ [ Plain
                [ Str "nested" , Space , Str "item" , Space , Str "1" ]
            ]
          , [ Plain
                [ Str "nested" , Space , Str "item" , Space , Str "2" ]
            ]
          ]
      ]
    ]
]
```
