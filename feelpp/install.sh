#!/bin/bash

source ../common.sh

LIB_VERSION=develop
GCC_VERSION=6.4.0
MPI_LIB=openmpi
MPI_VERSION=1.10.7 #2.1.1 #1.10.7
GCC_FULL=gcc-$GCC_VERSION
GCC_SHORT="gcc${GCC_VERSION//.}"
MPI_FULL=${MPI_LIB}-${MPI_VERSION}
MPI_SHORT="${MPI_LIB}${MPI_VERSION//.}"

LIB_NAME="feelpp-lib"
LIB_QUICKSTART_NAME="feelpp-quickstart"
LIB_TOOLBOXES_NAME="feelpp-toolboxes"
LIB_FULLNAME=${LIB_NAME}-${LIB_VERSION}
LIB_QUICKSTART_FULLNAME=${LIB_QUICKSTART_NAME}-${LIB_VERSION}
LIB_TOOLBOXES_FULLNAME=${LIB_TOOLBOXES_NAME}-${LIB_VERSION}
SUB_LIB_DIR=${LIB_NAME}/${LIB_VERSION}/${GCC_FULL}/${MPI_FULL}
SUB_QUICKSTART_DIR=${LIB_QUICKSTART_NAME}/${LIB_VERSION}/${GCC_FULL}/${MPI_FULL}
SUB_TOOLBOXES_DIR=${LIB_TOOLBOXES_NAME}/${LIB_VERSION}/${GCC_FULL}/${MPI_FULL}
SRC_DIR=${PREWORK_DIR}/${SUB_LIB_DIR}
GIT_URL="https://github.com/feelpp/feelpp.git"
BUILD_LIB_DIR=${SRC_DIR}/build-lib
BUILD_QUICKSTART_DIR=${SRC_DIR}/build-quickstart
BUILD_TOOLBOXES_DIR=${SRC_DIR}/build-toolboxes
INSTALL_LIB_DIR=${PREINSTALL_DIR}/${SUB_LIB_DIR}
INSTALL_QUICKSTART_DIR=${PREINSTALL_DIR}/${SUB_QUICKSTART_DIR}
INSTALL_TOOLBOXES_DIR=${PREINSTALL_DIR}/${SUB_TOOLBOXES_DIR}
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MODULE_LIB_DIR=${PREMODULE_DIR}/libs/${LIB_NAME}
MODULE_LIB_PATH=${MODULE_LIB_DIR}/${LIB_VERSION}_${GCC_SHORT}_${MPI_SHORT}
MODULE_LIB_NAME=${LIB_NAME}/${LIB_VERSION}_${GCC_SHORT}_${MPI_SHORT}
MODULE_QUICKSTART_DIR=${PREMODULE_DIR}/libs/${LIB_QUICKSTART_NAME}
MODULE_QUICKSTART_PATH=${MODULE_QUICKSTART_DIR}/${LIB_VERSION}_${GCC_SHORT}_${MPI_SHORT}
MODULE_TOOLBOXES_DIR=${PREMODULE_DIR}/libs/${LIB_TOOLBOXES_NAME}
MODULE_TOOLBOXES_PATH=${MODULE_TOOLBOXES_DIR}/${LIB_VERSION}_${GCC_SHORT}_${MPI_SHORT}

FEELPP_PROFILE=feelpp.profile_${GCC_SHORT}_${MPI_SHORT}

install_lib()
{
module purge
module load ${FEELPP_PROFILE}
module list

gcc --version |head -n 1
sleep 2
mpirun --version |head -n 1
sleep 2

if [[ ! -d $SRC_DIR/feelpp ]]; then
  mkdir -p $SRC_DIR
  cd  $SRC_DIR
  git clone $GIT_URL
else
  cd  $SRC_DIR/feelpp && git pull
fi
cd  $SRC_DIR/feelpp && git submodule update --init --recursive
    
rm -rf $BUILD_LIB_DIR
mkdir $BUILD_LIB_DIR
cd $BUILD_LIB_DIR || exit 1
cmake -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_CXX_COMPILER=clang++ \
      -DCMAKE_C_COMPILER=clang \
      -DCMAKE_INSTALL_PREFIX=${INSTALL_LIB_DIR} \
      -DCMAKE_CXX_FLAGS="-Wno-expansion-to-defined" \
      -DFEELPP_ENABLE_OMC=OFF  -DFEELPP_ENABLE_FMILIB=OFF \
       $SRC_DIR/feelpp || exit 1
cd $BUILD_LIB_DIR/cmake && make install || exit 1
cd $BUILD_LIB_DIR/contrib && make install -j16 || exit 1
cd $BUILD_LIB_DIR/feel && make install -j16 || exit 1
cd $BUILD_LIB_DIR/applications/mesh && make install -j16 || exit 1
cd $BUILD_LIB_DIR/applications/databases && make install -j16 || exit 1
}

