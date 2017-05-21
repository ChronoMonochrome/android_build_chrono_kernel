#!/sbin/sh

swap() {
	busybox mv "$1" "$1"2
	busybox mv "$1"1 "$1"
	busybox mv "$1"2 "$1"1
}

swap /ramdisk/fstab
swap /ramdisk/fstab_specs.txt
swap /ramdisk/boot.cpio
swap /ramdisk/twrp.fstab
swap /ramdisk/twrp3.fstab
