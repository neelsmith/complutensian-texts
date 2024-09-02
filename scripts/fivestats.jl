repo = pwd()

using EditorsRepo
using CitableBase
using CitableText
using CitableCorpus

using CitableParserBuilder
using Tabulae

using Orthography
using LatinOrthography

using StatsBase
using OrderedCollections

using Downloads

function vulg()
	url = "https://github.com/neelsmith/compnov/raw/main/corpus/compnov.cex"
	c = fromcex(url, CitableTextCorpus, UrlReader)
	filter(p -> versionid(p.urn) == "vulgate", c.passages) |> CitableTextCorpus
end

"""Format quotient of part and whole as a rounded percentage."""
function pct(part, whole)
    @info("pct of $(part) / $(whole)")
	rslt = ((part / whole) * 100 ) |> round
    @info("Got $(rslt)")
    rslt
end

function downgrade23(s)
    lc = lowercase(s)
    step1 = replace(lc, "v" => "u")
    step2 = replace(step1, "j" => "i")
    step2
end

function buildp23()
	url = "http://shot.holycross.edu/complutensian/complut-lat23-current.cex"
	f = Downloads.download(url)
	data = readlines(f)
	rm(f)
	TabulaeStringParser(data, latin23(), "|")
end
p23 = buildp23()

"""True if any form in a list of analyses is a verb form."""
function verbparse(parses)
	verbal = false
	for p in parses
		try
			latform = latinForm(p)
			if is_verb(latform)
				verbal = true
			end
		catch
			@warn("Error on $(p)")
		end
	end
	verbal
end


"""Select verb tokens from a vocabulary list"""
function verbtokens(lex; parser = p23)
    parselist =  map(lex) do tkn
		(token = tkn, parses = parsetoken(tkn, parser))
	end
    verbids = map(filter(pr -> verbparse(pr.parses), parselist)) do pr
        pr.token
    end
    filter(tkn -> tkn in verbids, lex)  
end


"""Report number of tokens, number analyzed and percent analyzed;
number of distinct tokens, number of distinct tokens analyzed, and percent distinct tokens analyzed;
number of lexemes.
"""
function linescore(lexstrings; ortho = latin23())
    # 1)
	total = length(lexstrings)

    # Parse unique vocab list
	lex = lexstrings |> unique |> sort
    parselist =  map(lex) do tkn
		(token = tkn, parses = parsetoken(tkn, p23))
	end
    # Save list of forms that parsed
    successes = map(filter(pr -> ! isempty(pr.parses), parselist)) do pr
        pr.token
    end

    # 2)
    analyzed = filter(s -> s in successes, lexstrings) |> length
    @info("Analyzed $(analyzed)")
    # 3)
    pctanalyzed = pct(analyzed, total)
   
   
    # 4)
    numdistinct = length(lex)
    # 5)
    distinctanalyzed = filter(s -> s in successes, lex) |> length
    # 6)
    distinctpctanalyzed = pct(distinctanalyzed, numdistinct)


    # 7)
    numlexemes = map(pr -> lexemeurn.(pr.parses), parselist) |> Iterators.flatten  |> collect .|> string |> unique |> length
   
    (total, analyzed, pctanalyzed, 
    numdistinct, distinctanalyzed, distinctpctanalyzed,
    numlexemes
    )
   
end

function verbsplits(tknlist; parser = p23)
    finite = []
    infinitive = []
    participle = []
    gerundive = []
    for t in tknlist
        parses = filter(parsetoken(t,parser)) do p
            is_verb(latinForm(p) )
        end
        
        if latinForm(parses[1]) isa LMFFiniteVerb
            push!(finite, t)
        elseif latinForm(parses[1]) isa LMFInfinitive
            push!(infinitive, t)
        elseif latinForm(parses[1]) isa LMFParticiple
            push!(participle, t)
        elseif latinForm(parses[1]) isa LMFGerundive
            push!(gerundive, t)            
        else 
            @warn("Couldn't place token $(t) as a verb form")
        end
        
    end
    (finite, infinitive, participle, gerundive)
end


r =  repository(repo)
corpus = normalizedcorpus(r)

lxxcorpus = filter(psg -> workcomponent(psg.urn) == 
"bible.genesis.sept_latin.normalized", corpus.passages) |> CitableTextCorpus
lxxlextokens = filter(tokenize(lxxcorpus, latin23())) do ct
	tokencategory(ct) isa LexicalToken
end
lxxvocab = map(t -> downgrade23(tokentext(t)), lxxlextokens)

lxxverbs = verbtokens(lxxlextokens)
lxxverbvocab = map(t -> downgrade23(tokentext(t)), lxxverbs)

targcorpus = filter(psg -> workcomponent(psg.urn) == 
"bible.genesis.targum_latin.normalized", corpus.passages) |> CitableTextCorpus
targlextokens = filter(tokenize(targcorpus, latin23())) do ct
	tokencategory(ct) isa LexicalToken
end
targvocab = map(t -> downgrade23(tokentext(t)), targlextokens)

targverbs = verbtokens(targlextokens)
targverbvocab = map(t -> downgrade23(tokentext(t)), targverbs)

vulgate = vulg()
vulgate_genesis = begin
	allgenesis = filter(p -> workid(p.urn) == "genesis", vulgate.passages) 
	chaptlist = map(psg -> collapsePassageBy(urn(psg), 1) |> passagecomponent, lxxcorpus) |> unique
	filter(psg -> passagecomponent(collapsePassageBy(psg.urn,1)) in chaptlist, allgenesis) |> CitableTextCorpus
end
vulglextokens = filter(tokenize(vulgate_genesis, latin25())) do ct
	tokencategory(ct) isa LexicalToken
end
vulgvocab = map(t -> downgrade23(tokentext(t)), vulglextokens)
vulgverbs = verbtokens(vulglextokens)
vulgverbvocab = map(t -> downgrade23(tokentext(t)), vulgverbs)


linescore(vulgvocab)
linescore(lxxvocab)
linescore(targvocab)

linescore(vulgverbvocab)
linescore(lxxverbvocab)
linescore(targverbvocab)


chaptlist = map(psg -> collapsePassageBy(urn(psg), 1) |> passagecomponent, lxxcorpus) |> unique


function chapterproportion(tokenlist, chapter; parser = p23, normfunction = downgrade23)
   
   chapttokens = filter(tokenlist) do t
        startswith(passagecomponent(urn(t)), "$(c).")
    end
    chaptnormed = map(tkn -> normfunction(tokentext(tkn)), chapttokens)
    vtokens = verbtokens(chaptnormed; parser = parser)

    length(vtokens) / length(tokenlist)
end



function verbproportion(tokenlist, chaptlist; parser = p23, normfunction = downgrade23)
    map(chaptlist) do c
        prop = chapterproportion(tokenlist, c; parser = parser, normfunction = normfunction)
        @info("$(c) -> $(prop)")
        prop
    end
end

lxxverbproportion = verbproportion(lxxlextokens, chaptlist)
targverbproportion = verbproportion(targlextokens, chaptlist)
vulgverbproportion = verbproportion(vulglextokens, chaptlist; normfunction = lowercase)

verbproportion(lxxlextokens, chaptlist[1:3])


using Plots
plotly()

xs = 1:37

plot(xs, lxxverbproportion)
plot!(xs, targverbproportion)
plot!(xs, vulgverbproportion)
#bar(x = xs, y = ys)

ys[1]


xs = [1,2,3]
ys  = [5,10,15]
bar(x = xs, y = ys)

plot(xs, ys)