#!/bin/bash

# source module configuration
FILE_TO_SOURCE=/etc/profile.d/modules.sh
if [[ -f "${FILE_TO_SOURCE}" ]]; then
    source ${FILE_TO_SOURCE}
else
    echo "File to source (${FILE_TO_SOURCE}) does not exist"
fi

# source atlas configuration for modules
PREVPATH=`pwd`
cd /data/software/config/etc
FILE_TO_SOURCE=feelpprc.sh
if [[ -f "${FILE_TO_SOURCE}" ]]; then
    source ${FILE_TO_SOURCE}
else
    echo "File to source (${FILE_TO_SOURCE}) does not exist"
fi
cd ${PREVPATH}

module purge
module load compilers/gcc/6.1.0

gcc --version

if [[ -z $CEMRACS_INSTALL_DIR ]]; then
    export CEMRACS_INSTALL_DIR=/data/software/install
fi

if [[ ! -f ./cmake-3.6.1.tar.gz ]]; then
    wget https://cmake.org/files/v3.6/cmake-3.6.1.tar.gz
fi
if [[ ! -d ./cmake-3.6.1 ]]; then
    tar zxvf cmake-3.6.1.tar.gz
fi

if [[ ! -d ./cmake-3.6.1-build ]]; then
mkdir cmake-3.6.1-build
cd cmake-3.6.1-build
../cmake-3.6.1/configure --prefix=${CEMRACS_INSTALL_DIR}/CMake/3.6.1/gcc-6.1.0
cd ..
fi

cd cmake-3.6.1-build
make -j 24
make install
cd ..
