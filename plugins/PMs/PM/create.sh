#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@users.sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_009
#
########################################################################
#
# Copyright (C) 2007,2008,2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

_myPKGNAME_PM_CREATE="${BASH_SOURCE}"
_myPKGVERS_PM_CREATE="01.11.009"
hookInfoAdd $_myPKGNAME_PM_CREATE $_myPKGVERS_PM_CREATE

#The call for wake up of peer by WoL.
CTYS_WOL_WAKEUP=${CTYS_WOL_WAKEUP:-$MYLIBEXECPATH/ctys-wakeup.sh}

#The timout for a wait loop, when a console is defined.
#This applies to "Soft-Consoles" only, gwhich are to be executed on the target 
#itself.
#When an IP based "Remote-IP-Console" or a Serial-Console is used, a timeout is not 
#required of course.
#
#The value is the sleep-value between failing ping and ssh-requests until success.
CTYS_WOL_WAKEUP_WAIT=${CTYS_WOL_WAKEUP_WAIT:-10}

#This is the maximum number of repetition perionds for attachment trials to the PM.
CTYS_WOL_WAKEUP_MAXTRIAL=${CTYS_WOL_WAKEUP_MAXTRIAL:-24}

#Call for Remote-IP-Console.
CONSOLE_IPC=${CONSOLE_IPC:-ffs}

#Call for Serial attached console.
CONSOLE_SERIAL=${CONSOLE_SERIAL:-ffs}



