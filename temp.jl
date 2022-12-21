using Revise
using CairoMakie
using ColorSchemes
using TernaryDiagrams

n = 100
arr = rand(n, 3)
arr ./= sum(arr, dims=2)
arr
color = [ColorSchemes.Dark2_8[i] for i in rand(1:8, n)] 
vs = rand(n)

fig = Figure();
ax = Axis(fig[1,1]);

ternaryaxis!(ax);

# ternaryscatter!(ax, arr[:, 1], arr[:, 2], arr[:, 3]; color)
# ternaryline!(ax, arr[:, 1], arr[:, 2], arr[:, 3])

ternaryfill!(ax, arr[:, 1], arr[:, 2], arr[:, 3], vs; triangle_length=0.0091) # 0.4

xlims!(ax, -0.2, 1.2)
ylims!(ax, -0.3, 1.1)
hidedecorations!(ax)
fig