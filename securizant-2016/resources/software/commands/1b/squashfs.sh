#!/tools/bin/bash
#
#       Copyright (c) 2004-2006 Daniel Robert Bradley. All rights reserved.
#

source /mnt/software/download.sh

COMMAND_BASE=/system/software/commands
CATEGORY=filesystem
PACKAGE=squashfs
VERSION=3.3
ARCHIVE=tar.gz
UNZIP=-z

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
	mkdir -p $COMMAND_BASE/$CATEGORY/$PACKAGE-$VERSION
	mkdir -p $COMMAND_BASE/$CATEGORY/$PACKAGE-$VERSION/bin
}

unpack_package()
{
	if [ ! -d $BUILD/$PACKAGE$VERSION ]
	then
		tar -C $BUILD -xvf $SOURCE/$PKG_DIR/$PKG $UNZIP
	fi
}

patch_package()
{
	if [ -f $BUILD/$PACKAGE$VERSION/README ] 
	then
		if [ ! -f $BUILD/$PACKAGE$VERSION/SUCCESS.PATCHED ]
		then
			cd $BUILD/$PACKAGE$VERSION &&
			touch $BUILD/$PACKAGE$VERSION/SUCCESS.PATCHED
		fi
	fi
}

configure_package()
{
	if [ -f $BUILD/$PACKAGE$VERSION/SUCCESS.PATCHED ]
	then
		if [ ! -f $BUILD/$PACKAGE$VERSION/SUCCESS.CONFIGURE ]
		then
			cd $BUILD/$PACKAGE$VERSION &&
			touch $BUILD/$PACKAGE$VERSION/SUCCESS.CONFIGURE
		fi
	fi
}

make_package()
{
	if [ -f $BUILD/$PACKAGE$VERSION/SUCCESS.CONFIGURE ]
	then
		if [ ! -f $BUILD/$PACKAGE$VERSION/SUCCESS.MAKE ]
		then
			cd $BUILD/$PACKAGE$VERSION/squashfs-tools &&
	                make &&
			touch $BUILD/$PACKAGE$VERSION/SUCCESS.MAKE
		fi
	fi
}

install_package()
{
	if [ -f $BUILD/$PACKAGE$VERSION/SUCCESS.MAKE ]
	then
		if [ ! -f $BUILD/$PACKAGE$VERSION/SUCCESS.INSTALL ]
		then
			cd $BUILD/$PACKAGE$VERSION/squashfs-tools &&
	                cp mksquashfs unsquashfs $COMMAND_BASE/$CATEGORY/$PACKAGE-$VERSION/bin
			touch $BUILD/$PACKAGE$VERSION/SUCCESS.INSTALL
		fi
	fi
}

complete()
{
	if [ -f $BUILD/$PACKAGE$VERSION/SUCCESS.INSTALL ]
	then
		cd $BUILD/$PACKAGE$VERSION &&
		rm -rf $BUILD/$PACKAGE$VERSION/*
	fi
}

main $@

