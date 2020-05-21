#!/tools/bin/bash
#
#       Copyright (c) 2004-2006 Daniel Robert Bradley. All rights reserved.
#

source /mnt/software/download.sh

GNU_BASE=/system/software/commands
CATEGORY=development
PACKAGE=gcc
VERSION=4.0.3
DNAME=gnu-4.0.3
ARCHIVE=tar.bz2
UNZIP=-j

URL=$RESOURCE_URL
PKG_DIR=core/toolchain
PKG=$PACKAGE-$VERSION.$ARCHIVE

SOURCE=/mnt/source
BUILD=/mnt/build/toolchain

#CHOST=i386-pc-linux-gnu

#  Executables used
GREP=/tools/software/bin/grep
TOUCH=/tools/software/bin/touch
RM=/tools/software/bin/rm

main()
{
	setup            &&
	unpack_package   &&
	apply_patches    &&
	configure_source &&
	compile_source   &&
	install_package  &&
	modify_package   &&
	complete
}

setup()
{
	download ${URL} ${PKG_DIR} ${PKG}
}

unpack_package()
{
	if [ ! -d $BUILD/$PACKAGE-$VERSION ]
	then
		tar -C $BUILD -xvf ${SOURCE}/${PKG_DIR}/${PKG} $UNZIP
	fi
}

apply_patches()
{
	if [ -f $BUILD/$PACKAGE-$VERSION/configure ]
	then
		if [ ! -f $BUILD/$PACKAGE-$VERSION/SUCCESS.PATCH ]
		then
			cd $BUILD/$PACKAGE-$VERSION &&
			sed -i 's/install_to_$(INSTALL_DEST) //'       libiberty/Makefile.in &&
			sed -i 's/^XCFLAGS =$/& -fomit-frame-pointer/'       gcc/Makefile.in &&
			sed -i 's@\./fixinc\.sh@-c true@'                    gcc/Makefile.in &&
			sed -i 's/@have_mktemp_command@/yes/'                gcc/gccbug.in   &&
			touch $BUILD/$PACKAGE-$VERSION/SUCCESS.PATCH
		fi
	fi
}

configure_source()
{
	if [ -f $BUILD/$PACKAGE-$VERSION/SUCCESS.PATCH ]
	then

		if [ ! -f $BUILD/$PACKAGE-$VERSION/SUCCESS.CONFIGURE ]
		then
			mkdir -p $BUILD/$PACKAGE-build &&
			cd $BUILD/$PACKAGE-build &&
#			CFLAGS="-march=i386" CXXFLAGS="-march=i386" \
			../$PACKAGE-$VERSION/configure \
				--prefix=$GNU_BASE/$CATEGORY/$DNAME \
				--with-sysroot=/system/softwware/lib \
				--with-native-system-header-dir=/system/software/lib \
				--libexecdir=/system/software/commands/development/gnu-${VERSION}/libexec \
				--enable-shared \
				--enable-threads=posix \
				--enable-__cxa_atexit \
				--enable-clocale=gnu \
				--enable-languages=c,c++ \
				--with-local-prefix=/local/software &&
#				--host=$CHOST --target=$CHOST
			touch $BUILD/$PACKAGE-$VERSION/SUCCESS.CONFIGURE
		fi
	fi
}

compile_source()
{
	if [ -f $BUILD/$PACKAGE-$VERSION/SUCCESS.CONFIGURE ]
	then
		if [ ! -f $BUILD/$PACKAGE-$VERSION/SUCCESS.COMPILE ]
		then
			cd $BUILD/$PACKAGE-build
			make LDFLAGS="-Wl,--dynamic-linker,/system/software/lib/ld-linux.so.2" &&
			touch $BUILD/$PACKAGE-$VERSION/SUCCESS.COMPILE
		fi
	fi
}

install_package()
{
	if [ -f $BUILD/$PACKAGE-$VERSION/SUCCESS.COMPILE ]
	then
		if [ ! -f $BUILD/$PACKAGE-$VERSION/SUCCESS.INSTALL ]
		then
			cd $BUILD/$PACKAGE-build &&
			make install &&
#			mkdir -p /system/software/libraries/gnu/g++-3.3.1/lib &&
#                        cp /system/software/Applications/development/gnu-3.3.1/lib/libstdc++* \
#                                /system/software/libraries/gnu/g++-3.3.1/lib &&
			ln -sf gcc $GNU_BASE/$CATEGORY/$DNAME/bin/cc &&

			touch $BUILD/$PACKAGE-$VERSION/SUCCESS.INSTALL
		fi
	fi
}

modify_package()
{
	local GCC="$GNU_BASE/$CATEGORY/$DNAME/bin/gcc"
	local FILENAME=`${GCC}  -print-libgcc-file-name`
	local SPECFILEDIR=`dirname $FILENAME`
	local SPECFILE="$SPECFILEDIR/specs"

	if [ -f $BUILD/$PACKAGE-$VERSION/SUCCESS.INSTALL ]
	then
		if [ ! -f $BUILD/$PACKAGE-$VERSION/SUCCESS.MODIFY ]
		then
			cd $BUILD/$PACKAGE-build &&
			$GCC -dumpspecs                                                    > "$SPECFILE" &&
			sed  -i 's@^/lib/ld-linux.so.2@/system/software/lib/ld-linux.so.2@g' "$SPECFILE" &&
			#sed -i '/\*startfile_prefix_spec:/{n;s@.*@/system/software/lib/ @}' "$SPECFILE" &&
			#sed -i '/\*cpp:/{n;s@$@ -isystem /system/software/include@}'        "$SPECFILE" &&

			touch $BUILD/$PACKAGE-$VERSION/SUCCESS.MODIFY
		fi
	fi
}

complete()
{
	if [ -f $BUILD/$PACKAGE-$VERSION/SUCCESS.MODIFY ]
	then
		rm -rf $BUILD/$PACKAGE-$VERSION/*
		rm -rf $BUILD/$PACKAGE-build/*
		chown -R 100:1000 $GNU_BASE/$CATEGORY/$DNAME
	fi
}

main $@

