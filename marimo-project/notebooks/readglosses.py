# /// script
# dependencies = [
#     "citable-corpus==0.2.0",
#     "marimo",
#     "urn-citation==0.7.2",
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
def _(datasource, mo):
    mo.md(f"""
    *Data source:* {datasource}
    """)
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    # Read Latin glosses on Complutensian texts
    """)
    return


@app.cell(hide_code=True)
def _(bookchoice, chapterchoice, mo, passagechoice):
    mo.md(f"""
    {bookchoice} *Chapter* {chapterchoice} *Passage* {passagechoice}
    """)
    return


@app.cell(hide_code=True)
def _(bookchoice, lxxdisplaychoices, mo, passagechoice):
    lxxdisplay = None
    if passagechoice.value:
        lxxdisplay = mo.md(f"""## Latin glosses to Septuagint: : *{bookchoice.value.title()}*, {passagechoice.value}

    *Display* {lxxdisplaychoices}


    """)

    lxxdisplay    
    return (lxxdisplay,)


@app.cell
def _(lxxblocks, lxxdisplay, mo):
    showlxx = None
    if lxxdisplay:
        showlxx = mo.hstack(lxxblocks)
    showlxx    
    return


@app.cell(hide_code=True)
def _(bookchoice, mo, passagechoice, targumdisplaychoices):
    targumdisplay = None
    if passagechoice.value:
        targumdisplay = mo.md(f"""## Latin glosses to Targum: *{bookchoice.value.title()}*, {passagechoice.value}

    *Display* {targumdisplaychoices}


    """)

    targumdisplay 
    return (targumdisplay,)


@app.cell(hide_code=True)
def _(mo, targumblocks, targumdisplay):
    showtargum = None
    if targumdisplay:
        showtargum = mo.hstack(targumblocks)
    showtargum    
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
    ## Output choices
    """)
    return


@app.cell
def _(lxxdisplayblocks, mo):
    lxxdisplaychoices = mo.ui.multiselect(options = lxxdisplayblocks, value = list(lxxdisplayblocks.keys()))
    return (lxxdisplaychoices,)


@app.cell
def _():
    lxxdisplayblocks = {
        "Septuagint glosses: diplomatic text": "lxxdiplresult",
        "Septuagint glosses: normalized": "lxxnormresult",
        "Septuagint glosses: visual diff": "lxxdiffs"
    }
    return (lxxdisplayblocks,)


@app.cell
def _(mo, targumdisplayblocks):
    targumdisplaychoices = mo.ui.multiselect(options = targumdisplayblocks, value = list(targumdisplayblocks.keys()))
    return (targumdisplaychoices,)


@app.cell
def _():
    targumdisplayblocks = {
        "Targum glosses: diplomatic text": "targumdiplresult",
        "Targum glosses: normalized": "targumnormresult",
        "Targum glosses: visual diff": "targumdiffs"
    }
    return (targumdisplayblocks,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## Display blocks
    """)
    return


@app.cell
def _(targumdisplaychoices):
    targumdisplaychoices.value
    return


@app.cell
def _(lxxdiffs, lxxdiplresult, lxxdisplaychoices, lxxnormresult, mo):
    lxxblocks = []
    lxxcandidates = [
      "lxxdiplresult",
      "lxxnormresult",
      "lxxdiffs"
    ]
    if lxxnormresult:
        if "lxxdiplresult" in lxxdisplaychoices.value:
            lxxblocks.append(mo.vstack([mo.md("**Diplomatic text**"), mo.md(lxxdiplresult)]))
        if "lxxnormresult" in lxxdisplaychoices.value:
            lxxblocks.append(mo.vstack([mo.md("**Normalized text**"), mo.md(lxxnormresult)]))   
        if "lxxdiffs" in lxxdisplaychoices.value:
            lxxblocks.append(mo.vstack([mo.md("**Difference**"), mo.md(lxxdiffs)]))        

    return (lxxblocks,)


@app.cell
def _(
    mo,
    targumdiffs,
    targumdiplresult,
    targumdisplaychoices,
    targumnormresult,
):
    targumblocks = []
    targumcandidates =[
      "targumdiplresult",
      "targumnormresult",
      "targumdiffs"
    ]
    if targumnormresult:
        if "targumdiplresult" in targumdisplaychoices.value:
            targumblocks.append(mo.vstack([mo.md("**Diplomatic text**"), mo.md(targumdiplresult)]))
        if "targumnormresult" in targumdisplaychoices.value:
            targumblocks.append(mo.vstack([mo.md("**Normalized text**"), mo.md(targumnormresult)]))   
        if "targumdiffs" in targumdisplaychoices.value:
            targumblocks.append(mo.vstack([mo.md("**Difference**"), mo.md(targumdiffs)])) 
    return (targumblocks,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## Text selection
    """)
    return


@app.cell
def _(CtsUrn, lxxglossurn, passagechoice):
    lxx_urn = None
    if passagechoice.value:
        lxx_urn = CtsUrn.from_string(lxxglossurn + passagechoice.value)
    return (lxx_urn,)


@app.cell
def _(lxx_urn, lxxdipl):
    lxxdiplresult = None
    if lxx_urn:
        lxxdipl_cps = lxxdipl.retrieve(lxx_urn) # , lxxnorm
        lxxdiplresult = "\n\n".join([p.text for p in lxxdipl_cps])
    return (lxxdiplresult,)


@app.cell
def _(lxx_urn, lxxnorm):
    lxxnormresult = None
    if lxx_urn:
        lxxnorm_cps = lxxnorm.retrieve(lxx_urn) # , lxxnorm
        lxxnormresult = "\n\n".join([p.text for p in lxxnorm_cps])
    return (lxxnormresult,)


