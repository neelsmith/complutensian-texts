# /// script
# dependencies = [
#     "dse-polars==0.3.3",
#     "marimo",
#     "polars==1.38.1",
# ]
# requires-python = ">=3.13"
# ///

import marimo

__generated_with = "0.20.2"
app = marimo.App(width="columns")


@app.cell(column=0)
def _(dse):
    dse.df
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## Imports
    """)
    return


@app.cell
def _():
    import marimo as mo

    return (mo,)


@app.cell
def _():
    import polars as pl

    return (pl,)


@app.cell
def _():
    from dse_polars import DSE

    return (DSE,)


@app.cell
def _():
    from io import StringIO

    return (StringIO,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## UI
    """)
    return


@app.cell
def _(mo):
    pagefrom = mo.ui.dropdown(
        {
            "List of page ids" : "page_id",
            "Thumbnail image gallery": "image_gallery",
            "Passage reference": "passage"
        },label=("*Select page from*:")

    )
    return (pagefrom,)


@app.cell
def _(mo):
    pagelist = mo.ui.dropdown(["Page id"])
    return (pagelist,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## Load DSE data
    """)
    return


@app.cell
def _(mo):
    nb_dir = mo.notebook_location()
    if isinstance(nb_dir, str):
        base_url = nb_dir.rstrip("/") + "/public"
        lxxsrc = f"{base_url}/septuagint_latin_genesis_dse.cex"
        targumsrc = f"{base_url}/targum_latin_genesis_dse.cex"
    else:
        from pathlib import Path

        local_public = Path(nb_dir) / "public"
        local_dse = Path(nb_dir).parents[1] / "dse"

        lxx_path = local_public / "septuagint_latin_genesis_dse.cex"
        if not lxx_path.exists():
            lxx_path = local_dse / "septuagint_latin_genesis_dse.cex"

        targum_path = local_public / "targum_latin_genesis_dse.cex"
        if not targum_path.exists():
            targum_path = local_dse / "targum_latin_genesis_dse.cex"

        lxxsrc = str(lxx_path)
        targumsrc = str(targum_path)
    return lxxsrc, targumsrc


@app.cell
def _(DSE, loaddf, lxxsrc, pl, targumsrc):
    lxxdf = loaddf(lxxsrc)
    targumdf = loaddf(targumsrc)
    dse = DSE(pl.concat([lxxdf, targumdf]).unique(maintain_order=True))
    return (dse,)


@app.cell
def _(StringIO, pl):
    def loaddf(src):
        "Read dataframe from source that could be either a local file or a URL"
        def extract_dse_table(raw_text: str) -> str:
            lines = raw_text.splitlines()
            header_idx = None
            for i, line in enumerate(lines):
                normalized = line.strip().lower()
                if normalized in {"passage|image|surface", "passage|imageroi|surface"}:
                    header_idx = i
                    break

            if header_idx is None:
                raise ValueError("Could not find DSE header row in source")

            return "\n".join(lines[header_idx:])

        if src.startswith(("http://", "https://")):
            import urllib.request
            with urllib.request.urlopen(src) as response:
                csv_text = response.read().decode("utf-8")
        else:
            with open(src, "r", encoding="utf-8") as f:
                csv_text = f.read()

        dse_table = extract_dse_table(csv_text)
        df = pl.read_csv(StringIO(dse_table), separator="|", quote_char=None)
        if "imageroi" in df.columns:
            df = df.rename({"imageroi": "image"})
        return df.drop_nulls()

    return (loaddf,)


@app.cell(column=1, hide_code=True)
def _(mo):
    mo.md("""
    # Read pages of the Complutensian polyglot Bible
    """)
    return


@app.cell(hide_code=True)
def _(pagefrom):
    pagefrom
    return


@app.cell
def _(pagefrom, pagelist):
    currentpage = None
    if pagefrom.value == "page_id":
        currentpage = pagelist.value
    #elif pagefrom.value == "image_gallery":

    currentpage
    return


if __name__ == "__main__":
    app.run()
