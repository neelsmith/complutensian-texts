# /// script
# dependencies = [
#     "cite_exchange>=0.3.0",
#     "dse-polars==0.6.1",
#     "iiif-anywidget==0.7.0",
#     "marimo",
#     "polars==1.38.1",
# ]
# requires-python = ">=3.13"
# ///

import marimo

__generated_with = "0.20.4"
app = marimo.App(width="columns")


@app.cell(column=0, hide_code=True)
def _(mo):
    mo.md("""
    # Read pages of the Complutensian polyglot Bible
    """)
    return


@app.cell(hide_code=True)
def _(pagefrom):
    pagefrom
    return


@app.cell(hide_code=True)
def _(dse, iiif, mo, pagefrom, passagemenu, service):
    choiceblock = None
    pagelist = None
    gallery = None

    if pagefrom.value == "page_id":
        pagemenu = dse.df["surface"].drop_nulls().unique(maintain_order=True).str.split(":").list.last().to_list()

        pagelist = mo.ui.dropdown(pagemenu, label="*Select page id*:")
        choiceblock = pagelist


    elif pagefrom.value == "passage":
        choiceblock = passagemenu

    elif pagefrom.value == "image_gallery":
        imgs = dse.images().to_series().to_list()
        infourls = [service.urn2info_url(img) for img in imgs]
        gallery = iiif.IIIFThumbnailGallery(info_urls=infourls)
        choiceblock = gallery  # mo.md(f"COming for {pagefrom.value}...here's one {imgs[0]}")

    choiceblock
    return gallery, pagelist


@app.cell(hide_code=True)
def _(dse, gallery, mo, pagefrom, pagelist, passagemenu, service):
    currentpage = None
    if pagefrom.value == "page_id":
        currentpage = pagelist.value

    elif pagefrom.value == "passage":
        if passagemenu.value:
            psgurn = "urn:cts:compnov:bible.genesis.sept_latin:" + passagemenu.value
            psgmatches = dse.surfacesforpassage(psgurn).to_series().to_list()
            if len(psgmatches) == 1:
                currentpage = psgmatches[0]

    elif pagefrom.value == "image_gallery":
        clickie = service.info_url2urn(gallery.selected_info_url)
        pagematches  = dse.surfacesforimage(clickie)
        if len(pagematches) == 1:
            currentpage = pagematches.to_series().to_list()[0]


    hdr = None
    if currentpage:
        hdr = mo.md(f"## Page `{currentpage}`")


    hdr
    return


@app.cell(column=1)
def _():
    #dse.images().to_series().to_list()
    return


@app.cell
def _():


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
    import iiif_anywidget as iiif
    import cite_exchange as cex
    import dse_polars

    return dse_polars, iiif


@app.cell
def _(dse_polars):
    dse_polars.CitableIIIFService
    return


@app.cell
def _():
    import polars as pl
    from io import StringIO

    return StringIO, pl


@app.cell
def _():
    return


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
def _(dse, mo, pl):
    passagemenudf = (
            dse.df
            .select(["work", "passageref"])
            .drop_nulls()
            .unique(subset=["passageref"], keep="first", maintain_order=True)
            .with_columns(
                (
                    pl.col("work").str.replace_all("_", " ").str.to_titlecase()
                    + pl.lit(" ")
                    + pl.col("passageref")
                ).alias("label")
            )
        )

    passageoptions = dict(zip(passagemenudf["label"].to_list(), passagemenudf["passageref"].to_list()))
    passagemenu = mo.ui.dropdown(passageoptions, label="*Select a passage*")
    return (passagemenu,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## Image data
    """)
    return


@app.cell
def _(dse_polars):
    service = dse_polars.CitableIIIFService(urlbase = "https://www.homermultitext.org/iipsrv?IIIF=/project/homer/pyramidal/deepzoom/", extension = "tif")
    return (service,)


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
def _(dse_polars, loaddf, lxxsrc, pl, targumsrc):
    lxxdf = loaddf(lxxsrc)
    targumdf = loaddf(targumsrc)
    dse = dse_polars.DSE(pl.concat([lxxdf, targumdf]).unique(maintain_order=True))
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


if __name__ == "__main__":
    app.run()
