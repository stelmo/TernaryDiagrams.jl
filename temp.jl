using Revise
using CairoMakie
using ColorSchemes
using TernaryDiagrams
const td = TernaryDiagrams
using GeometricalPredicates, VoronoiDelaunay, LinearAlgebra, Interpolations
const vd = VoronoiDelaunay
using JLD2


a1 = load("data.jld2", "a1")
a2 = load("data.jld2", "a2")
a3 = load("data.jld2", "a3")
vs = Float64.(load("data.jld2", "mus"))

xs, ys = td.from_bary_to_cart(a1, a2, a3)

# colormap
colscheme = reverse(ColorSchemes.Spectral)
_lb, _ub = extrema(vs)
lb = _lb # max(_lb, tr.min_val[])
ub = _ub # min(_ub, tr.max_val[])
ncolors = length(colscheme) # length(tr.color[])
d = (ub - lb) / (ncolors + 1)
bins = [(lb + n * d) for n = 1:ncolors]
above_isovalue(x, i) = x .>= bins[i]
get_xy(p) = [p._x, p._y]

scaled_coords = td.delaunay_scale.(xs, ys)

tess = DelaunayTessellation()
sizehint!(tess, length(scaled_coords))
push!(tess, Point2D[vd.Point(p...) for p in scaled_coords])

fig = Figure();
ax = Axis(fig[1, 1]);

for edge in delaunayedges(tess)
    a = geta(edge)
    b = getb(edge)
    Makie.lines!(
        ax,
        [
            Point2(td.delaunay_unscale(get_xy(a)...)...),
            Point2(td.delaunay_unscale(get_xy(b)...)...),
        ],
    )
end

level = 1
for (p, v) in zip(scaled_coords, vs)
    # scatter!(ax, [Makie.Point2(td.delaunay_unscale(p...)...),]; color = above_isovalue(v, level) ? :red : :black)

    scatter!(
        ax,
        [Makie.Point2(td.delaunay_unscale(p...)...)];
        color = get(colscheme, v, (lb, ub)),
    )
end

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

level_dpoints = Dict{Int64,Vector{Tuple{Vector{Float64},Vector{Float64}}}}()
for triangle in tess
    for level = 1:ncolors
        a = get_xy(geta(triangle))
        a_idx = argmin(norm(x - a) for x in scaled_coords)
        a_above = above_isovalue(vs[a_idx], level)

        b = get_xy(getb(triangle))
        b_idx = argmin(norm(x - b) for x in scaled_coords)
        b_above = above_isovalue(vs[b_idx], level)

        c = get_xy(getc(triangle))
        c_idx = argmin(norm(x - c) for x in scaled_coords)
        c_above = above_isovalue(vs[c_idx], level)

        p_ab = nothing
        if a_above && !b_above || !a_above && b_above
            p_ab = interp_point(vs[a_idx], vs[b_idx], a, b, level)
        end
        p_ac = nothing
        if a_above && !c_above || !a_above && c_above
            p_ac = interp_point(vs[a_idx], vs[c_idx], a, c, level)
        end
        p_bc = nothing
        if b_above && !c_above || !b_above && c_above
            p_bc = interp_point(vs[b_idx], vs[c_idx], b, c, level)
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
            push!(
                get!(level_dpoints, level, []),
                (
                    Point2(td.delaunay_unscale(p_ac...)...),
                    Point2(td.delaunay_unscale(p_bc...)...),
                ),
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
            push!(
                get!(level_dpoints, level, []),
                (
                    Point2(td.delaunay_unscale(p_ab...)...),
                    Point2(td.delaunay_unscale(p_bc...)...),
                ),
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
            push!(
                get!(level_dpoints, level, []),
                (
                    Point2(td.delaunay_unscale(p_ac...)...),
                    Point2(td.delaunay_unscale(p_ab...)...),
                ),
            )
        end
    end
end


td.ternaryaxis!(ax; labelx = "hello");

fig

##############
