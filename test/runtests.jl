using SafeTestsets

@safetestset "Aqua" begin
    include("aqua.jl")
end

@safetestset "ReferenceTests" begin
    include("referencetests.jl")
end