#!/bin/sh

if [ -z $1 ]; then
	if [ -z $KBUILD_BUILD_VERSION ]; then
		export KBUILD_BUILD_VERSION="Test-`date '+%Y%m%d-%H%m'`"
	fi
	echo "Kernel will be labelled ($KBUILD_BUILD_VERSION)"
else
	echo "Setting kernel name to ($1)"
	export KBUILD_BUILD_VERSION=$1
fi

echo "Compiling the kernel"
if test -f arch/arm/boot/zImage; then
	rm arch/arm/boot/zImage
fi

make -j2 CROSS_COMPILE=/usr/arm-toolchain/bin/arm-eabi- ARCH=arm

if test -f arch/arm/boot/zImage; then
	echo "Tarballing the kernel"
	cp arch/arm/boot/zImage ./
	tar cf $KBUILD_BUILD_VERSION-zImage.tar zImage
	rm zImage
else
	echo "Will not tarball as make didn't produce zImage"
fi

echo "Done"
