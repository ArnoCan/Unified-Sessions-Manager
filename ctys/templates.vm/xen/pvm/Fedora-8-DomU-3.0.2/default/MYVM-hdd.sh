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


MYVMPATH=%MYVMPATH%
MYIMAGE0=%MYIMAGE0%
MYIMAGE0_BS=%MYDISK0_BS%
MYIMAGE0_SEEK=%MYDISK0_SEEK%
MYIMAGE0_COUNT=%MYDISK0_COUNT%

#1. without pre-reserve:count=1 seek=<size>
#2. pre-reserve:count=<size> <undef seek>
dd if=/dev/zero of=${MYIMAGE0} oflag=direct \
  bs=${MYIMAGE0_BS} count=${MYIMAGE0_COUNT} ${MYIMAGE0_SEEK:+ seek=$MYIMAGE0_SEEK}
