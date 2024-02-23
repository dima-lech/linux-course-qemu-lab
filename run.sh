#!/bin/bash

if [ ! -d "$1" ]; then
	echo "Wrong directory parameter!"
	exit
fi

qemu-system-arm \
	-machine "versatilepb" \
	-kernel "$1/zImage" \
	-nographic \
	-dtb "$1/versatile-pb.dtb" \
	-initrd "$1/initrd.cpio.gz" \
	-append "rdinit=/sbin/init"
