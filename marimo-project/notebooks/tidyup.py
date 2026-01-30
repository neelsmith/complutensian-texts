import marimo

__generated_with = "0.19.7"
app = marimo.App(width="medium")


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    # Find bad data
    """)
    return


@app.cell(hide_code=True)
def _(file_picker):
    file_picker
    return


@app.cell(hide_code=True)
def _(bad_greek, bad_hebrew, mo):
    if bad_greek is not None:
        display_total = mo.md(f"""/// admonition | Totals
    Found **{len(bad_greek)}** bad Greek values and **{len(bad_hebrew)}** bad Hebrew values.
    ///
    
            """)
    
    else:
        display_total = mo.md(f"*Please choose a file to load*.")
    display_total    
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## Bad Hebrew lemma
    """)
    return


@app.cell
def _(bad_hebrew):
    bad_hebrew
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## Bad Greek lemma
    """)
    return


@app.cell(hide_code=True)
def _(bad_greek):
    bad_greek
    return


@app.cell(hide_code=True)
def _(mo):
    mo.Html("<hr/></hr><br/><br/><br/><br/><br/><br/><br/>")
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## Back end computation
    """)
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    **Validation**
    """)
    return


@app.cell
def _():
    hebrew_regex = r"[^\u0590-\u05ff]"
    return (hebrew_regex,)


@app.cell
def _(df, hebrew_regex, pl):
    if df is not None:
        bad_hebrew = df.filter(pl.col("hebrew_lemma").str.contains(hebrew_regex))
    else:
        bad_hebrew = None
    return (bad_hebrew,)


@app.cell
def _():
    greek_regex = r"[^\u0370-\u03ff\u1f00-\u1fff\s.,;:·]"
    return (greek_regex,)


@app.cell
def _(df, greek_regex, pl):
    if df is not None:
        bad_greek = df.filter(pl.col("greek_lemma").str.contains(greek_regex))
    else:
        bad_greek = None
    return (bad_greek,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    **Data loading**
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


@app.cell
def _():
    import marimo as mo
    import polars as pl
    import io
    import complutensian as co
    return io, mo, pl


if __name__ == "__main__":
    app.run()
