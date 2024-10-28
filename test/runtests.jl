using SafeTestsets

@testset "TernaryDiagrams" begin
    @safetestset "Aqua" include("aqua.jl")
    @safetestset "ReferenceTests" include("referencetests.jl")
end
