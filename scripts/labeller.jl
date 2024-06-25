using Tabulae
using CitableParserBuilder
using CitableBase
using CitableText
using CitableCorpus
using CitableTeiReaders
using EditionBuilders

using Orthography, LatinOrthography

repo = pwd()
skiplist = ["mane","eo","eam"]


# Orthography and parsers:
ortho23 = latin23()
ortho25 = latin25()

p23url = "http://shot.holycross.edu/tabulae/medieval-lat23-current.cex"
parser23 = tabulaeStringParser(p23url, UrlReader)

p25url = "http://shot.holycross.edu/tabulae/medieval-lat25-current.cex"
parser25 = tabulaeStringParser(p25url, UrlReader)


# Septuagint glosses:
septlatinxml = joinpath(repo, "editions", "septuagint_latin_genesis.xml")
septlatinxmlcorpus = readcitable(septlatinxml, CtsUrn("urn:cts:compnov:bible.genesis.sept_latin:"), TEIDivAb, FileReader)
lxxbldr = normalizedbuilder(; versionid = "lxxlatinnormed")
septlatin = edited(lxxbldr, septlatinxmlcorpus)

# Targum glosses:
targumlatinxml =  joinpath(repo, "editions", "targum_latin_genesis.xml")
targbldr = normalizedbuilder(; versionid = "targumlatinnormed")
targumlatinxmlcorpus = readcitable(targumlatinxml, CtsUrn("urn:cts:compnov:bible.genesis.sept_latin:"), TEIDivAb, FileReader)
targumlatin = edited(targbldr, targumlatinxmlcorpus)


# Vulgate:
srcurl = "https://raw.githubusercontent.com/neelsmith/compnov/main/corpus/compnov.cex"
corpus = fromcex(srcurl, CitableTextCorpus, UrlReader)
vulgate = filter(corpus.passages) do psg
	versionid(psg.urn) == "vulgate"
end |> CitableTextCorpus



vulgtkns = tokenizedcorpus(vulgate, ortho25)
vulgparses = parsecorpus(vulgtkns, parser25)

"""True if analysis has a verb form."""
function verbform(a::Analysis)
	latform = latinForm(a)
	latform isa LMFFiniteVerb ||
	latform isa LMFInfinitive ||
	latform isa LMFParticiple 
end
vulgverbtokens = filter(vulgparses.analyses) do a
	! isempty(a.analyses) && verbform(a.analyses[1])
end



function formsforlex(parsedtkns)
	dict = Dict()
	for atkn in parsedtkns
		l = atkn.analyses[1] |> lexemeurn |> string
		t = atkn.analyses[1] |> token
		if haskey(dict, l)
			prev = dict[l]
			push!(prev, t)
			dict[l] = unique(prev)
		else
			dict[l] = [t]
		end
	end
	dict
end

vulgforms = formsforlex(vulgverbtokens)
(vulgforms |> keys |> collect)[1]

vulgforms["ls.n36504"]

outstrs = []
for k in keys(vulgforms)
    formlist = vulgforms[k]
    s = ""
    if length(formlist) < 3
        s = string(k, "|", join(formlist,", "))
    else
        s = string(k, "|", join(formlist[1:3],", "), "...")
    end
    push!(outstrs, s)
end

open("labels.cex", "w") do io
    write(io, join(outstrs,"\n"))
end