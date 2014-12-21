#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_009
#
########################################################################
#
# Copyright (C) 2007 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

_myPKGNAME_CONFIG="${BASH_SOURCE}"
_myPKGVERS_CONFIG="01.11.009"
hookInfoAdd "$_myPKGNAME_CONFIG" "$_myPKGVERS_CONFIG"


#default fall back
CTYSCONF=${CTYSCONF:-/etc/ctys.d/[pv]m.conf}
hookPackage "`dirname ${_myPKGNAME_CONFIG}`/fieldaccess.sh"
hookPackage "`dirname ${_myPKGNAME_CONFIG}`/config-${MYOS}.sh"



#FUNCBEG###############################################################
#NAME:
#  getConfFilesList
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  First wins.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Name of "ID" or "PNAME" containing the configuration.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getConfFilesList () {
    local fx=;
    for i in "${1%.vdi}.ctys" "${1%.*}.vmx" "${1%.*}.conf" "${1%.*}.ctys" "${1%/*}.ctys" "${CTYSCONF}";do
        [ ! -f "$i" ]&&continue;
	fx="${fx} ${i}"
    done
    echo "${fx}"
}



#FUNCBEG###############################################################
#NAME:
#  getVMSTATE
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Name of "ID" or "PNAME" containing the configuration.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getVMSTATE () {
    local _IP=;
    for i in `getConfFilesList "${1}"`;do
	if [ -r "${i}" ];then
	    _IP=`cat  "${i}"|getConfValueOf "#@#VMSTATE"`
            if [ "$_IP" != "" ];then
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from ${i}"
		break;
	    fi
	fi
    done
    echo -n -e "${_IP##* }"
}

#FUNCBEG###############################################################
#NAME:
#  getHYPERREL
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Name of "ID" or "PNAME" containing the configuration.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getHYPERREL () {
    local _IP=;
    for i in `getConfFilesList "${1}"`;do
	if [ -r "${i}" ];then
	    _IP=`cat  "${i}"|getConfValueOf "#@#INST_HYPERREL"`
            if [ "$_IP" != "" ];then
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from ${i}"
		break;
	    fi
	fi
    done
    echo -n -e "${_IP##* }"
}


#FUNCBEG###############################################################
#NAME:
#  getSTACKCAP
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Name of "ID" or "PNAME" containing the configuration.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getSTACKCAP () {
    local _IP=;
    for i in `getConfFilesList "${1}"`;do
	if [ -r "${i}" ];then
	    _IP=`cat  "${i}"|getConfValueOf "#@#STACKCAP"`
            if [ "$_IP" != "" ];then
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from ${i}"
		break;
	    fi
	fi
    done
    echo -n -e "${_IP##* }"
}


#FUNCBEG###############################################################
#NAME:
#  getSTACKREQ
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Name of "ID" or "PNAME" containing the configuration.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getSTACKREQ () {
    local _IP=;
    for i in `getConfFilesList "${1}"`;do
	if [ -r "${i}" ];then
	    _IP=`cat  "${i}"|getConfValueOf "#@#STACKREQ"`
            if [ "$_IP" != "" ];then
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from ${i}"
		break;
	    fi
	fi
    done
    echo -n -e "${_IP##* }"
}


#FUNCBEG###############################################################
#NAME:
#  getGUESTARCH
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Name of "ID" or "PNAME" containing the configuration.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getGUESTARCH () {
    local _IP=;
    for i in `getConfFilesList "${1}"`;do
	if [ -r "${i}" ];then
	    _IP=`cat  "${i}"|getConfValueOf "#@#ARCH"`
            if [ "$_IP" != "" ];then
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from ${i}"
		break;
	    fi
	fi
    done
    echo -n -e "${_IP##* }"
}


#FUNCBEG###############################################################
#NAME:
#  getGUESTPLATFORM
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Name of "ID" or "PNAME" containing the configuration.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getGUESTPLATFORM () {
    local _IP=;
    for i in `getConfFilesList "${1}"`;do
	if [ -r "${i}" ];then
	    _IP=`cat  "${i}"|getConfValueOf "#@#PLATFORM"`
            if [ "$_IP" != "" ];then
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from ${i}"
		break;
	    fi
	fi
    done
    echo -n -e "${_IP##* }"
}


