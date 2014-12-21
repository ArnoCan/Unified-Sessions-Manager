#!/bin/bash

########################################################################
#
#KGROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_009
#
########################################################################
#
# Copyright (C) 2008,2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

_myPKGNAME_STACKER="${BASH_SOURCE}"
_myPKGVERS_STACKER="01.11.009"
hookInfoAdd "$_myPKGNAME_STACKER" "$_myPKGVERS_STACKER"


#default fall back
hookPackage "`dirname ${_myPKGNAME_STACKER}`/statics.sh"
hookPackage "`dirname ${_myPKGNAME_STACKER}`/dynamics.sh"


#
#Value marks the first JOB to be executed for a VMSTACK.
#The behaviour is controlled by C_STACKREUSE, it's value 
#is assigned by one of the STACKER modules, as required.
STACKER_STARTIDX=0;

#FUNCBEG###############################################################
#NAME:
#  stackerCreatePropagate
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#  This method processes the requested creation of a stack containing 
#  multiple VMs/PMs, but operates for each call on one stack only.
#  Therefore a specific SUBTASK, of type VMSTACK is required for 
#  execution, where the C_STACK variable is set. 
#
#  Each stack is thus worked out in a single call structure which could
#  be subdivided, but handles the control for one stack call autonomously.
#  Concurrent calls on the same stack could be processed, these are not
#  synchronized explicitly, but may not neccessarily interfere erroneous.
#  Anyhow, no guarantee is given.
#
#  This function makes usage of the global data structure containing the 
#  jobdata as defined within the EXEC modules.
#  Therefore common interfaces are used, but eventually not that much 
#  consequently if required else.
#
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: <behaviour>:=CONTROLLER|NESTED
#      The mode of operations, wheter this function operates as a classical
#      CONTROLLER design with a supervising role of the complete process,
#      including each single subprocess, or whether it operates in nested 
#      mode propagating the flow of control to each intermediate instance 
#      once reaching the state ACTIVE.
#
#      In case of NESTED the actual job will be propagated as a reduced job,
#      where the prefix current containing instance if dropped before 
#      propagating the remaining stack request.
#
#      This version supports a single "row" of stacked VMs for each call
#      only.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function stackerCreatePropagate () {
    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=$@"

    #requested behaviour
    local _behaviour=$1;shift
    _behaviour=${_behaviour:-$DEFAULT_STACKMODE};
    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_behaviour=$_behaviour"

    case $_behaviour in
	CONTROLLER)
	    ;;
	NESTED)
            ABORT=1
	    printERR $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:The operational mode \"$_behaviour\" will"
	    printERR $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:be supported soon, but is not yet available."
	    gotoHell ${ABORT}
	    ;;
	*)
            ABORT=1
	    printERR $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:Unknown operational mode \"$_behaviour\""
	    gotoHell ${ABORT}
	    ;;
    esac

    #method and args
    local _methodall=${1};
    local _method=${1%:*};
    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_method=$_method"
    local _margs=${1#*:};
    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_margs=$_margs"
    shift

    #list of next level peer-members to be treated
    if [ -z "${@}" ];then
	local _jobdat="${CALLERJOBID}:$((JOB_IDXSUB++))"
	local _allact=`${MYLIBEXECPATH}/ctys.sh -j ${_jobdat} -E -F ${VERSION} ${C_DARGS} -T XEN,QEMU,VMW  -a list=label,id,SERVER`
    else
	local _allact="${@}"
    fi
    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_allact=$_allact"

    local _cur=;

    #checks whether it is the native-container which is listed, else it might be an upper peer
    function checkMe () {
	local _t=${1#*;*;*;};_t=${_t%%;*}
	  if [ "${_t}" == "/etc/ctys.d/pm.conf" -o "${_t}" == "/etc/ctys.d/vm.conf" ];then
	      return 0
	  fi
	  return 1
    }

    function callHypervisor () {
        local __mt=$1
        local __todo=$2
        local __i=$3
	if [ -n "${__mt}" -a -n "${__i}" ];then
	    local _jobdat="${CALLERJOBID}:$((JOB_IDXSUB++))"
	    printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "${FUNCNAME}:ctys -j ${_jobdat} -E -F ${VERSION} ${C_DARGS} -t ${__mt} -a cancel=i:${__i},${__todo},FORCE"

	    local _call="${MYLIBEXECPATH}/ctys.sh -j ${_jobdat} -E -F ${VERSION} ${C_DARGS}"
	    local _call="${_call}  -t ${__mt} -a cancel=i:${__i},${__todo},FORCE "
	    printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${_call}"
	    eval ${_call} &
	else
	    printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "${FUNCNAME}:NO-MATCH for:\"${_cur//;/ }\""
	fi	  
    }

    local _t=;
    local _l=;
    local _mt=;
    local _i=;
    for _cur in $_allact;do
	printDBG $S_CORE ${D_UID} $LINENO $BASH_SOURCE "${FUNCNAME}:_cur=${_cur//;/ }"

        #self is ignored here and has to be treated by the caller.
	checkMe $_cur
	if [ $? -eq 0 ];then
	    printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "${FUNCNAME}:MYSELF-CONTINUE"
	    continue;
	fi

	if [ -n "$DBREC" ];then
	    local _i4=`${MYLIBEXECPATH}/ctys-vhost.sh ${C_DARGS} -s -C macmap -o l,id,t,st,uid -M unique R:$DBREC`
	else
	    local _i4=`${MYLIBEXECPATH}/ctys-vhost.sh ${C_DARGS} -s -C macmap -o l,id,t,st,uid -M unique ${MYHOST} ${_cur//;/ }`
	fi
        local _err1=$?;
	if [ $_err1 -ne 0 ];then
	    printWNG 1 $LINENO $BASH_SOURCE ${_err1} "Erroneous call of:ctys-vhost.sh"             
	fi
	_mt=${_i4%%;*};
	_l=${_i4#*;};_l=${_l%%;*};
	_i=${_i4#*;*;};_i=${_i%%;*};
	_t=${_i4#*;*;*;};_t=${_t%%;*};
	_u=${_i4##*;};
	printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "${FUNCNAME}:_i4=$_i4 =>  st=$_mt t=$_t l=$_l i=$_i u=$_uid"

        #_t required for target, _mt for the appropriate plugin to be called
	if [ -n "$_mt" -a -n "$_i" -a -n "$_t" ];then
	    printDBG $S_CORE ${D_UID} $LINENO $BASH_SOURCE "${FUNCNAME}:native upper stack-peer found:st=$_mt t=$_t"
	    local _call="ping -c 1 ${_t}" 
	    printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${_call}"
	    eval ${_call} 2>&1 >/dev/null
	    if [ $? -ne 0 ];then
		printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "${FUNCNAME}:CHK(ping)NOK"
		printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "${FUNCNAME}:try hypervisor:\"$_i4\""
		callHypervisor "${_mt}" "${_methodall}" "${_i}" 
	    else
		printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "${FUNCNAME}:CHK(ping)OK:$_i4"
		if [ "$_t" != "${_t//@/}" ];then
		    local _call="ssh ${_t} echo" 
		    printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${_call}"
		    eval ${_call} >/dev/null 2>/dev/null;
		else
		    local _call="ssh ${_u:+$_u@}${_t} echo ";
		    printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${_call}"
		    eval ${_call} >/dev/null 2>/dev/null;
		fi
		local _call="ssh ${_t} echo"
		printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${_call}"
		eval ${_call} >/dev/null 2>/dev/null;
		if [ $? -ne 0 ];then
		    printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "${FUNCNAME}:CHK(ssh)NOK"
		    printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "${FUNCNAME}:try hypervisor:\"$_i4\""
		    callHypervisor "${_mt}" "${_methodall}" "${_i}" 
		else
		    printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "${FUNCNAME}:CHK(ssh)OK:$_i4"
		    local _call="ssh ${_t} ctys ${C_DARGS} -X -V "
		    printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${_call}"
		    eval ${_call} >/dev/null 2>/dev/null;
		    if [ $? -eq 0 ];then
			printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "${FUNCNAME}:CHK(ctys)OK:$_i4"
                        #assume access
			local _call="ctys ${D_ARGS} -t ${_mt} -a cancel=ALL,SELF,POWEROFF:0 "

			local _rargs=;
			[ -n "${C_DARGS}" ]&&_rargs="${_rargs} ${C_DARGS}";
			[ "${USE_SUDO}" == 1 ]&&_rargs="${_rargs} -Z SUDO";
			[ "${USE_KSU}" == 1 ]&&_rargs="${_rargs} -Z KSU";
			[ "${C_SSH_PSEUDOTTY}" != 0 ]&&_rargs="${_rargs} -z ${C_SSH_PSEUDOTTY}";

			if [ -n "${_rargs}" ];then
			    _call="${_call} ${_t}'(${_rargs})'"
			else
			    _call="${_call} ${_t}"
			fi

			printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${_call}"
			eval ${_call};
			continue	
		    else
			printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "${FUNCNAME}:CHK(ctys)NOK"
			local _call="ssh ${_t} halt -p"
			printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${_call}"
			eval ${_call} >/dev/null 2>/dev/null;
			continue	
		    fi
		fi
	    fi
	else
            #so, try the hypervisor, requires _mt and _l
	    printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "${FUNCNAME}:no native upper stack-peer, check hypervisor:\"$_i4\""
	    callHypervisor "${_mt}" "${_methodall}" "${_i}"
	fi
    done
}


#FUNCBEG###############################################################
#NAME:
#  stackerCancelPropagate
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Workout the execution stack of VMs on current PM. Therefore an 
#  incremented walk-up from the current stack to the topmost and 
#  step-back by incrementally cancelling the stack topdown is performed.
#
#  The most essential functionality to be used here is ctys-vhost.sh in order 
#  to evaluate the MACHINE-TYPE and the TCP/IP address of the instance 
#  to be canceled.
#
#  Once this information is available, the incremental call to that 
#  instance is performed by using ctys itself again.
#
#  Due to the standard encapsulation of CANCEL method, no specific 
#  knowledge about the called plugin is required for the call.
#
#  Thus the only parameter to be passed through is the input parameter
#  gwhich is the generic suboption for the type of CANCEL to be performed.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: <behaviour>
#      SELF,FORCE|STACK
#
#  $2: <method>[:subarg]
#
#  $3  [<specific-target-list>]
#       - Records: "<label>;<pname>"
#       - FS:" "
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function stackerCancelPropagate () {
    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=$@"

    #requested behaviour
    local _behaviour=$1;shift
    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_behaviour=$_behaviour"

    #method and args
    local _methodall=${1};
    local _method=${1%:*};
    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_method=$_method"
    local _margs=${1#*:};
    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_margs=$_margs"
    shift


    #list of next level peer-members to be treated
    if [ -z "${*}" -o "${*// /}" == ALL ];then
	local _jobdat="${CALLERJOBID}:$((JOB_IDXSUB++))";

	local _pkgl0=${CTYS_STACKERKILL_DEFAULT:-ALL};
	if [ "${_pkgl0}" != ALL ];then
	    local _pkgl1=",PKG:${_pkgl0//,/\%}"
	fi
	local _allact=$(${MYLIBEXECPATH}/ctys.sh -j ${_jobdat} ${C_DARGS} -T ${CTYS_STACKERKILL_DEFAULT:-ALL}  -a list=label,id,SERVER,TERSE${_pkgl1})
    else
	local _allact="${@}"
    fi
    printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME:_allact=$_allact"

    local _cur=;

    #checks whether it is the native-container gwhich is listed, else it might be an upper peer
    function checkMe () {
	local _t=${1#*;*;*;};_t=${_t%%;*}
	  if [ "${_t}" == "/etc/ctys.d/pm.conf" -o "${_t}" == "/etc/ctys.d/vm.conf" ];then
	      return 0
	  fi
	  return 1
    }

    function callHypervisor () {
        local __mt=$1
        local __todo=$2
        local __i=$3
	if [ -n "${__mt}" -a -n "${__i}" ];then
	    local _jobdat="${CALLERJOBID}:$((JOB_IDXSUB++))"
	    printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "${FUNCNAME}:ctys -j ${_jobdat} -E -F ${VERSION} ${C_DARGS} -t ${__mt} -a cancel=i:${__i},${__todo},FORCE"

	    local _call="${MYLIBEXECPATH}/ctys.sh -j ${_jobdat} -E -F ${VERSION} ${C_DARGS}"
	    local _call="${_call}  -t ${__mt} -a cancel=i:${__i},${__todo},FORCE "
	    printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${_call}"
	    eval ${_call} &
	else
	    printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "${FUNCNAME}:NO-MATCH for:\"${_cur//;/ }\""
	fi	  
    }


    local _t=;
    local _l=;
    local _mt=;
    local _i=;
    for _cur in $_allact;do
	printDBG $S_CORE ${D_UID} $LINENO $BASH_SOURCE "${FUNCNAME}:_cur=${_cur//;/ }"

        #self is ignored here and has to be treated by the caller.
	checkMe $_cur
	if [ $? -eq 0 ];then
	    printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "${FUNCNAME}:MYSELF-CONTINUE"
	    continue;
	fi

	if [ -n "$DBREC" ];then
	    local _i4=`${MYLIBEXECPATH}/ctys-vhost.sh ${C_DARGS} -s -C macmap -o l,id,t,st,uid -M unique R:$DBREC`
	else
	    local _i4=`${MYLIBEXECPATH}/ctys-vhost.sh ${C_DARGS} -s -C macmap -o l,id,t,st,uid -M unique ${MYHOST} ${_cur//;/ }`
	fi
        local _err1=$?;
	if [ $_err1 -ne 0 ];then
	    printWNG 1 $LINENO $BASH_SOURCE ${_err1} "Erroneous call of:ctys-vhost.sh"             
	fi
	_mt=${_i4%%;*};
	_l=${_i4#*;};_l=${_l%%;*};
	_i=${_i4#*;*;};_i=${_i%%;*};
	_t=${_i4#*;*;*;};_t=${_t%%;*};
	_u=${_i4##*;};
	printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "${FUNCNAME}:_i4=$_i4 =>  st=$_mt t=$_t l=$_l i=$_i u=$_uid"

        #_t required for target, _mt for the appropriate plugin to be called
	if [ -n "$_mt" -a -n "$_i" -a -n "$_t" ];then
	    printDBG $S_CORE ${D_UID} $LINENO $BASH_SOURCE "${FUNCNAME}:native upper stack-peer found:st=$_mt t=$_t"
	    local _call="ping -c 1 ${_t}" 
	    printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${_call}"
	    eval ${_call} 2>&1 >/dev/null
	    if [ $? -ne 0 ];then
		printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "${FUNCNAME}:CHK(ping)NOK"
		printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "${FUNCNAME}:try hypervisor:\"$_i4\""
		callHypervisor "${_mt}" "${_methodall}" "${_i}" 
	    else
		printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "${FUNCNAME}:CHK(ping)OK:$_i4"
		if [ "$_t" != "${_t//@/}" ];then
		    local _call="ssh ${_t} echo" 
		    printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${_call}"
		    eval ${_call} >/dev/null 2>/dev/null;
		else
		    local _call="ssh ${_u:+$_u@}${_t} echo ";
		    printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${_call}"
		    eval ${_call} >/dev/null 2>/dev/null;
		fi
		if [ $? -ne 0 ];then
		    printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "${FUNCNAME}:CHK(ssh)NOK"
		    printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "${FUNCNAME}:try hypervisor:\"$_i4\""
		    callHypervisor "${_mt}" "${_methodall}" "${_i}" 
		else
		    printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "${FUNCNAME}:CHK(ssh)OK:$_i4"
		    local _call="${MYLIBEXECPATH}/ctys.sh ${C_DARGS} ${_t}'(-X -V)' ";
		    printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${_call}"
		    eval ${_call} >/dev/null 2>/dev/null;
		    if [ $? -eq 0 ];then
			printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "${FUNCNAME}:CHK(ctys)OK:$_i4"
                        #assume access
			local _call="${MYLIBEXECPATH}/ctys.sh ${C_DARGS}  -t PM -T all -a cancel=ALL,SELF,STACK,POWEROFF:0"

			local _rargs=;
			[ -n "${C_DARGS}" ]&&_rargs="${_rargs} ${C_DARGS}";
			[ "${USE_SUDO}" == 1 ]&&_rargs="${_rargs} -Z SUDO";
			[ "${USE_KSU}" == 1 ]&&_rargs="${_rargs} -Z KSU";
			[ "${C_SSH_PSEUDOTTY}" != 0 ]&&_rargs="${_rargs} -z ${C_SSH_PSEUDOTTY}";

			if [ -n "${_rargs}" ];then
			    _call="${_call} ${_t}'(${_rargs})'"
			else
			    _call="${_call} ${_t}"
			fi
			printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${_call}"
			eval ${_call}
			continue	
		    else
			printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "${FUNCNAME}:CHK(ctys)NOK"
			local _call="ssh ${_t} halt -p"
			printFINALCALL $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${_call}"
			eval ${_call} >/dev/null 2>/dev/null;
			continue	
		    fi
		fi
	    fi
	else
            #so, try the hypervisor, requires _mt and _l
	    printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "${FUNCNAME}:no native upper stack-peer, check hypervisor:\"$_i4\""
	    callHypervisor "${_mt}" "${_methodall}" "${_i}"
	fi
    done
}





#FUNCBEG###############################################################
#NAME:
#  stackerGetMyLevel
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Evaluates the actual stack level of current instance.
#
#  Current instance is the actual OS instance the current process is 
#  executed within.
#
#  ATTENTION:
#     Is not cached, due to the possibility of SHIFTs between container 
#     instances on various stack-levels.
#
#
#  REMARK: current version is based on PM configuration file,
#          gwhich will be extended/changed soon.
#          Thus for now static-configured stack-levels are 
#          supported only.
#
#
#          1. if exist "/etc/ctys.d/pm.conf"
#             =>0
#          2. if exist "/etc/ctys.d/STACKLEVEL.assume"
#             =>getConfValueOf STACKLEVEL
#          3. if exist "/etc/ctys.d/vm.conf"
#             =>1
#          4. assume 0
#             =>0
#
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Name of "ID" or "PNAME" containing the configuration.
#      Could be empty => "".
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function stackerGetMyLevel () {
    local _IP=;
    local _myConf=${1};
    _myConf=${_myConf:-/etc/ctys.d/STACKLEVEL.assume};

    if [ ! -e "/etc/pm.conf" ];then
	for i in ${_myConf};do
	    if [ -e "${i}" ];then
		_IP=`cat  "${i}" 2>/dev/null|getConfValueOf "#@#STACKLEVEL"`
		if [ "$_IP" != "" ];then
		    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from ${i}"
		    break;
		fi
	    fi
	done
    fi
    _IP=${_IP// /}
    if [ -z "${_IP}" ];then
	if [ ! -e "/etc/vm.conf" ];then
	    _IP=1;
            printINFO 2 $LINENO $BASH_SOURCE 1 "$FUNCNAME:Set to assumption by vm.conf:STACKLEVEL=<${_IP}>"

	else
	    _IP=0;
            printINFO 2 $LINENO $BASH_SOURCE 1 "$FUNCNAME:Set to default-assumption:STACKLEVEL=<${_IP}>"
	fi
    fi
    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:STACKLEVEL=<${_IP}>"
    echo -n -e "${_IP}"
}






#FUNCBEG###############################################################
#NAME:
#  stackerController
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function stackerController () {
    printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME"
    local _ret=0;

    function checkCallConsistency () {
	printINFO 1 $LINENO $BASH_SOURCE 1 "$FUNCNAME:Call-Integrity"
	local siz=${#JOB_EXECSERVER[@]};
	local x=;

	for((x=0;x<${siz};x++));do
	    if [ -n "${JOB_EXECSERVER[$x]}" ];then
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:JOB_EXECSERVER[$x]=${JOB_EXECSERVER[$x]}"
		local _buf="${JOB_EXECSERVER[$x]}";
		local _st=$(getSessionType ${_buf});
		local _ac=$(getAction ${_buf});

		case "$_st" in
		    X11|VNC|CLI);;
		    *)
			local _optval=$(cliGetOptValue "-a" ${_buf});

			_optval=$(cliSplitSubOpts ${_optval});
			local _ix7;
			for _ix7 in ${_optval};do
			    local _k=$(cliGetKey $_ix7);
			    local _a=$(cliGetArg $_ix7);
			    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_k=${_k}  _a=${_a}"
			    if [ "$_k" == CONSOLE ];then
				case "$_a" in
				    [nN][oO][nN][eE]);;
				    *)
					ABORT=1;
					printERR $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:Current version supports only seperate calls"
					printERR $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:of console plugins: CLI, VNC, X11"
					printERR $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:JOB_EXECSERVER[$x]=${JOB_EXECSERVER[$x]}"
					gotoHell ${ABORT};
					;;
				esac
			    fi
			done
			;;
		esac
	    fi
	done
    }


    if [ "$C_STACKMASTER" == 1 ];then
	stackerCheckDynamics
	checkCallConsistency
    fi

  ###
   ###OK, now start stack
  ###

    printINFO 1 $LINENO $BASH_SOURCE 1 "$FUNCNAME:Start pre-checked STACK"
    #
    #assuming "-b stack" == "-b seq,sync"
    #
    local siz=${#JOB_EXECSERVER[@]};
    local x=;


    for((x=0;x<${siz};x++));do
	if((x<STACKER_STARTIDX));then
	    printINFO 1 $LINENO $BASH_SOURCE 0 "$FUNCNAME:VMSTACK-REUSE-LAYER:($x)"
	    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:VMSTACK-REUSE-LAYER:($x)"
	    continue;
	fi

	local _b511="${JOB_EXECSERVER[$x]}"
	if [ -n "${_b511// /}" ];then
	    printINFO 1 $LINENO $BASH_SOURCE 0 "$FUNCNAME:CALL-SERVER-JOB($x)"
	    printINFO 2 $LINENO $BASH_SOURCE 0 "$FUNCNAME:CALL-SERVER-JOB($x):${JOB_EXECSERVER[$x]}"
	    doExecCall ${JOB_EXECSERVER[$x]}
	    _ret=$?
	    if((_ret!=0));then
		printERR $LINENO $BASH_SOURCE ${_ret} "$FUNCNAME:START of SERVER-JOB($x) failed($_ret)"
		printERR $LINENO $BASH_SOURCE ${_ret} "$FUNCNAME:FAILED-SERVER-JOB($x):${JOB_EXECSERVER[$x]}"
		return $_ret
	    fi
	    let JOB_CNT++;
	fi

	if [ -n "${JOB_EXECCLIENTS[$x]// /}" ];then
	    printINFO 1 $LINENO $BASH_SOURCE 0 "$FUNCNAME:CALL-CLIENT-JOB($x)"
	    printINFO 2 $LINENO $BASH_SOURCE 0 "$FUNCNAME:CALL-CLIENT-JOB($x):${JOB_EXECCLIENTS[$x]}"
	    doExecCall ${JOB_EXECCLIENTS[$x]}
	    _ret=$?;
	    if((_ret!=0));then
		printERR $LINENO $BASH_SOURCE ${_ret} "$FUNCNAME:START of CLIENT failed, for now ignored($_ret)."
		printERR $LINENO $BASH_SOURCE ${_ret} "$FUNCNAME:FAILED-CLIENT-JOB($x):${JOB_EXECCLIENTS[$x]}"
#		return $_ret
	    fi
	    let JOB_CNT++;
	fi
    done
    return 
}


#FUNCBEG###############################################################
#NAME:
#  stackerCheckConsistency
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
# Performs static and dynamic checks in order to approve basic feature 
# consistecy and actual resource applicabilty.
#
#EXAMPLE:
#
#PARAMETERS:
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function stackerCheckConsistency () {
    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:ENTRY:\$@=${@}"
    local _ret=0;

    stackerCheckStatics
    _ret=$?;
    
    if [ $_ret -eq 0 ];then
	stackerCheckDynamics
	_ret=$?;
    fi
    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:EXIT:_ret=${_ret}"
    return $_ret
}
