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


################################################################
#                   Begin of FrameWork                         #
################################################################


#FUNCBEG###############################################################
#
#PROJECT:
MYPROJECT="Unified Sessions Manager"
#
#NAME:
#  ctys-extractMAClst.sh
#
#AUTHOR:
AUTHOR="Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org"
#
#FULLNAME:
FULLNAME="CTYS Extract MAC-Address List from dhcpd.conf"
#
#CALLFULLNAME:
CALLFULLNAME="ctys-setupVDE.sh"
#
#LICENCE:
LICENCE=GPL3
#
#TYPE:
#  bash-script
#
#VERSION:
VERSION=01_11_011
#DESCRIPTION:
#  Configures the VDE based TAP device and virtual switch.
#
#EXAMPLE:
#
#PARAMETERS:
#
#  refer to online help "-h" and/or "-H"
#
#OUTPUT:
#  RETURN:
#  VALUES:
#    Standard output is screen.
#
#FUNCEND###############################################################


################################################################
#                     Global shell options.                    #
################################################################
shopt -s nullglob



################################################################
#       System definitions - do not change these!              #
################################################################

C_EXECLOCAL=1;

#Execution anchor
MYCALLPATHNAME=$0
MYCALLNAME=`basename $MYCALLPATHNAME`
MYCALLNAME=${MYCALLNAME%.sh}
MYCALLPATH=`dirname $MYCALLPATHNAME`


_ARGSCALL=$*;

#
#If a specific library is forced by the user
#
if [ -n "${CTYS_LIBPATH}" ];then
    MYLIBPATH=$CTYS_LIBPATH
    MYLIBEXECPATHNAME=${CTYS_LIBPATH}/bin/$MYCALLNAME
else
    MYLIBEXECPATHNAME=$MYCALLPATHNAME
fi

#
#identify the actual location of the callee
#
if [ -n "${MYLIBEXECPATHNAME##/*}" ];then
	MYLIBEXECPATHNAME=${PWD}/${MYLIBEXECPATHNAME}
fi
MYLIBEXECPATH=`dirname $MYLIBEXECPATHNAME`

###################################################
#load basic library required for bootstrap        #
###################################################
MYBOOTSTRAP=${MYLIBEXECPATH}/bootstrap
if [ ! -d "${MYBOOTSTRAP}" ];then
    MYBOOTSTRAP=${MYCALLPATH}/bootstrap
    if [ ! -d "${MYBOOTSTRAP}" ];then
	echo "${MYCALLNAME}:$LINENO:ERROR:Missing:MYBOOTSTRAP=${MYBOOTSTRAP}"
	cat <<EOF  

DESCRIPTION:
  This directory contains the common mandatory bootstrap functions.
  Your installation my be erroneous.  

SOLUTION-PROPOSAL:
  First of all check your installation, because an error at this level
  might - for no reason - bypass the final tests.

  If this does not help please send a bug-report.

EOF
	exit 1
    fi
fi

MYBOOTSTRAP=${MYBOOTSTRAP}/bootstrap.01.01.003.sh
if [ ! -f "${MYBOOTSTRAP}" ];then
    echo "${MYCALLNAME}:$LINENO:ERROR:Missing:MYBOOTSTRAP=${MYBOOTSTRAP}"
    cat <<EOF  

DESCRIPTION:
  This file contains the common mandatory bootstrap functions required
  for start-up of any shell-script within this package.

  It seems though your installation is erroneous or you detected a bug.  

SOLUTION-PROPOSAL:
  First of all check your installation, because an error at this level
  might - for no reason - bypass the final tests.

  When your installation seems to be OK, you may try to set a TEMPORARY
  symbolic link to one of the files named as "bootstrap.<highest-version>".
  
    ln -s ${MYBOOTSTRAP} bootstrap.<highest-version>

  in order to continue for now. 

  Be aware, that any installation containing the required file will replace
  the symbolic link, because as convention the common boostrap files are
  never symbolic links, thus only recognized as a temporary workaround to 
  be corrected soon.

  If this does not work you could try one of the other versions.

  Please send a bug-report.

EOF
    exit 1
fi

###################################################
#Start bootstrap now                              #
###################################################
. ${MYBOOTSTRAP}
###################################################
#OK - utilities to find components of this version#
#available now.                                   #
###################################################

#
#set real path to install, resolv symbolic links
_MYLIBEXECPATHNAME=`bootstrapGetRealPathname ${MYLIBEXECPATHNAME}`
MYLIBEXECPATH=`dirname ${_MYLIBEXECPATHNAME}`

_MYCALLPATHNAME=`bootstrapGetRealPathname ${MYCALLPATHNAME}`
MYCALLPATHNAME=`dirname ${_MYCALLPATHNAME}`

#
###################################################
#Now find libraries might perform reliable.       #
###################################################


#current language, not really NLS
MYLANG=${MYLANG:-en}

#path for various loads: libs, help, macros, plugins
MYLIBPATH=${CTYS_LIBPATH:-`dirname $MYLIBEXECPATH`}

#path for various loads: libs, help, macros, plugins
MYHELPPATH=${MYHELPPATH:-$MYLIBPATH/help/$MYLANG}


###################################################
#Check master hook                                #
###################################################
bootstrapCheckInitialPath
###################################################
#OK - Now should work.                            #
###################################################

MYCONFPATH=${MYCONFPATH:-$MYLIBPATH/conf/ctys}
if [ ! -d "${MYCONFPATH}" ];then
    echo "${MYCALLNAME}:$LINENO:ERROR:Missing:MYCONFPATH=${MYCONFPATH}"
    exit 1
fi

if [ -f "${MYCONFPATH}/versinfo.conf.sh" ];then
    . ${MYCONFPATH}/versinfo.conf.sh
fi

