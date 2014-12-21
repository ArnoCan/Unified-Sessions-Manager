#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_007
#
########################################################################
#
# Copyright (C) 2007,2008,2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

_myPKGNAME_VMW_SESSION="${BASH_SOURCE}"
_myPKGVERS_VMW_SESSION="01.11.007"
hookInfoAdd $_myPKGNAME_VMW_SESSION $_myPKGVERS_VMW_SESSION
_myPKGBASE_VMW_SESSION="`dirname ${_myPKGNAME_VMW_SESSION}`"

_VNC_CLIENT_MODE=;

#FUNCBEG###############################################################
#NAME:
#  noClientServerSplitSupportedMessageVMW
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
function noClientServerSplitSupportedMessageVMW () {
    printERR $LINENO $BASH_SOURCE ${ABORT} "INFO:Current version supports CONNECTIONFORWARDING with CONSOLE for WMware-Server only"
    printERR $LINENO $BASH_SOURCE ${ABORT} "INFO:Following options are available:"
    printERR $LINENO $BASH_SOURCE ${ABORT} "INFO:  Client and Server on different machines: CONNECTIONFORWARDING"
    printERR $LINENO $BASH_SOURCE ${ABORT} "INFO:    -> Workstation 6+ with VNC client"
    printERR $LINENO $BASH_SOURCE ${ABORT} "INFO:    -> Server with CONSOLE"
    printERR $LINENO $BASH_SOURCE ${ABORT} "INFO:  Client and Server on same machine: DISPLAYFORWARDING"
    printERR $LINENO $BASH_SOURCE ${ABORT} "INFO:    -> Workstation 6+ with CONSOLE"
    printERR $LINENO $BASH_SOURCE ${ABORT} "INFO:    -> Workstation 6+ with VNC client"
    printERR $LINENO $BASH_SOURCE ${ABORT} "INFO:    -> Server with CONSOLE"
}


#FUNCBEG###############################################################
#NAME:
#  expandSessionIDVMW
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
function expandSessionIDVMW () {
    echo $1
}

#FUNCBEG###############################################################
#NAME:
#  isActiveVMW
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
function isActiveVMW () {
    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:<$1>"

    if [ -z "$1" ];then
	ABORT=2
	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing ID"
	gotoHell ${ABORT}
    fi
    local x=$(${PS} ${PSEF} |grep -v "grep"|grep -v "$CALLERJOB"|grep ${1#*:} 2>/dev/null)
    if [ -n "$x" ];then
	printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:0($x)"
	echo 0
	return 0;
    fi
    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:1($x)"
    echo 1
    return 1;
}



#FUNCBEG###############################################################
#NAME:
#  getClientTPVMW
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
#  $1: <label>
#       The <label> to gwhich the client will be attached.
#
#  $2: <pname>
#      The pname of the configuration file, this is required for 
#      VNC-sessions, and given to avoid scanning for labels
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
function getClientTPVMW () {
    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=$@"
    local _port=;

    #for ws>6 only
    if [ -n "$2" -a "${VMW_MAGIC}" == "VMW_WS6" -o "${VMW_MAGIC}" == "VMW_WS7" ];then
	if [ -f "$2" ];then
	    _port=`cat $2|sed -n 's/\t//g;/^#/d;s/RemoteDisplay.vnc.port *= *"\([^"]*\)"/\1/p'`
	fi
	printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_port=$_port"
    fi

    #for s2
    if [ -z "$_port" -a -f "/etc/vmware/hostd/proxy.xml" ];then
	_port=`cat /etc/vmware/hostd/proxy.xml |sed -n 's@<httpsPort>\([0-9]*\)</httpsPort>@\1@p'`
	if [ -z "$_port" ];then
	    _port=`cat /etc/vmware/hostd/proxy.xml |sed -n 's@<httpPort>\([0-9]*\)</httpPort>@\1@p'`
	fi
    fi

    #for ws and server
    if [ -z "$_port" -a -f "/etc/vmware/config" ];then
	_port=`cat /etc/vmware/config |sed -n 's/authd.client.port *= *"\([0-9]*\)"/\1/p'`
    fi

    #for player not an error!
    if [ -z "${_port}" ];then
	if [ "${VMW_MAGIC}" == "VMW_S104" ];then
	    echo
	    ABORT=2
	    printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Error, can not get port number for label:${1}"
	    gotoHell ${ABORT}
	fi
    fi
    local _ret=$_port;  
    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME port number=$_ret from ID=_port"
    echo ${_ret}
}



#FUNCBEG###############################################################
#NAME:
#  startSessionVMW
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
#     Not each supported by any version:
#
#                VMW-S2  VMW-S   VMW-W   VMW-W7   VMW-P   VMW-P2 
#     ------------------------------------------------------------
#     ->VMWRC      X        -       -       -        -       -
#     ->FIREFOX    X        -       -       -        -       -
#     ->VMW        -        X       X       -        X       -
#     ->VNC        -        X       -       -        -       -
#     ->NONE       X        X       -       -        -       -
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function startSessionVMW () {
    local _label=$1;
    local _pname=$2;
    local _myVM=$3;
    local _conty=$4;
    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:LABEL     =$_label"
    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:PNAME     =$_pname"
    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:VM-TCP/IP =$_myVM"
    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:CONSOLE   =$_conty"

    local _isInInventory=NO;
    local _store="";
    local _oid="";

    if [ "${C_STACK}" == 1 ];then
	printDBG $S_VMW ${D_FLOW} $LINENO $BASH_SOURCE "C_STACK=${C_STACK}"
	if [ -z "${_myVM}" -a \( "$_pingVMW" == 1 -o  "$_sshpingVMW" == 1 \) ];then
	    ABORT=2;
	    printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Missing the TCP/IP address of VM:${_label}"
	    printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Cannot operate synchronous with GuestOS."
	    printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:So VMSTACK is in almost any case not operable."
	    gotoHell ${ABORT}
	fi
    fi

    function getVMWServerPID () {
	case ${VMW_MAGIC} in
	    VMW_S*)
		local x=`${PS} ${PSEF}|awk -v id="${1}" '$0!~/awk/&&$0~/vmware-vmx/&&$3=="1"&&$0~id{printf("%s",$2);}'`
		;;
	    VMW_WS*)
		local x=`${PS} ${PSEF}|awk -v id="${1}" '$0!~/awk/&&$0~/vmware-vmx/&&$3=="1"&&$0~id{printf("%s",$2);}'`
		;;

	    VMW_P105)
		local x=`${PS} ${PSEF}|awk -v id="${1}" '$0!~/awk/&&$0~/vmware/&&$3=="1"&&$0~id{printf("%s",$2);}'`
		;;
	    VMW_P2)
		local x=`${PS} ${PSEF}|awk -v id="${1}" '$0!~/awk/&&$0~/vmware/&&$3=="1"&&$0~id{printf("%s",$2);}'`
		;;
	    VMW_P3)
		local x=`${PS} ${PSEF}|awk -v id="${1}" '$0!~/awk/&&$0~/vmware/&&$3=="1"&&$0~id{printf("%s",$2);}'`
		;;
	esac
	printDBG $S_VMW ${D_BULK} $LINENO $BASH_SOURCE "VMW_MAGIC=<${VMW_MAGIC}> x=<${x}> \$1=<${1}>"
	if [ -z "${x}" ];then
	    return 1
	fi
	echo -n -e "${x}"
    }


    function getVMWClientPID () {
	case ${VMW_MAGIC} in
	    VMW_S1*)
		local x=`${PS} ${PSEF}|awk -v id="${1}" '$0!~/awk/&&$0~/\/bin\/vmware/&&$0!~/wrapper/&&$0~/displayName/&&$3!="1"&&$0~id{printf("%s",$2);}'`
		;;
