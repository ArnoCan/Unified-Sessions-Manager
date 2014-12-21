#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_003
#
########################################################################
#
# Copyright (C) 2007,2008,2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

_myPKGNAME_DIGGER="${BASH_SOURCE}"
_myPKGVERS_DIGGER="01.11.003"
hookInfoAdd "$_myPKGNAME_DIGGER" "$_myPKGVERS_DIGGER"

_myPKGBASE_DIGGER=`dirname ${_myPKGNAME_DIGGER}`

hookPackage "${_myPKGBASE_DIGGER}/list.sh"


#FUNCBEG###############################################################
#NAME:
#  digLocalPort
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Supports a local port to the listener port given by <host>:<label>.
#  <label> is a free defined label by user, gwhich has to be unique on 
#  the target host.
#
#  The port is forwarded as an encrypted channel by usage of ssh port 
#  forwarding.
#
#  For the evaluation of the port value from the label a package 
#  specific functio is called:
#
#    "digLocalPort<package-id> <host>:<label>"
#
#  Local label access is supported by a simple trick, the ssh call will 
#  be performed as a one-shot emulation anyway, so the label will be 
#  supported as a remote call comment, e.g. like:
#
#  Defined format:
#    CALL:
#      "ssh -f -L 6001:localhost:5901 host01 sleep <timeout> \&\&\
#        echo "# DYNREMAP:<package>:<host>:<port>:<label>:<rport>:<myhost>:<uid>:<gid>:<pid>:<ppid>:<jobid>:">/dev/null 
#              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#                         \1        \2     \3     \4      \5      \6       \7    \8    \9    \10    \11
#
#
#      <timeout>=${SSH_ONESHOT_TIMEOUT}
#
#  The tunnel has to be used before the timer expires, but once in usage it
#  will remain until the client is closed. During the whole lifetime of the
#  tunnel the label and any additional text will be shown and could be 
#  accessed by ps/grep/awk.
#
#  The particularly important part here is the simplified dynamic decision
#  of the port to be used for mapping. Therefor the highest port incremented by 1
#  will be tried. The initial port is provided by LOCAL_PORTREMAP
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: <package>
#  $2: <host>
#  $3: <label>
#  $4: [<id>|<pname>]
#  $5: [<blacklist>]
#
#GLOBALS:
#  LOCAL_PORTREMAP
#    The base for local port remapping.
#  SSH_ONESHOT_TIMEOUT
#
#OUTPUT:
#  RETURN:
#  VALUES:
#    <local-port>
#      The local port number for accessing <label>@<host>
#
#FUNCEND###############################################################
function digLocalPort () {
    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME package   \$1=$1"
    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME host      \$2=$2"
    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME label     \$3=$3"
    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME id        \$4=$4"
    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME blacklist \$5=$5"

    if [ -z "$1" ];then
        ABORT=2
        printERR $LINENO $BASH_SOURCE ${ABORT} "SYSTEM error, Missing package"
        gotoHell ${ABORT} 
    fi

    if [ -z "$2" ];then
        ABORT=2
        printERR $LINENO $BASH_SOURCE ${ABORT} "Missing host for remote tunnel"
        gotoHell ${ABORT} 
    fi
    if [ -z "$3" ];then
        ABORT=2
        printERR $LINENO $BASH_SOURCE ${ABORT} "Missing label for target"
        gotoHell ${ABORT} 
    fi

    local _blst=$5;

    local _rhost=`echo "${2}"|sed 's/(/"(/g;s/)/)"/g'`;
    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME _rhost=$_rhost"

    local remoteClientTP=`eval digGetClientTPfromServer "$3" "${_rhost}" "$1" "$4"`

    _rhost=`echo "${_rhost}"|sed 's/"([^)]*)"//g'`;

    if [ -z "${remoteClientTP}" ];then
        ABORT=2
	printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "Cannot create SSH tunnel, missing remote port."
	eval noClientServerSplitSupportedMessage${C_SESSIONTYPE}
        gotoHell ${ABORT} 
    fi

    #take first free
    local localClientAccess=`ps ${PSEF} |grep -v sed |sed -n '/# DYNREMAP:/!d;s/.* \([0-9]*:localhost:[0-9]*\) .*/\1/;p'|\
       sort|awk -F':' ${_blst:+ -v b="$_blst"} 'BEGIN{max=0;}$1!=b{if(max!=0&&($1-max)>1){exit;} if(max<$1)max=$1;}END{print max+1;}'`

    #if this is the first
    if [ "${localClientAccess}" == "1" ];then
	localClientAccess=${LOCAL_PORTREMAP}
    fi

    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME Using for port forwarding - aka CONNECTIONFORWARDING:"
    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME   Keyword for dynamic port evaluation of forwarding processes:"
    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME   grep-keyword         = \"# DYNREMAP\""
    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME   timeout for connect  = ${SSH_ONESHOT_TIMEOUT}"
    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME "
    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME   localClientAccess    = ${localClientAccess}"
    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME   remoteClientTP       = ${remoteClientTP}"
    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME "


    local _tunnel="ssh -f -L ${localClientAccess}:localhost:${remoteClientTP} $_rhost sleep ${SSH_ONESHOT_TIMEOUT} \# DYNREMAP:$1:$_rhost:${localClientAccess}:$3:${remoteClientTP}:${MYHOST}:${MYUID}:${MYGID}:${MYPID}:${MYPPID}:${CALLERJOB//:/-}-$((JOB_IDXSUB++))"

    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME "
    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME Assembled tunnel-call:"
    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME _tunnel=${_tunnel}"
    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME "
    printFINALCALL $LINENO $BASH_SOURCE "FINAL-DO-EXEC:" "eval $_tunnel"
    eval $_tunnel

    if [ $? -ne 0 ];then
        ABORT=1
        printERR $LINENO $BASH_SOURCE ${ABORT} "openning port forwarding tunnel failed"
        printERR $LINENO $BASH_SOURCE ${ABORT} "  CALLED:<${_tunnel}>"
        gotoHell ${ABORT} 
    fi

    echo ${localClientAccess}
}


