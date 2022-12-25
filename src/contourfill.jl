is_closed(curve) = norm(first(curve) - last(curve)) < tol

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
    cc = 0
    for level = 1:tr.levels[]
        for curve in split_edges(level_edges[level])
            if is_closed(curve)
                cc += 1
                # poly!(
                #     tr,
                #     [Point2f(delaunay_unscale(vertex)...) for vertex in [last(curve); curve]],
                #     color = get(tr.colormap[], bins[level], (lb, ub))
                # )

                lines!(
                    tr,
                    [Point2(delaunay_unscale(vertex)...) for vertex in curve],
                    color = isnothing(tr.color[]) ?
                            get(tr.colormap[], bins[level], (lb, ub)) : tr.color,
                    linewidth = tr.linewidth,
                    linestyle = tr.linestyle,
                )
            else

            end
        end
    end
    @info "num cc = $cc"
    tr
end