#	    VMW_S20*)
	    VMW_S20*|VMW_RC)
		local x=`${PS} ${PSEF}|awk -v id="${1}" '$0!~/awk/&&$0~/\/bin\/vmware/&&$0!~/wrapper/&&$0~/displayName/&&$3!="1"&&$0~id{printf("%s",$2);}'`
		;;
	    VMW_WS*)
		local x=`${PS} ${PSEF}|awk -v id="${1}" '$0!~/awk/&&$0~/\/bin\/vmware/&&$0!~/wrapper/&&$0~/displayName/&&$3!="1"&&$0~id{printf("%s",$2);}'`
		;;

	    VMW_P105)
		local x=`${PS} ${PSEF}|awk -v id="${1}" '$0!~/awk/&&$0~/\/bin\/vmware/&&$0!~/wrapper/&&$0~/displayName/&&$3!="1"&&$0~id{printf("%s",$2);}'`
		;;
	    VMW_P2)
		local x=`${PS} ${PSEF}|awk -v id="${1}" '$0!~/awk/&&$0~/\/bin\/vmware/&&$0!~/wrapper/&&$0~/displayName/&&$3!="1"&&$0~id{printf("%s",$2);}'`
		;;
	    VMW_P3)
		local x=`${PS} ${PSEF}|awk -v id="${1}" '$0!~/awk/&&$0~/\/bin\/vmware/&&$0!~/wrapper/&&$0~/displayName/&&$3!="1"&&$0~id{printf("%s",$2);}'`
		;;
	esac
	printDBG $S_VMW ${D_BULK} $LINENO $BASH_SOURCE "VMW_MAGIC=<${VMW_MAGIC}> x=<${x}> \$1=<${1}>"
	if [ -z "${x}" ];then
	    return 1
	fi
	echo -n -e "${x}"
    }

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
    case ${VMW_MAGIC} in
	VMW_S1*)
	    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:check inventory:<$_pname>"
	    if [ -n "${VMWMGR}" ];then
		callErrOutWrapper $LINENO $BASH_SOURCE ${VMWCALL} ${VMWMGR} -l|grep -q ${_pname} 
		if [ $? -ne 0 ];then
		    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:add to inventory:<$_pname>"
		    local _mycall="${VMWCALL} ${VMWMGR} -s register '${_pname}'"
		    printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${_mycall}"
		    callErrOutWrapper $LINENO $BASH_SOURCE $_mycall
		    if [ $? -ne 0 -a $? -ne 20  ];then
                        ABORT=1;
			printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "Check inventory entry:<$_pname>"
			printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:failed to add inventory:<$_pname>"
			printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:check access permissions for:"
			printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}: ->\"${VMWCALL} ${VMWMGR}\""
			_isInInventory=NO;

			#keep consitent, for now deactivate
