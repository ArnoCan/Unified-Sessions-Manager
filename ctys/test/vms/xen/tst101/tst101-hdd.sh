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


MYVMPATH=/homen/acue/xen/tst101
MYIMAGE0=/homen/acue/xen/tst101/xvda.img
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

