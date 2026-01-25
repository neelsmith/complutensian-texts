import marimo

__generated_with = "0.19.6"
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


@app.cell
def _(refversion):
    refversion
    return


@app.cell
def _(df, pl):
    type(df.select(pl.col("greek_lemma").value_counts(sort=True)))
    return


@app.cell
def _():
    import plotly.express as px
    return (px,)


@app.cell
def _(df, pl):
    # 1. Calculate counts and unnest into a flat structure
    # 'sort=True' puts the most frequent values first
    counts_df = df.select(pl.col("greek_lemma").value_counts(sort=True)).unnest("greek_lemma")

    return (counts_df,)


@app.cell
def _(counts_df):
    counts_df
    return


@app.cell
def _(counts_df, px):
    fig = px.bar(
        counts_df, 
        x="greek_lemma", 
        y="count", 
        title="Frequency of Greek Vocabulary",
        #color="greek", # Optional: adds distinct colors
        labels={"greek_lemma": "Lexeme", "count": "Occurrences"}
    )
    return (fig,)


@app.cell
def _():
    return


@app.cell
def _(fig):
    fig
    return


@app.cell(hide_code=True)
def _(df):
    df
    return


@app.cell
def _():
    return


@app.cell(hide_code=True)
def _(mo):
    mo.Html("<hr/><hr/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>")
    return


@app.cell
def _():
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
    **UI**:
    """)
    return


@app.cell
def _(mo):
    file_picker = mo.ui.file(label="Select delimited file",   filetypes=[".csv", ".cex"],)
    return (file_picker,)


@app.cell
def _(mo, versions_menu):
    refversion = mo.ui.dropdown(
        options=versions_menu,
        label="Select a version",
    )
    return (refversion,)


@app.cell
def _():
    versions_menu = {"Greek Septuagint": "lxx", "Latin Vulgate": "vulgate", "Masoretic Hebrew": "masoretic",
                "Aramaic Targum Onkelos": "onkelos"}
    return (versions_menu,)


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
    **Data**:
    """)
    return


@app.cell
def _():
    #if fil#e_picker.value:
    #    c#sv_content = file_picker.contents()
    #else#:
    #    #csv_content = None
    return


@app.cell
def _(file_picker, io, pl):
    if file_picker.value:
        df = pl.read_csv(io.BytesIO(file_picker.contents()), separator = "|",truncate_ragged_lines=True)
    else:
        df = None

    return (df,)


@app.cell
def _():
    import polars as pl
    import marimo as mo
    import io
    return io, mo, pl


if __name__ == "__main__":
    app.run()