# 			printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Failed to add inventory entry:"
# 			printERR $LINENO $BASH_SOURCE ${ABORT} "path : <${_pname}>"
#  			printERR $LINENO $BASH_SOURCE ${ABORT} "Create the entry manually and/or check access permissions for:"
# 			printERR $LINENO $BASH_SOURCE ${ABORT} "call : <${_mycall}>"
# 	 		gotoHell ${ABORT}
	    else
			_isInInventory=YES;
		    fi
		else
		    _isInInventory=YES;
		fi
	    fi
	    ;;
	VMW_S2*)
###########################
#4TEST:VMW_RC: later add remote evaluation
#	VMW_S2*|VMW_RC)
###########################
	    if [ -n "${VMWMGR}" ];then
		_oid=$(ctysVMWS2FetchVMWObjID4Path ${_pname})
		printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:_oid=<${_oid}>"
		_store=$(ctysVMWS2ConvertToDatastore ${_pname})
		printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:oid=${oid} - _store=<$_store>"
		if [ -z "${_oid}" ];then
		    printINFO 0 $LINENO $BASH_SOURCE 0 "${FUNCNAME}:Missing inventory entry, create it."

		    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:add to inventory path:<$_pname>"
		    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:as:<$_store>"
		    local _mycall="${VMWCALL} ${VMWMGR} register '${_store}'"
		    printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${_mycall}"
		    eval "$_mycall"
		    if [ $? -ne 0 ];then
			ABORT=1;
			printERR $LINENO $BASH_SOURCE ${ABORT} "Failed to add inventory entry:"
			printERR $LINENO $BASH_SOURCE ${ABORT} "path:<$_pname>"
			printERR $LINENO $BASH_SOURCE ${ABORT} "as  :<$_store>"
 			printERR $LINENO $BASH_SOURCE ${ABORT} "Create the entry manually and/or check access permissions for:"
			printERR $LINENO $BASH_SOURCE ${ABORT} "<${_mycall}>"
			printINFO 1 $LINENO $BASH_SOURCE 0 "HINT:vmware-2.0 inventory addition requires a valid USER(-u) and PASSWD(-p)"
			printINFO 1 $LINENO $BASH_SOURCE 0 "HINT:Use suboption:ctys -create=user:${USER}%<passwd>,..."
 			gotoHell ${ABORT}
		    else
			printINFO 1 $LINENO $BASH_SOURCE 0 "path : <$_pname>"
			printINFO 1 $LINENO $BASH_SOURCE 0 "store: <$_store>"
		    fi
		fi
	    fi
	    ;;
    esac

    local CALLER=;
    case ${VMW_MAGIC} in
	VMW_P105)
	    CALLCLIENT="${VMWEXE}  ${C_SESSIONIDARGS:-$VMW_DEFAULTOPTS} \"${_pname}\""
	    CALLSERVER=;
	    ;;
	VMW_P2)
	    CALLCLIENT="${VMWEXE}  ${C_SESSIONIDARGS:-$VMW_DEFAULTOPTS} \"${_pname}\""
	    CALLSERVER=;
	    ;;
	VMW_P3)
	    CALLCLIENT="${VMWEXE}  ${C_SESSIONIDARGS:-$VMW_DEFAULTOPTS} \"${_pname}\""
	    CALLSERVER=;
	    ;;
	VMW_S1*)
	    CALLCLIENT="${VMWEXE} "
	    CALLCLIENT="${CALLCLIENT}  -s displayName=\"${_label}\" ${C_SESSIONIDARGS:-$VMW_DEFAULTOPTS} \"${_pname}\""
	    if [ -n "${C_GEOMETRY}" -o -n "${C_XTOOLKITOPTS}" ];then
		CALLCLIENT="${CALLCLIENT} -- ${C_GEOMETRY:+-geometry $C_GEOMETRY} ${C_XTOOLKITOPTS} "
	    fi

	    case "${_conty}" in
		NONE)
		    CALLCLIENT=;
		    CALLSERVER="${VMWMGR} \"${_pname}\" start trysoft"
		    ;;
	    esac
	    ;;
	VMW_RC)
	    case "${_conty}" in
		VMWRC)
		    CALLCLIENT="cd ${CTYS_VMW_VMRC%/*}&&"
		    CALLCLIENT="${CALLCLIENT}${CTYS_VMW_VMRC}";

		    if [ -n "${VMW_SESSION_USER}" ];then
			CALLCLIENT="${CALLCLIENT} -u ${VMW_SESSION_USER} ";
			if [ -n "${VMW_SESSION_CRED}" ];then
			    CALLCLIENT="${CALLCLIENT} -p ${VMW_SESSION_CRED} ";
			fi
		    fi

		    if [ -n "${CTYS_VMW_VMRC_ACCESS_HOST}" ];then
			CALLCLIENT="${CALLCLIENT} -h ${CTYS_VMW_VMRC_ACCESS_HOST} ";
		    fi
		    CALLCLIENT="${CALLCLIENT} -M ${_oid} ";
		    CALLSERVER=
		    ;;
		*)
		    CALLCLIENT="${VMWEXE}";
		    CALLSERVER=
		    ;;
	    esac
	    printDBG $S_VMW ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME:_conty=\"${_conty}\""
	    printDBG $S_VMW ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME:CALLCLIENT=\"${CALLCLIENT}\""
	    printDBG $S_VMW ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME:CALLSERVER=\"${CALLSERVER}\""
            ;;
	VMW_S2*)
	    local _oid=$(ctysVMWS2FetchVMWObjID4Path ${_pname})
	    case "${_conty}" in
		FIREFOX)
		    CALLCLIENT=`getPathName $LINENO $BASH_SOURCE ERROR firefox /usr/bin`
		    CALLCLIENTARGS="\"https://127.0.0.1:8333/ui/?wsUrl=http://localhost:8222/sdk&mo=VirtualMachine|${_oid}&inventory=none&tabs=hide_#{e:%22VirtualMachine|${_oid}%22,w:{t:false,i:0}}\""
		    CALLSERVER="${VMWMGR} start "
		    ;;
		VMWRC)
		    CALLCLIENT="cd ${CTYS_VMW_VMRC%/*}&&"
		    CALLCLIENT="${CALLCLIENT}${CTYS_VMW_VMRC}";

		    if [ -n "${VMW_SESSION_USER}" ];then
			CALLCLIENT="${CALLCLIENT} -u ${VMW_SESSION_USER} ";
			if [ -n "${VMW_SESSION_CRED}" ];then
			    CALLCLIENT="${CALLCLIENT} -p ${VMW_SESSION_CRED} ";
			fi
		    fi

		    if [ -n "${CTYS_VMW_VMRC_ACCESS_HOST}" ];then
			CALLCLIENT="${CALLCLIENT} -h ${CTYS_VMW_VMRC_ACCESS_HOST} ";
		    fi
		    CALLCLIENT="${CALLCLIENT} -M ${_oid} ";
		    CALLSERVER="${VMWMGR} start "
		    ;;
		NONE)
		    CALLCLIENT=;
		    CALLSERVER="${VMWMGR} start "
		    ;;
		*)
		    CALLCLIENT="${VMWEXE}";
		    CALLSERVER="${VMWMGR} start "
		    ;;
	    esac
	    printDBG $S_VMW ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME:_conty=\"${_conty}\""
	    printDBG $S_VMW ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME:CALLCLIENT=\"${CALLCLIENT}\""
	    printDBG $S_VMW ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME:CALLSERVER=\"${CALLSERVER}\""
	    ;;
	VMW_WS*)
	    CALLCLIENT="${VMWEXE} "
	    CALLCLIENT="${CALLCLIENT}  -s displayName=\"${_label}\" ${C_SESSIONIDARGS:-$VMW_DEFAULTOPTS} \"${_pname}\""
	    if [ -n "${C_GEOMETRY}" -o -n "${C_XTOOLKITOPTS}" ];then
		CALLCLIENT="${CALLCLIENT} -- ${C_GEOMETRY:+-geometry $C_GEOMETRY} ${C_XTOOLKITOPTS} "
	    fi

	    case "${_conty}" in
		VNC)
		    CALLCLIENT=;
		    CALLSERVER="${VMWMGR} start \"${_pname}\" nogui"
		    ;;
		NONE)
		    CALLCLIENT=;
		    CALLSERVER="${VMWMGR} start \"${_pname}\" nogui"
		    ;;
	    esac
	    ;;
    esac


    case ${VMW_MAGIC} in
	VMW_S2*|VMW_RC)
	    ;;
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
	_pingVMW=1;
	_sshpingVMW=1;
	printINFO 2 $LINENO $BASH_SOURCE 0 "$FUNCNAME:Activate C_STACK-ping+sshping"
    fi

    printINFO 2 $LINENO $BASH_SOURCE 0 "$FUNCNAME:CALLSERVER=\"${CALLSERVER}\""
    printINFO 2 $LINENO $BASH_SOURCE 0 "$FUNCNAME:CALLCLIENT=\"${CALLCLIENT}\""
    printDBG $S_VMW ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME:CALLSERVER=\"${CALLSERVER}\""
    printDBG $S_VMW ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME:CALLCLIENT=\"${CALLCLIENT}\""

    if [ -z "${C_NOEXEC}" ];then
	if [ -n "${CALLSERVER}" ];then
 	    printDBG $S_VMW ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:${VMW_MAGIC}-CALLSERVER=${CALLSERVER}"
 	    printDBG $S_VMW ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:${VMW_MAGIC}-CALLSERVER=${_store}"
	    case ${VMW_MAGIC} in
		VMW_S2*|VMW_RC)
		    printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${CALLSERVER} \"${_store}\""
		    eval ${CALLSERVER} "\"${_store}\""&>/dev/null&
		    ;;
		*)
		    printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${CALLSERVER}"
		    eval ${CALLSERVER}&>/dev/null&
		    ;;
	    esac
	    sleep ${_waitsVMW};
	else
            #non-stack only
	    if [ -n "${CALLCLIENT}" ];then
 		printDBG $S_VMW ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:${VMW_MAGIC}-CALLCLIENT=${CALLCLIENT}"
		case ${VMW_MAGIC} in
		    VMW_WS*)
			printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${CALLCLIENT}"
			eval ${CALLCLIENT} &
			;;
		    VMW_P*)
			printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${CALLCLIENT}"
			eval ${CALLCLIENT} &
			;;
		    VMW_S1*)
			printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${CALLCLIENT}"
			eval ${CALLCLIENT} &>/dev/null&
			;;
		    VMW_RC)
			printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${CALLCLIENT} ${CALLCLIENTARGS}"
			eval ${CALLCLIENT} "${CALLCLIENTARGS}"&>/dev/null&
			;;
		    VMW_S2*)
			printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${CALLCLIENT} ${CALLCLIENTARGS}"
			eval ${CALLCLIENT} "${CALLCLIENTARGS}"&>/dev/null&
			;;
		    *)
			printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${CALLCLIENT}"
			eval ${CALLCLIENT} &
			;;
		esac
		sleep ${_waitcVMW};
	    else
		ABORT=3
		printERR $LINENO $BASH_SOURCE ${ABORT} "Missing CALLSERVER AND CALLCLIENT"
		gotoHell ${ABORT}
	    fi
	fi

	local _pingok=0;
	local _sshpingok=0;

	if [ "$_pingVMW" == 1 ];then
	    netWaitForPing "${_myVM}" "${_pingcntVMW}" "${_pingsleepVMW}"
	    _pingok=$?;
	fi

	if [ "$_pingok" == 0 -a "$_sshpingVMW" == 1 ];then
	    netWaitForSSH "${_myVM}" "${_sshpingcntVMW}" "${_sshpingsleepVMW}" "${_actionuserVMW}"
	    _sshpingok=$?;
	fi

	if [ "${C_STACK}" == 1 ];then
	    printDBG $S_VMW ${D_FLOW} $LINENO $BASH_SOURCE "C_STACK=${C_STACK}"
	    if [ $_pingok != 0 ];then
		ABORT=1
		printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "Start timed out:netWaitForPing"
		printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "  VM =${_myVM}"

		printWNG 1 $LINENO $BASH_SOURCE 0 "${_VHOST}  <${_label}> <${MYHOST}>  <${_pname}>"
		printWNG 1 $LINENO $BASH_SOURCE 0 "<${_myVM}> <${_pingcntVMW}> <${_pingsleepVMW}>"
		gotoHell ${ABORT}
	    else
 		printDBG $S_VMW ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:Accessable by ping:${_myVM}"
	    fi

	    netWaitForSSH "${_myVM}" "${_sshpingcntVMW}" "${_sshpingsleepVMW}" "${_actionuserVMW}"
	    if [ $? != 0 ];then
		printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "Start timed out:netWaitForSSH"
		printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "  VM =${_myVM}"

		printWNG 1 $LINENO $BASH_SOURCE 0 "${_VHOST}  <${_label}> <${MYHOST}>  <${_pname}>"
		printWNG 1 $LINENO $BASH_SOURCE 0 "<${_myVM}> <${_sshpingcntVMW}> <${_sshpingsleepVMW}>"
		gotoHell 0
	    else
 		printDBG $S_VMW ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:Accessable by ssh:${_myVM}"
	    fi
	fi

        #
        #assume pre-checked appropriate content
	if [ -n "${CALLSERVER}" -a -n "${CALLCLIENT}" ];then
 	    printDBG $S_VMW ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:${VMW_MAGIC}"
	    case ${VMW_MAGIC} in
