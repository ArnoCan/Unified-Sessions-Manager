#!/bin/bash

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

MYVMPATH=%MYVMPATH%
MYIMAGE0=%MYIMAGE0%
MYIMAGE0_BS=%MYDISK0_BS%
MYIMAGE0_SEEK=%MYDISK0_SEEK%
MYIMAGE0_COUNT=%MYDISK0_COUNT%

#1. without pre-reserve:count=1 seek=<size>
#2. pre-reserve:count=<size> <undef seek>
dd if=/dev/zero of=${MYIMAGE0} oflag=direct \
  bs=${MYIMAGE0_BS} count=${MYIMAGE0_COUNT} ${MYIMAGE0_SEEK:+ seek=$MYIMAGE0_SEEK}
