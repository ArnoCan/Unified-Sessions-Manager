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
# Copyright (C) 2007,2008,2010,2011 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

#VMW generic default parameters, will be dynamically reset in setVersionVMW
VMW_STATE=DISABLED
VMW_MAGIC=VMW_GENERIC
VMW_VERSTRING=;
VMW_ACCELERATOR=;
VMW_DEFAULTOPTS="-x -q"
VMW_PREREQ=;
VMW_PRODVERS=;
VMW_SERVER=;

_myPKGNAME_VMW="${BASH_SOURCE}"
_myPKGVERS_VMW="01.11.011"
hookInfoAdd $_myPKGNAME_VMW $_myPKGVERS_VMW

_myPKGBASE_VMW="`dirname ${_myPKGNAME_VMW}`"

VMW_VERSTRING="${_myPKGVERS_VMW}"


if [ -d "${HOME}/.ctys" -a -d "${HOME}/.ctys/vmw" ];then
    if [ -f "${HOME}/.ctys/vmw/vmw.conf-${MYOS}.sh" ];then
	. "${HOME}/.ctys/vmw/vmw.conf-${MYOS}.sh"
    fi

fi

#
#To be impersonated to when contacting the VMware-Entities, could be different
#from the OS-Accounts for host based systems.
#
#ESX/ESXi-use the base loging as they rely on their "own RHEL".
#
#See USER-option.
VMW_SESSION_USER=${VMW_SESSION_USER:-$USER}
VMW_SESSION_CRED=${VMW_SESSION_CRED}

printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "MYCONFPATH=\"${MYCONFPATH}\""
if [ -d "${MYCONFPATH}/vmw" ];then
    if [ -f "${MYCONFPATH}/vmw/vmw.conf-${MYOS}.sh" ];then
	. "${MYCONFPATH}/vmw/vmw.conf-${MYOS}.sh"
    fi
fi


_waitcVMW=${VMW_INIT_WAITC:-0}
_waitsVMW=${VMW_INIT_WAITS:-0}

_pingVMW=${CTYS_PING_DEFAULT_VMW:-1};
_pingcntVMW=${CTYS_PING_ONE_MAXTRIAL_VMW:-20};
_pingsleepVMW=${CTYS_PING_ONE_WAIT_VMW:-2};

_sshpingVMW=${CTYS_SSHPING_DEFAULT_VMW:-0};
_sshpingcntVMW=${CTYS_SSHPING_ONE_MAXTRIAL_VMW:-20};
_sshpingsleepVMW=${CTYS_SSHPING_ONE_WAIT_VMW:-2};

_actionuserVMW="${MYUID}";


