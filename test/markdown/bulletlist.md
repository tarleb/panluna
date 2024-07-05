``` {#input}
+   item 1
+   item 2

    -   nested item 1
    -   nested item 2
```

``` {#output}
[ BulletList
    [ [ Para [ Str "item" , Space , Str "1" ] ]
    , [ Para [ Str "item" , Space , Str "2" ]
      , BulletList
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
