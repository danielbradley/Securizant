#!/tools/bin/bash
#
#       Copyright (c) 2004-2006 Daniel Robert Bradley. All rights reserved.
#

source /mnt/software/download.sh

LIBRARIES_BASE=/system/software/libraries
CATEGORY=math
PACKAGE=gmp
VERSION=6.1.2
ARCHIVE=tar.bz2
UNZIP=-j

URL=$RESOURCE_URL
PKG_DIR=core/libraries
PKG=$PACKAGE-$VERSION.$ARCHIVE

DEST=$LIBRARIES_BASE/$CATEGORY/$PACKAGE-$VERSION

SOURCE=/mnt/source
BUILD=/mnt/build/libraries

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
        mkdir -p $LIBRARIES_BASE/$CATEGORY/$PACKAGE-$VERSION
}

unpack_package()
{
	if [ ! -d $BUILD/$PACKAGE-$VERSION ]
	then
		download ${RESOURCE_URL} ${PKG_DIR} ${PKG}
		tar -C $BUILD -xvf ${SOURCE}/${PKG_DIR}/${PKG} $UNZIP
	fi
}

patch_package()
{
	if [ -f $BUILD/$PACKAGE-$VERSION/configure ] 
	then
		if [ ! -f $BUILD/$PACKAGE-$VERSION/SUCCESS.PATCHED ]
		then
			cd $BUILD/$PACKAGE-$VERSION &&
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
			./configure \
        	                --prefix=$LIBRARIES_BASE/$CATEGORY/$PACKAGE-$VERSION \
				--enable-cxx \
				--disable-static \
        	                --docdir=$LIBRARIES_BASE/$CATEGORY/$PACKAGE-$VERSION/share/doc/gmp-6.1.2
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
	                make      &&
	                make html &&
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
	                make install      &&
	                make install-html &&
			touch $BUILD/$PACKAGE-$VERSION/SUCCESS.INSTALL
		fi
	fi
}

complete()
{
	if [ -f $BUILD/$PACKAGE-$VERSION/SUCCESS.INSTALL ]
	then
		rm -rf $BUILD/$PACKAGE-$VERSION/*
	fi
}

main $@
