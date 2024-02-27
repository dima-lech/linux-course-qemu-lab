# Linux Course - QEMU Lab

This repository walks through:
* Setting up [QEMU](https://www.qemu.org) to emulate an ARM target
* Building custom (minimal) Linux environment, including [Linux Kernel](https://www.kernel.org) and [Busybox](https://busybox.net)
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

Emulated target is: [Arm Versatile Board](https://www.qemu.org/docs/master/system/arm/versatile.html) (*versatilepb*)


## Setup

Install following packages for QEMU ARM architecture and ARM cross-compiler:
> qemu-system-arm  
> gcc-arm-linux-gnueabi

In Ubuntu:
```
sudo apt update
sudo apt install qemu-system-arm gcc-arm-linux-gnueabi
```

Additional packages may be required throughout these instructions, install as needed.
For example on Ubuntu:
```
sudo apt install gcc make flex bison libncurses-dev bc xz-utils bzip2 cpio wget (...)
```


## Build

### General Notes

#### Cross-Compiling

Note that since we are building for an ARM target, we have to use a [cross-compiler](https://en.wikipedia.org/wiki/Cross_compiler). If we invoke `gcc` directly we are using our *native* toolchain which compiles only for our current architecture by default (x86_64). To invoke a cross-compiler, we have to use the format *arch*-*os*-*abi*-**gcc**, and in our case: `arm-linux-gnueabi-gcc`.

To achieve this we normally pass the **prefix** of our cross-compiler (and sometimes the architecture as well) to the Makefile, e.g. `make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi-`. This will tell the Makefile to use our cross compile instead of the native one.

Keep in mind that different projects could use different approaches for pasing this information to the build system, so it's always recommended to check the project's documentation first.

#### Using Make

By calling `make` we are invoking the build rules described in the current directory's *Makefile*. The arguments used in instructions below can be generally split into three categories:
1. **Makefile flags**: described above (*ARCH*, *CROSS_COMPILE*). These flags are passed to the Makefile in order to determine the build settings. They are specific to the currently used Makefile.
2. **Make switches**: options for make itself. For example, use `-j8` in order to run 8 concurrent jobs for faster build time. Generally this number is selected to be equal to the number of CPU cores using `nproc`, as such: `` -j`nproc` ``.
3. **Target**: "what" to build, e.g. `all`, `clean`, etc. Multiple targets can be specified, each one will be invoked sequentially in the order specified. Must be the last argument(s) for `make` command. If no target is specified then the default one is used (normally `all`). This is also specific to the currently used Makefile.  
For example: `make (...) menuconfig` builds and displays a menu-style configuration, where the project's settings can be modified before building it.


### Linux Kernel Build

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

### Busybox Build

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


### (ADVANCED - NOT REQUIRED) Bash Build

Bash version used: 5.2.21

Good luck ;)

*(hint: see configure-make-bash.sh)*


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
* **nographic**: use serial interface only
* **dtb**: device tree blob for Linux boot corresponding to target machine
* **initrd**: packed *initrd* image, in our case - the Busybox environment
* **append**: additional parameters passed to kernel, in our case - executed user-space binary from *initrd*

Usage example:
```
chmod +x run.sh
./run.sh env_dir
```
(*chmod* has to be done only once)

System should boot correctly and display a functional shell. If it does, ***congratulations!*** You have your first Linux system built from scratch.

<details>
  <summary>[Expand for boot log example]</summary>

  ```
$ ./run.sh env_dir
ALSA lib confmisc.c:767:(parse_card) cannot find card '0'
ALSA lib conf.c:4732:(_snd_config_evaluate) function snd_func_card_driver returned error: No such file or directory
ALSA lib confmisc.c:392:(snd_func_concat) error evaluating strings
ALSA lib conf.c:4732:(_snd_config_evaluate) function snd_func_concat returned error: No such file or directory
ALSA lib confmisc.c:1246:(snd_func_refer) error evaluating name
ALSA lib conf.c:4732:(_snd_config_evaluate) function snd_func_refer returned error: No such file or directory
ALSA lib conf.c:5220:(snd_config_expand) Evaluate error: No such file or directory
ALSA lib pcm.c:2642:(snd_pcm_open_noupdate) Unknown PCM default
alsa: Could not initialize DAC
alsa: Failed to open `default':
alsa: Reason: No such file or directory
ALSA lib confmisc.c:767:(parse_card) cannot find card '0'
ALSA lib conf.c:4732:(_snd_config_evaluate) function snd_func_card_driver returned error: No such file or directory
ALSA lib confmisc.c:392:(snd_func_concat) error evaluating strings
ALSA lib conf.c:4732:(_snd_config_evaluate) function snd_func_concat returned error: No such file or directory
ALSA lib confmisc.c:1246:(snd_func_refer) error evaluating name
ALSA lib conf.c:4732:(_snd_config_evaluate) function snd_func_refer returned error: No such file or directory
ALSA lib conf.c:5220:(snd_config_expand) Evaluate error: No such file or directory
ALSA lib pcm.c:2642:(snd_pcm_open_noupdate) Unknown PCM default
alsa: Could not initialize DAC
alsa: Failed to open `default':
alsa: Reason: No such file or directory
audio: Failed to create voice `lm4549.out'
vpb_sic_write: Bad register offset 0x2c
Booting Linux on physical CPU 0x0
Linux version 6.7.5-DIMA_L (dima@DIMA-DELL) (arm-linux-gnueabi-gcc (Ubuntu 9.4.0-1ubuntu1~20.04.2) 9.4.0, GNU ld (GNU Binutils for Ubuntu) 2.34) #1 Fri Feb 23 07:31:32 IST 2024
CPU: ARM926EJ-S [41069265] revision 5 (ARMv5TEJ), cr=00093177
CPU: VIVT data cache, VIVT instruction cache
OF: fdt: Machine model: ARM Versatile PB
Memory policy: Data cache writeback
Zone ranges:
  Normal   [mem 0x0000000000000000-0x0000000007ffffff]
Movable zone start for each node
Early memory node ranges
  node   0: [mem 0x0000000000000000-0x0000000007ffffff]
Initmem setup node 0 [mem 0x0000000000000000-0x0000000007ffffff]
Kernel command line: rdinit=/sbin/init
Dentry cache hash table entries: 16384 (order: 4, 65536 bytes, linear)
Inode-cache hash table entries: 8192 (order: 3, 32768 bytes, linear)
Built 1 zonelists, mobility grouping on.  Total pages: 32512
mem auto-init: stack:off, heap alloc:off, heap free:off
Memory: 119128K/131072K available (5034K kernel code, 186K rwdata, 1340K rodata, 216K init, 149K bss, 11944K reserved, 0K cma-reserved)
SLUB: HWalign=32, Order=0-3, MinObjects=0, CPUs=1, Nodes=1
NR_IRQS: 16, nr_irqs: 16, preallocated irqs: 16
VIC @(ptrval): id 0x00041190, vendor 0x41
FPGA IRQ chip 0 "interrupt-controller" @ (ptrval), 20 irqs, parent IRQ: 47
clocksource: arm,sp804: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 1911260446275 ns
sched_clock: 32 bits at 1000kHz, resolution 1000ns, wraps every 2147483647500ns
sched_clock: 32 bits at 24MHz, resolution 41ns, wraps every 89478484971ns
Console: colour dummy device 80x30
printk: legacy console [tty0] enabled
Calibrating delay loop... 2020.14 BogoMIPS (lpj=10100736)
CPU: Testing write buffer coherency: ok
pid_max: default: 32768 minimum: 301
Mount-cache hash table entries: 1024 (order: 0, 4096 bytes, linear)
Mountpoint-cache hash table entries: 1024 (order: 0, 4096 bytes, linear)
Setting up static identity map for 0x8400 - 0x8458
VFP support v0.3: implementor 41 architecture 1 part 10 variant 9 rev 0
clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 19112604462750000 ns
futex hash table entries: 256 (order: -1, 3072 bytes, linear)
NET: Registered PF_NETLINK/PF_ROUTE protocol family
DMA: preallocated 256 KiB pool for atomic coherent allocations
platform vga: Fixed dependency cycle(s) with /bridge/ports/port@1/endpoint
amba 10120000.display: Fixed dependency cycle(s) with /bridge/ports/port@0/endpoint
platform 10000000.sysreg:display@0: Fixed dependency cycle(s) with /amba/display@10120000/port@0/endpoint@0
Serial: AMBA PL011 UART driver
101f1000.serial: ttyAMA0 at MMIO 0x101f1000 (irq = 28, base_baud = 0) is a PL011 rev1
printk: legacy console [ttyAMA0] enabled
101f2000.serial: ttyAMA1 at MMIO 0x101f2000 (irq = 29, base_baud = 0) is a PL011 rev1
101f3000.serial: ttyAMA2 at MMIO 0x101f3000 (irq = 30, base_baud = 0) is a PL011 rev1
uart-pl011 10009000.serial: aliased and non-aliased serial devices found in device tree. Serial port enumeration may be unpredictable.
10009000.serial: ttyAMA3 at MMIO 0x10009000 (irq = 54, base_baud = 0) is a PL011 rev1
pps_core: LinuxPPS API ver. 1 registered
pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
PTP clock support registered
clocksource: Switched to clocksource arm,sp804
NET: Registered PF_INET protocol family
IP idents hash table entries: 2048 (order: 2, 16384 bytes, linear)
tcp_listen_portaddr_hash hash table entries: 1024 (order: 0, 4096 bytes, linear)
Table-perturb hash table entries: 65536 (order: 6, 262144 bytes, linear)
TCP established hash table entries: 1024 (order: 0, 4096 bytes, linear)
TCP bind hash table entries: 1024 (order: 1, 8192 bytes, linear)
TCP: Hash tables configured (established 1024 bind 1024)
UDP hash table entries: 256 (order: 0, 4096 bytes, linear)
UDP-Lite hash table entries: 256 (order: 0, 4096 bytes, linear)
NET: Registered PF_UNIX/PF_LOCAL protocol family
RPC: Registered named UNIX socket transport module.
RPC: Registered udp transport module.
RPC: Registered tcp transport module.
RPC: Registered tcp-with-tls transport module.
RPC: Registered tcp NFSv4.1 backchannel transport module.
NetWinder Floating Point Emulator V0.97 (double precision)
Trying to unpack rootfs image as initramfs...
workingset: timestamp_bits=30 max_order=15 bucket_order=0
jffs2: version 2.2. (NAND) © 2001-2006 Red Hat, Inc.
romfs: ROMFS MTD (C) 2007 Red Hat, Inc.
io scheduler mq-deadline registered
io scheduler kyber registered
io scheduler bfq registered
pl061_gpio 101e4000.gpio: PL061 GPIO chip registered
pl061_gpio 101e5000.gpio: PL061 GPIO chip registered
pl061_gpio 101e6000.gpio: PL061 GPIO chip registered
pl061_gpio 101e7000.gpio: PL061 GPIO chip registered
versatile-tft-panel 10000000.sysreg:display@0: no panel detected
drm-clcd-pl111 10120000.display: set up callbacks for Versatile PL110
drm-clcd-pl111 10120000.display: found bridge on endpoint 1
drm-clcd-pl111 10120000.display: Using non-panel bridge
[drm] Initialized pl111 1.0.0 20170317 for 10120000.display on minor 0
drm-clcd-pl111 10120000.display: enable Versatile CLCD connectors
Console: switching to colour frame buffer device 100x37
Freeing initrd memory: 3600K
drm-clcd-pl111 10120000.display: [drm] fb0: pl111drmfb frame buffer device
brd: module loaded
physmap-flash 34000000.flash: versatile/realview flash protection
physmap-flash 34000000.flash: physmap platform flash device: [mem 0x34000000-0x37ffffff]
34000000.flash: Found 1 x32 devices at 0x0 in 32-bit bank. Manufacturer ID 0x000000 Chip ID 0x000000
Intel/Sharp Extended Query Table at 0x0031
Using buffer write method
smc91x.c: v1.1, sep 22 2004 by Nicolas Pitre <nico@fluxnic.net>
smc91x 10010000.net eth0: SMC91C11xFD (rev 1) at (ptrval) IRQ 41

smc91x 10010000.net eth0: Ethernet addr: 52:54:00:12:34:56
rtc-ds1307 0-0068: registered as rtc0
rtc-ds1307 0-0068: setting system clock to 2024-02-27T09:10:55 UTC (1709025055)
versatile reboot driver registered
leds-syscon 10000008.0.led: registered LED (null)
leds-syscon 10000008.1.led: registered LED (null)
leds-syscon 10000008.2.led: registered LED (null)
leds-syscon 10000008.3.led: registered LED (null)
leds-syscon 10000008.4.led: registered LED (null)
leds-syscon 10000008.5.led: registered LED (null)
leds-syscon 10000008.6.led: registered LED (null)
leds-syscon 10000008.7.led: registered LED (null)
ledtrig-cpu: registered to indicate activity on CPUs
NET: Registered PF_PACKET protocol family
mmci-pl18x fpga:0b: mmc1: PL181 manf 41 rev0 at 0x1000b000 irq 49,50 (pio)
mmci-pl18x fpga:05: mmc0: PL181 manf 41 rev0 at 0x10005000 irq 59,60 (pio)
clk: Disabling unused clocks
Freeing unused kernel image (initmem) memory: 216K
Kernel memory protection not selected by kernel config.
Run /sbin/init as init process
input: AT Raw Set 2 keyboard as /devices/platform/amba/amba:fpga/10006000.kmi/serio0/input/input0
=== Hello World! ===
~ # input: ImExPS/2 Generic Explorer Mouse as /devices/platform/amba/amba:fpga/10007000.kmi/serio1/input/input2
~ #
  ```
  
</details>

If boot fails:
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




