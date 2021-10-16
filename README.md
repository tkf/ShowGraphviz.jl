# ShowGraphviz: Derive various `show` methods from `text/vnd.graphviz`

The main API of ShowGraphviz.jl is `@deriveall`. Given a type that defines
`show` on DOT language  MIME type`text/vnd.graphviz`, it defines `show` methods
for various image types such as PNG, GIF, SVG, PDF, etc.

```julia
struct HelloWorld end

Base.show(io::IO, ::MIME"text/vnd.graphviz", ::HelloWorld) =
    print(io, "digraph G {Hello->World}")

using ShowGraphviz
ShowGraphviz.@deriveall HelloWorld

svg = sprint(show, "image/svg+xml", HelloWorld())
occursin("<svg", svg)

# output
true
```

## API

All top level functions and types (but not modules) defined in `ShowGraphviz`
are public API.

### Low-level API

* `ShowGraphviz.@derive type mimes...`: Similar to `@deriveall` but only define
   the methods with specified `mimes`.
* `ShowGraphviz.show(io, mime, x)`: show `x` as an image of MIME type `mime`
  using `dot` command line program.
* `ShowGraphviz.setoption(io, option)`: Set command line option for `dot` program
  via `IOContext`.
* `ShowGraphviz.addoption(io, option)`: Append option.
* `ShowGraphviz.getoption(io)`: Get option.

### Utilities

* `ShowGraphviz.DOT(source)`: a wrapper object that converts DOT `source`
* `ShowGraphviz.dot"source"`: create `DOT` using a string macro
* `ShowGraphviz.CONFIG.dot`: `dot` command
* `ShowGraphviz.CONFIG.dot_option`: global `dot` command option
