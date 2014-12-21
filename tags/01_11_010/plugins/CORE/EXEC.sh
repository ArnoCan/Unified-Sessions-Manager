#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_007
#
########################################################################
#
# Copyright (C) 2007,2008,2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

_myPKGNAME_EXEC="${BASH_SOURCE}"
_myPKGVERS_EXEC="01.11.007"
hookInfoAdd "$_myPKGNAME_EXEC" "$_myPKGVERS_EXEC"


EXCCALL=""
EXECLINK=""
EXECCALLBASE=""

#Arrays containing complete list of execCall-prefixes

#Set of all resulting target hosts after completion of permutation with 
#user@host-EMail-Form only.
declare -a EXECCALLS;


#Set of user@host specific sessions remote parameters, gwhich would be applied 
#on the remote host only.
declare -a EXECOPTIONS;


#Index for linked-handling of JOB_-arrays.
#This is the resulting job counter too.
JOB_IDX=0;
JOB_CNT=0;

#numbers subjobs by increment
#masterjob is the only one with 0 increment, relying on for 
#bundled execution, e.g. headers for multi-target polls.
JOB_IDXSUB=1;


#Complete calling master job.
CALLERJOB=;

#Index for calling master job.
CALLERJOB_IDX=${JOB_IDX};

#Key of calling master job.
CALLERDATETIME=${DATETIME};

#PID of caller
CALLERPID=$$;

#ID of caller job
CALLERID="${CALLERDATETIME}:${CALLERPID}"

#shortcut for current job
CALLERJOBID="${CALLERDATETIME}:${CALLERJOB_IDX}"

#shortcut for cache data of current job
#DO NOT CHANGE without knowing exactly what you are doing!
CALLERCACHE=;
CALLERCACHEREUSE=;


#Set of local clients when the 'CONNECTIONFORWARDING' option is choosen and a 
#local client for the remote server is requested.
#Storing the client requests in a temporary cache and executing the server
#requests first completely seems to offer the better overall average 
#performance.
#One effort-saving alternative approach would be synchrounous operations, 
#gwhich technically could be implemented as polling-mode only. This might 
#lead in case of group starts to sequentialized and long enduring 
#responce times.
#The reply is definitive required in order to choose the appropriate 
#port for "plumbing the tunnel" e.g. towards a vncserver.
#
#We do not want to manage ports in distributed environments, because we
#operate stateless, and in a small autonomous view in "a lot"!!!
#
#This array contains just complete calls, to be used as they are.
declare -a JOB_EXECCLIENTS;


#This array is used for statistics, debugging and macro-recording purposes.
#The evaluated EXECCALL will be stored here, even though this might not be 
#absolutely neccessary. It makes some administrative tasks for post-processing
#and post-analysis easier.
#This array contains just complete calls, to be used as they are.
#This could be a server-only call as well as a server+client-on-server call.
declare -a JOB_EXECSERVER;


#
#This is - to be honest - more or less a temporary patchwork.
#I contains the EXECCALLS entry for each expanded element of the original 
#EXECCALS entry, so far so good. BUT, the expansion of "-t ALL", gwhich it is
#primarily, should be done remotely, and not as implemented on client side.
#Anyhow, for this version other tasks has higher priority. 
#This solution requires less additional effort, than the target solution.
#
declare -a JOB_EXECCALLS;


#FUNCBEG###############################################################
#NAME:
#  assembleExeccall
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Sets up the generic call structure for remote execution.
#
#  Currently it seems - and is heavily forced - that no package specific 
#  details has to be known here. Just "abstract" CLI options are assembled,
#  package specific options will be passed through transparently by this
#  dispatcher.
#
#  Any specific handling (e.g. geometry of VNC and VMware) should be performed
#  at the site of execution.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: PROPAGARE
#      Optional parameter gwhich suppresses the settting of the execution flag.
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function assembleExeccall () {
    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:Prepare remote call"
    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=<${@}>"
    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "Pre:EXECCALL=\"${EXECCALL}\""
    case $1 in
	PROPAGATE)
	    local  _propagate=1
	    ;;
    esac


    if [ "$C_MODE" == DEFAULT -a -z "${_propagate}" ];then
	ABORT=2;
	printERR $LINENO $BASH_SOURCE ${ABORT} "ERROR:ACTION \"-a\" not yet set."
	gotoHell ${ABORT}
    fi
    if [ "$C_MODE_ARGS" == DEFAULT -a -z "${_propagate}" ];then
	ABORT=2;
	printERR $LINENO $BASH_SOURCE ${ABORT} "ERROR:ACTION \"-a\" arguments not yet set."
	gotoHell ${ABORT}
    fi


    if [ -z "${CTYS_SUBCALL}" ];then
	local _originator="${DATETIME}:$$:0:$((JOB_IDXSUB++))"
    else
	local _originator="${CALLERJOBID}:$((JOB_IDXSUB++))"
    fi

    EXECCALL=" -j \"${_originator}\" "
    if [ -z "${_propagate}" ];then
	EXECCALL="${EXECCALL} -E  "
    fi
    EXECCALL="${EXECCALL} -F \"${VERSION}\" "
    if [ "${CTYS_XTERM}" == 0 ];then
	EXECCALL="${EXECCALL} -y "
    fi

    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "after0:C_SESSIONTYPE=${C_SESSIONTYPE}"
    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "after0:(DEFAULT_C_SESSIONTYPE=${DEFAULT_C_SESSIONTYPE})"

    if [ -n "${C_SESSIONTYPE}" \
        -a "${C_SESSIONTYPE}" != DEFAULT \
	];then
        EXECCALL="${EXECCALL} -t ${C_SESSIONTYPE} "
    fi
    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "after1:EXECCALL=\"${EXECCALL}\""

    if [ -n "${C_MODE_ARGS}" \
        -a "${C_MODE_ARGS}" != DEFAULT \
	];then
	EXECCALL="${EXECCALL} -a \"${C_MODE}=${C_MODE_ARGS}\" "
    else
	if [ -z "${_propagate}" ];then
	    EXECCALL="${EXECCALL} -a \"${C_MODE}${DEFAULT_LIST_C_MODE_ARGS:+=$DEFAULT_LIST_C_MODE_ARGS}\" "                 
	fi
    fi
    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "after2:EXECCALL=\"${EXECCALL}\""

    if [ -n "${C_SCOPE_ARGS}" ];then
	EXECCALL="${EXECCALL} -s \"${C_SCOPE}=${C_SCOPE_ARGS}\" "
    else
	if [ -z "${_propagate}" ];then
	    EXECCALL="${EXECCALL} -s \"${C_SCOPE}${DEFAULT_LIST_C_SCOPE_ARGS:+=$DEFAULT_LIST_C_SCOPE_ARGS}\" "
	fi
    fi
    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "after3:EXECCALL=\"${EXECCALL}\""

    if [ -n "${C_GEOMETRY}" ];then
	X_OPTS=" ${X_OPTS} -g \"${C_GEOMETRY}\" ";
    fi

    if [ -n "${C_REMOTERESOLUTION}" ];then
	X_OPTS=" ${X_OPTS} -r \"${C_REMOTERESOLUTION}\" ";
    fi

    if [ -n "${C_WMC_DESK}" ];then
	X_OPTS=" ${X_OPTS} -D \"${C_WMC_DESK}\" ";
    fi

    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "Pre-Post:R_OPTS=\"${R_OPTS}\""
    R_OPTS=$(cliOptionsClearRedundant ${R_OPTS})
    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "Pre-Post:R_OPTS=\"${R_OPTS}\""

    X_OPTS=$(cliOptionsClearRedundant ${X_OPTS})
    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "Pre-Post:X_OPTS=\"${X_OPTS}\""

    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "Pre-Post:EXECCALL=\"${EXECCALL}\""
    if [ -z "${_propagate}" ];then
	printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "_propagate"
	EXECCALL="${EXECCALL} ${C_CLIENTLOCATION}  ${X_OPTS} ${R_TEXT}"
	EXECCALL="`cliOptionsUpdate ${R_OPTS} -- ${EXECCALL} `"
	EXECCALL="`cliOptionsAddMissing ${EXECOPTIONS[$JOB_CNT]} -- ${EXECCALL} `"
    else
	EXECCALL="${EXECCALL} ${C_CLIENTLOCATION} ${R_OPTS} ${X_OPTS} ${R_TEXT}"
    fi

    EXECCALL="${MYCALLNAME} ${EXECCALL}"
    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "Post:EXECCALL=\"${EXECCALL}\""
}




