#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_10_008
#
########################################################################
#
# Copyright (C) 2007,2008,2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

_myPKGNAME_QEMU_SESSION="${BASH_SOURCE}"
_myPKGVERS_QEMU_SESSION="01.10.008"
hookInfoAdd $_myPKGNAME_QEMU_SESSION $_myPKGVERS_QEMU_SESSION
_myPKGBASE_QEMU_SESSION="`dirname ${_myPKGNAME_QEMU_SESSION}`"





#FUNCBEG###############################################################
#NAME:
#  getServerAccessPortQEMU
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Returns the actual dynamic extended QEMUMONSOCK.
#  In current version this is the Server-ASCII-Console too,
#  gwhich is used as the client-access-port for the CLI based 
#  console types.
#
#EXAMPLE:
#
#PARAMETERS:
# $1: label
#OUTPUT:
#  RETURN:
#  VALUES:
#    QEMUMONSOCK
#
#FUNCEND###############################################################
function getServerAccessPortQEMU () {
    printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=<$@>"
    local _port=;

    _port=`listMySessionsQEMU S MACHINE|awk -F';' -v l="${1}" '$2~l{print $8;}'`
    if [ -n "${_port}" ];then
	local _ret=$_port;  
	printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:Label(${1})ServerAccessPort=<${_ret}>"
    fi
    echo ${_ret}
}


#FUNCBEG###############################################################
#NAME:
#  expandSessionIDQEMU
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
function expandSessionIDQEMU () {
  echo $1
}






