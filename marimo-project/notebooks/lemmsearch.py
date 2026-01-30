import marimo

__generated_with = "0.19.7"
app = marimo.App(width="medium")


@app.cell(hide_code=True)
def _(file_picker, mo):
    choosefile = mo.md(f"*Select a delimited-text file with verb alignment data*:{file_picker}")
    return (choosefile,)


@app.cell(hide_code=True)
def _(choosefile, mo, see_fname):
    mo.hstack([choosefile, see_fname])
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    # Lemmatized search
    """)
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    *Choose a text version and vocabulary item*
    """)
    return


@app.cell(hide_code=True)
def _(lemma, mo, refversion):
    mo.hstack([refversion, lemma], justify = "center")
    return


@app.cell
def _(psg_list):
    psg_list
    return


@app.cell
def _(df, lemma, lemmacol, pl):
    if df is not None and lemmacol:
        psg_list = df.filter(pl.col(lemmacol) ==lemma.value)["passage"].to_list()
    else:
        psg_list = []
    return (psg_list,)


@app.cell
def _(counts_df):
    counts_df
    return


@app.cell(hide_code=True)
def _(df):
    df
    return


@app.cell(hide_code=True)
def _(mo):
    mo.Html("<hr/><hr/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>")
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    # Under the hood
    """)
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    **Data source**:
    """)
    return


@app.cell
def _(mo):
    file_picker = mo.ui.file(label="Select delimited file",   filetypes=[".csv", ".cex"],)
    return (file_picker,)


@app.cell
def _(file_picker, mo):
    if file_picker.value:
        see_fname = mo.md(f"*Selected file*: `{file_picker.name()}`")
    else:
        see_fname  = mo.md("")
    return (see_fname,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    **Version of text**:
    """)
    return


@app.cell
def _():
    versions_menu = {"Greek Septuagint": "lxx", "Latin Vulgate": "vulgate", "Masoretic Hebrew": "masoretic",
                "Aramaic Targum Onkelos": "onkelos"}
    return (versions_menu,)


@app.function
def find_lemma_col(versionstring):
    """Get name of lemma column for selected version of the text."""
    if versionstring == "lxx":
        return "greek_lemma"
    elif versionstring == "vulgate":
        return "latin_lemma"
    elif versionstring == "masoretic":
        return "hebrew_lemma"
    elif versionstring == "onkelos":
        return "aramaic_lemma"
    else:
        return None


@app.cell
def _(mo, versions_menu):
    refversion = mo.ui.dropdown(
        options=versions_menu,
        label="Text version:",
    )
    return (refversion,)


@app.cell
def _(refversion):
    if refversion.value:
        lemmacol = find_lemma_col(refversion.value)
    else:
        lemmacol = None
    return (lemmacol,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    **Vocabulary choice**:
    """)
    return


@app.cell
def _(mo, vocab):
    lemma = mo.ui.dropdown(
        options=vocab,
        label="Lexeme:",
    )
    return (lemma,)


@app.cell
def _(counts_df, lemmacol):
    if counts_df is not None:
        vocab = counts_df[lemmacol].to_list()
    else:
        vocab = []
    return (vocab,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    **Data**:
    """)
    return


@app.cell
def _(file_picker, io, pl):
    if file_picker.value:
        df = pl.read_csv(io.BytesIO(file_picker.contents()), separator = "|",truncate_ragged_lines=True)
    else:
        df = None
    return (df,)


@app.cell
def _(df, lemmacol, pl):
    # 1. Calculate counts and unnest into a flat structure
    # 'sort=True' puts the most frequent values first
    if df is not None and lemmacol:
        counts_df = df.select(pl.col(lemmacol).value_counts(sort=True)).unnest(lemmacol)
    else:
        counts_df = None
    

    return (counts_df,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    **Imports**:
    """)
    return


@app.cell
def _():
    import polars as pl
    import marimo as mo
    import io
    return io, mo, pl


@app.cell
def _(df, lemmacol, pl):
    if df is not None and lemmacol:
        reftype = df.select(pl.col(lemmacol).value_counts(sort=True))
    else:
        reftype = None
    return


if __name__ == "__main__":
    app.run()
