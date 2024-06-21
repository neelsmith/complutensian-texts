# Build data tables from texts
using CitableBase, CitableText, CitableCorpus
using Tabulae
using CitableParserBuilder
using Orthography, LatinOrthography
using CitableTeiReaders
using EditionBuilders
#using StatsBase, OrderedCollections

using TypedTables
using CSV

repo = pwd()

#orthos and parsers:
ortho23 = latin23()
ortho25 = latin25()
p23url = "http://shot.holycross.edu/tabulae/medieval-lat23-current.cex"
parser23 = tabulaeStringParser(p23url, UrlReader)
p25url = "http://shot.holycross.edu/tabulae/medieval-lat25-current.cex"
parser25 = tabulaeStringParser(p25url, UrlReader)

# text reading functions
function readvulgate()
	srcurl = "https://raw.githubusercontent.com/neelsmith/compnov/main/corpus/compnov.cex"
	corpus = fromcex(srcurl, CitableTextCorpus, UrlReader)
	vulgate = filter(corpus.passages) do psg
		versionid(psg.urn) == "vulgate"
	end |> CitableTextCorpus
end
function readseptuagint(basedir)
	septlatinxml = joinpath(basedir, "editions", "septuagint_latin_genesis.xml")
	septlatinxmlcorpus = readcitable(septlatinxml, CtsUrn("urn:cts:compnov:bible.genesis.sept_latin:"), TEIDivAb, FileReader)
	lxxbldr = normalizedbuilder(; versionid = "lxxlatinnormed")
	septlatin = edited(lxxbldr, septlatinxmlcorpus)
end
function readtargum(basedir)
	targumlatinxml =  joinpath(basedir, "editions", "targum_latin_genesis.xml")
	targbldr = normalizedbuilder(; versionid = "targumlatinnormed")
	targumlatinxmlcorpus = readcitable(targumlatinxml, CtsUrn("urn:cts:compnov:bible.genesis.sept_latin:"), TEIDivAb, FileReader)
	targumlatin = edited(targbldr, targumlatinxmlcorpus)
end

# texts
septlatin = readseptuagint(repo)
targumlatin = readtargum(repo)
vulgate = readvulgate()

## Parsed texts
targtkns = tokenizedcorpus(targumlatin, ortho23)
targparses = parsecorpus(targtkns, parser23)
septtkns = tokenizedcorpus(septlatin, ortho23)
septparses = parsecorpus(septtkns, parser23)
vulgtkns = tokenizedcorpus(vulgate, ortho25)
vulgparses = parsecorpus(vulgtkns, parser25)



## Analysis
"""True if analysis has a verb form."""
function verbform(a::Analysis)
	latform = latinForm(a)
	latform isa LMFFiniteVerb ||
	latform isa LMFInfinitive ||
	latform isa LMFParticiple 
end
septverbs = filter(septparses.analyses) do a
	! isempty(a.analyses) && verbform(a.analyses[1])
end
targverbs = filter(targparses.analyses) do a
	! isempty(a.analyses) && verbform(a.analyses[1])
end
vulgverbs = filter(vulgparses.analyses) do a
	! isempty(a.analyses) && verbform(a.analyses[1])
end



## References and retrieval
reflistraw = map(p -> dropversion(urn(p)), targumlatin.passages) 
reflist = filter(reflistraw) do u
	! endswith(passagecomponent(u), "title")
end


"""Retrieve parses from analyzed tokens for a given passage reference."""
function retrieveparses(u::CtsUrn, v::Vector{AnalyzedToken})
	
	if isrange(u)
		"Not handling rnges yet."
	else
		psgref = passagecomponent(u)
		dotted = psgref * "."
		filter(v) do atkn
			psg = atkn |> passage
			checkref = passagecomponent(urn(psg)) 
			groupid(urn(psg)) == groupid(u) &&
			workid(urn(psg)) == workid(u) &&
			(psgref == checkref || startswith(checkref, dotted) )
		end
	end
end

"""Get lexeme URN of first analysis."""
function alex(a::AnalyzedToken)
	a.analyses[1] |> lexemeurn
end

"""Get string values for lexical IDs of verbs in a passage."""
function passagelexstrings(u::CtsUrn, v::Vector{AnalyzedToken})
	retrieveparses(u,v) .|> alex .|> string |> unique
end





"""Get list of all lexeme ID strings"""
function vocab()
	tlex = targverbs .|> alex .|> string
	slex = septverbs .|> alex .|> string
	vlex = vulgverbs .|> alex .|> string
	vcat(tlex, slex, vlex) |> unique
end
verbinventory = vocab()


"""Compose a TypedTable for our data."""
function populatettable(urnlist, tverbs, sverbs, vverbs)	
	seq = []
	urns = []
	docs = []
	lexemes = []
	for (i,u) in enumerate(urnlist)
		if i % 5 == 0
			@info("Passage $(i)/$(length(urnlist))...")
		end
		for lex in passagelexstrings(u, vverbs)
			push!(seq, i)
			push!(urns, u)
			push!(docs,"vulgate")
			push!(lexemes, lex)
		end
		for lex in passagelexstrings(u, tverbs)
			push!(seq, i)
			push!(urns, u)
			push!(docs,"targum")
			push!(lexemes, lex)
		end
		for lex in passagelexstrings(u, sverbs)
			push!(seq, i)
			push!(urns, u)
			push!(docs,"septuagint")
			push!(lexemes, lex)
		end
	end
    Table(sequence = seq, urn = urns, document = docs, lexeme = lexemes)
end

@time t = populatettable(reflist, targverbs, septverbs, vulgverbs)