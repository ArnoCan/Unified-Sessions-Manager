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

MYVMPATH=/homen/acue/xen/tst104
MYIMAGE0=/homen/acue/xen/tst104/xvda.img
MYIMAGE0_BS=1M
MYIMAGE0_SEEK=4095
MYIMAGE0_COUNT=1

#1. without pre-reserve:count=1 seek=<size>
#2. pre-reserve:count=<size> <undef seek>
dd if=/dev/zero of=${MYIMAGE0} oflag=direct \
  bs=${MYIMAGE0_BS} count=${MYIMAGE0_COUNT} ${MYIMAGE0_SEEK:+ seek=$MYIMAGE0_SEEK}



#dd if=/dev/zero of=${MYIMAGE0} oflag=direct bs=MYIMAGE0_BS count=MYIMAGE0_COUNT seek=MYIMAGE0_SEEK
#fully pre-reserved
#dd if=/dev/zero of=${MYIMAGE0} oflag=direct bs=1M count=4096
#dd if=/dev/zero of=${MYIMAGE0} oflag=direct bs=MYIMAGE0_BS count=MYIMAGE0_SEEK ${MYIMAGE0_SEEK:+ seek=$MYIMAGE0_SEEK}

