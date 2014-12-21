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


_myLIBNAME_VBOX="${BASH_SOURCE}"
_myLIBVERS_VBOX="01.01.011b01"
libManInfoAdd "${_myLIBNAME_VBOX}" "${_myLIBVERS_VBOX}"

export _myLIBBASE_VBOX="`dirname ${_myLIBNAME_VBOX}`"


#FUNCBEG###############################################################
#NAME:
#  fetchState
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: name|uuid|path(convention!)
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function fetchState  {
    [ -z "${VBOXMGR}" ]&&return 1;

    local myID=$1
    if [ "${myID//\//}" != "${myID}" ];then
	myID="${myID##*/}";
	myID="${myID%.*}";
    fi

    local _ms=$(${VBOXMGR} showvminfo $myID --machinereadable|\
        sed -n 's/^VMState="\(.*\)"$/\1/p'|awk '{printf("%s",$0);}')
    case ${_ms// /} in
	paused)   _ms=PAUSE;;
	saved)    _ms=SUSPEND;;
	running)  _ms=ACTIVE;;
	poweroff) _ms=DEACTIVE;;
    esac
    echo -n $_ms
}


#FUNCBEG###############################################################
#NAME:
#  fetchMAC
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: name|uuid|path(convention!)
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function fetchMAC  {
    [ -z "${VBOXMGR}" ]&&return 1;

    local myID=$1
    if [ "${myID//\//}" != "${myID}" ];then
	myID="${myID##*/}";
	myID="${myID%.*}";
    fi

    $VBOXMGR showvminfo $myID |\
        sed -n '
           s/NIC .*MAC: *\([0-9ABCDEF][0-9ABCDEF]\)\([0-9ABCDEF][0-9ABCDEF]\)\([0-9ABCDEF][0-9ABCDEF]\)\([0-9ABCDEF][0-9ABCDEF]\)\([0-9ABCDEF][0-9ABCDEF]\)\([0-9ABCDEF][0-9ABCDEF]\).*/\1:\2:\3:\4:\5:\6/p
        '|\
        awk 'BEGIN{x="";}{if(x!~/^$/){x=x" "$0;}else{x=x""$0;}}END{printf("%s",x);}'
}


#FUNCBEG###############################################################
#NAME:
#  fetchUUID
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: name|uuid|path(convention!)
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function fetchUUID  {
    [ -z "${VBOXMGR}" ]&&return 1;

    local myID=$1
    if [ "${myID//\//}" != "${myID}" ];then
	myID="${myID##*/}";
	myID="${myID%.*}";
    fi
    local _mycall="$VBOXMGR showvminfo $myID --machinereadable|awk -F'=' '/uuid=/{gsub(\"\\\"\",\"\",\$2);printf(\"%s\",\$2);}'"
    printFINALCALL 0  $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${_mycall}"
    if [ -n "$myID" ];then
	eval ${_mycall}
	return $?
    else
	ABORT=1
	printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:Missing ID"
	return 1
    fi
}


#FUNCBEG###############################################################
#NAME:
#  fetchNAME
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: name|uuid|path(convention!)
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function fetchNAME  {
    [ -z "${VBOXMGR}" ]&&return 1;

    local myID=$1
    if [ "${myID//\//}" != "${myID}" ];then
	myID="${myID##*/}";
	myID="${myID%.*}";
    fi
    local _mycall="$VBOXMGR showvminfo $myID --machinereadable|awk -F'=' '/name=/{gsub(\"\\\"\",\"\",\$2);printf(\"%s\",\$2);}'"
    printFINALCALL 0  $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${_mycall}"
    if [ -n "$myID" ];then
	eval ${_mycall}
	return $?
    else
	ABORT=1
	printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:Missing Name"
	return 1
    fi
}


#FUNCBEG###############################################################
#NAME:
#  fetchCFGFile
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: name|uuid|path(convention!)
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function fetchCFGFile  {
    [ -z "${VBOXMGR}" ]&&return 1;

    local myID=$1
    if [ "${myID//\//}" != "${myID}" ];then
	myID="${myID##*/}";
	myID="${myID%.*}";
    fi
    local _mycall="$VBOXMGR showvminfo $myID --machinereadable|awk -F'=' '/CfgFile=/{gsub(\"\\\"\",\"\",\$2);printf(\"%s\",\$2);}'"
    printFINALCALL 0  $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${_mycall}"
    if [ -n "$myID" ];then
	eval ${_mycall}
	return $?
    else
	ABORT=1
	printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:Missing Name"
	return 1
    fi
}


