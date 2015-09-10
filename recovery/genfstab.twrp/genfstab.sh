#!/sbin/sh

set -x

DATA=/dev/block/mmcblk0p5
CACHE=/dev/block/mmcblk0p4
SYSTEM=/dev/block/mmcblk0p3

DIR=/tmp/genfstab.fstab
FSTAB=/ramdisk/twrp.fstab
if test -f $FSTAB; then
	exit
fi

dd if=$DATA of=/tmp/tmp count=1 bs=1036
is_data_f2fs=$(grep -c $'\x10\x20\xF5\xF2' /tmp/tmp)  
dd if=$SYSTEM of=/tmp/tmp count=1 bs=1036
is_system_f2fs=$(grep -c $'\x10\x20\xF5\xF2' /tmp/tmp) 
dd if=$CACHE of=/tmp/tmp count=1 bs=1036
is_cache_f2fs=$(grep -c $'\x10\x20\xF5\xF2' /tmp/tmp) 
	
if [ $is_system_f2fs == 0 ] ; then
	cat $DIR/system_ext4 > $FSTAB ;
else
	cat $DIR/system_f2fs > $FSTAB ;
fi

if [ $is_cache_f2fs == 0 ] ; then
	cat $DIR/cache_ext4 >> $FSTAB ;
else
	cat $DIR/cache_f2fs >> $FSTAB ;
fi

if [ $is_data_f2fs == 0 ] ; then
	cat $DIR/data_ext4 >> $FSTAB ;
else
	cat $DIR/data_f2fs >> $FSTAB ;
fi
	
cat $DIR/fstab1 >> $FSTAB
