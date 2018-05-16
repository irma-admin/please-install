#!/bin/bash

source ../common.sh

LIB_NAME="starpu"
LIB_VERSION="21055"
GCC_VERSION=6.4.0
MPI_LIB=openmpi
MPI_VERSION=1.10.7

LIB_FULLNAME=${LIB_NAME}-r${LIB_VERSION}
GCC_FULL=gcc-$GCC_VERSION
GCC_SHORT="gcc${GCC_VERSION//.}"
MPI_FULL=${MPI_LIB}-${MPI_VERSION}
MPI_SHORT="${MPI_LIB}${MPI_VERSION//.}"
SUB_DIR=${LIB_NAME}/${LIB_VERSION}/${GCC_FULL}/${MPI_FULL}
WORK_DIR=${PREWORK_DIR}/${SUB_DIR}
SRC_DIR=${WORK_DIR}/${LIB_FULLNAME}
ARCHIVE=${SRC_DIR}.tar.gz
URL="svn://scm.gforge.inria.fr/svnroot/starpu/trunk"
BUILD_DIR=${WORK_DIR}/${LIB_FULLNAME}-build
INSTALL_DIR=${PREINSTALL_DIR}/${SUB_DIR}
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MODULE_DIR=${PREMODULE_DIR}/libs/${LIB_NAME}
MODULE_PATH=${MODULE_DIR}/${LIB_VERSION}_${GCC_SHORT}_${MPI_SHORT}

install_lib()
{
module purge
module load gcc/${GCC_VERSION}
module load ${MPI_LIB}/${MPI_VERSION}_${GCC_SHORT}
module load AMD-APP-SDK/3.0.130.136

gcc --version |head -n 1
sleep 2
mpirun --version |head -n 1
sleep 2

if [[ ! -d $SRC_DIR ]]; then
  svn checkout -r $LIB_VERSION $URL $SRC_DIR || exit 1
  cd $SRC_DIR
  ./autogen.sh || exit 1
fi


if [[ ! -d $BUILD_DIR ]]; then
  mkdir $BUILD_DIR
  cd $BUILD_DIR
  ${SRC_DIR}/configure \
  --enable-mpi-check \
  --disable-build-doc \
  --enable-openmp \
  --with-opencl-lib-dir=/data/software/install/AMD-APP-SDK/3.0.130.136/AMDAPPSDK-3.0/ \
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