#FUNCBEG###############################################################
#NAME:
#  buildExecCalls
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  This function prepares the two arrays EXECCALLS and EXECOPTIONS 
#  for later execution. Therefore the users and targets with specific
#  suboptions are permutated and stored as ready-to-use entities.
#
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
function buildExecCalls() {
    #fetch all explicitly given <user@host>
    #and collect all <host> only for permutation with "-l" option or "$USER" otherwise
    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:R_HOSTS=<${R_HOSTS}>"
    local n=0;
    local i=x;
    local _HostOnlyLst="";
    local _ARGSOPTIND=;
    let _ARGSOPTIND=1;

    while [ -n "${i}" -o ${_ARGSOPTIND} -eq 1 ]  ;do
        #fetch line-by-line each argument with it's specific arguments, e.g. "...host01(-d 6 -L SERVERONLY)..."
	i="`splitArgsWithOpts ${_ARGSOPTIND} ${R_HOSTS}`"
	printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "R_HOSTS(i)($n)(${_ARGSOPTIND})=<${i}>"

	local _myt="${i#(*)}";

        #end of list
        if [ -z "${_myt// /}" ];then break;fi
	printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "Current entry:i=<${i}>"


        #Check whether entry has the form user@host
	local _myHost="${i%%(*}";
	if [ "${i#*@}" == "${i}" ];then
	    printDBG $S_CORE ${D_UID} $LINENO $BASH_SOURCE "Add user to host:$_myHost"
	    if [ -n "${R_USERS}" ];then
		EXECCALLS[$n]=${R_USERS}@${_myHost};
	    else
		EXECCALLS[$n]=${USER}@${_myHost};
	    fi
	else
	    EXECCALLS[$n]="${_myHost}";
	fi
	printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "Add user@host to EXECCALLS[$n]:${EXECCALLS[$n]}"

        #target should be canonical here:<user>@<host>
	local _tmpExe=;
	_tmpExe=`checkAndSetIsHostOrGroup ${EXECCALLS[$n]}`
	if [ $? -eq 0 ];then
	    EXECCALLS[$n]=$_tmpExe;
	    printDBG $S_CORE ${D_UID} $LINENO $BASH_SOURCE "Checked-OK:host/group:EXECCALLS[$n]=\"${EXECCALLS[$n]}\""

	    local _argopts=`getArgOpts $i`
            if [ -n "${_argopts}" ];then
		EXECOPTIONS[$n]=${_argopts};
 		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "Add argoptions to EXECOPTIONS[$n]:${EXECOPTIONS[$n]}"
            fi

  	    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "EXECCALLS[$n]:${EXECOPTIONS[$n]}"
 	    let n++;
	else
# 	    ABORT=1;
# 	    printERR $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:Unknown host, job is ignored:${EXECCALLS[$n]}"
	    printERR $LINENO $BASH_SOURCE 1  "$FUNCNAME:Unknown host, job is ignored:${EXECCALLS[$n]}"
  	    EXECCALLS[$n]=;
	    EXECOPTIONS[$n]=;
	fi
	let _ARGSOPTIND=_ARGSOPTIND+1;
    done

    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:FINISHED:EXECCALLS=<${#EXECCALLS[@]}>"
    #
    #EXECCALLS[] and EXECOPTIONS[] now prepared for execution.
    #
}



#FUNCBEG###############################################################
#NAME:
#  pushExecCall
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
function pushExecCall () {
    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:\$*=$*"
    local x=$1;shift

    case $1 in
	PROPAGATE)local _propagate=1;;
    esac
    shift

    showEnv "${D_BULK}"

    local _ST=`getSessionType ${*}`;_ST=${_ST:-$C_SESSIONTYPE};
    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:SESSIONTYPE=\"${_ST}\""

    #
    #Check and do the client-server-split if required now.
    #

    local _JOB_IDX=${#JOB_EXECSERVER[@]};
    JOB_CNT=$_JOB_IDX;

    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:EXECCALL=\"${EXECCALL}\""

    if [ -n "${_ST}" -a "${_ST}" != DEFAULT -a "${_ST}" != ALL -a -n "${EXECCALLS[$x]// /}" ];then
	local _S=`serverRequire${_ST} ${EXECCALL}`
	printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_S=\"${_S}\""
	if [ -n "$_S" ];then
	    JOB_EXECSERVER[$_JOB_IDX]="${_S}"
	else
	    JOB_EXECSERVER[$_JOB_IDX]=" "
	fi

	local _C=`clientRequire${_ST} ${EXECCALL}`
	printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_C=\"${_C}\""
	if [ -n "$_C" ];then

	    local _base1="$R_OPTS"
	    local _base="`cliOptionsStrip KEEP -Z -d -- $_base1`"
	    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:REMOTE-ONLY:_base=<${_base}>"
	    if [ -n "${_base// /}" ];then
		_base="'( ${_base} )'"
	    fi
	    JOB_EXECCLIENTS[$_JOB_IDX]="${_C} ${EXECCALLS[$_JOB_IDX]}${_base}"
	else
	    JOB_EXECCLIENTS[$_JOB_IDX]=" "
	fi
    else
	case `getLocation ${EXECCALL}` in
	    CLIENTONLY)
                #HINT: may require host anyhow
		JOB_EXECSERVER[$_JOB_IDX]=" ";
		JOB_EXECCLIENTS[$_JOB_IDX]="${EXECCALL}";
		;;
	    *)
                #option "CONNECTIONFORWARDING" is not given, so it is either "-L SERVERONLY" 
                #or a Display Forwarding job.
		JOB_EXECSERVER[$_JOB_IDX]="${EXECCALL} ${EXECOPTIONS[$JOB_IDX]}";
		JOB_EXECCLIENTS[$_JOB_IDX]=" ";
		;;
	esac
    fi
    JOB_EXECCALLS[$_JOB_IDX]="${EXECCALLS[$x]}";

    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:OnStack:JOB_EXECCALLS[$_JOB_IDX] = ${JOB_EXECCALLS[$_JOB_IDX]}"
    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:OnStack:JOB_EXECCLIENTS[$_JOB_IDX] = ${JOB_EXECCLIENTS[$_JOB_IDX]}"
    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:OnStack:JOB_EXECSERVER[$_JOB_IDX] = ${JOB_EXECSERVER[$_JOB_IDX]}"
}


