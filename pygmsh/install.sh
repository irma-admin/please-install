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

LIB_NAME="pygmsh"
LIB_VERSION=4.0.3
PYTHON3_VERSION=3.0.0
PYTHON2_VERSION=2.7.0
#GMSH_VERSION=2.16.0
#GCC_VERSION=6.4.0

LIB_VERSION_MAJOR=`echo "${LIB_VERSION}" | sed 's/\([0-9]\)[.][0-9][.][0-9]/\1/g'`
LIB_VERSION_MINOR=`echo "${LIB_VERSION}" | sed 's/[0-9][.]\([0-9]\)[.][0-9]/\1/g'`
LIB_VERSION_PATCH=`echo "${LIB_VERSION}" | sed 's/[0-9][.][0-9][.]\([0-9]\)/\1/g'`
PYTHON3_VERSION_MAJOR=`echo "${PYTHON3_VERSION}" | sed 's/\([0-9]\)[.][0-9][.][0-9]/\1/g'`
PYTHON3_VERSION_MINOR=`echo "${PYTHON3_VERSION}" | sed 's/[0-9][.]\([0-9]\)[.][0-9]/\1/g'`
PYTHON3_VERSION_PATCH=`echo "${PYTHON3_VERSION}" | sed 's/[0-9][.][0-9][.]\([0-9]\)/\1/g'`
PYTHON2_VERSION_MAJOR=`echo "${PYTHON2_VERSION}" | sed 's/\([0-9]\)[.][0-9][.][0-9]/\1/g'`
PYTHON2_VERSION_MINOR=`echo "${PYTHON2_VERSION}" | sed 's/[0-9][.]\([0-9]\)[.][0-9]/\1/g'`
PYTHON2_VERSION_PATCH=`echo "${PYTHON2_VERSION}" | sed 's/[0-9][.][0-9][.]\([0-9]\)/\1/g'`

DEPEND_PYTHON3=python-${PYTHON3_VERSION_MAJOR}
DEPEND_MODULE_PYTHON3=python${PYTHON3_VERSION_MAJOR}
DEPEND_PYTHON2=python-${PYTHON2_VERSION_MAJOR}
DEPEND_MODULE_PYTHON2=python${PYTHON2_VERSION_MAJOR}
#DEPEND_GMSH=gmsh-${GMSH_VERSION}
#DEPEND_MODULE_GMSH=gmsh-${PYTHON_VERSION_MAJOR}

PYTHON2_SOURCE_DIR=${SOURCE_BASE_DIR}/${LIB_NAME}/${LIB_VERSION}/${DEPEND_PYTHON2}
#PYTHON2_BUILD_DIR=${BUILD_BASE_DIR}/${LIB_NAME}/${LIB_VERSION}/${DEPEND_PYTHON2}/build
PYTHON2_INSTALL_DIR=${INSTALL_BASE_DIR}/${LIB_NAME}/${LIB_VERSION}/${DEPEND_PYTHON2}
PYTHON3_SOURCE_DIR=${SOURCE_BASE_DIR}/${LIB_NAME}/${LIB_VERSION}/${DEPEND_PYTHON3}
#PYTHON3_BUILD_DIR=${BUILD_BASE_DIR}/${LIB_NAME}/${LIB_VERSION}/${DEPEND_PYTHON3}/build
PYTHON3_INSTALL_DIR=${INSTALL_BASE_DIR}/${LIB_NAME}/${LIB_VERSION}/${DEPEND_PYTHON3}

MODULE_DIR=${MODULE_BASE_DIR}/libs/${LIB_NAME}
PYTHON2_MODULE_PATH=${MODULE_DIR}/${LIB_VERSION}_${DEPEND_MODULE_PYTHON2}
PYTHON3_MODULE_PATH=${MODULE_DIR}/${LIB_VERSION}_${DEPEND_MODULE_PYTHON3}

install_lib()
{
    pip3 install \
    --src ${PYTHON3_SOURCE_DIR} \
    --target ${PYTHON3_INSTALL_DIR} \
    "${LIB_NAME}==${LIB_VERSION}"
    pip2.7 install \
    --src ${PYTHON2_SOURCE_DIR} \
    --target ${PYTHON2_INSTALL_DIR} \
    "${LIB_NAME}==${LIB_VERSION}"
}

install_module()
{
    cd $SCRIPT_DIR
    mkdir -p ${MODULE_DIR}

    export LIB_NAME
    export LIB_VERSION
    INSTALL_DIR=$PYTHON2_INSTALL_DIR
    export INSTALL_DIR
    envtpl  --keep-template -o $PYTHON2_MODULE_PATH module.tmpl
    INSTALL_DIR=$PYTHON3_INSTALL_DIR
    export INSTALL_DIR
    envtpl  --keep-template -o $PYTHON3_MODULE_PATH module.tmpl
}

if [[ $1 == "module" ]]
then
    install_module
elif [[ $1 == "clean" ]]
then
  clean_all
else
    install_lib
    install_module
fi
