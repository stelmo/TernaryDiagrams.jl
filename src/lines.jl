function Makie.plot!(tr::TernaryLines)

    # create observables
    dpoints = Observable(Point2[])

    function update_plot(xs, ys, zs)
        empty!(dpoints[])
        for (x, y, z) in zip(xs, ys, zs)
            carts = R * [x, y, z]
            push!(dpoints[], Point2(carts[2], carts[3]))
        end
    end

    Makie.Observables.onany(update_plot, tr[:x], tr[:y], tr[:z])

    update_plot(tr[:x][], tr[:y][], tr[:z][])

    # plot data points
    lines!(
        tr,
        dpoints,
        color = tr.color[],
        linewidth = tr.linewidth[],
        linestyle = tr.linestyle[],
    )

    tr
end
