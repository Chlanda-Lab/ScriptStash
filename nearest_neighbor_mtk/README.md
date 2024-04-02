# Nearest neighbor clustering analysis with MTK

## Installation

Create a conda environment using the environment.yml file:

```
conda env create -f environment.yml
```

You will also need MTK (shipped with IMOD)


## Usage

The nearest-neighbor distances are calculated using the `mtk.sh` script. It extracts the correct objects from the passed model file based on the object names.
This script is invoked automatically by `run_all_mtk.sh`, which finds all appropriate model files and runs `mtk.sh` in parallel for all model files.

For each model file, a directory (called mtk) is created which contains the MTK output (randomly shifted models and nearest neighbor analysis).

All further quantification is done in the jupyter notebooks `nearest_neighbor_and_cluster_analysis.ipynb` and `plotting.ipynb`.
