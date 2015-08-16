#!/sbin/sh

# 
# Copyright (c) 2015, Shilin Victor <chrono.monochrome@gmail.com>
# 
# This software is licensed under the terms of the GNU General Public
# License version 2, as published by the Free Software Foundation, and
# may be copied, distributed, and modified under those terms.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# General Public License for more details.
#
#

set -x

FSTAB=$1

# FIXME: use variable below instead of hardcoded value
#F2FS_MAGIC=$'\x10\x20\xF5\xF2'

# partition "pattern"
PART_PTRN="mmcblk[01]p[1-9]*[ \t]*"

# mount points
MNT_PT[0]="/system" 
MNT_PT[1]="/cache"
MNT_PT[2]="/modemfs"
MNT_PT[3]="/efs"
MNT_PT[4]="/data" 
MNT_PT[5]="/preload"

# default partition scheme. Below only numbers - should match with order above. These only used if ones can't be read from existing fstab file.
PART_NUM[0]=3 
PART_NUM[1]=4 
PART_NUM[2]=2 
PART_NUM[3]=7 
PART_NUM[4]=5 
PART_NUM[5]=9

# system
PART_FLAGS_EXT4[0]="ext4 ro,noatime,errors=panic wait"
# cache
PART_FLAGS_EXT4[1]="ext4 noatime,nosuid,nodev,errors=panic wait,check"
# modemfs
PART_FLAGS_EXT4[2]="ext4 noatime,nosuid,nodev,errors=panic                            wait,check"
# efs
PART_FLAGS_EXT4[3]="ext4  noatime,nosuid,nodev,errors=panic                            wait,check"
# data
PART_FLAGS_EXT4[4]="ext4 noatime,nosuid,nodev,discard,noauto_da_alloc,errors=panic wait,check,encryptable=/efs/metadata"
# preload
PART_FLAGS_EXT4[5]="ext4 ro,noatime,errors=panic wait"

# system
PART_FLAGS_F2FS[0]="f2fs ro wait"
# cache
PART_FLAGS_F2FS[1]="f2fs rw,discard,nosuid,nodev,noatime,nodiratime,flush_merge,background_gc=off,inline_xattr,active_logs=2 wait "
# modemfs
PART_FLAGS_F2FS[2]="f2fs noatime,nosuid,nodev,errors=panic                            wait,check"
# efs
PART_FLAGS_F2FS[3]="f2fs noatime,nosuid,nodev,errors=panic                            wait,check"
# data
PART_FLAGS_F2FS[4]="f2fs rw,discard,nosuid,nodev,noatime,nodiratime,flush_merge,background_gc=off,inline_xattr,active_logs=2 wait,nonremovable,encryptable=/efs/metadata"
# preload
PART_FLAGS_F2FS[5]="f2fs ro,noatime,errors=panic wait"

OUTPUT=$FSTAB".tmp"
rm -f $OUTPUT ; touch $OUTPUT

LEN=$(( ${#MNT_PT[@]} - 1 ))
for i in $( seq 0 $LEN) 
do

     NEW_PART[$i]=$( cat $FSTAB | grep -e "$PART_PTRN ${MNT_PT[$i]}" | awk '{print $1}' )
     # use default partition scheme if there's problems with parsing existing fstab file

     if [ -z ${NEW_PART[$i]} ] ; then
            NEW_PART[$i]="/dev/block/mmcblk0p${PART_NUM[$i]}"
     fi

     dd if=${NEW_PART[$i]} of=/tmp/tmp count=1 bs=1036
     is_part_f2fs=$(grep -c $'\x10\x20\xF5\xF2' /tmp/tmp)  
     if [ ${MNT_PT[$i]} == "/system" ] ; then
          # check whether we should add /preload partition to fstab file
          if [ $is_part_f2fs == 0 ] ; then
                 mount -t ext4 ${NEW_PART[$i]} /system ;
          else
                 mount -t f2fs ${NEW_PART[$i]} /system
          fi
          VERSION=$(cat /system/build.prop | grep "ro.build.version.release" | awk -F'=' '{print $2}')
     fi

     # skip /preload for non-stock ROMs
     if [ $VERSION != "4.1.2" ] && [ ${MNT_PT[$i]} == "/preload" ] ; then
         break;
     fi

     if [ $is_part_f2fs == 0 ] ; then
          echo "${NEW_PART[$i]} ${MNT_PT[$i]} ${PART_FLAGS_EXT4[$i]}" >> $OUTPUT ;
    else
	     echo "${NEW_PART[$i]} ${MNT_PT[$i]} ${PART_FLAGS_F2FS[$i]}" >> $OUTPUT
    fi
     
done


# vold-managed devices

VOLD_DEV0=$( cat $FSTAB | grep "/devices/sdi2/mmc_host/mmc0/mmc0" )
VOLD_DEV1=$( cat $FSTAB | grep "/devices/sdi0/mmc_host/mmc1/mmc1" )

if [ -z "$VOLD_DEV0" ] || [ -z "$VOLD_DEV1" ] ; then
        echo "/devices/sdi2/mmc_host/mmc0/mmc0 auto auto defaults voldmanaged=sdcard0:8,nonremovable,noemulatedsd" >> $OUTPUT
       echo "/devices/sdi0/mmc_host/mmc1/mmc1 auto auto defaults voldmanaged=sdcard1:auto" >> $OUTPUT
else
      echo $VOLD_DEV0 >> $OUTPUT
      echo $VOLD_DEV1 >> $OUTPUT
fi
 
# recovery
   
echo "/dev/block/mmcblk0p15 /boot emmc defaults recoveryonly" >> $OUTPUT

mv $FSTAB $FSTAB".bak"
mv $OUTPUT $FSTAB
