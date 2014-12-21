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

X11_MAGIC=X11_GENERIC;
X11_VERSTRING=;
X11_STATE=DISABLED;
X11SERVER_OPT=;
X11VIEWER_OPT=;
X11_PREREQ=;
X11_PRODVERS=;



_myPKGNAME_X11="${BASH_SOURCE}"
_myPKGVERS_X11="01.06.001a09"
hookInfoAdd $_myPKGNAME_X11 $_myPKGVERS_X11
_myPKGBASE_X11="${_myPKGNAME_X11%/hook.sh}"

X11_VERSTRING=${_myPKGVERS_X11};


C_X11_DEFAULT="${C_X11_DEFAULT:-bash -l -i}"

if [ -d "${HOME}/.ctys" -a -d "${HOME}/.ctys/x11" ];then
    #Source pre-set environment from user
    if [ -f "${HOME}/.ctys/x11/x11.conf-${MYOS}.sh" ];then
	. "${HOME}/.ctys/x11/x11.conf-${MYOS}.sh"
    fi
fi

if [ -d "${MYCONFPATH}" -a -d "${MYCONFPATH}/x11" ];then
    #Source pre-set environment from installation 
    if [ -f "${MYCONFPATH}/x11/x11.conf-${MYOS}.sh" ];then
	. "${MYCONFPATH}/x11/x11.conf-${MYOS}.sh"
    fi
fi




#FUNCBEG###############################################################
#NAME:
#  serverRequireX11
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
function serverRequireX11 () {
    printDBG $S_X11 ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME \$@=$@"
    local _CS_SPLIT=`echo ${*}|sed -n 's/CONNECTIONFORWARDING/SERVERONLY/p'`;
    local _S=`getSessionType ${*}`;_S=${_S:-$C_SESSIONTYPE};
    local _A=`getActionResulting ${*}`;
    local _ret=1;
    local _res=;

    printDBG $S_X11 ${D_BULK} $LINENO $BASH_SOURCE "_CS_SPLIT=\"${_CS_SPLIT}\""
    printDBG $S_X11 ${D_BULK} $LINENO $BASH_SOURCE "_S=\"${_S}\""
    printDBG $S_X11 ${D_BULK} $LINENO $BASH_SOURCE "_A=\"${_A}\""


    #if split not supported server only could be used
    if [ -n "${_CS_SPLIT}" ];then
	ABORT=1;
	printERR $LINENO $BASH_SOURCE ${ABORT} "The console type X11 doe not support ConnectionForwariding"
	gotoHell ${ABORT}
    else
 	_res="${*}";_ret=0;
    fi

    printDBG $S_X11 ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_res=\"${_res}\""
    printDBG $S_X11 ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_ret=\"${_ret}\""
    echo -n "${_res}";
    return ${_ret};  
}



#FUNCBEG###############################################################
#NAME:
#  clientRequireX11
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
function clientRequireX11 () {
    printDBG $S_X11 ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME \$@=$@"
    local _CS_SPLIT=`echo ${*}|sed -n 's/CONNECTIONFORWARDING/1/p'`;
    local _S=`getSessionType ${*}`;_S=${_S:-$C_SESSIONTYPE};
    local _A=`getActionResulting ${*}`;
    local _ret=1;
    local _res=;

    printDBG $S_X11 ${D_BULK} $LINENO $BASH_SOURCE "_CS_SPLIT=\"${_CS_SPLIT}\""
    printDBG $S_X11 ${D_BULK} $LINENO $BASH_SOURCE "_S=\"${_S}\""
    printDBG $S_X11 ${D_BULK} $LINENO $BASH_SOURCE "_A=\"${_A}\""

    #if split not supported server only could be used
    if [ -n "${_CS_SPLIT}" ];then
	ABORT=1;
	printERR $LINENO $BASH_SOURCE ${ABORT} "The console type X11 doe not support CONNECTIONFORWARDING"
	gotoHell ${ABORT}
    else
 	_res=;_ret=1;
    fi

    printDBG $S_X11 ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_res=\"${_res}\""
    printDBG $S_X11 ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_ret=\"${_ret}\""
    echo -n "${_res}";
    return ${_ret};  
}





