#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@users.sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_007
#
########################################################################
#
# Copyright (C) 2007,2008,2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

#PM generic default parameters, will be reset in setVersionPM
PM_MAGIC=PM_GENERIC
PM_VERSTRING=;
PM_STATE=DISABLED
PM_DEFAULTOPTS=;
PM_PREREQ=;
PM_PRODVERS=;
PM_ACCELERATOR=;

PM_SERVER=ENABLED;

PM_VMSTACK=01.11.007;
PM_WOLSUPPORT=0;

_myPKGNAME_PM="${BASH_SOURCE}"
_myPKGVERS_PM="01.10.008"
hookInfoAdd $_myPKGNAME_PM $_myPKGVERS_PM

_myPKGBASE_PM="`dirname ${_myPKGNAME_PM}`"


PM_CAPABILITY="PM-CAPABILITY:PM-${_myPKGVERS_PM}-${MYARCH}"

#Exe-File(common for client and server): vmplayer or vmware
_CALLEXE=;

if [ -d "${HOME}/.ctys" -a -d "${HOME}/.ctys/pm" ];then
    #Source pre-set environment from user
    if [ -f "${HOME}/.ctys/pm/pm.conf-${MYOS}.sh" ];then
	. "${HOME}/.ctys/pm/pm.conf-${MYOS}.sh"
    fi
fi

if [ -d "${MYCONFPATH}/pm" ];then
    #Source pre-set environment from installation 
    if [ -f "${MYCONFPATH}/pm/pm.conf-${MYOS}.sh" ];then
	. "${MYCONFPATH}/pm/pm.conf-${MYOS}.sh"
    fi
fi


_waitcPM=${PM_INIT_WAITC:-2}
_waitsPM=${PM_INIT_WAITS:-2}



_pingPM=1;
_pingcntPM=${CTYS_PING_ONE_MAXTRIAL_PM:-20};
_pingsleepPM=${CTYS_PING_ONE_WAIT_PM:-2};

_sshpingPM=1;
_sshpingcntPM=${CTYS_SSHPING_ONE_MAXTRIAL_PM:-20};
_sshpingsleepPM=${CTYS_SSHPING_ONE_WAIT_PM:-2};
_actionuserPM="${MYUID}";



#for later reset, once relevant parameters different from default are been detected
export CTYS_WOL_RAW="${CTYS_WOL_RAW:-$CTYS_WOL}"
export CTYS_WOL_LOCAL_RAW="${CTYS_WOL_LOCAL_RAW:-$CTYS_WOL_LOCAL}"
export CTYS_WOL_LOCAL_WAKEUP_RAW="${CTYS_WOL_LOCAL_WAKEUP_RAW:-$CTYS_WOL_LOCAL_WAKEUP}"
export CTYS_ETHTOOL_RAW="${CTYS_ETHTOOL_RAW:-$CTYS_ETHTOOL}"
export CTYS_ETHTOOL_WOL_RAW="${CTYS_ETHTOOL_WOL_RAW:-$CTYS_ETHTOOL_WOL}"

printDBG $S_PM ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:CTYS_WOL_RAW=${CTYS_WOL_RAW}"
printDBG $S_PM ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:CTYS_WOL_LOCAL_RAW=${CTYS_WOL_LOCAL_RAW}"
printDBG $S_PM ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:CTYS_WOL_LOCAL_WAKEUP_RAW=${CTYS_WOL_LOCAL_WAKEUP_RAW}"
printDBG $S_PM ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:CTYS_ETHTOOL_RAW=${CTYS_ETHTOOL_RAW}"
printDBG $S_PM ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:CTYS_ETHTOOL_WOL_RAW=${CTYS_ETHTOOL_WOL_RAW}"



. ${MYLIBPATH}/lib/libPMbase.sh



#FUNCBEG###############################################################
#NAME:
#  pmGetACCELERATOR
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Returns type of harware accelerator.
#
#   - VMX (Intel)
#   - SVN (AMD)
#   - PAE (EXTMEM only)
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
function pmGetACCELERATOR () {
    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME $1"
    local _a=;
    case $MYOS in
	Linux)
	    cat /proc/cpuinfo|\
            sed -n 's/\t//g;s/^\([^[:space:]]*[[:space:]]\{0,2\}[^[:space:]]*\)[[:space:]]*: *\(.*\)$/\1:\2/gp'|\
            awk -F':' '
              $2~/vmx/ {fVMX=1;}
              $2~/svm/ {fSVN=1;}
              $2~/pae/ {fPAE=1;}
              END{
                if(fVMX==1){printf("VMX");}
                else if(fSVN==1){printf("SVN");}
                else if(fPAE=1){printf("PAE");}
              }
              '
	    ;;
    esac
}




