#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@users.sourceforge.net
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

_myPKGNAME_COMMON="${BASH_SOURCE}"
_myPKGVERS_COMMON="01.02.002c01"
hookInfoAdd "$_myPKGNAME_COMMON" "$_myPKGVERS_COMMON"



#FUNCBEG###############################################################
#NAME:
#  setVersion
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Sets the current release of installed ctys.
#
#
#EXAMPLE:
#
#GLOBALS:
#
export CTYSREL;
#
# VERSGEN:
#   Filepathname containing the version information of installed ctys.
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
function setVersion () {
  local _curinst=`cat ${VERSGEN}|sed -n 's/^CTYSREL="\([^"][^"]*\)"/\1/p'`

  if [ -z "${CTYSREL}" ];then
    ABORT=1;
    printERR $LINENO $BASH_SOURCE ${ABORT} "Cannot installed version information."
    printERR $LINENO $BASH_SOURCE ${ABORT} "Check your installation."
    printERR $LINENO $BASH_SOURCE ${ABORT} "Failed:"
    printERR $LINENO $BASH_SOURCE ${ABORT} " =>\"${VERSGEN}\""

    gotoHell ${ABORT}
  fi
  return 0
}

#FUNCBEG###############################################################
#NAME:
#  checkVersion
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Checks the first 9 characters by default for literal match:
#
#
#    AA_BB_CCC([abc]DD)
#
#  The postfix is ignored, implying compatibility.
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
function checkVersion () {
  local _curAction=$2

  if [ "${1%???}" != "${CTYSREL%???}" ];then
    ABORT=1;
    printERR $LINENO $BASH_SOURCE ${ABORT} "Remote and local versions seems to be incompatible"
    printERR $LINENO $BASH_SOURCE ${ABORT} "  Requested L_VERS         = ${L_VERS}"
    printERR $LINENO $BASH_SOURCE ${ABORT} "  Actual    CTYSREL        = ${CTYSREL}"
    printERR $LINENO $BASH_SOURCE ${ABORT} "  Called    MYLIBEXECPATHNAME = ${MYLIBEXECPATHNAME}"

    gotoHell ${ABORT}
  fi
  return 0
}




#FUNCBEG###############################################################
#NAME:
#  connectCheckParam
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
function connectCheckParam (){
    if [ -z "$C_MODE_ARGS" ];then
        ABORT=1
        printERR $LINENO $BASH_SOURCE ${ABORT} "Missing target to connect, try \"-a LIST\" for available targets."
        gotoHell ${ABORT} 
    fi
}





#FUNCBEG###############################################################
#NAME:
#  setStatusColor
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Encapsulates the input-string with appropriate escape sequences for
#  colored output. Therefore it is checked whether XTERM is set, and 
#  only than proceeded.
#
#  Operates on STATEs rather than explicitly defined colors. 
#
#  REMARK:
#    Due to performance reasons for parts of common trace-output the 
#    values are hardcoded within the whole module.
#  
#EXAMPLE:
#
#PARAMETERS:
#  $1: long:  IGNORED|AVAILABLE|DISABLED|ENABLED|IDLE|BUSY
#      short: IGN|AVA|DIS|ENA|IDL|BUS
#
#      IGN: IGNORED(-)    magenta(35)
#      AVA: AVAILABLE(0)  lightblue(36)
#      DIS: DISABLED(1)   red(31)
#      ENA: ENABLED(2)    green(32)
#      IDL: IDLE(3)       blue(34)
#      BUS: BUSY(4)       orange(33)
#
#
#  $2-*
#OUTPUT:
#  RETURN:
#    0: OK
#    1: NOK
#  VALUES:
#    "<esc-color>$2-*<esc-color-reset>"
#
#FUNCEND###############################################################
function setStatusColor () {
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:<$@>"
    local col=$1;shift
    [ "$CTYS_XTERM" != 0 ]&&echo -n -e "$*"||\
    case $col in
	IGN|IGNORED)  echo -n -e "\033[35m${*}\033[m";;
	AVA|AVAILABLE)echo -n -e "\033[36m${*}\033[m";;
	DIS|DISABLED) echo -n -e "\033[31m${*}\033[m";;
	ENA|ENABLED)  echo -n -e "\033[32m${*}\033[m";;
	IDL|IDLE)     echo -n -e "\033[34m${*}\033[m";;
	BUS|BUSY)     echo -n -e "\033[33m${*}\033[m";;
	*)            echo -n -e "$*";;
    esac
}

