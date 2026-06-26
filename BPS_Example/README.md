# BPS_Example
This cookie generates a fully-expressed BPS configuration from a wizard-like menu interface.

This "survey" consists of a series of branching prompts that allow the interactive definition of a BPS workflow configuration with options for auto provisioning, site affinity, and other user-provided inputs.

The resulting BPS config file can be further refined by the user, used directly with `bps`, or used as a template example itself.

## Setup
- See `README.md` in the repository root for information about setting up `cookiecutter`.
- Navigate to the root directory for the rendered cookies.
- `cookiecutter https://github.com/lsst-dm/cm-cookiecutters.git --directory="BPS_Example"`
- Add `--checkout <branch>` for running with branches other than `main`.

## Components

- `hooks/`: this directory contains scripts that `cookiecutter` may use for invoking custom code at certain phases of cookie creation.
    - `pre_prompt.py`: This script defines the survey/prompt questions that allow the user to provide variable data to the cookie. Usually this is defined entirely within `cookiecutter.json`, but this hook allows one to make dynamic changes to that file before the cookie starts "baking".
    - `prompts.py`: This library module contains most of the actual prompt payloads used by `pre_prompt.py` to build a dynamic cookiecutter config.
- `local_extensions.py`: This library module contains custom functions and Jinja extensions that are added to the Jinja environment by `cookiecutter.json` to use as tags and filters during the rendering process. Some of these functions are also used during the "survey" process to manipulate inputs.
- `cookiecutter.json`: The starting point for the cookiecutter config. It is a minimal config that defines the `project_slug` (i.e., package-friendly name of the output artifacts) and customizes the Jinja environment. All other inputs are acquired by the `pre_prompt.py` hook script.
- `{{ cookiecutter.project_slug }}`: The actual templates that make up the cookie, that will be written out as new rendered artifacts by `cookiecutter` during runtime.
