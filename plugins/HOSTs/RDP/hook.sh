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

RDP_MAGIC=RDP_GENERIC;
RDP_VERSTRING=;
RDP_STATE=DISABLED;
RDPSERVER_OPT=;
RDPVIEWER_OPT=;
RDP_PREREQ=;
RDP_PRODVERS=;


export RDP_BASEPORT=${RDP_BASEPORT:-5900}
export RDPDESKIDLIST=;
export RDPWM=;

export RDPC=;
export RDPC_OPT=;


_myPKGNAME_RDP="${BASH_SOURCE}"
_myPKGVERS_RDP="01.11.005alpha"
hookInfoAdd $_myPKGNAME_RDP $_myPKGVERS_RDP
_myPKGBASE_RDP="${_myPKGNAME_RDP%/hook.sh}"


RDP_VERSTRING=${_myPKGVERS_RDP};
RDP_PREREQ="HOST-CAPABILITY:RDP-${RDP_VERSTRING}-${MYARCH}";


if [ -d "${HOME}/.ctys" -a -d "${HOME}/.ctys/rdp" ];then
    if [ -f "${HOME}/.ctys/rdp/rdp.conf-${MYOS}.sh" ];then
	. "${HOME}/.ctys/rdp/rdp.conf-${MYOS}.sh"
    fi
fi

if [ -d "${MYCONFPATH}" -a -d "${MYCONFPATH}/rdp" ];then
    if [ -f "${MYCONFPATH}/rdp/rdp.conf-${MYOS}.sh" ];then
	. "${MYCONFPATH}/rdp/rdp.conf-${MYOS}.sh"
    fi
fi



_waitcRDP=${RDP_INIT_WAITC:-2}
_waitsRDP=${RDP_INIT_WAITS:-2}



#FUNCBEG###############################################################
#NAME:
#  getFirstFreeRDPPort
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Gets the first free port above a given base, thus multiple regions
#  could be managed
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: <MIN>
#  $2: [<MAX>]
#
#OUTPUT:
#  RETURN:
#  VALUES:
#    <first-port>
#
#FUNCEND###############################################################
function getFirstFreeRDPPort () {
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:CALL=<${*}>"
    local MIN=${1:-$RDP_BASEPORT};
    local MAX=$2;
    [ -z "$MAX" ]&&let MAX=MIN+1000;
    local _seed=$((RANDOM%RDPPORTSEED));
    doDebug $S_XEN  ${D_MAINT} $LINENO $BASH_SOURCE
    local D=$?

    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:MIN=${MIN} MAX=${MAX} seed=${_seed}"
    case ${MYOS} in
	Linux)
	    local localClientAccess=`${CTYS_NETSTAT} -n -l -t|awk -v d="${D}" -v min="${MIN}" -v max="${MAX}" -v seed="${_seed}" -f ${_myPKGBASE_RDP}/getFirstFreeRDPPort-${MYOS}.awk`
	    ;;
	FreeBSD|OpenBSD)
	    local localClientAccess=`${CTYS_NETSTAT} -n -l -t|awk -v d="${D}" -v min="${MIN}" -v max="${MAX}" -v seed="${_seed}" -f ${_myPKGBASE_RDP}/getFirstFreeRDPPort-${MYOS}.awk`
	    ;;
	SunOS)
	    local localClientAccess=`${CTYS_NETSTAT} -n -l -t|awk -v d="${D}" -v min="${MIN}" -v max="${MAX}" -v seed="${_seed}" -f ${_myPKGBASE_RDP}/getFirstFreeRDPPort-${MYOS}.awk`
	    ;;
    esac
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:localClientAccess=<${localClientAccess}>"
    echo -n -e "${localClientAccess}";
}

#FUNCBEG###############################################################
#NAME:
#  getFirstFreeRDPDisplay
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Gets the first free display above a given base, thus multiple regions
#  could be managed
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: <MIN>
#  $2: [<MAX>]
#
#OUTPUT:
#  RETURN:
#  VALUES:
#    <first-port>
#
#FUNCEND###############################################################
function getFirstFreeRDPDisplay () {
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:CALL=<${*}>"
    local MIN=${1:-$RDP_BASEPORT};
    local MAX=$2;
    [ -z "$MAX" ]&&let MAX=RDP_PORT+1000;
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:MIN=${MIN} MAX=${MAX}"
    local _myPort=`getFirstFreeRDPPort ${@}`
    local _myDisplay=$((_myPort-MIN));
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_myPort=<${_myPort}>"
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_myDisplay=<${_myDisplay}>"
    echo -n -e "${_myDisplay}";
}


