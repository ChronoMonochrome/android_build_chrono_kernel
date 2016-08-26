#!/sbin/sh

set -x

export PATH=/tmp:/ramdisk/bin:$PATH

cd /tmp
7za x zimage.7z
rm zimage.7z
mv zimage/* .
rm -fr zimage

#sed -i 's/\xed\xaf\x86\x57/\x88\x13\x00\x00/g' kernel
sed -ie 's,androidboot.hardware=samsungcodina,androidboot.hardware=samsungjanice,' kernel

sed -ie "s,androidboot.hardware=samsungcodina,androidboot.hardware=samsungjanice," /tmp/cmdline.txt
sed -ie "s,androidboot.hardware=samsungcodina,androidboot.hardware=samsungjanice," /ramdisk/cmdline.txt

/sbin/sh /tmp/gen_cmdline_script.sh kernel
lz4c -l -c1 kernel kernel.lz4
cat start_chunk  kernel.lz4 end_chunk > boot.img

dd if=boot.img of=/dev/block/mmcblk0p15 bs=512000
