#!/sbin/sh

set -x
rm -fr /ramdisk/modules/*
rm -f /system/lib/modules/*.ko
ln -s /ramdisk/modules/dhd.ko /system/lib/modules/dhd.ko
rm -f /ramdisk/modules-*.img