#FUNCBEG###############################################################
#NAME:
#  serverRequirePM
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
function serverRequirePM () {
    printDBG $S_PM ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME \$@=$@"
    local _CS_SPLIT=`echo ${*}|sed -n 's/CONNECTIONFORWARDING/SERVERONLY/p'`;
    local _S=`getSessionType ${*}`;_S=${_S:-$C_SESSIONTYPE};
    local _A=`getActionResulting ${*}`;
    local _ret=1;
    local _res=;

    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "_CS_SPLIT=\"${_CS_SPLIT}\""
    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "_S=\"${_S}\""
    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "_A=\"${_A}\""


    #if split not supported server only could be used
    if [ -n "${_CS_SPLIT}" ];then
        #check for consoles, gwhich are one decisive for component location
	local _myConsole=;
	[ "${*}" != "${*//:[cC][lL][iI]}" ]&&_myConsole=CLI
	[ "${*}" != "${*//:[gG][tT][eE][rR][mM]}" ]&&_myConsole=GTERM
	[ "${*}" != "${*//:[xX][tT][eE][rR][mM]}" ]&&_myConsole=XTERM
	[ "${*}" != "${*//:[vV][nN][cC]}" ]&&_myConsole=VNC

	case $_A in 
 	    CONNECT)
		case $_myConsole in
		    CLI|GTERM|XTERM)
			ABORT=1;
			printERR $LINENO $BASH_SOURCE ${ABORT} "The console type $_myConsole for $_A cannot be combined with"
			printERR $LINENO $BASH_SOURCE ${ABORT} "option: -L CONNECTIONFORWARDING"
			gotoHell ${ABORT}
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
		ABORT=1;
		printERR $LINENO $BASH_SOURCE ${ABORT} "The console type $_myConsole for $_A cannot be combined with"
		printERR $LINENO $BASH_SOURCE ${ABORT} "option: -L CONNECTIONFORWARDING"
		gotoHell ${ABORT}
		;;
	esac
    else
 	_res="${*}";_ret=0;
    fi

    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_res=\"${_res}\""
    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_ret=\"${_ret}\""
    echo -n "${_res}";
    return ${_ret};  
}



#FUNCBEG###############################################################
#NAME:
#  clientRequirePM
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
function clientRequirePM () {
    printDBG $S_PM ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME \$@=$@"
    local _CS_SPLIT=`echo ${*}|sed -n 's/CONNECTIONFORWARDING/1/p;s/LOCALONLY/1/p;s/CLIENTONLY/1/p'`;
    local _S=`getSessionType ${*}`;_S=${_S:-$C_SESSIONTYPE};
    local _A=`getActionResulting ${*}`;
    local _ret=1;
    local _res=;

    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "_CS_SPLIT=\"${_CS_SPLIT}\""
    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "_S=\"${_S}\""
    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "_A=\"${_A}\""

    #if split not supported server only could be used
    if [ -n "${_CS_SPLIT}" ];then
        #check for consoles, gwhich are one decisive for component location
	local _myConsole=;
	[ "${*}" != "${*//:[cC][lL][iI]}" ]&&_myConsole=CLI
	[ "${*}" != "${*//:[gG][tT][eE][rR][mM]}" ]&&_myConsole=GTERM
	[ "${*}" != "${*//:[xX][tT][eE][rR][mM]}" ]&&_myConsole=XTERM
	[ "${*}" != "${*//:[vV][nN][cC]}" ]&&_myConsole=VNC

	case $_A in 
 	    CONNECT)
		case $_myConsole in
		    CLI|GTERM|XTERM)
			ABORT=1;
			printERR $LINENO $BASH_SOURCE ${ABORT} "The console type $_myConsole for $_A cannot be combined with"
			printERR $LINENO $BASH_SOURCE ${ABORT} "option: -L CONNECTIONFORWARDING"
			gotoHell ${ABORT}
			;;
		    VNC)
			_res=${*};_ret=0;
			;;
		    *)
			printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:Assume true:$_myConsole for $_A "
			_res=${*};_ret=0;
			;;
		esac
		;;
 	    CREATE)  
		ABORT=1;
		printERR $LINENO $BASH_SOURCE ${ABORT} "The console type $_myConsole for $_A cannot be combined with"
		printERR $LINENO $BASH_SOURCE ${ABORT} "option: -L CONNECTIONFORWARDING"
		gotoHell ${ABORT}
		;;
	esac
    else
 	_res=;_ret=1;
    fi

    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_res=\"${_res}\""
    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_ret=\"${_ret}\""
    echo -n "${_res}";
    return ${_ret};  
}



