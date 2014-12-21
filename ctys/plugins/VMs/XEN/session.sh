#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@users.sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_018
#
########################################################################
#
# Copyright (C) 2007,2008,2010,2011 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

_myPKGNAME_XEN_SESSION="${BASH_SOURCE}"
_myPKGVERS_XEN_SESSION="01.11.018"
hookInfoAdd $_myPKGNAME_XEN_SESSION $_myPKGVERS_XEN_SESSION
_myPKGBASE_XEN_SESSION="`dirname ${_myPKGNAME_XEN_SESSION}`"

_VNC_CLIENT_MODE=;


#FUNCBEG###############################################################
#NAME:
#  fetchXenDomID4Label
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Onyl applicable on execution target
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: LABEL
#
#OUTPUT:
#  RETURN:
#  VALUES:
#    <DomU-ID>
#
#FUNCEND###############################################################
function fetchXenDomID4Label () {
    local _x=`callErrOutWrapper $LINENO $BASH_SOURCE  ${VIRSHCALL} ${VIRSH} domid $1`
    local _ret=$?
    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:domid=${_x//[^0-9]/}"
    echo ${_x//[^0-9]/}
    return $_ret
}


#FUNCBEG###############################################################
#NAME:
#  noClientServerSplitSupportedMessageXEN
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
function noClientServerSplitSupportedMessageXEN () {
    ABORT=1
    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "INFO:Client-Server-Split is supported by Xen, thus check following hints:"
    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "INFO: - Server is not running"
    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "INFO: - VNC is not configured for DomU:\"vnc=1\""
    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "INFO: - No access permissions for \"virsh dumpxml\", check sudo/ksu"
    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "INFO: - No SSH access to target"
}


#FUNCBEG###############################################################
#NAME:
#  expandSessionIDXEN
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
function expandSessionIDXEN () {
    echo $1
}



#FUNCBEG###############################################################
#NAME:
#  startSessionXEN
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
#     For legacy reasons of inherited code, in case of Xen, Xen itself
#     requires UNIQUE(scope=node+) DomainName=LABEL to be preconfigured
#     in config file(pname), so must not differ!!!
#
# $2: ID/pname
# $3: console type:CLI|VNC|GTERM|XTERM
# $4: BootMode
# $5: GuestOS-TCP/IP-Address
#
# $6: Instmode
#     <mode>[%<path>]
# $7: KernelMode
#     <kernel>[%<initrd>[%<append>]]
# $8: AddArgs

#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function startSessionXEN () {
    local _label=$1
    local _pname=$2
    local _console=${3:-$XEN_CONSOLE_DEFAULT}
    local _bootmode=$4
    local _myVM=${5};
    local _instmode=${6}
    local _kernelmode=${7}
    local _addargs=${8}

    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:LABEL              =<$_label>"
    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:PNAME              =<$_pname>"
    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:CONSOLE            =<$_console>"
    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:BOOTMODE           =<$_bootmode>"
    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:C_CLIENTLOCATION   =<$C_CLIENTLOCATION>"
    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:GUEST-IP          =<$_myVM>"
    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:INSTMODE           =<$_instmode>"
    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:KERNEL             =<$_kernelmode>"
    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:ADDARGS            =<$_addargs>"

    local CALLER=;

    #should not happen, anyhow, once again, check it
    if [ -z "${_label}" ];then
	ABORT=1
	printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Missing LABEL"
	gotoHell ${ABORT}
    fi

    #should not happen, anyhow, once again, check it
    if [ -z "${_pname}" ];then
	ABORT=1
	printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Missing PNAME"
	gotoHell ${ABORT}
    fi

    if [ "${C_STACK}" == 1 ];then
	printDBG $S_XEN ${D_FLOW} $LINENO $BASH_SOURCE "C_STACK=${C_STACK}"
	if [ -z "${_myVM}" -a \( "$_pingXEN" == 1 -o  "$_sshpingXEN" == 1 \) ];then
	    ABORT=2;
	    printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Missing the TCP/IP address of VM:${_label}"
	    printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Cannot operate synchronous with GuestOS."
	    printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:So VMSTACK is in almost any case not operable."
	    gotoHell ${ABORT}
	fi
    fi


    if [ ! -e "${_pname}" ];then
	ABORT=1
	printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Missing file PNAME=${_pname}"
	gotoHell ${ABORT}
    fi

    #use these in wrapper config scripts: _pname
    export XENUCALL
    export XEN
    export XEN_MAGIC

    #get free for forced set
    VNCACCESSDISPLAY=`getFirstFreeVNCDisplay "${VNC_BASEPORT}"`;
    let VNCACCESSPORT=VNCACCESSDISPLAY-VNC_BASEPORT;

    #set appropriate call
    CALLER="${_pname/.ctys/.sh} ${C_DARGS} "
    case $_console in
	SDL)
 	    CALLER="${CALLER}--console=SDL "
	    ;;
	CLI0)
 	    CALLER="${CALLER}--console=CLI "
	    ;;
	XTERM|GTERM|EMACS|EMACSM|EMACSA|EMACSAM)
