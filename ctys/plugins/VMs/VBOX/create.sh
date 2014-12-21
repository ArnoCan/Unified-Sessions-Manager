#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_009alpha
#
########################################################################
#
# Copyright (C) 2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

_myPKGNAME_VBOX_CREATE="${BASH_SOURCE}"
_myPKGVERS_VBOX_CREATE="01.11.009alpha"
hookInfoAdd $_myPKGNAME_VBOX_CREATE $_myPKGVERS_VBOX_CREATE
_myPKGBASE_VBOX_CREATE="`dirname ${_myPKGNAME_VBOX_CREATE}`"

#specifies a record index
export DBREC=;

#FUNCBEG###############################################################
#NAME:
#  createConnectVBOX
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
function createConnectVBOX () {
    local OPMODE=$1;shift
    local ACTION=$1;shift

    local A;
    local KEY;
    local ARG;
    local _pname=;
    local _ret=0;

    local _conty=;
    case $VBOX_MAGIC in
	*)
	    _conty=RDP;
	    ;;
    esac

    #gimme some more time
    SSH_ONESHOT_TIMEOUT=${VBOX_SSH_ONESHOT_TIMEOUT:-40}

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

		printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "C_MODE_ARGS=$C_MODE_ARGS"
		A=`cliSplitSubOpts ${C_MODE_ARGS}`
		for i in $A;do
		    KEY=`cliGetKey ${i}`
		    ARG=`cliGetArg ${i}`
                    if [ -n "${ARG}" \
			-o -z "${ARG}" -a "${KEY}" == "REUSE" \
			-o -z "${ARG}" -a "${KEY}" == "RESUME" \
			-o -z "${ARG}" -a "${KEY}" == "CONNECT" \
			-o -z "${ARG}" -a "${KEY}" == "RECONNECT" \
			];then
			case $KEY in
			    CONNECT)
				let _unambigCON+=1;
				local _reuse=1;
				local _connect=1;
				printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "CONNECT=>connect only if present"
				if [ -n "${ARG}" ]; then
				    ABORT=1;
				    printERR $LINENO $BASH_SOURCE ${ABORT} "No arguments are supported for \"$KEY\""
 				    gotoHell ${ABORT}
				fi
				;;

			    REUSE)
				let _unambigCON+=1;
				local _reuse=1;
				printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "REUSE=>connect or create"
				if [ -n "${ARG}" ]; then
				    ABORT=1;
				    printERR $LINENO $BASH_SOURCE ${ABORT} "No arguments are supported for \"$KEY\""
 				    gotoHell ${ABORT}
				fi
				;;

			    RECONNECT)
                                #check for VMPlayer has to be performed on <execution-target>
				local _reuse=1;
				local _reconnect=1;
				let _unambigCON+=1;
				printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "RECONNECT=>CANCEL running clients first"
				if [ -n "${ARG}" ]; then
				    ABORT=1;
				    printERR $LINENO $BASH_SOURCE ${ABORT} "No arguments are supported for \"$KEY\""
 				    gotoHell ${ABORT}
				fi
				;;

			    RESUME)
                                #check for VMPlayer has to be performed on <execution-target>
				local _resume=1;
				let _unambigCON+=1;
				printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "RESUME=>Applicable for state SUSPENDED"
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
				printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "DBRECORD=${DBREC}"
				;;
			    BASEPATH|BASE|B)
				local _base="${ARG}";
				printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "BASE=${_base}"
				let _unambig+=1;
				;;
			    TCP|T)
				local _tcp="${ARG}";
				printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "TCP=${_tcp}"
				let _unambig+=1;
				;;
			    MAC|M)
				local _mac="${ARG}";
				printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "MAC=${_mac}"
				let _unambig+=1;
				;;
			    UUID|U)
                                #has to be checked later
				local _uuid="${ARG}";
 				printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "UUID=${_uuid}"
				let _unambig+=1;
				;;
			    LABEL|L)
                                #has to be checked later
				local _label="${ARG}";
 				printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "LABEL=${_label}"
				let _unambig+=1;
				;;
			    FILENAME|FNAME|F)
                                #has to be checked later
				local _fname="${ARG}";
				printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "FILENAME=${_fname}"
				let _unambig++;
				;;
			    ID|I|PATHNAME|PNAME|P)
                                #can (partly for relative names) be checked now
				if [ -n "${ARG##/*}" ]; then
				    ABORT=1;
				    printERR $LINENO $BASH_SOURCE ${ABORT} "PNAME has to be an absolute path, use fname else."
				    printERR $LINENO $BASH_SOURCE ${ABORT} " PNAME=${ARG}"
 				    gotoHell ${ABORT}
				fi
				local _idgiven=1;
				printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "PATHNAME=${ARG}"
				;;

                     #######################
                     # Specific attributes #  
                     #######################
			    CALLOPTS|C)
                                #trust the user for now, and let the target call check it
				local _callopts="${ARG//\%/ }";
				printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "CALLOPTS=${_callopts}"
				;;
			    XOPTS|X)
                                #trust the user for now, and let the target call check it
				local _xopts="${ARG//\%/ }";
				printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "XTOOLKITOPTS=${_xopts}"
				;;

                        ###########
			    CONSOLE)
				local _conty="`echo ${ARG}|tr '[:lower:]' '[:upper:]'`";
				case ${_conty} in
				    VBOX)
					;;

				    SDL)
					;;

				    RDPVIEWER|RDP)
					printWNG 2 $LINENO $BASH_SOURCE 0 "Requires support on destination for ${_conty}"
					local _rdp=1;
					;;

				    NONE)
					printWNG 2 $LINENO $BASH_SOURCE 0 "Requires support on destination for ${_conty}"
					local _none=1;
					printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "NONE"
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
				local _console=$_conty;
				if [ "${C_STACK}" == 1 -a "${_console}" != NONE ];then
				    ABORT=1;
				    printERR $LINENO $BASH_SOURCE ${ABORT} "VMSTACK requires HEADLESS for synchronous SSH operations."
 				    gotoHell ${ABORT}
				fi
				printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "CONSOLE=${ARG}"
				;;

			    PING)
				if [ -z "${ARG}" ];then
				    ABORT=1;
				    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing arguments:$KEY"
 				    gotoHell ${ABORT}
				fi
				case "${ARG}" in
				    [oO][fF][fF])_pingVBOX=0;;
				    [oO][nN])_pingVBOX=1;;
				    *)
					if [ "${ARG//\%/}" == "${ARG}"  ];then
					    ABORT=1;
					    printERR $LINENO $BASH_SOURCE ${ABORT} "Both are mandatory:<#cnt>+<sleep>"
 					    gotoHell ${ABORT}
					fi
					_pingcntVBOX=${ARG%\%*};
					if [ -n "${_pingcntVBOX//[0-9]/}" ];then
					    ABORT=1;
					    printERR $LINENO $BASH_SOURCE ${ABORT} "Non-Numertic:<#pingcnt>=$_pingcntVBOX"
 					    gotoHell ${ABORT}
					fi
					_pingsleepVBOX=${ARG#*\%};
					if [ -n "${_pingsleepVBOX//[0-9]/}" ];then
					    ABORT=1;
					    printERR $LINENO $BASH_SOURCE ${ABORT} "Non-Numertic:<pingsleep>=$_pingsleepVBOX"
 					    gotoHell ${ABORT}
					fi
					;;
				esac
				printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "PING     =${_pingVBOX}"
				printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "PINGCNT  =${_pingcntVBOX}"
				printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "PINGSLEEP=${_pingsleepVBOX}"
				;;

			    SSHPING)
				if [ -z "${ARG}" ];then
				    ABORT=1;
				    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing arguments:$KEY"
 				    gotoHell ${ABORT}
				fi
				case "${ARG}" in
				    [oO][fF][fF])_sshpingVBOX=0;;
				    [oO][nN])_sshpingVBOX=1;;
				    *)
					if [ "${ARG//\%/}" == "${ARG}"  ];then
					    ABORT=1;
					    printERR $LINENO $BASH_SOURCE ${ABORT} "Both are mandatory:<#cnt>+<sleep>"
 					    gotoHell ${ABORT}
					fi
					_sshpingcntVBOX=${ARG%\%*};
					if [ -n "${_sshpingcntVBOX//[0-9]/}" ];then
					    ABORT=1;
					    printERR $LINENO $BASH_SOURCE ${ABORT} "Non-Numertic:<#sshpingcnt>=$_sshpingcntVBOX"
 					    gotoHell ${ABORT}
					fi
					_sshpingsleepVBOX=${ARG#*\%};
					if [ -n "${_sshpingsleepVBOX//[0-9]/}" ];then
					    ABORT=1;
					    printERR $LINENO $BASH_SOURCE ${ABORT} "Non-Numertic:<sshpingsleep>=$_sshpingsleepVBOX"
 					    gotoHell ${ABORT}
					fi
					;;
				esac
				printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "SSHPING     =${_sshpingVBOX}"
				printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "SSHPINGCNT  =${_sshpingcntVBOX}"
				printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "SSHPINGSLEEP=${_sshpingsleepVBOX}"
				;;

			    USER)
				if [ -z "${ARG}" ];then
				    ABORT=1;
				    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing arguments:$KEY"
 				    gotoHell ${ABORT}
				fi
				_actionuserVBOX="${ARG}";
				printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "ACTION-USER=${_actionuserVBOX}"

				local _u0=${_actionuserVBOX%% *}
				if [ -z "${_u0}" ];then
				    ABORT=1;
				    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing USER:$KEY"
