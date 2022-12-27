using CairoMakie
using ColorSchemes
using TernaryDiagrams
using JLD2

a1 = load("test/data.jld2", "a1")
a2 = load("test/data.jld2", "a2")
a3 = load("test/data.jld2", "a3")
ws = Float64.(load("test/data.jld2", "mus"))

fig = Figure();
ax = Axis(fig[1, 1]);

ternarycontour!(
    ax,
    a1,
    a2,
    a3,
    ws;
    levels = 5,
    linewidth = 4,
    color = nothing,
    colormap = reverse(ColorSchemes.Spectral),
    pad_data = true,
)

ternaryaxis!(ax);

xlims!(ax, -0.2, 1.2)
ylims!(ax, -0.3, 1.1)
hidedecorations!(ax)
fig

Makie.FileIO.save("figs/contour.svg", fig)
