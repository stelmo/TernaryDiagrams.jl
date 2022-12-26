# TernaryDiagrams
[repostatus-url]: https://www.repostatus.org/#active
[repostatus-img]: https://www.repostatus.org/badges/latest/active.svg

[![repostatus-img]][repostatus-url] [![TernaryDiagrams Downloads](https://shields.io/endpoint?url=https://pkgs.genieframework.com/api/v1/badge/TernaryDiagrams)](https://pkgs.genieframework.com?packages=TernaryDiagrams)

This package exports a few [Makie](https://github.com/MakieOrg/Makie.jl) recipes
that can be used to construct [ternary
plots](https://en.wikipedia.org/wiki/Ternary_plot). 

In all the examples that follow, assume that `a1[i] + a2[i] + a3[i] = 1`. If
applicable, `w[i]` corresponds to the weight associated with the point `(a1[i],
a2[i], a3[i])`.

## The ternary axis
```julia
fig = Figure();
ax = Axis(fig[1, 1]);

ternaryaxis!(
    ax; 
    labelx = "a1",
    labely = "a2",
    labelz = "a3",
    # more options available, check out attributes with ?ternaryaxis
)

xlims!(ax, -0.2, 1.2) # to center the triangle
ylims!(ax, -0.3, 1.1) # to center the triangle
hidedecorations!(ax) # to hide the axis decos
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
ax = Axis(fig[1, 1]);

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
ax = Axis(fig[1, 1]);

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
ax = Axis(fig[1, 1]);

ternarycontour!(
    ax,
    a1,
    a2,
    a3,
    ws;
    levels = 5,
    linewidth = 1,
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
```julia

```