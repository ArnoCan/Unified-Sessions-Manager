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

_myPKGNAME_OpenBSD_SHOW="${BASH_SOURCE}"
_myPKGVERS_OpenBSD_SHOW="01.02.001b01"
hookInfoAdd $_myPKGNAME_OpenBSD_SHOW $_myPKGVERS_OpenBSD_SHOW



#FUNCBEG###############################################################
#NAME:
#  SHOWOpenBSD
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
function SHOWOpenBSD () {
    local _allign=3
    local _label=12
    local _label2=20
    echo "#############################"
    printf "%s:%s\n" "Node" `uname -n`
    printf "%"${_allign}"s%-"${_label}"s:%s\n" " " "System"    `uname -s`
    printf "%"${_allign}"s%-"${_label}"s:%s\n" " " "OS"        `uname -s`
    printf "%"${_allign}"s%-"${_label}"s:%s\n" " " "RELEASE"   `uname -r`
    printf "%"${_allign}"s%-"${_label}"s:%s\n" " " "MACHINE"   `uname -m`

    printf "%"${_allign}"s%-"${_label}"s\n" " " "MEM-INFO"
    printf "%"$((3*_allign))"s%-"${_label}"s:%"$((2*_allign))"s\n" \
       " " "MemTotal" "`sysctl -n hw.physmem`"
    printf "%"$((3*_allign))"s%-"${_label}"s:%"$((2*_allign))"s\n" \
       " " "MemMaxUser" "`sysctl -n hw.usermem`"
    printf "%"$((3*_allign))"s%-"${_label}"s:%"$((2*_allign))"s\n" \
       " " "PageSize" "`sysctl -n hw.pagesize`"
    printf "%"$((3*_allign))"s%-"${_label}"s:%"$((2*_allign))"s\n" \
       " " "SwapTotal" "`swapctl -s -k|sed 's/^total: *//;s/k *.*/k/'`"

    echo

    local _iter=1
    local _head=30
    printf "%"${_allign}"s%-"${_label}"s: iterations=%d\n" " " "Top" ${_iter}
    top -b -n ${_iter}|head -n ${_head}|awk -v a=${_allign} '{printf("%'$((2*_allign))'s%s\n"," ",$0);}'

    printf "%"${_allign}"s%-"${_label}"s\n" " " "HEALTH" 
    ${CTYS_SENSORS}|\
    awk -F':' -v a=${_allign} '
      BEGIN{
        alarm=0;
        headOK=0;
      }
      function printHead() {
        headOK=1;
        printf("%'$((2*_allign))'s%s\n"," ",$0);
      }
      /ALARM/{
        printHead();
        alarm+=1;
        printf("%'$((2*_allign))'sALARM(%d)\n"," ",alarm);
        printf("%'$((3*_allign))'s%s\n"," ",$0);
      }
#      /RPM/ {printf("%'$((2*_allign))'s%s\n"," ",$0);}
#      /°C/ {printf("%'$((2*_allign))'s%s\n"," ",$0);}

      END{
        printf("%'$((2*_allign))'sTotal ALARMs=%d\n"," ",alarm);
      }
    '
}


