# /// script
# dependencies = [
#     "dse-polars==0.1.1",
#     "iiif-anywidget==0.3.0",
#     "marimo",
# ]
# requires-python = ">=3.14"
# ///

import marimo

__generated_with = "0.20.2"
app = marimo.App(width="medium")


@app.cell(hide_code=True)
def _():
    import marimo as mo

    return (mo,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    # Browse DSE of the Complutensian Polyglot Bible
    """)
    return


@app.cell(hide_code=True)
def _(manifest):
    manifest
    return


@app.cell(hide_code=True)
def _(imageheight):
    imageheight
    return


@app.cell
def _(info_url2urn, mo, service, ustate):
    mo.vstack([
        mo.md("*Currently displayed image*:"),
        mo.md(f"""{ustate["url"]}"""),
        mo.md(f"*Equivalent URN*:"),
        mo.md(f"`{info_url2urn(ustate["url"],service)}`")
    ])
    return


@app.cell(hide_code=True)
def _(galleryblock):
    galleryblock
    return


@app.cell(hide_code=True)
def _(mo):
    mo.Html("<br/><br/><br/><br/><br/><br/><br/><br/>")
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## Computation
    """)
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ### Mocks for image package
    """)
    return


@app.cell
def _(dataclass):
    @dataclass
    class CitableIIIFService:
        urlbase: str
        extension: str

    return (CitableIIIFService,)


@app.cell
def _(CitableIIIFService):
    service = CitableIIIFService(urlbase = "https://www.homermultitext.org/iipsrv?IIIF=/project/homer/pyramidal/deepzoom/", extension = "tif")
    return (service,)


@app.cell
def _(CitableIIIFService, u):
    def urn2info_url(urn: str,srvc: CitableIIIFService):
        speclabel,spectype,ns,collection,objectcomponent =  u.split(":")
        collectionid, collectionversion = collection.split(".")
        return srvc.urlbase + ns + "/" + collectionid + "/" + collectionversion + "/" + objectcomponent + "." + srvc.extension + "/info.json"

    return (urn2info_url,)


@app.cell
def _(CitableIIIFService):
    def info_url2urn1(url: str, srvc: CitableIIIFService):
        strip1 = url.replace(srvc.urlbase,"")
        ns,coll,vers,imgid,junk = strip1.split("/")
        suffix = f".{srvc.extension}"
        objid = imgid.removesuffix(suffix)
        return  "urn:cite2:" + ns + ":" + coll + "." + vers  + ":" + objid

    def info_url2urn(url: str, srvc: CitableIIIFService):
        return info_url2urn1(url, srvc)

    return (info_url2urn,)


@app.cell
def _(info_url2urn, infourl_eg, service):
    info_url2urn(infourl_eg,service)
    return


@app.cell
def _():
    u = "urn:cite2:citebne:complutensian.v1:v1p19"
    return (u,)


@app.cell
def _(service, u, urn2info_url):
    infourl_eg = urn2info_url(u, service)
    return (infourl_eg,)


@app.cell
def _(infourl_eg, mo):
    mo.md(f"""
    {infourl_eg}
    """)
    return


@app.cell
def _():
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ### Load DSE
    """)
    return


@app.cell
def _(mo):
    datadir = mo.notebook_location() / "public"
    return (datadir,)


@app.cell
def _(datadir):
    lxxfile = str(datadir / "septuagint_latin_genesis_dse.cex")
    return (lxxfile,)


@app.cell
def _(lxxfile):
    lxxfile
    return


@app.cell
def _(lxxfile, pl):
    lxxdf = pl.read_csv( lxxfile, separator="|")
    return (lxxdf,)


@app.cell
def _(DSE, lxxdf):
    lxx = DSE(lxxdf)
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ### Set up variable observer
    """)
    return


@app.cell
def _(url_state):
    ustate = url_state()
    return (ustate,)


@app.cell
def _(mo):
    url_state, set_url_state = mo.state(
        {
            "url": ""
        }
    )
    return set_url_state, url_state


@app.cell
def _(push_state, viewer):
    if viewer:
        viewer.observe(push_state, names=["url"])
        viewer._marimo_observer = push_state
        push_state()
    return


@app.cell
def _(set_url_state, viewer):
    def push_state(_change=None):
        "Update value of URL from viewer object."
        set_url_state(
            {
                "url": viewer.url
            }
        )

    return (push_state,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ### Layout
    """)
    return


@app.cell
def _(IIIFThumbnailGallery, manifest):
    gallery = None
    if manifest.value:
        gallery = IIIFThumbnailGallery(manifest_url = manifest.value)
    return (gallery,)


@app.cell
def _(gallery):
    image_choice = None
    if gallery:
        image_choice = gallery.selected_info_url.strip()
    return (image_choice,)


@app.cell
def _(IIIFViewer, image_choice, imageheight):
    viewer = None
    if image_choice:
        viewer = IIIFViewer(url = image_choice, height=imageheight.value)
    return (viewer,)


@app.cell
def _(gallery, mo, viewer):
    galleryblock = None
    if viewer:    
        galleryblock = mo.hstack([
            viewer,
            mo.md(""),
            gallery
        ], widths=[75, 5, 20])
    return (galleryblock,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ### User selection
    """)
    return


@app.cell
def _(mo):
    imageheight = mo.ui.slider(start=100,stop=1500,value=600,show_value=True,label="*Height of image (pixels)*:")
    return (imageheight,)


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
    ### Imports
    """)
    return


@app.cell
def _():
    from iiif_anywidget import IIIFViewer, IIIFThumbnailGallery

    return IIIFThumbnailGallery, IIIFViewer


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
    from dataclasses import dataclass

    return (dataclass,)


if __name__ == "__main__":
    app.run()
