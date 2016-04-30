#!/sbin/sh

set -x

# genfstab config file
FSTAB_SPECS="/ramdisk/fstab_specs.txt"


# defaults
FSTAB_VER="1.0"
DATA=/dev/block/mmcblk0p5
CACHE=/dev/block/mmcblk0p4
SYSTEM=/dev/block/mmcblk0p3

VERSION_LINE=$(cat /system/build.prop | grep "ro.build.version.release" | cut -d "=" -f2)
VX=$(echo $VERSION_LINE | cut -d "." -f1)
VY=$(echo $VERSION_LINE | cut -d "." -f2)

if [ $VX == 6 ]; then
	FSTAB_VER="2.0"
fi

if ! test -f $FSTAB_SPECS ; then
	touch $FSTAB_SPECS
	echo "ver="$FSTAB_VER >> $FSTAB_SPECS
	echo "data="$DATA >> $FSTAB_SPECS
	echo "system="$SYSTEM >> $FSTAB_SPECS
	echo "cache="$CACHE >> $FSTAB_SPECS
else
	DATA=$(cat $FSTAB_SPECS | grep "data=" | cut -d "=" -f2)
	SYSTEM=$(cat $FSTAB_SPECS | grep "system=" | cut -d "=" -f2)
	CACHE=$(cat $FSTAB_SPECS | grep "cache=" | cut -d "=" -f2)
fi


DIR=/tmp
FSTAB=/ramdisk/fstab
FSTAB_SWAP=/ramdisk/fstab_swap

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
	

cat $FSTAB > $FSTAB_SWAP

cat $DIR/fstab4_v$FSTAB_VER >> $FSTAB
cat $DIR/fstab4_v$FSTAB_VER >> /tmp/kernel_log.txt

cat $DIR/fstab4_v$FSTAB_VER"_swap" >> $FSTAB_SWAP
cat $DIR/fstab4_v$FSTAB_VER"_swap" >> /tmp/kernel_log.txt
