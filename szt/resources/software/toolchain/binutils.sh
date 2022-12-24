#!/tools/bin/bash
#
#       Copyright (c) 2004-2006 Daniel Robert Bradley. All rights reserved.
#

source /mnt/software/download.sh

GNU_BASE=/system/software/commands
CATEGORY=development
PACKAGE=binutils
VERSION=2.16.1
DNAME=gnu-3.4.3
ARCHIVE=tar.bz2
UNZIP=-j

URL=$RESOURCE_URL
PKG_DIR=core/toolchain
PKG=$PACKAGE-$VERSION.$ARCHIVE

SOURCE=/mnt/source
BUILD=/mnt/build/toolchain

#CHOST=i386-pc-linux-gnu

echo "IN HERE"

main()
{
	setup &&
	unpack_package &&
	apply_patches &&
	configure_source &&
	compile_source &&
	install_package &&
	complete &&
	echo done
}

setup()
{
	download ${URL} ${PKG_DIR} ${PKG}
	mkdir -p $GNU_BASE/$CATEGORY/$PACKAGE
	return
}

unpack_package()
{

	if [ ! -d $BUILD/$PACKAGE-$VERSION ]
	then
		tar -C $BUILD -xvf ${SOURCE}/${PKG_DIR}/${PKG} $UNZIP
	fi
}

apply_patches()
{
	if [ -f $BUILD/$PACKAGE-$VERSION/README ]
	then
		if [ ! -f $BUILD/$PACKAGE-$VERSION/SUCCESS.PATCHED ]
		then
			cd $BUILD/$PACKAGE-$VERSION
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
			mkdir -p $BUILD/$PACKAGE-build &&
			cd $BUILD/$PACKAGE-build &&

#			CFLAGS="-march=i386"
			../$PACKAGE-$VERSION/configure \
				--prefix=$GNU_BASE/$CATEGORY/$DNAME \
				--enable-shared \
				--with-lib-path=/local/software/lib:/system/software/lib
#				--host=$CHOST --target=$CHOST &&
			touch /$BUILD/$PACKAGE-$VERSION/SUCCESS.CONFIGURE
		fi
	fi
}

compile_source()
{
	if [ -f $BUILD/$PACKAGE-$VERSION/SUCCESS.CONFIGURE ]
	then
		if [ ! -f $BUILD/$PACKAGE-$VERSION/SUCCESS.MAKE ]
		then
			cd $BUILD/$PACKAGE-build &&
			make LDFLAGS="-Wl,--dynamic-linker,/system/software/lib/ld-linux.so.2" \
				LIB_PATH=/system/software/lib &&
			touch $BUILD/$PACKAGE-$VERSION/SUCCESS.MAKE
		fi
	fi
}

install_package()
{
	if [ -f $BUILD/$PACKAGE-$VERSION/SUCCESS.MAKE ]
	then
		if [ ! -f $BUILD/$PACKAGE-$VERSION/SUCCESS.INSTALL ]
		then
			cd $BUILD/$PACKAGE-build &&
			make install &&
			cp $BUILD/$PACKAGE-$VERSION/include/libiberty.h \
				$GNU_BASE/$CATEGORY/$DNAME/include
			touch $BUILD/$PACKAGE-$VERSION/SUCCESS.INSTALL
		fi
	fi
}

complete()
{
	if [ -f $BUILD/$PACKAGE-$VERSION/SUCCESS.INSTALL ]
	then
		rm -rf $BUILD/$PACKAGE-$VERSION/* &&
		rm -rf $BUILD/$PACKAGE-build/*
	fi
}

main $@
