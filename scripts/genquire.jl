#=

17|urn:cite2:citebne:complutensian.v1:v1p21|urn:cite2:complutensian:pages.all.bne:v1_a_ii_r|recto|Volume 1, page a ii recto
18|urn:cite2:citebne:complutensian.v1:v1p22|urn:cite2:complutensian:pages.all.bne:v1_a_ii_v|verso|Volume 1, page a ii verso

15|urn:cite2:citebne:complutensian.v1:v1p19|urn:cite2:complutensian:pages.all.bne:v1_a_i_r|recto|Volume 1, page a i recto
=#


romans = ["i","ii","iii", "iiii", "v", "vi", "vii", "viii"]
rvlabel = Dict(
    "r" => "recto",
    "v" => "verso"
)


function quirepages(vol, quire, pagebase, pagecount, folioinquire, totalseq)
    @info("folio in quire $(folioinquire)")
    pageinquire = romans[folioinquire]
    rv = isodd(folioinquire) ?  "r" : "v"
    pieces = [
        totalseq,
        "urn:cite2:citebne:complutensian.v1:$(pagebase)$(pagecount)",
        "urn:cite2:complutensian:pages.all.bne:v$(vol)_$(quire)_$(pageinquire)_$(rv)",
        "Volume $(vol), page $(quire) $(pageinquire) $(rvlabel[rv])"
    ]
    join(pieces,"|")
end


quirepages(1,"a","v1p",19, 1, 15)


function ternion(vol, quire, pagebase, pgcount, totalseq)
    lines = []
    pageinfolio = 0
    push!(lines, pageinfolio)
    
    push!(lines, quirepages(vol, quire, pagebase, pageinfolio, totalseq))
# quirepages(1,"a","v1p",19, 1, 15)
    for i in 1:11
        if iseven(i) 
            pageinfolio = pageinfolio + 1
        end
        push!(lines, pageinfolio)
        #runningtotal = totalseq + 1
        #push!(lines, quirepages(vol, quire, pagebase, pageinfolio, runningtotal))
    end
    
    join(lines, "\n")
end


ternion(1, "a", "v1p", 19, 15) |> println


q = quirepages(1, "a", "v1p", 19, 15)

q