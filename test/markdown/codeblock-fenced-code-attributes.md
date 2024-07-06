``` {#options .lua}
return {
  fenced_code_attributes = true,
  fenced_code_blocks = true,
  preserve_tabs = true,
}
```

```` {#input .markdown}
~~~ {.haskell foo="bar"}
putStrLn "Hi!"
~~~
````

``` {#output .haskell}
[ CodeBlock ( "" , ["haskell"] , [ ("foo", "bar")] ) "putStrLn \"Hi!\"\n" ]
```