#FUNCBEG###############################################################
#NAME:
#  digGetLocalPort
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Finds the local port for a remote accesspoint. This is an forwarded 
#  clientTP established by digLocalPort to be used for client access.
#  
#  When multiple would match, the first is returned.
#
#  ATTENTION: 
#    The so called tunnel is established as a one-shot channel with an
#    timeout, there might be closed already when applying this function,
#    or might be closed after successful detection, when the following 
#    access has too long delay.
#    Thus do not shorten the value of SSH_ONESHOT_TIMEOUT dramatically!
#    Give it almost half a minute for starting, because a misusage might
#    be in single(?)-user working environment with localhost access not
#    really to be expected.
#
#  Defined format:
#   ....ssh -f -L 4801:localhost:4801 host sleep <timeout> \
#      # DYNREMAP:<package>:<host>:<port>:<label>:<rport>:<myhost>
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: <label>
#  $2: [<package>]
#  $3: [<host>]
#
#OUTPUT:
#  RETURN:
#  VALUES:
#    <local-port>
#      The local port number for accessing <label>@<host>
#
#FUNCEND###############################################################
function digGetLocalPort () {
    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME CALL=<${@}>"

    #
    #....ssh -f -L 4801:localhost:4801 host sleep 1000 \
    #             # DYNREMAP:<package>:<host>:<port>:<label>:<rport>:<myhost>:<uid>:<gid>:<pid>:<ppid>:<JobID//:/->
    #                         \1        \2     \3      \4     \5       \6     \7    \8    \9    \10    \11

    local _localClientAccess=`ps ${PSEF} |grep -v sed |sed -n '
        /# DYNREMAP/!d;
        s/.*# DYNREMAP:\([^:]*\):\([^:]*\):\([0-9]*\):\([^:]*\):\([^:]*\):\([^:]*\):\([^:]*\):\([^:]*\):\([^:]*\):\([^:]*\):\([^:]*\)[^:]*$/\1:\2:\3:\4:\5:\6:\7:\8:\9:\10\11/p
        '|awk -F':' -v l="$1" -v p="$2" -v h="$3" '
           BEGIN{port=0;}
           $4~l&&$2~h&&$1~p{print $3;exit;}
           $4~l&&$2~h&&p==/^$/{print $3;exit;}
           $4~l&&h~/^$/&&p~/^$/{print $3;exit;}
        '`
    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME _localClientAccess=${_localClientAccess}"
    echo ${_localClientAccess}
}


