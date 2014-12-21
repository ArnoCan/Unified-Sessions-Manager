#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@users.sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_10_010
#
########################################################################
#
# Copyright (C) 2007,2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

_myPKGNAME_QEMU_LIST="${BASH_SOURCE}"
_myPKGVERS_QEMU_LIST="01.10.010"
hookInfoAdd $_myPKGNAME_QEMU_LIST $_myPKGVERS_QEMU_LIST
_myPKGBASE_QEMU_LIST="`dirname ${_myPKGNAME_QEMU_LIST}`"


#FUNCBEG###############################################################
#NAME:
#  listMySessionsQEMU
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Lists all QEMU sessions.
#
#EXAMPLE:
#
#PARAMETERS:
# $1: C|S|B
#     determines the filter to be applied.
#     C: clients
#     S: servers
#     B: both
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function listMySessionsQEMU () {
    local _site=$1;shift

    printDBG $S_QEMU ${D_BULK} $LINENO $BASH_SOURCE "QEMU_MAGIC  =${QEMU_MAGIC}"
    local CLIENTLST=;
    local SERVERLST=;

    #controls debugging for awk-scripts
    doDebug $S_QEMU  ${D_MAINT} $LINENO $BASH_SOURCE
    local D=$?

    local _ugid=;
    _ugid=${_ugid:-;}

    printDBG $S_QEMU ${D_BULK} $LINENO $BASH_SOURCE "_site=${_site}"

    printDBG $S_QEMU ${D_BULK} $LINENO $BASH_SOURCE "D=${D}"

    case ${QEMU_MAGIC} in
	QEMU_*)
            #get-call for LABEL
	    local _call1="sed -n 's/\t//g;/^#[^@]/d;s/#@#LABEL *= *\"\\\([^\"]*\\\)\"/\\\1/p' ";

            #get-call for UUID
	    local _call2="sed -n 's/[ -]//g;s/#@#UUID *= *\"\\\([^\"]*\\\)\"/\\\1/p' ";

            #get-call for TCP
	    local _call3="sed -n 's/[ -]//g;s/#@#IP0 *= *\"\\\([^\"]*\\\)\"/\\\1/p' ";

	    if [ "${_site}" == S -o "${_site}" == B ];then
		SERVERLST=`listProcesses|awk -v myProcLst="${QEMU_EXELIST_BASENAME}" -v mycallpath="${MYLIBEXECPATH}" -v _c1="$_call1" -v _c2="$_call2" -v _c3="$_call3" -v f=$_F -v d=$D -v cdargs="${C_DARGS}" -v s=$SUBTYPE -v vncbase="${VNC_BASEPORT}" -f ${_myPKGBASE_QEMU}/qemulst01.awk`
	    fi
 	    if [ "${_site}" == C -o "${_site}" == B ];then
		printWNG 3 $LINENO $BASH_SOURCE 0 "LIST for clients is not supported, these are managed"
		printWNG 3 $LINENO $BASH_SOURCE 0 "by their specific plugin:VNC|X11|CLI"
 		CLIENTLST=;
 	    fi
  	    ;;
        RELAY)#no own client support, see hosts plugins
            ;;
	*)  
	    if [ "QEMU_STATE" != DISABLED ];then
                #ooooops!!!!!!
		ABORT=2
		printERR $LINENO $BASH_SOURCE ${ABORT} "mismatch:QEMU_MAGIC=${QEMU_MAGIC}"
		return ${ABORT}
#		gotoHell ${ABORT}
	    fi
	    ;;
    esac

    printDBG $S_QEMU ${D_BULK} $LINENO $BASH_SOURCE "SERVERLST(RAW)=<${SERVERLST}>"
    printDBG $S_QEMU ${D_BULK} $LINENO $BASH_SOURCE "CLIENTLST(RAW)=<${CLIENTLST}>"

    if [ -z "${SERVERLST}" -a -z "${CLIENTLST}" ];then
        printDBG $S_QEMU ${D_BULK} $LINENO $BASH_SOURCE "No sessions yet."
	return
    fi

    export -f getClientTPQEMU
    export -f printDBG
    export -f printERR
    export -f gotoHell
    export QEMU_MAGIC

    local reserved01=";;"
    local cstrg=;
    local hrx=;
    local exep=;
    local acc=;
    local arch=;

    printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "SERVERLST(PROCESSED)=\"${SERVERLST}\""
    printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "CLIENTLST(PROCESSED)=\"${CLIENTLST}\""
    for i in ${SERVERLST} ${CLIENTLST};do
	_myPid=${i#*;*;*;*;*;*;*;}
	_myPid=${_myPid%%;*}
	printDBG $S_QEMU ${D_BULK} $LINENO $BASH_SOURCE "_myPid=${_myPid}"
	if [ -n "${_myPid}" ];then
	    _myJobID=`cacheGetAttrFromPersistent LAZY "${_myPid}" JOBID`
	    printDBG $S_QEMU ${D_BULK} $LINENO $BASH_SOURCE "_myJobID=${_myJobID}"

	    cstrg="";
	    exep="${i%;}";
	    exep="${exep##*;}";
	    exep=$(PATH=${PATH}:${QEMU_PATHLIST}&&gwhich ${exep} 2>/dev/null);
	    hrx=$(getHYPERRELRUN_QEMU ${exep});
	    acc=$(getACCELERATOR_QEMU ${exep});
	    arch=;
	    i="${i%;*;}${_myJobID};${reserved01}${cstrg};${exep};${hrx};${acc};${arch}";
 	fi
        i="${MYHOST};${i}"
	printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "MATCH=${i}"
	echo "${i}"
    done
}
