# 1. ISOLATE HEBREW VERBS
using OpenScripturesHebrew
words = tanakh()
hebrew = filter(w -> language(w.code) isa HebrewLanguage, words)
hebrewverbs = filter(w -> isverb(w), hebrew)
# Map to tuple of passage + lexeme
@time hebrewverblexems = map(hebrewverbs) do v
    trueurn = CtsUrn(v.urn)
    id = join([workid(trueurn), passagecomponent(trueurn)], ":")
    (ref = id, lexeme = v.lemma)
end

# 2. ISOLATE VERBS IN GREEK LXXX
using CitableBase, CitableText, CitableCorpus
srcurl = "https://raw.githubusercontent.com/neelsmith/compnov/main/corpus/compnov.cex"
corpus = fromcex(srcurl, CitableTextCorpus, UrlReader) 

lxx = filter(corpus.passages) do psg
    versionid(psg.urn) == "septuagint"
end |> CitableTextCorpus

using Orthography, PolytonicGreek
@time lxxtokens = tokenize(lxx, literaryGreek())
lxxlex = filter(t -> tokencategory(t) isa LexicalToken, lxxtokens)



using CitableParserBuilder
using Downloads
using Kanones
"""Insantiate Complutensian parser for Septuagint"""
function buildkparser()
	   url = "http://shot.holycross.edu/morphology/complutensian-current.cex"
	   f = Downloads.download(url)
	   data = readlines(f)
	   rm(f)
	   KanonesStringParser(data, literaryGreek(), "|")
end

greekparser = buildkparser()
"""True if a GreekMorphologicalForm is a verbal form."""
function is_verb(f::T) where T <: GreekMorphologicalForm
    f isa GMFFiniteVerb ||
    f isa GMFInfinitive ||
    f isa GMFParticiple ||
    f isa GMFVerbalAdjective
end



"""Parse all citable tokens in a list, and return pairs of passage ids + lexeme id
for verb forms only.
"""
function isolate_greek_verbs(ctokenlist, parser; messageinterval = 1000 )
    i = 0
    greekverbs = []
    for t in ctokenlist
        id = join([workid(t.passage.urn), passagecomponent(collapsePassageBy(t.passage.urn,1))], ":")

        i = i + 1
        if mod(i, messageinterval) == 0
            @info("$(i):  $(id)")
        end
        
        str = t.passage.text
        parses = parsetoken(t.passage.text, parser)
        @debug("$(id) has $(length(parses)) parses.")
        for p in parses
            f = greekForm(p.form)
            if is_verb(f)
                lexid = p.lexeme
                @debug("Verb form: $(str) =  $(f) from $(lexid)")
                push!(greekverbs, (ref = id, lexeme = lexid))
            end
        end
    end
    greekverbs
end

@time greekverblexemes = isolate_greek_verbs(lxxlex, greekparser)


# 2. ISOLATE VERBS IN LATIN VULGATE
using LatinOrthography
using Tabulae

vulgate = filter(corpus.passages) do psg
    versionid(psg.urn) == "vulgate"
end |> CitableTextCorpus
@time vulgatetokens = tokenize(vulgate, latin25())
vulgatelex = filter(t -> tokencategory(t) isa LexicalToken, vulgatetokens)


p25url = "http://shot.holycross.edu/tabulae/complut-lat25-current.cex"
vulgateparser = tabulaeStringParser(p25url, UrlReader)




"""True if a LatinMorphologicalForm is a verbal form."""
function is_latin_verb(f::T) where T <: LatinMorphologicalForm
    f isa LMFFiniteVerb ||
    f isa LMFGerundive ||
    f isa LMFInfinitive ||
    f isa LMFParticiple
    # omit supine for now
end


function isolate_latin_verbs(ctokenlist, parser; messageinterval = 1000 )
    i = 0
    latinverbs = []
    for t in ctokenlist
        id = join([workid(t.passage.urn), passagecomponent(collapsePassageBy(t.passage.urn,1))], ":")

        i = i + 1
        if mod(i, messageinterval) == 0
            @info("$(i):  $(id)")
        end
        
        str = t.passage.text
        parses = parsetoken(t.passage.text, parser)
        @debug("$(id) has $(length(parses)) parses.")
        for p in parses
            f = latinForm(p.form)
            if is_latin_verb(f)
                lexid = p.lexeme
                @debug("Verb form: $(str) =  $(f) from $(lexid)")
                push!(latinverbs, (ref = id, lexeme = lexid))
            end
        end
    end
    latinverbs
end

@time latinverblexemes = isolate_latin_verbs(vulgatelex, vulgateparser)




## Use these for surveying coverage #########################################################
#=
@time lxxstringtokens = map(t -> knormal(tokentext(t)), lxxlex)
using StatsBase, OrderedCollections
lxxstringcounts = sort(OrderedDict(countmap(lxxstringtokens)); rev = true, byvalue = true)

=#