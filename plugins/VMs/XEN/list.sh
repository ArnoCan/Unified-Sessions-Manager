#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_10_008
#
########################################################################
#
# Copyright (C) 2007,2008,2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

_myPKGNAME_XEN_LIST="${BASH_SOURCE}"
_myPKGVERS_XEN_LIST="01.10.008"
hookInfoAdd $_myPKGNAME_XEN_LIST $_myPKGVERS_XEN_LIST
_myPKGBASE_XEN_LIST="`dirname ${_myPKGNAME_XEN_LIST}`"


#FUNCBEG###############################################################
#NAME:
#  listMySessionsXEN
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Lists all XEN sessions.
#
#EXAMPLE:
#
#PARAMETERS:
# $1: (C|CLIENT)|(S|SERVER)|(B|BOTH)
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
function listMySessionsXEN () {
    local _site=$1;shift
    case $_site in
	B|BOTH)_site=B;;
	C|CLIENT)_site=C;;
	S|SERVER)_site=S;;
    esac

    printDBG $S_XEN ${D_BULK} $LINENO $BASH_SOURCE "XEN_MAGIC  =${XEN_MAGIC}"
    local CLIENTLST=;
    local SERVERLST=;

    #controls debugging for awk-scripts
    doDebug $S_XEN  ${D_MAINT} $LINENO $BASH_SOURCE
    local D=$?

    local _ugid=;
#alright: essential access requires root-permission, so no specific
#user owns a DomU exclusively, but root - even though someone else
#might have created it. So let it open here, gwhich defaults to use
#root when action required is mandatory.
#    _ugid=`getMyUGID`
    _ugid=${_ugid:-;}

    printDBG $S_XEN ${D_BULK} $LINENO $BASH_SOURCE "${_site} ${_site}"


    case ${XEN_MAGIC} in
	XEN_*)
	    if [ "${_site}" == S -o "${_site}" == B ];then
		if [ -n "${VIRSH}" ];then
                    #preferred
		    local _running=`callErrOutWrapper $LINENO $BASH_SOURCE ${VIRSHCALL} ${VIRSH} list |\
                                    awk 'BEGIN{b=0;}/-------/{b=1;next;}b==1&&$0!~/^ *$/{print $1";"$2}'`
		    local _l=;
                    local _cur=;
                    local _curid=;
		    for _l in ${_running};do
			_cur=`callErrOutWrapper $LINENO $BASH_SOURCE ${VIRSHCALL} ${VIRSH} dumpxml ${_l%;*}|\
                            awk -v d="${D}" -v voffset="${VNC_BASEPORT:-0}" -v ugid="${_ugid}" \
                            -f ${_myPKGBASE_XEN_LIST}/virshlst01.awk`
			printDBG $S_XEN ${D_BULK} $LINENO $BASH_SOURCE "_cur=<${_cur}>"
 			SERVERLST="${SERVERLST} ${_cur}"
		    done
		else
                    #should not occur!
		    ABORT=2
		    printERR $LINENO $BASH_SOURCE ${ABORT} "Requires VIRSH or XM"
		    gotoHell ${ABORT}
		fi
	    fi
 	    if [ "${_site}" == C -o "${_site}" == B ];then
		printWNG 2 $LINENO $BASH_SOURCE 0 "Sorry, LIST for clients is not supported, these are managed"
		printWNG 2 $LINENO $BASH_SOURCE 0 "by their specific plugin:VNC|X11|CLI"
 		CLIENTLST=;
 	    fi
  	    ;;
        RELAY)#no own client support, see hosts plugins
            ;;
        DISABLED)#nothing to do
            ;;
	*)  #ooooops!!!!!!
	    ABORT=2
	    printERR $LINENO $BASH_SOURCE ${ABORT} "mismatch:XEN_MAGIC=${XEN_MAGIC}"
	    gotoHell ${ABORT}
	    ;;
    esac

    printDBG $S_XEN ${D_BULK} $LINENO $BASH_SOURCE "SERVERLST(RAW)=<${SERVERLST}>"
    printDBG $S_XEN ${D_BULK} $LINENO $BASH_SOURCE "CLIENTLST(RAW)=<${CLIENTLST}>"

    if [ -z "${SERVERLST}" -a -z "${CLIENTLST}" ];then
        printDBG $S_XEN ${D_BULK} $LINENO $BASH_SOURCE "No sessions yet."
	return
    fi

    export -f getClientTPXEN
    export -f printDBG 
    export -f printERR
    export -f gotoHell
    export XEN_MAGIC

    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "SERVERLST(PROCESSED)=\"${SERVERLST}\""
    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "CLIENTLST(PROCESSED)=\"${CLIENTLST}\""

    local i=;
    local _myPid=;
    local _myJobID=;
    local _myUID=;
    local _myGID=;
    local reserved0123=";;;;"
    local qhrx=;
    local qacc=;
    local qarch=;

    local reserved01=";;"
    local cstrg=;
    local hrx=;
    local exep=;
    local acc=;
    local arch=;

    for i in ${SERVERLST} ${CLIENTLST};do
	_myPid=${i#*;*;*;*;*;*;*;}
	_myPid=${_myPid%%;*}
	_myPre=${i%;*;*;*;*;*;*;*}
	_myPost=${i#*;*;*;*;*;*;*;*;*;*;}

	printDBG $S_XEN ${D_BULK} $LINENO $BASH_SOURCE "_myPid=${_myPid}"
	if [ -n "${_myPid}" -a "${_myPid}" != 0 ];then
	    _myJobID=`cacheGetAttrFromPersistent LAZY "${_myPid}.${XENJOBPOSTFIX}" JOBID`
	    printDBG $S_XEN ${D_BULK} $LINENO $BASH_SOURCE "_myJobID=${_myJobID}"
	    _myUID=`cacheGetAttrFromPersistent LAZY "${_myPid}.${XENJOBPOSTFIX}" UID`
	    printDBG $S_XEN ${D_BULK} $LINENO $BASH_SOURCE "_myUID=${_myUID}"
	    _myGID=`cacheGetAttrFromPersistent LAZY "${_myPid}.${XENJOBPOSTFIX}" GID`
	    printDBG $S_XEN ${D_BULK} $LINENO $BASH_SOURCE "_myGID=${_myGID}"
	    i="${_myPre};${_myPid};${_myUID};${_myGID};${_myPost}${_myJobID}";
 	fi
	cstrg="";
	hrx=${XEN_PRODVERS};
	exep=$(getSTARTERCALL_XEN4CONF);
	acc=$(getACCELERATOR_XEN);
	arch=$(getARCHR_XEN);

        i="${MYHOST};${i}${reserved01};${cstrg};${exep};${hrx};${acc};${arch}";
	printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "MATCH=${i}"
	echo "${i}"
    done
}
