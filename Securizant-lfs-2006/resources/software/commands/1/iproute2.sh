#!/tools/bin/bash
#
#       Copyright (c) 2004-2006 Daniel Robert Bradley. All rights reserved.
#

source /mnt/software/download.sh

COMMAND_BASE=/system/software/commands
CATEGORY=network
PACKAGE=iproute2
VERSION=2.6.16-060323
ARCHIVE=tar.gz
UNZIP=-z

URL=$RESOURCE_URL
PKG_DIR=core/commands
PKG=$PACKAGE-$VERSION.$ARCHIVE
#PATCH1=$PACKAGE-$VERSION-szt1.patch

DEST=$COMMAND_BASE/$CATEGORY/$PACKAGE-$VERSION

SOURCE=/mnt/source
BUILD=/mnt/build/commands

#CHOST=i386-pc-linux-gnu

main()
{
	echo Scripting $PACKAGE-$VERSION &&
	prepare                          &&
	unpack_package                   &&
	patch_package                    &&
	configure_package                &&
	make_package                     &&
	install_package                  &&
	complete
}

prepare()
{
	download ${URL} ${PKG_DIR} ${PKG} &&
	#download ${URL} ${PKG_DIR} ${PATCH1}
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
			sed -i "s|SBINDIR=/usr/sbin|SBINDIR=$DEST/sbin|"                                Makefile &&
			sed -i "s|CONFDIR=/etc/iproute2|CONFDIR=/local/settings/network/meta/iproute2|" Makefile &&
			sed -i "s|DOCDIR=/usr/share/doc/iproute2|DOCDIR=$DEST/share/doc/iproute2|"      Makefile &&
			sed -i "s|MANDIR=/usr/share/man|MANDIR=$DEST/share/man|"                        Makefile &&
			sed -i "s|DBM_INCLUDE:=/usr/include|DBM_INCLUDE:=/system/software/include|"     Makefile &&

			sed -i "s|/etc/iproute2|/local/settings/network/meta/iproute2|g"                lib/rt_names.c &&

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
	        make SBINDIR=$DEST/sbin &&
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
	        make SBINDIR=$DEST/sbin install &&
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
