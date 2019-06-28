#!/tools/bin/bash
#
#       Copyright (c) 2004-2006 Daniel Robert Bradley. All rights reserved.
#

#
#	See BLFS svn-20070203 GCC-3.3.6
#

source /mnt/software/download.sh

GNU_BASE=/system/software/libraries
CATEGORY=system
PACKAGE=gcc
VERSION=3.3.6
DNAME=libstdc++-5
ARCHIVE=tar.bz2
UNZIP=-j

URL=$RESOURCE_URL
PKG_DIR=core/libraries
PKG=$PACKAGE-$VERSION.$ARCHIVE
PATCH1=$PACKAGE-$VERSION-no_fixincludes-1.patch
PATCH2=$PACKAGE-$VERSION-linkonce-1.patch

SOURCE=/mnt/source
BUILD=/mnt/build/libraries

DEST=$GNU_BASE/$CATEGORY/$DNAME

#CHOST=i386-pc-linux-gnu

#  Executables used
GREP=/tools/software/bin/grep
TOUCH=/tools/software/bin/touch
RM=/tools/software/bin/rm

main()
{
	prepare &&
	unpack_package &&
	apply_patches &&
	configure_source &&
	compile_source &&
	install_package &&
	complete
}

prepare()
{
	download ${URL} ${PKG_DIR} ${PKG}
	download ${URL} ${PKG_DIR} ${PATCH1}
	download ${URL} ${PKG_DIR} ${PATCH2}
}

unpack_package()
{
	if [ ! -d $BUILD/$PACKAGE-$VERSION ]
	then
		tar -C $BUILD -xvf $SOURCE/$PKG_DIR/$PKG $UNZIP
	fi
}

apply_patches()
{
	if [ -f $BUILD/$PACKAGE-$VERSION/configure ]
	then
		if [ ! -f $BUILD/$PACKAGE-$VERSION/SUCCESS.PATCH ]
		then
			cd $BUILD/$PACKAGE-$VERSION &&
			patch -Np1 -i $SOURCE/$PKG_DIR/$PATCH1 &&
			patch -Np1 -i $SOURCE/$PKG_DIR/$PATCH2 &&
			touch $BUILD/$PACKAGE-$VERSION/SUCCESS.PATCH
		fi
	fi
}

configure_source()
{
	if [ -f $BUILD/$PACKAGE-$VERSION/SUCCESS.PATCH ]
	then

		if [ ! -f $BUILD/$PACKAGE-$VERSION/SUCCESS.CONFIGURE ]
		then
			mkdir -p $BUILD/$PACKAGE-build &&
			cd $BUILD/$PACKAGE-build &&
#			CFLAGS="-march=i386" CXXFLAGS="-march=i386" \
			../$PACKAGE-$VERSION/configure \
				--prefix=$DEST \
				--libexecdir=/system/software/lib \
				--enable-shared \
				--enable-threads=posix \
				--enable-__cxa_atexit \
				--enable-clocale=gnu \
				--enable-languages=c,c++ \
				--with-local-prefix=/local/software &&
#				--host=$CHOST --target=$CHOST
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
			cd $BUILD/$PACKAGE-build
			make LDFLAGS="-Wl,--dynamic-linker,/system/software/lib/ld-linux.so.2" bootstrap &&
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
			cd $BUILD/$PACKAGE-build &&
			make install &&
			rm $DEST/{bin,include,info,man,share} -r &&
			rm $DEST/lib/*a &&
			rm $DEST/lib/*so &&
			rm $DEST/lib/*1 &&
			rm $DEST/lib/gcc-lib -r &&
##			mkdir -p /system/software/libraries/gnu/g++-3.3.1/lib &&
##                        cp /system/software/Applications/development/gnu-3.3.1/lib/libstdc++* \
##                                /system/software/libraries/gnu/g++-3.3.1/lib &&
##			ln -s gcc $GNU_BASE/$CATEGORY/$DNAME/bin/cc &&
			touch $BUILD/$PACKAGE-$VERSION/SUCCESS.INSTALL
		fi
	fi
}

complete()
{
	if [ -f $BUILD/$PACKAGE-$VERSION/SUCCESS.INSTALL ]
	then
		rm -rf $BUILD/$PACKAGE-$VERSION/*
		rm -rf $BUILD/$PACKAGE-build/*
	fi
}

main $@

