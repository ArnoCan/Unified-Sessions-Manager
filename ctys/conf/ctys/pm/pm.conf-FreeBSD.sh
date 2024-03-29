#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@users.sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_07_001b02
#
########################################################################
#
# Copyright (C) 2007,2008 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
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


#Extend this when required, 
#e.g. PATH=${PATH}:/usr/sbin

[ -z "$CTYS_HALT" ]&&CTYS_HALT=`getPathName      $LINENO $BASH_SOURCE WARNINGEXT halt /sbin`
[ -z "$CTYS_REBOOT" ]&&CTYS_REBOOT=`getPathName    $LINENO $BASH_SOURCE WARNINGEXT reboot /sbin`
[ -z "$CTYS_POWEROFF" ]&&CTYS_POWEROFF=`getPathName  $LINENO $BASH_SOURCE WARNINGEXT shutdown /sbin`
[ -z "$CTYS_INIT" ]&&CTYS_INIT=`getPathName      $LINENO $BASH_SOURCE WARNINGEXT init /sbin`

[ -z "$CTYS_IFCONFIG" ]&&CTYS_IFCONFIG=`getPathName  $LINENO $BASH_SOURCE WARNINGEXT ifconfig /sbin`
[ -z "$CTYS_ETHTOOL" ]&&CTYS_ETHTOOL=`getPathName   $LINENO $BASH_SOURCE WARNINGEXT ethtool /sbin`
[ -z "$CTYS_WOL" ]&&CTYS_WOL="${MYLIBEXECPATH}/ctys-wakeup.sh"
[ -z "$CTYS_WOL_LOCAL" ]&&CTYS_WOL_LOCAL=`getPathName $LINENO $BASH_SOURCE WARNINGEXT wol /usr/local/bin`
[ -z "$CTYS_NETCAT0" ]&&CTYS_NETCAT0=`getPathName $LINENO $BASH_SOURCE WARNINGEXT nc /usr/bin`


#Call for Remote-IP-Console.
CONSOLE_IPC=

#Call for Serial attached console.
CONSOLE_SERIAL=

#delay bevor executing POWEROFF
PM_POWOFFDELAY=${PM_POWOFFDELAY:-30}

#
#Timeout for first attempt to connect to a VM after create call.
#PM requires longer to start, particularly within stacks, when
#multiplr layers are involved.
PM_INIT_WAITC=${PM_INIT_WAITC:-2}
PM_INIT_WAITS=${PM_INIT_WAITS:-2}

#
#Timeout for polling the base IP stack mainly after initial start.
#WAIT unit is seconds, REPEAT unit is #nr.
CTYS_PING_DEFAULT_PM=${CTYS_PING_DEFAULT_PM:-1};
CTYS_PING_ONE_MAXTRIAL_PM=${CTYS_PING_ONE_MAXTRIAL_PM:-40};
CTYS_PING_ONE_WAIT_PM=${CTYS_PING_ONE_WAIT_PM:-3};

#
#Timeout for polling the base SSH access, requires preconfigured permissions.
#WAIT unit is seconds, REPEAT unit is #nr.
CTYS_SSHPING_DEFAULT_PM=${CTYS_SSHPING_DEFAULT_PM:-0};
CTYS_SSHPING_ONE_MAXTRIAL_PM=${CTYS_SSHPING_ONE_MAXTRIAL_PM:-20};
CTYS_SSHPING_ONE_WAIT_PM=${CTYS_SSHPING_ONE_WAIT_PM:-3};

#
#Trials to interconnect a vncviewer to the PM-VM for "vnc"
PM_RETRYVNCCLIENTCONNECT=15; #numerical, integer - #trials
PM_RETRYVNCCLIENTTIMEOUT=3;  #numerical, integer - seconds

#
#individual PM defaults for STACKCHECK parameter
#0:OFF, 1:ON
_stackChkContextPM=0;
_stackChkHWCapPM=0;
_stackChkStacCapPM=0:



#
#default HOSTs for login
#
PM_DEFAULT_HOSTS=VNC

#
#default HOSTs for CONSOLE
#
PM_DEFAULT_CONSOLE=VNC

