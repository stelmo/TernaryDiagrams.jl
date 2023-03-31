# TernaryDiagrams
[repostatus-url]: https://www.repostatus.org/#active
[repostatus-img]: https://www.repostatus.org/badges/latest/active.svg

[![repostatus-img]][repostatus-url] [![TernaryDiagrams Downloads](https://shields.io/endpoint?url=https://pkgs.genieframework.com/api/v1/badge/TernaryDiagrams)](https://pkgs.genieframework.com?packages=TernaryDiagrams)

This package exports a few [Makie](https://github.com/MakieOrg/Makie.jl) recipes
that can be used to construct a (relatively quick and dirty) [ternary
plot](https://en.wikipedia.org/wiki/Ternary_plot). 

In all the examples that follow, it is assumed that `a1[i] + a2[i] + a3[i] = 1`.
If applicable, `w[i]` corresponds to the weight associated with the point
`(a1[i], a2[i], a3[i])` for each index `i` in the dataset. If you would like to
load a test dataset, use `test/data.jld2`, which can be opened with
[JLD2.jl](https://github.com/JuliaIO/JLD2.jl). The file contains `a1`, `a2`,
`a3` and `mus`, with the latter being weights associated with the data points.
See the file `temp.jl` for an example of its usage.

## The ternary axis
```julia
fig = Figure();
ax = Axis(fig[1, 1]; aspect = AxisAspect(96/71));

ternaryaxis!(
    ax; 
    xlabel = "a1",
    ylabel = "a2",
    zlabel = "a3",
    # more options available, check out attributes with ?ternaryaxis (same for other plot functions)
    #= Note 
    Depending on the length of the axis labels, they may seem unaligned. 
    Use the kwarg arrow_label_rotation_adjustment to rotate them slightly. 
    For longer labels, use a value closer to 1 (trial and error it).
    =#
)

# the triangle is drawn from (0,0) to (0.5, sqrt(3)/2) to (1,0).
xlims!(ax, -0.2, 1.2) # to center the triangle and allow space for the labels
ylims!(ax, -0.3, 1.1)
hidedecorations!(ax) # to hide the axis decorations
fig
```
<br>
<div align="center">
    <img src="figs/axis.svg?maxAge=0" width="80%">
</div>
</br>

## Ternary lines
```julia
fig = Figure();
ax = Axis(fig[1, 1]; aspect = AxisAspect(96/71));

ternaryaxis!(ax);
ternarylines!(ax, a1, a2, a3; color = :blue)

xlims!(ax, -0.2, 1.2)
ylims!(ax, -0.3, 1.1)
hidedecorations!(ax)
fig
```
<br>
<div align="center">
    <img src="figs/lines.svg?maxAge=0" width="80%">
</div>
</br>

## Ternary scatter
```julia

fig = Figure();
ax = Axis(fig[1, 1]; aspect = AxisAspect(96/71)));

ternaryaxis!(ax);
ternaryscatter!(
    ax,
    a1,
    a2,
    a3;
    color = [get(ColorSchemes.Spectral, w, extrema(ws)) for w in ws],
    marker = :circle,
    markersize = 20,
)

xlims!(ax, -0.2, 1.2)
ylims!(ax, -0.3, 1.1)
hidedecorations!(ax)
fig
```
<br>
<div align="center">
    <img src="figs/scatter.svg?maxAge=0" width="80%">
</div>
</br>

## Ternary contours
```julia
fig = Figure();
ax = Axis(fig[1, 1]; aspect = AxisAspect(96/71)));

ternarycontour!(
    ax,
    a1,
    a2,
    a3,
    ws;
    levels = 5,
    linewidth = 4,
    color = nothing,
    colormap = reverse(ColorSchemes.Spectral),
    pad_data = true,
)

ternaryaxis!(ax);

xlims!(ax, -0.2, 1.2)
ylims!(ax, -0.3, 1.1)
hidedecorations!(ax)
fig
```
<br>
<div align="center">
    <img src="figs/contour.svg?maxAge=0" width="80%">
</div>
</br>

## Ternary filled contours
Note: `ternarycontour` uses a different Delaunay triangulation scheme to
`ternarycontourf` (the former is made by me, while the latter essentially calls
[`tricontourf`](https://docs.makie.org/v0.19.0/examples/plotting_functions/tricontourf/)
from Makie internally).
```julia
fig = Figure();
ax = Axis(fig[1, 1]; aspect = AxisAspect(96/71)));
ternarycontourf!(ax, a1, a2, a3, ws; levels = 10)
ternaryaxis!(ax);
xlims!(ax, -0.2, 1.2)
ylims!(ax, -0.3, 1.1)
hidedecorations!(ax)
fig
```
<br>
<div align="center">
    <img src="figs/contourfill.svg?maxAge=0" width="80%">
</div>
</br>

## Long term plans
If you use this package and run into issues, please let me know! I am planning
on extending the package to make a ternary plot axis instead of co-opting the
regular 2D axis. Before that stage though, I would like to sort out any bugs I
currently have implemented. So let me know what you think!