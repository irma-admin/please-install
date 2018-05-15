#!/bin/bash

source ../common.sh

LIB_NAME="boost"
LIB_VERSION=1.65.0
LIB_VERSION_DOWNLOAD=1_65_0
GCC_VERSION=6.4.0
MPI_LIB=openmpi
MPI_VERSION=1.10.7 #2.1.1

LIB_FULLNAME=${LIB_NAME}-${LIB_VERSION}
GCC_FULL=gcc-$GCC_VERSION
GCC_SHORT="gcc${GCC_VERSION//.}"
MPI_FULL=${MPI_LIB}-${MPI_VERSION}
MPI_SHORT="${MPI_LIB}${MPI_VERSION//.}"
SUB_DIR=${LIB_NAME}/${LIB_VERSION}/${GCC_FULL}/${MPI_FULL}
WORK_DIR=${PREWORK_DIR}/${SUB_DIR}
SRC_DIR=${WORK_DIR}/${LIB_FULLNAME}
ARCHIVE=${SRC_DIR}.tar.gz
URL="https://sourceforge.net/projects/boost/files/boost/${LIB_VERSION}/boost_${LIB_VERSION_DOWNLOAD}.tar.gz"
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
  cd $BUILD_DIR/boost_${LIB_VERSION_DOWNLOAD}
  
  touch user-config.jam
  echo "using mpi ;" >> user-config.jam
  echo "" >> user-config.jam
fi

cd $BUILD_DIR/boost_${LIB_VERSION_DOWNLOAD}
./bootstrap.sh || exit 1
./bjam -j24 install --layout=tagged --prefix=${INSTALL_DIR} --user-config=user-config.jam variant=release threading=single,multi link=static,shared || exit 1
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