#	    CALLER="${CALLER}--console=CLI "
	    CALLER="${CALLER}--console=NONE "
	    ;;
	VNC)
	    CALLER="${CALLER}--console=VNC "
	    ;;
	NONE)
	    CALLER="${CALLER}--console=NONE "
	    ;;
	*)
	    CALLER="${CALLER}--console=${_console// /} "
	    ;;
    esac
    CALLER="${CALLER} --vncaccessdisplay=${VNCACCESSDISPLAY} "
    if [ -z "$_instmode" ];then
	CALLER="${CALLER} ${_bootmode:+--bootmode=$_bootmode} "
    else
	case ${_instmode} in
	    '')	    ;;
	    CONFIG) CALLER="${CALLER} --instmode --initmode  ";;
	    *)      CALLER="${CALLER} ${_instmode:+--instmode=$_instmode} ";;
	esac
    fi
    CALLER="${CALLER} ${_kernelmode:+--kernelmode=$_kernelmode} "
    CALLER="${CALLER} ${_appargs:+--appargs=$_appargs} "

    CALLER="export C_ASYNC=${C_ASYNC}&&${CALLER} ";
    
    printDBG $S_XEN ${D_FLOW} $LINENO $BASH_SOURCE "_console         = ${_console}"
    printDBG $S_XEN ${D_FLOW} $LINENO $BASH_SOURCE "TERM             = ${TERM}"
    printDBG $S_XEN ${D_FLOW} $LINENO $BASH_SOURCE "ENABLE           = ${CALLER}"
    printDBG $S_XEN ${D_FLOW} $LINENO $BASH_SOURCE "C_ASYNC          = ${C_ASYNC}"
    printDBG $S_XEN ${D_FLOW} $LINENO $BASH_SOURCE "C_CLIENTLOCATION = ${C_CLIENTLOCATION}"

    printINFO 2 $LINENO $BASH_SOURCE 0 "$LINENO $BASH_SOURCE $FUNCNAME:CALLER=\"${CALLER}\""

    if [ "${C_STACK}" == 1 ];then
	_pingXEN=1;
	_sshpingXEN=1;
    fi


  ###
   ####
    ####Start now.
   ####
  ###


    if [ -z "${C_NOEXEC}" ];then
	printFINALCALL 1  $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${CALLER} --check"
	export PATH=${XEN_PATHLIST}:${PATH}&&eval ${CALLER} --check
	if [ $? -ne 0 ];then
	    ABORT=1
	    printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Check failed:"
	    printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:<${CALLER} --check>"
	    printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Check execution permissions first."

	    gotoHell ${ABORT}
	fi
	printFINALCALL 1  $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${CALLER}"
	export PATH=${XEN_PATHLIST}:${PATH}&&eval ${CALLER} &sleep ${CTYS_PREDETACH_TIMEOUT:-10}>/dev/null&
	sleep ${XEN_INIT_WAITS}

	local _pingok=0;
	local _sshpingok=0;

	if [ "$_pingXEN" == 1 ];then
	    netWaitForPing "${_myVM}" "${_pingcntXEN}" "${_pingsleepXEN}"
	    _pingok=$?;
	fi

	if [ "$_pingok" == 0 -a "$_sshpingXEN" == 1 ];then
	    netWaitForSSH "${_myVM}" "${_sshpingcntXEN}" "${_sshpingsleepXEN}" "${_actionuserXEN}"
	    _sshpingok=$?;
	fi

	if [ "${C_STACK}" == 1 ];then
	    printDBG $S_XEN ${D_FLOW} $LINENO $BASH_SOURCE "C_STACK=${C_STACK}"
	    if [ $_pingok != 0 ];then
		ABORT=1
		printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "Start timed out:netWaitForPing"
		printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "  VM =${_myVM}"

		printWNG 1 $LINENO $BASH_SOURCE 0 "${_VHOST}  <${_label}> <${MYHOST}>  <${_pname}>"
		printWNG 1 $LINENO $BASH_SOURCE 0 "<${_myVM}> <${_pingcntXEN}> <${_pingsleepXEN}>"
		gotoHell ${ABORT}
	    else
 		printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:Accessable by ping:${_myVM}"
	    fi

	    netWaitForSSH "${_myVM}" "${_sshpingcntXEN}" "${_sshpingsleepXEN}" "${_actionuserXEN}"
	    if [ $? != 0 ];then
		printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "Start timed out:netWaitForSSH"
		printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "  VM =${_myVM}"

		printWNG 1 $LINENO $BASH_SOURCE 0 "${_VHOST}  <${_label}> <${MYHOST}>  <${_pname}>"
		printWNG 1 $LINENO $BASH_SOURCE 0 "<${_myVM}> <${_sshpingcntXEN}> <${_sshpingsleepXEN}>"
		gotoHell 0
	    else
 		printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:Accessable by ssh:${_myVM}"
	    fi
	fi
	cacheStoreWorkerPIDData SERVER XEN "${_pname}" "${_label}" 0 ""
    fi

    VNCACCESSDISPLAY=;
    VNCACCESSPORT=;


    #
    #just wait for the "inherent" prompt.
    #
    if [ "$_console" == "CLI0" -o  "$_console" == "SDL" -o  "$_console" == "NONE" ];then
	return
    fi

    #
    #no client is required, so it's headless
    if [ "${C_CLIENTLOCATION}" ==  "-L SERVERONLY" ];then
	return
    fi

    printDBG $S_XEN ${D_FLOW} $LINENO $BASH_SOURCE "Attach CONSOLE:${CALLER}"
    case $_console in
	VNC)
	    local _myDisp=`fetchDisplay4Label CHILD ${_label}`
	    local xi=;
	    for((xi=0;xi<XEN_RETRYVNCCLIENTCONNECT;xi++));do
		if [ -z "${_myDisp}" ];then
		    sleep ${XEN_RETRYVNCCLIENTTIMEOUT};
		    _myDisp=`fetchDisplay4Label CHILD  ${_label}`
		fi
	    done
	    if [ -z "$_myDisp" ];then
		ABORT=1
		printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Cannot evaluate server display for VNC."
		gotoHell ${ABORT}
	    fi
	    connectSessionXEN $_console  "$_label" "$_pname" "$_myDisp"
	    ;;
	CLI|XTERM|GTERM|EMACS|EMACSM|EMACSA|EMACSAM)
	    connectSessionXEN $_console "$_label" "$_pname" 
	    ;;
	NONE)
	    ;;
	*)
	    ABORT=1
	    printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Unexpected CONSOLE:${_console}"
	    gotoHell ${ABORT}
	    ;;
    esac

    if [ "${C_ASYNC}" == 0 ];then
	wait
    fi
    return
}


