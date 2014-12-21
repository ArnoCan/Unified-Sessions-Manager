#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@users.sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_011
#
########################################################################
#
# Copyright (C) 2007,2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

_myPKGNAME_CLI_SESSION="${BASH_SOURCE}"
_myPKGVERS_CLI_SESSION="01.11.011"
hookInfoAdd $_myPKGNAME_CLI_SESSION $_myPKGVERS_CLI_SESSION
_myPKGBASE_CLI_SESSION="`dirname ${_myPKGNAME_CLI_SESSION}`"



#FUNCBEG###############################################################
#NAME:
#  startSessionCLI
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1:  <label>
#  $2:  <mytask> <callopts>
#  $3:  <xopts>
#  $4:  <chdir>
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function startSessionCLI () {
    printDBG $S_CLI ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=$@"
    printDBG $S_CLI ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:\$1=$1"
    printDBG $S_CLI ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:\$2=$2"
    printDBG $S_CLI ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:\$3=$3"
    printDBG $S_CLI ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:\$4=$4"
    printDBG $S_CLI ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:\$5=$5"
    local _label=${1:-DEFAULT-$DATETIME};shift
    checkUniqueness4Label ${_label};
    if [ $? -eq 0 ];then
	local _unique=1
    else
	if [ -z "${C_ALLOWAMBIGIOUS}" ];then
	    ABORT=2
	    printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Ambigious <session-label>:${_label}"
	    gotoHell ${ABORT}
	else 
	    printWNG 1 $LINENO $BASH_SOURCE ${RET} "${FUNCNAME}:Label is ambigious:${_label}"
	fi
    fi

    #can do this for stub call later.
    if [ -z "${C_STUBCALL}" ];then
	_label2="${USER}@${MYHOST}:${_label}"
	case "${1%% *}" in 
            bash*)
		if [ "$CTYS_XTERM" == 0 ];then
		    echo -ne "\033]2;${_label2}\007\033]1;\007"
		fi
		;;
            *sh)
		if [ "$CTYS_XTERM" == 0 ];then
		    echo -ne "\033]2;${_label2}\007\033]1;\007"
		fi
		;;
# 	*)
# 	    local _title=" --title ${_label2} "
# 	    ;;
	esac 

	local _execStrg="$1 $2  ${_title}"
    else
	local _execStrg="$1 $2"
    fi

    if [ -n "${C_STUBCALL}" ];then
	_execStrg="exec ${_execStrg}"
	_execStrg="${3:+cd $3\&\&}${_execStrg}"
    else
	_execStrg="${3:+cd $3&&}${_execStrg}"
    fi

    printDBG $S_CLI ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:C_SSH_PSEUDOTTY=${C_SSH_PSEUDOTTY}"
    printDBG $S_CLI ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:TERM=${TERM}"
    printDBG $S_CLI ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_execStrg=${_execStrg}"
    printFINALCALL 0  $LINENO $BASH_SOURCE "FINAL-CLI-CONSOLE:STARTER(${_label})" "${_execStrg}"

    if [ -n "${C_STUBCALL}" ];then
	echo -n "${_execStrg}"
    else
	[ -z "${C_NOEXEC}" ]&&eval ${_execStrg}
    fi
}


