using CitableBase, CitableText, CitableCorpus
using Orthography, PolytonicGreek
using CitableParserBuilder
using Downloads
using Kanones
using LatinOrthography
using Tabulae
using StatsBase, OrderedCollections

repo = pwd()

# Greek parser and parsing utilities
"""Instantiate Complutensian parser for Septuagint"""
function buildkparser()
	   url = "http://shot.holycross.edu/morphology/complutensian-current.cex"
	   f = Downloads.download(url)
	   data = readlines(f)
	   rm(f)
	   KanonesStringParser(data, literaryGreek(), "|")
end
greekparser = buildkparser()

function greeklkabeldict()
    compositedict = Dict()
    dict1 = "https://raw.githubusercontent.com/neelsmith/Kanones.jl/refs/heads/main/datasets/lsj-vocab/lexemes/lsj.cex"
    f1 = Downloads.download(dict1)
    for ln in filter(ln -> ! isempty(ln), readlines(f1))[2:end]
        (id, label) = split(ln, "|")
        compositedict[id] = label
    end
    rm(f1)


    dict2 = "https://raw.githubusercontent.com/neelsmith/Kanones.jl/refs/heads/main/datasets/lsj-vocab/lexemes/lsjx.cex"
    f2 = Downloads.download(dict2)
    for ln in filter(ln -> ! isempty(ln), readlines(f2))[2:end]
        (id, label) = split(ln, "|")
        compositedict[id] = label
    end
    rm(f2)

    compositedict
end
greeklabels = greeklkabeldict()




# Latin parser and parsing utilities
p25url = "http://shot.holycross.edu/tabulae/complut-lat25-current.cex"
vulgateparser = tabulaeStringParser(p25url, UrlReader)
latinlabels = Tabulae.lexlemma_dict_remote()


# Text corpus
srcurl = "https://raw.githubusercontent.com/neelsmith/compnov/main/corpus/compnov.cex"
corpus = fromcex(srcurl, CitableTextCorpus, UrlReader) 

function book(corpus::CitableTextCorpus, version, bookid)
    filter(corpus.passages) do psg
        versionid(psg.urn) == version &&
        workid(psg.urn) == bookid
    end |> CitableTextCorpus
end

# 1. ISOLATE VERBS IN GREEK LXXX
#lxxbook = book(corpus, "septuagint", "genesis")
#@time lxxbooktokens = tokenize(lxxbook, literaryGreek())
# lxxbooklex = filter(t -> tokencategory(t) isa LexicalToken, lxxbooktokens)
lxx = filter(p -> versionid(p.urn) == "septuagint", corpus.passages) |> CitableTextCorpus
@time lxxtokens = tokenize(lxx, literaryGreek())
lxxlex = filter(t -> tokencategory(t) isa LexicalToken, lxxtokens)


"""True if a GreekMorphologicalForm is a verbal form."""
function is_greek_verb(f::T) where T <: GreekMorphologicalForm
    f isa GMFFiniteVerb ||
    f isa GMFInfinitive ||
    f isa GMFParticiple ||
    f isa GMFVerbalAdjective
end

"""Parse all citable tokens in a list, and return pairs of passage ids + lexeme id
for verb forms only.
"""
function isolate_greek_verbs(ctokenlist, parser, labelsdict; messageinterval = 1000 )
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
            if is_greek_verb(f)
                lexid = string(p.lexeme)
                @debug("Verb form: $(str) =  $(f) from $(lexid)")
                lbl = haskey(labelsdict, string(lexid)) ? labelsdict[lexid] : "no_label"
                push!(greekverbs, (ref = id, lexeme = lexid, label = lbl))
            end
        end
    end
    greekverbs
end

@time greekverblexemes = isolate_greek_verbs(lxxlex, greekparser, greeklabels)
#@time greekverblexemes = isolate_greek_verbs(lxxbooklex, greekparser, greeklabels)
greekverblexemes[1]