function checkSyscallsLinuxWoL () {
    CTYS_WOL="${CTYS_WOL_RAW}"
    CTYS_WOL_LOCAL="${CTYS_WOL_LOCAL_RAW}"
    CTYS_WOL_LOCAL_WAKEUP="${CTYS_WOL_LOCAL_WAKEUP_RAW}"
    CTYS_ETHTOOL="${CTYS_ETHTOOL_RAW}"
    CTYS_ETHTOOL_WOL="${CTYS_ETHTOOL_WOL_RAW}"

    PMCALL=;
    CTYS_WOL="$PMCALL $CTYS_WOL"
    PM_WOLSUPPORT="2-${PM_WOLSUPPORT}";
    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME CTYS_WOL=$CTYS_WOL"
    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME CTYS_WOL_WAKEUP=$CTYS_WOL_WAKEUP"
    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME CTYS_ETHTOOL=$CTYS_ETHTOOL"
    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME CTYS_ETHTOOL_WOLIF=$CTYS_ETHTOOL_WOLIF"


    #temporary - will be replaced later
    PMCALL=;
    if [ -n "${CTYS_WOL_LOCAL}" ];then
	checkedSetSUaccess  "${_myHint}" PMCALL   CTYS_WOL_LOCAL  -i lo 11:22:33:44:55:66
	if [ $? -eq 0 ];then
	    CTYS_WOL_LOCAL="$PMCALL $CTYS_WOL_LOCAL"
	    PM_WOLSUPPORT="3-${PM_WOLSUPPORT}";
	else
	    CTYS_WOL_LOCAL="printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:Missing exec permission for:$PMCALL $CTYS_WOL_LOCAL\";"
	    CTYS_WOL_LOCAL="${CTYS_WOL_LOCAL}printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:Check '-z KSU,SUDO'\";"
	    CTYS_WOL_LOCAL="${CTYS_WOL_LOCAL}printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:Permissions are passed through,\";"
	    CTYS_WOL_LOCAL="${CTYS_WOL_LOCAL}printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:thus have to be equal for the whole stack\";"
	    CTYS_WOL_LOCAL="gotoHell 1;"
	fi
    else
	CTYS_WOL_LOCAL="printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:Missing content for CTYS_WOL_LOCAL\";gotoHell 1;"
    fi
    CTYS_WOL_LOCAL_WAKEUP="$CTYS_WOL_LOCAL"
    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME CTYS_WOL_LOCAL=$CTYS_WOL_LOCAL"
    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME CTYS_WOL_LOCAL_WAKEUP=$CTYS_WOL_LOCAL_WAKEUP"


    PMCALL=;
    local _check0=99;
    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:CTYS_ETHTOOL=$CTYS_ETHTOOL access:"
    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:CHECK0:CTYS_ETHTOOL_WOLIF=${CTYS_ETHTOOL_WOLIF}"
    if [ -n "${CTYS_ETHTOOL}" ];then
	CTYS_ETHTOOL1=$CTYS_ETHTOOL
	checkedSetSUaccess  "${_myHint}" PMCALL   CTYS_ETHTOOL1   -S ${CTYS_ETHTOOL_WOLIF}>/dev/null
	_check0=$?;
	if [ $_check0 -eq 97 ];then
            #assume to be a standard Xen p-if
	    CTYS_ETHTOOL1=$CTYS_ETHTOOL
	    checkedSetSUaccess  "${_myHint}" PMCALL   CTYS_ETHTOOL1   -S p${CTYS_ETHTOOL_WOLIF}${CTYS_ETHTOOL_WOLIF}>/dev/null
	    _check0=$?;
	fi
    else
	CTYS_ETHTOOL="printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:Missing content for CTYS_ETHTOOL\";gotoHell 1;"
    fi

    #if still not works, provide the raw system name of physical IF explicitly with the call.
    #remapping with individual schemas is not supported.
    #bridge-interfaces are supported as
    #
    #   1. renamed in Xen style.
    #   2. name is natively set as member
    #
    if [ $_check0 -eq 0 ];then
	if [ "`stackerGetMyLevel`" == "0" ];then
	    CTYS_ETHTOOL="$PMCALL $CTYS_ETHTOOL1"
	    PM_WOLSUPPORT="4-${PM_WOLSUPPORT}";
	fi
    else
	if [ $_check0 -eq 99 ];then
	    CTYS_ETHTOOL="printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:Missing CTYS_ETHTOOL\";gotoHell 1;"
	else
	    if [ $_check0 -eq 97 ];then
		CTYS_ETHTOOL="printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:Missing exec permission for:$PMCALL $CTYS_ETHTOOL\";"
		CTYS_ETHTOOL="${CTYS_ETHTOOL}printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:Check '-z KSU,SUDO'\";"
		CTYS_ETHTOOL="${CTYS_ETHTOOL}printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:Permissions are passed through,\";"
		CTYS_ETHTOOL="${CTYS_ETHTOOL}printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:thus have to be equal for the whole stack\";"
		if [ "${USE_SUDO}" == 1 ];then
		    CTYS_ETHTOOL="${CTYS_ETHTOOL}printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:Check the 'requiretty' attribute of sudoers\";"
		    CTYS_ETHTOOL="${CTYS_ETHTOOL}printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:alterntively set '-z 2'\";"
		fi
		CTYS_ETHTOOL="${CTYS_ETHTOOL}gotoHell 1;"
	    else
		CTYS_ETHTOOL="printWNG 1 $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:CHECK-Operation not supported by CTYS_ETHTOOL\";"
		CTYS_ETHTOOL="${CTYS_ETHTOOL}printWNG 1 $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:but permission available\";"
		CTYS_ETHTOOL="${CTYS_ETHTOOL}$PMCALL $CTYS_ETHTOOL1"
		PM_WOLSUPPORT="4-${PM_WOLSUPPORT}";
	    fi
	fi
    fi
    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME CTYS_ETHTOOL=$CTYS_ETHTOOL"

    CTYS_ETHTOOL_WOL="$PMCALL $CTYS_ETHTOOL_WOL"
    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME CTYS_ETHTOOL_WOL=$CTYS_ETHTOOL_WOL"

    if [ $_check0 -eq 0 ];then
        #for additional
	local _woli=0;
	local _xwoli=;
	for((_woli=0;_woli<10;_woli++));do
	    eval _xwoli="\"\$CTYS_ETHTOOL_WOL$_woli\""
	    if [ -n "$_xwoli" ];then
		_xwoli="$PMCALL $_xwoli"
		eval CTYS_ETHTOOL_WOL$_woli=\"$_xwoli\"
		printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME CTYS_ETHTOOL_WOL$_woli=$_xwoli"
	    fi
	done
    fi
}