MYMACROPATH=${MYMACROPATH:-$MYCONFPATH/macros}
if [ ! -d "${MYMACROPATH}" ];then
    echo "${MYCALLNAME}:$LINENO:ERROR:Missing:MYMACROPATH=${MYMACROPATH}"
    exit 1
fi

MYPKGPATH=${MYPKGPATH:-$MYLIBPATH/plugins}
if [ ! -d "${MYPKGPATH}" ];then
    echo "${MYCALLNAME}:$LINENO:ERROR:Missing:MYPKGPATH=${MYPKGPATH}"
    exit 1
fi

MYINSTALLPATH= #Value is assigned in base. Symbolic links are replaced by target


##############################################
#load basic library required for bootstrap   #
##############################################
. ${MYLIBPATH}/lib/base.sh
. ${MYLIBPATH}/lib/libManager.sh
#
#Germish: "Was the egg or the chicken first?"
#
#..and prevent real load order for later display.
#
bootstrapRegisterLib
baseRegisterLib
libManagerRegisterLib
##############################################
#Now the environment is armed, so let's go.  #
##############################################

if [ ! -d "${MYINSTALLPATH}" ];then
    ABORT=1;
    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing:MYINSTALLPATH=${MYINSTALLPATH}"
    gotoHell ${ABORT}
fi

