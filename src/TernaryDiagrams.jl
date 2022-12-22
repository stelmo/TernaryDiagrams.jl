module TernaryDiagrams

using Makie, LinearAlgebra, ColorSchemes
import Base

# default coordinates of triangle
const r1 = [0, 0]
const r2 = [1, 0]
const r3 = [0.5, sqrt(3)/2]
const R = [
    1 1 1
    r1 r2 r3
]
const invR = inv(R)
const tol = 1e-5

from_cart_to_bary(x, y) = invR * [1, x, y]
from_bary_to_cart(a1, a2, a3) = (R * [a1, a2, a3])[2:3]

@recipe(TernaryAxis) do scene
    Attributes(
        labelx = "labelx",
        labely = "labely",
        labelz = "labelz",
        y_label_vertex_vertical_adjustment = 0.05,
        y_label_edge_vertical_adjustment = 0.10,
        y_label_edge_vertical_arrow_adjustment = 0.08,
        arrow_scale  = 0.4,
        arrow_label_rotation_adjustment = 0.85,
        tick_fontsize = 8,
        grid_line_color = :grey,
        grid_line_width = 0.5,
    )
end

@recipe(TernaryScatter, x, y, z) do scene
    Attributes(
        color = :red, # can also be an array of colors
    )
end

@recipe(TernaryLine, x, y, z) do scene
    Attributes(
        color = :red,
    )
end

@recipe(TernaryFill, x, y, z, v) do scene
    Attributes(
        color = ColorSchemes.Spectral,
        triangle_length = 0.021,
        min_val = -Inf,
        max_val = Inf,
    )
end

"""
Helper function to draw the triangle outline.
"""
function draw_triangle_base!(tr::TernaryAxis)
    lines!(tr, [
        Point2(r1...),
        Point2(r2...),
        Point2(r3...),
        Point2(r1...),
        ],
        color=:black,
    )
end

"""
Helper function to insert the text at the outline vertices.
"""
function draw_triangle_vertex_labels!(tr::TernaryAxis)
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

"""
Helper function to draw the axis labels.
"""
function draw_triangle_axis_labels!(tr::TernaryAxis)
    # overall settings
    y_adj = tr.y_label_edge_vertical_adjustment[]
    y_arrow_adj = tr.y_label_edge_vertical_arrow_adjustment[]
    arrow_scale = tr.arrow_scale[]
    arrow_label_rot_adj = tr.arrow_label_rotation_adjustment[]

    # lambda 3: the "z" axis
    x0, y0 = (R * [0.5, 0.0, 0.5])[2:3] # middle of the edge
    y1 = y0 + y_adj/2
    x1 = x0 - sqrt(3) * (y1 - y0)
    text!(tr,
        Point2(x1, y1);
        text = tr.labelz[],
        align = (:center, :center),
        rotation = π/3 * arrow_label_rot_adj, # sometimes this is not aligned
    )
    x0, y0 = (R * [0.7, 0.0, 0.3])[2:3] # eyeballed good looking arrow start
    y1 = y0 + y_arrow_adj/2
    x1 = x0 - sqrt(3) * (y1 - y0)
    arrows!(tr,
        [x1,], [y1,], [arrow_scale * r3[1],], [arrow_scale * r3[2],],
    )

    # lambda 2: the "y" axis
    x0, y0 = (R * [0.0, 0.5, 0.5])[2:3]
    y1 = y0 + y_adj/2
    x1 = x0 + sqrt(3) * (y1 - y0)
    text!(tr,
        Point2(x1, y1);
        text = tr.labely[],
        align = (:center, :center),
        rotation = -π/3 * arrow_label_rot_adj,
    )
    x0, y0 = (R * [0.0, 0.3, 0.7])[2:3]
    y1 = y0 + y_arrow_adj/2
    x1 = x0 + sqrt(3) * (y1 - y0)
    arrows!(tr,
        [x1,], [y1,], [-arrow_scale * (r3[1] - r2[1]),], [-arrow_scale * (r3[2] - r2[2]),],
    )

    # lambda 1: the "x" axis
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

