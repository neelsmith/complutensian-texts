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


@app.cell
def _():
    import marimo as mo

    return (mo,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    # Read text of Latin glosses by page
    """)
    return


@app.cell
def _(page):
    page
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ### UI
    """)
    return


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
    page = mo.ui.dropdown(pagelist)
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
    return


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
    from dse_polars import DSE

    return (DSE,)


if __name__ == "__main__":
    app.run()
