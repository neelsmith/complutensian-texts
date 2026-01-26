from pathlib import Path

import pytest
from citable_corpus import CitableCorpus, CitablePassage
from urn_citation import CtsUrn

from complutensian.textloading import (
    load_corpora,
    lxx,
    masoretic,
    vulgate,
    onkelos,
)


# Test load_corpora function
def test_load_corpora_returns_dict():
    """Test that load_corpora returns a dictionary with the expected keys."""
    project_root = Path(__file__).resolve().parents[1]
    corpus_path = project_root / "public" / "compnov.cex"
    
    result = load_corpora(str(corpus_path))
    
    assert isinstance(result, dict)
    assert set(result.keys()) == {"lxx", "masoretic", "vulgate", "onkelos"}


def test_load_corpora_all_values_are_corpora():
    """Test that all values in the returned dict are CitableCorpus objects."""
    project_root = Path(__file__).resolve().parents[1]
    corpus_path = project_root / "public" / "compnov.cex"
    
    result = load_corpora(str(corpus_path))
    
    for key, corpus in result.items():
        assert isinstance(corpus, CitableCorpus), f"{key} should be a CitableCorpus"


def test_load_corpora_with_custom_path():
    """Test that load_corpora works with a custom path."""
    project_root = Path(__file__).resolve().parents[1]
    corpus_path = project_root / "public" / "compnov.cex"
    
    result = load_corpora(str(corpus_path))
    
    assert result is not None
    assert len(result) == 4


def test_load_corpora_uses_default_path():
    """Test that load_corpora can use default path parameter."""
    # This test assumes the function is called from the project root or 
    # that public/compnov.cex exists relative to where tests run
    try:
        result = load_corpora()
        assert isinstance(result, dict)
    except FileNotFoundError:
        # Expected if not in the right directory - skip test
        pytest.skip("Default path not accessible from test location")


# Test lxx function
def test_lxx_filters_septuagint_passages():
    """Test that lxx returns only Septuagint passages."""
    # Create mock passages
    passages = [
        CitablePassage(urn=CtsUrn.from_string("urn:cts:compnov:bible.genesis.septuagint:1.1"), text="Greek text"),
        CitablePassage(urn=CtsUrn.from_string("urn:cts:compnov:bible.genesis.masoretic:1.1"), text="Hebrew text"),
        CitablePassage(urn=CtsUrn.from_string("urn:cts:compnov:bible.genesis.septuagint:1.2"), text="More Greek"),
        CitablePassage(urn=CtsUrn.from_string("urn:cts:compnov:bible.genesis.vulgate:1.1"), text="Latin text"),
    ]
    corpus = CitableCorpus(passages=passages)
    
    result = lxx(corpus)
    
    assert isinstance(result, CitableCorpus)
    assert len(result.passages) == 2
    for passage in result.passages:
        assert passage.urn.version == "septuagint"


def test_lxx_returns_empty_corpus_when_no_matches():
    """Test that lxx returns an empty corpus when no Septuagint passages exist."""
    passages = [
        CitablePassage(urn=CtsUrn.from_string("urn:cts:compnov:bible.genesis.masoretic:1.1"), text="Hebrew text"),
        CitablePassage(urn=CtsUrn.from_string("urn:cts:compnov:bible.genesis.vulgate:1.1"), text="Latin text"),
    ]
    corpus = CitableCorpus(passages=passages)
    
    result = lxx(corpus)
    
    assert isinstance(result, CitableCorpus)
    assert len(result.passages) == 0


def test_lxx_with_empty_corpus():
    """Test that lxx handles empty corpus correctly."""
    corpus = CitableCorpus(passages=[])
    
    result = lxx(corpus)
    
    assert isinstance(result, CitableCorpus)
    assert len(result.passages) == 0


# Test masoretic function
def test_masoretic_filters_masoretic_passages():
    """Test that masoretic returns only Masoretic passages."""
    passages = [
        CitablePassage(urn=CtsUrn.from_string("urn:cts:compnov:bible.genesis.septuagint:1.1"), text="Greek text"),
        CitablePassage(urn=CtsUrn.from_string("urn:cts:compnov:bible.genesis.masoretic:1.1"), text="Hebrew text"),
        CitablePassage(urn=CtsUrn.from_string("urn:cts:compnov:bible.genesis.masoretic:1.2"), text="More Hebrew"),
        CitablePassage(urn=CtsUrn.from_string("urn:cts:compnov:bible.genesis.vulgate:1.1"), text="Latin text"),
    ]
    corpus = CitableCorpus(passages=passages)
    
    result = masoretic(corpus)
    
    assert isinstance(result, CitableCorpus)
    assert len(result.passages) == 2
    for passage in result.passages:
        assert passage.urn.version == "masoretic"


def test_masoretic_returns_empty_corpus_when_no_matches():
    """Test that masoretic returns an empty corpus when no Masoretic passages exist."""
    passages = [
        CitablePassage(urn=CtsUrn.from_string("urn:cts:compnov:bible.genesis.septuagint:1.1"), text="Greek text"),
        CitablePassage(urn=CtsUrn.from_string("urn:cts:compnov:bible.genesis.vulgate:1.1"), text="Latin text"),
    ]
    corpus = CitableCorpus(passages=passages)
    
    result = masoretic(corpus)
    
    assert isinstance(result, CitableCorpus)
    assert len(result.passages) == 0


