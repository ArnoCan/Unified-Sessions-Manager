#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_10_013
#
########################################################################
#
# Copyright (C) 2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
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
#    prtconf -v -c /devices/cpus|\
    ${CTYS_PRTCONF} -v -c /devices|sed -n '/^  *cpus/,$p'|\
    awk 'BEGIN{x="";}/name=/{x=$0;}/value=/{x=x" "$0;print x}'|\
    awk  -v d="$C_DBG" '
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

     function ptrace(inp){
       if(!d){
         print line ":" inp | "cat 1>&2"
       }
     }

     function hex2dez(hex){
       h=substr(hex,1,1);
       dez=0;
       for(jj=length(hex);jj>0&&h!="";){
         if(h=="a"){h=10;}
         if(h=="b"){h=11;}
         if(h=="c"){h=12;}
         if(h=="d"){h=13;}
         if(h=="e"){h=14;}
         if(h=="f"){h=15;}

         if(jj==1){dez=dez+h;}
         if(jj==2){dez=dez+h*16;}
         if(jj==3){dez=dez+h*256;}
         if(jj==4){dez=dez+h*4096;}
         if(jj==5){dez=dez+h*65536;}
         if(jj==6){dez=dez+h*1048576;}
         if(jj==7){dez=dez+h*16777216;}
         if(jj==8){dez=dez+h*268435456;}
         if(jj==9){dez=dez+h*4294967296;}
         if(jj==10){dez=dez+h*4294967296*16;}
         if(jj==11){dez=dez+h*4294967296*256;}
         if(jj==12){dez=dez+h*4294967296*256*16;}
         if(jj==13){dez=dez+h*4294967296*256*16*16;}
         if(jj>13){dez=999999999999999999999999999999999999;}

         jj-=1;
         h=substr(hex,jj,1);
       }
       return dez;
     }

     $1~/device_type/            {processor++;}

     $1~/vendor-id/&&$NF~/Intel/ {vendor="Intel";}
     $1~/vendor-id/&&$NF~/AMD/   {vendor="AMD";}
     $1~/vendor-id/&&$NF~/VIA/   {vendor="VIA";}

     $1~/family/                 {family=$NF;gsub("value=0*","",family);family=hex2dez(family);}
     $1~/model name/             {next;}
     $1~/cpu-model/              {model=$NF;gsub("value=0*","",model);model=hex2dez(model);}
     $1~/stepping-id/            {stepping=$NF;gsub("value=0*","",stepping);stepping=hex2dez(stepping);}
     $1~/cpu-mhz/                {gsub("[.,][0-9]*$","",$NF);speed=$NF;gsub("value=0*","",speed);speed=hex2dez(speed)"MHz";}
     $1~/l2-cache-size/          {gsub(" ","",$NF);cache=$NF;gsub("value=0*","",cache);cache=hex2dez(cache)/1024"KB";}

     $2~/vmx/&&_flagsVMX!=1      {_flagsVMX=1;flags=flags"-VMX"}
     $2~/svm/&&_flagsSVM!=1      {_flagsSVM=1;flags=flags"-SVM"}
     $2~/pae/&&_flagsPAE!=1      {_flagsPAE=1;flags=flags"-PAE"}

     END{
       cputype=vendor"-"family"-"model"-"stepping"-"cache"-"speed;
       if(flags==""){flags="-.";}
       cpuinfo="CPU:"processor"x"cputype""flags;
       printf("%s",cpuinfo);
     }
     '
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
    local _ram=$(${CTYS_PRTCONF}|awk '/Memory size:/{printf("%d",$3);}');
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
    local _hdd=;
    _hdd=$(df -hl ${*}|\
                awk '
                   BEGIN{x="";}
                   $1~/^\/dev\//{
                      dev=$1;gsub(".*/","",dev);
                      gsub("s[0-9]$","",dev);
                      if(x!=""){x=x"%"dev}
                      else{x=dev}
                    }
                    END{
                      printf("%s",x);
                    }
                  '
        )
    printDBG $S_LIB ${D_UID} $LINENO $BASH_SOURCE "HDD=${_hdd}"
    [ -n "${_hdd}" ]&&echo -n "HDD:${_hdd}"
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
	if [ -e /export/home ];then
	    _fslst="${_fslst} /export/home"
	fi
	local _h;
	for _h in /export/home[0-9]*;do
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
	local _fs=`df -k ${_fslst} |awk 'BEGIN{fs="";}/home/||/srv/{fs=fs"%"sprintf("%s-%dM",$NF,$2/1024);}END{gsub("^%","",fs);printf("%s",fs);}'`
    else
	local _fs=;
	local _i=;
	for _i in ${_fslst};do
 	    _fs="${_fs} $(df -lk ${_i}|awk '{fs="%"sprintf("%s-%dM",$NF,$2/1024);}END{printf("%s",fs);}')"
	done
	_fs=${_fs## };
	_fs=${_fs%% };
	_fs=${_fs##%};
    fi
    [ -n "${_fs}" ]&&echo -n "FS:${_fs}"

    return;
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
   
    _hw=$(${CTYS_PRTDIAG} |awk 'BEGIN{machine="PM";}/VMware/{machine="VM";}END{printf("%s",machine);}');
    case ${_hw} in
        PM|VM);;
	*)_hw="PM";;
    esac

    printDBG $S_LIB ${D_UID} $LINENO $BASH_SOURCE "MACHINE-TYPE=${_hw}"
    echo -n "${_hw}"
    return
}
