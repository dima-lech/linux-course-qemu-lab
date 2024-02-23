#!/bin/bash
cd linux-6.7.5 && make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- -j6 menuconfig