#FUNCBEG###############################################################
#NAME:
#  setVersionX11
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
function setVersionX11 () {
    local _checkonly=;
    local _ret=0;
    if [ "$1" == "NOEXIT" ];then
	local _checkonly=1;        
    fi

    local _verstrg=;
    if [ -z "$X11EXE" ];then
	ABORT=2
	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing X for X11"
	printERR $LINENO $BASH_SOURCE ${ABORT} "can not find:"
	printERR $LINENO $BASH_SOURCE ${ABORT} " -> X"
	printERR $LINENO $BASH_SOURCE ${ABORT} ""
	printERR $LINENO $BASH_SOURCE ${ABORT} "Check your PATH"
	printERR $LINENO $BASH_SOURCE ${ABORT} " -> PATH=${PATH}"
	printERR $LINENO $BASH_SOURCE ${ABORT} ""
	if [ "${C_SESSIONTYPE}" == "X11" -a -z "${_checkonly}" ];then
	    gotoHell ${ABORT}
	else
	    return ${ABORT}
	fi
	_ret=${ABORT};
    fi



    _verstrg=`${X11EXE} -version 2>&1|awk '/(X Protocol Version)/{x="X"$4"R"$6"-"$8;gsub(",","",x);printf("%s",x);}'`
    if [ -z "${_verstrg}" ];then
	printDBG $S_LIB ${D_SYS} $LINENO "$BASH_SOURCE" "$FUNCNAME:`setSeverityColor TRY \"call(${X11EXE} -version)\"` => [ `setSeverityColor ERR NOK` ]"
	case ${MYOS} in
	    SunOS)
		case ${MYREL} in
		    5.10)#asume for now on supported Solaris-5.10
			_verstrg="X11R6";
			printINFO 1 $LINENO $BASH_SOURCE 0  "Missing X-Version, guess for ${MYOS}/${MYREL}=>${_verstrg}"
			;;
		    5.1[0-9]*)#asume for now on 
			_verstrg="X11R6x";
			printINFO 1 $LINENO $BASH_SOURCE 0  "Missing X-Version, guess for ${MYOS}/${MYREL}=>${_verstrg}"
			;;
		    *)
			printWNG 1 $LINENO $BASH_SOURCE 0  "Missing X-Version, guess for ${MYOS}/${MYREL}=>${_verstrg}"
			_verstrg="X11Rx";
			;;
		esac
		;;
	    *)#hope
		printWNG 1 $LINENO $BASH_SOURCE 0  "Missing X-Version, assume GENERIC"
  		_verstrg=GENERIC
		_ret=2;
		;;
	esac

    else
	printDBG $S_LIB ${D_SYS} $LINENO "$BASH_SOURCE" "$FUNCNAME:`setSeverityColor TRY \"call(${X11EXE} -version)\"` => [ `setSeverityColor INF OK` ]"
	_ret=0;
    fi

    printDBG $S_X11 ${D_BULK} $LINENO $BASH_SOURCE "X11"
    printDBG $S_X11 ${D_BULK} $LINENO $BASH_SOURCE "  _verstrg=${_verstrg}"

    if [ -n "$X11EXE" ];then
	X11_PREREQ="${X11_PREREQ} X11:X";
	_ret=0;
    else
	X11_PREREQ="${X11_PREREQ} <disabled:X:X11>";
	_ret=2;
    fi


    if [ -n "$X11XTERMEXE" ];then
	local _xtermver=`callErrOutWrapper $LINENO $BASH_SOURCE ${X11XTERMEXE} -version `
	if [ -n "$_xtermver" ];then
	    X11_PREREQ="${X11_PREREQ} xterm-${_xtermver}";
	    _ret=0;
	else
	    X11_PREREQ="${X11_PREREQ} <disabled:xterm>";
	    _ret=2;
	fi
    fi

    if [ -n "$X11MWMEXE" ];then
	local _gdmver=`${X11MWMEXE} --help 2>&1|grep Another`
	if [ -n "$_gdmver" ];then
	    X11_PREREQ="${X11_PREREQ} Motif:mwm";
	    printDBG $S_LIB ${D_SYS} $LINENO "$BASH_SOURCE" "$FUNCNAME:`setSeverityColor TRY \"call(${X11MWMEXE} --help)\"` => [ `setSeverityColor INF OK` ]"
	    _ret=0;
	else
	    X11_PREREQ="${X11_PREREQ} <disabled:Motif:mwm>";
	    printDBG $S_LIB ${D_SYS} $LINENO "$BASH_SOURCE" "$FUNCNAME:`setSeverityColor TRY \"call(${X11MWMEXE} --help)\"` => [ `setSeverityColor ERR NOK` ]"
	    _ret=2;
	fi
    fi

    if [ -n "$X11GDMEXE" ];then
	local _gdmver=`callErrOutWrapper $LINENO $BASH_SOURCE ${X11GDMEXE} --version|awk '/GDM/{printf("gdm-%s",$2);}' `
	if [ -n "$_gdmver" ];then
	    X11_PREREQ="${X11_PREREQ} GNOME:${_gdmver// /_}:gdm";
	    _ret=0;
	else
	    X11_PREREQ="${X11_PREREQ} <disabled:GNOME:gdm>";
	    _ret=2;
	fi
    fi

    if [ -n "$X11GTERMEXE" ];then
	local _gtermver=`callErrOutWrapper $LINENO $BASH_SOURCE ${X11GTERMEXE} --version|awk '/terminal/{printf("%s",$3);}' `
	if [ -n "$_gtermver" ];then
	    X11_PREREQ="${X11_PREREQ} GNOME:gnome-terminal${_gtermver}";
	    _ret=0;
	else
	    X11_PREREQ="${X11_PREREQ} <disabled:GNOME:gnome-terminal>";
	    _ret=2;
	fi
    fi

    if [ -n "$X11KDMEXE" ];then
	local _kdmexe=`callErrOutWrapper $LINENO $BASH_SOURCE ${X11KDMEXE} --help `
	if [ -n "$_kdmexe" ];then
	    X11_PREREQ="${X11_PREREQ} KDE:kdm";
	    _ret=0;
	else
	    X11_PREREQ="${X11_PREREQ} <disabled:KDE:kdm>";
	    _ret=2;
	fi
    fi

    if [ -n "$X11FVWMEXE" ];then
        local _fvwmver=`${X11FVWMEXE} --version 2>&1 |awk '/[^-][vV]ersion/{printf("%s",$3);}'`
	if [ -n "$_fvwmver" ];then
	    X11_PREREQ="${X11_PREREQ} FVWM:fvwm-${_fvwmver// /_}:fvwm";
	    printDBG $S_LIB ${D_SYS} $LINENO "$BASH_SOURCE" "$FUNCNAME:`setSeverityColor TRY \"call(${X11FVWMEXE} -version)\"` => [ `setSeverityColor INF OK` ]"
	    _ret=0;
	else
	    X11_PREREQ="${X11_PREREQ} <disabled:FVWM:fvwm>";
	    printDBG $S_LIB ${D_SYS} $LINENO "$BASH_SOURCE" "$FUNCNAME:`setSeverityColor TRY \"call(${X11FVWMEXE} --version)\"` => [ `setSeverityColor ERR NOK` ]"
	    _ret=2;
	fi
    fi

    if [ -n "$X11XFCE4EXE" ];then