#FUNCBEG###############################################################
#NAME:
#  isActiveVMW
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
function isActiveVMW () {
    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:<$1>"

    if [ -z "$1" ];then
	ABORT=2
	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing ID"
	gotoHell ${ABORT}
    fi
    local x=$(${PS} ${PSEF} |grep -v "grep"|grep -v "$CALLERJOB"|grep ${1#*:} 2>/dev/null)
    if [ -n "$x" ];then
	printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:0($x)"
	echo 0
	return 0;
    fi
    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:1($x)"
    echo 1
    return 1;
}



#FUNCBEG###############################################################
#NAME:
#  getClientTPVMW
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
#  The port is the local port number, gwhich in general has to be mapped 
#  on remote site, when already in use. Therefore the application has
#  to provide a port-number-independent client access protocol in order 
#  to be used by connection forwarding. In any other case display 
#  forwarding has to be choosen.
#
#  Some applications support only one port for access by multiple 
#  sessions, dispatching and bundling the communications channels
#  by their own protocol. 
#
#  While others require for each channel a seperate litenning port.
#
#  So it is up to the specific package to support a function returning 
#  the required port number gwhich could be used to attach an forwarded 
#  port. 
#  
#  The applications client has to support a remapped port number.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: <label>
#       The <label> to gwhich the client will be attached.
#
#  $2: <pname>
#      The pname of the configuration file, this is required for 
#      VNC-sessions, and given to avoid scanning for labels
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
function getClientTPVMW () {
    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=$@"
    local _port=;

    #for ws>6 only
    if [ -n "$2" -a "${VMW_MAGIC}" == "VMW_WS6" -o "${VMW_MAGIC}" == "VMW_WS7" ];then
	if [ -f "$2" ];then
	    _port=`cat $2|sed -n 's/\t//g;/^#/d;s/RemoteDisplay.vnc.port *= *"\([^"]*\)"/\1/p'`
	fi
	printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_port=$_port"
    fi

    #for s2
    if [ -z "$_port" -a -f "/etc/vmware/hostd/proxy.xml" ];then
	_port=`cat /etc/vmware/hostd/proxy.xml |sed -n 's@<httpsPort>\([0-9]*\)</httpsPort>@\1@p'`
	if [ -z "$_port" ];then
	    _port=`cat /etc/vmware/hostd/proxy.xml |sed -n 's@<httpPort>\([0-9]*\)</httpPort>@\1@p'`
	fi
    fi

    #for ws and server
    if [ -z "$_port" -a -f "/etc/vmware/config" ];then
	_port=`cat /etc/vmware/config |sed -n 's/authd.client.port *= *"\([0-9]*\)"/\1/p'`
    fi

    #for player not an error!
    if [ -z "${_port}" ];then
	if [ "${VMW_MAGIC}" == "VMW_S104" ];then
	    echo
	    ABORT=2
	    printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Error, can not get port number for label:${1}"
	    gotoHell ${ABORT}
	fi
    fi
    local _ret=$_port;  
    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME port number=$_ret from ID=_port"
    echo ${_ret}
}



#FUNCBEG###############################################################
#NAME:
#  serverRequireVMW
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
function serverRequireVMW () {
    printDBG $S_VMW ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME \$@=$@"
    local _ret=1;
    local _res=;

    local _CS_SPLIT=`echo ${*}|sed -n 's/CONNECTIONFORWARDING/SERVERONLY/p'`;
    local _S=`getSessionType ${*}`;_S=${_S:-$C_SESSIONTYPE};
    local _A=`getActionResulting ${*}`;

    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "_CS_SPLIT=\"${_CS_SPLIT}\""
    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "_S=\"${_S}\""
    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "_A=\"${_A}\""

    #if split not supported server only could be used
    if [ -n "${_CS_SPLIT}" ];then
        #check for consoles, gwhich are one decisive for component location
	local _myConsole=;

	case $VMW_MAGIC in
	    VMW_S20*)
		_myConsole=${CTYS_VMW2_DEFAULTCONTYPE:-VMWRC}
		;;
	    *)
		_myConsole=VMW;
		;;
	esac

	[ "${*}" != "${*//:[vV][mM][wW][rR][cC]}" ]&&_myConsole=VMWRC
	[ "${*}" != "${*//:[vV][mM][wW]}" ]&&_myConsole=VMW
	[ "${*}" != "${*//:[vV][nN][cC]}" ]&&_myConsole=VNC

	case $_A in 
 	    CONNECT)
		case $_myConsole in
		    VMWRC)
			_res=;_ret=1;
			;;
		    VMW)
			_res=;_ret=1;
			;;
		    VNC)
			_res=;_ret=1;
			;;
		    *)
			printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:Assume false:$_myConsole for $_A "
			_res=;_ret=1;
			;;
		esac
		;;
 	    CREATE)  
		case $_myConsole in
		    VMWRC)
			_res="${_CS_SPLIT}";_ret=0;
			;;
		    VMW)
			_res="${_CS_SPLIT}";_ret=0;
			;;
		    VNC)
			printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:Require WS6 on target:$_myConsole for $_A "
			_res="${_CS_SPLIT}";_ret=0;
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

    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_res=\"${_res}\""
    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_ret=\"${_ret}\""
    echo -n "${_res}";
    return ${_ret};  
}



