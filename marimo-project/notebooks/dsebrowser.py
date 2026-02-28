import marimo

__generated_with = "0.20.2"
app = marimo.App(width="medium")


@app.cell(hide_code=True)
def _():
    import marimo as mo

    return (mo,)


@app.cell
def _():
    #dse.df
    return


@app.cell(hide_code=True)
def _(mo):
    debug = mo.ui.checkbox()
    mo.md(f"*Show debugging info* {debug}")
    return (debug,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    # Browse the Complutensian polyglot Bible

    Latin glosses to the Septuagint and Targum Onkelos have been manually edited for *Genesis*. Browse in volume 1 to read these transcriptions alongside the source image.
    """)
    return


@app.cell(hide_code=True)
def _(manifest):
    manifest
    return


@app.cell(hide_code=True)
def _(
    clickedon,
    currentpsgreff,
    debug,
    imgstate,
    manifest,
    mo,
    x_state,
    y_state,
):
    showinfo = None
    if debug.value:
        showinfo = mo.vstack([
            mo.vstack([
                mo.md("*Manifest*:"),
                mo.md(f"{manifest.value}")]),
            mo.vstack([mo.md("*Current image*:"), mo.md(f"{imgstate}")]),
            mo.md(f"x,y =  `{x_state}, {y_state}`"),

            mo.vstack([mo.md("*Clicked on*"), clickedon]),
            mo.vstack([mo.md("*Text reff"), currentpsgreff])
        ])
    showinfo    
    return


@app.cell
def _(gallery):
    gallery
    return


@app.cell
def _(gallery, mo, viewer):
    mo.hstack([
        viewer,mo.md(""), gallery],
               widths=[75, 5, 20]
             )
    return


@app.cell(hide_code=True)
def _(mo):
    mo.Html("<hr/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>")
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    # Computation
    """)
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## Load text corpus
    """)
    return


@app.cell
def _():
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## Load DSE
    """)
    return


@app.cell
def _(DSE, alldse):
    dse = DSE(alldse)
    return (dse,)


@app.cell
def _(loadsource, lxxsrc, pl, targumsrc):
    lxxdf = loadsource(lxxsrc)
    targumdf = loadsource(targumsrc)
    alldse = pl.concat([lxxdf, targumdf]).unique()
    return (alldse,)


@app.cell
def _(mo):
    lxxsrc = str(mo.notebook_dir() / "public" / "septuagint_latin_genesis_dse.cex")
    targumsrc = str(mo.notebook_dir() / "public" / "targum_latin_genesis_dse.cex")
    return lxxsrc, targumsrc


@app.cell
def _(StringIO, lxxsrc, pl, urlopen):
    def loadsource(src):
        if src.startswith(("http://", "https://")):
            with urlopen(src) as response:
                csv_text = response.read().decode("utf-8")
                return pl.read_csv(StringIO(csv_text), separator="|", quote_char=None)
        else:
            return pl.read_csv(lxxsrc,separator="|",quote_char=None)

    return (loadsource,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## Wire coordinate tracking
    """)
    return


@app.cell
def _(mo):
    x_coord_state, set_x_coord_state = mo.state(0.0)
    y_coord_state, set_y_coord_state = mo.state(0.0)
    return set_x_coord_state, set_y_coord_state, x_coord_state, y_coord_state


@app.cell
def _(x_coord_state, y_coord_state):
    x_state = x_coord_state()
    y_state = y_coord_state()
    return x_state, y_state


@app.cell
def _(set_x_coord_state, set_y_coord_state, viewer):
    def push_coordinate_state(_change=None):
        "Update normalized x/y values from gallery object."
        next_x = getattr(viewer, "normalized_x", 0.0)
        next_y = getattr(viewer, "normalized_y", 0.0)
        if isinstance(_change, dict):
            changed_name = _change.get("name")
            if changed_name == "normalized_x":
                next_x = _change.get("new")
            elif changed_name == "normalized_y":
                next_y = _change.get("new")

        set_x_coord_state(next_x)
        set_y_coord_state(next_y)

    return (push_coordinate_state,)


@app.cell
def _(push_coordinate_state, viewer):
    if viewer is not None:
        previous_image_observer = getattr(viewer, "_marimo_coord_observer", None)
        if previous_image_observer:
            viewer.unobserve(previous_image_observer, names=["normalized_x", "normalized_y"])
        viewer.observe(push_coordinate_state, names=["normalized_x", "normalized_y"])
        viewer._marimo_coord_observer = push_coordinate_state
        push_coordinate_state()
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## Wire tracking image selection
    """)
    return


@app.cell
def _(image_state):
    imgstate = image_state()
    return (imgstate,)


@app.cell
def _(mo):
    image_state, set_image_state = mo.state("")
    return image_state, set_image_state


@app.cell
def _(gallery, set_image_state):
    def push_image_state(_change=None):
        "Update value of URL from viewer object."
        selected_info_url = ""
        if isinstance(_change, dict):
            selected_info_url = (_change.get("new") or "").strip()
        if not selected_info_url:
            selected_info_url = (gallery.selected_info_url or "").strip()
        set_image_state(selected_info_url)

    return (push_image_state,)


