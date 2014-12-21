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

_myPKGNAME_VBOX_SESSION="${BASH_SOURCE}"
_myPKGVERS_VBOX_SESSION="01.11.008alpha"
hookInfoAdd $_myPKGNAME_VBOX_SESSION $_myPKGVERS_VBOX_SESSION
_myPKGBASE_VBOX_SESSION="`dirname ${_myPKGNAME_VBOX_SESSION}`"

_RDP_CLIENT_MODE=;

#FUNCBEG###############################################################
#NAME:
#  noClientServerSplitSupportedMessageVBOX
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
function noClientServerSplitSupportedMessageVBOX () {
    printERR $LINENO $BASH_SOURCE ${ABORT} "INFO:Current version supports CONNECTIONFORWARDING with CONSOLE for WMware-Server only"
    printERR $LINENO $BASH_SOURCE ${ABORT} "INFO:Following options are available:"
    printERR $LINENO $BASH_SOURCE ${ABORT} "INFO:  Client and Server on different machines: CONNECTIONFORWARDING"
    printERR $LINENO $BASH_SOURCE ${ABORT} "INFO:    -> Local RDP client: ${RDPRDESK}"
    printERR $LINENO $BASH_SOURCE ${ABORT} "INFO:    +  Interconnecting SSH-Tunnel"
    printERR $LINENO $BASH_SOURCE ${ABORT} "INFO:    +  Remote Server with CONSOLE"
    printERR $LINENO $BASH_SOURCE ${ABORT} "INFO:  Client and Server on same machine: DISPLAYFORWARDING"
    printERR $LINENO $BASH_SOURCE ${ABORT} "INFO:    -> Coallocated RDP client: ${RDPRDESK}"
    printERR $LINENO $BASH_SOURCE ${ABORT} "INFO:    -> or intergrated DESKTOP-CONSOLE VirtualBox"
    printERR $LINENO $BASH_SOURCE ${ABORT} "INFO:    -> or intergrated DESKTOP-CONSOLE SDL"
    printERR $LINENO $BASH_SOURCE ${ABORT} "INFO:    +  Server with CONSOLE"
}


#FUNCBEG###############################################################
#NAME:
#  expandSessionIDVBOX
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
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function expandSessionIDVBOX () {
    echo $1
}

