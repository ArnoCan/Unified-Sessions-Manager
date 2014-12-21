#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_006alpha
#
########################################################################
#
# Copyright (C) 2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

_myPKGNAME_RDP_CREATE="${BASH_SOURCE}"
_myPKGVERS_RDP_CREATE="01.11.006alpha"
hookInfoAdd $_myPKGNAME_RDP_CREATE $_myPKGVERS_RDP_CREATE
_myPKGBASE_RDP_CREATE="`dirname ${_myPKGNAME_RDP_CREATE}`"

export INSECURE=;


#FUNCBEG###############################################################
#NAME:
#  createConnectRDP
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
function createConnectRDP () {
    local OPMODE=$1;shift
    local ACTION=$1;shift

    local A;
    local KEY;
    local ARG;

    unset _VNATIVE;

    case ${OPMODE} in
        CHECKPARAM)
            printDBG $S_RDP ${D_UID} $LINENO $BASH_SOURCE "C_MODE_ARGS=$C_MODE_ARGS"
	    A=`cliSplitSubOpts ${C_MODE_ARGS}`;
            for i in $A;do                         
		KEY=`cliGetKey ${i}`
		ARG=`cliGetArg ${i}`
		case $KEY in
                    CONNECT)
			local _connect=1;
			if [ -n "${ARG}" ]; then
			    ABORT=1;
			    printERR $LINENO $BASH_SOURCE ${ABORT} "No arguments are supported for \"$KEY\""
 			    gotoHell ${ABORT}
			fi
			;;

                    RECONNECT)
			local _reconnect=1;
			if [ -n "${ARG}" ]; then
			    ABORT=1;
			    printERR $LINENO $BASH_SOURCE ${ABORT} "No arguments are supported for \"$KEY\""
 			    gotoHell ${ABORT}
			fi
			;;



        #####################
        # <machine-address> #
        #####################

                    L|LABEL)
			_LABEL="${ARG}";
			;;

                    I|ID)
			if [ -z "$_connect" ];then
			    ABORT=1
			    printERR $LINENO $BASH_SOURCE ${ABORT} "${ACTION}:Suboption ${KEYXS} NOT supported"
			    gotoHell ${ABORT}
			fi
			_ID="${_ID} ${ARG}";
			if [ -n "${ARG}" -a -n "${ARG//[0-9]/}" ];then
			    ABORT=1
			    printERR $LINENO $BASH_SOURCE ${ABORT} "Integers only:\"${ARG}\""
			    gotoHell ${ABORT}
			fi
			;;


        #######################
        # Specific attributes #  
        #######################

		    CONSOLE)
			local _conty="`echo ${ARG}|tr '[:lower:]' '[:upper:]'`";
			printDBG $S_RDP ${D_UID} $LINENO $BASH_SOURCE "_conty=${_conty}"
			case ${_conty} in
			    RDESKTOP)
				;;

			    *)
				ABORT=1;
				printERR $LINENO $BASH_SOURCE ${ABORT} "UNKNOWN ARG=${ARG}"
 				gotoHell ${ABORT}
				;;				  
			esac
			local _console=$_conty;
			printDBG $S_RDP ${D_UID} $LINENO $BASH_SOURCE "CONSOLE=${ARG}"
			;;

                    INSECURE)
			INSECURE="${ARG}";
			;;


                    RDPPORT)
			if [ -n "${_VNATIVE}" ];then
			    ABORT=1
			    printERR $LINENO $BASH_SOURCE ${ABORT} "RDP native port is supported once per call only"
			    gotoHell ${ABORT}
			fi
			if [ -n "${ARG}" -a -n "${ARG//[0-9]/}" ];then
			    ABORT=1
			    printERR $LINENO $BASH_SOURCE ${ABORT} "RDP native port requires integers only:\"${ARG}\""
			    gotoHell ${ABORT}
			fi
			_VNATIVE="${ARG}";
			;;

		    *)
			ABORT=1
			printERR $LINENO $BASH_SOURCE ${ABORT} "Unknown suboption:<${i}>"
			printERR $LINENO $BASH_SOURCE ${ABORT} "  Probably the key is missing \"<key>:<arg>\""
			gotoHell ${ABORT}
			;;
		esac
            done
            printDBG $S_RDP ${D_MAINT} $LINENO $BASH_SOURCE "_ID      = <${_ID}>"
            printDBG $S_RDP ${D_MAINT} $LINENO $BASH_SOURCE "_LABEL   = <${_LABEL}>"
            printDBG $S_RDP ${D_MAINT} $LINENO $BASH_SOURCE "_RDP     = <${_RDP}>"
            printDBG $S_RDP ${D_MAINT} $LINENO $BASH_SOURCE "INSECURE = <${INSECURE}>"
            printDBG $S_RDP ${D_MAINT} $LINENO $BASH_SOURCE "_RDPBASE = <${_RDPBASE}>"
            printDBG $S_RDP ${D_MAINT} $LINENO $BASH_SOURCE "_VNATIVE = <${_VNATIVE}>"

	    if [ -z "${_LABEL}" ];then
		ABORT=1;
		printERR $LINENO $BASH_SOURCE ${ABORT} "Missing mandatory suboption: LABEL"
		gotoHell ${ABORT}
	    fi

	    if [ -z "${_VNATIVE}" ];then
		ABORT=1;
		printERR $LINENO $BASH_SOURCE ${ABORT} "Missing mandatory suboption: RDPPORT"
		gotoHell ${ABORT}
	    fi

            unset _ID;
            unset _LABEL;
            unset _VNATIVE;
	    ;;

	ASSEMBLE)
	    ;;

	EXECUTE)
	    if [ -n "${R_TEXT}" ];then
		echo "${R_TEXT}"
	    fi
            _LABEL="";

            printDBG $S_RDP ${D_UID} $LINENO $BASH_SOURCE "C_MODE_ARGS=$C_MODE_ARGS"
	    A=`cliSplitSubOpts ${C_MODE_ARGS}`;
	    for i in $A;do
		KEY=`cliGetKey ${i}`
		ARG=`cliGetArg ${i}`
		case $KEY in
                    CONNECT)
			local _connect=1;
			;;

                    RECONNECT)
			hookPackage "${_myPKGBASE_RDP}/cancel.sh"
			local _reconnect=1;
			;;

         #########

                    L|LABEL)