#FUNCBEG###############################################################
#NAME:
#  fetchCTYSFile
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: name|uuid|path(convention!)
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function fetchCTYSFile  {
    [ -z "${VBOXMGR}" ]&&return 1;

    local myNAME=$(fetchNAME $1);
    if [ -z "${myNAME}" ];then
	return 1
    fi

    local myID=$1
    if [ "${myID//\//}" != "${myID}" ];then
	if [ "${myID}" != "${myID%/$myNAME\/$myNAME.ctys}" ];then
	    echo -n "$1"
	    return 0
	fi
	return 1
    fi

    #might suffice in almost any case
    myID=$(
      $VBOXMGR showvminfo $myID --machinereadable|awk -F'=' -v n="$myNAME" '
        $0~n"/"n".vdi"{gsub("\"","",$2);printf("%s",$2);}
       '|sort -u);

    myID=${myID//.vdi/.ctys}
    if [ -n "$myID" ];then
	echo -n "$myID"
	return 0
    else
	ABORT=1
	printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:Missing ID"
	return 1
    fi
}


#FUNCBEG###############################################################
#NAME:
#  fetchCTYSDir
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: name|uuid|path(convention!)
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function fetchCTYSDir  {
    local myDIR=$(fetchCTYSFile $1);
    if [ -z "${myDIR}" ];then
	return 1
    fi

    myDIR0=${myDIR%/*}/
    if [ "${myDIR0}" != "${myDIR}" ];then
	echo -n "${myDIR0}"
	return 0
    fi
    return 1
}



#FUNCBEG###############################################################
#NAME:
#  getRDPport
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: name|uuid|path(convention!)
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getRDPport  {
    [ -z "${VBOXMGR}" ]&&return 1;

    local myID=$1
    if [ "${myID//\//}" != "${myID}" ];then
	myID="${myID##*/}";
	myID="${myID%.*}";
    fi
                    
    local _mycall="$VBOXMGR showvminfo $myID --machinereadable|awk -F'=' '/vrdpport=/{gsub(\"\\\"\",\"\",\$2);printf(\"%s\",\$2);}'"
    printFINALCALL 0  $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${_mycall}"
    if [ -n "$myID" ];then
	eval ${_mycall}
	return $?
    else
	ABORT=1
	printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:Missing ID"
	return 1
    fi
}


#FUNCBEG###############################################################
#NAME:
#  getRDPportlst
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: name|uuid|path(convention!)
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getRDPportlst  {
    [ -z "${VBOXMGR}" ]&&return 1;

    local myID=$1
    if [ "${myID//\//}" != "${myID}" ];then
	myID="${myID##*/}";
	myID="${myID%.*}";
    fi

    local _mycall="$VBOXMGR showvminfo $myID --machinereadable|awk -F'=' '/vrdpports=/{gsub(\"\\\"\",\"\",\$2);printf(\"%s\",\$2);}'"
    printFINALCALL 0  $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${_mycall}"
    if [ -n "$myID" ];then
	eval ${_mycall}
	return $?
    else
	ABORT=1
	printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:Missing ID"
	return 1
    fi
}



#FUNCBEG###############################################################
#NAME:
#  checkIsInInventory
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: name|uuid|pathname(convention!)
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function checkIsInInventory  {
    local xtmp=$(fetchUUID $1);
    [ -n "${xtmp// /}" ]&&return 0||return 1;
}

#FUNCBEG###############################################################
#NAME:
#  inventoryAdd
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: name|uuid|pathname(convention!)
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function inventoryAdd  {
	return 1
}

#FUNCBEG###############################################################
#NAME:
#  inventoryRemove
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: name|uuid|pathname(convention!)
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function inventoryRemove  {
	return 1
}


export -f fetchMAC
export VBOXMGR



#FUNCBEG###############################################################
#NAME:
#  ctysVBOXListClientServers
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
function ctysVBOXListClientServers () {
#4TEST:D=0
    listProcesses|awk -v d=$D -v c=1 -f ${_myLIBBASE_VBOX}/libVBOX.d/libVBOX.awk;
}


#FUNCBEG###############################################################
#NAME:
#  ctysVBOXListLocalServers
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
function ctysVBOXListLocalServers () {
#4TEST:D=0
    ctysVBOXListClientServers
    listProcesses|awk -v d=$D -v s=1 -f ${_myLIBBASE_VBOX}/libVBOX.d/libVBOX2.awk;
}

