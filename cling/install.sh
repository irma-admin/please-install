#!/bin/bash

source ../common.sh

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

LIB_NAME="cling"
LIB_VERSION=0.4.0
GCC_VERSION=6.4.0
CMAKE_VERSION=3.9.2

# Use cern repository! (patched version)
LLVM_REPOSITORY=http://root.cern.ch/git/llvm.git
CLING_REPOSITORY=http://root.cern.ch/git/cling.git
CLANG_REPOSITORY=http://root.cern.ch/git/clang.git

LIB_VERSION_MAJOR=`echo "${LIB_VERSION}" | sed 's/\([0-9]\)[.][0-9][.][0-9]/\1/g'`
LIB_VERSION_MINOR=`echo "${LIB_VERSION}" | sed 's/[0-9][.]\([0-9]\)[.][0-9]/\1/g'`
LIB_VERSION_PATCH=`echo "${LIB_VERSION}" | sed 's/[0-9][.][0-9][.]\([0-9]\)/\1/g'`
GCC_VERSION_MAJOR=`echo "${GCC_VERSION}" | sed 's/\([0-9]\)[.][0-9][.][0-9]/\1/g'`
GCC_VERSION_MINOR=`echo "${GCC_VERSION}" | sed 's/[0-9][.]\([0-9]\)[.][0-9]/\1/g'`
GCC_VERSION_PATCH=`echo "${GCC_VERSION}" | sed 's/[0-9][.][0-9][.]\([0-9]\)/\1/g'`


DEPEND_GCC=gcc-${GCC_VERSION_MAJOR}${GCC_VERSION_MINOR}${GCC_VERSION_PATCH}
DEPEND_MODULE_GCC=gcc${GCC_VERSION_MAJOR}${GCC_VERSION_MINOR}${GCC_VERSION_PATCH}

SOURCE_DIR=${PREWORK_DIR}/${LIB_NAME}/${LIB_VERSION}/${DEPEND_GCC}
BUILD_DIR=${PREBUILD_DIR}/${LIB_NAME}/${LIB_VERSION}/${DEPEND_GCC}/build
INSTALL_DIR=${PREINSTALL_DIR}/${LIB_NAME}/${LIB_VERSION}/${DEPEND_GCC}
MODULE_DIR=${PREMODULE_DIR}/compilers/${LIB_NAME}
MODULE_PATH=${MODULE_DIR}/${LIB_VERSION}_${DEPEND_MODULE_GCC}


prepare_lib()
{
    # Prepare directories.
    mkdir -p ${SOURCE_DIR}
    cd ${SOURCE_DIR}
    if [[ ! -d ${SOURCE_DIR}/llvm ]]; then
        echo "-- Cloning repositories in ${SOURCE_DIR}/"
        #--------------------------------------------------
        # Get LLVM
        git clone ${LLVM_REPOSITORY}
        cd llvm
        #git checkout cling-patches
        git checkout tags/cling-v${LIB_VERSION_MAJOR}.${LIB_VERSION_MINOR}
        cd tools
        #--------------------------------------------------
        # Get cling
        git clone ${CLING_REPOSITORY}
        cd cling
        git checkout tags/v${LIB_VERSION_MAJOR}.${LIB_VERSION_MINOR}
        cd ..
        #--------------------------------------------------
        # Get clang
        git clone ${CLANG_REPOSITORY}
        #git clone https://github.com/llvm-mirror/lld.git
        cd clang
        git checkout tags/cling-v${LIB_VERSION_MAJOR}.${LIB_VERSION_MINOR}
        cd ..
    else
        echo "[WARNING] Repo exist ignore clone! (${SOURCE_DIR}/llvm)"
    fi
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
    module load cmake/${CMAKE_VERSION}_${GCC_VERSION_MAJOR}${GCC_VERSION_MINOR}${GCC_VERSION_PATCH}
    module list

    # Check gcc version here
    gcc --version |head -n 1
    sleep 2

    cmake -DCMAKE_C_COMPILER=`which gcc` \
        -DCMAKE_CXX_COMPILER=`which g++` \
        -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR}/ \
        -DPYTHON_EXECUTABLE=`which python` \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=ON \
        -LLVM_TOOL_LLD_BUILD=ON \
    ${SOURCE_DIR}/llvm

    cmake --build . -- -j
}

install_lib()
{
    cmake --build . --target install
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
elif [[ $1 == "clean" ]]
then
  clean_all
else
    prepare_lib
    build_lib
    install_lib
    install_module
fi
