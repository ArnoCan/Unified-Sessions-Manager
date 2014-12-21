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

_myPKGNAME_SunOS_INFO="${BASH_SOURCE}"
_myPKGVERS_SunOS_INFO="01.02.001b01"
hookInfoAdd $_myPKGNAME_SunOS_INFO $_myPKGVERS_SunOS_INFO



#FUNCBEG###############################################################
#NAME:
#  INFOSunOS
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
function INFOSunOS () {
    local _allign=3
    local _label=12
    local _label2=20
    echo "#############################"
    printf "%s:%s" "Node" `uname -n`
    printf "  -  ctys(%s)\n" "$VERSION"

    printf "%"${_allign}"s%-"${_label}"s:%s\n" " " "System"    `uname -s`
    printf "%"${_allign}"s%-"${_label}"s:%s\n" " " "OS"        `uname -s`
    printf "%"${_allign}"s%-"${_label}"s:%s\n" " " "RELEASE"   `uname -r`
    printf "%"${_allign}"s%-"${_label}"s:%s\n" " " "MACHINE"   `uname -m`

#     printf "%"${_allign}"s%-"${_label}"s:" " " "KERNEL#CPU"
#     local _smp=`sysctl -n hw.ncpu`
#     if((_smp>1));then
#   	printf "%"${_allign}"s\n" "SMP-KERNEL"
#     else
#   	printf "%"${_allign}"s\n" "SINGLE-CPU-KERNEL"
#     fi

#     printf "%"${_allign}"s%-"${_label}"s\n" " " "CPU-INFO"
#     printf "%"$((2*_allign))"s%-"${_label}"s\n" " " "processor:0" ""
#     printf "%"$((3*_allign))"s%-"${_label}"s:%"$((2*_allign))"s\n" \
#       " " "model name" "`sysctl -n hw.model`"
#     printf "%"$((3*_allign))"s%-"${_label}"s:%"$((2*_allign))"s\n" \
#       " " "cpu MHz" "`sysctl -n hw.cpuspeed`"

#     echo

#     printf "%"${_allign}"s%-"${_label}"s\n" " " "MEM-INFO"
#     printf "%"$((3*_allign))"s%-"${_label}"s:%"$((2*_allign))"s\n" \
#        " " "MemTotal" "`sysctl -n hw.physmem`"
#     printf "%"$((3*_allign))"s%-"${_label}"s:%"$((2*_allign))"s\n" \
#        " " "SwapTotal" "`swapctl -s -k|sed 's/^total: *//;s/k *.*/k/'`"

    echo

    printf "%"$((_allign))"s%-"${_label}"s\n" " " "SOFTWARE"
    printf "%"$((2*_allign))"s%-"${_label}"s\n" " " "Mandatory:"

    #bash
    gwhich bash 2>&1 >/dev/null
    if [ $? -eq 0 ]; then
  	printf "%"$((3*_allign))"s%-"${_label}"s:%"$((2*_allign))"s\n" \
          "  " "bash" "`bash --version|sed -n '/bash.* version/p'`"
    else
  	printf "%"$((3*_allign))"s%-"${_label}"s:%"$((2*_allign))"s\n" \
            "  " "bash" "bash is on this machine not available"
    fi

    #awk
    gwhich awk 2>&1 >/dev/null
    if [ $? -eq 0 ]; then
	case ${MYREL} in
	    5.10)
		local _myAwk=xcu4;
		;;
	    *)
		local _myAwk=generic;
		;;
	esac
  	printf "%"$((3*_allign))"s%-"${_label}"s:%"$((2*_allign))"s\n" \
            "  " "gawk" "$_myAwk"
    else
  	printf "%"$((3*_allign))"s%-"${_label}"s:%"$((2*_allign))"s\n" \
          "  " "awk" "awk is on this machine not available"
    fi

    #sed
    gwhich bash 2>&1 >/dev/null
    if [ $? -eq 0 ]; then
  	printf "%"$((3*_allign))"s%-"${_label}"s:%"$((2*_allign))"s\n" \
          "  " "sed" "unknown version"
    else
  	printf "%"$((3*_allign))"s%-"${_label}"s:%"$((2*_allign))"s\n" \
          "  " "sed" "GNU sed is on this machine not available"
    fi


    #OpenSSH
    gwhich ssh 2>&1 >/dev/null
    if [ $? -eq 0 ]; then
  	printf "%"$((3*_allign))"s%-"${_label}"s:%"$((2*_allign))"s\n" \
          "  " "SSH" "`ssh -v 2>&1|sed -n '/OpenSSH/p'`"
    else
  	printf "%"$((3*_allign))"s%-"${_label}"s:%"$((2*_allign))"s\n" \
          "  " "SSH" "SSH is on this machine not available"
    fi

    #top
    gwhich top 2>&1 >/dev/null
    if [ $? -eq 0 ]; then
  	printf "%"$((3*_allign))"s%-"${_label}"s:%"$((2*_allign))"s\n" \
          "  " "top" "unknown version"
    else
  	printf "%"$((3*_allign))"s%-"${_label}"s:%"$((2*_allign))"s\n" \
          "  " "top" "top is on this machine not available"
    fi


    #######
    echo

    printf "%"$((2*_allign))"s%-"${_label}"s\n" " " "Optional:"

    #wmctrl
    desktopsSupportCheck
    if [ $? -eq 0 ]; then
  	printf "%"$((3*_allign))"s%-"${_label}"s:%"$((2*_allign))"s\n" \
          " " "wmctrl" "`wmctrl -V`"
    else
  	printf "%"$((3*_allign))"s%-"${_label}"s:%"$((2*_allign))"s\n" \
          " " "wmctrl" "wmctrl is on this machine not available"
    fi

#     #sensors
#     printf "%"$((3*_allign))"s%-"${_label}"s:%"$((2*_allign))"s\n" \
#         "  " "lm_sensors" "\"sysctl hw\""

#     #hddtemp
#     gwhich hddtemp 2>&1 >/dev/null
#     if [ $? -eq 0 ]; then
#   	printf "%"$((3*_allign))"s%-"${_label}"s:%"$((2*_allign))"s\n" \
#           "  " "hddtemp" "`${CTYS_HDDTEMP} -v 2>&1`"
#     else
#   	printf "%"$((3*_allign))"s%-"${_label}"s:%"$((2*_allign))"s\n" \
#           "  " "hddtemp" "hddtemp is on this machine not available"
#     fi




    echo
    local _knownTypes="`hookGetKnownTypes`"
    printf "%"$((1*_allign))"s%-"${_label}"s:%"$((2*_allign))"s\n" \
        " " "PLUGINS" "${_knownTypes}"
    for _ty in ${_knownTypes};do
	eval handle${_ty} PROLOGUE INFO
	eval info${_ty} $_allign 2>/dev/null
    done
}