#FUNCBEG###############################################################
#NAME:
#  startSessionQEMU
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
# $1: label
#     For legacy reasons of inherited code, in case of Xen, Xen itself
#     requires UNIQUE(scope=node+) DomainName=LABEL to be preconfigured
#     in config file(pname), so must not differ!!!
#
# $2: ID/pname
# $3: ConsoleType
# $4: BootMode
#     <mode>[%<path>]
# $5: GuestOS-TCP/IP-Address
#
# $6: Instmode
#     <mode>[%<path>]
# $7: KernelMode
#     <kernel>[%<initrd>[%<append>]]
# $8: AddArgs, seperated by common space-mask '%'
#
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function startSessionQEMU () {
  printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:\$@=$@"
  local _label=$1
  local _pname=${2/.sh/.ctys};
  local _console=${3:-$QEMU_DEFAULT_CONSOLE}
  local _console=${_console:-VNC}
  local _bootmode=${4}
  local _myVM=${5};
  local _instmode=${6}
  local _kernelmode=${7}
  local _argsadd=${8#* }
  local _argsapp=${8%% *}

  printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:LABEL    =<$_label>"
  printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:PNAME    =<$_pname>"
  printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:CONSOLE  =<$_console>"
  printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:BOOTMODE =<$_bootmode>"
  printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:GUEST-IP =<$_myVM>"
  printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:INSTMODE =<$_instmode>"
  printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:KERNEL   =<$_kernelmode>"
  printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:ARGAPP   =<$_argsapp>"
  printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:ARGSADD  =<$_argsadd>"
  printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "${FUNCNAME}:ARGSADD  =<$_argsadd>"

  #should not happen, anyhow, once again, check it
  if [ -z "${_label}" ];then
      ABORT=1
      printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Missing LABEL"
      gotoHell ${ABORT}
  fi

  #should not happen, anyhow, once again, check it
  if [ -z "${_pname}" ];then
      ABORT=1
      printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Missing PNAME"
      gotoHell ${ABORT}
  fi

  if [ "${C_STACK}" == 1 ];then
      printDBG $S_QEMU ${D_FLOW} $LINENO $BASH_SOURCE "C_STACK=${C_STACK}"
      if [ -z "${_myVM}" -a \( "$_pingQEMU" == 1 -o  "$_sshpingQEMU" == 1 \) ];then
	  ABORT=2;
	  printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Missing the TCP/IP address of VM:${_label}"
	  printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Cannot operate synchronous with GuestOS."
	  printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:So VMSTACK is in almost any case not operable."
	  gotoHell ${ABORT}
      fi
  fi

  case ${QEMU_MAGIC} in
      QEMU_091) #verified to work
	  ;;
      QEMU_090) #verified to work
	  ;;
      QEMU_09x)
	  printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:This version is not yet tested, but any version \"0.9.x\" might work."
	  printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:  QEMU_VERSTRING = ${QEMU_VERSTRING}"
	  printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:  QEMU_MAGIC     = ${QEMU_MAGIC}"
	  ;;
      QEMU_011) #verified to work
	  ;;
      QEMU_012) #verified to work
	  ;;
      *)
	  printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:This version is not yet tested."
	  printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:  QEMU_VERSTRING = ${QEMU_VERSTRING}"
	  printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:  QEMU_MAGIC     = ${QEMU_MAGIC}"
	  ;;
  esac


  #use these in wrapper config scripts: _pname
  export QEMUCALL
  export QEMU
  export QEMU_MAGIC


  VNCACCESSDISPLAY=`getFirstFreeVNCDisplay "${VNC_BASEPORT}"`;
  let VNCACCESSPORT=VNCACCESSDISPLAY-VNC_BASEPORT;
  #set appropriate call
  CALLER="${_pname/.ctys/.sh} ${C_DARGS} --console"
  case $_console in
      SDL)
 	  CALLER="${CALLER}=SDL "
	  ;;
      CLI0)
 	  CALLER="${CALLER}=CLI "
	  ;;
      XTERM|GTERM|EMACS|EMACSM|EMACSA|EMACSAM)
	  CALLER="${CALLER}=CLI "
	  ;;
      VNC)
	  CALLER="${CALLER}=VNC "
	  ;;
      NONE)
	  CALLER="${CALLER}=NONE "
	  ;;
      *)
	  CALLER="${CALLER}=${_console// /} "
	  ;;
  esac
  CALLER="${CALLER} --vncaccessdisplay=${VNCACCESSDISPLAY} "
  if [ -z "$_instmode" ];then
      CALLER="${CALLER} ${_bootmode:+--bootmode=$_bootmode} "
  else
      CALLER="${CALLER} ${_instmode:+--instmode=$_instmode} "
  fi
  CALLER="${CALLER} ${_kernelmode:+--kernelmode=$_kernelmode} "

  if [ -n "${_argsadd}" ];then
      case $_argsapp in
	  C|B)
	      ABORT=1
	      printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Only valid target for additional arguments is 'S':ADDARGS"
	      gotoHell ${ABORT}
	      ;;
	  S)
	      CALLER="${CALLER} ${_argsadd:+--argsadd=\"$_argsadd\"} "
	      ;;
	  *)
	      ABORT=1
	      printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Missing target for additional arguments:ADDARGS"
	      printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}: 'ARGSADD:(C|S|B)%<argsadd>'"
	      printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:  C:client-call"
	      printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:  S:server-call"
	      printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:  B:both"
	      printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Current version supports only: S"
	      gotoHell ${ABORT}
	      ;;
      esac
  fi
  CALLER="export C_ASYNC=${C_ASYNC}&&${CALLER} ";

  printDBG $S_QEMU ${D_FLOW} $LINENO $BASH_SOURCE "_console         = ${_console}"
  printDBG $S_QEMU ${D_FLOW} $LINENO $BASH_SOURCE "TERM             = ${TERM}"
  printDBG $S_QEMU ${D_FLOW} $LINENO $BASH_SOURCE "ENABLE           = ${CALLER}"
  printDBG $S_QEMU ${D_FLOW} $LINENO $BASH_SOURCE "C_ASYNC          = ${C_ASYNC}"
  printDBG $S_QEMU ${D_FLOW} $LINENO $BASH_SOURCE "C_CLIENTLOCATION = ${C_CLIENTLOCATION}"

  printINFO 2 $LINENO $BASH_SOURCE 0 "$LINENO $BASH_SOURCE $FUNCNAME:CALLER=\"${CALLER}\""

  if [ "${C_STACK}" == 1 ];then
      _pingQEMU=1;
      _sshpingQEMU=1;
  fi


  ###
   ####
    ####Start now.
   ####
  ###

  if [ -z "${C_NOEXEC}" ];then
      printFINALCALL 1  $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${CALLER} --check"
      export PATH=${QEMU_PATHLIST}:${PATH}&&eval ${CALLER} --check
      if [ $? -ne 0 ];then
	  ABORT=1
	  printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Check failed:"
	  printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:<${CALLER} --check>"
	  printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Check execution permissions first."

	  gotoHell ${ABORT}
      fi
      printFINALCALL 1  $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${CALLER}"
      export PATH=${QEMU_PATHLIST}:${PATH}&&eval ${CALLER} &sleep ${CTYS_PREDETACH_TIMEOUT:-10}>/dev/null&
      sleep ${QEMU_INIT_WAITS}

      local _pingok=0;
      local _sshpingok=0;

      if [ "$_pingQEMU" == 1 ];then
	  netWaitForPing "${_myVM}" "${_pingcntQEMU}" "${_pingsleepQEMU}"
	  _pingok=$?;
      fi

      if [ "$_pingok" == 0 -a "$_sshpingQEMU" == 1 ];then
	  netWaitForSSH "${_myVM}" "${_sshpingcntQEMU}" "${_sshpingsleepQEMU}" "${_actionuserQEMU}"
	  _sshpingok=$?;
      fi

      if [ "${C_STACK}" == 1 ];then
	  printDBG $S_QEMU ${D_FLOW} $LINENO $BASH_SOURCE "C_STACK=${C_STACK}"
	  if [ $_pingok != 0 ];then
	      ABORT=1
	      printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "Start timed out:netWaitForPing"
	      printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "  VM =${_myVM}"

	      printWNG 1 $LINENO $BASH_SOURCE 0 "${_VHOST}  <${_label}> <${MYHOST}>  <${_pname}>"
	      printWNG 1 $LINENO $BASH_SOURCE 0 "<${_myVM}> <${_pingcntQEMU}> <${_pingsleepQEMU}>"
	      gotoHell ${ABORT}
	  else
 	      printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:Accessable by ping:${_myVM}"
	  fi

	  netWaitForSSH "${_myVM}" "${_sshpingcntQEMU}" "${_sshpingsleepQEMU}" "${_actionuserQEMU}"
	  if [ $? != 0 ];then
	      printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "Start timed out:netWaitForSSH"
	      printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "  VM =${_myVM}"

	      printWNG 1 $LINENO $BASH_SOURCE 0 "${_VHOST}  <${_label}> <${MYHOST}>  <${_pname}>"
	      printWNG 1 $LINENO $BASH_SOURCE 0 "<${_myVM}> <${_sshpingcntQEMU}> <${_sshpingsleepQEMU}>"
	      gotoHell 0
	  else
 	      printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:Accessable by ssh:${_myVM}"
	  fi
      fi
      cacheStoreWorkerPIDData SERVER QEMU "${_pname}" "${_label}" 0 ""
  fi

  VNCACCESSDISPLAY=;
  VNCACCESSPORT=;

  #
  #just wait for the "inherent" prompt.
  #
  if [ "$_console" == "CLI0" -o  "$_console" == "SDL" -o  "$_console" == "NONE" ];then
      return
  fi

  #
  #no client is required, so it's headless
  if [ "${C_CLIENTLOCATION}" ==  "-L SERVERONLY" ];then
      return
  fi

  printDBG $S_QEMU ${D_FLOW} $LINENO $BASH_SOURCE "Attach CONSOLE:${CALLER}"
  case $_console in
      VNC)
	  local _myDisp=`fetchDisplay4Label CHILD ${_label}`
	  local xi=;
	  for((xi=0;xi<QEMU_RETRYVNCCLIENTCONNECT;xi++));do
	      if [ -z "${_myDisp}" ];then
		  sleep ${QEMU_RETRYVNCCLIENTTIMEOUT};
		  _myDisp=`fetchDisplay4Label CHILD  ${_label}`
	      fi
	  done
	  if [ -z "$_myDisp" ];then
	      ABORT=1
	      printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Cannot evaluate server display for VNC."
	      gotoHell ${ABORT}
	  fi
	  connectSessionQEMU $_console  "$_label" "$_pname" "$_myDisp"
	  ;;
      CLI|XTERM|GTERM|EMACS|EMACSM|EMACSA|EMACSAM)
	  connectSessionQEMU $_console "$_label" "$_pname" 
	  ;;
      NONE)
	  ;;
      *)
	  ABORT=1
	  printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Unexpected CONSOLE:${_console}"
	  gotoHell ${ABORT}
	  ;;
  esac


  if [ "${C_ASYNC}" == 0 ];then
      wait
  fi
}



