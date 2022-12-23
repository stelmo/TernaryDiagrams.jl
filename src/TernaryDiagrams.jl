module TernaryDiagrams

using Makie, LinearAlgebra, ColorSchemes, DocStringExtensions
import GeometricalPredicates, VoronoiDelaunay, Interpolations
const vd = VoronoiDelaunay

# default coordinates of triangle
const r1 = [0, 0]
const r2 = [1, 0]
const r3 = [0.5, sqrt(3) / 2]
const R = [
    1 1 1
    r1 r2 r3
]
const invR = inv(R)
const tol = 1e-5

from_cart_to_bary(x, y) = invR * [1, x, y]
from_bary_to_cart(a1, a2, a3) = (R*[a1, a2, a3])[2:3]

delaunay_scale(x, y) = [0.8 * x + 1.1, 0.8 * y + 1.1]
delaunay_unscale(x, y) = [(x - 1.1) / 0.8, (y - 1.1) / 0.8]

"""
TernaryAxis

Draw the base triangle without any data to form a barycentric axis. Use the
"adjustment" kwargs to adjust various formatting options.

## Attributes
$(Makie.ATTRIBUTES)
"""
@recipe(TernaryAxis) do scene
    Attributes(
        labelx = "labelx",
        labely = "labely",
        labelz = "labelz",
        label_fontsize = 18,
        label_vertex_vertical_adjustment = 0.05,
        label_edge_vertical_adjustment = 0.10,
        label_edge_vertical_arrow_adjustment = 0.08,
        arrow_scale = 0.4,
        arrow_label_rotation_adjustment = 0.85,
        arrow_label_fontsize = 16,
        tick_fontsize = 8,
        grid_line_color = :grey,
        grid_line_width = 0.5,
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

Note: `colormap` and `color` both apply to the color of the isolines. Thus, one
of them must be set to `nothing` to draw the correct on the isolines.

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
    )
end

include("contour.jl")

# """
# TernaryContourf

# Draw a filled contour plot using barycentric coordindates, `x`, `y`, `z`, i.e.
# `x + y + z = 1`. The weight of the coordinates is passed through `w`.

# ## Attributes
# $(Makie.ATTRIBUTES)
# """
# @recipe(TernaryContourf, x, y, z, w) do scene
#     Attributes(
#         color = ColorSchemes.Spectral,
#         clip_min_w = -Inf,
#         clip_max_w = Inf,
#     )
# end

# include("fill.jl")

end