MYOPTSFILES=${MYOPTSFILES:-$MYLIBPATH/help/$MYLANG/*_base_options} 
checkFileListElements "${MYOPTSFILES}"
if [ $? -ne 0 ];then
    ABORT=1;
    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing:MYOPTSFILES=${MYOPTSFILES}"
    gotoHell ${ABORT}
fi


################################################################
# Main supported runtime environments                          #
################################################################
#release
TARGET_OS="Linux: CentOS/RHEL(5+), SuSE-Professional 9.3"

#to be tested - coming soon
TARGET_OS_SOON="OpenBSD+Linux(might work for any dist.):Ubuntu+OpenSuSE"

#to be tested - might be almsot OK - but for now FFS
#...probably some difficulties with desktop-switching only?!
TARGET_OS_FFS="FreeBSD+Solaris/SPARC/x86"

#release
TARGET_WM="Gnome + fvwm"

#to be tested - coming soon
TARGET_WM_SOON="xfce"

#to be tested - coming soon
TARGET_WM_FORESEEN="KDE(might work now)"

################################################################
#                     End of FrameWork                         #
################################################################

. ${MYLIBPATH}/lib/help/help.sh
. ${MYLIBPATH}/lib/security.sh
. ${MYLIBPATH}/lib/network/network.sh
. ${MYLIBPATH}/lib/misc.sh
. ${MYLIBPATH}/lib/groups.sh

#
#Verify OS support
#
case ${MYOS} in
    Linux);;
    *)
        printINFO 1 $LINENO $BASH_SOURCE 1 "${MYCALLNAME} is not supported on ${MYOS}"
	gotoHell 0
	;;
esac

#path to directory containing the default mapping db
if [ -d "${HOME}/.ctys/db/default" ];then
    DEFAULT_DBPATHLST=${DEFAULT_DBPATHLST:-$HOME/.ctys/db/default}
fi

#path to directory containing the default mapping db
if [ -d "${MYCONFPATH}/db/default" ];then
    DEFAULT_DBPATHLST=${DEFAULT_DBPATHLST:-$HOME/conf/db/default}
fi


_myHint="${MYCONFPATH}/systools.conf-${MYDIST}.sh"
#Source pre-set environment from user
if [ -f "${HOME}/.ctys/ctys.conf.sh" ];then
    . "${HOME}/.ctys/ctys.conf.sh"
fi

#Source pre-set environment from installation 
if [ -f "${MYCONFPATH}/ctys.conf.sh" ];then
    . "${MYCONFPATH}/ctys.conf.sh"
fi

#system tools
if [ -f "${HOME}/.ctys/systools.conf-${MYDIST}.sh" ];then
    . "${HOME}/.ctys/systools.conf-${MYDIST}.sh"
else

    if [ -f "${MYCONFPATH}/systools.conf-${MYDIST}.sh" ];then
	. "${MYCONFPATH}/systools.conf-${MYDIST}.sh"
    else
	if [ -f "${MYLIBEXECPATH}/../conf/ctys/systools.conf-${MYDIST}.sh" ];then
	    . "${MYLIBEXECPATH}/../conf/ctys/systools.conf-${MYDIST}.sh"
	else
	    ABORT=1;
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing system tools configuration file:\"systools.conf-${MYDIST}.sh\""
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Check your installation."
	    gotoHell ${ABORT}
	fi
    fi
fi



#Requires some shared settings with QEMU
if [ -f "${HOME}/.ctys/qemu/qemu.conf-${MYOS}.sh" ];then
    . "${HOME}/.ctys/qemu/qemu.conf-${MYOS}.sh"
fi
if [ -f "${MYCONFPATH}/qemu/qemu.conf-${MYOS}.sh" ];then
    . "${MYCONFPATH}/qemu/qemu.conf-${MYOS}.sh"
fi

#Requires some shared settings with QEMU-KVM
if [ -f "${HOME}/.ctys/kvm/kvm.conf-${MYOS}.sh" ];then
    . "${HOME}/.ctys/kvm/kvm.conf-${MYOS}.sh"
fi
if [ -f "${MYCONFPATH}/kvm/kvm.conf-${MYOS}.sh" ];then
    . "${MYCONFPATH}/kvm/kvm.conf-${MYOS}.sh"
fi


###############################
#verify presence of required tools
###############################

#
#Required for some OSs as pre-delay for socket initialisation,
#thus do it here for ultimate force.
#Change these only if you are definitely sure about.
#For common settings use the configuration files.

case $MYDIST in
    openSUSE)
	CTYS_NETCAT_ACCESS_DELAY=${CTYS_NETCAT_ACCESS_DELAY:-1}
	printINFO 2 $LINENO $BASH_SOURCE 1 "Running on $(setSeverityColor WNG $MYDIST):Set $(setSeverityColor WNG CTYS_NETCAT_ACCESS_DELAY=${CTYS_NETCAT_ACCESS_DELAY}sec)"
	if [ -z "$CTYS_NETCAT" ];then
	    ABORT=2
	    printERR $LINENO $BASH_SOURCE ${ABORT} "$(setSeverityColor ERR Missing) mandatory \"$(setSeverityColor ERR nc)\" variant of netcat $(setSeverityColor WNG with \"-U\" option)  for $(setSeverityColor ERR $MYDIST)."
	    printERR $LINENO $BASH_SOURCE ${ABORT} "QEMU/KVM may not work correctly on this distribution due to internal"
	    printERR $LINENO $BASH_SOURCE ${ABORT} "communications faults with vde_switch(${VDE_SWITCH})."
#	gotoHell ${ABORT}  
	else
	    CTYS_NETCAT="$CTYS_NETCAT ${CTYS_NETCAT_ACCESS_DELAY:+ -i $CTYS_NETCAT_ACCESS_DELAY} "
	fi
	;;
esac



function showVDERef() {
    ABORT=2
    printERR $LINENO $BASH_SOURCE ${ABORT} "Refer for additonal Information to:"
    printERR $LINENO $BASH_SOURCE ${ABORT} "  \"http://wiki.virtualsquare.org/index.php/VDE_Basic_Networking\""

}

function initSetupVDE () {
    ABORT=1;
    if [ -z "$CTYS_IFCONFIG" ];then
	printERR $LINENO $BASH_SOURCE ${ABORT} "Cannot get pathname for system tool \"ifconfig\", check your system."
	gotoHell ${ABORT}  
    fi

    if [ -z "$CTYS_BRCTL" ];then
	printERR $LINENO $BASH_SOURCE ${ABORT} "Cannot get pathname for system tool \"brctl\", check your system."
	gotoHell ${ABORT}  
    fi

    if [ -z "$VDE_TUNCTL" ];then
	printERR $LINENO $BASH_SOURCE ${ABORT} "Cannot get pathname for VDE tool \"vde_tunctl\", check your system."
	showVDERef
	gotoHell ${ABORT}  
    fi

    if [ -z "$VDE_SWITCH" ];then
	printERR $LINENO $BASH_SOURCE ${ABORT} "Cannot get pathname for VDE tool \"vde_switch\", check your system."
	showVDERef
	gotoHell ${ABORT}  
    fi

    if [ -z "$VDE_UNIXTERM" ];then
	printERR $LINENO $BASH_SOURCE ${ABORT} "Cannot get pathname for VDE tool \"unixterm\", check your system."
	showVDERef
	gotoHell ${ABORT}  
    fi

    if [ -z "$CTYS_NETCAT" ];then
	printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "Use fall-back \"unixterm\", please install \"nc\" soon."
# 	printERR $LINENO $BASH_SOURCE ${ABORT} "Cannot get pathname for \"netcat - nc\", check your system."
# 	showVDERef
# 	gotoHell ${ABORT}  
    fi



    ###############################
    #verify required parameters
    ###############################
    ABORT=1;

    if [ -z "${_interface}" ];then
	_interface=`netGetFirstIf`;
	printINFO 2 $LINENO $BASH_SOURCE ${ABORT} "Scanned first interface=${_interface}"
    fi
    export _interface
    printINFO 2 $LINENO $BASH_SOURCE ${ABORT} "Use interface=${_interface}"

    export _user=${_user:-$USER};
    if [ -z "$_group" ];then
	_group=`getGroup ${_user}`
    fi

    if [ -n "$_group" -a -n "$_sbitgroup" ];then
	if [ "$_group" != "$_sbitgroup" ];then
	    ABORT=1
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Group for sbit has to be the same as the GROUP of the USER."
	    printERR $LINENO $BASH_SOURCE ${ABORT} "$_group != $_sbitgroup"
	    gotoHell ${ABORT}  
	fi
    fi


    if [ -z "$_user" ];then
	printERR $LINENO $BASH_SOURCE ${ABORT} "Aha, missing USER - do something???!!!"
	gotoHell ${ABORT}  
    else
	printINFO 2 $LINENO $BASH_SOURCE ${ABORT} "Ownership for sockets USER=$_user GROUP=$_group"

	if [ -z "${_ssock}" ];then
	    export _ssock=${_ssock:-$QEMUSOCK};
	    export _ssock=${_ssock%\.*}.${_user};
	fi
	printINFO 2 $LINENO $BASH_SOURCE ${ABORT} "Use _ssock=${_ssock}"

	if [ -z "${_msock}" ];then
	    export _msock=${_msock:-$QEMUMGMT};
	    export _msock=${_msock%\.*}.${_user};
	fi
	printINFO 2 $LINENO $BASH_SOURCE ${ABORT} "Use _msock=${_msock}"
    fi


    _mybridge=ctysbr0
    if [ -n "$_bridge" ];then
	printINFO 2 $LINENO $BASH_SOURCE ${ABORT} "Bridge for TAN attachment _bridge=$_bridge"
    else
	_bridge=`netListBridges`
	if [ -n "${_bridge}" ];then
	    printINFO 2 $LINENO $BASH_SOURCE ${ABORT} "Detected _bridge=<${_bridge}>"
	    _bridge="${_bridge%% *}"
	    printINFO 2 $LINENO $BASH_SOURCE ${ABORT} "Use first detected _bridge=<${_bridge}>"
	else
	    _bridge=${_mybridge}
	    printINFO 2 $LINENO $BASH_SOURCE ${ABORT} "Use default _bridge name:$_bridge"
	fi
    fi
    export _bridge


    export _ssock=${_ssock:-$QEMUSOCK};
    if [ -z "$_ssock" ];then
	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing socket for virtual switch, provide \"-s\" or QEMUSOCK"
	gotoHell ${ABORT}  
    else
	printINFO 2 $LINENO $BASH_SOURCE ${ABORT} "Socket for virtual switch QEMUSOCK=$_ssock"
    fi

    export _msock=${_msock:-$QEMUMGMT};
    if [ -z "$_msock" ];then
	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing management socket for virtual switch, provide \"-S\" or QEMUMGMT"
	gotoHell ${ABORT}  
    else
	printINFO 2 $LINENO $BASH_SOURCE ${ABORT} "Management-Socket for virtual switch QEMUMGMT=$_msock"
    fi


    #hard-coded for now
    export _pfile=/var/run/${_msock##*\/}


    #should be preset
    BRIDGE_FORWARDDELAY=${BRIDGE_FORWARDDELAY:-0};


    ###########
    #'guess we're armed now. Ignore resource permissions here for now.
    ###########
}



function createSwitch () {
    local _bridge=${1}
    local _interface=${2}
    printINFO 1 $LINENO $BASH_SOURCE ${ABORT} "CREATE:attach switch to bridge:<${_bridge}> interface:<${_interface}>"

    if ! netCheckBridgeExists ${_bridge} ; then
	netCreateBridge KEEPIP ${_bridge} ${_interface}
    else
        printINFO 1 $LINENO $BASH_SOURCE ${ABORT} "CREATE:use present bridge:$_bridge"
    fi

    local VDECALL=;
    local _myTap=`checkedSetSUaccess  retry norootpreference display1 "${_myHint}" VDECALL  VDE_TUNCTL -b -u ${_user}`
    if [ -z "${_myTap// /}" ];then
	ABORT=1;
	printERR $LINENO $BASH_SOURCE ${ABORT} "Failed to create a new TAP device, check:"
	printERR $LINENO $BASH_SOURCE ${ABORT} "$VDECALL  $VDE_TUNCTL -b -u ${_user}"
	gotoHell ${ABORT}  
    fi
    printINFO 1 $LINENO $BASH_SOURCE ${ABORT} "CREATE:new device TAP=$_myTap for USER=$_user"

    #This is for completeness of tests only, DO NOT configure ksu/sudo for chmod/chown!!!
    #If so, only for your admin, with reliable PATH!!!
    local CALLCHOWN=;
    local CALLCHMOD=;
    local CHOWN=`getPathName $LINENO $BASH_SOURCE WARNINGEXT chown /bin`;
    local CHMOD=`getPathName $LINENO $BASH_SOURCE WARNINGEXT chmod /bin`;
    _group=${_group// /}
    local UG=$_user${_group:+.$_group}

    checkedSetSUaccess  retry norootpreference "${_myHint}" VDECALL  CTYS_IFCONFIG $_myTap 0.0.0.0 up
    if [ $? -ne 0 ];then
	ABORT=1;
	printERR $LINENO $BASH_SOURCE ${ABORT} "Failed to setup a TAP device:${_myTap}."
        #no rollback
	gotoHell ${ABORT}  
    fi
    printINFO 1 $LINENO $BASH_SOURCE ${ABORT} "CREATE:new interface TAP=$_myTap for USER=$_user"

    local BRCTLCALL=;
    if [ -n "$_bridge" ];then
	checkedSetSUaccess  retry norootpreference "${_myHint}" BRCTLCALL  CTYS_BRCTL  addif $_bridge $_myTap
	if [ $? -ne 0 ];then
	    ABORT=1;
	    printERR $LINENO $BASH_SOURCE ${ABORT} "ATTACH failed:TAP=$_myTap to bridge=$_bridge"
	    gotoHell ${ABORT}
	fi
	printINFO 1 $LINENO $BASH_SOURCE ${ABORT} "CREATE:attach TAP=$_myTap to bridge=$_bridge"
    else
	printINFO 2 $LINENO $BASH_SOURCE ${ABORT} "Non-bridged direct attachment of TAP=$_myTap"
    fi

    printINFO 1 $LINENO $BASH_SOURCE ${ABORT} "CREATE:new switch $_myTap $_ssock $_msock"
    printINFO 1 $LINENO $BASH_SOURCE ${ABORT} "CREATE: ...may require a short while:"
    printINFO 1 $LINENO $BASH_SOURCE ${ABORT} "CREATE:    $(setSeverityColor WNG BRIDGE_FORWARDDELAY=${BRIDGE_FORWARDDELAY}sec)"
    checkedSetSUaccess retry norootpreference "${_myHint}" BRCTLCALL  VDE_SWITCH -d -t $_myTap -s $_ssock -M $_msock -p $_pfile

    checkedSetSUaccess retry norootpreference "${_myHint}" CALLCHOWN  CHOWN -R $UG $_pfile
    checkedSetSUaccess retry norootpreference "${_myHint}" CALLCHOWN  CHOWN -R $UG $_msock
    checkedSetSUaccess retry norootpreference "${_myHint}" CALLCHOWN  CHOWN -R $UG $_ssock
    checkedSetSUaccess retry norootpreference "${_myHint}" CALLCHMOD  CHMOD -R g-rwxs $_ssock
    checkedSetSUaccess retry norootpreference "${_myHint}" CALLCHMOD  CHMOD -R o-rwxs $_ssock

    printINFO 1 $LINENO $BASH_SOURCE ${ABORT} "CREATE:grant switch-access by chown for USER=$_user GROUP=$_group"

    if [ -n "$_sbitgroup" ];then
	printINFO 1 $LINENO $BASH_SOURCE ${ABORT} "CREATE:extend switch-access by chmod s-bit for GROUP=$_group"
	checkedSetSUaccess retry norootpreference "${_myHint}" CALLCHMOD  CHMOD -R g+s  $_ssock
	checkedSetSUaccess retry norootpreference "${_myHint}" CALLCHMOD  CHMOD -R g+s $_msock
    fi

    #vde_switch seem to set first bonding device to down, do the workaround - resume it to up
    netWorkaroundRestoreBonding $_interface
}


function cancelSwitch () {
    local VDECALL=;

    if [ ! -S $_msock ];then
	ABORT=1;
	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing management socket for vde_switch=\"${_msock}\""
	gotoHell ${ABORT}  
    fi

    if [ -n "${CTYS_NETCAT}" ];then
        if [ "$USER" != root ];then
	    checkedSetSUaccess  "${_myHint}" BRCTLCALL  CTYS_NETCAT -h
        fi
	local _myTap=$(callErrOutWrapper $LINENO $BASH_SOURCE "echo 'port/print'|$CTYS_NETCAT -U $_msock|awk '/tuntap/{print \$NF}'")
    else
	local _myTap=`{
	    callErrOutWrapper $LINENO $BASH_SOURCE $VDE_UNIXTERM $_msock <<EOF
port/print
EOF
        }|awk '/tuntap/{print $NF}'
	`
    fi

    if [ -n "$_myTap" ];then
	if [ -n "${CTYS_NETCAT}" ];then
            if [ "$USER" != root ];then
		checkedSetSUaccess  "${_myHint}" BRCTLCALL  CTYS_NETCAT -h
            fi
	    callErrOutWrapper $LINENO $BASH_SOURCE "echo shutdown|$CTYS_NETCAT -U $_msock">/dev/null
	else
	    checkedSetSUaccess retry norootpreference "${_myHint}" BRCTLCALL  VDE_UNIXTERM $_msock <<EOF
shutdown
EOF
	fi

    else
	if [ -e "$_pfile" ];then
	    local _mypid=`cat ${_pfile}`
	    if [ -z "$_mypid" ];then
		ABORT=1;
		printERR $LINENO $BASH_SOURCE ${ABORT} "Cannot get PID from:_pfile=\"${_pfile}\""
		gotoHell ${ABORT}  
	    fi
	else
	    ABORT=1;
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Cannot find run-file:_pfile=\"${_pfile}\""
	    gotoHell ${ABORT}  
	fi

	local _myTap=`${PS} ${PSEF}|grep -v grep|grep ${_mypid}|sed -n 's/.* -t \([^ ]*\) .*/\1/p'`
	if [ -n "$_force" ];then
	    checkedSetSUaccess  retry norootpreference "${_myHint}" BRCTLCALL  KILL ${_mypid}
	else
	    ABORT=1;
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Failed to \"shutdown\" vde_switch for TAP=\"${_myTap}\"."
	    printERR $LINENO $BASH_SOURCE ${ABORT} "by it's management interface MSOCK=\"${_msock}\"."
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Use \"-f\" for forced kill of the process by it's PID=${_mypid}"
	    printERR $LINENO $BASH_SOURCE ${ABORT} "The UNIX-Domain socket may have to be deleted manually."
	    gotoHell ${ABORT}  
	fi
    fi
    printINFO 2 $LINENO $BASH_SOURCE 0 "CANCEL:virtual switch for TAP=\"$_myTap\" on QEMUMGMT=\"$_msock\""
    printINFO 2 $LINENO $BASH_SOURCE 0 "This version ignores present ports!!!"

    #
    #if there is one, it is the one used in earlier create call
    #
    if [ -z  "${_bridge}" ];then
        printINFO 1 $LINENO $BASH_SOURCE 0 "CANCEL:Search bridge"
	for i in `netListBridges`;do
	    if [ "$i" == "$_mybridge" ];then
		_bridge=$_mybridge;
	    fi
	done
    else
        printINFO 1 $LINENO $BASH_SOURCE 0 "CANCEL:User provided bridge=$_bridge"
    fi

    local BRCTLCALL=;
    if [ -n "$_bridge" ];then
        printINFO 1 $LINENO $BASH_SOURCE 0  "CANCEL:bridge=$_bridge remove TAP=\"$_myTap\""
	checkedSetSUaccess retry norootpreference "${_myHint}" BRCTLCALL  CTYS_BRCTL  delif $_bridge $_myTap
    else
	printINFO 2 $LINENO $BASH_SOURCE 0 "Non-bridged direct attachment of TAP=$_myTap"
    fi

    printINFO 2 $LINENO $BASH_SOURCE 0 "CANCEL ifconfig for TAP=\"${_myTap}\""
    checkedSetSUaccess retry norootpreference "${_myHint}" VDECALL  CTYS_IFCONFIG $_myTap down
    if [ $? -ne 0 ];then
	ABORT=1;
	printERR $LINENO $BASH_SOURCE ${ABORT} "Failed to CANCEL interface for TAP=\"${_myTap}\""
	gotoHell ${ABORT}  
    else
        printINFO 1 $LINENO $BASH_SOURCE 0 "CANCEL:interface shutdown TAP=\"$_myTap\""
    fi

    printINFO 2 $LINENO $BASH_SOURCE 0 "CANCEL TAP=\"${_myTap}\""

    local _myTap=`checkedSetSUaccess retry norootpreference display1 "${_myHint}" VDECALL  VDE_TUNCTL -d ${_myTap}`
    if [ $? -ne 0 ];then
	ABORT=1;
	printERR $LINENO $BASH_SOURCE ${ABORT} "Failed to CANCEL TAP=\"${_myTap}\""
	gotoHell ${ABORT}  
    else
        printINFO 1 $LINENO $BASH_SOURCE 0 "CANCEL:device remove TAP=\"$_myTap\""
    fi

    #
    #only implicit generated bridges are canceled, else has to do manually.
    #
    if [ "$_bridge" != "$_mybridge" ];then
        printINFO 1 $LINENO $BASH_SOURCE 0 "CANCEL:keep pre-present/non-standard bridge:$_bridge != $_mybridge"
    else
        printINFO 1 $LINENO $BASH_SOURCE 0 "CANCEL:remove standard-created bridge:$_bridge == $_mybridge"
	local _inUse=0;
	local _nonTapCount=0;

	for i in `netListBridgePorts $_bridge`;do
            #assume only one non-tap device is within the own self-created-bridge,
            #the _myTap is deleted above, thus none should remain
	    if [ "${i##tap}" == "${i}" ];then
		_interface=$i;
		let _nonTapCount++;
	    else
		let _inUse++;
	    fi
	done

        if((_inUse>0));then
            printINFO 1 $LINENO $BASH_SOURCE 0 "CANCEL:Still in use(${_inUse}) bridge:$_bridge"
	    return
	fi
        if((_nonTapCount>1));then
            printINFO 1 $LINENO $BASH_SOURCE 0 "CANCEL:Matched more non-TAP interfaces(${_nonTapCount}=>1) than expected bridge:$_bridge"
	    return
	fi

	netCancelBridge "$_bridge"
    fi
}


