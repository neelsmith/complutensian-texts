# 1. ISOLATE HEBREW VERBS
using OpenScripturesHebrew
words = tanakh()
hebrew = filter(w -> language(w.code) isa HebrewLanguage, words)
hebrewverbs = filter(w -> isverb(w), hebrew)
# Map to tuple of passage + lexeme
oshverblexemes = map(hebrewverbs) do v
    trueurn = CtsUrn(v.urn)
    id = join([workid(trueurn), passagecomponent(trueurn)], ":")
    (ref = id, lexeme = v.lemma, mtoken = v.mtoken, otoken = v.otoken)
end


repo = pwd()
datadir = joinpath(repo, "data")
cexsrc = filter(f -> endswith(f, "cex"), readdir(datadir))

using CitableText


function isolatesefariafiles(flist)
    tuples = []
    for f in flist
        datalines = readlines(joinpath(datadir, f))[2:end]
        #urn:cts:compnov:bible.genesis.masoretic_tokens:1.1.2|בָּרָ֣א|בָּרָא|BDB01439
        for ln in filter(ln -> ! isempty(ln), datalines)
            (urnstr, form, lemma, lexid) = split(ln, "|")
            u = CtsUrn(urnstr)
            id = join([workid(u), passagecomponent(collapsePassageBy(u, 1))], ":")
            push!(tuples, (ref = id, lexeme = lexid, label = lemma))

        end
    end
    tuples
end

sefariaverblexemes = isolatesefariafiles(cexsrc)


