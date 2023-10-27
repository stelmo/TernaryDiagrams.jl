module TernaryDiagrams

using Makie, LinearAlgebra, ColorSchemes, DocStringExtensions
import GeometricalPredicates, VoronoiDelaunay, Base
const vd = VoronoiDelaunay
const gp = GeometricalPredicates

# default coordinates of triangle
const r1 = [0, 0]
const r2 = [1, 0]
const r3 = [0.5, sqrt(3) / 2]
const R = [
    1 1 1
    r1 r2 r3
]
const invR = inv(R) # do once

# tolerance for calculations
const TOL = 1e-6

# some convenience functions 
from_cart_to_bary(x, y) = invR * [1, x, y]
from_bary_to_cart(a1, a2, a3) = (R*[a1, a2, a3])[2:3]

# GeometricalPredicates requires coordinates to lie between (1 + eps, 2 - 2eps)
delaunay_scale(x, y) = [0.8 * x + 1.1, 0.8 * y + 1.1]
delaunay_scale(p::gp.Point2D) = gp.Point2D(0.8 * p._x + 1.1, 0.8 * p._y + 1.1)
delaunay_unscale(p::gp.Point2D) = gp.Point2D((p._x - 1.1) / 0.8, (p._y - 1.1) / 0.8)
delaunay_unscale(x, y) = [(x - 1.1) / 0.8, (y - 1.1) / 0.8]

unpack(p::gp.Point2D) = (p._x, p._y)

# extend some functions to work with Point2D from GeometricalPredicates
Base.:(-)(a::gp.Point2D, b::gp.Point2D) = gp.Point2D(a._x - b._x, a._y - b._y)
Base.:(+)(a::gp.Point2D, b::gp.Point2D) = gp.Point2D(a._x + b._x, a._y + b._y)
Base.:(*)(a::gp.Point2D, b::Float64) = gp.Point2D(a._x * b, a._y * b)
LinearAlgebra.norm(a::gp.Point2D) = sqrt(a._x^2 + a._y^2)

include("contour_funcs.jl")

# plot recipes, after recipe macro, include plot function

"""
TernaryAxis

Draw the base triangle without any data to form a barycentric axis. Use the
"adjustment" kwargs to adjust various formatting options.

## Attributes
$(Makie.ATTRIBUTES)
"""
Makie.@recipe(TernaryAxis) do scene
    Attributes(
        labelx = "labelx",
        labely = "labely",
        labelz = "labelz",
        label_fontsize = 18,
        label_vertex_vertical_adjustment = 0.05,
        label_edge_vertical_adjustment = 0.10,
        label_edge_vertical_arrow_adjustment = 0.08,
        labelx_arrow = nothing,
        labely_arrow = nothing,
        labelz_arrow = nothing,
        arrow_scale = 0.4,
        arrow_label_rotation_adjustment = 0.85,
        arrow_label_fontsize = 16,
        tick_fontsize = 8,
        grid_line_color = :grey,
        grid_line_width = 0.5,
        hide_vertex_labels = false,
        hide_triangle_labels = false,
    )
end

include("axis.jl")

"""
TernaryScatter

Draw scattered data points using barycentric coordindates, `x`, `y`, `z`, i.e.
`x + y + z = 1`. Attributes are passed to `scatter`. 

## Attributes
$(Makie.ATTRIBUTES)
"""
@recipe(TernaryScatter, x, y, z) do scene
    Attributes(
        color = :red, # can also be an array of colors
        marker = :circle,
        markersize = 8,
    )
end

include("scatter.jl")

"""
TernaryLines

Draw a line using barycentric coordindates, `x`, `y`, `z`, i.e.
`x + y + z = 1`. Attributes are passed to `lines`. 

## Attributes
$(Makie.ATTRIBUTES)
"""
@recipe(TernaryLines, x, y, z) do scene
    Attributes(color = :red, linewidth = 4, linestyle = :solid)
end

include("lines.jl")

"""
TernaryContour

Draw a contour plot using barycentric coordindates, `x`, `y`, `z`, i.e. `x + y +
z = 1`. The weight of the coordinates is passed through `w`. 

## Notes 
- `colormap` and `color` both apply to the color of the isolines. Thus, one of
   them must be set to `nothing` to draw the correct coloredv isoclines.
-  `pad_data` adds extra data points for the purpose of generating prettier
   isoclines. These padded points take the weight value of the closest actual
   data point's weight.  

## Attributes
$(Makie.ATTRIBUTES)
"""
@recipe(TernaryContour, x, y, z, w) do scene
    Attributes(
        color = :black,
        colormap = nothing,
        levels = 5,
        clip_min_w = -Inf,
        clip_max_w = Inf,
        linewidth = 4,
        linestyle = :solid,
        pad_data = false,
    )
end

include("contour.jl")

"""
TernaryContourf

Draw a filled contour plot using barycentric coordindates, `x`, `y`, `z`, i.e.
`x + y + z = 1`. The weight of the coordinates is passed through `w`.

## Notes
The data is always padded to make filling the entire plot area easier. Padded
data is interpolated based on the nearest data point.

## Attributes
$(Makie.ATTRIBUTES)
"""
@recipe(TernaryContourf, x, y, z, w) do scene
    Attributes(colormap = :Spectral, levels = 5)
end

include("contourfill.jl")

end