function listPortsSwitch () {
    local VDECALL=;
    if [ "${MYARCH}" == i386 ];then
	printINFO 1 $LINENO $BASH_SOURCE 0  "on i386 difficulties may occur, if nothing is displayed "
	printINFO 1 $LINENO $BASH_SOURCE 0  "use \"unixterm\" interactively."
    fi
    if [ ! -e "$_msock" ] ;then
	printWNG 2 $LINENO $BASH_SOURCE 1 "Missing UNIX socket:$_msock"
	return 1
    fi
    echo "SWITCH-PORTS:"
    if [ -n "$CTYS_NETCAT" ];then
	if [ "$USER" == root ];then
	    callErrOutWrapper $LINENO $BASH_SOURCE "echo 'port/print'|$CTYS_NETCAT -U $_msock "
	else
	    checkedSetSUaccess  "${_myHint}" BRCTLCALL  CTYS_NETCAT -h 
 	    callErrOutWrapper $LINENO $BASH_SOURCE "echo "port/print"|$CTYS_NETCAT -U $_msock"
	fi
    else
	callErrOutWrapper $LINENO $BASH_SOURCE $VDE_UNIXTERM $_msock <<EOF
port/print
EOF
    fi
    echo
}


function checkPorts () {
    local portList=$(listPortsSwitch | awk '/endpoint/{print $NF;}');
    local tapOK=0;
    local sockOK=0;
    local switchOK=0;
    local switchProc4Tap=0;
    local switchProc=0;

    local _i=;
    for _i in $portList;do
	printINFO 2 $LINENO $BASH_SOURCE 1 "Port:<$_i>"
	case $_i in
	    tap*)
		${CTYS_IFCONFIG} $_i 2>&1 >/dev/null
		if [ $? -eq 0 ];then
		    let tapOK++;
		    local _x=$(${PS} ${PSEF}|awk -v t="$_i" '$0!~/awk/&&/vde_switch/&&$0~t{print;}' 2>/dev/null)
		    if [ -n "$_x" ];then
			let switchOK++;
			_x=;
		    else
			let switchProc4Tap++;
		    fi
		fi
		;;
	    *)
		if [ -S ${i#SOCK=} ];then
		    let sockOK++;
		fi
		;;
	esac
    done
    local _tapExist=0;
    _tapExist=$(${CTYS_IFCONFIG}|awk 'BEGIN{t=0;}$1~/tap[0-9]/{t++;}END{printf("%d",t);}');
    switchProc=$(${PS} ${PSEF}|awk 'BEGIN{s=0;}$0!~/awk/&&/vde_switch/{s++;}END{printf("%d",s);}')

    if [ "$C_TERSE" != 1 ];then
	if((switchOK==0||switchOK!=tapOK));then
	    ABORT=1;
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "switchNOK for USER=\"${_user}\": #tap=$(setSeverityColor WNG $tapOK)  => [$(setSeverityColor WNG NOK)]"
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} " Missing #switchProc4Tap = ${switchProc4Tap}"
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} " Present #switchOK       = ${switchOK}"
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} " Present #tapOK          = ${tapOK}"
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} " Present #tap            = ${_tapExist}"
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} " Present #switchProc     = ${switchProc}"
	else
	    printINFO 2 $LINENO $BASH_SOURCE 0 "switchOK for USER=\"${_user}\":#tap=$(setSeverityColor INF $tapOK)  => [$(setSeverityColor INF OK)]"
	fi

	if((sockOK==0));then
	    printWNG 2 $LINENO $BASH_SOURCE 0 "#sockNOK for USER=\"${_user}\":<$(setSeverityColor WNG $sockOK)> => [$(setSeverityColor WNG NOK)]"
	else
	    printINFO 2 $LINENO $BASH_SOURCE 0 "#sockOK for USER=\"${_user}\":<$(setSeverityColor INF $sockOK)> => [$(setSeverityColor INF OK)]"
	fi
    fi

    if((tapOK==0));then
	return 1;
    fi
    if [ "$C_TERSE" != 1 ];then
	printINFO 1 $LINENO $BASH_SOURCE 0 "VDE environment  for USER=\"${_user}\" => [$(setSeverityColor INF OK)]"
    fi
    return 0
}

