#!/bin/bash

set -e

if [ "$(id -u)" -ne 0 ]; then
	echo "Error: you have to run this script with sudo." >&2
	exit 1
fi

source ./config.sh

echo "Download sources packages..."

if [ -f "toolchain_list.txt" ]; then
	wget -c -i toolchain_list.txt -P $SRC_DIR
else
	echo "Error: toolchain_list.txt not found"
	exit 0;
fi

setup_source() {
    local pkg_name=$1
    echo "Search package : $pkg_name..."

    local tarball=$(find $SRC_DIR -name "$pkg_name-*.tar.*" | head -n 1)

    if [ -z "$tarball" ]; then
        echo "Error : Package not found for $pkg_name in $SRC_DIR"
        exit 1
    fi

    echo "Extract $(basename $tarball)..."
    tar -xf $tarball -C $SRC_DIR

    local dir_name=$(basename $tarball | sed 's/\.tar\..*//')
    cd $SRC_DIR/$dir_name

    rm -rf build
    mkdir -v build
}

echo "Binutils..."
cd $SRC_DIR
setup_source "binutils"

cd build
../configure --prefix=$TOOLS_DIR        \
             --with-sysroot=$LFS        \
             --target=$LFS_TGT          \
             --disable-nls              \
             --disable-werror

make $MAKEFLAGS
make install
echo "Binutils installed."

echo "GCC..."
cd $SRC_DIR

GCC_TAR=$(find $SRC_DIR -name "gcc-*.tar.*" | head -n 1)
tar -xf $GCC_TAR -C $SRC_DIR
GCC_DIR=$(basename $GCC_TAR | sed 's/\.tar\..*//')
cd $SRC_DIR/$GCC_DIR

echo "Integrate GMP, MPFR, MPC in GCC..."
tar -xf $(find $SRC_DIR -name "mpfr-*.tar.*" | head -n 1) && mv -v mpfr-* mpfr
tar -xf $(find $SRC_DIR -name "gmp-*.tar.*" | head -n 1)   && mv -v gmp-* gmp
tar -xf $(find $SRC_DIR -name "mpc-*.tar.*" | head -n 1)   && mv -v mpc-* mpc

mkdir -v build
cd build

../configure                                       \
    --target=$LFS_TGT                              \
    --prefix=$TOOLS_DIR                            \
    --with-glibc-version=2.35                      \
    --with-sysroot=$LFS                            \
    --with-newlib                                  \
    --without-headers                              \
    --enable-initfini-array                        \
    --disable-nls                                  \
    --disable-shared                               \
    --disable-multilib                             \
    --disable-decimal-float                        \
    --disable-threads                              \
    --disable-libatomic                            \
    --disable-libgomp                              \
    --disable-libquadmath                          \
    --disable-libssp                               \
    --disable-libvtv                               \
    --disable-libstdcxx                            \
    --enable-languages=c,c++

make $MAKEFLAGS
make install
echo "GCC installed."

echo "Linux API Headers..."
cd $SRC_DIR
setup_source "linux"
cd ..

make mrproper
make headers_install ARCH=x86_64 INSTALL_HDR_PATH=$LFS/usr
echo "Linux Headers installed"

echo "Glibc..."
cd $SRC_DIR
setup_source "glibc"

cd build
../configure                             \
      --prefix=/usr                      \
      --host=$LFS_TGT                    \
      --build=$(../scripts/config.guess) \
      --enable-kernel=3.2                \
      --with-headers=$LFS/usr/include    \
      libc_cv_slibdir=/usr/lib

make $MAKEFLAGS
make DESTDIR=$LFS install

sed '/RTLDLIST=/s@/usr@@g' -i $LFS/usr/bin/ldd

echo "Glibc installed"

echo "Libstdc++..."
cd $SRC_DIR/$GCC_DIR/build
rm -rf *

../libstdc++-v3/configure           \
    --host=$LFS_TGT                 \
    --prefix=/usr                   \
    --disable-multilib              \
    --disable-nls                   \
    --disable-libstdcxx-pch         \
    --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/11.2.0

make $MAKEFLAGS
make DESTDIR=$LFS install

echo "1st step TOOLCHAIN finished !"

