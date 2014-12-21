#!/bin/bash
########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@users.sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_10_013
#
########################################################################
#
#     Copyright (C) 2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
#     This program is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
#
#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
#
#     You should have received a copy of the GNU General Public License
#     along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
########################################################################

#
#INSTALLER-INFO:
#===============
#
#@#INST_EDITOR               =  MARKER_EDITOR
#@#INST_DATE                 =  MARKER_DATE
#@#INST_CTYSREL              =  MARKER_CTYSREL
#@#INST_VERNO                =  MARKER_VERNO
#@#INST_SERNO                =  MARKER_SERNO
#@#INST_UID                  =  MARKER_UID
#@#INST_GID                  =  MARKER_GID
#@#INST_HOST                 =  MARKER_HOST








# install
# url --url MARKER_REPOSITORY_URL
# lang de_DE.UTF-8
# keyboard de-latin1-nodeadkeys
# network --bootproto dhcp --device eth0





# # Bogus password, change to something sensible!
# #rootpw --iscrypted $1$GSH3s.Pf$L5V/cTZTWo3FABVezJDjm0
# rootpw install

# firewall --disabled
# authconfig --enableshadow --enablemd5
# selinux --disabled
# timezone --utc Europe/Berlin
# bootloader --location=mbr --driveorder=xvda --append="console=xvc0"
# #reboot
# poweroff

# # Partitioning
# clearpart --all --initlabel --drives=xvda
# part /boot --fstype ext3 --size=100 --ondisk=xvda
# part pv.2 --size=0 --grow --ondisk=xvda
# volgroup VolGroup00 --pesize=32768 pv.2
# logvol / --fstype ext3 --name=LogVol00 --vgname=VolGroup00 --size=3072 --grow
# logvol swap --fstype swap --name=LogVol01 --vgname=VolGroup00 --size=256 --grow --maxsize=768

# %packages
# @base
# #@base-x
# @core
# #@gnome-desktop
# #@graphical-internet
# #@printing


###################################################################
###################################################################
###################################################################
#1.  dd if=/dev/zero of=xvda2.img bs=1M count=1 seek=512
#2.  mkswap xvda2.im
#3.  dd if=/dev/zero of=xvda1.img bs=1M count=1 seek=6143
#4.  mkfs.ext3 xvda1.img
#5.  mount -o loop xvda1.img debootstrap-232
#6.  debootstrap lenny debootstrap-232 http://delphi/isos/debian/5.0.0/raw/5.0.0/amd64/iso-dvd/debian-500-amd64-DVD-1
#7.  cd debootstrap-232
#8.  cd lib/modules
#9.  cp -a /lib/modules/2.6.26-2-xen-amd64 .
#10. cd ../../boot
#11. cp -a /boot/* .
#12. cd ../etc
#13. vi fstab
#      /dev/sda1          /             ext3      defaults,errors=remount-ro    0     0
#      /dev/sda2          swap          swap      sw                            0     0
#      proc               /proc         proc      defaults                      0     0
#      none            /dev/pts        devpts  defaults 0 0
#14. vi inttab
#      1:2345:respawn:/sbin/getty 38400 hvc0
#      2:23:respawn:/sbin/getty 38400 tty1
#
#15. cd ../boot/grub
#16. vi menu.lst
#      default <#xen-domU>
#
#      serial --unit=0 --speed=9600 --word=8 --parity=no --stop=1
#      terminal --timeout=5 serial console
#
#      kernel .... noreboot console=tty1 console=ttsS0
#
#
#
#17. cd ../../..
#18. chroot debootstrap-232
#19. aptitude udev
#20. exit
#21. umount debootstrap-232
#22. /usr/sbin/xm create -c /mntn/vmpool/vmpool05/xen/tst232/tst232-inst.conf  vcpus=1 memory=512 vif='mac=00:50:56:13:12:20,bridge=eth1' vnc=1 bootloader="/usr/lib64/xen-3.2-1/bin/pygrub" boot=d
#
#




###################################################################
###################################################################
###################################################################
#1.  dd if=/dev/zero of=xvda2.img bs=1M count=1 seek=512
#2.  mkswap xvda2.img
#3.  dd if=/dev/zero of=xvda1.img bs=1M count=1 seek=6143
#4.  losetup /dev/loop7 xvda1.img
#5.  fdisk /dev/loop7
#6.  kpartx -a -p "-part" -v /dev/loop7
#      add map loop7-part1 (253:5): 0 530082 linear /dev/loop7 63
#      add map loop7-part2 (253:6): 0 1012095 linear /dev/loop7 530145
#      add map loop7-part3 (253:7): 0 11036655 linear /dev/loop7 1542240
#
#7.  mkfs.ext3  /dev/mapper/loop7-part1
#8.  mkswap /dev/mapper/loop7-part2
#9.  mkfs.ext3  /dev/mapper/loop7-part3
#10. mount /dev/mapper/loop7-part3  deboot
#11. mkdir deboot/boot
#12. mount /dev/mapper/loop7-part1  deboot/boot
#13. debootstrap lenny deboot  http://delphi/isos/debian/5.0.0/raw/5.0.0/amd64/iso-dvd/debian-500-amd64-DVD-1
#14. cp -a /lib/modules/2.6.26-2-xen-amd64 deboot/lib/modules
#15. cp -a /boot/* deboot/boot
#16. vi deboot/etc/fstab
#      /dev/sda1          /             ext3      defaults,errors=remount-ro    0     0
#      /dev/sda2          swap          swap      sw                            0     0
#      proc               /proc         proc      defaults                      0     0
#      none            /dev/pts        devpts  defaults 0 0
#
#17. vi deboot/etc/inittab
#      1:2345:respawn:/sbin/getty 38400 hvc0
#      2:23:respawn:/sbin/getty 38400 tty1
#
#18. vi deboot/boot/grub/menu.lst
#      default <#xen-domU> (0)
#
#      serial --unit=0 --speed=9600 --word=8 --parity=no --stop=1
#      terminal --timeout=5 serial console
#
#      title           Debian GNU/Linux, kernel 2.6.26-2-xen-amd64
#      root            (hd0,0)
#      kernel          /vmlinuz-2.6.26-2-xen-amd64 root=/dev/md0 ro noreboot console=tty1 console=ttsS0
#      initrd          /initrd.img-2.6.26-2-xen-amd64
#
#19. chroot deboot
#20. aptitude install udev
#21. exit
#22. umount deboot/boot
#23. umount deboot
#24. kpartx -d -p "-part" -v /dev/loop7
#24. losetup -d  /dev/loop7
#26. /usr/sbin/xm create -c /mntn/vmpool/vmpool05/xen/tst233/tst233-inst.conf boot=c
