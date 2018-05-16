# Overview

This a set of example bash scripts designed to perform repeatable and cumulative installations on a HPC cluster where library versions are handled by [environment modules](http://modules.sourceforge.net/).

Two assumptions:

- libraries are installed in a shared partition
- module files are named according to the following scheme: `{library_version}_{compiler_version}_{main_dependency_version}`

Example of resulting module organization:

```bash
tree modules/tools/
modules/tools/
├── cmake
│   └── 3.9.2_gcc640
├── paraview
│   ├── 5.3.0_gcc640_openmpi1107
│   ├── 5.3.0_gcc640_openmpi211
│   ├── 5.4.1_gcc640_openmpi1107
│   ├── 5.4.1_gcc640_openmpi211
│   └── 5.4.1-py3_gcc640_openmpi1107
└── singularity
    └── 2.4.0_gcc640
```

and corresponding installation directories (here for `paraview`):

```bash
tree -L 3 install/paraview/
install/paraview/
├── 5.3.0
│   └── gcc-6.4.0
│       ├── openmpi-1.10.7
│       └── openmpi-2.1.1
├── 5.4.1
│   └── gcc-6.4.0
│       ├── openmpi-1.10.7
│       └── openmpi-2.1.1
└── 5.4.1-py3
    └── gcc-6.4.0
        └── openmpi-1.10.7
```


# Installation

## Dependencies

Requires only `bash` for execution and `envtpl` for module file templating:

```
pip install envtpl
```

## Configuration

Set your custom paths in `common.sh` for the 3 directories:

```bash
PREWORK_DIR=${SOFT_DIR}/sources  # sources download and compilation top directory
PREINSTALL_DIR=${SOFT_DIR}/install  # libraries installation top directory
PREMODULE_DIR=${SOFT_DIR}/modules  # modulefiles top directory
```

These directories will be created if they don't exist.

# Usage

Each sub directory of this project corresponds to a library (or application) installation.
For most cases, it contains 2 files:

- `module.tmpl`, a module file templated with Jinja2
- `install.sh`, a bash script to be run:
	- `./install.sh` without argument
		1. download && compile && install the library
		2. build && install the module file
	- `./install.sh clean`: remove the temporary directories used for download and compilation
	- `./install.sh module`: build && install only the module file

## Create a new library installation

- Copy an existing directory and adapt the `install.sh` and `module.tmpl` files.
- From this directory, run:

```bash
./install.sh
```

## Install a new version of an existing library

- `install.sh`: the only parameters values that may be changed are located at the top of the file.
For example for [paraview/install.sh](paraview/install.sh):

```bash
LIB_NAME="paraview"  # unchanged
LIB_VERSION_URL=5.4.1
LIB_VERSION=${LIB_VERSION_URL}-py3
GCC_VERSION=6.4.0
MPI_LIB=openmpi
MPI_VERSION=1.10.7
HDF5_VERSION=1.10.1
CMAKE_VERSION=3.9.2
```

- `module.tmpl` remains unchanged.
- Run again:

```
./install.sh
```
