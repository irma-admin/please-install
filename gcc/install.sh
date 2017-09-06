#!/bin/bash

set -x 
export LIB_NAME="gcc"
export LIB_VERSION=6.4.0

export LIB_FULLNAME=${LIB_NAME}-${LIB_VERSION}
export LIB_VERSION_SHORT="${LIB_VERSION//.}"
export SUB_DIR=${LIB_NAME}/${LIB_VERSION}
WORK_DIR=/data/software/sources/${SUB_DIR}
SRC_DIR=${WORK_DIR}/${LIB_FULLNAME}
ARCHIVE=${SRC_DIR}.tar.gz
URL="ftp://ftp.irisa.fr/pub/mirrors/gcc.gnu.org/gcc/releases/gcc-${LIB_VERSION}/gcc-${LIB_VERSION}.tar.gz"
BUILD_DIR=${WORK_DIR}/${LIB_FULLNAME}-build
export INSTALL_DIR=/data/software/install/${SUB_DIR}
MODULE_DIR=/data/software/modules/compilers/${LIB_NAME}
MODULE_PATH=${MODULE_DIR}/${LIB_VERSION_SHORT}

gcc --version

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
  ${SRC_DIR}/configure -v --with-pkgversion='Ubuntu 6.4.0' \
  --with-bugurl=file:///usr/share/doc/gcc-6/README.Bugs \
  --enable-languages=c,ada,c++,java,go,fortran,objc,obj-c++ \
  --program-suffix=-6 \
  --program-prefix=x86_64-linux-gnu- \
  --enable-shared \
  --enable-linker-build-id \
  --libexecdir=/usr/lib \
  --without-included-gettext \
  --enable-threads=posix \
  --libdir=/usr/lib \
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
  --enable-java-awt=gtk \
  --enable-gtk-cairo \
  --with-java-home=/usr/lib/jvm/java-1.5.0-gcj-6-amd64/jre \
  --enable-java-home \
  --with-jvm-root-dir=/usr/lib/jvm/java-1.5.0-gcj-6-amd64 \
  --with-jvm-jar-dir=/usr/lib/jvm-exports/java-1.5.0-gcj-6-amd64 \
  --with-arch-directory=amd64 \
  --with-ecj-jar=/usr/share/java/eclipse-ecj.jar \
  --with-target-system-zlib \
  --enable-objc-gc=auto \
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
fi

cd $BUILD_DIR
make -j || exit 1
make -j install || exit 1

make -p ${MODULE_DIR}
envtpl < module.tmpl > $MODULE_PATH
