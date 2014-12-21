#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_02_007a17
#
########################################################################
#
# Copyright (C) 2007 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

CLI_MAGIC=CLI_GENERIC;
CLI_VERSTRING=;
CLI_STATE=DISABLED;
CLISERVER_OPT=;
CLIVIEWER_OPT=;
CLI_PREREQ="bash";
CLI_PRODVERS=;



_myPKGNAME_CLI="${BASH_SOURCE}"
_myPKGVERS_CLI="01.06.001a09"
hookInfoAdd $_myPKGNAME_CLI $_myPKGVERS_CLI
_myPKGBASE_CLI="${_myPKGNAME_CLI%/hook.sh}"


CLI_VERSTRING=${_myPKGVERS_CLI};
CLI_PREREQ="HOST-CAPABILITY:CLI-${CLI_VERSTRING}-${MYARCH}";

if [ -d "${HOME}/.ctys" -a -d "${HOME}/.ctys/cli" ];then
    if [ -f "${HOME}/.ctys/cli/cli.conf-${MYOS}.sh" ];then
	. "${HOME}/.ctys/cli/cli.conf-${MYOS}.sh"
    fi
fi

if [ -d "${MYCONFPATH}" -a -d "${MYCONFPATH}/cli" ];then
    if [ -f "${MYCONFPATH}/cli/cli.conf-${MYOS}.sh" ];then
	. "${MYCONFPATH}/cli/cli.conf-${MYOS}.sh"
    fi
fi


#FUNCBEG###############################################################
#NAME:
#  serverRequireCLI
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
function serverRequireCLI () {
    printDBG $S_CLI ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME \$@=$@"
    local _CS_SPLIT=`echo ${*}|sed -n 's/CONNECTIONFORWARDING/SERVERONLY/p'`;
    local _S=`getSessionType ${*}`;_S=${_S:-$C_SESSIONTYPE};
    local _A=`getActionResulting ${*}`;
    local _ret=1;
    local _res=;

    printDBG $S_CLI ${D_MAINT} $LINENO $BASH_SOURCE "_CS_SPLIT=\"${_CS_SPLIT}\""
    printDBG $S_CLI ${D_MAINT} $LINENO $BASH_SOURCE "_S=\"${_S}\""
    printDBG $S_CLI ${D_MAINT} $LINENO $BASH_SOURCE "_A=\"${_A}\""


    #if split not supported server only could be used
    if [ -n "${_CS_SPLIT}" ];then
	ABORT=1;
	printERR $LINENO $BASH_SOURCE ${ABORT} "The console type CLI doe not support ConnectionForwariding"
	gotoHell ${ABORT}
    else
 	_res="${*}";_ret=0;
    fi

    printDBG $S_CLI ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_res=\"${_res}\""
    printDBG $S_CLI ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_ret=\"${_ret}\""
    echo -n "${_res}";
    return ${_ret};  
}



#FUNCBEG###############################################################
#NAME:
#  clientRequireCLI
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
function clientRequireCLI () {
    printDBG $S_CLI ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME \$@=$@"
    local _CS_SPLIT=`echo ${*}|sed -n 's/CONNECTIONFORWARDING/1/p'`;
    local _S=`getSessionType ${*}`;_S=${_S:-$C_SESSIONTYPE};
    local _A=`getActionResulting ${*}`;
    local _ret=1;
    local _res=;

    printDBG $S_CLI ${D_MAINT} $LINENO $BASH_SOURCE "_CS_SPLIT=\"${_CS_SPLIT}\""
    printDBG $S_CLI ${D_MAINT} $LINENO $BASH_SOURCE "_S=\"${_S}\""
    printDBG $S_CLI ${D_MAINT} $LINENO $BASH_SOURCE "_A=\"${_A}\""

    #if split not supported server only could be used
    if [ -n "${_CS_SPLIT}" ];then
	ABORT=1;
	printERR $LINENO $BASH_SOURCE ${ABORT} "The console type CLI doe not support CONNECTIONFORWARDING"
	gotoHell ${ABORT}
    else
 	_res=;_ret=1;
    fi

    printDBG $S_CLI ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_res=\"${_res}\""
    printDBG $S_CLI ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_ret=\"${_ret}\""
    echo -n "${_res}";
    return ${_ret};  
}


