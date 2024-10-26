function draw_triangle_base!(tr::TernaryAxis)
    lines!(tr, [Point2(r1...), Point2(r2...), Point2(r3...), Point2(r1...)], color = :black)
end

function draw_triangle_vertex_labels!(tr::TernaryAxis)
    y_adj = tr.label_vertex_vertical_adjustment[]
    xlabelpos = r1 .+ [0, -y_adj]
    ylabelpos = r2 .+ [0, -y_adj]
    zlabelpos = r3 .+ [0, y_adj]
    text!(       
        tr,
        zlabelpos...;
        text = tr.labelz[],
        align = (:center, :center),
        fontsize = tr.label_fontsize[] * !tr.hide_vertex_labels[],
    )
    text!(
        tr,
        ylabelpos...;
        text = tr.labely[],
        align = (:left, :center),
        fontsize = tr.label_fontsize[] * !tr.hide_vertex_labels[],
    )
    text!(
        tr,
        xlabelpos...;
        text = tr.labelx[],
        align = (:right, :center),
        fontsize = tr.label_fontsize[] * !tr.hide_vertex_labels[],
    )
end

function draw_triangle_axis_labels!(tr::TernaryAxis)
    # overall settings
    y_adj = tr.label_edge_vertical_adjustment[]
    y_arrow_adj = tr.label_edge_vertical_arrow_adjustment[]
    arrow_scale = tr.arrow_scale[]
    arrow_label_rot_adj = tr.arrow_label_rotation_adjustment[]

    # lambda 3: the "z" axis
    x0, y0 = (R*[0.5, 0.0, 0.5])[2:3] # middle of the edge
    y1 = y0 + y_adj / 2
    x1 = x0 - sqrt(3) * (y1 - y0)
    isnothing(tr.labelz_arrow[]) || text!(
        tr,
        Point2(x1, y1);
        text = tr.labelz_arrow[],
        align = (:center, :center),
        rotation = π / 3 * arrow_label_rot_adj, # sometimes this is not aligned
        fontsize = tr.arrow_label_fontsize[] * !tr.hide_triangle_labels[],
    )
    x0, y0 = (R*[0.7, 0.0, 0.3])[2:3] # eyeballed good looking arrow start
    y1 = y0 + y_arrow_adj / 2
    x1 = x0 - sqrt(3) * (y1 - y0)
    arrows!(tr, [x1], [y1], [arrow_scale * r3[1]], [arrow_scale * r3[2]])

    # lambda 2: the "y" axis
    x0, y0 = (R*[0.0, 0.5, 0.5])[2:3]
    y1 = y0 + y_adj / 2
    x1 = x0 + sqrt(3) * (y1 - y0)
    isnothing(tr.labely_arrow[]) || text!(
        tr,
        Point2(x1, y1);
        text = tr.labely_arrow[],
        align = (:center, :center),
        rotation = -π / 3 * arrow_label_rot_adj,
        fontsize = tr.arrow_label_fontsize[] * !tr.hide_triangle_labels[],
    )
    x0, y0 = (R*[0.0, 0.3, 0.7])[2:3]
    y1 = y0 + y_arrow_adj / 2
    x1 = x0 + sqrt(3) * (y1 - y0)
    arrows!(
        tr,
        [x1],
        [y1],
        [-arrow_scale * (r3[1] - r2[1])],
        [-arrow_scale * (r3[2] - r2[2])],
    )

    # lambda 1: the "x" axis
    x0, y0 = (R*[0.5, 0.5, 0.0])[2:3]
    x1 = x0
    y1 = y0 - y_adj
    isnothing(tr.labelx_arrow[]) || text!(
        tr,
        Point2(x1, y1);
        text = tr.labelx_arrow[],
        align = (:center, :center),
        fontsize = tr.arrow_label_fontsize[] * !tr.hide_triangle_labels[],
    )
    x0, y0 = (R*[0.3, 0.7, 0.0])[2:3]
    y1 = y0 - y_arrow_adj
    x1 = x0
    arrows!(tr, [x1], [y1], [-arrow_scale * r2[1]], [-arrow_scale * r2[2]])
end

function draw_grid!(tr::TernaryAxis)
    # settings
    grid_line_width = tr.grid_line_width[]
    grid_line_color = tr.grid_line_color[]
    # draw grid
    fracs = 0.0:0.1:1.0

    for f1 in fracs
        f2 = 1 - f1
        vec1 = [f1, f2, 0]
        vec2 = [f1, 0, f2]

        x1 = Point2((R*vec1)[2:3]...)
        x2 = Point2((R*vec2)[2:3]...)

        lines!(tr, [x1, x2], linewidth = grid_line_width, color = grid_line_color)

        # labelx
        f1 in 0:0.2:1.0 && continue
        text!(
            tr,
            x1,
            text = "  " * string(round(f1, digits = 2)),
            fontsize = tr.tick_fontsize[],
            rotation = -π / 3,
            align = (:left, :center),
        )
    end

    for f1 in fracs
        f2 = 1 - f1
        vec1 = [0, f2, f1]
        vec2 = [f1, f2, 0]

        x1 = Point2((R*vec1)[2:3]...)
        x2 = Point2((R*vec2)[2:3]...)

        lines!(tr, [x1, x2], linewidth = grid_line_width, color = grid_line_color)

        #labely
        f1 in 0:0.2:1.0 && continue
        text!(
            tr,
            x1,
            text = "  " * string(round(f2, digits = 2)),
            fontsize = tr.tick_fontsize[],
            rotation = π / 3,
            align = (:left, :center),
        )
    end

    for f1 in fracs
        f2 = 1 - f1
        vec1 = [f2, 0, f1]
        vec2 = [0, f2, f1]

        x1 = Point2((R*vec1)[2:3]...)
        x2 = Point2((R*vec2)[2:3]...)

        lines!(tr, [x1, x2], linewidth = grid_line_width, color = grid_line_color)

        # labelz
        f1 in 0:0.2:1.0 && continue
        text!(
            tr,
            x1,
            text = string(round(f1, digits = 2)) * "  ",
            fontsize = tr.tick_fontsize[],
            align = (:right, :center),
        )
    end
end

function Makie.plot!(tr::TernaryAxis)

    # draw base
    draw_triangle_base!(tr)
    draw_triangle_vertex_labels!(tr)
    draw_triangle_axis_labels!(tr)
    draw_grid!(tr)
    tr
end
