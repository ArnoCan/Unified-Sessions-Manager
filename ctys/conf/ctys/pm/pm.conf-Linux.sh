#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@users.sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_008
#
########################################################################
#
# Copyright (C) 2007,2008,2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

########################################################################
#
#     Copyright (C) 2007,2008,2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
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


if [ -n "$C_EXECLOCAL" ];then

    [ -z "$CTYS_IFCONFIG" ]&&CTYS_IFCONFIG=`getPathName  $LINENO $BASH_SOURCE WARNINGEXT ifconfig /sbin`
    [ -z "$CTYS_WOL" ]&&CTYS_WOL="${MYLIBEXECPATH}/ctys-wakeup.sh"
    [ -z "$CTYS_INIT" ]&&CTYS_INIT=`getPathName      $LINENO $BASH_SOURCE WARNINGEXT init /sbin`

    case ${MYDIST} in
	ESX)
	    [ -z "$CTYS_REBOOT" ]&&CTYS_REBOOT=`getPathName    $LINENO $BASH_SOURCE WARNINGEXT reboot /sbin`
	    [ -z "$CTYS_HALT" ]&&CTYS_HALT=`getPathName      $LINENO $BASH_SOURCE WARNINGEXT halt /sbin`
	    [ -z "$CTYS_POWEROFF" ]&&CTYS_POWEROFF=`getPathName  $LINENO $BASH_SOURCE WARNINGEXT poweroff /sbin`
	    [ -z "$CTYS_ETHTOOL" ]&&CTYS_ETHTOOL=`getPathName   $LINENO $BASH_SOURCE WARNINGEXT ethtool /sbin`
	    [ -z "$CTYS_WOL_LOCAL" ]&&CTYS_WOL_LOCAL=`getPathName $LINENO $BASH_SOURCE WARNINGEXT ether-wake /sbin`
	    [ -z "$CTYS_NETCAT0" ]&&CTYS_NETCAT0=`getPathName $LINENO $BASH_SOURCE WARNINGEXT nc /usr/bin`
	    ;;
	XenServer)
	    [ -z "$CTYS_REBOOT" ]&&CTYS_REBOOT=`getPathName    $LINENO $BASH_SOURCE WARNINGEXT reboot /sbin`
	    [ -z "$CTYS_HALT" ]&&CTYS_HALT=`getPathName      $LINENO $BASH_SOURCE WARNINGEXT halt /sbin`
	    [ -z "$CTYS_POWEROFF" ]&&CTYS_POWEROFF=`getPathName  $LINENO $BASH_SOURCE WARNINGEXT poweroff /sbin`
	    [ -z "$CTYS_ETHTOOL" ]&&CTYS_ETHTOOL=`getPathName   $LINENO $BASH_SOURCE WARNINGEXT ethtool /sbin`
	    [ -z "$CTYS_WOL_LOCAL" ]&&CTYS_WOL_LOCAL=`getPathName $LINENO $BASH_SOURCE WARNINGEXT ether-wake /sbin`
	    [ -z "$CTYS_NETCAT0" ]&&CTYS_NETCAT0=`getPathName $LINENO $BASH_SOURCE WARNINGEXT nc /usr/bin`
	    ;;
	MeeGo)
	    [ -z "$CTYS_REBOOT" ]&&CTYS_REBOOT=`getPathName    $LINENO $BASH_SOURCE WARNINGEXT reboot /sbin`
	    [ -z "$CTYS_HALT" ]&&CTYS_HALT=`getPathName      $LINENO $BASH_SOURCE WARNINGEXT halt /sbin`
	    [ -z "$CTYS_POWEROFF" ]&&CTYS_POWEROFF=`getPathName  $LINENO $BASH_SOURCE WARNINGEXT poweroff /sbin`
	    [ -z "$CTYS_ETHTOOL" ]&&CTYS_ETHTOOL=`getPathName   $LINENO $BASH_SOURCE WARNINGEXT ethtool /sbin`
	    [ -z "$CTYS_WOL_LOCAL" ]&&CTYS_WOL_LOCAL=`getPathName $LINENO $BASH_SOURCE WARNINGEXT ether-wake /sbin`
	    [ -z "$CTYS_NETCAT0" ]&&CTYS_NETCAT0=`getPathName $LINENO $BASH_SOURCE WARNINGEXT nc /usr/bin`
	    ;;
	CentOS)
	    [ -z "$CTYS_REBOOT" ]&&CTYS_REBOOT=`getPathName    $LINENO $BASH_SOURCE WARNINGEXT reboot /sbin`
	    [ -z "$CTYS_HALT" ]&&CTYS_HALT=`getPathName      $LINENO $BASH_SOURCE WARNINGEXT halt /sbin`
	    [ -z "$CTYS_POWEROFF" ]&&CTYS_POWEROFF=`getPathName  $LINENO $BASH_SOURCE WARNINGEXT poweroff /sbin`
	    [ -z "$CTYS_ETHTOOL" ]&&CTYS_ETHTOOL=`getPathName   $LINENO $BASH_SOURCE WARNINGEXT ethtool /sbin`
	    [ -z "$CTYS_WOL_LOCAL" ]&&CTYS_WOL_LOCAL=`getPathName $LINENO $BASH_SOURCE WARNINGEXT ether-wake /sbin`
	    [ -z "$CTYS_NETCAT0" ]&&CTYS_NETCAT0=`getPathName $LINENO $BASH_SOURCE WARNINGEXT nc /usr/bin`
	    ;;
	EnterpriseLinux)
	    [ -z "$CTYS_REBOOT" ]&&CTYS_REBOOT=`getPathName    $LINENO $BASH_SOURCE WARNINGEXT reboot /sbin`
	    [ -z "$CTYS_HALT" ]&&CTYS_HALT=`getPathName      $LINENO $BASH_SOURCE WARNINGEXT halt /sbin`
	    [ -z "$CTYS_POWEROFF" ]&&CTYS_POWEROFF=`getPathName  $LINENO $BASH_SOURCE WARNINGEXT poweroff /sbin`
	    [ -z "$CTYS_ETHTOOL" ]&&CTYS_ETHTOOL=`getPathName   $LINENO $BASH_SOURCE WARNINGEXT ethtool /sbin`
	    [ -z "$CTYS_WOL_LOCAL" ]&&CTYS_WOL_LOCAL=`getPathName $LINENO $BASH_SOURCE WARNINGEXT ether-wake /sbin`
	    [ -z "$CTYS_NETCAT0" ]&&CTYS_NETCAT0=`getPathName $LINENO $BASH_SOURCE WARNINGEXT nc /usr/bin`
	    ;;
	RHEL)
	    [ -z "$CTYS_REBOOT" ]&&CTYS_REBOOT=`getPathName    $LINENO $BASH_SOURCE WARNINGEXT reboot /sbin`
	    [ -z "$CTYS_HALT" ]&&CTYS_HALT=`getPathName      $LINENO $BASH_SOURCE WARNINGEXT halt /sbin`
	    [ -z "$CTYS_POWEROFF" ]&&CTYS_POWEROFF=`getPathName  $LINENO $BASH_SOURCE WARNINGEXT poweroff /sbin`
	    [ -z "$CTYS_ETHTOOL" ]&&CTYS_ETHTOOL=`getPathName   $LINENO $BASH_SOURCE WARNINGEXT ethtool /sbin`
	    [ -z "$CTYS_WOL_LOCAL" ]&&CTYS_WOL_LOCAL=`getPathName $LINENO $BASH_SOURCE WARNINGEXT ether-wake /sbin`
	    [ -z "$CTYS_NETCAT0" ]&&CTYS_NETCAT0=`getPathName $LINENO $BASH_SOURCE WARNINGEXT nc /usr/bin`
	    ;;
	Scientific)
	    [ -z "$CTYS_REBOOT" ]&&CTYS_REBOOT=`getPathName    $LINENO $BASH_SOURCE WARNINGEXT reboot /sbin`
	    [ -z "$CTYS_HALT" ]&&CTYS_HALT=`getPathName      $LINENO $BASH_SOURCE WARNINGEXT halt /sbin`
	    [ -z "$CTYS_POWEROFF" ]&&CTYS_POWEROFF=`getPathName  $LINENO $BASH_SOURCE WARNINGEXT poweroff /sbin`
	    [ -z "$CTYS_ETHTOOL" ]&&CTYS_ETHTOOL=`getPathName   $LINENO $BASH_SOURCE WARNINGEXT ethtool /sbin`
	    [ -z "$CTYS_WOL_LOCAL" ]&&CTYS_WOL_LOCAL=`getPathName $LINENO $BASH_SOURCE WARNINGEXT ether-wake /sbin`
	    [ -z "$CTYS_NETCAT0" ]&&CTYS_NETCAT0=`getPathName $LINENO $BASH_SOURCE WARNINGEXT nc /usr/bin`
	    ;;
	Fedora)
	    [ -z "$CTYS_REBOOT" ]&&CTYS_REBOOT=`getPathName    $LINENO $BASH_SOURCE WARNINGEXT reboot /sbin`
	    [ -z "$CTYS_HALT" ]&&CTYS_HALT=`getPathName      $LINENO $BASH_SOURCE WARNINGEXT halt /sbin`
	    [ -z "$CTYS_POWEROFF" ]&&CTYS_POWEROFF=`getPathName  $LINENO $BASH_SOURCE WARNINGEXT poweroff /sbin`
	    [ -z "$CTYS_ETHTOOL" ]&&CTYS_ETHTOOL=`getPathName   $LINENO $BASH_SOURCE WARNINGEXT ethtool /sbin`
	    [ -z "$CTYS_WOL_LOCAL" ]&&CTYS_WOL_LOCAL=`getPathName $LINENO $BASH_SOURCE WARNINGEXT ether-wake /sbin`
	    [ -z "$CTYS_NETCAT0" ]&&CTYS_NETCAT0=`getPathName $LINENO $BASH_SOURCE WARNINGEXT nc /usr/bin`
	    ;;
	SuSE)
	    [ -z "$CTYS_REBOOT" ]&&CTYS_REBOOT=`getPathName    $LINENO $BASH_SOURCE WARNINGEXT reboot /sbin`
	    [ -z "$CTYS_HALT" ]&&CTYS_HALT=`getPathName      $LINENO $BASH_SOURCE WARNINGEXT halt /sbin`
	    [ -z "$CTYS_POWEROFF" ]&&CTYS_POWEROFF=`getPathName  $LINENO $BASH_SOURCE WARNINGEXT poweroff /sbin`
	    [ -z "$CTYS_ETHTOOL" ]&&CTYS_ETHTOOL=`getPathName   $LINENO $BASH_SOURCE WARNINGEXT ethtool /usr/sbin`
	    [ -z "$CTYS_NETCAT0" ]&&CTYS_NETCAT0=`getPathName $LINENO $BASH_SOURCE WARNINGEXT nc /usr/bin`
	    [ -z "$CTYS_WOL_LOCAL" ]&&CTYS_WOL_LOCAL=`getPathName $LINENO $BASH_SOURCE WARNINGEXT wol /usr/bin`
	    ;;
	openSUSE)
	    [ -z "$CTYS_REBOOT" ]&&CTYS_REBOOT=`getPathName    $LINENO $BASH_SOURCE WARNINGEXT reboot /sbin`
	    [ -z "$CTYS_HALT" ]&&CTYS_HALT=`getPathName      $LINENO $BASH_SOURCE WARNINGEXT halt /sbin`
	    [ -z "$CTYS_POWEROFF" ]&&CTYS_POWEROFF=`getPathName  $LINENO $BASH_SOURCE WARNINGEXT poweroff /sbin`
	    [ -z "$CTYS_ETHTOOL" ]&&CTYS_ETHTOOL=`getPathName   $LINENO $BASH_SOURCE WARNINGEXT ethtool /usr/sbin`
	    [ -z "$CTYS_WOL_LOCAL" ]&&CTYS_WOL_LOCAL=`getPathName $LINENO $BASH_SOURCE WARNINGEXT wol /usr/bin`
 	    [ -z "$CTYS_NETCAT0" ]&&CTYS_NETCAT0=`getPathName $LINENO $BASH_SOURCE WARNINGEXT nc /usr/bin`
 	    [ -z "$CTYS_NETCAT0" ]&&CTYS_NETCAT0=`getPathName $LINENO $BASH_SOURCE WARNINGEXT netcat /usr/bin`
	    ;;
	debian)
	    [ -z "$CTYS_REBOOT" ]&&CTYS_REBOOT=`getPathName    $LINENO $BASH_SOURCE WARNINGEXT reboot /sbin`
	    [ -z "$CTYS_HALT" ]&&CTYS_HALT=`getPathName      $LINENO $BASH_SOURCE WARNINGEXT halt /sbin`
	    [ -z "$CTYS_POWEROFF" ]&&CTYS_POWEROFF=`getPathName  $LINENO $BASH_SOURCE WARNINGEXT poweroff /sbin`
	    [ -z "$CTYS_WOL_LOCAL" ]&&CTYS_WOL_LOCAL=`getPathName $LINENO $BASH_SOURCE WARNINGEXT etherwake /usr/sbin`
	    [ -z "$CTYS_NETCAT0" ]&&CTYS_NETCAT0=`getPathName $LINENO $BASH_SOURCE WARNINGEXT nc /bin`
	    [ -z "$CTYS_ETHTOOL" ]&&CTYS_ETHTOOL=`getPathName   $LINENO $BASH_SOURCE WARNINGEXT ethtool /usr/sbin`
	    ;;
	Ubuntu)
	    [ -z "$CTYS_REBOOT" ]&&CTYS_REBOOT=`getPathName    $LINENO $BASH_SOURCE WARNINGEXT reboot /sbin`
	    [ -z "$CTYS_HALT" ]&&CTYS_HALT=`getPathName      $LINENO $BASH_SOURCE WARNINGEXT halt /sbin`
	    [ -z "$CTYS_POWEROFF" ]&&CTYS_POWEROFF=`getPathName  $LINENO $BASH_SOURCE WARNINGEXT poweroff /sbin`
	    [ -z "$CTYS_WOL_LOCAL" ]&&CTYS_WOL_LOCAL=`getPathName $LINENO $BASH_SOURCE WARNINGEXT etherwake /usr/sbin`
	    [ -z "$CTYS_NETCAT0" ]&&CTYS_NETCAT0=`getPathName $LINENO $BASH_SOURCE WARNINGEXT nc /usr/bin`
	    [ -z "$CTYS_ETHTOOL" ]&&CTYS_ETHTOOL=`getPathName   $LINENO $BASH_SOURCE WARNINGEXT ethtool /usr/sbin`
	    ;;
	FreeBSD|OpenBSD)
	    [ -z "$CTYS_REBOOT" ]&&CTYS_REBOOT=`getPathName    $LINENO $BASH_SOURCE WARNINGEXT reboot /sbin`
	    [ -z "$CTYS_HALT" ]&&CTYS_HALT=`getPathName      $LINENO $BASH_SOURCE WARNINGEXT halt /sbin`
	    [ -z "$CTYS_POWEROFF" ]&&CTYS_POWEROFF=`getPathName  $LINENO $BASH_SOURCE WARNINGEXT poweroff /sbin`
	    [ -z "$CTYS_WOL_LOCAL" ]&&CTYS_WOL_LOCAL=`getPathName $LINENO $BASH_SOURCE WARNINGEXT wol /usr/local/bin`
	    ;;
	Mandriva)
	    [ -z "$CTYS_REBOOT" ]&&CTYS_REBOOT=`getPathName    $LINENO $BASH_SOURCE WARNINGEXT reboot /sbin`
	    [ -z "$CTYS_HALT" ]&&CTYS_HALT=`getPathName      $LINENO $BASH_SOURCE WARNINGEXT halt /sbin`
	    [ -z "$CTYS_POWEROFF" ]&&CTYS_POWEROFF=`getPathName  $LINENO $BASH_SOURCE WARNINGEXT poweroff /sbin`
	    [ -z "$CTYS_ETHTOOL" ]&&CTYS_ETHTOOL=`getPathName   $LINENO $BASH_SOURCE WARNINGEXT ethtool /sbin`
	    [ -z "$CTYS_WOL_LOCAL" ]&&CTYS_WOL_LOCAL=`getPathName $LINENO $BASH_SOURCE WARNINGEXT ether-wake /sbin`
	    [ -z "$CTYS_NETCAT0" ]&&CTYS_NETCAT0=`getPathName $LINENO $BASH_SOURCE WARNINGEXT nc /usr/bin`
	    ;;
	SunOS)
	    [ -z "$CTYS_REBOOT" ]&&CTYS_REBOOT=`getPathName    $LINENO $BASH_SOURCE WARNINGEXT reboot /usr/sbin`
	    [ -z "$CTYS_HALT" ]&&CTYS_HALT=`getPathName      $LINENO $BASH_SOURCE WARNINGEXT halt /usr/sbin`
	    [ -z "$CTYS_POWEROFF" ]&&CTYS_POWEROFF=`getPathName  $LINENO $BASH_SOURCE WARNINGEXT poweroff /usr/sbin`

	    [ -z "$CTYS_WOL_LOCAL" ]&&CTYS_WOL_LOCAL=`getPathName $LINENO $BASH_SOURCE WARNINGEXT etherwake /usr/sbin`
	    [ -z "$CTYS_ETHTOOL" ]&&CTYS_ETHTOOL=`getPathName   $LINENO $BASH_SOURCE WARNINGEXT ethtool /usr/sbin`
	    ;;
	*)
	    [ -z "$CTYS_REBOOT" ]&&CTYS_REBOOT=`getPathName    $LINENO $BASH_SOURCE WARNINGEXT reboot /sbin`
	    [ -z "$CTYS_HALT" ]&&CTYS_HALT=`getPathName      $LINENO $BASH_SOURCE WARNINGEXT halt /sbin`
	    [ -z "$CTYS_POWEROFF" ]&&CTYS_POWEROFF=`getPathName  $LINENO $BASH_SOURCE WARNINGEXT poweroff /sbin`
	    ;;
    esac
