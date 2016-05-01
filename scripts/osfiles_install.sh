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

IS_OMNI=$(echo $BUILD_ID | grep -c omni)
IS_ULTI=$(echo $BUILD_ID | grep -c ulti)

VERSION_LINE=$(cat /system/build.prop | grep "ro.build.version.release" | cut -d "=" -f2)
VX=$(echo $VERSION_LINE | cut -d "." -f1)
VY=$(echo $VERSION_LINE | cut -d "." -f2)
os="$VX.$VY.x"

if test -f /ramdisk/.dont_touch_ramdisk ; then
	echo "file /ramdisk/.dont_touch_ramdisk found, not installing osfiles"
	exit 0
fi

if [ $IS_OMNI == 1 ] && [ "$os" == "5.1.x" ] ; then
		echo "Omni ROM has been detected" >> /tmp/kernel_log.txt
		os="5.1.x_omni"
fi

if [ $IS_ULTI == 1 ] && [ "$os" == "6.0.x" ] ; then
		echo "Ultimate ROM has been detected" >> /tmp/kernel_log.txt
		os="6.0.x_ulti"
fi

ramdisk_path="/tmp/"
dev_files="/tmp/"$DEVICE


##### Unpack ramdisk.7z #####

cur_dir=$PWD

cd /tmp
rm -fr /tmp/4.*.x* /tmp/5.*.x* /tmp/6.*.x* /tmp/codina* /tmp/common
rm -fr /tmp/osfiles /tmp/recovery /tmp/twrp.fstab
/tmp/7za x ramdisk.7z osfiles/common osfiles/codina osfiles/codinap osfiles/$os recovery/twrp.fstab
mv osfiles/* .
mv /tmp/recovery/twrp.fstab /tmp/twrp.fstab

cd $cur_dir

##### Unpack ramdisk.7z #####



if [ $VX == 6 ] ; then
	if [ $VY == 0 ] ; then
		echo "6.0"
        fi

	if test -f /system/lib/modules/uid_cputime.ko ; then
		mv /system/lib/modules/uid_cputime.ko /ramdisk/modules/autoload
	fi
	ramdisk_path=/tmp/$os/$os.cpio

	rm /ramdisk/.use_sdcardfs
	touch /ramdisk/.use_ramdisk_fstab
fi

if [ $VX == 5 ] ; then
	if [ $VY == 0 ] ; then
		echo "5.0"
	fi

	if [ $VY == 1 ] ; then
		echo "5.1"
	fi

	ramdisk_path=/tmp/$os/$os.cpio
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

	touch /ramdisk/.use_sdcardfs
	touch /ramdisk/.use_ramdisk_fstab
fi

if [ $VX == 4 ] ; then
	if [ $VY == 4 ] ; then
		echo "4.4" ;
		ramdisk_path=$ramdisk_path"4.4.x/4.4.x.cpio"
		mv -f /ramdisk/init.u8500.rc /ramdisk/init.u8500.rc.bak
		cp -f /tmp/common/init.u8500.rc /ramdisk
		chmod 750 /ramdisk/init.u8500.rc
	fi
	
	if [ $VY == 3 ] ; then
		echo "4.3" ;
		ramdisk_path=$ramdisk_path"4.3.x/4.3.x.cpio"
	fi
	
	if [ $VY == 2 ] ; then
		echo "4.2" ;
		ramdisk_path=$ramdisk_path"4.2.x/4.2.x.cpio"
	fi
	
	mv -f /ramdisk/$DEV_SCRIPT /ramdisk/$DEV_SCRIPT".bak"
	mv -f /ramdisk/$DEF_PROP /ramdisk/$DEF_PROP".bak"
	cp $dev_files/$DEV_SCRIPT /ramdisk
	cp $dev_files/$DEF_PROP /ramdisk
	chmod 750 /ramdisk/$DEV_SCRIPT
	chmod 644 /ramdisk/$DEF_PROP
	
	if [ $VY == 1 ] ; then
		echo "4.1" ;
		ramdisk_path=$ramdisk_path"4.1.x/4.1.x.cpio"
		cp -f /tmp/4.1.x/$DEV_SCRIPT /ramdisk
		chmod 750 /ramdisk/$DEV_SCRIPT
	fi

	rm /ramdisk/.use_sdcardfs
	touch /ramdisk/.use_ramdisk_fstab
fi

rm -f /ramdisk/boot.cpio.bak

#if test -f /ramdisk/boot.cpio ; then
#	mv -f /ramdisk/boot.cpio /ramdisk/boot.cpio.bak
#fi
#
#if test -f /ramdisk/boot.cpio ; then
#	mv -f /ramdisk/boot.cpio /ramdisk/boot.cpio.bak
#fi

rm -f /ramdisk/boot.cpio.gz

cp $ramdisk_path /ramdisk/boot.cpio
