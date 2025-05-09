#!/usr/bin/env python3

"""Script to rasterize HiPS for multiple color bands in parallel.

This script uses a basic multiprocesisng pool to launch multiple pipetask runs
in parallel. Each run has an associated log file, and the exit code is printed
to the console when the process completes, but this wrapper script is otherwise
uninterested in the results.
"""

import os
import subprocess
import sys
from multiprocessing import Pool
from pathlib import Path

PIPETASK_COMMAND=(
    "pipetask --long-log --log-level=INFO run -j 8 "
    "-b embargo -i ${{HIPS_COLLECTION}} --output ${{HIPS_COLLECTION}} "
    "-p generate_colors_deep.yaml#generateColorHips{band} "
    "-c 'generateColorHips{band}:hips_base_uri=${{HIPS_OUTPUT_COLLECTION}}' "
    "-c 'generateColorHips{band}:properties.obs_title_template=''"
    "--register-dataset-types"
)

def worker(band):
        print(f"starting {band}")
        log_file = Path(f"hips_raster_{band}.log")
        with open(log_file, "wb") as f:
            pipetask = subprocess.run(
                PIPETASK_COMMAND.format(band=band),
                shell=True,
                capture_output=False,
                check=False,
                stdout=f,
                stderr=subprocess.STDOUT,
            )
        print(f"finished {band} with exit code {pipetask.returncode}")


def main():
    # Available Color Bands
    # COLOR_BANDS=["GRI", "RIZ", "UGR", "IZY"]
    COLOR_BANDS=["GRI", "UGR"]

    with Pool(len(COLOR_BANDS)) as p:
        p.map(worker, COLOR_BANDS)


if __name__ == "__main__":
    if any([
         "HIPS_COLLECTION" not in os.environ,
         "HIPS_OUTPUT_COLLECTION" not in os.environ,
    ]):
         print("Missing one or more of necessarily environment variables")
         print("HIPS_COLLECTION or HIPS_OUTPUT_COLLECTION missing")
         sys.exit(1)
    main()
