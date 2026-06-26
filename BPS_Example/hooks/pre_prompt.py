"""Cookiecutter hook script, runs in the root directory of a copy of the
repository. Allows the rewrite of `cookiecutter.json` before prompting the user
"""
import json
import sys
from datetime import datetime, UTC
from pathlib import Path

import prompts

CC_HOME = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(CC_HOME))


def main():

    TODAY = datetime.now(tz=UTC).timestamp()
    cookiecutter_json = CC_HOME / "cookiecutter.json"
    context = json.loads(cookiecutter_json.read_text())

    # Create new or dynamic variables
    context["_today"] = TODAY

    # Create a skeleton for configuration manifests as dynamic cc variables!
    # 
    context["_manifests"] = {
        "lsst": {},
        "bps": {},
        "wms": {},
        "butler": {},
        "facility": {},
    }

    # Prompts
    prompts.prompt_cookiecutter(context)
    prompts.prompt_lsst(context)
    prompts.prompt_bps(context)
    prompts.prompt_wms(context)
    prompts.prompt_site(context)

    # Write the new file back
    cookiecutter_json.write_text(json.dumps(context))


if __name__ == "__main__":
    main()
