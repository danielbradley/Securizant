#!/tools/bin/bash
#
#       Copyright (c) 2004-2006 Daniel Robert Bradley. All rights reserved.
#

source /mnt/software/download.sh

CATEGORY=toolchain

PACKAGE=glibc
VERSION=2.3.4
ARCHIVE=tar.bz2
UNZIP=-j

URL=$RESOURCE_URL
PKG_DIR=core/toolchain
PKG=$PACKAGE-$VERSION.$ARCHIVE
PKG2=$PACKAGE-linuxthreads-$VERSION.$ARCHIVE
PATCH1=glibc-2.3.4-rtld_search_dirs-1.patch
PATCH2=glibc-2.3.4-fix_test-1.patch
PATCH3=glibc-2.3.4-tls_assert-1.patch

SOURCE=/mnt/source
BUILD=/mnt/build/toolchain

#CHOST=i386-pc-linux-gnu

#  Executables used
GREP=/tools/bin/grep
TOUCH=/tools/bin/touch
RM=/tools/bin/rm

echo "URL: $URL"

main()
{
	echo "URL2: $URL"
	copy_kernel_headers &&
	setup &&
	unpack_package &&
	apply_patches &&
	configure_source &&
	compile_source &&
	install_package &&
	install_locales &&
	activate_package &&
	complete &&
#	overwrite_ldsoconf
	echo
}

copy_kernel_headers()
{
	if [ ! -d /system/software/source/linux/include/asm ]
	then
		mkdir -p /system/software/source/linux/include/asm
		cp -Rf /tools/include/asm         /system/software/source/linux/include
		cp -Rf /tools/include/linux       /system/software/source/linux/include
		chown -R 100:1000 /system/software/source/linux
	fi
}

setup()
{
	echo "URL3: $URL"
	download ${URL} ${PKG_DIR} ${PKG}
	download ${URL} ${PKG_DIR} ${PKG2}
	download ${URL} ${PKG_DIR} ${PATCH1}
	download ${URL} ${PKG_DIR} ${PATCH2}
	download ${URL} ${PKG_DIR} ${PATCH3}

	mkdir -p /system/software/runtimes/GNU/${PACKAGE}-${VERSION}/etc
	touch /system/software/runtimes/GNU/${PACKAGE}-${VERSION}/etc/ld.so.conf
}

unpack_package()
{
	if [ ! -d $BUILD/$PACKAGE-$VERSION ]
	then
		tar -C $BUILD -xvf $SOURCE/${PKG_DIR}/${PKG} $UNZIP
		tar -C $BUILD/$PACKAGE-$VERSION -xvf $SOURCE/${PKG_DIR}/${PKG2} $UNZIP
	fi
}

apply_patches()
{
	if [ -f $BUILD/$PACKAGE-$VERSION/configure ]
	then
		if [ ! -f $BUILD/$PACKAGE-$VERSION/SUCCESS.PATCHED ]
		then
			cd $BUILD/$PACKAGE-$VERSION &&
			patch -Np1 -i $SOURCE/${PKG_DIR}/${PATCH1}
			patch -Np1 -i $SOURCE/${PKG_DIR}/${PATCH2}
			patch -Np1 -i $SOURCE/${PKG_DIR}/${PATCH3}

			# Modify paths.h
			
			sed -i 's@/etc@/local/settings/lsb@g' sysdeps/unix/sysv/linux/paths.h &&
			sed -i 's@/var@/local/data/_system@g' sysdeps/unix/sysv/linux/paths.h &&

			sed -i 's@/usr/bin@!!!BINDIR!!!@g' sysdeps/unix/sysv/linux/paths.h &&
			sed -i 's@/usr/sbin@!!!SBINDIR!!!!@g' sysdeps/unix/sysv/linux/paths.h &&

			sed -i 's@/bin@!!!BINDIR!!!@g' sysdeps/unix/sysv/linux/paths.h &&
			sed -i 's@/sbin@!!!SBINDIR!!!@g' sysdeps/unix/sysv/linux/paths.h &&

			sed -i 's@!!!BINDIR!!!@/system/software/bin@g' sysdeps/unix/sysv/linux/paths.h &&
			sed -i 's@!!!SBINDIR!!!@/system/software/sbin@g' sysdeps/unix/sysv/linux/paths.h &&

#			sed -i 's@/dev/@/system/devices/@g' sysdeps/unix/sysv/linux/paths.h &&
			sed -i 's@/tmp@/system/mounts/TEMP@g' sysdeps/unix/sysv/linux/paths.h &&
			sed -i 's@/proc/@/system/processes/@g' sysdeps/unix/sysv/linux/paths.h &&

			sed -i 's@/usr/share/man@/system/software/share/man@g' sysdeps/unix/sysv/linux/paths.h &&
			sed -i 's@/boot/vmlinux@/system/software/kernels/linux-kernel@g' sysdeps/unix/sysv/linux/paths.h &&

			# Nuke-style modification of everything else
			
			local Dev="`find . -name "*.c"` `find . -name "*.h"`"
			local Etc=`grep -l -R "/etc"  *` &&
			local Var=`grep -l -R "/var"  *` &&
			local Pro=`grep -l -R "/proc" *` &&

			replace_with_in "/dev" "/system/devices" "${Dev}"

			#if [ -n "$Dev" ]
			#then
			#	sed -i 's@/dev@/system/devices@g' $Dev
			#fi

			if [ -n "$Etc" ]
			then
				sed -i 's@/etc@/local/settings/lsb@g' $Etc
			fi
			
			#if [ -n "$Pro" ]
			#then
			#	sed -i 's|/proc|/system/processes|g' $Pro
			#fi

			#if [ -n "$Var" ]
			#then
			#	sed -i 's@/var@/local/sysdata@g' $Var
			#fi

			touch $BUILD/$PACKAGE-$VERSION/SUCCESS.PATCHED
		fi
	fi
	return 0
}

