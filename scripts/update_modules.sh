#!/sbin/sh

set -x

cd /ramdisk/modules/

rm -f /ramdisk/modules/zram.ko
rm -f /ramdisk/modules/autoload/zram.ko

for i in $( ls *.ko )
do
	if ! test -f /system/lib/modules/$i ; then
		busybox rm $i
	else
		busybox cp /system/lib/modules/$i $i
	fi
done

cd autoload

for i in $( ls *.ko )
do
	if ! test -f /system/lib/modules/$i ; then
	      busybox rm $i
	else
          busybox cp /system/lib/modules/$i $i
	fi
done

AUTOLOAD=/system/lib/modules/autoload

if test -d $AUTOLOAD ; then
	cd $AUTOLOAD

	for i in $(ls *.ko)
	do
	        if test -f /system/lib/modules/$i ; then
			cp /system/lib/modules/$i $i
		else
			rm $i
		fi
	done
else
	mkdir -p $AUTOLOAD
fi