#FUNCBEG###############################################################
#NAME:
#  serverRequireRDP
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Reports whether a server component has to be called for the current
#  action.
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
#    INPUT, where required changes for destination are set.
#  VALUES:
#    0: true, required - output is valid.
#    1: false, not required - output is not valid.
#
#FUNCEND###############################################################
function serverRequireRDP () {
    printDBG $S_RDP ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME \$@=$@"
    local _ret=1;
    local _res=;

    local _S=`getSessionType ${*}`;_S=${_S:-$C_SESSIONTYPE};
    local _A=`getActionResulting ${*}`;
    case $_A in
	GETCLIENTPORT)
	    printDBG $S_RDP ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_res=\"${*}\""
	    printDBG $S_RDP ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_ret=\"0\""
	    echo -n "${*}";
	    return 0
	    ;;
    esac

    local _CS_SPLIT=${*};
    _CS_SPLIT=${_CS_SPLIT//CONNECTIONFORWARDING/SERVERONLY}
    _CS_SPLIT=${_CS_SPLIT//*LOCALONLY*/}
    _CS_SPLIT=${_CS_SPLIT//*CLIENTONLY*/}
    if [ -n "${_CS_SPLIT}" ];then
	_res="${_CS_SPLIT}";_ret=0;
    fi


    printDBG $S_RDP ${D_MAINT} $LINENO $BASH_SOURCE "_CS_SPLIT=\"${_CS_SPLIT}\""
    printDBG $S_RDP ${D_MAINT} $LINENO $BASH_SOURCE "_S=\"${_S}\""
    printDBG $S_RDP ${D_MAINT} $LINENO $BASH_SOURCE "_A=\"${_A}\""

    printDBG $S_RDP ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_res=\"${_res}\""
    printDBG $S_RDP ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_ret=\"${_ret}\""
    echo -n "${_res}";
    return ${_ret};  
}



#FUNCBEG###############################################################
#NAME:
#  clientRequireRDP
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Reports whether a client component has to be called for the current
#  action.
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
#    INPUT, where required changes for destination are set.
#  VALUES:
#    0: true, required - output is valid.
#    1: false, not required - output is not valid.
#
#FUNCEND###############################################################
function clientRequireRDP () {
    printDBG $S_RDP ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME \$@=$@"
    local _ret=1;
    local _res=;

    local _A=`getActionResulting ${*}`;

    local _S=`getSessionType ${*}`;_S=${_S:-$C_SESSIONTYPE};
    local _CS_SPLIT=${*};
    _CS_SPLIT=${_CS_SPLIT//*DISPLAYFORWARDING*/}
    _CS_SPLIT=${_CS_SPLIT//*SERVERONLY*/}
    if [ "${_CS_SPLIT}" == "${*}" ];then
	_res="${_CS_SPLIT}";_ret=0;
    fi
    printDBG $S_RDP ${D_MAINT} $LINENO $BASH_SOURCE "_CS_SPLIT=\"${_CS_SPLIT}\""
    printDBG $S_RDP ${D_MAINT} $LINENO $BASH_SOURCE "_S=\"${_S}\""
    printDBG $S_RDP ${D_MAINT} $LINENO $BASH_SOURCE "_A=\"${_A}\""

    printDBG $S_RDP ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_res=\"${_res}\""
    printDBG $S_RDP ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_ret=\"${_ret}\""
    echo -n "${_res}";
    return ${_ret};  
}






#FUNCBEG###############################################################
#NAME:
#  setVersionRDP
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Sets defaults and MAGIC-ID for local vmware version.
#
#EXAMPLE:
#
#PARAMETERS:
#
#
#OUTPUT:
#  GLOBALS:
#    RDP_MAGIC:  {RDP_REAL412|RDP_TIGHT129|...}
#      Value to be checked.
#
#    VMW_DEFAULTOPTS
#      Appropriate defaults.
#
#      -RealRDP  - 4.1.2 
#      -TightRDP - 1.2.9
#
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function setVersionRDP () {
    local _checkonly=;
    local _ret=0;
    if [ "$1" == "NOEXIT" ];then
	local _checkonly=1;        
    fi

    RDPC=;
    RDPC_OPT=;
    local _verstrg=;

#     if [ -n "$RDPTSC" ];then
# 	local _verstrg_tsc=$(${RDPTSC} --version|awk '$0~/version/&&$0~/tsclient/{print $NF}')
# 	_verstrg_tsc="${RDPTSC##*/}-$_verstrg_tsc"

# 	if [ -z "$_verstrg_tsc" ];then
# 	    if [ -n "`${RDPTSC} --help 2>&1|egrep '(open display:)'`" ];then
# 		printWNG 1 $LINENO $BASH_SOURCE 0  "DISPLAY is not available"
# 		printWNG 1 $LINENO $BASH_SOURCE 0  " 1. One common cause is the call of \"ssh\" without the \"-X\""
# 		printWNG 1 $LINENO $BASH_SOURCE 0  "    option. Even for the utilized check by \"rdpviewer --help\" "
# 		printWNG 1 $LINENO $BASH_SOURCE 0  "    option a display is required."

#                 #OpenBSD-4.6+
# 		printWNG 1 $LINENO $BASH_SOURCE 0  " 2. Another common cause for the initial usage is the missing "
# 		printWNG 1 $LINENO $BASH_SOURCE 0  "    permission \"X11Forwarding yes\" in \"/etc/ssh/sshd_conf\"."
#   		_verstrg_tsc=GENERIC
# 		_ret=0;
# 	    fi
# 	fi
# 	RDP_PREREQ="${RDP_PREREQ}%${_verstrg_tsc}-${MYARCH}";
#     fi

    if [ -n "$RDPRDESK" ];then
	_verstrg_rd=$(${RDPRDESK} --help 2>&1|awk '$0~/Version/&&$0~/Copyright/{print $2}')
	_verstrg_rd="${RDPRDESK##*/}-$_verstrg_rd"
	RDP_PREREQ="${RDP_PREREQ}%${_verstrg_rd}-${MYARCH}";
    fi


    if [ -n "$RDPRDESK" ];then
	RDPC="$RDPRDESK"
	RDPC_OPT="$RDPRDESK_OPT"
	RDPC_NATIVE="$RDPRDESK_NATIVE"
	_verstrg=$_verstrg_rd
#     else
# 	RDPC="$RDPTSC"
# 	RDPC_OPT="$RDPTSC_OPT"
# 	RDPC_NATIVE="$RDPTSC_NATIVE"
# 	_verstrg=$_verstrg_tsc
    fi

    if [ -z "${RDPC}" ];then
	ABORT=2
	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing supported executables for RDP client"
	printERR $LINENO $BASH_SOURCE ${ABORT} "can not find:"
	printERR $LINENO $BASH_SOURCE ${ABORT} " -> rddesktop"
# 	printERR $LINENO $BASH_SOURCE ${ABORT} " -> tsclient"
	printERR $LINENO $BASH_SOURCE ${ABORT} ""
	printERR $LINENO $BASH_SOURCE ${ABORT} "Check your PATH"
	printERR $LINENO $BASH_SOURCE ${ABORT} " -> PATH=${PATH}"
	printERR $LINENO $BASH_SOURCE ${ABORT} ""
	if [ "${C_SESSIONTYPE}" == "RDP" -a -z "${_checkonly}" ];then
	    gotoHell ${ABORT}
	else
	    return ${ABORT}
	fi
	_ret=${ABORT};
    fi




    printDBG $S_RDP ${D_BULK} $LINENO $BASH_SOURCE "RDPC=$RDP"
    printDBG $S_RDP ${D_BULK} $LINENO $BASH_SOURCE "_verstrg=${_verstrg}"


    #currently somewhat restrictive to specific versions.
    case ${_verstrg} in
# 	"tsclient"*)
# 	    RDP_MAGIC=RDPTSC;
# 	    RDP_STATE=ENABLED;
# 	    RDP_PREREQ="${RDP_PREREQ}%DEFAULT:${_verstrg}-${MYARCH}";
# 	    _ret=0;
# 	    ;;

	"rdesktop"*)
	    RDP_MAGIC=RDPRD;
	    RDP_STATE=ENABLED;
	    RDP_PREREQ="${RDP_PREREQ}%DEFAULT:${_verstrg}-${MYARCH}";
	    _ret=0;
	    ;;

         *)
	    RDP_MAGIC=RDPG;
	    RDP_PREREQ="${RDP_PREREQ}%DEFAULT:${_verstrg}-${MYARCH}";
	    _ret=2;
	    ;;
    esac

    RDP_PRODVERS="${_verstrg}";
    RDP_PRODVERS="${RDP_PRODVERS// /}";
    RDP_PRODVERS="${RDP_PRODVERS//;/}";
    RDP_PRODVERS="${RDP_PRODVERS//,/}";

    printDBG $S_RDP ${D_BULK} $LINENO $BASH_SOURCE "RDP_MAGIC       = ${RDP_MAGIC}"
    printDBG $S_RDP ${D_BULK} $LINENO $BASH_SOURCE "RDP_VERSTRING   = ${RDP_VERSTRING}"
    printDBG $S_RDP ${D_BULK} $LINENO $BASH_SOURCE "RDP_PRODVERS    = ${RDP_PRODVERS}"
    printDBG $S_RDP ${D_BULK} $LINENO $BASH_SOURCE "RDP_STATE       = ${RDP_STATE}"
    printDBG $S_RDP ${D_BULK} $LINENO $BASH_SOURCE "RDP_PREREQ      = ${RDP_PREREQ}"
    printDBG $S_RDP ${D_BULK} $LINENO $BASH_SOURCE "RDPC            = ${RDPC}"
    printDBG $S_RDP ${D_BULK} $LINENO $BASH_SOURCE "RDPC_OPT        = ${RDPC_OPT}"
    return $_ret;
}







#FUNCBEG###############################################################
#NAME:
#  noClientServerSplitSupportedMessageRDP
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
#  VALUES:
#
#FUNCEND###############################################################
function noClientServerSplitSupportedMessageRDP () {
    ABORT=2
    printERR $LINENO $BASH_SOURCE ${ABORT} "Unexpected ERROR!!!"
    printERR $LINENO $BASH_SOURCE ${ABORT} "RDP perfectly supports ClientServerSplit!!!"
    printERR $LINENO $BASH_SOURCE ${ABORT} "Check for process ownership, probably just missing permissions."
    printERR $LINENO $BASH_SOURCE ${ABORT} "On grave slow machines just a timeout may have occured."
    printERR $LINENO $BASH_SOURCE ${ABORT} "Try a following connect, if so adapt TIMEOUT value, but for this target only."
}



#FUNCBEG###############################################################
#NAME:
#  clientServerSplitSupportedRDP
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Checks whether the split of client and server is supported.
#  This is just a hardcoded attribute.
#
#EXAMPLE:
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#    0: If supported
#    1: else
#
#  VALUES:
#
#FUNCEND###############################################################
function clientServerSplitSupportedRDP () {
    printDBG $S_RDP ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME $1"
    case $1 in
	CREATE)return 0;;
	CANCEL)return 0;;
    esac
    return 1;
}



