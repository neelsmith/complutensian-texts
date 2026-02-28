import marimo

__generated_with = "0.20.2"
app = marimo.App(width="medium")


@app.cell
def _():
    import marimo as mo

    return (mo,)


@app.cell
def _(manifest):
    manifest
    return


@app.cell(hide_code=True)
def _(mo):
    debug = mo.ui.checkbox()
    mo.md(f"*Show debugging info* {debug}")
    return (debug,)


@app.cell(hide_code=True)
def _(debug, imgstate, manifest, mo):
    showinfo = None
    if debug.value:
        showinfo = mo.vstack([
            mo.vstack([
                mo.md("*Manifest*:"),
                mo.md(f"{manifest.value}")]),
            mo.vstack([mo.md("*Current image*:"), mo.md(f"{imgstate}")])
        ])
    showinfo    
    return


@app.cell(hide_code=True)
def _(gallery, mo, viewer):
    mo.hstack([
        viewer,mo.md(""), gallery],
               widths=[75, 5, 20]
             )
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## Wire image selection
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
def _(IIIFImageOverlayViewer, imgstate):
    viewer = None
    if imgstate:
        viewer = IIIFImageOverlayViewer(
            url = imgstate)
    return (viewer,)


@app.cell
def _():
    return


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

    return


@app.cell
def _():
    from dse_polars import DSE

    return


@app.cell
def _():
    from dataclasses import dataclass

    return


if __name__ == "__main__":
    app.run()
