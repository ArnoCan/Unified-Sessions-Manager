#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@users.sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_07_001b02
#
########################################################################
#
# Copyright (C) 2007,2008 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

_myPKGNAMEBASH_SOURCE="${BASH_SOURCE}"
_myPKGVERSBASH_SOURCE="01.07.001b02"
hookInfoAdd $_myPKGNAMEBASH_SOURCE $_myPKGVERSBASH_SOURCE




#FUNCBEG###############################################################
#NAME:
#  selfCancelPM
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  For native cancel. Calls before cancel itself the contained stack.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: METHOD:ARG
#  $2: <stack>
#  $3: ""|SELF
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function selfCancelPM () {
    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCTION:\$@=$@"

    local _METHOD=${1%:*};local _ARG=${1#*:};shift
    local _force=${1};shift
    local _self=${1}

    if [ -z "${_self}" ];then
	return
    fi

    case $_METHOD in
	INIT)
	    printINFO 1 $LINENO $BASH_SOURCE 0 "$_METHOD ${_ARG}"
	    local _myMessage="`basename $BASH_SOURCE`:$LINENO:INIT(${_ARG}):${DEFAULT_KILL_DELAY_POWEROFF}"
	    logger -i -t ${MYCALLNAME} -- "${_myMessage}"
	    wall "${_myMessage}"
  	    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "delay:${DEFAULT_KILL_DELAY_POWEROFF}"
	    sleep ${DEFAULT_KILL_DELAY_POWEROFF}
	    case ${MYOS} in
		FreeBSD|OpenBSD)
		    case ${_ARG} in
			0)    eval ${CTYS_HALT} -p;;
			[12]) eval ${CTYS_INIT} -s;;
			[345]);;
			6)    eval ${CTYS_REBOOT};;
		    esac
		    ;;
		SunOS)
		    case ${_ARG} in
			0)    eval ${CTYS_POWEROFF};;
			[12]) eval ${CTYS_INIT} -s;;
			[345]);;
			6)    eval ${CTYS_REBOOT};;
		    esac
		    ;;
		Linux)
		    eval ${CTYS_INIT} ${_ARG}
		    ;;
	    esac
	    gotoHell 0
	    ;;

        REBOOT)
	    printINFO 1 $LINENO $BASH_SOURCE 0 "$_METHOD"
	    local _myMessage="`basename $BASH_SOURCE`:$LINENO:REBOOT:${DEFAULT_KILL_DELAY_POWEROFF}"
	    logger -i -t ${MYCALLNAME} -- "${_myMessage}"
	    wall "${_myMessage}"
	    wall "System maintenance:REBOOT in ${DEFAULT_KILL_DELAY_POWEROFF} seconds"
  	    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "delay:${DEFAULT_KILL_DELAY_POWEROFF}"
	    sleep ${DEFAULT_KILL_DELAY_POWEROFF}
	    eval ${CTYS_REBOOT}
	    gotoHell 0
	    ;;

	RESET)
	    printINFO 1 $LINENO $BASH_SOURCE 0 "$_METHOD"
	    local _myMessage="`basename $BASH_SOURCE`:$LINENO:RESET:${DEFAULT_KILL_DELAY_POWEROFF}"
	    logger -i -t ${MYCALLNAME} -- "${_myMessage}"
	    wall "${_myMessage}"
	    wall "System maintenance:RESET in ${DEFAULT_KILL_DELAY_POWEROFF} seconds"
  	    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "delay:${DEFAULT_KILL_DELAY_POWEROFF}"
	    sleep ${DEFAULT_KILL_DELAY_POWEROFF}
	    eval  ${CTYS_REBOOT}
	    gotoHell 0
	    ;;

        PAUSE|S3)
	    printINFO 1 $LINENO $BASH_SOURCE 0 "$_METHOD"
	    local _myMessage="`basename $BASH_SOURCE`:$LINENO:PAUSE:${DEFAULT_KILL_DELAY_POWEROFF}"
	    logger -i -t ${MYCALLNAME} -- "${_myMessage}"
	    wall "${_myMessage}"
	    wall "System maintenance:RESET in ${DEFAULT_KILL_DELAY_POWEROFF} seconds"
  	    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "delay:${DEFAULT_KILL_DELAY_POWEROFF}"
	    sleep ${DEFAULT_KILL_DELAY_POWEROFF}
            #temporary halt
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "PAUSE-S3 not yet supported, mapped to S5"
	    case ${MYOS} in
		SunOS)   eval ${CTYS_POWEROFF};;
		*)       eval ${CTYS_HALT} -p ;;
	    esac
	    gotoHell 0
	    ;;

        SUSPEND|S4)
	    printINFO 1 $LINENO $BASH_SOURCE 0 "$_METHOD"
	    local _myMessage="`basename $BASH_SOURCE`:$LINENO:SUSPEND:${DEFAULT_KILL_DELAY_POWEROFF}"
	    logger -i -t ${MYCALLNAME} -- "${_myMessage}"
	    wall "${_myMessage}"
	    wall "System maintenance:SUSPEND in ${DEFAULT_KILL_DELAY_POWEROFF} seconds"
  	    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "delay:${DEFAULT_KILL_DELAY_POWEROFF}"
	    sleep ${DEFAULT_KILL_DELAY_POWEROFF}
            #temporary halt
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "SUSPEND-S4 not yet supported, mapped to S5"
	    case ${MYOS} in
		SunOS)   eval ${CTYS_POWEROFF};;
		*)       eval ${CTYS_HALT} -p ;;
	    esac
	    gotoHell 0
	    ;;

        POWEROFF|S5)
	    printINFO 1 $LINENO $BASH_SOURCE 0 "$_METHOD"
	    local _myMessage="`basename $BASH_SOURCE`:$LINENO:POWEROFF:${_ARG:-$DEFAULT_KILL_DELAY_POWEROFF}"
	    logger -i -t ${MYCALLNAME} -- "${_myMessage}"
	    wall "${_myMessage}"
	    wall "System maintenance:POWEROFF in ${_ARG:-$DEFAULT_KILL_DELAY_POWEROFF} seconds"
  	    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "delay:${_ARG:-DEFAULT_KILL_DELAY_POWEROFF}"
 	    sleep ${_ARG:-$DEFAULT_KILL_DELAY_POWEROFF}
	    case ${MYOS} in
		SunOS)   eval ${CTYS_POWEROFF};;
		*)       eval ${CTYS_HALT} -p;;
	    esac
	    gotoHell 0
	    ;;

	*)
	    ABORT=1;
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Reached unexpected execution tracepoint"
	    printERR $LINENO $BASH_SOURCE ${ABORT} "'seems to be, that a suboption of cancel is missing????"
	    printERR $LINENO $BASH_SOURCE ${ABORT} "This might be an internal error???"
	    gotoHell ${ABORT}
	    ;;
    esac
}



