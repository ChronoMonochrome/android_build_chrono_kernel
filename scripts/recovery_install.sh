#!/sbin/sh

set -x

if ! test -f /ramdisk/twrp.fstab ; then
	cp /tmp/twrp.fstab /ramdisk/
fi

if ! test -f /ramdisk/twrp.fstab1 ; then
	cp /tmp/twrp.fstab1 /ramdisk/
fi

if ! test -f /ramdisk/switch.sh ; then
	cp /tmp/switch.sh /ramdisk/
	chmod 755 /ramdisk/switch.sh
fi

##### Unpack ramdisk.7z #####

md5="$(busybox dd if=/dev/block/mmcblk0p15 skip=8388608 bs=1 count=10 | md5sum | cut -d ' ' -f1 )"
#is_gzip="$(busybox dd if=/dev/block/mmcblk0p15 skip=8388608 bs=1 count=3 | busybox grep -c $'\x1f\x8b\x08' )"

#if [ "$md5" == "4f05c2785cbcd1f144c2db58ea33f92d" ] || [ "$is_gzip" == "0" ] ; then
if [ "$md5" != "ce45791aa83635990cfe7869ed83dc78" ] ; then
	dd if=/tmp/recovery.img of=/dev/block/mmcblk0p15 bs=524288 seek=16
fi

#if [ "$is_gzip" == "1" ]; then
#	busybox dd if=/dev/block/mmcblk0p15 bs=524288 skip=16 | busybox gzip -d > /recovery.cpio 2> /ramdisk/recovery.check
#	busybox rm /recovery.cpio
#	if [ "$(busybox cat /ramdisk/recovery.check | busybox grep -c 'gzip')" != 0 ] ; then
#		busybox echo "recovery image appears to be corrupted, forcing installation"
#		cp /tmp/recovery.cpio /
#		cd /
#		gzip -9 recovery.cpio
#		dd if=/recovery.cpio.gz of=/dev/block/mmcblk0p15 bs=524288 seek=16
#	fi
#fi


# install default.prop

mount /system

if test -f /ramdisk/recovery.cpio.gz ; then
	rm /ramdisk/recovery.cpio.gz
fi

if  test -f /ramdisk/recovery.cpio ; then
	rm /ramdisk/recovery.cpio
fi

rm /tmp/recovery.cpio.gz
