from pathlib import Path

from citable_corpus import CitableCorpus

from complutensian.textloading import load_corpus


def test_load_corpus_reads_compnov_cex():
    project_root = Path(__file__).resolve().parents[1]
    corpus_path = project_root / "public" / "compnov.cex"

    corpus = load_corpus(str(corpus_path))

    assert isinstance(corpus, CitableCorpus)
    assert len(corpus.passages) == 85514

    first = corpus.passages[0]
    assert str(first.urn) == "urn:cts:compnov:bible.genesis.septuagint:1.1"
    assert first.text == "ἘΝ ἀρχῇ ἐποίησεν ὁ Θεὸς τὸν οὐρανὸν καὶ τὴν γῆν."
