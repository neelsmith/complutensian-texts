import polars as pl
from pathlib import Path


def alignments_df(f) -> pl.DataFrame:
    """Read delimited-text file into a Polars DataFrame with expected settings: `separator` = '|' and `truncate_ragged_lines` = True.
    
    # Arguments:
        f: Path to the delimited-text file.
    """
    return pl.read_csv(f, separator="|", truncate_ragged_lines=True)


def score_pair_directed(df, col1, col2) -> pl.DataFrame:
    """Score alignments between two columns in the DataFrame.
    
    # Arguments:
        df: Polars DataFrame containing the data.
        col1: Name of the first column to compare.
        col2: Name of the second column to compare.
        
    # Returns:
        A Polars DataFrame with the normalized scores of non-null alignments between the two columns .
    """
    #xtab = (
     #   df.filter(pl.col(col1).is_not_null() & pl.col(col2).is_not_null())
    xtab = (
        df.filter(pl.col(col1).is_not_null())
        .group_by([col1, col2])
        .len()
        .sort([col1, "len"], descending=[False, True])
    )
    #print("Xtab computed:")

    scoresdf = xtab.with_columns(
        (pl.col("len") / pl.col("len").sum().over(col1)).alias("scores")
    )
    return scoresdf



def score_pair_two_way(scores1, scores2, col1, col2) -> pl.DataFrame:
    return None

# This seems to work:
#final_df = gl.join(
#   lg, 
#    on=["greek_lemma", "latin_lemma"], 
#    how="outer",  # Keep everything
#    suffix="_rev"
#).fill_null(0).with_columns(
#    ((pl.col("scores") + pl.col("scores_rev")) / 2).alias("average_score")
#)