#FUNCBEG###############################################################
#NAME:
#  clientRequireVMW
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
function clientRequireVMW () {
    printDBG $S_VMW ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME \$@=$@"
    local _CS_SPLIT=`echo ${*}|sed -n 's/CONNECTIONFORWARDING/1/p;s/LOCALONLY/1/p;s/CLIENTONLY/1/p'`;
    local _S=`getSessionType ${*}`;_S=${_S:-$C_SESSIONTYPE};
    local _A=`getActionResulting ${*}`;
    local _ret=1;
    local _res=;

    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "_CS_SPLIT=\"${_CS_SPLIT}\""
    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "_S=\"${_S}\""
    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "_A=\"${_A}\""

    #if split not supported server only could be used
    if [ -n "${_CS_SPLIT}" ];then
        #check for consoles, gwhich are one decisive for component location
	local _myConsole=;
	case $VMW_MAGIC in
	    VMW_S20*)
		_myConsole=${CTYS_VMW2_DEFAULTCONTYPE:-VMWRC}
		;;
	    *)
		_myConsole=VMW;
		;;
	esac

	[ "${*}" != "${*//:[vV][mM][wW]}" ]&&_myConsole=VMW
	[ "${*}" != "${*//:[vV][nN][cC]}" ]&&_myConsole=VNC
	[ "${*}" != "${*//:[vV][mM][wW][rR][cC]}" ]&&_myConsole=VMWRC

	case $_A in 
 	    CONNECT)
		case $_myConsole in
		    VMWRC)
			case $VMW_MAGIC in
			    VMW_P[2]*)_res=;_ret=1;;
			    VMW_S[2]*)_res=${*};_ret=1;;
			    VMW_WS[7]*)_res=${*};_ret=0;;
			    VMW_RC)_res=${*};_ret=0;;
                        esac
			;;
		    VMW)
			case $VMW_MAGIC in
			    VMW_P[1]*)_res=;_ret=1;;
			    VMW_S[1]*)_res=${*};_ret=0;;
			    VMW_WS[56]*)_res=${*};_ret=0;;
                        esac
			;;
		    VNC)
			printDBG $S_VMW ${D_UI} $LINENO $BASH_SOURCE "$FUNCNAME:Has to be decided on target:$_myConsole for $_A "
			;;
		    *)
			printDBG $S_VMW ${D_UI} $LINENO $BASH_SOURCE "$FUNCNAME:Assume true:$_myConsole for $_A "
			_res=${*};_ret=0;
			;;
		esac
		;;
 	    CREATE)  
		case $_myConsole in
		    VMWRC)
			case $VMW_MAGIC in
			    VMW_P[2]*)_res=;_ret=1;;
			    VMW_S[2]*)_res=${*};_ret=0;;
			    VMW_WS[7]*)_res=${*};_ret=0;;
			    VMW_RC)_res=${*};_ret=0;;
                        esac
			;;
		    VMW)
			case $VMW_MAGIC in
			    VMW_P[1]*)_res=;_ret=1;;
			    VMW_S[1]*)_res=${*};_ret=0;;
			    VMW_WS[56]*)_res=${*};_ret=0;;
                        esac
			;;
		    VNC)
			printDBG $S_VMW ${D_UI} $LINENO $BASH_SOURCE "$FUNCNAME:Has to be decided on target:$_myConsole for $_A "
			;;
		    *)
			printDBG $S_VMW ${D_UI} $LINENO $BASH_SOURCE "$FUNCNAME:Assume true:$_myConsole for $_A "
			_res=${*};_ret=0;
			;;
		esac
		;;
	esac
    else
 	_res=;_ret=1;
    fi

    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_res=\"${_res}\""
    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_ret=\"${_ret}\""
    echo -n "${_res}";
    return ${_ret};  
}