install_lib_quickstart()
{
    module purge
    module load feelpp-lib/${LIB_VERSION}_${GCC_SHORT}_${MPI_SHORT}
    module list

    if [[ ! -d $SRC_DIR/feelpp ]]; then
	echo "no src dir : exit"
	exit 1
    fi

    echo "start configure of quickstart with FEELPP_DIR=${FEELPP_DIR}" 
    
    rm -rf $BUILD_QUICKSTART_DIR
    mkdir $BUILD_QUICKSTART_DIR
    cd $BUILD_QUICKSTART_DIR || exit 1

    cmake -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_CXX_COMPILER=clang++ \
	  -DCMAKE_C_COMPILER=clang \
	  -DCMAKE_INSTALL_PREFIX=${INSTALL_QUICKSTART_DIR} \
	  -DFEELPP_DIR=${FEELPP_DIR} \
	  $SRC_DIR/feelpp/quickstart || exit 1
    make install -j16
}

install_lib_tooboxes()
{
    module purge
    module load feelpp-lib/${LIB_VERSION}_${GCC_SHORT}_${MPI_SHORT}
    module list

    if [[ ! -d $SRC_DIR/feelpp ]]; then
	echo "no src dir : exit"
	exit 1
    fi

    echo "start configure of toolboxes with FEELPP_DIR=${FEELPP_DIR}" 
    
    rm -rf $BUILD_TOOLBOXES_DIR
    mkdir $BUILD_TOOLBOXES_DIR
    cd $BUILD_TOOLBOXES_DIR || exit 1

    cmake -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_CXX_COMPILER=clang++ \
	  -DCMAKE_C_COMPILER=clang \
	  -DCMAKE_INSTALL_PREFIX=${INSTALL_TOOLBOXES_DIR} \
	  -DFEELPP_DIR=${FEELPP_DIR} \
	  $SRC_DIR/feelpp/toolboxes || exit 1
    make install -j16
}

install_module_lib()
{
    cd $SCRIPT_DIR
    mkdir -p ${MODULE_LIB_DIR}

    export LIB_NAME
    export LIB_VERSION
    export INSTALL_LIB_DIR
    export FEELPP_PROFILE
    envtpl  --keep-template -o $MODULE_LIB_PATH module_lib.tmpl
}

install_module_quickstart()
{
    cd $SCRIPT_DIR
    mkdir -p ${MODULE_QUICKSTART_DIR}
    export LIB_QUICKSTART_NAME
    export LIB_VERSION
    export INSTALL_QUICKSTART_DIR
    export MODULE_LIB_NAME
    envtpl  --keep-template -o $MODULE_QUICKSTART_PATH module_quickstart.tmpl
}

install_module_tooboxes()
{
    cd $SCRIPT_DIR
    mkdir -p ${MODULE_TOOLBOXES_DIR}
    export LIB_TOOLBOXES_NAME
    export LIB_VERSION
    export INSTALL_TOOLBOXES_DIR
    export MODULE_LIB_NAME
    envtpl  --keep-template -o $MODULE_TOOLBOXES_PATH module_toolboxes.tmpl
}

if [[ $1 == "module" ]]; then
    install_module_lib
    install_module_tooboxes
    exit 1
fi

if [[ $1 == "feelpp-lib" ]]; then
    install_lib
    install_module_lib
    exit 1
fi

if [[ $1 == "feelpp-quickstart" ]]; then
    install_lib_quickstart
    install_module_quickstart
    exit 1
fi

if [[ $1 == "feelpp-toolboxes" ]]; then
    install_lib_tooboxes
    install_module_tooboxes
    exit 1
fi

install_lib
install_module_lib
install_lib_quickstart
install_module_quickstart
install_lib_tooboxes
install_module_tooboxes