function infoSwitch () {
    local VDECALL=;
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME"
    if [ "${MYARCH}" == i386 ];then
	printINFO 1 $LINENO $BASH_SOURCE 0 "on i386 difficulties may occur, if nothing is displayed "
	printINFO 1 $LINENO $BASH_SOURCE 0 "use \"unixterm\" interactively."
    fi

    if [ ! -e "$_msock" ] ;then
	printWNG 2 $LINENO $BASH_SOURCE 1 "Missing UNIX socket QEMUMGMT/_msock=$_msock"
	return 1
    fi
    echo "SWITCH-INFO:"

    case $MYDIST in
	Ubuntu)
	    if [ -n "$VDE_UNIXTERM" ];then
		if [ "$USER" == root ];then
		    callErrOutWrapper $LINENO $BASH_SOURCE $VDE_UNIXTERM $_msock <<EOF
showinfo
EOF
		else
		    checkedSetSUaccess  "${_myHint}" BRCTLCALL  VDE_UNIXTERM $_msock <<EOF
showinfo
EOF
		fi
	    else
		if [ "$USER" == root ];then
		    callErrOutWrapper $LINENO $BASH_SOURCE "echo showinfo|$CTYS_NETCAT -U \"$_msock\""
		else
		    checkedSetSUaccess  "${_myHint}" BRCTLCALL  CTYS_NETCAT "-h 2>&1|grep -q -e '-D'"
		    callErrOutWrapper $LINENO $BASH_SOURCE "echo showinfo|$CTYS_NETCAT -U \"$_msock\""
		fi
	    fi
	    ;;
	*)
	    if [ -n "$CTYS_NETCAT" ];then
		if [ "$USER" == root ];then
		    callErrOutWrapper $LINENO $BASH_SOURCE "echo showinfo|$CTYS_NETCAT -U \"$_msock\""
		else
		    checkedSetSUaccess  "${_myHint}" BRCTLCALL  CTYS_NETCAT "-h 2>&1|grep -q -e '-D'"
		    callErrOutWrapper $LINENO $BASH_SOURCE "echo showinfo|$CTYS_NETCAT -U \"$_msock\""
		fi
	    else
		if [ "$USER" == root ];then
		    callErrOutWrapper $LINENO $BASH_SOURCE $VDE_UNIXTERM $_msock <<EOF
