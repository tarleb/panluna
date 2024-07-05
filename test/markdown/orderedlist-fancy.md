``` {#options .lua}
return {
  fancy_lists = true,
  startnum = true,
}
```

``` {#input .markdown}
1.  item 1

2.  item 2

    a)   nested item 1
    b)   nested item 2

Intermittent text.

3.  item 3

4.  item 4
```

``` {#output .haskell}
[ OrderedList
    ( 1 , Decimal , Period )
    [ [ Para [ Str "item" , Space , Str "1" ] ]
    , [ Para [ Str "item" , Space , Str "2" ]
      , OrderedList
          ( 1 , LowerAlpha , OneParen )
          [ [ Plain
                [ Str "nested" , Space , Str "item" , Space , Str "1" ]
            ]
          , [ Plain
                [ Str "nested" , Space , Str "item" , Space , Str "2" ]
            ]
          ]
      ]
    ]
, Para [ Str "Intermittent" , Space , Str "text." ]
, OrderedList
    ( 3 , Decimal , Period )
    [ [ Para [ Str "item" , Space , Str "3" ] ]
    , [ Para [ Str "item" , Space , Str "4" ] ]
    ]
]
```
