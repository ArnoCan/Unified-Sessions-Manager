#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_005
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

################################################################
#    Default definitions - User-Customizable  from shell       #
################################################################


#Keeps the tunnel open for connection, but reserves the port!
VMW_SSH_ONESHOT_TIMEOUT=${SSH_ONESHOT_TIMEOUT:-40}


#
#Base path, where the vmw packages for initial tests are stored
VMW_BASE=${VMW_BASE:-$HOME/vmware}




################################################################
################################################################
#
#Version-2x-pre-settings
#
################################################################
################################################################

#
#specifics for Server-2.x

#
#firefox is supported only
#
[ -z "$CTYS_VMW_BROWSER" ]&&CTYS_VMW_BROWSER=`getPathName $LINENO $BASH_SOURCE WARNINGEXT firefox /usr/bin`

#
#vmware-vmrc provides standalone acces, becomes mandatory later in the code,
#for now set the preconfig only.
#
#searchpaths 
#
[ -z "$CTYS_VMW_VMRC" ]&&CTYS_VMW_VMRC=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vmware-vmrc ${MYADDONSPATH}/vmware-rc-x64`
[ -z "$CTYS_VMW_VMRC" ]&&CTYS_VMW_VMRC=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vmware-vmrc ${HOME}/vmware/vmware-rc-x64`
[ -z "$CTYS_VMW_VMRC" ]&&CTYS_VMW_VMRC=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vmware-vmrc /opt/vmware/vmware-rc-x64`
[ -z "$CTYS_VMW_VMRC" ]&&CTYS_VMW_VMRC=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vmware-vmrc /usr/bin`
[ -z "$CTYS_VMW_VMRC" ]&&CTYS_VMW_VMRC=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vmware-vmrc /usr/local/bin`
[ -z "$CTYS_VMW_VMRC" ]&&CTYS_VMW_VMRC=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vmware-vmrc /usr/share/vmware-rc`
[ -z "$CTYS_VMW_VMRC" ]&&CTYS_VMW_VMRC=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vmware-vmrc /usr/share/vmware-rc-x64`
[ -z "$CTYS_VMW_VMRC" ]&&CTYS_VMW_VMRC=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vmware-vmrc /usr/share/vmware-rc-x86`
[ -z "$CTYS_VMW_VMRC" ]&&CTYS_VMW_VMRC=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vmware-vmrc /opt/bin`
[ -z "$CTYS_VMW_VMRC" ]&&CTYS_VMW_VMRC=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vmware-vmrc /opt/vmware/vmware-rc`

#
#set the default console type fro version 2+, if available to standalone 'vmwrc'
[ -n "$CTYS_VMW_VMRC" ]&&CTYS_VMW2_DEFAULTCONTYPE=${CTYS_VMW2_DEFAULTCONTYPE:-VMWRC}
[ -n "$CTYS_VMW_BROWSER" ]&&CTYS_VMW2_DEFAULTCONTYPE=${CTYS_VMW2_DEFAULTCONTYPE:-FIREFOX}
CTYS_VMW2_DEFAULTCONTYPE=${CTYS_VMW2_DEFAULTCONTYPE:-VMW}


#
#Exe-File(common for client and server): vmplayer or vmware(server or ws)
#
#Can do this with any user, so sould be the same for the following
#access-permissions too.
#
if [ -z "$VMWEXE" ];then
    VMWEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vmware /usr/bin`
    if [ -n "$VMWEXE" ];then
        #server: vmware-cmd first, it contains vmrun too!
	VMWMGR=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vmware-cmd /usr/bin`
	if [ -z "$VMWMGR" ];then
            #ws: just has vmrun, but does not manage inventory
	    VMWMGR=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vmrun /usr/bin`
	fi
        #vmplayer has none
    else
	VMWEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vmplayer /usr/bin`
    fi
fi


#
#vmw-server >=2.0
if [ -z "$VMWEXE" -a -n "$CTYS_VMW_VMRC" ];then
    VMWEXE="$CTYS_VMW_VMRC"
