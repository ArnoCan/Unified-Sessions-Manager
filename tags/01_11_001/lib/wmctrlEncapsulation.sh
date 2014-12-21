#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_09_001
#
########################################################################
#
# Copyright (C) 2007,2008 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

_myLIBNAME_wmctrlUtils="${BASH_SOURCE}"
_myLIBVERS_wmctrlUtils="01.07.001b06"
libManInfoAdd "${_myLIBNAME_wmctrlUtils}" "${_myLIBVERS_wmctrlUtils}"



#The active desktop when starting the caller of this script, thus 
#this could be set as active after processings by
#
#  desktopsSetStaring
#
export DESKTOPS_STARTING=



#FUNCBEG###############################################################
#NAME:
#  desktopsSupportCheck
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Check whether multiple Desktops are supported.
#
#PARAMETERS:
#
#
#OUTPUT:
#  RETURN:
#    0: OK, sets C_MDESK=1
#    1: NOK unsets C_MDESK
#  VALUES:
#  
#FUNCEND###############################################################
function desktopsSupportCheck () {
    printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME"
    local _wmctrl=${CTYS_WMCTRL}
    if [ -z "$_wmctrl" ];then
	printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:wmctrl not set"
	printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME: wmctrl=\"${_wmctrl}\""
	printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "So \"-D\" does not work on local console"
	unset DESKTOPS_STARTING;
	unset C_MDESK;
	return 1;
    fi

    gwhich "$_wmctrl" 2>/dev/null >/dev/null
    if [ $? -ne 0 ];then
	printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:wmctrl not accessible"
	printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME: wmctrl=\"${_wmctrl}\""
	printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "So \"-D\" does not work on local console"
	unset DESKTOPS_STARTING;
	unset C_MDESK;
	return 1;
    fi

    export C_MDESK=1;
    printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "wmctrl found at:${_wmctrl}"
    printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "Multiple desktops are supported:C_MDESK=1"
    if [ -z "${DESKTOPS_STARTING}" ];then
        DESKTOPS_STARTING=`desktopsGetCurrentId`
    fi
}


#FUNCBEG###############################################################
#NAME:
#  desktopsCheckDesk
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Check whether the <desktopId> or <desktopLabel> is available.
#
#PARAMETERS:
#  $1: <desktopId> or <desktopLabel>
#
#OUTPUT:
#  RETURN:
#    0: OK, present.
#    1: NOK not available.
#  VALUES:
#  
#FUNCEND###############################################################
function desktopsCheckDesk () {
    printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME \$*=$*"

    if [ -z "${C_MDESK}" ];then
	printDBG $S_LIB ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME wmctrl not available"
        desktopsSupportCheck
	[ $? -ne 0 ]&&return 1
    fi

    local _idX=$1
    printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME _idX=$_idX"
    case "${_idX}" in
        #It should be an <desktopId> 
	[0-9][0-9][0-9]|[0-9][0-9]|[0-9])
            local _lb=`desktopsGetLabel $_idX`;
	    printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME DesktopId=$_lb"
            if [ "`desktopsGetId ${_lb}`" == "${_idX}" ];then
		printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME DesktopId=$_lb"
              #OK it seems so be OK now.
		return 0;
            fi
            return 1;
	    ;;
        #This could be a <desktopLabel>
	*) 
            local _id=`desktopsGetId $_idX`;
	    printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME DesktopId=$_id"
            if [ "`desktopsGetLabel ${_id}`" == "${_idX}" ];then
		printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME DesktopId=$_id"
                #OK it seems so be OK now.
		return 0;
            fi
            return 1;

	    ;;
    esac
}


#FUNCBEG###############################################################
#NAME:
#  desktopsGetId
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Gets the <desktopId> related to <desktopLabel>.
#  The input of a valid <desktopId> will be detected and returns
#  exactly the input.
#
#PARAMETERS:
#  $1: <desktopLabel>
#
#OUTPUT:
#  RETURN:
#    0: OK, present.
#    1: NOK not available.
#  VALUES:
#    <desktopId>
#  
#FUNCEND###############################################################
function desktopsGetId () {
    printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME \$*=$*"
    if [ -z "${C_MDESK}" ];then
	printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME wmctrl not available"
        desktopsSupportCheck
	[ $? -ne 0 ]&&return 1
    fi

    local _ret=`${CTYS_WMCTRL} -d|awk -v lb=${1} '$NF==lb{print $1}'`
    printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME DesktopId=$_ret"

    case "${_ret}" in
	[0-9][0-9][0-9]|[0-9][0-9]|[0-9])
            if [ "`${CTYS_WMCTRL} -d|awk -v id=${_ret} '$1~id{print $NF}'`" == "$1" ];then
                printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME DesktopId=$_ret"
		echo ${_ret}
		return 0;
            fi
	    ;;
	*) 
            #maybe it was an id already
	     _ret=`${CTYS_WMCTRL} -d|awk -v id=${1} '$1==id{print $NF}'`
            if [ "`${CTYS_WMCTRL} -d|awk -v lbl=${_ret} '$NF~lbl{print $1}'`" == "$1" ];then
                printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME DesktopId=$_ret"
		echo ${1}
		return 0;
            fi
	    ;;
    esac
    return 1;
}

