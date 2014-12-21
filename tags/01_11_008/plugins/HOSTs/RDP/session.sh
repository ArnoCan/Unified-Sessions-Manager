#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_008alpha
#
########################################################################
#
# Copyright (C) 2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

_myPKGNAME_RDP_SESSION="${BASH_SOURCE}"
_myPKGVERS_RDP_SESSION="01.11.008alpha"
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

    [ -z "${C_NOEXEC}" ]&&eval ${CALLER}
    return
}




