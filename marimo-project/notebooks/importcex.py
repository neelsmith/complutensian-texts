# /// script
# dependencies = [
#     "cite-exchange==0.3.0",
#     "marimo",
# ]
# requires-python = ">=3.13"
# ///

import marimo

__generated_with = "0.20.4"
app = marimo.App(width="medium")


@app.cell
def _():
    import marimo as mo

    return


@app.cell
def _():
    import cite_exchange as cex

    return


if __name__ == "__main__":
    app.run()
