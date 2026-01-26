from citable_corpus import CitableCorpus


def load_corpus(path: str = "public/compnov.cex") -> CitableCorpus:
    corpus = CitableCorpus.from_cex_file(path)
    return corpus
    

def lxx(c: CitableCorpus):
    psgs = [p for p in c.passages if p.urn.version == "lxx"]
    CitableCorpus(passages=psgs)    