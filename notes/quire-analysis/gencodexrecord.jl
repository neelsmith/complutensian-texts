# Generate codex record for each volume of the Compltensian

# images 1 - 599.

"""Starting with alignment of sequence number, page number
and image number, generate strings for records through image 100.
"""
function hundred(seq, pg, img, vol, objprefix; recto = :odd, header = false)
    seq = seq - 1
    pg = pg  -1 
    records = []
    if header
        push!(records, "sequence|image|urn|rv|label")
    end
    for img in img:100
        println(img)
        seq = seq + 1
        pg = pg + 1
        pgid = "urn:cite2:citebne:complutensian.v1:v$(vol)p$(pg)"
        imgid = "urn:cite2:citebne:complutensian.v1:$(objprefix)$(img)"

        str = "$(seq)|$(imgid)|$(pgid)|RV|Volume $(vol), page $(pg)"
        push!(records, str)
    end
    records
end


h1 = hundred(15, 1, 19, 1, "v1p")
h2 = hundred(97, 83, 1, 1, "v1a_p") # include header to debug
h3 = hundred(197,183,1,1,"v1b_p")
h4 = hundred(297,283,1,1,"v1cp")
h5 = hundred(397,383,1,1,"v1_dp")

# These are missing!
#h6 = hundred(497,483,1,1,"v1_ep")



#96|urn:cite2:citebne:complutensian.v1:v1p100|urn:cite2:citebne:complutensian.v1:v1_p82|recto|Volume 1, page 82
open("h2.cex", "w") do io
    write(io, join(h2, "\n"))
end

#       str = "$(seq)|urn:cite2:citebne:complutensian.v1:v2a_p$(img)|urn:cite2:citebne:complutensian.v1:v1_p$(pg)|recto|Volume 2, page $(pg)"
 
println(h5)