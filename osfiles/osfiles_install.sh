#!/sbin/sh

set -x

mount /system

DEVICE=$(cat /system/build.prop | grep "ro.product.device=" | cut -d "=" -f2)

if [ "$DEVICE" == "GT-I8160" ] ; then
        DEVICE=codina
fi

if [ "$DEVICE" == "GT-I8160P" ] ; then
        DEVICE=codinap
fi

BUILD_ID=$(cat /system/build.prop | grep "ro.build.display.id=" | cut -d "=" -f2)
DEV_SCRIPT="init.samsungcodina.rc"
DEF_PROP="recovery_default.prop"

# skip osfiles installation on omni
IS_OMNI=$(echo $BUILD_ID | grep -c omni)

if [ $IS_OMNI == 1 ] ; then
	exit
fi 

VERSION_LINE=$(cat /system/build.prop | grep "ro.build.version.release" | cut -d "=" -f2)
VX=$(echo $VERSION_LINE | cut -d "." -f1)
VY=$(echo $VERSION_LINE | cut -d "." -f2)

ramdisk_path="/tmp/"
os=""
dev_files="/tmp/"$DEVICE

if [ $VX == 5 ] ; then
	if [ $VY == 0 ] ; then
		echo "5.0"
		os="5.0.x"
	fi

	if [ $VY == 1 ] ; then
		echo "5.1"
		os="5.1.x"
	fi
	
	ramdisk_path=/tmp/$os/$os.cpio.gz
	mv -f /ramdisk/$DEV_SCRIPT /ramdisk/$DEV_SCRIPT".bak"
	mv -f /ramdisk/$DEF_PROP /ramdisk/$DEF_PROP".bak"
	mv -f /ramdisk/init.u8500.rc /ramdisk/init.u8500.rc.bak
	cp -f /tmp/$os/$DEVICE/$DEV_SCRIPT /ramdisk
	cp $dev_files/$DEF_PROP /ramdisk
	cp /tmp/common/init.u8500.rc /ramdisk
	chmod 750 /ramdisk/init.u8500.rc
	chmod 750 /ramdisk/$DEV_SCRIPT
	chmod 644 /ramdisk/$DEF_PROP
	
	if ! test -f /system/etc/firmware ; then
		mkdir /system/etc/firmware
		chmod 755 /system/etc/firmware
	fi
	
	if ! test -f /system/etc/firmware/fw_bcmdhd.bin ; then
		ln -s /system/vendor/firmware/fw_bcmdhd.bin /system/etc/firmware/fw_bcmdhd.bin
	fi
	
	if ! test -f /system/etc/firmware/fw_bcmdhd_apsta.bin ; then
		ln -s /system/vendor/firmware/fw_bcmdhd_apsta.bin /system/etc/firmware/fw_bcmdhd_apsta.bin
	fi
fi

if [ $VX == 4 ] ; then
	if [ $VY == 4 ] ; then
		echo "4.4" ;
		ramdisk_path=$ramdisk_path"4.4.x/4.4.x.cpio.gz"
		mv -f /ramdisk/init.u8500.rc /ramdisk/init.u8500.rc.bak
		cp -f /tmp/common/init.u8500.rc /ramdisk
		chmod 750 /ramdisk/init.u8500.rc
	fi
	
	if [ $VY == 3 ] ; then
		echo "4.3" ;
		ramdisk_path=$ramdisk_path"4.3.x/4.3.x.cpio.gz"
	fi
	
	if [ $VY == 2 ] ; then
		echo "4.2" ;
		ramdisk_path=$ramdisk_path"4.2.x/4.2.x.cpio.gz"
	fi
	
	mv -f /ramdisk/$DEV_SCRIPT /ramdisk/$DEV_SCRIPT".bak"
	mv -f /ramdisk/$DEF_PROP /ramdisk/$DEF_PROP".bak"
	cp $dev_files/$DEV_SCRIPT /ramdisk
	cp $dev_files/$DEF_PROP /ramdisk
	chmod 750 /ramdisk/$DEV_SCRIPT
	chmod 644 /ramdisk/$DEF_PROP
	
	if [ $VY == 1 ] ; then
		echo "4.1" ;
		ramdisk_path=$ramdisk_path"4.1.x/4.1.x.cpio.gz"
		cp -f /tmp/4.1.x/$DEV_SCRIPT /ramdisk
		chmod 750 /ramdisk/$DEV_SCRIPT
	fi
fi

if test -f /ramdisk/boot.cpio.bak ; then
	rm /ramdisk/boot.cpio.bak
fi

#if test -f /ramdisk/boot.cpio ; then
#	mv -f /ramdisk/boot.cpio /ramdisk/boot.cpio.bak
#fi
#
#if test -f /ramdisk/boot.cpio.gz ; then
#	mv -f /ramdisk/boot.cpio.gz /ramdisk/boot.cpio.gz.bak
#fi

cp $ramdisk_path /ramdisk/boot.cpio.gz
