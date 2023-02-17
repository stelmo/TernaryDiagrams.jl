Makie.@Block TernaryAxis begin
    # "The Scene of the GeoAxis, which holds all plots."
    scene::Scene
    # "Targeted limits in input space"
    targetlimits::Observable{Rect2d}
    # "Final limits in input space"
    finallimits::Observable{Rect2d}
    interactions::Dict{Symbol, Tuple{Bool, Any}}
    # "The plot elements of the axis - spines, ticks, labels, etc."
    elements::Dict{Symbol, Any}
    cycler::Cycler
    palette::Palette
    @attributes begin

        # arrow labels
        xlabel = "x"
        xlabelsize = @inherit(:fontsize, 16)
        xlabelfont = :regular
        xlabelcolor = @inherit(:textcolor, :black)
        xlabelrotation = 0f0
        xlabelpad = 5f0
        xlabelvisible = true

        ylabel = "y"
        ylabelsize = @inherit(:fontsize, 16)
        ylabelfont = @inherit(:font, :regular)
        ylabelcolor = @inherit(:textcolor, :black)
        ylabelrotation = 0f0
        ylabelpad = 5f0
        ylabelvisible = true

        zlabel = "z"
        zlabelsize = @inherit(:fontsize, 16)
        zlabelfont = @inherit(:font, :regular)
        zlabelcolor = @inherit(:textcolor, :black)
        zlabelrotation = 0f0
        zlabelpad = 5f0
        zlabelvisible = true
        # vertex labels
        xvertexlabel = ""
        xvertexlabelsize = @inherit(:fontsize, 16)
        xvertexlabelfont = @inherit(:font, :regular)
        xvertexlabelcolor = @inherit(:textcolor, :black)
        xvertexlabelrotation = 0f0
        xvertexlabelpad = 5f0
        xvertexlabelvisible = true

        yvertexlabel = ""
        yvertexlabelsize = @inherit(:fontsize, 16)
        yvertexlabelfont = @inherit(:font, :regular)
        yvertexlabelcolor = @inherit(:textcolor, :black)
        yvertexlabelrotation = 0f0
        yvertexlabelpad = 5f0
        yvertexlabelvisible = true

        zvertexlabel = ""
        zvertexlabelsize = @inherit(:fontsize, 16)
        zvertexlabelfont = @inherit(:font, :regular)
        zvertexlabelcolor = @inherit(:textcolor, :black)
        zvertexlabelrotation = 0f0
        zvertexlabelpad = 5f0
        zvertexlabelvisible = true
        
        xticks = LinearTicks(5)
        xtickformat = _default_formatter
        xticksize = @inherit((:Axis, :xticksize), 5f0)
        xtickalign = 1f0
        xtickcolor = @inherit(:color, :black)
        xtickwidth = 1f0
        xtickvisible = true
        xticklabelsize = @inherit(:fontsize, 16)
        xticklabelfont = @inherit(:font, :regular)
        xticklabelcolor = @inherit(:textcolor, :black)
        xticklabelrotation = 0f0
        xticklabelpad = 5f0
        xticklabelvisible = true

        yticks = LinearTicks(5)
        ytickformat = _default_formatter
        yticksize = @inherit((:Axis, :xticksize), 5f0)
        ytickalign = 1f0
        ytickcolor = @inherit(:color, :black)
        ytickwidth = 1f0
        ytickvisible = true
        yticklabelsize = @inherit(:fontsize, 16)
        yticklabelfont = @inherit(:font, :regular)
        yticklabelcolor = @inherit(:textcolor, :black)
        yticklabelrotation = 0f0
        yticklabelpad = 5f0
        yticklabelvisible = true

        zticks = LinearTicks(5)
        ztickformat = _default_formatter
        zticksize = @inherit((:Axis, :xticksize), 5f0)
        ztickalign = 1f0
        ztickcolor = @inherit(:color, :black)
        ztickwidth = 1f0
        ztickvisible = true
        zticklabelsize = @inherit(:fontsize, 16)
        zticklabelfont = @inherit(:font, :regular)
        zticklabelcolor = @inherit(:textcolor, :black)
        zticklabelrotation = 0f0
        zticklabelpad = 5f0
        zticklabelvisible = true

        xgridcolor = RGBAf(@inherit(:color, RGBAf(0, 0, 0, 0.12)), 0.12)
        xgridstyle = :solid
        xgridwidth = @inherit((:Axis, :xgridwidth), 1)
        xgridcolor = @inherit(:color, :black)
        xgridvisible = true

        ygridcolor = RGBAf(@inherit(:color, RGBAf(0, 0, 0, 0.12)), 0.12)
        ygridstyle = :solid
        ygridwidth = @inherit((:Axis, :xgridwidth), 1)
        ygridcolor = @inherit(:color, :black)
        ygridvisible = true

        zgridcolor = RGBAf(@inherit(:color, RGBAf(0, 0, 0, 0.12)), 0.12)
        zgridstyle = :solid
        zgridwidth = @inherit((:Axis, :xgridwidth), 1)
        zgridcolor = @inherit(:color, :black)
        zgridvisible = true

        
        xspinecolor = RGBAf(@inherit(:color, :black), 0.12)
        xspinestyle = :solid
        xspinewidth = @inherit((:Axis, :xspinewidth), 1)
        xspinecolor = @inherit(:color, :black)
        xspinevisible = true

        yspinecolor = RGBAf(@inherit(:color, :black), 0.12)
        yspinestyle = :solid
        yspinewidth = @inherit((:Axis, :xspinewidth), 1)
        yspinecolor = @inherit(:color, :black)
        yspinevisible = true

        zspinecolor = RGBAf(@inherit(:color, :black), 0.12)
        zspinestyle = :solid
        zspinewidth = @inherit((:Axis, :xspinewidth), 1)
        zspinecolor = @inherit(:color, :black)
        zspinevisible = true

        # layouting stuff
        "The vertical alignment of the axis within its suggested bounding box."
        valign = :center
        "The horizontal alignment of the axis within its suggested bounding box."
        halign = :center
        "The width of the axis."
        width = nothing
        "The height of the axis."
        height = nothing
        "Controls if the parent layout can adjust to this element's width"
        tellwidth::Bool = true
        "Controls if the parent layout can adjust to this element's height"
        tellheight::Bool = true
        "The relative margins added to the autolimits in x direction."
        xautolimitmargin::Tuple{Float64, Float64} = (0.05f0, 0.05f0)
        "The relative margins added to the autolimits in y direction."
        yautolimitmargin::Tuple{Float64, Float64} = (0.05f0, 0.05f0)


    end
end

function initialize_block!(axis::TernaryAxis)
    scene = setup_axis!(axis)

    draw_ticks!(axis)


end

function draw_ticks!(axis::TernaryAxis)
    topscene = axis.blockscene
    scene = axis.scene

    lift(axis.finallimits, axis.scene.px_area, axis.xticks, axis.yticks, axis.zticks, axis....) do ...

    end
end

