#=
Instaniate Codex models of the 6 volumes of the BNE copy of the Compultensian, and compose IIIF manifests for each. Write the results to the iiif directory of the gh repository.

Make sure the value of `repo`` is the 
root directory of the gh repo:
=#
repo = pwd()

using CitablePhysicalText, CitableBase
using CitableImage

imgsvc_baseurl = "http://www.homermultitext.org/iipsrv"
imgsvc_root = "/project/homer/pyramidal/deepzoom"
imgsvc = IIIFservice(imgsvc_baseurl, imgsvc_root)

manifestids = ["https://raw.githubusercontent.com/neelsmith/complutensian-texts/refs/heads/main/iiif/complutensian-bne-v$(i)-manifest.json" for i in 1:6]
configs = iiifconfig.(manifestids)

codexfiles = [joinpath(repo, "codex", "bne_v$(i).cex") for i in 1:6]
codices = [fromcex(f, Codex, FileReader)[1] for f in codexfiles]

manifests = [iiifmanifest(codices[i], configs[i], imgsvc) for i in 1:6]

outdir = joinpath(repo, "iiif")
for i in 1:6
    outfile = joinpath(outdir, "complutensian-bne-v$(i)-manifest.json")
    open(outfile,"w") do io
        write(outfile, manifests[i])
    end
    @info("Wrote manifest for volume $(i).")
end


totalpages = [length(c.pages) for c in codices] |> sum
@info("Total pages documented in manifests: $(totalpages)")

#########
# Can test volumes individually if necessary...
#=
m1 = iiifmanifest(codices[1], configs[1], imgsvc)
m2 = iiifmanifest(codices[2], configs[2], imgsvc)
m3 = iiifmanifest(codices[3], configs[3], imgsvc)
m4 = iiifmanifest(codices[4], configs[4], imgsvc)
m5 = iiifmanifest(codices[5], configs[5], imgsvc)
m6 = iiifmanifest(codices[6], configs[6], imgsvc)
=#