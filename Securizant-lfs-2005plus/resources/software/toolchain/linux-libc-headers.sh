#!/bin/bash
#
#       Copyright (c) 2004-2006 Daniel Robert Bradley. All rights reserved.
#

source /mnt/software/download.sh

CATEGORY=toolchain

PACKAGE=linux-libc-headers	# Package information
VERSION=2.6.12.0			# Version information
ARCHIVE=tar.bz2
UNZIP=-j

URL=$RESOURCE_URL
PKG_DIR=core/toolchain
PKG=$PACKAGE-$VERSION.$ARCHIVE
PATCH1=linux-libc-headers-2.6.12.0-inotify-3.patch

SOURCE=/mnt/source					# Where source packages are located
BUILD=/mnt/build/toolchain			# Where this package should be built

main()
{
	echo $PACKAGE-$VERSION

	setup           &&
	unpack_package  &&
	apply_patches   &&
	install_package &&
	complete        &&
	echo done
}

setup()
{
	download ${URL} ${PKG_DIR} ${PKG}
	download ${URL} ${PKG_DIR} ${PATCH1}
}

unpack_package()
{
	if [ ! -d $BUILD/$PACKAGE-$VERSION ]
	then
		mkdir -p $BUILD
		tar -C $BUILD -xvf $SOURCE/${PKG_DIR}/${PKG} $UNZIP
	fi
}

apply_patches()
{
	if [ -d $BUILD/$PACKAGE-$VERSION/doc ]
	then
		if [ ! -f $BUILD/$PACKAGE-$VERSION/SUCCESS.PATCHED ]
		then
			cd $BUILD/$PACKAGE-$VERSION                &&
			patch -Np1 -i $SOURCE/${PKG_DIR}/${PATCH1} &&
			touch $BUILD/$PACKAGE-$VERSION/SUCCESS.PATCHED
		fi
	fi
	return 0
}


install_package()
{
	local $PREFIX=/system/software/source/linux

	if [ -f $BUILD/$PACKAGE-$VERSION/SUCCESS.PATCHED ]
	then
		if [ ! -f $BUILD/$PACKAGE-$VERSION/SUCCESS.INSTALL ]
		then
			cd $BUILD/$PACKAGE-$VERSION
			cp -Rv include/asm-i386 /system/software/source/linux/include/asm
			cp -Rv include/linux    /system/software/source/linux/include/linux
			touch $BUILD/$PACKAGE-$VERSION/SUCCESS.INSTALL
		fi
	fi
}

complete()
{
	if [ -f $BUILD/$PACKAGE-$VERSION/SUCCESS.INSTALL ]
	then
		rm -rf $BUILD/$PACKAGE-$VERSION/*
	fi
}

premain()
{
	local Here=`pwd`
	main $@
	let ret=$?
	cd ${Here}
	return $ret
}

premain $@
