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

_myPKGNAME_VNC_CREATE="${BASH_SOURCE}"
_myPKGVERS_VNC_CREATE="01.11.011"
hookInfoAdd $_myPKGNAME_VMW_CREATE $_myPKGVERS_VNC_CREATE
_myPKGBASE_VNC_CREATE="`dirname ${_myPKGNAME_VNC_CREATE}`"


#FUNCBEG###############################################################
#NAME:
#  bulkExpand
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  This is a special for VNC, gwhich expands a number and a label to 
#  a combined label with an enumeration as index.
#
#  This feature is particularly used for testing purposes of ctys 
#  itself and local native applications within a VNC session.
#
#EXAMPLE:
#  bulkcnt + <label> => <label>NNN  (N=[0-9])
#
#PARAMETERS:
#  $1: #bulkcnt
#  $2: <label>
#      A label is required and will be used as prefix
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#    <label><id>
#      The label is enumerated as given with #bulkcnt 
#      (3digits with leading '0').
#      Each entry is given as seperate line for postprocessing.
#
#FUNCEND###############################################################
function bulkExpand () {
    printDBG $S_VNC ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME bulkcnt=<$1>"
    printDBG $S_VNC ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME label  =<$2>"

    local _LABEL=$2
    local _BULKCNT=;
    case $1 in
	[0-9]|[0-9][0-9]|[0-9][0-9][0-9])
	    _BULKCNT=$1;
	    ;;
	*)ABORT=1
	    ;;
    esac
    if [ -z "${_BULKCNT}" ];then
	_BULKCNT=1;
        unset ABORT;
    fi
    if [ -n "${ABORT}" -o \( -n "${_BULKCNT}" -a -n "${_BULKCNT//[0-9]/}" \) ];then
	ABORT=1
	printERR $LINENO $BASH_SOURCE ${ABORT} "Integers only:_BULKCNT=${_BULKCNT}"
	gotoHell ${ABORT}
    fi
    printDBG $S_VNC ${D_MAINT} $LINENO $BASH_SOURCE "_BULKCNT = <${_BULKCNT}>"
    printDBG $S_VNC ${D_MAINT} $LINENO $BASH_SOURCE "_LABEL   = <${_LABEL}>"

    for((i=0;i<_BULKCNT&&i<R_CREATE_MAX;i++));do
	_LABEL_OUT=${_LABEL};
	if [ "${_BULKCNT}" != 1 -a -n "${_LABEL}" ];then
	    _LABEL_OUT=${_LABEL_OUT}`printf "%03d" "${i}"`
	fi
        printDBG $S_VNC ${D_MAINT} $LINENO $BASH_SOURCE "_LABEL_OUT=<${_LABEL_OUT}>"
        echo ${_LABEL_OUT}
    done
}