fi


#########
#WOL
#
##################
#packet originator
##################
#
#Take the first interface only, works for bonding too, but should be considered
#e.g. for multi-homed. 
#
#local subnet default
if [ -z "${CTYS_WOL_WAKEUPIF}" ];then
    CTYS_WOL_WAKEUPIF=`netGetFirstIf`
    if [ -z "${CTYS_WOL_WAKEUPIF}" ];then
	printWNG 1 $LINENO $BASH_SOURCE 1  "Can not evaluate WAKEUP send interface."
    fi
fi
#
#local subnet default
if [ -z "${CTYS_WOL_BROADCAST}" ];then
    CTYS_WOL_BROADCAST=`netGetIfBroadcast ${CTYS_WOL_BROADCAST}`
    if [ -z "${CTYS_WOL_BROADCAST}" ];then
	printWNG 1 $LINENO $BASH_SOURCE 1  "Can not evaluate WAKEUP broadcast address."
    fi
fi
CTYS_WOL_WAKEUP=$CTYS_WOL

printDBG $S_CONF  ${D_FRAME} $LINENO $BASH_SOURCE "CTYS_WOL_WAKEUP   =$CTYS_WOL_WAKEUP"
printDBG $S_CONF  ${D_FRAME} $LINENO $BASH_SOURCE "CTYS_WOL_WAKEUPIF =$CTYS_WOL_WAKEUPIF"
printDBG $S_CONF  ${D_FRAME} $LINENO $BASH_SOURCE "CTYS_WOL_BROADCAST=$CTYS_WOL_BROADCAST"


