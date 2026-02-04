import marimo

__generated_with = "0.19.7"
app = marimo.App(width="medium")


@app.cell
def _():
    import marimo as mo
    return (mo,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    # Test WASM publication
    """)
    return


@app.cell(hide_code=True)
def _(langdropdown):
    langdropdown
    return


@app.cell(hide_code=True)
def _(langdropdown, mo):
    result = None
    if langdropdown.value is not None:
        result = mo.md(f"You chose **{langdropdown.value}**")
    result    
    
    return


@app.cell(hide_code=True)
def _(languages, mo):
    langdropdown = mo.ui.dropdown(
        options=languages, label="Choose a language"
    )

    return (langdropdown,)


@app.cell(hide_code=True)
def _():
    languages = ["Hebrew", "Greek", "Latin", "Aramaic"]
    return (languages,)


@app.cell
def _():
    return


if __name__ == "__main__":
    app.run()
