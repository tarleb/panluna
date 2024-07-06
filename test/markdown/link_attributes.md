``` {#options .lua}
return {
  link_attributes = true,
}
```

From the lunamark docs:

> Current implementation restrictions and differences with the Pandoc
> option by the same name: attributes cannot be set on links
> and indirect images (i.e. only direct images support them).

``` {#input .markdown}
![pandoc logo](images/logo.svg){#pandoc-logo .internal}
```

``` {#output .haskell}
[ Para
    [ Image
        ( "pandoc-logo" , [ "internal" ] , [] )
        [ Str "pandoc" , Space , Str "logo" ]
        ( "images/logo.svg" , "" )
    ]
]
```
