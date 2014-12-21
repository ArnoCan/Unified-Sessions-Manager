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
# Copyright (C) 2008,2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################



#FUNCBEG###############################################################
#NAME:
#  getCPUinfo
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Lists the basic CPU information with dominant flags for 
#  virtualization.
#  Currently numerical form only.
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
function getCPUinfo () {
    cat /proc/cpuinfo|\
    sed -n 's/\t//g;s/^\([^[:space:]]*[[:space:]]\{0,2\}[^[:space:]]*\)[[:space:]]*: *\(.*\)$/\1:\2/gp'|\
    awk -F':' '
     BEGIN{
       cpuinfo="";

       cputype=".";
       vendor=".";
       family=".";
       model=".";
       stepping=".";
       speed=".";
       cache=".";
       flags="";

     }
     $1~/processor/   {processor++;}

     $1~/vendor_id/&&$2~/Intel/   {vendor="Intel";}
     $1~/vendor_id/&&$2~/AMD/   {vendor="AMD";}
     $1~/vendor_id/&&$2~/VIA/   {vendor="VIA";}

     $1~/family/      {family=$2;}
     $1~/model name/  {next;}
     $1~/model/       {model=$2;}
     $1~/stepping/    {stepping=$2;}
     $1~/cpu MHz/     {gsub("[.,][0-9]*$","",$2);speed=$2"MHz";}
     $1~/cache size/  {gsub(" ","",$2);cache=$2;}
     $2~/vmx/&&_flagsVMX!=1         {_flagsVMX=1;flags=flags"-VMX"}
     $2~/svm/&&_flagsSVM!=1         {_flagsSVM=1;flags=flags"-SVM"}
     $2~/pae/&&_flagsPAE!=1         {_flagsPAE=1;flags=flags"-PAE"}

     END{
       cputype=vendor"-"family"-"model"-"stepping"-"cache"-"speed;
       if(flags==""){flags="-.";}
       cpuinfo="CPU:"processor"x"cputype""flags;
       printf("%s",cpuinfo);
     }
     '
}


#FUNCBEG###############################################################
#NAME:
#  getMEMinfo
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Lists the RAM size and the SWAP space.
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
function getMEMinfo () {
    cat /proc/meminfo|\
    sed -n 's/^\([^[:space:]]*[[:space:]]\{0,2\}[^[:space:]]*\)[[:space:]]*:[^0-9]*\([0-9]*\).*$/\1:\2/gp'|\
    awk -F':' '
     BEGIN{
       _meminfo="";
     }
     $1~/MemTotal/    {_meminfo="RAM:"$2/1000"M";}
     $1~/SwapTotal/   {_swpinfo="SWAP:"$2/1000"M";}
     END{
       gsub("[.,][0-9]*M","M",_meminfo);
       gsub("[,.][0-9]*M","M",_swpinfo);
       printf("%s,%s",_meminfo,_swpinfo);
     }
     '
}