function draw_grid!(tr::TernaryAxis)
    # settings
    grid_line_width = tr.grid_line_width[]
    grid_line_color = tr.grid_line_color[]
    # draw grid
    fracs = 0.0:0.1:1.0
    fontsize = tr.tick_fontsize
    for f1 in fracs
        f2 = 1 - f1
        vec1 = [f1, f2, 0]
        vec2 = [f1, 0, f2]

        x1 = Point2((R * vec1)[2:3]...)
        x2 = Point2((R * vec2)[2:3]...)

        lines!(tr, [x1, x2], linewidth = grid_line_width, color=grid_line_color)

        # labelx
        f1 in 0:0.2:1.0 && continue
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

        lines!(tr, [x1, x2], linewidth = grid_line_width, color=grid_line_color)

        #labely
        f1 in 0:0.2:1.0 && continue
        text!(
            tr,
            x1,
            text = "  " * string(round(f2, digits=2)),
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

        lines!(tr, [x1, x2], linewidth = grid_line_width, color=grid_line_color)

        # labelz
        f1 in 0:0.2:1.0 && continue
        text!(
            tr,
            x1,
            text = string(round(f1, digits=2)) * "  ",
            fontsize = fontsize,
            align = (:right, :center),
        )
    end
end

"""
Draw the base triangle without any data to form a barycentric axis.
"""
function Makie.plot!(tr::TernaryAxis)

    # draw base
    draw_triangle_base!(tr)
    draw_triangle_vertex_labels!(tr)
    draw_triangle_axis_labels!(tr)
    draw_grid!(tr)

    tr
end

"""
To a barycentric axis, add data points in a scatter like format.
"""
function Makie.plot!(tr::TernaryScatter)

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

"""
To a barycentric axis, add data points in a line like format.
"""
function Makie.plot!(tr::TernaryLine)

    # create observables
    dpoints = Observable(Point2f[])

    function update_plot(xs, ys, zs)
        empty!(dpoints[])
        for (x, y, z) in zip(xs, ys, zs)
            carts = R * [x,y,z]
            push!(dpoints[], Point2f(carts[2], carts[3]))
        end
    end

    Makie.Observables.onany(update_plot, tr[:x], tr[:y], tr[:z])
    
    update_plot(tr[:x][], tr[:y][], tr[:z][])
    
    # plot data points
    lines!(tr, dpoints, color=tr.color[])

    tr
end

"""
Internal edge used to construct filled triangle. 
"""
struct Edge
    p1::Point2
    p2::Point2
end

point_similar(p1::Point2, p2::Point2) = norm(p1 - p2) <= tol

function Base.:(==)(e1::Edge, e2::Edge) 
    point_similar(e1.p1, e2.p1) && point_similar(e1.p2, e2.p2) || 
    point_similar(e1.p1, e2.p2) && point_similar(e1.p2, e2.p1)
end 

"""
Struct used to store the overall Polygon of the joined minitriangles.
"""
struct Polygon
    color::Int64
    edges::Vector{Edge}
end

function extend_shapes!(pgons::Vector{Polygon}, col, edges)
    
    idx = 0
    for (i, pgon) in enumerate(pgons)
        if col == pgon.color && any(in.(edges, Ref(pgon.edges))) # color and at least 1 edge in common
            idx = i 
            break
        end
    end

    if idx == 0 # found no match
        push!(pgons, Polygon(col, edges))
    else # found a match
        # remove these common edges
        rem_idxs = [i for (i, edge) in enumerate(pgons[idx].edges) if edge in edges]
        # keep these edges
        keep_idxs = [i for (i, edge) in enumerate(edges) if edge ∉ pgons[idx].edges]
        
        deleteat!(pgons[idx].edges, rem_idxs)        
        append!(pgons[idx].edges, edges[keep_idxs])
    end
end



"""
To a barycentric axis, add filled mini-triangles (mostly) where the color map is
based on the attribute `color`. The number of color groups plotted depends on
the length of the supplied color map. Expect this function to work better with
`length(color) < 10`.
"""
function Makie.plot!(tr::TernaryFill)

    # create observables
    dpoints = Observable(Point2f[])
    dvalues = Observable(Float64[])

    function update_plot(xs, ys, zs, vs)
        empty!(dpoints[])
        empty!(dvalues[])
        for (x, y, z, v) in zip(xs, ys, zs, vs)
            carts = R * [x, y, z]
            push!(dpoints[], Point2f(carts[2], carts[3]))
            push!(dvalues[], v)
        end
    end

    Makie.Observables.onany(update_plot, tr[:x], tr[:y], tr[:z], tr[:v])
     
    update_plot(tr[:x][], tr[:y][], tr[:z][], tr[:v][])
    
    # settings
    h = tr.triangle_length[]
    N = floor(Int64, 1.0/h)
    
    # helper functions to guide coordinates
    """
    Given the top (x0,y0) of a triangle, get the x coordinate when the
    mini-triangle has side length h. 
    """
    left_point_x(x0, y0, h) = 0.25 * (-sqrt(4 * h^2 + 2 * sqrt(3) * x0 * y0 - 3 * x0^2 - y0^2) + x0 + sqrt(3) * y0)
    """
    Get the y coordinate of the left point.
    """
    left_point_y(x) = sqrt(3) * x 
    """
    At a certain height (y coordinate), get the x coordinate of the end of the
    big triangle.
    """
    to_far_right(y) = -(y - sqrt(3))/sqrt(3)

    """
    Get the triangle coordinates for the n-th row where the triangle has side
    length h. When n == N then h is reduced to fit the triangle inside the
    default space.
    """
    first_triangle(n, h, N) = begin
        if n == 0
            top = Point2(r3...)
        else
            tpx = left_point_x(r3..., h * n)
            tpy = left_point_y(tpx)
            top = Point2(tpx, tpy)    
        end
        
        h = n == N ? h = 1 - N * h : h # adjust side if necessary
        lpx = left_point_x(top..., h)
        lpy = left_point_y(lpx)
        left = Point2(lpx, lpy)
        
        right = Point2(first(left.data) + h, last(left.data))
        
        top, left, right  
    end

    """
    Get the triangle coordinates when the triangle gets shifted right by i.
    """
    position_triangle(_top,_left, _right, i, n, h, N) = begin
        h = n == N ? h = 1 - N * h : h # adjust side if necessary

        if i == 1
            return _top, _left, _right
        else
            # flip
            d = sqrt(3) / 2 * h 
            tpx, tpy = _top.data
            lpx, lpy = _left.data
            rpx, rpy = _right.data
            
            tpx += h/2
            tpy = iseven(i) ? tpy - d : tpy + d
            lpx += h/2
            lpy = iseven(i) ? lpy + d : lpy - d
            rpx += h/2
            rpy = iseven(i) ? rpy + d : rpy - d
        end

        Point2(tpx, tpy), Point2(lpx, lpy), Point2(rpx, rpy)
    end

    # colormap
    _lb, _ub = extrema(dvalues[])
    lb = max(_lb, tr.min_val[])
    ub = min(_ub, tr.max_val[])
    ncolors = length(tr.color[])
    d = (ub - lb)/ncolors
    bins = [(lb + n*d)..(lb + (n+1)*d) for n in 0:(ncolors-1)]
    
    cmap(idx) = tr.color[][idx]
    cmap_idx(x) = findfirst([x in bin for bin in bins])
    closest_idx(pnts) = begin
        arr = [findmin(norm.(dpoints[] .- pnt)) for pnt in pnts]
        min_vs = [first(x) for x in arr]
        min_idxs = [last(x) for x in arr]
        min_idxs[argmin(min_vs)]
    end
    closest_value(pnts) = dvalues[][closest_idx(pnts)]
    
    pgons = Polygon[] # vector to store polygons

    # first triangle
    for n in 0:N        
        abs(1.0 - n * h) < tol && break # ignore small polygons
        
        top, left, right = first_triangle(n, h, N) # reset
        i = 1
        while true
            top, left, right = position_triangle(top, left, right, i, n, h, N)
  
            if any(first(x) > to_far_right(last(x)) for x in [top, left, right])
                h = n == N ? h = 1 - N * h : h # adjust side if necessary for last row
                d = sqrt(3) / 2 * h 

                tpx = first(top) - h/2
                tpy = iseven(i) ? last(top) + d : last(top) - d 
                
                t2px = to_far_right(tpy)
                t2py = tpy

                rpx = first(right) - h/2
                rpy = iseven(i) ? last(right) - d : last(right) + d

                r2px = to_far_right(rpy)
                r2py = rpy

                top = Point2(tpx, tpy)
                top2 = Point2(t2px, t2py)
                right2 = Point2(r2px, r2py)
                right = Point2(rpx, rpy)

                col_idx = cmap_idx(closest_value([top, top2, right2, right]))
                if abs(tpx - t2px) < tol && abs(rpx - r2px) < tol
                    break # polygon is a line, skip    
                elseif abs(tpx - t2px) < tol # top and top2 are the same
                    edges = [Edge(top, right2), Edge(right2, right), Edge(right, top)]
                elseif abs(rpx - r2px) < tol # right and right2 are the same
                    edges = [Edge(top, top2), Edge(top2, right), Edge(right, top)]                                    
                else
                    edges = [Edge(top, top2), Edge(top2, right2), Edge(right2, right), Edge(right, top)]
                end
                
                extend_shapes!(pgons, col_idx, edges)

                break
            else
                col_idx = cmap_idx(closest_value([top, left, right, top]))
                edges = [Edge(top, left), Edge(left, right), Edge(right, top)]
                extend_shapes!(pgons, col_idx, edges)

            end
            i += 1
        end
    end

    # need to sweep through pgons again because some shapes are not combined above
    min_pgons = Polygon[]
    for pgon in pgons
        extend_shapes!(min_pgons, pgon.color, pgon.edges)
    end

    # println(length(min_pgons))
    # for pgon in min_pgons
    #     println("color = ", pgon.color)
    #     for edge in pgon.edges
    #         println(edge)
    #     end
    # end

    for (ii, pgon) in enumerate(min_pgons)
        # println("doing pgon: ", ii)
        # build edges by connecting vertices
        vertices = [pgon.edges[1].p1, pgon.edges[1].p2]
        edge_idxs = collect(2:length(pgon.edges)) # look from the 2nd edge onwards
        while !isempty(edge_idxs)
            v = last(vertices)
            
            i = findfirst(x -> point_similar(pgon.edges[x].p1, v) || point_similar(pgon.edges[x].p2, v), edge_idxs)
            if point_similar(pgon.edges[edge_idxs[i]].p1, v)
                push!(vertices, pgon.edges[edge_idxs[i]].p2)
            else
                push!(vertices, pgon.edges[edge_idxs[i]].p1)
            end
        
            deleteat!(edge_idxs, i)
        end
        push!(vertices, pgon.edges[1].p1) # complete shape
        
        # draw polygon
        poly!(tr, 
            vertices;
            color = cmap(pgon.color),
            strokewidth = 0,
            strokecolor = :transparent,
            shading = false,
        ) 
    end

    tr
end

end

