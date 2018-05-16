#!/bin/bash

source ../common.sh

LIB_NAME="nvidia-display"
LIB_VERSION=384.69

LIB_FULLNAME=${LIB_NAME}-${LIB_VERSION}
SUB_DIR=${LIB_NAME}/${LIB_VERSION}
WORK_DIR=${BASE_WORK_DIR}/${SUB_DIR}
BUILD_SCRIPT=NVIDIA-Linux-x86_64-${LIB_VERSION}.run
URL="http://us.download.nvidia.com/XFree86/Linux-x86_64/${LIB_VERSION}/${BUILD_SCRIPT}"
INSTALL_DIR=${BASE_INSTALL_DIR}/${SUB_DIR}
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MODULE_DIR=${BASE_MODULE_DIR}/tools/${LIB_NAME}
MODULE_PATH=${MODULE_DIR}/${LIB_VERSION}_${GCC_SHORT}_${MPI_SHORT}

install_lib()
{

if [[ ! -f ${WORK_DIR}/${BUILD_SCRIPT} ]]; then
  mkdir -p $WORK_DIR
  cd $WORK_DIR
  wget $URL
fi

#export LIB_VERSION_VERYSHORT
#export INSTALL_DIR
#envtpl  --keep-template -o ${WORK_DIR}/qt-installer-noninteractive.qs qt-installer-noninteractive.tmpl || exit 1
cd $WORK_DIR
chmod u+x $BUILD_SCRIPT
#./$BUILD_SCRIPT --script qt-installer-noninteractive.qs

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
elif [[ $1 == "clean" ]]
then
  clean_all
else
  install_lib
#  install_module
fi