#		VMW_S2*)
		VMW_S2*|VMW_RC)
 		    printDBG $S_VMW ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:${CALLCLIENT} ${CALLCLIENTARGS}"
		    printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${CALLCLIENT} ${CALLCLIENTARGS:+\"$CALLCLIENTARGS\"}&"
		    eval ${CALLCLIENT} ${CALLCLIENTARGS:+"$CALLCLIENTARGS"}&
		    ;;
		*)
		    printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${CALLCLIENT} &"
		    eval ${CALLCLIENT} &
		    ;;
	    esac
	    sleep ${_waitcVMW};
	else
	    case "${_conty}" in
		VNC)
		    _VNC_CLIENT_MODE=`getVNCport "${_pname}"`
		    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:VNCviewer:"
		    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_VNC_CLIENT_MODE=<${_VNC_CLIENT_MODE}>"
		    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_label=<${_label}>"
		    connectSessionVMWVNC "${_VNC_CLIENT_MODE}" "${_label}"
		    ;;
	    esac
	fi

	local _myAttrLst="JOBID=${CALLERJOB}:$((JOB_IDXSUB++));"
	cacheStoreWorkerPIDData SERVER VMW "${_pname}" "${_label}" 0 "" REPLACE "${_myAttrLst}"
	case "${_conty}" in
	    VMWRC)
		cacheStoreWorkerPIDData CLIENT VMW "${_pname}" "${_label}" 0 "" REPLACE "${_myAttrLst}"
		;;
	    VMW)
		cacheStoreWorkerPIDData CLIENT VMW "${_pname}" "${_label}" 0 "" REPLACE "${_myAttrLst}"
		;;
	    VNC)
		cacheStoreWorkerPIDData CLIENT VNC "" "${_label}" 0 "" REPLACE "${_myAttrLst}"
		;;
	esac
	if [ "${C_ASYNC}" == 0 ];then
	    wait
	fi
    fi
}



