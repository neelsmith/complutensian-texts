# Update this to make a collection of manifests,
# with each volume of the BNE complutensian represented by a single manifest?

"""Format a complete IIIF item for one page."""
function iiifpageitem(vol, volumesection, img)
    lines = [
        "{",
        
        "\"id\": \"http://shot.holycross.edu/complutensiancanvases/bne/$(volumesection)/img$(img)\",",
        "\"type\": \"Canvas\",",
        "\"label\": {",
            "\"en\": [",
                "\"Volume $(vol), image $(img)\"",
            "]",
        "},",
        "\"height\": 3181,",
        "\"width\": 2550,",
        "\"items\": [",
        



        
            "{",
            "\"id\": \"http://shot.holycross.edu/complutensianpages/bne/$(volumesection)/img$(img)\",",
            "\"type\": \"AnnotationPage\",",
            "\"items\": [",


            "{",
            "\"id\": \"http://shot.holycross.edu/complutensianannotations/bne/v$(volumesection)/img$(img)\",",
            "\"type\": \"Annotation\",",
            "\"motivation\": \"painting\",",
            "\"body\": {",
            "\"id\": \"https://www.homermultitext.org/iipsrv?IIIF=/project/homer/pyramidal/deepzoom/citebne/complutensian/v1/$(volumesection)p$(img).tif/full/full/0/default.jpg\",",


            "\"type\": \"Image\",",

            "\"format\": \"image/jpeg\",",
            "\"height\": 3181,",
            "\"width\": 2550,",

            "\"service\": [",
            "{",
                "\"id\": \"https://www.homermultitext.org/iipsrv?IIIF=/project/homer/pyramidal/deepzoom/citebne/complutensian/v1/$(volumesection)p$(img).tif\",",

                "\"profile\": \"level1\",",

                "\"type\": \"ImageService2\"",
                "}",
                "]",


            "},",
            "\"target\": \"http://shot.holycross.edu/complutensiancanvases/bne/$(volumesection)/img$(img)\"",
                        
            "}",



            "]",
            "}",
        "]",
        "}"
    ]
    join(lines, "\n")
end


"""Format IIIF header for one volume of Complutensian."""
function volumeheader(volume)
    headerlines = [
    "{",
        "\"@context\": \"http://iiif.io/api/presentation/3/context.json\",",

        "\"id\": \"https://shot.holycross.edu/iiif/complutensian-bne/manifest.json\",",

        "\"type\": \"Manifest\",",

        "\"label\": {",
        "\"en\": [",
        "\"Complutensian Bible (Biblioteca Nacional de España), volume $(volume)\"",
        "]",
        "},"
    ]
    headerlines
end




"""Format manifest for volume 1 of BNE Complutensian."""
function vol1()
    lines = volumeheader(1)
    push!(lines,"\"items\": [")
        
    itemlist = []
    for img in 1:99
        push!(itemlist, iiifpageitem(1,"v1", img))
    end
    for img in 1:99
        push!(itemlist, iiifpageitem(1,"v1a_", img))
    end
    for img in 1:99
        push!(itemlist, iiifpageitem(1,"v1b_", img))
    end
    for img in 1:99
        push!(itemlist, iiifpageitem(1,"v1c_", img))
    end
    for img in 1:99
        push!(itemlist, iiifpageitem(1,"v1d_", img))
    end
   
    push!(lines, join(itemlist, ","))
    push!(lines, "]")
    push!(lines, "}")

    join(lines, "\n")
end


"""Format manifest for volume 2 of BNE Complutensian."""
function vol2()
    lines = volumeheader(2)
    push!(lines,"\"items\": [")
        
    itemlist = []
     for img in 1:98
        push!(itemlist, iiifpageitem(2,"v2a_", img))
    end
    for img in 1:99
        push!(itemlist, iiifpageitem(2,"v2b_", img))
    end
    for img in 1:99
        push!(itemlist, iiifpageitem(2,"v2c_", img))
    end
    for img in 1:99
        push!(itemlist, iiifpageitem(2,"v2d_", img))
    end
    for img in 1:99
        push!(itemlist, iiifpageitem(2,"v2e_", img))
    end
   
    push!(lines, join(itemlist, ","))
    push!(lines, "]")
    push!(lines, "}")

    join(lines, "\n")
end


