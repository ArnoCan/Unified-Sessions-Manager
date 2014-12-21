#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@users.sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_018
#
########################################################################
#
# Copyright (C) 2010,2011 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

#VBOX generic default parameters, will be dynamically reset in setVersionVBOX
VBOX_STATE=DISABLED
VBOX_MAGIC=VBOX_GENERIC
VBOX_VERSTRING=;
VBOX_ACCELERATOR=;
VBOX_DEFAULTOPTS="-x -q"
VBOX_PREREQ=;
VBOX_PRODVERS=;

VBOX_SERVER=;

_myPKGNAME_VBOX="${BASH_SOURCE}"
_myPKGVERS_VBOX="01.11.018"
hookInfoAdd $_myPKGNAME_VBOX $_myPKGVERS_VBOX

_myPKGBASE_VBOX="`dirname ${_myPKGNAME_VBOX}`"

VBOX_VERSTRING="${_myPKGVERS_VBOX}"


if [ -d "${HOME}/.ctys" -a -d "${HOME}/.ctys/vbox" ];then
    if [ -f "${HOME}/.ctys/vbox/vbox.conf-${MYOS}.sh" ];then
	. "${HOME}/.ctys/vbox/vbox.conf-${MYOS}.sh"
    fi
fi

if [ -d "${HOME}/.ctys" -a -d "${HOME}/.ctys/rdp" ];then
    if [ -f "${HOME}/.ctys/rdp/rdp.conf-${MYOS}.sh" ];then
	. "${HOME}/.ctys/rdp/rdp.conf-${MYOS}.sh"
    fi
fi


#
#To be impersonated to when contacting the vboxare-Entities, could be different
#from the OS-Accounts for host based systems.
#
#ESX/ESXi-use the base loging as they rely on their "own RHEL".
#
#See USER-option.
VBOX_SESSION_USER=${VBOX_SESSION_USER:-$USER}
VBOX_SESSION_CRED=${VBOX_SESSION_CRED}

printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "MYCONFPATH=\"${MYCONFPATH}\""
if [ -d "${MYCONFPATH}/vbox" ];then
    if [ -f "${MYCONFPATH}/vbox/vbox.conf-${MYOS}.sh" ];then
	. "${MYCONFPATH}/vbox/vbox.conf-${MYOS}.sh"
    fi
fi

if [ -d "${MYCONFPATH}/rdp" ];then
    if [ -f "${MYCONFPATH}/rdp/rdp.conf-${MYOS}.sh" ];then
	. "${MYCONFPATH}/rdp/rdp.conf-${MYOS}.sh"
    fi
fi


_waitcVBOX=${VBOX_INIT_WAITC:-0}
_waitsVBOX=${VBOX_INIT_WAITS:-0}

_pingVBOX=${CTYS_PING_DEFAULT_VBOX:-1};
_pingcntVBOX=${CTYS_PING_ONE_MAXTRIAL_VBOX:-20};
_pingsleepVBOX=${CTYS_PING_ONE_WAIT_VBOX:-2};

_sshpingVBOX=${CTYS_SSHPING_DEFAULT_VBOX:-0};
_sshpingcntVBOX=${CTYS_SSHPING_ONE_MAXTRIAL_VBOX:-20};
_sshpingsleepVBOX=${CTYS_SSHPING_ONE_WAIT_VBOX:-2};

#_actionuserVBOX="${MYUID}";


. ${MYLIBPATH}/lib/libVBOXbase.sh
. ${MYLIBPATH}/lib/libVBOX.sh




