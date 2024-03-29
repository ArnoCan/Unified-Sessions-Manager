#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@users.sourceforge.net
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

_myPKGNAME_XEN_CREATE="${BASH_SOURCE}"
_myPKGVERS_XEN_CREATE="01.11.011"
hookInfoAdd $_myPKGNAME_XEN_CREATE $_myPKGVERS_XEN_CREATE
_myPKGBASE_XEN_CREATE="`dirname ${_myPKGNAME_XEN_CREATE}`"

#specifies a record index
export DBREC=;


#FUNCBEG###############################################################
#NAME:
#  createConnectXEN
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Creates a session and/or connects to the server.
#
#EXAMPLE:
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function createConnectXEN () {
    printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE "${FUNCNAME}:$*"
    local OPMODE=$1;shift
    local ACTION=$1;shift

    local A;
    local KEY;
    local ARG;
    local _pname=;
    local _ret=0;

    local _consoleType=${XEN_CONSOLE_DEFAULT:-NONE};
    local _bootmode=VHDD;
    local _instmode=;

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

		printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "C_MODE_ARGS=$C_MODE_ARGS"
		A=`cliSplitSubOpts ${C_MODE_ARGS}`
		for i in $A;do
		    KEY=`cliGetKey ${i}`
		    ARG=`cliGetArg ${i}`
                    if [ -n "${ARG}" \
			-o -z "${ARG}" -a "${KEY}" == "REUSE" \
			-o -z "${ARG}" -a "${KEY}" == "RECONNECT" \
			-o -z "${ARG}" -a "${KEY}" == "CONNECT" \
			-o -z "${ARG}" -a "${KEY}" == "RESUME" \
			-o -z "${ARG}" -a "${KEY}" == "INSTMODE" \
			];then
			case $KEY in
			    CONNECT)
				let _unambigCON+=1;
				local _connect=1;
				printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "CONNECT"
				if [ -n "${ARG}" ]; then
				    ABORT=1;
				    printERR $LINENO $BASH_SOURCE ${ABORT} "No arguments are supported for \"$KEY\""
 				    gotoHell ${ABORT}
				fi
				;;
			    REUSE)
				let _unambigCON+=1;
				local _reuse=1;
				printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "REUSE"
				if [ -n "${ARG}" ]; then
				    ABORT=1;
				    printERR $LINENO $BASH_SOURCE ${ABORT} "No arguments are supported for \"$KEY\""
 				    gotoHell ${ABORT}
				fi
				;;
			    RECONNECT)
				local _reuse=1;
				local _reconnect=1;
				let _unambigCON+=1;
				printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "RECONNECT"
				if [ -n "${ARG}" ]; then
				    ABORT=1;
				    printERR $LINENO $BASH_SOURCE ${ABORT} "No arguments are supported for \"$KEY\""
 				    gotoHell ${ABORT}
				fi
				;;
			    RESUME)
				local _resume=1;
				let _unambigCON+=1;
				printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "RESUME"
				if [ -n "${ARG}" ]; then
				    ABORT=1;
				    printERR $LINENO $BASH_SOURCE ${ABORT} "No arguments are supported for \"$KEY\""
 				    gotoHell ${ABORT}
				fi
				;;
                     #####################
                     # <machine-address> #
                     #####################
			    DBRECORD|DBREC|DR)
				local DBREC="${ARG}";
				printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "DBRECORD=${DBREC}"
				local _idgiven=1;
				;;
			    BASEPATH|BASE|B)
				local _base="${ARG}";
				printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "BASE=${_base}"
				;;
			    TCP|T)
				local _tcp="${ARG}";
				printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "TCP=${_tcp}"
				let _unambig+=1;
				;;
			    MAC|M)
				local _mac="${ARG}";
				printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "MAC=${_mac}"
				let _unambig+=1;
				;;
			    UUID|U)
				local _uuid="${ARG}";
 				printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "UUID=${_uuid}"
				let _unambig+=1;
				;;
			    LABEL|L)
				local _label="${ARG}";
 				printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "LABEL=${_label}"
				let _unambig+=1;
				;;
			    FILENAME|FNAME|F)
				local _fname="${ARG}";
				printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "FILENAME=${_fname}"
				let _unambig++;
				;;
			    ID|I|PATHNAME|PNAME|P)
				local _ta="${ARG//\\}"
				if [ -n "${_ta##/*}" ]; then
				    ABORT=1;
				    printERR $LINENO $BASH_SOURCE ${ABORT} "PNAME has to be an absolute path, use fname else."
				    printERR $LINENO $BASH_SOURCE ${ABORT} " PNAME=${ARG}"
 				    gotoHell ${ABORT}
				fi
				local _idgiven=1;
				printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "PATHNAME=${ARG}"
				;;

                     #######################
                     # Specific attributes #  
                     #######################
			    CALLOPTS|C)
				local _callopts="${ARG//\%/ }";
				printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "CALLOPTS=${_callopts}"
				;;
			    XOPTS|X)
				local _xopts="${ARG//\%/ }";
				printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "XTOOLKITOPTS=${_xopts}"
				;;

                        ###########
			    CONSOLE)
				local _conty="`echo ${ARG}|tr '[:lower:]' '[:upper:]'`";
				case ${_conty} in
				    CLI)
					C_ASYNC=0
					if [ "${C_CLIENTLOCATION}" ==  "-L CONNECTIONFORWARDING" ];then
					    ABORT=1;
					    printERR $LINENO $BASH_SOURCE ${ABORT} "\"CONNECTIONFORWARDING\" is not supported for ${_conty}"
 					    gotoHell ${ABORT}
					fi
					printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "Interactive call, force: \"-b 0,2\""
 					printDBG $S_CLI ${D_UID} $LINENO $BASH_SOURCE "Interactive call, force:"
 					printDBG $S_CLI ${D_UID} $LINENO $BASH_SOURCE "C_PARALLEL=0"
 					printDBG $S_CLI ${D_UID} $LINENO $BASH_SOURCE "C_ASYNC=0"
					C_PARALLEL=0;
					C_ASYNC=0;
					printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "C_SSH_PSEUDOTTY=${C_SSH_PSEUDOTTY}"
					if [ "$C_SSH_PSEUDOTTY" == 0 ];then
					    C_SSH_PSEUDOTTY=2;
					    printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "Set forced PTY"
					    printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "Set forced PTY"
					fi
					;;
				    XTERM|GTERM|EMACS|EMACSA|EMACSM|EMACSAM)
					if [ "${C_CLIENTLOCATION}" ==  "-L CONNECTIONFORWARDING" ];then
					    ABORT=1;
					    printERR $LINENO $BASH_SOURCE ${ABORT} "\"CONNECTIONFORWARDING\" is not supported for ${_conty}"
 					    gotoHell ${ABORT}
					fi
					if [ "${C_ASYNC}" == 0 -a "${C_STACK}" != 0 ];then
					    printWNG 2 $LINENO $BASH_SOURCE 1 "for ${_conty} the use of option \"-b 1\" is recommended"
					fi
					;;
				    VNC)
					;;
				    SDL)
					;;
				    NONE)
					C_CLIENTLOCATION="-L SERVERONLY";
					;;
				    *)
					ABORT=1;
					printERR $LINENO $BASH_SOURCE ${ABORT} "UNKNOWN ARG=${ARG}"
 					gotoHell ${ABORT}
					;;				  
				esac
				if [ -n "${_console}" ];then
				    ABORT=1;
				    printERR $LINENO $BASH_SOURCE ${ABORT} "CONSOLE has to be unique."
 				    gotoHell ${ABORT}
				fi
				printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "CONSOLE=${ARG}"
				local _console=$_conty;
				;;
			    BOOTMODE)
				_bootmode="${ARG//\%/ }";
				case ${_bootmode} in
				    CD);;
				    FDD);;
				    USB);;
				    ISO);;
				    KERNEL);;
				    PXE);;
				    VHDD);;
				    INSTALL);;
				    *)
					ABORT=1;
					printERR $LINENO $BASH_SOURCE ${ABORT} "Unsupported BOOTMODE=${_bootmode}"
 					gotoHell ${ABORT}
					;;
				esac
				printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "BOOTMODE=${_bootmode}"
				;;

			    INSTMODE)
				_instmode="${ARG}";
				local _cx="${ARG%% *}";
				_cx="`echo ${_cx}|tr '[:lower:]' '[:upper:]'`";
				case ${_cx} in
				    CD);;
				    DVD);;
