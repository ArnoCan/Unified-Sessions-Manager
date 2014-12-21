#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_07_001b05
#
########################################################################
#
# Copyright (C) 2007,2008 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

_myPKGNAME_VNC_LIST="${BASH_SOURCE}"
_myPKGVERS_VNC_LIST="01.07.001b05"
hookInfoAdd $_myPKGNAME_VNC_LIST $_myPKGVERS_VNC_LIST
_myPKGBASE_VNC_LIST="`dirname ${_myPKGNAME_VNC_LIST}`"



#FUNCBEG###############################################################
#NAME:
#  listMySessionsVNC
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
function listMySessionsVNC () {
    local _site=$1;shift

    printDBG $S_VNC ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME ${*}"

    #controls debugging for awk-scripts
    doDebug $S_GEN  ${D_MAINT} $LINENO $BASH_SOURCE
    local D=$?

    if [ "${_site}" == S -o "${_site}" == B ];then
	case ${MYDIST} in
	    debian|Ubuntu)
                #Reminder on "Xrealvnc": Yes, an "Extrawurst" for anyone!
		local SERVERLST=`listProcesses|egrep '(Xrealvnc :|Xvnc :|Xvnc4 :)'|grep -v grep`
		printDBG $S_VNC ${D_BULK} $LINENO $BASH_SOURCE "SERVERLST(RAW)=${SERVERLST}"
		SERVERLST=`echo "${SERVERLST}"|awk -v d="${D}" -f ${_myPKGBASE_VNC}/serverlst01-${MYOS}.awk`
		;;
	    SunOS)
                #Reminder Due to limited ps, with restricted args
		local SERVERLST=`listProcesses|egrep '(Xrealvnc :|Xvnc :|Xvnc4 :)'|grep -v grep`
		printDBG $S_VNC ${D_BULK} $LINENO $BASH_SOURCE "SERVERLST(RAW)=${SERVERLST}"
		SERVERLST=`echo "${SERVERLST}"|awk -v d="${D}" -f ${_myPKGBASE_VNC}/serverlst01-${MYOS}.awk`
		;;
	    *)
		local SERVERLST=`listProcesses|egrep '(Xrealvnc :|Xvnc :|Xvnc4 :)'|grep -v grep`
		printDBG $S_VNC ${D_BULK} $LINENO $BASH_SOURCE "SERVERLST(RAW)=${SERVERLST}"
		SERVERLST=`echo "${SERVERLST}"|awk -v d="${D}" -f ${_myPKGBASE_VNC}/serverlst01-${MYOS}.awk`
		;;
	esac
        printDBG $S_VNC ${D_BULK} $LINENO $BASH_SOURCE "SERVERLST(PROCESSED)=${SERVERLST}"
    fi

    if [ "${_site}" == C -o "${_site}" == B -a -z "$CTYSLIST79RECCNT" ];then
	local CLIENTLST=`listProcesses|grep 'vncviewer'|grep -v grep`
        printDBG $S_VNC ${D_BULK} $LINENO $BASH_SOURCE "CLIENTLST(RAW)=<${CLIENTLST}>"

        CLIENTLST=`echo "${CLIENTLST}"|awk -v d="${D}" -f ${_myPKGBASE_VNC}/clientlst01-${MYOS}.awk`

        printDBG $S_VNC ${D_BULK} $LINENO $BASH_SOURCE "CLIENTLST(PROCESSED-0)=<${CLIENTLST}>"
        case $VNC_MAGIC in
	    VNCT)
                #now in canonical format and does not need exported funcs
                #correct reduced cli-footprint of forked vncviewer-child
		local il=;
		local il0=;
		local il1=;
		local il1x=;

		for il in ${CLIENTLST};do
		    if [ -z "$_c" ];then
			local _c=1;
			CLIENTLST=;
		    fi
		    ila="${il%%;*}";                   
		    il1="${il#*;}";il1="${il1%%;*}";
		    il1x="${il#*;*;}";
		    printDBG $S_VNC ${D_BULK} $LINENO $BASH_SOURCE "il0=${il0}<>${il1}/${ila}+${il1}+${il1x}"
		    if [ "${ila}" == "localhost" ];then
			if [ -z "$CTYSLIST79RECCNT" ];then
			    export CTYSLIST79RECCNT=1;
			    il0=`fetchLabel4ID "${il1}"`
			    unset CTYSLIST79RECCNT;
			    CLIENTLST="${CLIENTLST} ${il0};${il1};${il1x}"
			fi
		    else
			CLIENTLST="${CLIENTLST} $il"
		    fi
		    printDBG $S_VNC ${D_BULK} $LINENO $BASH_SOURCE "ila=${ila}+il0=${il0}+il1x=${il1x}"
		done
		;;
	esac

        printDBG $S_VNC ${D_BULK} $LINENO $BASH_SOURCE "CLIENTLST(PROCESSED)=${CLIENTLST}"
    fi

    local SESLST="${CLIENTLST} ${SERVERLST}"


    printDBG $S_VNC ${D_MAINT} $LINENO $BASH_SOURCE "SESLST(PROCESSED)=\"${SESLST}\""
    local _i=;
    local _myPid=;
    local _myJobID=;
    for _i in ${SESLST};do
	_myPid=${_i#*;*;*;*;*;*;*;}
	_myPid=${_myPid%%;*}
	printDBG $S_VNC ${D_BULK} $LINENO $BASH_SOURCE "_myPid=${_myPid}"
	if [ -n "${_myPid}" ];then
	    _myJobID=`cacheGetAttrFromPersistent LAZY "${_myPid}" JOBID`
	    printDBG $S_VNC ${D_BULK} $LINENO $BASH_SOURCE "_myJobID=${_myJobID}"

 	fi
	_i="${MYHOST};${_i}"
	local EXEP="${_i%;}"
	EXEP="${EXEP##*;};"
        _i="${_i%;*;};${_myJobID};";
	local RES0=";"
	local RES1=";"
	local CTXS=";"
	local HRX="${VNC_PRODVERS};"
	local ACC=";"
	local ARCH="$(getCurArch)"
	_i="${_i}${RES0}${RES1}${CTXS}${EXEP}${HRX}${ACC}${ARCH}"
	printDBG $S_VNC ${D_UID} $LINENO $BASH_SOURCE "MATCH=${_i}"
	echo "${_i}"
    done
}


