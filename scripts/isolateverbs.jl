using OpenScripturesHebrew
words = tanakh()
hebrew = filter(w -> language(w.code) isa HebrewLanguage, words)
verbs = filter(w -> isverb(w), hebrew)


using CitableBase, CitableText, CitableCorpus

srcurl = "https://raw.githubusercontent.com/neelsmith/compnov/main/corpus/compnov.cex"
corpus = fromcex(srcurl, CitableTextCorpus, UrlReader) 


vulgate = filter(corpus.passages) do psg
    versionid(psg.urn) == "vulgate"
end |> CitableTextCorpus

lxx = filter(corpus.passages) do psg
    versionid(psg.urn) == "septuagint"
end |> CitableTextCorpus


