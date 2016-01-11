set -x

cd /tmp

/tmp/7za x ramdisk.7z
mv osfiles/* $PWD
mv recovery/* $PWD