function checkSyscallsLinux () {
    PMCALL=;
    checkedSetSUaccess  "${_myHint}" PMCALL   CTYS_HALT      -w
    if [ $? -eq 0 ];then
 	CTYS_HALT="$PMCALL $CTYS_HALT"
    else
	CTYS_HALT="printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:Missing exec permission for:$PMCALL $CTYS_HALT\";"
	CTYS_HALT="${CTYS_HALT}printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:Check '-z KSU,SUDO'\";"
	CTYS_HALT="${CTYS_HALT}printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:Permissions are passed through,\";"
	CTYS_HALT="${CTYS_HALT}printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:thus have to be equal for the whole stack\";"
	CTYS_HALT="${CTYS_HALT}gotoHell 1;"
    fi
    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME CTYS_HALT=$CTYS_HALT"

    PMCALL=;
    checkedSetSUaccess  "${_myHint}" PMCALL   CTYS_REBOOT    -w
    if [ $? -eq 0 ];then
	CTYS_REBOOT="$PMCALL $CTYS_REBOOT"
    else
	CTYS_REBOOT="printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:Missing exec permission for:$CTYS_REBOOT\";"
	CTYS_REBOOT="${CTYS_REBOOT}printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:Check '-z KSU,SUDO'\";"
	CTYS_REBOOT="${CTYS_REBOOT}printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:Permissions are passed through,\";"
	CTYS_REBOOT="${CTYS_REBOOT}printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:thus have to be equal for the whole stack\";"
	CTYS_REBOOT="${CTYS_REBOOT}gotoHell 1;"
    fi
    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME CTYS_REBOOT=$CTYS_REBOOT"

    PMCALL=;
    checkedSetSUaccess  "${_myHint}" PMCALL   CTYS_POWEROFF  -w
    if [ $? -eq 0 ];then
	CTYS_POWEROFF="$PMCALL $CTYS_POWEROFF"
    else
	CTYS_POWEROFF="printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:Missing exec permission for:$PMCALL $CTYS_POWEROFF\";"
	CTYS_POWEROFF="${CTYS_POWEROFF}printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:Check '-z KSU,SUDO'\";"
	CTYS_POWEROFF="${CTYS_POWEROFF}printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:Permissions are passed through,\";"
	CTYS_POWEROFF="${CTYS_POWEROFF}printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:thus have to be equal for the whole stack\";"
	CTYS_POWEROFF="${CTYS_POWEROFF}gotoHell 1;"
    fi
    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME CTYS_POWEROFF=$CTYS_POWEROFF"

    PM_WOLSUPPORT="1-${PM_WOLSUPPORT}";
    PMCALL=;
    local _myRunLevel=`who -a |awk '/run-level/{print $2;}'`
    if [ "${_myRunLevel##[35]}" != "$_myRunLevel" ];then
	checkedSetSUaccess  "${_myHint}" PMCALL   CTYS_INIT  $_myRunLevel
	if [ $? -eq 0 ];then
	    CTYS_INIT="$PMCALL $CTYS_INIT"
	else
	    CTYS_INIT="printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:Missing exec permission for:$PMCALL $CTYS_INIT\";"
	    CTYS_INIT="${CTYS_INIT}printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:Check '-z KSU,SUDO'\";"
	    CTYS_INIT="${CTYS_INIT}printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:Permissions are passed through,\";"
	    CTYS_INIT="${CTYS_INIT}printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:thus have to be equal for the whole stack\";"
	    CTYS_INIT="${CTYS_INIT}gotoHell 1;"
	fi
    else
	CTYS_INIT="printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:Missing exec permission for:$PMCALL $CTYS_INIT\";"
	CTYS_INIT="${CTYS_INIT}printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:Check '-z KSU,SUDO'\";"
	CTYS_INIT="${CTYS_INIT}printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:Permissions are passed through,\";"
	CTYS_INIT="${CTYS_INIT}printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:thus have to be equal for the whole stack\";"
	CTYS_INIT="${CTYS_INIT}gotoHell 1;"
    fi
    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME CTYS_INIT=$CTYS_INIT"
}

