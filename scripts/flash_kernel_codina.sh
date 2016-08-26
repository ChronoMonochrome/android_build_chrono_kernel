#!/sbin/sh

set -x

export PATH=/tmp:/ramdisk/bin:$PATH

cd /tmp
7za x zimage.7z
rm zimage.7z
mv zimage/* .
rm -fr zimage

# set arch_id = 5003 to make bootloader happy
#sed -i 's/\xed\xaf\x86\x57/\x8b\x13\x00\x00/g' kernel
# now kernel requires cmdline to match with the device
sed -ie 's,androidboot.hardware=samsungjanice,androidboot.hardware=samsungcodina,' kernel

sed -ie 's,androidboot.hardware=samsungjanice,androidboot.hardware=samsungcodina,' /tmp/cmdline.txt
sed -ie 's,androidboot.hardware=samsungjanice,androidboot.hardware=samsungcodina,' /ramdisk/cmdline.txt

/sbin/sh /tmp/gen_cmdline_script.sh kernel
lz4c -l -c1 kernel kernel.lz4
cat start_chunk  kernel.lz4 end_chunk > boot.img

dd if=boot.img of=/dev/block/mmcblk0p15 bs=512000
