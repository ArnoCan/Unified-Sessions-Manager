#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_09_001
#
########################################################################
#
# Copyright (C) 2007 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

_myPKGNAME_CLI="${BASH_SOURCE}"
_myPKGVERS_CLI="01.07.001b06"
hookInfoAdd "$_myPKGNAME_CLI" "$_myPKGVERS_CLI"



#FUNCBEG###############################################################
#NAME:
#  setDefaultsByMasterOption
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Sets defaults as defined for master option. The settings are implemented 
#  in accordance to the table "Resulting Defaults for a given '-a <action>'".
#
#  Master option is defined for this project to be "-a <ACTION>" gwhich
#  defines the task to be performed.
# 
#  For this project a default for the mandatory master option itself is 
#  defined as, so the does not neccessarily needs to provide it.
#
#    "-a INFO"
#
#  As defined with generic behaviour, gives static relevant information
#  for selected node, gwhich is as default "localhost".
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
function setDefaultsByMasterOption () {
    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:C_MODE=$C_MODE"
    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:C_SESSIONTYPE=$C_SESSIONTYPE"
    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:C_MODE_ARGS=$C_MODE_ARGS"
    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:R_OPTS=$R_OPTS"

    #options list not to be evaluated locally, will be stripped off and bypassed
    #could be varied for each ACTION
    REMOTEONLY=" -A -r -d -T -Z -z "

    case ${C_MODE} in
        GETCLIENTPORT)
	    C_SCOPE=${C_SCOPE//*DEFAULT*/$DEFAULT_C_SCOPE}
            ;;
        ISACTIVE)
	    C_SCOPE=${C_SCOPE//*DEFAULT*/$DEFAULT_C_SCOPE}
            ;;
	LIST)
            #do it on terminating leaf or missing any request
            if [  -n "${C_EXECLOCAL}" ];then
		C_SESSIONTYPE=${C_SESSIONTYPE//*DEFAULT*/ALL};
		C_SESSIONTYPE=${C_SESSIONTYPE:-ALL};
	    else
		CTYS_MULTITYPE=${CTYS_MULTITYPE//*DEFAULT*/ALL}
		CTYS_MULTITYPE=${CTYS_MULTITYPE:-ALL}
	    fi

            #no preselection
	    if [ "${1}" == "${1// -t}" -a "${R_OPTS}" == "${R_OPTS// -T /}" ];then
		if [  -n "${C_EXECLOCAL}" ];then
		    local _rpart="${1}"
		else
		    local _rpart="${1#*\(}"
		fi
		if [ "${_rpart}" == "${_rpart// -T /}" ];then
		    local _R_OPTS=`cliOptionsStrip KEEP ' -T ' -- " ${1} "`
		    if [ -n "$_R_OPTS" ];then
			R_OPTS="${R_OPTS} ${_R_OPTS}"
		    else
			R_OPTS="${R_OPTS} -T ${CTYS_MULTITYPE:-ALL}"
		    fi
		fi
	    fi

	    C_CACHEDOP=${C_CACHEDOP//*DEFAULT*/0};
	    C_ASYNC=${C_ASYNC//*DEFAULT*/0};
	    C_PARALLEL=${C_PARALLEL//*DEFAULT*/1};

	    C_MODE_ARGS=${C_MODE_ARGS//*DEFAULT*/$DEFAULT_C_MODE_ARGS_LIST}
	    C_MODE_ARGS=`replaceMacro ${C_MODE_ARGS}`
	    R_CLIENT_DELAY=0;
	    X_DESKTOPSWITCH_DELAY=0;
	    C_SCOPE=${C_SCOPE//*DEFAULT*/ALL}
	    ;;

	ENUMERATE)
            #do it on terminating leaf
            if [  -n "${C_EXECLOCAL}" ];then
		C_SESSIONTYPE=${C_SESSIONTYPE//*DEFAULT*/ALL};
	    fi

            #no preselection
            if [ "${1}" == "${1// -t}" ];then
		R_OPTS="${R_OPTS} `cliOptionsStrip KEEP ' -T ' -- ${1}`"
		printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:R_OPTS=$R_OPTS"
	    fi

	    C_CACHEDOP=${C_CACHEDOP//*DEFAULT*/0};
	    C_ASYNC=${C_ASYNC//*DEFAULT*/0};
	    C_PARALLEL=${C_PARALLEL//*DEFAULT*/1};

	    C_MODE_ARGS=${C_MODE_ARGS//*DEFAULT*/$DEFAULT_C_MODE_ARGS_ENUMERATE}
	    R_CLIENT_DELAY=0;
	    X_DESKTOPSWITCH_DELAY=0;
	    C_SCOPE=${C_SCOPE//*DEFAULT*/$DEFAULT_C_SCOPE}
	    ;;

	INFO)
            #do it on terminating leaf
            if [  -n "${C_EXECLOCAL}" ];then
		C_SESSIONTYPE=${C_SESSIONTYPE//*DEFAULT*/ALL};
	    else
		CTYS_MULTITYPE=${CTYS_MULTITYPE//*DEFAULT*/ALL}
	    fi

            #no preselection
	    if [ "${1}" == "${1// -t}" ];then
		local _R_OPTS="`cliOptionsStrip KEEP ' -T ' -- ${1}`"
		if [ -n "$_R_OPTS" ];then
		    R_OPTS="${R_OPTS} ${_R_OPTS}"
		else
		    R_OPTS="${R_OPTS} -T ${CTYS_MULTITYPE}"
		fi
	    fi

	    C_CACHEDOP=${C_CACHEDOP//*DEFAULT*/0};
	    C_ASYNC=${C_ASYNC//*DEFAULT*/0};
	    C_PARALLEL=${C_PARALLEL//*DEFAULT*/1};

	    C_MODE_ARGS=${C_MODE_ARGS//*DEFAULT*/$DEFAULT_C_MODE_ARGS_LIST}
	    C_MODE_ARGS=`replaceMacro ${C_MODE_ARGS}`
	    R_CLIENT_DELAY=0;
	    X_DESKTOPSWITCH_DELAY=0;
	    C_SCOPE=${C_SCOPE//*DEFAULT*/ALL}
	    ;;

	SHOW)
            #do it on terminating leaf
            if [  -n "${C_EXECLOCAL}" ];then
		C_SESSIONTYPE=${C_SESSIONTYPE//*DEFAULT*/ALL};
	    else
		CTYS_MULTITYPE=${CTYS_MULTITYPE//*DEFAULT*/ALL}
	    fi

            #no preselection
	    if [ "${1}" == "${1// -t}" ];then
		local _R_OPTS="`cliOptionsStrip KEEP ' -T ' -- ${1}`"
		if [ -n "$_R_OPTS" ];then
		    R_OPTS="${R_OPTS} ${_R_OPTS}"
		else
		    R_OPTS="${R_OPTS} -T ${CTYS_MULTITYPE}"
		fi
	    fi

	    C_CACHEDOP=${C_CACHEDOP//*DEFAULT*/0};
	    C_ASYNC=${C_ASYNC//*DEFAULT*/0};
	    C_PARALLEL=${C_PARALLEL//*DEFAULT*/1};

	    C_MODE_ARGS=${C_MODE_ARGS//*DEFAULT*/$DEFAULT_C_MODE_ARGS_LIST}
	    C_MODE_ARGS=`replaceMacro ${C_MODE_ARGS}`
	    R_CLIENT_DELAY=0;
	    X_DESKTOPSWITCH_DELAY=0;
	    C_SCOPE=${C_SCOPE//*DEFAULT*/ALL}
	    ;;


	CREATE)
	    C_SESSIONTYPE=${C_SESSIONTYPE//*DEFAULT*/VNC};
            case "${C_SESSIONTYPE}" in 
		CLI)C_ASYNC=${C_ASYNC//*DEFAULT*/0};
		    C_PARALLEL=${C_PARALLEL//*DEFAULT*/0};
		    C_SSH_PSEUDOTTY=${C_SSH_PSEUDOTTY//*DEFAULT*/2};
		    ;;
		*) C_ASYNC=${C_ASYNC//*DEFAULT*/1};;
	    esac

	    C_CACHEDOP=${C_CACHEDOP//*DEFAULT*/0};
	    C_ASYNC=${C_ASYNC//*DEFAULT*/0};
	    C_PARALLEL=${C_PARALLEL//*DEFAULT*/1};

	    C_MODE_ARGS=${C_MODE_ARGS//*DEFAULT*/$DEFAULT_C_MODE_ARGS_CREATE}
	    C_SCOPE=${C_SCOPE//*DEFAULT*/$DEFAULT_C_SCOPE}
	    ;;

	CANCEL)
	    C_SESSIONTYPE=${C_SESSIONTYPE//*DEFAULT*/VNC};
	    C_ASYNC=${C_ASYNC//*DEFAULT*/1};
	    C_CACHEDOP=${C_CACHEDOP//*DEFAULT*/0}
	    C_PARALLEL=${C_PARALLEL//*DEFAULT*/1};

	    R_CLIENT_DELAY=0;
	    X_DESKTOPSWITCH_DELAY=0;
	    C_SCOPE=${C_SCOPE//*DEFAULT*/$DEFAULT_C_SCOPE}


            case "${C_SESSIONTYPE}" in 
		PM)
                    #prepare all contained VMs and HOSTs
		    if [  -n "${C_EXECLOCAL}" ];then
			[ "PM" == "${CTYS_MULTITYPE// /}" ]&&CTYS_MULTITYPE=ALL;
			CTYS_MULTITYPE=${CTYS_MULTITYPE//*DEFAULT*/ALL};
		    fi
		    ;;
	    esac
	    ;;

	*)
	    ;;
    esac

    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:C_SESSIONTYPE=${C_SESSIONTYPE}"
    CTYS_MULTITYPE=${CTYS_MULTITYPE//*DEFAULT*/$DEFAULT_CTYS_MULTITYPE}
    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:CTYS_MULTITYPE=${CTYS_MULTITYPE}"

    USE_K5USERS=${USE_K5USERS//*DEFAULT*/0}
    USE_SUDO=${USE_SUDO//*DEFAULT*/0}
    C_SSH_PSEUDOTTY=${C_SSH_PSEUDOTTY//*DEFAULT*/0}

    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:C_SESSIONTYPE=$C_SESSIONTYPE"
    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:R_OPTS=$R_OPTS"
    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:USE_K5USERS=$USE_K5USERS"
    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:USE_SUDO=$USE_SUDO"
    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:C_SSH_PSEUDOTTY=$C_SSH_PSEUDOTTY"
}



#FUNCBEG###############################################################
#NAME:
#  fetchOptions
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Analyse CLI options. It sets the appropriate context, gwhich could be 
#  for remote or local execution.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1:   Callcontext:
#        LOCAL  : for local execution
#        REMOTE : for local and remote execution, because some HAS to 
#                 be recognized locally too, so for "simplicity" => both
#  $2-*: Options
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function fetchOptions () {
    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=<${@}>"
    local _callContext=$1;shift
    local _myArgs=$@

    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_myArgs=<${_myArgs}>"

    #check now for options gwhich really are for remote evaluation only,
    #the remaining are to be handled loacally for remote assembly, but some local processing
    if [ "${_callContext}" == REMOTE ];then

	if [ "${C_CACHEAUTO}" == 1 -a -n "${CTYS_SUBCALL}" ];then
	    digCheckLocal
	    if [ $? -eq 1 ];then
		ABORT=2
		printERR $LINENO $BASH_SOURCE ${ABORT} "AUTO is supported for local access only:R_HOSTS=\"${R_HOSTS}\""
		gotoHell ${ABORT}
	    fi
	fi

	printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:R_OPTS=<${R_OPTS}>"
	local _buf1="`cliOptionsStrip KEEP $REMOTEONLY -- $_myArgs`"
	R_OPTS="`cliOptionsUpdate ${_buf1} -- ${R_OPTS} `"
	printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:REMOTE-ONLY:R_OPTS=<${R_OPTS}>"
	_myArgs="`cliOptionsStrip REMOVE $REMOTEONLY -- $_myArgs`"
	printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:LOCAL-ONLY:_myArgs=<${_myArgs}>"
    fi

    #control flow
    EXECUTE=1;
    unset ABORT
    OPTIND=1
    OPTLST="a:A:b:d:D:c:C:EfF:g:hH:j:k:l:L:M:no:O:p:r:s:S:t:T:vVwW:x:XyYz:Z:";

    #otherwise does it awk-y
    if [ -z "${_myArgs// }" ];then
	printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:remaining NO-ARGS:_myArgs=\"\""
	return
    fi
    while getopts $OPTLST CUROPT ${_myArgs} && [ -z "${ABORT}" ]; do
	case ${CUROPT} in
	    a) #[-a:]
		if [ -z "${OPTARG}" ]; then
		    ABORT=1;         
		fi

                #for bi-usage-options like "-V", gwhich could be used seperately, or for analysis of
                #runtime resources at the end of an execution
                local _actionSet=1;

		C_MODE=`echo "${OPTARG}"|awk -F'=' '{print $1}'`
		printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "C_MODE=$C_MODE"
		C_MODE=`echo ${C_MODE}|tr '[:lower:]' '[:upper:]'`
		printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "C_SESSIONTYPE=$C_SESSIONTYPE"
		printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "C_MODE=$C_MODE"
		printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "OPTARG=<${OPTARG}>"
		local _argbuf=`echo "${OPTARG}"|awk -F'=' '{for(i=2;i<=NF;i++){if(i>2){printf("=");}printf("%s",$i)};printf("\n");}'`;

                if [ -n "$_argbuf" ];then
		    C_MODE_ARGS="${_argbuf}";
		fi
 		printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "C_MODE_ARGS=$C_MODE_ARGS"
                #1. Stage: Check and set appropriate generic defaults to the different tasks
                setDefaultsByMasterOption "${_myArgs}"
		;;

	    A) #[-A:]
		if [ -z "${OPTARG}" ]; then
		    ABORT=1;         
		    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing sub-arguments for \"-A\" option."
		fi
		case ${OPTARG} in
		    0|[oO][fF][fF])unset C_ALLOWAMBIGIOUS;;
		    1|[oO][nN])
			C_ALLOWAMBIGIOUS=1;
			R_OPTS="${R_OPTS} -A 1 ";
			;;
		    *)
			ABORT=1;
			printERR $LINENO $BASH_SOURCE ${ABORT} "Erroneous sub-arguments for option:\"-A\" ${OPTARG}"
			;;
		esac
		printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "Allow ambiguous labels:${C_ALLOWAMBIGIOUS}"
		;;

	    b) #[-b:] 
                if [ -z "${OPTARG}" ]; then 
                    ABORT=1; 
                    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing sub-arguments for \"-b\" option."  
		fi 
                if((C_STACK==0)); then 
		    local _rx=;
		    for i in ${OPTARG//,/ };do
			case ${i} in 
			    [sS][tT][aA][cC][kK])C_ASYNC=0;C_PARALLEL=0;C_STACK=1;_rx="${_rx},STACK";;
			    [sS][yY][nN][cC]|0|[oO][fF][fF])C_ASYNC=0;_rx="${_rx},SYNC";;
 			    [aA][sS][yY][nN][cC]|1|[oO][nN])C_ASYNC=1;_rx="${_rx},ASYNC";; 
 			    [sS][eE][qQ][uU][eE][nN][tT][iI][aA][lL]|[sS][eE][qQ]|2)C_PARALLEL=0;_rx="${_rx},SEQ";; 
 			    [pP][aA][rR][aA][lL][lL][eE][lL]|[pP][aA][rR]|3)C_PARALLEL=1;_rx="${_rx},PAR";; 
			    *)  ABORT=1; 
				printERR $LINENO $BASH_SOURCE ${ABORT} "Erroneous sub-arguments for option:\"-b\" ${OPTARG}" 
				;; 
			esac 
		    done
		    R_OPTS=" -b ${_rx#,} ${R_OPTS}"
		    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "R_OPTS=\"${R_OPTS}\"" 
		else
		    C_ASYNC=0;C_PARALLEL=0;
		    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "Ignore \"-b\" in STACK mode" 
		fi
		printDBG $S_CORE ${D_FRAME}	$LINENO $BASH_SOURCE "Background operations: \"${C_ASYNC}\"" 
                ;;

	    c) #[-c:]
                local _myR_OPTS=;
		for i in ${OPTARG//,/ };do
		    case $i in
			[oO][fF][fF])C_NSCACHELOCATE=0;_myR_OPTS="${_myR_OPTS},OFF";;
			[bB][oO][tT][hH])C_NSCACHELOCATE=1;;
			[lL][oO][cC][aA][lL])C_NSCACHELOCATE=2;_myR_OPTS="${_myR_OPTS},OFF";;
			[rR][eE][mM][oO][tT][eE])C_NSCACHELOCATE=3;;

			[oO][nN])C_NSCACHELOCATE=1;;
			[oO][nN][lL][yY])C_NSCACHEONLY=1;_myR_OPTS="${_myR_OPTS},ONLY";;
			*)
			    ABORT=1; 
			    printERR $LINENO $BASH_SOURCE ${ABORT} "Unknown suboption:\"${i}\""
			    gotoHell ${ABORT}       
			    ;;
		    esac
		done

		_myR_OPTS="${_myR_OPTS#,}";
		if [ -n "${_myR_OPTS}" ];then
		    R_OPTS=" ${R_OPTS} -c ${_myR_OPTS} ";
		fi
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "R_OPTS           = ${R_OPTS}"
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "C_NSCACHELOCATE  = ${C_NSCACHELOCATE}"
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "C_NSCACHELONLY   = ${C_NSCACHELONLY}"
		;;

	    C) #[-C:]
		C_CACHEDOP=1;
                local _myR_OPTS=;
		for i in ${OPTARG//,/ };do
		    if [ "$C_CACHEDOP" == 0 ];then
			ABORT=2
			printERR $LINENO $BASH_SOURCE ${ABORT} "OFF cannot be combined:\"${OPTARG}\""
			gotoHell ${ABORT}
		    fi
		    case $i in
			[oO][fF][fF]|0)C_CACHEDOP=0;C_CACHEDOPMEM=0;;
			[oO][nN]|1)C_CACHEDOP=1;;
			[kK][eE][eE][pP])C_CACHEKEEP=1;;
			[kK][eE][eE][pP][aA][lL][lL])C_CACHEKEEP=1;_myR_OPTS="${_myR_OPTS},${i}";;
			[oO][nN][lL][yY])C_CACHEONLY=1;_myR_OPTS="${_myR_OPTS},${i}";;
			[rR][aA][wW])C_CACHERAW=1;_myR_OPTS="${_myR_OPTS},${i}";;
			[fF][oO][uU][tT]:*)
			    if [ "${i}" != "${i#/}" ];then
				CALLERCACHE=${i};
			    else
				CALLERCACHE=${MYTMP}/${i##*:};
			    fi
			    _myR_OPTS="${_myR_OPTS},${i}"
			    ;;
			[aA][uU][tT][oO])
			    C_CACHEAUTO=1;
			    _myR_OPTS="${_myR_OPTS},${i}";
			    ;;

			[lL][iI][fF][eE][tT][iI][mM][eE]:*)
			    SESSIONCACHEPERIOD=${i##*:};
 			    if [ -n "${SESSIONCACHEPERIOD##+([0-9])}" ];then
				ABORT=2
				printERR $LINENO $BASH_SOURCE ${ABORT} "Integer value required:${i}"
				gotoHell ${ABORT}
			    fi
			    _myR_OPTS="${_myR_OPTS},${i}";
			    ;;

			[fF][iI][nN]:*)
			    if [ "${i}" != "${i#/}" ];then
				CALLERCACHEREUSE=${i};
			    else
				CALLERCACHEREUSE=${MYTMP}/${i##*:};
			    fi
			    _myR_OPTS="${_myR_OPTS},${i}";
			    if [ ! -f "${CALLERCACHEREUSE}" ]; then
				printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "Missing file:CALLERCACHEREUSE=\"${CALLERCACHEREUSE}\""
			    fi
			    ;;
			*)
			    ABORT=1; 
			    printERR $LINENO $BASH_SOURCE ${ABORT} "Unknown suboption:\"${i}\""
			    gotoHell ${ABORT}       
			    ;;
		    esac
		done

		_myR_OPTS="${_myR_OPTS#,}";
		if [ -n "${_myR_OPTS}" ];then
		    R_OPTS=" ${R_OPTS} -C ${_myR_OPTS} ";
		fi
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "R_OPTS           = ${R_OPTS}"
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "C_NSCACHELOCATE  = ${C_NSCACHELOCATE}"
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "C_CACHEDOP       = ${C_CACHEDOP}"
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "C_CACHEKEEP      = ${C_CACHEKEEP}"
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "C_CACHEONLY      = ${C_CACHEONLY}"
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "C_CACHERAW       = ${C_CACHERAW}"
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "CALLERCACHE      = \"${CALLERCACHE}\""
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "CALLERCACHEREUSE = \"${CALLERCACHEREUSE}\""
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "LIFETIME         = \"${SESSIONCACHEPERIOD}\""
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "AUTO             = ${C_CACHEAUTO}"
		;;

	    d) #[-d:] see prefetch
                #do it again for context options, MACROs, and GROUPs, which will be 
                #loaded delayed
                fetchDBGArgs $*
		;;

	    D) #[-D]
		if [ -z "${OPTARG}" ]; then
		    ABORT=1;         
		fi
		export C_DISPLAY="${OPTARG}";
		if [ "${C_DISPLAY}" != "${C_DISPLAY//:*/}" ];then
		    ABORT=1;         
		    printERR $LINENO $BASH_SOURCE ${ABORT} "Localhost is supported for DISPLAY redirection only"
		    printERR $LINENO $BASH_SOURCE ${ABORT} "  C_DISPLAY=<${C_DISPLAY}>"
		    gotoHell 1
		fi
		;;

	    E) #[-E]
		C_EXECLOCAL=1;
		;;

	    f) #[-f]
		C_FORCE=1;
		;;

	    F) #[-F:]
		if [ -z "${OPTARG}" ]; then
		    ABORT=1;         
		fi
		L_VERS="${OPTARG}";
		;;

	    g) #[-g:]
		if [ -z "${OPTARG}" ]; then
		    ABORT=1;         
		    printERR $LINENO $BASH_SOURCE ${ABORT} "geometry parameter missing geometry:-g"
		    gotoHell ${ABORT}
		fi

		doDebug $S_CORE $D_BULK $LINENO $BASH_SOURCE
		C_GEOMETRY=`expandGeometry $? "${OPTARG}"`;
		if [ $? -ne 0 ]; then
		    ABORT=1;         
		    printERR $LINENO $BASH_SOURCE ${ABORT} "geometry parameter expansion error:-g \"${OPTARG}\""
		    printERR $LINENO $BASH_SOURCE ${ABORT} " => \"${C_GEOMETRY}\""
		    gotoHell ${ABORT}
		fi
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "-g \"${OPTARG}\" => C_GEOMETRY=${C_GEOMETRY}"
		;;

	    h) #[-h]
		_noActionWng=1;
		printHelp;
		showToolHelp;
		ABORT=0;
		;;

	    H) #[-H]
		_noActionWng=1;
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "-H \"${OPTARG}\""
		printHelpEx "${OPTARG}";
		ABORT=0;
		;;

	    j) #[-j:]
		if [ -z "${OPTARG}" ]; then
		    ABORT=1;         
		fi
		CALLERJOB="${OPTARG}"
		CALLERDATETIME="${OPTARG%%:*}"
		CALLERJOB_IDX="${OPTARG#*:}"
		if [ -z "${CALLERDATETIME}" -o -z "${CALLERJOB_IDX}" ];then
		    ABORT=1;
		    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing or erroneous suboption:-j \"${OPTARG}\""
		    gotoHell ${ABORT}
		fi
                CTYS_SUBCALL=1;
		printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "Setting job-data from master:"
		printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "CALLERDATETIME=${CALLERDATETIME}"
		printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "CALLERJOB_IDX=${CALLERJOB_IDX}"
		CALLERJOBID="${CALLERDATETIME}:${CALLERJOB_IDX}"
		printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "CALLERJOBID=${CALLERJOBID}"
		;;

	    k) #[-k:] 
                if [ -z "${OPTARG}" ]; then 
                    ABORT=1; 
                    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing sub-arguments for \"-k\" option."  
		fi 

		local _rx=;
		for i in ${OPTARG//,/ };do
		    case ${i} in 
			[rR][eE][uU][sS][eE]:*)
			    C_STACKREUSE=${i##*:};
 			    if [ -n "${C_STACKREUSE##+([0-2])}" ];then
				ABORT=2
				printERR $LINENO $BASH_SOURCE ${ABORT} "Integer value required(0,1,2):${i}"
				gotoHell ${ABORT}
			    fi
			    _rx="${_rx},${i}";
			    ;;


			*)  ABORT=1; 
			    printERR $LINENO $BASH_SOURCE ${ABORT} "Erroneous sub-arguments for option:\"-k\" ${OPTARG}" 
			    ;; 
		    esac 
		done
		R_OPTS=" -k ${_rx#,} ${R_OPTS}"
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "R_OPTS=\"${R_OPTS}\"" 
                ;;


	    l) #[-l]
		if [ -z "${OPTARG}" ]; then
		    ABORT=1;         
		fi
		R_USERS="${OPTARG}";
		if [ "${R_USERS}" != "${R_USERS// /}" ];then
		    ABORT=1;         
		    printERR $LINENO $BASH_SOURCE ${ABORT} "Spaces within user names are not provided:\"${R_USERS}\""
		    gotoHell 1
		fi
		;;

	    L) #[-L:]
		if [ -z "${OPTARG}" ]; then
		    ABORT=1;         
		    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing sub-arguments for \"-L\" option."
		fi

		local _X=`echo ${OPTARG}|tr '[:lower:]' '[:upper:]'`
		case ${_X} in
		    LO|LOCALONLY)
			C_CLIENTLOCATION="-L LOCALONLY";
 		        ;;

		    CF|CONNECTIONFORWARDING)
			C_CLIENTLOCATION="-L CONNECTIONFORWARDING";
 		        ;;
		    DF|DISPLAYFORWARDING)
			C_CLIENTLOCATION="-L DISPLAYFORWARDING";
			;;

		    CO|CLIENTONLY)
			C_CLIENTLOCATION="-L CLIENTONLY";
 		        ;;
		    SO|SERVERONLY)
			C_CLIENTLOCATION="-L SERVERONLY";
			;;

		    *) 
			ABORT=1; 
			printERR $LINENO $BASH_SOURCE ${ABORT} "Erroneous sub-arguments for option:\"-L\"${OPTARG}" 
			;; 
		esac 
		printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "LocalClient - Connection Forwarding:\"${C_CLIENTLOCATION}\"" 
		;;

	    M) #[-M:]
		if [ -z "${OPTARG}" ]; then
		    ABORT=1;         
		fi
		R_TEXT="-M ${OPTARG}";
		;;

	    n) #[-n]
		C_NOEXEC=1;
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "-n => C_NOEXEC=${C_NOEXEC}"
		;;

	    O) #[-O:]
		if [ -z "${OPTARG}" ]; then
		    ABORT=1;         
   		    printERR $LINENO $BASH_SOURCE ${ABORT} "remote global options for server, suboptions missing:-O"
		fi
		R_OPTS="${R_OPTS} ${OPTARG}";
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "remote global options for server:-O \"${OPTARG}\""
		;;

	    o) #[-o:]
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "-o - generic option to be passed through to application plugins"
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "     currently yust reserved,  not yet implemented."
		ABORT=1;         
		printERR $LINENO $BASH_SOURCE ${ABORT} "option not yet implemented:\"-o\""
		gotoHell ${ABORT}

                C_PASSTHRUOPTS=${OPTARG}
		;;

	    p) #[-p:]
		if [ -z "${OPTARG}" ]; then
		    ABORT=1;         
   		    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing:database path: \"-p\""
		    gotoHell ${ABORT}
		fi
              
		if [ ! -d "${OPTARG}" ]; then
		    ABORT=1;         
   		    printERR $LINENO $BASH_SOURCE ${ABORT} "Expected directory for database path: \"-p ${OPTARG}\""
		    gotoHell ${ABORT}
		fi

                #export does the "export", is checked by sub-utilities
                export DBPATHLST=${OPTARG}
		printDBG $S_CORE ${D_UID} $LINENO $BASH_SOURCE "database path or address-mapping:DBPATHLST=\"${DBPATHLST}\""
		;;

	    r) #[-r:]
		if [ -z "${OPTARG}" ]; then
		    ABORT=1;         
		    printERR $LINENO $BASH_SOURCE ${ABORT} "remote resolution parameter missing geometry:-r"
		    gotoHell ${ABORT}
		fi

		doDebug $S_CORE $D_BULK $LINENO $BASH_SOURCE
		local _C_REMOTERESOLUTION_RAW=`expandGeometry $? "${OPTARG}"`;
		if [ $? -ne 0 ]; then
		    ABORT=1;         
		    printERR $LINENO $BASH_SOURCE ${ABORT} "remote resolution parameter expansion error:-r \"${OPTARG}\""
		    printERR $LINENO $BASH_SOURCE ${ABORT} " => \"${_C_REMOTERESOLUTION_RAW}\""
		    gotoHell ${ABORT}
		fi

		C_REMOTERESOLUTION=`echo ${_C_REMOTERESOLUTION_RAW}|sed -n 's/[^0-9]*\([0-9x]*\).*$/\1/gp'`;
		if [ -z "${C_REMOTERESOLUTION}" ]; then
		    ABORT=1;         
		    printERR $LINENO $BASH_SOURCE ${ABORT} "remote resolution parameter expansion error:-r \"${OPTARG}\""
		    printERR $LINENO $BASH_SOURCE ${ABORT} " => \"${C_REMOTERESOLUTION}\""
		    printERR $LINENO $BASH_SOURCE ${ABORT} "Size-Only is supported for remote resolution: \"<xsize>x<ysize>\""
		    gotoHell ${ABORT}
		fi

		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "-r \"${OPTARG}\" "
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "   => C_REMOTERESOLUTION=${C_REMOTERESOLUTION}"
		;;

	    s) #[-s:]
		if [ -z "${OPTARG}" ]; then
		    ABORT=1;         
		fi

		C_SCOPE=`echo "${OPTARG}"|awk -F'=' '{print $1}'`
		C_SCOPE=`echo ${C_SCOPE}|tr '[:lower:]' '[:upper:]' 2>/dev/null`
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "C_SCOPE=$C_SCOPE"
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "OPTARG=<${OPTARG}>"
		C_SCOPE_ARGS=`echo "${OPTARG}"|awk -F'=' '{print $2}' 2>/dev/null`;
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "C_SCOPE_ARGS=$C_SCOPE_ARGS"
		X1="${OPTARG}_x_"
		if [ "${X1//=_x_/}=" == "${OPTARG}"  ];then
		    ABORT=1;
		    printERR $LINENO $BASH_SOURCE ${ABORT} "Erroneous subopts:${OPTARG}"
		fi
		case ${C_SCOPE} in
		    USER|GROUP)
			if [ -n "${C_SCOPE_ARGS}"  ];then
			    ABORT=1;
			    printERR $LINENO $BASH_SOURCE ${ABORT} "For \"-s USER|GROUP\" are no subopts allowed:\"-s ${C_SCOPE}=${C_SCOPE_ARGS}\""
			fi
			;;

		    USRLST|GRPLST)
			if [ -z "${C_SCOPE_ARGS}"  ];then
			    ABORT=1;
			    printERR $LINENO $BASH_SOURCE ${ABORT} "For \"-s USRLST|GRPLST\" are subopts required"
			fi
			;;

		    ALL)
			if [ -n "${C_SCOPE_ARGS}"  ];then
			    ABORT=1;
			    printERR $LINENO $BASH_SOURCE ${ABORT} "For \"-s ALL\" are no subopts allowed:\"-s ${C_SCOPE}=${C_SCOPE_ARGS}\""
			fi
			C_SCOPE=USRLST;
			C_SCOPE_ARGS=ALL;
			printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "C_SCOPE=ALL remapped to"
			printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "-> C_SCOPE     = USRLST"
			printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "-> C_SCOPEARGS = ALL"
			;;

		    *)
			ABORT=1;
			printERR $LINENO $BASH_SOURCE ${ABORT} "Erroneous scope:${C_SCOPE}"
			printERR $LINENO $BASH_SOURCE ${ABORT} " Supported values: USER|GROUP|USRLST|GRPLST"
			;;        
		esac
		C_SCOPE_CONCAT="${C_SCOPE}=${C_SCOPE_ARGS}"
		;;

	    S) #[-S:]
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "OPTARG=<${OPTARG}>"
		R_OPTS="${R_OPTS} -S ${OPTARG}";
                export SIGISSET=1;
                local _mySIGSPEC=;
		for i in ${OPTARG//,/ };do
		    case $i in
			[oO][fF][fF])SIGISSET=0;;
			[oO][nN])SIGISSET=1;;
			*)_mySIGSPEC="${_mySIGSPEC} ${i}";;
		    esac
		done

		if [ -n "${_mySIGSPEC}" ];then
		    CTYS_SIGIGNORESPEC="${_mySIGSPEC}";
		fi
		if [ -n "${CTYS_SIGIGNORESPEC}" ];then
		    if [ "$SIGISSET" == "1" ];then
			printINFO 1 $LINENO $BASH_SOURCE 0 "TRAP:SET:${CTYS_SIGIGNORESPEC}"
			trap  "" ${CTYS_SIGIGNORESPEC}
		    else
			printINFO 1 $LINENO $BASH_SOURCE 0 "TRAP:RESET:${CTYS_SIGIGNORESPEC}"
			trap  - ${CTYS_SIGIGNORESPEC}
			CTYS_SIGIGNORESPEC=;
		    fi
		fi
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "SIGISSET           = ${SIGISSET}"
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "CTYS_SIGIGNORESPEC = ${CTYS_SIGIGNORESPEC}"
		;;

	    t) #[-t:]
		if [ -z "${OPTARG}" ]; then
		    ABORT=1;         
		fi
                printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "OPTARG=${OPTARG}"
		C_SESSIONTYPE=`echo ${OPTARG}|tr '[:lower:]' '[:upper:]'`
                printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "C_SESSIONTYPE=${C_SESSIONTYPE}"
		if [ "${PACKAGES_KNOWNTYPES//$C_SESSIONTYPE}" == "${PACKAGES_KNOWNTYPES}" \
                    -a "${C_SESSIONTYPE}" != "ALL" \
		    ];then

                    #try a postfetch, might be a context-only call
		    local _myPkgPath=`hookGetPathname ${C_SESSIONTYPE}`
		    hookPackage ${_myPkgPath}
		    if [ "${PACKAGES_KNOWNTYPES//$C_SESSIONTYPE}" == "${PACKAGES_KNOWNTYPES}" ];then
			ABORT=1;
			printERR $LINENO $BASH_SOURCE ${ABORT} "Erroneous session type:${C_SESSIONTYPE}"
			printERR $LINENO $BASH_SOURCE ${ABORT} "Available types are:"
			printERR $LINENO $BASH_SOURCE ${ABORT} "  ${PACKAGES_KNOWNTYPES}"
		    fi
		fi
		;;

	    T) #[-T:]
		if [ -z "${OPTARG}" ]; then
		    ABORT=1;         
		fi
                #To be pre-processed in calling-main.
                #Defines the types of plugins to be loaded
		CTYS_MULTITYPE=${ARG};
		;;

	    v) #[-v]
                let C_PRINTINFO+=1;
		_noActionWng=1;
		;;

	    V) #[-V]
		if [ -z "$C_TERSE" ];then
		    printVersion
		    gotoHell 0
		fi
                let C_PRINTINFO+=1;
		_noActionWng=1;
		;;

	    w) #[-w] # Dummy for scanner algorithms, no comments please!
		;;

	    W) #[-W:]
		if [ -z "${OPTARG}" ]; then
		    ABORT=1;         
		fi

                #It is the remote component of DISPLAYFORWARDING, for gwhich the GUI will be set on the
                #DISPLAY-client, thus not here!
                runningOnDisplayStation
		if [ $? == 0 ];then
                    desktopsSupportCheck
		    if [ $? -ne 0 ]; then
			ABORT=1; 
			printERR $LINENO $BASH_SOURCE ${ABORT} "This option is only available when \"wmctrl\" is installed."
			gotoHell ${ABORT}       
		    fi

                    C_WMC_DESK="${OPTARG}";
                    desktopsCheckDesk ${C_WMC_DESK}
		    if [ $? -ne 0 ]; then
			ABORT=1; 
			printERR $LINENO $BASH_SOURCE ${ABORT} "given desktop is not available:-D <${C_WMC_DESK}>"
			printERR $LINENO $BASH_SOURCE ${ABORT} "  due to reliability desktops has to be pre-created manually."
			gotoHell ${ABORT}       
		    fi
		fi
		;;

	    x) #[-x:]
		if [ -z "${OPTARG}" ]; then
		    ABORT=1;         
		fi
		local _cnt=0;
		for i in ${OPTARG//,/ };do
		    case $i in
  			0|[Oo][Ff][Ff])C_RESOLVER=OFF;;
  			1|[Ss][Tt][Aa][Rr])C_RESOLVER=STAR;;
  			2|[Cc][Hh][Aa][Ii][Nn])C_RESOLVER=CHAIN;;
			*)
			    ABORT=1;         
			    printERR $LINENO $BASH_SOURCE ${ABORT} "Unknown Resolver-Option:-x \"${OPTARG}\""
			    printERR $LINENO $BASH_SOURCE ${ABORT} "Valid:OFF|STAR|CHAIN"
			    gotoHell ${ABORT}
			    ;;
		    esac
		done
		R_OPTS="${R_OPTS} -R ${C_RESOLVER}"
		printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "-x <nested-access-resolver>}"
		printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "  C_RESOLVER =${C_RESOLVER}"
		if((_cnt=0));then
		    ABORT=2;
		    printERR $LINENO $BASH_SOURCE ${ABORT} "Argument error:\"-x ${OPTARG}\""
		    gotoHell $ABORT
		fi
		;;

	    X) #[-X]
		R_OPTS="${R_OPTS} -X ";
		C_TERSE=" -X ";
		;;

	    y) #[-y]
		CTYS_XTERM=0;
		R_OPTS="${R_OPTS} -y ";
		;;

	    Y) #[-Y]
		C_AGNTFWD=1;
		;;

	    z) #[-z:]
		if [ -z "${OPTARG}" ]; then
		    ABORT=1;         
		fi
		local _cnt=0;
		export C_SSH_PSEUDOTTY=0;
		for i in ${OPTARG//,/ };do
		    case $i in
  			[Nn][Oo][Pp][Tt][Yy])C_NOPTY=1;C_SSH_PSEUDOTTY=0;((_cnt++));;
  			[Pp][Tt][Yy])let C_SSH_PSEUDOTTY++;((_cnt++));;
			1)export C_SSH_PSEUDOTTY=1;((_cnt++));;
			2)export C_SSH_PSEUDOTTY=2;((_cnt++));;
		    esac
		done
		printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "  C_SSH_PSEUDOTTY =${C_SSH_PSEUDOTTY}"
		if((_cnt=0));then
		    ABORT=2;
		    printERR $LINENO $BASH_SOURCE ${ABORT} "Argument error:\"-Z ${OPTARG}\""
		    gotoHell $ABORT
		fi
		;;

	    Z) #[-Z:]
		if [ -z "${OPTARG}" ]; then
		    ABORT=1;         
		fi
		local _cnt=0;
		printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "Set \"su\" mechanism..."
		for i in ${OPTARG//,/ };do
		    case $i in
			[kK][sS][uU})  export USE_K5USERS=1;((_cnt++));;
			[nN][oO][kK][sS][uU])export USE_K5USERS=0;((_cnt++));;

			[sS][uU][dD][oO])  export USE_SUDO=1;((_cnt++));;
			[nN][oO][sS][uU][dD][oO])export USE_SUDO=0;((_cnt++));;


			[aA][lL][lL])   export USE_SUDO=1;export USE_K5USERS=1;((_cnt++));;
			*);;
		    esac
		done
		printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "...results to:"
		printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "  USE_K5USERS        =${USE_K5USERS}"
		printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "  USE_SUDO           =${USE_SUDO}"
		if((_cnt=0));then
		    ABORT=2;
		    printERR $LINENO $BASH_SOURCE ${ABORT} "Argument error:\"-Z ${OPTARG}\""
		    gotoHell $ABORT
		fi
		;;

	    *)
		ABORT=1;
		printERR $LINENO $BASH_SOURCE ${ABORT} "Erroneous parameter"
		printERR $LINENO $BASH_SOURCE ${ABORT} "type \"${MYCALLNAME} -h\" for additional help"
		;;
	esac
    done

    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "ABORT=<${ABORT}>"

    if [ -n "${ABORT}" -a "${ABORT}" != "0" ];then
	ABORT=1
	printERR $LINENO $BASH_SOURCE ${ABORT} "ERROR:CLI error for call parameters."
	gotoHell ${ABORT}
    fi


    if [ "$_actionSet" == 1 ];then
        #2. Stage: Verify options by selected feature package.
	printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "DISPATCH:PACKAGES_KNOWNTYPES=${PACKAGES_KNOWNTYPES}"
	printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "DISPATCH:C_MODE=${C_MODE}"
	printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "C_MODE_ARGS=$C_MODE_ARGS"

	for y in ${PACKAGES_KNOWNTYPES};do
	    if [ "${C_SESSIONTYPE}" == $y -o "${C_SESSIONTYPE}" == "ALL" -o "${C_SESSIONTYPE}" == DEFAULT ];then
 		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "DISPATCH:PACKAGE=${y}"
		_matched=1;
		case ${C_MODE} in
		    LIST|ENUMERATE|SHOW|INFO)
			eval handleGENERIC CHECKPARAM ${C_MODE} 
			;;
		    *)
			eval handle${y} CHECKPARAM ${C_MODE}
			;;
		esac
	    fi
	done

	if [ -z "$_matched" ];then
	    ABORT=1;
	    printERR $LINENO $BASH_SOURCE ${ABORT} "System Error, unexpected C_SESSIONTYPE=${C_SESSIONTYPE}"
	    printERR $LINENO $BASH_SOURCE ${ABORT} "  PACKAGES_KNOWNTYPES=${PACKAGES_KNOWNTYPES}"
	    gotoHell ${ABORT}
	fi
    fi

    if [ \( "${_callContext}" == LOCAL  -a -z "${_actionSet}" \) -a -z "${_noActionWng}" ];then
	printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "Missing ACTION \"-a\""
    fi

    if [ "${C_CACHEONLY}" != 0 ];then
	case ${C_MODE} in
	    LIST|ENUMERATE|SHOW|INFO);;
	    *)
		ABORT=1
		printERR $LINENO $BASH_SOURCE ${ABORT} "CACHE ONLY is only supported for generic collectors:"
		printERR $LINENO $BASH_SOURCE ${ABORT} " => LIST | ENUMERATE | SHOW | INFO"
		gotoHell ${ABORT}
		;;
	esac
    fi
}


