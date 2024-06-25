# Run this from repository root:
repo = pwd() 

using CitableBase, CitableText, CitableCorpus
using Tabulae
using CitableParserBuilder
using Orthography, LatinOrthography
using CitableTeiReaders
using EditionBuilders
using StatsBase, OrderedCollections

## Utility functions for getting verbs from a corpus:
"""Retrieve texts from corpus, omitting title elements."""
function retrieve(u::CtsUrn, c::CitableTextCorpus)
	if isrange(u)
		"Not handling rnges yet."
	else
		psgref = passagecomponent(u)
		dotted = psgref * "."
		
		psglist = filter(c.passages) do psg
			checkref = passagecomponent(psg.urn) 
			groupid(psg.urn) == groupid(u) &&
			workid(psg.urn) == workid(u) &&
			(psgref == checkref || startswith(checkref, dotted) )
		end
		filter(psglist) do psg
			! endswith(passagecomponent(urn(psg)), "title")
		end
	end
end

"""True if analysis has a verb form."""
function verbform(a::Analysis)
	latform = latinForm(a)
	latform isa LMFFiniteVerb ||
	latform isa LMFInfinitive ||
	latform isa LMFParticiple 
end

"""Collect verbs from a vector of passages.
"""
function passageverbs(psgvect, ortho, p)
	tlist = []
	for psg in psgvect
		if ortho == ortho23
			normedstr1 = replace(psg.text, "v" => "u")
			normedstr = replace(normedstr1, "j" => "j")
			
			normed = CitablePassage(urn(psg),normedstr)
				
			
			push!(tlist, singleverbs(normed, ortho, p))
		else
			
			push!(tlist, singleverbs(psg, ortho, p))
		end
	end
	
	#join(tlist,"\n")
	tlist
end

"""Find verbs in a single citable passage."""
function singleverbs(psg, ortho, p)
	vlist = []
	tlist = ["<p><span class=\"ref\">$(passagecomponent(urn(psg)))</span> "]
	for t in tokenize(psg, ortho)
		if tokencategory(t) isa LexicalToken
			parses = parsetoken(t.passage.text,p)
			if ! isempty(parses)
				if verbform(parses[1])
					push!(vlist, parses[1])
				end
			end	
		end
	end
	push!(tlist,"</p>")
	join(tlist)
	vlist
end


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
vulgparses.analyses[1] |> typeof


vulgverbtokens = filter(vulgparses.analyses) do a
	! isempty(a.analyses) && verbform(a.analyses[1])
end

vulgverblexx = map(vulgverbtokens) do tkn
	tkn.analyses .|> lexemeurn .|> string 
end


vulglexcounts = vulgverblexx |> Iterators.flatten |> collect |>  countmap |> OrderedDict
sort!(vulglexcounts, byvalue=true, rev=true)

vulglexinv = keys(vulglexcounts) |> collect |> unique

length(vulgverblexx)


reflistraw = map(p -> dropversion(urn(p)), targumlatin.passages) 
reflist = filter(reflistraw) do u
	! endswith(passagecomponent(u), "title")
end


tpsg = retrieve(reflist[1], targumlatin)
tverbs = passageverbs(tpsg, ortho23, parser23) |> Iterators.flatten |> collect

tlexx = map(tverbs) do a
	a |> lexemeurn |> string
end |> unique
#vulgverbs = passageverbs(vulgate.passages,ortho25, parser25 )

#psgverbs[1] .|> lexemeurn .|> string |> unique