#	local _xfcever=`xfce4-session --version|awk '/xfce4-session 4/{printf("%s-%s",$1,$2);}'`
	local _xfcever=`callErrOutWrapper $LINENO $BASH_SOURCE ${X11XFCE4SESEXE} --version|awk '/xfce4-session 4/{printf("%s-%s",$1,$2);}' `
	if [ -n "$_xfcever" ];then
	    X11_PREREQ="${X11_PREREQ} XFCE:${_xfcever// /_}:startxfce4+xfce4-session";
	else
	    X11_PREREQ="${X11_PREREQ} XFCE:${_xfcever// /_}:startxfce+xfce-session";
	fi
	_ret=0;
    else
	X11_PREREQ="${X11_PREREQ} <disabled:Xfce4:startxfce4>";
	_ret=2;
    fi

    #currently somewhat restrictive to specific versions.
    case ${_verstrg} in
	"X11R"*)
	    X11_MAGIC=X11;
	    X11_STATE=ENABLED;
	    X11SERVER_OPT=;
	    X11VIEWER_OPT=;
	    X11_PREREQ="HOST-CAPABILITY:X11-${X11_VERSTRING}-${MYARCH}%${_verstrg}-${MYARCH} ${X11_PREREQ}";
	    _ret=0;
	    ;;
        *)
	    X11_MAGIC=X11G;
	    X11SERVER_OPT=;
	    X11VIEWER_OPT=;
	    _ret=2;
	    ;;
    esac
    X11_PRODVERS="${_verstrg}"
    X11_PRODVERS="${X11_PRODVERS// /}"
    X11_PRODVERS="${X11_PRODVERS//,/}"
    X11_PRODVERS="${X11_PRODVERS//;/}"

    printDBG $S_X11 ${D_BULK} $LINENO $BASH_SOURCE "X11_MAGIC       = ${X11_MAGIC}"
    printDBG $S_X11 ${D_BULK} $LINENO $BASH_SOURCE "X11_VERSTRING   = ${X11_VERSTRING}"
    printDBG $S_X11 ${D_BULK} $LINENO $BASH_SOURCE "X11_PRODVERS    = ${X11_PRODVERS}"
    printDBG $S_X11 ${D_BULK} $LINENO $BASH_SOURCE "X11_STATE       = ${X11_STATE}"
    printDBG $S_X11 ${D_BULK} $LINENO $BASH_SOURCE "X11_PREREQ      = ${X11_PREREQ}"
    printDBG $S_X11 ${D_BULK} $LINENO $BASH_SOURCE "X11SERVER_OPT   = ${X11SERVER_OPT}"
    printDBG $S_X11 ${D_BULK} $LINENO $BASH_SOURCE "X11VIEWER_OPT   = ${X11VIEWER_OPT}"
    return $_ret
}





