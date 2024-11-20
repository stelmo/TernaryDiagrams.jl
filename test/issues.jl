using GLMakie
using TernaryDiagrams

#This testset checks that reported issues have been resolved; prevents regressions.

#https://github.com/stelmo/TernaryDiagrams.jl/issues/22
a = try 
        using CairoMakie
        using TernaryDiagrams
        fig = Figure()
        ax = Axis(fig[1, 1])
        ternaryaxis!(ax)
        ternaryscatter!(ax, [0.2, 0.1], [0.2, 0.6], [0.6, 0.3])
        fig
    catch e 
        e
    end
 @test !isa(a, Exception)