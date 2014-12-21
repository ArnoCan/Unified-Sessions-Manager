#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_002
#
########################################################################
#
# Copyright (C) 2007,2008 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

_myPKGNAME_VNC_SESSION="${BASH_SOURCE}"
_myPKGVERS_VNC_SESSION="01.11.002"
hookInfoAdd $_myPKGNAME_VNC_SESSION $_myPKGVERS_VNC_SESSION
_myPKGBASE_VNC_SESSION="`dirname ${_myPKGNAME_VNC_SESSION}`"


#FUNCBEG###############################################################
#NAME:
#  getClientTPVNC
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
#  The port is the local port number, gwhich in general has to be mapped 
#  on remote site, when already in use. Therefore the application has
#  to provide a port-number-independent client access protocol in order 
#  to be used by connection forwarding. In any other case display 
#  forwarding has to be choosen.
#
#  Some applications support only one port for access by multiple 
#  sessions, dispatching and bundling the communications channels
#  by their own protocol. 
#
#  While others require for each channel a seperate litenning port.
#
#  So it is up to the specific package to support a function returning 
#  the required port number gwhich could be used to attach an forwarded 
#  port. 
#  
#  The applications client has to support a remapped port number.
#
#EXAMPLE:
#
#PARAMETERS:
#  <label>
#    The <label> to gwhich the client will be attached.
#
#GLOBALS:
#  VBASEPORT
#    The baseport for calculations of VNC display number, gwhich is 
#    5900. This will be used to calculate the client TP.
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
function getClientTPVNC () {
    local _arg0=${1}

    printDBG $S_VNC ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME Label=$_arg0"

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
    let _ret=VNC_BASEPORT+_port;
    
    printDBG $S_VNC ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME port number=$_ret from ID=$_port"
    echo ${_ret}
}