@app.cell
def _(gallery, push_image_state):
    if gallery is not None:
        previous_observer = getattr(gallery, "_marimo_observer", None)
        if previous_observer:
            gallery.unobserve(previous_observer, names=["selected_info_url"])
        gallery.observe(push_image_state, names=["selected_info_url"])
        gallery._marimo_observer = push_image_state
        push_image_state()
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## Image displays
    """)
    return


@app.cell
def _(IIIFThumbnailGallery, manifest):
    gallery = None
    if manifest.value:
        gallery = IIIFThumbnailGallery(manifest_url = manifest.value)
    return (gallery,)


@app.cell
def _(currentrects):
    currentrects
    return


@app.cell
def _(IIIFImageOverlayViewer, currentrects, imgstate):
    viewer = None
    if imgstate:
        viewer = IIIFImageOverlayViewer(
            url = imgstate,rectangles_csv=currentrects)
    return (viewer,)


@app.cell
def _(CitableIIIFService):
    service = CitableIIIFService(urlbase = "https://www.homermultitext.org/iipsrv?IIIF=/project/homer/pyramidal/deepzoom/", extension = "tif")
    return (service,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## Current DSE selections
    """)
    return


@app.cell
def _(imgstate, info_url2urn, service):
    currentimg = info_url2urn(imgstate,service)
    return (currentimg,)


@app.cell
def _(currentimg):
    currentimg
    return


@app.cell
def _(currentimg, dse):
    pgs = dse.surfacesforimage(currentimg)
    pgs
    return (pgs,)


@app.cell
def _(pgs):
    pgs.is_empty()
    return


@app.cell
def _(pgs):
    currentdsepage = pgs[0,0]
    return (currentdsepage,)


@app.cell
def _(currentdsepage):
    currentdsepage
    return


@app.cell
def _(currentdsepage, dse, pgs, pl):
    if pgs.is_empty():
        pagedf = pgs
    else:
        pagedf = dse.df.filter(pl.col("surface") == currentdsepage)
    return (pagedf,)


@app.cell
def _():
    #pagedf
    return


@app.cell
def _(pagedf, rois):
    if pagedf.is_empty():
        roilist = []
    else:
        roilist = rois(pagedf)
    return (roilist,)


@app.cell
def _(roilist):
    currentrects =  "\n".join(roilist)
    return (currentrects,)


@app.cell
def _(currentdsepage, mo):
    mo.md(f"Current page: `{currentdsepage}`")
    return


@app.cell
def _(currentrects, mo):
    mo.md(f"Current rects: {currentrects}")
    return


@app.cell
def _(pagedf, ptinrect, x_state, y_state):
    if pagedf.is_empty():
        clickedon = pagedf
    else:
        clickedon = pagedf.filter(ptinrect(x_state, y_state))
    
    return (clickedon,)


@app.cell
def _(clickedon):
    clickedon
    return


@app.cell
def _(clickedon, pl):
    currentpsgreff = clickedon.select("passage").filter(pl.col("passage").is_not_null()).to_series().to_list()
    return (currentpsgreff,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## User selections
    """)
    return


@app.cell
def _(manifests, mo):
    manifest = mo.ui.dropdown(manifests,label="*Choose a volume:*")
    return (manifest,)


@app.cell
def _():
    manifests = {"volume 1": "https://raw.githubusercontent.com/neelsmith/complutensian-texts/refs/heads/main/iiif/complutensian-bne-v1-manifest.json",
    "volume 2": "https://raw.githubusercontent.com/neelsmith/complutensian-texts/refs/heads/main/iiif/complutensian-bne-v2-manifest.json",
    "volume 3": "https://raw.githubusercontent.com/neelsmith/complutensian-texts/refs/heads/main/iiif/complutensian-bne-v3-manifest.json",
    "volume 4": "https://raw.githubusercontent.com/neelsmith/complutensian-texts/refs/heads/main/iiif/complutensian-bne-v4-manifest.json",
    "volume 5": "https://raw.githubusercontent.com/neelsmith/complutensian-texts/refs/heads/main/iiif/complutensian-bne-v5-manifest.json",
    "volume 6": "https://raw.githubusercontent.com/neelsmith/complutensian-texts/refs/heads/main/iiif/complutensian-bne-v6-manifest.json"
    }
    return (manifests,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## Imports
    """)
    return


@app.cell
def _():
    from iiif_anywidget import IIIFViewer, IIIFThumbnailGallery, IIIFImageOverlayViewer

    return IIIFImageOverlayViewer, IIIFThumbnailGallery


@app.cell
def _():
    import polars as pl

    return (pl,)


@app.cell
def _():
    from dse_polars import DSE, CitableIIIFService, info_url2urn, urn2image_url, rois, ptinrect
    from dse_polars.texts import textcontents

    return CitableIIIFService, DSE, info_url2urn, ptinrect, rois


@app.cell
def _():
    from dataclasses import dataclass

    return


@app.cell
def _():
    from io import StringIO
    from urllib.request import urlopen

    return StringIO, urlopen


if __name__ == "__main__":
    app.run()