#FUNCBEG###############################################################
#NAME:
#  setVersionVMW
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Sets defaults and MAGIC-ID for local vmware version.
#
#  The defaults for VMW_DEFAULTOPTS will only be used when no CLI
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
#    VMV_MAGIC:  {VMW_WS6|VMW_S103|...}
#      Value to be checked, when no local native components are 
#      present, the following values will be set.
#
#      They have to be checked, when C_EXECLOCAL or "-L CF".
#
#        NOLOC     No local component available, remaining:
#                  -> !C_EXECLOCAL && "-L (DF|SO)"
#
#        NOLOCVMV  No local VMware component, remaining:
#                  -> !C_EXECLOCAL && "-L (DF|SO)"
#                  -> VNC-viewer for WS6 IF "VNC"
#
#  (ffs.)NOLOCVNC  No local "VNC" (for WS6), remaining:
#                  -> "-L (DF|SO|CF|LO)"
#
#    VMW_DEFAULTOPTS
#      Appropriate defaults.
#
#      -Pre-set generic default parameters: "-x -q"
#      -WMW_WS6:                            "-x -q -n"
#      -WMW_S103:                           "-x -q -l"
#      -WMW_S104:                           "-x -q -l"
#
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function setVersionVMW () {
    local _checkonly=;
    local _ret=0;
    if [ "$1" == "NOEXIT" ];then
	local _checkonly=1;        
    fi

    local _cap="VM-CAPABILITY:VMW-${VMW_VERSTRING}-${MYARCH}";

    local _verstrg=;
    if [ -n "$VMWEXE" ];then
	_verstrg=`callErrOutWrapper $LINENO $BASH_SOURCE $VMWEXE -v`
	if [ $? -ne 0 -o "${_verstrg//vmware-config.pl/}" != "${_verstrg}" ];then
	    _verstrg=;
	else
	    #4TEST:REMINDER:check "callErrOutWrapper" for redirection
	    #4TEST:REMINDER:get rid of "MIT-MAGIC-COOKIE..." in stdio!!!
	    _verstrg=$(echo "$_verstrg"|awk 'x!="NO"{print;x="NO";}' )
	fi
    fi

    if [ -z "${_verstrg}" ];then
	ABORT=2
	VMW_STATE=DISABLED;
	VMW_MAGIC=NOLOC;
	VMW_PREREQ="<`setStatusColor ${VMW_STATE} VERSION`:CANNOT-EVALUATE>"
	if [ "${C_SESSIONTYPE}" == "VMW" -a -z "${_checkonly}" ];then
	    if [ -z "${VMWEXE}" ];then
		printERR $LINENO $BASH_SOURCE ${ABORT} "Missing executable for VMware"
		printERR $LINENO $BASH_SOURCE ${ABORT} "can not find:"
		printERR $LINENO $BASH_SOURCE ${ABORT} " -> vmware && vmplayer"
		printERR $LINENO $BASH_SOURCE ${ABORT} ""
		printERR $LINENO $BASH_SOURCE ${ABORT} "Check your PATH"
		printERR $LINENO $BASH_SOURCE ${ABORT} " -> PATH=${PATH}"
		printERR $LINENO $BASH_SOURCE ${ABORT} ""
	    else
		printERR $LINENO $BASH_SOURCE ${ABORT} "Cannot evaluate version:\"${VMWEXE} -v\","
		printERR $LINENO $BASH_SOURCE ${ABORT} "this typically occurs when not yet configured."
	    fi
	    gotoHell ${ABORT}
	else
	    if [ -z "${VMWEXE}" ];then
		printDBG $S_VMW ${D_BULK} $LINENO $BASH_SOURCE "CHKONLY:VMware seems not to be installed."
	    else
		printDBG $S_VMW ${D_BULK} $LINENO $BASH_SOURCE "CHKONLY:Cannot evaluate version:\"${VMWEXE}\""
	    fi
	    return ${ABORT}
	fi
    fi

    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "VMware"
#    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "  VMWEXE=${_CALLEXE}"
    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "  VMWEXE=\"${VMWEXE}\""
    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "  VMWMGR=\"${VMWMGR}\""
    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "  _verstrg=${_verstrg}"


    #currently somewhat restrictive to specific versions.
    case ${_verstrg} in
	"VMware Player 1.0."*)
	    VMW_MAGIC=VMW_P105;
	    VMW_PRODVERS="P-$(echo ${_verstrg}|sed 's/^[^0-9]*//;s/ *build//')";
	    VMW_DEFAULTOPTS="";
	    VMW_STATE=ENABLED
	    VMW_SERVER=ENABLED;
            local _buf1="${_verstrg#VMware Player }"
            _buf1="${_buf1% build*}"
            _cap="${_cap}%vmw/player-${_buf1}-`getExecArch /usr/lib/vmware/bin/vmplayer`"
	    ABORT=1;
	    printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "Limited options support, e.g. no \"-g <geometry>\" for:\"${_verstrg}\""
	    _ret=0;
	    ;;

	"VMware Player 2."*)
	    VMW_MAGIC=VMW_P2;
	    VMW_PRODVERS="P-$(echo ${_verstrg}|sed 's/^[^0-9]*//;s/ *build//')";
	    VMW_DEFAULTOPTS="";
	    VMW_STATE=ENABLED
	    VMW_SERVER=ENABLED;
            local _buf1="${_verstrg#VMware Player }"
            _buf1="${_buf1% build*}"
            _cap="${_cap}%vmw/player-${_buf1}-`getExecArch /usr/lib/vmware/bin/vmplayer`"
	    ABORT=1;
	    printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "Limited options support, e.g. no \"-g <geometry>\" for:\"${_verstrg}\""
	    _ret=0;
	    ;;

	"VMware Player 3."*)
	    VMW_MAGIC=VMW_P3;
	    VMW_PRODVERS="P-$(echo ${_verstrg}|sed 's/^[^0-9]*//;s/ *build//')";
	    VMW_DEFAULTOPTS="";
	    VMW_STATE=ENABLED
	    VMW_SERVER=ENABLED;
            local _buf1="${_verstrg#VMware Player }"
            _buf1="${_buf1% build*}"
            _cap="${_cap}%vmw/player-${_buf1}-`getExecArch /usr/lib/vmware/bin/vmplayer`"
	    ABORT=1;
	    printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "Limited options support, e.g. no \"-g <geometry>\" for:\"${_verstrg}\""
	    _ret=0;
	    ;;

	"VMware Server 1.0."*)
	    VMW_MAGIC=VMW_S104;
	    VMW_PRODVERS="S-$(echo ${_verstrg}|sed 's/^[^0-9]*//;s/ *build//')";
	    VMW_STATE=ENABLED
	    VMW_SERVER=ENABLED;
	    VMW_DEFAULTOPTS="-x -q -l";
            local _buf1="${_verstrg#VMware Server }"
            _buf1="${_buf1% build*}"
            _cap="${_cap}%vmw/server-${_buf1}-`getExecArch /usr/lib/vmware/bin/vmware`"
	    _ret=0;

            #check for "register", but is not required mandatory.
            checkedSetSUaccess  "${MYCONFPATH}/vmw/vmw.conf-${MYOS}.sh" VMWCALL VMWMGR -l
	    ;;

	"VMware Server 2.0."*)
	    VMW_MAGIC=VMW_S20;
	    VMW_PRODVERS="S-$(echo ${_verstrg}|sed 's/^[^0-9]*//;s/ *build//')";
	    VMW_STATE=ENABLED
	    VMW_SERVER=ENABLED;
	    VMW_DEFAULTOPTS="-x -q -l";
            local _buf1="${_verstrg#VMware Server }"
            _buf1="${_buf1% build*}"
            _cap="${_cap}%vmw/server-${_buf1}-`getExecArch /usr/bin/vmware`"
	    _ret=0;

            #switch to VMRUN
	    VMWMGR=`getPathName $LINENO $BASH_SOURCE ERROR vmrun /usr/bin`
	    if [ $? -eq 0 ];then
		VMWMGR="${VMWMGR} -T server -h ${CTYS_VMW_S2_ACCESS_HOST} "
                #check for "register", but is not required mandatory.
		checkedSetSUaccess  "${MYCONFPATH}/vmw/vmw.conf-${MYOS}.sh" VMWCALL VMWMGR -l
		. ${MYLIBPATH}/lib/libVMWserver2.sh
	    else
		VMW_STATE=DISABLED
		VMW_SERVER=;
		printERR $LINENO $BASH_SOURCE ${ABORT} "Missing vmrun for detected Server Version-2.x"
	    fi
	    ;;

	"VMware Remote Console Plug-in 2."*)
	    VMW_MAGIC=VMW_S20;
	    VMW_PRODVERS="S-$(echo ${_verstrg}|sed 's/^[^0-9]*//;s/ *build//')";
	    VMW_STATE=ENABLED
	    VMW_DEFAULTOPTS="-x -q -l";
            local _buf1="${_verstrg// /_}"
            _buf1="${_buf1% build*}"
	    _ret=0;

            #switch to VMRUN
	    VMWMGR=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vmrun /usr/bin`
	    if [ $? -eq 0 ];then
		VMWMGR="${VMWMGR} -T server -h ${CTYS_VMW_S2_ACCESS_HOST} "
                #check for "register", but is not required mandatory.
		checkedSetSUaccess  "${MYCONFPATH}/vmw/vmw.conf-${MYOS}.sh" VMWCALL VMWMGR -l

		. ${MYLIBPATH}/lib/libVMWserver2.sh
	    else
		if [ "$C_EXECLOCAL" != 1 ];then
		    VMW_STATE=ENABLED
		    VMW_MAGIC=VMW_RC;
		    _cap="${_cap} ${_buf1}"

		    printWNG 2 $LINENO $BASH_SOURCE 0 "'Remote Console' plugin is present without Server installation."
		    printWNG 2 $LINENO $BASH_SOURCE 0 "For now console is supported in DISPLAYFORWARDING only."
		else
		    VMW_STATE=DISABLED
		    VMW_MAGIC=VMW_RC;
		    _cap="${_cap} ${_buf1}"

		    printWNG 2 $LINENO $BASH_SOURCE 0 "'Remote Console' plugin is present without Server installation."
		    printWNG 2 $LINENO $BASH_SOURCE 0 "For now console is supported in DISPLAYFORWARDING only."

		fi
	    fi
	    ;;

	"VMware Workstation 6"*)
	    VMW_MAGIC=VMW_WS6;
	    VMW_PRODVERS="W-$(echo ${_verstrg}|sed 's/^[^0-9]*//;s/ *build//')";
	    VMW_STATE=ENABLED
	    VMW_SERVER=ENABLED;
	    VMW_DEFAULTOPTS="-x -q -n";
            local _buf1="${_verstrg#VMware Workstation }"
            _buf1="${_buf1% build*}"
            _cap="${_cap}%vmw/workstation-${_buf1}-`getExecArch /usr/lib/vmware/bin/vmware`"
            VMW_PREREQ="${VMW_PREREQ} vmware,vncviewer"
	    _ret=0;
	    ;;

	"VMware Workstation 7"*)
	    VMW_MAGIC=VMW_WS7;
	    VMW_PRODVERS="W-$(echo ${_verstrg}|sed 's/^[^0-9]*//;s/ *build//')";
	    VMW_STATE=ENABLED
	    VMW_SERVER=ENABLED;
	    VMW_DEFAULTOPTS="-x -q -n";
            local _buf1="${_verstrg#VMware Workstation }"
            _buf1="${_buf1% build*}"
            _cap="${_cap}%vmw/workstation-${_buf1}-`getExecArch /usr/lib/vmware/bin/vmware`"
            VMW_PREREQ="${VMW_PREREQ} vmware,vncviewer"
	    _ret=0;
	    ;;

        *)
	    printWNG 2 $LINENO $BASH_SOURCE 0 "Unsupported or misconfigured local version:"
	    printWNG 2 $LINENO $BASH_SOURCE 0 "  ctys    :<${VERSION}>"
	    printWNG 2 $LINENO $BASH_SOURCE 0 "  VMW     :<${_myPKGVERS_VMW}>"
	    printWNG 2 $LINENO $BASH_SOURCE 0 "  Product :<${_verstrg}>"
	    printWNG 2 $LINENO $BASH_SOURCE 0 "."
	    printWNG 2 $LINENO $BASH_SOURCE 0 "Remaining options:"
	    printWNG 2 $LINENO $BASH_SOURCE 0 "->remote: \"-L DISPLAYFORWARDING\""
	    printWNG 2 $LINENO $BASH_SOURCE 0 "->remote: \"-L SERVERONLY\"(partial...)"
	    printWNG 2 $LINENO $BASH_SOURCE 0 "->local:  VNC-client"
	    printWNG 2 $LINENO $BASH_SOURCE 0 "."
	    VMW_MAGIC=NOLOC;
	    _cap="${_cap} <`setStatusColor ${QEMU_STATE} VERSION`:UNKNOWN-VERSION:${_verstrg// /_}>"
	    _ret=2;
	    ;;
    esac
    VMW_PREREQ="${_cap} ${VMW_PREREQ}"
    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "VMW_MAGIC       = ${VMW_MAGIC}"
    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "VMW_STATE       = ${VMW_STATE}"
    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "VMW_VERSTRING   = ${VMW_VERSTRING}"
    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "VMW_PRODVERS    = ${VMW_PRODVERS}"
    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "VMW_PREREQ      = ${VMW_PREREQ}"
    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "VMW_DEFAULTOPTS = ${VMW_DEFAULTOPTS}"
    return $_ret;
}




#FUNCBEG###############################################################
#NAME:
#  clientServerSplitSupportedVMW
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
function clientServerSplitSupportedVMW () {
    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME $1"
    case $1 in
	CREATE)
	    case ${VMW_MAGIC} in
		VMW_S10*)
		    return 0
 		    ;;
		VMW_S20)
		    return 0
 		    ;;
                #VMW_S103|WMW_WS6|VMW_GENERIC)
		*)  #For now seems to be common
		    ABORT=2
		    noClientServerSplitSupportedMessageVMW
		    gotoHell ${ABORT}
 		    ;;
	    esac
	    ;;

	CANCEL)return 0;;
    esac
    return 1;
}



#FUNCBEG###############################################################
#NAME:
#  handleVMW
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
function handleVMW () {
    printDBG $S_VMW ${D_UID} $LINENO $BASH_SOURCE "${FUNCNAME}:$*"
    local OPMODE=$1;shift
    local ACTION=$1;shift

    case ${ACTION} in

	LIST)
	    case ${OPMODE} in
		PROLOGUE)
		    hookPackage "${_myPKGBASE_VMW}/list.sh"
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
		    hookPackage "${_myPKGBASE_VMW}/info.sh"
		    ;;
		EPILOGUE)
		    ;;
		CHECKPARAM)
		    ;;
		ASSEMBLE)
		    ;;
		EXECUTE)
		    hookPackage "${_myPKGBASE_VMW}/list.sh"
		    ;;
	    esac
	    ;;

	ENUMERATE)
	    case ${OPMODE} in
		PROLOGUE)
		    hookPackage "${_myPKGBASE_VMW}/enumerate.sh"
		    ;;
		EPILOGUE)
		    ;;
		CHECKPARAM)
		    ;;
		ASSEMBLE)
		    ;;
		EXECUTE)
		    hookPackage "${_myPKGBASE_VMW}/list.sh"
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
		    hookPackage "${_myPKGBASE_VMW}/create.sh"
		    createConnectVMW ${OPMODE} ${ACTION} 
		    ;;
		ASSEMBLE)
		    hookPackage "${_myPKGBASE_VMW}/create.sh"
		    createConnectVMW ${OPMODE} ${ACTION} 
		    ;;
		EXECUTE)
		    hookPackage "${_myPKGBASE_VMW}/session.sh"
		    hookPackage "${_myPKGBASE_VMW}/list.sh"
		    createConnectVMW ${OPMODE} ${ACTION} 
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
		    hookPackage "${_myPKGBASE_VMW}/cancel.sh"
		    cutCancelSessionVMW ${OPMODE} ${ACTION} 
		    ;;
		ASSEMBLE)
		    hookPackage "${_myPKGBASE_VMW}/cancel.sh"
		    cutCancelSessionVMW ${OPMODE} ${ACTION} 
		    ;;
		EXECUTE)
		    hookPackage "${_myPKGBASE_VMW}/session.sh"
		    hookPackage "${_myPKGBASE_VMW}/list.sh"
		    cutCancelSessionVMW ${OPMODE} ${ACTION} 
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
			printDBG $S_VMW ${D_UID} $LINENO $BASH_SOURCE "C_MODE_ARGS=$C_MODE_ARGS"
			_C_GETCLIENTPORT=$C_MODE_ARGS
		    else
			ABORT=1
			printERR $LINENO $BASH_SOURCE ${ABORT} "Missing <session-label>|<session-id>"
			gotoHell ${ABORT}
		    fi
                    ;;

		EXECUTE)
		    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "Remote command:OPTARG=${OPTARG}"
		    case $VMW_MAGIC in
			VMW_P*)
  			    echo ""
			    ABORT=1
			    printERR $LINENO $BASH_SOURCE ${ABORT} "Current version of VMware Player does not support remote consoles."
			    printERR $LINENO $BASH_SOURCE ${ABORT} "  Version:${VMW_VERSTRING}"
			    gotoHell ${ABORT}
			    ;;
			VMW_S1*)
			    ;;
			VMW_S2*)
			    ;;
			VMW_WS6)
			    ;;
			VMW_WS7)
			    ;;
			*)
  			    echo ""
			    ABORT=1
			    printERR $LINENO $BASH_SOURCE ${ABORT} "Unknown version, reject remote console."
			    printERR $LINENO $BASH_SOURCE ${ABORT} "  Version:${VMW_VERSTRING}"
			    gotoHell ${ABORT}
			    ;;
		    esac
  		    echo "CLIENTPORT(VMW,${MYHOST},${_C_GETCLIENTPORT})=`getClientTPVMW ${_C_GETCLIENTPORT//,/ }`"
		    gotoHell 0
		    ;;

 		ASSEMBLE)
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
			printDBG $S_VMW ${D_UID} $LINENO $BASH_SOURCE "C_MODE_ARGS=$C_MODE_ARGS"
			_MYID=$C_MODE_ARGS
		    else
			ABORT=1
			printERR $LINENO $BASH_SOURCE ${ABORT} "Missing <session-id>"
			gotoHell ${ABORT}
		    fi
                    ;;

		EXECUTE)
		    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "Remote command:OPTARG=${OPTARG}"
		    case $VMW_MAGIC in
			VMW_P1*)
			    ;;
			VMW_P2*)
			    ;;
			VMW_P3*)
			    ;;
			VMW_S1*)
			    ;;
			VMW_S2*)
			    ;;
			VMW_WS6)
			    ;;
			VMW_WS7)
			    ;;
			*)
  			    echo ""
			    ABORT=1
			    printERR $LINENO $BASH_SOURCE ${ABORT} "Unknown version, reject remote console."
			    printERR $LINENO $BASH_SOURCE ${ABORT} "  Version:${VMW_VERSTRING}"
			    gotoHell ${ABORT}
			    ;;
		    esac
 		    echo "ISACTIVE(VMW,${C_MODE_ARGS})=`isActiveVMW ${C_MODE_ARGS}`"
		    gotoHell 0
		    ;;

 		ASSEMBLE)
 		    ;;
            esac
	    ;;

	*)
            ABORT=1;
            printERR $LINENO $BASH_SOURCE ${ABORT} "System Error, unexpected VMW:OPMODE=${OPMODE} ACTION=${ACTION}"
	    gotoHell ${ABORT}
            ;;
    esac
}



#FUNCBEG###############################################################
#NAME:
#  initVMW
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
function initVMW () {
    local _curInit=$1;shift
    local _initConsequences=$1
    local ret=0;

    local _raise=$((INITSTATE<_curInit));

    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:${INITSTATE} -> ${_curInit} - ${_raise}"

    if [ "$_raise" == "1" ];then
      #for raise of INITSTATE do not touch the OS's decisions, just expand.

	case $_curInit in
	    0);;#NOP - Done by shell
	    1)  
              #adjust version specifics  
		setVersionVMW $_initConsequences
		ret=$?

              #add own help to searchlist for options
		MYOPTSFILES="${MYOPTSFILES} ${MYHELPPATH}/010_vmw"
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