#FUNCBEG###############################################################
#NAME:
#  getClientTPVBOX
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
# GENERIC-IF-DESCRIPTION:
#  Gives the termination points port number, to gwhich a client could be 
#  attachhed. This port is forseen to be used in port-forwarding e.g.
#  by OpenSSH.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: <label>
#       The <label> to gwhich the client will be attached.
#
#  $2: <pname>
#      The pname of the configuration file, this is required for 
#      RDP-sessions, and given to avoid scanning for labels
#
#OUTPUT:
#  RETURN:
#    0: If OK
#    1: else
#
#  VALUES:
#    <TP-port>
#      The TP port, to gwhich a client could be attached.
#
#FUNCEND###############################################################
function getClientTPVBOX () {
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=$@"
    local _port=;

    if [ -n "$2" ];then
	_port=$(getRDPport ${2})
    fi
    if [ -z "$_port" -a  -n "$1" ];then
	_port=$(getRDPport ${1})
    fi

    if [ -z "${_port}" ];then
	echo
	ABORT=2
	printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Error, can not get port number for label:${1}"
	printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Check your access permissions:USER=$MYUID"
	gotoHell ${ABORT}
    fi
    local _ret=$_port;  
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME port number=$_ret from ID=_port"
    echo ${_ret}
}




#FUNCBEG###############################################################
#NAME:
#  isActiveVBOX
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#    0: Active
#    1: Not active
#
#  VALUES:
#    0: Active
#    1: Not active
#
#FUNCEND###############################################################
function isActiveVBOX () {
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:<$1>"

    if [ -z "$1" ];then
	ABORT=2
	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing ID"
	gotoHell ${ABORT}
    fi
    local x=$(${PS} ${PSEF} |grep -v "grep"|grep -v "$CALLERJOB"|grep ${1#*:} 2>/dev/null)
    if [ -n "$x" ];then
	printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:0($x)"
	echo 0
	return 0;
    fi
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:1($x)"
    echo 1
    return 1;
}



#FUNCBEG###############################################################
#NAME:
#  serverRequireVBOX
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Reports whether a server component has to be called for the current
#  action.
#
#EXAMPLE:
#
#PARAMETERS:
# $*: ${EXECCALL}|<options-list>
#     Generally a string containing an <options-list>, where the
#     first match is choosen. So only one type option is allowed to
#     be contained.
#
#OUTPUT:
#  RETURN:
#    INPUT, where required changes for destination are set.
#  VALUES:
#    0: true, required - output is valid.
#    1: false, not required - output is not valid.
#
#FUNCEND###############################################################
function serverRequireVBOX () {
    printDBG $S_VBOX ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME \$@=$@"
    local _ret=1;
    local _res=;

    local _CS_SPLIT=`echo ${*}|sed -n 's/CONNECTIONFORWARDING/SERVERONLY/p'`;
    local _S=`getSessionType ${*}`;_S=${_S:-$C_SESSIONTYPE};
    local _A=`getActionResulting ${*}`;

    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "_CS_SPLIT=\"${_CS_SPLIT}\""
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "_S=\"${_S}\""
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "_A=\"${_A}\""

    #if split not supported server only could be used
    if [ -n "${_CS_SPLIT}" ];then
        #check for consoles, gwhich are one decisive for component location
	local _myConsole=;
	[ "${*}" != "${*//:[vV][bB][oO][xX]}" ]&&_myConsole=VBOX
	[ "${*}" != "${*//:[rR][dD][pP]}" ]&&_myConsole=RDP
	[ "${*}" != "${*//:[vV][rR][dD][pP]}" ]&&_myConsole=VRDP
	case $_A in 
 	    CONNECT)
		case $_myConsole in
		    #rdesktop
		    RDESKTOP|RDESK|RDP|RD)
			_res="${_CS_SPLIT}";_ret=0;
			;;

		    #terminal server client
		    TSCLIENT|TSC)
			_res="${_CS_SPLIT}";_ret=0;
			;;

		    #VBox: rdesktop-vrdp
		    RDESKTOPVRDP|VBVRDP|VBRD)
			_res="${_CS_SPLIT}";_ret=0;
			;;

		    #VBoxHeadless
		    VBOXHEADLESS|VHEAD|VH)
			_res=;_ret=1;
			;;

		    VBOXSDL|VSDL|VS|VBOX)
			ABORT=1;
			printERR $LINENO $BASH_SOURCE ${ABORT} "The console type $_myConsole for $_A cannot be combined with"
			printERR $LINENO $BASH_SOURCE ${ABORT} "option: -L CONNECTIONFORWARDING"
			gotoHell ${ABORT}
			;;

		    *)
			printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:Assume false:$_myConsole for $_A "
			_res=;_ret=1;
			;;
		esac
		;;
 	    CREATE)  
		case $_myConsole in

		    #rdesktop
		    RDESKTOP|RDESK|RDP|RD)
			_res="${_CS_SPLIT}";_ret=0;
			;;

		    #terminal server client
		    TSCLIENT|TSC)
			_res="${_CS_SPLIT}";_ret=0;
			;;

		    #VBox: rdesktop-vrdp
		    RDESKTOPVRDP|VBVRDP|VRDP)
			_res="${_CS_SPLIT}";_ret=0;
			;;

		    #VBoxHeadless
		    VBOXHEADLESS|VHEAD|VH)
			_res="${_CS_SPLIT}";_ret=1;
			;;

		    VBOXSDL|VSDL|VS|VBOX)
			ABORT=1;
			printERR $LINENO $BASH_SOURCE ${ABORT} "The console type $_myConsole for $_A cannot be combined with"
			printERR $LINENO $BASH_SOURCE ${ABORT} "option: -L CONNECTIONFORWARDING"
			gotoHell ${ABORT}
			;;

		    *)
			printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:Assume true:$_myConsole for $_A "
			_res="${*}";_ret=0;
			;;
		esac
		;;
	esac
    else
 	_res="${*}";_ret=0;
    fi

    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_res=\"${_res}\""
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_ret=\"${_ret}\""
    echo -n "${_res}";
    return ${_ret};  
}



