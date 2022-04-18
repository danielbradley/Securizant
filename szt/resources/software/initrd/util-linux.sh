#!/tools/bin/bash
#
#       Copyright (c) 2004-2006 Daniel Robert Bradley. All rights reserved.
#

source /mnt/software/download.sh

INITRD_BASE=/mnt/initrd
CATEGORY=utils
PACKAGE=util-linux
VERSION=2.12q
ARCHIVE=tar.bz2
UNZIP=-j

URL=$RESOURCE_URL
PKG_DIR=core/commands
PKG=$PACKAGE-$VERSION.$ARCHIVE
PATCH1=$PACKAGE-$VERSION-cramfs-1.patch
PATCH2=$PACKAGE-$VERSION-umount_fix-1.patch

DEST=$INITRD_BASE

SOURCE=/mnt/source
BUILD=/mnt/build/initrd

#CHOST=i386-pc-linux-gnu

main()
{
	echo "Scripting $PACKAGE-$VERSION (initrd)" &&
	prepare &&
	unpack_package &&
	patch_package &&
	configure_package &&
	make_package &&
	install_package &&
	complete
	copy_exes
}

prepare()
{
	download "${URL}" "${PKG_DIR}" "${PKG}"
	download "${URL}" "${PKG_DIR}" "${PATCH1}"
	download "${URL}" "${PKG_DIR}" "${PATCH2}"
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
#			sed -i 's@etc/adjtime@var/lib/hwclock/adjtime@g' \
#				hwclock/hwclock.c &&
#			mkdir -p /var/lib/hwclock &&
			patch -Np1 -i $SOURCE/$PKG_DIR/$PATCH1 &&
			patch -Np1 -i $SOURCE/$PKG_DIR/$PATCH2 &&
			sed -i 's/USE_TTY_GROUP=yes/USE_TTY_GROUP=no/' MCONFIG &&
			sed -i 's/root/system/' MCONFIG &&
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
			DESTDIR=$INITRD_BASE
			MANDIR=$INITRD_BASE/man
			#CPPFLAGS=-I/usr/software/include
			LDFLAGS="-static"
			export DESTDIR MANDIR CPPFLAGS LDFLAGS
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
			make
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
			make install
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

copy_exes()
{
	if [ -f $INITRD_BASE/bin/mount ]
	then
		cp $INITRD_BASE/bin/{mount,umount} \
			/system/mounts/INITRD/bin
		cp $INITRD_BASE/sbin/pivot_root \
			/system/mounts/INITRD/bin
	fi
}

main $@
