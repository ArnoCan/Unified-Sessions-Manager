#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_005
#
########################################################################
#
# Copyright (C) 2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################






#FUNCBEG###############################################################
#NAME:
#  getVBOXMAClst
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
function getVBOXMAClst () {
    local _IP=;
    for i in `getConfFilesList "${1}"`;do
#	    _IP=`sed -n 's/\t//g;/^#/d;s/ethernet\([0-9]*\).address *= *"\([^"]*\)"/\1=\2/p' "${i}"`;
	_IP=`sed -n 's/\t//g;/^#/d;s/ethernet\([0-9]*\).address *= *"\([^"]*\)"/\1=\2/p;s/ethernet\([0-9]*\).generatedAddress *= *"\([^"]*\)"/\1=\2/p' "${i}"`;
        [ "$_IP" != "" ]&&break;
    done
    echo $_IP
}




#FUNCBEG###############################################################
#NAME:
#  getVBOXUUID
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
function getVBOXUUID () {
    local _IP=;
    if [ -z "${1}" ];then
	gwhich dmidecode 2>/dev/null >/dev/null
	if [ $? == 0 ];then
	    _IP=`dmidecode |awk '/UUID/{if(NF==2)print $2}'|sed 's/-//g'`
	fi
    else
	for i in `getConfFilesList "${1}"`;do
	    _IP=`sed -n '/uuid.bios/!d;s/[ -]//g;p' "${i}"|getConfValueOf "uuid.bios"`
  	    [ "$_IP" != "" ]&&break;
	done
    fi
    echo ${_IP##* }
}



#FUNCBEG###############################################################
#NAME:
#  getVBOXLABEL
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
function getVBOXLABEL () {
    local _IP=;
    for i in `getConfFilesList "${1}"`;do
	_IP=`cat  "${i}"|getConfValueOf "displayName"`
  	[ "$_IP" != "" ]&&break;
	_IP=`cat  "${i}"|getConfValueOf "#@#LABEL"`
        [ "$_IP" != "" ]&&break;
    done
    echo ${_IP##* }
}



#FUNCBEG###############################################################
#NAME:
#  getVBOXGUESTVCPU
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
function getVBOXGUESTVCPU () {
    local _IP=;
    for i in `getConfFilesList "${1}"`;do
	_IP=`cat  "${i}"|getConfValueOf "numvcpus"`
  	[ "$_IP" != "" ]&&break;
	_IP=`cat  "${i}"|getConfValueOf "#@#VCPU"`
        [ "$_IP" != "" ]&&break;
    done
    echo ${_IP##* }
}



#FUNCBEG###############################################################
#NAME:
#  getVBOXOS
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
function getVBOXOS () {
    local _IP=;
    for i in `getConfFilesList "${1}"`;do
	_IP=`sed -n 's/^[^#]*guestOS *= *"\([^"]*\)"/\1/p' "${i}"|\
                   awk '{if(x){printf(" %s",$0);}else{printf("%s",$0);}x=1;}'`;
  	[ "$_IP" != "" ]&&break;
    done
    echo ${_IP##* }
}



#FUNCBEG###############################################################
#NAME:
#  getVBOXVNCACCESSPORT
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
function getVBOXVNCACCESSPORT () {
    local _IP=;
    for i in `getConfFilesList "${1}"`;do
 	_IP=`cat "${i}"|getConfValueOf "RemoteDisplay.vnc.port"`
        if [ "$_IP" != "" ];then
	    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from ${i}"
	    break;
	fi
    done
    if [ -n "${_IP// /}" ];then
	printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_IP=${_IP} from ${1}"
	echo ${_IP##* }
        return
    fi
    getVNCACCESSPORT "${1}"
}




#FUNCBEG###############################################################
#NAME:
#  getVBOXGUESTVRAM
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
function getVBOXGUESTVRAM () {
    local _IP=;
    for i in `getConfFilesList "${1}"`;do
	_IP=`cat  "${i}"|getConfValueOf "memsize"`
        if [ "$_IP" != "" ];then
	    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from ${i}"
	    break;
	fi
    done
    if [ -n "${_IP// /}" ];then
	printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_IP=${_IP} from ${1}"
	echo ${_IP##* }
        return
    fi
    getGUESTVRAM "${1}"
}