fi
if [ -z "$VMWEXE" -a -n "$CTYS_VMW_BROWSER" ];then
    VMWEXE="$CTYS_VMW_VMRC"
fi

if [ -z "$VMWMGR" ];then
    #server: vmware-cmd first, it contains vmrun too!
    VMWMGR=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vmware-cmd /usr/bin`
    if [ -z "$VMWMGR" ];then
            #ws: just has vmrun, but does not manage inventory
	VMWMGR=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vmrun /usr/bin`
    fi
fi


#
#vmw-server >=2.0
if [ -z "$VMWMGR" ];then
    VMWMGR=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vmrun /usr/lib/vmware/bin`
fi


#
#For products with combined start the server-wait+client-wait is performed.
#
#Timeout after execution of client/server.
VMW_INIT_WAITC=${VMW_INIT_WAITC:-0}
VMW_INIT_WAITS=${VMW_INIT_WAITS:-0}


#
#Timeout for polling the base IP stack mainly after initial start.
#WAIT unit is seconds, REPEAT unit is #nr.
CTYS_PING_DEFAULT_VMW=${CTYS_PING_DEFAULT_VMW:-0};
CTYS_PING_ONE_MAXTRIAL_VMW=${CTYS_PING_ONE_MAXTRIAL_VMW:-20};
CTYS_PING_ONE_WAIT_VMW=${CTYS_PING_ONE_WAIT_VMW:-2};


#
#Timeout for polling the base SSH access, requires preconfigured permissions.
#WAIT unit is seconds, REPEAT unit is #nr.
CTYS_SSHPING_DEFAULT_VMW=${CTYS_SSHPING_DEFAULT_VMW:-0};
CTYS_SSHPING_ONE_MAXTRIAL_VMW=${CTYS_SSHPING_ONE_MAXTRIAL_VMW:-20};
CTYS_SSHPING_ONE_WAIT_VMW=${CTYS_SSHPING_ONE_WAIT_VMW:-2};

#
#individual VMW defaults for STACKCHECK parameter
#0:OFF, 1:ON
_stackChkContextVMW=1;
_stackChkHWCapVMW=1;
_stackChkStacCapVMW=1:




################################################################
################################################################
#
#Version-2x-pre-settings
#
################################################################
################################################################
#
#Only local connections are supported, anything else than SSH should be rejected...
#
case ${MYDIST} in
    debian)
	case ${MYREL} in
	    5.0)
                #
		#KEEP4REMINDER:
		#
                #Due to some firefox restrictions in default install somewhat inconsequent,
                #but for local conns only!
                #
                #May help the initial intro into the market - a little.
                #
		#CTYS_VMW_S2_ACCESS_HOST=${CTYS_VMW_S2_ACCESS_HOST:-http://127.0.0.1:8222/sdk}
		#CTYS_VMW_VMRC_ACCESS_HOST=${CTYS_VMW_VMRC_ACCESS_HOST:-127.0.0.1:8222}

		#
                #solution is simply to delete the file '/etc/pam.d/vmware-authd'
		#seems to work now!
                #
		CTYS_VMW_S2_ACCESS_HOST=${CTYS_VMW_S2_ACCESS_HOST:-http://localhost:8333/sdk}
		CTYS_VMW_VMRC_ACCESS_HOST=${CTYS_VMW_VMRC_ACCESS_HOST:-localhost:8333}
		;;
	esac
	;;
    *)
	CTYS_VMW_S2_ACCESS_HOST=${CTYS_VMW_S2_ACCESS_HOST:-https://localhost:8333/sdk}
	CTYS_VMW_VMRC_ACCESS_HOST=${CTYS_VMW_VMRC_ACCESS_HOST:-localhost:8333}
	;;
esac



#
#default HOSTs for login
#
VMW_DEFAULT_HOSTS=VNC

#
#default for CONSOLE
#
VMW_DEFAULT_CONSOLE=VMWRC