#FUNCBEG###############################################################
#NAME:
#  connectSessionVMW
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
#      REMARKS: The design idea for intoduction of this param is:
#
#        1. This is an plugin-internal function, though 
#           developer-level experience is assumed.
#
#        2. Despite this, parameter structure for this common task 
#           has to be kept common, at least similiar, even though 
#           some partial enhancement opportunity may remain.
#
#           So analogous to ...
#
#             VNC-plugin,
#               where <session-id> is the display ID and so
#               in an algoritmic relation to the TCP-PORT. Which 
#               is true due to design-standard for local server  
#               port as well, as for the entry-port of remote-tunnel.
#             WMWVNC
#               where basically an intermix of VMW and VNC is 
#               implemented, requiring an bridging addressing schema
#               between VM-ID and TCP-accessport.
#             XEN
#               very close to VMWVNC.
#
#           The design assumption, where the <session-id> could be
#           mathematically calculated from the server's TCP accessport 
#           and vice versa is not true for VMW with it's propriatery 
#           CONSOLE.
#
#       So, now:
#
#         <actual-access-id> is
#           1. if 
#                 [ <actual-access-id> == <session-id> ]
#              or
#                 [ <actual-access-id> == "" ]
#
#              to be replaced by <pname> for local access by native call
#
#           2. if [ <actual-access-id> != <session-id> ]
#
#              to be used as TCP-port for remote access by tunnel to 
#              remote server where assumed:
#
#                 <actual-access-id> == <tunnel-entry TCP-port> 
#
#              Generally could be assumed
#
#                 <actual-access-id> == <ANY local single TCP-port-entry to ANYWHERE> 
#
#              Basically it is transparent to where the connection leads.
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
function connectSessionVMW () {
    local _id=${1}
    local _label=${2}
    local _actaccessID=${3}
    local _myVM=$4;
    local _myCon=$5;
    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:ID        =$_pname"
    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:LABEL     =$_label"
    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:ACCESSID  =$_actaccessID"
    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:VM-TCP/IP =$_myVM"
    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:CONSOLE   =$_myCon"

    if [ -z "${_id}" -o -z "${_label}" ];then
	ABORT=1
	printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:At least one parameter required:<session-id> or <session-label>"
	gotoHell ${ABORT}
    fi

    if [ -z "${_actaccessID}" -o "${_actaccessID}" == "${_id}" ];then
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
	case ${VMW_MAGIC} in
	    VMW_S103|VMW_S104)
                #Yes, the connect-call for a session gwhich is - as PRE-REQUIRED - in 
                #background-continue-mode - is identical to the create-call.
                #=> CONNECT-CLI-IF of vmware is identical to CREATE-CLI-IF
		startSessionVMW "${_label}" "${_id}" "${_myVM}" "${_myCon}"
 		;;

	    VMW_S20|VMW_RC)
                #Yes, the connect-call for a session gwhich is - as PRE-REQUIRED - in 
                #background-continue-mode - is identical to the create-call.
                #=> CONNECT-CLI-IF of vmware is identical to CREATE-CLI-IF
		startSessionVMW "${_label}" "${_id}" "${_myVM}" "${_myCon}"
 		;;

            #	VMW_S103|WMW_WS6|VMW_GENERIC)
	    *)  #For now seems to be common, but let it beeee....

                #Yes, the connect-call for a session gwhich is - as PRE-REQUIRED - in 
                #background-continue-mode - is identical to the create-call.
                #=> CONNECT-CLI-IF of vmware is identical to CREATE-CLI-IF
		startSessionVMW "${_label}" "${_id}" "${_myVM}" "${_myCon}"
 		;;
	esac
    else
        #
        #remote access through local wormhole
        #
        #Now _accessID should be the port for local wormhole entry
        #and of course, this process is executing on callers machine.
        #
        #And of course, hopefully the local client - with its VMW_MAGIC -
        #is compatible to the remote callee or in case of VNC the server 
        #site should be a ws6+.
        #

        #
        #Tests are performed from a workstation with VMW_S103 to 
        #servers and workstations with VMW_S103 and WMW_WS6,
        #and installed RealVNC.


	if [ -n "${_VNC_CLIENT_MODE}" ];then
            #Let client "beeee a WS6+", let's go
	    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:VNCviewer"
	    connectSessionVMWVNC "${_VNC_CLIENT_MODE}" "${_label}" 
	else
	    case ${VMW_MAGIC} in
		VMW_S20|VMW_RC)

                    #Yes, the connect for a session gwhich is - as PRE-REQUIRED - in 
                    #background-continue-mode - CONNECT-CLI-IF of vmware is identical 
                    #to CREATE-CLI-IF

		    VMW_DEFAULTOPTS="${VMW_DEFAULTOPTS} -h localhost -P ${_actaccessID}"
		    startSessionVMW "${_label}" "${_id}" "${_myVM}" "${_myCon}"
 		    ;;

		VMW_S10*)

                    #Yes, the connect for a session gwhich is - as PRE-REQUIRED - in 
                    #background-continue-mode - CONNECT-CLI-IF of vmware is identical 
                    #to CREATE-CLI-IF

		    VMW_DEFAULTOPTS="${VMW_DEFAULTOPTS} -h localhost -P ${_actaccessID}"
		    startSessionVMW "${_label}" "${_id}" "${_myVM}" "${_myCon}"
 		    ;;

               #	VMW_S103|VMW_WS6|VMW_GENERIC)
		*)  #For now seems to be common, but let it beeee....
		    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME "
		    ABORT=2
		    noClientServerSplitSupportedMessageVMW
		    gotoHell ${ABORT}
 		    ;;
	    esac
	fi

    fi
}




