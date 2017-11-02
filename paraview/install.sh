#!/bin/bash

set -x 
LIB_NAME="paraview"
LIB_VERSION_URL=5.4.1
LIB_VERSION=${LIB_VERSION_URL}-py3
GCC_VERSION=6.4.0
MPI_LIB=openmpi
MPI_VERSION=1.10.7
HDF5_VERSION=1.10.1
CMAKE_VERSION=3.9.2

LIB_FULLNAME=${LIB_NAME}-${LIB_VERSION}
LIB_VERSION_SHORT="${LIB_VERSION%.*}"
GCC_FULL=gcc-$GCC_VERSION
GCC_SHORT="gcc${GCC_VERSION//.}"
MPI_FULL=${MPI_LIB}-${MPI_VERSION}
MPI_SHORT="${MPI_LIB}${MPI_VERSION//.}"
SUB_DIR=${LIB_NAME}/${LIB_VERSION}/${GCC_FULL}/${MPI_FULL}
WORK_DIR=/data/software/sources/${SUB_DIR}
SRC_DIR=${WORK_DIR}/${LIB_FULLNAME}
ARCHIVE=${SRC_DIR}.tar.gz
URL="https://www.paraview.org/paraview-downloads/download.php?submit=Download&version=v${LIB_VERSION_SHORT}&type=binary&os=Sources&downloadFile=ParaView-v${LIB_VERSION_URL}.tar.gz"
BUILD_DIR=${WORK_DIR}/${LIB_FULLNAME}-build
INSTALL_DIR=/data/software/install/${SUB_DIR}
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MODULE_DIR=/data/software/modules/tools/${LIB_NAME}
MODULE_PATH=${MODULE_DIR}/${LIB_VERSION}_${GCC_SHORT}_${MPI_SHORT}


install_lib()
{
module purge
module load gcc/${GCC_VERSION}
module load ${MPI_LIB}/${MPI_VERSION}_${GCC_SHORT}
module load hdf5/${HDF5_VERSION}_${GCC_SHORT}_${MPI_SHORT}
module load cmake/${CMAKE_VERSION}_${GCC_SHORT}

gcc --version |head -n 1
mpirun --version |head -n 1
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
  cmake $SRC_DIR \
  -DCMAKE_C_COMPILER=`which gcc` \
  -DCMAKE_CXX_COMPILER=`which g++` \
  -DBUILD_TESTING=OFF \
  -DVTK_RENDERING_BACKEND=OpenGL2 \
  -DPARAVIEW_ENABLE_CATALYST=ON \
  -DPARAVIEW_ENABLE_PYTHON=ON \
  -DPYTHON_LIBRARY="/usr/lib/x86_64-linux-gnu/libpython3.5m.so" \
  -DPYTHON_INCLUDE_DIR="/usr/include/python3.5" \
  -DPYTHON_EXECUTABLE="/usr/bin/python3" \
  -DPARAVIEW_INSTALL_DEVELOPMENT_FILES=ON \
  -DPARAVIEW_USE_MPI=ON \
  -DPARAVIEW_QT_VERSION=4 \
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
export GCC_VERSION
export GCC_SHORT
export MPI_LIB
export MPI_VERSION
export MPI_SHORT
export HDF5_VERSION
envtpl  --keep-template -o $MODULE_PATH module.tmpl
}

if [[ $1 == "module" ]]
then
  install_module
elif [[ $1 == "clean" ]]
then
  if [[ -d $BUILD_DIR ]]
  then
    rm -rf $BUILD_DIR
  else
    echo "$BUILD_DIR does not exist"
    exit 1
  fi
else
  install_lib
  install_module
fi