###################
#packet destination
###################
#
#
#has to use the physical interface, which is assumed for XEN to be of form "peth0"
#
#BUT for current version (3.0.2) ethtool does not work for "g"-MagicPacket, even though
#broadcasts DOES ("umbg"), so following generic work-around is implemented.
#
# 1. proceed here as usual - ignore the error for now
# 2. If "-a CANCEL=WOL,..." is called:
#    Check for cancel with WOL option whether specific handling for Xen is required.
#    If so, remove bridges first, and scan for interfaces again.
#    BUT do not scan, if user has provided one to use, than it is his responsibility.
#
#
#so following scan priority is used:
#
# 1. pre-set is taken
# 2. else: the first non-lo is taken 
#
# 3. The subsystems are responsible for management of their non standard interface names and
#    the bridges eventually required, thus will decide how to proceed.
#
#Multiple interfaces could be defined with the naming schema:
#
#  CTYS_ETHTOOL_WOLIF<index>
#
#Access-grant is checked only for the first:CTYS_ETHTOOL_WOLIF
#
#check whether IF is pre-set by user
if [ -z "${CTYS_ETHTOOL_WOLIF}" ];then
    CTYS_ETHTOOL_WOLIF=`netGetFirstIf`
    if [ -z "${CTYS_ETHTOOL_WOLIF}" ];then
	printWNG 1 $LINENO $BASH_SOURCE 0  "Can not evaluate target WoL interface."
    fi
fi
printDBG $S_CONF  ${D_FRAME} $LINENO $BASH_SOURCE "CTYS_ETHTOOL_WOLIF=$CTYS_ETHTOOL_WOLIF"



#The timout for a wait loop, when a console is defined.
#This applies to "Soft-Consoles" only, which are to be executed on the target 
#itself.
#When an IP based "Remote-IP-Console" or a Serial-Console is used, a timeout is not 
#required of course.
#
#The value is the sleep-value between failing ping and ssh-requests until success.
CTYS_WOL_WAKEUP_WAIT=${CTYS_WOL_WAKEUP_WAIT:-10}

#This is the maximum number of repetition perionds for attachment trials to the PM.
CTYS_WOL_WAKEUP_MAXTRIAL=${CTYS_WOL_WAKEUP_MAXTRIAL:-24}

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

