module TestDoctest

import ShowGraphviz
using Documenter: doctest
using Test

function test_doctest()
    doctest(ShowGraphviz; manual = false)
end

end  # module