function checkSyscallsOpenBSD () {
    PMCALL=;
    setSUaccess  "${_myHint}" PMCALL   CTYS_HALT    
    if [ $? -eq 0 ];then
	CTYS_HALT="$PMCALL $CTYS_HALT"
    else
	CTYS_HALT="printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:Missing exec permission for:$PMCALL $CTYS_HALT\";"
	CTYS_HALT="${CTYS_HALT}printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:Check '-z KSU,SUDO'\";"
	CTYS_HALT="${CTYS_HALT}printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:Permissions are passed through,\";"
	CTYS_HALT="${CTYS_HALT}printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:thus have to be equal for the whole stack\";"
	CTYS_HALT="${CTYS_HALT}gotoHell 1;"
    fi
    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME CTYS_HALT=$CTYS_HALT"

    PMCALL=;
    setSUaccess  "${_myHint}" PMCALL   CTYS_REBOOT  
    if [ $? -eq 0 ];then
	CTYS_REBOOT="$PMCALL $CTYS_REBOOT"
    else
	CTYS_REBOOT="printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:Missing exec permission for:$CTYS_REBOOT\";"
	CTYS_REBOOT="${CTYS_REBOOT}printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:Check '-z KSU,SUDO'\";"
	CTYS_REBOOT="${CTYS_REBOOT}printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:Permissions are passed through,\";"
	CTYS_REBOOT="${CTYS_REBOOT}printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:thus have to be equal for the whole stack\";"
	CTYS_REBOOT="${CTYS_REBOOT}gotoHell 1;"
    fi
    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME CTYS_REBOOT=$CTYS_REBOOT"

    PMCALL=;
    setSUaccess  "${_myHint}" PMCALL   CTYS_POWEROFF
    if [ $? -eq 0 ];then
	CTYS_POWEROFF="$PMCALL $CTYS_POWEROFF"
    else
	CTYS_POWEROFF="printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:Missing exec permission for:$PMCALL $CTYS_POWEROFF\";"
	CTYS_POWEROFF="${CTYS_POWEROFF}printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:Check '-z KSU,SUDO'\";"
	CTYS_POWEROFF="${CTYS_POWEROFF}printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:Permissions are passed through,\";"
	CTYS_POWEROFF="${CTYS_POWEROFF}printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:thus have to be equal for the whole stack\";"
	CTYS_POWEROFF="${CTYS_POWEROFF}gotoHell 1;"
    fi
    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME CTYS_POWEROFF=$CTYS_POWEROFF"

    PMCALL=;
    setSUaccess  "${_myHint}" PMCALL   CTYS_INIT
    if [ $? -eq 0 ];then
	CTYS_INIT="$PMCALL $CTYS_INIT"
    else
	CTYS_INIT="printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:Missing exec permission for:$PMCALL $CTYS_INIT\";"
	CTYS_INIT="${CTYS_INIT}printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:Check '-z KSU,SUDO'\";"
	CTYS_INIT="${CTYS_INIT}printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:Permissions are passed through,\";"
	CTYS_INIT="${CTYS_INIT}printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:thus have to be equal for the whole stack\";"
	CTYS_INIT="${CTYS_INIT}gotoHell 1;"
    fi
    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME CTYS_INIT=$CTYS_INIT"
}


