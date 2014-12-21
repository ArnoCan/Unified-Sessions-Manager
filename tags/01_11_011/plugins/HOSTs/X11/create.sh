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
# Copyright (C) 2007,2008,2009,2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

_myPKGNAME_X11_CREATE="${BASH_SOURCE}"
_myPKGVERS_X11_CREATE="01.11.011"
hookInfoAdd $_myPKGNAME_X11_CREATE $_myPKGVERS_X11_CREATE
_myPKGBASE_X11_CREATE="`dirname ${_myPKGNAME_X11_CREATE}`"


#FUNCBEG###############################################################
#NAME:
#  createConnectX11
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
function createConnectX11 () {
    printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE "${FUNCNAME}:$*"
    local OPMODE=$1;shift
    local ACTION=$1;shift

    local A;
    local KEY;
    local ARG;
    local i;
    local _notitle=1;

    case ${OPMODE} in
	CHECKPARAM)
            #
            #Just check syntax drafts, the expansion of labels etc. could just be
            #expanded on target machine.
            #
            if [ -n "$C_MODE_ARGS" ];then
                #guarantee unambiguity of EXOR: (label|l)  (fname|f)  (pname|p)
		local _unambig=0;
		local _unambigCON=0;

                printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE "C_MODE_ARGS=$C_MODE_ARGS"
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
                        -o "${KEY}" == "NOTITLE" \
                        -o "${KEY}" == "DH"  \
                        -o "${KEY}" == "SH"  \
                        \) \
			];then
			case $KEY in

			    SHELL|S)
                                local _shell="${ARG}";
 				printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE "SHELL=$_shell"
				;;
			    CMD)
                                local _cmd="${ARG}";
 				printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE "CMD=$_cmd"
				local _command=1;
				;;
			    CHDIR|CD)
                                local _chdir="${ARG}";
 				printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE "CHDIR=$_chdir"
				;;
			    DH)
                                local _dh=1;
 				printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE "DH=$_dh"
				;;
			    SH)
                                local _sh=1;
 				printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE "SH=$_sh"
				;;


                          #####################
                          # <call-arguments>  #
                          #####################
			    CALLOPTS|C)
				local _callopts="${ARG//\%/ }";
				printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE "CALLOPTS=${_callopts}"
				;;
			    XOPTS|X)
				local _xopts="${ARG//\%/ }";
				printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE "XTOOLKITOPTS=${_xopts}"
				;;
                          #####################
                          # <machine-address> #
                          #####################

			    LABEL|L)
				local _label="${ARG}";
 				printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE "LABEL=${_label}"
				let _unambig+=1;
				;;

                            STUBMODE|STUB)
				C_STUBCALL=1;
 				printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE "STUBMODE"
                                local _wrapper="${ARG// /}";
				case "$_wrapper" in
				    [oO][nN])C_NOWRAPPER=;
				esac
 				printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE "WRAPPER=${_wrapper:-OFF}"
				;;

                        ###########
			    NOTITLE)
				printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE "_notitle=${ARG}"
				;;

			    TITLEKEY)
				printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE "_titlekey=${ARG}"
				;;

			    CONSOLE)
				local _conty="`echo ${ARG}|tr '[:lower:]' '[:upper:]'`";
				case ${_conty} in
				    EMACSAM|EMACSA|EMACSM|EMACS|XTERM|GTERM)
