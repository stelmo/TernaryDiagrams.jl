function generate_padded_data(xs, ys, ws)
    pad_coords = [
        td.delaunay_scale(td.from_bary_to_cart(a1, a2, 1.0 - a1 - a2)...) for
        a1 = 0:0.1:1 for a2 = 0:0.1:1 if 1.0 - a1 - a2 >= 0
    ]

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
    above_isovalue(x, i) = x >= bins[i]

    if tr.pad_data[]
        data_coords = delaunay_scale.(xs[], ys[])
        pad_coords, pad_weights = generate_padded_data(xs[], ys[], ws[])
        scaled_coords = [data_coords; pad_coords]
        weights = [ws[]; pad_weights]
    else
        scaled_coords = delaunay_scale.(xs[], ys[])
        weights = ws[]
    end

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
        for level = 1:tr.levels[]
            a = gp.geta(triangle)
            a_idx = argmin(norm(x - a) for x in scaled_coords)
            a_above = above_isovalue(weights[a_idx], level)

            b = gp.getb(triangle)
            b_idx = argmin(norm(x - b) for x in scaled_coords)
            b_above = above_isovalue(weights[b_idx], level)

            c = gp.getc(triangle)
            c_idx = argmin(norm(x - c) for x in scaled_coords)
            c_above = above_isovalue(weights[c_idx], level)

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

    for level = 1:tr.levels[]
        for edge in level_edges[level]
            lines!(
                tr,
                [Point2(delaunay_unscale(pnt)...) for pnt in edge],
                color = isnothing(tr.color[]) ? get(tr.colormap[], bins[level], (lb, ub)) :
                        tr.color,
                linewidth = tr.linewidth,
                linestyle = tr.linestyle,
            )
        end
    end

    tr
end