#FUNCBEG###############################################################
#NAME:
#  getGUESTVRAM
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Name of "ID" or "PNAME" containing the configuration.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getGUESTVRAM () {
    local _IP=;
    for i in `getConfFilesList "${1}"`;do
	if [ -r "${i}" ];then
	    _IP=`cat  "${i}"|getConfValueOf "#@#VRAM"`
            if [ "$_IP" != "" ];then
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from ${i}"
		break;
	    fi
	fi
    done
    echo -n -e "${_IP##* }"
}


#FUNCBEG###############################################################
#NAME:
#  getGUESTVCPU
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Name of "ID" or "PNAME" containing the configuration.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getGUESTVCPU () {
    local _IP=;
    for i in `getConfFilesList "${1}"`;do
	if [ -r "${i}" ];then
	    _IP=`cat  "${i}"|getConfValueOf "#@#VCPU"`
            if [ "$_IP" != "" ];then
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from ${i}"
		break;
	    fi
	fi
    done
    if [ -z "${_IP// /}" ];then
	echo 1;
	return
    fi
    echo ${_IP##* }
}


#FUNCBEG###############################################################
#NAME:
#  getCONTEXTSTRING
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Name of "ID" or "PNAME" containing the configuration.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getCONTEXTSTRING () {
    local _IP=;
    for i in `getConfFilesList "${1}"`;do
	if [ -r "${i}" ];then
	    _IP=`cat  "${i}"|getConfValueOf "#@#CSTRG"`
            if [ "$_IP" != "" ];then
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from ${i}"
		break;
	    fi
	fi
    done
    echo -n -e "${_IP##* }"
}


#FUNCBEG###############################################################
#NAME:
#  getUSERSTRING
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Name of "ID" or "PNAME" containing the configuration.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getUSERSTRING () {
    local _IP=;
    for i in `getConfFilesList "${1}"`;do
	if [ -r "${i}" ];then
	    _IP=`cat  "${i}"|getConfValueOf "#@#USTRG"`
            if [ "$_IP" != "" ];then
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from ${i}"
		break;
	    fi
	fi
    done
    echo -n -e "${_IP##* }"
}


#FUNCBEG###############################################################
#NAME:
#  getLABEL
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Name of "ID" or "PNAME" containing the configuration.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getLABEL () {
    local _IP=;
    for i in `getConfFilesList "${1}"`;do
        [ ! -f "$i" ]&&continue;
	if [ -r "${i}" ];then
	    _IP=`cat  "${i}"|getConfValueOf "#@#LABEL"`
            if [ "$_IP" != "" ];then
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from ${i}"
		break;
	    fi
	fi
    done
    echo -n -e "${_IP##* }"
}


#FUNCBEG###############################################################
#NAME:
#  getSERNO
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Name of "ID" or "PNAME" containing the configuration.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getSERNO () {
    local _IP=;
    for i in `getConfFilesList "${1}"`;do
	if [ -r "${i}" ];then
	    _IP=`cat  "${i}"|getConfValueOf "#@#SERNO"`
            if [ "$_IP" != "" ];then
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from ${i}"
		break;
	    fi
	fi
    done
    echo -n -e "${_IP##* }"
}



#FUNCBEG###############################################################
#NAME:
#  getCATEGORY
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Name of "ID" or "PNAME" containing the configuration.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getCATEGORY () {
    local _IP=;
    for i in `getConfFilesList "${1}"`;do
	if [ -r "${i}" ];then
	    _IP=`cat  "${i}"|getConfValueOf "#@#CATEGORY"`
            if [ "$_IP" != "" ];then
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from ${i}"
		break;
	    fi
	fi
    done
    echo -n -e "${_IP##* }"
}


#FUNCBEG###############################################################
#NAME:
#  getMAGIC
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Name of "ID" or "PNAME" containing the configuration.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getMAGIC () {
    local _IP=;
    for i in `getConfFilesList "${1}"`;do
	if [ -r "${i}" ];then
	    _IP=`cat  "${i}"|getConfValueOf "#@#MAGICID-${MYOS}"`
            if [ "$_IP" != "" ];then
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from ${i}"
		break;
	    fi
	fi
    done
    echo -n -e "${_IP##* }"
}



#FUNCBEG###############################################################
#NAME:
#  checkMAGIC
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Name of "ID" or "PNAME" containing the configuration.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function checkMAGIC () {
    grep -q "#@#MAGICID-${MYOS}" $1
}


#FUNCBEG###############################################################
#NAME:
#  getUID
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Name of "ID" or "PNAME" containing the configuration.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getUID () {
    local _IP=;
    for i in `getConfFilesList "${1}"`;do
	if [ -r "${i}" ];then
	    _IP=`cat  "${i}"|getConfValueOf "#@#UID"`
            if [ "$_IP" != "" ];then
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from ${i}"
		break;
	    fi
	fi
    done
    echo -n -e "${_IP##* }"
}


#FUNCBEG###############################################################
#NAME:
#  getGID
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Name of "ID" or "PNAME" containing the configuration.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getGID () {
    local _IP=;
    for i in `getConfFilesList "${1}"`;do
	if [ -r "${i}" ];then
	    _IP=`cat  "${i}"|getConfValueOf "#@#GID"`
            if [ "$_IP" != "" ];then
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from ${i}"
		break;
	    fi
	fi
    done
    echo -n -e "${_IP##* }"
}




#FUNCBEG###############################################################
#NAME:
#  getVNCACCESSPORT
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Number of VNC port.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getVNCACCESSPORT () {
    local _IP=;
    for i in `getConfFilesList "${1}"`;do
	if [ -r "${i}" ];then
	    _IP=`cat  "${i}"|getConfValueOf "#@#VNCACCESSPORT"`
            if [ "$_IP" != "" ];then
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from ${i}"
		break;
	    fi
	fi
    done
    echo -n -e "${_IP##* }"
}


#FUNCBEG###############################################################
#NAME:
#  getVNCBASEPORT
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Number of VNC port.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getVNCBASEPORT () {
    local _IP=;
    for i in `getConfFilesList "${1}"`;do
	if [ -r "${i}" ];then
	    _IP=`cat  "${i}"|getConfValueOf "#@#VNCBASEPORT"`
            if [ "$_IP" != "" ];then
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from ${i}"
		break;
	    fi
	fi
    done
    echo -n -e "${_IP##* }"
}



#FUNCBEG###############################################################
#NAME:
#  getVNCACCESSDISPLAY
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Number of VNC port.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getVNCACCESSDISPLAY () {
    local _IP=;
    for i in `getConfFilesList "${1}"`;do
	if [ -r "${i}" ];then
	    _IP=`cat  "${i}"|getConfValueOf "#@#VNCACCESSDISPLAY"`
            if [ "$_IP" != "" ];then
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from ${i}"
		break;
	    fi
	fi
    done
    echo -n -e "${_IP##* }"
}


#FUNCBEG###############################################################
#NAME:
#  getSPORT
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Number of VNC port.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getSPORT () {
    local _IP=;
    for i in `getConfFilesList "${1}"`;do
	if [ -r "${i}" ];then
	    _IP=`cat  "${i}"|getConfValueOf "#@#SPORT"`
            if [ "$_IP" != "" ];then
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from ${i}"
		break;
	    fi
	fi
    done
    echo -n -e "${_IP##* }"
}



#FUNCBEG###############################################################
#NAME:
#  getMAC
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Treats first interface only
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Name of "ID" or "PNAME" containing the configuration.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getMAC () {
    local _IP=;
    if [ -z "${1}" ];then
	_IP=`netGetMAC`
    else
	for i in `getConfFilesList "${1}"`;do
	    if [ -r "${i}" ];then
		_IP=`cat  "${i}"|getConfValueOf "#@#MAC[0]*"`
		if [ "$_IP" != "" ];then
		    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from ${i}"
		    break;
		fi
	    fi
	done
    fi
    echo -n -e "${_IP##* }"
}


#FUNCBEG###############################################################
#NAME:
#  getMAClst
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
# returns a list of all  with included IF number of MAC
#
# Uses global cache "_curMACCache", should be cleaned after each 
# interface.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Name of "ID" or "PNAME" containing the configuration.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getMAClst () {
    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=${@}";
    local _IP=;
    for i in `getConfFilesList "${1}"`;do
	if [ -r "${i}" ];then
	    _IP=`cat  "${i}"|tr "'" '"'|sed -n 's/^ *#@#MAC\([0-9]*\) *= *"*\([^"]*\)"*/\1=\2/p'`;
            [ "$_IP" != "" ]&&break;
	fi
    done
    if [ "${_IP// /}" != "" ];then
	printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_IP=${_IP} from ${1}"
	echo -n -e "${_IP##* }"
    fi
}


