from citable_corpus import CitableCorpus


def load_corpus():
    corpus = CitableCorpus.from_cex_file("public/compnov.cex")
    return corpus
    

def lxx(c: CitableCorpus):
    psgs = [p for p in c.passages if p.urn.version == "lxx"]
    CitableCorpus(passages=psgs)    