#!/sbin/sh

set -x

if ! test -f /ramdisk/twrp.fstab ; then
	cp /tmp/twrp.fstab /ramdisk/twrp.fstab
fi

#if test -f /ramdisk/recovery.cpio.gz ; then
#	exit
#fi

#if  test -f /ramdisk/recovery.cpio ; then
#	exit
#fi

##### Unpack ramdisk.7z #####

cur_dir=$PWD

cd /tmp
rm -fr /tmp/recovery
/tmp/7za x ramdisk.7z recovery
mv recovery/* .

cd $cur_dir

##### Unpack ramdisk.7z #####

cd /tmp
#cp /tmp/recovery.cpio.gz /ramdisk/recovery.cpio.gz

if [ "$(busybox dd if=/dev/block/mmcblk0p4 skip=3145728 bs=1 count=3 | busybox grep -c $'\x1f\x8b\x08' )" == "0" ] ; then
	gzip -9 recovery.cpio

	# dirty hack for CWM to forcibly unmount /cache...
	dd if=/dev/zero of=/dev/block/mmcblk0p4 count=5
	umount -l /cache
	umount /cache
	
	
	mke2fs -m 0 /dev/block/mmcblk0p4
	/tmp/resize2fs /dev/block/mmcblk0p4 3M

	dd if=/tmp/recovery.cpio.gz of=/dev/block/mmcblk0p4 bs=524288 seek=6

	rm /tmp/recovery.cpio.gz

fi


