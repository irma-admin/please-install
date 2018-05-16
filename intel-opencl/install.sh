#!/bin/bash

# See https://wiki.tiker.net/OpenCLHowTo#Installing_the_Intel_CPU_ICD

source ../common.sh

export LIB_NAME="intel-opencl"
export LIB_VERSION="1.2-6.4.0.37"

export LIB_FULLNAME=${LIB_NAME}-${LIB_VERSION}
SUB_DIR=${LIB_NAME}/${LIB_VERSION}
WORK_DIR=${BASE_WORK_DIR}/${SUB_DIR}
SRC_DIR=${WORK_DIR}/${LIB_FULLNAME}
ARCHIVE=${WORK_DIR}/opencl_runtime_16.1.2_x64_rh_6.4.0.37.tgz
URL="http://registrationcenter-download.intel.com/akdlm/irc_nas/12556/opencl_runtime_16.1.2_x64_rh_6.4.0.37.tgz"
export INSTALL_DIR=${BASE_INSTALL_DIR}/${SUB_DIR}

install_lib()
{

if [[ ! -f $ARCHIVE ]]; then
  mkdir -p $WORK_DIR
  wget $URL -O $ARCHIVE
fi

if [[ ! -d $SRC_DIR ]]; then
  tar zxf $ARCHIVE --directory $WORK_DIR
fi

cd $WORK_DIR

mkdir -p "$INSTALL_DIR"
rpm2cpio opencl_runtime_16.1.2_x64_rh_*/rpm/opencl-*-intel-cpu-*.x86_64.rpm | cpio -idmv
cp ./opt/intel/opencl-*/lib64/* "$INSTALL_DIR"
# (now handle by Saltstack:)
# echo "$INSTALL_DIR/libintelocl.so" > /etc/OpenCL/vendors/intel.icd
}

install_lib

