#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_02_007a17
#
########################################################################
#
# Copyright (C) 2007 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

_myPKGNAME_QEMU_CANCEL="${BASH_SOURCE}"
_myPKGVERS_QEMU_CANCEL="01.01.001a00pre"
hookInfoAdd $_myPKGNAME_QEMU_CANCEL $_myPKGVERS_QEMU_CANCEL
_myPKGBASE_QEMU_CANCEL="`dirname ${_myPKGNAME_QEMU_CANCEL}`"

#FUNCBEG###############################################################
#NAME:
#  cutCancelSessionQEMU
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
function cutCancelSessionQEMU () {
    local OPMODE=$1;shift
    local ACTION=$1;shift

    local A;
    local KEY;
    local ARG;

    #Killing server alone is senseless, so client else both is applicable.
    local _CSB=;

    local _behaviour=${QEMU_CANCEL_DEFAULT:-POWEROFF};
    local _i=;
    local _matchKey=;
    local _pname=;
    local _ret=0;


    function killClients () {
	local _killlst=$*
	for _i in ${_killlst};do
	    [ "${_i##*;}" != CLIENT ]&&continue;
	    printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "kill:${_i}"
	    local _pid=${_i%;*}
	    _pid=${_pid##*;}
	    echo -n "CANCEL-CLIENT Session:\"${_i%%;*}\":PID=$_pid"
	    echo -n "   ID    =${_i%%;*}"
	    echo -n "   PID   =$_pid"
	    kill $_pid
	    echo
	done

    }


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

		printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "C_MODE_ARGS=$C_MODE_ARGS"
		A=`cliSplitSubOpts ${C_MODE_ARGS}`
		for i in $A;do
		    KEY=`cliGetKey ${i}`
		    ARG=`cliGetArg ${i}`
                    if [ -n "${ARG}" \
			-o -z "${ARG}" -a "${KEY}" == "CLIENT" \
			-o -z "${ARG}" -a "${KEY}" == "SERVER" \
			-o -z "${ARG}" -a "${KEY}" == "BOTH" \
			-o -z "${ARG}" -a "${KEY}" == "S3" \
			-o -z "${ARG}" -a "${KEY}" == "S4" \
			-o -z "${ARG}" -a "${KEY}" == "S5" \
			-o -z "${ARG}" -a "${KEY}" == "POWEROFF" \
			-o -z "${ARG}" -a "${KEY}" == "SUSPEND" \
			-o -z "${ARG}" -a "${KEY}" == "RESET" \
			-o -z "${ARG}" -a "${KEY}" == "FORCE" \
			-o -z "${ARG}" -a "${KEY}" == "STACK" \
			-o -z "${ARG}" -a "${KEY}" == "SELF" \
			-o -z "${ARG}" -a "${KEY}" == "ALL" \
			];then
			case $KEY in

             ##################################################
             # Common control enforcement scope and behaviour #
             ##################################################
			    FORCE)
				local _force=1;
				printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "MODE:FORCE"
				;;

			    STACK)
				local _stack=1;
				printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "MODE:STACK (DEFAULT)"
				;;

			    SELF)
				local _self=1;
				printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "MODE:SELF"
				;;
			    TIMEOUT)
				local _timeout="${ARG}";
				if [ -z "${_timeout}" ];then
				    ABORT=1;
				    printERR $LINENO $BASH_SOURCE ${ABORT} "${KEY} requires a value"
				    gotoHell ${ABORT}
				fi
				printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "${KEY}=${_timeout}"
				;;


              ##################
              # Common methods #  
              ##################
			    REBOOT)
				local _reboot=1;
				let _unambigCMD+=1;
 				printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "MODE:REBOOT"
				;;
			    RESET)
				local _reset=1;
				let _unambigCMD+=1;
 				printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "MODE:RESET"
				;;
			    PAUSE|S3)
				local _pause=1;
				let _unambigCMD+=1;
 				printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "MODE:PAUSE-S3"
				;;
			    SUSPEND|S4)
				local _suspend=1;
				let _unambigCMD+=1;
 				printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "MODE:SUSPEND-S4"
				;;
			    POWEROFF|S5)
				local _powoff=1;
				local _powoffdelay="${ARG:-0}";
				let _unambigCMD+=1;
				printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "MODE:POWEROFF-S5 DELAY=${_powoffdelay}"
				;;

			    INIT)
				local _init=1;
				local _initstate="${ARG}";
				let _unambigCMD+=1;
				printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "MODE:INIT STATE=${_initstate}"
				;;


              #####################
              # <machine-address> #
              #####################
			    BASEPATH|BASE|B)
				local _base="${ARG}";
				printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "RANGE:BASE=${_base}"
				;;
			    TCP|T)
				local _tcp="${ARG}";
				printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "TCP=${_tcp}"
				let _unambig+=1;
				;;
			    MAC|M)
				local _mac="${ARG}";
				printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "MAC=${_mac}"
				let _unambig+=1;
				;;
			    UUID|U)
				local _uuid="${ARG}";
 				printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "RANGE:UUID=${_uuid}"
				let _unambig+=1;
				;;
			    LABEL|L)
				local _label="${ARG}";
 				printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "RANGE:LABEL=${_label}"
				let _unambig+=1;
				;;
			    FILENAME|FNAME|F)
				local _fname="${ARG}";
				printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "RANGE:FILENAME=${_fname}"
				let _unambig++;
				;;
			    ID|I|PATHNAME|PNAME|P)
                              #can (partly for relative names) be checked now
				if [ -n "${ARG##/*}" ]; then
				    ABORT=1;
				    printERR $LINENO $BASH_SOURCE ${ABORT} "PNAME has to be an absolute path, use fname else."
				    printERR $LINENO $BASH_SOURCE ${ABORT} "  PNAME=${ARG}"
 				    gotoHell ${ABORT}
				fi
				local _idgiven=1;
				printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "RANGE:PATHNAME=${ARG}"
				;;

              #######################
              # Specific attributes #  
              #######################
			    ALL)
				local _all=1;
 				printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "RANGE:ALL"
				let _unambig+=1;
				;;
			    CLIENT)
				_CSB=CLIENT;
				let _unambigCSB+=1;
 				printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "SCOPE:CLIENT"
				;;
			    SERVER)
				_CSB=SERVER;
				let _unambigCSB+=1;
  				printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "SCOPE:SERVER"
				;;
			    BOTH)
				_CSB=BOTH;
				let _unambigCSB+=1;
  				printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "SCOPE:BOTH=CLIENT+SERVER"
				;;
			    *)
				ABORT=1;
				printERR $LINENO $BASH_SOURCE ${ABORT} "Unknown sub-opts for QEMU:${KEY}"
				printERR $LINENO $BASH_SOURCE ${ABORT} "Allowed values: REUSE - base|b - label|l - fname|f - pname|p"
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

		local _CSB=SERVER;

		if((_unambigCSB>1));then
		    ABORT=1;
		    printERR $LINENO $BASH_SOURCE ${ABORT} "The following sub-opts are EXOR applicable only:"
		    printERR $LINENO $BASH_SOURCE ${ABORT} "  CLIENT|SERVER|BOTH"
 		    gotoHell ${ABORT}
		fi

		if((_unambigCMD>1));then
		    ABORT=1;
		    printERR $LINENO $BASH_SOURCE ${ABORT} "The following sub-opts are EXOR applicable only:"
		    printERR $LINENO $BASH_SOURCE ${ABORT} "  REBOOT|RESET|SUSPEND|POWEROFF|INIT"
 		    gotoHell ${ABORT}
		fi

		if [ "${_CSB}" == CLIENT ];then
		    case ${KEY} in
			SUSPEND|RESET|POWEROFF)
			    ABORT=1;
			    printERR $LINENO $BASH_SOURCE ${ABORT} "CLIENT cannot be combined with:SUSPEND|RESET|POWEROFF"
 			    gotoHell ${ABORT}
			    ;;
		    esac
		fi
            fi

            if((_unambig==0&&_idgiven!=1));then
		ABORT=1;
		printERR $LINENO $BASH_SOURCE ${ABORT} "Missing address parameter."
 		gotoHell ${ABORT}
            fi
	    ;;

	ASSEMBLE)
	    ;;

	EXECUTE)
	    if [ -n "${R_TEXT}" ];then
		echo "${R_TEXT}"
	    fi

	    local _unambig=0;

	    printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "C_MODE_ARGS=$C_MODE_ARGS"
	    A=`cliSplitSubOpts ${C_MODE_ARGS}`
	    for i in $A;do
		KEY=`cliGetKey ${i}`
		ARG=`cliGetArg ${i}`
                if [ -n "${ARG}" \
		    -o -z "${ARG}" -a "${KEY}" == "CLIENT" \
		    -o -z "${ARG}" -a "${KEY}" == "SERVER" \
		    -o -z "${ARG}" -a "${KEY}" == "BOTH" \
		    -o -z "${ARG}" -a "${KEY}" == "S3" \
		    -o -z "${ARG}" -a "${KEY}" == "S4" \
		    -o -z "${ARG}" -a "${KEY}" == "S5" \
		    -o -z "${ARG}" -a "${KEY}" == "POWEROFF" \
		    -o -z "${ARG}" -a "${KEY}" == "SUSPEND" \
		    -o -z "${ARG}" -a "${KEY}" == "RESET" \
		    -o -z "${ARG}" -a "${KEY}" == "STACK" \
		    -o -z "${ARG}" -a "${KEY}" == "FORCE" \
		    -o -z "${ARG}" -a "${KEY}" == "SELF" \
		    -o -z "${ARG}" -a "${KEY}" == "ALL" \
		    ];then
		    case $KEY in
           ##################################################
           # Common control enforcement scope and behaviour #
           ##################################################
			FORCE)
			    local _force=1;
			    printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "MODE:FORCE"
			    ;;

			STACK)
			    local _stack=1;
			    printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "MODE:STACK (DEFAULT)"
			    ;;

			SELF)
			    local _self=1;
			    printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "MODE:SELF"
			    ;;
			TIMEOUT)
			    local _timeout="${ARG}";
			    if [ -z "${_timeout}" ];then
				ABORT=1;
				printERR $LINENO $BASH_SOURCE ${ABORT} "${KEY} requires a value"
				gotoHell ${ABORT}
			    fi
			    printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "${KEY}=${_timeout}"
 			    DEFAULT_KILL_DELAY_POWEROFF=${_timeout};
			    ;;

              ##################
              # Common methods #  
              ##################
			REBOOT)
			    local _reboot=1;
			    _behaviour=REBOOT;
 			    printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "MODE:REBOOT"
			    ;;
			RESET)
			    local _reset=1;
			    _behaviour=RESET;
 			    printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "MODE:RESET"
			    ;;
			PAUSE|S3)
			    local _pause=1;
			    _behaviour=PAUSE;
 			    printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "MODE:PAUSE-S3"
			    ;;
			SUSPEND|S4)
			    local _suspend=1;
			    _behaviour=SUSPEND;
 			    printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "MODE:SUSPEND-S4"
			    ;;
			POWEROFF|S5)
			    local _powoff=1;
			    local _powoffdelay="${ARG:-$DEFAULT_KILL_DELAY_POWEROFF}";
			    _behaviour=POWEROFF;
			    printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "MODE:POWEROFF-S5 DELAY=${_powoffdelay}"
			    ;;
			INIT)
			    local _init=1;
			    local _initstate="${ARG}";
			    _behaviour=INIT;
			    printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "MODE:INIT STATE=${_initstate}"
			    ;;

            #####################
            # <machine-address> #
            #####################
			BASEPATH|BASE|B)
                            local _base="${ARG}";
			    printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "RANGE:BASE=${_base}"

                            #                       
                            #quick-shot for temp solution of too early cache-masking
                            #
                            _base=${_base//\%/ }
                            _base=${_base//\\\//\/}
                            for i in ${_base};do
                                if [ ! -d "${i}" ];then
				    ABORT=1;
				    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing given base-path";
				    printERR $LINENO $BASH_SOURCE ${ABORT} "  i  = ${i}";
				    printERR $LINENO $BASH_SOURCE ${ABORT} "  PWD= ${PWD}";
				    printERR $LINENO $BASH_SOURCE ${ABORT} "Check your actual PWD when providing a relative base-path";
 				    gotoHell ${ABORT};
                                fi
			    done
			    ;;

			TCP|T)
			    local _tcp="${ARG}";
			    printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "TCP=${_tcp}"
			    ;;

			MAC|M)
			    local _mac="${ARG}";
			    printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "MAC=${_mac}"
			    ;;

			UUID|U)
			    local _uuid="${ARG}";
 			    printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "RANGE:UUID=${_uuid}"
			    ;;

			LABEL|L)
                            local _label="${ARG}";
 			    printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "RANGE:LABEL=${_label}"
			    ;;
			FILENAME|FNAME|F)
                            local _fname="${ARG}";
			    printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "RANGE:FILENAME=${_fname}"
			    ;;
			ID|I|PATHNAME|PNAME|P)
                            #can be checked now, no additional combination check required 
                            #due to previous CHECKPARAM.
                            if [ ! -f "${ARG}" ];then
				ABORT=1;
				printERR $LINENO $BASH_SOURCE ${ABORT} "Missing given pathname"
				printERR $LINENO $BASH_SOURCE ${ABORT} "  _pname=${ARG}"
 				gotoHell ${ABORT}
                            fi
                            local _pname="${_pname:+$_pname|}${ARG}";
			    printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "RANGE:PATHNAME=${_pname}"
			    ;;

                #####################
			ALL)
			    local _all=1;
 			    printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "RANGE:all within scope"
			    ;;
			CLIENT)
			    local _CSB=CLIENT;
  			    printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "SCOPE:CLIENT"
			    ;;
			SERVER)
			    local _CSB=SERVER;
  			    printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "SCOPE:SERVER"
			    ;;
			BOTH)
			    local _CSB=BOTH;
  			    printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "SCOPE:BOTH=CLIENT+SERVER"
			    ;;
			*)
			    ABORT=1;
			    printERR $LINENO $BASH_SOURCE ${ABORT} "Unexpected sub-opts for QEMU:${KEY}"
 			    gotoHell ${ABORT}
			    ;;
		    esac
		fi
	    done
	    local _CSB=SERVER;


    #####
     #####
      #So basic isolated parameters seem to be OK, let's put them together.
     #####
    #####


	    printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "CombineParamaters"

            ################################
            #
            #Lists extended pname(1-awk-increment):LABEL,ID,PID,SITE,SPORT
            #                                      #3    #4 #11 #14  #10
            ################################

            #
            #expand given only.
            #
	    if [ -n "${_pname}" ];then
		printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "PNAME-EVALUATE-EXPAND=<$_pname>"
		local _tmpBuf=`listMySessions ${_CSB},MACHINE`
		printDBG $S_QEMU ${D_BULK} $LINENO $BASH_SOURCE "PNAME-EVALUATE-EXPAND-ALL=<$_tmpBuf>"
		_pname=`for _i2 in ${_tmpBuf};do echo "$_i2"|\
                        awk -F';' -v p="${_pname}" '$4~p{print $3 ";" $4 ";" $11 ";" $14 ";" $10}';done`
		printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "PNAME-EVALUATE-EXPAND-TO=<$_pname>"
	    fi


            #
            #fetch all running instances
            #
	    if [ -n "${_all}" ];then
		printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "PNAME-EVALUATE-ALL"
		_pname=`listMySessions ${_CSB},MACHINE|awk -F';' '{print $3 ";" $4 ";" $11 ";" $14 ";" $10}'`
	    fi


            #
            #specific instance, resolved from cache
            #
            if [ -z "${_all}" -a -z "${_pname}" -a "${C_NSCACHEONLY}" == 1 -a "${C_NSCACHELOCATE}" == 0 ];then
		ABORT=1;
		printERR $LINENO $BASH_SOURCE ${ABORT} "Missing PNAME, required from client due to \"-c LOCAL,ONLY...\""
 		gotoHell ${ABORT}
	    fi

	    if [ -z "${_pname}"  -a "${C_NSCACHELOCATE}" -gt 0 ];then
		printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "PNAME-EVALUATE-CACHE"
		printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "Current version does not support cached operations for LIST."
	    fi


            #
            #specific instance, resolved from pool of running instances
            #
            if [ -z "${_pname// /}" ];then
		printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "PNAME-EVALUATE-RUNTIME-SYSTEM"

		if [ -n "${_uuid}" ];then
		    _pname=`listMySessions ${_CSB},MACHINE|\
                            awk -F';' -v u="${_uuid}" '$5~u{print $3 ";" $4 ";" $11 ";" $14 ";" $10}'`
		else
		    if [ -n "${_label}" ];then
			_pname=`listMySessions ${_CSB},MACHINE|\
                                awk -F';' -v l="${_label}" '$3~l{print $3 ";" $4 ";" $11 ";" $14 ";" $10}'`
		    else
			if [ -n "${_tcp}" ];then
			    if [ -n "${_tcp}" -a "${C_NSCACHELOCATE}" != 0 ];then
 				local _cx1=`${MYLIBEXECPATH}/ctys-vhost.sh $_dbg1 -s -o MAC -p ${DBPATHLST} ${_tcp}`
				if [ -n "$_cx1" ];then
				    _pname=`listMySessions ${_CSB},MACHINE|\
                                        awk -F';' -v l="${_cx1}" '$7~l{print $3 ";" $4 ";" $11 ";" $14 ";" $10}'`
				fi
			    else
				printDBG $S_QEMU ${D_UI} $LINENO $BASH_SOURCE "NS cache is off \"-c off\"."
			    fi
			    printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "_pname=${_pname}"
			else
	 		    if [ -n "${_mac}" ];then
				_pname=`listMySessions ${_CSB},MACHINE|\
                                        awk -F';' -v l="${_mac}" '$6~l{print $3 ";" $4 ";" $11 ";" $14 ";" $10}'`
				printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "_pname=${_pname}"
			    else
				if [ -n "${_fname}" ];then
   				    _pname=`listMySessions ${_CSB},MACHINE|\
                                            awk -F';' -v f="${_fname}" '$4~f{print $3 ";" $4 ";" $11 ";" $14 ";" $10}'`
				    printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "_pname=${_pname}"
				fi
			    fi
			fi
		    fi
		fi
		if [ -n "${_pname}" ];then
		    printDBG $S_QEMU ${D_TST} $LINENO $BASH_SOURCE "$FUNCNAME:ENTRY:OPMODE=${OPMODE}:ACTION=${ACTION}:PNAME=FROM-LIST"
		fi
	    fi

            #
            #Well, now we have a complete list (probably a valid EMPTY-LIST) of sessions to be canceled.
            #With format:
            #
            #  _pname="<label>;<id=filepathname>;<pid>;<CLIENT|SERVER>;<SPORT>"
            #          #1       #2                #3    #4             #5(master-pid)
            #
	    printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "----------------------"
	    printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "- Cancel sessions:"
	    printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "-  _force     = ${_force}"
	    printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "----------------------"
	    printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "-  _reboot    = ${_reboot}"
	    printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "-  _reset     = ${_reset}"
	    printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "-  _suspend   = ${_suspend}"
	    printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "-  _init      = ${_init} - ${_initstate}"
	    printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "-  _powoff    = ${_powoff} - ${_powoffdelay}"
	    printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "----------------------"
	    printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "-  _behaviour = ${_behaviour}"
	    printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "----------------------"
	    printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "  PATHNAME    = ${_pname}"
	    printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "----------------------"


	    if [ -z "${_pname}" ];then
		printDBG $S_QEMU ${D_TST} $LINENO $BASH_SOURCE "$FUNCNAME:ENTRY:OPMODE=${OPMODE}:ACTION=${ACTION}:PNAME=MISSING"
	    fi

      ###########################
       #    So, ... let's go!    #
      ###########################

            #prepare parameters for STACKER
	    local _target=;
            local _i7=;
	    for _i7 in ${_pname};do
		_target="${_target} ${_i7%;*;*;*}"
	    done

            if [ "${_CSB}" == CLIENT ];then
                #kill clients, guess the caller knows what he is doing, particularly
                #has assured a stateless server!!!
  		printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "MODE=CUT/LEAVE"
		for _i in ${_pname};do
                    [ "${_i##*;}" != CLIENT ]&&continue;
		    printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "kill:${_i}"
                    local _pid=${_i%;*}
                    _pid=${_pid##*;}
                    echo -n "Session:\"${_i%%;*}\":PID=$_pid"
                    kill $_pid
                    echo
		done
	    else
		case $_behaviour in
		    INIT)
                        local _checkAction=0;
  			printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "ACTION-MODE=INIT"
			if [ -z "$_force" ];then
			    stackerCancelPropagate STACK "INIT:${_initstate}" "${_self:-$_target}"
  			    printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "delay:${DEFAULT_KILL_DELAY_POWEROFF}"
			    sleep ${DEFAULT_KILL_DELAY_POWEROFF}
			    _checkAction=1;
			fi
			if [ -n "${_self}" ];then
  			    printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "SELF"
			    init ${_initstate}
			    _checkAction=1;
			fi
			if [ "${_checkAction}" == 0 ];then
  			    printINFO 1 $LINENO $BASH_SOURCE "INIT is a pure GuestOS functionality, hypervisor is not utilized."
  			    printINFO 1 $LINENO $BASH_SOURCE "No action by INIT, check manual."
  			    printINFO 1 $LINENO $BASH_SOURCE "For action FORCE must be unset and/or SELF has to be set."
			fi
			;;


		    RESET|REBOOT)
  			printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "ACTION-MODE=RESET|REBOOT"

			if [ -z "$_force" ];then
                            #the "maybe" alternate would be to freeze the contained, and restart+reset
                            #them when the container is available again, but what about interrupted/disrupted
                            #session-timeouts, so prefer to keep things simple, a solution is NOT available
                            #anyhow.
			    stackerCancelPropagate STACK "REBOOT" "${_self:-$_target}";
			    sleep ${DEFAULT_KILL_DELAY_POWEROFF}
			else
  			    for _i in ${_pname};do
				[ "${_i##*;}" == CLIENT ]&&continue;
				printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "reset:${_i}"

				local _id=${_i%;*;*}
				_id=${_id#*;}
				if [ "$_i" == "$_id" ];then
				    _ret=1;
				    printERR $LINENO $BASH_SOURCE ${_ret} "Record=${_i}:REASON=Erroneous _pname=<${_pname}>"
				    continue
				fi

				local _pid=${_i#*;*;}
				_pid=${_pid%;*}
				if [ "$_i" == "$_pid" ];then
				    _ret=1;
				    printERR $LINENO $BASH_SOURCE ${_ret} "ID=${_id}:REASON=Erroneous _pid=<${_pid}>"
				    continue
				fi

				local _sport=${_i##*;}
				if [ "$_i" == "$_sport" ];then
				    _ret=1;
				    printERR $LINENO $BASH_SOURCE ${_ret} "ID=${_id}:REASON=Erroneous _sport=<${_sport}>"
				    continue
				fi

				local _label=${_i%%;*}
				if [ "$_i" == "$_label" ];then
				    _ret=1;
				    printERR $LINENO $BASH_SOURCE ${_ret} "LABEL=${_label}:REASON=Erroneous _label=<${_label}>"
				    continue
				fi
				echo
				echo  "----------------------------"
				echo  "RESET-SERVER Session:"
				echo  "   ID    =$_id"
				echo  "   LABEL =$_label"
				echo  "   PID   =$_pid"
				echo  "   SPORT =$_sport"
				echo  "----------------------------"
				vmMgrQEMU RESET "$_label" "$_id" "$_pid" "$_sport"
				echo
				echo  "----------------------------"
				echo
			    done
			fi
			if [ -n "${_self}" ];then
  			    printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "SELF"
			    reboot
			fi
			;;

		    PAUSE|S3)
			printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "PAUSE|S3 is not supported by QEMU, partially mapped to S4"
#shifted to later version
#                         #suspend servers controlled with proprietary tool first
#   			printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "ACTION-MODE=PAUSE-S3"
# 			if [ -z "$_force" ];then
# 			    stackerCancelPropagate STACK "PAUSE" "${_self:-$_target}";
# 			    sleep ${DEFAULT_KILL_DELAY_POWEROFF}
# 			fi

			for _i in ${_pname};do
			    [ "${_i##*;}" == CLIENT ]&&continue;
			    printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "MAPPED TO suspend:${_i}"

			    local _id=${_i%;*;*}
			    _id=${_id#*;}
			    if [ "$_i" == "$_id" ];then
				_ret=1;
				printERR $LINENO $BASH_SOURCE ${_ret} "Record=${_i}:REASON=Erroneous _pname=<${_pname}>"
				continue
			    fi

			    local _pid=${_i#*;*;}
			    _pid=${_pid%;*}
			    if [ "$_i" == "$_pid" ];then
				_ret=1;
				printERR $LINENO $BASH_SOURCE ${_ret} "ID=${_id}:REASON=Erroneous _pid=<${_pid}>"
				continue
			    fi

			    local _sport=${_i##*;}
			    if [ "$_i" == "$_sport" ];then
				_ret=1;
				printERR $LINENO $BASH_SOURCE ${_ret} "ID=${_id}:REASON=Erroneous _sport=<${_sport}>"
				continue
			    fi

			    local _label=${_i%%;*}
			    if [ "$_i" == "$_label" ];then
				_ret=1;
				printERR $LINENO $BASH_SOURCE ${_ret} "LABEL=${_label}:REASON=Erroneous _label=<${_label}>"
				continue
			    fi
			    echo
			    echo  "----------------------------"
			    echo  "RESET-SERVER Session:"
			    echo  "   ID    =$_id"
			    echo  "   LABEL =$_label"
			    echo  "   PID   =$_pid"
			    echo  "   SPORT =$_sport"
			    echo  "----------------------------"
			    vmMgrQEMU SUSPEND "$_label" "$_id" "$_pid" "$_sport"
			    echo
			    echo  "----------------------------"
			    echo
			done

                        #kill remaining clients 
			killClients ${_pname}

			if [ -n "${_self}" ];then
			    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "PAUSE-S3 not yet supported, mapped to S5"
			    halt -p
			fi
			;;

		    SUSPEND|S4)
                        #suspend servers controlled with proprietary tool first
  			printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "ACTION-MODE=SUSPEND-S4"

#shifted to later version
# 			if [ -z "$_force" ];then
# 			    stackerCancelPropagate STACK "SUSPEND" "${_self:-$_target}";
# 			    sleep ${DEFAULT_KILL_DELAY_POWEROFF}
# 			fi

			for _i in ${_pname};do
			    [ "${_i##*;}" == CLIENT ]&&continue;
			    printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "suspend:${_i}"

			    local _id=${_i%;*;*}
			    _id=${_id#*;}
			    if [ "$_i" == "$_id" ];then
				_ret=1;
				printERR $LINENO $BASH_SOURCE ${_ret} "Record=${_i}:REASON=Erroneous _pname=<${_pname}>"
				continue
			    fi

			    local _pid=${_i#*;*;}
			    _pid=${_pid%;*}
			    if [ "$_i" == "$_pid" ];then
				_ret=1;
				printERR $LINENO $BASH_SOURCE ${1} "ID=${_id}:REASON=Erroneous _pid=<${_pid}>"
				continue
			    fi

			    local _sport=${_i##*;}
			    if [ "$_i" == "$_sport" ];then
				_ret=1;
				printERR $LINENO $BASH_SOURCE ${_ret} "ID=${_id}:REASON=Erroneous _sport=<${_sport}>"
				continue
			    fi

			    local _label=${_i%%;*}
			    if [ "$_i" == "$_label" ];then
				_ret=1;
				printERR $LINENO $BASH_SOURCE ${_ret} "LABEL=${_label}:REASON=Erroneous _label=<${_label}>"
				continue
			    fi
			    echo
			    echo  "----------------------------"
			    echo  "SUSPEND-SERVER Session:"
			    echo  "   ID    =$_id"
			    echo  "   LABEL =$_label"
			    echo  "   PID   =$_pid"
			    echo  "   SPORT =$_sport"
			    echo  "----------------------------"
			    vmMgrQEMU SUSPEND "$_label" "$_id" "$_pid" "$_sport"
			    echo
			    echo  "----------------------------"
			    echo
			done

                        #kill remaining clients 
			killClients ${_pname}
			if [ -n "${_self}" ];then
			    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "SUSPEND-S4 not yet supported, mapped to S5"
			    halt -p
			fi
			;;

		    POWEROFF|S5)
  			printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "ACTION-MODE=POWEROFF"

			if [ -z "$_force" ];then
			    stackerCancelPropagate STACK "POWEROFF" "${_self:-$_target}";
 			    sleep ${_powoffdelay:-$DEFAULT_KILL_DELAY_POWEROFF}
			fi

			for _i in ${_pname};do
			    [ "${_i##*;}" == CLIENT ]&&continue;
			    printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "stop:${_i}"

			    local _id=${_i#*;}
			    _id=${_id%%;*}
			    if [ -z "$_id" -o "$_i" == "$_id" ];then
				_ret=1;
				printERR $LINENO $BASH_SOURCE ${_ret} "Record=${_i}:REASON=Erroneous _pname=<${_pname}>"
				continue
			    fi

			    local _pid=${_i#*;*;}
			    _pid=${_pid%%;*}
			    if [ -z "$_pid" -o "$_i" == "$_pid" ];then
				_ret=1;
				printERR $LINENO $BASH_SOURCE ${_ret} "ID=${_id}:REASON=Erroneous _pid=<${_pid}>"
				continue
			    fi

			    local _sport=${_i##*;}
			    if [ -z "$_sport" -o "$_i" == "$_sport" ];then
				_ret=1;
				printERR $LINENO $BASH_SOURCE ${_ret} "ID=${_id}:REASON=Erroneous _sport=<${_sport}>"
				continue
			    fi

			    local _label=${_i%%;*}
			    if [ -z "$_label" -o "$_i" == "$_label" ];then
				_ret=1;
				printERR $LINENO $BASH_SOURCE ${_ret} "LABEL=${_label}:REASON=Erroneous _label=<${_label}>"
				continue
			    fi

                            echo
			    echo  "----------------------------"
			    echo  "POWEROFF-SERVER Session:"
			    echo  "   ID    =$_id"
			    echo  "   LABEL =$_label"
			    echo  "   PID   =$_pid"
			    echo  "   SPORT =$_sport"
			    echo  "   DELAY =${_powoffdelay:-$DEFAULT_KILL_DELAY_POWEROFF}"
			    echo  "   FLAG  =${_force:+FORCE}"
			    echo  "----------------------------"
			    vmMgrQEMU POWEROFF "$_label" "$_id" "$_pid" "$_sport" "${_powoffdelay:-$DEFAULT_KILL_DELAY_POWEROFF}" "${_force:+FORCE}"
			    echo
			    echo  "----------------------------"
			    echo
			done

			if [ "${_CSB}" != SERVER ];then 
                            #kill remaining clients 
			    killClients ${_pname}
			fi
			if [ -n "${_self}" ];then
  			    printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "SELF"
			    halt -p
			fi
			;;


		    *)
			ABORT=1;
			printERR $LINENO $BASH_SOURCE ${ABORT} "Reached unexpected execution tracepoint"
			printERR $LINENO $BASH_SOURCE ${ABORT} "  _behaviour=$_behaviour"
			printERR $LINENO $BASH_SOURCE ${ABORT} "'seems to be, that a suboption of cancel is missing????"
			printERR $LINENO $BASH_SOURCE ${ABORT} "This might be an internal error???"
			gotoHell ${ABORT}
			;;
		esac
            fi
	    ;;
    esac

    if [ $_ret -eq 0 ];then
	printDBG $S_QEMU ${D_TST} $LINENO $BASH_SOURCE "$FUNCNAME:EXIT:OPMODE=${OPMODE}:ACTION=${ACTION}:RESULT=OK"
    else
	printDBG $S_QEMU ${D_TST} $LINENO $BASH_SOURCE "$FUNCNAME:EXIT:OPMODE=${OPMODE}:ACTION=${ACTION}:RESULT=NOK"
    fi
    return $_ret
}
