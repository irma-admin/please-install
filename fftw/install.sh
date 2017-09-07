#!/bin/bash

set -x 
LIB_NAME="fftw"
LIB_VERSION=3.3.6
GCC_VERSION=6.4.0
MPI_LIB=openmpi
MPI_VERSION=2.1.1

LIB_FULLNAME=${LIB_NAME}-${LIB_VERSION}
GCC_FULL=gcc-$GCC_VERSION
GCC_SHORT="gcc${GCC_VERSION//.}"
MPI_FULL=${MPI_LIB}-${MPI_VERSION}
MPI_SHORT="${MPI_LIB}${MPI_VERSION//.}"
SUB_DIR=${LIB_NAME}/${LIB_VERSION}/${GCC_FULL}/${MPI_FULL}
WORK_DIR=/data/software/sources/${SUB_DIR}
SRC_DIR=${WORK_DIR}/${LIB_FULLNAME}-pl2
ARCHIVE=${SRC_DIR}.tar.gz
URL="http://www.fftw.org/${LIB_FULLNAME}-pl2.tar.gz"
#URL="http://75.98.172.202/${LIB_FULLNAME}-pl2.tar.gz"
BUILD_DIR=${WORK_DIR}/${LIB_FULLNAME}-build
INSTALL_DIR=/data/software/install/${SUB_DIR}
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MODULE_DIR=/data/software/modules/libs/${LIB_NAME}
MODULE_PATH=${MODULE_DIR}/${LIB_VERSION}_${GCC_SHORT}_${MPI_SHORT}

module purge
module load gcc/${GCC_VERSION}
module load ${MPI_LIB}/${MPI_VERSION}_${GCC_SHORT}

gcc --version
sleep 2
mpirun --version
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
  --prefix=${INSTALL_DIR} \
  --enable-mpi \
  --enable-shared
fi

cd $BUILD_DIR
make -j || exit 1
make -j install || exit 1

cd $SCRIPT_DIR
mkdir -p ${MODULE_DIR}

export LIB_NAME
export LIB_VERSION
export INSTALL_DIR
envtpl  --keep-template -o $MODULE_PATH module.tmpl
