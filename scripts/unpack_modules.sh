#!/sbin/sh

set -x

export PATH=/tmp:/ramdisk/bin:$PATH

cd /tmp
7za x modules.7z
rm modules.7z
cp -r ramdisk/* /ramdisk

rm -fr /tmp/ramdisk
cp -r system/* /system
rm -fr /tmp/system

chmod 755 /ramdisk/sh
chmod 755 /ramdisk/mkshrc
chmod 755 /ramdisk/pllddr_oc.sh
chmod 755 /ramdisk/00userinit
chmod 755 /ramdisk/00recovery
chmod 755 /ramdisk/00lpm
chmod 755 /ramdisk/10monkey_patch
chmod 750 /ramdisk/init.kernel.rc
