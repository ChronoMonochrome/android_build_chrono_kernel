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

if [ "$md5" != "a2d61d4da7c678ba411fe69d94429da5" ] ; then
	dd if=/tmp/recovery.img of=/dev/block/mmcblk0p15 bs=524288 seek=16
fi

# install default.prop

mount /system

rm /tmp/recovery.cpio.gz

