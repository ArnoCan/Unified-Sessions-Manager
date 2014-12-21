#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_10_013
#
########################################################################
#
# Copyright (C) 2007,2008,2009,2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

_myPKGNAME_GENERIC_ENUMERATE="${BASH_SOURCE}"
_myPKGVERS_GENERIC_ENUMERATE="01.10.013"
hookInfoAdd "$_myPKGNAME_GENERIC_ENUMERATE" "$_myPKGVERS_GENERIC_ENUMERATE"
_myPKGBASE_GENERIC_ENUMERATE="`dirname ${_myPKGNAME_GENERIC_ENUMERATE}`"

_titleENUM=;
_machineENUM=;

#NF of internal record-if
C_ENUMNF=43;
#
#This is the currently processed ENUMERATE configuration, gwhich
#has been detected as valid.
#
#It's value is to be managed by each plugin, though this component 
#is for each configuration the only one beeing able to validate
#a match.
#
#Due to it's cooparative nature somewhat dependent on the reliability
#of the plugins.
#
CURRENTENUM=;

#FUNCBEG###############################################################
#NAME:
#  enumerateMySessions
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Enumerates all VM sessions, therefore each VM type specific interface 
#  will be called. The given list of options by enabler-switches is displayed 
#  in a canonical format by each callee for it's own VMs.
#
#  When selected, the TYPE is added to displayed attributes for information of 
#  caller when using it interactively, or for later processing by internal calls.
#
#  Multiple occurances of values are listed, even though the processing routines 
#  currently use first entry only. For some of the values, sucha as MAC multiple
#  settings might be OK, but for others like UUID NOT!
#
#  Multiple values allowed:        MAC, IP
#  Multiple values NOT allowed:    LABEL, UUID, TYPE, PNAME
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: The full scope of CLI-attributes, if missing will be "prelaced" by C_MODE_ARGS,
#      provided values replace C_MODE_ARGS, particula internal use for:
#        ([MACHINE|ALL|]([LABEL,][UUID,][MAC,][IP,][TYPE,][PNAME,])[TERSE,]<base-dir>
#        MACHINE
#          Display all attributes and forces TERSE.
#        ALL
#          Display all attributes.
#        [LABEL,][UUID,][MAC,][IP,][TYPE,][PNAME,]
#          Display-switches, the given order represents the order of display, 
#          when selected.
#
#          Particularly TYPE is of interest of generic usage of enumeration for
#          addressing GUESTOSs.
#
#        [TERSE,]
#          Output format for postprocessing.
#
#        B:<base-dir>
#          base directory to be used for "find".
#
#GLOBALS:
#  C_TERSE
#    Where <dname> is literally equal to the result of call 
#    "fetchLabel4ID", and <filename/ID> is literally equal to 
#    the result of call "fetchID4Label".
#
#    off   Formatted display-output, format:
#
#          Label       =>  ID/vmx-file  
#          --------------------------------
#          "<dname>    =>  <filename/ID>"
#
#    on    Formatted machine-output, format:
#
#          "<dname>:<filename/ID>"
#
#
#   NOREAD
#     This value should be used for callees, when access to required VM 
#     configurations is not permitted due to UNIX access rights.
#
#       NOREAD="NO-READ-PERMISSION"
#
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#    Enumerate-Output-Format:
#    ========================
#
#    +-----------------------------+
#      0 - h:    host              |
#      1 - t:    type              |
#      2 - l:    label             |
#      3 - i:    id                | Identical to LIST
#      4 - uu:   uuid              |
#      5 - mac:  mac               |
#    +-----------------------------+
#      6 - IP
#      7 - VNCPORT
#      8 - VNCBASE
#      9 - VNCDISPLAY
#     10 - DIST
#     11 - OS
#     12 - VERNO
#     13 - SERNO
#     14 - CATEGORY
#
#
#FUNCEND###############################################################
function enumerateMySessions () {
  local _args=${1:-$DEFAULT_ENUMERATE_CONTENT}
  if [ -z "$_args" ];then
    _args=${C_MODE_ARGS}
  fi

  printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=<${@}>"
  printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:MODE=${C_MODE}"
  printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:MODE_ARGS=${_args}"

  #could be ACTIVATEd on the fly, e.g. VBOX/VMW
  local _mstat='ACTIVE|DISABLED|^$'; #ACTIVE|DISABLED|EMPTY
#  _mstat=;

  local _prologue=0;
  local _epilogue=0;
  local _terse=0;
  local _machine=0;
  local _maxkey=0;
  local _none=0;
  local _all=0;
  local _titlestyle=0;
  local _title=0;
  local _titleidx=0;
  local _VCP=0;
  local _VB=0;
  local _VDSP=0;
  local _L=0;
  local _ID=0;
  local _UU=0;
  local _IP=0;
  local _MAC=0;
  local _T=0;
  local _dist=0;
  local _os=0;
  local _ver=0;
  local _ser=0;
  local _cat=0;

  local _tcp=0;
  local _dns=0;

  local _base=;
  local _tab=;
  local _table=0;
  local _TABARGS=;
  local _sort=0;
  local _sortkey=0;
  local _sortunique=;

  local _vmstate=0;
  local _hyperrel=0;
  local _stackcap=0;
  local _stackreq=0;
  local _arch=0;
  local _platform=0;
  local _vram=0;
  local _vcpu=0;
  local _contextstrg=0;
  local _userstr=0;
  local _sshport=0;
  local _netname=0;



  local hwcap=0;
  local hwreq=0;
  local execloc=0;
  local reloccap=0;
  local ifname=0;
  local ctysrel=0;
  local netmask=0;
  local gateway=0;
  local relay=0;

  local _pkg=0;
  local _pkgargs=;

  local _hrx=0;
  local _acc=0;
  local _exep=0;


  local _reserv1=0;
  local _reserv2=0;
  local _reserv3=0;
  local _reserv4=0;
  local _reserv5=0;
  local _reserv6=0;
  local _reserv7=0;
  local _reserv8=0;
  local _reserv9=0;
  local _reserv10=0;
  local _reserv11=0;
  local _reserv12=0;
  local _reserv13=0;
  local _reserv14=0;
  local _reserv15=0;

  #controls debugging for awk-scripts
  doDebug $S_GEN  ${D_MAINT} $LINENO $BASH_SOURCE
  local D=$?
  local i=;

  function scan4sessions () {
      printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME"
      printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "PACKAGES_KNOWNTYPES=${PACKAGES_KNOWNTYPES}"
      local y=;
      local _ssumtime=`getCurTime`;
      printDBG $S_GEN ${D_FLOW} $LINENO $BASH_SOURCE "${FUNCNAME}:START-machine-${_ssumtime}--"
      for y in ${PACKAGES_KNOWNTYPES};do
	  [ "$y" == "CLI" -o "$y" == "X11" -o "$y" == "VNC" ]&&continue;
	  if [ -n "`typeset -f enumerateMySessions${y}`" ];then
	      printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "C_SESSIONTYPE=${C_SESSIONTYPE} => ${y}"
	      if [ "${C_SESSIONTYPE}" == "${y}" -o "${C_SESSIONTYPE}" == "ALL" -o "${C_SESSIONTYPE}" == "DEFAULT" ];then

		  if [ "${_pkg}" == "1" ];then
		      local _blacklist=1;
		      local _ip=;
		      for _ip in ${_pkgargs//\%/ };do
			  if [ "${y}" == "${_ip}" ];then
			      _blacklist=0;
			      break;
			  fi
		      done
		      if [ "${_blacklist}" == "1" ];then
			  printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "IGNORED:\"${_pkg}\"!=\"${y}\""
			  continue;
		      fi
		  fi
		  local _stime=`getCurTime`;
		  printDBG $S_GEN ${D_FLOW} $LINENO $BASH_SOURCE "${FUNCNAME}:START-${y}-${_stime}--"
		  _matched=1;

		  if [ -n "$_base" ];then
		      SESLST="${SESLST} `enumerateMySessions${y} \"${_base}\"`"
		  else
		      SESLST="${SESLST} `enumerateMySessions${y}`"
		  fi
		  local _ftime=`getCurTime`;
		  local _duration=`getDiffTime $_ftime $_stime`;
		  printDBG $S_GEN ${D_FLOW} $LINENO $BASH_SOURCE "${FUNCNAME}:FINISH-${y}-${_stime}-${_ftime}-${_duration}"
	      fi
	  else
	      local _ftime=`getCurTime`;
	      local _duration=`getDiffTime $_ftime $_stime`;
	      printDBG $S_GEN ${D_FLOW} $LINENO $BASH_SOURCE "${FUNCNAME}:FINISH-${y}-${_stime}-${_ftime}-IGNORED"
	  fi
      done
      local _fsumtime=`getCurTime`;
      local _sumduration=`getDiffTime $_fsumtime $_ssumtime`;
      printDBG $S_GEN ${D_FLOW} $LINENO $BASH_SOURCE "${FUNCNAME}:FINISH-machine-${_ssumtime}-${_fsumtime}-${_sumduration}"

      if((_matched==0));then
	  ABORT=2
	  printERR $LINENO $BASH_SOURCE ${ABORT} "System Error, unexpected C_SESSIONTYPE=${C_SESSIONTYPE}"
	  printERR $LINENO $BASH_SOURCE ${ABORT} "  PACKAGES_KNOWNTYPES=${PACKAGES_KNOWNTYPES}"

	  gotoHell ${ABORT}
      fi
      printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:SESLST=${SESLST}"
  }


  function applySort () {
      if [ "$_sort" == 1 ];then
	  if [ "$_sortkey" != "0" ];then
	    [ "$_table" -eq 1 ]\
              &&sort -t '|' ${_sortunique:+-u} -k ${_sortkey}\
              ||sort -t ';' ${_sortunique:+-u} -k ${_sortkey};
	  else
	      sort ${_sortunique:+-u} 
	  fi
      else
	  cat
      fi
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

      awk -F';' -v vb="$_VB" -v ip="$_IP" -v dist="$_dist" -v os="$_os" -v ver="$_ver" -v ser="$_ser" \
	  -v reserv1="$_reserv1" -v reserv2="$_reserv2"   -v reserv3="$_reserv3" -v reserv4="$_reserv4" \
	  -v reserv5="$_reserv5" -v reserv6="$_reserv6"   -v reserv7="$_reserv7" -v reserv8="$_reserv8" \
	  -v reserv9="$_reserv9" -v reserv10="$_reserv10" -v reserv11="$_reserv11" -v reserv12="$_reserv12" \
	  -v acc="$_acc" -v hrx="$_hrx" -v exep="$_exep" \
	  -v vmstate="$_vmstate" -v hyperrel="$_hyperrel" -v stackcap="$_stackcap" -v stackreq="$_stackreq" \
          -v arch="$_arch" -v platform="$_platform" -v vram="$_vram" -v vcpu="$_vcpu"  \
          -v contextstrg="$_contextstrg" -v userstr="$_userstr"  -v sshport="$_sshport" \
          -v hwcap="$_hwcap" -v hwreq="$_hwreq" -v execloc="$_execloc" -v reloccap="$_reloccap" \
          -v netname="$_netname" -v ifname="$_ifname" -v ctysrel="$_ctysrel" -v netmask="$_netmask" \
          -v gateway="$_gateway" -v relay="$_relay" \
          -v distrel="$_distrel" -v osrel="$_osrel" -v sport="$_SPORT" \
          -v cat="$_cat" -v l=$_L -v i=$_ID -v t=$_T -v uu=$_UU  \
	  -v mac=$_MAC  -v dsp=$_VDSP -v cp=$_VCP  \
	  -v h=$MYHOST -v tcp=$_tcp -v dns=$_dns \
	  -v enumnf=$C_ENUMNF \
	  -v d=$D  -v dargs="${C_DARGS}" -v callp="${MYLIBEXECPATH}/" \
	  -v cols="$_TABARGS"  \
	  -v mstat="${_mstat}" \
	  \
	  -f ${2} \
          \
	  -v title=${t} -v titleidx=${tx}
  }


  printDBG $S_CLI ${D_UID} $LINENO $BASH_SOURCE "_args=$_args"
  _args=`cliSplitSubOpts ${_args}`;
  for i in ${_args};do
      KEY=`cliGetKey ${i}`
      ARG=`cliGetArg ${i}`
      case $KEY in
	  PROLOGUE)         _prologue=1;;
	  EPILOGUE)         _epilogue=1;;

	  VMSTATE|VSTAT)    _vmstate=1;;
	  HYPERREL|HYREL)   _hyperrel=1;;
	  STACKCAP|SCAP)    _stackcap=1;;
	  STACKREQ|SREQ)    _stackreq=1;;

	  ARCH)             _arch=1;;
	  PLATFORM|PFORM)   _platform=1;;
	  VRAM)             _vram=1;;
	  VCPU)             _vcpu=1;;
	  CONTEXTSTRING|CSTRG) _contextstrg=1;;
	  USERSTRING|USTRG) _userstr=1;;
	  SSHPORT)          _sshport=1;;

          HWCAP)            _hwcap=1;;
          HWREQ)            _hwreq=1;;
          EXECLOCATION)     _execloc=1;;
          RELOCCAP)         _reloccap=1;;
          NETNAME)          _netname=1;;
          IFNAME)           _ifname=1;;
          CTYSRELEASE)      _ctysrel=1;;
          NETMASK)          _netmask=1;;
          GATEWAY)          _gateway=1;;
          RELAY)            _relay=1;;


	  TERSE)            _terse=1;;
	  MACHINE)          _machine=1;;
	  MAXKEY)           _maxkey=1;;
	  NONE)             _none=0;;
	  ALL)              _all=1;;

	  TITLE)            _title=1;;
	  TITLEIDXASC)      _titleidx=2;;
	  TITLEIDX)         _titleidx=1;;

	  SERVERACCESS|SPORT|S)  _SPORT=1;;
	  VNCPORT|CPORT)    _VCP=1;;
	  VNCBASE)          _VB=1;;
	  DISP|VNCDISPLAY)  _VDSP=1;;

	  LABEL|L)          _L=1;;
	  IDS|ID)           _ID=1;;
	  UUID|U)           _UU=1;;
 	  MAC|M)            _MAC=1;;
	  TYPE|STYPE|ST)    _T=1;;

 	  IP)               _IP=1;;
          TCP|T)            _tcp=1;;
          DNS|D)            _dns=2;;

          DIST)             _dist=1;;
          DISTREL)          _distrel=1;;
          OS|O)             _os=1;;
          OSREL)            _osrel=1;;
          VERSION|VERNO|VER)_ver=1;;
          SERIALNUMBER|SERNO)_ser=1;;
          CATEGORY|CAT)      _cat=1;;

          EXEPATH)           _exep=1;;
          ACCELLERATOR)      _acc=1;;
          HYPERRELRUN|HRELRUN|HRELX|HRX)
                             _hrx=1;;


          B|BASE|BASEPATH) 
                            _base="${ARG}"
	                    printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_base=${_base}"
                            ;;

	  MATCHVSTAT)        
		       _mstat=;
		       local i1=;
		       for i1 in ${ARG//\%/ };do
			   case ${i1} in
			       [cC][uU][sS][tT][oO][mM])
				   _custom=1;
				   ;;
			       [pP][rR][eE][sS][eE][nN][tT])
				   _mstat=".";
				   break;
				   ;;
			       [aA][lL][lL])
				   _mstat=".|^$";
				   break;
				   ;;
			       [eE][mM][pP][tT][yY])
				   _mstat="${_mstat}|^$";
				   ;;
			       [aA][cC][tT][iI][vV][eE])
				   _mstat="${_mstat}|ACTIVE";
				   ;;
			       [dD][iI][sS][aA][bB][lL][eE][dD])
				   _mstat="${_mstat}|DISABLED";
				   ;;
			       [tT][eE][mM][pP][lL][aA][tT][eE])
				   _mstat="${_mstat}|TEMPLATE";
				   ;;
			       [bB][aA][cC][kK][uU][pP])
				   _mstat="${_mstat}|BACKUP";
				   ;;

			       [tT][eE][sS][tT][dD][uU][mM][mM][yY])
				   _mstat="${_mstat}|TESTDUMMY";
				   ;;

			       *)
				   if [ -z "$_custom" ];then
				       ABORT=2
				       printERR $LINENO $BASH_SOURCE ${ABORT} "Unexpected MATCHVSTAT key:${i1}"
				       printERR $LINENO $BASH_SOURCE ${ABORT} "If used intentionally, set CUSTOM on the left"
				       printERR $LINENO $BASH_SOURCE ${ABORT} " \"...MATCHVSTAT:CUSTOM%${i1}..."
				       gotoHell ${ABORT}
				   else
				       local _upcase="`echo ${i1}|tr '[:lower:]' '[:upper:]'`";
				       _mstat="${_mstat}|${_upcase}";
				   fi
				   ;;
			   esac
		       done
		       _mstat="${_mstat#|}";
	               printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_mstat=${_mstat}"
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
                       _sortunique=;
		       local i1=;
		       for i1 in ${ARG//,/ };do
			   case ${i1} in
			       [aA][lL][lL])#will be sorted in the topmost schedular once, does not require sub-sorts
				   _sort=1;
				   if [ -n "${CTYS_SUBCALL}" ];then
				       _sort=0;
				   fi
				   ;;
			       [eE][aA][cC][hH])
				   _sort=0;
				   if [ -n "${CTYS_SUBCALL}" ];then
				       _sort=1;
				   fi
				   ;;
			       [uU][nN][iI][qQ][uU][eE])
                                   _sortunique=1;
				   ;;
			       [0-9][0-9][0-9]|[0-9][0-9]|[0-9])
				   _sortkey=${i1};
				   ;;
			       *)
				   ABORT=2
				   printERR $LINENO $BASH_SOURCE ${ABORT} "Unexpected sort suboption:${ARG}"
				   gotoHell ${ABORT}
				   ;;
			   esac
		       done
		       ;;

	  TAB_GEN)    _table=1;_tab=TAB_GEN;_title=1;_machine=1;
   	              _TABARGS=${ARG}
	              ;;

	  SPEC_GEN|SPEC)
                      _table=1;_tab=SPEC_GEN;_machine=1;
   	              _TABARGS=${ARG}
	              ;;
	  REC_GEN|REC)
                      _table=1;_tab=REC_GEN;_machine=1;
   	              _TABARGS=${ARG}
	              ;;
	  XML_GEN|XML)
                      _table=1;_tab=XML_GEN;_machine=1;
   	              _TABARGS=${ARG}
	              ;;
      esac
  done


  if [ "$_prologue" -eq 1 -a  -n "$_tab" -a "$_sort" -eq 1 ];then
      if [ "${_TABARGS//_B/}" != "${_TABARGS}" ];then
	  ABORT=1;
	  printDBG $S_GEN ${D_DATA} $LINENO $BASH_SOURCE "The combination of SORT and table entries with \"B\"-clipping/break"
	  printDBG $S_GEN ${D_DATA} $LINENO $BASH_SOURCE "option is erroneous in this version in the case that a break within"
	  printDBG $S_GEN ${D_DATA} $LINENO $BASH_SOURCE "a field actually occurs."
	  printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "The combination of SORT and table entries with \"B\"-clipping/break"
	  printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "option is erroneous in this version in the case that a break within"
	  printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "a field actually occurs."
      fi 
  fi


  if((_epilogue+_prologue>1));then
      ABORT=1
      printERR $LINENO $BASH_SOURCE ${ABORT} "Internal error, use EXOR: PROLOGUE|EPILOGUE"
      gotoHell ${ABORT}
  fi


  if((_all==1));then
      _SPORT=1;
      _VCP=1;
      _VB=1;
      _VDSP=1;
      _L=1;
      _ID=1;
      _UU=1;
      _IP=1;
      _MAC=1;
      _T=1;
      _dist=1;
      _distrel=1;
      _os=1;
      _osrel=1;
      _ver=1;
      _ser=1;
      _cat=1;
      _vmstate=1;
      _hyperrel=1;
      _stackcap=1;
      _stackreq=1;
      _arch=1;
      _platform=1;
      _vram=1;
      _vcpu=1;
      _contextstrg=1;
      _userstr=1;
      _sshport=1;
      _hwcap=1;
      _hwreq=1;
      _execloc=1;
      _reloccap=1;
      _netname=1;
      _ifname=1;
      _ctysrel=1;
      _netmask=1;
      _gateway=1;
      _relay=1;
      _exep=1;
      _hrx=1;
      _acc=1;
  fi

  if((_none==1));then
      _SPORT=0;
      _VCP=0;
      _VB=0;
      _VDSP=0;
      _L=0;
      _ID=0;
      _UU=0;
      _IP=0;
      _MAC=0;
      _T=0;
      _dist=0;
      _distrel=0;
      _os=0;
      _osrel=0;
      _ver=0;
      _ser=0;
      _cat=0;
      _vmstate=0;
      _hyperrel=0;
      _stackcap=0;
      _stackreq=0;
      _arch=0;
      _platform=0;
      _vram=0;
      _vcpu=0;
      _contextstrg=0;
      _userstr=0;
      _sshport=0;
      _hwcap=0;
      _hwreq=0;
      _execloc=0;
      _reloccap=0;
      _netname=0;
      _ifname=0;
      _ctysrel=0;
      _netmask=0;
      _gateway=0;
      _relay=0;
      _exep=0;
      _hrx=0;
      _acc=0;
  fi

  if((_maxkey==1));then
      #don't touch this
      _terse=1;_F=1;
      _H=1;_T=1;_L=1;_ID=1;_UU=1;_MAC=1;
      _tcp=0;

      _VCP=0; _VB=0; _VDSP=0; _IP=0; _dist=0; _os=0; _ver=0; _ser=0; _cat=0;
  fi

  if((_machine==1));then
      _H=1;_L=1;_T=1;
      let _ID++;
      let _UU++;
      let _MAC++;
      let _tcp++;
      _terse=1;

      _SPORT=1; _VCP=1; _VB=1; _VDSP=1; _IP=1; 
      _dist=1; _distrel=1; _osrel=1; _os=1; _ver=1; _ser=1; _cat=1;
      _vmstate=1; _hyperrel=1; _stackcap=1; _stackreq=1; _arch=1;
      _platform=1; _vram=1; _vcpu=1; _contextstrg=1; _userstr=1;
      _sshport=1; _hwcap=1; _hwreq=1; _execloc=1; _reloccap=1;
      _netname=1; _ifname=1; _ctysrel=1; _netmask=1; _gateway=1;
      _relay=1; _exep=1; _hrx=1; _acc=1;

      _reserv1=1; _reserv2=1; _reserv3=1; _reserv4=1; _reserv5=1; _reserv6=1; 
      _reserv7=1; _reserv8=1; _reserv9=1; _reserv10=1; _reserv11=1; 
      _reserv12=1; _reserv13=1; _reserv14=1; _reserv15=1; 
  fi

  #set content default
  if((_SPORT+_VCP+_VB+_VDSP+_L+_ID+_UU+_MAC+_T+_dist+_distrel+_os+_osrel+_ver+_ser+_cat+_IP+_vmstate+_hyperrel+_stackcap+_stackreq+_arch+_platform+_vram+_vcpu+_contextstrg+_userstr+_sshport+hwcap+hwreq+execloc+reloccap+netname+ifname+ctysrel+netmask+gateway+relay+_exep+_acc+_hrx));then
      printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "Force of ID"
      _ID=1;
  fi



  printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "_VCP=$_VCP _VB=$_VB _VDSP=$_VDSP _L=$_L _ID=$_ID _UU=$_UU _IP=$_IP "
  printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "_MAC=$_MAC _T=$_T _dist=$_dist _os=$_os _ver=$_ver "
  printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "_SPORT=$_SPORT _distrel=$_distrel _osrel=$_osrel  "
  printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "_ser=$_ser _cat=$_cat "

  printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "vmstate=$_vmstate hyperrel=$_hyperrel stackcap=$_stackcap"
  printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "stackreq=$_stackreq arch=$_arch platform=$_platform"
  printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "vram=$_vram vcpu=$_vcpu contextstrg=$_contextstrg"
  printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "userstr=$_userstr sshport=$_sshport"
  printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "hwcap=$_hwcap hwreq=$_hwreq execloc=$_execloc"
  printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "reloccap=$_reloccap netname=$_netname ifname=$_ifname"
  printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "ctysrel=$_ctysrel netmask=$_netmask gateway=$_gateway"
  printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "relay=$_relay _exep=$_exep _acc=$_acc _hrx=$_hrx"
  printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "mstat=$_mstat"


  printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "C_SESSIONTYPE=${C_SESSIONTYPE}"
  local SESLST=

  printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "C_CACHEDOP       = ${C_CACHEDOP}"
  printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "C_CACHEONLY      = ${C_CACHEONLY}"
  printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "CALLERCACHE      = ${CALLERCACHE}"
  printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "CALLERCACHEREUSE = ${CALLERCACHEREUSE}"
  printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "C_CACHEAUTO      = ${C_CACHEAUTO}"
  printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "_prologue        = ${_prologue}"
  printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "_epilogue        = ${_epilogue}"
  if [ "${_prologue}" == 1 ];then
      #header only, title-style-single-shot
      case $_tab in
	  TAB_GEN)echo -e ""|applyFilter 1 "${MYLIBPATH}/lib/tab_gen/tab_gen.awk";;
	  SPEC_GEN);;
	  REC_GEN);;
	  XML_GEN);;
	  *)      echo -e ""|applyFilter 1 "${_myPKGBASE_GENERIC_ENUMERATE}/canonize.awk";;
      esac
  else
      local _matched=0;


      if [ "$_epilogue" == 0 ];then
	  if [ "$C_CACHEDOP" == 0  ];then
	      printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "CACHE:NON-CACHED-OP"
	      scan4sessions
	      printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "CACHE:SESLST=${SESLST}"
	  else
	      if [ "$C_CACHEONLY" == 0  ];then
		  printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "CACHE:NON-CACHED-OP"
		  scan4sessions
		  printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "CACHE:SESLST=${SESLST}"
	      else
		  if [ ! -f "${CALLERCACHEREUSE}" -a "$C_CACHEAUTO" == 1 ];then
		      printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "CACHE:AUTO:build:${CALLERCACHE}"
		      scan4sessions
		      printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "CACHE:SESLST=${SESLST}"
		      for  i in ${SESLST};do
			  echo -e $i>>"${CALLERCACHEREUSE}"
		      done
		  fi
	      fi
	  fi
      fi
      _site=${_site:+1}
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
		  if [ "$C_CACHEDOP" == 1 -a "$C_CACHEONLY" == 1 -a -s "${CALLERCACHEREUSE}" -a "$C_CACHEPROCESSED" != 1 ];then
                      #provided cache from any previous run
		      printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "CACHE:READOUT:CALLERCACHEREUSE=${CALLERCACHEREUSE}"
		      cat ${CALLERCACHEREUSE}
		  else
                      #runs on fresh data within memory or requires build of cache
		      printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "USE SESLST=<${SESLST}>"
		      for i in ${SESLST};do
			  printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "CURSES=${i}"
			  if [ "${_terse}" == 0 ];then
			      echo -n -e "+->";
			  fi

			  if [ "$C_CACHERAW" == 1 ];then
			      echo -e "${i}"
			  else
			      case $_tab in
				  SPEC_GEN|REC_GEN|XML_GEN)
				      echo -e "${i}"|applyFilter 1 "${_myPKGBASE_GENERIC_ENUMERATE}/canonrec.awk"
				      ;;
				  *)
				      echo -e "${i}"|applyFilter 0 "${_myPKGBASE_GENERIC_ENUMERATE}/canonize.awk"
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
                      #write in case of cached operations first all as machine into caller's local cache
		      applySort
		  else
		      printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "CACHE:WRITE"
		      case $_tab in
			  TAB_GEN)
			      if [ "$C_CACHERAW" == 1 ];then
				  applyFilter 0 "${_myPKGBASE_GENERIC_ENUMERATE}/canonize.awk"|\
                                  applyFilter 0 "${MYLIBPATH}/lib/tab_gen/tab_gen.awk"|\
                                  applySort
 			      else
				  applyFilter 0 "${MYLIBPATH}/lib/tab_gen/tab_gen.awk"|applySort
			      fi
			      ;;
			  SPEC_GEN)
			      if [ "$C_CACHERAW" == 1 ];then
				  applyFilter 1 "${_myPKGBASE_GENERIC_ENUMERATE}/canonrec.awk"|\
                                  applyFilter 1 "${MYLIBPATH}/lib/tab_gen/spec_gen.awk"|\
                                  applySort
 			      else
				  applyFilter 0 "${MYLIBPATH}/lib/tab_gen/spec_gen.awk"|applySort
			      fi
			      ;;
			  REC_GEN)
			      if [ "$C_CACHERAW" == 1 ];then
				  applyFilter 1 "${_myPKGBASE_GENERIC_ENUMERATE}/canonrec.awk"|\
                                  applyFilter 1 "${MYLIBPATH}/lib/tab_gen/rec_gen.awk"|\
                                  applySort
 			      else
				  applyFilter 0 "${MYLIBPATH}/lib/tab_gen/rec_gen.awk"|applySort
			      fi
			      ;;
			  XML_GEN)
			      if [ "$C_CACHERAW" == 1 ];then
				  applyFilter 1 "${_myPKGBASE_GENERIC_ENUMERATE}/canonrec.awk"|\
                                  applyFilter 1 "${MYLIBPATH}/lib/tab_gen/xml_gen.awk"|\
                                  applySort
 			      else
				  applyFilter 0 "${MYLIBPATH}/lib/tab_gen/xml_gen.awk"|applySort
			      fi
			      ;;
 			  *)
			      if [ "$C_CACHERAW" == 1 ];then
				  applyFilter 0 "${_myPKGBASE_GENERIC_ENUMERATE}/canonize.awk"|applySort
			      else
				  applySort
			      fi
			      ;;
		      esac
		  fi
	      fi
	  }
      fi
  fi
  C_CACHEPROCESSED=1;
  printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME"
}



