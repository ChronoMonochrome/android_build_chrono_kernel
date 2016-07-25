#!/sbin/sh

SCRIPTS_DIR=/ramdisk/init.d

set -x

install_if_not_exists()
{    
       script=$SCRIPTS_DIR/$1
       if test -f $script ; then
            echo "$1 exists" ;
       else
            cp /tmp/$1 $script
            chmod 0755 $script
       fi
}

mount -o remount /system

install_if_not_exists 00autoload
install_if_not_exists 10dynamic

cp /tmp/60zram $SCRIPTS_DIR/60zram
chmod 755  $SCRIPTS_DIR/60zram

cp /tmp/20minfree  $SCRIPTS_DIR/20minfree
chmod 755 $SCRIPTS_DIR/20minfree

if test -f /system/etc/init.d/60zram ; then
	rm /system/etc/init.d/60zram
fi

if test -f /system/etc/init.d/20minfree ; then
	rm /system/etc/init.d/20minfree
fi

