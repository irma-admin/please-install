#!/bin/bash

source ../common.sh

LIB_NAME="armadillo"
LIB_VERSION=8.200.2

LIB_FULLNAME=${LIB_NAME}-${LIB_VERSION}
LIB_VERSION_SHORT="${LIB_VERSION%.*}"
SUB_DIR=${LIB_NAME}/${LIB_VERSION}
WORK_DIR=${BASE_WORK_DIR}/${SUB_DIR}
SRC_DIR=${WORK_DIR}/${LIB_FULLNAME}
ARCHIVE=${SRC_DIR}.tar.xz
URL="https://downloads.sourceforge.net/project/arma/armadillo-${LIB_VERSION}.tar.xz?r=http%3A%2F%2Farma.sourceforge.net%2Fdownload.html&ts=1510843687&use_mirror=freefr"
BUILD_DIR=${WORK_DIR}/${LIB_FULLNAME}-build
INSTALL_DIR=${BASE_INSTALL_DIR}/${SUB_DIR}
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MODULE_DIR=${BASE_MODULE_DIR}/libs/${LIB_NAME}
MODULE_PATH=${MODULE_DIR}/${LIB_VERSION}


install_lib()
{
module purge
module load superlu

gcc --version |head -n 1
sleep 2

if [[ ! -f $ARCHIVE ]]; then
  mkdir -p $WORK_DIR
  wget $URL -O $ARCHIVE || exit 1
fi

if [[ ! -d $SRC_DIR ]]; then
  EXTRACT_DIR=${ARCHIVE%.tar*}
  mkdir -p $EXTRACT_DIR
  tar --extract --file=${ARCHIVE} --strip-components=1 --directory=$EXTRACT_DIR
fi

if [[ ! -d $BUILD_DIR ]]; then
  mkdir $BUILD_DIR
  cd $BUILD_DIR
  CXX_FLAGS=-fPIC cmake $SRC_DIR \
  -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR || exit 1
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
export LIB_VERSION_SHORT
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

