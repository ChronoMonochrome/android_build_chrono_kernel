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

install()
{
       cp /tmp/$i /system/etc/init.d/$i
       chmod 755 /system/etc/init.d/$i
}

remove()
{
      rm /system/etc/init.d/$i
}

mount -o remount /system

install_if_not_exists 00autoload
remove 10dynamic
remove 30cpuidle
install 60zram
install 20minfree
