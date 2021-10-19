mutable struct ShowGraphvizConfig
    dot::Cmd
    dot_option::Cmd
    pygmentize::Cmd
    pygmentize_option::Cmd
end

const CONFIG = ShowGraphvizConfig(`dot`, ``, `pygmentize`, ``)

# `Graphviz_jll.dot`-like interface
function dot(f)
    f(CONFIG.dot)
end

const SUPPORTS_GRAPHVIZ = Dict{Cmd,Bool}()
supports_graphviz(cmd) =
    get!(SUPPORTS_GRAPHVIZ, cmd) do
        _supports_graphviz(cmd)
    end

function _supports_graphviz(cmd)
    io = IOBuffer()
    try
        communicate(`$cmd -L`; stdin = devnull, stdout = io)
    catch err
        @error "Igoring error from `$cmd`" exception = (err, catch_backtrace())
        return false
    end
    occursin("graphviz", String(take!(io)))
end

highlight_dot(io::IO, input::AbstractString) = highlight_dot(io, IOBuffer(input))
function highlight_dot(io::IO, input::IO)
    cmd = CONFIG.pygmentize
    if !supports_graphviz(cmd) || get(io, :color, false) === false
        write(io, input)
    else
        cmd = `$cmd $(CONFIG.pygmentize_option)`
        cmd = `$cmd -l dot`
        communicate(cmd; stdin = input, stdout = io)
    end
end
