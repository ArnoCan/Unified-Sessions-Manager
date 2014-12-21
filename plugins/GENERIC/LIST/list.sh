#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@users.sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_018
#
########################################################################
#
# Copyright (C) 2007,2010,2011 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

_myPKGNAME_GENERIC_LIST="${BASH_SOURCE}"
_myPKGVERS_GENERIC_LIST="01.11.018"
hookInfoAdd "$_myPKGNAME_GENERIC_LIST" "$_myPKGVERS_GENERIC_LIST"
_myPKGBASE_GENERIC_LIST="`dirname ${_myPKGNAME_GENERIC_LIST}`"


#Check of length for internal interface
C_LIST_NF=22


#FUNCBEG###############################################################
#NAME:
#  listProcesses
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
# $1: <ID>
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function listProcesses () {
    printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=<${@}>"
    local ntop=$1;
    local tmpScope=${2:-$C_SCOPE};
    local tmpScopeArgs=${3:-$C_SCOPE_ARGS};
    printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:tmpScope=<${tmpScope}>"
    printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:tmpScopeArgs=<${tmpScopeArgs}>"

    tmpScopeArgs=`echo ${tmpScopeArgs}|tr '[:lower:]' '[:upper:]'`

    doDebug $S_GEN  ${D_BULK} $LINENO $BASH_SOURCE
    if [ "$?" -eq "0" -a -z "$ntop" ];then
	printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "Check for raw process-list on `uname -n`:=>`echo;listProcesses STOP|sed 's/^/      /';echo`<="
    fi

    case ${tmpScope} in 
	USER)    
	    printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "PS-CALL:\"ps ${PSU} ${USER} ${PSF} \""
	    ${PS} ${PSU} ${USER} ${PSF} 
	    ;;
	GROUP)
            case ${MYOS} in
	        Linux)
		    printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "PS-CALL:\"ps ${PSG} `getUserGroup ${USER}` ${PSF}\""
  	            ${PS} ${PSG} `getUserGroup ${USER}` ${PSF}
 	            ;;
            esac
            ;;
	USRLST)  
	    if [ "${tmpScopeArgs}" == "ALL" ];then
		printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "PS-CALL:\"ps ${PSEF}\""
                ${PS} ${PSEF} ;
            else
		printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "PS-CALL:\"ps ${PSU} ${tmpScopeArgs} ${PSF}\""
                ${PS} ${PSU} ${tmpScopeArgs} ${PSF} ;
            fi
            ;;
	GRPLST)  
	    if [ "${tmpScopeArgs}" == "ALL" ];then
		printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "PS-CALL:\"ps ${PSEF}\""
		${PS} ${PSEF};
            else
		printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "PS-CALL:\"ps ${PSG} ${tmpScopeArgs} ${PSF}\""
		${PS} ${PSG} ${tmpScopeArgs} ${PSF} ;
            fi
            ;;
	*)
	    ABORT=2
	    printERR $LINENO $BASH_SOURCE ${ABORT} "System Error, unknown SCOPE=${tmpScope}"
	    gotoHell ${ABORT}
	    ;;
    esac
}



