# CM-COOKIECUTTERS

## Prerequisites
A Python tool manager (`uv` or `pipx`) is highly recommended.
Cookiecutter is a regular pip-installable Python package, though, and this repository has no dependencies other than Cookiecutter's own.

It is recommended that you create a `.cookiecutterrc` file in your home directory. Cookiecutter will automatically read this file, which can provide default values for some "well-known" variables with cross-cookie utility.

```
cat <<EOF > ~/.cookiecutterrc
default_context:
  full_name: "Bob Loblaw"
  email: "bob@loblaw.blog"
EOF
```

## Runtime Setup
### Using uv or pipx
Run `uv tool install cookiecutter` or `pipx install cookiecutter`. Cookiecutter is installed to a managed virtual environment and symlinked to (usually) your user-specific bin directory.

Run `uv tool upgrade cookiecutter` or `pipx upgrade cookiecutter` to upgrade the packages for the managed tool.

### Using venv
Create and activate a virtual environment; use pip to install the package. You will need to activate this environment every time you use cookiecutter.

```
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install cookiecutter
```

## Cookies

### BPS_Example
A fully-expressed guided BPS template for general Campaign Management Use.

See *DM-55191*.

### M49_FL_CI
A nightly continuous integration campaign for M49 FL (2025).

See *DM-50783*.

## Developer Setup
Run `uv sync`.

### Contributing
The cookies in this repository are independent cookiecutter projects. Each directory contains one cookie.

See [Cookiecutter Documentation](https://cookiecutter.readthedocs.io/en/stable/) for API help and tutorials.
