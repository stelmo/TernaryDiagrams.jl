function draw_triangle_base!(tr::TernaryAxis)
    lines!(tr, [Point2(r1...), Point2(r2...), Point2(r3...), Point2(r1...)], color = :black)
end

function draw_triangle_vertex_labels!(tr::TernaryAxis)
    y_adj = tr.label_vertex_vertical_adjustment[]
    text!(
        tr,
        Point2(r3...) + Point(0, y_adj);
        text = tr.zlabel,
        align = (:center, :center),
        fontsize = tr.label_fontsize[],
    )
    text!(
        tr,
        Point2(r2...) + Point(0, -y_adj);
        text = tr.ylabel,
        align = (:left, :center),
        fontsize = tr.label_fontsize[],
    )
    text!(
        tr,
        Point2(r1...) + Point2(0, -y_adj);
        text = tr.xlabel,
        align = (:right, :center),
        fontsize = tr.label_fontsize[],
    )
end

function Makie.bracket_bezierpath(::Val{:line}, p1, p2, d, width)
    p12 = 0.5 * (p1 + p2) + width * d

    c1 = p1 + width * d
    c2 = p2 + width * d

    b = BezierPath([
        MoveTo(c1),
        LineTo(c2),
    ])

    return b, p12
end

function Makie.bracket_bezierpath(::Val{:arrow}, p1, p2, d, width)

    θ = π/5

    p12 = 0.5 * (p1 + p2) + width * d

    c1 = p1 + width * d
    c2 = p2 + width * d
    arrow_disp = (c2-c1) * 0.03
    a1 = -Makie.Mat2f(cos(θ), sin(θ), -sin(θ), cos(θ)) * arrow_disp + c2
    a2 = -Makie.Mat2f(cos(-θ), sin(-θ), -sin(-θ), cos(-θ)) * arrow_disp + c2

    b = BezierPath([
        MoveTo(c1),
        LineTo(c2),
        LineTo(a1),
        MoveTo(c2),
        LineTo(a2),
    ])

    return b, p12
end
Makie.data_limits(pl::Bracket) = mapreduce(union, pl[1][]) do points
    Rect3f([points...])
end

triangle_gridline(f1, dim::Int) = triangle_gridline(f1, Val(dim))

function triangle_gridline(f1, ::Val{Dim}) where Dim
    f2 = 1 - f1
    local vec1, vec2
    if Dim == 1
        vec1 = [f1, f2, 0]
        vec2 = [f1, 0, f2]
    elseif Dim == 2
        vec1 = [0, f2, f1]
        vec2 = [f1, f2, 0]
    elseif Dim == 3
        vec1 = [f2, 0, f1]
        vec2 = [0, f2, f1]
    end

    return [Point2f((R * vec1)[2:3]), Point2f((R * vec2)[2:3])]

end

dimsym(sym, ::Val{1}) = Symbol(:x, sym)
dimsym(sym, ::Val{2}) = Symbol(:y, sym)
dimsym(sym, ::Val{3}) = Symbol(:z, sym)

triangle_arrow_scalevec(::Val{1}) = -Point2f(r2)
triangle_arrow_scalevec(::Val{2}) = -Point2f(r3 .- r2)
triangle_arrow_scalevec(::Val{3}) = Point2f(r3)

