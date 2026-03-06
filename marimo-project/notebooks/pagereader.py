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
def _(choiceblock):
    choiceblock
    return


@app.cell(hide_code=True)
def _(currentclickpage, dse, mo, pagefrom, pagemenu, passagemenu, service):
    currentpage = None
    debugs = ""
    if pagefrom.value == "page_id":
        currentpage = pagemenu.value

    elif pagefrom.value == "passage":
        if passagemenu.value:
            psgurn = "urn:cts:compnov:bible.genesis.sept_latin:" + passagemenu.value
            psgmatches = dse.surfacesforpassage(psgurn).to_series().to_list()
            if len(psgmatches) == 1:
                currentpage = psgmatches[0]

    elif pagefrom.value == "image_gallery" and currentclickpage:
        clickie = service.info_url2urn(currentclickpage)
        pagematches = dse.surfacesforimage(clickie)
        debugs = f"for {clickie} found {pagematches.to_series().to_list()}"
        if len(pagematches) == 1:
            currentpage = pagematches.to_series().to_list()[0]


    hdr = None
    if currentpage:
        hdr = mo.md(f"""## Read page `{currentpage}`
        """)
    hdr
    return (currentpage,)


@app.cell(hide_code=True)
def _(imagetab, mo, texttab):
    tabs = mo.ui.tabs({
        "Text view": texttab,
        "Image view": imagetab
    })
    tabs
    return


@app.cell(column=1, hide_code=True)
def _(mo):
    mo.md("""
    ## Image tab
    """)
    return


@app.cell
def _(coords):
    coords
    return


@app.cell
def _(
    coords_state,
    currentpage,
    currentpageimg,
    currentpageinfourl,
    mo,
    observer_status,
    viewer,
):
    coords = coords_state()
    pixmsg = f"x,y {coords['pixel_x']}, {coords['pixel_y']}"
    normmsg = f"normalized {coords['normalized_x']}, {coords['normalized_y']}"
    last_change = coords.get("last_change", "")
    last_new = coords.get("last_new", "")
    imagetab = mo.vstack([
        mo.md(f""" 

    - page {currentpage} 
    - image {currentpageimg}
    - info url is {currentpageinfourl}



    pixels {pixmsg}
    {normmsg}
    observer {observer_status}
    last change {last_change}
    last new {last_new}

    Use Option-click (Alt-click) in the viewer to update coordinates.
    """), viewer])
    return coords, imagetab


@app.cell
def _(imglist):

    currentpageimg = None
    if len(imglist) == 1:
        currentpageimg = imglist[0]
    return (currentpageimg,)


@app.cell
def _(currentpageimg, service):
    currentpageinfourl = None
    if currentpageimg:
        currentpageinfourl = service.urn2info_url(currentpageimg)
    return (currentpageinfourl,)


@app.cell
def _(currentpageinfourl, iiif, pagerect_strings):
    viewer = None
    if currentpageinfourl:
        viewer = iiif.IIIFImageOverlayViewer(url = currentpageinfourl, rectangles_csv = "\n".join(pagerect_strings))
    return (viewer,)


@app.cell
def _(currentpage, dse):
    imglist = dse.wholeimagesforsurface(currentpage).to_series().to_list()
    return (imglist,)


