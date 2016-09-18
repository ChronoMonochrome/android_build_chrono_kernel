#!/sbin/sh

VERSION_LINE=$(cat /system/build.prop | grep "ro.build.version.release" | cut -d "=" -f2)
VX=$(echo $VERSION_LINE | cut -d "." -f1)
VY=$(echo $VERSION_LINE | cut -d "." -f2)


if [ $VX != 4 ] && [ $VY != 4 ] ; then
		echo "OS version is not 4.4.x, skipped"
		exit
fi

APPS_PATHS="/system/priv-app /system/app /data/app"
UNZIP="/system/xbin/unzip"
NTAPP_ICON="res/drawable-hdpi-v4/novathor_icon.png"
NTAPP_PREV_LOCATION="/ramdisk/ntapp.txt"

IS_FOUND=0
IS_FROZEN=0

FREEZE_POSTFIX="~ntapp"

mount /data 2>/dev/null
mount /system 2>/dev/null

LD_LIBRARY_PATH_BACKUP=$LD_LIBRARY_PATH

LD_LIBRARY_PATH="/system/lib"

cd /tmp

freeze_ntapp()
{	
	if test -f "$1$FREEZE_POSTFIX" ; then
		IS_FROZEN=1
		echo "NT App is already frozen"
		exit
	fi
	
	if test -f $1 ; then

		$UNZIP -qq $1 $NTAPP_ICON -d /tmp 2>/dev/null
		if test -f /tmp/$NTAPP_ICON ; then
			rm -f /tmp/$NTAPP_ICON
			
			echo "found NT app: $1"
			IS_FOUND=1
			
			echo $1 > $NTAPP_PREV_LOCATION
		
			mv $1 $1$FREEZE_POSTFIX
		
			echo "NT app is frozen: $1 -> $1$FREEZE_POSTFIX"
		fi
	else
		echo "freeze_ntapp: $1: not found"
	fi
}

if test -f $NTAPP_PREV_LOCATION ; then
	freeze_ntapp $(cat $NTAPP_PREV_LOCATION)
fi

for path in $APPS_PATHS
do
	if [ $IS_FOUND -eq 1 ] ; then
		break
	fi
	
	for i in $(find "$path" -name "*.apk")
	do
		freeze_ntapp $i
		
		if [ $IS_FOUND -eq 1 ] ; then
			break
		fi
		
		rm -f /tmp/$NTAPP_ICON
	done
done


LD_LIBRARY_PATH=$LD_LIBRARY_PATH_BACKUP