function checkSyscallsSunOS () {
    PMCALL=;
    setSUaccess  "${_myHint}" PMCALL   CTYS_HALT    
    if [ $? -eq 0 ];then
	CTYS_HALT="$PMCALL $CTYS_HALT"
    else
	CTYS_HALT="printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:Missing exec permission for:$PMCALL $CTYS_HALT\";"
	CTYS_HALT="${CTYS_HALT}printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:Check '-z KSU,SUDO'\";"
	CTYS_HALT="${CTYS_HALT}printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:Permissions are passed through,\";"
	CTYS_HALT="${CTYS_HALT}printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:thus have to be equal for the whole stack\";"
	CTYS_HALT="${CTYS_HALT}gotoHell 1;"
    fi
    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME CTYS_HALT=$CTYS_HALT"

    PMCALL=;
    setSUaccess  "${_myHint}" PMCALL   CTYS_REBOOT  
    if [ $? -eq 0 ];then
	CTYS_REBOOT="$PMCALL $CTYS_REBOOT"
    else
	CTYS_REBOOT="printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:Missing exec permission for:$PMCALL $CTYS_REBOOT\";"
	CTYS_REBOOT="${CTYS_REBOOT}printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:Check '-z KSU,SUDO'\";"
	CTYS_REBOOT="${CTYS_REBOOT}printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:Permissions are passed through,\";"
	CTYS_REBOOT="${CTYS_REBOOT}printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:thus have to be equal for the whole stack\";"
	CTYS_REBOOT="${CTYS_REBOOT}gotoHell 1;"
    fi
    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME CTYS_REBOOT=$CTYS_REBOOT"

    PMCALL=;
    setSUaccess  "${_myHint}" PMCALL   CTYS_POWEROFF
    if [ $? -eq 0 ];then
	CTYS_POWEROFF="$PMCALL $CTYS_POWEROFF"
    else
	CTYS_POWEROFF="printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:Missing exec permission for:$PMCALL $CTYS_POWEROFF\";"
	CTYS_POWEROFF="${CTYS_POWEROFF}printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:Check '-z KSU,SUDO'\";"
	CTYS_POWEROFF="${CTYS_POWEROFF}printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:Permissions are passed through,\";"
	CTYS_POWEROFF="${CTYS_POWEROFF}printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:thus have to be equal for the whole stack\";"
	CTYS_POWEROFF="${CTYS_POWEROFF}gotoHell 1;"
    fi
    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME CTYS_POWEROFF=$CTYS_POWEROFF"

    PMCALL=;
    setSUaccess  "${_myHint}" PMCALL   CTYS_INIT
    if [ $? -eq 0 ];then
	CTYS_INIT="$PMCALL $CTYS_INIT"
    else
	CTYS_INIT="printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:Missing exec permission for:$PMCALL $CTYS_INIT\";"
	CTYS_INIT="${CTYS_INIT}printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:Check '-z KSU,SUDO'\";"
	CTYS_INIT="${CTYS_INIT}printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:Permissions are passed through,\";"
	CTYS_INIT="${CTYS_INIT}printERR $LINENO $BASH_SOURCE 1 \"$FUNCNAME:DELAYED-OUT:thus have to be equal for the whole stack\";"
	CTYS_INIT="${CTYS_INIT}gotoHell 1;"
    fi
    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME CTYS_INIT=$CTYS_INIT"
}