#FUNCBEG###############################################################
#NAME:
#  connectSessionQEMU
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  This function is the plugins local connection wrapper.
#  The basic decisions from where the connection is established and 
#  to gwhich peer it has to be connected is done before calling this.
#  But some knowledge of the connection itself is still required here.
#
#  So "the wrapper is in close relation to the controller", it is his  
#  masters not so stupid paladin.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: <console-type> could be
#      CLI|GTERM|XTERM|EMACS|VNC
#
#  $2: <session-label>
#      This will be used for the title of the client window.
#
#  $3: <session-id>
#      This is the absolute pathname to the vmx-file.
#
#  $4: <actual-access-id>
#      This will be used for actual connection, when direct acces to
#      an ip port is provided. 
#
#
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function connectSessionQEMU () {
  printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME \@=\"${@}\""
  local _contype=${1:-$QEMU_DEFAULT_CONSOLE}
  local _contype=${_contype:-VNC}
  local _label=${2}
  local _id=${3}
  local _actaccessID=${4}

  printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME \"${_contype}\⅛ \"${_label}\" \"${_id}\" \"${_actaccessID}\⅛"

  if [ -z "${_id}" -a -z "${_label}" ];then
      ABORT=1
      printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:At least one parameter required:<session-id> or <session-label>"
      gotoHell ${ABORT}
  fi

  local _args1=;
  _args1="${_args1} ${C_DARGS} "
  _args1="${_args1} ${C_ASYNC:+ -b $C_ASYNC} "
  _args1="${_args1} ${C_GEOMETRY:+ -g $C_GEOMETRY} "
  _args1="${_args1} ${C_ALLOWAMBIGIOUS:+ -A $C_ALLOWAMBIGIOUS} "
  _args1="${_args1} ${C_SSH_PSEUDOTTY:+ -z $C_SSH_PSEUDOTTY} "
  _args1="${_args1} ${C_XTOOLKITOPTS} "


  local _args2=;
  _args2="${_args2} ${C_DARGS}"
  _args2="${_args2} -b 0 " #****???
  _args1="${_args1} ${C_GEOMETRY:+ -g $C_GEOMETRY} "
  _args2="${_args2} ${C_ALLOWAMBIGIOUS:+ -A $C_ALLOWAMBIGIOUS} "
  _args2="${_args2} ${C_XTOOLKITOPTS}"

  [ -n "${_args2}" ]&&_args2=" '(""${_args2}"")' "
  _args1="${_args1} ${_args2} "


  local _args=" -j ${CALLERJOBID} ";

  #
  #local native access: same as DISPLAYFORWARDING or LOCALONLY
  #
  case $_contype in
      CLI0|SDL)
	  ABORT=1
	  printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Not supported for CONNECT:$_contype"
	  gotoHell ${ABORT}
	  ;;

      VNC)
	  if [ -n "${_actaccessID}" ];then
 	      connectSessionQEMUVNC "${_actaccessID}" "${_label}" 
	  else
	      ABORT=1
	      printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Missing _actaccessID:${_actaccessID}"
	      gotoHell ${ABORT}
	  fi
	  ;;
      CLI)
	  local _xport=`getServerAccessPortQEMU ${_label}`;
	  printDBG $S_QEMU ${D_FLOW} $LINENO $BASH_SOURCE "_xport=${_xport}"

	  if [ -n "$_xport" ];then
	      if [ -n "${CTYS_NETCAT}" ];then
		  _args="${QEMUCALL} ${CTYS_NETCAT} -U ${_xport} "
	      else
		  _args="${QEMUCALL} ${VDE_UNIXTERM} ${_xport} "
	      fi
	      printDBG $S_QEMU ${D_FLOW} $LINENO $BASH_SOURCE "_args=${_args}"
	      ${_args}
	  else
	      ABORT=1
	      printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Missing _xport:${_xport}"
	      gotoHell ${ABORT}
	  fi
	  ;;
      XTERM)
	  local _xport=`getServerAccessPortQEMU ${_label}`;
	  printDBG $S_QEMU ${D_FLOW} $LINENO $BASH_SOURCE "_xport=${_xport}"

	  if [ -n "$_xport" ];then
	      _args="${_args}  -t X11 -a create=l:${_label},cmd:xterm,sh"
	      if [ -n "${CTYS_NETCAT}" ];then
		  _args="${_args},c:${QEMUCALL// /%}${CTYS_NETCAT// /\%}%-U%${_xport} "
	      else
		  _args="${_args},c:${QEMUCALL// /%}${VDE_UNIXTERM// /\%}%${_xport} "
	      fi
              _args="${MYLIBEXECPATH}/ctys.sh ${_args} ${_args1} "
	      printDBG $S_QEMU ${D_FLOW} $LINENO $BASH_SOURCE "_args=${_args}"
	      eval ${_args}
	  else
	      ABORT=1
	      printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Missing _xport:${_xport}"
	      gotoHell ${ABORT}
	  fi
	  ;;
      GTERM)
	  local _xport=`getServerAccessPortQEMU ${_label}`;
	  printDBG $S_QEMU ${D_FLOW} $LINENO $BASH_SOURCE "_xport=${_xport}"
	  if [ -n "$_xport" ];then
	      _args="${_args} -t X11 -a create=l:${_label},cmd:gnome-terminal,dh"
	      if [ -n "${CTYS_NETCAT}" ];then
		  _args="${_args},c:${QEMUCALL// /%}%${CTYS_NETCAT// /\%}%-U%${_xport} "
	      else
		  _args="${_args},c:${QEMUCALL// /%}%${VDE_UNIXTERM// /\%}%${_xport} "
	      fi
              _args="${MYLIBEXECPATH}/ctys.sh ${_args} ${_args1} "
	      printDBG $S_QEMU ${D_FLOW} $LINENO $BASH_SOURCE "_args=${_args}"
	      eval ${_args}
	  else
	      ABORT=1
	      printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Missing _xport:${_xport}"
	      gotoHell ${ABORT}
	  fi
	  ;;
      EMACS|EMACSM|EMACSA|EMACSAM)
	  local _xport=`getServerAccessPortQEMU ${_label}`;
	  printDBG $S_QEMU ${D_FLOW} $LINENO $BASH_SOURCE "_xport=${_xport}"
	  if [ -n "$_xport" ];then
	      _args="${_args}  -t X11 -a create=l:${_label},console:${_contype}"
	      if [ "$SIGISSET" == "1" ];then
		  if [ -n "${CTYS_SIGIGNORESPEC}" ];then
		      _args="${_args},c:\"trap%''%${CTYS_SIGIGNORESPEC// /%};"
		      if [ -n "${CTYS_NETCAT}" ];then
			  _args="${_args}${QEMUCALL// /%}%${CTYS_NETCAT// /\%}%-U%${_xport}\" ${_args1}"
		      else
			  _args="${_args}${QEMUCALL// /%}%${VDE_UNIXTERM// /\%}%${_xport}\" ${_args1}"
		      fi
		  fi
	      else
		  if [ -n "${CTYS_NETCAT}" ];then
		      _args="${_args},c:${QEMUCALL// /%}%${CTYS_NETCAT// /\%}%-U%${_xport} ${_args1}"
		  else
		      _args="${_args}${QEMUCALL// /%}%${VDE_UNIXTERM// /\%}%${_xport}\" ${_args1}"
		  fi
	      fi
              _args="${MYLIBEXECPATH}/ctys.sh ${_args} "
	      printDBG $S_QEMU ${D_FLOW} $LINENO $BASH_SOURCE "_args=${_args}"
	      eval ${_args}
	  else
	      ABORT=1
	      printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Missing _xport:${_xport}"
	      gotoHell ${ABORT}
	  fi
	  ;;

      *)
	  ABORT=1
	  printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Unknown CONSOLE:${_contype}"
	  gotoHell ${ABORT}
	  ;;
  esac
}


