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

    tr
end