#FUNCBEG###############################################################
#NAME:
#  expandExecCall
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Expands the "ALL" attributes in given jobs and store them on execution 
#  stack as "single-exec" calls.
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
function expandExecCall () {
    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:\$*=$*"
    local x=$1;
    
    checkVersion ${L_VERS} ${C_MODE}

    case ${C_SESSIONTYPE} in
	ALL|DEFAULT)
            #Doing the split for session types locally saves implementation effort(priority now),
            #but costs some performance, ffs.
	    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:Split: C_SESSIONTYPE  =${C_SESSIONTYPE}"
	    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:Split: C_MODE         =${C_MODE}"
	    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME: =>PACKAGES_KNOWNTYPES=${PACKAGES_KNOWNTYPES}"
            case ${C_MODE} in
		LIST|ENUMERATE|SHOW|INFO)
		    EXECCALL=;
		    if [ -n "$C_EXECLOCAL" ];then
			eval handleGENERIC EXECUTE ${C_MODE} 
		    else
			eval handleGENERIC ASSEMBLE ${C_MODE} 
			assembleExeccall
		    fi
		    pushExecCall $x
		    local _match=1;
		    ;;
		*)
                    if [ ${C_SESSIONTYPE} != DEFAULT ];then
			local i=;
			for i in ${PACKAGES_KNOWNTYPES};do
			    EXECCALL=;
			    C_SESSIONTYPE=$i
			    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:C_SESSIONTYPE=${C_SESSIONTYPE}==\"${i}\""

			    if [ -n "$C_EXECLOCAL" ];then
				eval handle${i} EXECUTE ${C_MODE}
			    else
				eval handle${i} ASSEMBLE ${C_MODE}
				assembleExeccall
			    fi

			    printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME:EXECCALL=\"${EXECCALL}\""
 			    if [ -z "${EXECCALL}" ];then continue;fi
			    pushExecCall $x
 			done
			C_SESSIONTYPE=ALL
			local _match=1;
		    else
			printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME:MATCH-SUBTASK"
			R_OPTS="${R_OPTS} -w"
			if [ -z "$C_EXECLOCAL" ];then
			    assembleExeccall PROPAGATE
			fi

			case ${EXECCALLS[$x]} in 
			    *SUBTASK*|*SUBGROUP*)
				printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME:x=\"${x}\""
				pushExecCall $x PROPAGATE
				;;
			    *VMSTACK*)
				printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME:x=\"${x}\""
				pushExecCall $x PROPAGATE
				;;
			esac
		    fi
		    ;;
	    esac
	    ;;
 	*)
	    local i=;
            for i in ${PACKAGES_KNOWNTYPES};do
		if [ "${C_SESSIONTYPE}" == $i ];then
		    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:C_SESSIONTYPE:\"${C_SESSIONTYPE}\"==\"${i}\""
                    local _match=1;
                    case ${C_MODE} in
			LIST|ENUMERATE|SHOW|INFO)
			    if [ -n "$C_EXECLOCAL" ];then
				eval handleGENERIC EXECUTE ${C_MODE} 
			    else
 				eval handleGENERIC ASSEMBLE ${C_MODE} 
				assembleExeccall
			    fi
			    ;;
			*)
			    if [ -n "$C_EXECLOCAL" ];then
				eval handle${i} EXECUTE ${C_MODE}
			    else
				eval handle${i} ASSEMBLE ${C_MODE}
				assembleExeccall
			    fi
			    ;;
		    esac
		    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:EXECCALL=\"${EXECCALL}\""
 		    if [ -z "${EXECCALL}" ];then continue;fi
		    pushExecCall $x
		fi
            done
            ;;
    esac
    if [ -z "$_match" -a "${C_SESSIONTYPE}" != DEFAULT ];then
	ABORT=1;
	printERR $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:System Error, unexpected C_SESSIONTYPE=${C_SESSIONTYPE}"
	printERR $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:  PACKAGES_KNOWNTYPES=${PACKAGES_KNOWNTYPES}"
	printERR $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:  C_SESSIONTYPE   =${C_SESSIONTYPE}"
	printERR $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:  C_MODE          =${C_MODE}"
    fi
}


