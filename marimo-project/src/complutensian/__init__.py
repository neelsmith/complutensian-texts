from importlib.metadata import version, PackageNotFoundError

try:
    __version__ = version("complutensian") # 'name' of package from pyproject.toml
except PackageNotFoundError:
    # Package is not installed (e.g., running from a local script)
    __version__ = "unknown"

from .textloading import load_corpora, lxx, masoretic, vulgate, onkelos

__all__ = ["lxx", "masoretic","vulgate", "onkelos", "load_corpora"]
