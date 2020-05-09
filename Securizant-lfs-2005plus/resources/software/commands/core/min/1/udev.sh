#!/tools/bin/bash

source /mnt/software/download.sh
source /mnt/software/altersource.sh

COMMAND_BASE=/system/software/commands
CATEGORY=system
PACKAGE=udev
VERSION=096
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
	if [ -f $BUILD/$PACKAGE-$VERSION/README ] 
	then
		if [ ! -f $BUILD/$PACKAGE-$VERSION/SUCCESS.PATCHED ]
		then
			cd $BUILD/$PACKAGE-$VERSION &&

			#
			#	Modify Makefile to not make assumptions
			#
			sed -i 's@/usr/bin/install@install@g' Makefile     &&
			sed -i 's/killall/echo killall/'      Makefile     &&

			#	overkill for now, use sed instead to
			#	replace /sys in source files
			#
			#altersource "." "/sys" "/system/mounts/SYS" ".c"
			sed -i 's|/sys|/system/mounts/SYS|g'  udev_sysfs.c &&

			#	use altersource to replace legacy assumptions in rules
			#
			#
			altersource "etc" "/sys"     "/system/mounts/SYS"      ".rules" &&
			altersource "etc" "/bish/sh" "/system/software/bin/sh" ".rules" &&
			
			sed -i 's|/sys|/system/mounts/SYS|g' libsysfs/sysfs/libsysfs.h  &&

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
	        make prefix=$DEST udevdir=/system/devices &&
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
	        make prefix=$DEST udevdir=/system/devices install &&
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