#FUNCBEG###############################################################
#NAME:
#  getIP
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Treats first interface only
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Name of "ID" or "PNAME" containing the configuration.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getIP () {
    local _IP=;
    if [ -z "${1}" ];then
	_IP=`netGetIP`
    else
	for i in `getConfFilesList "${1}"`;do
	    if [ -r "${i}" ];then
		_IP=`cat  "${i}"|getConfValueOf "#@#IP[0]*"`
		if [ "$_IP" != "" ];then
		    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from ${i}"
		    break;
		fi
	    fi
	done
    fi
    echo -n -e "${_IP##* }"
}

#FUNCBEG###############################################################
#NAME:
#  getSSHPORT
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Treats first interface only.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Name of "ID" or "PNAME" containing the configuration.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getSSHPORT () {
    local _IP=;
    if [ -z "${1}" ];then
	if [ -r "/etc/ssh/sshd_config" ];then
	    _IP=`sed -n '/^ *# *P/d;s/^ *Port *\([0-9]*\)[^0-9]*/\1/p' /etc/ssh/sshd_config`
	fi
    else
	for i in `getConfFilesList "${1}"`;do
	    if [ -r "${i}" ];then
		_IP=`cat  "${i}"|getConfValueOf "#@#SSHPORT"`
		if [ "$_IP" != "" ];then
		    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from ${i}"
		    break;
		fi
	    fi
	done
    fi
    echo -n -e "${_IP##* }"
}