#FUNCBEG###############################################################
#NAME:
#  vmMgrVMW
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Encapsulates the vmrun command with unified calls.
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
#                                                            &&kill -9 <vm-pid>
#
#
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function vmMgrVMW () {
    printDBG $S_VMW ${D_FLOW} $LINENO $BASH_SOURCE "${FUNCNAME}:$*"
    local _cmd=$1;shift
    local _label=$1;shift;#just for unifying interface
    local _id=$1;shift

    printINFO 1 $LINENO $BASH_SOURCE 0 "${FUNCNAME}:Check hypervisor now for remaining VM:$_label"

    #TODO
    #check for execution elsewhere-once-only
    #
    case $VMW_MAGIC in
	VMW_S2*)
	    _store=$(ctysVMWS2ConvertToDatastore ${_id})
	    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:_store=<$_store>"
	    if [ -z "$_store" ];then
                ABORT=1;
		printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Missing:<$_pname>"
		printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:shouldn't happen here??!!!"
		return 1;
	    fi
	    CALLSERVER="callErrOutWrapper $LINENO $BASH_SOURCE ${CALLSERVER}"
	    ;;
    esac


    case $_cmd in
	START|CREATE|RESUME)
	    local _params=$1;shift
	    case $(_params) in
		gui);;
		nogui)
		    printINFO 1 $LINENO $BASH_SOURCE $ABORT "${FUNCNAME}:Call Headless"
		    ;;
		*)
		    ;;
	    esac
            if [ -z "${C_NOEXEC}" ];then
		printINFO 1 $LINENO $BASH_SOURCE $ABORT "${FUNCNAME}:Require hypervisor for:$_cmd"
		case $VMW_MAGIC in
		    VMW_WS*)
			case $(_params) in
			    gui)
				printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${VMWMGR} start $_id"
				${VMWMGR} start $_id
				;;
			    nogui)
				printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${VMWMGR} start $_id nogui"
				${VMWMGR} start "$_id" nogui
				;;
			    *)
				;;
			esac
			;;
		    VMW_S1*)
			case $(_params) in
			    gui)
				ABORT=1
				printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:GUI is not supported by \"${VMWMGR}\""
				gotoHell ${ABORT}
				;;
			    nogui)
				printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${VMWMGR} start $_id hard"
				${VMWMGR} $_id start hard
				;;
			    *)
				;;
			esac
			;;
		    VMW_S2*)
			case $(_params) in
			    gui)
				ABORT=1
				printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:GUI is not supported by \"${VMWMGR}\""
				gotoHell ${ABORT}
				;;
			    nogui)
				case $_cmd in
				    START)
					printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${VMWMGR} start $_id \"${_store}\""
					eval ${VMWMGR} start "\"${_store}\""
					;;
				    RESUME)
					printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${VMWMGR} start \"${_store}\""
					eval ${VMWMGR} start "\"${_store}\""
					;;
				esac
				;;

			    *)
				;;
			esac
			;;
		esac
	    fi
	    ;;
	STOP|CANCEL)
	    ABORT=1
	    printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Command is not supported:${_cmd}"
	    gotoHell ${ABORT}


            if [ -z "${C_NOEXEC}" ];then
		printDBG $S_VMW ${D_FLOW} $LINENO $BASH_SOURCE "${FUNCNAME} Call:SHUTDOWN/STOP"
		printDBG $S_VMW ${D_FLOW} $LINENO $BASH_SOURCE "  ID = ${_id}"
		case $VMW_MAGIC in
		    VMW_WS*)
			${VMWMGR} stop $_id
			;;
		    VMW_S2*)
			printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${VMWMGR} stop \"${_store}\""
			eval ${VMWMGR} stop "\"${_store}\""
			;;
		    VMW_S1*)
			printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${VMWMGR} $_id stop trysoft"
			${VMWMGR} $_id stop trysoft
			;;
		esac
	    fi
	    ;;
	SUSPEND)
            if [ -z "${C_NOEXEC}" ];then
		printINFO 1 $LINENO $BASH_SOURCE $ABORT "${FUNCNAME}:Require hypervisor for:SUSPEND"
		case $VMW_MAGIC in
		    VMW_WS*)
			printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${VMWMGR} suspend $_id"
			${VMWMGR} suspend $_id
			;;
		    VMW_S1*)
			printINFO 0 $LINENO $BASH_SOURCE 1 "FINAL-WRAPPER-SCRIPT-CALL=<eval ${VMWMGR} $_id suspend hard "
			${VMWMGR} $_id suspend hard
			;;
		    VMW_S2*)
			printINFO 0 $LINENO $BASH_SOURCE 1 "FINAL-WRAPPER-SCRIPT-CALL=<eval ${VMWMGR} suspend \"${_store}\""
			eval ${VMWMGR} suspend "\"${_store}\""
			;;
		esac
	    fi
	    ;;
	RESET)
            if [ -z "${C_NOEXEC}" ];then
		printINFO 1 $LINENO $BASH_SOURCE $ABORT "${FUNCNAME}:Require hypervisor for:RESET"
		printDBG $S_VMW ${D_FLOW} $LINENO $BASH_SOURCE "${FUNCNAME} Call:RESET"
		printDBG $S_VMW ${D_FLOW} $LINENO $BASH_SOURCE "  ID = ${_id}"
		case $VMW_MAGIC in
		    VMW_WS*)
			printINFO 0 $LINENO $BASH_SOURCE 1 "FINAL-WRAPPER-SCRIPT-CALL=<eval ${VMWMGR} reset $_id"
			${VMWMGR} reset $_id
			;;
		    VMW_S1*)
			printINFO 0 $LINENO $BASH_SOURCE 1 "FINAL-WRAPPER-SCRIPT-CALL=<eval ${VMWMGR} $_id reset hard"
			${VMWMGR} $_id reset hard
			;;
		    VMW_S2*)
			printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${VMWMGR} reset \"${_store}\""
			eval ${VMWMGR} reset "\"${_store}\""