@app.cell
def _(CtsUrn, passagechoice, targumglossurn):
    targum_urn = None
    if passagechoice.value:
        targum_urn = CtsUrn.from_string(targumglossurn + passagechoice.value)
    return (targum_urn,)


@app.cell
def _(targum_urn, targumdipl):
    targumdiplresult = None
    if targum_urn:
        targumdipl_cps = targumdipl.retrieve(targum_urn) # , lxxnorm
        targumdiplresult = "\n\n".join([p.text for p in targumdipl_cps])
    return (targumdiplresult,)


@app.cell
def _(targum_urn, targumnorm):
    targumnormresult = None
    if targum_urn:
        targumnorm_cps = targumnorm.retrieve(targum_urn) # , lxxnorm
        targumnormresult = "\n\n".join([p.text for p in targumnorm_cps])
    return (targumnormresult,)


@app.cell
def _(targumdiplresult):
    targumdiplresult
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## Visual diffs
    """)
    return


@app.cell
def _(lxxdiplresult, lxxnormresult, visual_diff):
    lxxdiffs = None
    if lxxdiplresult:
        lxxdiffs = visual_diff(lxxdiplresult, lxxnormresult)
    return (lxxdiffs,)


@app.cell
def _(targumdiplresult, targumnormresult, visual_diff):
    targumdiffs = None
    if targumdiplresult:
        targumdiffs = visual_diff(targumdiplresult, targumnormresult)
    return (targumdiffs,)


@app.cell
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


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## Navigation
    """)
    return


@app.cell
def _():
    books = {"Genesis": "genesis"}
    return (books,)


@app.cell
def _(books, mo):
    bookchoice = mo.ui.dropdown(books,value="Genesis")
    return (bookchoice,)


@app.cell
def _(lxxdipl, re):
    chappattern = r"\..+"
    allchaps = [re.sub(chappattern, "", p.urn.passage) for p in lxxdipl.passages]
    chapters = list(dict.fromkeys(allchaps))
    return (chapters,)


@app.cell
def _(chapters, mo):
    chapterchoice = mo.ui.dropdown(chapters)
    return (chapterchoice,)


@app.cell
def _(chapterchoice, lxxdipl):
    allpassages = [p.urn.passage for p in lxxdipl.passages]
    passages = []
    if chapterchoice.value:
        passages = [p for p in allpassages if p.startswith(chapterchoice.value + ".")]
    return (passages,)


@app.cell
def _(mo, passages):
    passagechoice = mo.ui.dropdown(passages)
    return (passagechoice,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## Load data
    """)
    return


@app.cell
def _(mo):
    datasource = mo.ui.dropdown({"Download":"url", "Use local file": "local"}, value="Download")
    return (datasource,)


@app.cell
def _(buildeditions, targumfulltext, targumglossurn):
    targumdipl, targumnorm = buildeditions(targumfulltext, targumglossurn)
    return targumdipl, targumnorm


@app.cell
def _(buildeditions, lxxfulltext, lxxglossurn):
    lxxdipl, lxxnorm = buildeditions(lxxfulltext, lxxglossurn)
    return lxxdipl, lxxnorm


@app.cell
def _(datasource, lxxglossfile, lxxurl, requests):
    lxxfulltext = None
    if datasource.value == "url":
        lxxfulltext = requests.get(lxxurl).text

    else:
        lxxfulltext = lxxglossfile.read_text(encoding="utf-8")
    return (lxxfulltext,)


@app.cell
def _(datasource, requests, targumglossfile, targumurl):
    targumfulltext = None
    if datasource.value == "url":
        targumfulltext =  requests.get(targumurl).text

    else:
        targumfulltext = targumglossfile.read_text(encoding="utf-8")
    return (targumfulltext,)


@app.cell
def _(TEIDiplomatic, TEIDivAbReader, TEINormalized):
    def buildeditions(glosstext: str, baseurn):
        #glosstext = fpath.read_text(encoding="utf-8")
        xmlcorpus = TEIDivAbReader.corpus(glosstext, baseurn)
        dipl = TEIDiplomatic.edition(xmlcorpus)
        norm = TEINormalized.edition(xmlcorpus)
        return (dipl, norm)

    return (buildeditions,)


@app.cell
def _():
    lxxurl = "https://raw.githubusercontent.com/neelsmith/complutensian-texts/refs/heads/main/editions/septuagint_latin_genesis.xml"
    return (lxxurl,)


@app.cell
def _():
    targumurl = "https://raw.githubusercontent.com/neelsmith/complutensian-texts/refs/heads/main/editions/targum_latin_genesis.xml"
    return (targumurl,)


@app.cell
def _(Path):
    lxxglossfile = Path.cwd().parent / "editions" / "septuagint_latin_genesis.xml"
    return (lxxglossfile,)


@app.cell
def _():
    lxxglossurn = "urn:cts:compnov:bible.genesis.sept_latin:"
    return (lxxglossurn,)


@app.cell
def _(Path):
    targumglossfile = Path.cwd().parent / "editions" / "targum_latin_genesis.xml"
    return (targumglossfile,)


@app.cell
def _():
    targumglossurn = "urn:cts:compnov:bible.genesis.targum_latin:"
    return (targumglossurn,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    ## Imports
    """)
    return


@app.cell
def _():
    from urn_citation import CtsUrn
    from citable_corpus import CitableCorpus, CitablePassage, TEIDivAbReader, TEIDiplomatic, TEINormalized

    return CtsUrn, TEIDiplomatic, TEIDivAbReader, TEINormalized


@app.cell
def _():
    from pathlib import Path
    import re

    return Path, re


@app.cell
def _():
    import difflib
    from html import escape

    return difflib, escape


@app.cell
def _():
    import requests

    return (requests,)


if __name__ == "__main__":
    app.run()
