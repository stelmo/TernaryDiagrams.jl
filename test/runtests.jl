using SafeTestsets
using Test

@testset "TernaryDiagrams" begin
    @safetestset "Aqua" include("aqua.jl")
    @safetestset "Issue check" include("issues.jl")
    @safetestset "ReferenceTests" include("referencetests.jl")
end
