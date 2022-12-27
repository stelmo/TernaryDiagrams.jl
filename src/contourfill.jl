function Makie.plot!(tr::TernaryContourf)

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

    # always pad data to make filling easier
    data_coords = delaunay_scale.([gp.Point2D.(x,y) for (x,y) in zip(xs[], ys[])])
    pad_coords, pad_weights = generate_padded_data(data_coords, ws[])
    _scaled_coords = [data_coords; pad_coords]
    _weights = [ws[]; pad_weights]

    scaled_coords, weights = rem_repeats(_scaled_coords, _weights)

    level_edges, point_directions = contour_triangle(scaled_coords, bins, weights, tr.levels[])
    level_open_curves = Dict{Int64, Vector{Curve}}()
    level_closed_curves = Dict{Int64, Vector{Curve}}()

    for level in 1:tr.levels[]
        for curve in split_edges(level_edges[level])
            if is_closed(curve)
                push!(get!(level_closed_curves, level, Vector{Curve}()), curve)
            else
                push!(get!(level_open_curves, level, Vector{Curve}()), curve)
            end
        end
    end

    # draw

    for level in 1:tr.levels[]

    end
    tr
end

# poly!(
#     tr,
#     [Point2f(delaunay_unscale(vertex)...) for vertex in curve],
#     color = get(tr.colormap[], bins[level], (lb, ub)),
# )


# lines!(
#     tr,
#     [Point2f(delaunay_unscale(vertex)...) for vertex in curve],
#     color = get(tr.colormap[], bins[level], (lb, ub)),
# )