#FUNCBEG###############################################################
#NAME:
#  stackerCancelPM
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  For native cancel. Calls before cancel itself the contained stack.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: METHOD:ARG
#  $2: <stack>
#  $3: ""|SELF
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function stackerCancelPM () {
    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCTION:\$@=$@"

    local _METHOD=${1%:*};local _ARG=${1#*:};shift
    local _force=${1};shift
    local _self=${1}

    if [ -n "$_force" ];then
	return;
    fi

    case $_METHOD in
	INIT)
  	    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "ACTION-MODE=INIT"
	    stackerCancelPropagate "STACK,INIT:${_ARG}";
	    ;;

	REBOOT)
  	    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "ACTION-MODE=REBOOT"
	    stackerCancelPropagate "STACK,INIT:0";
	    ;;

	RESET)
  	    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "ACTION-MODE=RESET"
	    stackerCancelPropagate "STACK,INIT:0";
	    ;;

	PAUSE|S3)
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "PAUSE-S3 not yet supported, mapped temporarily to S5"
  	    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "ACTION-MODE=PAUSE-S3"
	    stackerCancelPropagate "STACK,PAUSE";
	    ;;

	SUSPEND|S4)
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "SUSPEND-S4 not yet supported, mapped temporarily to S5"
  	    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "ACTION-MODE=SUSPEND-S4"
	    stackerCancelPropagate "STACK,SUSPEND";
	    ;;

	POWEROFF|S5)
  	    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "ACTION-MODE=POWEROFF-S5"
	    stackerCancelPropagate "STACK,INIT:0";
	    ;;

	*)
	    ABORT=1;
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Reached unexpected execution tracepoint"
	    printERR $LINENO $BASH_SOURCE ${ABORT} "'seems to be, that a suboption of cancel is missing????"
	    printERR $LINENO $BASH_SOURCE ${ABORT} "This might be an internal error???"
	    gotoHell ${ABORT}
	    ;;
    esac
}



