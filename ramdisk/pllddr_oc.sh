#!/system/bin/sh
#
# Copyright (c) 2017 Shilin Victor.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, version 3.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#

PROC=""

init() {
	if ! test -d /sys/kernel/pllddr ; then
		insmod /system/lib/modules/pllddr.ko
	fi
}

freeze_threads() {
	cd /proc

	for i in $( echo +([0-9]) )
	do
		#echo $i
		if [ "$i" != "$$" ] && [ "$i" != "1" ] && [ "$(grep -c /sbin/adb /proc/$i/cmdline)" == "0" ]; then
			PROC="$i $PROC"
			kill -s STOP $i
		fi
	done

	echo "stopped!"

}

unfreeze_threads() {
	for i in $PROC
	do
		kill -s CONT $i
	done

	echo "continued!"
}

prcmu_get_reg() {
	echo $@ > /sys/kernel/prcmu/prcmu_rreg
	cut -d " " -f2 < /sys/kernel/prcmu/prcmu_rreg
}

prcmu_set_reg() {
	echo $@ > /sys/kernel/prcmu/prcmu_wreg
}

pllddr_oc() {
	# acquire wakelock to prevent suspend
	echo pllddr_oc_lock > /sys/power/wake_lock

	# schedule OC
	echo $@ > /sys/kernel/pllddr/pllddr

	freeze_threads

	SDMMC_VAL=$(prcmu_get_reg 24)

	# disable SDMMCCLK
	prcmu_set_reg 24 88

	if test -d /sys/devices/pri_lcd_ws2401.0; then
		echo 0 > /sys/devices/pri_lcd_ws2401.0/enable
	fi

	if test -d /sys/devices/pri_lcd_s6d* ; then
		echo 0 > /sys/devices/pri_lcd_s6d*/enable
	fi

	#sleep 2

	MCDECLK_VAL=$(prcmu_get_reg 64)

	# disable MCDECLK
	prcmu_set_reg 64 85

	# wait for earlysuspend to trigger OC
	#sleep 5
	#sleep 2
	time=0
	while [ $(grep -c pending /sys/kernel/pllddr/pllddr) -ne 0 ] ;
	do
 		sleep 0.1
		time=$(( $time + 1 ))
		if [ $time -ge 50 ]; then
			break
			# TODO: cancel overclock
		fi
	done

 	echo $time
	echo 1 > /sys/module/earlysuspend/parameters/goto_suspend

	#sleep 1

	# restore MCDECLK
	#prcmu_set_reg 64 $MCDECLK_VAL

	# return from earlysuspend
	echo 1 > /sys/module/earlysuspend/parameters/goto_suspend
	echo 0 > /sys/module/earlysuspend/parameters/goto_suspend

	# restore SDMMCCLK
	#prcmu_set_reg 24 $SDMMC_VAL

	#echo 24 188 > /sys/kernel/prcmu/prcmu_wreg

	unfreeze_threads

	echo pllddr_oc_lock > /sys/power/wake_unlock
}

init
pllddr_oc $@
