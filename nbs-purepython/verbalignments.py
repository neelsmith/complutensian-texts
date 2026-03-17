# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "marimo>=0.20.4",
#     "networkx==3.6.1",
#     "nump==5.5.5.5",
#     "numpy==2.4.3",
#     "plotly[express]==6.6.0",
#     "polars==1.39.0",
#     "requests==2.32.5",
#     "scipy==1.17.1",
# ]
# ///

import marimo

__generated_with = "0.21.0"
app = marimo.App(
    width="columns",
    layout_file="layouts/verbalignments.grid.json",
)


@app.cell(column=0, hide_code=True)
def _(versioninfo):
    versioninfo
    return


@app.cell(hide_code=True)
def _(mo, versioninfo):
    versiondisplay = None
    if versioninfo.value is True:
        versiondisplay = mo.md(f"""*Notebook version*: **0.2.0** (Mar. 14, 2026)

        """)
    versiondisplay    
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    # Complutensian Bible, *Genesis*: alignments of verbal forms
    """)
    return


@app.cell(hide_code=True)
def _(complutensian_alignment_app):
    complutensian_alignment_app
    return


@app.cell(hide_code=True)
def _():
    # spacer
    return


@app.cell(column=1, hide_code=True)
def _(mo):
    mo.md("""
    # App assembly
    """)
    return


@app.cell
def _():
    import marimo as mo

    return (mo,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## App UI
    """)
    return


@app.cell
def _(mo):
    versioninfo = mo.ui.checkbox(label="*See version info*")
    return (versioninfo,)


