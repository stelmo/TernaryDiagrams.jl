using Revise
using JLD2
using Makie, LinearAlgebra, ColorSchemes, DocStringExtensions
using CairoMakie
import GeometricalPredicates, VoronoiDelaunay, Interpolations, Base, TernaryDiagrams
const vd = VoronoiDelaunay
const gp = GeometricalPredicates
const td = TernaryDiagrams

a1 = load("test/data.jld2", "a1")[1:10]
a2 = load("test/data.jld2", "a2")[1:10]
a3 = load("test/data.jld2", "a3")[1:10]
ws = Float64.(load("test/data.jld2", "mus"))[1:10]

xs, ys = td.from_bary_to_cart(a1, a2, a3)

# colormap
levels = 5
clip_min_w = -Inf
clip_max_w = Inf

lb = max(minimum(ws), clip_min_w)
ub = min(maximum(ws), clip_max_w)
d = (ub - lb) / (levels + 1)
bins = [(lb + n * d) for n = 1:levels]
above_isovalue(x, i) = x >= bins[i]

scaled_coords = [td.delaunay_scale.(x, y) for (x, y) in zip(xs, ys)]
td.delaunay_unscale(first(scaled_coords))

tess = vd.DelaunayTessellation()
# vd.sizehint!(tess, length(scaled_coords))
push!(tess, [x for x in scaled_coords])

fig = Figure();
ax = Axis(fig[1, 1]);
td.ternaryaxis!(ax; labelx = "hello");

for edge in vd.delaunayedges(tess)
    a = gp.geta(edge)
    b = gp.getb(edge)
    Makie.lines!(ax, [Point2(td.delaunay_unscale(a)...), Point2(td.delaunay_unscale(b)...)])
end
fig

level = 3
for (pnt, v) in zip(scaled_coords, ws)
    x, y = td.delaunay_unscale(pnt)
    # for (x, y, v) in zip(xs, ys, ws)
    Makie.scatter!(ax, [x], [y]; color = above_isovalue(v, level) ? :red : :black)
end
fig

interp_point(_high_v, _low_v, _p_high, _p_low, level) = begin
    if _high_v > _low_v
        high_v = _high_v
        low_v = _low_v
        p_high = _p_high
        p_low = _p_low
    else
        high_v = _low_v
        low_v = _high_v
        p_high = _p_low
        p_low = _p_high
    end

    frac = (bins[level] - low_v) / (high_v - low_v)
    d = p_high - p_low
    return d * frac + p_low
end

for triangle in tess

    a = td.get_xy(gp.geta(triangle))
    a_idx = argmin(norm(td.get_xy(x) - a) for x in scaled_coords)
    a_above = above_isovalue(ws[a_idx], level)

    b = td.get_xy(gp.getb(triangle))
    b_idx = argmin(norm(td.get_xy(x) - b) for x in scaled_coords)
    b_above = above_isovalue(ws[b_idx], level)

    c = td.get_xy(gp.getc(triangle))
    c_idx = argmin(norm(td.get_xy(x) - c) for x in scaled_coords)
    c_above = above_isovalue(ws[c_idx], level)

    p_ab = nothing
    if (a_above && !b_above) || (!a_above && b_above)
        p_ab = interp_point(ws[a_idx], ws[b_idx], a, b, level)
    end
    p_ac = nothing
    if (a_above && !c_above) || (!a_above && c_above)
        p_ac = interp_point(ws[a_idx], ws[c_idx], a, c, level)
    end
    p_bc = nothing
    if (b_above && !c_above) || (!b_above && c_above)
        p_bc = interp_point(ws[b_idx], ws[c_idx], b, c, level)
    end

    if isnothing(p_ab) && !isnothing(p_ac) && !isnothing(p_bc)
        Makie.lines!(
            ax,
            [
                Point2(td.delaunay_unscale(p_ac...)...),
                Point2(td.delaunay_unscale(p_bc...)...),
            ],
            color = :black,
        )

    elseif isnothing(p_ac) && !isnothing(p_ab) && !isnothing(p_bc)
        Makie.lines!(
            ax,
            [
                Point2(td.delaunay_unscale(p_ab...)...),
                Point2(td.delaunay_unscale(p_bc...)...),
            ],
            color = :black,
        )

    elseif isnothing(p_bc) && !isnothing(p_ac) && !isnothing(p_ab)
        Makie.lines!(
            ax,
            [
                Point2(td.delaunay_unscale(p_ac...)...),
                Point2(td.delaunay_unscale(p_ab...)...),
            ],
            color = :black,
        )
    end
end

fig

##############
