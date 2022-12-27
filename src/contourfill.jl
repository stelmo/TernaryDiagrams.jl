function Makie.plot!(tr::TernaryContourf)

    # create observables
    xs = Observable(Float64[])
    ys = Observable(Float64[])
    ws = Observable(Float64[])

    function update_plot(in_xs, in_ys, in_zs, in_ws)
        empty!(xs[])
        empty!(ys[])
        empty!(ws[])

        _xs = Float64[]
        _ys = Float64[]
        _ws = Float64[]
        for (x, y, z, w) in zip(in_xs, in_ys, in_zs, in_ws)
            carts = R * [x, y, z]
            push!(_xs, carts[2])
            push!(_ys, carts[3])
            push!(_ws, w)
        end

        # always pad data to make filling easier
        data_coords = delaunay_scale.([gp.Point2D.(x, y) for (x, y) in zip(_xs, _ys)])
        pad_coords, pad_weights = generate_padded_data(data_coords, _ws)
        _scaled_coords = [data_coords; pad_coords]
        _weights = [_ws; pad_weights]

        scaled_coords, weights = rem_repeats(_scaled_coords, _weights)

        append!(xs[], [first(unpack(delaunay_unscale(p))) for p in scaled_coords])
        append!(ys[], [last(unpack(delaunay_unscale(p))) for p in scaled_coords])
        append!(ws[], weights)
    end
    Makie.Observables.onany(update_plot, tr[:x], tr[:y], tr[:z], tr[:w])
    update_plot(tr[:x][], tr[:y][], tr[:z][], tr[:w][])

    # thanks Makie!
    tricontourf!(tr, xs, ys, ws; levels = tr.levels[], colormap = tr.colormap[])

    tr
end
