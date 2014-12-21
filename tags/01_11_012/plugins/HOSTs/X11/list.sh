#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_06_001a11
#
########################################################################
#
# Copyright (C) 2007 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

_myPKGNAME_X11_LIST="${BASH_SOURCE}"
_myPKGVERS_X11_LIST="01.01.001a00"
hookInfoAdd $_myPKGNAME_X11_LIST $_myPKGVERS_X11_LIST
_myPKGBASE_X11_LIST="`dirname ${_myPKGNAME_X11_LIST}`"


#FUNCBEG###############################################################
#NAME:
#  listMySessionsX11
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
#    output format: "host:label:id:UUID:pid:uid:gid:sessionType:clientServer"
#
#FUNCEND###############################################################
function listMySessionsX11 () {
    local _site=$1 #only this is relevant for X11


    printDBG $S_X11 ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME ${*}"
    if [ "${C_SESSIONTYPE}" != "X11" -a "${C_SESSIONTYPE}" != "ALL" ];then 
        ABORT=2
        printERR $LINENO $BASH_SOURCE ${ABORT} "Unexpected session type:C_SESSIONTYPE=${C_SESSIONTYPE}"
        gotoHell ${ABORT}
    fi

    #the XClient is now actually a client.
    if [ "$_site" == B -o "$_site" == C ];then
        #controls debugging for awk-scripts
	doDebug $S_GEN  ${D_MAINT} $LINENO $BASH_SOURCE
	local D=$?

	local SERVERLST=`listProcesses|awk '/CTYS-X11-/&&!/awk/{print;}'`
	printDBG $S_X11 ${D_BULK} $LINENO $BASH_SOURCE "SERVERLST(RAW)=${SERVERLST}"
	local SERVERLST1=`echo "${SERVERLST}"|awk -v d="${D}" -f ${_myPKGBASE_X11}/serverlst01-${MYOS}.awk`
	printDBG $S_X11 ${D_MAINT} $LINENO $BASH_SOURCE "SESLST(PROCESSED)=\"${SERVERLST1}\""
	local i=;
	for i in ${SERVERLST1};do
	    printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE "i=${i}"
	    i="${MYHOST};${i}"
	    local RES0=""
	    local IFNAME=""
	    local CSTR=""
	    local EXEP="${i%;}"
	    EXEP="${EXEP##*;}"
	    printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE "EXEP=${EXEP}"
	    local HRX="${X11_PRODVERS}"
	    local ACC=""
	    local ARCH="$(getCurArch)"
	    i="${i%;*;};${RES0};${IFNAME};${CSTR};${EXEP};${HRX};${ACC};${ARCH}"
	    printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE "MATCH=${i}"
	    echo "${i}"
	done
    fi
}
