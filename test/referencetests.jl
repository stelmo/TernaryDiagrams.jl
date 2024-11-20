using GLMakie
using TernaryDiagrams
using JLD2
using ReferenceTests

@load joinpath(pkgdir(TernaryDiagrams), "test", "data.jld2") a1 a2 a3 mus
a1 = a1[1:20]
a2 = a2[1:20]
a3 = a3[1:20]
mus = mus[1:20]

function testimage_axis()
    fig = Figure()
    ax = Axis(fig[1, 1])

    ternaryaxis!(
        ax;
        labelx = "a1",
        labely = "a2",
        labelz = "a3",
    )

    xlims!(ax, -0.2, 1.2) # to center the triangle
    ylims!(ax, -0.3, 1.1) # to center the triangle
    hidedecorations!(ax) # to hide the axis decos
    fig
end

function testimage_lines()  
    fig = Figure()
    ax = Axis(fig[1, 1])

    ternaryaxis!(ax)
    ternarylines!(ax, a1, a2, a3; color = :blue)

    xlims!(ax, -0.2, 1.2)
    ylims!(ax, -0.3, 1.1)
    hidedecorations!(ax)
    fig
end

function testimage_scatter()
    fig = Figure()
    ax = Axis(fig[1, 1])

    ternaryaxis!(ax)
    ternaryscatter!(
        ax,
        a1,
        a2,
        a3;
        color = [get(Makie.ColorSchemes.Spectral, w, extrema(mus)) for w in mus],
        marker = :circle,
        markersize = 20,
    )

    xlims!(ax, -0.2, 1.2)
    ylims!(ax, -0.3, 1.1)
    hidedecorations!(ax)
    fig
end

function testimage_contour()
    fig = Figure()
    ax = Axis(fig[1, 1])

    ternarycontour!(
        ax,
        a1,
        a2,
        a3,
        mus;
        levels = 5,
        linewidth = 4,
        color = nothing,
        colormap = reverse(Makie.ColorSchemes.Spectral),
        pad_data = true,
    )

    ternaryaxis!(ax)

    xlims!(ax, -0.2, 1.2)
    ylims!(ax, -0.3, 1.1)
    hidedecorations!(ax)
    fig
end

function testimage_contourf()
    fig = Figure()
    ax = Axis(fig[1, 1])
    ternarycontourf!(ax, a1, a2, a3, mus; levels = 10)
    ternaryaxis!(ax)
    xlims!(ax, -0.2, 1.2)
    ylims!(ax, -0.3, 1.1)
    hidedecorations!(ax)
    fig
end

function testimage_temp()    
    fig = Figure()
    ax = Axis(fig[1, 1])

    ternarycontourf!(
        ax,
        a1,
        a2,
        a3,
        mus;
        levels = 10,
        linewidth = 4,
        color = nothing,
        colormap = reverse(Makie.ColorSchemes.Spectral),
        pad_data = true,
    )

    ternaryscatter!(
        ax,
        a1,
        a2,
        a3;
        color = :black,
        marker = :circle,
        markersize = 15,
    )

    ternaryscatter!(
        ax,
        a1,
        a2,
        a3;
        color = [get(reverse(Makie.ColorSchemes.Spectral), w, extrema(mus)) for w in mus],
        marker = :circle,
        markersize = 10,
    )

    ternaryaxis!(ax)

    xlims!(ax, -0.2, 1.2)
    ylims!(ax, -0.3, 1.1)
    hidedecorations!(ax)
    fig

end

@test_reference "../figs/axis.png" testimage_axis()
@test_reference "../figs/lines.png" testimage_lines()
@test_reference "../figs/scatter.png" testimage_scatter()
@test_reference "../figs/contour.png" testimage_contour()
@test_reference "../figs/contourfill.png" testimage_contourf()
@test_reference "../figs/temp.png" testimage_temp()
