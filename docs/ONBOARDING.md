# Campaign Management Cookie Cutters

## Introduction
A "cookie" is an instance of a software project that has been generated from a template defined in a package called a "cookie cutter".
This pattern is backed by the Python Cookiecutter package, which is a command-line tool that simplifies the collection of instance variables and subsequent rendering of Jinja2 templates.
Through this template rendering, complete boilerplate projects can be created quickly and kept independent (i.e., the rendered cookies maintain no links or dependencies on the cookie cutter) on a variety of systems.

## Getting Started
Cookiecutter is a pip-installable Python package that provides a command-line interface to the package.

To install the Cookiecutter package, use `uv` or `pipx` to install a dedicated Python environment for the Cookiecutter package. The version of Python used does not matter as long as it is supported by the Cookiecutter package.

> [!NOTE]
> The best practice for installing Cookiecutter is to use `uv tool install cookiecutter`. When using `uv`, be sure to do so with a "clean shell" and a `uv`-managed Python in order to eliminate external dependencies.

> [!CAUTION]
> To minimize conflicts and other issues, avoid installing or attempting to install Cookiecutter using a system Python or with an unrelated Python environment activated.

## Cookiecutter Repository
This repository is structured for use with Cookiecutter -- each top-level directory is an independent Cookiecutter that can be used by the tool, and this may be on the `main` branch or any other arbitrary branch.

In the root area of the repository, only basic repo-level files are present; none of these are required for Cookiecutters.

## Creating a New Cookiecutter

1. Clone this repo to a development location in the usual way.

1. If necessary, use `uv sync` to create a Python virtual environment for the repo. The `pyproject.toml` file indicates that that only requirement is the Cookiecutter package. If Cookiecutter is otherwise installed, this step is not necessary.

1. Create a new branch for the new Cookiecutter in the usual way.

1. Create a new Cookiecutter directory and develop the Cookiecutter.

1. Commit the work and push the branch to the upstream repo.

### Example

```
cd ~/git
git clone https://github.com/lsst-dm/cm-cookiecutters.git
cd cm-cookiecutters
git branch u/me/mycookie
mkdir mycookie
cd mycookie
touch cookiecutter.json
```

## Cookiecutter Requirements
All Cookiecutters must have, in their directory, two items: A `cookiecutter.json` file, and a template directory tree.

The `cookiecutter.json` file contains a JSON object where each key defines a Cookiecutter templating *variable* and its value indicates the default value for that variable.

> [!NOTE]
> For each template variable your cookie cutter will use, this variable name *must* be defined in the `cookiecutter.json` file. Template variables may be manipulated with Python methods within your template files, but every variable name must be declared in this JSON file. The default value of a template variable may itself refer to other template variables, as seen in the next example.

The second item every Cookiecutter must have is the directory tree of actual template contents. This may have a fixed name but is more often itself based on the value of a Cookiecutter variable.

> [!NOTE]
> Cookiecutter variables are always referred to using the "double-mustache" template string `{{ ... }}` where the variable name is used between the "mustaches," such as with `{{ cookiecutter.project_name }}`.

All files for the Cookiecutter are then added to the template directory. Within these files, any *variable* text can be referenced with the `{{ cookiecutter.varname }}` template reference.
This can be done in any text file, irrespective of its type, and the files do not -- and should not -- be named any differently to their intended name, e.g., call a file `run.sh` and not `run.sh.template`.

Within the template placeholder string, the value can be manipulated with *template filters* or with Python methods.
A common pattern might be to call string methods to manipulate a value, such as with `{{ cookiecutter.variable.lower() }}` to use the lower-case version of a value.
You can use complete Python expressions within the template placeholders, e.g., `{{ int(cookiecutter.number_value) * 10 }}`, as needed to express your intentions.

Any time a cookie is created from this cookiecutter, you have the opportunity to set these values or accept the default, and any instance of a cookiecutter variable in these files is replaced with the appropriate value.

### Example

Given a `cookiecutter.json` with the following contents:

```
{
    "project_name": "project",
    "project_day": "20250601",
    "project_directory": "{{cookiecutter.project_name}}_{{cookiecutter.project_day}}"
}
```

Create a directory called `{{cookiecutter.project_directory}}` for the template contents. When the cookie is rendered, the actual directory created will be `project_20250601` -- the result of replacing the `{{...}}` variable references in the `project_directory` value with the definition for that variable.

## Creating Cookie Instances

Once the cookiecutter template is defined, the cookiecutter CLI tool is used to create instances of the cookie, which are new directories with contents rendered from the values provided.

In any target directory, invoke the cookiecutter command with the location of the cookiecutter template repo, the specific directory within that repo for your cookie, and, optionally, any cookie variables you want to set on the command line.
The location of the cookiecutter template can be a local path (useful when testing cookies during development) or a Github url with or without a branch specification.

```
cookiecutter https://github.com/lsst-dm/cm-cookiecutters.git --directory="mycookie" --checkout <branchname>
```

The cookiecutter tool then downloads or syncs the repository and queries the user to provide any variable input.
Using that input, the new cookie directory is created and all the contents rendered out into it.

> [!NOTE]
> The creation of cookies can be automated or streamlined by passing the `--no-input` argument to prevent prompting for parameters, in which case the default values are always used. Alternately, cookiecutter supports a `--replay` option to reproduce cookies with specific inputs. Check the cookiecutter documentation for more information.

## Advanced Topics
Beyond basic Cookiecutters, the package supports many advanced situations, which can be learned from the appropriate documentation.
Some topics of interest to cookiecutter developers to support more advanced use cases include:

- Pre- and post-render hooks.
- Private or hidden variables.
- Public and local Template extentions.
- Using cookiecutters with Python APIs.

## References

- [Cookiecutter](https://www.cookiecutter.io)
- [Cookiecutter Documentation](https://cookiecutter.readthedocs.io/en/stable/)
- [uv](https://docs.astral.sh/uv/)
