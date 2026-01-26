import marimo

__generated_with = "0.19.6"
app = marimo.App(width="medium")


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    # It's all about verb alignments
    """)
    return


@app.cell(hide_code=True)
def _(file_picker):
    file_picker
    return


@app.cell(hide_code=True)
def _(see_fname):
    see_fname
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


@app.cell
def _(mo):
    file_picker = mo.ui.file(label="Select delimited file",   filetypes=[".csv", ".cex"],)
    return (file_picker,)


@app.cell
def _():
    import polars as pl
    import marimo as mo
    import io
    return io, mo, pl


@app.cell
def _(csv_content, file_picker, io, pl):
    #df =  pl.read_csv(file_picker.value, separator="|", ) if file_picker.value else None
    #csv_content = file_picker.contents()
    if file_picker.value:
        df = pl.read_csv(io.BytesIO(csv_content), separator = "|",truncate_ragged_lines=True)
    else:
        df = None
    
    return (df,)


@app.cell
def _(file_picker, mo):
    if file_picker.value:
        see_fname = mo.md(f"Selected file `{file_picker.name()}`")
    else:
        see_fname  = mo.md("")
    return (see_fname,)


@app.cell
def _(file_picker):
    if file_picker.value:
        csv_content = file_picker.contents()
    else:
        csv_content = None
    return (csv_content,)


if __name__ == "__main__":
    app.run()
