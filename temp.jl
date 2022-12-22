using Revise
using CairoMakie
using ColorSchemes
using TernaryDiagrams
const td = TernaryDiagrams

n = 50
arr = rand(n, 3)
arr ./= sum(arr, dims=2)
arr
color = [ColorSchemes.Dark2_8[i] for i in rand(1:8, n)] 
vs = rand(n)

fig = Figure();
ax = Axis(fig[1,1]);

ternaryaxis!(ax; labelx = "hello");
ternaryfill!(ax, arr[:, 1], arr[:, 2], arr[:, 3], vs; triangle_length=0.005, color=reverse(ColorSchemes.Spectral_4))

xlims!(ax, -0.2, 1.2)
ylims!(ax, -0.3, 1.1)
hidedecorations!(ax)
fig

###########################################


pgon = td.Polygon(
    2,
    [
        TernaryDiagrams.Edge([0.5000000000000002, 0.2598076211353315], [0.4650000000000002, 0.1991858428704208])
        TernaryDiagrams.Edge([0.5350000000000001, 0.1991858428704208], [0.5000000000000002, 0.2598076211353315])
        TernaryDiagrams.Edge([0.5000000000000001, 0.13856406460551007], [0.4650000000000001, 0.19918584287042074])
        TernaryDiagrams.Edge([0.5350000000000001, 0.19918584287042074], [0.6050000000000002, 0.19918584287042074])
        TernaryDiagrams.Edge([0.6050000000000002, 0.19918584287042074], [0.5700000000000002, 0.13856406460551007])
        TernaryDiagrams.Edge([0.5350000000000003, 0.0779422863405994], [0.5000000000000002, 0.1385640646055101])
        TernaryDiagrams.Edge([0.5700000000000003, 0.1385640646055101], [0.6400000000000003, 0.1385640646055101])
        TernaryDiagrams.Edge([0.6400000000000003, 0.1385640646055101], [0.6050000000000003, 0.0779422863405994])
        TernaryDiagrams.Edge([0.5700000000000002, 0.017320508075688565], [0.6400000000000002, 0.017320508075688565])
        TernaryDiagrams.Edge([0.6050000000000002, 0.07794228634059927], [0.6750000000000003, 0.07794228634059927])
        TernaryDiagrams.Edge([0.6400000000000002, 0.017320508075688565], [0.7100000000000003, 0.017320508075688565])
        TernaryDiagrams.Edge([0.7100000000000003, 0.017320508075688565], [0.7800000000000004, 0.017320508075688565])
        TernaryDiagrams.Edge([0.7800000000000004, 0.017320508075688565], [0.8500000000000004, 0.017320508075688565])
        TernaryDiagrams.Edge([0.8500000000000004, 0.017320508075688565], [0.9200000000000005, 0.017320508075688565])
        TernaryDiagrams.Edge([0.9550000000000002, 0.07794228634059926], [0.9900000000000001, 0.017320508075688565])
        TernaryDiagrams.Edge([0.9900000000000001, 0.017320508075688565], [0.9200000000000005, 0.017320508075688565])
        TernaryDiagrams.Edge([0.7100000000000004, 0.2598076211353315], [0.6750000000000004, 0.1991858428704208])
        TernaryDiagrams.Edge([0.7100000000000004, 0.2598076211353315], [0.7800000000000004, 0.2598076211353315])
        TernaryDiagrams.Edge([0.7800000000000005, 0.2598076211353315], [0.8500000000000001, 0.2598076211353315])
        TernaryDiagrams.Edge([0.8500000000000001, 0.2598076211353315], [0.8850000000000001, 0.1991858428704208])
        TernaryDiagrams.Edge([0.8850000000000001, 0.1991858428704208], [0.9200000000000002, 0.13856406460551002])
        TernaryDiagrams.Edge([0.92, 0.1385640646055101], [0.9550000000000001, 0.0779422863405994])
        TernaryDiagrams.Edge([0.6750000000000003, 0.1991858428704208], [0.6400000000000002, 0.13856406460551002])
        TernaryDiagrams.Edge([0.6750000000000004, 0.0779422863405994], [0.6400000000000003, 0.1385640646055101])
        TernaryDiagrams.Edge([0.5000000000000001, 0.01732050807568855], [0.4650000000000001, 0.07794228634059927])
        TernaryDiagrams.Edge([0.4650000000000001, 0.07794228634059927], [0.5350000000000001, 0.07794228634059927])
        TernaryDiagrams.Edge([0.5000000000000001, 0.017320508075688565], [0.5700000000000002, 0.017320508075688565])
    ]
)


fig = Figure();
ax = Axis(fig[1,1]);
# ternaryaxis!(ax; labelx = "hello");
for edge in pgon.edges
    lines!(ax, [edge.p1, edge.p2])
end
fig

# build edges by connecting vertices
vertices = [pgon.edges[1].p1, pgon.edges[1].p2]
edge_idxs = collect(2:length(pgon.edges)) # look from the 2nd edge onwards
while !isempty(edge_idxs)
    v = last(vertices)
    
    i = findfirst(x -> td.point_similar(pgon.edges[x].p1, v) || td.point_similar(pgon.edges[x].p2, v), edge_idxs)
    if td.point_similar(pgon.edges[edge_idxs[i]].p1, v)
        push!(vertices, pgon.edges[edge_idxs[i]].p2)
    else
        push!(vertices, pgon.edges[edge_idxs[i]].p1)
    end
    
    deleteat!(edge_idxs, i)
end
push!(vertices, pgon.edges[1].p1) # complete shape

# draw polygon
poly!(ax, 
    vertices;
    color = :red,
) 

fig