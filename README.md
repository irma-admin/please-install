# Installation

Requires only `envtpl` for module file templating:

```
pip install envtpl
```

# Usage

Each directory corresponds to a library/application installation.
It contains 2 files:

- `module.tmpl`, a module file templated with Jinja2
- `install.sh`, a bash script to be run:
	- without argument, it downloads/compiles/installs the library + module file
	- with `./install.sh clean`: removes the building directory
	- with `./install.sh module`: install only the module file