#4TEST:OBSOLETE - TEMP REMINDER
# 					if [ "${C_CLIENTLOCATION}" ==  "-L CONNECTIONFORWARDING" ];then
# 					    ABORT=1;
# 					    printERR $LINENO $BASH_SOURCE ${ABORT} "\"CONNECTIONFORWARDING\" is not supported for ${_conty}"
#  					    gotoHell ${ABORT}
# 					fi
					if [ "${C_ASYNC}" == 0 ];then
					    if [ "${C_STACK}" == 1 ];then
						printINFO 2 $LINENO $BASH_SOURCE ${ABORT} "CONSOLE:${_conty} will be set to \"-b async,par\""
					    else
						printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "for ${_conty} the use of option \"-b 1\" is recommended"
					    fi
					fi
					;;
				    *)
					ABORT=1;
					printERR $LINENO $BASH_SOURCE ${ABORT} "Unsupported:${KEY}:${ARG}"
 					gotoHell ${ABORT}
					;;
				esac
				;;

			    *)
				ABORT=1;
				printERR $LINENO $BASH_SOURCE ${ABORT} "Unknown sub-opts for X11:${KEY}"
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

		if [ -n "$C_STUBCALL" ];then
		    case "${C_CLIENTLOCATION#-L }" in
			CONNECTIONFORWARDING|CF);;
			*)
			    case ${_conty} in
				EMACSAM|EMACSA|EMACSM|EMACS)
				    ABORT=1;
				    printERR $LINENO $BASH_SOURCE ${ABORT} "STUBMODE is not supported for CONSOLE:\"${_conty}\""
				    printERR $LINENO $BASH_SOURCE ${ABORT} "Use: GTERM|XTERM"
 				    gotoHell ${ABORT}
				    ;;
				*)
				    ;;
			    esac  
			    ;;
		    esac  
		fi
				

		if [ -n "$_dh" -a -n "$_sh" ];then
		    ABORT=1;
		    printERR $LINENO $BASH_SOURCE ${ABORT} "The suboptions DH and SH are EXOR."
 		    gotoHell ${ABORT}               
		fi

	    fi
            #Eas later procesing by simple key, else not really required.
	    if [ -z "${_label}" ];then
		ABORT=1;
		printERR $LINENO $_CLI_CREATE ${ABORT} "Missing mandatory parameter:\"LABEL\""
 		gotoHell ${ABORT}               
	    fi
            #Eas later procesing by simple key, else not really required.
	    if [ -n "${_console}" -a -n "${_command}" ];then
		ABORT=1;
		printERR $LINENO $_CLI_CREATE ${ABORT} "Command and console has to be used exclusive."
		printERR $LINENO $_CLI_CREATE ${ABORT} "When setting a X11 command include the console-\"frame\" in the call"
		printERR $LINENO $_CLI_CREATE ${ABORT} "_cmd=$_cmd"
		printERR $LINENO $_CLI_CREATE ${ABORT} "_conty=$_conty"
 		gotoHell ${ABORT}               
	    fi
	    ;;


	ASSEMBLE)
            case "${C_CLIENTLOCATION#-L }" in
		CONNECTIONFORWARDING|CF)
		    ${FUNCNAME} EXECUTE $ACTION 
		    ;;
		*)
		    if [ -z "$C_STUBCALL" ];then
			assembleExeccall 
		    else
			${FUNCNAME} EXECUTE $ACTION 
		    fi
		    ;;
	    esac
	    ;;

	PROPAGATE)
	    assembleExeccall PROPAGATE
	    ;;

	EXECUTE)
	    if [ -n "${R_TEXT}" ];then
		echo "${R_TEXT}"
	    fi
	    if [ -n "$C_MODE_ARGS" ];then
                #guarantee unambiguity of EXOR: (label|l)  (fname|f)  (pname|p)
		local _unambig=0;

                printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE "C_MODE_ARGS=$C_MODE_ARGS"
		A=`cliSplitSubOpts ${C_MODE_ARGS}`
		for i in $A;do
		    KEY=`cliGetKey ${i}`
		    ARG=`cliGetArg ${i}`
		    if [ -n "${ARG}" \
			-o -z "${ARG}" -a \( \
                        "${KEY}" == "DUMMY" \
                        -o "${KEY}" == "NOTITLE" \
                        -o "${KEY}" == "DH"  \
                        -o "${KEY}" == "SH"  \
                        \) \
			];then
			case $KEY in
			    SHELL|S)