#				    FDD);;
#				    HDD);;
#				    USB);;
#				    VHDD);;
				    PXE);;
				    KS);;
				    '')_instmode=CONFIG;;
				    *)
					ABORT=1;
					printERR $LINENO $BASH_SOURCE ${ABORT} "Unsupported INSTMODE=${_instmode}"
 					gotoHell ${ABORT}
					;;
				esac
				printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "BOOTMODE=${_instmode}"
				;;

			    PING)
				if [ -z "${ARG}" ];then
				    ABORT=1;
				    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing arguments:$KEY"
 				    gotoHell ${ABORT}
				fi
				case "${ARG}" in
				    OFF)_pingXEN=0;;
				    *)
					if [ "${ARG//\%/}" == "${ARG}"  ];then
					    ABORT=1;
					    printERR $LINENO $BASH_SOURCE ${ABORT} "Both are mandatory:<#cnt>+<sleep>"
 					    gotoHell ${ABORT}
					fi
					_pingcntXEN=${ARG%\%*};
					if [ -n "${_pingcntXEN//[0-9]/}" ];then
					    ABORT=1;
					    printERR $LINENO $BASH_SOURCE ${ABORT} "Non-Numertic:<#pingcnt>=$_pingcntXEN"
 					    gotoHell ${ABORT}
					fi
					_pingsleepXEN=${ARG#*\%};
					if [ -n "${_pingsleepXEN//[0-9]/}" ];then
					    ABORT=1;
					    printERR $LINENO $BASH_SOURCE ${ABORT} "Non-Numertic:<pingsleep>=$_pingsleepXEN"
 					    gotoHell ${ABORT}
					fi
					;;
				esac
				printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "PING     =${_pingXEN}"
				printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "PINGCNT  =${_pingcntXEN}"
				printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "PINGSLEEP=${_pingsleepXEN}"
				;;

			    SSHPING)
				if [ -z "${ARG}" ];then
				    ABORT=1;
				    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing arguments:$KEY"
 				    gotoHell ${ABORT}
				fi
				case "${ARG}" in
				    OFF)_sshpingXEN=0;;
				    *)
					if [ "${ARG//\%/}" == "${ARG}"  ];then
					    ABORT=1;
					    printERR $LINENO $BASH_SOURCE ${ABORT} "Both are mandatory:<#cnt>+<sleep>"
 					    gotoHell ${ABORT}
					fi
					_sshpingcntXEN=${ARG%\%*};
					if [ -n "${_sshpingcntXEN//[0-9]/}" ];then
					    ABORT=1;
					    printERR $LINENO $BASH_SOURCE ${ABORT} "Non-Numertic:<#sshpingcnt>=$_sshpingcntXEN"
 					    gotoHell ${ABORT}
					fi
					_sshpingsleepXEN=${ARG#*\%};
					if [ -n "${_sshpingsleepXEN//[0-9]/}" ];then
					    ABORT=1;
					    printERR $LINENO $BASH_SOURCE ${ABORT} "Non-Numertic:<sshpingsleep>=$_sshpingsleepXEN"
 					    gotoHell ${ABORT}
					fi
					;;
				esac
				printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "SSHPING     =${_sshpingXEN}"
				printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "SSHPINGCNT  =${_sshpingcntXEN}"
				printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "SSHPINGSLEEP=${_sshpingsleepXEN}"
				;;

			    USER)
				if [ -z "${ARG}" ];then
				    ABORT=1;
				    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing arguments:$KEY"
 				    gotoHell ${ABORT}
				fi
				_actionuserXEN="${ARG}";
				printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "ACTION-USER=${_actionuserXEN}"
				;;

			    WAITC)
				if [ -z "${ARG}" ];then
				    ABORT=1;
				    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing arguments:$KEY"
 				    gotoHell ${ABORT}
				fi
				case "${ARG}" in
				    *)
					_waitcXEN=${ARG};
					if [ -n "${_waitcXEN//[0-9]/}" ];then
					    ABORT=1;
					    printERR $LINENO $BASH_SOURCE ${ABORT} "Non-Numeric $KEY:$_waitcXEN"
 					    gotoHell ${ABORT}
					fi
					;;
				esac
				printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "WAITC =${_waitcXEN}"
				;;

			    WAITS)
				if [ -z "${ARG}" ];then
				    ABORT=1;
				    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing arguments:$KEY"
 				    gotoHell ${ABORT}
				fi
				case "${ARG}" in
				    *)
					_waitsXEN=${ARG};
					if [ -n "${_waitsXEN//[0-9]/}" ];then
					    ABORT=1;
					    printERR $LINENO $BASH_SOURCE ${ABORT} "Non-Numeric $KEY:$_waitsXEN"
 					    gotoHell ${ABORT}
					fi
					;;
				esac
				printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "WAITS =${_waitsXEN}"
				;;

			    STACKCHECK)
				if [ -z "${ARG}" ];then
				    ABORT=1;
				    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing arguments:$KEY"
 				    gotoHell ${ABORT}
				fi
				local _si=;
				for _si in "${ARG//%/ }";do
				    case "${_si}" in
					CONTEXT|NOCONTEXT);;
					HWCAP|NOHWCAP);;
					STACKCAP|NOSTACKCAP);;
					OFF);;
					*)
					    ABORT=1;
					    printERR $LINENO $BASH_SOURCE ${ABORT} "Unknown argument to ${KEY}:${_si}"
 					    gotoHell ${ABORT}
					    ;;
				    esac
				done
				;;

			    *)
				ABORT=1;
				printERR $LINENO $BASH_SOURCE ${ABORT} "Unknown sub-opts for XEN:${KEY}"
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
		if [ "${_unambigCON}" -gt 1 ];then
		    ABORT=1;
		    printERR $LINENO $BASH_SOURCE ${ABORT} "Choose one of the following sub-options:"
		    printERR $LINENO $BASH_SOURCE ${ABORT} "  CONNECT | RECONNECT |REUSE | RESUME"
 		    gotoHell ${ABORT}
		fi
            fi
            if((_unambig==0&&_idgiven!=1));then
		ABORT=1;
		printERR $LINENO $BASH_SOURCE ${ABORT} "Missing parameter for target entity of action($_unambig/$_idgiven)"
 		gotoHell ${ABORT}
            fi


	    if [ -n "${DBREC}" -a -z "${_pname}" ];then
		if [ -n "${_base}" -o -n "${_tcp}" -o -n "${_mac}" -o -n "${_uuid}" \
                    -o -n "${_label}" -o -n "${_fname}" -o -n "${_pname}" ];then
		    printWNG 1 $LINENO $BASH_SOURCE 1 "The provided DB index has priority for address"
		    printWNG 1 $LINENO $BASH_SOURCE 1 "if matched the remeining address parameters are ignored"
		fi
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
	    printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "C_MODE_ARGS=$C_MODE_ARGS"
	    A=`cliSplitSubOpts ${C_MODE_ARGS}`
	    for i in $A;do
		KEY=`cliGetKey ${i}`
		ARG=`cliGetArg ${i}`
		if [ -n "${ARG}" \
		    -o -z "${ARG}" -a "${KEY}" == "REUSE" \
		    -o -z "${ARG}" -a "${KEY}" == "RECONNECT" \
  		    -o -z "${ARG}" -a "${KEY}" == "CONNECT" \
		    -o -z "${ARG}" -a "${KEY}" == "RESUME" \
		    -o -z "${ARG}" -a "${KEY}" == "INSTMODE" \
		    ];then
		    case $KEY in
 			CONNECT)
                            local _connect=1;
			    printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "CONNECT=>requires server running"
			    ;;
 			REUSE)
                            local _reuse=1;
			    printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "REUSE=>try CONNECT before CREATE"
			    ;;
			RECONNECT)
                            local _reuse=1;
                            local _reconnect=1;
			    printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "RECONNECT=>CANCEL running clients first"
			    ;;
			RESUME)
			    local _resume=1;
			    printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "RESUME"
			    ;;
                     #####################
                     # <machine-address> #
                     #####################
			DBRECORD|DBREC|DR)
			    local DBREC="${ARG}";
			    printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "DBRECORD=${DBREC}"
			    local _idgiven=1;
			    ;;
			BASEPATH|BASE|B)
                            #can be checked now
                            local _base="${ARG}";
			    printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "BASE=${_base}"

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
			    printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "TCP=${_tcp}"
			    ;;
			MAC|M)
			    local _mac="${ARG}";
			    printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "MAC=${_mac}"
			    ;;
			UUID|U)
                            #has to be checked later
			    local _uuid="${ARG}";
 			    printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "UUID=${_uuid}"
			    ;;
			LABEL|L)
                            #has to be checked later due to probable following base-prefix
                            local _label="${ARG}";
 			    printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "LABEL=${_label}"
			    ;;
			FILENAME|FNAME|F)
                            #has to be checked later due to probable following base-prefix
                            local _fname="${ARG}";
			    printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "FILENAME=${_fname}"
			    ;;
			ID|PATHNAME|PNAME|P)
                            #can be checked now, no additional combination check required 
                            #due to previous CHECKPARAM.
			    local _ta="${ARG//\\}"
                            if [ ! -f "${_ta}" ];then
				ABORT=1;
				printERR $LINENO $BASH_SOURCE ${ABORT} "Missing given file or access permission for ID/PNAME"
				printERR $LINENO $BASH_SOURCE ${ABORT} "  ID=${ARG}"
 				gotoHell ${ABORT}
                            fi
                            local _pname="${_ta}";
			    printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "PATHNAME=${_pname}"
			    ;;
			CALLOPTS|C)
                            #trust the user for now, and let the target call check it
			    local _callopts="${ARG//\%/ }";
			    printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "CALLOPTS=${_callopts}"
                            C_SESSIONIDARGS="${_callopts}"
			    ;;
			XOPTS|X)
                            #trust the user for now, and let the target call check it
			    local _xopts="${ARG//\%/ }";
			    printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "XTOOLKITOPTS=${_xopts}"
                            C_XTOOLKITOPTS="${_xopts}"
			    ;;
			CONSOLE)
			    local _conty="`echo ${ARG}|tr '[:lower:]' '[:upper:]'`";
			    case  ${_conty} in
				CLI|XTERM|GTERM|EMACS|EMACSA|EMACSM|EMACSAM)
				    _consoleType=${_conty};
				    ;;
				VNC)_consoleType=${_conty};;
				SDL)_consoleType=${_conty};;
				NONE)_consoleType=${_conty};
				    C_CLIENTLOCATION="-L SERVERONLY";
				    ;;
				*)
				    ABORT=1;
				    printERR $LINENO $BASH_SOURCE ${ABORT} "UNKNOWN ARG=${ARG}"
 				    gotoHell ${ABORT}
				    ;;
			    esac
			    printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "CONSOLE=${ARG}"
			    local _console=1;
			    ;;
			BOOTMODE)
			    _bootmode="${ARG//\%/ }";
			    case ${_bootmode} in
				CD)_bootmode=cd;;
				FDD)_bootmode=fdd;;
				USB)_bootmode=usb;;
				ISO)_bootmode=iso;;
				KERNEL)_bootmode=kernel;;
				PXE)_bootmode=pxe;;
				VHDD)_bootmode=;;
				INSTALL)_bootmode=inst;;
				*)
				    ABORT=1;
				    printERR $LINENO $BASH_SOURCE ${ABORT} "Unsupported BOOTMODE=${_bootmode}"
 				    gotoHell ${ABORT}
				    ;;
			    esac
			    printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "BOOTMODE=${_bootmode}"
			    ;;

			INSTMODE)
			    _instmode="${ARG}";
			    local _cx="${ARG%% *}";
			    _cx="`echo ${_cx}|tr '[:lower:]' '[:upper:]'`";
			    case ${_cx} in
				CD);;
				DVD);;
