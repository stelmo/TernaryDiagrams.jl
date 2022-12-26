using Revise
using CairoMakie
using ColorSchemes
using TernaryDiagrams

const td = TernaryDiagrams

fig = Figure();
ax = Axis(fig[1, 1]);

ternaryaxis!(
    ax;
    labelx = "a1",
    labely = "a2",
    labelz = "a3",
    # more options available, check out attributes with ?ternaryaxis
)

xlims!(ax, -0.2, 1.2) # to center the triangle
ylims!(ax, -0.3, 1.1) # to center the triangle
hidedecorations!(ax) # to hide the axis decos
fig

Makie.FileIO.save("figs/axis.svg", fig)