#FUNCBEG###############################################################
#NAME:
#  createConnectVNC
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
function createConnectVNC () {
    local OPMODE=$1;shift
    local ACTION=$1;shift

    local A;
    local KEY;
    local ARG;

    unset _VNATIVE;

    case ${OPMODE} in
        CHECKPARAM)
            printDBG $S_VNC ${D_UID} $LINENO $BASH_SOURCE "C_MODE_ARGS=$C_MODE_ARGS"
	    A=`cliSplitSubOpts ${C_MODE_ARGS}`;
            for i in $A;do                         
		KEY=`cliGetKey ${i}`
		ARG=`cliGetArg ${i}`
		case $KEY in
                    REUSE)
			local _reuse=1;
			if [ -n "${ARG}" ]; then
			    ABORT=1;
			    printERR $LINENO $BASH_SOURCE ${ABORT} "No arguments are supported for \"$KEY\""
 			    gotoHell ${ABORT}
			fi
			;;

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

                    RESUME)
			ABORT=1
			printERR $LINENO $BASH_SOURCE ${ABORT} "${ACTION}:Suboption ${KEY} NOT supported"
			gotoHell ${ABORT}
			;;


        #####################
        # <machine-address> #
        #####################

		    VNCDESKIDLIST|VDIL)
                        local _vdil="${ARG}";
 			printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE "VNCDESKIDLIST=$_vdil"
			;;

		    VNCVM|WM)
                        local _vm="${ARG}";
 			printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE "VNCVM=$_vm"
			;;

		    BASEPATH|BASE|B|TCP|T|MAC|M|UUID|U|FILENAME|FNAME|F|PATHNAME|PNAME|P)
			ABORT=1
			printERR $LINENO $BASH_SOURCE ${ABORT} "${ACTION}:Suboption ${KEY} NOT supported"
			gotoHell ${ABORT}
			;;

                    L|LABEL)
			_LABEL="${_LABEL} ${ARG}";
			;;

                    I|ID)
			if [ -z "$_connect" ];then
			    ABORT=1
			    printERR $LINENO $BASH_SOURCE ${ABORT} "${ACTION}:Suboption ${KEYXS} requires CONNECT"
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
                    BULK)
			case ${ACTION} in
                            CONNECT|REUSE|RECONNECT)
				ABORT=1
				printERR $LINENO $BASH_SOURCE ${ABORT} "${ACTION}:Suboption ${KEY} NOT supported"
				gotoHell ${ABORT}
				;;
			esac

                            #bulk will concatenate 3digit-leading-zero integers with current label
			if [ -n "${_uniqeBulk}" ];then
			    ABORT=1
			    printERR $LINENO $BASH_SOURCE ${ABORT} "Suboption ${i} has to be unique."
			    gotoHell ${ABORT}
			fi
                        local _uniqeBulk=1;
			_BULKCNT=${ARG};
			if [ -n "${ARG}" -a -n "${ARG//[0-9]/}" ];then
			    ABORT=1
			    printERR $LINENO $BASH_SOURCE ${ABORT} "Integers only:\"${ARG}\""
			    gotoHell ${ABORT}
			fi
			;;

                    VNCBASE)
			if [ -n "${_VNC_BASEPORT}" ];then
			    ABORT=1
			    printERR $LINENO $BASH_SOURCE ${ABORT} "Suboption ${i} has to be unique."
			    gotoHell ${ABORT}
			fi
                        _VNC_BASEPORT="${ARG}";
			if [ -n "${ARG}" -a -n "${ARG//[0-9]/}" ];then
			    ABORT=1
			    printERR $LINENO $BASH_SOURCE ${ABORT} "Integers only:\"${ARG}\""
			    gotoHell ${ABORT}
			fi
			;;

                    VNCPORT)
			if [ -n "${_VNATIVE}" ];then
			    ABORT=1
			    printERR $LINENO $BASH_SOURCE ${ABORT} "VNC native port is supported once per call only"
			    gotoHell ${ABORT}
			fi
			if [ -n "${ARG}" -a -n "${ARG//[0-9]/}" ];then
			    ABORT=1
			    printERR $LINENO $BASH_SOURCE ${ABORT} "VNC native port requires integers only:\"${ARG}\""
			    gotoHell ${ABORT}
			fi
			_VNATIVE="${ARG}";
			;;

                    WAITS)
			WAITS=${ARG};
			if [ -n "${ARG}" -a -n "${ARG//[0-9]/}" ];then
			    ABORT=1
			    printERR $LINENO $BASH_SOURCE ${ABORT} "Integers only:\"${ARG}\""
			    gotoHell ${ABORT}
			fi
			;;

		    *)
			ABORT=1
			printERR $LINENO $BASH_SOURCE ${ABORT} "Unknown suboption:<${i}>"
			printERR $LINENO $BASH_SOURCE ${ABORT} "  Probably the key is missing \"<key>:<arg>\""
			gotoHell ${ABORT}
			;;
		esac
            done
            printDBG $S_VNC ${D_MAINT} $LINENO $BASH_SOURCE "_BULKCNT = <${_BULKCNT}>"
            printDBG $S_VNC ${D_MAINT} $LINENO $BASH_SOURCE "_ID      = <${_ID}>"
            printDBG $S_VNC ${D_MAINT} $LINENO $BASH_SOURCE "_LABEL   = <${_LABEL}>"
            printDBG $S_VNC ${D_MAINT} $LINENO $BASH_SOURCE "_VNC     = <${_VNC}>"
            printDBG $S_VNC ${D_MAINT} $LINENO $BASH_SOURCE "_VNCBASE = <${_VNCBASE}>"
            printDBG $S_VNC ${D_MAINT} $LINENO $BASH_SOURCE "_VNATIVE = <${_VNATIVE}>"

	    if [ \( -n "${_BULKCNT}" -o -n "${_ID}" \) -a -n "${_VNATIVE}" ];then
		ABORT=1;
		printERR $LINENO $BASH_SOURCE ${ABORT} "Native VNC only supports combination with LABEL"
                gotoHell ${ABORT}
	    fi

	    if [ -n "${_VNATIVE}" -a  -n "${_LABEL}" ];then
		if [ "${_LABEL}" != "${_LABEL% */}" ];then
		    ABORT=1;
		    printERR $LINENO $BASH_SOURCE ${ABORT} "Native VNC and LABEL could be just combined one by one."
		    gotoHell ${ABORT}
		fi
	    fi

	    if [ -z "${_LABEL}" -a -z "${_VNATIVE}" -a -z "${_ID}" ];then
		ABORT=1;
		printERR $LINENO $BASH_SOURCE ${ABORT} "Missing mandatory suboption: LABEL, ID or VNCPORT"
		gotoHell ${ABORT}
	    fi

            if [  -n "${BULKCNT}" -a $(( _BULKCNT < R_CREATE_MAX )) -eq 0 ];then
		ABORT=1;
		printERR $LINENO $BASH_SOURCE ${ABORT} "Given number too high, limit is:R_CREATE_MAX=${R_CREATE_MAX}"
		printERR $LINENO $BASH_SOURCE ${ABORT} "  =>  ${C_MODE_ARGS}>${R_CREATE_MAX}"                
            fi

            unset _BULKCNT;
            unset _ID;
            unset _LABEL;
            unset _VNATIVE;
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
            _LABEL="";

            printDBG $S_VNC ${D_UID} $LINENO $BASH_SOURCE "C_MODE_ARGS=$C_MODE_ARGS"
	    A=`cliSplitSubOpts ${C_MODE_ARGS}`;
	    for i in $A;do
		KEY=`cliGetKey ${i}`
		ARG=`cliGetArg ${i}`
		case $KEY in
                    REUSE)
			local _reuse=1;
			;;

                    CONNECT)
			local _connect=1;
			;;

                    RECONNECT)
			hookPackage "${_myPKGBASE_VNC}/cancel.sh"
			local _reconnect=1;
			;;

                    RESUME)
			ABORT=1
			printERR $LINENO $BASH_SOURCE ${ABORT} "${ACTION}:Suboption ${KEY} NOT supported"
			gotoHell ${ABORT}
			;;

         #########

		    VNCDESKIDLIST|VDIL)
                        local _vdil="${ARG}";
 			printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE "VNCDESKIDLIST=$_vdil"

			#
			#passed through by env to the actual vncserver process for switching xstartup
 			VNCDESKIDLIST="${_vdil//\%/ }";export VNCDESKIDLIST
			;;

		    VNCVM|WM)
                        VNCWM="$(echo "${ARG}"|tr '[:lower:]' '[:upper:]')";

 			printDBG $S_X11 ${D_UID} $LINENO $BASH_SOURCE "VNCVM=$_vm"
			;;


                    L|LABEL)
			_LABEL="${_LABEL} ${ARG}";
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
			printDBG $S_VNC ${D_UID} $LINENO $BASH_SOURCE "_ID=${_ID}"
			printDBG $S_VNC ${D_UID} $LINENO $BASH_SOURCE "_IDlbl=${_IDlbl}"
			;;

          #########
                    BULK)
			_BULKCNT=${ARG};
			if [ -n "${ARG}" -a -n "${ARG//[0-9]/}" ];then
			    ABORT=1
			    printERR $LINENO $BASH_SOURCE ${ABORT} "Integers only:\"${ARG}\""
			    gotoHell ${ABORT}
			fi
			;;

                    VNCBASE)
			_VNC_BASEPORT="${ARG}";
			printDBG $S_VNC ${D_UID} $LINENO $BASH_SOURCE "VNC_BASEPORT=${VNC_BASEPORT}"
			;;

                    VNCPORT)
			_VNATIVE="${ARG}";
			printDBG $S_VNC ${D_UID} $LINENO $BASH_SOURCE "_VNATIVE=${_VNATIVE// /}"
			;;

                    WAITS)
			WAITS=${ARG};
			printDBG $S_VNC ${D_UID} $LINENO $BASH_SOURCE "WAITS=${WAITS}"
			;;


         #########
		    *)
			ABORT=1
			printERR $LINENO $BASH_SOURCE ${ABORT} "Unknown suboption:<${i}>"
			gotoHell ${ABORT}
			;;
		esac
	    done

            #_VNATIVE: This could only be unique, due to previous checks
            #if LABEL is supported, this will be used as DISPLAYNAME only,
            #so _VNATIVE dominates. Specific applications:
            #   VMW(WS6) and XEN.
	    if [ -n "${_VNATIVE}" ];then
		_BULKEXPAND="${_VNATIVE}"
	    else
                #generate normalized set of session-ids to be created
                #particularly the set containing 1 element only is included
                #and is the default case
		if [ -n "${_BULKCNT}" ];then
		    local _BULKEXPAND=`bulkExpand "${_BULKCNT}" "${_LABEL}"`;
		else
		    local _BULKEXPAND="${_LABEL}";
		fi
		_BULKEXPAND="${_BULKEXPAND} ${_IDlbl}"
	    fi

	    printDBG $S_VNC ${D_UID} $LINENO $BASH_SOURCE "${_LABEL}(${_BULKCNT}) -> _BULKEXPAND=${_BULKEXPAND}"
            for i in ${_BULKEXPAND}; do
                #perform session creation
		printDBG $S_VNC ${D_UID} $LINENO $BASH_SOURCE "Start session=${i}"
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
		printDBG $S_VNC ${D_UID} $LINENO $BASH_SOURCE "_LBL=${_LBL}  _ID=${_ID}"

                #Might be executed on remote host, not the calling station
		printDBG $S_VNC ${D_UID} $LINENO $BASH_SOURCE "C_CLIENTLOCATION=${C_CLIENTLOCATION}"
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

		printDBG $S_VNC ${D_MAINT} $LINENO $BASH_SOURCE " Session-Identifier: ${i}->${_ID} ${_LBL} ->${_IDx}"
                #check whether server is already running(local or remote)
                #therfore a peer must be present
                #but nevertheless, when doing a RECONNECT on a one-shot-stub things might be different
		if [ -n "${_IDx}" ];then
                    #Server is already running, so it is a potential CONNECT.
		    if [ -z "${_reconnect}" -a -z "${_connect}" -a -z "${_reuse}"  ];then
			ABORT=1
			printERR $LINENO $BASH_SOURCE ${ABORT} "Server already running, CANCEL first or use:"
			printERR $LINENO $BASH_SOURCE ${ABORT} "  REUSE|CONNECT|RECONNECT"
			printERR $LINENO $BASH_SOURCE ${ABORT} "  ID=${_IDx}  LABEL=$_LABEL"
			gotoHell ${ABORT}
		    fi

                    #for reconnect, actually for vnc only required in shared-mode,
                    #this one instance replaces all active clients
		    if [ -n "${_reconnect}"  ];then
			cancelVNC CLIENT POWEROFF "i:${_IDx}"
		    fi

                    #perform only if REUSE is present
		    if [ "${C_CLIENTLOCATION}" !=  "-L SERVERONLY" ];then
			if [ -n "${_reconnect}" -o -n "${_connect}" -o -n "${_reuse}" ];then
			    if [ -n "${_VNATIVE}" ];then
				connectSessionVNC "${_IDx}" "${_LABEL}"
			    else
				connectSessionVNC "${_IDx}" "${i}"
			    fi
			fi
		    else
			printDBG $S_VNC ${D_UID} $LINENO $BASH_SOURCE "C_CLIENTLOCATION=${C_CLIENTLOCATION}"
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

 			printDBG $S_VNC ${D_UID} $LINENO $BASH_SOURCE "C_CLIENTLOCATION=${C_CLIENTLOCATION}"
			startSessionVNC "${i}"
		    else
                        #
                        #So, this is executed on the client site, different from server site,
                        #it is CONNECTIONFORWARDING to a remote server.
                        #So, dig the tunnel and connect myself.
                        #
 			printDBG $S_VNC ${D_UID} $LINENO $BASH_SOURCE "C_CLIENTLOCATION=${C_CLIENTLOCATION}"

                        #for reconnect, actually for vnc only required in shared-mode,
                        #this one instance replaces all active clients
			if [ -n "${_reconnect}"  ];then
			    cancelVNC CLIENT POWEROFF "i:${_IDx}"
			fi

  			_IDx=`digGetLocalPort "${i}" "VNC"`
                        if [ -z "$_IDx" -o -z "${_reuse}" ];then
			    if [ -z "${_VNATIVE}" ];then
				digLocalPort "VNC" "$R_HOSTS" "$i" >/dev/null
			    else
				digLocalPort "VNC" "$R_HOSTS" "$i" "$i" >/dev/null
			    fi
  			    _IDx=`digGetLocalPort "${i}" "VNC"`
			    if [ -z "$_IDx" ];then
                                #Something wrent wrong???                                      
				ABORT=1
				printERR $LINENO $BASH_SOURCE ${ABORT} "Cannot allocate CONNECTIONFORWARDING"
				printERR $LINENO $BASH_SOURCE ${ABORT} "  digLocalPort <VNC> <$R_HOSTS> <$i>"
				gotoHell ${ABORT}
			    fi
			fi

			let _IDx=_IDx-VNC_BASEPORT;
 			printDBG $S_VNC ${D_UID} $LINENO $BASH_SOURCE "_IDx=${_IDx} i=${i}"

                        #kill of clients closes tunnel, gwhich is due to security reasons in "one-shot-mode"
			if [ -n "${_reconnect}" -o -n "${_connect}" -o -n "${_IDx}" ];then
 			    connectSessionVNC "${_IDx}" "${i}"
			else
			    printWNG 2 $LINENO $BASH_SOURCE 0 "Create a new tunnel in \"one-shot-mode\" again."
			    startSessionVNC "${i}"
			fi			    
		    fi
		fi
	    done
	    gotoHell 0
	    ;;
    esac
}
