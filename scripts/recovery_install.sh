#!/sbin/sh

set -x

cp /tmp/twrp.fstab /ramdisk/twrp.fstab

if test -f /ramdisk/recovery.cpio.gz ; then
	exit
fi

if  test -f /ramdisk/recovery.cpio ; then
	exit
fi

cp /tmp/recovery.cpio.gz /ramdisk/recovery.cpio.gz
