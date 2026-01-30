from citable_corpus import CitableCorpus

def load_corpora(path: str | None = None) -> dict[str, CitableCorpus]:
    """From a CEX file with corpora of the Complutensian Bible, return a dict of CitableCorpus objects for each version."""

    if path is None:
        url = 'https://raw.githubusercontent.com/neelsmith/complutensian-texts/refs/heads/main/marimo-project/public/compnov.cex'
        #print("Woohoo, I'm loading...")
        corpus = CitableCorpus.from_cex_url(url)
    else:
        corpus = CitableCorpus.from_cex_file(path)
        
    return {
        "lxx": lxx(corpus),
        "masoretic": masoretic(corpus),
        "vulgate": vulgate(corpus),
        "onkelos": onkelos(corpus),
    }
    

def lxx(c: CitableCorpus):
    """Filter a citable corpus for only Septuagint passages."""
    psgs = [p for p in c.passages if p.urn.version == "septuagint"]
    return CitableCorpus(passages=psgs)    


def masoretic(c: CitableCorpus):
    """Filter a citable corpus for only Masoretic passages."""
    psgs = [p for p in c.passages if p.urn.version == "masoretic"]
    return CitableCorpus(passages=psgs) 

def vulgate(c: CitableCorpus):
    """Filter a citable corpus for only Vulgate passages."""
    psgs = [p for p in c.passages if p.urn.version == "vulgate"]
    return CitableCorpus(passages=psgs)   

def onkelos(c: CitableCorpus):
    """Filter a citable corpus for only Onkelos passages."""
    psgs = [p for p in c.passages if p.urn.version == "onkelos"]
    return CitableCorpus(passages=psgs)         