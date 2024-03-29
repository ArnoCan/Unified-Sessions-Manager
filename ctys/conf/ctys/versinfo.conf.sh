#!/bin/bash


########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@users.sourceforge.net
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

################################################################
# Main supported runtime environments                          #
################################################################

#######
#OS
TARGET_OS="Linux: CentOS/RHEL(5+), SuSE-Professional 9.3"

#release
TARGET_WM="Gnome + fvwm"

#######
#VM
TARGET_VM="VMware(WS6<Native+VNC>+Server+Player), Xen"


#######
#WM
TARGET_WM="Gnome"



#LOC -Lines-Of-Code
#Generated during install:
# => find ctys.01_02_007a15 -type f -name '*[!~]'  -name '[!0-9][!0-9]*' -exec cat {} \;|wc -l
#LOC=36986

#LOD -Lines-Of-Documentation
#Generated during install:
# => find ctys.01_02_007a15 -type f -name '*[!~]'  -name '[0-9][0-9]*' -exec cat {} \;|wc -l
#LOD=8795

. ${MYCONFPATH}/versinfo.gen.sh
