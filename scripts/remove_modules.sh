#!/sbin/sh

set -x
rm -fr /ramdisk/modules/*
rm -f /system/lib/modules/*.ko
rm /ramdisk/modules-*.img
