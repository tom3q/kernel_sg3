#!/bin/sh
#
# Kernel build script
#
# By Mark "Hill Beast" Kennard
#

TOOLCHAIN=/usr/arm-4.4.3-toolchain/bin/arm-eabi-
ARCH=arm

CPUCORES=`grep "cpu cores" /proc/cpuinfo | awk '{ print $4 }' | head -c 1`

USEOUTDIR=`echo $1 $2 $3 $4 | grep -useout`

if [ -z "$USEOUTDIR" ]; then
	echo "Make will output to kernel directory"
else
	OUTDIR=/mnt/out/out
	OUTSUBDIR=`cat .git/config | grep url | sed "s|/| |" | awk '{ print $4 }'`
	USEOUTDIR="$OUTDIR/kernel/$OUTSUBDIR/"
	echo "Using output directory ($USEOUTDIR)"
	mkdir -p $USEOUTDIR 2> /dev/null
fi

if [ -z $1 ]; then
	if [ -z $KBUILD_BUILD_VERSION ]; then
		export KBUILD_BUILD_VERSION="Test-`date '+%Y%m%d-%H%M'`"
	fi
	echo "Kernel will be labelled ($KBUILD_BUILD_VERSION)"
else
	if [ $1 = "config" ]; then
		if [ -z "$USEOUTDIR" ]; then
			make menuconfig CROSS_COMPILE=$TOOLCHAIN ARCH=$ARCH
		else
			make menuconfig CROSS_COMPILE=$TOOLCHAIN ARCH=$ARCH O=$USEOUTDIR
		fi
		exit
	fi
	if [ $1 = "saveconfig" ]; then
		if [ -z $2 ]; then
			echo "You need to specify a defconfig filename"
			echo "./build.sh saveconfig [x_defconfig]"
			exit
		fi
		if test -f arch/$ARCH/configs/$2; then
			cp arch/$ARCH/configs/$2 arch/$ARCH/configs/$2.bak
		fi
		grep "=" $USEOUTDIR".config" > arch/$ARCH/configs/$2
		echo ".config saved to arch/$ARCH/configs/$2"
		exit
	fi
	echo "Setting kernel name to ($1)"
	export KBUILD_BUILD_VERSION=$1
fi

echo "Compiling the kernel"
if test -f $USEOUTDIR"arch/$ARCH/boot/zImage"; then
	rm $USEOUTDIR"arch/$ARCH/boot/zImage"
fi

if [ -z "$USEOUTDIR" ]; then
	echo "make -j$CPUCORES CROSS_COMPILE=$TOOLCHAIN ARCH=$ARCH"
	make -j$CPUCORES CROSS_COMPILE=$TOOLCHAIN ARCH=$ARCH
else
	echo "make -j$CPUCORES CROSS_COMPILE=$TOOLCHAIN ARCH=$ARCH O=$USEOUTDIR"
	make -j$CPUCORES CROSS_COMPILE=$TOOLCHAIN ARCH=$ARCH O=$USEOUTDIR
fi

if test -f $USEOUTDIR"arch/arm/boot/zImage"; then
	TARBALL=$KBUILD_BUILD_VERSION-zImage.tar
	cp $USEOUTDIR"arch/arm/boot/zImage" ./
	echo "  TAR     $TARBALL"
	tar cf $TARBALL zImage
	rm zImage
else
	echo "Will not tarball as make didn't produce zImage"
fi

echo "Done"

