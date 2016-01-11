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
gzip -9r recovery.cpio.gz recovery.cpio
rm /tmp/recovery.cpio
cp /tmp/recovery.cpio.gz /ramdisk/recovery.cpio.gz