#FUNCBEG###############################################################
#NAME:
#  clientRequireVBOX
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Reports whether a client component has to be called for the current
#  action.
#
#EXAMPLE:
#
#PARAMETERS:
# $*: ${EXECCALL}|<options-list>
#     Generally a string containing an <options-list>, where the
#     first match is choosen. So only one type option is allowed to
#     be contained.
#
#OUTPUT:
#  RETURN:
#    INPUT, where required changes for destination are set.
#  VALUES:
#    0: true, required - output is valid.
#    1: false, not required - output is not valid.
#
#FUNCEND###############################################################
function clientRequireVBOX () {
    printDBG $S_VBOX ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME \$@=$@"
#    local _CS_SPLIT=`echo ${*}|sed -n 's/CONNECTIONFORWARDING/1/p;s/LOCALONLY/1/p;s/CLIENTONLY/1/p'`;
    local _CS_SPLIT=`echo ${*}|awk '/CONNECTIONFORWARDING/||/LOCALONLY/||/CLIENTONLY/{print}'`;

    local _S=`getSessionType ${*}`;_S=${_S:-$C_SESSIONTYPE};
    local _A=`getActionResulting ${*}`;
    local _ret=1;
    local _res=;

    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "_CS_SPLIT=\"${_CS_SPLIT}\""
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "_S=\"${_S}\""
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "_A=\"${_A}\""

    #if split not supported server only could be used
    if [ -n "${_CS_SPLIT}" ];then
        #check for consoles, gwhich are one decisive for component location
	local _myConsole=;
	[ "${*}" != "${*//:[vV][bB][oO][xX]}" ]&&_myConsole=VBOX
	[ "${*}" != "${*//:[rR][dD][pP]}" ]&&_myConsole=RDP
	[ "${*}" != "${*//:[vV][rR][dD][pP]}" ]&&_myConsole=VRDP

	case $_A in 
 	    CONNECT)
		case $_myConsole in
		    #rdesktop
		    RDESKTOP|RDESK|RDP|RD)
			_res="${_CS_SPLIT}";_ret=1;
			;;

		    #terminal server client
		    TSCLIENT|TSC)
			_res="${_CS_SPLIT}";_ret=1;
			;;

		    #VBox: rdesktop-vrdp
		    RDESKTOPVRDP|VBVRDP|VRDP)
			_res="${_CS_SPLIT}";_ret=0;
			;;

		    #VBoxSDL
		    VBOXSDL|VSDL|VS)
			_res=;_ret=0;
			;;

		    #VBoxHeadless
		    VBOXHEADLESS|VHEAD|VH)
			_res=;_ret=1;
			;;

		    #VirtualBox
		    VBOX)
			_res="${_CS_SPLIT}";_ret=0;
			;;
		    *)
			printDBG $S_VBOX ${D_UI} $LINENO $BASH_SOURCE "$FUNCNAME:Assume true:$_myConsole for $_A "
			_res=${*};_ret=0;
			;;
		esac
		;;
 	    CREATE)  
		case $_myConsole in
		    #rdesktop
		    RDESKTOP|RDESK|RDP|RD)
			_res="${_CS_SPLIT}";_ret=1;
			;;

		    #terminal server client
		    TSCLIENT|TSC)
			_res="${_CS_SPLIT}";_ret=1;
			;;

		    #VBox: rdesktop-vrdp
		    RDESKTOPVRDP|VBVRDP|VBRD)
			_res="${_CS_SPLIT}";_ret=0;
			;;

		    #VBoxSDL
		    VBOXSDL|VSDL|VS)
			_res=;_ret=0;
			;;

		    #VBoxHeadless
		    VBOXHEADLESS|VHEAD|VH)
			_res=;_ret=1;
			;;

		    #VirtualBox
		    VBOX)
			_res="${_CS_SPLIT}";_ret=0;
			;;
		    *)
			printDBG $S_VBOX ${D_UI} $LINENO $BASH_SOURCE "$FUNCNAME:Assume true:$_myConsole for $_A "
			_res=${*};_ret=0;
			;;
		esac
		;;
	esac
    else
 	_res=;_ret=1;
    fi

    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_res=\"${_res}\""
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_ret=\"${_ret}\""
    echo -n "${_res}";
    return ${_ret};  
}