#FUNCBEG###############################################################
#NAME:
#  isActiveVBOX
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
#    0: Active
#    1: Not active
#
#  VALUES:
#    0: Active
#    1: Not active
#
#FUNCEND###############################################################
function isActiveVBOX () {
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:<$1>"

    if [ -z "$1" ];then
	ABORT=2
	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing ID"
	gotoHell ${ABORT}
    fi
    local x=$(${PS} ${PSEF} |grep -v "grep"|grep -v "$CALLERJOB"|grep ${1#*:} 2>/dev/null)
    if [ -n "$x" ];then
	printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:0($x)"
	echo 0
	return 0;
    fi
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:1($x)"
    echo 1
    return 1;
}



#FUNCBEG###############################################################
#NAME:
#  getClientTPVBOX
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
#  $1: <label>
#       The <label> to gwhich the client will be attached.
#
#  $2: <pname>
#      The pname of the configuration file, this is required for 
#      RDP-sessions, and given to avoid scanning for labels
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
function getClientTPVBOX () {
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=$@"
    local _port=;

    if [ -n "$2" ];then
	_port=$(getRDPport ${2})
    fi
    if [ -z "$_port" -a  -n "$1" ];then
	_port=$(getRDPport ${1})
    fi

    if [ -z "${_port}" ];then
	echo
	ABORT=2
	printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Error, can not get port number for label:${1}"
	gotoHell ${ABORT}
    fi
    local _ret=$_port;  
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME port number=$_ret from ID=_port"
    echo ${_ret}
}



#FUNCBEG###############################################################
#NAME:
#  startSessionVBOX
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
# $1: label
# $2: ID/pname
# $3: GuestOS-TCP/IP
# $4: Console-Type
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function startSessionVBOX () {
    local _label=$1;
    local _pname=$2;
    local _myVM=$3;
    local _conty=${4:-$CTYS_VBOX_DEFAULTCONTYPE};
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:LABEL     =$_label"
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:PNAME     =$_pname"
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:VM-TCP/IP =$_myVM"
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:CONSOLE   =$_conty"

    local _isInInventory=NO;
    local _store="";
    local _oid="";

    if [ "${C_STACK}" == 1 ];then
	printDBG $S_VBOX ${D_FLOW} $LINENO $BASH_SOURCE "C_STACK=${C_STACK}"
	if [ -z "${_myVM}" -a \( "$_pingVBOX" == 1 -o  "$_sshpingVBOX" == 1 \) ];then
	    ABORT=2;
	    printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Missing the TCP/IP address of VM:${_label}"
	    printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Cannot operate synchronous with GuestOS."
	    printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:So VMSTACK is in almost any case not operable."
	    gotoHell ${ABORT}
	fi
    fi

    #should not happen, anyhow, once again, check it
    if [ -z "${_label}" ];then
	ABORT=1
	printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Missing LABEL"
	gotoHell ${ABORT}
    fi

    #should not happen, anyhow, once again, check it
    if [ -z "${_pname}" ];then
	ABORT=1
	printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Missing PNAME for LABEL=\"$_label\""
	gotoHell ${ABORT}
    fi

    #
    #check inventory, if missing add it, because else VM does not start
    #function seems to be available from the box for server only
    #
    case ${VBOX_MAGIC} in
	VBOX_03*)
	    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:check inventory:<$_label>"
	    checkIsInInventory $_label
	    if [ $? -ne 0 ];then
		printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:add to inventory:<$_label>"
		addToInventory $_label
		if [ $? -ne 0 ];then
                    ABORT=1;
		    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "Check inventory entry:<$_label>"
		    printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:failed to add inventory:<$_label>"
		    printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:check access permissions for:"
		    _isInInventory=NO;
		else
		    _isInInventory=YES;
		fi
	    else
		_isInInventory=YES;
	    fi
	    ;;
    esac

    #
    #setup calls
    #
    local CALLER=;
    case ${VBOX_MAGIC} in
	VBOX_03*)
	    local _myID=$(fetchUUID ${_pname})
	    case "${_conty}" in
		VBOX)
		    CALLCLIENT=;
		    CALLSERVER="${VBOXEXE} --startvm $_myID";
		    ;;

		SDL)
		    CALLCLIENT=;
		    CALLSERVER="${VBOXSDL} --startvm $_myID";
		    ;;

		RDP)
		    #
		    #for alpha ignoring connectionforwarding for now, will be added a.s.a.p.
		    #
                    _myRDPPort=$(getFirstFreeRDPPort $RDP_BASEPORT)
		    CALLCLIENT="${RDPRDESK} localhost:$_myRDPPort"

		    CALLCLIENTARGS=
		    CALLSERVER="${VBOXHEADLESS} --vrdpport $_myRDPPort --startvm $_myID "
		    ;;

		NONE)
                    _myRDPPort=$(getFirstFreeRDPPort $RDP_BASEPORT)
		    CALLCLIENT=;
		    CALLSERVER="${VBOXHEADLESS} --vrdpport $_myRDPPort --startvm $_myID "
		    ;;
		*)
		    CALLCLIENT=;
		    CALLSERVER="${VBOXEXE} --startvm $_myID";
		    ;;
	    esac
	    printDBG $S_VBOX ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME:_conty=\"${_conty}\""
	    printDBG $S_VBOX ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME:CALLCLIENT=\"${CALLCLIENT}\""
	    printDBG $S_VBOX ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME:CALLSERVER=\"${CALLSERVER}\""
	    ;;
    esac

    #
    #version specific adaptions
    case ${VBOX_MAGIC} in
	*)
	    if [ -n "${CALLSERVER}" ];then
		CALLSERVER="callErrOutWrapper $LINENO $BASH_SOURCE ${CALLSERVER}"
	    fi
	    if [ -n "${CALLCLIENT}" ];then
		CALLCLIENT="callErrOutWrapper $LINENO $BASH_SOURCE ${CALLCLIENT}"
	    fi
	    ;;
    esac
    
    #just for safety
    if [ "${C_STACK}" == 1 -a "${_conty}" != NONE ];then
	ABORT=1;
	printERR $LINENO $BASH_SOURCE ${ABORT} "VMSTACK requires HEADLESS for synchronous SSH operations."
 	gotoHell ${ABORT}
    fi
    if [ "${C_STACK}" == 1 -a -n "${CALLCLIENT}" ];then
	ABORT=1;
	printERR $LINENO $BASH_SOURCE ${ABORT} "VMSTACK requires HEADLESS for synchronous SSH operations."
 	gotoHell ${ABORT}
    fi
    if [ "${C_STACK}" == 1 ];then
	_pingVBOX=1;
	_sshpingVBOX=1;
	printINFO 2 $LINENO $BASH_SOURCE 0 "$FUNCNAME:Activate C_STACK-ping+sshping"
    fi

    printINFO 2 $LINENO $BASH_SOURCE 0 "$FUNCNAME:CALLSERVER=\"${CALLSERVER}\""
    printINFO 2 $LINENO $BASH_SOURCE 0 "$FUNCNAME:CALLCLIENT=\"${CALLCLIENT}\""
    printDBG $S_VBOX ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME:CALLSERVER=\"${CALLSERVER}\""
    printDBG $S_VBOX ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME:CALLCLIENT=\"${CALLCLIENT}\""

    if [ -z "${C_NOEXEC}" ];then
	if [ -n "${CALLSERVER}" ];then
 	    printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:${VBOX_MAGIC}-CALLSERVER=${CALLSERVER}"
 	    printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:${VBOX_MAGIC}-CALLSERVER=${_store}"
	    case ${VBOX_MAGIC} in
		*)
		    printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${CALLSERVER}"
		    eval ${CALLSERVER}&>/dev/null&
		    ;;
	    esac
	    sleep ${_waitsVBOX};
	else
            #non-stack only
	    if [ -n "${CALLCLIENT}" ];then
 		printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:${VBOX_MAGIC}-CALLCLIENT=${CALLCLIENT}"
		case ${VBOX_MAGIC} in
		    VBOX_03*)
			printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${CALLCLIENT} ${CALLCLIENTARGS}"
			eval ${CALLCLIENT} "${CALLCLIENTARGS}"&>/dev/null&
			;;
		    *)
			printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${CALLCLIENT}"
			eval ${CALLCLIENT} &
			;;
		esac
		sleep ${_waitcVBOX};
	    else
		ABORT=3
		printERR $LINENO $BASH_SOURCE ${ABORT} "Missing CALLSERVER AND CALLCLIENT"
		gotoHell ${ABORT}
	    fi
	fi

	local _pingok=0;
	local _sshpingok=0;

	if [ "$_pingVBOX" == 1 ];then
	    netWaitForPing "${_myVM}" "${_pingcntVBOX}" "${_pingsleepVBOX}"
	    _pingok=$?;
	fi

	if [ "$_pingok" == 0 -a "$_sshpingVBOX" == 1 ];then
	    netWaitForSSH "${_myVM}" "${_sshpingcntVBOX}" "${_sshpingsleepVBOX}" "${_actionuserVBOX}"
	    _sshpingok=$?;
	fi

	if [ "${C_STACK}" == 1 ];then
	    printDBG $S_VBOX ${D_FLOW} $LINENO $BASH_SOURCE "C_STACK=${C_STACK}"
	    if [ $_pingok != 0 ];then
		ABORT=1
		printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "Start timed out:netWaitForPing"
		printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "  VM =${_myVM}"

		printWNG 1 $LINENO $BASH_SOURCE 0 "${_VHOST}  <${_label}> <${MYHOST}>  <${_pname}>"
		printWNG 1 $LINENO $BASH_SOURCE 0 "<${_myVM}> <${_pingcntVBOX}> <${_pingsleepVBOX}>"
		gotoHell ${ABORT}
	    else
 		printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:Accessable by ping:${_myVM}"
	    fi

	    netWaitForSSH "${_myVM}" "${_sshpingcntVBOX}" "${_sshpingsleepVBOX}" "${_actionuserVBOX}"
	    if [ $? != 0 ];then
		printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "Start timed out:netWaitForSSH"
		printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "  VM =${_myVM}"

		printWNG 1 $LINENO $BASH_SOURCE 0 "${_VHOST}  <${_label}> <${MYHOST}>  <${_pname}>"
		printWNG 1 $LINENO $BASH_SOURCE 0 "<${_myVM}> <${_sshpingcntVBOX}> <${_sshpingsleepVBOX}>"
		gotoHell 0
	    else
 		printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:Accessable by ssh:${_myVM}"
	    fi
	fi

        #
        #assume pre-checked appropriate content
	if [ -n "${CALLSERVER}" -a -n "${CALLCLIENT}" ];then
 	    printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:${VBOX_MAGIC}"
	    case ${VBOX_MAGIC} in
		VBOX_03*)
 		    printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:${CALLCLIENT} ${CALLCLIENTARGS}"
		    printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${CALLCLIENT} ${CALLCLIENTARGS:+\"$CALLCLIENTARGS\"}&"
		    eval ${CALLCLIENT} ${CALLCLIENTARGS:+"$CALLCLIENTARGS"}&
		    ;;
		*)
		    printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${CALLCLIENT} &"
		    eval ${CALLCLIENT} &
		    ;;
	    esac
	    sleep ${_waitcVBOX};
	fi

	local _myAttrLst="JOBID=${CALLERJOB}:$((JOB_IDXSUB++));"
	cacheStoreWorkerPIDData SERVER VBOX "${_pname}" "${_label}" 0 "" REPLACE "${_myAttrLst}"
	case "${_conty}" in