#                                local _shell="${ARG}";
                                local _shell="${ARG//\%/ }";
 				printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE "SHELL=$_shell"
				;;
			    CMD)
                                local _cmd="${ARG}";
 				printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE "CMD=$_cmd"
				local _command=1;
				;;
			    CHDIR|CD)
                                local _chdir="${ARG}";
 				printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE "CHDIR=$_chdir"
				;;
			    DH)
                                local _dh="--";
 				printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE "DH=$_dh"
				;;
			    SH)
                                local _sh="-";
 				printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE "SH=$_sh"
				;;



                          #####################
                          # <call-arguments>  #
                          #####################
			    CALLOPTS|C)
				local _callopts="${ARG//\%/ }";
				printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE "CALLOPTS=${_callopts}"
                                C_SESSIONIDARGS="${_callopts}"
				;;
			    XOPTS|X)
				local _xopts="${ARG//\%/ }";
				printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE "XTOOLKITOPTS=${_xopts}"
                                C_XTOOLKITOPTS="${_xopts}"
				;;



                          #####################
                          # <machine-address> #
                          #####################
			    LABEL|L)
                                local _label="${ARG}";
 				printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE "LABEL=${_label}"
				;;

                            STUBMODE|STUB)
				C_STUBCALL=1;
 				printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE "STUBMODE"
                                local _wrapper="${ARG// /}";
				case "$_wrapper" in
				    [oO][nN])C_NOWRAPPER=;
				esac
 				printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE "WRAPPER=${_wrapper:-OFF}"
				;;

			    NOTITLE)
				_notitle=1;
				;;

			    TITLEKEY)
				local _titlekey="${ARG}";
				_notitle=;
				printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE "_titlekey=${ARG}"
				;;

			    CONSOLE)
				local _conty="`echo ${ARG}|tr '[:lower:]' '[:upper:]'`";
				_cmd=${_conty};

				case  ${_conty} in
				    EMACS)
					local _sh="-";
					_shell=;
					if [ -z "${X11EMACXEXE// /}" ];then 
					    ABORT=2;
					    printERR $LINENO $BASH_SOURCE ${ABORT} "Cannot find path for EMACS"
 					    gotoHell ${ABORT}
					fi
					;;
				    EMACSA)
					local _sh="-";
					_shell=;
					if [ -z "${X11EMACXEXE// /}" ];then 
					    ABORT=3;
					    printERR $LINENO $BASH_SOURCE ${ABORT} "Cannot find path for EMACS"
 					    gotoHell ${ABORT}
					fi
					;;
				    EMACSM)
					local _sh="-";
					_shell=;
					if [ -z "${X11EMACXEXE// /}" ];then 
					    ABORT=3;
					    printERR $LINENO $BASH_SOURCE ${ABORT} "Cannot find path for EMACS"
 					    gotoHell ${ABORT}
					fi
					;;
				    EMACSAM)
					local _sh="-";
					_shell=;
					if [ -z "${X11EMACXEXE// /}" ];then 
					    ABORT=3;
					    printERR $LINENO $BASH_SOURCE ${ABORT} "Cannot find path for EMACS"
 					    gotoHell ${ABORT}
					fi
					;;
				    XTERM)
					local _sh="-";
					_shell=${_shell:-$X11_XTERM_SHELL_DEFAULT}
					if [ -z "${X11XTERMEXE// /}" ];then 
					    ABORT=3;
					    printERR $LINENO $BASH_SOURCE ${ABORT} "Cannot find path for xterm"
 					    gotoHell ${ABORT}
					fi
					;;
				    GTERM)
					local _dh="--";
					_shell=${_shell:-$X11_XTERM_SHELL_DEFAULT}
					if [ -z "${X11GTERMEXE// /}" ];then 
					    ABORT=3;
					    printERR $LINENO $BASH_SOURCE ${ABORT} "Cannot find path for gnome-terminal"
 					    gotoHell ${ABORT}
					fi
					;;

				    *)
					ABORT=1;
					printERR $LINENO $BASH_SOURCE ${ABORT} "Unsupported: ${KEY}=${ARG}"
 					gotoHell ${ABORT}
					;;
				esac
				printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE "CONSOLE=${ARG}"
				printDBG $S_X11 ${D_BULK} $LINENO $BASH_SOURCE "_shell=${_shell}"
				local _console=1;
				;;

			    *)
				ABORT=1;
				printERR $LINENO $BASH_SOURCE ${ABORT} "Unexpected sub-opts for X11:${KEY}"
 				gotoHell ${ABORT}
				;;
			esac
		    fi
		done
		printDBG $S_X11 ${D_MAINT} $LINENO $BASH_SOURCE "CombineParamaters"
	    else
		local stripDummy=;
		printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE "No user supplied parameters - set defaults"
	    fi

            #set correct hypen count for x-legacy and modern WM.
            #but anyhow, some are still intermixed, e.g. "-e" and "-x" option
	    _xp=${_dh:-$_sh}
	    _xp=${_xp:-$X11_WM_OPTPRE}
	    printDBG $S_X11 ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_xp=\"${_xp}\" _sh=\"${_sh}\" _dh=\"${_dh}\""

            if [ -n "${_notitle}" -a -z "${_titlekey}" ];then
		_label=NOTITLE
	    fi

            if [ -z "${_label}" ];then
                _label="DEFAULT-${DATETIME}"
            fi

            case "${C_CLIENTLOCATION#-L }" in
		LOCALONLY|DISPLAYFORWARDING)
		    printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE "startSessionX11 \"${_label}\""
		    printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE " ->\"${_label}\""
		    printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE " ->\"${_cmd}\""
		    printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE " ->\"${_shell}\""
		    printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE " ->\"${_callopts}\""
		    printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE " ->\"${_xopts}\""
		    printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE " ->\"${_titlekey}\""
		    printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE " ->\"${_chdir}\""
                    startSessionX11 "${_label}"  "${_cmd}" "${_shell}" "${_callopts}" "${_xopts}" "${_titlekey}" "${_chdir}"
		    gotoHell 0
		    ;;

		CONNECTIONFORWARDING)
		    printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE "startSessionX11 \"${_label}\""
		    printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE " ->\"${_label}\""
		    printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE " ->\"${_cmd}\""
		    printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE " ->\"${_shell}\""
		    printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE " ->\"${_callopts}\""
		    printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE " ->\"${_xopts}\""
		    printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE " ->\"${_titlekey}\""
		    printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE " ->\"${_chdir}\""

		    hookPackage CLI
		    hookInitPropagate4Package CLI

		    if [ -z "$C_STUBCALL" ];then
			_shell="${MYLIBEXECPATH}/ctys -t cli -a create=l:${_label} $R_HOSTS"
		    else
			_shell=;
			_shell="${_shell} -t CLI -a create=l:${_label}"
			if [ -n "$C_STUBCALL" ];then
			    _shell="${_shell},STUB"
			    if [ -z "$C_NOWRAPPER" ];then
				_shell="${_shell}:on"
			    fi
			fi
			_shell="${MYLIBEXECPATH}/ctys.sh ${_shell} $R_HOSTS"
			printDBG $S_XEN ${D_FLOW} $LINENO $BASH_SOURCE "_shell=${_shell}"
		    fi
                    startSessionX11 "${_label}"  "${_cmd}" "${_shell}" "${_callopts}" "${_xopts}" "${_titlekey}" "${_chdir}"
		    gotoHell 0
		    ;;

		*)
		    ABORT=1
		    printERR $LINENO $BASH_SOURCE ${ABORT} "Execution locality error:${C_CLIENTLOCATION}"
		    gotoHell ${ABORT}
		    ;;
	    esac
	    ;;
    esac

}