#FUNCBEG###############################################################
#NAME:
#  listMySessions
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Lists current active sessions.
#
#  The data input record format from the plugin specific list calls:
#
#
#  format: host:label:id:uuid:mac:disp:cport:sport:pid:uid:gid:sessionType:clientServer:tcp:jid:ifn:res1:cstrg:exep:hrx:acc:arch
#          0    1     2  3    4   5    6     7     8   9   10  11          12           13  14  15  16   17   18   19  20  21   
#          1    2     3  4    5   6    7     8     9   10  11  12          13           14  15  16  17   18   19   20  21  22
#
#
#  awk -F':' -v h=$_H -v l=$_L -v i=$_I -v p=$_P -v u=$_U -v g=$_G -v t=$_T -v uu=$_UU -v cs=$_S 
#            -v mac=$_MAC -v tcp=$_tcp -v dsp=_DSP -v jid=_jid -v cp=_CP -v sp=_SP  '
#
#
#  For additional semantic information refer to online help.
#
#EXAMPLE:
#
#PARAMETERS:
# $(1-*): <list attributes>
#           SERVER|CLIENTS|BOTH,
#           NONE,ALL,TERSE
#           LABEL,HOST,ID,PID,USER,GROUP,TYPE,UUID,SITE,IP,MAC,TCP,CPORT,SPORT,DISPLAY,
#           HYPERRELRUN,ACCELERATOR,ARCH
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#
#    List-Output-Format:
#    ===================
#
#    +-----------------------------+
#      1 - h:    host              |
#      2 - t:    type              |
#      3 - l:    label             |
#      4 - i:    id                | Identical to ENUMERATE
#      5 - uu:   uuid              |
#      6 - mac:  mac               |
#      7 - tcp:  TCP|IP|DNS        |
#    +-----------------------------+
#      8 - dsp:  display
#      9 - cp:   client access port
#     10 - sp:   server access port
#     11 - p:    pid
#     12 - u:    uid
#     13 - g:    gid
#     14 - cs:   client|server
#     15 - jid:  job id
#     16 - ifn:  if name
#     17 - ffs
#     18 - cstrg:contextstring
#     19 - exep: exepath
#     20 - hrx:  hyperrelrun
#     21 - acc:  accellerator
#     22 - arch: architecture
#
#FUNCEND###############################################################
function listMySessions () {
  local _args=${1:-$DEFAULT_LIST_CONTENT}
  if [ -z "$_args" ];then
    _args=${C_MODE_ARGS}
  fi

  case ${MYOS} in
      SunOS)
	  ABORT=2;
	  printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:${MYOS} is not properly supported by LIST action"
	  printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:This is due to limited length of ps command field"
	  printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:and some additional optimization by OS-Scheduler."
	  printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:Thus required attributes are frequently dropped from"
	  printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:ps-output, leaving the LIST action \"blind\", not "
	  printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:recognizing some actually running plugins(e.g. X11)!!!"
	  ;;
  esac

  printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=<${@}>"
  printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:MODE=${C_MODE}"
  printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:MODE_ARGS=${_args}"

  local _res1=0;

  local _ifn=0;

  local _site="";
  local _P=0;local _U=0;local _G=0;local _L=0;local _I=0;local _T=0;local _S=0;
  local _H=0;local _UU=0;
  local _MAC=0;local _tcp=0;local _dns=0;local _DSP=0;local _CP=0;local _SP=0;
  local _jid=0;
  local _cstrg=0;
  local _exep=0;
  local _arch=0;
  local _hrx=0;
  local _acc=0;

  local _title=0;
  local _titleidx=0;
  local _terse=${C_TERSE:-0};
  local _Ux=;

  local _pkg=0;
  local _pkgargs=;

  local _machine=0;
  local _maxkey=0;
  local _all=0;
  local _tab=;
  local _TABARGS=;

  #controls debugging for awk-scripts
  doDebug $S_GEN  ${D_MAINT} $LINENO $BASH_SOURCE
  local D=$?

  local _prologue=0;
  local _epilogue=0;
  local _sort=0;
  local _sortkey=0;
  local _unique=0;


  local i=;

  function fetchSessions () {
      printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME"
      printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "PACKAGES_KNOWNTYPES=${PACKAGES_KNOWNTYPES}"
      printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "PKG-CONSTRAINTS=${C_SESSIONTYPE}"
      local _matched=0;
      for y in ${PACKAGES_KNOWNTYPES} DIGGER;do
	  printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "C_SESSIONTYPE=${C_SESSIONTYPE} - y=${y}"
	  if [ "${C_SESSIONTYPE}" == $y -o "${C_SESSIONTYPE}" == "ALL" -o "${C_SESSIONTYPE}" == DEFAULT -o -n "${_pkgargs}" ];then
	      if [ "${_pkg}" == "1" ];then
		  local _blacklist=1;
		  local _ipx=;
		  for _ipx in ${_pkgargs//\%/ };do
		      if [ "${y}" == "${_ipx}" ];then
			  _blacklist=0;
			  break;
		      fi
		  done
		  if [ "${_blacklist}" == "1" ];then
		      printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "IGNORED:\"${y}\"!=\"${_ipx}\""
		      continue;
		  else
		      printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "USE:\"${y}\"==\"${_ipx}\""
		  fi
	      fi
	      _matched=1; 
	      [ "$_U" == 1 ]&&_Ux=UUID;
              local _yx="${y}_STATE";
              _yx=$(eval echo \${${_yx}})
	      printINFO 9 $LINENO $BASH_SOURCE 1 "${FUNCNAME}:<$(getCurTime)>:${y}:${_yx}"
              if [ "${_yx}" == ENABLED ];then
                    eval handle${y} PROLOGUE LIST
                    SESLST="${SESLST} `listMySessions${y} ${_site}`"
              fi
	  fi
      done
      if((_matched==0));then
	  ABORT=2
	  printERR $LINENO $BASH_SOURCE ${ABORT} "System Error, unexpected C_SESSIONTYPE=${C_SESSIONTYPE}"
	  printERR $LINENO $BASH_SOURCE ${ABORT} "  PACKAGES_KNOWNTYPES=${PACKAGES_KNOWNTYPES}"

	  gotoHell ${ABORT}
      fi
      printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:SESLST=${SESLST}"
  }


  #
  # $1:title-display:
  #    0: off
  #    1: on
  #
  # $2:awk-filter-file
  #
  function applyFilter () {
      local t=0;
      local tx=0;
      if [ "$1" == 1 ];then
	  local t=${_title};
	  local tx=${_titleidx};
      fi

      awk -F';' -v h=$_H -v l=$_L -v i=$_I -v p=$_P -v u=$_U -v g=$_G -v t=$_T -v uu=$_UU -v cs=$_S \
	  -v mac=$_MAC -v tcp=$_tcp -v dns=$_dns -v dsp=$_DSP -v cp=$_CP -v sp=$_SP -v jid=$_jid \
	  -v hrx=$_hrx -v acc=$_acc  -v arch=$_arch  -v cstrg=$_cstrg -v exep=$_exep \
	  -v res1=$_res1 -v ifn=$_ifn \
	  -v d=$D -v dargs="${C_DARGS}" -v callp="${MYLIBEXECPATH}/" \
	  -v cols="$_TABARGS" \
	  -v listnf="$C_LIST_NF" \
	  -f ${2} \
          \
	  -v title=${t} -v titleidx=${tx}
  }


  function applySort () {
      if [ "$_sort" == 1 ];then
	  if [ "$_sortkey" -ne 0 ];then
	      sort -t \| -k ${_sortkey} ${_unique:+ -u }
	  else
	      sort ${_unique:+ -u }
	  fi
      else
	  cat
      fi
  }

  printDBG $S_CLI ${D_UID} $LINENO $BASH_SOURCE "_args=$_args"
  _args=`cliSplitSubOpts ${_args}`;
  for i in ${_args};do
      KEY=`cliGetKey ${i}`
      ARG=`cliGetArg ${i}`
      case $KEY in
          ACCELERATOR|ACCEL) _acc=1;;
	  ARCH)       _arch=1;;
          CONTEXTSTRG|CSTRG) _cstrg=1;;
	  CPORT)      _CP=1;;
	  DISPLAY)    _DSP=1;;
	  EXEPATH|EXEP)_exep=1;;
	  GROUP|GID) _G=1;;
          HYPERRELRUN|HRELRUN|HRELX|HRX) _hrx=1;;
	  ID|PATHNAME|PNAME|P) _I=1;;
	  IFNAME|IF)  _ifn=1;;
	  JOBID|JID)  _jid=1;;
	  LABEL)      _L=1;;
 	  MAC)        _MAC=1;;
	  PID)        _P=1;;
	  PM|HOST)    _H=1;;
	  SITE)       _S=1;;
	  SPORT)      _SP=1;;
 	  TCP)        _tcp=1;;
	  TYPE|ST|STYPE) _T=1;;
	  USER|UID)    _U=1;;
	  UUID)       _UU=1;;

          ###
           #####
          ###

	  TITLE)      _title=1;;
	  TITLEIDXASC)_titleidx=2;;
	  TITLEIDX)   _titleidx=1;;

	  MACHINE)    _machine=1;;
	  MAXKEY)     _maxkey=1;;

          ###
           #####
          ###

	  TERSE)      _terse=1;;

          ###
           #####
          ###

 	  DNS)        _dns=2;;
 	  IP)         _ip=1;;

          ###
           #####
          ###

	  ALL)        _all=1;;

	  PROLOGUE)     
              _prologue=1;
	      ;;

	  EPILOGUE)     
              _epilogue=1;
	      ;;


	  SERVER)     
	      if [ -n "${_site}" ];then 
		  ABORT=2
		  printERR $LINENO $BASH_SOURCE ${ABORT} "following must be EXOR: SERVER | CLIENT | TUNNEL | BOTH"
		  gotoHell ${ABORT}
	      fi;
	      _site=S;
	      ;;
	  CLIENT)     
	      if [ -n "${_site}" ];then 
		  ABORT=2
		  printERR $LINENO $BASH_SOURCE ${ABORT} "following must be EXOR: SERVER | CLIENT | TUNNEL | BOTH"
		  gotoHell ${ABORT}
	      fi;
	      _site=C;
	      ;;
	  TUNNEL)     
	      if [ -n "${_site}" ];then 
		  ABORT=2
		  printERR $LINENO $BASH_SOURCE ${ABORT} "following must be EXOR: SERVER | CLIENT | TUNNEL | BOTH"
		  gotoHell ${ABORT}
	      fi;
	      _site=T;
	      ;;
	  BOTH)       
	      if [ -n "${_site}" ];then 
		  ABORT=2
		  printERR $LINENO $BASH_SOURCE ${ABORT} "following must be EXOR: SERVER | CLIENT | TUNNEL | BOTH"
		  gotoHell ${ABORT}
	      fi;
	      _site=B;
	      ;;
	  NONE) 
	      _none=0;
 	      _L=0;_P=0;_U=0;_G=0;_T=0;_H=0;_S=0;_I=0;_UU=0;_CP=0;_SP=0;_DSP=0;
	      _MAC=0;
	      _tcp=0;
	      ;;


	  PKG)        _pkg=1;
		      if [ -z "${ARG}" ];then
			  ABORT=1
			  printERR $LINENO $BASH_SOURCE ${ABORT} "Missing arguments for PKG"
			  gotoHell ${ABORT}
		      fi
   	              _pkgargs=$(echo ${ARG}|tr '[:lower:]' '[:upper:]')
	              ;;
	  SORT)        _sort=1;
		       local i1=;
		       for i1 in ${ARG//\%/ };do
			   case ${i1} in
			       [aA][lL][lL])#will be sorted in the topmost schedular once, does not require sub-sorts
				   if [ -n "${CTYS_SUBCALL}" ];then
				       _sort=0;
				   fi
				   ;;
			       [uU][nN][iI][qQ][uU][eE])
				   _unique=1;
				   ;;
			       [eE][aA][cC][hH])
				   ;;
			       [0-9][0-9][0-9]|[0-9][0-9][0-9]|[0-9][0-9]|[0-9])
				   _sortkey=${i1}
				   ;;
			       *)
				   ABORT=2
				   printERR $LINENO $BASH_SOURCE ${ABORT} "Unexpected sort suboption:${ARG}"
				   gotoHell ${ABORT}
				   ;;
			   esac
		       done
		       ;;

	  TAB|TAB_GEN)_tab=TAB_GEN;_title=1;_machine=1;
   	              _TABARGS=${ARG}
	              ;;
	  SPEC_GEN|SPEC)
                      _tab=SPEC_GEN;_machine=1;
   	              _TABARGS=${ARG}
	              ;;
	  REC_GEN|REC)
                      _tab=REC_GEN;_machine=1;
   	              _TABARGS=${ARG}
	              ;;
	  XML_GEN|XML)
                      _tab=XML_GEN;_machine=1;
   	              _TABARGS=${ARG}
	              ;;
	  TAB_TCP)    _tab=TAB_TCP;_title=1;_machine=1;
   	              _TABARGS=${ARG}
		      if [ -n "${_TABARGS##+([0-9%])}" ];then
			  ABORT=2
			  printERR $LINENO $BASH_SOURCE ${ABORT} "Column sizes:${_TABARGS}"
			  gotoHell ${ABORT}
		      fi
	              ;;
      esac
  done

  if((_epilogue+_prologue>1));then
      ABORT=1
      printERR $LINENO $BASH_SOURCE ${ABORT} "Internal error, use EXOR: PROLOGUE|EPILOGUE"
      gotoHell ${ABORT}
  fi

  #set content default
  if [ $_L == 0 -a $_H == 0 -a $_I == 0 -a $_P == 0 -a $_U == 0 -a $_G == 0 -a $_T == 0 -a $_UU == 0 -a $_S == 0 \
       -a $_MAC == 0 -a $_tcp == 0 -a $_CP == 0 -a $_SP == 0 -a $_DSP == 0 -a $_jid == 0 \
       -a $_arch == 0 -a $_hrx == 0 -a $_acc == 0 -a $_cstrg == 0 -a $_exep == 0 -a $_ifn == 0 \
       -a $_all == 0 -a $_maxkey == 0 -a $_machine == 0 \
      ];then
      printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "Force of ID"
      _I=1;
      _tab=TAB_TCP;_title=1;_machine=1;
 #_terse=1;
  fi

  if((_all==1));then
      _L=1;_P=1;_U=1;_G=1;_T=1;_H=1;_S=1;_I=1;_UU=0;_CP=0;_SP=0;_DSP=0;_jid=1;
      _MAC=0;
      _tcp=0;
      _arch=1;_hrx=1;_acc=1;_cstrg=1;_exep=1;_ifn=1;
      _res1=1;
  fi

  if((_maxkey==1));then
      #don't touch this
      _terse=1;
      _H=1;_T=1;_L=1;_I=1;_UU=1;_MAC=1;
      _tcp=0;_jid=0;
      _P=0;_U=0;_G=0;_S=0;_CP=0;_SP=0;_DSP=0;
  fi

  if((_machine==1));then
      _H=1;_L=1;_T=1;
      let _I++;
      let _UU++;
      let _MAC++;
      let _tcp++;
      _DSP=1;_CP=1;_SP=1;_P=1;_U=1;_G=1;_S=1;
      _jid=1;_arch=1;_hrx=1;_acc=1;_cstrg=1; _exep=1;_ifn=1;
      _res1=1; 
      _terse=1;
  fi

  if((_ip==1&&_tcp>0));then
      let  _tcp++;
  fi

  #default lists sessions only, gwhich are defined to be the server(-sessions),
  #due to the roaming feature of almost all clients, and partly broadcast support.
  if [ -z "${_site}" ];then
      _site=B;
  fi


  printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "_L=$_L _H=$_H _I=$_I _P=$_P _U=$_U  _G=$_G _T=$_T _UU=$_UU "
  printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "_S=$_S _tcp=$_tcp _MAC=$_MAC _CP=$_CP _SP=$_SP _DSP=$_DSP"
  printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "_jid=$_jid _ifn=$_ifn"
  printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "hrx=$_hrx acc=$_acc arch=$_arch cstrg=$_cstrg _exep=$_exep"

  printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "C_SESSIONTYPE    = ${C_SESSIONTYPE}"
  local SESLST=

  printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "C_CACHEDOP       = ${C_CACHEDOP}"
  printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "C_CACHEONLY      = ${C_CACHEONLY}"
  printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "CALLERCACHE      = ${CALLERCACHE}"
  printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "CALLERCACHEREUSE = ${CALLERCACHEREUSE}"
  printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "C_CACHEPROCESSED = ${C_CACHEPROCESSED}"

  printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "_prologue        = ${_prologue}"
  printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "_epilogue        = ${_epilogue}"

  if [ "${_prologue}" == 1 ];then
      if [ -z "${CTYS_SUBCALL}" -a "${C_CACHERAW}" != 1 ];then
      #do it in prologue because non-cached operations has to be provided too
      #header only
	  case $_tab in
	      TAB_GEN)echo ""|applyFilter 1 "${MYLIBPATH}/lib/tab_gen/tab_gen.awk";;
	      TAB_TCP)echo ""|applyFilter 1 "${_myPKGBASE_GENERIC_LIST}/tab_tcp.awk";;
	      XML_GEN);;
	      REC_GEN);;
	      SPEC_GEN);;
	      *)      echo ""|applyFilter 1 "${_myPKGBASE_GENERIC_LIST}/canonize.awk";;
	  esac
      fi
  else
      if [ "${_epilogue}" = 1 -a -z "${CTYS_SUBCALL}" -a "${C_CACHERAW}" == 1 ];then
	  case $_tab in
	      TAB_GEN)echo ""|applyFilter 1 "${MYLIBPATH}/lib/tab_gen/tab_gen.awk";;
	      TAB_TCP)echo ""|applyFilter 1 "${_myPKGBASE_GENERIC_LIST}/tab_tcp.awk";;
	      XML_GEN);;
	      REC_GEN);;
	      SPEC_GEN);;
	      *)      echo ""|applyFilter 1 "${_myPKGBASE_GENERIC_LIST}/canonize.awk";;
	  esac
      fi


      if [ \( "$C_CACHEONLY" == 0 -a "$C_CACHEDOP" == 0 -a "$_epilogue"  == 0  \) \
	  -o \( "$C_CACHEONLY" == 0 -a "$_epilogue"  == 0 \) \
	  ];then
	  fetchSessions
	  printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "CACHE:SESLST=${SESLST}"
      else
	  if [ \( "$C_CACHEONLY" == 1 -a \( "$C_CACHEDOP" == 0 -o "$_epilogue" == 0 \) \) \
	      -a \
	      ! -f "${CALLERCACHEREUSE}" -a "$C_CACHEAUTO" == 1\
		  ];then
              printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "CACHE:AUTO:build:${CALLERCACHE}"
              fetchSessions
	      printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "CACHE:SESLST=${SESLST}"
	      for  i in ${SESLST};do
		  echo $i>>"${CALLERCACHEREUSE}"
	      done
	  fi
      fi

      _site=${_site:+1}

      if [ "${_terse}" == 0 ];then
	  echo
	  echo "${C_SESSIONTYPE} sessions of SCOPE=${C_SCOPE} -  ${C_SCOPE_ARGS:-$USER}@`uname -n`:"
      fi

      if [ -n "${SESLST// /}" \
           -o \( \( "$C_CACHEDOP" == 1 -a "$_epilogue" == 1 \) -a \( -s "${CALLERCACHE}" -o -s "${CALLERCACHEREUSE}" \) \) \
           -o "$C_CACHEAUTO" == 1 \
	  ];then
	  {
	      if [ "$C_CACHEDOP" == 1 -a "$_epilogue" == 1 -a "$C_CACHEONLY" == 0  ];then
                  #fresh cache from current run
		  printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "CACHE:READOUT:CALLERCACHE=${CALLERCACHE}"
		  cat ${CALLERCACHE}
	      else
		  if [ "$C_CACHEDOP" == 1 -a "$C_CACHEONLY" == 1 -a -f "${CALLERCACHEREUSE}" -a "$C_CACHEPROCESSED" != 1 ];then
                      #provided cache from any previous run
		      printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "CACHE:READOUT:CALLERCACHEREUSE=${CALLERCACHEREUSE}"
		      cat ${CALLERCACHEREUSE}
		  else
                      #runs on fresh data within memory or requires build of cache
		      printDBG $S_GEN ${D_MAINT} $LINENO $BASH_SOURCE "CACHE:USE SESLST"
		      for i in ${SESLST};do
			  printDBG $S_GEN ${D_MAINT} $LINENO $BASH_SOURCE "MATCH=${i}"
			  if [ "${_terse}" == 0 ];then
			      echo -n "+->";
			  fi

			  if [ "$C_CACHERAW" == 1 ];then
			      echo "${i}"
			  else
			      case $_tab in
				  SPEC_GEN|REC_GEN|XML_GEN)
				      echo -e "${i}"|applyFilter 1 "${_myPKGBASE_GENERIC_LIST}/canonrec.awk"
				      ;;
				  *)
				      echo -e "${i}"|applyFilter 0 "${_myPKGBASE_GENERIC_LIST}/canonize.awk"
				      ;;
			      esac


			  fi
		      done
		  fi
	      fi
	  }|\
          {
	      if [ "$C_CACHEDOP" == 1 -a "$_prologue" == 0 -a "$_epilogue" == 0 -a "$C_CACHERAW" == 1 \
		  -a "$C_CACHEONLY" == 0 \
		  ];then
		  printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "CACHE:WRITE"
		  cat
	      else
		  if [ "$C_CACHEDOP" == 1 -a "$_prologue" == 0 -a "$_epilogue" == 1 -a "$C_CACHERAW" == 0 ];then
		      printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "CACHE:WRITE"
                      #write in case of cached operations first all in "machine" format into caller's local cache
		      applySort
		  else
		      printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "CACHE:WRITE"
		      case $_tab in
			  SPEC_GEN)
			      if [ "$C_CACHERAW" == 1 ];then
				  applyFilter 1 "${_myPKGBASE_GENERIC_LIST}/canonrec.awk"|\
                                  applyFilter 1 "${MYLIBPATH}/lib/tab_gen/spec_gen.awk"|\
                                  applySort;
			      else
				  applyFilter 0 "${MYLIBPATH}/lib/tab_gen/spec_gen.awk"|applySort
			      fi
			      ;;
			  REC_GEN)
			      if [ "$C_CACHERAW" == 1 ];then
				  applyFilter 1 "${_myPKGBASE_GENERIC_LIST}/canonrec.awk"|\
                                  applyFilter 1 "${MYLIBPATH}/lib/tab_gen/rec_gen.awk"|\
                                  applySort;
			      else
				  applyFilter 0 "${MYLIBPATH}/lib/tab_gen/rec_gen.awk"|applySort
			      fi
			      ;;
			  XML_GEN)
			      if [ "$C_CACHERAW" == 1 ];then
				  applyFilter 1 "${_myPKGBASE_GENERIC_LIST}/canonrec.awk"|\
                                  applyFilter 1 "${MYLIBPATH}/lib/tab_gen/xml_gen.awk"|\
                                  applySort;
			      else
				  applyFilter 0 "${MYLIBPATH}/lib/tab_gen/xml_gen.awk"|applySort
			      fi
			      ;;
			  TAB_GEN)
			      if [ "$C_CACHERAW" == 1 ];then
				  applyFilter 0 "${_myPKGBASE_GENERIC_LIST}/canonize.awk"|\
                                  applyFilter 0 "${MYLIBPATH}/lib/tab_gen/tab_gen.awk"|\
                                  applySort;
			      else
				  applyFilter 0 "${MYLIBPATH}/lib/tab_gen/tab_gen.awk"|applySort
			      fi
			      ;;
			  TAB_TCP)
			      if [ "$C_CACHERAW" == 1 ];then
				  applyFilter 0 "${_myPKGBASE_GENERIC_LIST}/canonize.awk"|\
                                  applyFilter 0 "${_myPKGBASE_GENERIC_LIST}/tab_tcp.awk"|\
                                  applySort;
			      else
				  applyFilter 0 "${_myPKGBASE_GENERIC_LIST}/tab_tcp.awk"|applySort
			      fi
			      ;;
 			  *)
			      if [ "$C_CACHERAW" == 1 ];then
				  applyFilter 0 "${_myPKGBASE_GENERIC_LIST}/canonize.awk"|applySort;
			      else
				  applySort
			      fi
			      ;;
		      esac
		  fi
	      fi
	  }
	  C_CACHEPROCESSED=1;
      else
	  if [ "${_terse}" == 0 ];then
	      echo "NONE"
	  fi
      fi
  fi
  printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME"
}