#FUNCBEG###############################################################
#NAME:
#  fetchArguments
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Analyse CLI arguments
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
function fetchArguments () {
    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:ARGV=<${*}>"
    #fetch remote options - the common global part
    #   =>  " [--] '(<common>)' host1'(<context1>)' ..."
     R_OPTS="${R_OPTS} `echo  ${*} |sed -n 's/^(\([^)]*\)).*/\1/p'`"

    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:R_OPTS=\"${R_OPTS}\""

    #the remaining parameters must be hostnames, with optional context-options.
    R_HOSTS="`echo ${*} |sed  's/^([^)]*) *//'`"


    #So we assume local operations, but not analyse the "-l" option for 
    #permutation now. The actual execution user will be detected at last,
    #just before execution, where the target-string 
    #
    #    "ssh <SSH-OPTS> ${USER}@localhost" 
    #
    #is simply deleted and just the command is executed.
    if [ -z "${R_HOSTS}" ];then
	R_HOSTS=localhost;
    fi

    R_HOSTS=`expandGroups ${R_HOSTS}`

    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "R_OPTS=<${R_OPTS}>"
    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "R_HOSTS=<${R_HOSTS}>"
}


#FUNCBEG###############################################################
#NAME:
#  getSessionType
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Extract the session type from a given EXECCAL argument or any
#  options list.
#  Therefore the string "... -t <SESSION-TYPE> ..." is extracted.
#  The given type should be a member of list PACKAGES_KNOWNTYPES.
#
#
#EXAMPLE:
#
#PARAMETERS:
# $*: ${EXECCALL}|<options-list>
#     Generally a string containing an <options-list>, where the
#     first match is choosen. So only one type option is allowed to
#     be contained.
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getSessionType () {
  printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "\$=<$*>"
  local _type=`echo $*|sed -n 's/^.*-t[ "]\([^ "]*\)[ "].*$/\1/p'`

  if [ -n "${_type}" \
       -a "${_type}" != "ALL" \
       -a "${1}"  != "listMySessions" \
       -a "${1}"  != "enumerateMySessions" \
       -a "${1}"  != "rExecute" \
       -a "${PACKAGES_KNOWNTYPES}" == "${PACKAGES_KNOWNTYPES//$_type}" \
  ]; then
      ABORT=2;
      printERR $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:Unknown _type=$_type"
      printERR $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:  \$*=$*"
      gotoHell ${ABORT};
  fi       
  printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "_type=$_type"
  echo ${_type}
}