# 				    gotoHell ${ABORT}
				fi

				_u0=${_actionuserVBOX#* }
				if [ -z "${_u0}" ];then
				    ABORT=1;
				    printWNG 1 $LINENO $BASH_SOURCE 1 "Missing USER-Credentials:$KEY"
#				    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing USER-Credentials:$KEY"
# 				    gotoHell ${ABORT}
				fi
				;;


			    WAITC)
				if [ -z "${ARG}" ];then
				    ABORT=1;
				    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing arguments:$KEY"
 				    gotoHell ${ABORT}
				fi
				case "${ARG}" in
				    *)
					_waitcVBOX=${ARG};
					if [ -n "${_waitcVBOX//[0-9]/}" ];then
					    ABORT=1;
					    printERR $LINENO $BASH_SOURCE ${ABORT} "Non-Numeric $KEY:$_waitcVBOX"
 					    gotoHell ${ABORT}
					fi
					;;
				esac
				printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "WAITC =${_waitcVBOX}"
				;;

			    WAITS)
				if [ -z "${ARG}" ];then
				    ABORT=1;
				    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing arguments:$KEY"
 				    gotoHell ${ABORT}
				fi
				case "${ARG}" in
				    *)
					_waitsVBOX=${ARG};
					if [ -n "${_waitsVBOX//[0-9]/}" ];then
					    ABORT=1;
					    printERR $LINENO $BASH_SOURCE ${ABORT} "Non-Numeric $KEY:$_waitsVBOX"
 					    gotoHell ${ABORT}
					fi
					;;
				esac
				printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "WAITS =${_waitsVBOX}"
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
				printERR $LINENO $BASH_SOURCE ${ABORT} "Unknown sub-opts for VBOX:${KEY}"
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

		
                #
                #handle remote options for actual execution...
                #
                #...trust the correctness, or better the checks of actual final tool,
                #these options are destined for, thus nothing to do her.
                #
		if [ "${_unambigCON}" -gt 1 ];then
		    _ret=1;
		    printERR $LINENO $BASH_SOURCE ${_ret} "The following sub-opts are EXOR applicable only:"
		    printERR $LINENO $BASH_SOURCE ${_ret} "  (CONNECT|REUSE) EXOR (RECONNECT|RESUME)"
 		    gotoHell ${_ret}               
		fi
            fi

            if((_unambig==0&&_idgiven!=1));then
		_ret=1;
		printERR $LINENO $BASH_SOURCE ${_ret} "Missing parameter, exactly one of the following is required:"
		printERR $LINENO $BASH_SOURCE ${_ret} "  (label|l|dname|d) EXOR (fname|f) EXOR (pname|p)EXOR (uuid|u)"
 		gotoHell ${_ret}               
            fi

	    case ${_conty} in
		RDPVIEWER|RDP)
		    local _rdp=1;
		    R_OPTS="$R_OPTS -T RDP,VBOX"
		    printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "RDPviewer set: -T RDP,VBOX"
		    ;;
	    esac

	    if [ -n "${DBREC}" -a -z "${_pname}" ];then
		if [ -n "${_base}" -o -n "${_tcp}" -o -n "${_mac}" -o -n "${_uuid}" \
                    -o -n "${_label}" -o -n "${_fname}" -o -n "${_pname}" ];then
		    printWNG 1 $LINENO $BASH_SOURCE 1 "The provided DB index has priority for address"
		    printWNG 1 $LINENO $BASH_SOURCE 1 "if matched the remeining address parameters are ignored"
		fi
	    fi
	    ;;

	ASSEMBLE)
	    ;;

	EXECUTE)
	    if [ -n "${R_TEXT}" ];then
		echo "${R_TEXT}"
	    fi

	    local _unambig=0;

	    printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "C_MODE_ARGS=$C_MODE_ARGS"
	    A=`cliSplitSubOpts ${C_MODE_ARGS}`
	    for i in $A;do
		KEY=`cliGetKey ${i}`
		ARG=`cliGetArg ${i}`
		if [ -n "${ARG}" \
		    -o -z "${ARG}" -a "${KEY}" == "REUSE" \
		    -o -z "${ARG}" -a "${KEY}" == "RESUME" \
		    -o -z "${ARG}" -a "${KEY}" == "CONNECT" \
		    -o -z "${ARG}" -a "${KEY}" == "RECONNECT" \
		    ];then
		    case $KEY in
			CONNECT)
                            local _connect=1;
                            local _reuse=1;
			    printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "REUSE=>try CONNECT before CREATE"
			    ;;

			REUSE)
                            local _reuse=1;
			    printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "REUSE=>try CONNECT before CREATE"
			    ;;

			RECONNECT)
                            local _reuse=1;
                            local _reconnect=1;
			    printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "RECONNECT=>CANCEL running clients first"
			    ;;
			RESUME)
			    local _reuse=1;
			    let _unambigCON+=1;
			    printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "RESUME=>Applicable for state SUSPENDED"
			    ;;


                     #####################
                     # <machine-address> #
                     #####################
			DBRECORD|DBREC|DR)
			    local DBREC="${ARG}";
			    printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "DBRECORD=${DBREC}"
			    ;;
			BASEPATH|BASE|B)
                            #can be checked now
                            local _base="${ARG}";
			    printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "BASE=${_base}"

                            #
                            #leisure,... for the last release-tests!!
                            #...quickshot for now, change it serious asap!!!
                            _base=${_base//\\\//\/}

                            for i in ${_base//\%/ };do
				if [ ! -d "${i}" ];then
				    ABORT=1;
				    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing given base-path";
				    printERR $LINENO $BASH_SOURCE ${ABORT} "  i  =  ${i}";
				    printERR $LINENO $BASH_SOURCE ${ABORT} "  PWD=  ${PWD}";
				    printERR $LINENO $BASH_SOURCE ${ABORT} "  BASE= ${_base}";
				    printERR $LINENO $BASH_SOURCE ${ABORT} "Check your actual PWD when providing a relative base-path";
 				    gotoHell ${ABORT};
				fi
			    done
			    ;;

			TCP|T)
			    local _tcp="${ARG}";
			    printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "TCP=${_tcp}"
			    ;;

			MAC|M)
			    local _mac="${ARG}";
			    printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "MAC=${_mac}"

			    ;;
			UUID|U)
			    local _uuid="${ARG}";
 			    printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "UUID=${_uuid}"
			    ;;

			LABEL|L)
                            local _label="${ARG}";
 			    printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "LABEL=${_label}"
			    ;;

			FILENAME|FNAME|F)
                            local _fname="${ARG}";
			    printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "FILENAME=${_fname}"
			    ;;

			ID|PATHNAME|PNAME|P)
                            if [ -n "${_pname}" -a "${_pname}" != "${ARG}" ];then
				ABORT=1;
				printERR $LINENO $BASH_SOURCE ${ABORT} "This version supports just ONE KEY=<${KEY}> "
				printERR $LINENO $BASH_SOURCE ${ABORT} "for each ACTION=<${ACTION}> call"
				printERR $LINENO $BASH_SOURCE ${ABORT} "  ID(1)=${_pname}"
				printERR $LINENO $BASH_SOURCE ${ABORT} "  ID(2)=${ARG}"
				printERR $LINENO $BASH_SOURCE ${ABORT} "Will be extended soon."
 				gotoHell ${ABORT}
                            fi
                            if [ ! -f "${ARG}" ];then
				ABORT=1;
				printERR $LINENO $BASH_SOURCE ${ABORT} "Missing given file or access permission for ID/PNAME"
				printERR $LINENO $BASH_SOURCE ${ABORT} "  ID=${ARG}"
 				gotoHell ${ABORT}
                            fi
                            local _pname="${ARG}";
			    printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "RANGE:PATHNAME=${_pname}"
			    ;;

                     #####################
			CALLOPTS|C)
			    local _callopts="${ARG//\%/ }";
			    printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "CALLOPTS=${_callopts}"
                            C_SESSIONIDARGS="${_callopts}"
			    ;;

			XOPTS|X)
			    local _xopts="${ARG//\%/ }";
			    printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "XTOOLKITOPTS=${_xopts}"
                            C_XTOOLKITOPTS="${_xopts}"
			    ;;

			CONSOLE)
			    local _conty="`echo ${ARG}|tr '[:lower:]' '[:upper:]'`";
			    printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "_conty=${_conty}"
			    case ${_conty} in
				VBOX)
				    ;;

				SDL)
				    ;;

				RDP)
				    if [ -z "`hookInfoCheckPKG RDP`" ];then
					ABORT=1;
					printERR $LINENO $BASH_SOURCE ${ABORT} "This feature reuqires RDP plugin ${ACTION}=${KEY}"
					printERR $LINENO $BASH_SOURCE ${ABORT} "-> Set the option \"-T\" for client and server"
					printERR $LINENO $BASH_SOURCE ${ABORT} "-> Check actually loaded plugins with option \"-V\""
 					gotoHell ${ABORT};
				    fi
				    local _rdp=1;
				    printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "rdesktop"
				    ;;

				NONE)
				    local _none=1;
				    printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "NONE"
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
			    local _console=$_conty;
			    printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "CONSOLE=${ARG}"
			    ;;

			PING)
			    if [ -z "${ARG}" ];then
				ABORT=1;
				printERR $LINENO $BASH_SOURCE ${ABORT} "Missing arguments:$KEY"
 				gotoHell ${ABORT}
			    fi
			    case "${ARG}" in
				[oO][fF][fF])_pingVBOX=0;;
				[oO][nN])_pingVBOX=1;;
				*)
				    if [ "${ARG//\%/}" == "${ARG}"  ];then
					ABORT=1;
					printERR $LINENO $BASH_SOURCE ${ABORT} "Both are mandatory:<#cnt>+<sleep>"
 					gotoHell ${ABORT}
				    fi
				    _pingcntVBOX=${ARG%\%*};
				    if [ -n "${_pingcntVBOX//[0-9]/}" ];then
					ABORT=1;
					printERR $LINENO $BASH_SOURCE ${ABORT} "Non-Numertic:<#pingcnt>=$_pingcntVBOX"
 					gotoHell ${ABORT}
				    fi
				    _pingsleepVBOX=${ARG#*\%};
				    if [ -n "${_pingsleepVBOX//[0-9]/}" ];then
					ABORT=1;
					printERR $LINENO $BASH_SOURCE ${ABORT} "Non-Numertic:<pingsleep>=$_pingsleepVBOX"
 					gotoHell ${ABORT}
				    fi
				    ;;
			    esac
			    printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "PING     =${_pingVBOX}"
			    printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "PINGCNT  =${_pingcntVBOX}"
			    printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "PINGSLEEP=${_pingsleepVBOX}"
			    ;;

			SSHPING)
			    if [ -z "${ARG}" ];then
				ABORT=1;
				printERR $LINENO $BASH_SOURCE ${ABORT} "Missing arguments:$KEY"
 				gotoHell ${ABORT}
			    fi
			    case "${ARG}" in
				[oO][fF][fF])_sshpingVBOX=0;;
				[oO][nN])_sshpingVBOX=1;;
				*)
				    if [ "${ARG//\%/}" == "${ARG}"  ];then
					ABORT=1;
					printERR $LINENO $BASH_SOURCE ${ABORT} "Both are mandatory:<#cnt>+<sleep>"
 					gotoHell ${ABORT}
				    fi
				    _sshpingcntVBOX=${ARG%\%*};
				    if [ -n "${_sshpingcntVBOX//[0-9]/}" ];then
					ABORT=1;
					printERR $LINENO $BASH_SOURCE ${ABORT} "Non-Numertic:<#sshpingcnt>=$_sshpingcntVBOX"
 					gotoHell ${ABORT}
				    fi
				    _sshpingsleepVBOX=${ARG#*\%};
				    if [ -n "${_sshpingsleepVBOX//[0-9]/}" ];then
					ABORT=1;
					printERR $LINENO $BASH_SOURCE ${ABORT} "Non-Numertic:<sshpingsleep>=$_sshpingsleepVBOX"
 					gotoHell ${ABORT}
				    fi
				    ;;
			    esac
			    printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "SSHPING     =${_sshpingVBOX}"
			    printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "SSHPINGCNT  =${_sshpingcntVBOX}"
			    printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "SSHPINGSLEEP=${_sshpingsleepVBOX}"
			    ;;

			USER)
			    if [ -z "${ARG}" ];then
				ABORT=1;
				printERR $LINENO $BASH_SOURCE ${ABORT} "Missing arguments:$KEY"
 				gotoHell ${ABORT}
			    fi
			    _actionuserVBOX="${ARG}";
			    printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "ACTION-USER=${_actionuserVBOX}"
			    VBOX_SESSION_USER=${_actionuserVBOX%% *}
