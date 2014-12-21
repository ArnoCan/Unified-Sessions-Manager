#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_011
#
########################################################################
#
# Copyright (C) 2007,2008,2009,2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

VNC_MAGIC=VNC_GENERIC;
VNC_VERSTRING=;
VNC_STATE=DISABLED;
VNCSERVER_OPT=;
VNCVIEWER_OPT=;
VNC_PREREQ=;
VNC_PRODVERS=;


export VNC_BASEPORT=${VNC_BASEPORT:-5900}
export VNCDESKIDLIST=;
export VNCWM=;


_myPKGNAME_VNC="${BASH_SOURCE}"
_myPKGVERS_VNC="01.11.011"
hookInfoAdd $_myPKGNAME_VNC $_myPKGVERS_VNC
_myPKGBASE_VNC="${_myPKGNAME_VNC%/hook.sh}"


VNC_VERSTRING=${_myPKGVERS_VNC};
VNC_PREREQ=;
VNC_PREREQ0="HOST-CAPABILITY:VNC-${VNC_VERSTRING}-${MYARCH}";


if [ -d "${HOME}/.ctys" -a -d "${HOME}/.ctys/vnc" ];then
    if [ -f "${HOME}/.ctys/vnc/vnc.conf-${MYOS}.sh" ];then
	. "${HOME}/.ctys/vnc/vnc.conf-${MYOS}.sh"
    fi
fi

if [ -d "${MYCONFPATH}" -a -d "${MYCONFPATH}/vnc" ];then
    if [ -f "${MYCONFPATH}/vnc/vnc.conf-${MYOS}.sh" ];then
	. "${MYCONFPATH}/vnc/vnc.conf-${MYOS}.sh"
    fi
fi



_waitcVNC=${VNC_INIT_WAITC:-2}
_waitsVNC=${VNC_INIT_WAITS:-2}



#
#Managed load of sub-packages gwhich are required in almost any case.
#On-demand-loads will be performed within requesting action.
#
hookPackage "${_myPKGBASE_VNC}/session.sh"
hookPackage "${_myPKGBASE_VNC}/list.sh"
hookPackage "${_myPKGBASE_VNC}/info.sh"

if [ -d "${HOME}/.ctys" -a -d "${HOME}/.ctys/vnc" ];then
    #Source pre-set environment from user
    if [ -f "${HOME}/.ctys/vnc/vnc.conf-${MYOS}.sh" ];then
	. "${HOME}/.ctys/vnc/vnc.conf-${MYOS}.sh"
    fi

    #Source pre-set environment from installation 
    if [ -f "${MYCONFPATH}/vnc/vnc/vnc.conf" ];then
	. "${MYCONFPATH}/conf/vnc/vnc.conf-${MYOS}.sh"
    fi
fi




#FUNCBEG###############################################################
#NAME:
#  getFirstFreeVNCPort
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Gets the first free port above a given base, thus multiple regions
#  could be managed
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: <MIN>
#  $2: [<MAX>]
#
#OUTPUT:
#  RETURN:
#  VALUES:
#    <first-port>
#
#FUNCEND###############################################################
function getFirstFreeVNCPort () {
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:CALL=<${*}>"
    local MIN=${1:-$VNC_BASEPORT};
    local MAX=$2;
    [ -z "$MAX" ]&&let MAX=MIN+1000;
    local _seed=$((RANDOM%VNCPORTSEED));
    doDebug $S_VNC  ${D_MAINT} $LINENO $BASH_SOURCE
    local D=$?

    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:MIN=${MIN} MAX=${MAX} seed=${_seed}"
    case ${MYOS} in
	Linux)
	    local localClientAccess=`${CTYS_NETSTAT} -n -l -t|awk -v d="${D}" -v min="${MIN}" -v max="${MAX}" -v seed="${_seed}" -f ${_myPKGBASE_VNC}/getFirstFreeVNCPort-${MYOS}.awk`
	    ;;
	FreeBSD|OpenBSD)
	    local localClientAccess=`${CTYS_NETSTAT} -n -l -t|awk -v d="${D}" -v min="${MIN}" -v max="${MAX}" -v seed="${_seed}" -f ${_myPKGBASE_VNC}/getFirstFreeVNCPort-${MYOS}.awk`
	    ;;
	SunOS)
	    local localClientAccess=`${CTYS_NETSTAT} -n -l -t|awk -v d="${D}" -v min="${MIN}" -v max="${MAX}" -v seed="${_seed}" -f ${_myPKGBASE_VNC}/getFirstFreeVNCPort-${MYOS}.awk`
	    ;;
    esac
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:localClientAccess=<${localClientAccess}>"
    echo -n -e "${localClientAccess}";
}

