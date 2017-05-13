#!/sbin/sh

set -x

if ! test -f /ramdisk/twrp.fstab ; then
	cp /tmp/twrp.fstab /ramdisk/twrp.fstab
fi

##### Unpack ramdisk.7z #####

cur_dir=$PWD

cd /tmp
rm -fr /tmp/recovery
/tmp/7za x ramdisk.7z recovery
mv recovery/* .

cd $cur_dir

##### Unpack ramdisk.7z #####

cd /tmp

if [ "$(busybox dd if=/dev/block/mmcblk0p15 skip=8388608 bs=1 count=3 | busybox grep -c $'\x1f\x8b\x08' )" == "0" ] ; then
	gzip -9 recovery.cpio

	dd if=/tmp/recovery.cpio.gz of=/dev/block/mmcblk0p15 bs=524288 seek=16

fi


# install default.prop

mount /system

if test -f /ramdisk/recovery.cpio.gz ; then
	exit
fi

if  test -f /ramdisk/recovery.cpio ; then
	exit
fi


cp /tmp/recovery.cpio.gz /ramdisk/recovery.cpio.gz

rm /tmp/recovery.cpio.gz
