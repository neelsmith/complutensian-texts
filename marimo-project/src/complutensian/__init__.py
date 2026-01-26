from importlib.metadata import version, PackageNotFoundError

try:
    __version__ = version("complutensian") # 'name' of package from pyproject.toml
except PackageNotFoundError:
    # Package is not installed (e.g., running from a local script)
    __version__ = "unknown"

from .textloading import lxx



__all__ = ["lxx"]