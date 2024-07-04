``` {#options .lua}
return {
  pandoc_title_blocks = true
}
```

``` markdown
% [Test] file
% [tarleb]; Jane Doe
% 2024-07-04

Nil

[tarleb]: https://tarleb.com
[Test]: https://example.com
```

``` haskell
Pandoc
  Meta
    { unMeta =
        fromList
          [ ( "author"
            , MetaList
                [ MetaInlines
                    [ Link
                        ( "" , [] , [] )
                        [ Str "tarleb" ]
                        ( "https://tarleb.com" , "" )
                    ]
                , MetaInlines [ Str "Jane" , Space , Str "Doe" ]
                ]
            )
          , ( "date"
            , MetaInlines
                [ Str "2024" , Str "-" , Str "07" , Str "-" , Str "04" ]
            )
          , ( "title"
            , MetaInlines
                [ Link
                    ( "" , [] , [] )
                    [ Str "Test" ]
                    ( "https://example.com" , "" )
                , Space
                , Str "file"
                ]
            )
          ]
    }
  [ Para [ Str "Nil" ] ]
```