#FUNCBEG###############################################################
#NAME:
#  connectSessionXEN
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
#  $1: <console-type> could be
#      CLI|X11|VNC
#
#  $2: <session-label>
#      This will be used for the title of the client window.
#
#  $3: <session-id>
#      This is the absolute pathname to the vmx-file.
#
#  $4: <actual-access-id>
#      This will be used for actual connection, when direct acces to
#      a ip port is provided. 
#
#
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function connectSessionXEN () {
    local _contype=${1}
    local _label=${2}
    local _id=${3}
    local _actaccessID=${4}

    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:LABEL              =$_label"
    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:ID                 =$_id"
    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:ACTACCESSID        =$_actaccessID"
    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:CONTYPE            =$_contype"
    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:C_CLIENTLOCATION=$C_CLIENTLOCATION"

    if [ -z "${_id}" -o -z "${_label}" ];then
	ABORT=1
	printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:At least one parameter required:<session-id> or <session-label>"
	gotoHell ${ABORT}
    fi

    local CALLER=;

    local _args=;
    local _args1=;
    _args1="${_args1} ${C_DARGS} "
    _args1="${_args1} ${C_ASYNC:+ -b $C_ASYNC} "
    _args1="${_args1} ${C_GEOMETRY:+ -g $C_GEOMETRY} "
    _args1="${_args1} ${C_ALLOWAMBIGIOUS+ -A $C_ALLOWAMBIGIOUS} "
    _args1="${_args1} ${C_SSH_PSEUDOTTY:+ -z $C_SSH_PSEUDOTTY} "
    _args1="${_args1} ${C_XTOOLKITOPTS} "


    local _args=" -j ${CALLERJOBID}.$((JOB_SUBIDX++)) -E -F ${VERSION} ";

    #
    #local native access: same as DISPLAYFORWARDING or LOCALONLY
    #
    case $_contype in
	CLI)
	    CALLER="${XENCALL} ${XM} console `fetchXenDomID4Label ${_label}`"
	    ;;
	GTERM)
	    _args="${_args} -t X11 -a create=l:${_label},cmd:gnome-terminal,dh"
 	    _args="${_args},c:${XENCALL// /%}%${XM}%console%`fetchXenDomID4Label ${_label}`"
            _args="${MYLIBEXECPATH}/ctys.sh ${_args} ${_args1} "
	    printDBG $S_XEN ${D_FLOW} $LINENO $BASH_SOURCE "_args=${_args}"
	    CALLER="${_args}"
	    ;;
	XTERM)
	    _args="${_args} -t X11 -a create=l:${_label},cmd:xterm,sh,c:${XENCALL// /%}%${XM}%console%`fetchXenDomID4Label ${_label}`"
            _args="${MYLIBEXECPATH}/ctys.sh ${_args} ${_args1} "
	    printDBG $S_XEN ${D_FLOW} $LINENO $BASH_SOURCE "_args=${_args}"
	    CALLER="${_args}"
	    ;;
	EMACS|EMACSA|EMACSM|EMACSAM)
