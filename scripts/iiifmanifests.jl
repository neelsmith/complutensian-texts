# Update this to make a collection of manifests,
# with each volume of the BNE complutensian represented by a single manifest.

"""Format a complete IIIF item for one page."""
function item(vol, img)
    lines = [
        "{",
        
        "\"id\": \"http://shot.holycross.edu/complutensiancanvases/bne/v$(vol)/img$(img)\",",
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
            "\"id\": \"http://shot.holycross.edu/complutensianpages/bne/v$(vol)/img$(img)\",",
            "\"type\": \"AnnotationPage\",",
            "\"items\": [",


            "{",
            "\"id\": \"http://shot.holycross.edu/complutensianannotations/bne/v$(vol)/img$(img)\",",
            "\"type\": \"Annotation\",",
            "\"motivation\": \"painting\",",
            "\"body\": {",
            "\"id\": \"https://www.homermultitext.org/iipsrv?IIIF=/project/homer/pyramidal/deepzoom/citebne/complutensian/v1/v$(vol)p$(img).tif/full/full/0/default.jpg\",",


            "\"type\": \"Image\",",

            "\"format\": \"image/jpeg\",",
            "\"height\": 3181,",
            "\"width\": 2550,",

            "\"service\": [",
            "{",
                "\"id\": \"https://www.homermultitext.org/iipsrv?IIIF=/project/homer/pyramidal/deepzoom/citebne/complutensian/v1/v$(vol)p$(img).tif\",",

                "\"profile\": \"level1\",",

                "\"type\": \"ImageService2\"",
                "}",
                "]",


            "},",
            "\"target\": \"http://shot.holycross.edu/complutensiancanvases/bne/v$(vol)/img$(img)\"",
                        
            "}",



            "]",
            "}",
        "]",
        "}"
    ]
    join(lines, "\n")
end



volume = 6
lines = [ "{",
    "\"@context\": \"http://iiif.io/api/presentation/3/context.json\",",

    "\"id\": \"https://shot.holycross.edu/iiif/complutensian-bne/manifest.json\",",

    "\"type\": \"Manifest\",",

    "\"label\": {",
    "\"en\": [",
    "\"Complutensian Bible (Biblioteca Nacional de España), volume $(volume)\"",
    "]",
    "},",
    "\"items\": ["
]
        
itemlist = []
for img in 1:96
    push!(itemlist, item(6,img))
end
push!(lines, join(itemlist, ","))

push!(lines, "]")
push!(lines, "}")

json = join(lines, "\n")


open("complutensian-bne-manifest.json", "w") do io
    write(io, json)
end


#=



       
              "body": {
                "id": "https://www.homermultitext.org/iipsrv?IIIF=/project/homer/pyramidal/deepzoom/citebne/complutensian/v1/v6p13.tif/full/full/0/default.jpg",
                "type": "Image",
                "format": "image/jpeg",
                "height": 3181,
                "width": 2550,
                "service": [
                  {
                    "id": "https://www.homermultitext.org/iipsrv?IIIF=/project/homer/pyramidal/deepzoom/citebne/complutensian/v1/v6p13.tif",
                    "profile": "level1",
                    "type": "ImageService2"
                  }
                ]
        
                
           



=#