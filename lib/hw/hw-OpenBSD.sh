#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_06_001a09
#
########################################################################
#
# Copyright (C) 2008 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
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
#
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
    local _ret=`sysctl hw|awk  '
      BEGIN{
       processor=0;
       cpuinfo="-.";

       cputype=".";
       vendor=".";
       family=".";
       model=".";
       stepping=".";
       speed=".";
       cache=".";
       flags=".";

      }
      /hw.ncpu/{gsub(".*=","",$1);processor=$1;}
      /hw.cpuspeed/{gsub(".*=","",$1);speed=$1;}
      /hw.model/&&/Intel/{vendor="Intel";}
      /hw.model/&&/AMD/{vendor="AMD";}
      /hw.model/&&/VIA/{vendor="VIA";}
      /hw.model/&&/ARM/{vendor="ARM";}

      /hw.model/&&/Intel/{gsub("Pentium.R.","Pentium");model=$2""$3;}

      /hw.model/&&/AMD-K6/{model="K6";next;}
      /hw.model/&&/AMD/{gsub(".tm.","",$5);model=$5""$7;}

     END{
       cputype=vendor"-"family"-"model"-"stepping"-"cache"-"speed;
       cpuinfo="CPU:"processor"x"cputype""cpuinfo;

       printf("%s",cpuinfo);
     }
    '`
    echo -n -e "${_ret}"
    return
}



#FUNCBEG###############################################################
#NAME:
#  getMEMinfo
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
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
    local _ram=`sysctl -n hw.physmem`
    let _ram=_ram/1024/1024;
    echo -n -e "RAM:${_ram}M"
    return
}





#FUNCBEG###############################################################
#NAME:
#  getHDDinfo
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
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
    local _dlst=;
    local _cur=;
    local _nlst=${*}
    if [ -z "${_nlst}" ];then
	_nlst=$(sysctl -n hw.disknames)
	for i in ${_nlst//,/ };do
	    if [ "${i//wd}" != "${i}" -o "${i//sd}" != "${i}" ];then
		if [ -n "$_dlst" ];then
		    _dlst="${_dlst}%${i}"
		else
		    _dlst="${i}"
		fi
	    fi
	done
    else
	for i in $_nlst;do
	    _cur=`df -lh ${i} 2>/dev/null|awk '/^\/dev/{gsub(".*dev\/","",$1);gsub("[a-z]$","",$1);printf("%s",$1)}'`
	    if [ -n "$_cur" ];then
		if [ -n "$_dlst" ];then
		    _dlst="${_dlst}%${_cur}"
		else
		    _dlst="${_cur}"
		fi
	    fi
	done
    fi
    printDBG $S_LIB ${D_UID} $LINENO $BASH_SOURCE "HDD=${_dlst}"

    echo -n "$_dlst"
    return
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
    return
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
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getFSinfo () {
    local _fslst=${*};
    if [ -z "${_fslst}" ];then
	local _fs=`df -lP /home /home[0-9]*|awk '
                     BEGIN{fs="";}
                     /home/{fs=fs"%"$NF"-"$2/2/1024/1024"G";}
                     END{gsub("^%","",fs);printf("%s",fs);}
                   '`
    else
	local _fs=;
	local _i=;
	for _i in ${_fslst};do
	    _fs="${_fs} $(df -lP ${_i}|awk '{fs="%"$NF"-"$2/2/1024/1024"G";}END{printf("%s",fs);}')"
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
    return
}