# 	    SDL)
# 		cacheStoreWorkerPIDData CLIENT VBOX "${_pname}" "${_label}" 0 "" REPLACE "${_myAttrLst}"
# 		;;
	    VBOX)
		cacheStoreWorkerPIDData CLIENT VBOX "${_pname}" "${_label}" 0 "" REPLACE "${_myAttrLst}"
		;;
	    RDP)
		cacheStoreWorkerPIDData CLIENT RDP "" "${_label}" 0 "" REPLACE "${_myAttrLst}"
		;;
	esac
	if [ "${C_ASYNC}" == 0 ];then
	    wait
	fi
    fi
}



#FUNCBEG###############################################################
#NAME:
#  connectSessionVBOX
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  This function is the plugins local connection wrapper.
#  The basic decisions from where the connection is established and 
#  to gwhich peer it has to be connected is done before calling this.
#  But some knowledge of the connection itself is still required here.
#
#  So "the wrapper is in close relation to the controller", it is his  
#  masters not so stupid paladin.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: <session-id>
#      This is the absolute pathname to the vmx-file.
#
#  $2: <session-label>
#      This will be used for the title of the client window.
#
#  $3: <actual-access-id>
#      This will be used for actual connection. 
#
#  $4: GuestOS-TCP/IP
#
#  $5: CONSOLE
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function connectSessionVBOX () {
    local _id=${1}
    local _label=${2}
    local _actaccessID=${3}
    local _myVM=$4;
    local _myCon=${5:-$CTYS_VBOX_DEFAULTCONTYPE_CONNECT};

    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:ID        =$_pname"
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:LABEL     =$_label"
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:ACCESSID  =$_actaccessID"
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:VM-TCP/IP =$_myVM"
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:CONSOLE   =$_myCon"

    if [ -z "${_id}" -a -z "${_label}" ];then
	ABORT=1
	printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:At least one parameter required:<session-id> or <session-label>"
	gotoHell ${ABORT}
    fi

    local cport=$(getRDPport "${_id}")
    if [ -z "$cport" -a -z "${_actaccessID}" -o "${_actaccessID}" == "${_id}" ];then
        #
        #local native access: same as DISPLAYFORWARDING or LOCALONLY
        #
	local _labelX=`fetchLabel4ID ${_id}`;
	if [ "${_label}" != "${_labelX}" ];then
	    ABORT=1
	    printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:LABEL and ID are not consistent:"
	    printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:  LABEL = ${_label}"
	    printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:  ID    = ${_id}   => ${_labelX}"
	    printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:A frequent cause is redundancy of VMs"
	    gotoHell ${ABORT}
	fi
	case ${VBOX_MAGIC} in
	    VBOX_03*)
                #Yes, the connect-call for a session gwhich is - as PRE-REQUIRED - in 
                #background-continue-mode - is identical to the create-call.
                #=> CONNECT-CLI-IF of vmware is identical to CREATE-CLI-IF
		startSessionVBOX "${_label}" "${_id}" "${_myVM}" "${_myCon}"
 		;;

            #	VBOX_S103|WMW_WS6|VBOX_GENERIC)
	    *)  #For now seems to be common, but let it beeee....

                #Yes, the connect-call for a session gwhich is - as PRE-REQUIRED - in 
                #background-continue-mode - is identical to the create-call.
                #=> CONNECT-CLI-IF of vmware is identical to CREATE-CLI-IF
		startSessionVBOX "${_label}" "${_id}" "${_myVM}" "${_myCon}"
 		;;
	esac
    else
	if [ -n "${_RDP_CLIENT_MODE}" ];then
            #Let client "beeee a WS6+", let's go
	    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:RDPviewer"
	    connectSessionVBOXRDP "${_RDP_CLIENT_MODE}" "${_label}" 
	else
	    case ${VBOX_MAGIC} in
		VBOX_03*)

                    #Yes, the connect for a session gwhich is - as PRE-REQUIRED - in 
                    #background-continue-mode - CONNECT-CLI-IF of vmware is identical 
                    #to CREATE-CLI-IF

		    VBOX_DEFAULTOPTS="${VBOX_DEFAULTOPTS} -h localhost -P ${_actaccessID}"
		    startSessionVBOX "${_label}" "${_id}" "${_myVM}" "${_myCon}"
 		    ;;

               #	VBOX_S103|VBOX_WS6|VBOX_GENERIC)
		*)  #For now seems to be common, but let it beeee....
		    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME "
		    ABORT=2
		    noClientServerSplitSupportedMessageVBOX
		    gotoHell ${ABORT}
 		    ;;
	    esac
	fi

    fi
}




