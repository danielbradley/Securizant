#!/tools/bin/bash
#
#       Copyright (c) 2004-2006 Daniel Robert Bradley. All rights reserved.
#

source /mnt/software/download.sh

COMMAND_BASE=/system/software/commands
CATEGORY=help
PACKAGE=man-db
VERSION=2.4.3
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
			cd $BUILD/$PACKAGE-$VERSION                        &&

			mv man/de{_DE.88591,}                              &&
			mv man/es{_ES.88591,}                              &&
			mv man/it{_IT.88591,}                              &&
			mv man/ja{_JP.eucJP,}                              &&

			sed -i 's@\*_\*@??@'             man/Makefile.in   &&

			sed -i '@\t\@usr\/man@d'         src/man_db.conf.in	&&

			#sed -i 's@-is@&R@g'              configure         &&
			#sed -i 's@/usr@@'                configure         &&
			#sed -i 's@MANPATH./usr/man@#&@g' src/man.conf.in   &&
			#sed -i 's#/usr/bin#@bindir@#' man2html/Makefile.in &&

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
			./configure \
				-confdir=/local/settings/software/commands/man \
				-prefix=$DEST \
				-bindir=$DEST/bin \
				-mandir=$DEST/man \
				-sbindir=$DEST/sbin \
				--enable-mb-groff \
				--disable-setuid &&
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
