#!/bin/bash

set -x 
LIB_NAME="AMD-APP-SDK"
LIB_VERSION=3.0.130.136

SUB_DIR=${LIB_NAME}/${LIB_VERSION}
SRC_DIR=/data/software/sources/${LIB_NAME}
TARBALL="${LIB_NAME}Installer-v${LIB_VERSION}-GA-linux64.tar.bz2"
INSTALL_SCRIPT="${LIB_NAME}-v${LIB_VERSION}-GA-linux64.sh"
TARGET_DIR=/data/software/install/${SUB_DIR}
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
INSTALL_DIR=${TARGET_DIR}/AMDAPPSDK-3.0
MODULE_DIR=/data/software/modules/libs/${LIB_NAME}
MODULE_PATH=${MODULE_DIR}/${LIB_VERSION}


if [[ -d $SRC_DIR ]]; then
  cd $SRC_DIR
  if [[ ! -f $INSTALL_SCRIPT ]]; then
    tar xvjf $TARBALL || exit 1
  fi
  ./$INSTALL_SCRIPT --nox11
else
  echo "Source dir $SRC_DIR does not exist."
  exit 1
fi


cd $SCRIPT_DIR
mkdir -p $MODULE_DIR

export INSTALL_DIR
envtpl  --keep-template -o $MODULE_PATH module.tmpl