#FUNCBEG###############################################################
#NAME:
#  vmMgrVBOX
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Encapsulates the VBoxManage command with unified calls.
#  <params> reflects type:gui|vrdpm where vrdp==nogui of VMW plugin.
#
#EXAMPLE:
#
#PARAMETERS:
# $1:                 $2       $3   $4         $5
#---------------------------------------------------------------------
# START|CREATE|RESUME <label>  <id> [<params>]            => START
# STOP|CANCEL         <label>  <id>                       => STOP
# SUSPEND             <label>  <id>                       => SUSPEND
# RESET               <label>  <id>                       => RESET
# POWEROFF            <label>  <id> <timeout>  <vm-pid>
#                                                         => STOP \
#                                                            &&sleep <timeout>  \
#  <id>:=lable|uuid|pathname                                 &&kill -9 <vm-pid>
#
#
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function vmMgrVBOX () {
    printDBG $S_VBOX ${D_FLOW} $LINENO $BASH_SOURCE "${FUNCNAME}:$*"
    local _cmd=$1;shift
    local _label=$1;shift;
    local _id=$1;shift
    [ -n "$_id" ]&&_id=$(fetchUUID $_id)

    printINFO 1 $LINENO $BASH_SOURCE 0 "${FUNCNAME}:Check hypervisor now for remaining VM:$_label"
    case $_cmd in
	START|CREATE)
	    local _params=$1;shift
            if [ -z "${C_NOEXEC}" ];then
		printINFO 1 $LINENO $BASH_SOURCE $ABORT "${FUNCNAME}:Require hypervisor for:$_cmd"
		case $VBOX_MAGIC in
		    VBOX_03*)
			case $(_params) in
			    gui)
				local _call="${VBOXMGR} startvm '$_id' -type gui"
				printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${_call}"
				eval ${_call}
				;;
			    nogui|vrdp)
				local _call="${VBOXMGR} startvm '$_id' -type vrdp"
				printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${_call}"
				eval ${_call}
				;;
			    *)
				;;
			esac
			;;
		esac
	    fi
	    ;;

	STOP|CANCEL|POWEROFF)
            local _timeout=${1:-$DEFAULT_KILL_DELAY_POWEROFF};shift
            local _pid=$1;shift
            ABORT=1;
	    local _idX=$(fetchID4PID ${_pid});
            if [ -z "${_idX}" ];then
		printINFO 1 $LINENO $BASH_SOURCE $ABORT "${FUNCNAME}:Server is already stopped by STACK operations."
	    else
		if [ -z "${C_NOEXEC}" ];then
		    printINFO 1 $LINENO $BASH_SOURCE $ABORT "${FUNCNAME}:Require hypervisor for:POWEROFF"
		    case $VBOX_MAGIC in
			VBOX_03*)
			    local _call="${VBOXMGR} controlvm '$_id' poweroff"
			    printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${_call}"
			    eval ${_call}
			    ;;
		    esac
		    printINFO 1 $LINENO $BASH_SOURCE $ABORT "${FUNCNAME}:Delay before need to kill:${_timeout} seconds"
		    sleep $_timeout

		    local _idX=$(fetchID4PID ${_pid});
                    if [ -z "${_idX}" ];then
			printINFO 1 $LINENO $BASH_SOURCE $ABORT "${FUNCNAME}:Server is already stopped by hypervisor."
		    else
			if [ "`fetchID4PID ${_pid}`" == "${_id}" ];then
			    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME} Can not avoid to kill:${_pid}==${_id}"
			    printWNG 1 $LINENO $BASH_SOURCE $ABORT "${FUNCNAME}   1.Still running:     pid(${_pid})"
			    printWNG 1 $LINENO $BASH_SOURCE $ABORT "${FUNCNAME}   2.Still what it was: id(${_id})"
			    callErrOutWrapper $LINENO $BASH_SOURCE  ${VBOXCALL} kill $_pid
			    printWNG 1 $LINENO $BASH_SOURCE $ABORT "${FUNCNAME} Delay forced \"kill -9\":${_timeout} seconds"
			    sleep $_timeout
			    if [ "`fetchID4PID ${_pid}`" == "${_id}" ];then
				printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME} Have to use \"-9\" now:${_pid}==${_id}"
				callErrOutWrapper $LINENO $BASH_SOURCE  ${VBOXCALL} kill $_pid
			    else
				printINFO 1 $LINENO $BASH_SOURCE $ABORT "${FUNCNAME}   \"-9\" was not required."
			    fi
			    printWNG 1 $LINENO $BASH_SOURCE $ABORT "${FUNCNAME} Done what to have..."
			    printWNG 1 $LINENO $BASH_SOURCE $ABORT "${FUNCNAME} ...do not forget \"fsck\""
			else
			    printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME} Can not apply kill, target changed:"
			    printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}   ${_pid} != ${_id}"
			fi
		    fi
		fi
	    fi
            ;;

	SUSPEND)
            if [ -z "${C_NOEXEC}" ];then
		printINFO 1 $LINENO $BASH_SOURCE $ABORT "${FUNCNAME}:Require hypervisor for:SUSPEND"
		case $VBOX_MAGIC in
		    VBOX_03*)
			local _call="${VBOXMGR} controlvm '$_id' savestate"
			printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${_call}"
			eval ${_call}
			;;
		esac
	    fi
	    ;;

	RESUME)
	    local _params=$1;shift
            if [ -z "${C_NOEXEC}" ];then
		printINFO 1 $LINENO $BASH_SOURCE $ABORT "${FUNCNAME}:Require hypervisor for:$_cmd"
		case $VBOX_MAGIC in
		    VBOX_03*)
			local _call="${VBOXMGR} controlvm '$_id' resume"
			printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${_call}"
			eval ${_call}
		esac
	    fi
	    ;;

	RESET)
            if [ -z "${C_NOEXEC}" ];then
		printINFO 1 $LINENO $BASH_SOURCE $ABORT "${FUNCNAME}:Require hypervisor for:RESET"
		printDBG $S_VBOX ${D_FLOW} $LINENO $BASH_SOURCE "${FUNCNAME} Call:RESET"
		printDBG $S_VBOX ${D_FLOW} $LINENO $BASH_SOURCE "  ID = ${_id}"
		case $VBOX_MAGIC in
		    VBOX_03*)
			local _call="${VBOXMGR} controlvm '$_id' reset"
			printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${_call}"
			eval ${_call}
		    ;;
		esac
	    fi
	    ;;
    esac
}





