import marimo

__generated_with = "0.19.7"
app = marimo.App(width="medium")


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    # A second marimo nb in the same directory
    """)
    return


@app.cell
def _(ok):
    ok
    return


@app.cell(hide_code=True)
def _(mo, ok):
    checking = mo.md("Not happy with this.")
    if ok.value is True:
        checking = mo.md("Yup, all OK.")
    checking    
    return


@app.cell(hide_code=True)
def _(mo):
    ok = mo.ui.checkbox(label="Think this is OK?")
    return (ok,)


@app.cell(hide_code=True)
def _():
    import marimo as mo
    return (mo,)


if __name__ == "__main__":
    app.run()
