#!/bin/bash
########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@users.sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      MARKER_VERNO
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
#
#DESCRIPTION:
#->Performs a complete setup of a basic VM on ubuntu-9.10
#
#
#
#
#
#



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
#@#INST_LABEL                =  MARKER_LABEL


####################
#some local defaults
#
_rootdrv=xvda1.img
_swapdrv=xvda2.img
_debootanchor=deboot



########################
#draft workflow-assembly
#

echo
echo "******************************************************************"
echo
echo "Initial storage setup for PARA virtualized Xen-DomU on ubuntu-9.10"
echo
echo
echo "Just a draft blueprint, use it on your own risk."
echo "Refer to GPL3."
echo
echo "******************************************************************"
echo




echo "VIRTUAL-DISK-IMAGES"
_BALLOON=MARKER_HDDBOOTIMAGE_INST_BALLOON
_bs=MARKER_HDDBOOTIMAGE_INST_BLOCKSIZE
_bs=${_bs:-1G}
_bc=MARKER_HDDBOOTIMAGE_INST_BLOCKCOUNT
_bc=${_bc:-8}
if [ "${_BALLOON}" == 'y' ];then
    let _bc--;
    echo "Create-BALLOON:${_rootdrv}"
    if [ -e "${_rootdrv}" ];then
	echo "Already present, remove first manually."
    else

	local _bsx=${_bc%%[^0-9]}
	local _unit=${_bc##[0-9]}
	if((_bsx<1));then
	    ABORT=127
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Blockcount for image creation is not valid:$_bsx"
	    gotoHell ${ABORT}
	fi

	dd if=/dev/zero of=${_rootdrv} bs=${_bs} count=1 seek=$((_bsx-1))$_unit
	mkfs.ext3 -F ${_rootdrv}
    fi

    echo "Create-BALLOON:${_swapdrv}"
    if [ -e "${_swapdrv}" ];then
	echo "Already present, remove first manually."
    else
	dd if=/dev/zero of=${_swapdrv} bs=1M count=1 seek=512
	mkswap ${_swapdrv}
    fi
else
    echo "Create-FIXED:${_rootdrv}"
    if [ -e "${_rootdrv}" ];then
	echo "Already present, remove first manually."
    else
	dd if=/dev/zero of=${_rootdrv} bs=${_bs} count=${_bc}
	mkfs.ext3 -F ${_rootdrv}
    fi
    echo "Create-FIXED:${_swapdrv}"
    if [ -e "${_swapdrv}" ];then
	echo "Already present, remove first manually."
    else
	dd if=/dev/zero of=${_swapdrv} bs=1M count=512
	mkswap ${_swapdrv}
    fi
fi
echo "MKFS"
mkdir ${_debootanchor}
mount -o loop ${_rootdrv} ${_debootanchor}





echo "DEBOOTSTRAP"
debootstrap lenny ${_debootanchor} MARKER_REPOSITORY_URL
if [ $? -ne 0 ];then
    echo "FAILED:debootstrap"
    echo "FAILED:check:MARKER_REPOSITORY_URL"
    exit 1
fi

echo "MODULES"
cp -a DOMU_MODULESDIR ${_debootanchor}/lib/modules


#it's already early in the moring, a little lazy now...
#switch a.s.a.p. to: DOMU_KERNEL + DOMU_INITRD + ...
echo "BOOT"
cp -a /boot/* ${_debootanchor}/boot

echo "FSTAB"
echo "#Generated by '$0' - MARKER_VERNO">>${_debootanchor}/etc/fstab
echo "/dev/sda1  /    ext3  defaults,errors=remount-ro  0 0">>${_debootanchor}/etc/fstab
echo "/dev/sda2  swap  swap  sw  0 0">>${_debootanchor}/etc/fstab
echo "proc  /proc proc  defaults 0 0">>${_debootanchor}/etc/fstab
echo "none  /dev/pts  devpts  defaults 0 0">>${_debootanchor}/etc/fstab


echo "INITTAB"
sed -i 's@1:2345:respawn:/sbin.*$@1:2345:respawn:/sbin/getty 38400 hvc0@' ${_debootanchor}/etc/inittab
sed -i 's@2:23:respawn:/sbin.*$@2:23:respawn:/sbin/getty 38400 tty1@' ${_debootanchor}/etc/inittab

#
#check by yourself
APTIFLAGS="--allow-untrusted --assume-yes --quiet "

echo "FINAL-APTITUDE"
chroot ${_debootanchor} aptitude ${APTIFLAGS} install udev
chroot ${_debootanchor} aptitude ${APTIFLAGS} install pciutils
chroot ${_debootanchor} aptitude ${APTIFLAGS} install bridge-utils
chroot ${_debootanchor} aptitude ${APTIFLAGS} install openssh-server
chroot ${_debootanchor} aptitude ${APTIFLAGS} install openssh-client
chroot ${_debootanchor} aptitude ${APTIFLAGS} install vnc4server
chroot ${_debootanchor} aptitude ${APTIFLAGS} install vnc4viewer
chroot ${_debootanchor} aptitude ${APTIFLAGS} install qemu 

echo "HOSTNAME"
sed -i 's/MARKER_HOST/MARKER_LABEL/g' ${_debootanchor}/etc/hostname

echo "TCP/IP0"
echo "#">>${_debootanchor}/etc/network/interfaces
echo "#Generated by '$0'">>${_debootanchor}/etc/network/interfaces
echo "TCP/IP - lo"
echo "auto lo">>${_debootanchor}/etc/network/interfaces
echo "iface lo inet loopback">>${_debootanchor}/etc/network/interfaces
echo >>${_debootanchor}/etc/network/interfaces
echo "TCP/IP - eth0"
echo "#begin-eth0">>${_debootanchor}/etc/network/interfaces
echo "#">>${_debootanchor}/etc/network/interfaces
echo "auto eth0">>${_debootanchor}/etc/network/interfaces
if [ "$DHCP" == y ];then
    echo "iface eth0 inet dhcp">>${_debootanchor}/etc/network/interfaces
else
    #assume static
    echo "iface eth0 inet static">>${_debootanchor}/etc/network/interfaces
    if [ -n "MARKER_IP" ];then
	echo "address MARKER_IP">>${_debootanchor}/etc/network/interfaces
    else
	echo "#address missing">>${_debootanchor}/etc/network/interfaces
    fi

    if [ -n "MARKER_NETMASK" ];then
	echo "netmask MARKER_NETMASK">>${_debootanchor}/etc/network/interfaces
    else
	echo "#netmask missing">>${_debootanchor}/etc/network/interfaces
    fi

    if [ -n "MARKER_GATEWAY" ];then
	echo "gateway MARKER_GATEWAY">>${_debootanchor}/etc/network/interfaces
    else
	echo "#gateway missing">>${_debootanchor}/etc/network/interfaces
    fi

    if [ -n "MARKER_MAC" ];then
	echo "#hwaddress MARKER_MAC">>${_debootanchor}/etc/network/interfaces
    else
	echo "#hwaddress missing">>${_debootanchor}/etc/network/interfaces
    fi
fi
echo "#">>${_debootanchor}/etc/network/interfaces
echo "#end-eth0">>${_debootanchor}/etc/network/interfaces
echo "#">>${_debootanchor}/etc/network/interfaces

echo "UDEV-NET"
echo "#">>${_debootanchor}/etc/nudev/rules.d/70-persistent-net.rules
echo "#Generated by '$0'">>${_debootanchor}/etc/udev/rules.d/70-persistent-net.rules
echo 'SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="MARKER_MAC", ATTR{type}=="1", KERNEL=="eth*", NAME="eth0"'>>${_debootanchor}/etc/udev/rules.d/70-persistent-net.rules
echo "#">>${_debootanchor}/etc/udev/rules.d/70-persistent-net.rules
echo "#">>${_debootanchor}/etc/udev/rules.d/70-persistent-net.rules



echo "UnifiedSessionsManager"
curAbsPath=/root/lib/ctys-$(getCurCTYSRel)
ctys-distribute -F 2 -P AnyDirectory,${_debootanchor}/${curAbsPath} localhost
chroot deboot ${curAbsPath}/bin/ctys-distribute.sh -F 2 -P UserHomeLinkonly localhost

echo "UMOUNT"
umount ${_debootanchor}

cat <<EOF

The following should be applied manually:

  Modification of /boot/grub/menu.lst
  ===================================

  1. set default to Xen-kernel:
      'DOMU_KERNEL' + 'DOMU_INITRD'

  2. Add serial:

     serial --unit=0 --speed=9600 --word=8 --parity=no --stop=1
     terminal --timeout=5 serial console

  3. Set kernel parameter:

     kernel .... noreboot console=tty0 console=ttyS0

EOF