#FUNCBEG###############################################################
#NAME:
#  finalizeExecCall
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  As might be expected, it finalizes the assembley and superpostioning
#  of all options sets and makes up the resulting set.
#  This call is stored for further optimization possible only with
#  focus on groups of jobs or displays/desktops.
#
#  Therefore the jobs will be splitted, into client and server part, and 
#  allocated in the appropriate job-array, when "Connection Forwarding" 
#  is choosen.
#
#  In case of required client execution only for option "CONNECTIONFORWARDING" 
#  choosen with "-a connect.." option, the job will be stored in client 
#  array only.
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
function finalizeExecCall () {
    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME \$*=$*"
    local x=$1;shift
    local _calltarget=;
    local _ret=0;
    
    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "PutExecPrefix-Pre:JOB_EXECSERVER[$x]=<${JOB_EXECSERVER[$x]}>"
    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "PutExecPrefix-Pre:JOB_EXECCALLS[$x]=<${JOB_EXECCALLS[$x]}>"

    #Now the remote execution caller-prefix will be assembled
    JOB_EXECSERVER[$x]=`echo ${JOB_EXECSERVER[$x]}|sed 's/^ //'`;
    if [ -n "${JOB_EXECSERVER[$x]## /}" ];then
	EXECCALLBASE="`digGetExecLink ${JOB_EXECCALLS[$x]}` "
        #so local execution for $USER@localhost, change '-L' option for further processing
	_ret=$?;
	if [ $_ret -ne 0  ];then 
	    case $_ret in
		1)
                    #local user or cache only
		    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "LOCAL-STANDARD"
		    JOB_EXECSERVER[$x]=`cliOptionsReplace "-L LOCALONLY" -- ${JOB_EXECSERVER[$x]}`
 		    JOB_EXECSERVER[$x]="${EXECCALLBASE}${JOB_EXECSERVER[$x]}";
		    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:JOB_EXECSERVER[$x]=${JOB_EXECSERVER[$x]}"
		    ;;

		2)
		    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "LOCAL-SUBGROUP"
		    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "EXECCALLBASE=${EXECCALLBASE}"
		    local _delayedgroup="${EXECCALLBASE#*::}";
		    EXECCALLBASE="${EXECCALLBASE%%::*}";
		    local JOB_EXEC_="${JOB_EXECSERVER[$x]}";
		    if [ "`getLocation ${JOB_EXEC_}`" == CONNECTIONFORWARDING ];then
                        #Do it for CF, when no subgroup
			JOB_EXEC_=`cliOptionsReplace "-L LOCALONLY" -- ${JOB_EXEC_}`
		    fi
		    JOB_EXECSERVER[$x]="${EXECCALLBASE} ${JOB_EXEC_} ${_delayedgroup// /}'(${JOB_EXEC_#$MYCALLNAME})'";
		    local JOB_EXEC_="${JOB_EXECSERVER[$x]}";
		    JOB_EXECSERVER[$x]="${JOB_EXEC_// -E / }";

		    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:JOB_EXECSERVER[$x]=${JOB_EXECSERVER[$x]}"

		    printINFO 2 $LINENO $BASH_SOURCE 1 "${FUNCNAME}:delayed member executed as SUBGROUP=${_delayedgroup}"
		    printINFO 2 $LINENO $BASH_SOURCE 1 "${FUNCNAME}:JOB_EXECSERVER[$x]=${JOB_EXECSERVER[$x]}"
		    ;;

		3)
		    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "LOCAL-VMSTACK"
		    local _delayedgroup="${EXECCALLBASE#*::}";
		    EXECCALLBASE="${EXECCALLBASE%%::*}";
		    local JOB_EXEC_="${JOB_EXECSERVER[$x]}";
		    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:JOB_EXEC_=${JOB_EXEC_}"

		    if [ "`getLocation ${JOB_EXEC_}`" == CONNECTIONFORWARDING ];then
                        #Do it for CF, when no subgroup
			JOB_EXEC_=`cliOptionsReplace "-L LOCALONLY" -- ${JOB_EXEC_}`
		    fi
		    JOB_EXECSERVER[$x]="${EXECCALLBASE} ${JOB_EXEC_} ${_delayedgroup// /}'(${JOB_EXEC_#$MYCALLNAME})'";
		    local JOB_EXEC_="${JOB_EXECSERVER[$x]}";
		    JOB_EXECSERVER[$x]="${JOB_EXEC_// -E / }";

		    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:JOB_EXECSERVER[$x]=${JOB_EXECSERVER[$x]}"

		    printINFO 2 $LINENO $BASH_SOURCE 1 "${FUNCNAME}:delayed member executed as VMSTACK=${_delayedgroup}"
		    printINFO 2 $LINENO $BASH_SOURCE 1 "${FUNCNAME}:JOB_EXECSERVER[$x]=${JOB_EXECSERVER[$x]}"
		    ;;

		*)
		    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "UNKNOWN TASK-ID"
		    ;;
	    esac
	else
            if [ -z "$C_EXECLOCAL" ];then
		printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:FORWARD - remote execution"
		if [ -n "${R_PATH}" ];then
		    EXECCALLBASE="${EXECCALLBASE} export PATH=${R_PATH}\&\&"
		    JOB_EXECSERVER[$x]="${EXECCALLBASE}${JOB_EXECSERVER[$x]}";
		else
                    #yes, this is because of PATH/env is for OpenSSH different with "-t" option!
                    #is not absolutely reliable, but almost!
		    if [ "${EXECCALLBASE//ssh }" != "${EXECCALLBASE}" ];then
                        #eval remote
			if [ "$C_SSH_PSEUDOTTY" == 0 ];then
			    EXECCALLBASE="${EXECCALLBASE}${EXECSHELLWRAPPERNOPTY} "
			    [ -n "${EXECSHELLWRAPPER// /}" ]&&local _wrapped=1;
			else
			    EXECCALLBASE="${EXECCALLBASE}${EXECSHELLWRAPPER} "
			    [ -n "${EXECSHELLWRAPPERNOPTY// /}" ]&&local _wrapped=1;
			fi
                        #maybe redundant, but anyhow, ssh does not provide an error code, when exec fails
                        #whithin a bash-wrapper
			JOB_EXECSERVER[$x]="export PATH=\\\${PATH}:\\\${HOME}/bin\&\&${JOB_EXECSERVER[$x]}";
			if [ -n "${_wrapped}" ];then
			    JOB_EXECSERVER[$x]="${EXECCALLBASE}\'${JOB_EXECSERVER[$x]}\'";
			else
			    JOB_EXECSERVER[$x]="${EXECCALLBASE} ${JOB_EXECSERVER[$x]}";
			fi
		    else
                        #eval local
			EXECCALLBASE="${EXECCALLBASE} export PATH=${PATH}:${HOME}/bin&&"
			JOB_EXECSERVER[$x]="${EXECCALLBASE}${JOB_EXECSERVER[$x]}";
		    fi
		fi
	    fi
	    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:EXECCALLBASE=${EXECCALLBASE}"
 	    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:C_CLIENTLOCATION=${C_CLIENTLOCATION}"
            #set locality, if "LOCALONLY"
            if [ "${C_CLIENTLOCATION}" == "-L LOCALONLY" ];then
		JOB_EXECSERVER[$x]="${JOB_EXECSERVER[$x]/DISPLAYFORWARDING/LOCALONLY}";
 		printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:changed C_CLIENTLOCATION"
	    fi
	    
	    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:JOB_EXECSERVER[$x]=${JOB_EXECSERVER[$x]}"
	fi
    fi

    #Put the call prefix now to assigned client-job
    JOB_EXECCLIENTS[$x]=`echo ${JOB_EXECCLIENTS[$x]}|sed 's/^ //'`;
    if [ -n "${JOB_EXECCLIENTS[$x]}" ];then
        if [ -n "${L_PATH}" ];then
	    JOB_EXECCLIENTS[$x]="export PATH=${L_PATH}&&${JOB_EXECCLIENTS[$x]}";
	fi

        #could be a job with local host as controller of a remote-execution, or a copy e.g.
        if [ "`getLocation ${EXECCALL}`" == "CLIENTONLY" ];then
	    JOB_EXECCLIENTS[$x]="${JOB_EXECCLIENTS[$x]} ${JOB_EXECCALLS[$x]}";
        fi
    fi
    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:PutExecPrefix-Post:JOB_EXECSERVER[$x]=${JOB_EXECSERVER[$x]}"
}


