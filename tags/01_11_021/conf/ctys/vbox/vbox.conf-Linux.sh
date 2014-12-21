#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@users.sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_011
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


#
#Controls RDP accessibility of VMs, this is mapped to 
#"VBoxManage controlvm vrdpaddress=127.0.0.1"
#If you want to deactivate this, just comment it out.
#Set your own NIC when desired.
VBOX_VRDPADDRESS=${VBOX_VRDPADDRESS:-127.0.0.1}

#
#Controls RDP availability of VMs, this is mapped to 
#"VBoxManage controlvm vrdp=(on|off)"
VBOX_VRDP=${VBOX_VRDP:-on}


#
#Force shared-mode for RDP, this is mapped to 
#"VBoxManage modifyvm vrdpmulticon=(on|off)"
VBOX_VRDPMULTICON=${VBOX_VRDPMULTICON:-on}


#Keeps the tunnel open for connection, but reserves the port!
VBOX_SSH_ONESHOT_TIMEOUT=${SSH_ONESHOT_TIMEOUT:-40}


#
#Base path, where the vmw packages for initial tests are stored
VBOX_BASE=${VBOX_BASE:-$HOME/vmware}



#
CTYS_VBOX_DEFAULTCONTYPE=${CTYS_VBOX_DEFAULTCONTYPE:-VBOX}
CTYS_VBOX_DEFAULTCONTYPE_CONNECT=${CTYS_VBOX_DEFAULTCONTYPE_CONNECT:-RDP}

#
if [ -z "$VBOXEXE" ];then
    VBOXEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT VirtualBox /usr/bin`
fi


if [ -z "$VBOXMGR" ];then
    VBOXMGR=`getPathName $LINENO $BASH_SOURCE WARNINGEXT VBoxManage /usr/bin`
fi

if [ -z "$VBOXHEADLESS" ];then
    VBOXHEADLESS=`getPathName $LINENO $BASH_SOURCE WARNINGEXT VBoxHeadless /usr/bin`
fi

if [ -z "$VBOXSDL" ];then
    VBOXSDL=`getPathName $LINENO $BASH_SOURCE WARNINGEXT VBoxSDL /usr/bin`
fi




#
#For products with combined start the server-wait+client-wait is performed.
#
#Timeout after execution of client/server.
VBOX_INIT_WAITC=${VBOX_INIT_WAITC:-3}
VBOX_INIT_WAITS=${VBOX_INIT_WAITS:-3}


#
#Timeout for polling the base IP stack mainly after initial start.
#WAIT unit is seconds, REPEAT unit is #nr.
CTYS_PING_DEFAULT_VBOX=${CTYS_PING_DEFAULT_VBOX:-0};
CTYS_PING_ONE_MAXTRIAL_VBOX=${CTYS_PING_ONE_MAXTRIAL_VBOX:-20};
CTYS_PING_ONE_WAIT_VBOX=${CTYS_PING_ONE_WAIT_VBOX:-2};


#
#Timeout for polling the base SSH access, requires preconfigured permissions.
#WAIT unit is seconds, REPEAT unit is #nr.
CTYS_SSHPING_DEFAULT_VBOX=${CTYS_SSHPING_DEFAULT_VBOX:-0};
CTYS_SSHPING_ONE_MAXTRIAL_VBOX=${CTYS_SSHPING_ONE_MAXTRIAL_VBOX:-20};
CTYS_SSHPING_ONE_WAIT_VBOX=${CTYS_SSHPING_ONE_WAIT_VBOX:-2};

#
#individual VBOX defaults for STACKCHECK parameter
#0:OFF, 1:ON
_stackChkContextVBOX=1;
_stackChkHWCapVBOX=1;
_stackChkStacCapVBOX=1:



#
#default HOSTs for login
#
VBOX_DEFAULT_HOSTS=VNC

#
#default HOSTs for CONSOLE
#
VBOX_DEFAULT_CONSOLE=RDP