#			eval ${VMWMGR} reset "\"${_store}\""&>/dev/null&
			;;
		esac
	    fi
	    ;;
	POWEROFF)
            local _timeout=${1:-$DEFAULT_KILL_DELAY_POWEROFF};shift
            local _pid=$1;shift
            ABORT=1;
	    local _idX=$(fetchID4PID ${_pid});
            if [ -z "${_idX}" ];then
		printINFO 1 $LINENO $BASH_SOURCE $ABORT "${FUNCNAME}:Server is already stopped by STACK operations."
	    else
		if [ -z "${C_NOEXEC}" ];then
		    printINFO 1 $LINENO $BASH_SOURCE $ABORT "${FUNCNAME}:Require hypervisor for:POWEROFF"
		    case $VMW_MAGIC in
			VMW_WS*)
			    printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${VMWMGR} stop $_id"
			    ${VMWMGR} stop $_id
			    ;;
			VMW_S1*)
			    printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${VMWMGR} $_id stop hard"
			    ${VMWMGR} $_id stop hard
			    ;;
			VMW_S2*)
			    printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${VMWMGR}  stop \"${_store}\""
			    eval ${VMWMGR} stop "\"${_store}\""
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
			    callErrOutWrapper $LINENO $BASH_SOURCE  ${VMWCALL} kill $_pid
			    printWNG 1 $LINENO $BASH_SOURCE $ABORT "${FUNCNAME} Delay forced \"kill -9\":${_timeout} seconds"
			    sleep $_timeout
			    if [ "`fetchID4PID ${_pid}`" == "${_id}" ];then
				printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME} Have to use \"-9\" now:${_pid}==${_id}"
				callErrOutWrapper $LINENO $BASH_SOURCE  ${VMWCALL} kill $_pid
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
    esac
}





#FUNCBEG###############################################################
#NAME:
#  connectSessionVMWVNC
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: <display-id>|<display-port>
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
function connectSessionVMWVNC () {
    local _id=${1}
    local _label=${2}
    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME ${_id} ${_label}"


    #even though this condition might be impossible now, let it beeeee ...
    if [ -z "${_label}" -a -z "${_id}" ];then
	ABORT=1
	printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Fetch of peer entry failed:_id=${_id} - _label=${_label}"
	gotoHell ${ABORT}
    fi

    printDBG $S_VMW ${D_FRAME} $LINENO $BASH_SOURCE "OK:_id=${_id} - _label=${_label}"
    #
    #Now shows name+id in title, id could not be set for server as default.
    local _vieweropt="-name ${_label}:${_id} ${VNCVIEWER_OPT} ${C_GEOMETRY:+ -geometry=$C_GEOMETRY} "
    #
    local CALLER="${VNCVIEWER} ${C_DARGS} ${_vieweropt} :${_id}"
    printDBG $S_VMW ${D_FRAME} $LINENO $BASH_SOURCE "${CALLER}"
    export C_ASYNC;
    [ -z "${C_NOEXEC}" ]&&eval ${CALLER}
}




