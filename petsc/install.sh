#!/bin/bash

set -x 
LIB_NAME="petsc"
LIB_VERSION=3.8.3 #3.7.6
GCC_VERSION=6.4.0
MPI_LIB=openmpi
MPI_VERSION=1.10.7 #2.1.1 #1.10.7

LIB_FULLNAME=${LIB_NAME}-${LIB_VERSION}
GCC_FULL=gcc-$GCC_VERSION
GCC_SHORT="gcc${GCC_VERSION//.}"
MPI_FULL=${MPI_LIB}-${MPI_VERSION}
MPI_SHORT="${MPI_LIB}${MPI_VERSION//.}"
SUB_DIR=${LIB_NAME}/${LIB_VERSION}/${GCC_FULL}/${MPI_FULL}
WORK_DIR=/data/software/sources/${SUB_DIR}
SRC_DIR=${WORK_DIR}/${LIB_FULLNAME}
ARCHIVE=${SRC_DIR}.tar.gz
URL="http://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-lite-${LIB_VERSION}.tar.gz"
BUILD_DIR=${WORK_DIR}/${LIB_FULLNAME}-build
INSTALL_DIR=/data/software/install/${SUB_DIR}
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MODULE_DIR=/data/software/modules/libs/${LIB_NAME}
MODULE_PATH=${MODULE_DIR}/${LIB_VERSION}_${GCC_SHORT}_${MPI_SHORT}

install_lib()
{
module purge
module load gcc/${GCC_VERSION}
module load ${MPI_LIB}/${MPI_VERSION}_${GCC_SHORT}
module load hdf5/1.10.1_${GCC_SHORT}_${MPI_SHORT}
module list

gcc --version |head -n 1
sleep 2
mpirun --version |head -n 1
sleep 2

if [[ ! -f $ARCHIVE ]]; then
  mkdir -p $WORK_DIR
  wget $URL -O $ARCHIVE
fi

if [[ ! -d $BUILD_DIR ]]; then
  mkdir $BUILD_DIR
  tar zxf $ARCHIVE --directory $BUILD_DIR
fi

cd $BUILD_DIR/petsc-${LIB_VERSION} || exit 1
./configure --with-shared-libraries=1 \
            --prefix=${INSTALL_DIR} \
            --with-cc=`which mpicc` \
            --with-cxx=`which mpic++` \
            --with-fc=`which mpif90` \
            --with-mpiexec=`which mpiexec` \
            --download-suitesparse=1  \
            --download-ml  \
            --download-blacs  \
            --download-scalapack \
            --download-fblaslapack  \
            --download-mumps  \
            --download-hypre  \
            --download-ptscotch \
            --with-hdf5=1 \
            --with-hdf5-dir=$HDF5_ROOT \
            --with-debugging=0 \
            --COPTFLAGS='-O3'  --CXXOPTFLAGS='-O3'  --FOPTFLAGS='-O3' || exit 1
make PETSC_DIR=`pwd` PETSC_ARCH="arch-linux2-c-opt" all || exit 1
make PETSC_DIR=`pwd` PETSC_ARCH="arch-linux2-c-opt" install || exit 1

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
else
  install_lib
  install_module
fi

