using Makie, LinearAlgebra, ColorSchemes, DocStringExtensions
import GeometricalPredicates, VoronoiDelaunay, Interpolations
const vd = VoronoiDelaunay
const gp = GeometricalPredicates

a = gp.Point(1.5, 1.5)
b = gp.Point(1.1, 1.1)
c = l = gp.Line(a, b)
println(gp.orientation(l, gp.Point(1.8, 1.6)))
println(gp.orientation(l, gp.Point(1.6, 1.8)))