@app.cell
def _(currentpage, dse):
    pagerect_strings = []
    if currentpage:
        pagerects = dse.rectsforsurface(currentpage)

        if hasattr(pagerects, "columns"):
            cols = set(pagerects.columns)
            if {"x", "y", "w", "h"}.issubset(cols):
                rows = pagerects.select(["x", "y", "w", "h"]).iter_rows(named=True)
                pagerect_strings = [
                    ",".join(str(row[key]) for key in ("x", "y", "w", "h"))
                    for row in rows
                ]
            elif "rect" in cols:
                for rect in pagerects.get_column("rect").to_list():
                    if isinstance(rect, dict) and {"x", "y", "w", "h"}.issubset(rect):
                        pagerect_strings.append(
                            ",".join(str(rect[key]) for key in ("x", "y", "w", "h"))
                        )
                    elif isinstance(rect, (list, tuple)) and len(rect) == 4:
                        pagerect_strings.append(",".join(str(v) for v in rect))
                    else:
                        pagerect_strings.append(str(rect))
        else:
            for rect in pagerects:
                if isinstance(rect, dict) and {"x", "y", "w", "h"}.issubset(rect):
                    pagerect_strings.append(
                        ",".join(str(rect[key]) for key in ("x", "y", "w", "h"))
                    )
                elif isinstance(rect, (list, tuple)) and len(rect) == 4:
                    pagerect_strings.append(",".join(str(v) for v in rect))
                else:
                    pagerect_strings.append(str(rect))
    return (pagerect_strings,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## Wiring alt-click action
    """)
    return


@app.cell
def _(mo):
    coords_state, set_coords_state = mo.state(
        {
            "pixel_x": -1.0,
            "pixel_y": -1.0,
            "normalized_x": -1.0,
            "normalized_y": -1.0,
            "last_change": "",
            "last_new": "",
        }
    )
    return coords_state, set_coords_state


@app.cell
def _(push_state, viewer):
    observer_status = "viewer_missing"
    if viewer is not None:
        _viewer_trait_names = ["pixel_x", "pixel_y", "normalized_x", "normalized_y"]

        _viewer_old_observer = getattr(viewer, "_marimo_observer", None)
        if _viewer_old_observer is not None:
            viewer.unobserve(_viewer_old_observer, names=_viewer_trait_names)

        viewer.observe(push_state, names=_viewer_trait_names)
        viewer._marimo_observer = push_state
        push_state()
        observer_status = "attached"
    return (observer_status,)


@app.cell
def _(set_coords_state, viewer):
    def push_state(_change=None):
        "Update value of coordinates state from viewer object."
        if viewer is None:
            return

        _change_name = "initial"
        _change_new = ""
        if isinstance(_change, dict):
            _change_name = str(_change.get("name", ""))
            _change_new = str(_change.get("new", ""))

        set_coords_state(
            {
                "pixel_x": float(viewer.pixel_x),
                "pixel_y": float(viewer.pixel_y),
                "normalized_x": float(viewer.normalized_x),
                "normalized_y": float(viewer.normalized_y),
                "last_change": _change_name,
                "last_new": _change_new,
            }
        )


    return (push_state,)


@app.cell(column=2, hide_code=True)
def _(mo):
    mo.md("""
    ## Text tab
    """)
    return


@app.cell
def _(lxxstack, mo, targumstack):
    texttab = mo.md(f"""

    ### Latin glosses on Septuagint

    {lxxstack}



    ### Latin glosses on Targum Onkelos

    {targumstack}

    """)
    return (texttab,)


@app.cell
def _(currentpage, dse):
    pagepassagelist = dse.passagesforsurface(currentpage).to_series().to_list()
    return (pagepassagelist,)


@app.cell
def _(pagepassagelist):
    pagepassagediplomatic = [
        f"{head}.diplomatic:{tail}"
        for u in pagepassagelist
        for head, _, tail in [u.rpartition(":")]
    ]
    return (pagepassagediplomatic,)


@app.cell
def _(pagepassagelist):
    pagepassagenormed = [
        f"{head}.normalized:{tail}"
        for u in pagepassagelist
        for head, _, tail in [u.rpartition(":")]
    ]
    return (pagepassagenormed,)


@app.cell
def _(lxxdiff, lxxdiplformatted, lxxnormformatted, mo):
    lxxstack =mo.hstack([lxxdiplformatted,mo.md(""), lxxnormformatted, mo.Html(lxxdiff)], widths=[30, 5, 30, 30])
    return (lxxstack,)


@app.cell
def _(lxxdiff):
    lxxdiff
    return


@app.cell(hide_code=True)
def _(difflib, escape):
    def visual_diff(string1: str, string2: str) -> str:
        """
        Generate an HTML visual diff of two strings.

        Args:
            string1: The first string to compare
            string2: The second string to compare

        Returns:
            HTML string with highlighted differences:
            - Common text: no highlighting
            - Text only in string1: pastel yellow background
            - Text only in string2: pastel green background
        """
        # Use SequenceMatcher to find differences at character level
        matcher = difflib.SequenceMatcher(None, string1, string2)

        html_parts = []

        for opcode, i1, i2, j1, j2 in matcher.get_opcodes():
            if opcode == 'equal':
                # Common text - no highlighting
                html_parts.append(escape(string1[i1:i2]))
            elif opcode == 'delete':
                # Text only in string1 - yellow background
                text = escape(string1[i1:i2])
                html_parts.append(f'<span style="background-color: #ffe4b3;">{text}</span>')
            elif opcode == 'insert':
                # Text only in string2 - green background
                text = escape(string2[j1:j2])
                html_parts.append(f'<span style="background-color: #c6efce;">{text}</span>')
            elif opcode == 'replace':
                # Text changed - show deleted part in yellow and inserted part in green
                if i1 < i2:
                    text = escape(string1[i1:i2])
                    html_parts.append(f'<span style="background-color: #ffe4b3;">{text}</span>')
                if j1 < j2:
                    text = escape(string2[j1:j2])
                    html_parts.append(f'<span style="background-color: #c6efce;">{text}</span>')

        return ''.join(html_parts)

    return (visual_diff,)


@app.cell
def _(formatpagetext, lxxdipl, pagepassagediplomatic, targumdipl):
    lxxdiplformatted = formatpagetext(lxxdipl, pagepassagediplomatic)
    targdiplformatted = formatpagetext(targumdipl, pagepassagediplomatic)
    return (lxxdiplformatted,)


@app.cell
def _(formatpagetext, lxxnorm, pagepassagenormed, targumnorm):
    lxxnormformatted = formatpagetext(lxxnorm, pagepassagenormed)
    targnormformatted = formatpagetext(targumnorm, pagepassagenormed)
    return (lxxnormformatted,)


@app.cell
def _(lxxdipl, pagepassagediplomatic, pl):
    pagelxxdipltext =    " ".join(lxxdipl.filter(pl.col("urn").is_in(pagepassagediplomatic)).select(["text"]).to_series().to_list())
    return (pagelxxdipltext,)


@app.cell
def _(lxxnorm, pagepassagenormed, pl):
    pagelxxdnormtext =    " ".join(lxxnorm.filter(pl.col("urn").is_in(pagepassagenormed)).select(["text"]).to_series().to_list())
    pagelxxdnormtext
    return (pagelxxdnormtext,)


@app.cell
def _(pagelxxdipltext):
    pagelxxdipltext
    return


@app.cell
def _(pagelxxdipltext, pagelxxdnormtext, visual_diff):
    lxxdiff = visual_diff(pagelxxdipltext, pagelxxdnormtext)
    return (lxxdiff,)


@app.cell
def _(md_passages, mo, pl):
    def formatpagetext(corpus, filterlist):
        pagefiltered = corpus.filter(pl.col("urn").is_in(filterlist)).select(["urn", "text"])
        return mo.md("\n\n".join(md_passages(pagefiltered, highlighter='**')))

    return (formatpagetext,)


@app.cell
def _():
    return


@app.cell
def _(pl):
    def md_passages(df: pl.DataFrame, highlighter = "*") -> list[str]:
        "Generates a formatted string for each passage in the dataframe consisting of the final passage component of the urn, surrounded by the highlighter string, followed by a space and the text content."
        rows = (
            df.select("urn", "text")
            .filter(pl.col("urn").is_not_null() & pl.col("text").is_not_null())
            .iter_rows(named=True)
        )
        return [
            f"{highlighter}{row['urn'].rsplit(':', 1)[-1]}{highlighter} {row['text']}"
            for row in rows
        ]

    return (md_passages,)


@app.cell
def _(mo):
    targumstack=mo.md("""
    Targum stack goes here
    """)
    return (targumstack,)


@app.cell(column=3, hide_code=True)
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
def _():
    import polars as pl
    from io import StringIO

    return StringIO, pl


@app.cell
def _():
    from pathlib import Path

    return


@app.cell
def _():
    import difflib
    from html import escape

    return difflib, escape


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## Wiring gallery reaction
    """)
    return