def test_masoretic_with_empty_corpus():
    """Test that masoretic handles empty corpus correctly."""
    corpus = CitableCorpus(passages=[])
    
    result = masoretic(corpus)
    
    assert isinstance(result, CitableCorpus)
    assert len(result.passages) == 0


# Test vulgate function
def test_vulgate_filters_vulgate_passages():
    """Test that vulgate returns only Vulgate passages."""
    passages = [
        CitablePassage(urn=CtsUrn.from_string("urn:cts:compnov:bible.genesis.septuagint:1.1"), text="Greek text"),
        CitablePassage(urn=CtsUrn.from_string("urn:cts:compnov:bible.genesis.vulgate:1.1"), text="Latin text"),
        CitablePassage(urn=CtsUrn.from_string("urn:cts:compnov:bible.genesis.vulgate:1.2"), text="More Latin"),
        CitablePassage(urn=CtsUrn.from_string("urn:cts:compnov:bible.genesis.masoretic:1.1"), text="Hebrew text"),
    ]
    corpus = CitableCorpus(passages=passages)
    
    result = vulgate(corpus)
    
    assert isinstance(result, CitableCorpus)
    assert len(result.passages) == 2
    for passage in result.passages:
        assert passage.urn.version == "vulgate"


def test_vulgate_returns_empty_corpus_when_no_matches():
    """Test that vulgate returns an empty corpus when no Vulgate passages exist."""
    passages = [
        CitablePassage(urn=CtsUrn.from_string("urn:cts:compnov:bible.genesis.septuagint:1.1"), text="Greek text"),
        CitablePassage(urn=CtsUrn.from_string("urn:cts:compnov:bible.genesis.masoretic:1.1"), text="Hebrew text"),
    ]
    corpus = CitableCorpus(passages=passages)
    
    result = vulgate(corpus)
    
    assert isinstance(result, CitableCorpus)
    assert len(result.passages) == 0


def test_vulgate_with_empty_corpus():
    """Test that vulgate handles empty corpus correctly."""
    corpus = CitableCorpus(passages=[])
    
    result = vulgate(corpus)
    
    assert isinstance(result, CitableCorpus)
    assert len(result.passages) == 0


# Test onkelos function
def test_onkelos_filters_onkelos_passages():
    """Test that onkelos returns only Onkelos passages."""
    passages = [
        CitablePassage(urn=CtsUrn.from_string("urn:cts:compnov:bible.genesis.septuagint:1.1"), text="Greek text"),
        CitablePassage(urn=CtsUrn.from_string("urn:cts:compnov:bible.genesis.onkelos:1.1"), text="Aramaic text"),
        CitablePassage(urn=CtsUrn.from_string("urn:cts:compnov:bible.genesis.onkelos:1.2"), text="More Aramaic"),
        CitablePassage(urn=CtsUrn.from_string("urn:cts:compnov:bible.genesis.vulgate:1.1"), text="Latin text"),
    ]
    corpus = CitableCorpus(passages=passages)
    
    result = onkelos(corpus)
    
    assert isinstance(result, CitableCorpus)
    assert len(result.passages) == 2
    for passage in result.passages:
        assert passage.urn.version == "onkelos"


def test_onkelos_returns_empty_corpus_when_no_matches():
    """Test that onkelos returns an empty corpus when no Onkelos passages exist."""
    passages = [
        CitablePassage(urn=CtsUrn.from_string("urn:cts:compnov:bible.genesis.septuagint:1.1"), text="Greek text"),
        CitablePassage(urn=CtsUrn.from_string("urn:cts:compnov:bible.genesis.masoretic:1.1"), text="Hebrew text"),
    ]
    corpus = CitableCorpus(passages=passages)
    
    result = onkelos(corpus)
    
    assert isinstance(result, CitableCorpus)
    assert len(result.passages) == 0


def test_onkelos_with_empty_corpus():
    """Test that onkelos handles empty corpus correctly."""
    corpus = CitableCorpus(passages=[])
    
    result = onkelos(corpus)
    
    assert isinstance(result, CitableCorpus)
    assert len(result.passages) == 0


# Integration test
def test_load_corpora_integration():
    """Integration test to verify load_corpora works with actual data."""
    project_root = Path(__file__).resolve().parents[1]
    corpus_path = project_root / "public" / "compnov.cex"
    
    if not corpus_path.exists():
        pytest.skip("compnov.cex not found")
    
    result = load_corpora(str(corpus_path))
    
    # All corpora should have passages
    for version_name, corpus in result.items():
        assert len(corpus.passages) > 0, f"{version_name} corpus should not be empty"
        
        # Verify each corpus only contains passages of its version
        #for passage in corpus.passages:
        #    assert passage.urn.version == version_name, \
        #        f"Found {passage.urn.version} in {version_name} corpus"