function draw_dim_axis!(tr::TernaryAxis, dim::Val{Dim}) where Dim

    # set up observables
    tickvals = Observable(Vector{Real}())
    ticklabels = Observable(Vector{Any}())
    ticklabelpositions = Observable(Vector{Point2f}())
    gridpoints = Observable(Vector{Point2f}())
    minorgridpoints = Observable(Vector{Point2f}())

    # lift to get ticks etc
    lift(tr[dimsym(:ticks, dim)], identity, tr[dimsym(:tickformat, dim)], 0, 1) do ticks, scale, format, vmin, vmax
        empty!(tickvals.val); empty!(ticklabels.val); empty!(ticklabelpositions.val); empty!(gridpoints.val)

        _tickvals, _ticklabels = Makie.get_ticks(ticks, scale, format, vmin, vmax)
        tickvals.val = _tickvals
        ticklabels.val = _ticklabels
        
        gridline_points = triangle_gridline.(_tickvals, dim)
        gridpoints.val = vcat(gridline_points...)
        origin_points = first.(gridline_points)
        ticklabelpositions.val = Point2f.(sincos.(atan.((p -> p[2]/p[1]).((last.(gridline_points) .- origin_points))))) .* 0.025 .* (Dim == 1 ? -1 : 1) .+ origin_points

        notify(tickvals); notify(ticklabels); notify(ticklabelpositions); notify(gridpoints)
    end

    lift(tickvals, tr[dimsym(:minorticks, dim)]) do tickvals, minorticks
        
        minortickvals = Makie.get_minor_tickvalues(minorticks, identity, tickvals, 0, 1)

        minorgridpoints[] = vcat(triangle_gridline.(minortickvals, dim)...)
    end

    # plot everything we can (spines, ticks, etc)
    spineplot = linesegments!(
        tr, triangle_gridline(0, dim);
        color = tr[dimsym(:spinecolor, dim)], linewidth = tr[dimsym(:spinewidth, dim)], style = tr[dimsym(:spinestyle, dim)], 
        visible = tr[dimsym(:spinevisible, dim)]
    )

    gridplot = linesegments!(
        tr, gridpoints; 
        color = tr[dimsym(:gridcolor, dim)], linewidth = tr[dimsym(:gridwidth, dim)], style = tr[dimsym(:gridstyle, dim)], 
        visible = tr[dimsym(:gridvisible, dim)]
    )

    minorgridplot = linesegments!(
        tr, minorgridpoints; 
        color = tr[dimsym(:minorgridcolor, dim)], linewidth = tr[dimsym(:minorgridwidth, dim)], style = tr[dimsym(:minorgridstyle, dim)], 
        visible = tr[dimsym(:minorgridvisible, dim)]
    )

    ticklabelplot = text!(
        tr, ticklabelpositions; 
        text = ticklabels, fontsize = tr[dimsym(:ticklabelsize, dim)], rotation = tr[dimsym(:ticklabelrotation, dim)], 
        color = tr[dimsym(:ticklabelcolor, dim)], font = tr[dimsym(:ticklabelfont, dim)],
        align = tr[dimsym(:ticklabelalign, dim)]
    )

    # finally, plot the arrow and its label as a bracket

    x0, y0 = Point2f((R * circshift([0.3, 0.7, 0.0], Dim-1))[2:3])

    labeltext_bbox = @lift(Makie.boundingbox($(ticklabelplot.plots[1][1]), fill(Point3f(0), length($(ticklabelplot.plots[1][1]))), fill(to_rotation(0), length($(ticklabelplot.plots[1][1])))))

    arrowplot = bracket!(
        tr, 
        Point2f(x0, y0), @lift(Point2f(x0, y0) + triangle_arrow_scalevec(dim) * $(tr.arrow_scale));
        text = tr[dimsym(:label, dim)],
        width = @lift(maximum(widths($labeltext_bbox)) + $(tr[dimsym(:ticklabelpad, dim)])),
        orientation = Dim == 1 ? :down : :up,
        style = :arrow,
        fontsize = tr.arrow_label_fontsize,
        linestyle = :solid,
        xautolimits = false,
        yautolimits = false,
        inspectable = false,
    )

    return (spineplot, gridplot, minorgridplot, ticklabelplot, arrowplot)


end

function draw_triangle_axis!(tr::TernaryAxis)

    # draw individual axes

    xspineplot, xgridplot, xminorgridplot, xticklabelplot, xarrowplot = draw_dim_axis!(tr, Val(1))
    yspineplot, ygridplot, yminorgridplot, yticklabelplot, yarrowplot = draw_dim_axis!(tr, Val(2))
    zspineplot, zgridplot, zminorgridplot, zticklabelplot, zarrowplot = draw_dim_axis!(tr, Val(3))

end

function Makie.plot!(tr::TernaryAxis)

    draw_triangle_vertex_labels!(tr)
    draw_triangle_axis!(tr)

    tr
end

Makie.data_limits(::TernaryAxis) = Rect3f((-0.2, -0.3, 0), (1.4, 1.4, 0))
Makie.foreach_plot(f, br::Makie.Bracket) = f(br)