#!/tools/bin/bash
#
#       Copyright (c) 2004-2006 Daniel Robert Bradley. All rights reserved.
#

source /mnt/software/download.sh

COMMAND_BASE=/system/software/commands
CATEGORY=system
PACKAGE=sysvinit
VERSION=2.86
ARCHIVE=tar.bz2
UNZIP=-j

URL=$RESOURCE_URL
PKG_DIR=core/commands
PKG=$PACKAGE-$VERSION.$ARCHIVE
PATCH=$PACKAGE-$VERSION-szt-args.patch

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
	download ${URL} ${PKG_DIR} ${PATCH}
	mkdir -p $DEST/{bin,include,sbin,man/{man1,man5,man8}}
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

			patch -Np1 -i ${SOURCE}/${PKG_DIR}/${PACKAGE}-${VERSION}-szt-args.patch     &&
			sed -i 's@Sending processes@& started by init@g'               src/init.c   &&
			sed -i 's@/usr/share/man@/man@g'                               src/Makefile &&
			sed -i 's/$(BIN_OWNER)/system/'                                src/Makefile &&
			sed -i 's/$(BIN_GROUP)/users/'                                 src/Makefile &&
			sed -i 's@/usr@@g'                                             src/Makefile &&
			sed -i 's@/etc/inittab@/system/startup/configuration/inittab@' src/paths.h  &&
			sed -i 's@/var/run@/system/mounts/TEMP/runstate/run@'          src/paths.h  &&
			sed -i 's@/sbin@/system/software/sbin@g'                       src/paths.h src/halt.c src/init.c src/killall5.c &&

			# Replace PATH in key files
			sed -i 's@PATH=/bin:/usr/bin:/sbin:/usr/sbin@PATH=/system/software/bin:/system/software/sbin@g' src/init.h src/initscript.sample src/shutdown.c &&

			# Replace /bin/xxx in several files
			sed -i 's|/bin/sh|/system/software/bin/sh|g'    `grep -l -R "/bin/sh" *`    &&
			sed -i 's|/bin/mount|/system/software/bin/sh|g' `grep -l -R "/bin/mount" *` &&
			sed -i 's|/etc|/local/settings/lsb|g'           `grep -l -R "/etc" *`       &&
			sed -i 's|/dev|/system/devices|g'               `grep -l -R "/dev" *`       &&

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
	                make ROOT=/system/software/commands/system/sysvinit-2.86 \
				-C src &&
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
	                make ROOT=/system/software/commands/system/sysvinit-2.86 \
				-C src install &&
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
