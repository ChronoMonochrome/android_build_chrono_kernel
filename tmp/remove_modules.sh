#!sbin/sh

for i in $( ls /system/lib/modules/*.ko )
do
busybox rm $i
done

for i in $( ls /ramdisk/modules/*.ko )
do
busybox rm $i
done