#FUNCBEG###############################################################
#NAME:
#  doExecCall
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
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
function doExecCall () {
    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:ENTRY:CALL=<${@}>"
    printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "EXECUTE:job[$JOB_CNT]=<${@}>"
    showEnv ${D_BULK}
    local _ret=0;
    if [ -z "${C_NOEXEC}" ];then

	printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:Do it now:\"eval ...\""
	printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:CALL-RAW=<${@}>"

        #SSH manages asynchronous operations by '-f'
        #jobcontrol bundels parallel tasks

	local _call=;
	_call=$(cacheReplaceCtysAddress $@);
	_ret=$?;

        #################
        #if no hit,
        # -> due to error
        #    -> if nscacheonly 
        #       -> that's it
        #    -> else
        #       -> don't mind, just inform(as done)
        # -> if nscacheonly 
        #    -> that's it
        # -> don't mind
        #################
	if((_ret!=0));then
	    case ${C_NSCACHELOCATE} in
		1|2)
		    printERR $LINENO $BASH_SOURCE ${_ret} "$FUNCNAME:Cache error for requested resolution by."
		    printERR $LINENO $BASH_SOURCE ${_ret} "$FUNCNAME:local cacheDB."
		    printERR $LINENO $BASH_SOURCE ${_ret} "$FUNCNAME:Most common reason for that is ambiguity,"
		    printERR $LINENO $BASH_SOURCE ${_ret} "$FUNCNAME:check your cacheDB."
		    printERR $LINENO $BASH_SOURCE ${_ret} "$FUNCNAME:CALL=<${@}>"
		    if((C_NSCACHEONLY==1));then
			printERR $LINENO $BASH_SOURCE ${_ret} "$FUNCNAME:ABORT current CALL."
			return $_ret
		    fi
		    ;;
		3)
                    #relevant? ...anyhow
		    if [ -z "C_EXECLOCAL" ];then
			printERR $LINENO $BASH_SOURCE ${_ret} "$FUNCNAME:Cache error for requested resolution by."
			printERR $LINENO $BASH_SOURCE ${_ret} "$FUNCNAME:remote cacheDB."
			printERR $LINENO $BASH_SOURCE ${_ret} "$FUNCNAME:Most common reason for that is ambiguity,"
			printERR $LINENO $BASH_SOURCE ${_ret} "$FUNCNAME:check your cacheDB."
			printERR $LINENO $BASH_SOURCE ${_ret} "$FUNCNAME:CALL=<${@}>"
			if((C_NSCACHEONLY==1));then
			    printERR $LINENO $BASH_SOURCE ${_ret} "$FUNCNAME:ABORT current CALL."
			    return $_ret
			fi
		    fi
		    ;;
	    esac
	    printWNG 1 $LINENO $BASH_SOURCE 0 "$FUNCNAME:Cache error for requested resolution, continue"
	    printWNG 1 $LINENO $BASH_SOURCE 0 "$FUNCNAME:with scan, if should stop use \"-c ONLY\"."
	fi
	printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:CALL-CACHE-RESOLVED=<${_call}>"
	if [ -z "$_call" ];then
	    _ret=3;
	    printERR $LINENO $BASH_SOURCE ${_ret} "$FUNCNAME:Internal error in NAMESERVICE-CACHE=>empty CALL:"
	    printERR $LINENO $BASH_SOURCE ${_ret} "$FUNCNAME:  INPUT   =<${@}>"
	    printERR $LINENO $BASH_SOURCE ${_ret} "$FUNCNAME:  RESOLVED=<${_call}>"
	    printERR $LINENO $BASH_SOURCE ${_ret} "$FUNCNAME:temporary workaround: \"-c off\""
	    printERR $LINENO $BASH_SOURCE ${_ret} "$FUNCNAME:Please forward a bug report."
	    return $_ret
	fi
	if [ $_ret -ne 0 ];then
	    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_call=<${_call}>"
	fi

	printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:C_PARALLEL=<${C_PARALLEL}>"
	printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:C_STACK   =<${C_STACK}>"
        #activate job-control
        #
        #The special case of VMSTACK is handled here due to missing "actual-namespaces",
        #but required non-posining of companions
	if [ "${C_STACK}" == 1 ];then
	    local _R_C_SESSIONTYPE=`cliGetOptValue -t ${_call}`
	    printINFO 2 $LINENO $BASH_SOURCE 0 "$FUNCNAME:VMSTACK:force NON-CLI-HOSTSs to ASYNC:<$_R_C_SESSIONTYPE>"
	    case $_R_C_SESSIONTYPE in
		X11)
		    _call=${_call//ssh/ssh -f};
		    printINFO 2 $LINENO $BASH_SOURCE 0 "$FUNCNAME:VMSTACK:_call => <${_call}>"
		    printFINALCALL $LINENO $BASH_SOURCE "FINAL-DO-EXEC:" "eval ${_call} &"
 		    eval "${_call} &"; 
		    ;;
		VNC)
		    _call=${_call//ssh/ssh -f};
		    printINFO 2 $LINENO $BASH_SOURCE 0 "$FUNCNAME:VMSTACK:_call => <${_call}>"
		    printFINALCALL $LINENO $BASH_SOURCE "FINAL-DO-EXEC:" "{ eval ${_call}; }&"
 		    { eval "${_call}"; } &
		    ;;
		*)
		    if [ "${C_PARALLEL}" == 1 ];then
			printFINALCALL $LINENO $BASH_SOURCE "FINAL-DO-EXEC:" "{ eval ${_call}; }&"
 			{ eval "${_call}"; } &
		    else
			printFINALCALL $LINENO $BASH_SOURCE "FINAL-DO-EXEC:" "{ eval ${_call}; }"
			{ eval "${_call}"; }
		    fi
		    ;;
	    esac
	else
	    if [ "${C_PARALLEL}" == 1 ];then
		printFINALCALL $LINENO $BASH_SOURCE "FINAL-DO-EXEC:" "{ eval ${_call}; }&"
 		{ eval "${_call}"; } &
	    else
		printFINALCALL $LINENO $BASH_SOURCE "FINAL-DO-EXEC:" "eval ${_call}"
 		eval "${_call}"       
	    fi
	fi
    fi

    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:EXIT:CALL=<${@}>"
}


