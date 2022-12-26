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
levels = 5

lb = minimum(ws)
ub = maximum(ws)
d = (ub - lb) / (levels + 1)
bins = [(lb + n * d) for n = 1:levels]

data_coords = td.delaunay_scale.(xs, ys)
pad_coords, pad_weights = td.generate_padded_data(data_coords, ws)
scaled_coords = [data_coords; pad_coords]
weights = [ws; pad_weights]

level_edges, pdirs = td.contour_triangle(scaled_coords, bins, weights, levels)

fig = Figure();
ax = Axis(fig[1, 1]);
for level = 1:levels
    # level = 5
    curves = td.split_edges(level_edges[level])
    for curve in curves
        td.is_closed(curve) && continue

        p1 = first(curve)
        p1_idx = argmin(norm(p1 - x.p) for x in pdirs)
        pend = last(curve)
        pend_idx = argmin(norm(pend - x.p) for x in pdirs)

        scatter!(
            ax,
            [
                Makie.Point2(td.delaunay_unscale(pdirs[idx].low)...) for
                idx in [p1_idx, pend_idx]
            ];
            color = :blue,
        )

        scatter!(
            ax,
            [
                Makie.Point2(td.delaunay_unscale(pdirs[idx].high)...) for
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
fig

const r1 = [0, 0]
const r2 = [1, 0]
const r3 = [0.5, sqrt(3) / 2]

on_left_edge(pnt) = begin
    # from (0,0) to (0.5, sqrt(3)/2)
end

on_right_edge(pnt) = begin
    # from (1,0) to (0.5, sqrt(3)/2)

end

on_bottom_edge(pnt) = begin
    # from (0,0) to (1,0)
    abs(pnt._y) <= TOL && -TOL <= pnt._x <= 1.0 + TOL
end