#FUNCBEG###############################################################
#NAME:
#  setVersionCLI
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Sets defaults and MAGIC-ID for local cli version.
#
#EXAMPLE:
#
#PARAMETERS:
#
#
#OUTPUT:
#  GLOBALS:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function setVersionCLI () {
    local _checkonly=;
    local _ret=0;
    if [ "$1" == "NOEXIT" ];then
	local _checkonly=1;        
    fi

    local _verstrg=;
    if [ -z "${CLIEXE}" ];then
	ABORT=2
	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing executable for bash"
	printERR $LINENO $BASH_SOURCE ${ABORT} "can not find:"
	printERR $LINENO $BASH_SOURCE ${ABORT} " -> bash"
	printERR $LINENO $BASH_SOURCE ${ABORT} ""
	printERR $LINENO $BASH_SOURCE ${ABORT} "Check your PATH"
	printERR $LINENO $BASH_SOURCE ${ABORT} " -> PATH=${PATH}"
	printERR $LINENO $BASH_SOURCE ${ABORT} ""
	if [ "${C_SESSIONTYPE}" == "CLI" -a -z "${_checkonly}" ];then
	    gotoHell ${ABORT}
	else
	    return ${ABORT}
	fi
    fi

    _verstrg=`${CLIEXE} --version 2>&1|awk '/(GNU bash)/{gsub("-.*","",$4);printf("%s\n",$4);}'`;
    _verstrg="bash-${_verstrg}-${MYARCH}";
    ${CLIEXE} --version >/dev/null 2>/dev/null 
    if [ -n "$_verstrg" -a $? -eq 0 ];then
	printDBG $S_LIB ${D_SYS} $LINENO "$BASH_SOURCE" "$FUNCNAME:`setSeverityColor TRY \"call(${CLIEXE} --version)\"` => [ `setSeverityColor INF OK` ]"
	_ret=0;
    else
	printWNG 1 $LINENO $BASH_SOURCE 0  "Missing: CLI=${CLIEXE}"
  	_verstrg=GENERIC
	CLI_PREREQ="${CLI_PREREQ} <disabled:CLI:bash>";
	printDBG $S_LIB ${D_SYS} $LINENO "$BASH_SOURCE" "$FUNCNAME:`setSeverityColor TRY \"call(${CLIEXE} --version)\"` => [ `setSeverityColor ERR NOK` ]"
	_ret=1;
    fi

    printDBG $S_CLI ${D_BULK} $LINENO $BASH_SOURCE "CLI"
    printDBG $S_CLI ${D_BULK} $LINENO $BASH_SOURCE "  _verstrg=${_verstrg}"

    #currently somewhat restrictive to specific versions.
    case ${_verstrg} in
	"bash-"[34]*)
	    CLI_MAGIC=CLIBASH;
	    CLI_STATE=ENABLED;
	    CLI_PREREQ="${CLI_PREREQ}%${_verstrg}";
	    CLISERVER_OPT=;
	    CLIVIEWER_OPT=;
	    _ret=0;
	    ;;


        *)
	    CLI_MAGIC=CLIG;
	    CLISERVER_OPT=;
	    CLIVIEWER_OPT=;
	    _ret=1;
	    ;;
    esac
    CLI_PRODVERS="${_verstrg}"
    CLI_PRODVERS="${CLI_PRODVERS// /}"
    CLI_PRODVERS="${CLI_PRODVERS//,/}"
    CLI_PRODVERS="${CLI_PRODVERS//;/}"

    printDBG $S_CLI ${D_MAINT} $LINENO $BASH_SOURCE "CLI_MAGIC       = ${CLI_MAGIC}"
    printDBG $S_CLI ${D_MAINT} $LINENO $BASH_SOURCE "CLI_VERSTRING   = ${CLI_VERSTRING}"
    printDBG $S_CLI ${D_MAINT} $LINENO $BASH_SOURCE "CLI_PRODVERS    = ${CLI_PRODVERS}"
    printDBG $S_CLI ${D_MAINT} $LINENO $BASH_SOURCE "CLI_STATE       = ${CLI_STATE}"
    printDBG $S_CLI ${D_MAINT} $LINENO $BASH_SOURCE "CLI_PREREQ      = ${CLI_PREREQ}"
    printDBG $S_CLI ${D_MAINT} $LINENO $BASH_SOURCE "CLISERVER_OPT   = ${CLISERVER_OPT}"
    printDBG $S_CLI ${D_MAINT} $LINENO $BASH_SOURCE "CLIVIEWER_OPT   = ${CLIVIEWER_OPT}"
    return $_ret
}





