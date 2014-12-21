#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_10_011
#
########################################################################
#
# Copyright (C) 2007,2008,2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

_myPKGNAME_GENERIC="${BASH_SOURCE}"
_myPKGVERS_GENERIC="01.10.011"
hookInfoAdd "$_myPKGNAME_GENERIC" "$_myPKGVERS_GENERIC"


#FUNCBEG###############################################################
#NAME:
#  print4Printer
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
function print4Printer () {
{
cat <<EOF1














EOF1
printVersion

cat <<EOF

DOC              = User Manual
DOC_STAT         = Draft Pre-Release, 
                   some parts to be accomplished.

EOF
_printHelpEx;
}|pr ${PR_OPTS} -h ${MYCALLNAME}
}




#FUNCBEG###############################################################
#NAME:
#  printPrerequisites
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
function printPrerequisites () {
cat << HEAD1

----------------------------------------------------------------------
OPTIONAL/MANDATORY PREREQUISITES:


HEAD1
    bash --version 2>/dev/null >/dev/null
    if [ $? -eq 0 ]; then
  	printf "%"${_allign}"s%-"${_label}"s:%"$((2*_allign))"s\n" \
          "  " "bash" "`bash --version|sed -n '/bash.* version/p'`"
    else
  	printf "%"${_allign}"s%-"${_label}"s:%"$((2*_allign))"s\n" \
          "  " "bash" "bash is on this machine not available"
    fi
    echo

    ssh -v 2>&1|sed -n '/OpenSSH/p' 2>/dev/null >/dev/null
    if [ $? -eq 0 ]; then
  	printf "%"${_allign}"s%-"${_label}"s:%"$((2*_allign))"s\n" \
          "  " "SSH" "`ssh -v 2>&1|sed -n '/OpenSSH/p'`"
    else
  	printf "%"${_allign}"s%-"${_label}"s:%"$((2*_allign))"s\n" \
          "  " "SSH" "SSH is on this machine not available"
    fi
    echo

    vncviewer --help 2>/dev/null >/dev/null
    if [ -n "`vncviewer --help 2>&1|egrep '(RealVNC)'`" ];then
        local _x1=`vncviewer --help 2>&1|egrep '(VNC Viewer)'|awk -v a=${_allign} '{printf("%s\n",$0);}'`;
  	printf "%"${_allign}"s%-"${_label}"s:%"$((2*_allign))"s\n" "  " "VNC" "$_x1";
    else
  	printf "%"${_allign}"s%-"${_label}"s:%"$((2*_allign))"s\n" \
          "  " "VNC" "vncviewer is on this machine not available"
    fi
    echo
    desktopsSupportCheck
    if [ $? -eq 0 ]; then
  	printf "%"${_allign}"s%-"${_label}"s:%"$((2*_allign))"s\n" \
          "  " "wmctrl" "`${CTYS_WMCTRL} 2>&1|sed -n '/wmctrl *[0-9]/p'`"
    else
  	printf "%"${_allign}"s%-"${_label}"s:%"$((2*_allign))"s\n" \
          "  " "wmctrl" "wmctrl is on this machine not available"
    fi
    echo


    echo
}

#FUNCBEG###############################################################
#NAME:
#  printMemUsage
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
function printMemUsage () {
cat << HEAD1

----------------------------------------------------------------------
CURRENT ARG-MEM-USAGE:


HEAD1
local _allign=2
local _label=2;
    printf "%"${_allign}"s%-"${_label}"s:%-"$((2*_allign))"s" \
      "  " "ArgList(bytes)" "\"env|wc -c\" => "
    env|wc -c
    printf "%"${_allign}"s%-"${_label}"s:%-"$((2*_allign))"s" \
      "  " "ArgList(bytes)" "\"set|wc -c\" => "
    set|wc -c
    echo 
    echo
}


