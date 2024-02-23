#!/bin/bash
cd busybox-1.36.1 && make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- -j6 menuconfig


