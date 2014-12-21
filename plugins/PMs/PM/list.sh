#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_10_008
#
########################################################################
#
# Copyright (C) 2007,2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

_myPKGNAME_PM_LIST="${BASH_SOURCE}"
_myPKGVERS_PM_LIST="01.10.008"
hookInfoAdd $_myPKGNAME_PM_LIST $_myPKGVERS_PM_LIST



#FUNCBEG###############################################################
#NAME:
#  listMySessionsPM
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Lists all PM sessions.
#
#EXAMPLE:
#
#PARAMETERS:
# $1: C|S|B
#     determines the filter to be applied.
#     C: clients
#     S: servers
#     B: both
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function listMySessionsPM () {
    local _site=$1;shift

    printDBG $S_PM ${D_BULK} $LINENO $BASH_SOURCE "${FUNCNAME}:\$@=$@"

    case ${MYOS} in
	FreeBSD|OpenBSD);;
	Linux);;
	SunOS);;
	*)
	    printDBG $S_PM ${D_FLOW} $LINENO $BASH_SOURCE "${FUNCNAME}:OS not supported by PM:${MYOS}"
	    return
    esac
    if [ "${_site}" != S -a "${_site}" != B ];then
	return
    fi

    printDBG $S_PM ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME $_site <$*>"
    if [ "${C_SESSIONTYPE}" != "PM" -a "${C_SESSIONTYPE}" != "ALL" ];then 
        ABORT=2
        printERR $LINENO $BASH_SOURCE ${ABORT} "Unexpected session type:C_SESSIONTYPE=${C_SESSIONTYPE}"
        gotoHell ${ABORT}
    fi

    local X=/etc/ctys.d/pm.conf
    if [ ! -f "${X}" ];then
	local X=/etc/ctys.d/vm.conf
    fi
    local _out=;

    local _out1=;
    _out1="${MYHOST}"; 
    _out1="${_out1};`getLABEL ${X}`";
    _out1="${_out1};${X}";
    _out1="${_out1};`getUUID ${X}`";
    #out="${_out};`getMAC ${X}`";
    local _out2=;
    _out2="${_out2};";
    _out2="${_out2};";
    _out2="${_out2};";
    _out2="${_out2};1";

    local _myX=$(getUID ${X});
    [ -z "$_myX" ]&&_myX=root;
    _out2="${_out2};${_myX}";

    local _myX=$(getGID ${X});
    [ -z "$_myX" ]&&_myX=root;
    _out2="${_out2};${_myX}";

    local _myX=$(getCATEGORY ${X});
    [ -z "$_myX" ]&&_myX=PM;
    _out2="${_out2};${_myX}";

    _out2="${_out2};SERVER;";

    local RES1=""
    local CSTR=";"
    local EXEP=";${MYOS}-${MYOSREL}"
    local HRX=";${PM_PRODVERS}"
    local ACC=";$(getACCELERATOR_PM)"
    local ARCH=";$(getCurArch)"
    local post="${RES1}${CSTR}${EXEP}${HRX}${ACC}${ARCH}"

    local _cnt=0;
    local _il="`netGetIFlst ALL CONFIG`";
    printDBG $S_PM ${D_FLOW} $LINENO $BASH_SOURCE "${FUNCNAME}:Polled if-list:${_il}"
    for i in $_il;do
	_out="${_out1};${i%%=*}${_out2}";
	local _ip="${i##*=}";_ip="${_ip%%\%*}";
	local _ina="${i##*=}";_ina="${_ina##*\%}";
	_out="${_out}${_ip};;${_ina}";

	_out="${_out};";
	_out="${_out}${post}";
	echo $_out
        let _cnt++;
    done
    if((_cnt==0));then
	_out="${_out1};${_out2};";
	_out="${_out};";
	_out="${_out}${post}";
	echo $_out
    fi
}
