# /// script
# requires-python = ">=3.10"
# dependencies = [
#     "marimo>=0.19.11",
# ]
# ///
import marimo

__generated_with = "0.19.6"
app = marimo.App(width="medium")


@app.cell
def _():
    import marimo as mo
    return


@app.cell
def _():
    import complutensian as co
    from pathlib import Path
    return Path, co


@app.cell
def _(Path):
    txtspath = str(Path.cwd() / "public" / "compnov.cex")
    return (txtspath,)


@app.cell
def _(txtspath):
    txtspath
    return


@app.cell
def _(co, txtspath):
    corpdict = co.load_corpora(txtspath)
    return (corpdict,)


@app.cell
def _(corpdict):
    corpdict.keys()
    return


@app.cell
def _(corpdict):
    [len(corpdict[k]) for k in corpdict.keys()]
    return


@app.cell
def _(corpdict):
    corpdict['onkelos'].passages[0].urn.passage
    return


@app.cell
def _(corpdict):
    torahreff = [p.urn.work + ":" + p.urn.passage for p in corpdict['onkelos'].passages]
    return (torahreff,)


@app.cell
def _(torahreff):
    torahreff[len(torahreff)-10:]
    return


@app.cell
def _():
    return


if __name__ == "__main__":
    app.run()
