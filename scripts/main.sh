#!/sbin/sh

set -x

#
# from http://forum.xda-developers.com/showthread.php?t=1023150
#
# get file descriptor for output
#OUTFD=$(ps | grep -v "grep" | grep -o -E "update_binary(.*)" | cut -d " " -f 3);
#
# same as progress command in updater-script, for example:
#
# progress 0.25 10
#
# will update the next 25% of the progress bar over a period of 10 seconds
#
#progress() {
#  if [ $OUTFD != "" ]; then
#    echo "progress ${1} ${2} " 1>&$OUTFD;
#  fi;
#}
#
# same as set_progress command in updater-script, for example:
#
# set_progress 0.25
#
# sets progress bar to 25%
#
#set_progress() {
#  if [ $OUTFD != "" ]; then
#    echo "set_progress ${1} " 1>&$OUTFD;
#  fi;
#}
#
# same as ui_print command in updater_script, for example:
#
# ui_print "hello world!"
#
# will output "hello world!" to recovery, while
#
# ui_print
#
# outputs an empty line
#
#ui_print() {
#  if [ $OUTFD != "" ]; then
#    echo "ui_print ${1} " 1>&$OUTFD;
#    echo "ui_print " 1>&$OUTFD;
#  else
#    echo "${1}";
#  fi;
#}
#
#

logged_execute()
{
	$1 1&> /tmp/tmp.txt
	cat /tmp/tmp.txt >> /tmp/kernel_log.txt
	rm /tmp/tmp.txt
	echo "" >> /tmp/kernel_log.txt
}

if [ "$1" == "wipe_log" ] ; then
	rm -f /tmp/kernel_log.txt
	touch /tmp/kernel_log.txt
	exit
fi

if [ "$1" == "check_ramdisk_partition" ] ; then
	echo "Checking ramdisk partition..." >> /tmp/kernel_log.txt
    #ui_print "Checking ramdisk partition..."
    logged_execute /tmp/check_ramdisk_partition.sh
fi

if [ "$1" == "remove_modules" ] ; then
    echo "Removing old modules..." >> /tmp/kernel_log.txt
    #ui_print "Removing old modules..."
    logged_execute /tmp/remove_modules.sh
fi

if [ "$1" == "unpack_modules" ] ; then
    echo "Unpacking modules file..." >> /tmp/kernel_log.txt
    logged_execute /tmp/unpack_modules.sh
fi

if [ "$1" == "update_modules" ] ; then
    echo "Updating modules..." >> /tmp/kernel_log.txt
    #ui_print "Updating modules..."
    logged_execute /tmp/update_modules.sh
fi

if [ "$1" == "fstab" ] ; then
	echo "Generating fstab..." >> /tmp/kernel_log.txt
	#ui_print "Generating fstab..."
	logged_execute /tmp/genfstab.sh

	#set_progress 0.7
fi

if [ "$1" == "osfiles" ] ; then
	echo "Installing osfiles..." >> /tmp/kernel_log.txt
	#ui_print "Installing osfiles..."
	logged_execute /tmp/osfiles_install.sh

	#set_progress 0.8
fi

if [ "$1" == "recovery" ] ; then
	echo "Installing recovery..." >> /tmp/kernel_log.txt
	#ui_print "Installing recovery..."
	logged_execute /tmp/recovery_install.sh

	#set_progress 0.9
fi

if [ "$1" == "init.d" ] ; then
	echo "Installing init.d scripts..." >> /tmp/kernel_log.txt
	#ui_print "Installing init.d scripts..."
	logged_execute /tmp/initd_install.sh
fi


if [ "$1" == "freeze_ntapp" ] ; then
	echo "Freezein NT App" >> /tmp/kernel_log.txt
	logged_execute /tmp/freeze_ntapp.sh
fi

cp /tmp/kernel_log.txt /ramdisk/last_kernel_install.txt
