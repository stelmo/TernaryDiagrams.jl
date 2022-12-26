using CairoMakie
using TernaryDiagrams

fig = Figure();
ax = Axis(fig[1, 1]);
ternarycontourf!(ax, a1, a2, a3, ws; levels = 15, pad_data = true)
ternaryaxis!(ax);
xlims!(ax, -0.2, 1.2)
ylims!(ax, -0.3, 1.1)
hidedecorations!(ax)
fig

Makie.FileIO.save("figs/axis.svg", fig)
