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
Setup with default *versatile* configuration first
```
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- versatile_defconfig
```
Build kernel
```
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- -j`nproc`
```

### Busybox

Busybox provides a minimal user-space runtime environment, and includes:
* Shell (*sh*)
* Utilities (*ls*, *cat*, ...)

Busybox version used: 1.36.1

Return to top level directory (if still inside kernel source directory)
```
cd ..
```
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
Setup with default configuration first
```
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- defconfig
```
Configure using menu
```
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- menuconfig
```
Enable static build option
* Navigate in menu to:
> Settings --> Build static binary (no shared libs)

* Press *space* to mark option with '*'
* Press right arrow to select *Exit* multiple times
* Answer *Yes* to save configuration

Build Busybox
```
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- -j`nproc`
```
Install Busybox - organize all built runtime environment binaries in *_install* directory
```
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- install
```
Use `ls -la _install` to review the hierarchy of *_install* (or `tree _install` if *tree* package was installed).
This directory will be the *root* file system mounted in the target, i.e. the `/` mount point.


### (ADVANCED - NOT REQUIRED) Bash

Bash version used: 5.2.21

Good luck :)

(hint: see configure-make-bash.sh)


## Package

See *pack.sh* script for packaging Busybox environment (*_install* directory) into an archive.

Note which files are being copied into *_install*.

Return to top level directory (if still inside Busybox or Bash source directory)
```
cd ..
```
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

Review each parameter passed to QEMU:
* **machine**: target machine
* **kernel**: packaged kernel image
* **nographic**: use serial iinterface only
* **dtb**: device tree blob for Linux boot corresponding to target machine
* **initrd**: packed *initrd* image, in our case - the Busybox environment
* **append**: additional parameters passed to kernel, in our case - executed user-space binary from *initrd*

Usage example:
```
chmod +x run.sh
./run.sh env_dir
```
(*chmod* has to be done only once)

System should boot correctly. If it does, congratulations! You have your first Linux system built from scratch.

If not:
* Close QEMU target (see below)
* Go over each step above again and verify correctness

Explore the running target environment:
* Do `ls -la /bin` and compare the contents with Busybox *_install* directory
* Do `cat /var/log/messages` to see the *syslog* messages
* Do `mount` to see all mounted file systems
* Do `echo $SHELL` to see currently running shell
* View contents of *inittab* (`cat /etc/inittab` on target or `cat inittab` in working directory), and identify settings which correspond to the points above


To close QEMU target, press following two key combinations in sequence:
> ctrl+a

> x