"""Format manifest for volume 3 of BNE Complutensian."""
function vol3()
    lines = volumeheader(3)
    push!(lines,"\"items\": [")
        
    itemlist = []
     for img in 1:99
        push!(itemlist, iiifpageitem(3,"v3a_", img))
    end
    for img in 1:99
        push!(itemlist, iiifpageitem(3,"v3b_", img))
    end
    for img in 1:99
        push!(itemlist, iiifpageitem(3,"v3c_", img))
    end
    for img in 1:99
        push!(itemlist, iiifpageitem(3,"v3d_", img))
    end
    for img in 1:23
        push!(itemlist, iiifpageitem(2,"v2e_", img))
    end
   
    push!(lines, join(itemlist, ","))
    push!(lines, "]")
    push!(lines, "}")

    join(lines, "\n")
end

"""Format manifest for volume 4 of BNE Complutensian."""
function vol4()
    lines = volumeheader(4)
    push!(lines,"\"items\": [")
        
    itemlist = []
     for img in 1:96
        push!(itemlist, iiifpageitem(4,"v4a_", img))
    end
    for img in 1:99
        push!(itemlist, iiifpageitem(4,"v4b_", img))
    end
    for img in 1:99
        push!(itemlist, iiifpageitem(4,"v4c_", img))
    end
    for img in 1:99
        push!(itemlist, iiifpageitem(4,"v4d_", img))
    end
    for img in 1:99
        push!(itemlist, iiifpageitem(4,"v4e_", img))
    end
    for img in 1:36
        push!(itemlist, iiifpageitem(4,"v4f_", img))
    end
   
    push!(lines, join(itemlist, ","))
    push!(lines, "]")
    push!(lines, "}")

    join(lines, "\n")
end

"""Format manifest for volume 5 of BNE Complutensian."""
function vol5()
    lines = volumeheader(5)
    push!(lines,"\"items\": [")
        
    itemlist = []
     for img in 1:96
        push!(itemlist, iiifpageitem(5,"v5a_", img))
    end
    for img in 1:99
        push!(itemlist, iiifpageitem(5,"v5b_", img))
    end
    for img in 1:99
        push!(itemlist, iiifpageitem(5,"v5c_", img))
    end
    for img in 1:99
        push!(itemlist, iiifpageitem(5,"v5d_", img))
    end
    for img in 1:99
        push!(itemlist, iiifpageitem(5,"v5e_", img))
    end
    for img in 1:46
        push!(itemlist, iiifpageitem(5,"v5f_", img))
    end
   
    push!(lines, join(itemlist, ","))
    push!(lines, "]")
    push!(lines, "}")

    join(lines, "\n")
end


"""Format manifest for volume 6 of BNE Complutensian."""
function vol6()
    lines = volumeheader(6)

    push!(lines,"\"items\": [")    
    itemlist = []
    for img in 1:96
        push!(itemlist, iiifpageitem(6,"v6", img))
    end

    for img in 1:99
        push!(itemlist, iiifpageitem(6,"v6b_", img))
    end
    for img in 1:99
        push!(itemlist, iiifpageitem(6,"v6c_", img))
    end
    for img in 1:99
        push!(itemlist, iiifpageitem(6,"v6d_", img))
    end
    for img in 1:48
        push!(itemlist, iiifpageitem(6,"v6e_", img))
    end
    push!(lines, join(itemlist, ","))
    push!(lines, "]") # close item list
    push!(lines, "}") # close header
    
    join(lines, "\n")
end


v1 = vol1()
v2 = vol2()
v3 = vol3()
v4 = vol4()
v5 = vol5()
v6 = vol6()


 open("complutensian-bne-v1-manifest.json", "w") do io
    write(io, v1)
 end
 open("complutensian-bne-v2-manifest.json", "w") do io
    write(io, v2)
 end
 open("complutensian-bne-v3-manifest.json", "w") do io
    write(io, v3)
 end
 open("complutensian-bne-v4-manifest.json", "w") do io
    write(io, v4)
 end
 open("complutensian-bne-v5-manifest.json", "w") do io
    write(io, v5)
 end
 open("complutensian-bne-v6-manifest.json", "w") do io
    write(io, v6)
 end



function bne()
    lines = [
    "{",
    "\"@context\": \"http://iiif.io/api/presentation/3/context.json\",",
    "\"id\": \"https://example.org/iiif/collection/top\",",
    "\"type\": \"Collection\",",
    "\"label\": {",
    "\"en\": [ \"Collection for Example Organization\" ] },",
    "\"summary\": { \"en\": [ \"Short summary of the Collection\" ] },",
    "\"requiredStatement\": {",
    "\"label\": { \"en\": [ \"Attribution\" ] },",
    "\"value\": { \"en\": [ \"Provided by Example Organization\" ] }",
    "},",

    "\"items\": [",
    v1,

    "]",
    "}"
    ]
    join(lines, "\n")
end

open("complutensian-bne-manifest.json","w") do io
    write(io, join(bne(), "\n"))
end