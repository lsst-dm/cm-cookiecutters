#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "cookiecutter",
# ]
# ///
from datetime import datetime, timedelta
from pathlib import Path

from cookiecutter.main import cookiecutter


def main():
    yesterday = datetime.today() - timedelta(days=1)
    obs_day = yesterday.strftime("%Y%m%d")
    cookiecutter(
        str(Path(__file__).parent),
        extra_context={
            "obs_day": obs_day,
        },
    )


if __name__ == "__main__":
    main()