#FUNCBEG###############################################################
#NAME:
#  cutCancelSessionPM
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Handles shutdown of PMs.
#
#  The current version controls the container instances and it's contents.
#  Here a PM will be managed with it's running entities, gwhich could be 
#  handled as nested execution stack. Therefore containment hierarchies of 
#  PMs, and nested VMs - e.g. Xen and QEMU - will be handled.
#
#  This version is solely based on SW features provided by the OS, future versions
#  will utilize in an seamless escalation scenario HW equipment with external sitches
#  for power-supply and controlled hardware-reset by remote enforcement.
#
#EXAMPLE:
#
#PARAMETERS:
#
# Control enforcement scope and behaviour 
#  FORCE
#    Forces the execution of method, even though some thing might hang.
#
#  STACK
#    When provided the execution stack on current instance will be worked 
#    top-down, thus providing a proper and (almost?) reliable shutdown.
#
# Special methods, e.g. OS dependent
#  INIT:<target-init-state>
#    Will be mapped to unix init command, depends on specific UNIX variant. 
#
# Common methods
#  REBOOT
#    Performs a soft reboot.
#
#  RESET
#    Performs a hard reboot, gwhich is currently an immediate command on 
#    current instance, therefore all VMs will be killed after a short 
#    timeout.
#
#  SUSPEND
#    Suspends both.
#
#  SUSPEND2D
#    Suspends to disk.
#
#  SUSPEND2R
#    Suspends to RAM.
#
#  POWEROFF
#    Switches the power off immediately.
#
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function cutCancelSessionPM () {
    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "${FUNCNAME}:$*"
    local OPMODE=$1;shift
    local ACTION=$1;shift

    local A;
    local KEY;
    local ARG;

    function chkCtysVhost () {
	if [ $1 != 0 ];then
	    printERR $LINENO $BASH_SOURCE ${ABORT} "ctys-vhost.sh ${C_DARGS} exit with error:$ret"
 	    gotoHell ${1}
	fi
    }

    local _behaviour=;
    local _i=;

    case ${OPMODE} in
	CHECKPARAM)
            #
            #Just check syntax drafts, the expansion of labels etc. could just be
            #expanded on target machine.
            #
            if [ -n "$C_MODE_ARGS" ];then
                #guarantee unambiguity
		local _unambig=0;
		local _unambigCSB=0;
		local _unambigCMD=0;

		printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "C_MODE_ARGS=$C_MODE_ARGS"
		A=`cliSplitSubOpts ${C_MODE_ARGS}`
		for i in $A;do
		    KEY=`cliGetKey ${i}`
		    ARG=`cliGetArg ${i}`
                    if [ -n "${ARG}" \
			-o  \( \
			"${KEY}" == "DUMMY" \
 			-o "${KEY}" == "FORCE" \
			-o "${KEY}" == "STACK" \
			-o "${KEY}" == "SELF" \
			-o "${KEY}" == "POWEROFF"  -o "${KEY}" == "S5" \
			-o "${KEY}" == "SUSPEND"   -o "${KEY}" == "S4" \
			-o "${KEY}" == "PAUSE"     -o "${KEY}" == "S3" \
			-o "${KEY}" == "RESET" \
 			-o "${KEY}" == "REBOOT" \
			-o "${KEY}" == "ALL" \
			-o "${KEY}" == "WOL" \
			\) \
			];then
			case $KEY in


                     ##################################################
                     # Common control enforcement scope and behaviour #
                     ##################################################
			    FORCE)
				local _force=1;
				printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "MODE:FORCE"
				;;

			    STACK)
				local _stack=1;
				printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "MODE:STACK (DEFAULT)"
				;;

			    SELF)
				local _self=1;
				printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "MODE:SELF"
				;;
			    TIMEOUT)
				local _timeout="${ARG}";
				if [ -z "${_timeout}" ];then
				    ABORT=1;
				    printERR $LINENO $BASH_SOURCE ${ABORT} "${KEY} requires a value"
				    gotoHell ${ABORT}
				fi
				printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "${KEY}=${_timeout}"
				;;


                     ##################
                     # Common methods #  
                     ##################
			    REBOOT)
				local _reboot=1;
				printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "MODE:REBOOT"
				;;
			    RESET)
				local _reset=1;
				printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "MODE:RESET"
				;;
			    PAUSE|S3)
				local _pause=1;
				printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "MODE:PAUSE-S3"
				;;
			    SUSPEND|S4)
				local _suspend=1;
				printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "MODE:SUSPEND-S4"
				;;
			    POWEROFF|S5)
				local _powoff=1;
				local _powoffdelay="${ARG}";
				if [ -z "${_powoffdelay}" ];then
				    _powoffdelay=${PM_POWOFFDELAY};
				fi
				let _unambigCMD+=1;
				printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "MODE:POWEROFF-S5 DELAY=${_powoffdelay}"
				;;

			    INIT)
				local _init=1;
				local _initstate="${ARG}";
				let _unambigCMD+=1;
				printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "MODE:INIT=${_initstate}"
				;;


                     #####################
                     # <machine-address> #
                     #####################
			    LABEL|L)#just for LIST of long-runner shutdown
				local _label="${ARG}";
 				printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "RANGE:LABEL=${_label}"
				let _unambig+=1;
				;;

 			    DBRECORD|DBREC|DR|BASEPATH|BASE|B|TCP|T|MAC|M|UUID|U|FILENAME|FNAME|F|ID|I|PATHNAME|PNAME|P)
 				;;


                     ##############
                     # additional #
                     ##############
			    IF)
				local _if=1;
				if [ -z "${ARG}" ];then
				    ABORT=1;
				    printERR $LINENO $BASH_SOURCE ${ABORT} "MIssing argument KEY=${KEY}"
 				    gotoHell ${ABORT}
				fi
				printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "${KEY}:${ARG}"
				;;

			    WOL)
				local _wol=0;
				printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "Set WoL attributes on NIC"
				R_OPTS="${R_OPTS} -T all"
				;;

			    ALL)
 				printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "ALL in any case"
				;;

			    *)
				ABORT=1;
				printERR $LINENO $BASH_SOURCE ${ABORT} "Unknown sub-opt for PM:\"${KEY}\""
 				gotoHell ${ABORT}
				;;
			esac
			    else
				ABORT=1;
				printERR $LINENO $BASH_SOURCE ${ABORT} "Erroneous KEY:<${KEY}>"
 				printERR $LINENO $BASH_SOURCE ${ABORT} "  Required syntax :<KEY>:<ARG>";
 				printERR $LINENO $BASH_SOURCE ${ABORT} "  Given systax    :<${KEY}>:<${ARG}>";
 				gotoHell ${ABORT}               
			    fi
		done
		    fi

		    if [ -z "$_reboot" -a -z "$_init" -a -z "$_powoff" ];then
			ABORT=1;
			printERR $LINENO $BASH_SOURCE ${ABORT} "Missing: REBOOT|INIT|POWEROFF"
 			gotoHell ${ABORT}
		    fi

		    if [ -n "$_force" -a -n "$_stack" ];then
			ABORT=1;
			printERR $LINENO $BASH_SOURCE ${ABORT} "Only one allowed: FORCE|STACK(default)"
 			gotoHell ${ABORT}
		    fi

		    if [ -n "$_force" -a -z "$_self" ];then
			ABORT=1;
			printERR $LINENO $BASH_SOURCE ${ABORT} "FORCE requires SELF, ..."
			printERR $LINENO $BASH_SOURCE ${ABORT} "...be aware of possible consequences, it just switches off the VM-stack!"
 			gotoHell ${ABORT}
		    fi


		    if((_reboot+_init+_powoff>1));then
			ABORT=1;
			printERR $LINENO $BASH_SOURCE ${ABORT} "Only one allowed: REBOOT|INIT|POWEROFF"
 			gotoHell ${ABORT}
		    fi

		    if [ \( -n "$_reboot" -o -n "$_reset" -o \( -n "$_init"  -a "${_initstate}" != "0" \) \) -a -n "$_wol" ];then
			ABORT=1;
			printERR $LINENO $BASH_SOURCE ${ABORT} "WOL cannot be combined with:"
			printERR $LINENO $BASH_SOURCE ${ABORT} "  REBOOT | RESET | INIT ${_initstate}"
			printERR $LINENO $BASH_SOURCE ${ABORT} "Supported:"
			printERR $LINENO $BASH_SOURCE ${ABORT} "  PAUSE|S3 | SUSPEND|S4 | POWEROFF|S5 | INIT 0"
 			gotoHell ${ABORT}
		    fi

		    if [ -z "$_wol" -a -n "$_if" ];then
			ABORT=1;
			printERR $LINENO $BASH_SOURCE ${ABORT} "IF requires WOL."
 			gotoHell ${ABORT}
		    fi
		    ;;

	ASSEMBLE)
	    assembleExeccall
	    ;;

	PROPAGATE)
	    assembleExeccall PROPAGATE
	    ;;

	EXECUTE)
	    if [ -n "${R_TEXT}" ];then
		echo "${R_TEXT}"
	    fi

	    local _unambig=0;

	    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "C_MODE_ARGS=$C_MODE_ARGS"
	    A=`cliSplitSubOpts ${C_MODE_ARGS}`
	    for i in $A;do
		KEY=`cliGetKey ${i}`
		ARG=`cliGetArg ${i}`
                if [ -n "${ARG}" \
		    -o -z "${ARG}" -a "${KEY}" == "S3" \
		    -o -z "${ARG}" -a "${KEY}" == "S4" \
		    -o -z "${ARG}" -a "${KEY}" == "S5" \
		    -o -z "${ARG}" -a "${KEY}" == "POWEROFF" \
		    -o -z "${ARG}" -a "${KEY}" == "RESET" \
		    -o -z "${ARG}" -a "${KEY}" == "REBOOT" \
		    -o -z "${ARG}" -a "${KEY}" == "PAUSE" \
		    -o -z "${ARG}" -a "${KEY}" == "SUSPEND" \
 		    -o -z "${ARG}" -a "${KEY}" == "FORCE" \
		    -o -z "${ARG}" -a "${KEY}" == "STACK" \
		    -o -z "${ARG}" -a "${KEY}" == "SELF" \
		    -o -z "${ARG}" -a "${KEY}" == "ALL" \
		    -o -z "${ARG}" -a "${KEY}" == "WOL" \
		    -o -z "${ARG}" -a "${KEY}" == "NOCACHE" \
		    -o -z "${ARG}" -a "${KEY}" == "NOPOLL" \
		    ];then
		    case $KEY in

              #########
			FORCE)
			    local _force=1;
			    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "MODE:FORCE"
			    ;;

			STACK)
			    local _stack=1;
			    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "MODE:STACK (DEFAULT)"
			    ;;

			SELF)
			    local _self=1;
			    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "MODE:SELF"
			    ;;
			TIMEOUT)
			    local _timeout="${ARG}";
			    if [ -z "${_timeout}" ];then
				ABORT=1;
				printERR $LINENO $BASH_SOURCE ${ABORT} "${KEY} requires a value"
				gotoHell ${ABORT}
			    fi
			    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "${KEY}=${_timeout}"
 			    DEFAULT_KILL_DELAY_POWEROFF=${_timeout};
			    ;;


                #########
			INIT)
			    _behaviour=INIT;
			    local _init=1;
			    local _initstate="${ARG}";
			    [ -n "${_initstate}" ]&&_behaviour="${_behaviour}:${_initstate}";
			    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "MODE:${_behaviour}"
			    ;;

                #########
			REBOOT)
			    _behaviour=REBOOT;
			    local _reboot=1;
			    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "MODE:REBOOT"
			    ;;
			RESET)
			    _behaviour=RESET;
			    local _reset=1;
			    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "MODE:RESET"
			    ;;
			PAUSE|S3)
			    _behaviour=PAUSE;
			    local _suspend=1;
			    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "MODE:PAUSE-S3"
			    ;;
			SUSPEND|S4)
			    _behaviour=SUSPEND;
			    local _suspend=1;
			    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "MODE:SUSPEND-S4"
			    ;;
			POWEROFF|S5)
			    _behaviour=POWEROFF;
			    local _powoff=1;
			    local _powoffdelay="${ARG}";
			    if [ -z "${_powoffdelay}" ];then
				_powoffdelay=${PM_POWOFFDELAY};
			    fi
			    _behaviour="$_behaviour:${_powoffdelay}";
			    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "MODE:POWEROFF-S5 DELAY=${_powoffdelay}"
			    ;;


               #####################
               # <machine-address> #
               #####################
			LABEL|L)
                            local _label="${ARG}";
 			    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "RANGE:LABEL=${_label}"
			    ;;
 			DBRECORD|DBREC|DR|BASEPATH|BASE|B|TCP|T|MAC|M|UUID|U|FILENAME|FNAME|F|ID|I|PATHNAME|PNAME|P)
 			    ;;


               ##############
               # additional #
               ##############
			IF)
			    local _if=${ARG};
			    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "_if=${_if}"
			    CTYS_ETHTOOL_WOLIF=$_if;
			    CTYS_ETHTOOL_WOLIF_RAW=$_if;
			    ;;

			WOL)
			    local _wol=0;
			    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "Set WoL attributes on NIC"
			    if [ "${MYOS}" != "Linux" ];then
				ABORT=1;
				printERR $LINENO $BASH_SOURCE ${ABORT} "This version does not support WOL configuration for ${MYOS}"
 				gotoHell ${ABORT}
			    fi
			    ;;

			ALL)
 			    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "ALL in any case"
			    ;;

			*)
			    ABORT=1;
			    printERR $LINENO $BASH_SOURCE ${ABORT} "Unexpected sub-opts for PM:${KEY}"
 			    gotoHell ${ABORT}
			    ;;
		    esac
			fi
	    done



	    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "CombineParamaters"
	    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "----------------------"
	    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "- Cancel sessions:"
	    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "-  _force     = ${_force}"
	    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "----------------------"
	    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "-  _reboot    = ${_reboot}"
	    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "-  _reset     = ${_reset}"
	    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "-  _suspend   = ${_suspend}"
	    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "-  _init      = ${_init} - ${_initstate}"
	    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "-  _powoff    = ${_powoff} - ${_powoffdelay}"
	    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "----------------------"
	    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "-  _behaviour = ${_behaviour}"
	    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "-  _timeout   = ${_timeout}"
	    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "----------------------"
	    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "-  _wol       = ${_wol}"
	    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "----------------------"


      ###########################
       #    So, ... let's go!    #
      ###########################

            #switch to new interface
	    if [ -n "${_if}" ];then
		checkSyscallsLinuxWoL
	    fi

            #first clear upper stack, should be finished before eventually changing network setup,
            #... yes, probably not successful?!
	    stackerCancelPM "${_behaviour}" "${_force}" "${_self}"; 

            #set WOL for next boot if requested, 
            #Validation has been approved before, thus if WoL is set, pre-requisites are mandatory!
            #The remaining target states for WoL are: poweroff, suspend, init 0
            if [ -n "${_wol}" ];then
 		printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "WOL detected"


                #
                #It is a good idea to load all missing, let them do their job,
                #particularly Xen should stop it's bridge.
                #
		local _postfetch=`hookEnumeratePackages`;
		hookPackage "$_postfetch";


                if [ -z "${CTYS_ETHTOOL_WOLIF}" ];then
		    ABORT=1;
		    printERR $LINENO $BASH_SOURCE ${ABORT} "WoL selected, but wakeup interface is missing."
 		    gotoHell ${ABORT}
                fi

                #clear any specific history, let plugins decide what to do
		if [ "$_initstate" == "6" -o -n "$_reboot" -o -n "$_reset" ];then
 		    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "initPACKAGES 6 NOEXIT"
		    initPACKAGES 6 NOEXIT
		else
  		    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "initPACKAGES 0 NOEXIT"
		    initPACKAGES 0 NOEXIT
		fi

                #
                #This might already not be visible
 		printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "After-Init-PACKAGES"
		
                #now get the "real" as default
                if [ -z "${CTYS_ETHTOOL_WOLIF}" ];then
		    CTYS_ETHTOOL_WOLIF=`netGetFirstIf`
                fi
		logger -i -s -t ${MYCALLNAME} -- "Set WoL on:${CTYS_ETHTOOL_WOLIF}"

                if [ -n "${CTYS_ETHTOOL_WOLIF}" ];then
		    CTYS_ETHTOOL_WOLD="${CTYS_ETHTOOL}  -s ${CTYS_ETHTOOL_WOLIF} wol d"
		    CTYS_ETHTOOL_WOLG="${CTYS_ETHTOOL} -s ${CTYS_ETHTOOL_WOLIF} wol g"

                    #this loop is history, but will be kept anyway!
 		    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "CTYS_ETHTOOL_WOL=${CTYS_ETHTOOL_WOL}"
		    eval ${CTYS_ETHTOOL_WOLD}
		    eval ${CTYS_ETHTOOL_WOLG}
		    local _woli=0;
		    local _xwolid=0;
		    local _xwolig=0;
		    for((_woli=0;_woli<10;_woli++));do
			eval "_xwolid=\"\$CTYS_ETHTOOL_WOL$_woli\""
			eval "_xwolig=\"\$CTYS_ETHTOOL_WOL$_woli\""
			if [ -n "${_xwolid}" ];then
			    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME CTYS_ETHTOOL_WOL$_wolid=<$_xwolid>"
 			    eval ${_xwolid}
			fi
			if [ -n "${_xwolig}" ];then
			    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME CTYS_ETHTOOL_WOL$_wolig=<$_xwolig>"
 			    eval ${_xwolig}
			fi
		    done
		    local _myMessage="`basename $BASH_SOURCE`:$LINENO:Set WoL for:${CTYS_ETHTOOL_WOLIF}"
		    logger -i -t ${MYCALLNAME} -- "${_myMessage}"
		else
		    printERR $LINENO $BASH_SOURCE 0 "Cannot find a WoL interface, continue without initialization of WoL"
                fi
	    fi
            #
            #if requested handle ultimately SELF
	    selfCancelPM  "${_behaviour}" "${_force}" "${_self}"; 
	    ;;
    esac

}

