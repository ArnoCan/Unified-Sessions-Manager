#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_011
#
########################################################################
#
# Copyright (C) 2007,2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

_myPKGNAME_CLI_CREATE="${BASH_SOURCE}"
_myPKGVERS_CLI_CREATE="01.11.011"
hookInfoAdd $_myPKGNAME_CLI_CREATE $_myPKGVERS_CLI_CREATE
_myPKGBASE_CLI_CREATE="`dirname ${_myPKGNAME_CLI_CREATE}`"


#FUNCBEG###############################################################
#NAME:
#  createConnectCLI
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Creates a session and/or connects to the server.
#  
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
function createConnectCLI () {
    printDBG $S_CLI ${D_UID} $LINENO $BASH_SOURCE "${FUNCNAME}:$*"
    local OPMODE=$1;shift
    local ACTION=$1;shift

    local A;
    local KEY;
    local ARG;
    local i;

    case ${OPMODE} in
	CHECKPARAM)
            #
            #Just check syntax drafts, the expansion of labels etc. could just be
            #expanded on target machine.
            #
            if [ -n "$C_MODE_ARGS" ];then
		local _unambig=0;
		local _unambigCON=0;

                printDBG $S_CLI ${D_UID} $LINENO $BASH_SOURCE "C_MODE_ARGS=$C_MODE_ARGS"
		A=`cliSplitSubOpts ${C_MODE_ARGS}`
		for i in $A;do
		    KEY=`cliGetKey ${i}`
		    ARG=`cliGetArg ${i}`
                    if [ -n "${ARG}" \
			-o -z "${ARG}" \
			-a \( \
                          "${KEY}" == "DUMMY"  \
                          -o "${KEY}" == "STUB" \
                          -o "${KEY}" == "STUBMODE" \
                        \) \
			];then
			case $KEY in
                            REUSE|CONNECT|RECONNECT|RESUME)
				ABORT=1
				printERR $LINENO $BASH_SOURCE ${ABORT} "${ACTION}:Suboption ${KEY} NOT supported"
				gotoHell ${ABORT}
				;;

			    SHELL|S)
                                local _shell="${ARG}";
 				printDBG $S_CLI ${D_UID} $LINENO $BASH_SOURCE "SHELL=$_shell"
				;;
			    CMD)
                                local _cmd="${ARG}";
 				printDBG $S_CLI ${D_UID} $LINENO $BASH_SOURCE "CMD=$_cmd"
				;;
			    CHDIR|CD)
                                local _chdir="${ARG}";
 				printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE "CHDIR=$_chdir"
				;;

                          #####################
                          # <call-arguments>  #
                          #####################
			    CALLOPTS|C)
				local _callopts="${ARG//\%/ }";
				printDBG $S_CLI ${D_UID} $LINENO $BASH_SOURCE "CALLOPTS=${_callopts}"
				;;
			    XOPTS|X)
				local _xopts="${ARG//\%/ }";
				printDBG $S_CLI ${D_UID} $LINENO $BASH_SOURCE "XTOOLKITOPTS=${_xopts}"
				;;

                          #####################
                          # <machine-address> #
                          #####################
			    BASEPATH|BASE|B|TCP|T|MAC|M|UUID|U|FILENAME|FNAME|F|ID|PATHNAME|PNAME|P)
				ABORT=1
				printERR $LINENO $BASH_SOURCE ${ABORT} "${ACTION}:Suboption ${KEY} NOT supported"
				gotoHell ${ABORT}
				;;

			    LABEL|L)
				local _label="${ARG}";
 				printDBG $S_CLI ${D_UID} $LINENO $BASH_SOURCE "LABEL=${_label}"
				let _unambig+=1;
				;;

                            STUBMODE|STUB)
				C_STUBCALL=1;
 				printDBG $S_CLI ${D_UID} $LINENO $BASH_SOURCE "STUBMODE"
                                local _wrapper="${ARG// /}";
				case "$_wrapper" in
				    [oO][nN])C_NOWRAPPER=;
				esac
 				printDBG $S_CLI ${D_UID} $LINENO $BASH_SOURCE "WRAPPER=${_wrapper:-OFF}"
				;;

			    *)
				ABORT=1;
				printERR $LINENO $BASH_SOURCE ${ABORT} "Unknown sub-opts for CLI:${KEY}"
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
	    fi
            #Ease later procesing by simple key, else not really required.
	    if [ -z "${_label}" ];then
		ABORT=1;
		printERR $LINENO $BASH_SOURCE ${ABORT} "Missing mandatory parameter:\"LABEL\""
 		gotoHell ${ABORT}               
	    fi
	    if [ -z "${_cmd}" -a $C_ASYNC -ne 1 ];then
		printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "Interactive call, force: \"-b 0,2\""
 		printDBG $S_CLI ${D_UID} $LINENO $BASH_SOURCE "Interactive call, force:"
 		printDBG $S_CLI ${D_UID} $LINENO $BASH_SOURCE "C_PARALLEL=0"
 		printDBG $S_CLI ${D_UID} $LINENO $BASH_SOURCE "C_ASYNC=0"
		C_PARALLEL=0;
		C_ASYNC=0;
	    fi
	    ;;

	ASSEMBLE)
	    if [ -z "$C_STUBCALL" ];then
		assembleExeccall 
	    else
		${FUNCNAME} EXECUTE $ACTION 
	    fi
	    ;;

	PROPAGATE)
	    assembleExeccall PROPAGATE
	    ;;

	EXECUTE)
	    if [ -n "${R_TEXT}" ];then
		echo "${R_TEXT}"
	    fi
	    if [ -n "$C_MODE_ARGS" ];then
		local _unambig=0;
                printDBG $S_CLI ${D_UID} $LINENO $BASH_SOURCE "C_MODE_ARGS=$C_MODE_ARGS"
		A=`cliSplitSubOpts ${C_MODE_ARGS}`
		for i in $A;do
		    KEY=`cliGetKey ${i}`
		    ARG=`cliGetArg ${i}`
		    if [ -n "${ARG}" \
			-o -z "${ARG}" \
			-a \( \
                        "${KEY}" == "DUMMY"  \
                        \) \
			];then
			case $KEY in
			    SHELL|S)
                                local _shell="${ARG}";
 				printDBG $S_CLI ${D_UID} $LINENO $BASH_SOURCE "SHELL=$_shell"
				;;
			    CMD)
                                local _cmd="${ARG}";
 				printDBG $S_CLI ${D_UID} $LINENO $BASH_SOURCE "CMD=$_cmd"
				;;
			    CHDIR|CD)
                                local _chdir="${ARG}";
 				printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE "CHDIR=$_chdir"
				;;

                          #####################
                          # <call-arguments>  #
                          #####################
			    CALLOPTS|C)
				local _callopts="${ARG//\%/ }";
				printDBG $S_CLI ${D_UID} $LINENO $BASH_SOURCE "CALLOPTS=${_callopts}"
                                C_SESSIONIDARGS="${_callopts}"
				;;
			    XOPTS|X)
				local _xopts="${ARG//\%/ }";
				printDBG $S_CLI ${D_UID} $LINENO $BASH_SOURCE "XTOOLKITOPTS=${_xopts}"
                                C_XTOOLKITOPTS="${_xopts}"
				;;

                          #####################
                          # <machine-address> #
                          #####################
			    LABEL|L)
                                local _label="${ARG}";
 				printDBG $S_CLI ${D_UID} $LINENO $BASH_SOURCE "LABEL=${_label}"
				;;
			    FILENAME|FNAME|F)
                                local _fname="${ARG}";
				printDBG $S_CLI ${D_UID} $LINENO $BASH_SOURCE "FILENAME=${_fname}"
				;;
                            STUBMODE|STUB)
				C_STUBCALL=1;
 				printDBG $S_CLI ${D_UID} $LINENO $BASH_SOURCE "STUBMODE"
                                local _wrapper="${ARG// /}";
				case "$_wrapper" in
				    [oO][nN])C_NOWRAPPER=;
				esac
 				printDBG $S_CLI ${D_UID} $LINENO $BASH_SOURCE "WRAPPER=${_wrapper:-OFF}"
				;;
			    *)
				ABORT=1;
				printERR $LINENO $BASH_SOURCE ${ABORT} "Unexpected sub-opts for CLI:${KEY}"
 				gotoHell ${ABORT}
				;;
			esac
		    fi
		done
		printDBG $S_CLI ${D_MAINT} $LINENO $BASH_SOURCE "CombineParamaters"
	    else
		local stripDummy=;
		printDBG $S_CLI ${D_UID} $LINENO $BASH_SOURCE "No user supplied parameters - set defaults"
	    fi

            #evaluate the actual task
	    local _mytask=;
            if [ -z "${_cmd}" ];then
		_mytask="${_shell:-$CLI_SHELL_DEFAULT}"
	    else
		_cmd="${_cmd//;/\\;}"
		_mytask="${_shell:-$CLI_SHELL_CMD_DEFAULT} \"${_cmd}\""
	    fi

            case "${C_CLIENTLOCATION#-L }" in
		LOCALONLY|DISPLAYFORWARDING)
                    if [ -z "${_label}" ];then
                        _label="DEFAULT-${DATETIME}"
                    fi

		    printDBG $S_CLI ${D_UID} $LINENO $BASH_SOURCE "startSessionCLI \"${_label}\""
		    printDBG $S_CLI ${D_UID} $LINENO $BASH_SOURCE " ->_label   =\"${_label}\""
		    printDBG $S_CLI ${D_UID} $LINENO $BASH_SOURCE " ->_mytask  =\"${_mytask}\""
		    printDBG $S_CLI ${D_UID} $LINENO $BASH_SOURCE " ->_callopts=\"${_callopts}\""
		    printDBG $S_CLI ${D_UID} $LINENO $BASH_SOURCE " ->_xopts   =\"${_xopts}\""
		    printDBG $S_CLI ${D_UID} $LINENO $BASH_SOURCE " ->_chdir   =\"${_chdir}\""

                    startSessionCLI "${_label}"  "${_mytask} ${_callopts}" "${_xopts}" "${_chdir}"
		    gotoHell 0
		    ;;

		CONNECTIONFORWARDING|*)
		    ABORT=1
		    printERR $LINENO $BASH_SOURCE ${ABORT} "Execution locality error:${C_CLIENTLOCATION}"
		    gotoHell ${ABORT}
		    ;;
	    esac
	    ;;
    esac
}