greekverbstrings = map(greekverblexemes) do tupl
    string(tupl.ref, "|", tupl.lexeme, "|", tupl.label)
end
hdr = "ref|lexeme|label\n"
greekverbfile = joinpath(repo, "data", "greek", "greekverbs.cex")
open(greekverbfile, "w") do io
    write(io, hdr * join(greekverbstrings, "\n"))
end



# 2. ISOLATE VERBS IN LATIN VULGATE
vulgate = filter(corpus.passages) do psg
    versionid(psg.urn) == "vulgate"
end |> CitableTextCorpus
@time vulgatetokens = tokenize(vulgate, latin25())
vulgatelex = filter(t -> tokencategory(t) isa LexicalToken, vulgatetokens)
#vulgatebook = book(corpus, "vulgate", "genesis")
#@time vulgatebooktokens = tokenize(vulgatebook, latin25())
#vulgatebooklex = filter(t -> tokencategory(t) isa LexicalToken, vulgatebooktokens)

"""True if a LatinMorphologicalForm is a verbal form."""
function is_latin_verb(f::T) where T <: LatinMorphologicalForm
    f isa LMFFiniteVerb ||
    f isa LMFGerundive ||
    f isa LMFInfinitive ||
    f isa LMFParticiple
    # omit supine for now
end


function isolate_latin_verbs(ctokenlist, parser, labelsdict = latinlabels; messageinterval = 1000 )
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
                lexid = string(p.lexeme)
                @debug("Verb form: $(str) =  $(f) from $(lexid)")
                lbl = haskey(labelsdict, string(lexid)) ? labelsdict[lexid] : "no_label"
                push!(latinverbs, (ref = id, lexeme = lexid, label = lbl))
                #push!(latinverbs, (ref = id, lexeme = lexid))
            end
        end
    end
    latinverbs
end

#@time latinverblexemes = isolate_latin_verbs(vulgatebooklex, vulgateparser)
@time latinverblexemes = isolate_latin_verbs(vulgatelex, vulgateparser)


latinverbstrings = map(latinverblexemes) do tupl
    string(tupl.ref, "|", tupl.lexeme, "|", tupl.label)
end

latinverbfile = joinpath(repo, "data", "latin", "latinverbs.cex")
open(latinverbfile, "w") do io
    write(io, hdr * join(latinverbstrings, "\n"))
end






# 3. Isolate verb data from Sefaria
datadir = joinpath(repo, "data", "sefaria")
cexsrc = filter(f -> endswith(f, "cex"), readdir(datadir))

function isolatesefariafiles(flist, srcdir = datadir)
    tuples = []
    for f in flist
        datalines = readlines(joinpath(srcdir, f))[2:end]
        #urn:cts:compnov:bible.genesis.masoretic_tokens:1.1.2|בָּרָ֣א|בָּרָא|BDB01439
        for ln in filter(ln -> ! isempty(ln), datalines)
            (urnstr, form, lemma, lexid) = split(ln, "|")
            u = CtsUrn(urnstr)
            id = join([workid(u), passagecomponent(collapsePassageBy(u,1))], ":")
            push!(tuples, (ref = id, lexeme = lexid, label = lemma, form = form))

        end
    end
    tuples
end

#@time sefariaverblexemes = isolatesefariafiles(["genesis.cex"])
@time sefariaverblexemes = isolatesefariafiles(cexsrc)
sefariaverblexemes[1]

sefariaverbstrings = map(sefariaverblexemes) do tupl
    string(tupl.ref, "|", tupl.lexeme, "|", tupl.label, "|", tupl.form)
end

sefariahdr = hdr = "ref|lexeme|label|form\n"
hebrewverbfile = joinpath(repo, "data", "hebrew", "sefariaverbs.cex")
open(hebrewverbfile, "w") do io
    write(io, hdr * join(sefariaverbstrings, "\n"))
end



# Find coocurrences:

