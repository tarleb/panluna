``` {#options .lua}
return {
  fenced_code_attributes = true,
  fenced_code_blocks = true,
  preserve_tabs = true,
}
```

```` {#input .markdown}

``` lua
	print("Hello")
```

~~~ haskell
putStrLn "Hi!"
~~~
````

``` {#output .haskell}
[ CodeBlock ( "" , ["lua"] , [] ) "\tprint(\"Hello\")\n"
, CodeBlock ( "" , ["haskell"] , [] ) "putStrLn \"Hi!\"\n" ]
```
