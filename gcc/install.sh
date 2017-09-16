#!/bin/bash

set -x 
export LIB_NAME="gcc"
export LIB_VERSION=6.4.0

export LIB_FULLNAME=${LIB_NAME}-${LIB_VERSION}
#export LIB_VERSION_SHORT="${LIB_VERSION//.}"
SUB_DIR=${LIB_NAME}/${LIB_VERSION}
WORK_DIR=/data/software/sources/${SUB_DIR}
SRC_DIR=${WORK_DIR}/${LIB_FULLNAME}
ARCHIVE=${SRC_DIR}.tar.gz
URL="ftp://ftp.irisa.fr/pub/mirrors/gcc.gnu.org/gcc/releases/gcc-${LIB_VERSION}/gcc-${LIB_VERSION}.tar.gz"
BUILD_DIR=${WORK_DIR}/${LIB_FULLNAME}-build
export INSTALL_DIR=/data/software/install/${SUB_DIR}
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MODULE_DIR=/data/software/modules/compilers/${LIB_NAME}
MODULE_PATH=${MODULE_DIR}/${LIB_VERSION}

install_lib()
{
module purge
gcc --version
sleep 1

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
  ${SRC_DIR}/configure -v --with-pkgversion='gcc 6.4.0' \
  --with-bugurl=file:///usr/share/doc/gcc-6/README.Bugs \
  --enable-languages=c,c++,fortran \
  --enable-shared \
  --enable-linker-build-id \
  --without-included-gettext \
  --enable-threads=posix \
  --enable-nls \
  --with-sysroot=/ \
  --enable-clocale=gnu \
  --enable-libstdcxx-debug \
  --enable-libstdcxx-time=yes \
  --with-default-libstdcxx-abi=new \
  --enable-gnu-unique-object \
  --disable-vtable-verify \
  --enable-libmpx \
  --enable-plugin \
  --enable-default-pie \
  --with-system-zlib \
  --disable-browser-plugin \
  --enable-gtk-cairo \
  --with-arch-directory=amd64 \
  --with-target-system-zlib \
  --enable-multiarch \
  --disable-werror \
  --with-arch-32=i686 \
  --with-abi=m64 \
  --with-multilib-list=m32,m64,mx32 \
  --enable-multilib \
  --with-tune=generic \
  --enable-checking=release \
  --build=x86_64-linux-gnu \
  --host=x86_64-linux-gnu \
  --target=x86_64-linux-gnu \
  --prefix=${INSTALL_DIR}
#  --libdir=/usr/lib \
#  --libexecdir=/usr/lib \
#  --program-suffix=-6 \
#  --program-prefix=x86_64-linux-gnu- \
#  --enable-languages=c,ada,c++,java,go,fortran,objc,obj-c++ \
#  --enable-java-awt=gtk \
#  --with-java-home=/usr/lib/jvm/java-1.5.0-gcj-6-amd64/jre \
#  --enable-java-home \
#  --with-jvm-root-dir=/usr/lib/jvm/java-1.5.0-gcj-6-amd64 \
#  --with-jvm-jar-dir=/usr/lib/jvm-exports/java-1.5.0-gcj-6-amd64 \
#  --with-ecj-jar=/usr/share/java/eclipse-ecj.jar \
#  --enable-objc-gc=auto \
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
export LIB_FULLNAME
export INSTALL_DIR
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

