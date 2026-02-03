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
    # Find correlations
    """)
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    /// admonition | Settings
    - Choose a delimited-text file to load.
    - Choose a text version, a vocabulary item, and one or more texts to compare it to.
    ///
    """)
    return


@app.cell(hide_code=True)
def _(cf_select, file_picker, lemma, mo, refversion):
    mo.vstack([file_picker, mo.hstack([refversion, lemma, cf_select], justify="center"), ], justify="center")
    return


@app.cell(hide_code=True)
def _(counts_df, mo):
    if counts_df is not None and len(counts_df) > 0:
        plotlimit = mo.ui.slider(
            start=1,
            stop=len(counts_df),
            step=1,
            value=min(20, len(counts_df)),
            label="Number of items to plot:",
        )
    else:
        plotlimit = None
    return (plotlimit,)


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
    # Debugging
    """)
    return


@app.cell(hide_code=True)
def _(cf_select, lemma, lemmacol, mo, refversion):
    mo.md(f"""
    /// attention | Debugging
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
    # Under the hood
    """)
    return


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
    import polars as pl
    import io
    import complutensian as co
    import pyarrow as pa
    import plotly.express as px
    return io, pl, px


if __name__ == "__main__":
    app.run()