replace_with_in()
{
	local Find="$1"
	local Replace="$2"
	local Files="$3"

	local Pattern="s|${Find}|${Replace}|g"

	for File in ${Files}
	do
		sed -i ${Pattern} ${File}
	done
}

configure_source()
{
	if [ -f $BUILD/$PACKAGE-$VERSION/SUCCESS.PATCHED ]
	then
		if [ ! -f $BUILD/glibc-build/SUCCESS.CONFIGURE ]
		then
			mkdir -p $BUILD/glibc-build &&
			cd $BUILD/glibc-build &&

#			CFLAGS="-mcpu=i386 -O2"
				../$PACKAGE-$VERSION/configure \
				--prefix=/system/software/runtimes/GNU/$PACKAGE-$VERSION \
				--disable-profile \
				--enable-add-ons \
				--enable-kernel=2.6.0 \
				--with-binutils=/tools/bin \
				--without-gd \
				--with-headers=/system/software/source/linux/include \
				--without-selinux \
				--sysconfdir=/local/settings/system/meta \
				--localstatedir=/local/data/_system
				
#				--sysconfdir=/local/settings    #Szt extra
#				--build=$CHOST --host=$CHOST --target=$CHOST &&
			touch $BUILD/glibc-build/SUCCESS.CONFIGURE
#		else
#			echo CFLAGS="-mcpu=i386 -O2" ../$PACKAGE/configure \
#				--prefix=/system/software/software/runtimes/GNU/$PACKAGE \
#				--sysconfdir=/local/settings \
#				--with-headers=/system/software/source/linux/include \
#				--enable-add-ons \
#				--disable-profile \
#				--build=$CHOST --host=$CHOST --target=$CHOST
		fi
	fi
}

compile_source()
{
	if [ -f $BUILD/glibc-build/SUCCESS.CONFIGURE ]
	then
		if [ ! -f $BUILD/glibc-build/SUCCESS.COMPILE ]
		then
			cd $BUILD/glibc-build &&
			make > /mnt/log/${PACKAGE}-$VERSION.log 2>&1 &&
#			make -k check >glibc-check-log 2>&1
			touch $BUILD/glibc-build/SUCCESS.COMPILE
		fi
	fi
}

install_package()
{
	if [ -f $BUILD/glibc-build/SUCCESS.COMPILE ]
	then
		if [ ! -f $BUILD/glibc-build/SUCCESS.INSTALL ]
		then
			cd $BUILD/glibc-build &&
			make install > /mnt/log/${PACKAGE}-$VERSION-install.log 2>&1 &&
			touch $BUILD/glibc-build/SUCCESS.INSTALL
		fi
	fi
}

install_locales()
{
	if [ -f $BUILD/glibc-build/SUCCESS.INSTALL ]
	then
		if [ ! -f $BUILD/glibc-build/SUCCESS.LOCALES ]
		then
			cd $BUILD/glibc-build &&
			make localedata/install-locales > /mnt/log/${PACKAGE}-$VERSION-locales.log &&		
			touch $BUILD/glibc-build/SUCCESS.LOCALES
		fi
	fi
}

activate_package()
{
	if [ -f $BUILD/glibc-build/SUCCESS.LOCALES ]
	then
		if [ ! -f $BUILD/glibc-build/SUCCESS.ACTIVATE ]
		then
			activate -li /system/software/runtimes/GNU/$PACKAGE-$VERSION &&
			chown -R 100:1000 /system/software/runtimes/GNU
		fi
		touch $BUILD/glibc-build/SUCCESS.ACTIVATE
	fi
}

complete()
{
	if [ -f $BUILD/glibc-build/SUCCESS.ACTIVATE ]
	then
		rm -rf $BUILD/$PACKAGE-$VERSION/*
		rm -rf $BUILD/glibc-build/*
	fi
}

overwrite_ldsoconf()
{
#	LD_SO_CONF=`grep "/system/software/lib" /etc/ld.so.conf` &&
#	if [ -z $LD_SO_CONF ]
#	then

#cat > /etc/ld.so.conf << "EOF"
#/system/software/software/lib
#/system/software/X11R6/lib
#/system/software/X11R6/software/lib
#EOF

#fi
	echo "overwrite_ldsoconf deprecated"
}

main $@
