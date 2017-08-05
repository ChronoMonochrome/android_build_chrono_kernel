#!/sbin/sh

set -x

# genfstab config file
FSTAB_SPECS="/ramdisk/fstab_specs.txt"


# defaults
FSTAB_VER="1.0"

FSTAB_INTERNAL_VER="1.1"
DATA=/dev/block/mmcblk0p5
#CACHE=/dev/block/mmcblk0p4
SYSTEM=/dev/block/mmcblk0p3
USE_CACHE=1
USE_PRELOAD=0
USE_SWAP=1
USE_INTSDCARD=1

VERSION_LINE=$(cat /system/build.prop | grep "ro.build.version.release" | cut -d "=" -f2)
VX=$(echo $VERSION_LINE | cut -d "." -f1)
VY=$(echo $VERSION_LINE | cut -d "." -f2)

if [ $VX -ge 6 ];  then
	FSTAB_VER="2.0"
fi

if [ $VX == 4 ]; then
	if [ $VY == 1 ] ; then
		USE_PRELOAD=1
	fi
fi

if test -f $FSTAB_SPECS ; then
	FSTAB_INTERNAL_VER_CONFIG=$(cat $FSTAB_SPECS | grep "ver_internal=" | cut -d "=" -f2)
	if [ "$FSTAB_INTERNAL_VER_CONFIG" != "$FSTAB_INTERNAL_VER" ] ; then
		echo "genfstab version mismatch, removing config" >> /tmp/kernel_log.txt
		rm $FSTAB_SPECS
	fi
fi

if ! test -f $FSTAB_SPECS ; then
	touch $FSTAB_SPECS
	echo "ver="$FSTAB_VER >> $FSTAB_SPECS
	echo "ver_internal="$FSTAB_INTERNAL_VER >> $FSTAB_SPECS
	echo "data="$DATA >> $FSTAB_SPECS
	echo "system="$SYSTEM >> $FSTAB_SPECS
	#echo "cache="$CACHE >> $FSTAB_SPECS
	#echo "use_cache_partition=1" >> $FSTAB_SPECS
	echo "use_preload_partition="$USE_PRELOAD >> $FSTAB_SPECS
	echo "use_swap="$USE_SWAP >> $FSTAB_SPECS
	echo "use_intsdcard="$USE_INTSDCARD >> $FSTAB_SPECS
else
	DATA=$(cat $FSTAB_SPECS | grep "data=" | cut -d "=" -f2)
	SYSTEM=$(cat $FSTAB_SPECS | grep "system=" | cut -d "=" -f2)
	#CACHE=$(cat $FSTAB_SPECS | grep "cache=" | cut -d "=" -f2)
	#USE_CACHE=$(cat $FSTAB_SPECS | grep "use_cache_partition=" | cut -d "=" -f2)
	USE_PRELOAD=$(cat $FSTAB_SPECS | grep "use_preload_partition=" | cut -d "=" -f2)
	USE_SWAP=$(cat $FSTAB_SPECS | grep "use_swap=" | cut -d "=" -f2)
	USE_INTSDCARD=$(cat $FSTAB_SPECS | grep "use_intsdcard=" | cut -d "=" -f2)
fi


DIR=/tmp

if [ "$USE_SWAP" == "1" ] ; then
	FSTAB=/ramdisk/fstab_swap
	FSTAB_SWAP=/ramdisk/fstab
else
	FSTAB=/ramdisk/fstab
	FSTAB_SWAP=/ramdisk/fstab_swap
fi

#CACHE_EXT4=$CACHE" /cache ext4 noatime,nosuid,nodev,errors=panic wait,check"
#CACHE_F2FS=$CACHE" /cache f2fs rw,discard,nosuid,nodev,noatime,nodiratime,flush_merge,background_gc=off,inline_xattr,active_logs=2 wait"
DATA_F2FS=$DATA" /data f2fs rw,discard,nosuid,nodev,noatime,nodiratime,flush_merge,background_gc=off,inline_xattr,active_logs=2 wait,nonremovable,encryptable=/efs/metadata"
DATA_EXT4=$DATA" /data ext4 noatime,nosuid,nodev,discard,noauto_da_alloc,errors=panic wait,check,encryptable=/efs/metadata"
SYSTEM_EXT4=$SYSTEM" /system ext4 ro,noatime,errors=panic wait"
SYSTEM_F2FS=$SYSTEM" /system f2fs ro wait"

PRELOAD_EXT4="/dev/block/mmcblk0p9 /preload ext4 ro,noatime,errors=panic wait"

dd if=$DATA of=/tmp/tmp count=1 bs=1036
is_data_f2fs=$(grep -c $'\x10\x20\xF5\xF2' /tmp/tmp) 
dd if=$SYSTEM of=/tmp/tmp count=1 bs=1036
is_system_f2fs=$(grep -c $'\x10\x20\xF5\xF2' /tmp/tmp) 
#dd if=$CACHE of=/tmp/tmp count=1 bs=1036
#is_cache_f2fs=$(grep -c $'\x10\x20\xF5\xF2' /tmp/tmp) 

cat $DIR/fstab1 > $FSTAB
cat $DIR/fstab1 >> /tmp/kernel_log.txt
	
if [ $is_system_f2fs == 0 ] ; then
	echo $SYSTEM_EXT4 >> $FSTAB ;
	echo $SYSTEM_EXT4 >> /tmp/kernel_log.txt
else
	echo $SYSTEM_F2FS >> $FSTAB ;
	echo $SYSTEM_F2FS >> /tmp/kernel_log.txt
fi

cat $DIR/fstab2 >> $FSTAB
cat $DIR/fstab2 >> /tmp/kernel_log.txt

#if [ "$USE_CACHE" == "1" ] ; then
#	if [ $is_cache_f2fs == 0 ] ; then
#		echo $CACHE_EXT4 >> $FSTAB ;
#		echo $CACHE_EXT4 >> /tmp/kernel_log.txt
#	else
#		echo $CACHE_F2FS >> $FSTAB ;
#		echo $CACHE_F2FS >> /tmp/kernel_log.txt
#	fi
#fi

if [ "$USE_PRELOAD" == "1" ] ; then
	echo $PRELOAD_EXT4 >> $FSTAB
	echo $PRELOAD_EXT4 >> /tmp/kernel_log.txt
fi

cat $DIR/fstab3 >> $FSTAB
cat $DIR/fstab3 >> /tmp/kernel_log.txt
	
if [ $is_data_f2fs == 0 ] ; then
	echo $DATA_EXT4 >> $FSTAB ;
	echo $DATA_EXT4 >> /tmp/kernel_log.txt
else
	echo $DATA_F2FS >> $FSTAB ;
	echo $DATA_F2FS >> /tmp/kernel_log.txt
fi
	

cat $FSTAB > $FSTAB_SWAP

cat $DIR/fstab4_v$FSTAB_VER >> $FSTAB
cat $DIR/fstab4_v$FSTAB_VER >> /tmp/kernel_log.txt

if [ "$USE_INTSDCARD" == "1" ] ; then
	cat $DIR/fstab4_v$FSTAB_VER"_swap" >> $FSTAB_SWAP
	cat $DIR/fstab4_v$FSTAB_VER"_swap" >> /tmp/kernel_log.txt
else
	cat $DIR/fstab4_v$FSTAB_VER"_swap_nointsdcard" >> $FSTAB_SWAP
	cat $DIR/fstab4_v$FSTAB_VER"_swap_nointsdcard" >> /tmp/kernel_log.txt
fi

#cat $DIR/fstab4_v$FSTAB_VER"_swap" >> /tmp/kernel_log.txt