#FUNCBEG###############################################################
#NAME:
#  setVersionVBOX
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Sets defaults and MAGIC-ID for local vmware version.
#
#  The defaults for VBOX_DEFAULTOPTS will only be used when no CLI
#  options are given.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: NOEXIT
#      This optional parameter as literal forces a return instead of 
#      exit by "gotoHell". Should be used, for test-only, when for
#      missing or erroneous plugins specific actions has to follow
#      within current execution thread.
#      
#
#OUTPUT:
#  GLOBALS:
#    VBOX_MAGIC:  
#      Value to be checked, when no local native components are 
#      present, the following values will be set.
#
#      They have to be checked, when C_EXECLOCAL or "-L CF".
#
#        NOLOC     No local component available, remaining:
#                  -> !C_EXECLOCAL && "-L (DF|SO)"
#
#        NOLOCVBOX No local VirtualBox component, remaining:
#                  -> !C_EXECLOCAL && "-L (DF|SO)"
#                  -> RDP-viewer for WS6 IF "RDP"
#
#  (ffs.)NOLOCRDP  No local "RDP" (for WS6), remaining:
#                  -> "-L (DF|SO|CF|LO)"
#
#    VBOX_DEFAULTOPTS
#
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function setVersionVBOX () {
    local _checkonly=;
    local _ret=0;
    if [ "$1" == "NOEXIT" ];then
	local _checkonly=1;        
    fi

    local _cap="VM-CAPABILITY:VBOX-${VBOX_VERSTRING}-${MYARCH}";

    #VNC - let us say required!!!
    hookPackage RDP
    hookInitPropagate4Package RDP

    local _rdpOK=`hookInfoCheckPKG RDP`
    if [ -z "${_rdpOK}" ];then
	ABORT=1;
	if [ "${C_SESSIONTYPE}" == "VBOX" -a -z "${_checkonly}" ];then
	    printERR $LINENO $BASH_SOURCE ${ABORT} "This feature requires additional RDP plugin to be pre-loaded."
	    printERR $LINENO $BASH_SOURCE ${ABORT} "-> Set the option \"-T rdp,vbox,...\" "
	    printERR $LINENO $BASH_SOURCE ${ABORT} "-> Check actually loaded plugins with option \"-v\""
	    gotoHell ${ABORT}
	else
	    printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "This feature reuqires additional RDP plugin to be pre-loaded."
	    printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "-> Set the option \"-T rdp,vbox,...\" "
	    printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "-> Check actually loaded plugins with option \"-v\""
	    return ${ABORT}
	fi
    else
	VBOX_PREREQ="${VBOX_PREREQ} RDP-ValidatedBy(hookInfoCheckPKG)"
    fi
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:verified pre-requisites:RDP"

    if [ "$C_EXECLOCAL" == 1 ];then
	if  [ -z "$VBOXEXE" -o -z "$VBOXMGR" -o -z "$VBOXHEADLESS" -o -z "$VBOXSDL" ];then
	    ABORT=1;
	    VBOX_STATE=DISABLED;
	    VBOX_MAGIC=NOLOC;
	    [ -z "$VBOXEXE" ]&&VBOX_PREREQ="${VBOX_PREREQ} <`setStatusColor ${VBOX_STATE} VirtualBox`:CANNOT-EVALUATE>"
	    [ -z "$VBOXMGR" ]&&VBOX_PREREQ="${VBOX_PREREQ} <`setStatusColor ${VBOX_STATE} VBoxManage`:CANNOT-EVALUATE>"
	    [ -z "$VBOXHEADLESS" ]&&VBOX_PREREQ="${VBOX_PREREQ} <`setStatusColor ${VBOX_STATE} VBoxHeadless`:CANNOT-EVALUATE>"
	    [ -z  "$VBOXSDL" ]&&VBOX_PREREQ="${VBOX_PREREQ} <`setStatusColor ${VBOX_STATE} VBoxSDL`:CANNOT-EVALUATE>"
	    return ${ABORT}
	fi
    else
	VBOX_STATE=ENABLED;
	VBOX_MAGIC=RELAY;
	return
    fi
    local _verstrg=;
    if [ -n "$VBOXEXE" ];then
	_verstrg=$(getVersionStrgVBOX $VBOXEXE)
	if [ $? -ne 0 ];then
	    _verstrg=;
	fi
    fi
    if [ -z "${_verstrg}" ];then

	local _creq=;
	clientRequireVBOX $_CLIARGS>/dev/null
	_creq=$?;

	if [ $_creq -eq 0 ];then
	    ABORT=2
	    VBOX_PREREQ="${VBOX_PREREQ} <`setStatusColor ${VBOX_STATE} VERSION`:CANNOT-EVALUATE>"

	    if [ "${C_SESSIONTYPE}" == "VBOX" -a -z "${_checkonly}" ];then
		if [ -z "${VBOXEXE}" ];then
		    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing executable for VirtualBox"
		    printERR $LINENO $BASH_SOURCE ${ABORT} "can not find:"
		    printERR $LINENO $BASH_SOURCE ${ABORT} " -> VirtualBox"
		    printERR $LINENO $BASH_SOURCE ${ABORT} ""
		    printERR $LINENO $BASH_SOURCE ${ABORT} "Check your PATH"
		    printERR $LINENO $BASH_SOURCE ${ABORT} " -> PATH=${PATH}"
		    printERR $LINENO $BASH_SOURCE ${ABORT} ""
		else
		    printERR $LINENO $BASH_SOURCE ${ABORT} "Cannot evaluate version:\"${VBOXEXE} --help\"."
		    printERR $LINENO $BASH_SOURCE ${ABORT} "Executable seems to be missing."
		fi
		gotoHell ${ABORT}
	    else
		if [ -z "${VBOXEXE}" ];then
		    printDBG $S_VBOX ${D_BULK} $LINENO $BASH_SOURCE "CHKONLY:VirtualBox seems not to be installed."
		else
		    printDBG $S_VBOX ${D_BULK} $LINENO $BASH_SOURCE "CHKONLY:Cannot evaluate version:\"${VBOXEXE}\""
		fi
		return ${ABORT}
	    fi
	fi
    else
	VBOX_SERVER=ENABLED;
    fi


    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "VirtualBox"
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "  VBOXEXE=\"${VBOXEXE}\""
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "  VBOXMGR=\"${VBOXMGR}\""
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "  _verstrg=${_verstrg}"

    VBOX_MAGIC=$(getVBOXMAGIC ${VBOXEXE});

    #currently somewhat restrictive to specific versions.
    case ${VBOX_MAGIC} in
	VBOX_03*)
	    VBOX_PRODVERS=${_verstrg};
	    VBOX_DEFAULTOPTS="";
	    VBOX_STATE=ENABLED
            _cap="${_cap}%${_verstrg}"
	    ABORT=1;
	    printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "Limited options support, e.g. no \"-g <geometry>\" for:\"${_verstrg}\""
	    _ret=0;
	    ;;

        *)
	    printWNG 2 $LINENO $BASH_SOURCE 0 "Unsupported or misconfigured local version:"
	    printWNG 2 $LINENO $BASH_SOURCE 0 "  ctys    :<${VERSION}>"
	    printWNG 2 $LINENO $BASH_SOURCE 0 "  VBOX     :<${_myPKGVERS_VBOX}>"
	    printWNG 2 $LINENO $BASH_SOURCE 0 "  Product :<${_verstrg}>"
	    printWNG 2 $LINENO $BASH_SOURCE 0 "."
	    printWNG 2 $LINENO $BASH_SOURCE 0 "Remaining options:"
	    printWNG 2 $LINENO $BASH_SOURCE 0 "->remote: \"-L DISPLAYFORWARDING\""
	    printWNG 2 $LINENO $BASH_SOURCE 0 "->remote: \"-L SERVERONLY\"(partial...)"
	    printWNG 2 $LINENO $BASH_SOURCE 0 "->local:  RDP-client"
	    printWNG 2 $LINENO $BASH_SOURCE 0 "."
	    VBOX_MAGIC=NOLOC;
	    _cap="${_cap} <`setStatusColor ${VBOX_STATE} VERSION`:UNKNOWN-VERSION:${_verstrg// /_}>"
	    _ret=2;
	    ;;
    esac
    VBOX_PREREQ="${_cap} ${VBOX_PREREQ}"
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "VBOX_MAGIC       = ${VBOX_MAGIC}"
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "VBOX_STATE       = ${VBOX_STATE}"
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "VBOX_VERSTRING   = ${VBOX_VERSTRING}"
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "VBOX_PRODVERS    = ${VBOX_PRODVERS}"
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "VBOX_PREREQ      = ${VBOX_PREREQ}"
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "VBOX_DEFAULTOPTS = ${VBOX_DEFAULTOPTS}"
    return $_ret;
}




