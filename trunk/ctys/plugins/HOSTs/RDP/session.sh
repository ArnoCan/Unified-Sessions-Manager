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

_myPKGNAME_RDP_SESSION="${BASH_SOURCE}"
_myPKGVERS_RDP_SESSION="01.11.006alpha"
hookInfoAdd $_myPKGNAME_RDP_SESSION $_myPKGVERS_RDP_SESSION
_myPKGBASE_RDP_SESSION="`dirname ${_myPKGNAME_RDP_SESSION}`"


#FUNCBEG###############################################################
#NAME:
#  getClientTPRDP
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
# GENERIC-IF-DESCRIPTION:
#  Gives the termination points port number, to gwhich a client could be 
#  attachhed. This port is forseen to be used in port-forwarding e.g.
#  by OpenSSH.
#
#EXAMPLE:
#
#PARAMETERS:
#  <label>
#    The <label> to gwhich the client will be attached.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#    0: If OK
#    1: else
#
#  VALUES:
#    <TP-port>
#      The TP port, to gwhich a client could be attached.
#
#FUNCEND###############################################################
function getClientTPRDP () {
    local _arg0=${1}

    printDBG $S_RDP ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME Label=$_arg0"

    local _port=`fetchID4Label ${_arg0}`;
    if [ -z "${_port}" ];then
        _port=`fetchLabel4ID ${_arg0}`;
    fi
    if [ -z "${_port}" ];then
	ABORT=2
	printINFO 2 $LINENO $BASH_SOURCE 0 "${FUNCNAME}:Cannot get port number for label:${1}"
	gotoHell ${ABORT}
    fi

    local _ret=;
    let _ret=RDP_BASEPORT+_port;
    
    printDBG $S_RDP ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME port number=$_ret from ID=$_port"
    echo ${_ret}
}


#FUNCBEG###############################################################
#NAME:
#  startSessionRDP
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: label
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function startSessionRDP () {
    printDBG $S_RDP ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME"
    local _name=${1:-DEFAULT-`date +%y%m%d%H%M%S`}
    printDBG $S_RDP ${D_UI} $LINENO $BASH_SOURCE "${RDPSERVER} <session-label>:${_name}"
    checkUniqueness4Label ${_name};
    if [ $? -eq 0 ];then
	local _unique=1
    else
	if [ -z "${C_ALLOWAMBIGIOUS}" ];then
	    ABORT=2
	    printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Ambigious <session-label>:${_name}"
	    printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:RDP is as default in \"shared\" mode, use \"-A\" if required."
	    gotoHell ${ABORT}
	else 
	    printWNG 1 $LINENO $BASH_SOURCE ${RET} "${FUNCNAME}:Reuse ambigious label:${_name}"
	fi
    fi
    local _vieweropt="${RDPC_OPT} ${C_GEOMETRY:+ -g $C_GEOMETRY} "
    printDBG $S_RDP ${D_MAINT} $LINENO $BASH_SOURCE "CURSES=$CURSES"
    printDBG $S_RDP ${D_MAINT} $LINENO $BASH_SOURCE "C_CLIENTLOCATION=<$C_CLIENTLOCATION>"
    printDBG $S_RDP ${D_MAINT} $LINENO $BASH_SOURCE "CALLERJOB=<$CALLERJOB>"
    printDBG $S_RDP ${D_MAINT} $LINENO $BASH_SOURCE "JOB_IDXSUB=<$JOB_IDXSUB>"
    if [ "${C_CLIENTLOCATION}" !=  "-L SERVERONLY" ];then
	local CALLER=;
	CALLER="export C_ASYNC=${C_ASYNC}&&${RDPC}  "
#	CALLER="${CALLER} ${C_DARGS} "
	CALLER="${CALLER} -T \"${_name}:${CURSES}\" "
	CALLER="${CALLER} ${_vieweropt} localhost:${CURSES} "

	printDBG $S_RDP ${D_MAINT} $LINENO $BASH_SOURCE "${C_NOEXEC:-CALL:}${CALLER}"
        #don't exec here, it could be one of a set!
	printDBG $S_RDP ${D_UID} $LINENO $BASH_SOURCE "WAITS=${WAITS}"
	printFINALCALL $LINENO $BASH_SOURCE "WAIT-TIMER:vncserver(${_label},WAITS)" "sleep ${WAITS}"
	printFINALCALL $LINENO $BASH_SOURCE "FINAL-RDP-CONSOLE:STARTER(${_label})" "${CALLER}"
	if [ -z "${C_NOEXEC}" ];then

	    if [ -n "${C_DISPLAY}" ];then
		DISPLAY=":${C_DISPLAY}";
		export DISPLAY;
	    fi
	    printFINALCALL $LINENO $BASH_SOURCE "FINAL-RDP-CONSOLE:STARTER(${_label})-DISPLAY=\"${DISPLAY}\"" "${CALLER}"

	    case ${C_DISPLAY// /} in
		*[a-z][A-Z]*)
		    export DISPLAY=":$(C_SESSIONTYPE=ALL fetchDisplay4Label ALL ${C_DISPLAY})";
		    ;;
		'')
		    ;;
		*)
		    export DISPLAY=":${C_DISPLAY}";
		    ;;
	    esac
	    eval ${CALLER} &sleep ${CTYS_PREDETACH_TIMEOUT:-10}>/dev/null&
	    sleep ${WAITS:-1}
 	    cacheStoreWorkerPIDData CLIENT RDP "${CURSES}" "${_name}" 0 "" 
	    if [ $? -ne 0 ];then
		printWNG 1 $LINENO $BASH_SOURCE 0  "$FUNCNAME:RDP:Failed to store runtime JobData for CLIENT:\"${_name}\""
		printWNG 1 $LINENO $BASH_SOURCE 0  "$FUNCNAME:RDP: =>Restart of CLIENT should be sufficient."
	    fi
	    if [ "${C_ASYNC}" == 0 ];then
		wait
	    fi
	fi
    fi
}


