#!/bin/bash

source ../common.sh

################################################################################
# GENERIC: Base directory for source, install, build.
SOURCE_BASE_DIR=${PREWORK_DIR}
BUILD_BASE_DIR=${PREWORK_DIR}
INSTALL_BASE_DIR=${PREINSTALL_DIR}
MODULE_BASE_DIR=${PREMODULE_DIR}
################################################################################
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

LIB_NAME="sympy"
LIB_VERSION=1.1.1
PYTHON_VERSION=3.0.0

LIB_VERSION_MAJOR=`echo "${LIB_VERSION}" | sed 's/\([0-9]\)[.][0-9][.][0-9]/\1/g'`
LIB_VERSION_MINOR=`echo "${LIB_VERSION}" | sed 's/[0-9][.]\([0-9]\)[.][0-9]/\1/g'`
LIB_VERSION_PATCH=`echo "${LIB_VERSION}" | sed 's/[0-9][.][0-9][.]\([0-9]\)/\1/g'`
PYTHON_VERSION_MAJOR=`echo "${PYTHON_VERSION}" | sed 's/\([0-9]\)[.][0-9][.][0-9]/\1/g'`
PYTHON_VERSION_MINOR=`echo "${PYTHON_VERSION}" | sed 's/[0-9][.]\([0-9]\)[.][0-9]/\1/g'`
PYTHON_VERSION_PATCH=`echo "${PYTHON_VERSION}" | sed 's/[0-9][.][0-9][.]\([0-9]\)/\1/g'`

DEPEND_PYTHON=python-${PYTHON_VERSION_MAJOR}
DEPEND_MODULE_PYTHON=python${PYTHON_VERSION_MAJOR}

SOURCE_DIR=${SOURCE_BASE_DIR}/${LIB_NAME}/${LIB_VERSION}/${DEPEND_PYTHON}
BUILD_DIR=${BUILD_BASE_DIR}/${LIB_NAME}/${LIB_VERSION}/${DEPEND_PYTHON}/build
INSTALL_DIR=${INSTALL_BASE_DIR}/${LIB_NAME}/${LIB_VERSION}/${DEPEND_PYTHON}
MODULE_DIR=${MODULE_BASE_DIR}/libs/${LIB_NAME}
MODULE_PATH=${MODULE_DIR}/${LIB_VERSION}_${DEPEND_MODULE_PYTHON}

install_lib()
{
    pip3 install \
    --src ${SOURCE_DIR} \
    --target ${INSTALL_DIR} \
    "${LIB_NAME}==${LIB_VERSION}"
}

install_module()
{
    cd $SCRIPT_DIR
    mkdir -p ${MODULE_DIR}

    export LIB_NAME
    export LIB_VERSION
    export INSTALL_DIR
    envtpl  --keep-template -o $MODULE_PATH module.tmpl
}

if [[ $1 == "module" ]]
then
    install_module
else
    install_lib
    install_module
fi