#FUNCBEG###############################################################
#NAME:
#  getAction
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Extract the action from a given EXECCAL argument or any
#  options list. Therefore the "effective" action is resolved.
#
#EXAMPLE:
#
#PARAMETERS:
# $*: ${EXECCALL}|<options-list>
#     Generally a string containing an <options-list>, where the
#     first match is choosen. So only one type option is allowed to
#     be contained.
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getAction () {
    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME \$@=$@"
    case ${1} in
	rExececute)_action=EXECUTE;;
	listMySessions)_action=LIST;;
	enumerateMySessions)_action=ENUMERATE;;
    esac

    if [ -z "${_action}" ];then
	local _action=`echo $*|sed -n 's/^.* -a[ "]*//;s/\([^ ="]*\)[= "].*$/\1/p'`
    fi
    _action="`echo ${_action}|tr '[:lower:]' '[:upper:]'`"

    case $_action in
	GETCLIENTPORT);;
	ISACTIVE);;
 	ENUMERATE|INFO|LIST|SHOW);;
 	CANCEL);;
 	CREATE);;
	*)
	    ABORT=2;
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Unknown _action=$_action"
	    gotoHell ${ABORT};
	    ;;
    esac
    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "_action=$_action"
    echo ${_action}
}


#FUNCBEG###############################################################
#NAME:
#  getActionResulting
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Extract the action from a given EXECCAL argument or any
#  options list. Therefore the "effective" action is resolved.
#
#  This is here due to the basic design assumption, that an 
#  action is related to a sessions could be e.g. CREATE, gwhich
#  creates a session, but e.g. to an already existing and 
#  performing "meeting" - by a shared connect.
#
#  So the ACTION=CREATE with the sub-ACTION=CONNECT will be the 
#  "effective" ACTION CONNECT.
#
#  Whereas a REUSE, gwhich means open a new session if "meeting" 
#  is not yet existing, but just join "CONNECT" when already there,
#  has technically still the effective ACTION CREATE.
#
#  This is particularly relevant, when deciding the required tasks, 
#  e.g. in case of the distributed approach of CONNECTIONFORWARDING.
#
#  Therefore the string "... -a <ACTION>=<sub-ACTION> ..." 
#  is extracted as "effective ACTION".
#
#  Supported types are literally:
#
#    CREATE={CREATE,REUSE,RESUME}
#    CONNECT={CREATE:CONNECT,CREATE:RECONNECT}
#           REMARKS: 
#             CREATE:RECONNECT:
#                 Clients handeled explicitly only on server site.
#    CANCEL={<any>}
#           REMARK: 
#             Clients are generally handeled explicitly only on 
#             server site.
#    LIST={<any>}    
#    ENUMERATE={<any>}    
#    SHOW={<any>}    
#    INFO={<any>}    
#
#
#EXAMPLE:
#
#PARAMETERS:
# $*: ${EXECCALL}|<options-list>
#     Generally a string containing an <options-list>, where the
#     first match is choosen. So only one type option is allowed to
#     be contained.
#
#OUTPUT:
#  RETURN:
#    0: true
#    1: false
#    2: could be - additional check required
#
#  VALUES:
#
#FUNCEND###############################################################
function getActionResulting () {
    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME \$@=$@"

    case ${1} in
	rExececute)_action=EXECUTE;;
	listMySessions)_action=LIST;;
	enumerateMySessions)_action=ENUMERATE;;
    esac

    if [ -z "${_action}" ];then
	if [ "${*//=/}" != "${*}" ];then
	    local _action=`echo $*|sed -n 's/^.* -a[ "]*//;s/\([^ ="]*\)[= "].*$/\1/p'`
	else
	    _action=SYNTAX-ERROR;
	fi
    fi
    _action="`echo ${_action}|tr '[:lower:]' '[:upper:]'`"

    local _res=$_action;
    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME _action=\"$_action\""
    case $_action in
	GETCLIENTPORT);;
	ISACTIVE);;
 	ENUMERATE|INFO|LIST|SHOW);;
 	CANCEL);;
 	CREATE)
	    if [ "${*//[rR][eE][cC][oO][nN][nN][eE][cC][tT][, ]}" != "${*}" ];then
		printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME _action=>RECONNECT=>CONNECT"
		_res=CONNECT;
	    else
		if [ "${*//[cC][oO][nN][nN][eE][cC][tT][, ]}" != "${*}" ];then
		    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME _action=>CONNECT=>CONNECT"
		    _res=CONNECT;
		else
		    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME _action=>CREATE"
		    _res=CREATE;
		fi
	    fi
	    ;;

	'')
	    printDBG $S_CORE ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:No local ACTION, assume remote-context-only"
	    ;;
	*)
	    ABORT=2;
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Unknown _action=$_action(${*})"
	    gotoHell ${ABORT};
	    ;;
    esac
    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_res=$_res"
    echo ${_res}
}



