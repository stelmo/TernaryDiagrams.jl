#=
Various functions used by the contour and contourf functions to draw the isolines and isobands.
=#

"""
Represents an straight line edge by two points.
"""
struct Edge
    a::gp.Point2D
    b::gp.Point2D
end
Base.first(edge::Edge) = edge.a
Base.last(edge::Edge) = edge.b

"""
Represents the orientation of a `point` by indicating the position of the `low`
and `high` weight used to construct the edge associated with the point.
"""
struct PointDirection
    point::gp.Point2D
    low::gp.Point2D
    high::gp.Point2D
end

const Curve = Vector{gp.Point2D} # a curve is a collection of points

"""
Generate coordinates along the edges of the triangle. Interpolates weights based
on nearest known weight.
"""
function generate_padded_data(data_coords, ws)
    pad_coords = [
        delaunay_scale(from_bary_to_cart(a1, a2, 1.0 - a1 - a2)...) for a1 = 0:0.1:1 for
        a2 = 0:0.1:1 if 1.0 - a1 - a2 >= 0
    ]
    pad_weights = Float64[]

    for p in pad_coords # TODO use nearest neighbor interpolant instead
        ds = [norm(p - x) for x in data_coords]
        idxs = sortperm(ds)[1:15] # this can be optimized
        dtot = sum(ds[idxs])
        w = sum(ws[idx] * ds[idx] / dtot for idx in idxs)
        push!(pad_weights, w)

        # idx = argmin(ds)
        # push!(pad_weights, ws[idx])
    end

    pad_coords, pad_weights
end

"""
Returns true if `edge` can be connected to the ends of the `curve`.
"""
function edge_in_curve(edge, curve)
    for curve_edge in curve
        if norm(first(curve_edge) - first(edge)) < TOL ||
           norm(last(curve_edge) - last(edge)) < TOL ||
           norm(first(curve_edge) - last(edge)) < TOL ||
           norm(last(curve_edge) - first(edge)) < TOL
            return true
        end
    end
    false
end

"""
Groups edges into curves of points by stitching them together at the ends if
possible. Can generate multiple curves if segments cannot be joined.
"""
function split_edges(edges::Vector{Edge})
    curves = Vector{Curve}() # each inner vector is a vector of points that define a curve
    _edge = first(edges)
    push!(curves, [_edge.a, _edge.b]) # initialize first seed
    edge_idxs = collect(2:length(edges)) #  edges left to group

    while !isempty(edge_idxs)
        used_edge_idx = 0
        for (i, e_idx) in enumerate(edge_idxs)
            edge = edges[e_idx]
            for (c_idx, curve) in enumerate(curves)
                if norm(last(curve) - first(edge)) < TOL # from global tolerance
                    curves[c_idx] = [curve; last(edge)]
                    used_edge_idx = i
                    break
                elseif norm(last(curve) - last(edge)) < TOL
                    curves[c_idx] = [curve; first(edge)]
                    used_edge_idx = i
                    break
                elseif norm(first(curve) - last(edge)) < TOL
                    curves[c_idx] = [first(edge); curve]
                    used_edge_idx = i
                    break
                elseif norm(first(curve) - first(edge)) < TOL
                    curves[c_idx] = [last(edge); curve]
                    used_edge_idx = i
                    break
                end
            end
            used_edge_idx != 0 && break
        end
        if used_edge_idx == 0 # could not join anything, create another seed
            i = first(edge_idxs)
            push!(curves, [edges[i].a, edges[i].b])
            deleteat!(edge_idxs, 1)
        else
            deleteat!(edge_idxs, used_edge_idx)
        end
    end
    curves
end

"""
Is weight `w` bigger than the bin at index `i` in  `bins`.
"""
above_isovalue(w, i, bins) = w >= bins[i]

"""
Use Delaunay triangles to draw contours based on input data `scaled_coords`. The
`weights` are assigned to `bins` which are composed of n-`levels`. 
"""
function contour_triangle(scaled_coords, bins, weights, levels)
    tess = vd.DelaunayTessellation()
    vd.sizehint!(tess, length(scaled_coords))
    push!(tess, [x for x in scaled_coords]) # NB: this modifies the second argument in place!

    """
    Interpolate between the vertices of an edge, and return a point that is
    between them, weighted by the value of the threshold for the isocline.
    """
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

    level_edges = Dict{Int64,Vector{Edge}}()
    orientation_points = Vector{PointDirection}()
    for triangle in tess
        for level = 1:levels
            a = gp.geta(triangle)
            a_idx = argmin(norm(x - a) for x in scaled_coords)
            a_above = above_isovalue(weights[a_idx], level, bins)

            b = gp.getb(triangle)
            b_idx = argmin(norm(x - b) for x in scaled_coords)
            b_above = above_isovalue(weights[b_idx], level, bins)

            c = gp.getc(triangle)
            c_idx = argmin(norm(x - c) for x in scaled_coords)
            c_above = above_isovalue(weights[c_idx], level, bins)

            p_ab = nothing
            if (a_above && !b_above) || (!a_above && b_above)
                p_ab = interp_point(weights[a_idx], weights[b_idx], a, b, level)
            end
            p_ac = nothing
            if (a_above && !c_above) || (!a_above && c_above)
                p_ac = interp_point(weights[a_idx], weights[c_idx], a, c, level)
            end
            p_bc = nothing
            if (b_above && !c_above) || (!b_above && c_above)
                p_bc = interp_point(weights[b_idx], weights[c_idx], b, c, level)
            end

            if isnothing(p_ab) && !isnothing(p_ac) && !isnothing(p_bc)
                push!(get!(level_edges, level, Vector{Edge}()), Edge(p_ac, p_bc))
                push!(
                    orientation_points,
                    PointDirection(p_ac, (a_above ? (c, a) : (a, c))...),
                )
                push!(
                    orientation_points,
                    PointDirection(p_bc, (b_above ? (c, b) : (b, c))...),
                )
            elseif isnothing(p_ac) && !isnothing(p_ab) && !isnothing(p_bc)
                push!(get!(level_edges, level, Vector{Edge}()), Edge(p_ab, p_bc))
                push!(
                    orientation_points,
                    PointDirection(p_ab, (a_above ? (b, a) : (a, b))...),
                )
                push!(
                    orientation_points,
                    PointDirection(p_bc, (b_above ? (c, b) : (b, c))...),
                )
            elseif isnothing(p_bc) && !isnothing(p_ac) && !isnothing(p_ab)
                push!(get!(level_edges, level, Vector{Edge}()), Edge(p_ac, p_ab))
                push!(
                    orientation_points,
                    PointDirection(p_ac, (a_above ? (c, a) : (a, c))...),
                )
                push!(
                    orientation_points,
                    PointDirection(p_ab, (b_above ? (a, b) : (b, a))...),
                )
            end
        end
    end

    level_edges, orientation_points
end

"""
Determine if a `curve` is closed, i.e. its ends join.
"""
is_closed(curve) = norm(first(curve) - last(curve)) < TOL
