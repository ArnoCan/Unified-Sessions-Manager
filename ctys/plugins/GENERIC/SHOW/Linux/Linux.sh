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

_myPKGNAME_Linux_SHOW="${BASH_SOURCE}"
_myPKGVERS_Linux_SHOW="01.02.001b01"
hookInfoAdd $_myPKGNAME_Linux_SHOW $_myPKGVERS_Linux_SHOW



#FUNCBEG###############################################################
#NAME:
#  SHOWLinux
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
function SHOWLinux () {
    local _allign=3
    local _label=12
    local _label2=20
    echo "#############################"
    printf "%s:%s\n" "Node" `uname -n`
    printf "%"${_allign}"s%-"${_label}"s:%s\n" " " "System"    `uname -s`
    printf "%"${_allign}"s%-"${_label}"s:%s\n" " " "OS"        `uname -o`
    printf "%"${_allign}"s%-"${_label}"s:%s\n" " " "RELEASE"   `uname -r`
    printf "%"${_allign}"s%-"${_label}"s:%s\n" " " "MACHINE"   `uname -m`

    cat /proc/meminfo|sed -n 's/^\([^[:space:]]*[[:space:]]\{0,2\}[^[:space:]]*\)[[:space:]]*:[^0-9]*\([0-9]*\).*$/\1:\2/gp'|\
    awk -F':' '
     BEGIN{
       printf("%'$((_allign))'s%-'${_label}'s\n"," ","MEM-INFO");
     }
     $1~/MemTotal/    {printf("%'$((2*_allign))'s%-'${_label2}'s:%6.0d G\n"," ",$1,$2/1000);}
     $1~/MemFree/     {printf("%'$((2*_allign))'s%-'${_label2}'s:%6.0d G\n"," ",$1,$2/1000);}
     $1~/SwapTotal/   {printf("%'$((2*_allign))'s%-'${_label2}'s:%6.0d G\n"," ",$1,$2/1000);}
     $1~/SwapFree/    {printf("%'$((2*_allign))'s%-'${_label2}'s:%6.0d G\n"," ",$1,$2/1000);}
     END{
     }
     '
    local _iter=1
    local _head=30
    printf "%"${_allign}"s%-"${_label}"s: iterations=%d\n" " " "Top" ${_iter}
    top -b -n ${_iter}|head -n ${_head}|awk -v a=${_allign} '{printf("%'$((2*_allign))'s%s\n"," ",$0);}'

    printf "%"${_allign}"s%-"${_label}"s\n" " " "HEALTH" 

    if [ -n "`gwhich ${CTYS_SENSORS} 2>/dev/null`" ];then
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
#        /RPM/ {printf("%'$((2*_allign))'s%s\n"," ",$0);}
#        /°C/ {printf("%'$((2*_allign))'s%s\n"," ",$0);}

        {
          printf("%'$((2*_allign))'s%s\n"," ",$0);
        }

        END{
          printf("%'$((2*_allign))'sTotal ALARMs=%d\n"," ",alarm);
        }
      '
    else
	printf "%"$((2*_allign))"s%-"${_label}"s:%s\n" " " "SENSORS not available"  ""
    fi
    echo
    printf "%"${_allign}"s%-"${_label}"s\n" " " "HDD Temperatures" 
#     case ${MYOS} in
# 	*)
# 	    printf "%"$((2*_allign))"s%-"${_label}"s:%s\n" " " "HHD temperatures not available"  ""
# 	    ;;
#     esac
    local _tl=$(getHDDtemp.sh)
    _tl=${_tl#*HDDtemp:}
    _tl=${_tl//\%/ }
    for i in $_tl;do
 	printf "%"$((2*_allign))"s%-"${_label}"s:%s\n" " " "${i%_*}"  "${i#*_}"
    done
    echo
}