#				FDD);;
#				HDD);;
#				USB);;
#				VHDD);;
				PXE);;
				KS);;
				'')_instmode=CONFIG;;
				*)
				    ABORT=1;
				    printERR $LINENO $BASH_SOURCE ${ABORT} "Unsupported INSTMODE=${_instmode}"
 				    gotoHell ${ABORT}
				    ;;
			    esac
			    _instmode="${_instmode// /%}";
			    printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "INSTMODE=${_instmode}"
			    ;;

			PING)
			    if [ -z "${ARG}" ];then
				ABORT=1;
				printERR $LINENO $BASH_SOURCE ${ABORT} "Missing arguments:$KEY"
 				gotoHell ${ABORT}
			    fi
			    case "${ARG}" in
				OFF)_pingXEN=0;;
				*)
				    if [ "${ARG//\%/}" == "${ARG}"  ];then
					ABORT=1;
					printERR $LINENO $BASH_SOURCE ${ABORT} "Both are mandatory:<#cnt>+<sleep>"
 					gotoHell ${ABORT}
				    fi
				    _pingcntXEN=${ARG%\%*};
				    if [ -n "${_pingcntXEN//[0-9]/}" ];then
					ABORT=1;
					printERR $LINENO $BASH_SOURCE ${ABORT} "Non-Numertic:<#pingcnt>=$_pingcntXEN"
 					gotoHell ${ABORT}
				    fi
				    _pingsleepXEN=${ARG#*\%};
				    if [ -n "${_pingsleepXEN//[0-9]/}" ];then
					ABORT=1;
					printERR $LINENO $BASH_SOURCE ${ABORT} "Non-Numertic:<pingsleep>=$_pingsleepXEN"
 					gotoHell ${ABORT}
				    fi
				    ;;
			    esac
			    printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "PING     =${_pingXEN}"
			    printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "PINGCNT  =${_pingcntXEN}"
			    printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "PINGSLEEP=${_pingsleepXEN}"
			    ;;

			SSHPING)
			    if [ -z "${ARG}" ];then
				ABORT=1;
				printERR $LINENO $BASH_SOURCE ${ABORT} "Missing arguments:$KEY"
 				gotoHell ${ABORT}
			    fi
			    case "${ARG}" in
				OFF)_sshpingXEN=0;;
				*)
				    if [ "${ARG//\%/}" == "${ARG}"  ];then
					ABORT=1;
					printERR $LINENO $BASH_SOURCE ${ABORT} "Both are mandatory:<#cnt>+<sleep>"
 					gotoHell ${ABORT}
				    fi
				    _sshpingcntXEN=${ARG%\%*};
				    if [ -n "${_sshpingcntXEN//[0-9]/}" ];then
					ABORT=1;
					printERR $LINENO $BASH_SOURCE ${ABORT} "Non-Numertic:<#sshpingcnt>=$_sshpingcntXEN"
 					gotoHell ${ABORT}
				    fi
				    _sshpingsleepXEN=${ARG#*\%};
				    if [ -n "${_sshpingsleepXEN//[0-9]/}" ];then
					ABORT=1;
					printERR $LINENO $BASH_SOURCE ${ABORT} "Non-Numertic:<sshpingsleep>=$_sshpingsleepXEN"
 					gotoHell ${ABORT}
				    fi
				    ;;
			    esac
			    printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "SSHPING     =${_sshpingXEN}"
			    printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "SSHPINGCNT  =${_sshpingcntXEN}"
			    printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "SSHPINGSLEEP=${_sshpingsleepXEN}"
			    ;;

			USER)
			    if [ -z "${ARG}" ];then
				ABORT=1;
				printERR $LINENO $BASH_SOURCE ${ABORT} "Missing arguments:$KEY"
 				gotoHell ${ABORT}
			    fi
			    _actionuserXEN="${ARG}";
			    printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "ACTION-USER=${_actionuserXEN}"
			    ;;

			WAITC)
			    if [ -z "${ARG}" ];then
				ABORT=1;
				printERR $LINENO $BASH_SOURCE ${ABORT} "Missing arguments:$KEY"
 				gotoHell ${ABORT}
			    fi
			    case "${ARG}" in
				*)
				    _waitcXEN=${ARG};
				    if [ -n "${_waitcXEN//[0-9]/}" ];then
					ABORT=1;
					printERR $LINENO $BASH_SOURCE ${ABORT} "Non-Numeric $KEY:$_waitcXEN"
 					gotoHell ${ABORT}
				    fi
				    ;;
			    esac
			    printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "WAITC =${_waitcXEN}"
			    ;;

			WAITS)
			    if [ -z "${ARG}" ];then
				ABORT=1;
				printERR $LINENO $BASH_SOURCE ${ABORT} "Missing arguments:$KEY"
 				gotoHell ${ABORT}
			    fi
			    case "${ARG}" in
				*)
				    _waitsXEN=${ARG};
				    if [ -n "${_waitsXEN//[0-9]/}" ];then
					ABORT=1;
					printERR $LINENO $BASH_SOURCE ${ABORT} "Non-Numeric $KEY:$_waitsXEN"
 					gotoHell ${ABORT}
				    fi
				    ;;
			    esac
			    printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "WAITC =${_waitsXEN}"
			    ;;

			STACKCHECK)
			    if [ -z "${ARG}" ];then
				ABORT=1;
				printERR $LINENO $BASH_SOURCE ${ABORT} "Missing arguments:$KEY"
 				gotoHell ${ABORT}
			    fi
			    local _si=;
			    for _si in "${ARG//%/ }";do
				case "${_si}" in
				    CONTEXT|NOCONTEXT);;
				    HWCAP|NOHWCAP);;
				    STACKCAP|NOSTACKCAP);;
				    OFF);;
				    *)
					ABORT=1;
					printERR $LINENO $BASH_SOURCE ${ABORT} "Unknown argument to ${KEY}:${_si}"
 					gotoHell ${ABORT}
					;;
				esac
			    done
			    ;;

			*)
			    ABORT=1;
			    printERR $LINENO $BASH_SOURCE ${ABORT} "Unexpected sub-opts for XEN:${KEY}"
 			    gotoHell ${ABORT}
			    ;;
		    esac
		fi
	    done

            if [ -z "${_pname}" -a "${C_NSCACHEONLY}" == 1 -a "${C_NSCACHELOCATE}" == 0 ];then
		ABORT=1;
		printERR $LINENO $BASH_SOURCE ${ABORT} "Missing PNAME, required from client due to \"-c LOCAL,ONLY...\""
 		gotoHell ${ABORT}
	    fi

	    case "${_conty}" in
		CLI|XTERM|GTERM|EMACS|EMACSA|EMACSM|EMACSAM)
		    if [ "${C_CLIENTLOCATION//CONNECTIONFORWARDING}" != "${C_CLIENTLOCATION}" ];then
			ABORT=1;
			printERR $LINENO $BASH_SOURCE ${ABORT} "\"CONNECTIONFORWARDING\" is not supported for ${_conty}"
 			gotoHell ${ABORT}
		    fi
		    ;;
	    esac

	    #
	    #find the correct db entry
	    #
 	    local _targetHost=${R_HOSTS#*@};
 	    _targetHost=${_targetHost%%[({\'\"]*};
	    if [ -z "${_actionuserQEMU}" ];then
		    _actionuserQEMU="${R_HOSTS%%@*}";
		    if [ "${R_HOSTS}" == "${_actionuserQEMU}" ];then
			_actionuserQEMU="${MYUID}";
		    fi
	    fi

            #
            #0. Try cache - DB-INDEX
            #
            if [ -z "${_pname// /}" -a -n "${DBREC// /}" ];then
		printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "PNAME-EVALUATE-CACHE-DBINDEX"
		local _VHOST="${MYLIBEXECPATH}/ctys-vhost.sh ${C_DARGS} -o PNAME -p ${DBPATHLST} -s "
		_pname=`${_VHOST} R:${DBREC}`
		if [ $? -ne 0 ];then
		    ABORT=1;
		    printERR $LINENO $BASH_SOURCE ${ABORT} "Cannot fetch indexed DB-RECORD:${DBREC}"
 		    gotoHell ${ABORT}
		fi
	    fi
            #
            #1. Try cache
            #
            if [ -z "${_pname// /}" ];then
		printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "PNAME-EVALUATE-CACHE"
		_call="cacheGetUniquePname \"${_base}\" \"${_targetHost}\" XEN ${_pname} ${_tcp} ${_mac} ${_uuid} ${_label} ${_fname} ${_actionuserQEMU} "
		printFINALCALL 1  $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${_call}"
		_pnameX=$(eval ${_call} )

		if [ $? -ne 0 ];then
		    ABORT=1;
		    printERR $LINENO $BASH_SOURCE ${ABORT} "Cannot fetch unique pathname"
 		    gotoHell ${ABORT}
		fi
	    fi

            #
            #2. Use filesystem
            #   This does an requires a UNIQUE match only.
            #
	    local _stime=`getCurTime`;
            if [ -z "${_pname// /}" ];then
		if [ "${C_NSCACHEONLY}" == 0 ];then
		    printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "PNAME-EVALUATE-RUNTIME-SYSTEM"

		    printINFO 1 $LINENO $BASH_SOURCE 0 "($_stime):No CACHE hit by \"ctys-vhost.sh\", scanning filesystem now."
		    printINFO 2 $LINENO $BASH_SOURCE 0 "Update your database with \"ctys-vdbgen.sh\"."

		    hookPackage "${_myPKGBASE_XEN}/config.sh"
		    hookPackage "${_myPKGBASE_XEN}/enumerate.sh"

                    #starts in $HOME
                    _base=${_base:-$HOME}

		    if [ -n "${_fname}" ];then
                        #fname 
			_pname=`enumerateMySessionsXEN ${_base}|awk -F';' -v d="${_fname}" '
                                BEGIN{firstX="";};$3~d{if(!firstX)firstX=$3;};END{print firstX}'`
			printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "_pname=${_pname}"
		    else
			if [ -n "${_uuid}" ];then
                            #UUID to be "grepped" from vmx-files
			    _pname=`enumerateMySessionsXEN ${_base}|awk -F';' -v d="${_uuid}" '
                                    BEGIN{firstX="";};$4~d{if(!firstX)firstX=$3;};END{print firstX}'`
			    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "_pname=${_pname}"
			else
			    if [ -n "${_label}" ];then
                                #displayName to be "grepped" from vmx-files
		 		_pname=`enumerateMySessionsXEN ${_base}|awk -F';' -v d="${_label}" '
                                        BEGIN{firstX="";};$2~d{if(!firstX)firstX=$3;};END{print firstX}'`
				printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "_pname=${_pname}"
			    else
				if [ -n "${_tcp}" ];then
                                    #displayName to be "grepped" from vmx-files
				    _pname=`enumerateMySessionsXEN ${_base}|awk -F';' -v d="${_tcp}" '
                                            BEGIN{firstX="";};$10~d{if(!firstX)firstX=$3;};END{print firstX}'`
				    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "_pname=${_pname}"
				else
	 			    if [ -n "${_mac}" ];then
                                        #displayName to be "grepped" from vmx-files
					_pname=`enumerateMySessionsXEN ${_base}|awk -F';' -v d="${_mac}" '
                                                BEGIN{firstX="";};$5~d{if(!firstX)firstX=$3;};END{print firstX}'`
					printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "_pname=${_pname}"

				    else
                                        #has to be a relative vmx-file name, the absolute path has to be found
					_pname=`enumerateMySessionsXEN ${_base}|awk -F';' -v d="${_fname}" '
                                                BEGIN{firstX="";};$3~d{if(!firstX)firstX=$3;};END{print firstX}'`
					_label=${_pname//:*}
					_pname=${_pname//*:}
					printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "_pname=${_pname}"
				    fi
				fi
			    fi
			fi
		    fi
		fi
		local _etime=`getCurTime`;
		local _dtime=`getDiffTime $_stime $_etime`;

                #should have find one
		if [ -z "${_pname// /}" ];then
		    _ret=1;
 		    printERR $LINENO $BASH_SOURCE ${_ret} "($_etime):Cannot evaluate ID/PNAME, input seems to be erroneous  =>${_dtime}"
 		    printERR $LINENO $BASH_SOURCE ${_ret} "  BASE            = ${_base}"
 		    printERR $LINENO $BASH_SOURCE ${_ret} "  LABEL           = ${_label}"
 		    printERR $LINENO $BASH_SOURCE ${_ret} "  UUID            = ${_uuid}"
 		    printERR $LINENO $BASH_SOURCE ${_ret} "  MAC             = ${_mac}"
 		    printERR $LINENO $BASH_SOURCE ${_ret} "  TCP             = ${_tcp}"
 		    printERR $LINENO $BASH_SOURCE ${_ret} "  FILENAME        = ${_fname}"
 		    printERR $LINENO $BASH_SOURCE ${_ret} "  R_HOSTS         = ${R_HOSTS}"
 		    printERR $LINENO $BASH_SOURCE ${_ret} "  MYHOST          = ${MYHOST}"
 		    printERR $LINENO $BASH_SOURCE ${_ret} "  _targetHost     = ${_targetHost}"
 		    printERR $LINENO $BASH_SOURCE ${_ret} "  _actionuserQEMU = ${_actionuserQEMU}"
		    gotoHell ${_ret};
		else
		    printINFO 1 $LINENO $BASH_SOURCE 0 "($_etime):FILE-MATCH:\"${_pname}\" =>${_dtime}"
		fi
	    else
	 	printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "use _pname=${_pname}"
	    fi

            #####
            #do some validation and postprocessing
            #####

            #Make it absolute, if not yet.
            #If relative, it could just result from a "find $HOME ..."
            if [ -n "${_pname##/*}" ]; then
		_pname=${HOME}/${_pname}
	    fi

	    if [ -z "$DBREC" ];then
		local _labelX=`getLABEL_XEN "${_pname}"`
                #LABEL=DOMAIN-NAME
		if [ -z "${_label}" -a -z "${_labelX}" ];then
		    ABORT=1;
		    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing LABEL, gwhich is the mandatory DomainName for Xen."
		    printERR $LINENO $BASH_SOURCE ${ABORT} "Defined as user defined pre-requisite for Xen."
 		    gotoHell ${ABORT}
		fi 

                #consistency of CLI and config
		if [ -n "${_label}" -a "${_label}" != "${_labelX}"  ];then
		    ABORT=1;
		    printERR $LINENO $BASH_SOURCE ${ABORT} "Different LABELs detected:\"${_label}\" == \"${_labelX}\""
 		    gotoHell ${ABORT}
		fi 
		_label="${_labelX}"


                #consistency of CLI and config
		local _tcpX=`getIP "${_pname}"`
		if [ -n "${_tcp}" -a "${_tcp}" != "${_tcpX}"  ];then
		    ABORT=1;
		    printERR $LINENO $BASH_SOURCE ${ABORT} "Different TCPs detected:\"${_tcp}\" == \"${_tcpX}\""
 		    gotoHell ${ABORT}
		fi 
		_tcp="${_tcpX}"

                #consistency of CLI and config
		local _macX=`getMAC_XEN "${_pname}"`
		if [ -n "${_mac}" -a "${_mac}" != "${_macX}"  ];then
		    ABORT=1;
		    printERR $LINENO $BASH_SOURCE ${ABORT} "Different MACs detected:\"${_mac}\" == \"${_macX}\""
 		    gotoHell ${ABORT}
		fi 
		_mac="${_macX}"

                #consistency of CLI and config
		local _uuidX=`getUUID_XEN "${_pname}"`
		if [ -n "${_uuid}" -a "${_uuid}" != "${_uuidX}"  ];then
		    ABORT=1;
		    printERR $LINENO $BASH_SOURCE ${ABORT} "Different UUIDs detected:\"${_uuid}\" == \"${_uuidX}\""
 		    gotoHell ${ABORT}
		fi 
		_uuid="${_uuidX}"
	    else
		local _VHOST="${MYLIBEXECPATH}/ctys-vhost.sh ${C_DARGS} -p ${DBPATHLST} -s -M unique "
		_VHOST="${_VHOST} ${_actionuserXEN:+ F:44:$_actionuserXEN}"


		case ${C_NSCACHELOCATE} in
		    0)#off
			;;
		    1)#both
			local _macX=`${_VHOST} -o MAC R:$DBREC `
			if [ -n "${_mac}" -a "${_mac}" != "${_macX}"  ];then
			    ABORT=1;
			    printERR $LINENO $BASH_SOURCE ${ABORT} "Different MACs detected:\"${_mac}\" == \"${_macX}\""
 			    gotoHell ${ABORT}
			fi 
			_mac="${_macX}"

                        #consistency of CLI and config
			local _uuidX=`${_VHOST} -o UUID R:$DBREC `
			if [ -n "${_uuid}" -a "${_uuid}" != "${_uuidX}"  ];then
			    ABORT=1;
			    printERR $LINENO $BASH_SOURCE ${ABORT} "Different UUIDs detected:\"${_uuid}\" == \"${_uuidX}\""
 			    gotoHell ${ABORT}
			fi 
			_uuid="${_uuidX}"
			;;
		    2)#local
			if [ "${C_EXECLOCAL}" != 1 ];then
			    local _macX=`${_VHOST} -o MAC R:$DBREC `
			    if [ -n "${_mac}" -a "${_mac}" != "${_macX}"  ];then
				ABORT=1;
				printERR $LINENO $BASH_SOURCE ${ABORT} "Different MACs detected:\"${_mac}\" == \"${_macX}\""
 				gotoHell ${ABORT}
			    fi 
			    _mac="${_macX}"

                            #consistency of CLI and config
			    local _uuidX=`${_VHOST} -o UUID R:$DBREC `
			    if [ -n "${_uuid}" -a "${_uuid}" != "${_uuidX}"  ];then
				ABORT=1;
				printERR $LINENO $BASH_SOURCE ${ABORT} "Different UUIDs detected:\"${_uuid}\" == \"${_uuidX}\""
 				gotoHell ${ABORT}
			    fi 
			    _uuid="${_uuidX}"
			fi
			;;
		    3)#remote
			if [ "${C_EXECLOCAL}" == 1 ];then
			    local _macX=`${_VHOST} -o MAC R:$DBREC `
			    if [ -n "${_mac}" -a "${_mac}" != "${_macX}"  ];then
				ABORT=1;
				printERR $LINENO $BASH_SOURCE ${ABORT} "Different MACs detected:\"${_mac}\" == \"${_macX}\""
 				gotoHell ${ABORT}
			    fi 
			    _mac="${_macX}"

                            #consistency of CLI and config
			    local _uuidX=`${_VHOST} -o UUID R:$DBREC `
			    if [ -n "${_uuid}" -a "${_uuid}" != "${_uuidX}"  ];then
				ABORT=1;
				printERR $LINENO $BASH_SOURCE ${ABORT} "Different UUIDs detected:\"${_uuid}\" == \"${_uuidX}\""
 				gotoHell ${ABORT}
			    fi 
			    _uuid="${_uuidX}"
			fi
			;;
		esac
	    fi

	    if [ -z "${_tcp}" ];then
		local _VHOST="${MYLIBEXECPATH}/ctys-vhost.sh ${C_DARGS} -o TCP -p ${DBPATHLST} -s -M unique "
		case ${C_NSCACHELOCATE} in
		    0)#off
			;;
		    1)#both
			if [ -n "$DBREC" ];then
			    local _tcp=`${_VHOST}  R:$DBREC `
			else
			    local _VHOST="${_VHOST} ${_actionuserXEN:+ F:44:$_actionuserXEN}"
			    local _tcp=`${_VHOST}  "${_label}" "${_targetHost}"  "${_pname}" `
			fi
			;;
		    2)#local
			if [ "${C_EXECLOCAL}" != 1 ];then
			    if [ -n "$DBREC" ];then
				local _tcp=`${_VHOST}  R:$DBREC `
			    else
				local _VHOST="${_VHOST} ${_actionuserXEN:+ F:44:$_actionuserXEN}"
				local _tcp=`${_VHOST}  "${_label}" "${_targetHost}"  "${_pname}" `
			    fi
			fi
			;;
		    3)#remote
			if [ "${C_EXECLOCAL}" == 1 ];then
			    if [ -n "$DBREC" ];then
				local _tcp=`${_VHOST}  R:$DBREC `
			    else
				local _VHOST="${_VHOST} ${_actionuserXEN:+ F:44:$_actionuserXEN}"
				local _tcp=`${_VHOST}  "${_label}" "${_targetHost}"  "${_pname}" `
			    fi
			fi
			;;
		esac

		if [ "${C_NSCACHEONLY}" != 1 -a -z "${_tcp}" ];then
		    local _tcp=`getIP "${_pname}"`
		fi
		printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "From vhost TCP = ${_tcp}"
	    fi
	    if [ -z "${_tcp}" ];then
		printWNG 1 $LINENO $BASH_SOURCE 1 "Cannot evaluate the TCP/IP address of VM:${_label}"
		printWNG 1 $LINENO $BASH_SOURCE 1 "Some functions may be erroneous."
	    fi


            #####
            #So, essential IDs are unambiguous now!
            #####

            #I guess we have a valid _pname and a _label now.
	    printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE  "Current ident-data:"
	    printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE  "  BASE     =${_base}"
	    printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE  "  PNAME    =${_pname}"
	    printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE  "  TCP      =${_tcp}"
	    printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE  "  MAC      =${_mac}"
	    printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE  "  UUID     =${_uuid}"
	    printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE  "  LABEL    =${_label}"
	    printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE  "  FNAME    =${_fname}"
	    printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE  "Console:"
	    printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE  "  TYPE     =${_consoleType}"
	    printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE  "Data source:"
	    printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE  "  NOCACHE  =${cache}"
	    printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE  "  NOPOLL   =${poll}"
	    printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE  "Boot-Mode:"
	    printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE  "  BOOTMODE            =\"${_bootmode}\""
	    printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE  "Inst-Mode:"
	    printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE  "  INSTMODE            =\"${_instmode}\""
	    printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE  "Parameters:"
	    printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE  "  CALLOPTS =\"${_callopts}\""
	    printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE  "  XOPTS    =\"${_xopts}\""

        ###########################
         #    So, ... let's go!    #
        ###########################

            #check whether a mediating wormhole is required. 
            #In any case find the entry for peer.