@app.cell
def _(gallery, mo, pagefrom):
    currentclickpage_state, set_currentclickpage_state = mo.state(None)

    if pagefrom.value == "image_gallery" and gallery is not None:
        def push_currentclickpage(_change=None):
            set_currentclickpage_state(gallery.selected_info_url)

        old_observer = getattr(gallery, "_marimo_selected_info_observer", None)
        if old_observer is not None:
            gallery.unobserve(old_observer, names=["selected_info_url"])

        gallery.observe(push_currentclickpage, names=["selected_info_url"])
        gallery._marimo_selected_info_observer = push_currentclickpage
        push_currentclickpage()
    else:
        set_currentclickpage_state(None)
    return (currentclickpage_state,)


@app.cell
def _(currentclickpage_state):
    currentclickpage = currentclickpage_state()
    return (currentclickpage,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## UI
    """)
    return


@app.cell
def _(gallery, mo, pagefrom, pagemenu, passagemenu):
    choiceblock = None
    if pagefrom.value == "page_id":
        choiceblock = mo.hstack([pagefrom,pagemenu],widths=[30,40])

    elif pagefrom.value == "passage":
        choiceblock = mo.hstack([pagefrom,passagemenu],widths=[30,40])

    elif pagefrom.value == "image_gallery":
        choiceblock = mo.vstack([pagefrom,gallery])
    else:
        choiceblock = pagefrom
    return (choiceblock,)


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
    pagemenudf = dse.surfaces().with_columns(
                pl.col("surface")
                .cast(pl.Utf8)
                .str.replace_all(r"[\[\]\"']", "")
                .str.replace_all(",", ":")
                .str.replace_all(r"\s+", "")
                .str.replace(r"^.*:", "")
                .alias("label")
            )
    pagemenulabels = pagemenudf["label"].to_list()
    pagemenuvals = pagemenudf["surface"].to_list()
    pagemenuoptions = dict(zip(pagemenulabels, pagemenuvals))
    pagemenu = mo.ui.dropdown(pagemenuoptions,label="*Select a page*")
    return (pagemenu,)


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


@app.cell
def _(dse, iiif, service):
    imgs = dse.images().to_series().to_list()
    infourls = [service.urn2info_url(img) for img in imgs]
    gallery = iiif.IIIFThumbnailGallery(info_urls=infourls, height="150px")
    return (gallery,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## Load DSE data
    """)
    return


