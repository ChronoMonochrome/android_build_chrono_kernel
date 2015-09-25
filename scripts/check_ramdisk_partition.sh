#!/sbin/sh

umount /ramdisk

dd if=/dev/block/mmcblk0p17 of=/tmp/tmp count=1 skip=540 bs=2
is_ramdisk_exists=$(grep -c $'\x53\xEF' /tmp/tmp)

if [ "$is_ramdisk_exists" -eq "0" ] ; then 
	mke2fs -t ext4 -m 0 /dev/block/mmcblk0p17
fi

mount -t ext4 /dev/block/mmcblk0p17 /ramdisk