#FUNCBEG###############################################################
#NAME:
#  setVersionPM
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Sets the version of the OS on top of PM, gwhich is in this case PM.
#  It will be tried to stay generic as long as possible, probably by support
#  of some minor "ifdef"-style.
#
#  Anyhow, the preferred PM platform is CentOS, mainly 5+, but 4.4+ 
#  will be supported too. RHEL should work too, is a sympathic target too,
#  of course.
#
#  OpenSuSE, and some legacy versions are in the range, because of using
#  SuSE PM almost from the first days on(since about 1992-93?, version 0.?).
#
#EXAMPLE:
#
#PARAMETERS:
#
#
#OUTPUT:
#  GLOBALS:
#
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function setVersionPM () {
    local _checkonly=;
    local _ret=0;
    if [ "$1" == "NOEXIT" ];then
	local _checkonly=1;        
    fi

    #setup callee for executables requiring root-permission 
    #
    #YES, the passed options for permissions-check without "actual severe action"
    #are found by trial-and-error.
    #These may alter on different platforms.
    #
    local _myHint="${MYCONFPATH}/pm/pm.conf-${MYOS}.sh"


    local _PMCONF=/etc/ctys.d/pm.conf
    if [ ! -f "${_PMCONF}" ];then
	_PMCONF=;
    fi

    local _VMCONF=/etc/ctys.d/vm.conf
    if [ ! -f "${_VMCONF}" ];then
	_VMCONF=;
    fi

    if [ -n "${_PMCONF}" -a -n "${_VMCONF}" ];then
        ABORT=1;
	printERR $LINENO $BASH_SOURCE ${ABORT} "Ambiguous definition, only one could be active:"
	printERR $LINENO $BASH_SOURCE ${ABORT} " VMCONF = ${_VMCONF}"
	printERR $LINENO $BASH_SOURCE ${ABORT} " PMCONF = ${_PMCONF}"
	gotoHell ${ABORT}
    fi

    if [ -n "${_PMCONF}" ];then
	PM_PREREQ="${PM_PREREQ} PMCONF=\"${_PMCONF}\"-assume-bottom-PM";
    else
	if [ -n "${_VMCONF}" ];then
	    PM_PREREQ="${PM_PREREQ} VMCONF=\"${_VMCONF}\"-assume-upper-stack-PM=>VM";
	    _myLvl=`stackerGetMyLevel`;
	    if [ -n "$_myLvl" ];then
		PM_PREREQ="${PM_PREREQ} STACKLEVEL=${_myLvl}";
	    fi
	else
	    PM_PREREQ="${PM_PREREQ} <`setSeverityColor WNG MISSING`:PMCONF-AND-VMCONF=>call:ctys-genmconf.sh-assume-bottom-PM>"
	fi
    fi


    if [ -n "${C_EXECLOCAL}" ];then
	case ${MYOS} in
	    Linux)checkSyscallsLinux;checkSyscallsLinuxWoL;;
	    FreeBSD|OpenBSD)checkSyscallsOpenBSD;;
	    SunOS)checkSyscallsSunOS;;
	    *)
		PM_MAGIC=NO_LOC
		ABORT=1
		if [ "${C_SESSIONTYPE}" == "PM" -a -z "${_checkonly}" ];then
		    gotoHell ${ABORT}
		else
		    return ${ABORT}
		fi
		;;
	esac
    fi

    local _buf1=;
    for i in ${PM_WOLSUPPORT//-/ };do
	case $i in
	    1) _buf1="${_buf1}-WoLCall";;
	    2) _buf1="${_buf1}-WoLLocal";;
	    3) _buf1="${_buf1}-WoLRemote";;
	    4) _buf1="${_buf1}-WoLTarget";;
	esac
    done
    PM_CAPABILITY="${PM_CAPABILITY}${_buf1}";
    PM_CAPABILITY="${PM_CAPABILITY}%VMStack-${PM_VMSTACK}";

    PM_PRODVERS="${MYDIST}-${MYREL}"
    PM_PRODVERS="${PM_PRODVERS// /}"
    PM_PRODVERS="${PM_PRODVERS//,/}"
    PM_PRODVERS="${PM_PRODVERS//;/}"


    PM_CAPABILITY="${PM_CAPABILITY}%${PM_PRODVERS}"
    PM_CAPABILITY="${PM_CAPABILITY}%${MYOS}-${MYOSREL}-${MYARCH}";
    PM_PREREQ="${PM_CAPABILITY} ${PM_PREREQ}";

    PM_PREREQ="${PM_PREREQ} MYOS=${MYOS// /_} MYOSREL=${MYOSREL// /_} MYDIST=${MYDIST// /_} MYREL=${MYREL// /_}";

    PM_VERSTRING="${MYDIST}(localhost)";
    PM_DEFAULTOPTS=;

    PM_ACCELERATOR=$(pmGetACCELERATOR);

    case ${MYOS} in
	Linux)
	    PM_MAGIC=PM_Linux;
	    PM_STATE=ENABLED
	    _ret=0;
	    ;;
	FreeBSD|OpenBSD)
	    PM_MAGIC=PM_OpenBSD;
	    PM_STATE=ENABLED
	    _ret=0;
	    ;;
	SunOS)
	    PM_MAGIC=PM_SunOS;
	    PM_STATE=ENABLED
	    _ret=0;
	    ;;
	*)
	    PM_MAGIC=NO_LOC
	    ABORT=1;
	    if [ "${C_SESSIONTYPE}" == "PM" -a -z "${_checkonly}" ];then
		gotoHell ${ABORT}
	    else
		return ${ABORT}
	    fi
	    ;;
    esac

    return $_ret
}




#FUNCBEG###############################################################
#NAME:
#  clientServerSplitSupportedPM
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
function clientServerSplitSupportedPM () {
    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME $1"
    case $1 in
	CREATE)return 0;;
	CANCEL)return 0;;
    esac
    return 1;
}


