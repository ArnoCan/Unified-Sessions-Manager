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

_myPKGNAME_COREHELP="${BASH_SOURCE}"
_myPKGVERS_COREHELP="01.02.002c01"
hookInfoAdd "$_myPKGNAME_COREHELP" "$_myPKGVERS_COREHELP"


#FUNCBEG###############################################################
#NAME:
#  printHelp
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
function printHelp () {

    return
}


#FUNCBEG###############################################################
#NAME:
#  _printHelpEx
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
function _printHelpEx () {
  local i=;
  [ -n "${MYHELPPATH}" ]&&for i in ${MYHELPPATH}/[0][0123456789]*[^~];do
      [ -n "$i" -a -f "$i" ]&&cat ${i};
  done
}
