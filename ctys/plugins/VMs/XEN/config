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

_myPKGNAME_XEN_CONFIG="${BASH_SOURCE}"
_myPKGVERS_XEN_CONFIG="01.01.001a01"
hookInfoAdd $_myPKGNAME_XEN_CONFIG $_myPKGVERS_XEN_CONFIG
_myPKGBASE_XEN_CONFIG="`dirname ${_myPKGNAME_XEN_CONFIG}`"




#FUNCBEG###############################################################
#NAME:
#  getLABEL_XEN
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
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getLABEL_XEN () {
    local _IP=;

    for i in `getConfFilesList "${1}"`;do
	_IP=`cat "${i}"|getConfValueOf "name"`
        [ "$_IP" != "" ]&&break;
    done
    if [ "${_IP// /}" != "" ];then
	printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from ${1}"
	echo ${_IP##* }
	return
    fi
    getLABEL "$1"
}


#FUNCBEG###############################################################
#NAME:
#  getUUID_XEN
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
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getUUID_XEN () {
    local _IP=;

    for i in `getConfFilesList "${1}"`;do
 	_IP=`cat "${i}"|getConfValueOf "uuid"`
        [ "$_IP" != "" ]&&break;
    done

    if [ "${_IP// /}" != "" ];then
	printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from ${1}"
	echo $_IP
	return
    fi
    getUUID "${1}"
}

#FUNCBEG###############################################################
#NAME:
#  getMAC_XEN
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
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getMAC_XEN () {
       #might be cached already, don't forget to reset for each record!!!
    if [ -n "$_curMACCache" ];then
	echo $_curMACCache
	return
    fi

    local _IP=;
    for i in `getConfFilesList "${1}"`;do
	_IP=`sed -n '
             s/\t//g;
             /^#/d;
             s/.*mac *=[^[:xdigit:]]*//;
             s/[^[:xdigit:]]*\([[:xdigit:]][[:xdigit:]]\:[[:xdigit:]][[:xdigit:]]\:[[:xdigit:]:]*\).*/\1/p
             ' "${i}"|\
             awk '{if(x){printf(" %s",$0);}else{printf("%s",$0);}x=1;}'`;
        _curMACCache=$_IP
        [ "$_IP" != "" ]&&break;
    done
    if [ "${_IP// /}" != "" ];then
	printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from ${1}"
	echo "$_IP"
        return
    fi
    getMAC "${1}"
}


#FUNCBEG###############################################################
#NAME:
#  getMAClst_XEN
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
# Extracts a list of 
#
#
#EXAMPLE:
#
# vif = ['mac=00:50:56:13:11:41, bridge=xenbr0']
# vif = ['mac=00:50:56:13:11:41, bridge=br0', 'mac=00:50:56:13:11:42, bridge=br1']
#
#PARAMETERS:
#  $1: Name of "ID" or "PNAME" containing the configuration.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#   $?
#  VALUES:
#   
#
#FUNCEND###############################################################
function getMAClst_XEN () {
    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=<${@}>"
    local _IP=;
    local _localMACCache=;

    for i in `getConfFilesList "${1}"`;do
        #set up an index for position, this is similar handled to eth-numbering
	_IP=`awk '
               $0~/mac/{
                 gsub("mac","\nmac");
                 print;
               }' "${i}"|\
             sed -n '
               s/\t//g;
               s/ //g;
               /^mac=/!d;
               s/.*mac *=[^[:xdigit:]]*//;
               s/[^[:xdigit:]]*\([[:xdigit:]][[:xdigit:]]\:[[:xdigit:]][[:xdigit:]]\:[[:xdigit:]:]*\).*/\1/g
               p;
               ' |\
               awk '{if(x){printf(" %s",$0);}else{printf("%s",$0);}x=1;}'
             `;
        [ -z "${_IP// /}" ]&&continue;
	printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_IP=<${_IP}>"
	local _cnt=0;
	for i in ${_IP};do
	    _localMACCache="${_localMACCache} ${_cnt}=${i}"
	    let _cnt++;
	done
	printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_localMACCache=${_localMACCache}"
        [ "$_IP" != "" ]&&break;
    done
    if [ -n "${_localMACCache// /}" ];then
	printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_localMACCache=${_localMACCache} from ${1}"
	echo $_localMACCache
        return
    fi
    getMAClst "${1}"
}