#FUNCBEG###############################################################
#NAME:
#  vmMgrQEMU
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Encapsulates the vmrun command with unified calls.
#
#EXAMPLE:
#
#PARAMETERS:
# $1:                 $2       $3         $4        $5       $6         $7
#--------------------------------------------------------------------------------
# REBOOT              <label> <id-pname>  <pid>     <sport>   
# RESET               <label> <id-pname>  <pid>     <sport>   
#
# PAUSE               <label> <id-pname>  <pid>     <sport>   
# RS3                 <label> <id-pname>  <pid>     <sport>   
# S3                  <label> <id-pname>  <pid>     <sport>  
#
# SUSPEND             <label> <id-pname>  <pid>     <sport>  [<tag>]
# RS4                 <label> <id-pname>  <pid>     <sport>  [<tag>]
# S4                  <label> <id-pname>  <pid>     <sport>  <statefile>
#
# POWEROFF            <label> <id-pname>  <pid>     <sport>  <timeout>  [FORCE]
# S5                  <label> <id-pname>  <pid>     <sport>  <timeout>  [FORCE]   
#
#
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function vmMgrQEMU () {
    printDBG $S_QEMU ${D_FLOW} $LINENO $BASH_SOURCE "${FUNCNAME} $*"

    local _cmd=$1;shift
    local _label=$1;shift
    local _id=$1;shift
    local _pid=$1;shift
    local _sport=$1;shift
    local _arg1=$1;shift
    local _arg2=$1;shift

    if [ -z "${_cmd}" ];then
	ABORT=1
	printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Missing CMD"
	gotoHell ${ABORT}
    fi
    if [ -z "${_label}" ];then
	ABORT=1
	printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Missing LABEL"
	gotoHell ${ABORT}
    fi
    if [ -z "${_id}" ];then
	ABORT=1
	printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Missing ID"
	gotoHell ${ABORT}
    fi
    if [ -z "${_pid}" ];then
	ABORT=1
	printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Missing PID"
	gotoHell ${ABORT}
    fi

    if [ -z "${_sport}" ];then
	ABORT=1
	printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Missing SPORT"
	gotoHell ${ABORT}
    fi

    if [ ! -e "${_sport}" ];then
	ABORT=1;
	printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:Missing UNIX-Domain socket:"
	printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:  SPORT=${_sport}"
	printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:Probably a prevoious \"stackerCancelPropagate\""
	printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:was meanwhile successful."
	printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:Continue, but use \"kill\" from now on if"
	printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:FORCE is set."
	_sport=;
    else
	if [ ! -S "${_sport}" ];then
	    ABORT=1;
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:Cannot access SPORT, Is not a UNIX-Domain socket:"
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:  SPORT=${_sport}"
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:Continue, but use \"kill\" from now on if"
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:FORCE is set."
	    _sport=;
	fi
    fi

    function callMonitorCmd () {
	printDBG $S_QEMU ${D_FLOW} $LINENO $BASH_SOURCE "${FUNCNAME} <${*}>"
        local _monsock=$1;shift
        local _cmd=$*
	printDBG $S_QEMU ${D_FLOW} $LINENO $BASH_SOURCE "${FUNCNAME} monsock=<${_monsock}> cmd=<${_cmd}>"

	checkConsole "${_monsock}"
	local _ret=$?;
	if [ $_ret -ne 0 ];then
	    printWNG 1 $LINENO $BASH_SOURCE 1 "${FUNCNAME}:Cannot acces MONSOCK=<${_monsock}>"
	    printWNG 1 $LINENO $BASH_SOURCE 1 "${FUNCNAME}:In use:users=$((_ret-1))"
	    printDBG $S_QEMU ${D_FLOW} $LINENO $BASH_SOURCE "${FUNCNAME}:Cannot acces MOSOCK=<${_monsock}>"
	    printDBG $S_QEMU ${D_FLOW} $LINENO $BASH_SOURCE "${FUNCNAME}:In use:users=$((_ret-1))"
	    return 1
	fi

	if [ -n "${CTYS_NETCAT}" ];then
	    local _call="printf '\x1\x63${_cmd}\n\x1\x63'|${QEMUCALL} ${CTYS_NETCAT} -U ${_monsock}"
	    printDBG $S_QEMU ${D_FLOW} $LINENO $BASH_SOURCE "${FUNCNAME} call=<${_call}>"
	    (
		callErrOutWrapper $LINENO $BASH_SOURCE  ${QEMUCALL} "$_call"
		callErrOutWrapper $LINENO $BASH_SOURCE  ${CTYS_UNLINK} "$_monsock"
            )&
	else
            (	    
                callErrOutWrapper $LINENO $BASH_SOURCE ${QEMUCALL} $VDE_UNIXTERM $_monsock <<EOF
\001\143${_cmd}\n\001\143
EOF
                callErrOutWrapper $LINENO $BASH_SOURCE  ${CTYS_UNLINK} "$_monsock"
            )&
	fi
    }


    releaseConsole "${_sport}"
    case $_cmd in
        #CREATE######################
	RS3|PAUSE)
            if [ -z "${C_NOEXEC}" ];then
		if [ -n "${_sport}" ];then
		    callMonitorCmd "${_sport}" cont
		else
		    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:Cannot submit command:${_cmd}"
		fi
	    fi
	    ;;

	RS4|SUSPEND)
            if [ -z "${C_NOEXEC}" ];then
		if [ -n "${_sport}" ];then
		    callMonitorCmd "${_sport}" loadvm S4
		    callMonitorCmd "${_sport}" delvm  S4
		else
		    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:Cannot submit command:${_cmd}"
		fi
	    fi
	    ;;

        #CANCEL######################
	S3)
            if [ -z "${C_NOEXEC}" ];then
		if [ -n "${_sport}" ];then
		    callMonitorCmd "${_sport}" stop
		else
		    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:Cannot submit command:${_cmd}"
		fi
	    fi
	    ;;

	S4)
            #1.S3-stop
            #2.S4-savevm
            #3.S5-system_powerdown

            if [ -z "${C_NOEXEC}" ];then
		if [ -n "${_sport}" ];then
		    callMonitorCmd "${_sport}" stop
		    callMonitorCmd "${_sport}" savevm S4
		    callMonitorCmd "${_sport}" system_powerdown
		    callMonitorCmd "${_sport}" '\001\170\n'
		else
		    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:Cannot submit command:${_cmd}"
		fi
	    fi
	    ;;

	REBOOT|RESET)
            if [ -z "${C_NOEXEC}" ];then
		if [ -n "${_sport}" ];then
		    callMonitorCmd "${_sport}" system_reset
		else
		    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:Cannot submit command:${_cmd}"
		fi
	    fi
	    ;;

	POWEROFF)
            if [ -z "${C_NOEXEC}" ];then
		if [ -n "${_sport}" ];then
		    callMonitorCmd "${_sport}" '\001\170\n'
		    if [ $? -ne 0 ];then
			ABORT=1
			printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:Cannot POWEROFF native GuestOS"
			if [ "$_arg2" != FORCE ];then
			    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:Stop running client, and/or use the \"FORCE\" Luke."
			fi
		    fi
		else
		    ABORT=1;
		    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:Missing SPORT, Cannot submit command:${_cmd}"
		fi
		case "$_arg2" in
		    FORCE)


			ABORT=1;
			_timeout=${_arg1:-1}
			printINFO 1 $LINENO $BASH_SOURCE $ABORT "${FUNCNAME} Delay forced kill:${_timeout} seconds"
 			sleep ${_timeout}

			printINFO 1 $LINENO $BASH_SOURCE $ABORT "${FUNCNAME} Check whether:"
			printINFO 1 $LINENO $BASH_SOURCE $ABORT "${FUNCNAME}   1.Still running:     pid(${_pid})"
			printINFO 1 $LINENO $BASH_SOURCE $ABORT "${FUNCNAME}   2.Still what it was: id(${_id})"
			if [ "`fetchID4PID ${_pid}`" == "${_id}" ];then
			    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME} Can not avoid to kill:${_pid}==${_id}"
			    callErrOutWrapper $LINENO $BASH_SOURCE  ${QEMUCALL} kill $_pid
			    printWNG 1 $LINENO $BASH_SOURCE $ABORT "${FUNCNAME} Delay forced \"kill -9\":${_timeout} seconds"
			    sleep $_timeout
			    if [ "`fetchID4PID ${_pid}`" == "${_id}" ];then
				printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME} Have to use \"-9\" now:${_pid}==${_id}"
				callErrOutWrapper $LINENO $BASH_SOURCE  ${QEMUCALL} kill $_pid
			    else
				printINFO 1 $LINENO $BASH_SOURCE $ABORT "${FUNCNAME}   \"-9\" was not required."
			    fi
			    printWNG 1 $LINENO $BASH_SOURCE $ABORT "${FUNCNAME} Done what to have..."
			    printWNG 1 $LINENO $BASH_SOURCE $ABORT "${FUNCNAME} ...do not forget \"fsck\""
			else
			    printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME} Can not apply kill, target changed:"
			    printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}   ${_pid} != ${_id}"
			fi
			;;
		    *)
			if [ -z "${_sport}" ];then
			    ABORT=1;
			    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:If VM is still present use of the FORCE Luke"
			    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:Be aware, that this is an actual and abrupt"
			    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:\"switch-off\" by \"kill\" of the QEMU processes"
			    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:which could eventually damage the the GuestOS."
			fi
			;;
		esac
	    fi
            ;;
    esac
}


