#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_011alpha
#
########################################################################
#
# Copyright (C) 2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################



#FUNCBEG###############################################################
#NAME:
#  getVBOXVMVal
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: UUID|vm-name
#  $2: value
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getVBOXVMVal () {
    printDBG $S_VMW ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:FName=${FName}"
    if [ -z "${VBOXMGR}" ];then
	ABORT=2;
	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing VBOXMGR"
	gotoHell ${ABORT}  
    fi
    if [ -n "${1}" -a -n "${2}" ];then
	local _v=$(${VBOXMGR} showvminfo "$1" -machinereadable 2>/dev/null|sed -n 's/^'"${2}"'="*\([^" ]\+\)"*/\1/p');
	printDBG $S_VMW ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:_v=$_v"
	echo "$_v"
	return 0
    fi
    return 1
}



#FUNCBEG###############################################################
#NAME:
#  checkVBOXVMSTATE
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
function checkVBOXVMSTATE () {

    FName="${1##*/}"
    FName="${FName%.vdi}"

    DName="${1%/*}"
    DName="${DName##*/}"

    printDBG $S_VMW ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:DName=${DName}"
    printDBG $S_VMW ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:FName=${FName}"

    #
    #check convention: system-hdd-prefix == contains-directory-name
    if [ "${FName}" != "${DName}" ];then
	return 1
    fi
    printDBG $S_VMW ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME"

    #
    #check imagefile by VBoxManage
    if [ -n "${FName}" ];then
	local _ret=$?
	${VBOXMGR} showvminfo $FName>/dev/null 2>/dev/null
	_ret=$?
	printDBG $S_VMW ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:X=$X($_ret)"
	return $_ret
    fi
    printDBG $S_VMW ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME"
    return 1
}





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
    local _f=${1};
    local _fx=${1//.ctys/.vdi}
    local _IP=;

    if [ -f "${_fx}" ];then
	_fx=${_fx##*/};_fx=${_fx%.*}
	local _IP=$(${VBOXMGR} showvminfo -machinereadable  "$_fx" 2>/dev/null|awk -F'=' '
                 /^macaddress[0-9]*/{
                      gsub(" ","",$2);gsub("\"","",$2);
                      z=gsub(":",":",colsA[5]);
                      if(z==0){
                          new=substr($2,1,2);
                          new=new":"substr($2,3,2);
                          new=new":"substr($2,5,2);
                          new=new":"substr($2,7,2);
                          new=new":"substr($2,9,2);
                          new=new":"substr($2,11,2);
                      }
                      gsub("^[^0-9]*","",$1);
                      x=x" "$1-1"="new
                 }
                 END{print x;}
             ');
	printDBG $S_VMW ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:_IP=$_IP"
    fi
    [ "$_IP" == "" ]&&_IP=`getMAClst ${_f}`;
    [ "$_IP" == "" ]&&return 1;
    echo "$_IP"
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
    local _f=${1##*/};_f=${_f%.*}
    _IP=`getVBOXVMVal "${_f}" UUID`
    _IP=${_IP//\"/}
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
	_IP=`cat  "${i}"|getConfValueOf "#@#LABEL"`
        [ "$_IP" != "" ]&&break;
    done
    if [ "$_IP" == "" ];then
	local _f=${1##*/};_f=${_f%.*}
	_IP=`getVBOXVMVal "${_f}" Name`
        [ "$_IP" == "" ]&&_IP=`getVBOXVMVal "${_f}" name`;
	[ "$_IP" == "" ]&&_IP="${_f}";
    fi
    _IP=${_IP//\"/}
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
    local _f=${1##*/};_f=${_f%.*}
    _IP=`getVBOXVMVal "${_f}" cpus`
    echo ${_IP##* }
}


#FUNCBEG###############################################################
#NAME:
#  getVBOXGUESTARCH
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
function getVBOXGUESTARCH () {
    local _IP=;
    [ -f "$1" ]&&_IP=$(getGUESTARCH $1)
    if [ "$_IP" == "" ];then
	local _f=${1##*/};_f=${_f%.*}
	_IP=`getVBOXVMVal "${_f}" ostype`
	case "${_IP//\"/}" in
	    '')_IP=;;
	    *_64)_IP=x86_64;;
	    *)_IP=i386;;
	esac
    fi
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
    local _f=${1##*/};_f=${_f%.*}
    _IP=`getVBOXVMVal "${_f}" ostype`
    _IP=${_IP//\"/}
    _IP=${_IP%_64}
    _IP=${_IP%_i386}
    echo ${_IP##* }
}

#FUNCBEG###############################################################
#NAME:
#  getVBOXACCEL
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
function getVBOXACCEL () {
    local _f=${1##*/};_f=${_f%.*}
    _IP=`getVBOXVMVal "${_f}" hwvirtex`
    _IP=${_IP//\"/}
    _IP=${_IP//on/VT}
    _IP=${_IP//off/}
    echo -n ${_IP##* }
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
    local _f=${1##*/};_f=${_f%.*}
    _IP=`getVBOXVMVal "${_f}" vrdpport`
    echo ${_IP##* }
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
    local _f=${1##*/};_f=${_f%.*}
    _IP=`getVBOXVMVal "${_f}" memory`
    echo ${_IP##* }
}


#FUNCBEG###############################################################
#NAME:
#  getVBOXBOOTHDDSIZE
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
function getVBOXBOOTHDDSIZE () {
    if [ -e "$1" ];then
	_IP=$(${VBOXMGR} -q showhdinfo "$1" 2>/dev/null|awk '/^Logical size:/{printf("%s",$3);}
           $4~/MBytes/{printf("M");}
           $4~/GBytes/{printf("G");}
           $4~/TBytes/{printf("T");}
           ');
    fi
    echo ${_IP##* }
}
