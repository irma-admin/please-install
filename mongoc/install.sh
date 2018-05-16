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

LIB_NAME="mongoc"
LIB_VERSION=1.9.4
GCC_VERSION=6.4.0

MONGOC_URL=https://github.com/mongodb/mongo-c-driver/releases/download/${LIB_VERSION}/mongo-c-driver-${LIB_VERSION}.tar.gz

# Use cern repository! (patched version)
LIB_VERSION_MAJOR=`echo "${LIB_VERSION}" | sed 's/\([0-9]\)[.][0-9][.][0-9]/\1/g'`
LIB_VERSION_MINOR=`echo "${LIB_VERSION}" | sed 's/[0-9][.]\([0-9]\)[.][0-9]/\1/g'`
LIB_VERSION_PATCH=`echo "${LIB_VERSION}" | sed 's/[0-9][.][0-9][.]\([0-9]\)/\1/g'`
GCC_VERSION_MAJOR=`echo "${GCC_VERSION}" | sed 's/\([0-9]\)[.][0-9][.][0-9]/\1/g'`
GCC_VERSION_MINOR=`echo "${GCC_VERSION}" | sed 's/[0-9][.]\([0-9]\)[.][0-9]/\1/g'`
GCC_VERSION_PATCH=`echo "${GCC_VERSION}" | sed 's/[0-9][.][0-9][.]\([0-9]\)/\1/g'`


DEPEND_GCC=gcc-${GCC_VERSION_MAJOR}${GCC_VERSION_MINOR}${GCC_VERSION_PATCH}
DEPEND_MODULE_GCC=gcc${GCC_VERSION_MAJOR}${GCC_VERSION_MINOR}${GCC_VERSION_PATCH}

SOURCE_DIR=${SOURCE_BASE_DIR}/${LIB_NAME}/${LIB_VERSION}/${DEPEND_GCC}
BUILD_DIR=${BUILD_BASE_DIR}/${LIB_NAME}/${LIB_VERSION}/${DEPEND_GCC}/build
INSTALL_DIR=${INSTALL_BASE_DIR}/${LIB_NAME}/${LIB_VERSION}/${DEPEND_GCC}
MODULE_DIR=${MODULE_BASE_DIR}/libs/${LIB_NAME}
MODULE_PATH=${MODULE_DIR}/${LIB_VERSION}_${DEPEND_MODULE_GCC}

prepare_lib()
{
    # Prepare directories.
    mkdir -p ${SOURCE_DIR}
    cd ${SOURCE_DIR}
    if [[ ! -d ${SOURCE_DIR}/singularity ]]; then
        echo "-- Cloning repositories in ${SOURCE_DIR}/"
        #--------------------------------------------------
        # Get LLVM
        wget ${MONGOC_URL}
        tar -xvf mongo-c-driver-${LIB_VERSION}.tar.gz
    else
        echo "[WARNING] Build directory exist ignore clone! (${SOURCE_DIR}/mongoc)"
        exit 1
    fi
    cd mongo-c-driver-${LIB_VERSION}
}

build_lib() {
    echo "-- Building ${LIB_NAME}-${LIB_VERSION}"

    if [[ ! -d ${BUILD_DIR} ]]; then
        mkdir -p ${BUILD_DIR}
    else
        echo "[WARNING] Build directory exist! Remove it first ! ${BUILD_DIR}"
        exit 1
    fi
    module purge
    module load gcc/${GCC_VERSION}
    module list

    # Check gcc version here
    gcc --version |head -n 1
    sleep 2

    ./configure --prefix=${INSTALL_DIR}
    make
}

install_lib()
{
    make install
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
    prepare_lib
    build_lib
    install_lib
    install_module
fi
