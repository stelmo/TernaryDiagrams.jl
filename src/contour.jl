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

    # make bins for levels
    lb = max(minimum(ws[]), tr.clip_min_w[])
    ub = min(maximum(ws[]), tr.clip_max_w[])
    d = (ub - lb) / (tr.levels[] + 1)
    bins = [(lb + n * d) for n = 1:tr.levels[]]

    if tr.pad_data[]
        data_coords = delaunay_scale.([gp.Point2D.(x, y) for (x, y) in zip(xs[], ys[])])
        pad_coords, pad_weights = generate_padded_data(data_coords, ws[])
        _scaled_coords = [data_coords; pad_coords]
        _weights = [ws[]; pad_weights]
    else
        _scaled_coords = delaunay_scale.([gp.Point2D.(x, y) for (x, y) in zip(xs[], ys[])])
        _weights = ws[]
    end

    scaled_coords, weights = rem_repeats(_scaled_coords, _weights)

    level_edges, _ = contour_triangle(scaled_coords, bins, weights, tr.levels[])

    for level = 1:tr.levels[]
        for curve in split_edges(level_edges[level])
            lines!(
                tr,
                [Point2(unpack(delaunay_unscale(vertex))...) for vertex in curve],
                color = isnothing(tr.color[]) ? get(tr.colormap[], bins[level], (lb, ub)) :
                        tr.color,
                linewidth = tr.linewidth,
                linestyle = tr.linestyle,
            )
        end
    end

    tr
end
