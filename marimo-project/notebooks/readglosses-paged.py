# /// script
# dependencies = [
#     "dse-polars==0.3.2",
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
    # Read text of Latin glosses by page
    """)
    return


@app.cell(hide_code=True)
def _(page):
    page
    return


@app.cell(hide_code=True)
def _(lxxdisplaychoices, mo, page):
    lxxdisplay = None
    if page.value:
        lxxdisplay = mo.md(f"""## Latin glosses to Septuagint: page id `{page.value}`

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
    mo.Html("<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><hr/>")
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
    ### Display
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


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ### Text selection and formatting
    """)
    return


@app.cell
def _(collection, dse, page):
    psglist = []
    if page.value:
        psglist = dse.passagesforsurface(collection + page.value).to_series().to_list()
    return (psglist,)


@app.cell
def _(psglist):
    dipllist = [addversion(u, "diplomatic") for u in psglist]
    return (dipllist,)


@app.cell
def _(dipllist, lxxdipl, pl):
    lxxdiplpage = lxxdipl.filter(pl.col("urn").is_in(dipllist))
    return (lxxdiplpage,)


@app.cell
def _(lxxdiplpage, textcontents):
    lxxdipltext = " ".join(textcontents(lxxdiplpage))
    return (lxxdipltext,)


@app.cell
def _(psglist):
    normlist = [addversion(u, "normalized") for u in psglist]
    return (normlist,)


@app.cell
def _(lxxnorm, normlist, pl):
    lxxnormpage = lxxnorm.filter(pl.col("urn").is_in(normlist))
    return (lxxnormpage,)


@app.cell
def _(lxxnormpage, textcontents):
    lxxnormtext = " ".join(textcontents(lxxnormpage))
    return (lxxnormtext,)


@app.function
def addversion(ctsu: str, version: str) -> str:
    parts = ctsu.split(":")
    return ":".join([parts[0], parts[1], parts[2], parts[3] + f".{version}", parts[4]])


@app.cell
def _(lxxdipltext, lxxnormtext, visual_diff):
    lxxdiffs = None
    if lxxdipltext:
        lxxdiffs = visual_diff(lxxdipltext, lxxnormtext)
    return (lxxdiffs,)


@app.cell
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
    ### UI
    """)
    return


@app.cell
def _():
    #dropobject = r"^.+:"
    return


@app.cell
def _():
    collection = "urn:cite2:complut:pages.bne:"
    return (collection,)


@app.cell
def _():
    leaveobject = r"[^:]+$"
    return (leaveobject,)


@app.cell
def _(dse, leaveobject, pl):
    pagelist = (
        dse.surfaces().drop_nulls().select(
            pl.col("surface").str.extract_all(leaveobject).flatten()
        )
    ).to_series().to_list()
    return (pagelist,)


@app.cell
def _(mo, pagelist):
    page = mo.ui.dropdown(pagelist,label="*Page*:")
    return (page,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ### Load data
    """)
    return


@app.cell
def _(loadeditions):
    lxxdipl, lxxnorm, targumdipl, targumnorm = loadeditions()
    return lxxdipl, lxxnorm


@app.cell
def _(DSE, loaddse, lxxsrc, pl, targumsrc):
    lxxdf = loaddse(lxxsrc)
    targumdf = loaddse(targumsrc)
    dse = DSE(pl.concat([lxxdf, targumdf]).unique(maintain_order=True))
    return (dse,)


@app.cell
def _(mo):
    lxxsrc = str(mo.notebook_dir() / "public" / "septuagint_latin_genesis_dse.cex")
    targumsrc = str(mo.notebook_dir() / "public" / "targum_latin_genesis_dse.cex")
    return lxxsrc, targumsrc


@app.cell
def _(StringIO, lxxsrc, pl, urlopen):
    def loaddse(src):
        if src.startswith(("http://", "https://")):
            with urlopen(src) as response:
                csv_text = response.read().decode("utf-8")
                return pl.read_csv(StringIO(csv_text), separator="|", quote_char=None)
        else:
            return pl.read_csv(lxxsrc,separator="|",quote_char=None)

    return (loaddse,)


@app.cell
def _(loadedition, mo):
    def loadeditions():
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

        return [loadedition(f) for f in fullpaths]

    return (loadeditions,)


@app.cell
def _(StringIO, pl):
    def loadedition(fname: str):
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

    return (loadedition,)


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

    return


@app.cell
def _():
    from dse_polars import DSE, textcontents

    return DSE, textcontents


@app.cell
def _():
    import difflib
    from html import escape

    return difflib, escape


if __name__ == "__main__":
    app.run()
