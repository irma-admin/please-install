#!/bin/bash

set -x

# You may tune this section
SOFT_DIR="/data/software"
BASE_WORK_DIR=${SOFT_DIR}/sources
BASE_INSTALL_DIR=${SOFT_DIR}/install
BASE_MODULE_DIR=${SOFT_DIR}/modules
###

mkdir -p $BASE_WORK_DIR
mkdir -p $BASE_INSTALL_DIR
mkdir -p $BASE_MODULE_DIR

clean_dir()
{
if [[ -d $1 ]]
then
  rm -rf $1
else
  echo "WARNING: $1 does not exist"
fi
}

clean_all()
{
  clean_dir $SRC_DIR
  clean_dir $BUILD_DIR
}
