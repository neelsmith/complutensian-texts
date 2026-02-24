from pathlib import Path
from citable_corpus import TEIDivAbReader, TEINormalized, TEIDiplomatic

editionsdir = Path.cwd() / "editions"
outputdir = Path.cwd() / "scratch"

lxxfile = editionsdir / "septuagint_latin_genesis.xml"
with lxxfile.open('r') as f:
    lxxxml = f.read()
targfile = editionsdir / "targum_latin_genesis.xml"
with targfile.open('r') as f:
    targxml = f.read()

lxxglossurn = "urn:cts:compnov:bible.genesis.sept_latin:"
lxxcorp = TEIDivAbReader.corpus(lxxxml, lxxglossurn)

targglossurn = "urn:cts:compnov:bible.genesis.targum_latin:"
targcorp = TEIDivAbReader.corpus(targxml, targglossurn)


lxxdipl = TEIDiplomatic.edition(lxxcorp)
lxxnorm = TEINormalized.edition(lxxcorp)
targdipl = TEIDiplomatic.edition(targcorp)
targnorm = TEINormalized.edition(targcorp)


lxxdiplcex = lxxdipl.cex(label_block=True)
lxxnormcex = lxxnorm.cex()
targdiplcex = targdipl.cex()
targnormcex = targnorm.cex()

with open(str(outputdir /"septuagint_latin_genesis_dipl.cex"), "w") as file:
    file.write(lxxdiplcex)

with open(str(outputdir / "septuagint_latin_genesis_norm.cex"), "w") as file:
    file.write(lxxnormcex)

with open(str(outputdir / "targum_latin_genesis_dipl.cex"), "w") as file:
    file.write(targdiplcex)

with open(str(outputdir / "targum_latin_genesis_norm.cex"), "w") as file:
    file.write(targnormcex)