#FUNCBEG###############################################################
#NAME:
#  connectSessionVBOXRDP
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Temporary for direct call.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: <display-port>
#      This is calculated from the port, and is the offset to that.
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
function connectSessionVBOXRDP () {
    local _id=${1}
    local _label=${2}
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME ${_id} ${_label}"

    #even though this condition might be impossible now, let it beeeee ...
    if [ -z "${_label}" -a -z "${_id}" ];then
	ABORT=1
	printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Fetch of peer entry failed:_id=${_id} - _label=${_label}"
	gotoHell ${ABORT}
    fi

    printDBG $S_VBOX ${D_FRAME} $LINENO $BASH_SOURCE "OK:_id=${_id} - _label=${_label}"
    #
    #Now shows name+id in title, id could not be set for server as default.
    local _rdpgeometry="${C_GEOMETRY:+ -g $C_GEOMETRY} "
    _rdpgeometry="${_rdpgeometry%%+*}"
    local _vieweropt="-T '${_label}:${_id}' ${RDPRDESK_OPT} ${_rdpgeometry} "
    #
    local CALLER="${RDPRDESK} ${_vieweropt} 127.0.0.1:${_id}"
    printDBG $S_VBOX ${D_FRAME} $LINENO $BASH_SOURCE "${CALLER}"
    printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${CALLER}"
    export C_ASYNC;

    if [ -z "${C_NOEXEC}" ];then
	if [ "${C_ASYNC}" == 0 ];then
	    eval ${CALLER}
	else
	    export PATH=${QEMU_PATHLIST}:${PATH}&&{ eval  ${CALLER} &sleep ${CTYS_PREDETACH_TIMEOUT_HOSTS:-5}; }>/dev/null&
	fi
    fi

}