function cooccurs(tuples1, tuples2; messageinterval = 5)
    masterdict = Dict()
    lemmalist = map(t -> string(t.lexeme), tuples1)
    uniquelemms = unique(lemmalist)
    lemmalabel = ""

    @info("Counting cooccurrences for $(length(uniquelemms)) lexemes")
    count = 0
    for lemm in uniquelemms
        count = count + 1

        cooccurlemms = []
        lemtuples = filter(t -> t.lexeme == lemm, tuples1)
        lemmalabel = lemm * ":" * lemtuples[1].label

        #if mod(count, messageinterval) == 0
        @info("$(lemmalabel): $(count) / $(length(unique(lemmalist))). $(length(lemtuples)) passages in source 1")
        #end

        passagecount = 0
        for t1 in lemtuples
            passagecount = passagecount + 1
            @info("$(count) / $(length(unique(lemmalist))) -> $(lemmalabel): $(t1.ref) $(passagecount) / $(length(lemtuples))")
            matches = filter(t2 -> t2.ref == t1.ref, tuples2)
            for v in matches
                push!(cooccurlemms, string(v.lexeme,":", v.label))
            end
        end 
        counted = sort(OrderedDict(countmap(cooccurlemms)), rev=true, byvalue=true)
        
        masterdict[lemmalabel] = counted
      
    end

    masterdict
end



function tabulate(dictofdicts)
    output = []
    for k in keys(dictofdicts)
        subdict = dictofdicts[k]
        for k2 in keys(subdict)
            push!(output, string(k,"|", k2, "|", subdict[k2]))
        end
    end
    output
end


@time Sept2Vulg = cooccurs(greekverblexemes, latinverblexemes)
s2vtable = tabulate(Sept2Vulg)


coocurhdr = "lemma1|lemma2|count\n"
s2vfile = joinpath(repo, "data", "cooccurrences", "septuagint_vulgate.cex")
open(s2vfile, "w") do io
    write(io, coocurhdr * join(s2vtable, "\n"))
end



Sept2Hebrew = cooccurs(greekverblexemes, sefariaverblexemes)
s2htable = tabulate(Sept2Hebrew)

s2hfile = joinpath(repo, "data", "cooccurrences", "septuagint_hebrew.cex")
open(s2hfile, "w") do io
    write(io, coocurhdr * join(s2htable, "\n"))
end


Hebrew2Vulg =  cooccurs(sefariaverblexemes, latinverblexemes)
h2vtable = tabulate(Hebrew2Vulg)

h2vfile = joinpath(repo, "data", "cooccurrences", "hebrew_vulgate.cex")
open(h2vfile, "w") do io
    write(io, coocurhdr * join(h2vtable, "\n"))
end


Hebrew2Sept =  cooccurs(sefariaverblexemes, greekverblexemes)
h2stable = tabulate(Hebrew2Sept)

h2sfile = joinpath(repo, "data", "cooccurrences", "hebrew_septuagint.cex")
open(h2sfile, "w") do io
    write(io, coocurhdr * join(h2stable, "\n"))
end

Vulg2Sept = cooccurs(latinverblexemes, greekverblexemes)
v2stable = tabulate(Vulg2Sept)


v2sfile = joinpath(repo, "data", "cooccurrences", "vulgate_septuagint.cex")
open(v2sfile, "w") do io
    write(io, coocurhdr * join(v2stable, "\n"))
end

Vulg2Hebrew = cooccurs(latinverblexemes, sefariaverblexemes)
v2htable = tabulate(Vulg2Hebrew)



v2hfile = joinpath(repo, "data", "cooccurrences", "vulgate_hebrew.cex")
open(v2hfile, "w") do io
    write(io, coocurhdr * join(v2htable, "\n"))
end






## Use these for surveying coverage #########################################################
#=
@time lxxstringtokens = map(t -> knormal(tokentext(t)), lxxlex)
using StatsBase, OrderedCollections
lxxstringcounts = sort(OrderedDict(countmap(lxxstringtokens)); rev = true, byvalue = true)
=#
