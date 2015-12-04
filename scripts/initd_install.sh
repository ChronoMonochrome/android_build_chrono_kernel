#!/sbin/sh

set -x

install_if_not_exists()
{    
       script=/system/etc/init.d/$1
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
cp /tmp/60zram /system/etc/init.d/60zram
chmod 755 /system/etc/init.d/60zram
