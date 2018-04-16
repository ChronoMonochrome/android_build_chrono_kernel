#!/system/bin/sh

BB=busybox

SETTINGS=/data/data/com.android.settings/shared_prefs/com.android.settings_preferences.xml
CURRENT_PROFILE=$($BB cat /ramdisk/.sys.perf.profile)

if test -f /tmp/.sys.perf.dont.recurse ; then
       $BB rm /tmp/.sys.perf.dont.recurse
       exit 0
fi

cpu_governor_hack() {
    if test -f $SETTINGS ; then
        CPU_GOVERNOR=$($BB cat $SETTINGS | $BB grep pref_cpu_gov | $BB cut -d ">" -f2 | $BB cut -d "<" -f1)
        if [ "$CPU_GOVERNOR" != "dynamic" ] ; then
            $BB echo $CPU_GOVERNOR > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
        fi
    fi
}

cpu_governor_hack

if ! test -f /tmp/.boot_completed ; then
       #echo $(date) "boot not completed" >> /ramdisk/.perf.log
       $BB touch /tmp/.sys.perf.dont.recurse
       setprop sys.perf.profile $CURRENT_PROFILE
       #$BB echo $(date) "getprop sys.perf.profile = " $(getprop sys.perf.profile) >> /ramdisk/.perf.log
fi

# PROFILE UPDATE HACK
profile=$($BB cat /tmp/.sys.perf.profile)
#$BB echo $profile >> /ramdisk/.perf.log

if [ "$profile" == "" ] ; then
	profile=1
fi

if test -f /tmp/.sys.perf.svc.first.boot ; then
    $BB echo $profile > /ramdisk/.sys.perf.profile
else
    #$BB echo $(date) "first boot = " $(getprop sys.perf.profile) >> /ramdisk/.perf.log
    $BB touch /tmp/.sys.perf.svc.first.boot
fi
# PROFILE UPDATE HACK END

if ! test -f /ramdisk/.sys.perf.profile ; then
    $BB echo 1 > /ramdisk/.sys.perf.profile
fi

CURRENT_PROFILE=$($BB cat /ramdisk/.sys.perf.profile)

if [ "$CURRENT_PROFILE" == "0" ] ; then
    $BB echo pll=0x0005011A > /sys/kernel/liveopp/arm_step00
    $BB echo ddropp=50 > /sys/kernel/liveopp/arm_step01
    $BB echo pll=0x00050141 > /sys/kernel/liveopp/arm_step01
    $BB echo varm=0x26 > /sys/kernel/liveopp/arm_step01
    $BB echo 400000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
    $BB echo 200000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
    $BB echo 256000 > /sys/kernel/mali/mali_boost_low
    $BB echo 256000 > /sys/kernel/mali/mali_boost_high
    $BB echo 400000 > /sys/devices/system/cpu/cpufreq/dynamic/power_optimal_freq
    $BB echo 400000 > /sys/devices/system/cpu/cpufreq/dynamic/max_non_oc_freq
    $BB echo 4000 > /sys/devices/system/cpu/cpufreq/dynamic/oc_freq_boost_ms
fi

if [ "$CURRENT_PROFILE" == "1" ] ; then
    $BB echo pll=0x00050134 > /sys/kernel/liveopp/arm_step00
    $BB echo ddropp=100 > /sys/kernel/liveopp/arm_step01
    $BB echo pll=0x00050168 > /sys/kernel/liveopp/arm_step01
    $BB echo varm=0x2A > /sys/kernel/liveopp/arm_step01
    $BB echo 256000 > /sys/kernel/mali/mali_boost_low
    $BB echo 399360 > /sys/kernel/mali/mali_boost_high
    $BB echo 800000 > /sys/devices/system/cpu/cpufreq/dynamic/power_optimal_freq
    if [ "$($BB cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq)" == "400000" ] ; then
        $BB echo 1000000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
    fi
    $BB echo 400000 > /sys/devices/system/cpu/cpufreq/dynamic/max_non_oc_freq
    $BB echo 4000 > /sys/devices/system/cpu/cpufreq/dynamic/oc_freq_boost_ms
fi

if [ "$CURRENT_PROFILE" == "2" ] ; then
    $BB echo pll=0x00050134 > /sys/kernel/liveopp/arm_step00
    $BB echo ddropp=100 > /sys/kernel/liveopp/arm_step01
    $BB echo pll=0x00050168 > /sys/kernel/liveopp/arm_step01
    $BB echo varm=0x2A > /sys/kernel/liveopp/arm_step01
    if [ "$($BB cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq)" == "400000" ] ; then
        $BB echo 1000000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
    fi
    $BB echo 399360 > /sys/kernel/mali/mali_boost_low
    $BB echo 499200 > /sys/kernel/mali/mali_boost_high
    $BB echo 0 > /sys/devices/system/cpu/cpufreq/dynamic/power_optimal_freq
    $BB echo 0 > /sys/devices/system/cpu/cpufreq/dynamic/max_non_oc_freq
    $BB echo 0 > /sys/devices/system/cpu/cpufreq/dynamic/oc_freq_boost_ms
fi

cpu_governor_hack