showinfo
EOF
		else
		    checkedSetSUaccess  "${_myHint}" BRCTLCALL  VDE_UNIXTERM $_msock <<EOF
showinfo
EOF
		fi
	    fi
	    ;;
    esac
    echo
}


function listSwitches () {
    if [ -z "${_ssock}" ];then
	export _ssock=${_ssock:-$QEMUSOCK};
	export _ssock=${_ssock%\.*}.${_user};
	printINFO 1 $LINENO $BASH_SOURCE 0 "Use standard path derived from QEMUSOCK=${_ssock}"
    fi

    local _basedir=${_ssock%$USER}
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "Use PREFIX=${_basedir}"
    printINFO 2 $LINENO $BASH_SOURCE 0 "Use PREFIX=${_basedir}"
    ls -ld $_basedir*|\
      awk -v h="${MYHOST}" '
         $NF!~/.[0-9]+-[0-9]+$/{
           x=$NF;gsub("^.*/","",x);
           printf("%-30s|%-12s|%-12s|%-12s|%-s\n",x,$3,$4,$1,h);
      }'
}


function listSwitchesAll () {
    if [ -z "${_ssock}" ];then
	export _ssock=${_ssock:-$QEMUSOCK};
	export _ssock=${_ssock%\.*}.${_user};
	printINFO 1 $LINENO $BASH_SOURCE 0 "Use standard path derived from QEMUSOCK=${_ssock}"
    fi

    local _basedir=${_ssock%$USER}
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "Use PREFIX=${_basedir}"
    printINFO 2 $LINENO $BASH_SOURCE 0 "Use PREFIX=${_basedir}"
    ls -ld $_basedir*|\
      awk -v h="${MYHOST}" '{x=$NF;gsub("^.*/","",x);printf("%-30s|%-12s|%-12s|%-12s|%-s\n",x,$3,$4,$1,h);}'
}



