# Linux Course - QEMU Lab

This repository walks through:
* Setting up QEMU to emulate ARM target
* Building custom (minimal) Linux environment, including busybox
* Running resulting images in QEMU

***NOTE***: scripts are provided here for ease of usage. It is ***very*** recommended to read through the scripts to understand what is being done, better yet to perform each action manually.


## Credit

Full credit goes to:
Mark Veltzer
> https://github.com/veltzer/demos-qemu

## Additional Reading

Bootlin - Embedded Linux training

> https://bootlin.com/training/embedded-linux


## Target Hardware

Emulated target is: Arm Versatile Board (versatilepb)
> https://www.qemu.org/docs/master/system/arm/versatile.html


## Setup

Install following package for QEMU ARM architecture:
> qemu-system-arm

In Ubuntu:
```
sudo apt install qemu-system-arm
```

Install following package for ARM cross-compiler:
> gcc-arm-linux-gnueabi

In Ubuntu:
```
sudo apt install gcc-arm-linux-gnueabi
```

Additional packages may be required throughout these instructions, install as needed.
For example on Ubuntu:
```
sudo apt install gcc make flex bison libncurses-dev (...)
```


## Build

### Linux

Kernel version used: 6.7.5 (probably could be used with any 6.7.***x***)

Obtain from:
> https://kernel.org

For example:
```
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.7.5.tar.xz
```
Extract archive
```
tar -xvf linux-6.7.5.tar.xz
```
Change directory
```
cd linux-6.7.5
```
Build *versatile_defconfig* configuration
```
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- versatile_defconfig
```

### Busybox

Busybox provides a minimal user-space runtime environment, and includes:
* Shell (*sh*)
* Utilities (*ls*, *cat*, ...)

Busybox version used: 1.36.1

Obtain Busybox sources
```
wget https://busybox.net/downloads/busybox-1.36.1.tar.bz2
```
Extract archive
```
tar -xvf busybox-1.36.1.tar.bz2
```
Change directory
```
cd busybox-1.36.1
```
Configure using menu
```
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- menuconfig
```
Enable static build option
> Settings --> Build static binary

Build Busybox
```
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- -j`nproc`
```
Install Busybox - organize all running environment binaries in *_install* directory
```
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- install
```


### (ADVANCED - NOT REQUIRED) Bash

Bash version used: 5.2.21

Good luck :)

(hint: see configure-make-bash.sh)


## Package

See *pack.sh* script for packaging Busybox environment (*_install* directory) into an archive.

Note which files are being copied into *_install*.

An empty environment directory has to be created first, for example: *env_dir*
```
mkdir env_dir
```
Script usage:
```
chmod +x pack.sh
./pack.sh env_dir
```
(*chmod* has to be done only once)

Review contents of *env_dir*.

## Run

See *run.sh* script for running target with a previously packaged environment.

For example:
```
chmod +x run.sh
./run.sh env_dir
```
(*chmod* has to be done only once)

To close QEMU target, press following two key combinations in sequence:
> ctrl+a

> x




