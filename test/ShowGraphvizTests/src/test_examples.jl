module TestExamples

using ..Examples
using Test

const ALL_MIMES = [
    # Ref: `ShowGraphviz.Internal.MIME_TO_DOT_OUTPUT`
    "image/png",
    "image/gif",
    "image/svg+xml",
    "application/pdf",
]

function iobuffer(mime, dot)
    io = IOBuffer()
    show(io, mime, dot)
    return io
end

function test_smoke()
    @testset for dot in [Examples.hello_world, Examples.cluster, Examples.HelloWorldAll()],
        mime in ALL_MIMES

        @test position(iobuffer(mime, dot)) > 0
    end
end

function test_derive_svg()
    @test position(iobuffer(MIME"image/svg+xml"(), Examples.HelloWorldSVG())) > 0
    @test_throws MethodError iobuffer(MIME"image/png"(), Examples.HelloWorldSVG())
end

end  # module