#FUNCBEG###############################################################
#NAME:
#  desktopsGetLabel
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Gets the <desktopLabel> related to <desktopId>.
#  The input of <desktopLabel> will be detected and returns the
#  exact literal.
#
#PARAMETERS:
#  $1: <desktopId>
#
#OUTPUT:
#  RETURN:
#    0: OK, present.
#    1: NOK not available.
#  VALUES:
#    <desktopLabel>
#  
#FUNCEND###############################################################
function desktopsGetLabel () {
    printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME \$*=$*"

    if [ -z "${C_MDESK}" ];then
	printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME wmctrl not available"
        desktopsSupportCheck
	[ $? -ne 0 ]&&return 1
    fi

    case "${1}" in
	[0-9][0-9][0-9]|[0-9][0-9]|[0-9])
            #given an id 
            local _ret=`${CTYS_WMCTRL} -d|awk -v id=${1} '$1~id{print $NF}'`
            if [ "`desktopsGetId $_ret`" == "$1" ];then
		printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME DesktopId=$_ret"
		echo ${_ret}
		return 0;
            fi
            #maybe it was an label already
            local _t=`desktopsGetId $1`;
	    local _x=`${CTYS_WMCTRL} -d|awk -v id=${_t}'$1~id{print $NF}'`
            if [ "$_x" == "$1" ];then
		printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME DesktopId=$_ret"
		echo ${1}
		return 0;
            fi
	    ;;
	*) 
            #might be a valid label already
            local _t=`desktopsGetId $1`;
            if [ "`${CTYS_WMCTRL} -d|awk -v id=${_t}'$1~id{print $NF}'`" == "$1" ];then
		printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME DesktopId=$_ret"
		echo ${1}
		return 0;
            fi
	    ;;
    esac
    return 1;
}

#FUNCBEG###############################################################
#NAME:
#  desktopsGetCurrentId
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Gets the <desktopId> of the current visible desktop.
#
#PARAMETERS:
#  none.
#
#OUTPUT:
#  RETURN:
#    0: OK, present.
#    1: NOK not available.
#  VALUES:
#    <desktopId>
#  
#FUNCEND###############################################################
function desktopsGetCurrentId () {
    printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME \$*=$*"

    if [ -z "${C_MDESK}" ];then
	printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME wmctrl not available"
        desktopsSupportCheck
	[ $? -ne 0 ]&&return 1
    fi

    local _ret=`${CTYS_WMCTRL} -d|awk '$2~/\*/{print $1}'`
    printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME DesktopId=$_ret"
    case "${_ret}" in
	[0-9][0-9][0-9]|[0-9][0-9]|[0-9])
	    echo ${_ret}
	    return 0;
	    ;;
	*) _ret="";;
    esac
    return 1;
}


#FUNCBEG###############################################################
#NAME:
#  desktopsChange
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Changes the current desktop.
#
#  ATTENTION: Due to my limited fortune-teller skills I just assume,
#             that any group of characters consisting of up to 3 digits
#             only, is an <desktopId>, anything else (except empty-string)
#             seems to me beeing a <desktopLabel>.
#
#             You might consider this when naming your desktops.
#
#
#PARAMETERS:
#  $1: <desktopId> or <desktopLabel>
#
#OUTPUT:
#  RETURN:
#    0: OK, present.
#    1: NOK not available.
#  VALUES:
#  
#FUNCEND###############################################################
function desktopsChange () {
    printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME \$*=$*"

    if [ -z "${C_MDESK}" ];then
	printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME wmctrl not available"
        desktopsSupportCheck
	[ $? -ne 0 ]&&return 1
    fi

    local _id=$1
    case "${_id}" in
	[0-9][0-9][0-9]|[0-9][0-9]|[0-9])
	    ;;
	*) _id=`desktopsGetId ${1}`;;
    esac
    if [ -n "$_id" -a "`desktopsGetCurrentId`" != "$_id" ];then
	${CTYS_WMCTRL} -s $_id
	return 0;
    fi
    return 1;
}


#FUNCBEG###############################################################
#NAME:
#  desktopsSetStarting
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Sets the desktop from starting point visible again.
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#    0: OK, present.
#    1: NOK not available.
#  VALUES:
#  
#FUNCEND###############################################################
function desktopsSetStarting () {

    if [ -z "${C_MDESK}" ];then
	printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME wmctrl not available"
        desktopsSupportCheck
	[ $? -ne 0 ]&&return 1
    fi

    if [ -n "${DESKTOPS_STARTING}" ];then
	desktopsChange "${DESKTOPS_STARTING}"
        printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME DESKTOPS_STARTING=$DESKTOPS_STARTING"
    fi
}


#FUNCBEG###############################################################
#NAME:
#  desktopsGetDeskList
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Returns a list of space/CR seperated list of <desktopId> for loop 
#  constructs.
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#    0: OK, present.
#    1: NOK not available.
#  VALUES:
#    <displayId>,...
#       Space/CR seperated list of desktop IDs.
#  
#FUNCEND###############################################################
function desktopsGetDeskList () {

    if [ -z "${C_MDESK}" ];then
	printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME wmctrl not available"
        desktopsSupportCheck
	[ $? -ne 0 ]&&return 1
    fi

    local _ret=`${CTYS_WMCTRL} -d|awk '{print $1}'`
    printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME Current present desktops _ret=$_ret"
    echo $_ret
}

