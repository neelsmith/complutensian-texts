import marimo

__generated_with = "0.19.5"
app = marimo.App(width="medium")


@app.cell
def _(mo):
    mo.md("""
    # It's all about verb alignments
    """)
    return


@app.cell
def _(file_picker):
    file_picker
    return


@app.cell
def _(mo):
    file_picker = mo.ui.file_browser(
        initial_path=".",
        multiple=False,
        filetypes=[".txt", ".cex", ".xml"],
    )
    return (file_picker,)


@app.cell
def _():
    import polars as pl
    return (pl,)


@app.cell
def _(file_picker, pl):
    df =  pl.read_csv(file_picker.value, separator="|") if file_picker.value else None
    return


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
    import marimo as mo
    return (mo,)


if __name__ == "__main__":
    app.run()