#			_LABEL="${_LABEL} ${ARG}";
			_LABEL="${ARG}";
			;;

                    I|ID)
			_ID="${_ID} ${ARG}";
                        #Yes this call saves "a real amount" of code, even though beeing redundant itself!
  			local _IDlbl1=`fetchLabel4ID "${_ID}"`
   			local _ID1=`fetchID4Label "${_IDlbl1}"`

			if [ -n "${_ID1// /}"  -a "${_ID// /}" != "${_ID1// /}" ];then
			    ABORT=1
			    printERR $LINENO $BASH_SOURCE ${ABORT} "\"${_ID}\" seems to be ambiguous, can not be resolved"
			    printERR $LINENO $BASH_SOURCE ${ABORT} "."
			    printERR $LINENO $BASH_SOURCE ${ABORT} "  ID=\"${_ID}\" => LABEL=\"${_IDlbl1}\" => ID1=\"${_ID1}\"(first match)"
			    printERR $LINENO $BASH_SOURCE ${ABORT} "  => ID=\"${_ID}\" != ID1=\"${_ID1}\""
			    printERR $LINENO $BASH_SOURCE ${ABORT} "."
			    printERR $LINENO $BASH_SOURCE ${ABORT} "Delete ambiguous processes manually, or use \"ALL\"."
			    gotoHell ${ABORT}
			fi

   			local _IDlbl="${_IDlbl} ${_IDlbl1}"
			printDBG $S_RDP ${D_UID} $LINENO $BASH_SOURCE "_ID=${_ID}"
			printDBG $S_RDP ${D_UID} $LINENO $BASH_SOURCE "_IDlbl=${_IDlbl}"
			;;

          #########

		    CONSOLE)
			local _conty="`echo ${ARG}|tr '[:lower:]' '[:upper:]'`";
			printDBG $S_RDP ${D_UID} $LINENO $BASH_SOURCE "_conty=${_conty}"
			case ${_conty} in
			    RDESKTOP)
				;;

			    *)
				ABORT=1;
				printERR $LINENO $BASH_SOURCE ${ABORT} "UNKNOWN ARG=${ARG}"
 				gotoHell ${ABORT}
				;;				  
			esac
			local _console=$_conty;
			printDBG $S_RDP ${D_UID} $LINENO $BASH_SOURCE "CONSOLE=${ARG}"
			;;

                    INSECURE)
			INSECURE="${ARG}";
			;;

                    RDPPORT)
			_VNATIVE="${ARG}";
			printDBG $S_RDP ${D_UID} $LINENO $BASH_SOURCE "_VNATIVE=${_VNATIVE// /}"
			;;

         #########
		    *)
			ABORT=1
			printERR $LINENO $BASH_SOURCE ${ABORT} "Unknown suboption:<${i}>"
			gotoHell ${ABORT}
			;;
		esac
	    done


            #perform session creation
	    printDBG $S_RDP ${D_UID} $LINENO $BASH_SOURCE "Start session=${i}"
  	    local _ID=`echo ${i}|sed 's/^.*\(...\)$/\1/'`
	    _ID=`removeLeadZeros "${_ID}"`
            if [ -z "${_VNATIVE}" ];then
 		local _LBL="${_LABEL}"
	    else
 		if [ -n "${i//[0-9]}" -a "${i%%???}" == "${i%[0-9][0-9][0-9]}" ];then
 		    local _LBL="${i%[0-9][0-9][0-9]}"
		else
 		    local _LBL="${i}"
		fi
	    fi
	    _LBL=${_LBL// }
	    printDBG $S_RDP ${D_UID} $LINENO $BASH_SOURCE "_LBL=${_LBL}  _ID=${_ID}"

            #Might be executed on remote host, not the calling station
	    printDBG $S_RDP ${D_UID} $LINENO $BASH_SOURCE "C_CLIENTLOCATION=${C_CLIENTLOCATION}"
            if [ -z "${_VNATIVE}" ];then
                #check for running local server
 		local _IDx=`fetchDisplay4Label "${i}"`
	    else
                #don't poison workflow, if splitted client server requested
                #setting it here goes into local, assumption is that a given port always
                #is for an existing and running application only.
		if [ "${C_CLIENTLOCATION}" !=  "-L CONNECTIONFORWARDING" ];then
 		    local _IDx=${_VNATIVE}
		fi
	    fi

	    printDBG $S_RDP ${D_MAINT} $LINENO $BASH_SOURCE " Session-Identifier: ${i}->${_ID} ${_LBL} ->${_IDx}"
            #check whether server is already running(local or remote)
            #therfore a peer must be present
            #but nevertheless, when doing a RECONNECT on a one-shot-stub things might be different
	    if [ -n "${_IDx}" ];then
                #Server is already running, so it is a potential CONNECT.
		if [ -z "${_reconnect}" -a -z "${_connect}" -a -z "${_reuse}"  ];then
		    _connect=1;
		fi

                #for reconnect, actually for vnc only required in shared-mode,
                #this one instance replaces all active clients
		if [ -n "${_reconnect}"  ];then
		    cancelRDP CLIENT POWEROFF "i:${_IDx}"
		fi

                #perform only if REUSE is present
		if [ "${C_CLIENTLOCATION}" !=  "-L SERVERONLY" ];then
		    if [ -n "${_reconnect}" -o -n "${_connect}" -o -n "${_reuse}" ];then
			if [ -n "${_VNATIVE}" ];then
			    connectSessionRDP "${_IDx}" "${_LABEL}"
			else
			    connectSessionRDP "${_IDx}" "${i}"
			fi
		    fi
		else
		    printDBG $S_RDP ${D_UID} $LINENO $BASH_SOURCE "C_CLIENTLOCATION=${C_CLIENTLOCATION}"
		fi

	    else
		if [ "${C_CLIENTLOCATION}" !=  "-L CONNECTIONFORWARDING" ];then
                    #
                    #So, this is executed on server site, it is a DISPLAYFORWARDING
                    #
                    #Server not yet running, so it is a CREATE
		    if [ -n "${_connect}" -o -n "${_reconnect}"  ];then
			ABORT=1
			printERR $LINENO $BASH_SOURCE ${ABORT} "Server not available, possible causes:"
			printERR $LINENO $BASH_SOURCE ${ABORT} "- Server is not running, cannot (RE)CONNECT, use REUSE"
			printERR $LINENO $BASH_SOURCE ${ABORT} "- No access permissions, check for process ownership"
			gotoHell ${ABORT}
		    fi

#  		    printDBG $S_RDP ${D_UID} $LINENO $BASH_SOURCE "C_CLIENTLOCATION=${C_CLIENTLOCATION}"
# 		    startSessionRDP "${i}"
		else
                    #
                    #So, this is executed on the client site, different from server site,
                    #it is CONNECTIONFORWARDING to a remote server.
                    #So, dig the tunnel and connect myself.

                    #
 		    printDBG $S_RDP ${D_UID} $LINENO $BASH_SOURCE "C_CLIENTLOCATION=${C_CLIENTLOCATION}"

                    #for reconnect, actually for vnc only required in shared-mode,
                    #this one instance replaces all active clients
		    if [ -n "${_reconnect}"  ];then
			cancelRDP CLIENT POWEROFF "i:${_IDx}"
		    fi

  		    _IDx=`digGetLocalPort "${i}" "RDP"`
                    if [ -z "$_IDx" -o -z "${_reuse}" ];then
			if [ -z "${_VNATIVE}" ];then
			    digLocalPort "RDP" "$R_HOSTS" "$i" >/dev/null
			else
			    digLocalPort "RDP" "$R_HOSTS" "$i" "$i" >/dev/null
			fi
  			_IDx=`digGetLocalPort "${i}" "RDP"`
			if [ -z "$_IDx" ];then
                            #Something wrent wrong???                                      
			    ABORT=1
			    printERR $LINENO $BASH_SOURCE ${ABORT} "Cannot allocate CONNECTIONFORWARDING"
			    printERR $LINENO $BASH_SOURCE ${ABORT} "  digLocalPort <RDP> <$R_HOSTS> <$i>"
			    gotoHell ${ABORT}
			fi
		    fi

		    let _IDx=_IDx-RDP_BASEPORT;
 		    printDBG $S_RDP ${D_UID} $LINENO $BASH_SOURCE "_IDx=${_IDx} i=${i}"

                    #kill of clients closes tunnel, gwhich is due to security reasons in "one-shot-mode"
		    if [ -n "${_reconnect}" -o -n "${_connect}" -o -n "${_IDx}" ];then
 			connectSessionRDP "${_IDx}" "${i}"
# 		    else
# 			printWNG 2 $LINENO $BASH_SOURCE 0 "Create a new tunnel in \"one-shot-mode\" again."
# 			startSessionRDP "${i}"
		    fi			    
		fi
	    fi

	    gotoHell 0
	    ;;
    esac
}
