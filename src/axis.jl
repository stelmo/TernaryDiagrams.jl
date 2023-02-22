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

triangle_gridline(f1, dim::Int) = point_on_axis(f1, Val(dim))

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
        ticklabelpositions.val = first.(gridline_points)

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
        text = ticklabels, fontsize = tr.tick_fontsize, rotation = tr[dimsym(:ticklabelrotation, dim)], 
        color = tr[dimsym(:ticklabelcolor, dim)], font = tr[dimsym(:ticklabelfont, dim)],
        align = tr[dimsym(:ticklabelalign, dim)]
    )

    # finally, plot the arrow and its label as a bracket

    x0, y0 = Point2f((R * circshift([0.3, 0.7, 0.0], Dim-1))[2:3])

    return (spineplot, gridplot, minorgridplot, ticklabelplot)


end

function draw_triangle_axis!(tr::TernaryAxis)

    # draw grid
    fracs = 0.0:0.1:1.0

    # xtickvals = Observable(Vector{Real}())
    # xticklabels = Observable(Vector{Any}())
    # xticklabelpositions = Observable(Vector{Point2f}())
    # xgridpoints = Observable(Vector{Point2f}())
    # xminorgridpoints = Observable(Vector{Point2f}())

    # lift(tr.xticks, identity, tr.xtickformat, 0, 1) do ticks, scale, format, vmin, vmax
    #     empty!(xtickvals.val); empty!(xticklabels.val); empty!(xticklabelpositions.val); empty!(xgridpoints.val)

    #     tickvals, ticklabels = Makie.get_ticks(ticks, scale, format, vmin, vmax)
    #     xtickvals.val = tickvals
    #     xticklabels.val = ticklabels
        
    #     gridline_points = triangle_gridline.(tickvals, Val(1))
    #     xgridpoints.val = vcat(gridline_points...)
    #     xticklabelpositions.val = last.(gridline_points)

    #     notify(xtickvals); notify(xticklabels); notify(xticklabelpositions); notify(xgridpoints)
    # end

    # lift(xtickvals, tr.xminorticks) do tickvals, minorticks
        
    #     minortickvals = Makie.get_minor_tickvalues(minorticks, identity, tickvals, 0, 1)

    #     xminorgridpoints[] = vcat(triangle_gridline.(minortickvals, Val(1))...)
    # end

    # xgridplot = linesegments!(
    #     tr, xgridpoints; 
    #     color = tr.xgridcolor, linewidth = tr.xgridwidth, style = tr.xgridstyle, 
    #     visible = tr.xgridvisible
    # )
    # xminorgridplot = linesegments!(
    #     tr, xminorgridpoints; 
    #     color = tr.xminorgridcolor, linewidth = tr.xminorgridwidth, style = tr.xminorgridstyle, 
    #     visible = tr.xminorgridvisible
    # )
    # xticklabelplot = text!(
    #     tr, xticklabelpositions; 
    #     text = xticklabels, fontsize = tr.tick_fontsize, rotation = tr.xticklabelrotation, 
    #     color = tr.xticklabelcolor, font = tr.xticklabelfont,
    #     align = (:left, :center)
    # )

    xspineplot, xgridplot, xminorgridplot, xticklabelplot = draw_dim_axis!(tr, Val(1))
    yspineplot, ygridplot, yminorgridplot, yticklabelplot = draw_dim_axis!(tr, Val(2))
    zspineplot, zgridplot, zminorgridplot, zticklabelplot = draw_dim_axis!(tr, Val(3))


    # ytickvals = Observable(Vector{Real}())
    # ytickpositions = Observable(Vector{Point2f}())
    # ygridpoints = Observable(Vector{Point2f}())

    # for f1 in fracs
    #     f2 = 1 - f1
    #     vec1 = [0, f2, f1]
    #     vec2 = [f1, f2, 0]

    #     x1 = Point2((R*vec1)[2:3]...)
    #     x2 = Point2((R*vec2)[2:3]...)

    #     push!(ygridpoints[], x1)
    #     push!(ygridpoints[], x2)

    #     # labely
    #     f1 in 0:0.2:1.0 && continue
    #     push!(ytickvals[], f1)
    #     push!(ytickpositions[], x1)
    # end

    # ygridplot = linesegments!(tr, ygridpoints; color = tr.grid_line_color, linewidth = tr.grid_line_width)
    # yticklabelplot = text!(tr, ytickpositions; text = @lift($(tr.ytickformat)($ytickvals)), fontsize = tr.tick_fontsize, rotation = tr.yticklabelrotation, align = (:left, :center))

    # ztickvals = Observable(Vector{Real}())
    # ztickpositions = Observable(Vector{Point2f}())
    # zgridpoints = Observable(Vector{Point2f}())

    # for f1 in fracs
    #     f2 = 1 - f1
    #     vec1 = [f2, 0, f1]
    #     vec2 = [0, f2, f1]

    #     x1 = Point2((R*vec1)[2:3]...)
    #     x2 = Point2((R*vec2)[2:3]...)

    #     push!(zgridpoints[], x1)
    #     push!(zgridpoints[], x2)

    #     # labelz
    #     f1 in 0:0.2:1.0 && continue
    #     push!(ztickvals[], f1)
    #     push!(ztickpositions[], x1)
    # end

    # zgridplot = linesegments!(tr, zgridpoints; color = tr.grid_line_color, linewidth = tr.grid_line_width)
    # zticklabelplot = text!(tr, ztickpositions; text = @lift($(tr.ztickformat)($ztickvals)), fontsize = tr.tick_fontsize, rotation = tr.zticklabelrotation, align = (:right, :center))

    # overall settings
    y_adj = tr.label_edge_vertical_adjustment[]
    y_arrow_adj = tr.label_edge_vertical_arrow_adjustment[]
    arrow_scale = tr.arrow_scale[]
    arrow_label_rot_adj = tr.arrow_label_rotation_adjustment[]

    x0, y0 = (R*[0.7, 0.0, 0.3])[2:3] # eyeballed good looking arrow start
    y1 = y0 + y_arrow_adj / 2
    x1 = x0 - sqrt(3) * (y1 - y0)
    bracket!(
        tr, 
        Point2f(x1, y1), Point2f(r3[1], r3[2]) * arrow_scale + Point2f(x1, y1);
        text = tr.zlabel,
        orientation = :up,
        style = :arrow,
        fontsize = tr.arrow_label_fontsize,
        linestyle = :solid,
        xautolimits = false,
        yautolimits = false,
        inspectable = false,
    )

    # lambda 2: the "y" axis
    x0, y0 = (R*[0.0, 0.3, 0.7])[2:3]
    y1 = y0 + y_arrow_adj / 2
    x1 = x0 + sqrt(3) * (y1 - y0)
    bracket!(
        tr, 
        Point2f(x1, y1), -Point2f(r3[1] - r2[1], r3[2] - r2[2]) * arrow_scale + Point2f(x1, y1);
        text = tr.ylabel,
        orientation = :up,
        style = :arrow,
        fontsize = tr.arrow_label_fontsize,
        linestyle = :solid,
        xautolimits = false,
        yautolimits = false,
        inspectable = false,
    )

    # lambda 1: the "x" axis
    x0, y0 = (R*[0.3, 0.7, 0.0])[2:3]
    y1 = y0 - y_arrow_adj
    x1 = x0
    bracket!(
        tr, 
        Point2f(x1, y1), -Point2f(r2[1], r2[2]) * arrow_scale + Point2f(x1, y1);
        text = tr.xlabel,
        # width = @lift($(tr.label_edge_vertical_arrow_adjustment) + $(tr.tick_fontsize)),
        orientation = :down,
        style = :arrow,
        fontsize = tr.arrow_label_fontsize,
        linestyle = :solid,
        xautolimits = false,
        yautolimits = false,
        inspectable = false,
    )
end

function Makie.plot!(tr::TernaryAxis)

    draw_triangle_vertex_labels!(tr)
    draw_triangle_axis!(tr)

    tr
end

Makie.data_limits(::TernaryAxis) = Rect3f((-0.2, -0.3, 0), (1.4, 1.4, 0))
Makie.foreach_plot(f, br::Makie.Bracket) = f(br)