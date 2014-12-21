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

#
#Base path, where the xen packages for initial tests are stored
XEN_BASE=${XEN_BASE:-$HOME/xen}


#
#Can do this with any user, so sould be the same for the following
#access-permissions too.
#
if [ -n "$C_EXECLOCAL" ];then
    [ -z "$XM" ]&&XM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT xm /usr/sbin`
    [ -z "$VIRSH" ]&&VIRSH=`getPathName $LINENO $BASH_SOURCE WARNINGEXT virsh /usr/bin`
    [ -z "$XENTRACE" ]&&XENTRACE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT xentrace /usr/bin`
    [ -z "$CTYS_RPM" ]&&CTYS_RPM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT rpm /bin`

    [ -z "$CTYS_HOST" ]&&CTYS_HOST=`getPathName $LINENO $BASH_SOURCE ERROR host /usr/bin`

    [ -z "$CTYS_ETHTOOL" ]&&CTYS_ETHTOOL=`getPathName $LINENO $BASH_SOURCE WARNINGEXT ethtool /sbin`
    [ -z "$CTYS_IP" ]&&CTYS_IP=`getPathName $LINENO $BASH_SOURCE ERROR ip /sbin`
    [ -z "$CTYS_IFCONFIG" ]&&CTYS_IFCONFIG=`getPathName $LINENO $BASH_SOURCE ERROR ifconfig /sbin`
    [ -z "$CTYS_IFUP" ]&&CTYS_IFUP=`getPathName $LINENO $BASH_SOURCE ERROR ifup /sbin`
    [ -z "$CTYS_IFDOWN" ]&&CTYS_IFDOWN=`getPathName $LINENO $BASH_SOURCE ERROR ifdown /sbin`
    [ -z "$CTYS_ROUTE" ]&&CTYS_ROUTE=`getPathName $LINENO $BASH_SOURCE ERROR route /sbin`

    case ${MYDIST} in
	CentOS)
	    [ -z "$CTYS_IPTABLES" ]&&CTYS_IPTABLES=`getPathName $LINENO $BASH_SOURCE ERROR iptables /sbin`
	    [ -z "$CTYS_BRCTL" ]&&CTYS_BRCTL=`getPathName $LINENO $BASH_SOURCE ERROR brctl /usr/sbin`
	    [ -z "$CTYS_NETWORK" ]&&CTYS_NETWORK=`getPathName $LINENO $BASH_SOURCE ERROR network /etc/init.d`
	    ;;
	EnterpriseLinux)
	    [ -z "$CTYS_IPTABLES" ]&&CTYS_IPTABLES=`getPathName $LINENO $BASH_SOURCE ERROR iptables /sbin`
	    [ -z "$CTYS_BRCTL" ]&&CTYS_BRCTL=`getPathName $LINENO $BASH_SOURCE ERROR brctl /usr/sbin`
	    [ -z "$CTYS_NETWORK" ]&&CTYS_NETWORK=`getPathName $LINENO $BASH_SOURCE ERROR network /etc/init.d`
	    ;;
	RHEL)
	    [ -z "$CTYS_IPTABLES" ]&&CTYS_IPTABLES=`getPathName $LINENO $BASH_SOURCE ERROR iptables /sbin`
	    [ -z "$CTYS_BRCTL" ]&&CTYS_BRCTL=`getPathName $LINENO $BASH_SOURCE ERROR brctl /usr/sbin`
	    [ -z "$CTYS_NETWORK" ]&&CTYS_NETWORK=`getPathName $LINENO $BASH_SOURCE ERROR network /etc/init.d`
	    ;;
	Scientific)
	    [ -z "$CTYS_IPTABLES" ]&&CTYS_IPTABLES=`getPathName $LINENO $BASH_SOURCE ERROR iptables /sbin`
	    [ -z "$CTYS_BRCTL" ]&&CTYS_BRCTL=`getPathName $LINENO $BASH_SOURCE ERROR brctl /usr/sbin`
	    [ -z "$CTYS_NETWORK" ]&&CTYS_NETWORK=`getPathName $LINENO $BASH_SOURCE ERROR network /etc/init.d`
	    ;;
	Fedora)
	    [ -z "$CTYS_IPTABLES" ]&&CTYS_IPTABLES=`getPathName $LINENO $BASH_SOURCE ERROR iptables /sbin`
	    [ -z "$CTYS_BRCTL" ]&&CTYS_BRCTL=`getPathName $LINENO $BASH_SOURCE ERROR brctl /usr/sbin`
	    [ -z "$CTYS_NETWORK" ]&&CTYS_NETWORK=`getPathName $LINENO $BASH_SOURCE ERROR network /etc/init.d`
	    ;;
	SuSE)
	    [ -z "$CTYS_BRCTL" ]&&CTYS_BRCTL=`getPathName $LINENO $BASH_SOURCE ERROR brctl /sbin`
	    [ -z "$CTYS_IPTABLES" ]&&CTYS_IPTABLES=`getPathName $LINENO $BASH_SOURCE ERROR iptables /usr/sbin`
	    [ -z "$CTYS_NETWORK" ]&&CTYS_NETWORK=`getPathName $LINENO $BASH_SOURCE ERROR network /etc/init.d`
	    ;;
	openSUSE)
	    [ -z "$CTYS_BRCTL" ]&&CTYS_BRCTL=`getPathName $LINENO $BASH_SOURCE ERROR brctl /sbin`
	    [ -z "$CTYS_IPTABLES" ]&&CTYS_IPTABLES=`getPathName $LINENO $BASH_SOURCE ERROR iptables /usr/sbin`
	    [ -z "$CTYS_NETWORK" ]&&CTYS_NETWORK=`getPathName $LINENO $BASH_SOURCE ERROR network /etc/init.d`
	    ;;
	debian)
	    [ -z "$CTYS_BRCTL" ]&&CTYS_BRCTL=`getPathName $LINENO $BASH_SOURCE ERROR brctl /usr/sbin`
	    [ -z "$CTYS_NETWORK" ]&&CTYS_NETWORK=`getPathName $LINENO $BASH_SOURCE ERROR networking /etc/init.d`
	    [ -z "$CTYS_IPTABLES" ]&&CTYS_IPTABLES=`getPathName $LINENO $BASH_SOURCE ERROR iptables /sbin`
	    ;;
	Ubuntu)
	    [ -z "$CTYS_BRCTL" ]&&CTYS_BRCTL=`getPathName $LINENO $BASH_SOURCE ERROR brctl /usr/sbin`
	    [ -z "$CTYS_NETWORK" ]&&CTYS_NETWORK=`getPathName $LINENO $BASH_SOURCE ERROR networking /etc/init.d`
	    [ -z "$CTYS_IPTABLES" ]&&CTYS_IPTABLES=`getPathName $LINENO $BASH_SOURCE ERROR iptables /sbin`
	    ;;
	Mandriva)
	    [ -z "$CTYS_IPTABLES" ]&&CTYS_IPTABLES=`getPathName $LINENO $BASH_SOURCE ERROR iptables /sbin`
	    [ -z "$CTYS_BRCTL" ]&&CTYS_BRCTL=`getPathName $LINENO $BASH_SOURCE ERROR brctl /usr/sbin`
	    [ -z "$CTYS_NETWORK" ]&&CTYS_NETWORK=`getPathName $LINENO $BASH_SOURCE ERROR network /etc/init.d`
	    ;;
	*)
	    [ -z "$CTYS_IPTABLES" ]&&CTYS_IPTABLES=`getPathName $LINENO $BASH_SOURCE ERROR iptables /sbin`
	    [ -z "$CTYS_BRCTL" ]&&CTYS_BRCTL=`getPathName $LINENO $BASH_SOURCE ERROR brctl /usr/sbin`
	    [ -z "$CTYS_NETWORK" ]&&CTYS_NETWORK=`getPathName $LINENO $BASH_SOURCE ERROR network /etc/init.d`
	    ;;
    esac
fi

#
#Required for xenbr-stop when WoL requested.
#These are not pre-checked for access permissions, this is due
#to the circumstance, that most of reliable access-checks are
#harmful to systems state by themself.
#


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
#XENCALL="${XENCALL:-$KSU -e }"
#VIRSHCALL="${VIRSHCALL:-$KSU -e }"


#
#XEN_BRIDGE_SCRIPT=${XEN_BRIDGE_SCRIPT:-/etc/xen/scripts/network-bridge}
XEN_BRIDGE_SCRIPT=${XEN_BRIDGE_SCRIPT:-$MYLIBEXECPATH/ctys-xen-network-bridge.sh}

#
#When this is set, no further checks are proceeded, the value is 
#just accepted.
#So be careful with that axe, Eugene...
#
#FORCE_THIS_IS_XEN_BRIDGE=${FORCE_THIS_IS_XEN_BRIDGE:-xenbr0}

#
#
#Default behaviour for CANCEL
XEN_CANCEL_DEFAULT=${XEN_CANCEL_DEFAULT:-POWEROFF}


#
#The default console
XEN_CONSOLE_DEFAULT=XTERM;


#Timeout for first attempt to connect to a VM after create call.
#XEN requires longer to start, particularly within stacks, when
#multiplr layers are involved.
XEN_INIT_WAITC=${XEN_INIT_WAITC:-2}
XEN_INIT_WAITS=${XEN_INIT_WAITS:-2}

#
#Timeout for polling the base IP stack mainly after initial start.
#WAIT unit is seconds, REPEAT unit is #nr.
CTYS_PING_DEFAULT_XEN=${CTYS_PING_DEFAULT_XEN:-1};
CTYS_PING_ONE_MAXTRIAL_XEN=${CTYS_PING_ONE_MAXTRIAL_XEN:-20};
CTYS_PING_ONE_WAIT_XEN=${CTYS_PING_ONE_WAIT_XEN:-2};

#
#Timeout for polling the base SSH access, requires preconfigured permissions.
#WAIT unit is seconds, REPEAT unit is #nr.
CTYS_SSHPING_DEFAULT_XEN=${CTYS_SSHPING_DEFAULT_XEN:-0};
CTYS_SSHPING_ONE_MAXTRIAL_XEN=${CTYS_SSHPING_ONE_MAXTRIAL_XEN:-20};
CTYS_SSHPING_ONE_WAIT_XEN=${CTYS_SSHPING_ONE_WAIT_XEN:-2};


#
#individual XEN defaults for STACKCHECK parameter
#0:OFF, 1:ON
_stackChkContextXEN=1;
_stackChkHWCapXEN=1;
_stackChkStacCapXEN=1:


#
#default HOSTs for login
#
XEN_DEFAULT_HOSTS=VNC

#
#default for CONSOLE
#
XEN_DEFAULT_CONSOLE=GTERM