#FUNCBEG###############################################################
#NAME:
#  enumerateCheckParam
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
function enumerateCheckParam () {
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

	    printDBG $S_GEN ${D_FRAME} $LINENO $BASH_SOURCE "KEY=${KEY}"
	    printDBG $S_GEN ${D_FRAME} $LINENO $BASH_SOURCE "ARG=<${ARG}>"
            #handle keywords
            case $KEY in
		PROLOGUE|EPILOGUE)_argsX1="${_argsX1},${KEY}";;

                TITLE|TITLEIDXASC|TITLEIDX)_argsX1="${_argsX1},${KEY}";;
                TERSE|MACHINE|MAXKEY)_argsX1="${_argsX1},${KEY}";;
                SERVERACCESS|SPORT|S|VNCDISPLAY|DISP|VNCBASE|VNCPORT|CPORT)_argsX1="${_argsX1},${KEY}";;
                ALL)_argsX1="${_argsX1},${KEY}";;
		NONE)_argsX1="${_argsX1},${KEY}";;

                LABEL|L|IDS|ID|PNAME|UUID|U|MAC|M)_argsX1="${_argsX1},${KEY}";;
                IP|TCP|T|DNS|D)_argsX1="${_argsX1},${KEY}";;

                DIST|DISTREL|OS|O|OSREL|VERNO|VER|VERNO|SERIALNUMBER|SERNO|CATEGORY|CAT)_argsX1="${_argsX1},${KEY}";;

		VMSTATE|VSTAT|HYPERREL|HYREL|STACKCAP|SCAP|STACKREQ|SREQ)_argsX1="${_argsX1},${KEY}";;
		ARCH|PLATFORM|PFORM|VRAM|VCPU)_argsX1="${_argsX1},${KEY}";;
		CONTEXTSTRING|CSTRG|USERSTRING|USTRG)_argsX1="${_argsX1},${KEY}";;

                TYPE|STYPE|ST)_argsX1="${_argsX1},${KEY}";;
                EXEPATH)_exep="${_argsX1},${KEY}";;
		ACCELLERATOR)_acc="${_argsX1},${KEY}";;
		HYPERRELRUN|HRELRUN|HRELX|HRX)_hrx="${_argsX1},${KEY}";;

		HWCAP|HWREQ|EXECLOCATION|RELOCCAP)_argsX1="${_argsX1},${KEY}";;
		SSHPORT|NETNAME|IFNAME|CTYSRELEASE|NETMASK|GATEWAY|RELAY)_argsX1="${_argsX1},${KEY}";;

                B|BASE|BASEPATH)_argsX1="${_argsX1},BASEPATH${ARG:+:$ARG}";;
                SORT)_argsX1="${_argsX1},${KEY}${ARG:+:$ARG}";;
                MATCHVSTAT)_argsX1="${_argsX1},${KEY}${ARG:+:$ARG}";;

                PKG)_argsX1="${_argsX1},${KEY}${ARG:+:$ARG}";;
                TAB_GEN)_argsX1="${_argsX1},${KEY}${ARG:+:$ARG}";;


                SPEC_GEN|SPEC)_argsX1="${_argsX1},${KEY}${ARG:+:$ARG}";;
                REC_GEN|REC)_argsX1="${_argsX1},${KEY}${ARG:+:$ARG}";;
                XML_GEN|XML)_argsX1="${_argsX1},${KEY}${ARG:+:$ARG}";;

                *)
                    ABORT=1;
                    printERR $LINENO $BASH_SOURCE ${ABORT} "Unknown sub-opts for ENUMERATE=<${KEY}>"
                    gotoHell ${ABORT}
                    ;;
            esac
        done

	printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "${FUNCNAME}:_argsX1=${_argsX1}"
        C_MODE_ARGS=${_argsX1#,}
	printDBG $S_GEN ${D_BULK} $LINENO $BASH_SOURCE "${FUNCNAME}:C_MODE_ARGS=${C_MODE_ARGS}"
    fi
}

