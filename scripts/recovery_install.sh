#!/sbin/sh

set -x

if test -f /ramdisk/twrp.fstab ; then
	fstab=$(cat /ramdisk/twrp.fstab)
	if [ "$fstab" == "" ] ; then 
		cp /tmp/twrp.fstab /ramdisk/twrp.fstab
	fi
fi

if test -f /ramdisk/recovery.cpio.gz ; then
	exit
fi

if  test -f /ramdisk/recovery.cpio ; then
	exit
fi

cp /tmp/recovery.cpio.gz /ramdisk/recovery.cpio.gz
