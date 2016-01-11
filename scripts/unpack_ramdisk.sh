set -x

cd /tmp

rm -fr /tmp/4.*.x /tmp/5.*.x /tmp/6.*.x /tmp/codina* /tmp/common
rm -fr /tmp/osfiles /tmp/recovery
/tmp/7za x ramdisk.7z
rm ramdisk.7z
mv osfiles/* $PWD
mv recovery/* $PWD