#FUNCBEG###############################################################
#NAME:
#  connectSessionQEMUVNC
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: <display-id>|<display-port>
#      This is calculated from the port, and is the offset to that.
#      The base-value is normally 5900 for RealVNC+TIghtVNC.
#      TightVNC might allow the selection of another port.
#
#  $2: <session-label>
#      This will be used for the title of the client window.
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function connectSessionQEMUVNC () {
  local _id=${1}
  local _label=${2}
  printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME ${_id} ${_label}"


  #even though this condition might be impossible now, let it beeeee ...
  if [ -z "${_label}" -a -z "${_id}" ];then
    ABORT=1
    printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Fetch of peer entry failed:_id=${_id} - _label=${_label}"
    gotoHell ${ABORT}
  fi

  printDBG $S_QEMU ${D_FRAME} $LINENO $BASH_SOURCE "OK:_id=${_id} - _label=${_label}"
  #
  #Now shows name+id in title, id could not be set for server as default.
  local _vieweropt="-name ${_label}:${_id} ${VNCVIEWER_OPT} ${C_GEOMETRY:+ -geometry=$C_GEOMETRY} "

  #old version with server-default label in title
  #  local _vieweropt="${VNCVIEWER_OPT} ${C_GEOMETRY:+ -geometry=$C_GEOMETRY} "
  local CALLER="${VNCVIEWER} ${C_DARGS} ${_vieweropt} :${_id}"
  printDBG $S_QEMU ${D_FRAME} $LINENO $BASH_SOURCE "CALLER=${CALLER}"
  export C_ASYNC;
  [ -z "${C_NOEXEC}" ]&&eval ${CALLER}
  printDBG $S_QEMU ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:finished"
}