#FUNCBEG###############################################################
#NAME:
#  digGetClientTPfromServer
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Gets remote port, of course some performance tuning could be done....
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: <label>
#  $2: [<host>]
#  $3: [<package>]
#  $4: [<id>|<pname>]
#
#OUTPUT:
#  RETURN:
#  VALUES:
#    <local-port>
#      The local port number for accessing <label>@<host>
#
#FUNCEND###############################################################
function digGetClientTPfromServer () {
    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME CALL=<${*}>"
    if [ -n "${C_DARGS}" ];then
	local _rcall="${MYLIBEXECPATHNAME} -t ${3:-$C_SESSIONTYPE} -a GETCLIENTPORT=$1${4:+,$4} ${C_DARGS} ${2:-$R_HOSTS}'(${C_DARGS})'"
    else
	local _rcall="${MYLIBEXECPATHNAME} -t ${3:-$C_SESSIONTYPE} -a GETCLIENTPORT=$1${4:+,$4} ${C_DARGS} ${2:-$R_HOSTS}"
    fi
#    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME _rcall=${_rcall}"
    printFINALCALL $LINENO $BASH_SOURCE "FINAL-GETCLIENTPORT-CALL" "${_rcall}"
    local _cPort=`$_rcall`
    printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME _cPort=${_cPort}"
    echo ${_cPort#*=}
}


#FUNCBEG###############################################################
#NAME:
#  digGetExecLink
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Sets the complete remote ssh call prefix, including the host. This is 
#  in distinction to the function "getExecTarget" the setup of the tunnel
#  call or local operation respectively. The "getExecTarget" is the 
#  interface for the name service of ctys in order of target location.
#
#  The own user on localhost is just dropped for local execution without
#  ssh-call to ${USER}@localhost.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: <host>
#
#OUTPUT:
#  RETURN:
#    0: remote-config:       ssh...
#    1: local-config:        cd $HOME&&
#    2: delayed-subgroup  :  cd $HOME&&::${_grp}
#    3: delayed-stackgroup:  cd $HOME&&::${_grp}   
#       requires "-b STACK" on intermediate relay.
#
#  VALUES:
#    <ssh-exec-prefix>  string a prefix for call
#
#FUNCEND###############################################################
function digGetExecLink () {
    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:TARGET(\$1-only!!!)=${*}"
    local _EXECLINK=""

    if [ -z "${1}" ];then
	return
    fi

    #check masking of braces, but might be first/last positioned, though 
    #should not be critical
    if [ "${1//SUBGROUP\{/}" != "${1}" ];then
        local _grp="${1// /}";
        _grp="${_grp//SUBGROUP\{/}";
        _grp="${_grp%\}}";
	local _ret="cd ${HOME}&&::${_grp}"
	printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:SUBGROUP detected:${_ret}"
	echo -n -e "${_ret}"
        return 2
    fi

    #check masking of braces, but might be first/last positioned, though 
    #should not be critical
    if [ "${1//VMSTACK\{/}" != "${1}" ];then
	local _grp="${1// /}";
	_grp="${_grp//VMSTACK\{/}";
	_grp="${_grp%\}}";
	local _ret="cd ${HOME}&&::${_grp}"
	printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:VMSTACK detected:${_ret}"
	echo -n -e "${_ret}"
	return 3
    fi


    if [ "${C_CACHEONLY}" != 0 ];then
	printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:use cached data only"
	printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:   \"cd \$HOME&&\" "
	echo -n "cd $HOME&&"
	return 1
    fi

    local _target="${1// }";
    if [ "${_target}" == "localhost" -o "${_target}" == "${USER}@localhost" ];then
	printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:local native execution for USER=$USER"
	printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:for unified PATH semantics:"
	printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:   \"cd \$HOME&&\" "
	echo -n "cd $HOME&&"
	return 1
    fi

    #OK - Even though it might to be executed on localhost, it is not the same USER!
    #So use SSH.
    if [ -n "${C_SSH}" ];then
	_EXECLINK="ssh -X "

	printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:C_SSH_PSEUDOTTY=${C_SSH_PSEUDOTTY}"

	if((C_SSH_PSEUDOTTY==1));then
	    _EXECLINK="${_EXECLINK} -t ";
	else
	    if((C_SSH_PSEUDOTTY>=2));then
		_EXECLINK="${_EXECLINK} -t -t";
	    else
		C_SSH_PSEUDOTTY=0;
	    fi
	fi
	
	if [ -n "${C_ASYNC}" -a "${C_ASYNC}" == 1 ];then
	    _EXECLINK="${_EXECLINK} -f "
	fi

	if [ -n "${C_AGNTFWD}" -a "${C_AGNTFWD}" == 1 ];then
	    _EXECLINK="${_EXECLINK} -A "
	fi

	if [ "$WNG" == 0 ];then
	    _EXECLINK="${_EXECLINK} -q "
	fi



	_EXECLINK="${_EXECLINK} ${_target}"

	printDBG $S_CORE ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_EXECLINK=${_EXECLINK}"

	if((C_SSH_PSEUDOTTY<2));then
	    if [ -n "${USE_SUDO}" ];then
		printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:SUDO requires frequently a TTY"
		printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME: 1. set C_SSH_PSEUDOTTY($C_SSH_PSEUDOTTY) by 2*PTY"
		printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME: 2. check \"requiretty\" in \"/etc/sudoers\""
	    fi
	fi
    else
	ABORT=1
	printERR $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:Only SSH sessions are supported for remote execution."
	gotoHell ${ABORT}
    fi
    echo -n "${_EXECLINK}"
}


#FUNCBEG###############################################################
#NAME:
#  digCheckLocal
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Checks whether it is a local call perfoming within user sessiosn, or 
#  remote call with an own ssh connection.
#
#EXAMPLE:
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#    0: local exec
#    1: remote exec
#  VALUES:
#
#FUNCEND###############################################################
function digCheckLocal () {
    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:R_HOSTS=${R_HOSTS}"
    if [ "$R_HOSTS" == "localhost" ];then
	return 0
    fi
    return 1
}


#FUNCBEG###############################################################
#NAME:
#  digGetSSHTarget
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Returns the target machine of a ssh-call, if not matched no output 
#  is provided.
#
#  For simlicity, the ctys-standard format including user and host is
#  expected for the target.
#
#EXAMPLE:
#
#PARAMETERS:
#  $*: <complete-ssh-exec-call-string>
#
#OUTPUT:
#  RETURN:
#    0: matched
#    1: else
#  VALUES:
#    [<exec-target>]
#       If present, the variants of "localhost" are treated as fully 
#       recognized remote machines here.
#
#FUNCEND###############################################################
function digGetSSHTarget () {
    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=${@}"
    local _x="${@}"

    if [ -z "$_x" ];then
	return 1
    fi

    _x=${_x#*ssh };
    if [ "${*}" != "${_x}" ];then
	_x=${_x#*@}
	_x=${_x%% *}
	echo -n -e "${_x}"
	return 0
    fi
    return 1
}
