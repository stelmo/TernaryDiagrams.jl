using Revise
using CairoMakie
using TernaryDiagrams

arr = rand(10, 3)
arr ./= sum(arr, dims=2)
arr

fig = Figure()
ax = Axis(fig[1,1])
crds = ternary!(ax, arr[:, 1], arr[:, 2], arr[:, 3])
xlims!(ax, -0.2, 1.2)
ylims!(ax, -0.3, 1.1)
hidedecorations!(ax)
fig