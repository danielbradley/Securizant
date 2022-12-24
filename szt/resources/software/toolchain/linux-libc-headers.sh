#!/tools/bin/bash
#
#       Copyright (c) 2004-2022 Daniel Robert Bradley. All rights reserved.
#

source /mnt/software/download.sh
source /mnt/software/altersource.sh

CATEGORY=toolchain

PACKAGE=linux-libc-headers
VERSION=2.6.12.0
ARCHIVE=tar.bz2
UNZIP=-j

URL=$RESOURCE_URL
PKG_DIR=core/toolchain
PKG=$PACKAGE-$VERSION.$ARCHIVE

PATCH1=linux-libc-headers-2.6.12.0-inotify-3.patch

SOURCE=/mnt/source
BUILD=/mnt/build/toolchain

#CHOST=i386-pc-linux-gnu

#  Executables used
GREP=/tools/bin/grep
TOUCH=/tools/bin/touch
RM=/tools/bin/rm

echo "URL: $URL"

main()
{
	setup            &&
	unpack_package   &&
	apply_patches    &&
	configure_source &&
	compile_source   &&
	install_package  &&
	complete         &&
	echo
}

setup()
{
	echo "URL3: $URL"                 &&
	download ${URL} ${PKG_DIR} ${PKG} &&
	download ${URL} ${PKG_DIR} ${PATCH1}
}

unpack_package()
{
	if [ ! -d $BUILD/$PACKAGE-$VERSION ]
	then
		tar -C $BUILD -xvf $SOURCE/${PKG_DIR}/${PKG} $UNZIP
	fi
}

apply_patches()
{
	if [ -f $BUILD/$PACKAGE-$VERSION/doc ]
	then
		if [ ! -f $BUILD/$PACKAGE-$VERSION/SUCCESS.PATCHED ]
		then
			cd $BUILD/$PACKAGE-$VERSION                &&
			patch -Np1 -i $SOURCE/${PKG_DIR}/${PATCH1} &&
			touch $BUILD/$PACKAGE-$VERSION/SUCCESS.PATCHED
		fi
	fi
}

configure_source()
{
	if [ -f $BUILD/$PACKAGE-$VERSION/SUCCESS.PATCHED ]
	then
		if [ ! -f $BUILD/$PACKAGE-$VERSION/SUCCESS.CONFIGURE ]
		then
			touch $BUILD/$PACKAGE-$VERSION/SUCCESS.CONFIGURE
		fi
	fi
}

compile_source()
{
	if [ -f $BUILD/$PACKAGE-$VERSION/SUCCESS.CONFIGURE ]
	then
		if [ ! -f $BUILD/$PACKAGE-$VERSION/SUCCESS.COMPILE ]
		then
			touch $BUILD/$PACKAGE-$VERSION/SUCCESS.COMPILE
		fi
	fi
}

install_package()
{
	if [ -f $BUILD/$PACKAGE-$VERSION/SUCCESS.COMPILE ]
	then
		if [ ! -f $BUILD/$PACKAGE-$VERSION/SUCCESS.INSTALL ]
		then
			install -dv                    /system/software/source/linux/include/asm &&
			cp      -Rv include/asm-i386/* /system/software/source/linux/include/asm &&
			cp      -Rv include/linux/     /system/software/source/linux/include     &&
			chown   -R  100:1000           /system/software/source/linux             &&

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

main $@