@app.cell
def _(mo):
    nb_dir = mo.notebook_location()
    local_public = nb_dir / "public"
    lxx_path = local_public / "septuagint_latin_genesis_dse.cex"
    targum_path = local_public / "targum_latin_genesis_dse.cex"
    return lxx_path, targum_path


@app.cell
def _(lxx_path, targum_path):
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


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## Load texts
    """)
    return


@app.cell
def _(loadeditions):
    lxxdipl, lxxnorm, targumdipl, targumnorm = loadeditions()
    return lxxdipl, lxxnorm, targumdipl, targumnorm


@app.cell
def _(StringIO, pl):
    def loadedition(fname: str):
        """Read a CEX file with a single labelled block of delimited data, so omitting initial line.
        Return a polars dataframe
        """
        # Check if fname is a URL or local file path
        if fname.startswith('http://') or fname.startswith('https://'):
            # WASM mode - fetch from URL
            import urllib.request
            with urllib.request.urlopen(fname) as response:
                content = response.read().decode('utf-8')
                src = '\n'.join(content.split('\n')[2:])
        else:
            # Local mode - read from file
            with open(fname, 'r', encoding='utf-8') as file:
                src = '\n'.join(file.readlines()[2:])

        return pl.read_csv(StringIO(src), separator='|', has_header=False, new_columns=["urn", "text"]).drop_nulls()

    return (loadedition,)


@app.cell
def _(loadedition, mo):
    def loadeditions():
        nb_location = mo.notebook_location()
        filenames = ["septuagint_latin_genesis_dipl.cex","septuagint_latin_genesis_norm.cex",
                     "targum_latin_genesis_dipl.cex","targum_latin_genesis_norm.cex"]

        # Check if running in WASM (URL) or local (Path)
        if isinstance(nb_location, str):
            # WASM mode - nb_location is a URL
            base_url = nb_location.rstrip('/') + '/public/'
            fullpaths = [base_url + f for f in filenames]
        else:
            # Local mode - nb_location is a Path
            editionsdir = nb_location / "public" 
            fullpaths = [str(editionsdir / f) for f in filenames]

        return [loadedition(f) for f in fullpaths]

    return (loadeditions,)


if __name__ == "__main__":
    app.run()
