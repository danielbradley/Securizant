#!/tools/bin/bash
#
#       Copyright (c) 2004-2006 Daniel Robert Bradley. All rights reserved.
#

source /mnt/software/download.sh

COMMAND_BASE=/system/software/commands
CATEGORY=utils
PACKAGE=util-linux
VERSION=2.12r
ARCHIVE=tar.bz2
UNZIP=-j

URL=$RESOURCE_URL
PKG_DIR=core/commands
PKG=$PACKAGE-$VERSION.$ARCHIVE
PATCH1=$PACKAGE-$VERSION-cramfs-1.patch
PATCH2=$PACKAGE-$VERSION-lseek-1.patch
PATCH3=$PACKAGE-$VERSION-configure1.patch

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
	download ${URL} ${PKG_DIR} ${PKG} &&
	download ${URL} ${PKG_DIR} ${PATCH1} &&
	download ${URL} ${PKG_DIR} ${PATCH2} &&
	download ${URL} ${PKG_DIR} ${PATCH3} &&
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
# LFS 6.1-1 (2.12q)
#			sed -i 's@etc/adjtime@var/lib/hwclock/adjtime@g' \
#				hwclock/hwclock.c &&
#			mkdir -p /var/lib/hwclock &&
#			patch -Np1 -i $SOURCE/$PACKAGE-$VERSION-cram*.patch &&
#			patch -Np1 -i $SOURCE/$PACKAGE-$VERSION-umou*.patch &&
#			sed -i 's/USE_TTY_GROUP=yes/USE_TTY_GROUP=no/' MCONFIG &&

# LFS 6.3 (2.12r)
			sed -e 's@etc/adjtime@var/lib/hwclock/adjtime@g' \
				-i $(grep -rl '/etc/adjtime' .)
			mkdir -pv /var/lib/hwclock

			patch -Np1 -i $SOURCE/$PKG_DIR/$PATCH1 &&
			patch -Np1 -i $SOURCE/$PKG_DIR/$PATCH2 &&
			
# SZT
			sed -i 's/root/system/' MCONFIG &&
			sed -i 's@chgrp@echo@g' misc-utils/Makefile
			patch -Np1 -i $SOURCE/$PKG_DIR/$PATCH3 &&

			sed -i 's@/proc@/system/processes@g' `grep  -l -R "/proc" *` &&

			#	Universal /etc --> /local/settings/lsb
			sed -i 's@/etc@/local/settings/lsb@g' `grep -l -R "/etc" *` &&

			#	Universal /dev --> /system/devices in .h,.c
			sed -i 's|/dev|/system/devices|g' `grep -l -R "/dev" *` &&

			local ProcFiles=`find . -name ".h"` &&
			ProcFiles=$ProcFiles `find . -name ".c"` &&
			if [ -n "$ProcFiles" ]
			then
				sed -i 's|/proc|/system/processes|g' $ProcFiles
			fi
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
			DESTDIR=$COMMAND_BASE/$CATEGORY/$PACKAGE-$VERSION
			CPPFLAGS=-I/system/software/include/ncurses
			export DESTDIR CPPFLAGS
			./configure &&
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
	                make HAVE_KILL=yes HAVE_SLN=yes &&
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
	                make HAVE_KILL=yes HAVE_SLN=yes install &&
			ln -s ../bin/mount $DESTDIR/sbin/mount &&
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
