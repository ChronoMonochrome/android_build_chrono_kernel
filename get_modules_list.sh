#!/bin/sh

rm $2

while read line
do
	echo $(basename $line) | sed "s,.ko,," >> $2
done < $1
