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

_myPKGNAME_Linux_INFO="${BASH_SOURCE}"
_myPKGVERS_Linux_INFO="01.02.001b01"
hookInfoAdd $_myPKGNAME_Linux_INFO $_myPKGVERS_Linux_INFO




#FUNCBEG###############################################################
#NAME:
#  INFOLinux
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
function INFOLinux () {
    local _allign=3
    local _label=12
    local _label2=20
    echo "#############################"
    printf "%s:%s" "Node" `uname -n`
    printf "  -  ctys(%s)\n" "$VERSION"

    printf "%"${_allign}"s%-"${_label}"s:%s\n" " " "System"    `uname -s`
    printf "%"${_allign}"s%-"${_label}"s:%s\n" " " "OS"        "${MYOS}"
    printf "%"${_allign}"s%-"${_label}"s:%s\n" " " "RELEASE"   "${MYOSREL}"
    printf "%"${_allign}"s%-"${_label}"s:%s\n" " " "MACHINE"   `uname -m`

    printf "%"${_allign}"s%-"${_label}"s:" " " "KERNEL#CPU"
    local _smp=`uname -v|sed -n 's/^.* SMP .*$/SMP/p'`
    if [ -n "${_smp}" ];then
  	printf "%"${_allign}"s\n" "SMP-KERNEL"
    else
  	printf "%"${_allign}"s\n" "SINGLE-CPU-KERNEL"
    fi
    cat /proc/cpuinfo|sed -n 's/\t//g;s/^\([^[:space:]]*[[:space:]]\{0,2\}[^[:space:]]*\)[[:space:]]*: *\(.*\)$/\1:\2/gp'|\
    awk -F':' '
     BEGIN{
       printf("%'$((_allign))'s%-'${_label}'s\n"," ","CPU-INFO");
       _processor=0
       _flags="";
     }
     $1~/processor/   {
                        if(length(_flags)!=0){
                          printf("%'$((3*_allign))'s%-'${_label2}'s:%s ...\n"," ","flags",_flags);
                          _flags="";
                        }
                        printf("%'$((2*_allign-1))'s%s:%s\n"," ",$1,$2);
                      }
     $1~/vendor_id/   {printf("%'$((3*_allign))'s%-'${_label2}'s:%s\n"," ",$1,$2);}
     $1~/family/      {printf("%'$((3*_allign))'s%-'${_label2}'s:%s\n"," ",$1,$2);}
     $1~/model name/  {printf("%'$((3*_allign))'s%-'${_label2}'s:%s\n"," ",$1,$2);next;}
     $1~/model/       {printf("%'$((3*_allign))'s%-'${_label2}'s:%s\n"," ",$1,$2);}
     $1~/stepping/    {printf("%'$((3*_allign))'s%-'${_label2}'s:%s\n"," ",$1,$2);}
     $1~/cpu MHz/     {printf("%'$((3*_allign))'s%-'${_label2}'s:%s\n"," ",$1,$2);}
     $1~/cache size/  {printf("%'$((3*_allign))'s%-'${_label2}'s:%s\n"," ",$1,$2);}
     $2~/vmx/         {_flagsVMX=1;}
     $2~/svm/         {_flagsSVM=1;}
     $2~/pae/         {_flagsPAE=1;}
     END{
       printf("\n");
       printf("%'$((2*_allign))'s%-'${_label2}'s\n"," ","Flags assumed equal for all processors on same machine:");
       printf("%'$((3*_allign))'s%-'${_label2}'s\n"," ","flags");
       printf("%'$((3*_allign))'s%-'${_label2}'s = %d\n"," ","   vmx(VT-x - Vanderpool)", _flagsVMX);
       printf("%'$((3*_allign))'s%-'${_label2}'s = %d\n"," ","   svm(AMD-V - Pacifica)", _flagsSVM);
       printf("%'$((3*_allign))'s%-'${_label2}'s = %d\n"," ","   PAE                    ", _flagsPAE);
       printf("\n");
     }
     '

    cat /proc/meminfo|sed -n 's/^\([^[:space:]]*[[:space:]]\{0,2\}[^[:space:]]*\)[[:space:]]*:[^0-9]*\([0-9]*\).*$/\1:\2/gp'|\
    awk -F':' '
     BEGIN{
       printf("%'$((_allign))'s%-'${_label}'s\n"," ","MEM-INFO");
     }
     $1~/MemTotal/    {printf("%'$((2*_allign))'s%-'${_label2}'s   :%6.0d M\n"," ",$1,$2/1000);}
     $1~/SwapTotal/   {printf("%'$((2*_allign))'s%-'${_label2}'s   :%6.0d M\n"," ",$1,$2/1000);}
     END{
     }
     '
    echo



    printf "%"$((_allign))"s%-"${_label}"s\n" " " "SOFTWARE"
    printf "%"$((2*_allign))"s%-"${_label}"s\n" " " "Mandatory:"

    #bash
    gwhich bash 2>/dev/null >/dev/null
    if [ $? -eq 0 ]; then
  	printf "%"$((3*_allign))"s%-"${_label}"s:%"$((2*_allign))"s\n" \
          "  " "bash" "`bash --version|sed -n '/bash.* version/p'`"
    else
  	printf "%"$((3*_allign))"s%-"${_label}"s:%"$((2*_allign))"s\n" \
          "  " "bash" "bash is on this machine not available"
    fi

    #awk
    gwhich awk 2>/dev/null >/dev/null
    if [ $? -eq 0 ]; then
        #gawk
	local _vs="`awk --version 2>&1|sed -n '/GNU Awk [0-9]*/p'`"
	if [ -n "$_vs" ];then
  	    printf "%"$((3*_allign))"s%-"${_label}"s:%"$((2*_allign))"s\n" \
		"  " "gawk" "${_vs## }"
	else
            #mawk
	    local _vs="`awk -W version 2>&1|awk '/mawk/&&/Copyright/{print $2}'`"
	    if [ -n "$_vs" ];then
  		printf "%"$((3*_allign))"s%-"${_label}"s:%"$((2*_allign))"s\n" \
		    "  " "mawk" "${_vs## }"
	    else
  		printf "%"$((3*_allign))"s%-"${_label}"s:%"$((2*_allign))"s\n" \
		    "  " "awk" "UNKNOWN-VERSION"
	    fi
	fi
    else
  	printf "%"$((3*_allign))"s%-"${_label}"s:%"$((2*_allign))"s\n" \
          "  " "awk" "awk is on this machine not available"
    fi

    #sed
    gwhich bash 2>/dev/null >/dev/null
    if [ $? -eq 0 ]; then
  	printf "%"$((3*_allign))"s%-"${_label}"s:%"$((2*_allign))"s\n" \
          "  " "sed" "`sed --version|sed -n '/GNU sed version/p'`"
    else
  	printf "%"$((3*_allign))"s%-"${_label}"s:%"$((2*_allign))"s\n" \
          "  " "sed" "GNU sed is on this machine not available"
    fi


    #OpenSSH
    gwhich ssh 2>/dev/null >/dev/null
    if [ $? -eq 0 ]; then
  	printf "%"$((3*_allign))"s%-"${_label}"s:%"$((2*_allign))"s\n" \
          "  " "SSH" "`ssh -v 2>&1|sed -n '/OpenSSH/p'`"
    else
  	printf "%"$((3*_allign))"s%-"${_label}"s:%"$((2*_allign))"s\n" \
          "  " "SSH" "SSH is on this machine not available"
    fi

    #top
    gwhich top 2>/dev/null >/dev/null
    if [ $? -eq 0 ]; then
  	printf "%"$((3*_allign))"s%-"${_label}"s:%"$((2*_allign))"s\n" \
          "  " "top" "`top -v|sed -n 's/^[[:space:]]*//g;/version/p'`"
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
          " " "wmctrl" "`${CTRS_WMCTRL} 2>&1|sed -n '/wmctrl *[0-9]/p'`"
    else
  	printf "%"$((3*_allign))"s%-"${_label}"s:%"$((2*_allign))"s\n" \
          " " "wmctrl" "wmctrl is on this machine not available"
    fi

    #lm_sensors
    gwhich sensors 2>/dev/null >/dev/null
    if [ $? -eq 0 ]; then
  	printf "%"$((3*_allign))"s%-"${_label}"s:%"$((2*_allign))"s\n" \
          "  " "lm_sensors" "`${CTYS_SENSORS} -v 2>&1`"
    else
  	printf "%"$((3*_allign))"s%-"${_label}"s:%"$((2*_allign))"s\n" \
          "  " "lm_sensors" "lm_sensors is on this machine not available"
    fi

    #hddtemp
    gwhich hddtemp 2>/dev/null >/dev/null
    if [ $? -eq 0 ]; then
  	printf "%"$((3*_allign))"s%-"${_label}"s:%"$((2*_allign))"s\n" \
          "  " "hddtemp" "`${CTYS_HDDTEMP} -v 2>&1`"
    else
  	printf "%"$((3*_allign))"s%-"${_label}"s:%"$((2*_allign))"s\n" \
          "  " "hddtemp" "hddtemp is on this machine not available"
    fi




    echo
    local _knownTypes="`hookGetKnownTypes`"
    printf "%"$((1*_allign))"s%-"${_label}"s:%"$((2*_allign))"s\n" \
        " " "PLUGINS" "${_knownTypes}"
    for _ty in ${_knownTypes};do
	eval handle${_ty} PROLOGUE INFO
	eval info${_ty} $_allign 2>/dev/null
    done
}

