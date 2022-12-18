module TernaryDiagrams

using Makie

# default coordinates of triangle
const r1 = [0, 0]
const r2 = [1, 0]
const r3 = [0.5, sqrt(3)/2]
const R = [
    1 1 1
    r1 r2 r3
]

@recipe(Ternary, x, y, z) do scene
    Attributes(
        color = :red,
        labelx = "labelx",
        labely = "labely",
        labelz = "labelz",
        y_label_vertex_vertical_adjustment = 0.05,
        y_label_edge_vertical_adjustment = 0.10,
        y_label_edge_vertical_arrow_adjustment = 0.08,
        arrow_scale  = 0.4,
    )
end

function draw_triangle_base!(tr::Ternary)
    lines!(tr, [
        Point2(r1...),
        Point2(r2...),
        Point2(r3...),
        Point2(r1...),
        ],
        color=:black,
    )
end

function draw_triangle_vertices!(tr::Ternary)
    y_adj = tr.y_label_vertex_vertical_adjustment[]
    text!(tr,
        Point2(r3...) + Point(0, y_adj);
        text = tr.labelz[],
        align = (:center, :center),
    )
    text!(tr,
        Point2(r2...) + Point(0, -y_adj);
        text = tr.labely[],
        align = (:left, :center),
    )
    text!(tr,
        Point2(r1...) + Point2(0, -y_adj);
        text = tr.labelx[],
        align = (:right, :center),
    )
end

function draw_triangle_axis_labels!(tr::Ternary)
    # overall settings
    y_adj = tr.y_label_edge_vertical_adjustment[]
    y_arrow_adj = tr.y_label_edge_vertical_arrow_adjustment[]
    arrow_scale = tr.arrow_scale[]

    # lambda 3
    x0, y0 = (R * [0.5, 0.0, 0.5])[2:3]
    y1 = y0 + y_adj/2
    x1 = x0 - sqrt(3) * (y1 - y0)
    text!(tr,
        Point2(x1, y1);
        text = tr.labelz[],
        align = (:center, :center),
        rotation = π/3 * 0.85,
    )
    x0, y0 = (R * [0.7, 0.0, 0.3])[2:3]
    y1 = y0 + y_arrow_adj/2
    x1 = x0 - sqrt(3) * (y1 - y0)
    arrows!(tr,
        [x1,], [y1,], [arrow_scale * r3[1],], [arrow_scale * r3[2],],
    )

    # lambda 2
    x0, y0 = (R * [0.0, 0.5, 0.5])[2:3]
    y1 = y0 + y_adj/2
    x1 = x0 + sqrt(3) * (y1 - y0)
    text!(tr,
        Point2(x1, y1);
        text = tr.labely[],
        align = (:center, :center),
        rotation = -π/3 * 0.85,
    )
    x0, y0 = (R * [0.0, 0.3, 0.7])[2:3]
    y1 = y0 + y_arrow_adj/2
    x1 = x0 + sqrt(3) * (y1 - y0)
    arrows!(tr,
        [x1,], [y1,], [-arrow_scale * (r3[1] - r2[1]),], [-arrow_scale * (r3[2] - r2[2]),],
    )

    # lambda 1
    x0, y0 = (R * [0.5, 0.5, 0.0])[2:3]
    x1 = x0
    y1 = y0 - y_adj
    text!(tr,
        Point2(x1, y1);
        text = tr.labelx[],
        align = (:center, :center),
    )
    x0, y0 = (R * [0.3, 0.7, 0.0])[2:3]
    y1 = y0 - y_arrow_adj
    x1 = x0
    arrows!(tr,
        [x1,], [y1,], [-arrow_scale * r2[1],], [-arrow_scale * r2[2],],
    )
end

function draw_grid!(tr::Ternary)
    # draw grid
    fracs = 0.0:0.1:1.0
    fontsize = 8
    for f1 in fracs
        f2 = 1 - f1
        vec1 = [f1, f2, 0]
        vec2 = [f1, 0, f2]

        x1 = Point2((R * vec1)[2:3]...)
        x2 = Point2((R * vec2)[2:3]...)

        lines!(tr, [x1, x2], linewidth = 0.5, color=:grey)

        # labelx
        isodd(f1 * 10) && continue
        text!(
            tr,
            x1,
            text = "  "*string(round(f1, digits=2)),
            fontsize = fontsize,
            rotation = -π/3,
            align = (:left, :center),
        )
    end

    for f1 in fracs
        f2 = 1 - f1
        vec1 = [0, f2, f1]
        vec2 = [f1, f2, 0]

        x1 = Point2((R * vec1)[2:3]...)
        x2 = Point2((R * vec2)[2:3]...)

        lines!(tr, [x1, x2], linewidth = 0.5, color=:grey)

        #labely
        isodd(f2 * 10) && continue
        text!(
            tr,
            x1,
            text = "  "*string(round(f2, digits=2)),
            fontsize = fontsize,
            rotation = π/3,
            align = (:left, :center),
        )
    end

    for f1 in fracs
        f2 = 1 - f1
        vec1 = [f2, 0, f1]
        vec2 = [0, f2, f1]

        x1 = Point2((R * vec1)[2:3]...)
        x2 = Point2((R * vec2)[2:3]...)

        lines!(tr, [x1, x2], linewidth = 0.5, color=:grey)

        # labelz
        isodd(f1 * 10) && continue
        text!(
            tr,
            x1,
            text = string(round(f1, digits=2))*"  ",
            fontsize = fontsize,
            align = (:right, :center),
        )
    end
end

function Makie.plot!(tr::Ternary)

    # draw base
    draw_triangle_base!(tr)
    draw_triangle_vertices!(tr)
    draw_triangle_axis_labels!(tr)
    draw_grid!(tr)

    # create observables
    dpoints = Observable(Point2f[])
    colors = Observable(Any[])

    function update_plot(xs, ys, zs)
        empty!(dpoints[])
        for (x, y, z) in zip(xs, ys, zs)
            carts = R * [x,y,z]
            push!(dpoints[], Point2f(carts[2], carts[3]))
        end
    end

    Makie.Observables.onany(update_plot, tr[:x], tr[:y], tr[:z])
    
    colors = tr.color isa Symbol ? fill(tr.color, length(tr[:z][])) : tr.color[] 
    update_plot(tr[:x][], tr[:y][], tr[:z][])
    
    # plot data points
    scatter!(tr, dpoints, color=colors)

    tr
end

end