#FUNCBEG###############################################################
#NAME:
#  startSessionVNC
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
function startSessionVNC () {
    printDBG $S_VNC ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME"
    local _name=${1:-DEFAULT-`date +%y%m%d%H%M%S`}
    printDBG $S_VNC ${D_UI} $LINENO $BASH_SOURCE "${VNCSERVER} <session-label>:${_name}"
    checkUniqueness4Label ${_name};
    if [ $? -eq 0 ];then
	local _unique=1
    else
	if [ -z "${C_ALLOWAMBIGIOUS}" ];then
	    ABORT=2
	    printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Ambigious <session-label>:${_name}"
	    printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:VNC is as default in \"shared\" mode, use \"-A\" if required."
	    gotoHell ${ABORT}
	else 
	    printWNG 1 $LINENO $BASH_SOURCE ${RET} "${FUNCNAME}:Reuse ambigious label:${_name}"
	fi
    fi

    #prepare server-opts, particulary servers display resolution.
    local CURSES=""
    local _serveropt="-name ${_name} ${VNCSERVER_OPT}"
    if [ -n "${C_REMOTERESOLUTION}" ];then
        #use explicityl given
	printDBG $S_VNC ${D_UID} $LINENO $BASH_SOURCE "C_REMOTERESOLUTION=${C_REMOTERESOLUTION}"
	local _servergeo=${C_REMOTERESOLUTION}
	_serveropt=`echo ${_serveropt}|sed 's/-geometry [0-9]*x[0-9x]*//g'`
	printDBG $S_VNC ${D_UID} $LINENO $BASH_SOURCE "_servergeo=${_servergeo}"

    else
	if [ -n "${C_GEOMETRY}" ];then
            #use same as given for client
	    printDBG $S_VNC ${D_UID} $LINENO $BASH_SOURCE "C_GEOMETRY=${C_GEOMETRY}"
	    local _servergeo=`echo ${C_GEOMETRY}|sed -n 's/+.*$//;s/[^0-9]*\([0-9x]*\).*$/\1/gp'`
	    _serveropt=`echo ${_serveropt}|sed 's/-geometry [0-9]*x[0-9x]*//g'`
	    printDBG $S_VNC ${D_UID} $LINENO $BASH_SOURCE "_servergeo=${_servergeo}"
	fi
    fi
    _serveropt="${_serveropt}  ${_servergeo:+ -geometry $_servergeo} "

    local _vieweropt="${VNCVIEWER_OPT} ${C_GEOMETRY:+ -geometry $C_GEOMETRY} "

    if [ -z "${C_NOEXEC}" ];then
	if [ "${C_CLIENTLOCATION}" !=  "-L CONNECTIONFORWARDING" ];then
	    SERVER="${VNCSERVER} ${C_DARGS} ${_serveropt} "
	    printDBG $S_VNC ${D_MAINT} $LINENO $BASH_SOURCE "SERVER=${SERVER}"
	    printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-VNC:SERVER(${_label})" "${SERVER}"
	    CURSES=`eval ${SERVER}`
	    printDBG $S_VNC ${D_MAINT} $LINENO $BASH_SOURCE "CURSES=${CURSES}"
	    if [ -z "${CURSES}" -o -n "`echo ${CURSES}|sed 's/[0-9]*//g'`" ];then
		ABORT=2
		printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Error when starting VNCSERVER:"
		printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:  ${VNCSERVER} ${_serveropt}"
		printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:  => CURSES=${CURSES}"
		printERR $LINENO $BASH_SOURCE ${ABORT} "."
		printERR $LINENO $BASH_SOURCE ${ABORT} "A common reason for this is an error for platform depency "
		printERR $LINENO $BASH_SOURCE ${ABORT} "of default passwd file."
		printERR $LINENO $BASH_SOURCE ${ABORT} "Call \"vncpasswd\" on the target machine and try creation "
		printERR $LINENO $BASH_SOURCE ${ABORT} "of the session again."
		printERR $LINENO $BASH_SOURCE ${ABORT} "This should already have be done anyhow."
		printERR $LINENO $BASH_SOURCE ${ABORT} "."
		gotoHell ${ABORT}
	    else
		printDBG $S_VNC ${D_MAINT} $LINENO $BASH_SOURCE "VNC:Current vncserver Xsession detected as successfull CURSES=<${CURSES}>"
	    fi   

	    cacheStoreWorkerPIDData SERVER VNC "${CURSES}" "${_name}" 0 "" 
	    if [ $? -ne 0 ];then
		printERR $LINENO $BASH_SOURCE 2 "$FUNCNAME:VNC:Failed to store runtime JobData for SERVER:\"${_name}\""
		printERR $LINENO $BASH_SOURCE 2 "$FUNCNAME:VNC: =>Continue for now, but further actions may be required!"
	    fi
	fi
    else
        #Dummy-value for display only
	CURSES=9999999
    fi
    printDBG $S_VNC ${D_MAINT} $LINENO $BASH_SOURCE "CURSES=$CURSES"
    printDBG $S_VNC ${D_MAINT} $LINENO $BASH_SOURCE "C_CLIENTLOCATION=<$C_CLIENTLOCATION>"
    printDBG $S_VNC ${D_MAINT} $LINENO $BASH_SOURCE "CALLERJOB=<$CALLERJOB>"
    printDBG $S_VNC ${D_MAINT} $LINENO $BASH_SOURCE "JOB_IDXSUB=<$JOB_IDXSUB>"
    if [ "${C_CLIENTLOCATION}" !=  "-L SERVERONLY" ];then
	local CALLER=;
	CALLER="export C_ASYNC=${C_ASYNC}&&${VNCVIEWER}  "
	CALLER="${CALLER} ${C_DARGS} "
	CALLER="${CALLER} -name \"${_name}:${CURSES}\" "
	CALLER="${CALLER} ${_vieweropt} localhost:${CURSES} "

	printDBG $S_VNC ${D_MAINT} $LINENO $BASH_SOURCE "${C_NOEXEC:-CALL:}${CALLER}"
        #don't exec here, it could be one of a set!
	printDBG $S_VNC ${D_UID} $LINENO $BASH_SOURCE "WAITS=${WAITS}"
	printFINALCALL $LINENO $BASH_SOURCE "WAIT-TIMER:vncserver(${_label},WAITS)" "sleep ${WAITS}"
	printFINALCALL $LINENO $BASH_SOURCE "FINAL-VNC-CONSOLE:STARTER(${_label})" "${CALLER}"
	if [ -z "${C_NOEXEC}" ];then

	    if [ -n "${C_DISPLAY}" ];then
		DISPLAY=":${C_DISPLAY}";
		export DISPLAY;
	    fi
	    printFINALCALL $LINENO $BASH_SOURCE "FINAL-VNC-CONSOLE:STARTER(${_label})-DISPLAY=\"${DISPLAY}\"" "${CALLER}"

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
 	    cacheStoreWorkerPIDData CLIENT VNC "${CURSES}" "${_name}" 0 "" 
	    if [ $? -ne 0 ];then
		printWNG 1 $LINENO $BASH_SOURCE 0  "$FUNCNAME:VNC:Failed to store runtime JobData for CLIENT:\"${_name}\""
		printWNG 1 $LINENO $BASH_SOURCE 0  "$FUNCNAME:VNC: =>Restart of CLIENT should be sufficient."
	    fi
	    if [ "${C_ASYNC}" == 0 ];then
		wait
	    fi
	fi
    fi
}


#FUNCBEG###############################################################
#NAME:
#  connectSessionVNC
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
#      The base-value is normally 5900 for RealVNC+TIghtVNC.
#      TightVNC might allow the selection of another port.
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
function connectSessionVNC () {
    local _id0=${1}
    local _id=`removeLeadZeros ${1}`
    local _label=${2}
    printDBG $S_VNC ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME ${_id0}->${_id} ${_label}"

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

    printDBG $S_VNC ${D_FRAME} $LINENO $BASH_SOURCE "OK:_id=${_id} - _label=${_label}"
    #
    #Now shows name+id in title, id could not be set for server as default.
    local _vieweropt="-name ${_label}:${_id} ${VNCVIEWER_OPT} ${C_GEOMETRY:+ -geometry $C_GEOMETRY} "
    local CALLER="${VNCVIEWER} ${C_DARGS} ${_vieweropt} localhost:${_id}"
    printDBG $S_VNC ${D_FRAME} $LINENO $BASH_SOURCE "${CALLER}"
    export C_ASYNC;
    if [ -n "${C_DISPLAY}" ];then
	DISPLAY=":${C_DISPLAY}";
	export DISPLAY;
    fi
    printFINALCALL $LINENO $BASH_SOURCE "FINAL-VNC-CONSOLE:STARTER(${_label})-DISPLAY=\"${DISPLAY}\"" "${CALLER}"

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

#KEEP4REMINDER:
#     if [ -z "${C_NOEXEC}" ];then
# 	eval ${CALLER} &
#  	if [ "${C_ASYNC}" == 0 ];then
#  	    wait
#  	fi
#     fi
}