function execSwitchAction () {
    _ex=0
    case $SWITCH_ACTION in

	CREATE) 
            x=`infoSwitch|grep Success`
	    if [ -z "$x" ];then
		createSwitch "${_bridge}" "${_interface}"
		_ex=$?;
	    else
		printINFO 1 $LINENO $BASH_SOURCE 0 "A functional switch is already present, reuse it."
	    fi
	    ;;

	CANCEL) 
            x=`infoSwitch|grep Success`
	    if [ -n "$x" ];then
		cancelSwitch
		_ex=$?;
	    else
		printINFO 1 $LINENO $BASH_SOURCE 0 "No switch found, nothing to do."
	    fi
	    ;;

	CHECK) 
	    checkPorts
            _ex=$?;
	    ;;

	LIST) 
	    listSwitches
            _ex=$?;
	    ;;

	LISTALL) 
	    listSwitchesAll
            _ex=$?;
	    ;;

	PORTS) 
	    listPortsSwitch
            _ex=$?;
	    ;;

	INFO) 
	    infoSwitch
            _ex=$?;
	    ;;

	*)
	    ABORT=1;
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Unknown SWITCH_ACTION=$SWITCH_ACTION"
	    printERR $LINENO $BASH_SOURCE ${ABORT} "_ARGSCALL=\"${_ARGSCALL}\""
            showToolHelp
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Unknown SWITCH_ACTION=$SWITCH_ACTION"
	    gotoHell ${ABORT}  
	    ;;
    esac
}





##########################
##########################
_ex=0
SWITCH_ACTION=;
ACTIONCHK=0;
_ARGS=;
RUSER=;
RUSER0=;
_ARGSCALL0=$_ARGSCALL;