#FUNCBEG###############################################################
#NAME:
#  clientServerSplitSupported
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  True if a for type and resultingAction task could be splitted.
#
#EXAMPLE:
#
#PARAMETERS:
# $*: ${EXECCALL}|<options-list>
#     Generally a string containing an <options-list>, where the
#     first match is choosen. So only one type option is allowed to
#     be contained.
#
#OUTPUT:
#  RETURN:
#    0: true
#    1: false
#    2: could be - additional check required
#
#  VALUES:
#
#FUNCEND###############################################################
function clientServerSplitSupported () {
    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME \$@=$@"
    local _CS_SPLIT=`echo ${*}|sed -n 's/CONNECTIONFORWARDING/SERVERONLY/p'`;
    local _S=`getSessionType ${*}`;_S=${_S:-$C_SESSIONTYPE};
    local _A=`getActionResulting ${*}`;
    local _ret=1;

    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "_CS_SPLIT=\"${_CS_SPLIT}\""
    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "_S=\"${_S}\""
    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "_A=\"${_A}\""

    if [ -n "${_CS_SPLIT}" ];then
	clientServerSplitSupported${_S} ${_A}
	_ret=$?;
	if [ $_ret -eq 0 ];then
	    case $_A in 
 		CONNECT)_ret=1;;
	    esac
	fi
    fi

    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_ret=\"${_ret}\""
    return ${_ret};
}






