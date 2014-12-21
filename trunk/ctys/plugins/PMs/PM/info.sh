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

_myPKGNAME_PM_INFO="${BASH_SOURCE}"
_myPKGVERS_PM_INFO="01.01.001a00"
hookInfoAdd $_myPKGNAME_PM_INFO $_myPKGVERS_PM_INFO




#FUNCBEG###############################################################
#NAME:
#  infoPM4Action
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
function infoPM4Action () {
    local _allign=$1

    printf "%"$((2*_allign))"s%-"${_label}"s %"$((2*_allign))"s\n" " " \
        "`setStatusColor ${PM_STATE} PM`:" "Plugin Version:${_myPKGVERS_PM}"
    printf "%"$((2*_allign))"s%-"${_label}"s %"$((2*_allign))"s\n" " " "" \
        "Operational State:`setStatusColor ${PM_STATE} ${PM_STATE}`"

    if [ -n "${PM_VERSTRING}" ];then
    printf "%"$((2*_allign))"s%-"${_label}"s %"$((2*_allign))"s\n" " " ""     "PM version:"
  	printf "%"$((2*_allign))"s%-"${_label}"s ->%"$((2*_allign))"s\n" " " " " "${PM_VERSTRING}"
  	printf "%"$((3*_allign))"s%-"${_label}"s %"$((2*_allign))"s\n" " " " " \
            "Magic-Number:`setStatusColor ${PM_STATE} ${PM_MAGIC}`"
  	printf "%"$((3*_allign))"s%-"${_label}"s %"$((2*_allign))"s\n" " " " " "Verified Prerequisites:"

	local i2=;
	for i2 in ${PM_PREREQ//,/ };do
  	    printf "%"$((3*_allign))"s%-"${_label}"s ->%s\n" " " " " "${i2}"
	done
    fi
    echo

    return
}


#FUNCBEG###############################################################
#NAME:
#  infoPM4MACHINE
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
#        Current type "PM".
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
function infoPM4MACHINE () {
    local _out=;
    _out="$MYACCOUNT"
    _out="${_out};PM"
    _out="${_out};$PM_ACCELERATOR"
    _out="${_out};${_myPKGVERS_PM}"
    _out="${_out};${PM_MAGIC}"
    _out="${_out};${PM_STATE}"
    _out="${_out};${PM_PREREQ}"
    echo "${_out}"
    return
}


#FUNCBEG###############################################################
#NAME:
#  infoPM
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
function infoPM () {
    local _arg1=$1

    case ${MYOS} in
	Linux);;
	FreeBSD|OpenBSD);;
	SunOS);;
	*)
	    printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "${FUNCNAME}:OS not supported by PM:${MYOS}";
	    return;
	    ;;
    esac

    case $_arg1 in
        [mM][aA][cC][hH][iI][nN][eE])
	    infoPM4MACHINE $*
	    ;;
	[0-9]*)
            if [ -n "${C_TERSE}" ];then
		infoPM4MACHINE $*
	    else
		infoPM4Action $*
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

