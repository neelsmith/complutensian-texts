import marimo

__generated_with = "0.19.6"
app = marimo.App(width="medium")


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    /// admonition | 1. Load data

    Choose a delimited-text file to load.
    ///
    """)
    return


@app.cell(hide_code=True)
def _(file_picker):
    file_picker
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    # Find correlations
    """)
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    /// admonition | 2. Settings

    Choose a text version, a vocabulary item, and one or more texts to compare it to.
    ///
    """)
    return


@app.cell(hide_code=True)
def _(cf_select, lemma, mo, refversion):
    mo.hstack([refversion, lemma, cf_select], justify="center")
    return


@app.cell(hide_code=True)
def _(cf_select, lemma, lemmacol, mo, refversion):
    mo.md(f"""/// attention | Debugging
    Text **{refversion.value}** search column **{lemmacol}** for **{lemma.value}**, cf with **{cf_select.value}**
    ///
    """)
    return


@app.cell
def _(aligns, selected_columns):
    aligns.select(selected_columns)
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    /// attention | Debugging

    *Loaded dataset for reference while developing nb.*
    ///
    """)
    return


@app.cell
def _(df):
    df
    return


@app.cell(hide_code=True)
def _(mo):
    mo.Html("<hr/><hr/><br/><br/><br/><br/><br/><br/><br/><br/>")
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    # Under the hood
    """)
    return


@app.cell
def _(aligns, cf_columns):
    if aligns is not None:
        lemmacounts = (
            aligns.group_by(cf_columns)
            .len(name="count")
            .sort("count", descending=True)
        )
    else:
        lemmacounts = None
    return (lemmacounts,)


@app.cell
def _(cf_options):
    cf_columns = [find_lemma_col(item) for item in cf_options]
    return (cf_columns,)


@app.cell
def _(cf_select):
    selected_columns = [find_lemma_col(item) for item in cf_select.value]
    return (selected_columns,)


@app.cell
def _(selected_columns):
    selected_columns
    return


@app.cell
def _(cf_columns):
    cf_columns
    return


@app.cell
def _():
    return


@app.cell
def _(lemmacounts):
    lemmacounts
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    **Language choices**:
    """)
    return


@app.cell
def _():
    versions_menu = {"Greek Septuagint (lxx)": "lxx", "Latin Vulgate (vulgate)": "vulgate", "Masoretic Hebrew (masoretic)": "masoretic",
                "Aramaic Targum Onkelos (onkelos)": "onkelos"}
    return (versions_menu,)


@app.cell
def _(mo, versions_menu):
    refversion = mo.ui.dropdown(
        options=versions_menu,
        label="Reference version:",
    )
    return (refversion,)


@app.cell
def _(refversion, versions_menu):
    cf_options = [v for v in versions_menu.values() if v != refversion.value]
    return (cf_options,)


@app.cell
def _(cf_options, mo):
    cf_select = mo.ui.multiselect(
        options=cf_options, label="Compare with:"
    )
    return (cf_select,)


@app.cell
def _():
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    **Vocabulary choices**:
    """)
    return


@app.cell
def _(refversion):
    if refversion.value:
        lemmacol = find_lemma_col(refversion.value)
    else:
        lemmacol = ""
    return (lemmacol,)


@app.cell
def _(df, lemmacol, pl):
    # 1. Calculate counts and unnest into a flat structure
    # 'sort=True' puts the most frequent values first
    if df is not None and lemmacol:
        counts_df = df.select(pl.col(lemmacol).value_counts(sort=True)).unnest(lemmacol).drop_nulls()
        vocab = counts_df[lemmacol].to_list()
    else:
        counts_df = None
        vocab = []
    return counts_df, vocab


@app.cell
def _(mo, vocab):
    lemma = mo.ui.dropdown(
        options=vocab,
        label="Lexeme:",
    )
    return (lemma,)


@app.cell
def _(counts_df):
    counts_df
    return


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
def _(df, lemma, lemmacol, pl):
    if lemma.value:
        aligns = df.filter(pl.col(lemmacol) == lemma.value)
    else:
        aligns = None
    return (aligns,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    **Loading data**:
    """)
    return


@app.cell
def _(mo):
    file_picker = mo.ui.file(label="Select delimited file",   filetypes=[".csv", ".cex"],)
    return (file_picker,)


@app.cell
def _(file_picker):
    if file_picker.value:
        csv_content = file_picker.contents()
    else:
        csv_content = None
    return (csv_content,)


@app.cell
def _(csv_content, io, pl):
    if csv_content:
        df = pl.read_csv(io.BytesIO(csv_content), separator = "|",truncate_ragged_lines=True)
    else:
        df = None
    return (df,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    **Imports**:
    """)
    return


@app.cell
def _():
    import marimo as mo
    import polars as pl
    import io
    import complutensian as co
    return io, mo, pl


if __name__ == "__main__":
    app.run()