#FUNCBEG###############################################################
#NAME:
#  getLocation
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Extract the location from a given EXECCAL argument or any
#  options list.
#  Therefore the string "... -L <LOCATION> ..." is extracted.
#  Supported types are literally:
#
#    NOW:
# 	LO|LOCALONLY, CF|CONNECTIONFORWARDING, DF|DISPLAYFORWARDING,
# 	CO|CLIENTONLY, SO|SERVERONLY
#
#EXAMPLE:
#
#PARAMETERS:
# $*: ${EXECCALL}|<options-list>
#     Generally a string containing an <options-list>, where the
#     first match is choosen. So only one type option is allowed to
#     be contained.
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getLocation () {
    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME \$@=$@"
    local _location=`echo $*|sed -n \
                -e 's/^.*-L *["\\]*\([^ "\\]*\) *["\\]*.*$/\1/p;' \
                -e "s/^.*-L *['\\]*\([^ '\\]*\) *['\\]*.*$/\1/p;"`
    
    case $_location in
        LO|LOCALONLY)            _location=LOCALONLY;;
        CF|CONNECTIONFORWARDING) _location=CONNECTIONFORWARDING;;
        DF|DISPLAYFORWARDING)    _location=DISPLAYFORWARDING;;
        CO|CLIENTONLY)           _location=CLIENTONLY;;
        SO|SERVERONLY)           _location=SERVERONLY;;
	*);;
    esac

    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "_location=$_location"
    echo ${_location}
}

