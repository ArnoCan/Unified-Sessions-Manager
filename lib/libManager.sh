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

_myLIBNAME_libManager="${BASH_SOURCE}"
_myLIBVERS_libManager="01.02.002c01"

#The only comprimese for bootstrap, calling it explicit 
#from anywhere. 
function libManagerRegisterLib () {
  libManInfoAdd "${_myLIBNAME_libManager}" "${_myLIBVERS_libManager}"
}


#actually loaded core project specific basic extensions
declare -a LIBMAN_NAME
declare -a LIBMAN_VERS


#FUNCBEG###############################################################
#NAME:
#  libManInfoAdd
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Adds an entry to info array, where all libraries will be registered
#  with basic information, which is for now:
#
#  <pkg-name> <pkg-version>
#
#EXAMPLE:
#
#PARAMETERS:
# <pkg-name> 
# <pkg-version>
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function libManInfoAdd () {
  local _s=${#LIBMAN_NAME[@]}

  if [ -n "$1" ];then
    LIBMAN_NAME[$_s]="${1##/*/}"
  fi
  if [ -n "$2" ];then
    LIBMAN_VERS[$_s]="$2"
  fi
}


#FUNCBEG###############################################################
#NAME:
#  libManInfoList
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Lists all entries from LIBMAN.
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
function libManInfoList () {
    local _s=${#LIBMAN_NAME[@]}

    echo "LIBRARIES(static-loaded - generic):"
    echo
    printf "  %02s   %-43s%s\n" "Nr" "Library" "Version"
    echo "  ------------------------------------------------------------"
    for((i=0;i<_s;i++));do
	printf "  %02d   %-43s%s\n" $i ${LIBMAN_NAME[$i]} ${LIBMAN_VERS[$i]}
    done
    echo
}




