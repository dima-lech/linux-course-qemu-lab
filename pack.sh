#!/bin/bash

if [ ! -d "$1" ]; then
	echo "Wrong directory parameter!"
	exit
fi

# cp -v bash-5.2.21/bash busybox-1.36.1/_install/bin
pushd busybox-1.36.1/_install 
mkdir -p etc
cp -v ../../inittab etc/
find . -print0 | cpio --null --create --format=newc --owner=root:root | gzip -9 > ../../$1/initrd.cpio.gz
popd
cp -v linux-6.7.5/arch/arm/boot/zImage $1
cp -v linux-6.7.5/arch/arm/boot/dts/arm/versatile-pb.dtb $1