#FUNCBEG###############################################################
#NAME:
#  getFirstFreeVNCDisplay
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Gets the first free display above a given base, thus multiple regions
#  could be managed
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: <MIN>
#  $2: [<MAX>]
#
#OUTPUT:
#  RETURN:
#  VALUES:
#    <first-port>
#
#FUNCEND###############################################################
function getFirstFreeVNCDisplay () {
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:CALL=<${*}>"
    local MIN=${1:-$VNC_BASEPORT};
    local MAX=$2;
    [ -z "$MAX" ]&&let MAX=VNC_PORT+1000;
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:MIN=${MIN} MAX=${MAX}"
    local _myPort=`getFirstFreeVNCPort ${@}`
    local _myDisplay=$((_myPort-MIN));
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_myPort=<${_myPort}>"
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_myDisplay=<${_myDisplay}>"
    echo -n -e "${_myDisplay}";
}


#FUNCBEG###############################################################
#NAME:
#  serverRequireVNC
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
function serverRequireVNC () {
    printDBG $S_VNC ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME \$@=$@"
    local _ret=1;
    local _res=;

    local _S=`getSessionType ${*}`;_S=${_S:-$C_SESSIONTYPE};
    local _A=`getActionResulting ${*}`;
    case $_A in
	GETCLIENTPORT)
	    printDBG $S_VNC ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_res=\"${*}\""
	    printDBG $S_VNC ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_ret=\"0\""
	    echo -n "${*}";
	    return 0
	    ;;
    esac

    local _CS_SPLIT=${*};
    _CS_SPLIT=${_CS_SPLIT//CONNECTIONFORWARDING/SERVERONLY}
    _CS_SPLIT=${_CS_SPLIT//*LOCALONLY*/}
    _CS_SPLIT=${_CS_SPLIT//*CLIENTONLY*/}
    if [ -n "${_CS_SPLIT}" ];then
	_res="${_CS_SPLIT}";_ret=0;
    fi


    printDBG $S_VNC ${D_MAINT} $LINENO $BASH_SOURCE "_CS_SPLIT=\"${_CS_SPLIT}\""
    printDBG $S_VNC ${D_MAINT} $LINENO $BASH_SOURCE "_S=\"${_S}\""
    printDBG $S_VNC ${D_MAINT} $LINENO $BASH_SOURCE "_A=\"${_A}\""

    printDBG $S_VNC ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_res=\"${_res}\""
    printDBG $S_VNC ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_ret=\"${_ret}\""
    echo -n "${_res}";
    return ${_ret};  
}



#FUNCBEG###############################################################
#NAME:
#  clientRequireVNC
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
function clientRequireVNC () {
    printDBG $S_VNC ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME \$@=$@"
    local _ret=1;
    local _res=;

    local _A=`getActionResulting ${*}`;

    local _S=`getSessionType ${*}`;_S=${_S:-$C_SESSIONTYPE};
    local _CS_SPLIT=${*};
    _CS_SPLIT=${_CS_SPLIT//*DISPLAYFORWARDING*/}
    _CS_SPLIT=${_CS_SPLIT//*SERVERONLY*/}
    if [ "${_CS_SPLIT}" == "${*}" ];then
	_res="${_CS_SPLIT}";_ret=0;
    fi
    printDBG $S_VNC ${D_MAINT} $LINENO $BASH_SOURCE "_CS_SPLIT=\"${_CS_SPLIT}\""
    printDBG $S_VNC ${D_MAINT} $LINENO $BASH_SOURCE "_S=\"${_S}\""
    printDBG $S_VNC ${D_MAINT} $LINENO $BASH_SOURCE "_A=\"${_A}\""

    printDBG $S_VNC ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_res=\"${_res}\""
    printDBG $S_VNC ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_ret=\"${_ret}\""
    echo -n "${_res}";
    return ${_ret};  
}






#FUNCBEG###############################################################
#NAME:
#  setVersionVNC
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Sets defaults and MAGIC-ID for local vmware version.
#
#EXAMPLE:
#
#PARAMETERS:
#
#
#OUTPUT:
#  GLOBALS:
#    VNC_MAGIC:  {VNC_REAL412|VNC_TIGHT129|...}
#      Value to be checked.
#
#    VMW_DEFAULTOPTS
#      Appropriate defaults.
#
#      -RealVNC  - 4.1.2 
#      -TightVNC - 1.2.9
#
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function setVersionVNC () {
    local _checkonly=;
    local _ret=0;
    if [ "$1" == "NOEXIT" ];then
	local _checkonly=1;        
    fi

    #
    #set for checks, e.g. CONNECTIONFORWAARDING
    local _rdisp=1
    runningOnDisplayStation
    _rdisp=$?

    local _verstrg=;
    if [ -z "${VNCSEXE}"  ];then

#4TEST-01.11.011
 	if [ "${C_EXECLOCAL}" == 1 -a $_rdisp -ne 0 ];then
	    ABORT=2;
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing executable for VNCserver"
	    printERR $LINENO $BASH_SOURCE ${ABORT} "can not find:"
	    printERR $LINENO $BASH_SOURCE ${ABORT} " -> vncserv"
	    printERR $LINENO $BASH_SOURCE ${ABORT} ""
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Check your PATH"
	    printERR $LINENO $BASH_SOURCE ${ABORT} " -> PATH=${PATH}"
	    printERR $LINENO $BASH_SOURCE ${ABORT} ""
	    if [ "${C_SESSIONTYPE}" == "VNC" -a -z "${_checkonly}" ];then
		gotoHell ${ABORT}
	    else
		return ${ABORT}
	    fi
	    _ret=${ABORT};
	fi
    else
	local _vsexe=`${VNCSEXE} --help 2>&1|egrep '(Usage:|usage:)'`
	ABORT=2;
	if [ -n "$_vsexe" ];then
	    printDBG $S_LIB ${D_SYS} $LINENO "$BASH_SOURCE" "$FUNCNAME:`setSeverityColor TRY \"call(${VNCSEXE} --help)\"` => [ `setSeverityColor INF OK` ]"
	    _ret=0;
	else
	    printDBG $S_LIB ${D_SYS} $LINENO "$BASH_SOURCE" "$FUNCNAME:`setSeverityColor TRY \"call(${VNCSEXE} --help)\"` => [ `setSeverityColor ERR NOK` ]"
	    _ret=${ABORT};
	fi
    fi

#4TEST-01.11.011
#    if [ -z "${VNCVEXE}"  ];then
# 	if [ "${C_EXECLOCAL}" == 1 ];then
    if [ -z "${VNCVEXE}" -a $_rdisp -eq 0 ];then
	    ABORT=2
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing executable for VNCviewer"
	    printERR $LINENO $BASH_SOURCE ${ABORT} "can not find:"
	    printERR $LINENO $BASH_SOURCE ${ABORT} " -> vncviewer"
	    printERR $LINENO $BASH_SOURCE ${ABORT} ""
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Check your PATH"
	    printERR $LINENO $BASH_SOURCE ${ABORT} " -> PATH=${PATH}"
	    printERR $LINENO $BASH_SOURCE ${ABORT} ""
	    if [ "${C_SESSIONTYPE}" == "VNC" -a -z "${_checkonly}" ];then
		gotoHell ${ABORT}
	    else
		return ${ABORT}
	    fi
	    _ret=${ABORT};
#4TEST-01.11.011
#	fi
    fi


    if [ -n "`${VNCVEXE} --help 2>&1|egrep '(TigerVNC)'`" ];then
	_verstrg=`${VNCVEXE} --help 2>&1|awk -v a=${_allign} '/TigerVNC/&&/[vV]ersion/{printf("%s\n",$5);}'`
	ABORT=2;
	if [ -n "$_verstrg" ];then
	    _verstrg="TigerVNC-${_verstrg}"
	    printDBG $S_LIB ${D_SYS} $LINENO "$BASH_SOURCE" "$FUNCNAME:`setSeverityColor TRY \"call(${VNCVEXE} -version)\"` => [ `setSeverityColor INF OK` ]"
	    _ret=0;
	else
	    printDBG $S_LIB ${D_SYS} $LINENO "$BASH_SOURCE" "$FUNCNAME:`setSeverityColor TRY \"call(${VNCVEXE} --version)\"` => [ `setSeverityColor ERR NOK` ]"
	    _ret=${ABORT};
	fi
    else
	if [ -n "`${VNCVEXE} --help 2>&1|egrep '(RealVNC)'`" ];then
	    _verstrg=`${VNCVEXE} --help 2>&1|sed -n 's/VNC [Vv]iewer[^0-9]*\([0-9]*.[0-9]*.[0-9]*\).*/\1/p'`
	    ABORT=2;
	    if [ -n "$_verstrg" ];then
		_verstrg="RealVNC-${_verstrg}"
		printDBG $S_LIB ${D_SYS} $LINENO "$BASH_SOURCE" "$FUNCNAME:`setSeverityColor TRY \"call(${VNCVEXE} -version)\"` => [ `setSeverityColor INF OK` ]"
		_ret=0;
	    else
		printDBG $S_LIB ${D_SYS} $LINENO "$BASH_SOURCE" "$FUNCNAME:`setSeverityColor TRY \"call(${VNCVEXE} --version)\"` => [ `setSeverityColor ERR NOK` ]"
		_ret=${ABORT};
	    fi
	else
	    if [ -n "`${VNCVEXE} --help 2>&1|egrep '(TightVNC)'`" ];then
		_verstrg=`${VNCVEXE} --help 2>&1|awk -v a=${_allign} '/[vV]iewer [vV]ersion/{printf("%s\n",$4);}'`
		ABORT=2;
		if [ -n "$_verstrg" ];then
		    _verstrg="TightVNC-${_verstrg}"
		    printDBG $S_LIB ${D_SYS} $LINENO "$BASH_SOURCE" "$FUNCNAME:`setSeverityColor TRY \"call(${VNCVEXE} -version)\"` => [ `setSeverityColor INF OK` ]"
		    _ret=0;
		else
		    printDBG $S_LIB ${D_SYS} $LINENO "$BASH_SOURCE" "$FUNCNAME:`setSeverityColor TRY \"call(${VNCVEXE} --version)\"` => [ `setSeverityColor ERR NOK` ]"
		    _ret=${ABORT};
		fi
	    else
		if [ -n "`${VNCVEXE} --help 2>&1|egrep '(Viewer Free Edition)'`" ];then
		    _verstrg=`${VNCVEXE} --help 2>&1|awk -v a=${_allign} '/[vV]iewer [fF]ree [eE]dition/{printf("%s\n",$5);}'`
		    ABORT=2;
		    if [ -n "$_verstrg" ];then
			_verstrg="RealVNC-${_verstrg}"
			printDBG $S_LIB ${D_SYS} $LINENO "$BASH_SOURCE" "$FUNCNAME:`setSeverityColor TRY \"call(${VNCVEXE} -version)\"` => [ `setSeverityColor INF OK` ]"
			_ret=0;
		    else
			printDBG $S_LIB ${D_SYS} $LINENO "$BASH_SOURCE" "$FUNCNAME:`setSeverityColor TRY \"call(${VNCVEXE} --version)\"` => [ `setSeverityColor ERR NOK` ]"
			_ret=${ABORT};
		    fi
		else
		    if [ -n "`${VNCVEXE} --help 2>&1|egrep '(open display:)'`" ];then
			printWNG 1 $LINENO $BASH_SOURCE 0  "DISPLAY is not available"
			printWNG 1 $LINENO $BASH_SOURCE 0  " 1. One common cause is the call of \"ssh\" without the \"-X\""
			printWNG 1 $LINENO $BASH_SOURCE 0  "    option. Even for the utilized check by \"vncviewer --help\" "
			printWNG 1 $LINENO $BASH_SOURCE 0  "    option a display is required."

                    #OpenBSD-4.6+
			printWNG 1 $LINENO $BASH_SOURCE 0  " 2. Another common cause for the initial usage is the missing "
			printWNG 1 $LINENO $BASH_SOURCE 0  "    permission \"X11Forwarding yes\" in \"/etc/ssh/sshd_conf\"."
  			_verstrg=GENERIC
			_ret=0;
		    else
			printWNG 1 $LINENO $BASH_SOURCE 0  "Can not evaluate version for \"which-ed\" $(setStatusColor DISABLED vncviewer)."
			printWNG 1 $LINENO $BASH_SOURCE 0  "."
			printWNG 1 $LINENO $BASH_SOURCE 0  " 1. Check whether vncviewer is installed"
			printWNG 1 $LINENO $BASH_SOURCE 0  " 2. One common cause is the call of \"ssh\" without the \"-X\""
			printWNG 1 $LINENO $BASH_SOURCE 0  "    option. Even for the utilized check by \"vncviewer --help\" "
			printWNG 1 $LINENO $BASH_SOURCE 0  "    option a display is required."
			printWNG 1 $LINENO $BASH_SOURCE 0  " 3. Another common cause for the initial usage is the missing "
			printWNG 1 $LINENO $BASH_SOURCE 0  "    permission \"X11Forwarding yes\" in \"/etc/ssh/sshd_conf\"."
  			_verstrg=GENERIC
			_ret=0;
		    fi
		fi
	    fi
	fi
    fi

    printDBG $S_VNC ${D_BULK} $LINENO $BASH_SOURCE "VNC"
    printDBG $S_VNC ${D_BULK} $LINENO $BASH_SOURCE "  _verstrg=${_verstrg}"

    #currently somewhat restrictive to specific versions.
    VNC_PREREQ="${VNC_PREREQ0}";
    case ${_verstrg} in
	"TigerVNC"*)
	    VNC_MAGIC=VNCTIGER;
	    VNC_STATE=ENABLED;
	    VNC_PREREQ="${VNC_PREREQ}%${_verstrg}-${MYARCH} ";
	    [ -n "${VNCVEXE}" ]&&VNC_PREREQ="${VNC_PREREQ} vncviewer";
	    [ -n "${VNCSEXE}" -a "${C_EXECLOCAL}" == 1 ]&&VNC_PREREQ="${VNC_PREREQ} ${VNCVEXE:+,}vncserver";

	    VNCSERVER_OPT="${VNCSERVER_OPT_TigerVNC}";
	    VNCVIEWER_OPT="${VNCVIEWER_OPT_TigerVNC}";
	    _ret=0;
	    ;;

	"TightVNC"*)
	    VNC_MAGIC=VNCT;
	    VNC_STATE=ENABLED;
	    VNC_PREREQ="${VNC_PREREQ}%${_verstrg}-${MYARCH} ";
	    [ -n "${VNCVEXE}" ]&&VNC_PREREQ="${VNC_PREREQ} vncviewer";
	    [ -n "${VNCSEXE}" -a "${C_EXECLOCAL}" == 1 ]&&VNC_PREREQ="${VNC_PREREQ} ${VNCVEXE:+,}vncserver";

	    VNCSERVER_OPT="${VNCSERVER_OPT_TightVNC}";
	    VNCVIEWER_OPT="${VNCVIEWER_OPT_TightVNC}";
	    _ret=0;
	    ;;

	"RealVNC-4"*)
	    VNC_MAGIC=VNCR4;
	    VNC_STATE=ENABLED;
	    VNC_PREREQ="${VNC_PREREQ}%${_verstrg}-${MYARCH} ";
	    [ -n "${VNCVEXE}" ]&&VNC_PREREQ="${VNC_PREREQ} vncviewer";
	    [ -n "${VNCSEXE}" -a "${C_EXECLOCAL}" == 1 ]&&VNC_PREREQ="${VNC_PREREQ} ${VNCVEXE:+,}vncserver";

            VNCSERVER_OPT="${VNCSERVER_OPT_RealVNC4}";
            VNCVIEWER_OPT="${VNCVIEWER_OPT_RealVNC4}";
	    _ret=0;
	    ;;

	"RealVNC"*)
	    VNC_MAGIC=VNCR;
	    VNC_STATE=ENABLED;
	    VNC_PREREQ="${VNC_PREREQ}%${_verstrg}-${MYARCH} ";
	    [ -n "${VNCVEXE}" ]&&VNC_PREREQ="${VNC_PREREQ} vncviewer";
	    [ -n "${VNCSEXE}" -a "${C_EXECLOCAL}" == 1 ]&&VNC_PREREQ="${VNC_PREREQ} ${VNCVEXE:+,}vncserver";

            VNCSERVER_OPT="${VNCSERVER_OPT_RealVNC}";
            VNCVIEWER_OPT="${VNCVIEWER_OPT_RealVNC}";
	    _ret=0;
	    ;;

         *)
	    VNC_MAGIC=VNCG;
	    VNC_PREREQ="${VNC_PREREQ}%${_verstrg}-${MYARCH} ";
	    [ -n "${VNCVEXE}" ]&&VNC_PREREQ="${VNC_PREREQ} vncviewer";
	    [ -n "${VNCSEXE}" -a "${C_EXECLOCAL}" == 1 ]&&VNC_PREREQ="${VNC_PREREQ} ${VNCVEXE:+,}vncserver";

            VNCSERVER_OPT="${VNCSERVER_OPT_GENERIC}";
            VNCVIEWER_OPT="${VNCVIEWER_OPT_GENERIC}";
	    _ret=2;
	    ;;
    esac

    VNC_PRODVERS="${_verstrg}";
    VNC_PRODVERS="${VNC_PRODVERS// /}";
    VNC_PRODVERS="${VNC_PRODVERS//;/}";
    VNC_PRODVERS="${VNC_PRODVERS//,/}";

    printDBG $S_VNC ${D_BULK} $LINENO $BASH_SOURCE "VNC_MAGIC       = ${VNC_MAGIC}"
    printDBG $S_VNC ${D_BULK} $LINENO $BASH_SOURCE "VNC_VERSTRING   = ${VNC_VERSTRING}"
    printDBG $S_VNC ${D_BULK} $LINENO $BASH_SOURCE "VNC_PRODVERS    = ${VNC_PRODVERS}"
    printDBG $S_VNC ${D_BULK} $LINENO $BASH_SOURCE "VNC_STATE       = ${VNC_STATE}"
    printDBG $S_VNC ${D_BULK} $LINENO $BASH_SOURCE "VNC_PREREQ      = ${VNC_PREREQ}"
    printDBG $S_VNC ${D_BULK} $LINENO $BASH_SOURCE "VNCSERVER_OPT   = ${VNCSERVER_OPT}"
    printDBG $S_VNC ${D_BULK} $LINENO $BASH_SOURCE "VNCVIEWER_OPT   = ${VNCVIEWER_OPT}"
    return $_ret;
}







