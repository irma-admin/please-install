#!/bin/bash

source ../common.sh

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

LIB_NAME="pyfmi"
LIB_VERSION=2.4.0
PYTHON3_VERSION=3.0.0
PYTHON2_VERSION=2.7.0
FMILIB_VERSION=2.0.3
GCC_VERSION=6.4.0
#GMSH_VERSION=2.16.0

LIB_VERSION_MAJOR=`echo "${LIB_VERSION}" | sed 's/\([0-9]\)[.][0-9][.][0-9]/\1/g'`
LIB_VERSION_MINOR=`echo "${LIB_VERSION}" | sed 's/[0-9][.]\([0-9]\)[.][0-9]/\1/g'`
LIB_VERSION_PATCH=`echo "${LIB_VERSION}" | sed 's/[0-9][.][0-9][.]\([0-9]\)/\1/g'`
PYTHON3_VERSION_MAJOR=`echo "${PYTHON3_VERSION}" | sed 's/\([0-9]\)[.][0-9][.][0-9]/\1/g'`
PYTHON3_VERSION_MINOR=`echo "${PYTHON3_VERSION}" | sed 's/[0-9][.]\([0-9]\)[.][0-9]/\1/g'`
PYTHON3_VERSION_PATCH=`echo "${PYTHON3_VERSION}" | sed 's/[0-9][.][0-9][.]\([0-9]\)/\1/g'`
PYTHON2_VERSION_MAJOR=`echo "${PYTHON2_VERSION}" | sed 's/\([0-9]\)[.][0-9][.][0-9]/\1/g'`
PYTHON2_VERSION_MINOR=`echo "${PYTHON2_VERSION}" | sed 's/[0-9][.]\([0-9]\)[.][0-9]/\1/g'`
PYTHON2_VERSION_PATCH=`echo "${PYTHON2_VERSION}" | sed 's/[0-9][.][0-9][.]\([0-9]\)/\1/g'`
FMILIB_VERSION_MAJOR=`echo "${FMILIB_VERSION}" | sed 's/\([0-9]\)[.][0-9][.][0-9]/\1/g'`
FMILIB_VERSION_MINOR=`echo "${FMILIB_VERSION}" | sed 's/[0-9][.]\([0-9]\)[.][0-9]/\1/g'`
FMILIB_VERSION_PATCH=`echo "${FMILIB_VERSION}" | sed 's/[0-9][.][0-9][.]\([0-9]\)/\1/g'`
GCC_VERSION_MAJOR=`echo "${GCC_VERSION}" | sed 's/\([0-9]\)[.][0-9][.][0-9]/\1/g'`
GCC_VERSION_MINOR=`echo "${GCC_VERSION}" | sed 's/[0-9][.]\([0-9]\)[.][0-9]/\1/g'`
GCC_VERSION_PATCH=`echo "${GCC_VERSION}" | sed 's/[0-9][.][0-9][.]\([0-9]\)/\1/g'`

DEPEND_PYTHON3=python-${PYTHON3_VERSION_MAJOR}
DEPEND_MODULE_PYTHON3=python${PYTHON3_VERSION_MAJOR}
DEPEND_PYTHON2=python-${PYTHON2_VERSION_MAJOR}
DEPEND_MODULE_PYTHON2=python${PYTHON2_VERSION_MAJOR}
DEPEND_FMILIB=fmilib-${FMILIB_VERSION}
DEPEND_MODULE_FMILIB=fmilib${FMILIB_VERSION_MAJOR}${FMILIB_VERSION_MINOR}${FMILIB_VERSION_PATCH}_gcc${GCC_VERSION_MAJOR}${GCC_VERSION_MINOR}${GCC_VERSION_PATCH}
#DEPEND_GMSH=gmsh-${GMSH_VERSION}
#DEPEND_MODULE_GMSH=gmsh-${PYTHON_VERSION_MAJOR}

PYTHON2_SOURCE_DIR=${PREWORK_DIR}/${LIB_NAME}/${LIB_VERSION}/${DEPEND_PYTHON2}/${DEPEND_FMILIB}
#PYTHON2_BUILD_DIR=${PREWORK_DIR}/${LIB_NAME}/${LIB_VERSION}/${DEPEND_PYTHON2}/build
PYTHON2_INSTALL_DIR=${PREINSTALL_DIR}/${LIB_NAME}/${LIB_VERSION}/${DEPEND_PYTHON2}/${DEPEND_FMILIB}
PYTHON3_SOURCE_DIR=${PREWORK_DIR}/${LIB_NAME}/${LIB_VERSION}/${DEPEND_PYTHON3}/${DEPEND_FMILIB}
#PYTHON3_BUILD_DIR=${PREWORK_DIR}/${LIB_NAME}/${LIB_VERSION}/${DEPEND_PYTHON3}/build
PYTHON3_INSTALL_DIR=${PREINSTALL_DIR}/${LIB_NAME}/${LIB_VERSION}/${DEPEND_PYTHON3}/${DEPEND_FMILIB}

MODULE_DIR=${PREMODULE_DIR}/libs/${LIB_NAME}
PYTHON2_MODULE_PATH=${MODULE_DIR}/${LIB_VERSION}_${DEPEND_MODULE_PYTHON2}_${DEPEND_MODULE_FMILIB}
PYTHON3_MODULE_PATH=${MODULE_DIR}/${LIB_VERSION}_${DEPEND_MODULE_PYTHON3}_${DEPEND_MODULE_FMILIB}

install_lib()
{
FILE_TO_SOURCE=/etc/profile.d/modules.sh
if [[ -f "${FILE_TO_SOURCE}" ]]; then
    source ${FILE_TO_SOURCE}
else
    echo "File to source (${FILE_TO_SOURCE}) does not exist"
fi
    module purge
    module load gcc/${GCC_VERSION}
    module load fmilib/${FMILIB_VERSION}_gcc${GCC_VERSION_MAJOR}${GCC_VERSION_MINOR}${GCC_VERSION_PATCH}
    module list

    pip3 install \
    --upgrade \
    --force-reinstall \
    --src ${PYTHON3_SOURCE_DIR} \
    --target ${PYTHON3_INSTALL_DIR} \
    "${LIB_NAME}==${LIB_VERSION}"
    pip2.7 install \
    --upgrade \
    --force-reinstall \
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
