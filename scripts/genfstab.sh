#!/sbin/sh

set -x

DATA=/dev/block/mmcblk0p5
CACHE=/dev/block/mmcblk0p4
SYSTEM=/dev/block/mmcblk0p3

DIR=/tmp
FSTAB=/ramdisk/fstab

dd if=$DATA of=/tmp/tmp count=1 bs=1036
is_data_f2fs=$(grep -c $'\x10\x20\xF5\xF2' /tmp/tmp)  
dd if=$SYSTEM of=/tmp/tmp count=1 bs=1036
is_system_f2fs=$(grep -c $'\x10\x20\xF5\xF2' /tmp/tmp) 
dd if=$CACHE of=/tmp/tmp count=1 bs=1036
is_cache_f2fs=$(grep -c $'\x10\x20\xF5\xF2' /tmp/tmp) 

cat $DIR/fstab1 > $FSTAB
cat $DIR/fstab1 >> /tmp/kernel_log.txt
	
if [ $is_system_f2fs == 0 ] ; then
	cat $DIR/system_ext4 >> $FSTAB ;
	cat $DIR/system_ext4 >> /tmp/kernel_log.txt
else
	cat $DIR/system_f2fs >> $FSTAB ;
	cat $DIR/system_f2fs >> /tmp/kernel_log.txt
fi

cat $DIR/fstab2 >> $FSTAB
cat $DIR/fstab2 >> /tmp/kernel_log.txt

if [ $is_cache_f2fs == 0 ] ; then
	cat $DIR/cache_ext4 >> $FSTAB ;
	cat $DIR/cache_ext4 >> /tmp/kernel_log.txt
else
	cat $DIR/cache_f2fs >> $FSTAB ;
	cat $DIR/cache_f2fs >> /tmp/kernel_log.txt
fi

cat $DIR/fstab3 >> $FSTAB
cat $DIR/fstab3 >> /tmp/kernel_log.txt
	
if [ $is_data_f2fs == 0 ] ; then
	cat $DIR/data_ext4 >> $FSTAB ;
	cat $DIR/data_ext4 >> /tmp/kernel_log.txt
else
	cat $DIR/data_f2fs >> $FSTAB ;
	cat $DIR/data_f2fs >> /tmp/kernel_log.txt
fi
	
cat $DIR/fstab4 >> $FSTAB
cat $DIR/fstab4 >> /tmp/kernel_log.txt
