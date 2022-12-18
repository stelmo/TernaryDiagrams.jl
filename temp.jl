using Revise
using CairoMakie
using ColorSchemes
using TernaryDiagrams

n = 100
arr = rand(n, 3)
arr ./= sum(arr, dims=2)
arr
color = [ColorSchemes.Dark2_8[i] for i in rand(1:8, n)] 

fig = Figure()
ax = Axis(fig[1,1])
crds = ternary!(ax, arr[:, 1], arr[:, 2], arr[:, 3]; color)
xlims!(ax, -0.2, 1.2)
ylims!(ax, -0.3, 1.1)
hidedecorations!(ax)
fig