function generate_padded_data(data_coords, ws)
    pad_coords = [
        delaunay_scale(from_bary_to_cart(a1, a2, 1.0 - a1 - a2)...) for a1 = 0:0.1:1 for
        a2 = 0:0.1:1 if 1.0 - a1 - a2 >= 0
    ]
    pad_weights = Float64[]

    for p in pad_coords
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

function edge_in_curve(edge, curve)
    for curve_edge in curve
        if norm(first(curve_edge) - first(edge)) < tol ||
           norm(last(curve_edge) - last(edge)) < tol ||
           norm(first(curve_edge) - last(edge)) < tol ||
           norm(last(curve_edge) - first(edge)) < tol
            return true
        end
    end
    false
end

function split_edges(edges::Vector{Vector{gp.Point2D}})
    curves = Vector{Vector{gp.Point2D}}()
    push!(curves, first(edges)) # initialize
    edge_idxs = collect(2:length(edges)) #  edges left to group

    while !isempty(edge_idxs)
        used_edge_idx = 0
        for (i, e_idx) in enumerate(edge_idxs)
            edge = edges[e_idx]
            for (c_idx, curve) in enumerate(curves)
                if norm(last(curve) - first(edge)) < tol
                    curves[c_idx] = [curve; last(edge)]
                    used_edge_idx = i
                    break
                elseif norm(last(curve) - last(edge)) < tol
                    curves[c_idx] = [curve; first(edge)]
                    used_edge_idx = i
                    break
                elseif norm(first(curve) - last(edge)) < tol
                    curves[c_idx] = [first(edge); curve]
                    used_edge_idx = i
                    break
                elseif norm(first(curve) - first(edge)) < tol
                    curves[c_idx] = [last(edge); curve]
                    used_edge_idx = i
                    break
                end
            end
            used_edge_idx != 0 && break
        end
        if used_edge_idx == 0
            i = first(edge_idxs)
            push!(curves, edges[i])
            deleteat!(edge_idxs, 1)
        else
            deleteat!(edge_idxs, used_edge_idx)
        end
    end
    curves
end

above_isovalue(x, i, bins) = x >= bins[i]

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

    level_edges = Dict{Int64,Vector{Vector{gp.Point2D}}}()
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
                edge = [p_ac, p_bc]
                push!(get!(level_edges, level, Vector{Vector{gp.Point2D}}()), edge)
            elseif isnothing(p_ac) && !isnothing(p_ab) && !isnothing(p_bc)
                edge = [p_ab, p_bc]
                push!(get!(level_edges, level, Vector{Vector{gp.Point2D}}()), edge)
            elseif isnothing(p_bc) && !isnothing(p_ac) && !isnothing(p_ab)
                edge = [p_ac, p_ab]
                push!(get!(level_edges, level, Vector{Vector{gp.Point2D}}()), edge)
            end
        end
    end
    level_edges
end

function Makie.plot!(tr::TernaryContour)

    # create observables
    xs = Observable(Float64[])
    ys = Observable(Float64[])
    ws = Observable(Float64[])

    function update_plot(_xs, _ys, _zs, _ws)
        empty!(xs[])
        empty!(ys[])
        empty!(ws[])
        for (x, y, z, w) in zip(_xs, _ys, _zs, _ws)
            carts = R * [x, y, z]
            push!(xs[], carts[2])
            push!(ys[], carts[3])
            push!(ws[], w)
        end
    end
    Makie.Observables.onany(update_plot, tr[:x], tr[:y], tr[:z], tr[:w])
    update_plot(tr[:x][], tr[:y][], tr[:z][], tr[:w][])

    # male bins for levels
    lb = max(minimum(ws[]), tr.clip_min_w[])
    ub = min(maximum(ws[]), tr.clip_max_w[])
    d = (ub - lb) / (tr.levels[] + 1)
    bins = [(lb + n * d) for n = 1:tr.levels[]]

    if tr.pad_data[]
        data_coords = delaunay_scale.(xs[], ys[])
        pad_coords, pad_weights = generate_padded_data(data_coords, ws[])
        scaled_coords = [data_coords; pad_coords]
        weights = [ws[]; pad_weights]
    else
        scaled_coords = delaunay_scale.(xs[], ys[])
        weights = ws[]
    end

    level_edges = contour_triangle(scaled_coords, bins, weights, tr.levels[])

    for level = 1:tr.levels[]
        for curve in split_edges(level_edges[level])
            lines!(
                tr,
                [Point2(delaunay_unscale(vertex)...) for vertex in curve],
                color = isnothing(tr.color[]) ? get(tr.colormap[], bins[level], (lb, ub)) :
                        tr.color,
                linewidth = tr.linewidth,
                linestyle = tr.linestyle,
            )
        end
    end

    tr
end
