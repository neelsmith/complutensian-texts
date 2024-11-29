using CitableBase, CitableCorpus, CitableText
using VectorAlignments
corpusurl = "https://github.com/neelsmith/compnov/raw/refs/heads/main/corpus/compnov.cex"
corpus = fromcex(corpusurl, CitableTextCorpus, UrlReader)


vulgate = filter(p -> endswith(workcomponent(p.urn), "vulgate"), corpus.passages) 
vbooks = map(p -> workid(p.urn), vulgate) |> unique

sept = filter(p -> endswith(workcomponent(p.urn), "septuagint"), corpus.passages)
sbooks = map(p -> workid(p.urn), sept) |> unique


masoretic = filter(p -> endswith(workcomponent(p.urn), "masoretic"), corpus.passages)
hbooks = map(p -> workid(p.urn), masoretic) |> unique

alignment = align(vbooks, sbooks, hbooks)


m = featurematrix(vbooks, sbooks, hbooks)