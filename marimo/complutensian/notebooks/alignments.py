import marimo

__generated_with = "0.19.5"
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


@app.cell
def _(file_picker):
    file_picker.value
    return


@app.cell
def _(df):
    df
    return


@app.cell(hide_code=True)
def _(mo):
    mo.Html("<hr/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>")
    return


@app.cell
def _(mo):
    file_picker = mo.ui.file(label="Select delimited file",   filetypes=[".csv", ".cex"],)
    return (file_picker,)


@app.cell
def _(mo):
    file_picker_big = mo.ui.file_browser(
        initial_path=".",
        multiple=False,
        filetypes=[".txt", ".cex", ".xml"],
    )
    return


@app.cell
def _():
    import polars as pl
    import marimo as mo
    import io
    return io, mo, pl


@app.cell
def _(file_picker, io, pl):
    #df =  pl.read_csv(file_picker.value, separator="|", ) if file_picker.value else None
    csv_content = file_picker.contents()
    df = pl.read_csv(io.BytesIO(csv_content), separator = "|")
    return (df,)


@app.cell
def _(file_picker, mo):
    mo.md(f"""
    **Selected file:** {file_picker.value if file_picker.value else "None"}
    """)
    return


@app.cell
def _():
    return


@app.cell
def _():
    return


if __name__ == "__main__":
    app.run()
