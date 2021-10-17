baremodule ShowGraphviz

macro derive end
macro deriveall end

struct DOT
    source::String
    DOT(source::AbstractString) = new(source)
end

macro dot_str end

function show end

function getoption end
function setoption end
function addoption end

module Internal

import ..ShowGraphviz: @derive, @deriveall, @dot_str
using ..ShowGraphviz: ShowGraphviz

# using Graphviz_jll: dot

include("utils.jl")
include("config.jl")
include("derive.jl")

# Use README as the docstring of the module:
function define_docstring()
    path = joinpath(dirname(@__DIR__), "README.md")
    include_dependency(path)
    doc = replace(read(path, String), r"^```julia"m => "```jldoctest README")
    @eval ShowGraphviz $Base.@doc $doc ShowGraphviz
end

end  # module Internal

const CONFIG = Internal.CONFIG

Internal.define_docstring()

end  # baremodule ShowGraphviz