#FUNCBEG###############################################################
#NAME:
#  noClientServerSplitSupportedMessageVNC
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
#  VALUES:
#
#FUNCEND###############################################################
function noClientServerSplitSupportedMessageVNC () {
    ABORT=2
    printERR $LINENO $BASH_SOURCE ${ABORT} "Unexpected ERROR!!!"
    printERR $LINENO $BASH_SOURCE ${ABORT} "VNC perfectly supports ClientServerSplit!!!"
    printERR $LINENO $BASH_SOURCE ${ABORT} "Check for process ownership, probably just missing permissions."
    printERR $LINENO $BASH_SOURCE ${ABORT} "On grave slow machines just a timeout may have occured."
    printERR $LINENO $BASH_SOURCE ${ABORT} "Try a following connect, if so adapt TIMEOUT value, but for this target only."
}



#FUNCBEG###############################################################
#NAME:
#  clientServerSplitSupportedVNC
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Checks whether the split of client and server is supported.
#  This is just a hardcoded attribute.
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
function clientServerSplitSupportedVNC () {
    printDBG $S_VNC ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME $1"
    case $1 in
	CREATE)return 0;;
	CANCEL)return 0;;
    esac
    return 1;
}



#FUNCBEG###############################################################
#NAME:
#  enumerateMySessionsVNC
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Not supported.
#
#EXAMPLE:
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function enumerateMySessionsVNC () {
    printDBG $S_VNC ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=${@}"
}