#FUNCBEG###############################################################
#NAME:
#  getIPlst
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
# returns a list of all  with included IF number of IP
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Name of "ID" or "PNAME" containing the configuration.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getIPlst () {
    local _IP=;
    for i in `getConfFilesList "${1}"`;do
	if [ -r "${i}" ];then
	    _IP=`cat  "${i}"|tr "'" '"'|sed -n 's/^ *#@#IP\([0-9]*\) *= *"*\([^"]*\)"*/\1=\2/p'`;
            [ "$_IP" != "" ]&&break;
	fi
    done
    _IP=" ${_IP%% }"
    echo -n -e "${_IP##* }"
}



#FUNCBEG###############################################################
#NAME:
#  getIFlst
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#  Returns a space seperated list of current Ethernet interfaces with a 
#  valid MAC and/or IP address.
#
#  If no KEY is given  netGetIFlst is called, gwhich just enumerates local
#  interfaces.
#
#
#  The following common syntax applies:
#
#
#  <INDEXEDENTRY>[0-9]* = <entity>
#
#    <entity>   =: <elements>[,<entity>]
#    <elements> =: <entry0>[%<entry1>[%<entry2>[%<entry3>[...]]]]
#
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: KEY
#      Controls source of information
#      - ""
#        calls netGEtIFlst for dynamic evaluation of running machine.
#
#      - INTERFACES:
#        takes two lists of argumens in the format:
#
#        $2: List of MAC addresses
#            MAC[0-9]* = <mac-entity>
#
#            <mac-entity> := <MAC-address>
#
#        $3: List of IP addresses
#            IP[0-9]* = <ip-entity>
#
#            <ipentity>    =: <ip-elements>[,<ip-entity>]
#            <ip-elements> =: 
#             <dotted-IP-addr>%[<netmask>]%[<relay>]%[<ifname>]%[<ssh-port>]%[<gateway>]]
#
#      - ID:
#        takes one argument for a configuration file with MAC/IP-information.
#
#        $2: Name of cofiguration file to scan.
#
#OUTPUT:
#  RETURN:
#    $?
#  VALUES:
#output
#  <MAC-addr>[=[<dotted-IP-addr>]%[<netmask>]%[<relay>]%[<ifname>]%[<ssh-port>]%[<gateway>]]
#  #1           #2-0               #2-1        #2-2      #2-3       #2-4         #2-5
#
#FUNCEND###############################################################
function getIFlst () {
    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=${@}";

    local X="${1}";shift
    local _IP=;
    local i=;

    local _myMAC=;
    local _myMAClst=;
    local _myIP=;
    local _myIPlst=;
    local i4=;
    local i4x=;
    local _ipx=;

    function assembleIP () {
	printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=<$@>"
	local _mx1=${1};
	local i3=;
	local _ifdat=;
        local _ipbuf="${_myIPlst[${_mx1}]}";
	printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "IP${_mx1} = \"${_myIPlst[${_mx1}]}\""
        for i3 in ${_ipbuf};do
	    local _padding=7;
	    local _idx9=1;
	    local _dat="${_myMAClst[${_mx1}]}=";
	    local i3=$i3"%";
	    local _A[0]=${i3%%\%*};
	    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "A[0]=<${_A[0]}>"
            i3=${i3#*\%};
	    _A[1]=${i3%%\%*};i3=${i3#*\%};
	    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "A[1]=<${_A[1]}>"
	    _A[2]=${i3%%\%*};i3=${i3#*\%};
	    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "A[2]=<${_A[2]}>"
	    _A[3]=${i3%%\%*};i3=${i3#*\%};
	    _A[3]=${_A[3]:-$_mx1};
	    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "A[3]=<${_A[3]}>"
	    _A[4]=${i3%%\%*};i3=${i3#*\%};
	    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "A[4]=<${_A[4]}>"
	    _A[5]=${i3%%\%*};
	    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "A[5]=<${_A[5]}>"

	    for((_idx9=0;_idx9<6;_idx9++));do
		if((_idx9==0));then
		    _dat="${_dat}${_A[${_idx9}]}";
		else		
		    _dat="${_dat}%${_A[${_idx9}]}";
		fi
	    done
	    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "_dat=<${_dat}>"
	    echo "${_dat}";
	done
    }


    if [ -z "${X}" ];then
	_IP=`netGetIFlst WITHMAC`
    else
	case "$X" in
	    INTERFACES)
                #fetch MAC addresses                
		_myMAC="${1}";shift
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_myMAC=${_myMAC}";

                #fetch IP addresses                
		_myIP="${1}";shift
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_myIP=${_myIP}";
		;;

	    ID)
		for i in `getConfFilesList "${1}"`;do
		    [ ! -f "$i" ]&&continue;
                    #fetch MAC addresses
		    _myMAC=`getMAClst "${i}"`;

                    #fetch IP addresses
		    _myIP=`getIPlst "${i}"`;
		    break;
		done
		;;

	    *)
		ABORT=2
		printERR $LINENO $BASH_SOURCE ${ABORT} "System Error, unknown KEY=\"${X}\""
		gotoHell ${ABORT}
		;;
	esac
    fi

    #
    #process MAC addresses                
    for i4x in ${_myMAC};do
	i4="${i4x%%=*}";
	printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "idx=${i4}"
	if [ -n "${_myMAClst[${i4}]}" ];then
	    printWNG 1 $LINENO $BASH_SOURCE 2 "Redundant MAC definition detected:\"MAC[${i4}]\" <> \"${i4}\""
	    printWNG 1 $LINENO $BASH_SOURCE 2 "=>\"${CURRENTENUM}\""
	    printWNG 1 $LINENO $BASH_SOURCE 2 "Using present only."
	    printWNG 1 $LINENO $BASH_SOURCE 2 "present:_myMAClst[${i4}]=${_myMAClst[${i4}]}";
	    printWNG 1 $LINENO $BASH_SOURCE 2 "dropped:${i4x}";

	    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "Redundant MAC definition detected:\"MAC[${i4}]\" <> \"${i4}\""
	    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "=>\"${CURRENTENUM}\""
	    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "Using present only."
	    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:present:_myMAClst[${i4}]=${_myMAClst[${i4}]}";
	    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:dropped:${i4x}";
	    continue;
	fi
	_myMAClst[${i4}]=${i4x#*=};
	printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_myMAClst[${i4}]=<${_myMAClst[${i4}]}>";
    done

    #
    #process IP addresses                
    if [ "$_myIP" != "" ];then
	printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "_myIP=<${_myIP}>"
	for i4x in $_myIP;do
	    i4="${i4x%=*}";
	    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "idx=${i4}"
	    if [ -n "${_myIPlst[${i4}]}" ];then
		printWNG 1 $LINENO $BASH_SOURCE 2 "Redundant IP definitions detected:\"IP[${i4}]\" <> \"${i4}\""
		printWNG 1 $LINENO $BASH_SOURCE 2 "=>\"${CURRENTENUM}\""
		printWNG 1 $LINENO $BASH_SOURCE 2 "Using present only."
		printWNG 1 $LINENO $BASH_SOURCE 2 "present:_myIPlst[${i4}]=${_myIPlst[${i4}]}";
		printWNG 1 $LINENO $BASH_SOURCE 2 "dropped:${i4x}";

		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "Redundant IP definition detected:\"MAC[${i4}]\" <> \"${i4%=*}\""
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "=>\"${CURRENTENUM}\""
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "Using present only."
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:present:_myIPlst[${i4}]=${_myIPlst[${i4}]}";
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:dropped:${i4x}";
		continue;
	    fi
	    _myIPlst[${i4}]="${i4x#*=}";
	    local _bufxy="${_myIPlst[${i4}]}";
	    _myIPlst[${i4}]="${_bufxy//,/ }";
	    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_myIPlst[${i4}]=<${_myIPlst[${i4}]}>";
	done
    fi

    local _mx=;

    #
    #iterate MAC list for all actual existing MAC entries
    for _mx in ${!_myMAClst[@]};do
	printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_myMAClst[${_mx}]=${_myMAClst[${_mx}]}";
	printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_myIPlst[${_mx}] =${_myIPlst[${_mx}]}";

	assembleIP ${_mx};
    done

    #
    #iterate over IP entries and append those without MAC entries
    #validate each IP entry
    for _mx in ${!_myIPlst[@]};do
#acue:20100218-check idx of _myIPlst, only one conf-err(!?) "W2Kservice"
#	[ -n "${_myMAClst[${_mx}]// }" ]&&continue;
	[ -n "${_myMAClst[${_mx}]// }" -o \( -z "${_myMAClst[${_mx}]// }" -a -z "${_myIPlst[${_mx}]// }" \) ]&&continue;

 	printINFO 2 $LINENO $BASH_SOURCE 0 "MATCH IP without MAC:${!_myIPlst[@]}=<${!_myIPlst[@]}>";

	printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:MATCH IP without MAC:_myMAClst[${_mx}]=<${_myMAClst[${_mx}]}";
	printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:MATCH IP without MAC:_myIPlst[${_mx}]=${_myIPlst[${_mx}]}";
 	printINFO 1 $LINENO $BASH_SOURCE 0 "MATCH IP without MAC:_myMAClst[${_mx}]=<${_myMAClst[${_mx}]}>";
 	printINFO 1 $LINENO $BASH_SOURCE 0 "MATCH IP without MAC:_myIPlst[${_mx}]=<${_myIPlst[${_mx}]}>";
	assembleIP ${_mx};
    done
}




#FUNCBEG###############################################################
#NAME:
#  getHWCAP
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Returns a list of HW capabilites.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Name of "ID" or "PNAME" containing the configuration.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getHWCAP () {
    local _IP=;
    for i in `getConfFilesList "${1}"`;do
	if [ -r "${i}" ];then
	    _IP=`cat  "${i}"|getConfValueOf "#@#HWCAP"`
            if [ "$_IP" != "" ];then
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from ${i}"
		break;
	    fi
	fi
    done
    echo -n -e "${_IP##* }"
}


#FUNCBEG###############################################################
#NAME:
#  getHWREQ
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Returns a list of HW requirements.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Name of "ID" or "PNAME" containing the configuration.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getHWREQ () {
    local _IP=;
    for i in `getConfFilesList "${1}"`;do
	if [ -r "${i}" ];then
	    _IP=`cat  "${i}"|getConfValueOf "#@#HWREQ"`
            if [ "$_IP" != "" ];then
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from ${i}"
		break;
	    fi
	fi
    done
    echo -n -e "${_IP##* }"
}


#FUNCBEG###############################################################
#NAME:
#  getEXECLOCATION
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Returns a list of valid execution locations.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Name of "ID" or "PNAME" containing the configuration.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getEXECLOCATION () {
    local _IP=;
    for i in `getConfFilesList "${1}"`;do
	if [ -r "${i}" ];then
	    _IP=`cat  "${i}"|getConfValueOf "#@#EXECLOCATION"`
            if [ "$_IP" != "" ];then
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from ${i}"
		break;
	    fi
	fi
    done
    echo -n -e "${_IP##* }"
}


#FUNCBEG###############################################################
#NAME:
#  getRELOCCAP
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Returns a list of possible relocation/location policies.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Name of "ID" or "PNAME" containing the configuration.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getRELOCCAP () {
    local _IP=;
    for i in `getConfFilesList "${1}"`;do
	if [ -r "${i}" ];then
	    _IP=`cat  "${i}"|getConfValueOf "#@#RELOCCAP"`
            if [ "$_IP" != "" ];then
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from ${i}"
		break;
	    fi
	fi
    done
    echo -n -e "${_IP##* }"
}




#FUNCBEG###############################################################
#NAME:
#  getCTYSRELEASE
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Returns the release of the hypervisor gwhich generated the VM.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Name of "ID" or "PNAME" containing the configuration.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getCTYSRELEASE () {
    local _IP=;
    for i in `getConfFilesList "${1}"`;do
	if [ -r "${i}" ];then
	    _IP=`cat  "${i}"|getConfValueOf "#@#CTYSREL"`
            if [ "$_IP" != "" ];then
		_IP=`cat  "${i}"|getConfValueOf "#@#CTYSRELEASE"`
	    fi
            if [ "$_IP" != "" ];then
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from ${i}"
		break;
	    fi
	fi
    done
    echo -n -e "${_IP##* }"
}



#FUNCBEG###############################################################
#NAME:
#  getGATEWAY
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Returns the gateway of the GuestOS.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Name of "ID" or "PNAME" containing the configuration.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getGATEWAY () {
    local _IP=;
    for i in `getConfFilesList "${1}"`;do
	if [ -r "${i}" ];then
	    _IP=`cat  "${i}"|getConfValueOf "#@#GUESTGATEWAY"`
            if [ "$_IP" != "" ];then
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from ${i}"
		break;
	    fi
	fi
    done
    echo -n -e "${_IP##* }"
}




#FUNCBEG###############################################################
#NAME:
#  getACCELERATOR
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Returns the configured accelerator. This could be different from the
#  available, e.g. PARA for a XEN on a HVM supporting CPU.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Name of "ID" or "PNAME" containing the configuration.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getACCELERATOR () {
    local _IP=;
    for i in `getConfFilesList "${1}"`;do
	if [ -r "${i}" ];then
	    _IP=`cat  "${i}"|getConfValueOf "#@#INST_ACCELERATOR"`
            if [ "$_IP" != "" ];then
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from ${i}"
		break;
	    fi
	fi
    done
    echo -n -e "${_IP##* }"
}

#FUNCBEG###############################################################
#NAME:
#  getSTARTERCALL
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Returns the configured startercall.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Name of "ID" or "PNAME" containing the configuration.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getSTARTERCALL () {
    local _IP=;
    for i in `getConfFilesList "${1}"`;do
	if [ -r "${i}" ];then
	    _IP=`cat  "${i}"|getConfValueOf "#@#STARTERCALL"`
            if [ "$_IP" != "" ];then
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from ${i}"
		break;
	    fi
	fi
    done
    echo -n -e "${_IP##* }"
}



#FUNCBEG###############################################################
#NAME:
#  getDEFAULTHOSTS
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Returns the configured default HOSTs.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Name of "ID" or "PNAME" containing the configuration.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getDEFAULTHOSTS () {
    local _IP=;
    for i in `getConfFilesList "${1}"`;do
	if [ -r "${i}" ];then
	    _IP=`cat  "${i}"|getConfValueOf "#@#DEFAULTHOSTS"`
            if [ "$_IP" != "" ];then
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from ${i}"
		break;
	    fi
	fi
    done
    echo -n -e "${_IP##* }"
}



#FUNCBEG###############################################################
#NAME:
#  getDEFAULTCONSOLE
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Returns the configured default CONSOLE.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Name of "ID" or "PNAME" containing the configuration.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getDEFAULTCONSOLE () {
    local _IP=;
    for i in `getConfFilesList "${1}"`;do
	if [ -r "${i}" ];then
	    _IP=`cat  "${i}"|getConfValueOf "#@#DEFAULTCONSOLE"`
            if [ "$_IP" != "" ];then
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from ${i}"
		break;
	    fi
	fi
    done
    echo -n -e "${_IP##* }"
}