#FUNCBEG###############################################################
#NAME:
#  getHDDinfo
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Lists the HDDs available.
#
#PARAMETERS:
#  $1: [<hdd-devlst-4-df>]
#
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getHDDinfo () {
    local _nlst=${*}
    if [ -z "${_nlst}" ];then
	local _hdd=`cat /proc/diskstats|\
                    awk '
                    BEGIN{
                        _hddinfo="";
                    }
                    $3~/^[sh]d[a-z]$/&&$4!="0"{_hddinfo=_hddinfo"%"$3}
                    $3~/^cciss.c[0-9]*d[0-9]*$/&&$4!="0"{_hddinfo=_hddinfo"%"$3}
                    END{
                        gsub("^%","",_hddinfo);
                        printf("%s",_hddinfo);
                    }
                    '`
    else
	local _dlst=;
	local _cur=;

	_nlst=${_nlst//\/dev\//};
	_nlst=${_nlst//  / };
 	_nlst=${_nlst//  / };
 	_nlst=${_nlst## };
 	_nlst=${_nlst%% };
	local _hdd=`cat /proc/diskstats|egrep "(${_nlst// /|})"|\
                    awk '
                      BEGIN{
                        _hddinfo="";
                      }
                      $4!="0"{_hddinfo=_hddinfo"%"$3}
                      END{
                        gsub("^%","",_hddinfo);
                        printf("%s",_hddinfo);
                      }
                      '`


    fi
    [ -n "${_hdd}" ]&&echo -n "HDD:${_hdd}"
}




#FUNCBEG###############################################################
#NAME:
#  getHDDtemp
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Lists the HDDs temps available.
#
#PARAMETERS:
#  $1: [<hdd-devlst-4-df>]
#
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getHDDtemp () {
    function get3wareHdd {
        # simple check for 3ware series
        # assuming only one controller is present
	DEVCHK="$(${CTYS_LSPCI}|grep '3ware*')"
	if [ -z "${DEVCHK}" ];then
	    return
	fi

	DEVCHK1=$(echo ${DEVCHK}|grep ' 9[0-9]*')
	if [ -n "$DEVCHK1" ];then 
	    DEV=twa0
	else
	    DEVCHK1=$(echo ${DEVCHK}|grep '7xxx/8xxx')
	    if [ -n "$DEVCHK1" ];then 
		DEV=twe0
	    else
		printWNG 2 $LINENO $BASH_SOURCE 1 "Unknown 3ware controller:${DEVCHK}"
		return
	    fi
	fi
	for  (( i=0; i<24; i++ )) ; do 
	    T=$(smartctl -a --device=3ware,$i /dev/$DEV|grep Tempera|awk '{printf("%s",$NF);}');
	    if [ -n "$T" ]; then
		echo -n "${DEV}-${i}_${T}°C%"
	    fi
	done
    }



    local _nlst=${*};
    local _tlst=;
    if [ -z "${_nlst}" ];then
	local _hdd=$(getHDDinfo)
	_hdd=${_hdd//\%/ }
	_hdd=${_hdd//HDD:/ }
    fi

    #standard hdd
    for i in ${_hdd};do
	if [ -n "${CTYS_SMARTCTL}" ];then
	    _tlst="${_tlst}%"$(${CTYS_SMARTCTL} -a /dev/$i|awk -v x=${i##*/} '/Temperature/{printf("%s_%s°C%%", x,$10);}')
	    _tlst="${_tlst%%\%}"
	    _tlst="${_tlst##\%}"
	fi
    done


    #specials
    _tlst="${_tlst}%$(get3wareHdd)"
    _tlst="${_tlst%%\%}"
    _tlst="${_tlst##\%}"
    _tlst="${_tlst// /}"


    printDBG $S_LIB ${D_UID} $LINENO $BASH_SOURCE "HDDtemp=${_dd}"
    [ -n "${_tlst}" ]&&echo -n "HDDtemp:${_tlst}"
}



#FUNCBEG###############################################################
#NAME:
#  getFSinfo
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Lists the filesystem size of "/home"(if a on it's own partition) and
#  "/home[0-9]*" HDDs available.
#
#PARAMETERS:
#  $*: [<filesystemlist-4-df>]
#
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getFSinfo () {
    local _fslst=${*}

    if [ -z "${_fslst}" ];then
	if [ -e /home ];then
	    _fslst="${_fslst} /home"
	fi
	local _h;
	for _h in /home[0-9]*;do
	    if [ -e "$_h" ];then
		_fslst="${_fslst} $_h"
	    fi
	done
	if [ -e /srv ];then
	    _fslst="${_fslst} /srv"
	fi
	for _h in /srv[0-9]*;do
	    if [ -e "$_h" ];then
		_fslst="${_fslst} $_h"
	    fi
	done
	local _fs=`df -hlPm ${_fslst} |awk 'BEGIN{fs="";}/home/||/srv/{fs=fs"%"sprintf("%s-%dM",$NF,$2);}END{gsub("^%","",fs);printf("%s",fs);}'`
    else
	local _fs=;
	local _i=;
	for _i in ${_fslst};do
 	    _fs="${_fs} $(df -hlPm ${_i}|awk '{fs="%"sprintf("%s-%dM",$NF,$2);}END{printf("%s",fs);}')"
	done
	_fs=${_fs## };
	_fs=${_fs%% };
	_fs=${_fs##%};
    fi
    [ -n "${_fs}" ]&&echo -n "FS:${_fs}"
}



#FUNCBEG###############################################################
#NAME:
#  getPLATFORMinfo
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
function getPLATFORMinfo () {
    local _hw=;
    
    local _buf0=;
    local _buf1=;

    if [ -n "${CTYS_LSPCI}" ];then
	_buf0=`${CTYS_LSPCI} -m |awk '
               BEGIN{pc=0;}
               $0~/Intel/&&$0~/Host bridge/{pc+=2;next;}
               $0~/Intel/&&$0~/ISA bridge/{pc+=2;next;}
               $0~/Intel/&&$0~/ICH[0-9] Family/{pc+=4;next;}

               $0~/VIA Technologies/&&$0~/Host bridge/{pc+=2;next;}
               $0~/VIA Technologies/&&$0~/ISA bridge/{pc+=2;next;}
               $0~/VIA Technologies/&&$0~/PCI bridge/{pc+=2;next;}

               $0~/Host bridge/{pc+=1;next;}
               $0~/ISA bridge/{pc+=1;next;}
               $0~/PCI bridge/{pc+=1;next;}

               END{printf("%d",pc);}
              '`
    fi

    local if=/proc/interrupts;
    if [ -e "${if}" ];then
	_buf1=`cat ${if}|awk '
	BEGIN{pc=0;}
	$1=="1:"&&$NF=="i8042"{pc++;next;}
	$1=="2:"&&$NF=="cascade"{pc=10;next;}
	$1=="8:"&&$NF=="rtc"{pc+=2;next;}
	$1=="12:"&&$NF=="i8042"{pc++;next;}
	END{printf("%d",pc);}
	'`
    fi
    #
    #>4. PC
    #
    case $((_buf0+_buf1)) in
        [01234])_hw="UNKNOWN";;
	*)_hw="PC";;
    esac

    printDBG $S_LIB ${D_UID} $LINENO $BASH_SOURCE "PLATFORM=${_hw}"
    echo -n "${_hw}"
    return
}


#FUNCBEG###############################################################
#NAME:
#  getVMinfo
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
function getVMinfo () {
    local _hw=;
   
    if [ -z "${CTYS_LSPCI}" ];then
	printWNG 1 $LINENO $BASH_SOURCE 0 "Missing package pciutils - CTYS_LSPCI"
	return
    fi

    #check VMW
    _hw=`${CTYS_LSPCI} -v |awk '
            BEGIN{machine="";}
            $0~/VGA.*compatible.*VMware .*SVGA.*Adapter/{machine="VM";}
            $0~/VMware .*Abstract.*Adapter/{machine="VM";}
            END{if(machine!~/^$/)printf("%s",machine);}
            '`

    #check KVM
    if [ -z "${_hw// /}" ];then
       _hw=`${CTYS_LSPCI} -m |awk '
            BEGIN{machine="";}
            $0~/Intel/&&$0~/Qumranet/&&$0~/Qemu/{machine="VM";}
            END{printf("%s",machine);}
            '`
	
    fi

    #check QEMU
    #check XEN
    #check VBOX

    case ${_hw} in
        PM|VM);;
	*)_hw="PM";;
    esac

    printDBG $S_LIB ${D_UID} $LINENO $BASH_SOURCE "MACHINE-TYPE=${_hw}"
    echo -n "${_hw}"
    return
}

