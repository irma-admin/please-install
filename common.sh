#!/bin/bash

set -x

# You may tune this section
#SOFT_DIR="/data/software"
SOFT_DIR="/Users/boileau/software"
PREWORK_DIR=${SOFT_DIR}/sources
PREINSTALL_DIR=${SOFT_DIR}/install
PREMODULE_DIR=${SOFT_DIR}/modules
###

mkdir -p $PREWORK_DIR
mkdir -p $PREINSTALL_DIR
mkdir -p $PREMODULE_DIR

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
