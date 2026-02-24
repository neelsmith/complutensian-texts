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
def _(bookchoice, lxxdisplaychoices, mo, passagechoice):
    lxxdisplay = None
    if passagechoice.value:
        lxxdisplay = mo.md(f"""## Latin glosses to Septuagint: : *{bookchoice.value.title()}*, {passagechoice.value}

    *Display* {lxxdisplaychoices}


    """)

    lxxdisplay    
    return (lxxdisplay,)


@app.cell(hide_code=True)
def _(lxxblocks, lxxdisplay, mo):
    showlxx = None
    if lxxdisplay:
        showlxx = mo.hstack(lxxblocks)
    showlxx    
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
    ### Display blocks
    """)
    return


@app.cell
def _(lxxdisplaychoices):
    lxxdisplaychoices.value
    return


@app.cell
def _(lxxdipltext, lxxdisplaychoices, lxxnormtext, mo):
    lxxblocks = []
    lxxcandidates = [
      "lxxdiplresult",
      "lxxnormresult",
      "lxxdiffs"
    ]
    if lxxnormtext:
        if "lxxdiplresult" in lxxdisplaychoices.value:
            lxxblocks.append(mo.vstack([mo.md("**Diplomatic text**"), mo.md(lxxdipltext)]))
        if "lxxnormresult" in lxxdisplaychoices.value:
            lxxblocks.append(mo.vstack([mo.md("**Normalized text**"), mo.md(lxxnormtext)]))   
        #if "lxxdiffs" in lxxdisplaychoices.value:
        #    lxxblocks.append(mo.vstack([mo.md("**Difference**"), mo.md(lxxdiffs)]))     
    return (lxxblocks,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ### Display choices
    """)
    return


@app.cell
def _(lxxdisplayblocks, mo):
    lxxdisplaychoices = mo.ui.multiselect(options = lxxdisplayblocks, value = list(lxxdisplayblocks.keys()))
    return (lxxdisplaychoices,)


@app.cell
def _(mo, targumdisplayblocks):
    targumdisplaychoices = mo.ui.multiselect(options = targumdisplayblocks, value = list(targumdisplayblocks.keys()))
    return


@app.cell
def _():
    lxxdisplayblocks = {
        "Septuagint glosses: diplomatic text": "lxxdiplresult",
        "Septuagint glosses: normalized": "lxxnormresult",
        "Septuagint glosses: visual diff": "lxxdiffs"
    }
    return (lxxdisplayblocks,)


@app.cell
def _():
    targumdisplayblocks = {
        "Targum glosses: diplomatic text": "targumdiplresult",
        "Targum glosses: normalized": "targumnormresult",
        "Targum glosses: visual diff": "targumdiffs"
    }
    return (targumdisplayblocks,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ### Text selection
    """)
    return


@app.cell
def _(lxxdipl, lxxnorm, passagechoice, pl, targumdipl, targumnorm):
    def lookup_passages():
        """Get text contents of passages matching user's current selection."""
        lxxglossurnbase = "urn:cts:compnov:bible.genesis.sept_latin"
        targumglossurnbase = "urn:cts:compnov:bible.genesis.targum_latin"
    
        if passagechoice.value:
            lxxdipl_urn = lxxglossurnbase + ".diplomatic:" + passagechoice.value
            lxxdiplrows = lxxdipl.filter(pl.col("urn") == lxxdipl_urn).get_column("text")
            lxxdipltext = "\n".join(lxxdiplrows)

            lxxnorm_urn = lxxglossurnbase + ".normalized:" + passagechoice.value
            lxxnormrows = lxxnorm.filter(pl.col("urn") == lxxnorm_urn).get_column("text")
            lxxnormtext = "\n".join(lxxnormrows)

            targumdipl_urn = targumglossurnbase + ".diplomatic:" + passagechoice.value
            targumdiplrows = targumdipl.filter(pl.col("urn") == targumdipl_urn).get_column("text")
            targumdipltext = "\n".join(targumdiplrows)

            targumnorm_urn = targumglossurnbase + ".normalized:" + passagechoice.value
            targumnormrows = targumnorm.filter(pl.col("urn") == targumnorm_urn).get_column("text")
            targumnormtext = "\n".join(targumnormrows)
        
        
            return [lxxdipltext, lxxnormtext, targumdipltext, targumnormtext]
        
        else:
            return [None,None, None, None]

    return (lookup_passages,)


@app.cell
def _(lookup_passages):
    lxxdipltext, lxxnormtext, targumdipltext, targumnormtext = lookup_passages()
    return lxxdipltext, lxxnormtext


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
    return lxxdipl, lxxnorm, targumdipl, targumnorm


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