#FUNCBEG###############################################################
#NAME:
#  clientServerSplitSupportedVBOX
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Checks whether the split of client and server is supported.
#  This is just a hardcoded attribute and controls the application 
#  matrix of following attribute values of option "-L" locality:
#
#   - CONNECTIONFORWARDING
#   - DISPLAYFORWARDING
#   - SERVERONLY
#   - LOCALONLY
#
#EXAMPLE:
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#    0: If supported
#    1: else
#
#  VALUES:
#
#FUNCEND###############################################################
function clientServerSplitSupportedVBOX () {
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME $1"
    case $1 in
	CREATE)
	    return 0
	    ;;

	CANCEL)return 0;;
    esac
    return 1;
}


#FUNCBEG###############################################################
#NAME:
#  handleVBOX
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Main dispatcher for current plugin. It manages specific actions and
#  context-specific sets of suboptions.
#
#  It has to follow defined interfaces for main framework, due its dynamic
#  detection, load, and initialization.
#  Anything works by naming convention, for files, directories, and function 
#  names so don't alter it.
#
#  Arbitrary subpackages could be defined and chained-loaded. This is due 
#  design decision of plugin developers. Just the entry point is fixed by 
#  common framework.
#
#EXAMPLE:
#
#PARAMETERS:
#
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function handleVBOX () {
  printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "${FUNCNAME}:$*"
  local OPMODE=$1;shift
  local ACTION=$1;shift

  case ${ACTION} in
      LIST)
	  case ${OPMODE} in
              PROLOGUE)
		  hookPackage "${_myPKGBASE_VBOX}/list.sh"
		  ;;
              EPILOGUE)
		  ;;
	      CHECKPARAM)
		  ;;
	      ASSEMBLE)
		  ;;
	      EXECUTE)
		  ;;
	  esac
	  ;;

      INFO)
	  case ${OPMODE} in
              PROLOGUE)
		  hookPackage "${_myPKGBASE_VBOX}/info.sh"
		  ;;
              EPILOGUE)
		  ;;
	      CHECKPARAM)
		  ;;
	      ASSEMBLE)
		  ;;
	      EXECUTE)
		  hookPackage "${_myPKGBASE_VBOX}/list.sh"
		  ;;
	  esac
	  ;;

      ENUMERATE)
	  case ${OPMODE} in
              PROLOGUE)
		  hookPackage "${_myPKGBASE_VBOX}/enumerate.sh"
		  ;;
              EPILOGUE)
		  ;;
	      CHECKPARAM)
		  ;;
	      ASSEMBLE)
		  ;;
	      EXECUTE)
		  hookPackage "${_myPKGBASE_VBOX}/session.sh"
		  hookPackage "${_myPKGBASE_VBOX}/list.sh"
		  ;;
	  esac
	  ;;


      CREATE) 
	  case ${OPMODE} in
              PROLOGUE)
		  ;;
              EPILOGUE)
		  ;;
	      CHECKPARAM)
		  hookPackage "${_myPKGBASE_VBOX}/create.sh"
		  createConnectVBOX ${OPMODE} ${ACTION} 
		  ;;
	      ASSEMBLE)
		  hookPackage "${_myPKGBASE_VBOX}/create.sh"
		  createConnectVBOX ${OPMODE} ${ACTION} 
		  ;;
	      EXECUTE)
		  hookPackage "${_myPKGBASE_VBOX}/session.sh"
		  hookPackage "${_myPKGBASE_VBOX}/list.sh"
		  hookPackage "${_myPKGBASE_VBOX}/create.sh"
		  createConnectVBOX ${OPMODE} ${ACTION} 
		  ;;
	  esac
	  ;;

      CANCEL)
	  case ${OPMODE} in
              PROLOGUE)
		  ;;
              EPILOGUE)
		  ;;
	      CHECKPARAM)
		  hookPackage "${_myPKGBASE_VBOX}/cancel.sh"
		  cutCancelSessionVBOX ${OPMODE} ${ACTION} 
		  ;;
	      ASSEMBLE)
		  hookPackage "${_myPKGBASE_VBOX}/cancel.sh"
		  cutCancelSessionVBOX ${OPMODE} ${ACTION} 
		  ;;
	      EXECUTE)
		  hookPackage "${_myPKGBASE_VBOX}/session.sh"
		  hookPackage "${_myPKGBASE_VBOX}/list.sh"
		  cutCancelSessionVBOX ${OPMODE} ${ACTION} 
		  ;;
	  esac
          ;;

      GETCLIENTPORT)
	  case ${OPMODE} in
              PROLOGUE)
		  ;;
              EPILOGUE)
		  ;;
              CHECKPARAM)
		  if [ -n "$C_MODE_ARGS" ];then
                      printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "C_MODE_ARGS=$C_MODE_ARGS"
                      _C_GETCLIENTPORT=$C_MODE_ARGS
		  else
		      ABORT=1
		      printERR $LINENO $BASH_SOURCE ${ABORT} "Missing <session-label>|<session-id>"
		      gotoHell ${ABORT}
		  fi
                  ;;

	      EXECUTE)
		  printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "Remote command:OPTARG=${OPTARG}"
		  case $VBOX_MAGIC in
		      VBOX_03*)
			  ;;
		      *)
  			  echo ""
			  ABORT=1
			  printERR $LINENO $BASH_SOURCE ${ABORT} "Unknown version, reject remote console."
			  printERR $LINENO $BASH_SOURCE ${ABORT} "  Version:${VBOX_VERSTRING}"
			  gotoHell ${ABORT}
			  ;;
		  esac
  		  echo "CLIENTPORT(VBOX,${MYHOST},${_C_GETCLIENTPORT})=`getClientTPVBOX ${_C_GETCLIENTPORT//,/ }`"
		  gotoHell 0
		  ;;

 	      ASSEMBLE)
		    assembleExeccall ${OPMODE}
 		  ;;
          esac
	  ;;

      ISACTIVE)
	  case ${OPMODE} in
              PROLOGUE)
		  ;;
              EPILOGUE)
		  ;;
              CHECKPARAM)
		  if [ -n "$C_MODE_ARGS" ];then
                      printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "C_MODE_ARGS=$C_MODE_ARGS"
                      _MYID=$C_MODE_ARGS
		  else
		      ABORT=1
		      printERR $LINENO $BASH_SOURCE ${ABORT} "Missing <session-id>"
		      gotoHell ${ABORT}
		  fi
                  ;;

	      EXECUTE)
		  printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "Remote command:OPTARG=${OPTARG}"
		  case $VBOX_MAGIC in
		      VBOX_03*)
			  ;;
		      *)
  			  echo ""
			  ABORT=1
			  printERR $LINENO $BASH_SOURCE ${ABORT} "Unknown version, reject remote console."
			  printERR $LINENO $BASH_SOURCE ${ABORT} "  Version:${VBOX_VERSTRING}"
			  gotoHell ${ABORT}
			  ;;
		  esac
 		  echo "ISACTIVE(VBOX,${C_MODE_ARGS})=`isActiveVBOX ${C_MODE_ARGS}`"
		  gotoHell 0
		  ;;

 	      ASSEMBLE)
 		  ;;
          esac
	  ;;

      *)
          ABORT=1;
          printERR $LINENO $BASH_SOURCE ${ABORT} "System Error, unexpected VBOX:OPMODE=${OPMODE} ACTION=${ACTION}"
	  gotoHell ${ABORT}
          ;;
  esac
}



#FUNCBEG###############################################################
#NAME:
#  initVBOX
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function initVBOX () {
  local _curInit=$1;shift
  local _initConsequences=$1
  local ret=0;

  local _raise=$((INITSTATE<_curInit));

  printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:${INITSTATE} -> ${_curInit} - ${_raise}"

  if [ "$_raise" == "1" ];then
      #for raise of INITSTATE do not touch the OS's decisions, just expand.

      case $_curInit in
	  0);;#NOP - Done by shell
	  1)  
              #adjust version specifics  
              setVersionVBOX $_initConsequences
              ret=$?

              #add own help to searchlist for options
	      MYOPTSFILES="${MYOPTSFILES} ${MYHELPPATH}/010_vbox"
	      ;;
	  2);;
	  3);;
	  4);;
	  5);;
	  6);;
      esac
  else
      case $_curInit in
	  *);;
      esac

  fi

  return $ret
}
