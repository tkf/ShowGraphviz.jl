const OPTIONKEY = :ShowGraphviz_option

ShowGraphviz.getoption(io::IO) = get(io, OPTIONKEY, ``)::Cmd
ShowGraphviz.setoption(io::IO, option) = IOContext(io, OPTIONKEY, `$option`)
function ShowGraphviz.addoption(io::IO, option)
    old = ShowGraphviz.getoption(io)
    new = `$old $option`
    return ShowGraphviz.setoption(io, new)
end

function run_dot(output::IO, input::IO, option = ``)
    cfg = CONFIG.dot_option
    ctx = ShowGraphviz.getoption(output)
    dot() do cmd
        cmd = `$cmd $cfg $ctx $option`
        @debug "Run: $cmd"
        communicate(cmd; stdin = input, stdout = output)
    end
    return output
end

function dot_to_iobuffer(dot)
    io = IOBuffer()
    show(io, MIME"text/vnd.graphviz"(), dot)
    seekstart(io)
    return io
end

Base.show(io::IO, ::MIME"text/vnd.graphviz", dot::ShowGraphviz.DOT) = print(io, dot.source)
dot_to_iobuffer(dot::ShowGraphviz.DOT) = IOBuffer(dot.source)

"""
    ShowGraphviz.show(io::IO, mime, x; option = ``)

Given a Julia value `x` that defines `show` on `text/vnd.graphviz` MIME type,
convert it into mime type using `dot` program.  Command line options for `dot`
can be set by `option` keyword argument.

It can be used even when `show` of `x` is not defined with `@derive` or
`@deriveall`.
"""
ShowGraphviz.show(io::IO, mime::AbstractString, dot; option = ``) =
    ShowGraphviz.show(ShowGraphviz.addoption(io, option), MIME(mime), dot)

# Run `dot -T?`
# See also https://graphviz.org/docs/outputs/
const MIME_TO_DOT_OUTPUT = [
    "image/png" => "png",
    "image/gif" => "gif",
    "image/svg+xml" => "svg",
    "application/pdf" => "pdf",
]

for (mime, output) in MIME_TO_DOT_OUTPUT
    @eval ShowGraphviz.show(io::IO, ::$(typeof(MIME(mime))), dot) =
        run_dot(io, dot_to_iobuffer(dot), $(`-T$output`))
end

function derive_impl(T, mimes::Vector{String})
    exprs = map(mimes) do mime
        quote
            $Base.show(io::$IO, m::$(typeof(MIME(mime))), x::$T) =
                $ShowGraphviz.show(io, m, x)
        end
    end
    return Expr(:block, exprs...)
end

"""
    ShowGraphviz.@derive Type "mime₁" "mime₂" … "mimeₙ"
"""
macro derive(T, mimes...)
    mimes = collect(String, mimes)
    return esc(derive_impl(T, mimes))
end

"""
    ShowGraphviz.@deriveall Type
"""
macro deriveall(T)
    mimes = map(first, MIME_TO_DOT_OUTPUT)
    return esc(derive_impl(T, mimes))
end

macro dot_str(source)
    esc(:($ShowGraphviz.DOT($(QuoteNode(source)))))
end

function ShowGraphviz.DOT(source::IO)
    io = IOBuffer()
    write(io, source)
    return ShowGraphviz.DOT(String(take!(io)))
end

function ShowGraphviz.DOT(dot)
    io = dot_to_iobuffer(dot)
    return ShowGraphviz.DOT(String(take!(io)))
end

@deriveall ShowGraphviz.DOT

function Base.show(io::IO, ::MIME"text/plain", dot::ShowGraphviz.DOT)
    println(io, ShowGraphviz, ".dot\"\"\"")
    highlight_dot(io, dot.source)
    print(io, "\"\"\"")
end
