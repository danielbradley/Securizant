#!/tools/bin/bash
#
#       Copyright (c) 2004-2006 Daniel Robert Bradley. All rights reserved.
#

source /mnt/software/download.sh

COMMAND_BASE=/system/software/commands
CATEGORY=network
PACKAGE=net-tools
VERSION=1.60
ARCHIVE=tar.bz2
UNZIP=-j

URL=$RESOURCE_URL
PKG_DIR=core/commands
PKG=$PACKAGE-$VERSION.$ARCHIVE
PATCH1=$PACKAGE-$VERSION-config.patch
PATCH2=$PACKAGE-$VERSION-switch.patch

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
	download ${URL} ${PKG_DIR} ${PATCH1}
	download ${URL} ${PKG_DIR} ${PATCH2}
	mkdir -p $COMMAND_BASE/$CATEGORY/$PACKAGE-$VERSION/bin
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
	if [ -f $BUILD/$PACKAGE-$VERSION/README ] 
	then
		if [ ! -f $BUILD/$PACKAGE-$VERSION/SUCCESS.PATCHED ]
		then
			cd $BUILD/$PACKAGE-$VERSION &&
			patch -Np1 -i $SOURCE/$PKG_DIR/$PATCH1 &&
			patch -Np1 -i $SOURCE/$PKG_DIR/$PATCH2 &&

			sed -i 's@/proc@/system/processes@g' iptunnel.c &&
			sed -i 's@/proc@/system/processes@g' nameif.c &&
			sed -i 's@/proc@/system/processes@g' lib/pathnames.h &&
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
#			CFLAGS="-march=i386"
#			./configure \
#        	                --prefix=$COMMAND_BASE/$CATEGORY/$PACKAGE-$VERSION &&
#				--host=$CHOST --target=$CHOST &&
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
			cp arp        $COMMAND_BASE/$CATEGORY/$PACKAGE-$VERSION/bin &&
			cp hostname   $COMMAND_BASE/$CATEGORY/$PACKAGE-$VERSION/bin &&
			cp ifconfig   $COMMAND_BASE/$CATEGORY/$PACKAGE-$VERSION/bin &&
			cp nameif     $COMMAND_BASE/$CATEGORY/$PACKAGE-$VERSION/bin &&
			cp netstat    $COMMAND_BASE/$CATEGORY/$PACKAGE-$VERSION/bin &&
			cp rarp       $COMMAND_BASE/$CATEGORY/$PACKAGE-$VERSION/bin &&
			cp route      $COMMAND_BASE/$CATEGORY/$PACKAGE-$VERSION/bin &&
			cp plipconfig $COMMAND_BASE/$CATEGORY/$PACKAGE-$VERSION/bin &&
			cp slattach   $COMMAND_BASE/$CATEGORY/$PACKAGE-$VERSION/bin &&

#	                make install &&
			touch $BUILD/$PACKAGE-$VERSION/SUCCESS.INSTALL
		fi
	fi
}

complete()
{
	if [ -f $BUILD/$PACKAGE-$VERSION/SUCCESS.INSTALL ]
	then
		cd $BUILD/$PACKAGE-$VERSION
		rm -rf $BUILD/$PACKAGE-$VERSION/*
	fi
}

main $@
