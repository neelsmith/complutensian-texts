import marimo

__generated_with = "0.19.7"
app = marimo.App(width="medium")


@app.cell(hide_code=True)
def _():
    import marimo as mo
    return (mo,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    # *Genesis* in the Complutensian Bible: alignments of verbal forms
    """)
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    /// admonition | Using this notebook
    Choose a text version (reference version), a vocabulary item (lexeme), and then choose one or more texts to find alignments in.

    Optionally, limit the number of items to display in the barchart.
    ///
    """)
    return


@app.cell(hide_code=True)
def _(cf_select, lemma, mo, plotlimit, refversion):
    mo.vstack([mo.hstack([refversion, lemma, cf_select], justify="center"), plotlimit], justify="center")
    return


@app.cell(hide_code=True)
def _(barplot):
    barplot
    return


@app.cell(hide_code=True)
def _(mo):
    mo.Html("<hr/><hr/><br/><br/><br/><br/><br/><br/><br/><br/>")
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    # Debugging data values
    """)
    return


@app.cell(hide_code=True)
def _(cf_select, lemma, lemmacol, mo, refversion):
    mo.md(f"""
    /// attention | User-selected settings
    In text **{refversion.value}**, search column **{lemmacol}** for **{lemma.value}**, and compare with **{cf_select.value}**
    ///
    """)
    return


@app.cell(hide_code=True)
def _(mo):
    debug = mo.ui.checkbox(label="Show dataframes")
    debug
    return (debug,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    **Alignments**:
    """)
    return


@app.cell(hide_code=True)
def _(aligns, debug):
    showaligns = None
    if aligns is not None and debug.value:
        showaligns = aligns #aligns.select(selected_columns)
    showaligns   
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    **Counts**:
    """)
    return


@app.cell(hide_code=True)
def _(debug, lemmacounts):
    showcounts = None
    if debug.value:
        showcounts = lemmacounts
    showcounts    
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    **Full df**:
    """)
    return


@app.cell(hide_code=True)
def _(debug, df):
    showdf = None
    if debug.value:
        showdf = df
    showdf    
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    # UI and computation
    """)
    return


@app.cell
def _(counts_df, lemmacounts, mo):
    if counts_df is not None and lemmacounts is not None:
        plotlimit = mo.ui.slider(
            start=1,
            stop=len(lemmacounts),
            step=1,
            value=len(lemmacounts),
            label="Number of items to plot:",
        )
    else:
        plotlimit = None
    return (plotlimit,)


@app.cell
def _(aligns, selected_columns):
    if aligns is not None and selected_columns:

        lemmacounts = (
            aligns.group_by(selected_columns)
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
    **Plotting**
    """)
    return


@app.cell
def _(lemma, lemmacounts, pl, plotlimit, px):
    if lemmacounts is not None and plotlimit is not None:
        # Get all columns except 'count'
        label_cols = [col for col in lemmacounts.columns if col != "count"]

        # Create labels by concatenating columns with spaces
        data = lemmacounts.head(plotlimit.value).with_columns(
            label=pl.concat_str(label_cols, separator=" ")
        )

        # Create bar chart
        barplot = px.bar(
            data,
            x="label",
            y="count",
            labels={"label": "", "count": "Count"},
            title=f"Alignments with {lemma.value}"
        )

        # Rotate x-axis labels to 45 degrees
        barplot.update_layout(
            xaxis_tickangle=-45,
            height=500,
            showlegend=False
        )
    else:
        barplot = None
    return (barplot,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    **Loading data**:
    """)
    return


@app.cell
def _(mo):
    srcpath= mo.notebook_location() / "public" / "genesis-verbs-numbered.cex"
    return (srcpath,)


@app.cell
def _(datetime, os, srcpath):
    lastmodstamp = os.path.getmtime(srcpath)
    lastmod = datetime.datetime.fromtimestamp(lastmodstamp).strftime('%Y-%m-%d %H:%M:%S')
    return


@app.cell
def _(pl, srcpath):
    df = pl.read_csv(str(srcpath),  separator = "|", truncate_ragged_lines=True)
    return (df,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    **Imports**:
    """)
    return


@app.cell
def _():
    import polars as pl
    import io
    import os
    import complutensian as co
    #import pyarrow as pa
    import plotly.express as px
    import datetime
    return datetime, os, pl, px


if __name__ == "__main__":
    app.run()
