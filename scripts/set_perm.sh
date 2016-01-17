set -x

chmod 444 /ramdisk/kernel_version
chmod 755 /ramdisk/00userinit
chmod 755 /ramdisk/00recovery
chmod 755 /ramdisk/00lpm
chmod 755 /ramdisk/10monkey_patch
chmod 755 /ramdisk/kern_init
chmod 755 /ramdisk/mount_modules
chmod 750 /ramdisk/init.kernel.rc