#FUNCBEG###############################################################
#NAME:
#  handleVNC
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: <OPMODE>
#  $2: <ACTION>
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function handleVNC () {
  printDBG $S_VNC ${D_BULK} $LINENO $BASH_SOURCE "${FUNCNAME}:$*"
  local OPMODE=$1;shift
  local ACTION=$1;shift

  case ${ACTION} in

      CREATE) 
	  case ${OPMODE} in
              PROLOGUE)
		  ;;
              EPILOGUE)
		  ;;
	      CHECKPARAM|ASSEMBLE|EXECUTE)
		  hookPackage "${_myPKGBASE_VNC}/create.sh"
		  createConnectVNC ${OPMODE} ${ACTION} 
		  ;;
	  esac
          ;;

      CANCEL)
	  case ${OPMODE} in
              PROLOGUE)
		  ;;
              EPILOGUE)
		  ;;
	      CHECKPARAM|ASSEMBLE|EXECUTE)
		  hookPackage "${_myPKGBASE_VNC}/cancel.sh"
		  cutCancelSessionVNC ${OPMODE} ${ACTION} 
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
                      printDBG $S_VNC ${D_BULK} $LINENO $BASH_SOURCE "C_MODE_ARGS=$C_MODE_ARGS"
                      _C_GETCLIENTPORT=$C_MODE_ARGS
		  else
		      ABORT=1
		      printERR $LINENO $BASH_SOURCE ${ABORT} "Missing <session-label>|<session-id>"
		      gotoHell ${ABORT}
		  fi

                  ;;
	      EXECUTE)
		  printDBG $S_VNC ${D_BULK} $LINENO $BASH_SOURCE "Remote command:C_MODE_ARGS=${C_MODE_ARGS}"
		  printDBG $S_VNC ${D_BULK} $LINENO $BASH_SOURCE "CLIENTPORT(VNC,${MYHOST},${_C_GETCLIENTPORT})=`getClientTPVNC ${_C_GETCLIENTPORT}`"
  		  echo "CLIENTPORT(VNC,${MYHOST},${_C_GETCLIENTPORT})=`getClientTPVNC ${_C_GETCLIENTPORT}`"
		  gotoHell 0
		  ;;
 	      ASSEMBLE)
   		  ;;
          esac
	  ;;

      *)
          #SUSPEND|RESUME|RESET
          ABORT=1;
          printERR $LINENO $BASH_SOURCE ${ABORT} "System Error, unsupported ACTION for VNC:ACTION=${ACTION} OPMODE=${OPMODE}"
          ;;
  esac

}


#FUNCBEG###############################################################
#NAME:
#  initVNC
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
#
#  VALUES:
#
#FUNCEND###############################################################
function initVNC () {
  local _curInit=$1;shift
  local _initConsequences=$1
  local ret=0;
  local _raise=$((INITSTATE<_curInit));

  printDBG $S_VNC ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:${INITSTATE} -> ${_curInit} - ${_raise}"

  if [ "$_raise" == "1" ];then
      #for raise of INITSTATE do not touch the OS's decisions, just expand.

      case $_curInit in
	  0);;#NOP - Done by shell
	  1)  #add own help to searchlist for options
	      setVersionVNC $_initConsequences
	      ret=$?
	      MYOPTSFILES="${MYOPTSFILES} ${MYHELPPATH}/010_vnc"
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
