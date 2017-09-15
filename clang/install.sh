#!/bin/bash

set -x 
LIB_NAME="clang"
LIB_VERSION=4.0.1
GCC_VERSION=6.4.0

LIB_FULLNAME=${LIB_NAME}-${LIB_VERSION}
GCC_FULL=gcc-$GCC_VERSION
GCC_SHORT="gcc${GCC_VERSION//.}"
SUB_DIR=${LIB_NAME}/${LIB_VERSION}/${GCC_FULL}
WORK_DIR=/data/software/sources/${SUB_DIR}

URL_LLVM="http://releases.llvm.org/${LIB_VERSION}/llvm-${LIB_VERSION}.src.tar.xz"
URL_CFE="http://releases.llvm.org/${LIB_VERSION}/cfe-${LIB_VERSION}.src.tar.xz"
URL_CLANG_TOOLS="http://releases.llvm.org/${LIB_VERSION}/clang-tools-extra-${LIB_VERSION}.src.tar.xz"
URL_COMPILER_RT="http://releases.llvm.org/${LIB_VERSION}/compiler-rt-${LIB_VERSION}.src.tar.xz"

BUILD_DIR=${WORK_DIR}/${LIB_FULLNAME}-build
INSTALL_DIR=/data/software/install/${SUB_DIR}
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MODULE_DIR=/data/software/modules/compilers/${LIB_NAME}
MODULE_PATH=${MODULE_DIR}/${LIB_VERSION}_${GCC_SHORT}


install_lib()
{
    module purge
    module load gcc/${GCC_VERSION}
    module load cmake/3.9.2_${GCC_SHORT}
    module list

    gcc --version |head -n 1
    sleep 2

    if [[ ! -d $WORK_DIR ]]; then
	mkdir -p $WORK_DIR
	cd $WORK_DIR
	wget ${URL_LLVM}
	wget ${URL_CFE}
	wget ${URL_CLANG_TOOLS}
	wget ${URL_COMPILER_RT}
	tar -xJf ${WORK_DIR}/llvm-${LIB_VERSION}.src.tar.xz
	tar -xJf ${WORK_DIR}/cfe-${LIB_VERSION}.src.tar.xz
	tar -xJf ${WORK_DIR}/clang-tools-extra-${LIB_VERSION}.src.tar.xz
	tar -xJf ${WORK_DIR}/compiler-rt-${LIB_VERSION}.src.tar.xz
	mv ${WORK_DIR}/llvm-${LIB_VERSION}.src ${WORK_DIR}/llvm
	mv ${WORK_DIR}/cfe-${LIB_VERSION}.src ${WORK_DIR}/llvm/tools/clang
	mv ${WORK_DIR}/clang-tools-extra-${LIB_VERSION}.src llvm/tools/clang/tools/extra
	mv ${WORK_DIR}/compiler-rt-${LIB_VERSION}.src llvm/projects/compiler-rt
    fi

    if [[ ! -d $BUILD_DIR ]]; then
	mkdir $BUILD_DIR
    fi
    cd $BUILD_DIR
    cmake  -DCMAKE_BUILD_TYPE=Release \
	   -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} \
	   -DGCC_INSTALL_PREFIX=${GCC_DIR} \
	   -DCMAKE_C_COMPILER=`which gcc` \
	   -DCMAKE_CXX_COMPILER=`which g++` \
	   -DBUILD_SHARED_LIBS=ON \
	   -DLLVM_BUILD_TOOLS=OFF \
	   -DCLANG_INCLUDE_DOCS=OFF \
	   -DCLANG_INCLUDE_TESTS=OFF \
	   ${WORK_DIR}/llvm || exit 1
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
else
    install_lib
    install_module
fi