#	    _args="${_args} -t X11 -a create=l:${_label},console:${_contype},c:${XENCALL// /%}%${XM}%console%`fetchXenDomID4Label ${_label}`"
	    _args="${_args} -t X11 -a create=l:${_label},console:${_contype},s:${XENCALL// /%}%${XM}%console%`fetchXenDomID4Label ${_label}`"
            _args="${MYLIBEXECPATH}/ctys.sh ${_args} ${_args1} "
	    printDBG $S_XEN ${D_FLOW} $LINENO $BASH_SOURCE "_args=${_args}"
	    CALLER="${_args}"
	    ;;
	VNC)
	    if [ -n "${_actaccessID}" ];then
 		connectSessionXENVNC "${_actaccessID}" "${_label}" 
	    else
		ABORT=1
		printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Missing port for VNC viewer, reasons could be:"
		printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:- Configuration error, check \"vnc=1\""
		printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:- Server is not running"
		gotoHell ${ABORT}
	    fi
	    return
	    ;;
	*)
	    ABORT=1
	    printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Unknown CONSOLE:${_contype}"
	    gotoHell ${ABORT}
	    ;;
    esac

    printDBG $S_XEN ${D_FLOW} $LINENO $BASH_SOURCE "TERM=${TERM}"
    printDBG $S_XEN ${D_FLOW} $LINENO $BASH_SOURCE "Attach CONSOLE:${CALLER}"
    printFINALCALL 1  $LINENO $BASH_SOURCE "FINAL-XEN-CONSOLE:STARTER(${_label})" "${CALLER}"
    [ -z "${C_NOEXEC}" ]&&eval ${CALLER} 
}



