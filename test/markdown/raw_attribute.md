``` {#options .lua}
return {
  raw_attribute = true,
  fenced_code_blocks = true,
}
```

From the lunamark docs:

> When enabled, inline code and fenced code blocks with a special kind
> of attribute will be parsed as raw content with the designated format,
> e.g. `{=format}`. Writers may pass relevant raw content to the target
> formatter.
>
> To use a raw attribute with fenced code blocks, `fenced_code_blocks`
> must be enabled.
>
> As opposed to the Pandoc option going by the same name, raw attributes
> can be continued with key=value pairs.
>
> How these constructs are honored depends on the writer. In the minimal
> case, they are ignored, as if they were stripped from the input.

``` {#input .markdown}
~~~ {=html}
<aside>I have discovered a truly marvelous proof of this, which
this margin is too narrow to contain.</aside>
~~~

Press `<kbd>Ctrl-A</kbd>`{=html foo=bar} to select everything.
```

``` {#output .haskell}
[ RawBlock
    (Format "html")
    "<aside>I have discovered a truly marvelous proof of this, which\nthis margin is too narrow to contain.</aside>\n"
, Para
    [ Str "Press"
    , Space
    , RawInline (Format "html") "<kbd>Ctrl-A</kbd>"
    , Space
    , Str "to"
    , Space
    , Str "select"
    , Space
    , Str "everything."
    ]
]
```