@app.cell
def _(graphtab, hotspottab, mo, wordquerytab):
    complutensian_alignment_app = mo.ui.tabs({ "Overview": hotspottab, "Individual terms": wordquerytab, "Network visualization": graphtab})
    return (complutensian_alignment_app,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## Loading data
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
    #lastmodstamp = os.path.getmtime(srcpath)
    #lastmod = datetime.datetime.fromtimestamp(lastmodstamp).strftime('%Y-%m-%d %H:%M:%S')
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

    import plotly.express as px
    import plotly.graph_objects as go
    import datetime

    import unicodedata

    return go, pl, px, unicodedata


@app.cell
def _():
    import networkx as nx
    import numpy as np
    import scipy as sp


    return np, nx


@app.cell(column=2, hide_code=True)
def _(mo):
    mo.md("""
    # Individual lexemes tab
    """)
    return


@app.cell
def _():
    #wordquerytab
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## Tab assembly
    """)
    return


@app.cell
def _(mo, workquerytabstack):
    wordquerytab = mo.vstack(workquerytabstack)
    return (wordquerytab,)


@app.cell
def _(cluster_plot, mo, querystack, searchguide, stacked_by_column_plot):
    workquerytabstack = [
        mo.md("## Explore individual word alignments"),
        searchguide,
        querystack
    ]
    if stacked_by_column_plot:
        workquerytabstack.append(stacked_by_column_plot)

    if cluster_plot:
        workquerytabstack.append(cluster_plot)
    return (workquerytabstack,)


@app.cell
def _(mo):
    searchguide=mo.md("""
    /// admonition | How to find alignments
    Choose a text version (reference version), a vocabulary item (lexeme), and then choose one or more texts to find alignments in.

    Optionally, limit the number of items to display in the barchart.
    ///
    """)
    return (searchguide,)


@app.cell
def _(cf_select, lemma, mo, plotlimit, refversion):
    queryvstack = [mo.hstack([refversion, lemma, cf_select], justify="center")]
    if plotlimit:
        queryvstack.append(plotlimit)
    return (queryvstack,)


@app.cell
def _(mo, queryvstack):
    querystack = mo.vstack(queryvstack, justify="center")
    return (querystack,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## UI and computation
    """)
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ### Language choices
    """)
    return


@app.cell
def _(mo, versions_menu):
    refversion = mo.ui.dropdown(
        options=versions_menu,
        label="*Reference version*:",
    )
    return (refversion,)


@app.cell
def _():
    versions_menu = {"Greek Septuagint (lxx)": "lxx", "Latin Vulgate (vulgate)": "vulgate", "Masoretic Hebrew (masoretic)": "masoretic",
                "Aramaic Targum Onkelos (onkelos)": "onkelos"}
    return (versions_menu,)


@app.cell
def _(refversion, versions_menu):
    cf_options = [v for v in versions_menu.values() if v != refversion.value]
    return (cf_options,)


@app.cell
def _(cf_options, mo):
    cf_select = mo.ui.multiselect(
        options=cf_options, label="*Compare with*:"
    )
    return (cf_select,)


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
            label="*Number of items to plot*:",
        )
    else:
        plotlimit = None
    return (plotlimit,)


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
def _(mo, vocab):
    lemma = mo.ui.dropdown(
        options=vocab,
        label="*Lexeme*:",
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
def _(df, pl):
    base = df.filter(pl.col("hebrew_lemma_stripped").is_not_null())

    alignment_counts = base.group_by("hebrew_lemma_stripped").agg(
        pl.len().alias("hebrew_count"),
        pl.col("greek_lemma_stripped").drop_nulls().n_unique().alias("greek_forms"),
        pl.col("latin_lemma_stripped").drop_nulls().n_unique().alias("latin_forms"),
        pl.col("aramaic_lemma_stripped").drop_nulls().n_unique().alias("aramaic_forms"),
    )

    for lang in ["greek", "latin", "aramaic"]:
        lemma_col = f"{lang}_lemma_stripped"
        top_counts = (
            base
            .filter(pl.col(lemma_col).is_not_null())
            .group_by(["hebrew_lemma_stripped", lemma_col])
            .len(name="_n")
            .group_by("hebrew_lemma_stripped")
            .agg(pl.max("_n").alias(f"{lang}_top"))
        )
        alignment_counts = alignment_counts.join(top_counts, on="hebrew_lemma_stripped", how="left")

    alignment_counts = alignment_counts.with_columns(
        pl.col("hebrew_count").cast(pl.Int64),
        pl.col("greek_forms").cast(pl.Int64),
        pl.col("latin_forms").cast(pl.Int64),
        pl.col("aramaic_forms").cast(pl.Int64),
        pl.col("greek_top").fill_null(0).cast(pl.Int64),
        pl.col("latin_top").fill_null(0).cast(pl.Int64),
        pl.col("aramaic_top").fill_null(0).cast(pl.Int64),
    )
    return (alignment_counts,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## Plotting
    """)
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ### Plot groupings of aligned terms: creates `cluster_plot`
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
        cluster_plot = px.bar(
            data,
            x="label",
            y="count",
            labels={"label": "", "count": "Count"},
            title=f"Alignments of {langlist} with {lemma.value}"
        )

        # Rotate x-axis labels to 45 degrees
        cluster_plot.update_layout(
            xaxis_tickangle=-45,
            height=500,
            showlegend=False
        )
    else:
        cluster_plot = None
        label_cols = []
    return cluster_plot, label_cols


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ### Stacked: generates `stacked_by_column_plot`
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


@app.cell
def _():
    return


@app.cell(column=3, hide_code=True)
def _(mo):
    mo.md("""
    # Overview tab
    """)
    return


@app.cell
def _():
    #hotspottab
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## Tab assembly
    """)
    return


@app.cell
def _(hotspotvstack, mo):
    hotspottab = mo.vstack(hotspotvstack)
    return (hotspottab,)


@app.cell
def _(avg_barplot, mo, numtodisplay, ovtabdict, summary_select, summarysort):
    hotspotvstack = [
        mo.md('## Overview of alignments: translation "hot spots"'),
          mo.md(f"""
    {summary_select} {summarysort} {numtodisplay}
    """)
    ]
    if avg_barplot:
        hotspotvstack.append(mo.ui.tabs(ovtabdict))
    return (hotspotvstack,)


@app.cell
def _(avg_barplot, top_barplot):
    ovtabdict = {}
    if avg_barplot:
        #hotspotvstack.append(avg_barplot)
        ovtabdict["Average alignments by language"] = avg_barplot
    if top_barplot:    
         ovtabdict["Top alignment by language"] = top_barplot
    return (ovtabdict,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## Compute pairings
    """)
    return


