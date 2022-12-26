using Revise
using JLD2
using Makie, LinearAlgebra, ColorSchemes, CairoMakie
import GeometricalPredicates, VoronoiDelaunay, Base, TernaryDiagrams
const td = TernaryDiagrams
const vd = VoronoiDelaunay
const gp = GeometricalPredicates

a1 = load("test/data.jld2", "a1")
a2 = load("test/data.jld2", "a2")
a3 = load("test/data.jld2", "a3")
ws = Float64.(load("test/data.jld2", "mus"))

xs, ys = td.from_bary_to_cart(a1, a2, a3)

# colormap
levels = 10

lb = minimum(ws)
ub = maximum(ws)
d = (ub - lb) / (levels + 1)
bins = [(lb + n * d) for n = 1:levels]

data_coords = td.delaunay_scale.(xs, ys)
pad_coords, pad_weights = td.generate_padded_data(data_coords, ws)
_scaled_coords = [data_coords; pad_coords]
_weights = [ws; pad_weights]

scaled_coords, weights = td.rem_repeats(_scaled_coords, _weights)

level_edges, point_directions = td.contour_triangle(scaled_coords, bins, weights, levels)

fig = Figure();
ax = Axis(fig[1, 1]);
for level = 1:levels
    # level = 5
    curves = td.split_edges(level_edges[level])
    for curve in curves
        if td.is_closed(curve)
            lines!(
                ax,
                [Makie.Point2(td.delaunay_unscale(vertex)...) for vertex in curve];
                color = :green,
            )
        else
            p1 = first(curve)
            p1_idx = argmin(norm(p1 - x.point) for x in point_directions)
            pend = last(curve)
            pend_idx = argmin(norm(pend - x.point) for x in point_directions)
            
            scatter!(
                ax,
                [
                    Makie.Point2(td.delaunay_unscale(point_directions[idx].low)...) for
                    idx in [p1_idx, pend_idx]
                ];
                color = :blue,
            )

            scatter!(
                ax,
                [
                    Makie.Point2(td.delaunay_unscale(point_directions[idx].high)...) for
                    idx in [p1_idx, pend_idx]
                ];
                color = :red,
            )

            lines!(
                ax,
                [Makie.Point2(td.delaunay_unscale(vertex)...) for vertex in curve];
                color = :black,
            )
        end
    end
end
fig

level_open_curves = Dict{Int64, Vector{td.Curve}}()
level_closed_curves = Dict{Int64, Vector{td.Curve}}()

for level in 1:levels
    for curve in td.split_edges(level_edges[level])
        if td.is_closed(curve)
            push!(get!(level_closed_curves, level, Vector{td.Curve}()), curve)
        else
            push!(get!(level_open_curves, level, Vector{td.Curve}()), curve)
        end
    end
end

td.ternaryaxis!(ax)
fig

Makie.FileIO.save("fig.pdf", fig)