#FUNCBEG###############################################################
#NAME:
#  vmMgrXEN
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
# $1:                 $2       $3                        
#---------------------------------------------------------------------
# REBOOT              <label> <id-pname>                 => virsh  reboot
# RESET               <label> <id-pname>                 => virsh  reboot
# PAUSE               <label> <id-pname>                 => virsh  suspend
# SUSPEND             <label> <id-pname>  <statefile>    => virsh  save 
# POWEROFF            <label> <id-pname>  <timeout>      => virsh  shutdown+destroy
#
# RESUME              <label> <id-pname>  [<statefile>]  => virsh  reboot
#
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function vmMgrXEN () {
    printDBG $S_XEN ${D_FLOW} $LINENO $BASH_SOURCE "${FUNCNAME} $*"
    local _cmd=$1;shift
    local _label=$1;shift
    local _id=$1;shift
    local _arg=$1;shift


    if [ -z "${_cmd}" ];then
	ABORT=1
	printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Missing CMD"
	gotoHell ${ABORT}
    fi
    if [ -z "${_label}" ];then
	ABORT=1
	printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Missing LABEL"
	gotoHell ${ABORT}
    fi
    if [ -z "${_id}" ];then
	ABORT=1
	printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Missing ID"
	gotoHell ${ABORT}
    fi


    [ "$C_ASYNC" == 1 ]&&local _bg="&"
    case $_cmd in
        #CREATE######################
	RESUME)
            if [ -z "${C_NOEXEC}" ];then
		printINFO 2 $LINENO $BASH_SOURCE $ABORT "${FUNCNAME}:Require hypervisor for:$_cmd"
		if [ -n "${_arg}" ];then
		    callErrOutWrapper $LINENO $BASH_SOURCE  ${VIRSHCALL} ${VIRSH} "restore" "${_arg}" ${_bg}
		else
		    callErrOutWrapper $LINENO $BASH_SOURCE  ${VIRSHCALL} ${VIRSH} "resume" "$_label" ${_bg}
		fi
	    fi
	    ;;

        #CANCEL######################
	SUSPEND)
	    printINFO 2 $LINENO $BASH_SOURCE $ABORT "${FUNCNAME}:Require hypervisor for:$_cmd"
            if [ -z "${C_NOEXEC}" ];then
		callErrOutWrapper $LINENO $BASH_SOURCE  ${VIRSHCALL} ${VIRSH} "save" "$_label" "${_arg}" ${_bg}
	    fi
	    ;;
	PAUSE)
	    printINFO 2 $LINENO $BASH_SOURCE $ABORT "${FUNCNAME}:Require hypervisor for:$_cmd"
            if [ -z "${C_NOEXEC}" ];then
		callErrOutWrapper $LINENO $BASH_SOURCE  ${VIRSHCALL} ${VIRSH} "suspend" "$_label" ${_bg}
	    fi
	    ;;
	REBOOT|RESET)
	    printINFO 2 $LINENO $BASH_SOURCE $ABORT "${FUNCNAME}:Require hypervisor for:$_cmd"
            if [ -z "${C_NOEXEC}" ];then
		callErrOutWrapper $LINENO $BASH_SOURCE  ${VIRSHCALL} ${VIRSH} "reboot" "$_label" ${_bg}
	    fi
	    ;;
	POWEROFF)
	    printINFO 2 $LINENO $BASH_SOURCE $ABORT "${FUNCNAME}:Require hypervisor for:${_cmd}(delay=${_arg:-1})"
            if [ -z "${C_NOEXEC}" ];then
		if [ "$C_ASYNC" == 1 ];then
		    {
			callErrOutWrapper $LINENO $BASH_SOURCE  ${VIRSHCALL} ${VIRSH} "shutdown" "$_label";
			sleep ${_arg:-1};
			callErrOutWrapper $LINENO $BASH_SOURCE  ${VIRSHCALL} ${VIRSH} "destroy" "$_label";
		    } &
		else
		    {
			callErrOutWrapper $LINENO $BASH_SOURCE  ${VIRSHCALL} ${VIRSH} "shutdown" "$_label";
			sleep ${_arg:-1};
			callErrOutWrapper $LINENO $BASH_SOURCE  ${VIRSHCALL} ${VIRSH} "destroy" "$_label";
		    }
		fi
	    fi
            ;;
    esac
}


#FUNCBEG###############################################################
#NAME:
#  connectSessionXENVNC
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
function connectSessionXENVNC () {
    local _id=${1}
    local _label=${2}
    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME ${_id} ${_label}"

    #even though this condition might be impossible now, let it beeeee ...
    if [ -z "${_label}" -a -z "${_id}" ];then
	ABORT=1
	printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Fetch of peer entry failed:_id=${_id} - _label=${_label}"
	gotoHell ${ABORT}
    fi

    printDBG $S_XEN ${D_FRAME} $LINENO $BASH_SOURCE "OK:_id=${_id} - _label=${_label}"
    #
    #Now shows name+id in title, id could not be set for server as default.
    local _vieweropt="-name ${_label}:${_id} ${VNCVIEWER_OPT} ${C_GEOMETRY:+ -geometry=$C_GEOMETRY} "

    #old version with server-default label in title
    #  local _vieweropt="${VNCVIEWER_OPT} ${C_GEOMETRY:+ -geometry=$C_GEOMETRY} "
    local CALLER="${VNCVIEWER} ${C_DARGS} ${_vieweropt} :${_id}"
    printDBG $S_XEN ${D_FRAME} $LINENO $BASH_SOURCE "${CALLER}"
    export C_ASYNC;
    printFINALCALL 0  $LINENO $BASH_SOURCE "FINAL-XEN-CONSOLE:STARTER(${_label})" "${CALLER}"
    [ -z "${C_NOEXEC}" ]&&eval ${CALLER}
}
