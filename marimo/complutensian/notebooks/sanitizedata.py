import marimo

__generated_with = "0.19.6"
app = marimo.App(width="medium")


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    # Learn basic work with delimited files in python to clean up delimited file structure
    """)
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## Setup
    """)
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    > **NB**: Run this notebook from root of marimo/complutensian project.
    """)
    return


@app.cell(hide_code=True)
def _(f, lines, mo):
    mo.md(f"""
    Read **{len(lines)}** source lines from `{f}`
    """)
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## Find short lines
    """)
    return


@app.cell(hide_code=True)
def _(mo, resultscols, settingsui):
    mo.vstack([settingsui,
               resultscols]
             )
    return


@app.cell(hide_code=True)
def _(mo):
    mo.Html("<hr/><hr/><br/><br/><br/><br/><br/><br/><br/><br/><br/>")
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
    **Data**:
    """)
    return


@app.cell
def _(Path):
    f = Path.cwd() / 'public' / 'torah-verbs.cex'
    return (f,)


@app.cell
def _(f):
    type(f)
    return


@app.cell
def _():
    return


@app.cell
def _(f):
    with open(f, 'r') as file:
        lines = [line.strip() for line in file]
    return (lines,)


@app.cell
def _(lines):
    linelenn = [(i, len(line.split('|'))) for i, line in enumerate(lines)]
    return (linelenn,)


@app.cell
def _(linelenn):
    headercount = linelenn[0][1]
    return (headercount,)


@app.cell
def _(cutoff, linelenn):
    shorties = [tup for tup in linelenn if tup[1] < cutoff.value]
    return (shorties,)


@app.cell
def _(lines, shorties):
    short_lines = [lines[idx] for idx, size in shorties]
    return (short_lines,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    **UI**:
    """)
    return


@app.cell
def _(mo, short_lines, shorties):
    resultscols = mo.hstack([
        shorties,
        short_lines
    
        ])
    return (resultscols,)


@app.cell
def _(cutoff, mo):
    settingsui = mo.md(f"*Find lines with fewer than* `n` *columns* {cutoff}")
    return (settingsui,)


@app.cell
def _(headercount, mo):
    cutoff = mo.ui.slider(start=8, stop=headercount, step=1, value=10)
    return (cutoff,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    **Imports**:
    """)
    return


@app.cell
def _():
    import marimo as mo
    import io
    from collections import Counter
    from pathlib import Path
    return Path, mo


if __name__ == "__main__":
    app.run()
