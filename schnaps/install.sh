#!/bin/bash

source ../common.sh

LIB_NAME="schnaps.profile"
GCC_VERSION=6.4.0
MPI_LIB=openmpi
MPI_VERSION=1.10.7

GCC_FULL=gcc-$GCC_VERSION
GCC_SHORT="gcc${GCC_VERSION//.}"
MPI_FULL=${MPI_LIB}-${MPI_VERSION}
MPI_SHORT="${MPI_LIB}${MPI_VERSION//.}"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MODULE_DIR=${BASE_MODULE_DIR}/profiles
MODULE_PATH=${MODULE_DIR}/${LIB_NAME}

install_module()
{
cd $SCRIPT_DIR
mkdir -p ${MODULE_DIR}

export GCC_VERSION
export GCC_SHORT
export MPI_LIB
export MPI_SHORT
export MPI_VERSION
export LIB_NAME

envtpl  --keep-template -o $MODULE_PATH module.tmpl
}

install_module