#FUNCBEG###############################################################
#NAME:
#  doExecCalls
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Ro be accomplished...
#
#  REMARKS:
#    - startup-delay: R_CLIENT_DELAY
#      After starting the server-only parts an delay is inserted for 
#      clients to bind to their server during bootstrap.
#      This might be in most of cases not necessary, but anyhow, 
#      for convincing new users is seems some more reliable.
#      Anyhow, be aware that the choosen value could be still too 
#      short when "big-servers" with intense-comands are started
#      probably on poor and overloaded hardware, and finally real 
#      slim clients on real fast hardware, ... 
#      ...and so on, thus it is an avarage, maybe too long for 
#      daily buiseness!
#      This value could be set by environment, and should be done so.
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
function doExecCalls () {
    local ssiz=0;
    local csiz=0;
    L_VERS=${L_VERS:-$VERSION}
    ssiz=${#JOB_EXECSERVER[@]};
    csiz=${#JOB_EXECCLIENTS[@]};
    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:Number of pending EXECCALLS     []=${#EXECCALLS[@]}"
    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:Number of pending JOB_EXECSERVER[]=$siz"
    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:Number of pending JOB_EXECCLIENTS[]=$siz"

    printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME:CHECK-SWITCH-TO-STACKMODE"
    if [ "$C_STACK" == "1" -a "$C_STACKMASTER" == "1" -a -z "$C_EXECLOCAL"  ];then
        #shift take control of batch-list to STACKER
        #be aware, that each job itself is still executed under standard framework control
	printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME:MACTH-STACKER-MODE"
        stackerController
	return
    fi
    printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME:CONTINUE-WITHOUT-STACKMODE"

    #Shortcut for single jobs. Anyhow, check stack first.
    printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME:SINGLE-CHECK"
    if((csiz==0&&ssiz==1));then
	doExecCall ${JOB_EXECSERVER[0]}
	JOB_EXECSERVER[$x]=;
	return
    fi
    printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME:START-SUBGROUPS"
    for((x=0;x<${ssiz};x++));do
	if [ -n "${JOB_EXECSERVER[$x]// /}" -a  "${JOB_EXECSERVER[$x]//SUBGROUP/}" != "${JOB_EXECSERVER[$x]// /}" ];then
	    doExecCall ${JOB_EXECSERVER[$x]}
	    JOB_EXECSERVER[$x]=;
            let JOB_CNT++;
	fi
    done
    printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME:START-SUBTASKS"
    for((x=0;x<${ssiz};x++));do
	if [ -n "${JOB_EXECSERVER[$x]// /}" -a  "${JOB_EXECSERVER[$x]//SUBTASK/}" != "${JOB_EXECSERVER[$x]// /}" ];then
	    doExecCall ${JOB_EXECSERVER[$x]}
	    JOB_EXECSERVER[$x]=;
            let JOB_CNT++;
	fi
    done

    #prepare remote calls for clients and servers
    printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME:START-NORMAL-EXECUTION"

    #Execute server-only calls, these execute "headless" in background mode, due to shorten overall
    #user-response-time the SERVERONLY parts of CONNECTIONFORWARDING will be executed too.
    #This is, because anytime multiple calls could be required with remote commands, thus sequentialized
    #access might not be the choice for multiple calls, though will be avoided as general approach.
    for((x=0;x<${ssiz};x++));do
	if [ -n "${JOB_EXECSERVER[$x]// /}" -a "`getLocation ${JOB_EXECSERVER[$x]}`" == "SERVERONLY" ];then
	    doExecCall ${JOB_EXECSERVER[$x]}
            let JOB_CNT++;
	    local _wait4jobs=1;
	fi
    done

    if [ -n "$_wait4jobs" ];then
        #... give them some delay for client binding for 
        #bootstrap, which might be in most of cases not necessary, but anyhow, 
        #for convincing new users is seems appropriate.
	printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "...give client some delay(${R_CLIENT_DELAY})..."
	sleep ${R_CLIENT_DELAY}
	unset _wait4jobs;
    fi

    ###########################################################################################################
    #                                                                                                         #
    #For now optimizing features - structure and stability -  performance and efficiency will follow later!!! #
    #                                                                                                         #
    ###########################################################################################################

    #if no support for multiple desktops is available, gwhich is currently solely on
    #the tool wmctrl, then just start anything on the current visible desktop.
    if [ -z "${C_MDESK}" ];then
 	printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "No support for desktops detected"
 	printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "Requires \"wmctrl\", will only be activated when \"-D\" option is used."

        #DISPLAYFORWARDING
	printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "Combined Server-Jobs with coallocated clients - DISPLAYFORWARDING"
	printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "Server jobs - CONNECTIONFORWARDING (ssiz=${ssiz})"
	for((x=0;x<${ssiz};x++));do
	    if [ -n "${JOB_EXECSERVER[$x]// /}" \
                 -a "`getLocation ${JOB_EXECSERVER[$x]}`" == "DISPLAYFORWARDING" \
            ];then
		doExecCall ${JOB_EXECSERVER[$x]}
		let JOB_CNT++;
	    fi
	done

        #LOCALONLY - doing it here gives some mor time for servers of CONNECTIONFORWARDING-Clients
	printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "Combined Server-Jobs to be executed locally - LOCALONLY"
	printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "Server jobs - LOCALONLY (ssiz=${ssiz})"
 	for((x=0;x<${ssiz};x++));do
	    if [ -n "${JOB_EXECSERVER[$x]// /}" \
                 -a "`getLocation ${JOB_EXECSERVER[$x]}`" == "LOCALONLY" \
            ];then
		doExecCall ${JOB_EXECSERVER[$x]}
		let JOB_CNT++;
	    fi
	done

        #CONNECTIONFORWARDING
	printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "Client jobs - CONNECTIONFORWARDING (csiz=${csiz})"
	for((x=0;x<${csiz};x++));do
	    if [ -n "${JOB_EXECCLIENTS[$x]}" ];then
		printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "JOB_EXECCLIENTS[$x]=${JOB_EXECCLIENTS[$x]}"
		doExecCall ${JOB_EXECCLIENTS[$x]}
		let JOB_CNT++;
	    fi
	done
    else
	printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "Support for desktops detected by \"wmctrl\" available."

        #DISPLAYFORWARDING  + CONNECTIONFORWARDING - Clients
        #
        #This will be done for each desktop together, beacuse a timeout for pop-up of 
        #windows on desktop is required. So this reduces the response time at least somewhat.
        #
        local match=0;
        for i in `desktopsGetDeskList`;do

            #DISPLAYFORWARDING - Server and/or Clients + LOCALONLY
	    for((x1=0;x1<${ssiz};x1++));do
		if [ -n "${JOB_EXECSERVER[$x1]// /}" ];then
		    if [ "`getDesktop ${JOB_EXECSERVER[$x1]}`" == "$i" ];then
                        case "`getLocation ${JOB_EXECSERVER[$x1]}`" in
			    DISPLAYFORWARDING|LOCALONLY)
				desktopsChange $i
				printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "JOB_EXECSERVER[$x1]=${JOB_EXECSERVER[$x1]}"
				doExecCall ${JOB_EXECSERVER[$x1]}
				let JOB_CNT++;
				match=1;
				;;
			esac
		    fi
		fi
	    done

            #CONNECTIONFORWARDING - Clients
	    for((x2=0;x2<${csiz};x2++));do
		if [ -n "${JOB_EXECCLIENTS[$x2]// /}" ];then
		    if [ "`getDesktop ${JOB_EXECCLIENTS[$x2]}`" == "$i" ];then
			if [ "`getLocation ${JOB_EXECCLIENTS[$x2]}`" == "CONNECTIONFORWARDING" ];then
                            desktopsChange $i
			    printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "JOB_EXECCLIENTS[$x2]=${JOB_EXECCLIENTS[$x2]}"
			    doExecCall ${JOB_EXECCLIENTS[$x2]}
			    let JOB_CNT++;
                            match=1;
			fi
		    fi
		fi
	    done

            #give them a chance to finish, but only if required - when switching desktop to be performed
            if [ "$match" == "1" ];then
                match=0;
		sleep ${X_DESKTOPSWITCH_DELAY};
	    fi
        done
    fi


    #handle local execution on server
    printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "Do local execs now."
    if [ -z "${ABORT}" -a -n "${C_EXECLOCAL}" ];then
        expandExecCall "${EXECCALL}"
	if [ -n "${EXECCALL}" ];then
	    doExecCall "${EXECCALL}"
            let JOB_CNT++;
	fi
    fi

    #activate job-control

######
#
#REMINDER-201005:Check this again!
#old:    
if [ "${C_PARALLEL}" == 1 ];then
#
######

#    if [ "${C_PARALLEL}" == 1 -a "${C_ASYNC}" == 0 ];then
	wait
    fi

    #Reset current to the initial face.
    desktopsSetStarting
}


#FUNCBEG###############################################################
#NAME:
#  doExecCallsPrologue
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Prepares execution of job queue.
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
function doExecCallsPrologue () {
    local siz=0;
    printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME:Number of pending EXECCALLS[]=$siz"

    L_VERS=${L_VERS:-$VERSION}

    #prepare remote calls for clients and servers
    printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME:Prepare call entries and split C/S parts."

    #extend "ALL" attributes
    siz=${#EXECCALLS[@]};
    for((x=0;x<${siz};x++));do
	printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:EXECCALLS[$x]=<${EXECCALLS[$x]}>"

        #If context specific options for remote execution are available superpose them.
        if [ -n "${EXECOPTIONS[$x]}" ];then
	    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:EXECOPTIONS[$x]=${EXECOPTIONS[$x]}"
            #set specific options for current target
            #be aware, in current implementation the specific options 
            #are just cumulated by overriding present options,
            #no previous state is stored or restored.
            #This might lead to unexpected states, thus be careful.
            fetchOptions REMOTE ${EXECOPTIONS[$x]}
	fi
	printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:EXECCALLS[$x]=${EXECCALLS[$x]}"
        expandExecCall $x
    done

    #split and set prefixes
    siz=${#JOB_EXECSERVER[@]};
    for((x=0;x<${siz};x++));do
	printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:JOB_EXECSERVER[$x]=${JOB_EXECSERVER[$x]}"
        finalizeExecCall $x
    done

    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:PROLOGUE:C_SESSIONTYPE=${C_SESSIONTYPE}"

    case ${C_SESSIONTYPE} in
	ALL|DEFAULT)
	    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:  => PACKAGES_KNOWNTYPES=${PACKAGES_KNOWNTYPES}"
            case ${C_MODE} in
		LIST|ENUMERATE|SHOW|INFO)
		    eval handleGENERIC PROLOGUE  ${C_MODE} 
		    local _match=1;
		    ;;
		*)
                    if [ ${C_SESSIONTYPE} != DEFAULT ];then
			for i in ${PACKAGES_KNOWNTYPES};do
			    C_SESSIONTYPE=$i
			    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME: => C_SESSIONTYPE=${C_SESSIONTYPE}"

			    eval handle${i} PROLOGUE ${C_MODE}
 			done
			C_SESSIONTYPE=ALL
			local _match=1;
		    fi
		    ;;
	    esac
	    ;;
 	*)
            for i in ${PACKAGES_KNOWNTYPES};do
		if [ "${C_SESSIONTYPE}" == $i ];then
		    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME: => C_SESSIONTYPE=${C_SESSIONTYPE}"
                    local _match=1;
                    case ${C_MODE} in
			LIST|ENUMERATE|SHOW|INFO)
			    eval handleGENERIC PROLOGUE ${C_MODE} 
			    ;;
			*)
			    eval handle${i} PROLOGUE ${C_MODE}
			    ;;
		    esac

		fi
            done
            ;;
    esac

}