#FUNCBEG###############################################################
#NAME:
#  listCheckParam
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
function listCheckParam () {
    if [ "${C_SCOPE}" == "DEFAULT"  ];then
        C_SCOPE=USRLST
        C_SCOPE_ARGS=ALL
    fi

    printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "${FUNCNAME}:${C_SESSIONTYPE} - ${C_EXECLOCAL}"
    if [ "${C_SESSIONTYPE}" == "DEFAULT" -a -n "${C_EXECLOCAL}" ];then
        C_SESSIONTYPE=ALL
    fi

    if [ -n "$C_MODE_ARGS" ];then
	printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "${FUNCNAME}:C_MODE_ARGS=\"${C_MODE_ARGS}\""

	printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "${FUNCNAME}:MODE_ARGS-X=${_argsX}"

        local i=;
	local _argsX1=;
        for i in ${C_MODE_ARGS//,/ };do
	    KEY=`echo ${i}|awk -F':' '{print $1}'|tr '[:lower:]' '[:upper:]'`
	    ARG=`echo ${i}|awk -F':' '{print $2}'`

	    printDBG $S_GEN ${D_MAINT} $LINENO $BASH_SOURCE "KEY=${KEY}"
	    printDBG $S_GEN ${D_MAINT} $LINENO $BASH_SOURCE "ARG=<${ARG}>"
            #handle keywords
            case $KEY in
                TITLE|TITLEIDX|TITLEIDXASC)_argsX1="${_argsX1},${KEY}";;
                TUNNEL)_argsX1="${_argsX1},${KEY}";;
                SORT)_argsX1="${_argsX1},${KEY}${ARG:+:$ARG}";;
                PKG)_argsX1="${_argsX1},${KEY}${ARG:+:$ARG}";;
                TERSE|MACHINE|MAXKEY)_argsX1="${_argsX1},${KEY}";;
                NONE|BOTH|ALL)_argsX1="${_argsX1},${KEY}";;
                TCP|IP|DNS|MAC)_argsX1="${_argsX1},${KEY}";;
                JOBID|JID)_argsX1="${_argsX1},${KEY}";;
		ARCH)_argsX1="${_argsX1},${KEY}";;
		EXEP|EXEPATH)_argsX1="${_argsX1},${KEY}";;
		IFNAME)_argsX1="${_argsX1},${KEY}";;
		HYPERRELRUN|HRELRUN|HRELX|HRX)_argsX1="${_argsX1},${KEY}";;
		ACCELERATOR|ACCEL)_argsX1="${_argsX1},${KEY}";;
		CONTEXTSTRG|CSTRG)_argsX1="${_argsX1},${KEY}";;
                ID|PATHNAME|PNAME|P)_argsX1="${_argsX1},${KEY}";;
                UUID|LABEL|TYPE|ST|STYPE|HOST|PM|PID|USER|GROUP)_argsX1="${_argsX1},${KEY}";;
                CLIENT|SERVER|BOTH|CPORT|SPORT|DISPLAY|SITE)_argsX1="${_argsX1},${KEY}";;

                SPEC|SPEC_GEN|XML|XML_GEN|REC|REC_GEN)_argsX1="${_argsX1},${KEY}${ARG:+:$ARG}";;
                TAB_TCP)_argsX1="${_argsX1},${KEY}${ARG:+:$ARG}";;
                TAB|TAB_GEN)_argsX1="${_argsX1},${KEY}${ARG:+:$ARG}";;
                *)
                    ABORT=1;
                    printERR $LINENO $BASH_SOURCE ${ABORT} "Unknown sub-opts for LIST:${KEY}"
                    gotoHell ${ABORT}
                    ;;
            esac
        done

	printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "${FUNCNAME}:_argsX1=${_argsX1}"
        C_MODE_ARGS=${_argsX1#,}
	printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "${FUNCNAME}:C_MODE_ARGS=${C_MODE_ARGS}"
    fi
}

