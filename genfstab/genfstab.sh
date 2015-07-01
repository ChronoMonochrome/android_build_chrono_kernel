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

FSTAB=/ramdisk/fstab

#F2FS_MAGIC=$'\x10\x20\xF5\xF2'

# partition "pattern"
PART_PTRN="mmcblk[01]p[1-9]*[ \t]*"

# mount points
MNT_PT=("/system" "/cache" "/modemfs" "/efs" "/data" "/preload")

# default partition scheme. Below only numbers - should match with order above. These only used if ones can't be read from existing fstab file.
PART_NUM=(3 4 2 7 5 9)

PART_FLAGS_EXT4=(
# system
"ext4 ro,noatime,errors=panic wait"\ 

# cache
"ext4 noatime,nosuid,nodev,errors=panic wait,check"\ 

# modemfs
"ext4 noatime,nosuid,nodev,errors=panic                            wait,check"\ 

# efs
"ext4  noatime,nosuid,nodev,errors=panic                            wait,check"\

# data
"ext4 noatime,nosuid,nodev,discard,noauto_da_alloc,errors=panic wait,check,encryptable=/efs/metadata"\ 

# preload
"ext4 ro,noatime,errors=panic wait")

PART_FLAGS_F2FS=(
# system
"f2fs ro wait"\ 

# cache
"f2fs rw,discard,nosuid,nodev,noatime,nodiratime,flush_merge,background_gc=off,inline_xattr,active_logs=2 wait "\ 

# modemfs
"f2fs noatime,nosuid,nodev,errors=panic                            wait,check"\ 

# efs
"f2fs noatime,nosuid,nodev,errors=panic                            wait,check"\ 

# data
"f2fs rw,discard,nosuid,nodev,noatime,nodiratime,flush_merge,background_gc=off,inline_xattr,active_logs=2 wait,nonremovable,encryptable=/efs/metadata"\ 

# preload
"f2fs ro,noatime,errors=panic wait" )

OUTPUT=$FSTAB".tmp"
rm -f $OUTPUT ; touch $OUTPUT

# check whether we should add /preload partition to fstab file
mount /system
VERSION=$(cat /system/build.prop | grep "ro.build.version.release" | awk -F'=' '{print $2}')


LEN=$(( ${#MNT_PT[@]} - 1 ))
for i in $( seq 0 $LEN) 
do

     NEW_PART[$i]=$( cat $FSTAB | grep -e "$PART_PTRN ${MNT_PT[$i]}" | awk '{print $1}' )
     # use default partition scheme if there's problems with parsing existinf fstab file

     if [ -z ${NEW_PART[$i]} ] ; then
            NEW_PART[$i]="/dev/block/mmcblk0p${PART_NUM[$i]}"
            #echo ${NEW_PART[$i]}
     fi

     dd if=${NEW_PART[$i]} of=/tmp/tmp count=1 bs=1036
     is_part_f2fs=$(grep -c $'\x10\x20\xF5\xF2' /tmp/tmp)  

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

cat $FSTAB | grep -e "/devices/sdi[0-9]/mmc_host/mmc[0-9]/mmc[0-9]" >> $OUTPUT
 
# recovery
   
echo "/dev/block/mmcblk0p15 /boot emmc defaults recoveryonly" >> $OUTPUT

mv $FSTAB $FSTAB".bak"
mv $OUTPUT $FSTAB