#FUNCBEG###############################################################
#NAME:
#  doExecCallsEpilogue
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Prepares execution of job queue.
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
function doExecCallsEpilogue () {
    local siz=0;
    printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME:Number of pending EXECCALLS[]=$siz"

    L_VERS=${L_VERS:-$VERSION}

    #prepare remote calls for clients and servers
    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:Postfix whatever it might be"
    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:EPILOGUE:C_SESSIONTYPE=${C_SESSIONTYPE}"

    case ${C_SESSIONTYPE} in
	ALL|DEFAULT)
	    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:  => PACKAGES_KNOWNTYPES=${PACKAGES_KNOWNTYPES}"
            case ${C_MODE} in
		LIST|ENUMERATE|SHOW|INFO)
		    eval handleGENERIC EPILOGUE  ${C_MODE} 
		    local _match=1;
		    ;;
		*)
                    if [ ${C_SESSIONTYPE} != DEFAULT ];then
			for i in ${PACKAGES_KNOWNTYPES};do
			    C_SESSIONTYPE=$i
			    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME: => C_SESSIONTYPE=${C_SESSIONTYPE}"

			    eval handle${i} EPILOGUE ${C_MODE}
 			done
			C_SESSIONTYPE=ALL
			local _match=1;
		    fi
		    ;;
	    esac
	    ;;
 	*)
            for i in ${PACKAGES_KNOWNTYPES};do
		if [ "${C_SESSIONTYPE}" == $i ];then
		    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME: => C_SESSIONTYPE=${C_SESSIONTYPE}"
                    local _match=1;
                    case ${C_MODE} in
			LIST|ENUMERATE|SHOW|INFO)
			    eval handleGENERIC EPILOGUE ${C_MODE} 
			    ;;
			*)
			    eval handle${i} EPILOGUE ${C_MODE}
			    ;;
		    esac
		fi
            done
            ;;
    esac
}



