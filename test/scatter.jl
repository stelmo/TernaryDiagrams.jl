using Revise
using CairoMakie
using ColorSchemes
using TernaryDiagrams
using JLD2
const td = TernaryDiagrams


a1 = load("test/data.jld2", "a1")[1:20]
a2 = load("test/data.jld2", "a2")[1:20]
a3 = load("test/data.jld2", "a3")[1:20]
ws = rand(20)

fig = Figure();
ax = Axis(fig[1, 1]);

ternaryaxis!(ax);
ternaryscatter!(
    ax,
    a1,
    a2,
    a3;
    color = [get(ColorSchemes.Spectral, w, extrema(ws)) for w in ws],
    marker = :circle,
    markersize = 20,
)

xlims!(ax, -0.2, 1.2)
ylims!(ax, -0.3, 1.1)
hidedecorations!(ax)
fig

Makie.FileIO.save("figs/scatter.svg", fig)
