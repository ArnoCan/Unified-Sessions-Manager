########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_06_001a03
#
########################################################################
#
# Copyright (C) 2007 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

########################################################################
#
#     Copyright (C) 2007,2008 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
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

install
url --url %MYFTP%
lang de_DE.UTF-8
network --bootproto dhcp --device eth0

# Bogus password, change to something sensible!
rootpw install

firewall --disabled
authconfig --enableshadow --enablemd5
selinux --disabled
timezone --utc Europe/Berlin
bootloader --location=mbr --driveorder=%MYDISK0% --append="console=xvc0"
#reboot
poweroff

# Partitioning
clearpart --all --initlabel --drives=%MYDISK0%
part /boot --fstype ext3 --size=100 --ondisk=%MYDISK0%
part pv.2 --size=0 --grow --ondisk=%MYDISK0%
volgroup VolGroup00 --pesize=32768 pv.2
logvol / --fstype ext3 --name=LogVol00 --vgname=VolGroup00 --size=3072 --grow
logvol swap --fstype swap --name=LogVol01 --vgname=VolGroup00 --size=256 --grow --maxsize=768

%packages
@base
#
# Append additional packages during pre-install from %MYVM%.sw
#
