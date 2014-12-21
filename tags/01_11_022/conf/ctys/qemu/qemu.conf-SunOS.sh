#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@users.sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_06_001a11
#
########################################################################
#
# Copyright (C) 2008 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
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

printDBG $S_CONF  ${D_FRAME} $LINENO $BASH_SOURCE "LOAD-CONFIG:${BASH_SOURCE}"

#protect multiple inclusion
if [ -z "$__QEMU_INCLUDED__" ];then
__QEMU_INCLUDED__=1



#Extend this when required, 
#e.g. PATH=${PATH}:/usr/sbin


#
#Base path, where the qemu packages for initial tests are stored
QEMU_BASE=${QEMU_BASE:-$HOME/qemu}


if [ -n "$C_EXECLOCAL" ];then
    printWNG 1 $LINENO $BASH_SOURCE 0 "\"Client-Only\" support for ${MYOS}"
fi


#
#The signal spec to be ignored when CLI0 is used.
QEMU_SIGIGNORESPEC="${QEMU_SIGIGNORESPEC:-2 3 19}"


#
#Trials to interconnect a vncviewer to the QEMU-VM for "vnc"
QEMU_RETRYVNCCLIENTCONNECT=15; #numerical, integer - #trials
QEMU_RETRYVNCCLIENTTIMEOUT=3;  #numerical, integer - seconds

#
#The default console when non provided, final hard-coded 
#fall-back is VNC
QEMU_DEFAULT_CONSOLE=${QEMU_DEFAULT_CONSOLE:-VNC}

#
#The default console when non provided, final hard-coded 
#fall-back is VHDD
QEMU_DEFAULT_BOOTMODE=${QEMU_DEFAULT_BOOTMODE:-VHDD}


#
#Timeout for first attempt to connect to a VM after create call.
#QEMU requires longer to start, particularly within stacks, when
#multiplr layers are involved.
QEMU_INIT_WAITC=${QEMU_INIT_WAITC:-2}
QEMU_INIT_WAITS=${QEMU_INIT_WAITS:-2}

#
#Timeout for polling the base IP stack mainly after initial start.
#WAIT unit is seconds, REPEAT unit is #nr.
CTYS_PING_DEFAULT_QEMU=${CTYS_PING_DEFAULT_QEMU:-1};
CTYS_PING_ONE_MAXTRIAL_QEMU=${CTYS_PING_ONE_MAXTRIAL_QEMU:-20};
CTYS_PING_ONE_WAIT_QEMU=${CTYS_PING_ONE_WAIT_QEMU:-2};


#
#Timeout for polling the base SSH access, requires preconfigured permissions.
#WAIT unit is seconds, REPEAT unit is #nr.
CTYS_SSHPING_DEFAULT_QEMU=${CTYS_SSHPING_DEFAULT_QEMU:-0};
CTYS_SSHPING_ONE_MAXTRIAL_QEMU=${CTYS_SSHPING_ONE_MAXTRIAL_QEMU:-20};
CTYS_SSHPING_ONE_WAIT_QEMU=${CTYS_SSHPING_ONE_WAIT_QEMU:-2};

#
#Trials to interconnect a vncviewer to the QEMU-VM for "vnc"
QEMU_RETRYVNCCLIENTCONNECT=15; #numerical, integer - #trials
QEMU_RETRYVNCCLIENTTIMEOUT=3;  #numerical, integer - seconds

#
#individual QEMU defaults for STACKCHECK parameter
#0:OFF, 1:ON
_stackChkContextQEMU=0;
_stackChkHWCapQEMU=1;
_stackChkStacCapQEMU=1:


#
#default HOSTs for login
#
QEMU_DEFAULT_HOSTS=VNC

#
#default HOSTs for CONSOLE
#
QEMU_DEFAULT_CONSOLE=VNC


#protect multiple inclusion
fi
