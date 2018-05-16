#!/bin/bash

source ../common.sh

LIB_NAME="pastix"
LIB_VERSION=5.2.3
GCC_VERSION=6.4.0
MPI_LIB=openmpi
MPI_VERSION=1.10.7
CMAKE_VERSION=3.9.2

LIB_FULLNAME=${LIB_NAME}-${LIB_VERSION}
LIB_VERSION_SHORT="${LIB_VERSION%.*}"
GCC_FULL=gcc-$GCC_VERSION
GCC_SHORT="gcc${GCC_VERSION//.}"
MPI_FULL=${MPI_LIB}-${MPI_VERSION}
MPI_SHORT="${MPI_LIB}${MPI_VERSION//.}"
SUB_DIR=${LIB_NAME}/${LIB_VERSION}/${GCC_FULL}/${MPI_FULL}
WORK_DIR=${PREWORK_DIR}/${SUB_DIR}
SRC_DIR=${WORK_DIR}/${LIB_FULLNAME}
ARCHIVE=${SRC_DIR}.tar.gz
URL="https://gforge.inria.fr/frs/download.php/file/36212/${pastix}_${LIB_VERSION}.tar.bz2"
INSTALL_DIR=${PREINSTALL_DIR}/${SUB_DIR}
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MODULE_DIR=${PREMODULE_DIR}/libs/${LIB_NAME}
MODULE_PATH=${MODULE_DIR}/${LIB_VERSION}_${GCC_SHORT}_${MPI_SHORT}

install_lib()
{
module purge
module load gcc/${GCC_VERSION}
module load ${MPI_LIB}/${MPI_VERSION}_${GCC_SHORT}

gcc --version |head -n 1
mpirun --version |head -n 1
sleep 2

if [[ ! -f $ARCHIVE ]]; then
  mkdir -p $WORK_DIR
  wget $URL -O $ARCHIVE
fi

if [[ ! -d $SRC_DIR ]]; then
  EXTRACT_DIR=${ARCHIVE%.tar*}
  mkdir -p $EXTRACT_DIR
  tar --extract --file=${ARCHIVE} --strip-components=1 --directory=$EXTRACT_DIR
fi

cd $SCRIPT_DIR

export INSTALL_DIR
envtpl  --keep-template -o $SRC_DIR/src/config.in config.tmpl || exit 1
cd $SRC_DIR/src
make clean || exit 1
make -j || exit 1
#make examples
make -j install || exit 1

}

install_module()
{
cd $SCRIPT_DIR
mkdir -p ${MODULE_DIR}

export LIB_NAME
export LIB_VERSION
export INSTALL_DIR
export GCC_VERSION
export GCC_SHORT
export MPI_LIB
export MPI_VERSION
export MPI_SHORT
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

