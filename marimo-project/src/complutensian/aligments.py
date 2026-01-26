import polars as pl
from pathlib import Path


def alignments_df(f) -> pl.DataFrame:
    """Read torah-verbs.cex file into a Polars DataFrame."""
    # Get the path relative to this file
    #current_dir = Path(__file__).parent
    #cex_path = current_dir.parent / "public" / "torah-verbs.cex"
    
    return pl.read_csv(f, separator="|")