#FUNCBEG###############################################################
#NAME:
#  handlePM
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
function handlePM () {
  printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "${FUNCNAME}:$*"
  local OPMODE=$1;shift
  local ACTION=$1;shift

  case ${ACTION} in

      LIST)
	  case ${OPMODE} in
              PROLOGUE)
		  hookPackage "${_myPKGBASE_PM}/list.sh"
		  ;;
              EPILOGUE)
		  ;;
	      CHECKPARAM)
		  ;;
	      EXECUTE|ASSEMBLE)
		  ;;
	  esac
	  ;;

      INFO)
	  case ${OPMODE} in
              PROLOGUE)
		  hookPackage "${_myPKGBASE_PM}/info.sh"
		  ;;
              EPILOGUE)
		  ;;
	      CHECKPARAM)
		  ;;
	      EXECUTE|ASSEMBLE)
		  ;;
	  esac
	  ;;

      ENUMERATE)
	  case ${OPMODE} in
              PROLOGUE)
		  hookPackage "${_myPKGBASE_PM}/session.sh"
		  hookPackage "${_myPKGBASE_PM}/list.sh"
		  hookPackage "${_myPKGBASE_PM}/enumerate.sh"
		  ;;
              EPILOGUE)
		  ;;
	      CHECKPARAM)
		  ;;
	      EXECUTE|ASSEMBLE)
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
		  hookPackage "${_myPKGBASE_PM}/create.sh"
		  createConnectPM ${OPMODE} ${ACTION} 
		  ;;
	      ASSEMBLE)
		  hookPackage "${_myPKGBASE_PM}/create.sh"
		  createConnectPM ${OPMODE} ${ACTION} 
		  ;;
	      EXECUTE)
		  hookPackage "${_myPKGBASE_PM}/session.sh"
		  hookPackage "${_myPKGBASE_PM}/list.sh"
		  hookPackage "${_myPKGBASE_PM}/create.sh"
		  createConnectPM ${OPMODE} ${ACTION} 
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
		  if [ -n "${C_EXECLOCAL}" ];then
		      case "${MYOS}" in
			  Linux);;
			  FreeBSD|OpenBSD)
			      printWNG 2 $LINENO $BASH_SOURCE 1 "${FUNCNAME}:\"${MYOS}\":limited for ${ACTION} support by PM(e.g. no WoL)"
			      ;;
			  SunOS)
			      printWNG 2 $LINENO $BASH_SOURCE 1 "${FUNCNAME}:\"${MYOS}\":limited for ${ACTION} support by PM(e.g. no WoL)"
			      ;;
			  *)
			      printWNG 2 $LINENO $BASH_SOURCE 1 "${FUNCNAME}:\"${MYOS}\":not supported for ${ACTION} by PM"
			      gotoHell 1;
			      ;;
		      esac
		  fi
		  hookPackage "${_myPKGBASE_PM}/cancel.sh"
		  cutCancelSessionPM ${OPMODE} ${ACTION} 
		  ;;
	      ASSEMBLE)
		  hookPackage "${_myPKGBASE_PM}/cancel.sh"
		  cutCancelSessionPM ${OPMODE}  ${ACTION} 
		  ;;
	      EXECUTE)
		  hookPackage "${_myPKGBASE_PM}/session.sh"
		  hookPackage "${_myPKGBASE_PM}/list.sh"
		  hookPackage "${_myPKGBASE_PM}/cancel.sh"
		  cutCancelSessionPM ${OPMODE}  ${ACTION} 
		  ;;
	  esac
          ;;

      GETCLIENTPORT)#seperate as reminder
          ABORT=1;
          printERR $LINENO $BASH_SOURCE ${ABORT} "System Error, unexpected PM:OPMODE=${OPMODE} ACTION=${ACTION}"
	  gotoHell ${ABORT}
          ;;

      *)
          ABORT=1;
          printERR $LINENO $BASH_SOURCE ${ABORT} "System Error, unexpected PM:OPMODE=${OPMODE} ACTION=${ACTION}"
	  gotoHell ${ABORT}
          ;;
  esac
}



#FUNCBEG###############################################################
#NAME:
#  initPM
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
function initPM () {
  local _curInit=$1;shift
  local _initConsequences=$1
  local ret=0;

  local _raise=$((INITSTATE<_curInit));

  printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:${INITSTATE} -> ${_curInit} - ${_raise}"

  if [ "$_raise" == "1" ];then
      #for raise of INITSTATE do not touch the OS's decisions, just expand.

      case $_curInit in
	  0);;#NOP - Done by shell
	  1)  
              #adjust version specifics  
              setVersionPM $_initConsequences
              ret=$?

              #add own help to searchlist for options
	      MYOPTSFILES="${MYOPTSFILES} ${MYHELPPATH}/010_pm"
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
