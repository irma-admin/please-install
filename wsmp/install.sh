#!/bin/bash

source ../common.sh

LIB_NAME="wsmp"
LIB_VERSION=17.07.01

LIB_FULLNAME=${LIB_NAME}-${LIB_VERSION}
LIB_VERSION_SHORT="${LIB_VERSION%.*}"
SUB_DIR=${LIB_NAME}/${LIB_VERSION}
WORK_DIR=${PREWORK_DIR}/${SUB_DIR}
SRC_DIR=${WORK_DIR}/${LIB_FULLNAME}
ARCHIVE=${SRC_DIR}.tar.gz
URL="http://researcher.watson.ibm.com/researcher/files/us-anshul/wsmp-Linux64-GNU-mt.tar.gz"
INSTALL_DIR=${PREINSTALL_DIR}/${SUB_DIR}
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MODULE_DIR=${PREMODULE_DIR}/libs/${LIB_NAME}
MODULE_PATH=${MODULE_DIR}/${LIB_VERSION}

install_lib()
{
if [[ ! -f $ARCHIVE ]]; then
  mkdir -p $WORK_DIR
  wget $URL -O $ARCHIVE
fi

if [[ ! -d $SRC_DIR ]]; then
  EXTRACT_DIR=${INSTALL_DIR}
  mkdir -p $EXTRACT_DIR
  tar --extract --file=${ARCHIVE} --strip-components=1 --directory=$EXTRACT_DIR
fi
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
  if [[ -d $SRC_DIR ]]
  then
    rm -rf $SRC_DIR
  else
    echo "$SRC_DIR does not exist"
    exit 1
  fi
else
  install_lib
  install_module
fi