#FUNCBEG###############################################################
#NAME:
#  noClientServerSplitSupportedMessageX11
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
function noClientServerSplitSupportedMessageX11 () {
    printERR $LINENO $_VMW_SESSION ${ABORT} "Unexpected ERROR!!!"
    printERR $LINENO $_VMW_SESSION ${ABORT} "X11 perfectly supports ClientServerSplit!!!"
}



#FUNCBEG###############################################################
#NAME:
#  clientServerSplitSupportedX11
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
function clientServerSplitSupportedX11 () {
    printDBG $S_X11 ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME $1"
    case $1 in
	CREATE)return 0;;
    esac
    return 1;
}

#FUNCBEG###############################################################
#NAME:
#  enumerateMySessionsX11
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
function enumerateMySessionsX11 () {
    printDBG $S_X11 ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=${@}"
}




#
#Managed load of sub-packages gwhich are required in almost any case.
#On-demand-loads will be performed within requesting action.
#
hookPackage "${_myPKGBASE_X11}/session.sh"
hookPackage "${_myPKGBASE_X11}/list.sh"
hookPackage "${_myPKGBASE_X11}/info.sh"



#FUNCBEG###############################################################
#NAME:
#  handleX11
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
function handleX11 () {
  printDBG $S_X11 ${D_BULK} $LINENO $BASH_SOURCE "${FUNCNAME}:$*"
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
		  hookPackage "${_myPKGBASE_X11}/create.sh"
		  createConnectX11 ${OPMODE} ${ACTION} 
		  ;;
	  esac
          ;;

      *)
          #unknown
          ABORT=1;
          printERR $LINENO $BASH_SOURCE ${ABORT} "System Error, unsupported ACTION for X11:ACTION=${ACTION} OPMODE=${OPMODE}"
          ;;
  esac

}


#FUNCBEG###############################################################
#NAME:
#  initX11
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
function initX11 () {
  local _curInit=$1;shift
  local _initConsequences=$1
  local ret=0;

  local _raise=$((INITSTATE<_curInit));

  printDBG $S_X11 ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:${INITSTATE} -> ${_curInit} - ${_raise}"

  if [ "$_raise" == "1" ];then
      #for raise of INITSTATE do not touch the OS's decisions, just expand.

      case $_curInit in
	  0);;#NOP - Done by shell
	  1)  #add own help to searchlist for options
	      MYOPTSFILES="${MYOPTSFILES} ${MYHELPPATH}/010_x11"
              setVersionX11 $_initConsequences
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
