using CairoMakie
using ColorSchemes
using TernaryDiagrams
using JLD2

a1 = load(joinpath(@__DIR__, "data.jld2"), "a1")[1:20]
a2 = load(joinpath(@__DIR__, "data.jld2"), "a2")[1:20]
a3 = load(joinpath(@__DIR__, "data.jld2"), "a3")[1:20]

fig = Figure();
ax = Axis(fig[1, 1]);

ternaryaxis!(ax);
ternarylines!(ax, a1, a2, a3; color = :blue)

hidedecorations!(ax)
fig

Makie.FileIO.save("figs/lines.svg", fig)
