``` {#options .lua}
return {
  task_list = true,
}
```

``` {#input}
- [x] buy beans
- [X] get coffee grinder
- [ ] brew espresso
```

``` {#output .haskell}
[ BulletList
    [ [ Plain
          [ Str "\9746" , Space , Str "buy" , Space , Str "beans" ]
      ]
    , [ Plain
          [ Str "\9746"
          , Space
          , Str "get"
          , Space
          , Str "coffee"
          , Space
          , Str "grinder"
          ]
      ]
    , [ Plain
          [ Str "\9744"
          , Space
          , Str "brew"
          , Space
          , Str "espresso"
          ]
      ]
    ]
]
```
