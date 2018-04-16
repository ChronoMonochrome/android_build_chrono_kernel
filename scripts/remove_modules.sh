#!/sbin/sh

set -x
rm -f /ramdisk/modules/autoload/*.ko
rm -f /ramdisk/modules/*.ko
rm -fr /system/lib/modules/
mkdir -p /system/lib/modules/autoload
chmod 755 /system/lib/modules/autoload
chmod 755 /system/lib/modules/
