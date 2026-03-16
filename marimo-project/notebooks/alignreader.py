# /// script
# dependencies = [
#     "marimo",
#     "polars==1.39.0",
#     "requests==2.32.5",
# ]
# requires-python = ">=3.13"
# ///

import marimo

__generated_with = "0.20.4"
app = marimo.App(width="columns")


@app.cell(column=0, hide_code=True)
def _():
    import marimo as mo

    return (mo,)


@app.cell
def _(mo, passagechoice, versionchoices):
    mo.md(f"{passagechoice} {versionchoices}")
    return


@app.cell(column=1, hide_code=True)
def _(mo):
    mo.md("""
    ## UI
    """)
    return


@app.cell
def _(genesis, pl):
    psglist = [s.split(" ")[1] for s in genesis.select(pl.col("passage").unique(maintain_order=True)).to_series().to_list()]
    return (psglist,)


@app.cell
def _(mo, psglist):
    passagechoice = mo.ui.dropdown(psglist, label="*Genesis passage*:")

    return (passagechoice,)


@app.cell
def _(mo, versions_menu):
    versionchoices = mo.ui.multiselect(
        options=versions_menu, label="*Versions to include*:"
    )

    return (versionchoices,)


@app.cell
def _():
    versions_menu = {"Greek Septuagint (lxx)": "lxx", "Latin Vulgate (vulgate)": "vulgate", "Masoretic Hebrew (masoretic)": "masoretic",
                "Aramaic Targum Onkelos (onkelos)": "onkelos"}
    return (versions_menu,)


@app.cell
def _(versions_menu):
    versionids = [v for v in versions_menu.values()]
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## Load alignment data
    """)
    return


@app.cell
def _(mo):
    srcpath= mo.notebook_location() / "public" / "genesis-verbs-numbered.cex"
    return (srcpath,)


@app.cell
def _(unicodedata):
    def strip_to_alphabetic(value):
        """Keep alphabetic characters only (drops niqqud and other marks)."""
        if value is None:
            return None


        normalized = unicodedata.normalize("NFKD", value)
        return "".join(ch for ch in normalized if ch.isalpha())

    return (strip_to_alphabetic,)


@app.cell
def _(datetime, os, pl, srcpath, strip_to_alphabetic):
    lastmodstamp = os.path.getmtime(srcpath)
    lastmod = datetime.datetime.fromtimestamp(lastmodstamp).strftime('%Y-%m-%d %H:%M:%S')
    df = pl.read_csv(str(srcpath),  separator = "|", truncate_ragged_lines=True)

    strip_targets = [
        ("hebrew_lemma", "hebrew_lemma_stripped"),
        ("latin_lemma", "latin_lemma_stripped"),
        ("greek_lemma", "greek_lemma_stripped"),
        ("aramaic_lemma", "aramaic_lemma_stripped"),
    ]
    strip_exprs = [
        pl.col(source)
        .map_elements(strip_to_alphabetic, return_dtype=pl.Utf8)
        .alias(target)
        for source, target in strip_targets
        if source in df.columns
    ]
    if strip_exprs:
        df = df.with_columns(strip_exprs)
    return (df,)


@app.cell
def _(df, pl):
    genesis = df.filter(pl.col("passage").str.starts_with("genesis"))
    return (genesis,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## Load texts
    """)
    return


@app.cell
def _(mo):
    textpath = mo.notebook_location() / "public" / "compnov.cex"
    return (textpath,)


@app.cell
def _(co, textpath):
    corpdict = co.load_corpora(textpath)
    return (corpdict,)


@app.cell
def _(corpdict):

    corpdict['vulgate'].passages[0].urn.work
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## Imports
    """)
    return


@app.cell
def _():
    import complutensian as co

    return (co,)


@app.cell
def _():
    import os
    import datetime


    return datetime, os


@app.cell
def _():
    import unicodedata

    return (unicodedata,)


@app.cell
def _():
    import polars as pl

    return (pl,)


@app.cell
def _():
    return


if __name__ == "__main__":
    app.run()
