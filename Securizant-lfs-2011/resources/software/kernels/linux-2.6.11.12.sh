#!/tools/bin/bash
#
#       Copyright (c) 2004-2006 Daniel Robert Bradley. All rights reserved.
#

source /mnt/software/download.sh

KERNELS_BASE=/system/software/kernels
KERNELS_SOURCE=/system/software/source/kernels
CATEGORY=
PACKAGE=linux
VERSION=2.6.11.12
ARCHIVE=tar.bz2
UNZIP=-j

URL=$RESOURCE_URL
PKG_DIR=core/kernels
PKG=$PACKAGE-$VERSION.$ARCHIVE
PKG2_DIR=core/commands
PKG2=squashfs-3.3.tar.gz
PATCH1=${PACKAGE}-${VERSION}-config4.patch &&

DEST=$COMMAND_BASE/$CATEGORY/$PACKAGE-$VERSION

SOURCE=/mnt/source
BUILD=/mnt/build/kernels

export LC_ALL=POSIX
export CHOST=i386-pc-linux-gnu

main()
{
	echo Scripting $PACKAGE &&
	prepare &&
	unpack_package &&

	patch_package &&
#	make_mrproper &&
	make_config &&
	make_dep &&
	make_bzimage &&
	make_install &&
	make_modules &&
	make_modules_install &&
	complete &&
	/system/software/sbin/depmod &&
	echo "Done: Kernels"
}

prepare()
{
	download ${URL} ${PKG_DIR} ${PKG}                 &&
	download ${URL} ${PKG_DIR} linux-2.6.11.12.config &&
	download ${URL} ${PKG2_DIR} ${PKG2}               &&
	download ${URL} ${PKG_DIR} ${PATCH1}              &&
	mkdir -p $BUILD/${PACKAGE}-${VERSION}-STATE       &&
	return
}

unpack_package()
{
	if [ ! -d $BUILD/$PACKAGE-$VERSION ]
	then
		tar -C $BUILD -xvf $SOURCE/$PKG_DIR/$PKG $UNZIP &&
		tar -C $BUILD -xvf $SOURCE/$PKG2_DIR/$PKG2 -z
	fi
}

patch_package()
{
	if [ -f $BUILD/$PACKAGE-$VERSION/README ] 
	then
		if [ ! -f $BUILD/${PACKAGE}-${VERSION}-STATE/SUCCESS.PATCHED ]
		then
			cd $BUILD/$PACKAGE-$VERSION                                                         &&
			patch -Np1 -i $BUILD/squashfs-3.3/kernel-patches/linux-2.6.12/squashfs3.3-patch     &&
			patch -Np1 -i $SOURCE/$PKG_DIR/$PATCH1                                              &&
			sed -i 's@static int max_loop = 8@static int max_loop = 255@g' drivers/block/loop.c &&
			cp .config  .config.dan.bak                                                         &&
			cp $SOURCE/$PKG_DIR/linux-2.6.11.12.config .config                                  &&
			touch $BUILD/${PACKAGE}-${VERSION}-STATE/SUCCESS.PATCHED
		fi
	fi
}

make_mrproper()
{
	if [ -f $BUILD/${PACKAGE}-${VERSION}-STATE/SUCCESS.PATCHED ]
	then
		if [ ! -f 
		$BUILD/${PACKAGE}-${VERSION}-STATE/SUCCESS.MRPROPER_ONE ]
		then
			cd $BUILD/$PACKAGE-$VERSION &&

			make mrproper
			touch $BUILD/${PACKAGE}-${VERSION}-STATE/SUCCESS.MRPROPER_ONE
		fi
	fi
}

make_config()
{
	if [ -f $BUILD/${PACKAGE}-${VERSION}-STATE/SUCCESS.PATCHED ]
	then
		if [ ! -f $BUILD/${PACKAGE}-${VERSION}-STATE/SUCCESS.CONFIG ]
		then
			cd $BUILD/$PACKAGE-$VERSION &&

			if [ -f ./.config ]
			then
				make oldconfig &&
				touch $BUILD/${PACKAGE}-${VERSION}-STATE/SUCCESS.CONFIG
			else
				make menuconfig &&
				touch $BUILD/${PACKAGE}-${VERSION}-STATE/SUCCESS.CONFIG
			fi
		fi
	fi
}

make_dep()
{
	if [ -f $BUILD/${PACKAGE}-${VERSION}-STATE/SUCCESS.CONFIG ]
	then
		if [ ! -f $BUILD/${PACKAGE}-${VERSION}-STATE/SUCCESS.DEP ]
		then
			cd $BUILD/$PACKAGE-$VERSION &&
			make dep &&
			touch $BUILD/${PACKAGE}-${VERSION}-STATE/SUCCESS.DEP
		fi
	fi
}

make_bzimage()
{
	set > $BUILD/${PACKAGE}-${VERSION}-STATE/set.txt &&
	if [ -f $BUILD/${PACKAGE}-${VERSION}-STATE/SUCCESS.DEP ]
	then
		if [ ! -f $BUILD/${PACKAGE}-${VERSION}-STATE/SUCCESS.BZIMAGE ]
		then
			cd $BUILD/$PACKAGE-$VERSION &&
			make bzImage &&
			touch $BUILD/${PACKAGE}-${VERSION}-STATE/SUCCESS.BZIMAGE
		fi
	fi
}

make_install()
{
	if [ -f $BUILD/${PACKAGE}-${VERSION}-STATE/SUCCESS.BZIMAGE ]
	then
		if [ ! -f $BUILD/${PACKAGE}-${VERSION}-STATE/SUCCESS.INSTALL ]
		then
			cd $BUILD/$PACKAGE-$VERSION &&
			#cp -Rp . /usr/source/linux-${VERSION}
			cp arch/i386/boot/bzImage /$KERNELS_BASE/${PACKAGE}-${VERSION} &&
			cp arch/i386/boot/bzImage /$KERNELS_BASE/${PACKAGE}-kernel &&
			touch $BUILD/${PACKAGE}-${VERSION}-STATE/SUCCESS.INSTALL
		fi
	fi
}

make_modules()
{
	if [ -f $BUILD/${PACKAGE}-${VERSION}-STATE/SUCCESS.INSTALL ]
	then
		if [ ! -f $BUILD/${PACKAGE}-${VERSION}-STATE/SUCCESS.MODULES ]
		then
			cd $BUILD/$PACKAGE-$VERSION &&
			make modules &&
			touch $BUILD/${PACKAGE}-${VERSION}-STATE/SUCCESS.MODULES
		fi
	fi
}

make_modules_install()
{
	if [ -f $BUILD/${PACKAGE}-${VERSION}-STATE/SUCCESS.MODULES ]
	then
		if [ ! -f $BUILD/${PACKAGE}-${VERSION}-STATE/SUCCESS.MODULES_INSTALL ]
		then
			cd $BUILD/$PACKAGE-$VERSION &&
			make modules_install &&
			touch $BUILD/${PACKAGE}-${VERSION}-STATE/SUCCESS.MODULES_INSTALL
		fi
	fi

}

complete()
{
	if [ -f $BUILD/${PACKAGE}-${VERSION}-STATE/SUCCESS.MODULES ]
	then
		echo rm -rf $BUILD/${PACKAGE}-${VERSION}/* /dev/null
		mkdir $KERNELS_SOURCE/$PACKAGE-$VERSION
		cp -Rp $BUILD/${PACKAGE}-${VERSION} $KERNELS_SOURCE
		rm -rf $BUILD/squashfs*
	fi
}

main $@
