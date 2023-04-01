using Revise
using CairoMakie
using ColorSchemes
using TernaryDiagrams

fig = Figure();
ax = Axis(fig[1, 1]);

ternaryaxis!(
    ax;
    xlabel = "a1",
    ylabel = "a2",
    zlabel = "a3",
    # more options available, check out attributes with ?ternaryaxis
)

hidedecorations!(ax) # to hide the axis decos
fig

Makie.FileIO.save("figs/axis.svg", fig)
