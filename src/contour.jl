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
    above_isovalue(x, i) = x .>= bins[i]
    get_xy(p) = [p._x, p._y]

    scaled_coords = delaunay_scale.(xs[], ys[])

    tess = vd.DelaunayTessellation()
    vd.sizehint!(tess, length(scaled_coords))
    push!(tess, vd.Point2D[vd.Point(p...) for p in scaled_coords])

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

    for triangle in tess
        for level = 1:tr.levels[]
            a = get_xy(vd.geta(triangle))
            a_idx = argmin(norm(x - a) for x in scaled_coords)
            a_above = above_isovalue(ws[][a_idx], level)

            b = get_xy(vd.getb(triangle))
            b_idx = argmin(norm(x - b) for x in scaled_coords)
            b_above = above_isovalue(ws[][b_idx], level)

            c = get_xy(vd.getc(triangle))
            c_idx = argmin(norm(x - c) for x in scaled_coords)
            c_above = above_isovalue(ws[][c_idx], level)

            p_ab = nothing
            if a_above && !b_above || !a_above && b_above
                p_ab = interp_point(ws[][a_idx], ws[][b_idx], a, b, level)
            end
            p_ac = nothing
            if a_above && !c_above || !a_above && c_above
                p_ac = interp_point(ws[][a_idx], ws[][c_idx], a, c, level)
            end
            p_bc = nothing
            if b_above && !c_above || !b_above && c_above
                p_bc = interp_point(ws[][b_idx], ws[][c_idx], b, c, level)
            end

            if isnothing(p_ab) && !isnothing(p_ac) && !isnothing(p_bc)
                lines!(
                    tr,
                    [
                        Point2(delaunay_unscale(p_ac...)...),
                        Point2(delaunay_unscale(p_bc...)...),
                    ],
                    color = isnothing(tr.color[]) ?
                            get(tr.colormap[], bins[level], (lb, ub)) : tr.color,
                    linewidth = tr.linewidth,
                    linestyle = tr.linestyle,
                )
            elseif isnothing(p_ac) && !isnothing(p_ab) && !isnothing(p_bc)
                lines!(
                    tr,
                    [
                        Point2(delaunay_unscale(p_ab...)...),
                        Point2(delaunay_unscale(p_bc...)...),
                    ],
                    color = isnothing(tr.color[]) ?
                            get(tr.colormap[], bins[level], (lb, ub)) : tr.color,
                    linewidth = tr.linewidth,
                    linestyle = tr.linestyle,
                )
            elseif isnothing(p_bc) && !isnothing(p_ac) && !isnothing(p_ab)
                lines!(
                    tr,
                    [
                        Point2(delaunay_unscale(p_ac...)...),
                        Point2(delaunay_unscale(p_ab...)...),
                    ],
                    color = isnothing(tr.color[]) ?
                            get(tr.colormap[], bins[level], (lb, ub)) : tr.color,
                    linewidth = tr.linewidth,
                    linestyle = tr.linestyle,
                )
            end
        end
    end


    tr
end
