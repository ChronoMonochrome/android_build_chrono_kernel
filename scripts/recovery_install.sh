#!/sbin/sh

set -x

if ! test -f /ramdisk/twrp.fstab
	cp /tmp/twrp.fstab /ramdisk/twrp.fstab
fi

if test -f /ramdisk/recovery.cpio.gz ; then
	exit
fi

if  test -f /ramdisk/recovery.cpio ; then
	exit
fi

##### Unpack ramdisk.7z #####

cur_dir=$PWD

cd /tmp
rm -fr /tmp/recovery
/tmp/7za x ramdisk.7z recovery
mv recovery/* .

cd $cur_dir

##### Unpack ramdisk.7z #####

cd /tmp
gzip -9 recovery.cpio
cp /tmp/recovery.cpio.gz /ramdisk/recovery.cpio.gz
rm /tmp/recovery.cpio.gz
