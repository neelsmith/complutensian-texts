import marimo

__generated_with = "0.19.6"
app = marimo.App(width="medium")


@app.cell
def _(file_picker):
    file_picker
    return


@app.cell(hide_code=True)
def _(corp, mo):
    mo.md(f"Corpus with {len(corp)} citable passages.")
    return


@app.cell
def _():
    import marimo as mo
    return (mo,)


@app.cell
def _():
    import src.textloading as textloading
    return (textloading,)


@app.cell
def _(mo):
    file_picker = mo.ui.file_browser(label="Select delimited file",   filetypes=[".csv", ".cex"],)
    return (file_picker,)


@app.cell
def _(file_picker, textloading):
    if file_picker.value:
        fullpath = str(file_picker.value[0].path)
        corp = textloading.load_corpus(fullpath)
    else:
        corp = None
    

    return (corp,)


if __name__ == "__main__":
    app.run()
