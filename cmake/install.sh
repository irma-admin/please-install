#!/bin/bash

source ../common.sh

LIB_NAME="cmake"
LIB_VERSION=3.9.2
GCC_VERSION=6.4.0

LIB_FULLNAME=${LIB_NAME}-${LIB_VERSION}
LIB_VERSION_SHORT="${LIB_VERSION%.*}"
GCC_FULL=gcc-$GCC_VERSION
GCC_SHORT="gcc${GCC_VERSION//.}"
SUB_DIR=${LIB_NAME}/${LIB_VERSION}/${GCC_FULL}
WORK_DIR=${PREWORK_DIR}/${SUB_DIR}
SRC_DIR=${WORK_DIR}/${LIB_FULLNAME}
ARCHIVE=${SRC_DIR}.tar.gz
URL="https://cmake.org/files/v${LIB_VERSION_SHORT}/${LIB_FULLNAME}.tar.gz"
BUILD_DIR=${WORK_DIR}/${LIB_FULLNAME}-build
INSTALL_DIR=${PREINSTALL_DIR}/${SUB_DIR}
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MODULE_DIR=${PREMODULE_DIR}/tools/${LIB_NAME}
MODULE_PATH=${MODULE_DIR}/${LIB_VERSION}_${GCC_SHORT}

install_lib()
{
module purge
module load gcc/${GCC_VERSION}

gcc --version |head -n 1
sleep 2

if [[ ! -f $ARCHIVE ]]; then
  mkdir -p $WORK_DIR
  wget $URL -O $ARCHIVE
fi

if [[ ! -d $SRC_DIR ]]; then
  tar zxf $ARCHIVE --directory $WORK_DIR
fi

if [[ ! -d $BUILD_DIR ]]; then
  mkdir $BUILD_DIR
  cd $BUILD_DIR

  ${SRC_DIR}/configure \
  --prefix=${INSTALL_DIR} || exit 1
fi

cd $BUILD_DIR
make -j || exit 1
make -j install || exit 1
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
  install_lib
  install_module
fi

