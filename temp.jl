using Revise
using JLD2
using Makie, LinearAlgebra, ColorSchemes, DocStringExtensions
using CairoMakie
import GeometricalPredicates, VoronoiDelaunay, Interpolations, Base, TernaryDiagrams
const vd = VoronoiDelaunay
const gp = GeometricalPredicates
const td = TernaryDiagrams

a1 = load("test/data.jld2", "a1")
a2 = load("test/data.jld2", "a2")
a3 = load("test/data.jld2", "a3")
ws = Float64.(load("test/data.jld2", "mus"))

xs, ys = td.from_bary_to_cart(a1, a2, a3)

# colormap
levels = 5

lb = minimum(ws)
ub = maximum(ws)
d = (ub - lb) / (levels + 1)
bins = [(lb + n * d) for n = 1:levels]

data_coords = td.delaunay_scale.(xs, ys)
pad_coords, pad_weights = td.generate_padded_data(data_coords, ws)
scaled_coords = [data_coords; pad_coords]
weights = [ws; pad_weights]

level_edges = td.contour_triangle(scaled_coords, bins, weights, levels)

fig = Figure();
ax = Axis(fig[1,1]);
# for level in 1:levels
level = 2
curves = td.split_edges(level_edges[level])
    for curve in curves
        if td.is_closed(curve)
            color = :red
        else
            color = :black
        end
        lines!(ax, [Makie.Point2(td.delaunay_unscale(vertex)...) for vertex in curve]; color)
    end
# end
fig

on_left_edge(pnt) = begin
    
end

on_right_edge(pnt) = begin
    
end

on_bottom_edge(pnt) = begin
    
end