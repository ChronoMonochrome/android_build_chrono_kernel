#!/sbin/sh

set -x
rm -fr /ramdisk/modules/*
rm -f /system/lib/modules/*.ko
busybox mkdir -p /efs
busybox mount -t ext4 /dev/block/mmcblk0p7 /efs
ln -s /modules/dhd.ko /system/lib/modules/dhd.ko
rm -f /efs/modules-*.img
