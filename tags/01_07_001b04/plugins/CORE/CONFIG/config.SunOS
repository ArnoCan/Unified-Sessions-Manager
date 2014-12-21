#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_06_001a09
#
########################################################################
#
# Copyright (C) 2007 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

_myPKGNAME_CONFIG="${BASH_SOURCE}"
_myPKGVERS_CONFIG="01.02.002c01"
#hookInfoAdd "$_myPKGNAME_CONFIG" "$_myPKGVERS_CONFIG"


#default fall back
CTYSCONF=${CTYSCONF:-/etc/ctys.d/[pv]m.conf}


####################################################################
#
#ATTENTION: For SETs take FIRST-ONLY (e.g. ethX).
#
####################################################################



#FUNCBEG###############################################################
#NAME:
#  getConfValueOf
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
#  $1: Name requested value.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getConfValueOf () {
    tr "'" '"'|\
    sed -n 's/\\t//g;s/^ *'"${1}"' *= *"*\([^"]*\)"*.*/\1/p'|\
    awk '{if(!x){printf("%s",$0);x=1;}}'
}


#FUNCBEG###############################################################
#NAME:
#  getConfValueOfMulti
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  All matches <CR> seperated.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Name requested value.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getConfValueOfMulti () {
    tr "'" '"'|sed -n 's/\\t//g;s/^ *'"${1}"' *= *"*\([^"]*\)"*.*/\1/p'
}


#FUNCBEG###############################################################
#NAME:
#  getUUID
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
function getUUID () {
    local X=$1
    local _IP=;
    if [ -z "${X}" ];then
	gwhich dmidecode 2>/dev/null >/dev/null
	if [ $? == 0 ];then
	    _IP=`dmidecode |awk '/UUID/{if(NF==2)print $2}'|sed 's/-//g'`
	    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from dmidecode"
	fi
    else        
	for i in "${X}" "${X%.*}.ctys" "${X%/*}.ctys" "${CTYSCONF}";do
	    [ ! -f "$i" ]&&continue;
	    _IP=`cat  "${i}"|getConfValueOf "#@#UUID"`
            if [ "$_IP" != "" ];then
		printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from ${i}"
		break;
	    fi
	done
    fi
    echo $_IP
}





#FUNCBEG###############################################################
#NAME:
#  getDIST
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
function getDIST () {
    local X=$1
    if [ -z "${X}" ];then
	local _IP=`cat /etc/*-release`;
	printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from /etc/*-release"
    else
        for i in "${X}" "${X%.*}.ctys" "${X%/*}.ctys" "${CTYSCONF}";do
	    [ ! -f "$i" ]&&continue;
	    _IP=`cat  "${i}"|getConfValueOf "#@#DIST"`
            if [ "$_IP" != "" ];then
		printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from ${i}"
		break;
	    fi
	done
    fi
    echo $_IP|sed 's/ /_/g'
}


#FUNCBEG###############################################################
#NAME:
#  getDISTREL
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
function getDISTREL () {
    local X=$1
    if [ -z "${X}" ];then
	local _IP=`cat /etc/*-release`;
	printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from /etc/*-release"
    else
        for i in "${X}" "${X%.*}.ctys" "${X%/*}.ctys" "${CTYSCONF}";do
	    [ ! -f "$i" ]&&continue;
	    _IP=`cat  "${i}"|getConfValueOf "#@#DISTREL"`
            if [ "$_IP" != "" ];then
		printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from ${i}"
		break;
	    fi
	done
    fi
    echo $_IP|sed 's/ /_/g'
}



#FUNCBEG###############################################################
#NAME:
#  getOS
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
function getOS () {
    local X=$1
    if [ -z "${X}" ];then
	local _IP=${MYOS};
	printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from MYOS"
    else
        for i in "${X}" "${X%.*}.ctys" "${X%/*}.ctys" "${CTYSCONF}";do
	    [ ! -f "$i" ]&&continue;
	    _IP=`cat  "${i}"|getConfValueOf "#@#OS"`
            if [ "$_IP" != "" ];then
		printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from ${i}"
		break;
	    fi
	done
    fi
    echo $_IP|sed 's/ /_/g'
}


#FUNCBEG###############################################################
#NAME:
#  getOSREL
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
function getOSREL () {
    local X=$1
    if [ -z "${X}" ];then
	local _IP=${MYOS};
	printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from MYOS"
    else
        for i in "${X}" "${X%.*}.ctys" "${X%/*}.ctys" "${CTYSCONF}";do
	    [ ! -f "$i" ]&&continue;
	    _IP=`cat  "${i}"|getConfValueOf "#@#OSREL"`
            if [ "$_IP" != "" ];then
		printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from ${i}"
		break;
	    fi
	done
    fi
    echo $_IP|sed 's/ /_/g'
}




#FUNCBEG###############################################################
#NAME:
#  getVERNO
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
function getVERNO () {
    local X=$1
    if [ -z "${X}" ];then
	local _IP=${MYOSREL};
	printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from MYOSREL"
    else
        for i in "${X}" "${X%.*}.ctys" "${X%/*}.ctys" "${CTYSCONF}";do
	    [ ! -f "$i" ]&&continue;
	    _IP=`cat  "${i}"|getConfValueOf "#@#VERSION"`
            if [ "$_IP" != "" ];then
		printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from ${i}"
		break;
	    fi
	done
    fi
    echo $_IP
}