#FUNCBEG###############################################################
#NAME:
#  createConnectPM
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Creates a session and/or connects to the server.
#  This works on a single server only, thus a bulk split has to be done 
#  within the level above.
#  
#  Due to the handling of a single server, this is the level of performing
#  a WAIT for synchronous mode.
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
function createConnectPM () {
    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "\$@=${@}"

    local OPMODE=$1;shift
    local ACTION=$1;shift

    local A;
    local KEY;
    local ARG;

    local _myMAC=;
    local _myIP=;

    #machine main access, could be local-segment WoL
    local _myPMMAC=;
    local _myPMIP=;

    local _consoleType=NONE;
    local _ret=0;


    function checkPMAddressConsistency () {

	function getMACFromCache () {
	    local _VHOST="${MYLIBEXECPATH}/ctys-vhost.sh ${C_DARGS} -o MAC -p ${DBPATHLST} -s "
	    if [ -n "$DBREC" ];then
		_myMAC=`${_VHOST} R:${DBREC}`
	    else
		_VHOST="${_VHOST}  -C MACMAP "
		_VHOST="${_VHOST} E:28:1  ${_actionuserPM:+ F:44:$_actionuserPM}"
	    fi

	    if [ -n "${_myMAC}" ];then
		return 0;
	    fi

	    if [ -n "${_tcp}" ];then
		_myMAC=`${_VHOST} "${_tcp}"`
	    else
		if [ -n "${_pname}" ];then
		    _myMAC=`${_VHOST} "${_pname}"`
		else
		    if [ -n "${_uuid}" ];then
			_myMAC=`${_VHOST} "${_uuid}"`
		    else
			if [ -n "${_label}" ];then
			    _myMAC=`${_VHOST}  "${_label}"`
			else
			    if [ -n "${_fname}" ];then
				_myMAC=`${_VHOST} "${_fname}"`
			    else
				ABORT=1;
				printERR $LINENO $BASH_SOURCE ${ABORT} "Missing a MAC address of WoL target."
				printERR $LINENO $BASH_SOURCE ${ABORT} "  PNAME =${_pname}"
				printERR $LINENO $BASH_SOURCE ${ABORT} "  UUID  =${_uuid}"
				printERR $LINENO $BASH_SOURCE ${ABORT} "  LABEL =${_label}"
				printERR $LINENO $BASH_SOURCE ${ABORT} "  FNAME =${_fname}"
				printERR $LINENO $BASH_SOURCE ${ABORT} "  TCP   =${_tcp}"
				printERR $LINENO $BASH_SOURCE ${ABORT} "  MAC   =${_mac}"
				printERR $LINENO $BASH_SOURCE ${ABORT} "Verify your nameservice database with \"ctys-vhost.sh\""
 				gotoHell ${ABORT}
			    fi
			fi
		    fi
		fi
	    fi
	}


	function getTCPFromCache () {
	    local _VHOST="${MYLIBEXECPATH}/ctys-vhost.sh ${C_DARGS} -o TCP -p ${DBPATHLST} -s "
	    if [ -n "$DBREC" ];then
		_myIP=`${_VHOST} R:${DBREC}`
	    else
		_VHOST="${_VHOST}  -C MACMAP "
		_VHOST="${_VHOST} E:28:1  ${_actionuserPM:+ F:44:$_actionuserPM}"
	    fi

	    if [ -n "${_myIP}" ];then
		return 0;
	    fi

	    if [ -n "${_mac}" ];then
		_myIP=`${_VHOST} "${_mac}"`
	    else
		if [ -n "${_pname}" ];then
		    _myIP=`${_VHOST} "${_pname}"`
		else
		    if [ -n "${_uuid}" ];then
			_myIP=`${_VHOST} "${_uuid}"`
		    else
			if [ -n "${_label}" ];then
			    _myIP=`${_VHOST} "${_label}"`
			else
			    if [ -n "${_fname}" ];then
				_myIP=`${_VHOST} "${_fname}"`
			    else
				ABORT=1;
				printERR $LINENO $BASH_SOURCE ${ABORT} "Missing a TCP/IP address for WoL target."
				printERR $LINENO $BASH_SOURCE ${ABORT} "  PNAME =${_pname}"
				printERR $LINENO $BASH_SOURCE ${ABORT} "  UUID  =${_uuid}"
				printERR $LINENO $BASH_SOURCE ${ABORT} "  LABEL =${_label}"
				printERR $LINENO $BASH_SOURCE ${ABORT} "  FNAME =${_fname}"
				printERR $LINENO $BASH_SOURCE ${ABORT} "  TCP   =${_tcp}"
				printERR $LINENO $BASH_SOURCE ${ABORT} "  MAC   =${_mac}"
				printERR $LINENO $BASH_SOURCE ${ABORT} "Verify your nameservice database with \"ctys-vhost.sh\""
 				gotoHell ${ABORT}
			    fi
			fi
		    fi
		fi
	    fi
	}

	function getTCPDNSFromCache () {
	    local _VHOST="${MYLIBEXECPATH}/ctys-vhost.sh ${C_DARGS} -o DNS -p ${DBPATHLST} -s "
	    if [ -n "$DBREC" ];then
		_myDN=`${_VHOST} R:${DBREC}`
		_myDN=${_myDN%.}
	    else
		_VHOST="${_VHOST}  -C MACMAP "
		_VHOST="${_VHOST} E:28:1  ${_actionuserPM:+ F:44:$_actionuserPM}"
	    fi

	    if [ -n "${_myDN}" ];then
		return 0;
	    fi

	    if [ -n "${_mac}" ];then
		_myDN=`${_VHOST} "${_mac}"`
	    else
		if [ -n "${_pname}" ];then
		    _myDN=`${_VHOST} "${_pname}"`
		else
		    if [ -n "${_uuid}" ];then
			_myDN=`${_VHOST} "${_uuid}"`
		    else
			if [ -n "${_label}" ];then
			    _myDN=`${_VHOST} "${_label}"`
			else
			    if [ -n "${_fname}" ];then
				_myDN=`${_VHOST} "${_fname}"`
			    else
				ABORT=1;
				printERR $LINENO $BASH_SOURCE ${ABORT} "Missing a TCP/IP address for WoL target."
				printERR $LINENO $BASH_SOURCE ${ABORT} "  PNAME =${_pname}"
				printERR $LINENO $BASH_SOURCE ${ABORT} "  UUID  =${_uuid}"
				printERR $LINENO $BASH_SOURCE ${ABORT} "  LABEL =${_label}"
				printERR $LINENO $BASH_SOURCE ${ABORT} "  FNAME =${_fname}"
				printERR $LINENO $BASH_SOURCE ${ABORT} "  TCP   =${_tcp}"
				printERR $LINENO $BASH_SOURCE ${ABORT} "  MAC   =${_mac}"
				printERR $LINENO $BASH_SOURCE ${ABORT} "Verify your nameservice database with \"ctys-vhost.sh\""
 				gotoHell ${ABORT}
			    fi
			fi
		    fi
		fi
	    fi
	}

        #
        #MAC required for MAGIC-PACKET(TM) on local operations,else just for interconnection.
	if [ -n "${_mac}" ];then
	    _myMAC=$_mac
	else
	    case ${C_NSCACHELOCATE} in
		0)#off
		    ;;
		1)#both
		    getMACFromCache
		    ;;
		2)#local
		    if [ "${C_EXECLOCAL}" != 1 ];then
			getMACFromCache
		    fi
		    ;;
		3)#remote
		    if [ "${C_EXECLOCAL}" == 1 ];then
			getMACFromCache
		    fi
		    ;;
	    esac
	fi


        #
        #TCP/IP required for poll(ping/sshping) when local operations and/or CONSOLE
	if [ -n "${_tcp}" ];then
	    _myIP=$_tcp
	else
	    case ${C_NSCACHELOCATE} in
		0)#off
		    ;;
		1)#both
		    getTCPFromCache
		    ;;
		2)#local
		    if [ "${C_EXECLOCAL}" != 1 ];then
			getTCPFromCache
		    fi
		    ;;
		3)#remote
		    if [ "${C_EXECLOCAL}" == 1 ];then
			getTCPFromCache
		    fi
		    ;;
	    esac
	fi

        #
        #TCP/IP-DN/Name required for poll(ping/sshping) when local operations and/or CONSOLE
	if [ -z "${_myDN}" ];then
	    case ${C_NSCACHELOCATE} in
		0)#off
		    ;;
		1)#both
		    getTCPDNSFromCache
		    ;;
		2)#local
		    if [ "${C_EXECLOCAL}" != 1 ];then
			getTCPDNSFromCache
		    fi
		    ;;
		3)#remote
		    if [ "${C_EXECLOCAL}" == 1 ];then
			getTCPDNSFromCache
		    fi
		    ;;
	    esac
	fi
	if [ -z "${_myDN}" ];then
	    _myDN=$_tcp
	fi

	printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "_label=${_label}"
	printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "_myIP=${_myIP}"
	printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "_myDN=${_myDN}"
	printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "_myMAC=${_myMAC}"

        if [ -z "${_myMAC}" -o -z "${_myIP}" ];then
	    ABORT=2;
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Local cacheDB is missing and/or remote cacheDB is "
	    printERR $LINENO $BASH_SOURCE ${ABORT} "switched off by USER, but required for IP/MAC mapping."
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Thus one of the following has to be applied:"
	    printERR $LINENO $BASH_SOURCE ${ABORT} "1. supply TCP and MAC address on command line"
	    printERR $LINENO $BASH_SOURCE ${ABORT} "   MAC=\"${_myMAC}\""
	    printERR $LINENO $BASH_SOURCE ${ABORT} "   TCP=\"${_myIP}\""
	    printERR $LINENO $BASH_SOURCE ${ABORT} "   DN =\"${_myDN}\""
	    printERR $LINENO $BASH_SOURCE ${ABORT} "2. use local cache only"
	    printERR $LINENO $BASH_SOURCE ${ABORT} "3. create a cacheDB on the remote target"
 	    gotoHell ${ABORT}
	fi
    }


    case ${OPMODE} in
	CHECKPARAM)
            if [ -n "$C_MODE_ARGS" ];then
                #guarantee unambiguity of EXOR: (label|l)  (fname|f)  (pname|p)
		local _unambig=0;
		local _unambigCON=0;

                printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "C_MODE_ARGS=$C_MODE_ARGS"
		A=`cliSplitSubOpts ${C_MODE_ARGS}`
		for i in $A;do
		    KEY=`cliGetKey ${i}`
		    ARG=`cliGetArg ${i}`
                    if [ -n "${ARG}" \
			-o -z "${ARG}" -a "${KEY}" == "REUSE" \
			-o -z "${ARG}" -a "${KEY}" == "RECONNECT" \
			-o -z "${ARG}" -a "${KEY}" == "CONNECT" \
			-o -z "${ARG}" -a "${KEY}" == "RESUME" \
			-o -z "${ARG}" -a "${KEY}" == "WOL" \
			];then
			case $KEY in
			    CONNECT)
				let _unambigCON+=1;
				local _reuse=1;
				local _connect=1;
				printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "CONNECT=>connect only if present"
				if [ -n "${ARG}" ]; then
				    ABORT=1;
				    printERR $LINENO $BASH_SOURCE ${ABORT} "No arguments are supported for \"$KEY\""
 				    gotoHell ${ABORT}
				fi
				;;

			    REUSE)
				let _unambigCON+=1;
				local _reuse=1;
				printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "CONNECT or CREATE"
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
				printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "RECONNECT=>CANCEL running clients first"
				if [ -n "${ARG}" ]; then
				    ABORT=1;
				    printERR $LINENO $BASH_SOURCE ${ABORT} "No arguments are supported for \"$KEY\""
 				    gotoHell ${ABORT}
				fi
				;;

			    RESUME)
				local _resume=1;
				local _reuse=1;
				let _unambigCON+=1;
				printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "RESUME"
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
				printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "DBRECORD=${DBREC}"
				local _idgiven=1;
				;;
			    BASEPATH|BASE|B)
				local _base="${ARG}";
				printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "BASE=${_base}"
				;;
			    TCP|T)
				local _tcp="${ARG}";
				printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "TCP=${_tcp}"
				let _unambig+=1;
				;;
			    MAC|M)
				local _mac="${ARG}";
				printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "MAC=${_mac}"
				let _unambig+=1;
				;;
			    UUID|U)
				local _uuid="${ARG}";
 				printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "UUID=${_uuid}"
				let _unambig+=1;
				;;
			    LABEL|L)
				local _label="${ARG}";
 				printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "LABEL=${_label}"
				let _unambig+=1;
				;;
			    FILENAME|FNAME|F)
				local _fname="${ARG}";
				printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "FILENAME=${_fname}"
				;;
			    ID|I|PATHNAME|PNAME|P)
				if [ -n "${ARG##/*}" ]; then
				    ABORT=1;
				    printERR $LINENO $BASH_SOURCE ${ABORT} "PNAME has to be an absolute path, use fname else."
				    printERR $LINENO $BASH_SOURCE ${ABORT} " PNAME=${ARG}"
 				    gotoHell ${ABORT}
				fi
				local _idgiven=1;
				printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "PATHNAME=${ARG}"
				;;

                     #######################
                     # Specific attributes #  
                     #######################
			    CALLOPTS|C)
				local _callopts="${ARG//\%/ }";
				printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "CALLOPTS=${_callopts}"
				;;
			    XOPTS|X)
				local _xopts="${ARG//\%/ }";
				printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "XTOOLKITOPTS=${_xopts}"
				;;

                         ##############
			    WOL)
				if [ "${MYOS}" != "Linux" ];then
				    ABORT=1;
				    printERR $LINENO $BASH_SOURCE ${ABORT} "This version does not support WOL for ${MYOS}"
 				    gotoHell ${ABORT}
				fi
				if [ "${KEY}" == "RESUME" ];then
				    printWNG 1 $LINENO $BASH_SOURCE 0 "The Resume will be implicitly mapped to WOL for ${C_SESSIONTYPE}!"
				fi

				local _wol=1;
				printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "WOL"

				if [ -n "${ARG}" ];then
				    local _woldelay=${ARG};
				fi
                                ;;

			    IF)
				local _if=1;
				if [ -z "${ARG}" ];then
				    ABORT=1;
				    printERR $LINENO $BASH_SOURCE ${ABORT} "MIssing argument KEY=${KEY}"
 				    gotoHell ${ABORT}
				fi
				printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "${KEY}:${ARG}"
				;;

			    BROADCAST)
				local _broadcast=1;
				if [ -z "${ARG}" ];then
				    ABORT=1;
				    printERR $LINENO $BASH_SOURCE ${ABORT} "MIssing argument KEY=${KEY}"
 				    gotoHell ${ABORT}
				fi
				printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "${KEY}:${ARG}"
				;;

			    BMAC)
				local _bmac="${ARG}";
				printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "BMAC=${_bmac}"
				;;

			    PORT)
				local _port=1;
				if [ -z "${ARG}" ];then
				    ABORT=1;
				    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing argument KEY=${KEY}"
 				    gotoHell ${ABORT}
				fi
				printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "${KEY}:${ARG}"
				;;

			    PING)
				if [ -z "${ARG}" ];then
				    ABORT=1;
				    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing arguments:$KEY"
 				    gotoHell ${ABORT}
				fi
				case "${ARG}" in
				    [oO][fF][fF])_pingPM=0;;
				    *)
					if [ "${ARG//\%/}" == "${ARG}"  ];then
					    ABORT=1;
					    printERR $LINENO $BASH_SOURCE ${ABORT} "Both are mandatory:<#cnt>+<sleep>"
 					    gotoHell ${ABORT}
					fi
					_pingcntPM=${ARG%\%*};
					if [ -n "${_pingcntPM//[0-9]/}" ];then
					    ABORT=1;
					    printERR $LINENO $BASH_SOURCE ${ABORT} "Non-Numertic:<#pingcnt>=$_pingcntPM"
 					    gotoHell ${ABORT}
					fi
					_pingsleepPM=${ARG#*\%};
					if [ -n "${_pingsleepPM//[0-9]/}" ];then
					    ABORT=1;
					    printERR $LINENO $BASH_SOURCE ${ABORT} "Non-Numertic:<pingsleep>=$_pingsleepPM"
 					    gotoHell ${ABORT}
					fi
					;;
				esac
				printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "PING     =${_pingPM}"
				printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "PINGCNT  =${_pingcntPM}"
				printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "PINGSLEEP=${_pingsleepPM}"
				;;

			    SSHPING)
				if [ -z "${ARG}" ];then
				    ABORT=1;
				    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing arguments:$KEY"
 				    gotoHell ${ABORT}
				fi
				case "${ARG}" in
				    [oO][fF][fF])_sshpingPM=0;;
				    [oO][nN])_sshpingPM=1;;
				    *)
					if [ "${ARG//\%/}" == "${ARG}"  ];then
					    ABORT=1;
					    printERR $LINENO $BASH_SOURCE ${ABORT} "Both are mandatory:<#cnt>+<sleep>"
 					    gotoHell ${ABORT}
					fi
					_sshpingcntPM=${ARG%\%*};
					if [ -n "${_sshpingcntPM//[0-9]/}" ];then
					    ABORT=1;
					    printERR $LINENO $BASH_SOURCE ${ABORT} "Non-Numertic:<#sshpingcnt>=$_sshpingcntPM"
 					    gotoHell ${ABORT}
					fi
					_sshpingsleepPM=${ARG#*\%};
					if [ -n "${_sshpingsleepPM//[0-9]/}" ];then
					    ABORT=1;
					    printERR $LINENO $BASH_SOURCE ${ABORT} "Non-Numertic:<sshpingsleep>=$_sshpingsleepPM"
 					    gotoHell ${ABORT}
					fi
					;;
				esac
				printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "SSHPING     =${_sshpingPM}"
				printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "SSHPINGCNT  =${_sshpingcntPM}"
				printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "SSHPINGSLEEP=${_sshpingsleepPM}"
				;;

			    USER)
				if [ -z "${ARG}" ];then
				    ABORT=1;
				    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing arguments:$KEY"
 				    gotoHell ${ABORT}
				fi
				_actionuserPM="${ARG}";
				printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "ACTION-USER=${_actionuserPM}"
				;;


			    WAITC)
				if [ -z "${ARG}" ];then
				    ABORT=1;
				    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing arguments:$KEY"
 				    gotoHell ${ABORT}
				fi
				case "${ARG}" in
				    *)
					_waitcPM=${ARG};
					if [ -n "${_waitcPM//[0-9]/}" ];then
					    ABORT=1;
					    printERR $LINENO $BASH_SOURCE ${ABORT} "Non-Numeric $KEY:$_waitcPM"
 					    gotoHell ${ABORT}
					fi
					;;
				esac
				printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "WAITC =${_waitcPM}"
				;;

			    WAITS)
				if [ -z "${ARG}" ];then
				    ABORT=1;
				    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing arguments:$KEY"
 				    gotoHell ${ABORT}
				fi
				case "${ARG}" in
				    *)
					_waitsPM=${ARG};
					if [ -n "${_waitsPM//[0-9]/}" ];then
					    ABORT=1;
					    printERR $LINENO $BASH_SOURCE ${ABORT} "Non-Numeric $KEY:$_waitsPM"
 					    gotoHell ${ABORT}
					fi
					;;
				esac
				printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "WAITS =${_waitsPM}"
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

			    CONSOLE)
				case "`echo ${ARG}|tr '[:lower:]' '[:upper:]'`" in
				    CLI)
					;;
				    XTERM|GTERM)
					;;
				    EMACS)
					;;
				    EMACSA)
					;;
				    VNC)
					;;
				    NONE)
					;;
				    *)
					ABORT=1;
					printERR $LINENO $BASH_SOURCE ${ABORT} "UNKNOWN ARG=${ARG}"
 					gotoHell ${ABORT}
					;;
				esac

				if((_console==1));then
				    ABORT=1;
				    printERR $LINENO $BASH_SOURCE ${ABORT} "CONSOLE has to be unique."
 				    gotoHell ${ABORT}
				fi
				printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "CONSOLE=${ARG}"
				local _console=1;
				;;

			    *)
				ABORT=1;
				printERR $LINENO $BASH_SOURCE ${ABORT} "Unknown sub-opts for PM:\"${KEY}\""
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

                #1. validate ambiguity
		if [ "${_unambigCON}" -gt 1 ];then
		    ABORT=1;
		    printERR $LINENO $BASH_SOURCE ${ABORT} "ambiguous sub-opts have to be EXOR"
 		    gotoHell ${ABORT}
		fi

                #Least required parameters
		if((_unambig==0&&_idgiven!=1));then
		    ABORT=1;
		    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing parameter, at least one of the following is required:"
		    printERR $LINENO $BASH_SOURCE ${ABORT} "  TCP|MAC|UUID|LABEL|DBREC"
 		    gotoHell ${ABORT}
		fi

		if((_broadcast==1&&_if==1));then
		    ABORT=1;
		    printERR $LINENO $BASH_SOURCE ${ABORT} "Only supported none or one of:BROADCAST or IF"
 		    gotoHell ${ABORT}
		fi

		if((_broadcast!=1&&_port==1));then
		    ABORT=1;
		    printERR $LINENO $BASH_SOURCE ${ABORT} "PORT is only supported with BROADCAST"
 		    gotoHell ${ABORT}
		fi
 		if [ -z "$CALLERJOB"  -a -n "${DBREC}" -a -z "${_pname}" ];then
		    if [ -n "${_base}" -o -n "${_tcp}" -o -n "${_mac}" -o -n "${_uuid}" \
			-o -n "${_label}" -o -n "${_fname}" -o -n "${_pname}" ];then
			printWNG 1 $LINENO $BASH_SOURCE 1 "The provided DB index has priority for address"
			printWNG 1 $LINENO $BASH_SOURCE 1 "if matched the remaining address parameters are ignored"
		    fi
		fi
		    fi
		    ;;

	ASSEMBLE)
            #
            #specifics for relay-ops
            #
	    local _tmpPref=" CALLDUMMY -t PM -a ${C_MODE}=";
	    local _tmpCallSim="${_tmpPref}${C_MODE_ARGS} ";
	    local _call=$_tmpCallSim;
	    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:CALL-CACHE-DUMMY=<${_call}>"
	    _call=`cacheGetMachineAddressFromCall MACHINEADDRESS NONE $_tmpCallSim`
	    _ret=$?;
	    if [ $_ret -eq 0 ];then
		printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:CALL-CACHE-RESOLVED=<${_call}>"
		_call=${_call# *$_tmpPref};
		printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:C_MODE_ARGS=<${C_MODE_ARGS}>"
		_call="${_call// /}";
		C_MODE_ARGS="${_call:+$_call,}${C_MODE_ARGS}";
	    fi
	    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:C_MODE_ARGS=<${C_MODE_ARGS}>"
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
		    -o -z "${ARG}" -a "${KEY}" == "REUSE" \
		    -o -z "${ARG}" -a "${KEY}" == "RECONNECT" \
  		    -o -z "${ARG}" -a "${KEY}" == "CONNECT" \
		    -o -z "${ARG}" -a "${KEY}" == "RESUME" \
		    -o -z "${ARG}" -a "${KEY}" == "WOL" \
		    ];then
		    case $KEY in
			CONNECT)
                            local _connect=1;
                            local _reuse=1;
			    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "CONNECT"
			    ;;
			REUSE)
                            local _reuse=1;
			    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "REUSE=>try CONNECT before CREATE"
			    ;;
			RECONNECT)
                            local _reuse=1;
                            local _reconnect=1;
			    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "RECONNECT=>CANCEL running clients first"
			    ;;
			RESUME)
                            local _resume=1;
			    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "REUSE=>try CONNECT before CREATE"
			    ;;


                  #####################
                  # <machine-address> #
                  #####################
			DBRECORD|DBREC|DR)
			    local DBREC="${ARG}";
			    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "DBRECORD=${DBREC}"
			    local _idgiven=1;
			    ;;
			BASEPATH|BASE|B)
                            #can be checked now
                            local _base="${ARG}";
			    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "BASE=${_base}"
                            for i in ${_base//\%/ };do
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
			    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "TCP=${_tcp}"
			    ;;
			MAC|M)
			    local _mac="${ARG}";
			    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "MAC=${_mac}"
			    ;;
			UUID|U)
			    local _uuid="${ARG}";
 			    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "UUID=${_uuid}"
			    ;;
			LABEL|L)
                            local _label="${ARG}";
 			    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "LABEL=${_label}"
			    ;;
			FILENAME|FNAME|F)
                            local _fname="${ARG}";
			    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "FILENAME=${_fname}"
			    ;;
			ID|PATHNAME|PNAME|P)
                            if [ ! -f "${ARG}" ];then
				ABORT=1;
				printERR $LINENO $BASH_SOURCE ${ABORT} "Missing given file or access permission for ID/PNAME"
				printERR $LINENO $BASH_SOURCE ${ABORT} "  ID=${ARG}"
 				gotoHell ${ABORT}
                            fi
                            local _pname="${_pname:+$_pname|}${ARG}";
			    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "RANGE:PATHNAME=${_pname}"
			    ;;


                   ##################
                   # remote options #
                   ##################
			CALLOPTS|C)
			    local _callopts="${ARG//\%/ }";
			    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "CALLOPTS=${_callopts}"
                            C_SESSIONIDARGS="${_callopts}"
			    ;;
			XOPTS|X)
			    local _xopts="${ARG//\%/ }";
			    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "XTOOLKITOPTS=${_xopts}"
                            C_XTOOLKITOPTS="${_xopts}"
			    ;;
			BROADCAST)
			    local _broadcast=${ARG};
			    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "_broadcast=${_broadcast}"
			    ;;
			PORT)
			    local _broadcastPort=${ARG};
			    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "_broadcastPort=${_broadcastPort}"
			    ;;
			BMAC)
			    local _bmac="${ARG}";
			    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "BMAC=${_bmac}"
			    ;;
			IF)
			    local _if=${ARG};
			    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "_if=${_if}"
			    ;;

			PING)
			    if [ -z "${ARG}" ];then
				ABORT=1;
				printERR $LINENO $BASH_SOURCE ${ABORT} "Missing arguments:$KEY"
 				gotoHell ${ABORT}
			    fi
			    case "${ARG}" in
				[oO][fF][fF])_pingPM=0;;
				*)
				    if [ "${ARG//\%/}" == "${ARG}"  ];then
					ABORT=1;
					printERR $LINENO $BASH_SOURCE ${ABORT} "Both are mandatory:<#cnt>+<sleep>"
 					gotoHell ${ABORT}
				    fi
				    _pingcntPM=${ARG%\%*};
				    if [ -n "${_pingcntPM//[0-9]/}" ];then
					ABORT=1;
					printERR $LINENO $BASH_SOURCE ${ABORT} "Non-Numertic:<#pingcnt>=$_pingcntPM"
 					gotoHell ${ABORT}
				    fi
				    _pingsleepPM=${ARG#*\%};
				    if [ -n "${_pingsleepPM//[0-9]/}" ];then
					ABORT=1;
					printERR $LINENO $BASH_SOURCE ${ABORT} "Non-Numertic:<pingsleep>=$_pingsleepPM"
 					gotoHell ${ABORT}
				    fi
				    ;;
			    esac
			    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "PING     =${_pingPM}"
			    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "PINGCNT  =${_pingcntPM}"
			    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "PINGSLEEP=${_pingsleepPM}"
			    ;;

			SSHPING)
			    if [ -z "${ARG}" ];then
				ABORT=1;
				printERR $LINENO $BASH_SOURCE ${ABORT} "Missing arguments:$KEY"
 				gotoHell ${ABORT}
			    fi
			    case "${ARG}" in
				[oO][fF][fF])_sshpingPM=0;;
				[oO][nN])_sshpingPM=1;;
				*)
				    if [ "${ARG//\%/}" == "${ARG}"  ];then
					ABORT=1;
					printERR $LINENO $BASH_SOURCE ${ABORT} "Both are mandatory:<#cnt>+<sleep>"
 					gotoHell ${ABORT}
				    fi
				    _sshpingcntPM=${ARG%\%*};
				    if [ -n "${_sshpingcntPM//[0-9]/}" ];then
					ABORT=1;
					printERR $LINENO $BASH_SOURCE ${ABORT} "Non-Numertic:<#sshpingcnt>=$_sshpingcntPM"
 					gotoHell ${ABORT}
				    fi
				    _sshpingsleepPM=${ARG#*\%};
				    if [ -n "${_sshpingsleepPM//[0-9]/}" ];then
					ABORT=1;
					printERR $LINENO $BASH_SOURCE ${ABORT} "Non-Numertic:<sshpingsleep>=$_sshpingsleepPM"
 					gotoHell ${ABORT}
				    fi
				    ;;
			    esac
			    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "SSHPING     =${_sshpingPM}"
			    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "SSHPINGCNT  =${_sshpingcntPM}"
			    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "SSHPINGSLEEP=${_sshpingsleepPM}"
			    ;;

			USER)
			    if [ -z "${ARG}" ];then
				ABORT=1;
				printERR $LINENO $BASH_SOURCE ${ABORT} "Missing arguments:$KEY"
 				gotoHell ${ABORT}
			    fi
			    _actionuserPM="${ARG}";
			    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "ACTION-USER=${_actionuserPM}"
			    ;;

			WAITC)
			    if [ -z "${ARG}" ];then
				ABORT=1;
				printERR $LINENO $BASH_SOURCE ${ABORT} "Missing arguments:$KEY"
 				gotoHell ${ABORT}
			    fi
			    case "${ARG}" in
				*)
				    _waitcPM=${ARG};
				    if [ -n "${_waitcPM//[0-9]/}" ];then
					ABORT=1;
					printERR $LINENO $BASH_SOURCE ${ABORT} "Non-Numeric $KEY:$_waitcPM"
 					gotoHell ${ABORT}
				    fi
				    ;;
			    esac
			    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "WAITC =${_waitcPM}"
			    ;;

			WAITS)
			    if [ -z "${ARG}" ];then
				ABORT=1;
				printERR $LINENO $BASH_SOURCE ${ABORT} "Missing arguments:$KEY"
 				gotoHell ${ABORT}
			    fi
			    case "${ARG}" in
				*)
				    _waitsPM=${ARG};
				    if [ -n "${_waitsPM//[0-9]/}" ];then
					ABORT=1;
					printERR $LINENO $BASH_SOURCE ${ABORT} "Non-Numeric $KEY:$_waitsPM"
 					gotoHell ${ABORT}
				    fi
				    ;;
			    esac
			    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "WAITS =${_waitsPM}"
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

			WOL)
			    local _wol=1;
			    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "WOL"
			    if [ -n "${ARG}" ];then
				local _woldelay=${ARG};
			    fi
			    ;;
			CONSOLE)
			    case "`echo ${ARG}|tr '[:lower:]' '[:upper:]'`" in
				CLI)_consoleType=CLI;;
				EMACS)_consoleType=EMACS;;
				EMACSA)_consoleType=EMACSA;;
				GTERM)_consoleType=GTERM;;
				XTERM)_consoleType=XTERM;;
				VNC)_consoleType=VNC;;
				NONE)_consoleType=NONE;;
				*)
				    ABORT=1;
				    printERR $LINENO $BASH_SOURCE ${ABORT} "UNKNOWN ARG=${ARG}"
 				    gotoHell ${ABORT}
				    ;;
			    esac
			    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "CONSOLE=${ARG}"
			    local _console=1;
			    ;;

			*)
			    ABORT=1;
			    printERR $LINENO $BASH_SOURCE ${ABORT} "Unexpected sub-opts for PM:${KEY}"
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


            #
	    checkPMAddressConsistency


	    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "BROADCAST=${_broadcast}"
	    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "BROADCAST-PORT=${_broadcastPort}"
	    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "BROADCAST-MAC=${_bmac}"
	    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "IP=${_myIP}"
	    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "MAC=${_myMAC}"


	    if [ -n "$_broadcast" ];then
		if [ -z "$_bmac" ];then
		    ABORT=1;
		    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing MAC address for broadcast packet."
		    printERR $LINENO $BASH_SOURCE ${ABORT} "_broadcast = ${_broadcast}"
 		    gotoHell ${ABORT}
		fi
	    fi

 	    local _myPM=${_myIP}

	    if [ "$MYHOST" != "$_myDN" -a "$MYHOST" != "$_myIP"  ];then
                #now TCP/IP address is available, short it up now if REUSE
		local _pingok=1;
   		printFINALCALL 0  $LINENO $BASH_SOURCE "WAIT-TIMER:DomU(${_label},CTYS_PING_ONE_MAXTRIAL_PM,CTYS_PING_ONE_WAIT_PM)" "netWaitForPing \"${_myPM}\" \"3\" \"1\""
		netWaitForPing "${_myPM}" 3 1
		_pingok=$?
		if [ $_pingok -eq 0 ];then
		    if [ "$_reuse" == 1 ];then
			printINFO 1 $LINENO $BASH_SOURCE ${ABORT} "REUSE of running machine:${_myPM}(${_myIP})"
		    else
			ABORT=1;
			printERR $LINENO $BASH_SOURCE ${ABORT} "Remote machine is already running, try \"REUSE\" if you want so."
			printERR $LINENO $BASH_SOURCE ${ABORT} " => ${_myPM}(${_myIP})"
 			gotoHell ${ABORT}
		    fi
		fi

                #Not yet running
		if [ $_pingok -ne 0 ];then
                    #wake-up remote PM
		    local _wolret=0;
		    local _callDbg=;
		    if [ -n "${_broadcast}" ];then
			printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "BROADCAST=${_broadcast}"
			printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "PORT     =${_broadcastPort}"
			if [ -n "${_broadcastPort}" ];then
 			    _callDbg="${CTYS_WOL_WAKEUP} ${C_DARGS} -t ${_broadcast} ${_broadcastPort} ${C_NOEXEC:+ -n} ${_bmac}"
			    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "_callDbg=${_callDbg}"
			    printFINALCALL 0  $LINENO $BASH_SOURCE "FINAL-EXEC:WOL-WAKEUP(${_label})" "${_callDbg}"
			    ${_callDbg}
			    _wolret=$?
			    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "_callDbg=>${_wolret}"
			else
 			    _callDbg="${CTYS_WOL_WAKEUP} ${C_DARGS} -t ${_broadcast} ${C_NOEXEC:+ -n} ${_bmac}"
			    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "_callDbg=${_callDbg}"
			    printFINALCALL 0  $LINENO $BASH_SOURCE "FINAL-EXEC:WOL-WAKEUP(${_label})" "${_callDbg}"
			    ${_callDbg}
			    _wolret=$?
			    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "_callDbg=>${_wolret}"
			fi
		    else
			_callDbg="${CTYS_WOL_WAKEUP} ${C_DARGS} -i ${CTYS_WOL_WAKEUPIF} ${C_NOEXEC:+ -n} ${_myMAC}"
			printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "_callDbg=${_callDbg}"
			printFINALCALL 0  $LINENO $BASH_SOURCE "FINAL-EXEC:WOL-WAKEUP(${_label})" "${_callDbg}"
			${_callDbg}
			_wolret=$?
			printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "_callDbg=>${_wolret}"
		    fi
		    if [ "${_wolret}" != "0" ];then
			ABORT=1
			printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "Error for WOL"
			gotoHell ${ABORT}
		    fi

		    if [ -n "${C_NOEXEC}" ];then
			printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "NOEXEC \"-n\" is set, terminating."
			gotoHell 0
		    fi

		    if [ -n "${_woldelay}" ];then
			printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "_woldelay=${_woldelay}"
			sleep ${_woldelay};
		    fi


                    #wait for basic network stack - remember, it's not sufficient!!!
   		    printFINALCALL 0  $LINENO $BASH_SOURCE "WAIT-TIMER:DomU(${_label},CTYS_PING_ONE_MAXTRIAL_PM,CTYS_PING_ONE_WAIT_PM)" "netWaitForPing \"${_myPM}\" \"${_pingcntPM}\" \"${_pingsleepPM}\""
		    netWaitForPing "${_myPM}" "${_pingcntPM}" "${_pingsleepPM}"
		    if [ $? != 0 ];then
			ABORT=1
			printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "Start timed out:netWaitForPing"
			printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "  PM =${_myPM}"

			printWNG 1 $LINENO $BASH_SOURCE 0 "${_VHOST}  <${_label}> <${MYHOST}>  <${_pname}>"
			printWNG 1 $LINENO $BASH_SOURCE 0 "<${_myPM}> <${_pingcntPM}> <${_pingsleepPM}>"

			printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "  IP =${_myIP}"
			printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "  MAC=${_myMAC}"

			gotoHell ${ABORT}
		    else
 			printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:Accessible by ping:${_myPM}"
   			printFINALCALL 0  $LINENO $BASH_SOURCE "WAIT-TIMER:Accessible by ping:${_myPM}"
		    fi
		fi

                #
                #wait for ssh login. requires access permissions - remember, this is sufficient!
                #
		if [ "${_sshpingPM}" == 1 ];then
   		    printFINALCALL 0  $LINENO $BASH_SOURCE "WAIT-TIMER:$_myPM(${_label},CTYS_SSHPING_ONE_MAXTRIAL_PM,CTYS_SSHPING_ONE_WAIT_PM)" "netWaitForSSH \"${_myPM}\" \"${_sshpingcntPM}\" \"${_sshpingsleepPM}\" \"${_actionuserPM}\" \"${C_AGNTFWD:+-A}\""
		    netWaitForSSH "${_myPM}" "${_sshpingcntPM}" "${_sshpingsleepPM}" "${_actionuserPM}" "${C_AGNTFWD:+-A}"
		    if [ $? != 0 ];then
			printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "Start timed out:netWaitForSSH"
			printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "  PM =${_myPM}"

			printWNG 1 $LINENO $BASH_SOURCE 0 "${_VHOST}  <${_label}> <${MYHOST}>  <${_pname}>"
			printWNG 1 $LINENO $BASH_SOURCE 0 "<${_myPM}> <${_sshpingcntPM}> <${_sshpingsleepPM}>"

			printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "  IP =${_myIP}"
			printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "  MAC=${_myMAC}"
			gotoHell 0
		    else
 			printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:Accessible by ssh:${_myPM}"
   			printFINALCALL 0  $LINENO $BASH_SOURCE "WAIT-TIMER:Accessible by ssh:${_myPM}"
		    fi
		fi
	    fi

            #OK, PM seems to be running and accessible soon, now establish a console if requested.

            if [ -n "${_console}" ];then
		printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:CTYS_WOL_WAKEUP_WAIT    =$CTYS_WOL_WAKEUP_WAIT"
		printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:CTYS_WOL_WAKEUP_MAXTRIAL=$CTYS_WOL_WAKEUP_MAXTRIAL"

                #forward locals, because they are remote for the caller.
		local _args1=;
		_args1="${_args1} ${C_DARGS} "
		_args1="${_args1} ${C_GEOMETRY:+ -g $C_GEOMETRY} "
		_args1="${_args1} ${C_ALLOWAMBIGIOUS:+ -A $C_ALLOWAMBIGIOUS} "
		_args1="${_args1} ${C_SSH_PSEUDOTTY:+ -z $C_SSH_PSEUDOTTY} "

		_args1="${_args1} ${C_XTOOLKITOPTS} "

		local _args=" -j ${CALLERJOBID} ";

		local i1=0;
                #once more for sshd to start after network
		sleep ${CTYS_WOL_WAKEUP_WAIT};

		printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:after-trial-ssh:$i1"
		case ${_consoleType} in
		    NONE)
			;;
		    CLI)
			_args1="${_args1} -b 0 "
			_args="${_args} -t CLI -a create=l:CONSOLE "
			if [ -n "$C_DARGS" ];then
			    _args="${MYLIBEXECPATH}/ctys.sh ${_args} ${_args1} ${_myPM}($C_DARGS)"
			else
			    _args="${MYLIBEXECPATH}/ctys.sh ${_args} ${_args1} ${_myPM}"
			fi
			printDBG $S_PM ${D_FLOW} $LINENO $BASH_SOURCE "_args=${_args}"
			printFINALCALL 0  $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL:" "${_args}"
 			${_args}
			;;
		    GTERM)
			if [ "${C_STACK}" == 1 ];then
			    _args1="${_args1} -b STACK "
			else
			    _args1="${_args1} ${C_ASYNC:+ -b $C_ASYNC} "
			fi
			_args="${_args} -t X11 -a create=l:CONSOLE,console:gterm"
			if [ -n "$C_DARGS" ];then
			    _args="${MYLIBEXECPATH}/ctys.sh ${_args} ${_args1} ${_myPM}($C_DARGS)"
			else
			    _args="${MYLIBEXECPATH}/ctys.sh ${_args} ${_args1} ${_myPM}"
			fi
			printDBG $S_PM ${D_FLOW} $LINENO $BASH_SOURCE "_args=${_args}"
			printFINALCALL 0  $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL:" "${_args}"
			${_args}
			;;
		    XTERM)
			if [ "${C_STACK}" == 1 ];then
			    _args1="${_args1} -b STACK "
			else
			    _args1="${_args1} ${C_ASYNC:+ -b $C_ASYNC} "
			fi
			_args="${_args} -t X11 -a create=l:CONSOLE,console:xterm"
			if [ -n "$C_DARGS" ];then
			    _args="${MYLIBEXECPATH}/ctys.sh ${_args} ${_args1} ${_myPM}'($C_DARGS)'"
			else
			    _args="${MYLIBEXECPATH}/ctys.sh ${_args} ${_args1} ${_myPM}"
			fi
			printDBG $S_PM ${D_FLOW} $LINENO $BASH_SOURCE "_args=${_args}"
			printFINALCALL 0  $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL:" "${_args}"
			${_args}
			;;
		    VNC)
			if [ "${C_STACK}" == 1 ];then
			    _args1="${_args1} -b STACK "
			else
			    _args1="${_args1} ${C_ASYNC:+ -b $C_ASYNC} "
			fi
			_args="${_args} -t VNC -a create=l:CONSOLE,waits:5"
			if [ -n "$C_DARGS" ];then
			    _args="${MYLIBEXECPATH}/ctys.sh ${_args} ${_args1} ${_myPM}($C_DARGS)"
			else
			    _args="${MYLIBEXECPATH}/ctys.sh ${_args} ${_args1} ${_myPM}"
			fi
			printDBG $S_PM ${D_FLOW} $LINENO $BASH_SOURCE "_args=${_args}"
			printFINALCALL 0  $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL:" "${_args}"
			${_args}

			;;
		    EMACS)
			if [ "${C_STACK}" == 1 ];then
			    _args1="${_args1} -b STACK "
			else
			    _args1="${_args1} ${C_ASYNC:+ -b $C_ASYNC} "
			fi
			_args="${_args} -t X11 -a create=l:CONSOLE,console:emacs"
			if [ -n "$C_DARGS" ];then
			    _args="${MYLIBEXECPATH}/ctys.sh ${_args} ${_args1} ${_myPM}($C_DARGS)"
			else
			    _args="${MYLIBEXECPATH}/ctys.sh ${_args} ${_args1} ${_myPM}"
			fi
			printDBG $S_PM ${D_FLOW} $LINENO $BASH_SOURCE "_args=${_args}"
			printFINALCALL 0  $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL:" "${_args}"
			${_args}
			;;
		    EMACSA)
			if [ "${C_STACK}" == 1 ];then
			    _args1="${_args1} -b STACK "
			else
			    _args1="${_args1} ${C_ASYNC:+ -b $C_ASYNC} "
			fi
			_args="${_args} -t X11 -a create=l:CONSOLE,console:emacsa"
			if [ -n "$C_DARGS" ];then
			    _args="${MYLIBEXECPATH}/ctys.sh ${_args} ${_args1} ${_myPM}($C_DARGS)"
			else
			    _args="${MYLIBEXECPATH}/ctys.sh ${_args} ${_args1} ${_myPM}"
			fi
			printDBG $S_PM ${D_FLOW} $LINENO $BASH_SOURCE "_args=${_args}"
			printFINALCALL 0  $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL:" "${_args}"
			${_args}
			;;
		    *)
			printWNG 1 $LINENO $BASH_SOURCE 0 "Try generic CONSOLE plugin:\"-t ${_consoleType}\""
			printFINALCALL 0  $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL:" "${MYLIBEXECPATH}/ctys.sh -t ${_consoleType} -a create=l:CONSOLE ${C_DARGS} ${_myPM}\"(C_DARGS)\""
			${MYLIBEXECPATH}/ctys.sh -t ${_consoleType} -a create=l:CONSOLE ${C_DARGS} ${_myPM}"(C_DARGS)"
			;;
		esac
		[ $? -eq 0 ]&&break;
		printFINALCALL 0  $LINENO $BASH_SOURCE "WAIT-TIMER:WOL(${_label},CTYS_WOL_WAKEUP_WAIT)" "sleep ${CTYS_WOL_WAKEUP_WAIT}"
		sleep ${CTYS_WOL_WAKEUP_WAIT};
		((i1++));
	    fi
	    ;;
    esac

    if [ "$_ret" -eq 0 ];then
	printDBG $S_PM ${D_TST} $LINENO $BASH_SOURCE "$FUNCNAME:EXIT:OPMODE=${OPMODE}:ACTION=${ACTION}:RESULT=OK"
    else
	printDBG $S_PM ${D_TST} $LINENO $BASH_SOURCE "$FUNCNAME:EXIT:OPMODE=${OPMODE}:ACTION=${ACTION}:RESULT=NOK"
    fi
    return $_ret
}

