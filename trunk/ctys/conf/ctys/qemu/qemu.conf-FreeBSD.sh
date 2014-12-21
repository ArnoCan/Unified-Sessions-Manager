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
    #
    #Can do this with any user, so sould be the same for the following
    #access-permissions too.
    #
    [ -z "$QEMU" ]&&QEMU=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu /usr/local/bin`

    #
    #Currently supports "VirtualSquare/VDE" only for Networking on Linux-Platforms
    #
    [ -z "$VDE_TUNCTL" ]&&VDE_TUNCTL=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vde_tunctl /usr/local/sbin`
    [ -z "$VDE_SWITCH" ]&&VDE_SWITCH=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vde_switch /usr/local/bin`
    [ -z "$VDE_UNIXTERM" ]&&VDE_UNIXTERM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT unixterm /usr/local/bin`
    [ -z "$VDE_DEQ" ]&&VDE_DEQ=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vdeq  /usr/local/bin`
    [ -z "$VDE_DEQEMU" ]&&VDE_DEQEMU=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vdeqemu /usr/local/bin`


#    [ -z "$CTYS_IPTABLES" ]&&CTYS_IPTABLES=`getPathName $LINENO $BASH_SOURCE ERROR iptables /sbin`
#    [ -z "$CTYS_IP" ]&&CTYS_IP=`getPathName $LINENO $BASH_SOURCE ERROR ip /sbin`
    [ -z "$CTYS_IFCONFIG" ]&&CTYS_IFCONFIG=`getPathName $LINENO $BASH_SOURCE ERROR ifconfig /sbin`
#    [ -z "$CTYS_IFUP" ]&&CTYS_IFUP=`getPathName $LINENO $BASH_SOURCE ERROR ifup /sbin`
#    [ -z "$CTYS_IFDOWN" ]&&CTYS_IFDOWN=`getPathName $LINENO $BASH_SOURCE ERROR ifdown /sbin`
#    [ -z "$CTYS_BRCTL" ]&&CTYS_BRCTL=`getPathName $LINENO $BASH_SOURCE ERROR brctl /usr/sbin`
#    [ -z "$CTYS_NETWORK" ]&&CTYS_NETWORK=`getPathName $LINENO $BASH_SOURCE ERROR network /etc/init.d`
    [ -z "$CTYS_ROUTE" ]&&CTYS_ROUTE=`getPathName $LINENO $BASH_SOURCE ERROR route /sbin`
#    [ -z "$CTYS_UNLINK" ]&&CTYS_UNLINK=`getPathName $LINENO $BASH_SOURCE ERROR unlink /bin`

    [ -z "$CTYS_SYSCTL" ]&&CTYS_SYSCTL=`getPathName $LINENO $BASH_SOURCE ERROR sysctl /sbin`

    [ -z "$CTYS_NETCAT" ]&&CTYS_NETCAT=`getPathName $LINENO $BASH_SOURCE WARNING nc /usr/bin`
    if [ -z "$CTYS_NETCAT" ];then 
	printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "Missing NETCAT for CentOS/Redhat(TM)-style, try SuSE(TM) variant now."
	CTYS_NETCAT=`getPathName $LINENO $BASH_SOURCE ERROR netcat /usr/bin`
    fi

    [ -z "$CTYS_LSOF" ]&&CTYS_LSOF=`getPathName $LINENO $BASH_SOURCE WARNING lsof /usr/local/sbin`
fi

#
#Due to required root permissions for most of the calls to xm/virsh the 
#impersonation aproach either by sudo or ksu should be used for restricted
#calls. These calls might be released for call with root permissions 
#selectively by local impersonation as root or an execution-account, instead 
#of releasing the whole set of ctys. The ctys-tools should be executed as a 
#different user without enhanced privileges.
#
#When using the root account natively no additional permissions are required
#of course.
#
#
#For ordinary users without enhnaced privileges one of the following two 
#approaches could be applied:
#
# - ksu
#   The preferred approach should be the seamless usage of kerberos, therefore
#   "ksu" with the configuration file ".k5users" should be used.
#
#   For each user the following entry is required:
#
#     "<users-pricipal> /usr/bin/which /usr/sbin/xm /usr/bin/virsh"
#
#   Where the paths may vary.
#
#   Due to the required few calls to which, xm and/or virsh only ".k5login" 
#   is not required.
#
# - sudo
#   Basically the same, but to be handled by local configurations on any machine.
#
#
#QEMUCALL="${XENCALL:-ksu -e }"
#VDECALL="${VDECALL:-ksu -e }"

#
#Default behaviour for CANCEL
QEMU_CANCEL_DEFAULT=${QEMU_CANCEL_DEFAULT:-POWEROFF}



#
#Sets the virtual switch for interconnection of QEMU-VMs with the
#external NIC of current container, which could be VM itself.
QEMUSOCK=${QEMUSOCK:-/var/tmp/vde_switch0.$USER}


#
#Sets the virtual switch for interconnection of QEMU-VMs with the
#external NIC of current container, which could be VM itself.
QEMUMGMT=${QEMUMGMT:-/var/tmp/vde_mgmt0.$USER}



#
#Sets the virtual switch for interconnection of QEMU-VMs with the
#external NIC of current container, which could be VM itself.
QEMUBIOS=${QEMUBIOS:-$QEMU_BASE/pc-bios}


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
