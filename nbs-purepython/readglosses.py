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
    mo.hstack([
        mo.md("*Notebook version*: **1.0.0** "), mo.md("*Data updated*: **2026-12-24**")
    ], justify="center",gap=1.2)
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    # Computensian Bible: read Latin glosses to translations
    """)
    return


@app.cell(hide_code=True)
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
def _(bookchoice, mo, passagechoice, targumdisplaychoices):
    targumdisplay = None
    if passagechoice.value:
        targumdisplay = mo.md(f"""## Latin glosses to Targum: *{bookchoice.value.title()}*, {passagechoice.value}

    *Display* {targumdisplaychoices}


    """)

    targumdisplay
    return (targumdisplay,)


@app.cell(hide_code=True)
def _(mo, targumblocks, targumdisplay):
    showtargum = None
    if targumdisplay:
        showtargum = mo.hstack(targumblocks)
    showtargum    
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
    ### Visual diffs
    """)
    return


@app.cell
def _(lxxdipltext, lxxnormtext, visual_diff):
    lxxdiffs = None
    if lxxdipltext:
        lxxdiffs = visual_diff(lxxdipltext, lxxnormtext)
    return (lxxdiffs,)


@app.cell
def _(targumdipltext, targumnormtext, visual_diff):
    targumdiffs = None
    if targumdipltext:
        targumdiffs = visual_diff(targumdipltext, targumnormtext)
    return (targumdiffs,)


@app.cell(hide_code=True)
def _(difflib, escape):
    def visual_diff(string1: str, string2: str) -> str:
        """
        Generate an HTML visual diff of two strings.

        Args:
            string1: The first string to compare
            string2: The second string to compare

        Returns:
            HTML string with highlighted differences:
            - Common text: no highlighting
            - Text only in string1: pastel yellow background
            - Text only in string2: pastel green background
        """
        # Use SequenceMatcher to find differences at character level
        matcher = difflib.SequenceMatcher(None, string1, string2)

        html_parts = []

        for opcode, i1, i2, j1, j2 in matcher.get_opcodes():
            if opcode == 'equal':
                # Common text - no highlighting
                html_parts.append(escape(string1[i1:i2]))
            elif opcode == 'delete':
                # Text only in string1 - yellow background
                text = escape(string1[i1:i2])
                html_parts.append(f'<span style="background-color: #ffe4b3;">{text}</span>')
            elif opcode == 'insert':
                # Text only in string2 - green background
                text = escape(string2[j1:j2])
                html_parts.append(f'<span style="background-color: #c6efce;">{text}</span>')
            elif opcode == 'replace':
                # Text changed - show deleted part in yellow and inserted part in green
                if i1 < i2:
                    text = escape(string1[i1:i2])
                    html_parts.append(f'<span style="background-color: #ffe4b3;">{text}</span>')
                if j1 < j2:
                    text = escape(string2[j1:j2])
                    html_parts.append(f'<span style="background-color: #c6efce;">{text}</span>')

        return ''.join(html_parts)

    return (visual_diff,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ### Display blocks
    """)
    return


@app.cell
def _(lxxdiffs, lxxdipltext, lxxdisplaychoices, lxxnormtext, mo):
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
        if "lxxdiffs" in lxxdisplaychoices.value:
            lxxblocks.append(mo.vstack([mo.md("**Difference**"), mo.md(lxxdiffs)]))     
    return (lxxblocks,)


@app.cell
def _(mo, targumdiffs, targumdipltext, targumdisplaychoices, targumnormtext):
    targumblocks = []
    targumcandidates =[
      "targumdiplresult",
      "targumnormresult",
      "targumdiffs"
    ]
    if targumnormtext:
        if "targumdiplresult" in targumdisplaychoices.value:
            targumblocks.append(mo.vstack([mo.md("**Diplomatic text**"), mo.md(targumdipltext)]))
        if "targumnormresult" in targumdisplaychoices.value:
            targumblocks.append(mo.vstack([mo.md("**Normalized text**"), mo.md(targumnormtext)]))   
        if "targumdiffs" in targumdisplaychoices.value:
            targumblocks.append(mo.vstack([mo.md("**Difference**"), mo.md(targumdiffs)])) 
    return (targumblocks,)


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
    return (targumdisplaychoices,)


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
    return lxxdipltext, lxxnormtext, targumdipltext, targumnormtext


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
        nb_location = mo.notebook_location()
        filenames = ["septuagint_latin_genesis_dipl.cex","septuagint_latin_genesis_norm.cex",
                     "targum_latin_genesis_dipl.cex","targum_latin_genesis_norm.cex"]
        
        # Check if running in WASM (URL) or local (Path)
        if isinstance(nb_location, str):
            # WASM mode - nb_location is a URL
            base_url = nb_location.rstrip('/') + '/public/'
            fullpaths = [base_url + f for f in filenames]
        else:
            # Local mode - nb_location is a Path
            editionsdir = nb_location / "public" 
            fullpaths = [str(editionsdir / f) for f in filenames]
        
        return [readedition(f) for f in fullpaths]


    return (readeditions,)


@app.cell
def _(StringIO, pl):
    def readedition(fname: str):
        """Read a CEX file with a single labelled block of delimited data, so omitting initial line.
        Return a polars dataframe
        """
        # Check if fname is a URL or local file path
        if fname.startswith('http://') or fname.startswith('https://'):
            # WASM mode - fetch from URL
            import urllib.request
            with urllib.request.urlopen(fname) as response:
                content = response.read().decode('utf-8')
                src = '\n'.join(content.split('\n')[2:])
        else:
            # Local mode - read from file
            with open(fname, 'r', encoding='utf-8') as file:
                src = '\n'.join(file.readlines()[2:])
        
        return pl.read_csv(StringIO(src), separator='|', has_header=False, new_columns=["urn", "text"]).drop_nulls()

        

    return (readedition,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ### Imports
    """)
    return


@app.cell
def _():
    import polars as pl
    from io import StringIO

    return StringIO, pl


@app.cell
def _():
    import re

    return (re,)


@app.cell
def _():
    import difflib
    from html import escape

    return difflib, escape


@app.cell
def _():
    import urllib.request 

    return


if __name__ == "__main__":
    app.run()