@app.cell
def _(pl):

    def score_pair_directed(df, col1, col2) -> pl.DataFrame:
        """Score alignments between two columns in the DataFrame.

        # Arguments:
            df: Polars DataFrame containing the data.
            col1: Name of the first column to compare.
            col2: Name of the second column to compare.

        # Returns:
            A Polars DataFrame with the normalized scores of non-null alignments between the two columns .
        """
        #xtab = (
         #   df.filter(pl.col(col1).is_not_null() & pl.col(col2).is_not_null())
        xtab = (
            df.filter(pl.col(col1).is_not_null())
            .group_by([col1, col2])
            .len()
            .sort([col1, "len"], descending=[False, True])
        )
        #print("Xtab computed:")

        scoresdf = xtab.with_columns(
            (pl.col("len") / pl.col("len").sum().over(col1)).alias("scores")
        )
        return scoresdf



    def score_pair_two_way(scores, col1, col2) -> pl.DataFrame:
        scores1 = score_pair_directed(scores, col1, col2)
        scores2 = score_pair_directed(scores, col2, col1)
        two_way = scores1.join(
            scores2,
            on=[col1, col2],
            how = "outer",
            suffix="_rev"
        ).fill_null(0).with_columns(
            ((pl.col("scores") + pl.col("scores_rev")) / 2).alias("average_score")
        )
        return two_way


    return (score_pair_two_way,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## UI
    """)
    return


@app.cell
def _(mo, summary_options):
    summary_select = mo.ui.multiselect(
        options=summary_options, label="*Compare with*:"
    )
    return (summary_select,)


@app.cell
def _():
    summary_options = {"lxx": 'greek', "vulgate": 'latin', "onkelos": 'aramaic'} # [v for v in versions_menu.values() if v != refversion.value]
    return (summary_options,)


@app.cell
def _(alignment_counts, mo):
    numtodisplay = mo.ui.slider(start=5,step=1,stop=len(alignment_counts),label="*Terms to display*",debounce=True,show_value=True,value=20)
    return (numtodisplay,)


@app.cell
def _(mo):
    summarysort = mo.ui.dropdown({"Number of aligned terms" : "total_avg", "Coverage of top aligned term": "top_term", "Frequency of Hebrew lemma": "hebrew_count"},value="Frequency of Hebrew lemma",label="*Sort by*")
    return (summarysort,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## Plotting
    """)
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ### Total series
    """)
    return


@app.cell
def _(alignment_counts, numtodisplay, pl, summary_select, summarysort):
    if not summary_select.value:
        summary_plot_df = None
        summary_x_vals = []
        summary_langs = []
    else:
        summary_langs = summary_select.value
        n_langs = len(summary_langs)

        _df = alignment_counts.with_columns(
            *[
                (pl.col(f"{lang}_forms") / pl.col("hebrew_count")).alias(f"{lang}_avg_alignment")
                for lang in summary_langs
            ],
            *[
                (pl.col(f"{lang}_top") / pl.col("hebrew_count")).alias(f"{lang}_top_alignment")
                for lang in summary_langs
            ],
            (
                sum(pl.col(f"{lang}_forms") for lang in summary_langs)
                / (pl.col("hebrew_count") * n_langs)
            ).alias("total_avg"),
            (
                sum(pl.col(f"{lang}_top") for lang in summary_langs)
                / (pl.col("hebrew_count") * n_langs)
            ).alias("total_top"),
        )

        if summarysort.value and summarysort.value in _df.columns:
            _df = _df.sort(summarysort.value, descending=True)

        summary_plot_df = _df.head(numtodisplay.value)
        summary_x_vals = summary_plot_df["hebrew_lemma_stripped"].to_list()
    return summary_langs, summary_plot_df, summary_x_vals


@app.cell
def _(go, summary_langs, summary_plot_df, summary_x_vals):
    if summary_plot_df is None:
        avg_barplot = None
    else:
        avg_cols = [f"{lang}_avg_alignment" for lang in summary_langs] + ["total_avg"]
        avg_barplot = go.Figure()
        for _col in avg_cols:
            avg_barplot.add_bar(
                x=summary_x_vals,
                y=summary_plot_df[_col].to_list(),
                name=_col,
            )
        avg_barplot.update_layout(
            barmode="group",
            xaxis_title="Hebrew lemma",
            yaxis_title="Normalized alignment",
            title="Average alignment by language",
            height=500,
        )
    return (avg_barplot,)


@app.cell
def _(go, summary_langs, summary_plot_df, summary_x_vals):
    if summary_plot_df is None:
        top_barplot = None
    else:
        top_cols = [f"{lang}_top_alignment" for lang in summary_langs] + ["total_top"]
        top_barplot = go.Figure()
        for _col in top_cols:
            top_barplot.add_bar(
                x=summary_x_vals,
                y=summary_plot_df[_col].to_list(),
                name=_col,
            )
        top_barplot.update_layout(
            barmode="group",
            xaxis_title="Hebrew lemma",
            yaxis_title="Normalized alignment",
            title="Top-term alignment by language",
            height=500,
        )
    return (top_barplot,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## Imports
    """)
    return