#FUNCBEG###############################################################
#NAME:
#  noClientServerSplitSupportedMessageCLI
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
function noClientServerSplitSupportedMessageCLI () {
    printERR $LINENO $_VMW_SESSION ${ABORT} "Unexpected ERROR!!!"
    printERR $LINENO $_VMW_SESSION ${ABORT} "CLI perfectly supports ClientServerSplit!!!"
}



#FUNCBEG###############################################################
#NAME:
#  clientServerSplitSupportedCLI
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
function clientServerSplitSupportedCLI () {
    printDBG $S_CLI ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME $1"
    case $1 in
	CREATE)return 0;;
#	CONNECT)return 0;;
#	CANCEL)return 0;;
#	SUSPEND)return 0;;
#	RESUME)return 0;;
#	SHIFT)return 0;;
    esac
    return 1;
}

#FUNCBEG###############################################################
#NAME:
#  enumerateMySessionsCLI
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
function enumerateMySessionsCLI () {
    printDBG $S_CLI ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=${@}"
}




#
#Managed load of sub-packages gwhich are required in almost any case.
#On-demand-loads will be performed within requesting action.
#
hookPackage "${_myPKGBASE_CLI}/session.sh"
hookPackage "${_myPKGBASE_CLI}/list.sh"
hookPackage "${_myPKGBASE_CLI}/info.sh"



#FUNCBEG###############################################################
#NAME:
#  handleCLI
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
function handleCLI () {
  printDBG $S_CLI ${D_BULK} $LINENO $BASH_SOURCE "${FUNCNAME}:$*"
  local OPMODE=$1;shift
  local ACTION=$1;shift

  case ${ACTION} in

      CREATE) 
          hookPackage "${_myPKGBASE_CLI}/create.sh"
	  case ${OPMODE} in
              PROLOGUE)
		  ;;
              EPILOGUE)
		  ;;
	      CHECKPARAM|ASSEMBLE|EXECUTE)
		  createConnectCLI ${OPMODE} ${ACTION} 
		  ;;
	  esac
          ;;

      *)
          #unknown
          ABORT=1;
          printERR $LINENO $BASH_SOURCE ${ABORT} "System Error, unsupported ACTION for CLI:ACTION=${ACTION} OPMODE=${OPMODE}"
          ;;
  esac
}


#FUNCBEG###############################################################
#NAME:
#  initCLI
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
function initCLI () {
  local _curInit=$1;shift
  local _initConsequences=$1
  local ret=0;

  local _raise=$((INITSTATE<_curInit));

  printDBG $S_CLI ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:${INITSTATE} -> ${_curInit} - ${_raise}"

  if [ "$_raise" == "1" ];then
      #for raise of INITSTATE do not touch the OS's decisions, just expand.
      case $_curInit in
	  0);;#NOP - Done by shell
	  1)  #add own help to searchlist for options
	      MYOPTSFILES="${MYOPTSFILES} ${MYHELPPATH}/010_cli"
              setVersionCLI ${_initConsequences}
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