# 			    VBOXMGR="${VBOXMGR} -u ${VBOX_SESSION_USER} "
			    VBOX_SESSION_CRED=${_actionuserVBOX#* }
 			    if [ "${VBOX_SESSION_CRED}" == "${_actionuserVBOX}" ];then
				VBOX_SESSION_CRED=;
# 			    else
# 				VBOXMGR="${VBOXMGR} -p ${VBOX_SESSION_CRED} "
			    fi
			    printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "VBOXMGR=${VBOXMGR}"
			    ;;

			WAITC)
			    if [ -z "${ARG}" ];then
				ABORT=1;
				printERR $LINENO $BASH_SOURCE ${ABORT} "Missing arguments:$KEY"
 				gotoHell ${ABORT}
			    fi
			    case "${ARG}" in
				*)
				    _waitcVBOX=${ARG};
				    if [ -n "${_waitcVBOX//[0-9]/}" ];then
					ABORT=1;
					printERR $LINENO $BASH_SOURCE ${ABORT} "Non-Numeric $KEY:$_waitcVBOX"
 					gotoHell ${ABORT}
				    fi
				    ;;
			    esac
			    printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "WAITC =${_waitcVBOX}"
			    ;;

			WAITS)
			    if [ -z "${ARG}" ];then
				ABORT=1;
				printERR $LINENO $BASH_SOURCE ${ABORT} "Missing arguments:$KEY"
 				gotoHell ${ABORT}
			    fi
			    case "${ARG}" in
				*)
				    _waitsVBOX=${ARG};
				    if [ -n "${_waitsVBOX//[0-9]/}" ];then
					ABORT=1;
					printERR $LINENO $BASH_SOURCE ${ABORT} "Non-Numeric $KEY:$_waitsVBOX"
 					gotoHell ${ABORT}
				    fi
				    ;;
			    esac
			    printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "WAITC =${_waitsVBOX}"
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

                     #####################
			*)
			    ABORT=1;
			    printERR $LINENO $BASH_SOURCE ${ABORT} "Unexpected sub-opts for VBOX:${KEY}"
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


	    case ${_conty} in
		RDP)
		    if [ -z "`hookInfoCheckPKG RDP`" ];then
			ABORT=1;
			printERR $LINENO $BASH_SOURCE ${ABORT} "This feature reuqires RDP plugin ${ACTION}=${KEY}"
			printERR $LINENO $BASH_SOURCE ${ABORT} "-> Set the option \"-T\" for client and server"
			printERR $LINENO $BASH_SOURCE ${ABORT} "-> Check actually loaded plugins with option \"-V\""
 			gotoHell ${ABORT};
		    fi
		    local _rdp=1;
		    local _console=$_conty;
		    printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "rdesktop"
		    ;;
	    esac


            #
            #0. Try cache - DB-INDEX
            #
            if [ -z "${_pname// /}" -a -n "${DBREC// /}" ];then
		printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "PNAME-EVALUATE-CACHE-DBINDEX"
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
		printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "PNAME-EVALUATE-CACHE"
		_pname=`cacheGetUniquePname "${_base}" "${MYHOST}" VBOX ${_pname} ${_tcp} ${_mac} ${_uuid} ${_label} ${_fname}`
		if [ $? -ne 0 ];then
		    ABORT=1;
		    printERR $LINENO $BASH_SOURCE ${ABORT} "Cannot fetch unique pathname, following should be checked:"
		    printERR $LINENO $BASH_SOURCE ${ABORT} "  1. Create a cache and/or check the contents."
		    printERR $LINENO $BASH_SOURCE ${ABORT} "  2. Use \"-c local\" uses ns-cache on caller's site only."
		    printERR $LINENO $BASH_SOURCE ${ABORT} "  3. Use \"-c off\" avoids ns-cache usage, scans filesystem."
		    printERR $LINENO $BASH_SOURCE ${ABORT} "  4. Provide \"pname\", and eventually \"tcp\" part of <machine-address>."
		    printERR $LINENO $BASH_SOURCE ${ABORT} "  5. Create a dummy macmap.fdb, continues with filesystem scan."
 		    gotoHell ${ABORT}
		fi
		printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "_pname=<${_pname}>"
	    fi

            #
            #2. Use filesystem
            #   This does an requires a UNIQUE match only.
            #
            if [ -z "${_pname// /}" ];then
		local _rem=${C_TERSE}
		C_TERSE=1
		local _pname=;
                local _chkKey=;

		if [ "${C_NSCACHEONLY}" == 0 ];then
		    printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "PNAME-EVALUATE-RUNTIME-SYSTEM"

		    local _stime=`getCurTime`;
		    printINFO 1 $LINENO $BASH_SOURCE 0 "($_stime):No CACHE hit by \"ctys-vhost.sh\", scanning filesystem now."
		    printINFO 2 $LINENO $BASH_SOURCE 0 "Update your database with \"ctys-vdbgen.sh\"."

                    #starts in $HOME
                    _base=${_base:-$HOME}
		    printINFO 1 $LINENO $BASH_SOURCE 0 "scan-start=$_base"
		    if [ -n "${_uuid}" ];then
                        #UUID to be "grepped" from vmx-files
			printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "_uuid=${_uuid}"
			_chkKey="${_uuid}"
			_pname=`enumerateMySessionsVBOX ${_base}|awk -F';' -v d="${_uuid}" '$4~d{print $3;}'`
			printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "_pname=${_pname}"
		    else
			if [ -n "${_label}" ];then
                            #displayName to be "grepped" from vmx-files
			    _chkKey="${_label}"
			    _pname=`enumerateMySessionsVBOX ${_base}|awk -F';' -v d="${_label}" '$2~d{print $3;}'`
			    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "_pname=${_pname}"
			else
			    if [ -n "${_tcp}" ];then
                                #displayName to be "grepped" from vmx-files
				_chkKey="${_tcp}"
				_pname=`enumerateMySessionsVBOX ${_base}|awk -F';' -v d="${_tcp}" '$9~d{print $3;}'`
				printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "_pname=${_pname}"
			    else
	 			if [ -n "${_mac}" ];then
                                    #displayName to be "grepped" from vmx-files
				    _chkKey="${_mac}"
				    _pname=`enumerateMySessionsVBOX ${_base}|awk -F';' -v d="${_mac}" '$5~d{print $3;}'`
				    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "_pname=${_pname}"
				else
                                    #has to be a relative vmx-file name, the absolute path has to be found
				    _chkKey="${_fname}"
				    _pname=`enumerateMySessionsVBOX ${_base}|awk -F';' -v d="${_fname}" '$3~d{print $3;}'`
				    _label=${_pname//:*}
				    _pname=${_pname//*:}
				    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "_pname=${_pname}"
				fi
			    fi
			fi
		    fi
		fi
		local _etime=`getCurTime`;
		local _dtime=`getDiffTime $_etime $_stime`;

		C_TERSE=${_rem}
	    else
	 	printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "use _pname=${_pname}"
	    fi

	    if [ -z "${_label}"  ];then
                #first trial, local access
                _label=`sed -n 's/\t//g;/^#/d;s/displayName *= *"\([^"]*\)"/\1/p' ${_pname}`;
		printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "_label=${_label}"
	    fi 

            #second trial enumerate remote sessions a.k.a. vmx-files,
            #this is currently not implicitly supported, do it manually and use the label.
	    if [ -z "${_label}" ];then
		ABORT=1;
		printERR $LINENO $BASH_SOURCE ${ABORT} "Can not get displayName from pname:\"${_pname}\""
		printERR $LINENO $BASH_SOURCE ${ABORT} "  This is almost only possible "
		printERR $LINENO $BASH_SOURCE ${ABORT} "  -> when you cannot access the vmx-file"
		printERR $LINENO $BASH_SOURCE ${ABORT} "  -> for local client with \"-L CONNECTIONFORWARDING\""
		printERR $LINENO $BASH_SOURCE ${ABORT} "  -> because it's accessible remote-only."
		printERR $LINENO $BASH_SOURCE ${ABORT} ""
		printERR $LINENO $BASH_SOURCE ${ABORT} "The internal remote access to sessions a.k.a. vmx-files is not yet supported."
		printERR $LINENO $BASH_SOURCE ${ABORT} "Use \"-a ENUMERATE\" for evaluation of <label>, gwhich is foreseen for internal remote access."
 		gotoHell ${ABORT}
	    fi

            #Make it absolute, if not yet.
            #If relative, it could just result from a "find $HOME ..."
            if [ -n "${_pname##/*}" ]; then
		_pname=${HOME}/${_pname}

	    fi

            #check for RDP client
            if [ -n "${_rdp}" ];then
		_RDP_CLIENT_MODE=`getRDPport "${_pname}"`
	    fi

	    if [ -z "${_tcp}" ];then
		local _VHOST="${MYLIBEXECPATH}/ctys-vhost.sh ${C_DARGS} -o TCP -p ${DBPATHLST} -s -M unique "
		case ${C_NSCACHELOCATE} in
		    0)#off
			;;
		    1)#both
			if [ -n "$DBREC" ];then
			    local _tcp=`${_VHOST}  R:${DBREC}`
			else
			    local _VHOST="${_VHOST} ${_actionuserVBOX:+ F:44:$_actionuserVBOX}"
			    local _tcp=`${_VHOST}  "${_label}" "${MYHOST}"  "${_pname}" `
			fi
			;;
		    2)#local
			if [ "${C_EXECLOCAL}" != 1 ];then
			    if [ -n "$DBREC" ];then
				local _tcp=`${_VHOST}  R:${DBREC}`
			    else
				local _VHOST="${_VHOST} ${_actionuserVBOX:+ F:44:$_actionuserVBOX}"
				local _tcp=`${_VHOST}  "${_label}" "${MYHOST}"  "${_pname}" `
			    fi
			fi
			;;
		    3)#remote
			if [ "${C_EXECLOCAL}" == 1 ];then
			    if [ -n "$DBREC" ];then
				local _tcp=`${_VHOST}  R:${DBREC}`
			    else
				local _VHOST="${_VHOST} ${_actionuserVBOX:+ F:44:$_actionuserVBOX}"
				local _tcp=`${_VHOST}  "${_label}" "${MYHOST}"  "${_pname}" `
			    fi
			fi
			;;
		esac

		if [ "${C_NSCACHEONLY}" != 1 -a -z "${_tcp}" ];then
		    local _tcp=`getIP "${_pname}"`
		    if [ -z "${_tcp}" ];then
                        #No configuration entry, try macmap
			if [ -z "${_mac}" ];then
                            #not yet present, jut do another trial from config file,
                            #could be vendor entry
			    _mac=`getMAC "${_pname}"`
			fi
			if [ -n "${_mac}" ];then
                            #if present check ip-ether-dns mapping-db only
			    _tcp=$(${MYLIBEXECPATH}/ctys-macmap.sh ${C_DARGS} -i ${_mac});
			    printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "From macmap TCP=<${_tcp}> MAC=<$_mac>"
			fi
			if [ -z "${_tcp}" ];then
                        #try convention of label as an dns-name
			    _tcp=$(netGetHostIP ${_label} 2>/dev/null)
			    printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "From netGetHostIP TCP=<${_tcp}>"
			fi
		    else
			printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "From config TCP=<${_tcp}>"
		    fi
		else
		    printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "From vhost TCP=<${_tcp}>"
		fi
	    fi
	    if [ -z "${_tcp}" ];then
		printINFO 1 $LINENO $BASH_SOURCE 0 "Cannot evaluate the TCP/IP address of GuestOS for VM:${_label}"
		printINFO 1 $LINENO $BASH_SOURCE 0 "Doing waits now by timeout instead of polling by ping for GuestOS"
		printWNG  1 $LINENO $BASH_SOURCE 1 "Some functions may be erroneous, you may edit configuration file of VM:<$_label>"
	    fi

            #I guess we have a valid _pname and a _label now.
	    printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "Start session:"
	    printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "  LABEL       = ${_label}"
	    printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "  RDPPORT     = ${_RDP_CLIENT_MODE} ($_rdp)"
	    printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "  UUID        = ${_uuid}"
	    printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "  MAC         = ${_mac}"
	    printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "  TCP         = ${_tcp}"
	    printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "  PATHNAME    = ${_pname}"
	    printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "  FILENAME    = ${_fname}"
	    printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "  CALLOPTS    = \"${_callopts}\""


           ###########################
            #    So, ... let's go!    #
           ###########################


            #check whether a mediating wormhole is required. 
            #In any case find the entry for peer.
	    if [ "${C_CLIENTLOCATION}" !=  "-L CONNECTIONFORWARDING" \
		-a "${C_CLIENTLOCATION}" !=  "-L LOCALONLY" \
 		];then

               #Seems to be executed on remote host, not the calling station
		printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "C_CLIENTLOCATION=${C_CLIENTLOCATION}"

                #check for running local server...
                #...remember, this part is actually running local-on-remote site!
 		local _IDx=`fetchID4Label ${_label}`
		_pname=${_pname:-$_IDx}
            else
                #Is executed on the calling station
                #so is to be executed completely locally or a local client to be tunneled.
                #
		printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "C_CLIENTLOCATION=${C_CLIENTLOCATION}"

                #find local entry for SSH-tunnel with generic LABEL as marker for proxying to remote server.
 		local _IDx=`digGetLocalPort ${_label} VBOX`
		_pname=${_pname:-`fetchID4Label ${_label}`}
		if [ "$_rdp" == 1 -a -n "$_IDx" ];then
		    _RDP_CLIENT_MODE=$_IDx
		fi
	    fi
	    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE " Session-Identifier: ${_label} ->${_IDx}($_pname)"

            #check whether server is already running(local or remote)
            #therfore a peer must be present
	    if [ -n "${_IDx}" ];then
                #Server is already running, so it is a potential CONNECT.
                #perform only if REUSE is present
                #so practically this could only be LOCALONLY or DISPLAYFORWARDING,
                #CONNECTIONFORWARDING is normally impossible, due to timeout of connection(One-Shot-Mode)
		if [ -n "${_reuse}" ];then
                    #only something to do when anything else than the server is running
                    #server is defined not to be reused
		    if [ "${C_CLIENTLOCATION}" !=  "-L SERVERONLY" ];then
                        #if to be reused
			printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "REUSE: \"${_pname}\" \"${_label}\" \"${_IDx}\""
                        #check now for reconnect, if so kill whole competition
			if [ -n "${_reconnect}" ];then
                            #So it is all to be killed: ID might be available here.
			    if [ "${VBOX_MAGIC}" == VBOX_WS6 -o "${VBOX_MAGIC}" == VBOX_WS7 ];then
				hookPackage RDP
				printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "_RDP_CLIENT_MODE=\"${_RDP_CLIENT_MODE}\""
				if [ -z "${_RDP_CLIENT_MODE// /}" ];then
				    local _RDP_CLIENTS=`getRDPport "${_pname}"`
				else
				    local _RDP_CLIENTS="${_RDP_CLIENT_MODE}"
				fi
				printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "_RDP_CLIENTS=\"${_RDP_CLIENTS}\""
			    fi
			    _history=`listMySessions CLIENT,MACHINE,PKG:VBOX%RDP|\
                               awk -F';' -v i="${_IDx}" -v p="${_RDP_CLIENTS}" '$4~i||$8~p||$9~p{print $3 ";" $4 ";" $11 ";" $14}'`

                            #kill clients, guess the caller knows what he is doing, particularly
                            #has assured a stateless server!!!
  			    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "MODE=RECONNECT($_history)"
			    for _i in ${_history};do
				[ "${_i##*;}" != CLIENT ]&&continue; #OK, not really required, but for safety
				printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "kill:${_i}"
				local _pid=${_i%;*}
				_pid=${_pid##*;}
				echo -n "Session:\"${_i%%;*}\":PID=$_pid"
				kill $_pid
				echo
			    done

			fi
                        #trust for now - any garbage is removed
			connectSessionVBOX "${_pname}" "${_label}" "${_RDP_CLIENT_MODE}" "${_tcp}"  "${_conty}"
		    fi
		else
		    ABORT=1
		    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "Session already exists ID=${_IDx} - LABEL=${_label}"
		    printERR $LINENO $BASH_SOURCE ${ABORT} "Session already exists ID=${_IDx} - LABEL=${_label}"
		    printERR $LINENO $BASH_SOURCE ${ABORT} "  Choose \"REUSE\" and \"RDP\" console if you want connect-only to an"
		    printERR $LINENO $BASH_SOURCE ${ABORT} "  existing session. Requires RDP access to be enabled before."
		    gotoHell ${ABORT}
		fi
	    else
                #Server not yet running, so it is a CREATE, or a remote connection has to be established,
                #gwhich must be a server-split of an CONNECTIONFORWARDING.
		if [ "${C_CLIENTLOCATION}" !=  "-L CONNECTIONFORWARDING" ];then
                    #
                    #So, this is executed on server site, it is a DISPLAYFORWARDING
                    #
 		    printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "C_CLIENTLOCATION=${C_CLIENTLOCATION}"
		    startSessionVBOX "${_label}" "${_pname}" "${_tcp}" "${_conty}"
		else
                    #
                    #So, this is executed on the client site, different from server site,
                    #it is CONNECTIONFORWARDING to a remote server.
                    #So, dig the tunnel and connect myself.
                    #
 		    printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "C_CLIENTLOCATION=${C_CLIENTLOCATION}"
                    digLocalPort VBOX "${R_HOSTS//(*)/}" "$_label" "$_pname"

 		    local _lport=`digGetLocalPort "${_label}" VBOX`
                    if [ -z "$_lport" ];then
                        #Something went wrong!!!???                                      
			ABORT=1
			printERR $LINENO $BASH_SOURCE ${ABORT} "Cannot allocate CONNECTIONFORWARDING"
			printERR $LINENO $BASH_SOURCE ${ABORT} "  digLocalPort <VBOX> <${R_HOSTS//(*)/}> <$i>"
			gotoHell ${ABORT}
		    fi

 		    printDBG $S_VBOX ${D_UID} $LINENO $BASH_SOURCE "_lport=${_lport} i=${i}"
		    if [ -n "${_rdp}" ];then
			_RDP_CLIENT_MODE=${_lport}
		    fi
		    connectSessionVBOX "${_pname}" "${_label}" "${_lport}"  "${_tcp}" "${_conty}"
		fi
	    fi
	    ;;
    esac

    if [ $_ret -eq 0 ];then
	printDBG $S_VBOX ${D_TST} $LINENO $BASH_SOURCE "$FUNCNAME:EXIT:OPMODE=${OPMODE}:ACTION=${ACTION}:RESULT=OK"
    else
	printDBG $S_VBOX ${D_TST} $LINENO $BASH_SOURCE "$FUNCNAME:EXIT:OPMODE=${OPMODE}:ACTION=${ACTION}:RESULT=NOK"
    fi
    return $_ret
}
