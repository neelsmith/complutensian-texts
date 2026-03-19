# /// script
# dependencies = [
#     "marimo",
#     "polars==1.39.2",
# ]
# requires-python = ">=3.14"
# ///

import marimo

__generated_with = "0.21.1"
app = marimo.App(width="columns", layout_file="layouts/viewdf.grid.json")


@app.cell(column=0, hide_code=True)
def _():
    import marimo as mo

    return (mo,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ### Complutensian Bible: verb alignments
    """)
    return


@app.cell
def _():
    return


@app.cell
def _(df):
    df
    return


@app.cell(column=1)
def _():
    import polars as pl
    import unicodedata

    return pl, unicodedata


@app.cell
def _(mo):
    mo.md("""
    ## UI
    """)
    return


@app.cell
def _(mo, whatisit):
    mo.accordion(items={"About this notebook": whatisit})
    return


@app.cell
def _(mo):
    whatisit = mo.md("""This notebook just loads data into a polars dataframe and lets you query or explore the data. The data set consists of alignments of verb forms in the Torah across the Masoretic Hebrew text, the Greek Septuagint, the Latin Vulgate, and the Aramaic Targum Onkelos as extracted by Gemini 2.5 Pro. 

    > For a great introduction to exploring polars dataframes in marimo, see [this youtube video](  https://www.youtube.com/watch?v=OM7utZeQ1GY&t=723s) on marimo tips and tricks, with tips on using polars dataframs starting at 12:03.
    """)
    return (whatisit,)


@app.cell
def _(whatisit):
    whatisit
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## Load df
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
def _(pl, srcpath, strip_to_alphabetic):
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


if __name__ == "__main__":
    app.run()