#FUNCBEG###############################################################
#NAME:
#  setLocation
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Sets the location to a given argument
#
#EXAMPLE:
#
#PARAMETERS:
# $1: <location>
# $2: <cli-string>
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function setLocation () {
    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME \$@=$@"
    local _new=$1;shift

    local _location=`echo $*|\
          sed  -e "s/CONNECTIONFORWARDING/${_new}/g;" \
               -e "s/DISPLAYFORWARDING/${_new}/g;" \
               -e "s/SERVERONLY/${_new}/g;" \
               -e "s/CLIENTONLY/${_new}/g;" \
               -e "s/LOCALONLY/${_new}/g;"`

    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME _location=${_location}"
    echo "${_location}"
}


#FUNCBEG###############################################################
#NAME:
#  getDesktop
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Extracts the desktop label or id:
#
#  "DISPLAYFORWARDING"     =>   DISPLAYFORWARDING
#  "CONNECTIONFORWARDING"  =>   CONNECTIONFORWARDING
#  "SERVERONLY"            =>   SERVERONLY
#
#
#EXAMPLE:
#
#PARAMETERS:
# $*: ${EXECCALL}|<options-list>
#     Generally a string containing an <options-list>, where the
#     first match is choosen. So only one type option is allowed to
#     be contained.
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getDesktop () {
    local _action=`echo $*|sed -n 's/^.*-D[ "]*\([^ "]*\)[ "].*$/\1/p'`
    local _id=;
    if [ -n "${_action}" ];then
        _id=`desktopsGetId ${_action}`
        echo $_id
    fi
    return
}

#FUNCBEG###############################################################
#NAME:
#  runningOnDisplayStation
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
#OUTPUT:
#  RETURN:
#    0: this is graphical output station running XServer
#    1: NO
#  VALUES:
#
#FUNCEND###############################################################
function runningOnDisplayStation () {
    if [ "${C_EXECLOCAL}" != "1" \
         -o "${C_CLIENTLOCATION}" != "-L DISPLAYFORWARDING" \
         -a "${C_CLIENTLOCATION}" != "-L SERVERONLY" \
    ];then
	return 0
    fi
    return 1
}
