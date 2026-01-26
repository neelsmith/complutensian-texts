import marimo

__generated_with = "0.19.4"
app = marimo.App(width="medium")


@app.cell
def _():
    import marimo as mo
    from citable_corpus import CitablePassage, CitableCorpus
    from urn_citation import CtsUrn
    return


@app.cell
def _():
    import src.textloading as textloading
    return (textloading,)


@app.cell
def _(textloading):
    corpus = textloading.load_corpus()
    return (corpus,)


@app.cell
def _(corpus):
    len(corpus)
    return


@app.cell
def _(corpus):
    corpus.passages[0].urn
    return


@app.cell
def _(corpus, textloading):
    lxx = textloading.lxx(corpus)
    return


if __name__ == "__main__":
    app.run()
