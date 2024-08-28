using EzXML
f = joinpath(pwd(), "editions", "septuagint_latin_genesis.xml")
lxxglosses = readxml(f)

teins = "http://www.tei-c.org/ns/1.0"

namelist = findall("//ns:persName", root(lxxglosses), ["ns" => teins])




placelist = findall("//ns:placeName", root(lxxglosses), ["ns" => teins])