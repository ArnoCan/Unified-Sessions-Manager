#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
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

_myPKGNAME_VBOX_INFO="${BASH_SOURCE}"
_myPKGVERS_VBOX_INFO="01.02.001b01"
hookInfoAdd $_myPKGNAME_VBOX_INFO $_myPKGVERS_VBOX_INFO
_myPKGBASE_VBOX_INFO="`dirname ${_myPKGNAME_VBOX_INFO}`"


#FUNCBEG###############################################################
#NAME:
#  infoVBOX4Action
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
function infoVBOX4Action () {
    local _allign=$1

    printf "%"$((2*_allign))"s%-"${_label}"s %"$((2*_allign))"s\n" " " \
        "`setStatusColor ${VBOX_STATE} VBOX`:" "Plugin Version:${_myPKGVERS_VBOX}"
    printf "%"$((2*_allign))"s%-"${_label}"s %"$((2*_allign))"s\n" " " "" \
        "Operational State:`setStatusColor ${VBOX_STATE} ${VBOX_STATE}`"


    if [ -n "${VBOX_VERSTRING}" ];then
	printf "%"$((2*_allign))"s%-"${_label}"s %"$((2*_allign))"s\n" " " ""     "VBOX version:"
  	printf "%"$((2*_allign))"s%-"${_label}"s ->%"$((2*_allign))"s\n" " " " " "${VBOX_VERSTRING}"
   	printf "%"$((3*_allign))"s%-"${_label}"s %"$((2*_allign))"s\n" " " " " \
            "Magic-Number:`setStatusColor ${VBOX_STATE} ${VBOX_MAGIC}`"
	printf "%"$((3*_allign))"s%-"${_label}"s %"$((2*_allign))"s\n" " " " " "Verified Prerequisites:"

	local i2=;
	for i2 in ${VBOX_PREREQ//,/ };do
  	    printf "%"$((3*_allign))"s%-"${_label}"s ->%s\n" " " " " "${i2}"
	done
    fi
    echo

    return
}


#FUNCBEG###############################################################
#NAME:
#  infoVBOX4MACHINE
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
#        Current type "VBOX".
#
#      <plug-vers>
#        The version of current plugin, gwhich is the value 
#        of _myPKGVERS_VBOX.
#
#      <plug-magic>
#        The magic ID, gwhich is the shortform of the version of 
#        current plugin stored in VBOX_MAGIC.
#
#      <plug-state>
#        This field represents the current value of the operational 
#        state for the VBOX plugin. The managed states are
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
function infoVBOX4MACHINE () {
    local _out=;
    _out="VBOX"
    _out="${_out};${_myPKGVERS_VBOX}"
    _out="${_out};${VBOX_MAGIC}"
    _out="${_out};${VBOX_STATE}"
    _out="${_out};${VBOX_PREREQ}"
    echo "${_out}"
    return
}


#FUNCBEG###############################################################
#NAME:
#  infoVBOX
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
function infoVBOX () {
    local _arg1=$1

    case $_arg1 in
        [mM][aA][cC][hH][iI][nN][eE])
	    infoVBOX4MACHINE $*
	    ;;
	[0-9]*)
            if [ -n "${C_TERSE}" ];then
		infoVBOX4MACHINE $*
	    else
		infoVBOX4Action $*
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


