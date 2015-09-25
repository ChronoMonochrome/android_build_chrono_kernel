#!/sbin/sh

for i in $( ls /system/lib/modules/*.ko )
do
	busybox rm $i
done

for i in $( ls /ramdisk/modules/*.ko )
do
	busybox rm $i
done

for i in $( ls /ramdisk/modules/autoload/*.ko )
do
        busybox rm $i
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