#FUNCBEG###############################################################
#NAME:
#  connectSessionRDP
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: <session-id>
#      This is calculated from the port, and is the offset to that.
#      The base-value is normally 5900 for RealRDP+TIghtRDP.
#      TightRDP might allow the selection of another port.
#
#  $2: <session-label>
#      This will be used for the title of the client window.
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function connectSessionRDP () {
    local _id0=${1}
    local _id=`removeLeadZeros ${1}`
    local _label=${2}
    printDBG $S_RDP ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME ${_id0}->${_id} ${_label}"

    if [ -z "${_label}" -a -z "${_id}" ];then
	ABORT=1
	printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:At least one parameter required:<session-id> or <session-label>"
	gotoHell ${ABORT}
    fi

    #not-having could be tolerated, even though something might be basically wrong.
    if [ -z "${_label}" -a -n "${_id}"   ]; then 
	_label=`fetchLabel4ID ${_id}`;
	if [ -z "${_label}" ];then
	    _label=DEFAULT;
	fi
    fi

    #missing could definitely NOT be tolerated, so abort if fails.
    if [ -n "${_label}" -a -z "${_id}" ]; then 
	_id=`fetchID4Label ${_label}`;
	if [ -z "${_id}" ];then
	    ABORT=1
	    printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Fetch of <session-id> failed:_label=${_label}"
	    gotoHell ${ABORT}
	fi
    fi

    #even though this condition might be impossible now, let it beeeee ...
    if [ -z "${_label}" -a -z "${_id}" ];then
	ABORT=1
	printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Fetch of peer entry failed:_id=${_id} - _label=${_label}"
	gotoHell ${ABORT}
    fi

    printDBG $S_RDP ${D_FRAME} $LINENO $BASH_SOURCE "OK:_id=${_id} - _label=${_label}"
    #
    #Now shows name+id in title, id could not be set for server as default.
    local _vieweropt="-T ${_label}:${_id} ${RDPC_OPT} ${C_GEOMETRY:+ -g $C_GEOMETRY} "
    if [ -n "${INSECURE}" ];then
	local CALLER="${RDPVIEWER} ${C_DARGS} ${_vieweropt} ${INSECURE}:${_id}"
    else
	local CALLER="${RDPVIEWER} ${C_DARGS} ${_vieweropt} localhost:${_id}"
    fi
    printDBG $S_RDP ${D_FRAME} $LINENO $BASH_SOURCE "${CALLER}"
    export C_ASYNC;
    if [ -n "${C_DISPLAY}" ];then
	DISPLAY=":${C_DISPLAY}";
	export DISPLAY;
    fi
    printFINALCALL $LINENO $BASH_SOURCE "FINAL-RDP-CONSOLE:STARTER(${_label})-DISPLAY=\"${DISPLAY}\"" "${CALLER}"

    case ${C_DISPLAY// /} in
	*[a-z][A-Z]*)
	    export DISPLAY=":$(C_SESSIONTYPE=ALL fetchDisplay4Label ALL ${C_DISPLAY})";
	    ;;
	'')
            ;;
	*)
	    export DISPLAY=":${C_DISPLAY}";
	    ;;
    esac

    if [ -z "${C_NOEXEC}" ];then
	eval ${CALLER}&
	if [ "${C_ASYNC}" == 0 ];then
 	    wait
	fi
    fi
    return
}