#4TEST:remove later
#4TEST:acue:20100518:for localonly connect, check this by regression
# 	    if [ "${C_CLIENTLOCATION}" !=  "-L CONNECTIONFORWARDING" \
# 		-a "${C_CLIENTLOCATION}" !=  "-L LOCALONLY" \
#  		];then

	    if [ "${C_CLIENTLOCATION}" !=  "-L CONNECTIONFORWARDING" \
 		];then
                #Seems to be executed on remote host, not the calling station
		printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "C_CLIENTLOCATION=${C_CLIENTLOCATION}"

                #check for running local server...
                #...remember, this part is actually running local-on-remote site!
 		local _IDx=`fetchID4Label ${_label}`
		_pname=${_pname:-$_IDx}
	    fi
	    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE " Session-Identifier: ${_label} ->${_IDx}"

            #check whether server is already running(local or remote)
            #therefore a peer must be present
	    if [ -n "${_IDx}" ];then
                #Server is already running, so it is a potential CONNECT.
                #perform only if REUSE is present
                #so practically this could only be LOCALONLY or DISPLAYFORWARDING,
                #CONNECTIONFORWARDING is normally impossible, due to timeout of connection(One-Shot-Mode)
		if [ -n "${_reuse}" -o -n "${_connect}" -o -n "${_reconnect}" ];then
                    #only something to do when anything else than the server is running
                    #server is defined not to be reused
		    if [ "${C_CLIENTLOCATION}" !=  "-L SERVERONLY" ];then
                        #if to be reused
			printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "REUSE: \"${_pname}\" \"${_label}\" \"${_IDx}\""

                        #check now for reconnect, if so kill whole competition
			if [ -n "${_reconnect}" ];then
                            #So it is all to be killed: ID might be available here.
			    _history=`\
                               ${MYLIBEXECPATH}/ctys.sh -T CLI,X11,VNC \
                                -a list=CLIENT,TERSE,LABEL,ID,PID,SITE \
                                -b 0 ${C_DARGS} ${C_DARGS:+-- "($C_DARGS)"}|\
                               awk -F';' -v l="${_label}" '$1~l{print $0 }'`

                            #kill clients, guess the caller knows what he is doing, particularly
                            #has assured a stateless server!!!
  			    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "MODE=RECONNECT($_history)"
			    for _i in ${_history};do
				[ "${_i##*;}" != CLIENT ]&&continue; #OK, not really required, but for safety
				printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "kill:${_i}"
				local _pid=${_i%;*}
				_pid=${_pid##*;}
				echo -n "Session:\"${_i%%;*}\":PID=$_pid"
				kill $_pid
				echo
			    done
			fi

                        #trust for now - any garbage is removed
			local _myDisp=`fetchCport4Label ${_label}`
			connectSessionXEN "${_consoleType}" "${_label}" "${_pname}" "${_myDisp}" 
		    fi
		else
		    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "Session already exists ID=${_IDx} - LABEL=${_label}"
		    ABORT=1
		    printERR $LINENO $BASH_SOURCE ${ABORT} "Session already exists ID=${_IDx} - LABEL=${_label}"
		    printERR $LINENO $BASH_SOURCE ${ABORT} "  Choose \"REUSE\" if you want connect-only when existing"
		    gotoHell ${ABORT}
		fi
	    else
                #Local server not yet running, so it is a CREATE, or a remote connection has to be established,
                #gwhich must be a server-split of an CONNECTIONFORWARDING.
		if [ "${C_CLIENTLOCATION}" !=  "-L CONNECTIONFORWARDING" ];then
                    #
                    #So, this is executed on server site, it is a DISPLAYFORWARDING
                    #
 		    printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "C_CLIENTLOCATION=${C_CLIENTLOCATION}"
		    if [ -n "$_connect" -o -n "$_connect" ];then
			ABORT=1
			printERR $LINENO $BASH_SOURCE ${ABORT} "Cannot CONNECT, server not running LABEL=${_label}"
			printERR $LINENO $BASH_SOURCE ${ABORT} "=>Choose \"REUSE\" if you want to create on-the-fly"
			gotoHell ${ABORT}
		    fi
		    startSessionXEN "${_label}" "${_pname}" "${_consoleType}" "${_bootmode}" "${_tcp}" "${_instmode}" "${_kernelmode}" "${_addargs}"
		else
                    #
                    #So, this is executed on the client site, different from server site,
                    #it is CONNECTIONFORWARDING to a remote server.
                    #So, dig the tunnel and connect myself.
                    #
                    #find local entry for SSH-tunnel with generic LABEL as marker for proxying to remote server.
		    _pname=${_pname:-`fetchID4Label ${_label}`}
		    local _lport=`digGetLocalPort ${_label} XEN`
 		    printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "C_CLIENTLOCATION=${C_CLIENTLOCATION}"
		    if [ -z "${_lport}" ];then	  
 			printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "No tunnel found, create a new one."
			digLocalPort XEN "$_targetHost" "$_label" "$_pname" "" "${_actionuserQEMU}">/dev/null
		    fi
                    #check it once again
 		    local _lport=`digGetLocalPort ${_label} XEN`
		    if [ -z "$_lport" ];then
                        #Something went wrong!!!???                                      
			ABORT=1
			printERR $LINENO $BASH_SOURCE ${ABORT} "Cannot allocate CONNECTIONFORWARDING"
			printERR $LINENO $BASH_SOURCE ${ABORT} "  digLocalPort XEN <$_targetHost> <$_label> <$_pname> <> <${_actionuserQEMU}>"
			printERR $LINENO $BASH_SOURCE ${ABORT} "  digGetLocalPort <$_label> XEN"
			gotoHell ${ABORT}
		    fi
 		    printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "_lport=${_lport} i=${i}"
		    connectSessionXEN "${_consoleType}" "${_label}" "${_pname}" "${_lport}"  
		fi
	    fi
	    printDBG $S_XEN ${D_TST} $LINENO $BASH_SOURCE "$FUNCNAME:EXIT:OPMODE=${OPMODE}:ACTION=${ACTION}:RESULT=OK"
	    gotoHell 0
	    ;;
    esac
    if [ $_ret -eq 0 ];then
	printDBG $S_XEN ${D_TST} $LINENO $BASH_SOURCE "$FUNCNAME:EXIT:OPMODE=${OPMODE}:ACTION=${ACTION}:RESULT=OK"
    else
	printDBG $S_XEN ${D_TST} $LINENO $BASH_SOURCE "$FUNCNAME:EXIT:OPMODE=${OPMODE}:ACTION=${ACTION}:RESULT=NOK"
    fi
    return $_ret
}
