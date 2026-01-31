from importlib.metadata import version, PackageNotFoundError

try:
    __version__ = version("complutensian") # 'name' of package from pyproject.toml
except PackageNotFoundError:
    # Package is not installed (e.g., running from a local script)
    __version__ = "unknown"

from .textloading import load_corpora, lxx, masoretic, vulgate, onkelos
from .alignments import alignments_df, score_pair_directed, score_pair_two_way

__all__ = [
        "lxx", "masoretic","vulgate", "onkelos", "load_corpora",
        "alignments_df", "score_pair_directed", "score_pair_two_way"
        ]
