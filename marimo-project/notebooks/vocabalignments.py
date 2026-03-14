# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "marimo>=0.20.4",
#     "nump==5.5.5.5",
#     "numpy==2.4.3",
#     "plotly[express]==6.6.0",
#     "polars==1.39.0",
#     "requests==2.32.5",
# ]
# ///

import marimo

__generated_with = "0.20.4"
app = marimo.App(width="columns")


@app.cell(column=0, hide_code=True)
def _():
    import marimo as mo

    return (mo,)


@app.cell(hide_code=True)
def _(versioninfo):
    versioninfo
    return


@app.cell(hide_code=True)
def _(lastmod, mo, versioninfo):
    versiondisplay = None
    if versioninfo.value is True:
        versiondisplay = mo.md(f"""*Notebook version*: **0.1.0** (Feb. 3, 2026)

        *Data last updated*: {lastmod}
        """)
    versiondisplay    
    return


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
def _(stacked_by_column_plot):
    stacked_by_column_plot
    return


@app.cell(hide_code=True)
def _(barplot):
    barplot
    return


@app.cell(column=1, hide_code=True)
def _(mo):
    mo.md("""
    ## Debugging data values
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
def _(lemmasortbycount):
    lemmasortbycount
    return


@app.cell(hide_code=True)
def _(mo):
    debug = mo.ui.checkbox(label="Show dataframes")
    debug
    return (debug,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ### Vocab
    """)
    return


@app.cell
def _(debug, vocab):
    showvocab = None
    if debug.value:
        showvocab = vocab

    showvocab    
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ### Alignments
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
    ### Counts
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
    ### Full df
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
    ## UI and computation
    """)
    return


@app.cell
def _(mo):
    versioninfo = mo.ui.checkbox(label="*See version info*")
    return (versioninfo,)


@app.cell
def _(mo):
    lemmasortbycount = mo.ui.checkbox(label="*Sort vocabulary menu by count*",value=True)
    return (lemmasortbycount,)


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
def _(aligns, lemmasortbycount, selected_columns):
    if aligns is not None and selected_columns:
        lemmacounts = (
            aligns.group_by(selected_columns)
            .len(name="count")
            .sort("count", descending=lemmasortbycount.value)
        )
    else:
        lemmacounts = None
    return (lemmacounts,)


@app.cell
def _(cf_options):
    cf_columns = [find_lemma_col(item) for item in cf_options]
    return


@app.cell
def _(cf_select):
    selected_columns = [find_lemma_col(item) for item in cf_select.value]
    return (selected_columns,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ### Language choices
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
    ### Vocabulary choices
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
def _(df, lemmacol, lemmasortbycount, pl):
    # 1. Calculate counts and unnest into a flat structure
    # 'sort=True' puts the most frequent values first
    if df is not None and lemmacol:
        counts_df = df.select(pl.col(lemmacol).value_counts(sort=lemmasortbycount.value)).unnest(lemmacol).drop_nulls()
    
        if lemmasortbycount.value == True:
            vocab = counts_df[lemmacol].to_list()
        else:
            vocab = counts_df[lemmacol].to_list()#.sort()
    else:
        counts_df = None
        vocab = []
    return counts_df, vocab


@app.cell
def _(vocab):
    x = vocab.sort()
    return (x,)


@app.cell(hide_code=True)
def _(vocab):
    vocab
    return


@app.cell
def _(x):
    x
    return


@app.cell
def _(mo, vocab):
    lemma = mo.ui.dropdown(
        options=vocab,
        label="Lexeme:",
    )
    return (lemma,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## Data selection
    """)
    return


@app.function
def find_lemma_col(versionstring):
    """Get name of lemma column for selected version of the text."""
    if versionstring == "lxx":
        return "greek_lemma_stripped"
    elif versionstring == "vulgate":
        return "latin_lemma_stripped"
    elif versionstring == "masoretic":
        return "hebrew_lemma_stripped"
    elif versionstring == "onkelos":
        return "aramaic_lemma_stripped"
    else:
        return None


@app.cell
def _(df, lemma, lemmacol, pl):
    if lemma.value:
        aligns = df.filter(pl.col(lemmacol) == lemma.value)
    else:
        aligns = None
    return (aligns,)


@app.cell
def _(label_cols):
    label_cols
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## Plotting
    """)
    return


@app.cell
def _(mo):
    mo.md("""
    ### Grouped
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


        langlist = ", ".join([s.removesuffix("_lemma_stripped").title() for s in label_cols])
        # Create bar chart
        barplot = px.bar(
            data,
            x="label",
            y="count",
            labels={"label": "", "count": "Count"},
            title=f"Alignments of {langlist} with {lemma.value}"
        )

        # Rotate x-axis labels to 45 degrees
        barplot.update_layout(
            xaxis_tickangle=-45,
            height=500,
            showlegend=False
        )
    else:
        barplot = None
        label_cols = []
    return barplot, label_cols


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ### Stacked
    """)
    return


@app.cell
def _(aligns, go, label_cols, pl):
    if aligns is not None and label_cols:
        stacked_counts_parts = []
        for col in label_cols:
            if col in aligns.columns:
                counts = (
                    aligns.group_by(col)
                    .len(name="count")
                    .sort("count", descending=True)
                    .drop_nulls(col)
                    .rename({col: "value"})
                    .with_columns(pl.lit(col).alias("language"))
                )
                stacked_counts_parts.append(counts)

        if stacked_counts_parts:
            stacked_counts = pl.concat(stacked_counts_parts, how="vertical_relaxed")
            stacked_by_column_plot = go.Figure()
            seen_values = set()

            for col in label_cols:
                if col not in stacked_counts.get_column("language").unique().to_list():
                    continue

                col_rows = (
                    stacked_counts
                    .filter(pl.col("language") == col)
                    .sort("count", descending=True)
                )

                for row in col_rows.iter_rows(named=True):
                    value_label = str(row["value"])
                    stacked_by_column_plot.add_bar(
                        x=[col],
                        y=[row["count"]],
                        name=value_label,
                        legendgroup=value_label,
                        showlegend=value_label not in seen_values,
                        hovertemplate=(
                            f"Language: {col}<br>"
                            f"Value: {value_label}<br>"
                            "Count: %{y}<extra></extra>"
                        ),
                    )
                    seen_values.add(value_label)

            stacked_by_column_plot.update_layout(
                barmode="stack",
                xaxis_title="Language",
                yaxis_title="Count",
                title="Corresponding terms by language",
                height=550,
            )
        else:
            stacked_by_column_plot = None
    else:
        stacked_by_column_plot = None
    return (stacked_by_column_plot,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## Loading data
    """)
    return


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
def _(mo):
    srcpath= mo.notebook_location() / "public" / "genesis-verbs-numbered.cex"
    return (srcpath,)


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
    return df, lastmod


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## Imports
    """)
    return


@app.cell
def _():
    import polars as pl
    import io
    import os
    import complutensian as co
    #import pyarrow as pa
    import numpy
    import plotly.express as px
    import plotly.graph_objects as go
    import datetime

    import unicodedata

    return datetime, go, os, pl, px, unicodedata


@app.cell(column=2, hide_code=True)
def _(mo):
    mo.md("""
    ## Widebody view
    """)
    return


@app.cell
def _(df):
    df
    return


if __name__ == "__main__":
    app.run()
