using Revise
using CairoMakie
using ColorSchemes
using TernaryDiagrams
const td = TernaryDiagrams
import GeometricalPredicates, VoronoiDelaunay, LinearAlgebra, Interpolations
const vd = VoronoiDelaunay
using JLD2

N = 300
a1 = load("test/data.jld2", "a1")[1:N]
a2 = load("test/data.jld2", "a2")[1:N]
a3 = load("test/data.jld2", "a3")[1:N]
ws = Float64.(load("test/data.jld2", "mus"))[1:N]

fig = Figure();
ax = Axis(fig[1, 1]);

ternaryaxis!(ax);
ternarycontour!(
    ax,
    a1,
    a2,
    a3,
    ws;
    levels = 25,
    color = nothing,
    colormap = reverse(ColorSchemes.Spectral),
)

ternaryscatter!(
    ax,
    a1,
    a2,
    a3;
    color = [get(reverse(ColorSchemes.Spectral), w, extrema(ws)) for w in ws],
)

xlims!(ax, -0.2, 1.2)
ylims!(ax, -0.3, 1.1)
hidedecorations!(ax)
fig

using FileIO

FileIO.save("fig.pdf", fig)