#FUNCBEG###############################################################
#NAME:
#  enumerateMySessionsRDP
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Not supported.
#
#EXAMPLE:
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function enumerateMySessionsRDP () {
    printDBG $S_RDP ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=${@}"
}


#
#Managed load of sub-packages gwhich are required in almost any case.
#On-demand-loads will be performed within requesting action.
#
hookPackage "${_myPKGBASE_RDP}/session.sh"
hookPackage "${_myPKGBASE_RDP}/list.sh"
hookPackage "${_myPKGBASE_RDP}/info.sh"

if [ -d "${HOME}/.ctys" -a -d "${HOME}/.ctys/rdp" ];then
    #Source pre-set environment from user
    if [ -f "${HOME}/.ctys/rdp/rdp.conf-${MYOS}.sh" ];then
	. "${HOME}/.ctys/rdp/rdp.conf-${MYOS}.sh"
    fi

    #Source pre-set environment from installation 
    if [ -f "${MYCONFPATH}/rdp/rdp/rdp.conf" ];then
	. "${MYCONFPATH}/conf/rdp/rdp.conf-${MYOS}.sh"
    fi
fi



#FUNCBEG###############################################################
#NAME:
#  handleRDP
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: <OPMODE>
#  $2: <ACTION>
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function handleRDP () {
  printDBG $S_RDP ${D_BULK} $LINENO $BASH_SOURCE "${FUNCNAME}:$*"
  local OPMODE=$1;shift
  local ACTION=$1;shift

  case ${ACTION} in

      CREATE) 
	  case ${OPMODE} in
              PROLOGUE)
		  ;;
              EPILOGUE)
		  ;;
	      CHECKPARAM|ASSEMBLE|EXECUTE)
		  hookPackage "${_myPKGBASE_RDP}/create.sh"
		  createConnectRDP ${OPMODE} ${ACTION} 
		  ;;
	  esac
          ;;

      CANCEL)
	  case ${OPMODE} in
              PROLOGUE)
		  ;;
              EPILOGUE)
		  ;;
	      CHECKPARAM|ASSEMBLE|EXECUTE)
		  hookPackage "${_myPKGBASE_RDP}/cancel.sh"
		  cutCancelSessionRDP ${OPMODE} ${ACTION} 
		  ;;
	  esac
          ;;


      GETCLIENTPORT)
	  case ${OPMODE} in
              PROLOGUE)
		  ;;
              EPILOGUE)
		  ;;
              CHECKPARAM)
		  if [ -n "$C_MODE_ARGS" ];then
                      printDBG $S_RDP ${D_BULK} $LINENO $BASH_SOURCE "C_MODE_ARGS=$C_MODE_ARGS"
                      _C_GETCLIENTPORT=$C_MODE_ARGS
		  else
		      ABORT=1
		      printERR $LINENO $BASH_SOURCE ${ABORT} "Missing <session-label>|<session-id>"
		      gotoHell ${ABORT}
		  fi

                  ;;
	      EXECUTE)
		  printDBG $S_RDP ${D_BULK} $LINENO $BASH_SOURCE "Remote command:C_MODE_ARGS=${C_MODE_ARGS}"
		  printDBG $S_RDP ${D_BULK} $LINENO $BASH_SOURCE "CLIENTPORT(RDP,${MYHOST},${_C_GETCLIENTPORT})=`getClientTPRDP ${_C_GETCLIENTPORT}`"
  		  echo "CLIENTPORT(RDP,${MYHOST},${_C_GETCLIENTPORT})=`getClientTPRDP ${_C_GETCLIENTPORT}`"
		  gotoHell 0
		  ;;
 	      ASSEMBLE)
   		  ;;
          esac
	  ;;

      *)
          #SUSPEND|RESUME|RESET
          ABORT=1;
          printERR $LINENO $BASH_SOURCE ${ABORT} "System Error, unsupported ACTION for RDP:ACTION=${ACTION} OPMODE=${OPMODE}"
          ;;
  esac

}


#FUNCBEG###############################################################
#NAME:
#  initRDP
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
#
#  VALUES:
#
#FUNCEND###############################################################
function initRDP () {
  local _curInit=$1;shift
  local _initConsequences=$1
  local ret=0;


  local _raise=$((INITSTATE<_curInit));

  printDBG $S_RDP ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:${INITSTATE} -> ${_curInit} - ${_raise}"

  if [ "$_raise" == "1" ];then
      #for raise of INITSTATE do not touch the OS's decisions, just expand.

      case $_curInit in
	  0);;#NOP - Done by shell
	  1)  #add own help to searchlist for options
	      MYOPTSFILES="${MYOPTSFILES} ${MYHELPPATH}/010_rdp"
              setVersionRDP $_initConsequences

              ret=$?
	      ;;
	  2);;
	  3);;
	  4);;
	  5);;
	  6);;
      esac
  else
      case $_curInit in
	  *);;
      esac

  fi

  return $ret
}
