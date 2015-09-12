#!sbin/sh

set -x

if  test -f /ramdisk/recovery.cpio ; then
	exit
fi

if  test -f /ramdisk/recovery.cpio.gz ; then
        exit
fi

cp -f /tmp/twrp.cpio.gz /ramdisk/recovery.cpio.gz

# install default.prop

mount /system

DEVICE=$(cat /system/build.prop | grep "ro.product.device=" | cut -d "=" -f2)

if [ "$DEVICE" == "GT-I8160" ] ; then
	DEVICE=codina
fi

if [ "$DEVICE" == "GT-I8160P" ] ; then
	DEVICE=codinap
fi

DEF_PROP="recovery_default.prop"
dev_files="/tmp/"$DEVICE

mv -f /ramdisk/$DEF_PROP /ramdisk/$DEF_PROP".bak"
cp $dev_files/$DEF_PROP /ramdisk
