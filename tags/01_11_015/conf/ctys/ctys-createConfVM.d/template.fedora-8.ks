#  -*- mode: conf; -*-
########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
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



install
url --url MARKER_REPOSITORY_URL
lang de_DE.UTF-8
#keyboard de-latin1-nodeadkeys
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



