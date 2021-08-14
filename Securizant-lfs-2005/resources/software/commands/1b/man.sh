#!/tools/bin/bash
#
#       Copyright (c) 2004-2006 Daniel Robert Bradley. All rights reserved.
#

source /mnt/software/download.sh

COMMAND_BASE=/system/software/commands
CATEGORY=help
PACKAGE=man
VERSION=1.5p
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
	if [ -f $BUILD/$PACKAGE-$VERSION/configure ] 
	then
		if [ ! -f $BUILD/$PACKAGE-$VERSION/SUCCESS.PATCHED ]
		then
			cd $BUILD/$PACKAGE-$VERSION &&
			sed -i 's@-is@&R@g' configure &&
			sed -i 's@MANPATH./usr/man@#&@g' src/man.conf.in &&
			sed -i 's@/usr@@' configure &&
			sed -i 's#/usr/bin#@bindir@#' man2html/Makefile.in &&
			sed -i 's#/bin/sh#/system/software/bin/sh#' configure &&
			sed -i 's#/bin/sh#/system/software/bin/sh#' man2html/scripts/cgi-bin/man/mansearch &&
			sed -i 's#/bin/sh#/system/software/bin/sh#' man2html/scripts/cgi-bin/man/mansearchhelp &&
			sed -i 's#/bin/sh#/system/software/bin/sh#' man2html/scripts/cgi-bin/man/man2html &&
			sed -i 's#/bin/sh#/system/software/bin/sh#' man2html/hman.sh &&
			sed -i 's#/bin/sh#/system/software/bin/sh#' msgs/gencat207fix.sh &&
			sed -i 's#/bin/sh#/system/software/bin/sh#' msgs/inst.sh &&
			sed -i 's#/bin/sh#/system/software/bin/sh#' src/man2dvi &&
			sed -i 's#/bin/sh#/system/software/bin/sh#' src/mwi &&
			sed -i 's#/bin/sh#/system/software/bin/sh#' src/apropos.sh &&
			sed -i 's#/bin/sh#/system/software/bin/sh#' src/makewhatis.sh &&
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
			./configure -confdir=/local/settings/software/commands/man \
				-prefix=$DEST \
				-bindir=$DEST/bin \
				-mandir=$DEST/man \
				-sbindir=$DEST/sbin &&
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
