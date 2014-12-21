########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_02_007a17
#
########################################################################
#
# Copyright (C) 2007 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################


install
url --url ftp://delphi/UNIXDist/centOS/5/inst/os/x86_64
lang de_DE.UTF-8
network --bootproto dhcp --device eth0

# Bogus password, change to something sensible!
rootpw install

firewall --disabled
authconfig --enableshadow --enablemd5
selinux --disabled
timezone --utc Europe/Berlin
bootloader --location=mbr --driveorder=xvda --append="console=xvc0"
#reboot
poweroff

# Partitioning
clearpart --all --initlabel --drives=xvda
part /boot --fstype ext3 --size=100 --ondisk=xvda
part pv.2 --size=0 --grow --ondisk=xvda
volgroup VolGroup00 --pesize=32768 pv.2
logvol / --fstype ext3 --name=LogVol00 --vgname=VolGroup00 --size=3072 --grow
logvol swap --fstype swap --name=LogVol01 --vgname=VolGroup00 --size=256 --grow --maxsize=768

%packages
@base
@base-x
@core
@gnome-desktop
@graphical-internet
@printing
