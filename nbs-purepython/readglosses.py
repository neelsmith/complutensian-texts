# /// script
# dependencies = [
#     "marimo",
#     "polars==1.38.1",
# ]
# requires-python = ">=3.14"
# ///

import marimo

__generated_with = "0.20.2"
app = marimo.App(width="medium")


@app.cell(hide_code=True)
def _():
    import marimo as mo

    return (mo,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    # Computensian Bible: read Latin glosses to translations
    """)
    return


@app.cell
def _(bookchoice, chapterchoice, mo, passagechoice):
    mo.md(f"""
    *Book* {bookchoice} *chapter* {chapterchoice} *passage* {passagechoice}
    """)
    return


@app.cell(hide_code=True)
def _(mo):
    mo.Html("<hr/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>")
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## Computation
    """)
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ### Navigation
    """)
    return


@app.cell
def _(mo):
    books = {"Genesis": "genesis"}
    bookchoice = mo.ui.dropdown(books,value="Genesis")
    return (bookchoice,)


@app.cell
def _(lxxdipl, re):
    passagepattern = r".+:"
    ulist = lxxdipl.get_column("urn").to_list()
    passagelist = [re.sub(passagepattern, "", ref) for ref in ulist]

    return (passagelist,)


@app.cell
def _(mo, passages):
    passagechoice = mo.ui.dropdown(passages)
    return (passagechoice,)


@app.cell
def _(chapterchoice):
    chapterchoice.value
    return


@app.cell
def _(passagelist, re):
    chappattern = r"\..+"
    allchaps = [re.sub(chappattern, "", p) for p in passagelist]
    chapters = list(dict.fromkeys(allchaps))
    return (chapters,)


@app.cell
def _(chapters, mo):
    chapterchoice = mo.ui.dropdown(chapters)
    return (chapterchoice,)


@app.cell
def _(mo):
    mo.md("""
    **Text selection**
    """)
    return


@app.cell
def _(passages):
    passages
    return


@app.cell
def _(chapterchoice, passagelist):
    passages = []
    if chapterchoice.value:
        passages = [p for p in passagelist if p.startswith(chapterchoice.value + ".")]
    return (passages,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ### Load data
    """)
    return


@app.cell
def _(readeditions):
    lxxdipl, lxxnorm, targumdipl, targumnorm = readeditions()
    return (lxxdipl,)


@app.cell
def _(mo, readedition):
    def readeditions():
        editionsdir = mo.notebook_location().parent / "cex-editions" 
        filenames = ["septuagint_latin_genesis_dipl.cex","septuagint_latin_genesis_norm.cex",
                     "targum_latin_genesis_dipl.cex","targum_latin_genesis_norm.cex"]
        fullpaths = [str(editionsdir / f) for f in filenames]
        return [readedition(f) for f in fullpaths]


    return (readeditions,)


@app.cell
def _(StringIO, pl):
    def readedition(fname: str):
        """Read a CEX file with a single labelled block of delimited data, so omitting initial line.
        Return a polars dataframe
        """
        with open(fname, 'r', encoding='utf-8') as file:
            src = '\n'.join(file.readlines()[2:])
            return pl.read_csv(StringIO(src),separator='|', has_header=False, new_columns=["urn", "text"]).drop_nulls()

    return (readedition,)


@app.cell
def _():
    import polars as pl
    from io import StringIO

    return StringIO, pl


@app.cell
def _():
    import re

    return (re,)


if __name__ == "__main__":
    app.run()
