#!/bin/bash

source ../common.sh

LIB_NAME="qt"
LIB_VERSION_SHORT=5.6
LIB_VERSION=${LIB_VERSION_SHORT}.2

LIB_FULLNAME=${LIB_NAME}-${LIB_VERSION}
LIB_VERSION_VERYSHORT="${LIB_VERSION_SHORT//.}"
SUB_DIR=${LIB_NAME}/${LIB_VERSION_SHORT}
WORK_DIR=${PREWORK_DIR}/${SUB_DIR}
BUILD_SCRIPT=qt-opensource-linux-x64-${LIB_VERSION}.run
QS_SCRIPT_PREFIX=qt-installer-noninteractive
URL="http://download.qt.io/official_releases/qt/${LIB_VERSION_SHORT}/${LIB_VERSION}/${BUILD_SCRIPT}"
INSTALL_DIR=${PREINSTALL_DIR}/${SUB_DIR}
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MODULE_DIR=${PREMODULE_DIR}/tools/${LIB_NAME}
MODULE_PATH=${MODULE_DIR}/${LIB_VERSION}_${GCC_SHORT}_${MPI_SHORT}

install_lib()
{

if [[ ! -f ${WORK_DIR}/${BUILD_SCRIPT} ]]; then
  mkdir -p $WORK_DIR
  cd $WORK_DIR
  wget $URL
fi

export LIB_VERSION_VERYSHORT
export INSTALL_DIR
envtpl  --keep-template -o ${WORK_DIR}/qt-installer-noninteractive.qs qt-installer-noninteractive.tmpl || exit 1
cd $WORK_DIR
chmod u+x $BUILD_SCRIPT
./$BUILD_SCRIPT --script qt-installer-noninteractive.qs

}

install_module()
{
cd $SCRIPT_DIR
mkdir -p ${MODULE_DIR}

export LIB_NAME
export LIB_VERSION_SHORT
export LIB_VERSION
export INSTALL_DIR
export GCC_VERSION
export GCC_VERSION_SHORT
export MPI_LIB
export MPI_VERSION
envtpl  --keep-template -o $MODULE_PATH module.tmpl
}

if [[ $1 == "module" ]]
then
  install_module
else
  install_lib
#  install_module
fi

