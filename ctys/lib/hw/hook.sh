#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@users.sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_06_001a09
#
########################################################################
#
# Copyright (C) 2008 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

_myLIBNAME_HW="${BASH_SOURCE}"
_myLIBVERS_HW="01.01.001a01"
libManInfoAdd "$_myLIBNAME_HW" "$_myLIBVERS_HW"

_myLIBNAME_BASE_HW="`dirname ${_myLIBNAME_HW}`"

_MYHWCAP=;

case ${MYOS} in
    Linux)
	. ${_myLIBNAME_BASE_HW}/hw-${MYOS}.sh
	;;
    FreeBSD|OpenBSD)
	. ${_myLIBNAME_BASE_HW}/hw-${MYOS}.sh
	;;
    SunOS)
	. ${_myLIBNAME_BASE_HW}/hw-${MYOS}.sh
	;;
    *)
        printINFO 1 $LINENO $BASH_SOURCE 1 "${MYCALLNAME} is not supported on ${MYOS}"
        printINFO 1 $LINENO $BASH_SOURCE 1 "Load dummies."
	. ${_myLIBNAME_BASE_HW}/hw.dummies.sh
	;;
esac




#FUNCBEG###############################################################
#NAME:
#  getHWCAP
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#
#PARAMETERS:
#
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getHWCAP () {
    local _hwcap=;
    local _buf=;
    _buf="`getCPUinfo`";[ -n "${_buf}" ]&&_hwcap="${_buf}";
    _buf="`getMEMinfo`";[ -n "${_buf}" ]&&_hwcap="${_hwcap},${_buf}";
    _buf="`getHDDinfo`";[ -n "${_buf}" ]&&_hwcap="${_hwcap},${_buf}";
    _buf="`getFSinfo`";[ -n "${_buf}" ]&&_hwcap="${_hwcap},${_buf}";

    printDBG $S_LIB ${D_UID} $LINENO $BASH_SOURCE "HWCAP=${_hwcap}"
    echo -n "${_hwcap}"
    return
}



#FUNCBEG###############################################################
#NAME:
#  getPLATFORM
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Currently experimental.
#
#PARAMETERS:
#
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getPLATFORM () {
    local _hwcap=;
    local _buf=;

    _buf="`getPLATFORMinfo`";[ -n "${_buf}" ]&&_hwcap="${_buf}";

    printDBG $S_LIB ${D_UID} $LINENO $BASH_SOURCE "PLATFORM=${_hwcap}"
    echo -n "${_hwcap}"
    return
}
