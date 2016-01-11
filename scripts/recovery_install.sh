#!/sbin/sh

set -x

cp /tmp/twrp.fstab /ramdisk/twrp.fstab

if test -f /ramdisk/recovery.cpio.gz ; then
	exit
fi

if  test -f /ramdisk/recovery.cpio ; then
	exit
fi

cd /tmp
gzip -9 recovery.cpio
cp /tmp/recovery.cpio.gz /ramdisk/recovery.cpio.gz
rm /tmp/recovery.cpio.gz