@app.cell(column=4, hide_code=True)
def _(mo):
    mo.md("""
    # Network viz tab
    """)
    return


@app.cell
def _():
    #graphtab
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## Tab assembly
    """)
    return


@app.cell
def _(fig, graphguide, graphstack, mo):
    graphtab = mo.vstack([
        graphguide,
        graphstack,
        fig
    ])
    return (graphtab,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## UI
    """)
    return


@app.cell
def _(mo):
    threshold_slider = mo.ui.slider(start=0, stop=100, step=5, value=75, label="*Cut-off percentage*")
    return (threshold_slider,)


@app.cell
def _(mo, subgr_gk_lat, threshold_slider):
    graphstack = mo.hstack([ threshold_slider, mo.md(f"**Selected nodes**: {subgr_gk_lat.number_of_nodes()}, **Selected edges**: {subgr_gk_lat.number_of_edges()}")], justify="center")
    return (graphstack,)


@app.cell
def _(mo):
    graphguide=mo.md(f"""
    **Choose a value for cut-off percentage**. The graph display will show relations of all nodes with connections stronger than your cut-off point.


    /// attention | Note

    *You will need to set the cut-off percentage at least once for the graph to display*.

    ///
    """)
    return (graphguide,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## Graph building
    """)
    return


@app.cell
def _(gk_lat):
    gk_lat
    return


@app.cell
def _(df, score_pair_two_way):
    if df is not None:
        gk_lat_clean = df.drop_nulls(subset=["greek_lemma_stripped", "latin_lemma_stripped"])
        gk_lat = score_pair_two_way(gk_lat_clean, "greek_lemma_stripped", "latin_lemma_stripped")
    else:
        gk_lat = None
    return (gk_lat,)


@app.cell
def _(nx):
    gk_lat_gr = nx.Graph()  # Undirected
    return (gk_lat_gr,)


@app.cell
def _(gk_lat, gk_lat_gr):
    if gk_lat is not None:
        gk_lat_gr.add_weighted_edges_from(gk_lat.select(["greek_lemma_stripped", "latin_lemma_stripped", "average_score"]).iter_rows())
    return


@app.cell
def _(get_significant_subgraph, gk_lat_gr, threshold_slider):
    if gk_lat_gr is not None:
        subgr_gk_lat = get_significant_subgraph(gk_lat_gr, threshold_slider.value)
    else:
        subgr_gk_lat = None
    return (subgr_gk_lat,)


@app.cell
def _(subgr_gk_lat):
    subgr_gk_lat.number_of_nodes()
    return


@app.cell
def _(np, nx):
    def get_significant_subgraph(G, weight_percentile):
        # Calculate weight threshold
        weights = [d['weight'] for u, v, d in G.edges(data=True)]
        #weights are 0.0:1.0

        # Handle empty graph or no edges
        if len(weights) == 0:
            return nx.Graph()

        q = np.percentile(weights, weight_percentile)


        # Filter edges and the resulting induced nodes
        strong_edges = [(u, v, d) for u, v, d in G.edges(data=True) if d['weight'] >= q]

        H = nx.Graph()
        H.add_edges_from(strong_edges)
        #print(f"H has {H.number_of_edges()}")
        # Optionally: Keep only the largest connected component to remove isolates
        if len(H) > 0:
            main_comp = max(nx.connected_components(H), key=len)
            H = H.subgraph(main_comp).copy()
        #print(f"adjusted H has {H.number_of_edges()} edges for {H.number_of_nodes()} nodes")
        return H

    return (get_significant_subgraph,)


@app.cell
def _(gk_lat_gr, mo, threshold_slider):
    mo.md(f"""
    /// admonition | *Debugging*
    In Greek-Latin graph: **total nodes**: {gk_lat_gr.number_of_nodes()}, **total edges**: {gk_lat_gr.number_of_edges()}

    Percentage **cut off**: {threshold_slider.value}

    ///
    """)
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## Graph plotting
    """)
    return


