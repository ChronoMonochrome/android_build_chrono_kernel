#!/sbin/sh

set -x

export PATH=/tmp:/ramdisk/bin:$PATH

cd /tmp
7za x zimage.7z
rm zimage.7z
mv zimage/* .
rm -fr zimage

lz4c -l -c1 kernel kernel.lz4
cat start_chunk  kernel.lz4 end_chunk > boot.img

dd if=boot.img of=/dev/block/mmcblk0p15 bs=512000