#
#pre-fetch su-settings for initial plugin bootstrap
#
fetchSUaccessOpts ${*}


################################################################
#    Default definitions - User-Customizable  from shell       #
################################################################

printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_ARGSCALL=${_ARGSCALL}"

while [ -n "$1" ];do
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:1=${1}"
    case $1 in
	'-b')shift;_bridge=$1;;
	'-f')_force=1;;
	'-i')shift;_interface=$1;;
	'-s')shift;_ssock=${1};;
	'-S')shift;_msock=${1};;
	'-g')shift;_sbitgroup=${1##.*};;
	'-u')shift;_user=${1%%.*};
	    if [ "${1}" != "${1##.*}" ];then
		_group=${1##.*}
	    fi
	    ;;

	'-n')_nohead=1;;

	'-l')shift;RUSER=$1;;
	'-r')shift;_RHOSTS=$1;;

	'-H'|'--helpEx'|'-helpEx')shift;_HelpEx="${1:-$MYCALLNAME}";;
	'-h'|'--help'|'-help')_showToolHelp=1;;
	'-V')_printVersion=1;;
	'-X')C_TERSE=1;;


	'-Z')shift;;
	'-d')shift;;

        -*)
	    ABORT=1;
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Unkown option:\"$1\""
	    gotoHell ${ABORT}
	    ;;

	*)
	    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_ARGS=${_ARGS}"
	    case $1 in
		[cC][hH][eE][cC][kK])     SWITCH_ACTION=CHECK;let ACTIONCHK++;;
		[cC][rR][eE][aA][tT][eE]) SWITCH_ACTION=CREATE;let ACTIONCHK++;;
		[cC][aA][nN][cC][eE][lL]) SWITCH_ACTION=CANCEL;let ACTIONCHK++;;
		[pP][oO][rR][tT][sS])     SWITCH_ACTION=PORTS;let ACTIONCHK++;;
		[iI][nN][fF][oO])         SWITCH_ACTION=INFO;let ACTIONCHK++;;
		[lL][iI][sS][tT][aA][lL][lL])
                    SWITCH_ACTION=LISTALL;let ACTIONCHK++;;
		[lL][iI][sS][tT])         SWITCH_ACTION=LIST;let ACTIONCHK++;;

		*)
   		    _ARGS="${_ARGS} $1"
		    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_ARGS=${_ARGS}"
		    ;;
	    esac
	    ;;
    esac
    shift
done

if((ACTIONCHK>1));then
    printERR $LINENO $BASH_SOURCE 1 "Single actions are suppored only:$_ARGSCALL"
    gotoHell 1
fi

if [ -n "$*" ];then
    printERR $LINENO $BASH_SOURCE 1 "Remaining arguments:$_ARGSCALL"
    gotoHell 1
fi

if [ -n "$_ARGS" ];then
    printERR $LINENO $BASH_SOURCE 1 "Unexpected arguments:$_ARGS"
    gotoHell 1
fi

if [ -n "$_HelpEx" ];then
    printHelpEx "${_HelpEx}";
    exit 0;
fi
if [ -n "$_showToolHelp" ];then
    showToolHelp;
    exit 0;
fi
if [ -n "$_printVersion" ];then
    printVersion;
    exit 0;
fi


function printHead () {
    [ -n "$_nohead" ]&&return;
    case $SWITCH_ACTION in
	LISTALL|LIST) 
	    echo
	    echo "switch                        |UID         |GID         |access      |machine-address"
	    echo "------------------------------+------------+------------+------------+-------------------------"
	    ;;
    esac
}


if [ -n "${_RHOSTS}" ];then
    if [ "$C_TERSE" != 1 ];then
	printINFO 1 $LINENO $BASH_SOURCE 1 "Remote execution${_RUSER:+ as \"$_RUSER\"} on:${_RHOSTS}"
    fi
fi

if [ "$_nohead" != 1 ];then
    printHead
else
    if [ -n "${_RHOSTS}" ];then
	printHead
    fi
fi

if [ -n "${_RHOSTS}" ];then
    _RARGS=${_ARGSCALL//$_RHOSTS/}
    _RARGS=${_RARGS//-r/}
    if [ -n "${_RUSER}" ];then
	_RARGS=${_RARGS//$_RUSER/}
	_RARGS=${_RARGS//\-l/}
    fi

    _RARGS=$(echo ${_RARGS}|sed 's/^  *//;s/  *$//')
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_RARGS=<$_RARGS>"
    _RARGS=${_RARGS//\%/\%\%}
    _RARGS=${_RARGS//,/,,}
    _RARGS=${_RARGS//:/::}
    _RARGS=${_RARGS//  / }
    _RARGS=${_RARGS//  / }
    _RARGS=${_RARGS// /\%}
    _RARGS="${_RARGS}%-n"
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_RARGS=<$_RARGS>"
    _MYLBL=${MYCALLNAME}-${MYUID}-${DATE}

    _call="ctys ${C_DARGS} -t cli -a create=l:${_MYLBL},cmd:${MYCALLNAME}${_RARGS:+%$_RARGS} ${_RUSER:+-l $_RUSER} ${_RHOSTS}"
    printFINALCALL 1  $LINENO $BASH_SOURCE "FINAL-REMOTE-CALL:" "${_call}"
    ${_call}
    exit $?
fi

if [ -n "${_RUSER}" ];then
    printERR $LINENO $BASH_SOURCE 1 "No remote host(\"-R\") for \"-l ${_RUSER}\""
    printERR $LINENO $BASH_SOURCE 1 "For local logins use \"sudo\""
    exit $?
fi


initSetupVDE
execSwitchAction
gotoHell $_ex