@app.cell
def _(nx, subgr_gk_lat):
    gk_lat_pos = nx.spring_layout(subgr_gk_lat)
    return (gk_lat_pos,)


@app.cell
def _(df, gk_lat_pos, go, subgr_gk_lat):
    gl_edge_x, gl_edge_y = [], []
    for u, v in subgr_gk_lat.edges():
        x0, y0 = gk_lat_pos[u]
        x1, y1 = gk_lat_pos[v]
        gl_edge_x.extend([x0, x1, None])
        gl_edge_y.extend([y0, y1, None])
    gl_edge_trace = go.Scatter(x=gl_edge_x, y=gl_edge_y, line=dict(width=0.5, color='#888'), mode='lines', showlegend=False)
    gl_node_x = [gk_lat_pos[node][0] for node in subgr_gk_lat.nodes()]
    gl_node_y = [gk_lat_pos[node][1] for node in subgr_gk_lat.nodes()]
    gl_node_labels = list(subgr_gk_lat.nodes())

    greek_nodes = set()
    latin_nodes = set()
    if df is not None:
        if "greek_lemma" in df.columns:
            greek_nodes = set(df["greek_lemma"].drop_nulls().to_list())
        if "latin_lemma" in df.columns:
            latin_nodes = set(df["latin_lemma"].drop_nulls().to_list())

    gl_node_colors = []
    for node in gl_node_labels:
        in_greek = node in greek_nodes
        in_latin = node in latin_nodes
        if in_greek and in_latin:
            gl_node_colors.append("#9467bd")  # both
        elif in_greek:
            gl_node_colors.append("#1f77b4")  # greek
        elif in_latin:
            gl_node_colors.append("#d62728")  # latin
        else:
            gl_node_colors.append("#7f7f7f")  # unknown

    gl_node_trace = go.Scatter(
        x=gl_node_x,
        y=gl_node_y,
        mode='markers',
        text=gl_node_labels,
        hovertemplate='<b>%{text}</b><extra></extra>',
        marker=dict(size=10, color=gl_node_colors),
        showlegend=False,
    )
    return gl_edge_trace, gl_node_trace


@app.cell
def _(gl_edge_trace, gl_node_trace, go):
    fig = go.Figure(data=[gl_edge_trace, gl_node_trace])
    return (fig,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## Imports
    """)
    return


@app.cell(column=5, hide_code=True)
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


@app.cell(hide_code=True)
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


@app.cell
def _():
    return


if __name__ == "__main__":
    app.run()
