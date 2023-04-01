using Revise
using CairoMakie
using TernaryDiagrams
using JLD2

a1 = load(joinpath(@__DIR__, "data.jld2"), "a1")
a2 = load(joinpath(@__DIR__, "data.jld2"), "a2")
a3 = load(joinpath(@__DIR__, "data.jld2"), "a3")
ws = Float64.(load(joinpath(@__DIR__, "data.jld2"), "mus"))

fig = Figure();
ax = Axis(fig[1, 1]);
ternarycontourf!(ax, a1, a2, a3, ws; levels = 10)
ternaryaxis!(ax);
xlims!(ax, -0.2, 1.2)
ylims!(ax, -0.3, 1.1)
hidedecorations!(ax)
fig

Makie.FileIO.save("figs/contourfill.svg", fig)