#FUNCBEG###############################################################
#NAME:
#  printSubcalls
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
function printSubcalls () {

    function checkListCalls () {
        local _vers=$1;shift
	local _lel=;
	local _i=0;
	unset _pathMissing;
	for _lel in $@;do
	    gwhich ${_lel} 2>/dev/null >/dev/null 
	    if [ $? -eq 0 ];then
		if [ "$_vers" = 1 ];then
		    printf "  %02d   %-43s%s" $_i ${_lel} "`${_lel} -X -V`"
		else
		    printf "  %02d   %-43s%s" $_i ${_lel} "OK"
		fi

		[ "${C_PRINTINFO}" == 2 ]&&printf " %s" "`gwhich ${_lel}`"
	    else
		local _pathMissing=1;
		printf "  %02d   %-43s%s" $_i ${_lel} "ERROR: missing PATH-entry"
		[ "${C_PRINTINFO}" == 2 ]&&printf " %s" "ERROR: ${_lel} - missing PATH-entry"
	    fi
	    printf "\n"
	    ((_i++));
	done
	if [ -n "${_pathMissing}" ];then
	    echo
	    printf "       %s\n" "ERROR: Check PATH variable for ctys generic helpers!"
	    printf "       Curent PATH value is\n"
	    splitPath 13 "" "$PATH"
	    printf "       %s\n" "Requires:\"PATH=\$PATH:${MYLIBEXECPATH}\""
	    printf "       %s\n" "  or a generic symbolic link collection, e.g. \"PATH=\$PATH:${HOME}/bin\""
	fi
    }

    echo "CTYS-INTERNAL-SUBCALLS:"
    echo
    printf "  %02s   %-43s%s\n" "Nr" "Component"   "Version"
    echo "  ------------------------------------------------------------"
    local _LST=;
    _LST="${_LST} ctys"
    _LST="${_LST} ctys-callVncserver.sh"
    _LST="${_LST} ctys-callVncviewer.sh"
    _LST="${_LST} ctys-createConfVM.sh"
    _LST="${_LST} ctys-distribute.sh"
    _LST="${_LST} ctys-dnsutil.sh"
    _LST="${_LST} ctys-extractARPlst.sh"
    _LST="${_LST} ctys-extractMAClst.sh"
    _LST="${_LST} ctys-genmconf.sh"
    _LST="${_LST} ctys-groups.sh"
    _LST="${_LST} ctys-getMasterPid.sh"
    _LST="${_LST} ctys-getNetInfo.sh"
    _LST="${_LST} ctys-install.sh"
    _LST="${_LST} ctys-install1.sh"
    _LST="${_LST} ctys-macros.sh"
    _LST="${_LST} ctys-macmap.sh"
    _LST="${_LST} ctys-plugins.sh"
    _LST="${_LST} ctys-setupVDE.sh"
    _LST="${_LST} ctys-smbutil.sh"
    _LST="${_LST} ctys-vdbgen.sh"
    _LST="${_LST} ctys-vhost.sh"
    _LST="${_LST} ctys-vping.sh"
    _LST="${_LST} ctys-wakeup.sh"
    _LST="${_LST} ctys-xen-network-bridge.sh"
    checkListCalls 1 $_LST


    echo
    printf "  Helpers:\n"
    echo
    local _LSThelper=;
    _LSThelper="${_LSThelper} getCPUinfo.sh"
    _LSThelper="${_LSThelper} getFSinfo.sh"
    _LSThelper="${_LSThelper} getHDDinfo.sh"
    _LSThelper="${_LSThelper} getHDDtemp.sh"
    _LSThelper="${_LSThelper} getMEMinfo.sh"
    _LSThelper="${_LSThelper} getPerfIDX.sh"
    _LSThelper="${_LSThelper} getVMinfo.sh"
    checkListCalls 1 $_LSThelper

    echo
    printf "  Tiny-Helpers:\n"
    echo
    local _LSThelper=;
    _LSThelper="${_LSThelper} getCurArch.sh"
    _LSThelper="${_LSThelper} getCurCTYSRel.sh"
    _LSThelper="${_LSThelper} getCurDistribution.sh"
    _LSThelper="${_LSThelper} getCurGID.sh"
    _LSThelper="${_LSThelper} getCurOS.sh"
    _LSThelper="${_LSThelper} getCurOSRel.sh"
    _LSThelper="${_LSThelper} getCurRelease.sh"
    _LSThelper="${_LSThelper} getSolarisUUID.sh"
    _LSThelper="${_LSThelper} pathlist.sh"
    checkListCalls 0 $_LSThelper

}




#FUNCBEG###############################################################
#NAME:
#  printLegal
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
function printLegal () {
  if [ -z "$C_TERSE" ];then
      printVersion
      libManInfoList
      echo
      hookInfoList
      echo
      printSubcalls
      echo
      printPrerequisites
      echo
      printMemUsage
  else
      echo -n "$VERSION"
  fi
}