#FUNCBEG###############################################################
#NAME:
#  execGetNumberOfJobs
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Returns the total number current jobs, this includes any state.
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
function execGetNumberOfJobs () {
    return $JOB_CNT
}


#FUNCBEG###############################################################
#NAME:
#  execGetCurentJobIdx
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Returns the index of the next job to executed. A check against the 
#  actual total number of jobs has to be performed.
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
function execGetCurentJobIdx () {
    return $JOB_IDX
}


#FUNCBEG###############################################################
#NAME:
#  execCurentJob
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Executes and updates the JOB_IDX. The actual execution state is 
#  signalled by the return code.
#
#EXAMPLE:
#
#PARAMETERS:
# $1: CLIENT|SERVER
#     
#
#OUTPUT:
#  RETURN:
#    0:  A job was still on the stack, and is executed.
#    99: When no job was pending to be executed, a return value 
#        of 99 is returned.
#
#  VALUES:
#
#FUNCEND###############################################################
function execCurentJob () {
    if [ -n "${JOB_EXECCLIENTS[$x]}" ];then
	printDBG $S_CORE ${D_FLOW} $LINENO $BASH_SOURCE "JOB_EXECCLIENTS[$x]=${JOB_EXECCLIENTS[$x]}"
	doExecCall ${JOB_EXECCLIENTS[$x]}
	let JOB_CNT++;
    fi
    return $JOB_IDX
}
