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

_myPKGNAME_VMW_INFO="${BASH_SOURCE}"
_myPKGVERS_VMW_INFO="01.02.001b01"
hookInfoAdd $_myPKGNAME_VMW_INFO $_myPKGVERS_VMW_INFO
_myPKGBASE_VMW_INFO="`dirname ${_myPKGNAME_VMW_INFO}`"


#FUNCBEG###############################################################
#NAME:
#  infoVMW4Action
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Shows results for "-a INFO" on-screen-display
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
function infoVMW4Action () {
    local _allign=$1

    printf "%"$((2*_allign))"s%-"${_label}"s %"$((2*_allign))"s\n" " " \
        "`setStatusColor ${VMW_STATE} VMW`:" "Plugin Version:${_myPKGVERS_VMW}"
    printf "%"$((2*_allign))"s%-"${_label}"s %"$((2*_allign))"s\n" " " "" \
        "Operational State:`setStatusColor ${VMW_STATE} ${VMW_STATE}`"


    if [ -n "${VMW_VERSTRING}" ];then
	printf "%"$((2*_allign))"s%-"${_label}"s %"$((2*_allign))"s\n" " " ""     "VMW version:"
  	printf "%"$((2*_allign))"s%-"${_label}"s ->%"$((2*_allign))"s\n" " " " " "${VMW_VERSTRING}"
   	printf "%"$((3*_allign))"s%-"${_label}"s %"$((2*_allign))"s\n" " " " " \
            "Magic-Number:`setStatusColor ${VMW_STATE} ${VMW_MAGIC}`"
	printf "%"$((3*_allign))"s%-"${_label}"s %"$((2*_allign))"s\n" " " " " "Verified Prerequisites:"

	local i2=;
	for i2 in ${VMW_PREREQ//,/ };do
  	    printf "%"$((3*_allign))"s%-"${_label}"s ->%s\n" " " " " "${i2}"
	done
    fi
    echo

    return
}


#FUNCBEG###############################################################
#NAME:
#  infoVMW4MACHINE
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Shows results of "-a INFO" for post-processing, therefor the plugin
#  has to be initialized completely to full init-level.
#
#
#EXAMPLE:
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#    Returns relevant information for current plugin in terse format.
#
#    <type>;<plug-vers>;<plug-magic>;<plug-state>;<prereq-list>
#
#      <type>
#        Current type "VMW".
#
#      <plug-vers>
#        The version of current plugin, gwhich is the value 
#        of _myPKGVERS_VMW.
#
#      <plug-magic>
#        The magic ID, gwhich is the shortform of the version of 
#        current plugin stored in VMW_MAGIC.
#
#      <plug-state>
#        This field represents the current value of the operational 
#        state for the VMW plugin. The managed states are
#
#          DISABLED(0)
#          ENABLED(1)
#          BUSY(3)
#
#      <prereq-list>
#        Comma seperated list of all pathless or fully qualified 
#        executable names required for proper execution. These need not 
#        all to be mandatory, e.g. vmware of vmplayer will be decided 
#        generic. Same for dependency of WS6 on VNC.
#
#
#  VALUES:
#
#FUNCEND###############################################################
function infoVMW4MACHINE () {
    local _out=;
    _out="$MYACCOUNT"
    _out="${_out};VMW"
    _out="${_out};$VMW_ACCELERATOR"
    _out="${_out};${_myPKGVERS_VMW}"
    _out="${_out};${VMW_MAGIC}"
    _out="${_out};${VMW_STATE}"
    _out="${_out};${VMW_PREREQ}"
    echo "${_out}"
    return
}


#FUNCBEG###############################################################
#NAME:
#  infoVMW
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
function infoVMW () {
    local _arg1=$1

    case $_arg1 in
        [mM][aA][cC][hH][iI][nN][eE])
	    infoVMW4MACHINE $*
	    ;;
	[0-9]*)
            if [ -n "${C_TERSE}" ];then
		infoVMW4MACHINE $*
	    else
		infoVMW4Action $*
	    fi
	    ;;
	*)
            ABORT=2;
            printERR $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:Unknown parameter:"
            printERR $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:   \$1=$1"
            printERR $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:   \$*=$*"
            gotoHell ${ABORT};
	    ;;
    esac
}


