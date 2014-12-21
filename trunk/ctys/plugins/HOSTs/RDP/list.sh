#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_006alpha
#
########################################################################
#
# Copyright (C) 2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

_myPKGNAME_RDP_LIST="${BASH_SOURCE}"
_myPKGVERS_RDP_LIST="01.11.006alpha"
hookInfoAdd $_myPKGNAME_RDP_LIST $_myPKGVERS_RDP_LIST
_myPKGBASE_RDP_LIST="`dirname ${_myPKGNAME_RDP_LIST}`"



#FUNCBEG###############################################################
#NAME:
#  listMySessionsRDP
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
function listMySessionsRDP () {
    local _site=$1;shift

    printDBG $S_RDP ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME ${*}"

    #controls debugging for awk-scripts
    doDebug $S_GEN  ${D_MAINT} $LINENO $BASH_SOURCE
    local D=$?

    if [ "${_site}" == S -o "${_site}" == B ];then
        #RDP is client only
	printDBG $S_RDP ${D_BULK} $LINENO $BASH_SOURCE "SERVERLST:Not applicable"
    fi

    if [ "${_site}" == S -o "${_site}" == C -o "${_site}" == B -a -z "$CTYSLIST79RECCNT" ];then
	local CLIENTLST=`listProcesses|egrep '(rdesktop|tsclient)'|grep -v grep`
        printDBG $S_RDP ${D_BULK} $LINENO $BASH_SOURCE "CLIENTLST(RAW)=<${CLIENTLST}>"
        CLIENTLST=`echo "${CLIENTLST}"|awk -v d="${D}" -f ${_myPKGBASE_RDP}/clientlst01-${MYOS}.awk`
        printDBG $S_RDP ${D_BULK} $LINENO $BASH_SOURCE "CLIENTLST(PROCESSED-0)=<${CLIENTLST}>"
        case $RDP_MAGIC in
	    RDPT)
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
		    printDBG $S_RDP ${D_BULK} $LINENO $BASH_SOURCE "il0=${il0}<>${il1}/${ila}+${il1}+${il1x}"
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
		    printDBG $S_RDP ${D_BULK} $LINENO $BASH_SOURCE "ila=${ila}+il0=${il0}+il1x=${il1x}"
		done
		;;
	esac

        printDBG $S_RDP ${D_BULK} $LINENO $BASH_SOURCE "CLIENTLST(PROCESSED)=${CLIENTLST}"
    fi

    local SESLST="${CLIENTLST}"


    printDBG $S_RDP ${D_MAINT} $LINENO $BASH_SOURCE "SESLST(PROCESSED)=\"${SESLST}\""
    local _i=;
    local _myPid=;
    local _myJobID=;
    for _i in ${SESLST};do
	_myPid=${_i#*;*;*;*;*;*;*;}
	_myPid=${_myPid%%;*}
	printDBG $S_RDP ${D_BULK} $LINENO $BASH_SOURCE "_myPid=${_myPid}"
	if [ -n "${_myPid}" ];then
	    _myJobID=`cacheGetAttrFromPersistent LAZY "${_myPid}" JOBID`
	    printDBG $S_RDP ${D_BULK} $LINENO $BASH_SOURCE "_myJobID=${_myJobID}"

 	fi
	_i="${MYHOST};${_i}"
	local EXEP="${_i%;}"
	EXEP="${EXEP##*;};"
        _i="${_i%;*;};${_myJobID};";
	local RES0=";"
	local RES1=";"
	local CTXS=";"
	local HRX="${RDP_PRODVERS};"
	local ACC=";"
	local ARCH="$(getCurArch)"
	_i="${_i}${RES0}${RES1}${CTXS}${EXEP}${HRX}${ACC}${ARCH}"
	printDBG $S_RDP ${D_UID} $LINENO $BASH_SOURCE "MATCH=${_i}"
	echo "${_i}"
    done
}


