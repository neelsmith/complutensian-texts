# 1. ISOLATE HEBREW VERBS
using OpenScripturesHebrew
words = tanakh()
hebrew = filter(w -> language(w.code) isa HebrewLanguage, words)
hebrewverbs = filter(w -> isverb(w), hebrew)
# Map to tuple of passage + lexeme
oshverblexemes = map(hebrewverbs) do v
    trueurn = CtsUrn(v.urn)
    id = join([workid(trueurn), passagecomponent(trueurn)], ":")
    (ref = id, lexeme = v.lemma)
end



repo = pwd()
datadir = joinpath(repo, "data")
genesisfile = joinpath(datadir, "genesis.cex")

data = filter(readlines(genesisfile)[2:end]) do ln
    ! isempty(ln)
end

data[1:10]
