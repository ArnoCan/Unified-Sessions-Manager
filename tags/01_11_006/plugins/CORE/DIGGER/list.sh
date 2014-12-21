#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_02_007a17
#
########################################################################
#
# Copyright (C) 2007 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

_myPKGNAME_DIGGER_LIST="${BASH_SOURCE}"
_myPKGVERS_DIGGER_LIST="01.02.001b01"
hookInfoAdd $_myPKGNAME_DIGGER_LIST $_myPKGVERS_DIGGER_LIST
_myPKGBASE_DIGGER_LIST="`dirname ${_myPKGNAME_DIGGER_LIST}`"



#FUNCBEG###############################################################
#NAME:
#  listMySessionsDIGGER
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
#    output format: "host:label:id:UUID:pid:uid:gid:sessionType:clientServer:JobID"
#
#FUNCEND###############################################################
function listMySessionsDIGGER () {
    local _site=$1;shift

    #controls debugging for awk-scripts
    doDebug $S_CORE  ${D_MAINT} $LINENO $BASH_SOURCE
    local D=$?


    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME ${*}"

    local TUNNELLST=`listProcesses|grep 'DYNREMAP:'|grep -v grep`;
    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "TUNNELLST(RAW)=${TUNNELLST}"

    local TUNNELLST=`echo " ${TUNNELLST} "| sed -n '
      /# DYNREMAP/!d;
      s/^ *[^ ][^ ]*  *\([0-9][0-9]*\) .*# DYNREMAP:\([^:]*:[^:]*:[0-9]*:[^:]*:[^:]*:[^:]*:[^:]*:[^:]*:[^:]*:[^:]*:[^:]*\)[^:]*$/\1:\2/p'`;
    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "TUNNELLST(RAW)=${TUNNELLST}"
    
    TUNNELLST=`echo "${TUNNELLST}"|awk -F':' -v d="${D}" -f ${_myPKGBASE_DIGGER}/tunnellst01.awk`
    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "TUNNELLST(PROCESSED)=${TUNNELLST}"

    local _i=;
    for _i in ${TUNNELLST};do
	_i="${MYHOST};${_i}"
	printDBG $S_CORE ${D_UID} $LINENO $BASH_SOURCE "MATCH=${_i}"
	echo "${_i}"
    done
}


