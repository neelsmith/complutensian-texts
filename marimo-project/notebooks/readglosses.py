# /// script
# dependencies = [
#     "citable-corpus==0.2.0",
#     "marimo",
#     "urn-citation==0.7.2",
# ]
# requires-python = ">=3.14"
# ///

import marimo

__generated_with = "0.19.6"
app = marimo.App(width="medium")


@app.cell(hide_code=True)
def _():
    import marimo as mo
    return (mo,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    # Read Latin glosses
    """)
    return


@app.cell(hide_code=True)
def _(bookchoice, chapterchoice, mo, passagechoice):
    mo.md(f"{bookchoice} *Chapter* {chapterchoice} *Passage* {passagechoice}")
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    # Computation
    """)
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## Navigation
    """)
    return


@app.cell
def _(chapterchoice, lxxdipl):
    allpassages = [p.urn.passage for p in lxxdipl.passages]
    passages = []
    if chapterchoice.value:
        passages = [p for p in allpassages if p.startswith(chapterchoice.value + ".")]
    return (passages,)


@app.cell
def _(chapterchoice):
    chapterchoice.value
    return


@app.cell
def _(mo, passages):
    passagechoice = mo.ui.dropdown(passages)
    return (passagechoice,)


@app.cell
def _():
    books = {"Genesis": "genesis"}
    return (books,)


@app.cell
def _(books, mo):
    bookchoice = mo.ui.dropdown(books,value="Genesis")
    return (bookchoice,)


@app.cell
def _(lxxdipl, re):
    chappattern = r"\..+"
    allchaps = [re.sub(chappattern, "", p.urn.passage) for p in lxxdipl.passages]
    chapters = list(dict.fromkeys(allchaps))
    return (chapters,)


@app.cell
def _(chapters, mo):
    chapterchoice = mo.ui.dropdown(chapters)
    return (chapterchoice,)


@app.cell
def _(chapters):
    chapters[0:10]
    return


@app.cell
def _():
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## Load data
    """)
    return


@app.cell
def _(buildeditions, targumglossfile, targumglossurn):
    targumdipl, targumnorm = buildeditions(targumglossfile, targumglossurn)
    return


@app.cell
def _(buildeditions, lxxglossfile, lxxglossurn):
    lxxdipl, lxxnorm = buildeditions(lxxglossfile, lxxglossurn)
    return (lxxdipl,)


@app.cell
def _(Path, TEIDiplomatic, TEIDivAbReader, TEINormalized):
    def buildeditions(fpath: Path, baseurn):
        glosstext = fpath.read_text(encoding="utf-8")
        xmlcorpus = TEIDivAbReader.corpus(glosstext, baseurn)
        dipl = TEIDiplomatic.edition(xmlcorpus)
        norm = TEINormalized.edition(xmlcorpus)
        return (dipl, norm)
    return (buildeditions,)


@app.cell
def _(Path):
    lxxglossfile = Path.cwd().parent / "editions" / "septuagint_latin_genesis.xml"
    return (lxxglossfile,)


@app.cell
def _():
    lxxglossurn = "urn:cts:compnov:bible.genesis.sept_latin:"
    return (lxxglossurn,)


@app.cell
def _(Path):
    targumglossfile = Path.cwd().parent / "editions" / "targum_latin_genesis.xml"
    return (targumglossfile,)


@app.cell
def _():
    targumglossurn = "urn:cts:compnov:bible.genesis.targum_latin:"
    return (targumglossurn,)


@app.cell
def _():
    from urn_citation import CtsUrn
    from citable_corpus import CitableCorpus, CitablePassage, TEIDivAbReader, TEIDiplomatic, TEINormalized
    return TEIDiplomatic, TEIDivAbReader, TEINormalized


@app.cell
def _():
    from pathlib import Path
    import re
    return Path, re


if __name__ == "__main__":
    app.run()
