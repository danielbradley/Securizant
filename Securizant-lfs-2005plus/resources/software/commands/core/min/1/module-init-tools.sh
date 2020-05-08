#!/tools/bin/bash
#
#       Copyright (c) 2004-2006 Daniel Robert Bradley. All rights reserved.
#

source /mnt/software/download.sh

COMMAND_BASE=/system/software/commands
CATEGORY=utils
PACKAGE=module-init-tools
VERSION=3.2.2
ARCHIVE=tar.bz2
UNZIP=-j

URL=$RESOURCE_URL
PKG_DIR=core/commands
PKG=$PACKAGE-$VERSION.$ARCHIVE

DEST=$COMMAND_BASE/$CATEGORY/$PACKAGE-$VERSION

SOURCE=/mnt/source
BUILD=/mnt/build/commands

#CHOST=i386-pc-linux-gnu

main()
{
	echo Scripting $PACKAGE-$VERSION &&
	prepare &&
	unpack_package &&
	patch_package &&
	configure_package &&
	make_package &&
	install_package &&
	complete
}

prepare()
{
	download ${URL} ${PKG_DIR} ${PKG}
	download ${URL} ${PKG_DIR} ${PACKAGE}-$VERSION}-modprobe-1.patch
	mkdir -p $COMMAND_BASE/$CATEGORY/$PACKAGE-$VERSION
}

unpack_package()
{
	if [ ! -d $BUILD/$PACKAGE-$VERSION ]
	then
		tar -C $BUILD -xvf $SOURCE/$PKG_DIR/$PKG $UNZIP
	fi
}

patch_package()
{
	if [ -f $BUILD/$PACKAGE-$VERSION/configure ] 
	then
		if [ ! -f $BUILD/$PACKAGE-$VERSION/SUCCESS.PATCHED ]
		then
			cd $BUILD/$PACKAGE-$VERSION &&
			touch modprobe.conf.5 &&

			patch -Np1 -i $SOURCE/$PKG_DIR/${PACKAGE}-${VERSION}-modprobe-1.patch

			sed -i 's@/lib/modules@/system/software/drivers@g' \
				configure configure.in depmod.8 depmod.c \
				doc/modules.dep.sgml \
				doc/depmod.sgml \
				doc/modprobe.sgml \
				doc/modinfo.sgml \
				modinfo.8 modinfo.c modprobe.8 modprobe.c \
				modules.dep.5 stress_modules.sh tables.c &&

			touch $BUILD/$PACKAGE-$VERSION/SUCCESS.PATCHED
		fi
	fi
}

configure_package()
{
	if [ -f $BUILD/$PACKAGE-$VERSION/SUCCESS.PATCHED ]
	then
		if [ ! -f $BUILD/$PACKAGE-$VERSION/SUCCESS.CONFIGURE ]
		then
			cd $BUILD/$PACKAGE-$VERSION &&
			#./configure                 &&
			#make check                  &&
			#make distclean              &&
			./configure \
				--enable-zlib \
        	                --prefix=$COMMAND_BASE/$CATEGORY/$PACKAGE-$VERSION &&
			touch $BUILD/$PACKAGE-$VERSION/SUCCESS.CONFIGURE
		fi
	fi
}

make_package()
{
	if [ -f $BUILD/$PACKAGE-$VERSION/SUCCESS.CONFIGURE ]
	then
		if [ ! -f $BUILD/$PACKAGE-$VERSION/SUCCESS.MAKE ]
		then
			cd $BUILD/$PACKAGE-$VERSION &&
	                make &&
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
			cd $BUILD/$PACKAGE-$VERSION &&
	                make install &&
			touch $BUILD/$PACKAGE-$VERSION/SUCCESS.INSTALL
		fi
	fi
}

complete()
{
	if [ -f $BUILD/$PACKAGE-$VERSION/SUCCESS.INSTALL ]
	then
		cd $BUILD/$PACKAGE-$VERSION &&
		rm -rf $BUILD/$PACKAGE-$VERSION/*
	fi
}

main $@
