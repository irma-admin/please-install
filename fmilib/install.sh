#!/bin/bash
set -x

MODULE_CATEGORY="libs"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

LIB_NAME="fmilib"
LIB_VERSION=2.0.3
GCC_VERSION=6.4.0
CMAKE_VERSION=3.9.2

# Use cern repository! (patched version)
FMIL_URL=http://www.jmodelica.org/downloads/FMIL/FMILibrary-${LIB_VERSION}-src.zip

LIB_VERSION_MAJOR=`echo "${LIB_VERSION}" | sed 's/\([0-9]\)[.][0-9][.][0-9]/\1/g'`
LIB_VERSION_MINOR=`echo "${LIB_VERSION}" | sed 's/[0-9][.]\([0-9]\)[.][0-9]/\1/g'`
LIB_VERSION_PATCH=`echo "${LIB_VERSION}" | sed 's/[0-9][.][0-9][.]\([0-9]\)/\1/g'`
GCC_VERSION_MAJOR=`echo "${GCC_VERSION}" | sed 's/\([0-9]\)[.][0-9][.][0-9]/\1/g'`
GCC_VERSION_MINOR=`echo "${GCC_VERSION}" | sed 's/[0-9][.]\([0-9]\)[.][0-9]/\1/g'`
GCC_VERSION_PATCH=`echo "${GCC_VERSION}" | sed 's/[0-9][.][0-9][.]\([0-9]\)/\1/g'`


DEPEND_GCC=gcc-${GCC_VERSION_MAJOR}${GCC_VERSION_MINOR}${GCC_VERSION_PATCH}
DEPEND_MODULE_GCC=gcc${GCC_VERSION_MAJOR}${GCC_VERSION_MINOR}${GCC_VERSION_PATCH}

SOURCE_DIR=${BASE_WORK_DIR}/${LIB_NAME}/${LIB_VERSION}/${DEPEND_GCC}
BUILD_DIR=${PREBUILD_DIR}/${LIB_NAME}/${LIB_VERSION}/${DEPEND_GCC}/build
INSTALL_DIR=${BASE_INSTALL_DIR}/${LIB_NAME}/${LIB_VERSION}/${DEPEND_GCC}
MODULE_DIR=${BASE_MODULE_DIR}/${MODULE_CATEGORY}/${LIB_NAME}
MODULE_PATH=${MODULE_DIR}/${LIB_VERSION}_${DEPEND_MODULE_GCC}


prepare_lib()
{
    # Prepare directories.
    mkdir -p ${SOURCE_DIR}
    cd ${SOURCE_DIR}
    wget ${FMIL_URL}
    unzip FMILibrary-${LIB_VERSION}-src.zip
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
        -DFMILIB_INSTALL_PREFIX=${INSTALL_DIR}/ \
        -DCMAKE_BUILD_TYPE=Release \
    ${SOURCE_DIR}/FMILibrary-${LIB_VERSION}

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
    export MODULE_CATEGORY
    envtpl  --keep-template -o $MODULE_PATH module.tmpl
}

if [[ $1 == "module" ]]
then
    echo ""
#    install_module
elif [[ $1 == "clean" ]]
then
  clean_all
else
    prepare_lib
    build_lib
    install_lib
    install_module
fi
