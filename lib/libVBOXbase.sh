#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_005
#
########################################################################
#
#     Copyright (C) 2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
#     This program is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
#
#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
#
#     You should have received a copy of the GNU General Public License
#     along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
########################################################################



#
#
#Requires the ctys framework, at least
#
#  <bin>/bootstrap/bootstrap<version>
#  <lib>/base.h
#
#
#
#

printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "LOAD-LIB-VBOXBASE"

#FUNCBEG###############################################################
#NAME:
#  getVersionStrgVBOX
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Fetch version info for VBOXKVM.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: name of executable
#
#OUTPUT:
#  RETURN:
#   0: OK
#   1: NOK
#  VALUES:
#
#FUNCEND###############################################################
function getVersionStrgVBOX () {
    if [ -z "${1}" ];then
	return
    fi
    _verstrg1=$(callErrOutWrapper $LINENO $BASH_SOURCE ${VBOXCALL} ${1} --help|awk '$0~/VirtualBox/&&$0~/Graphical/{printf("VirtualBox-%s",$NF);}')
    echo ${_verstrg1//,/};
}



#FUNCBEG###############################################################
#NAME:
#  getVBOXMAGIC
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Fetch version info for executable of VBOX/VBOXKVM/KVM variant and
#  returns an MAGICID for machine-processing.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: name of executable
#      
#
#OUTPUT:
#  RETURN:
#   0: OK
#   1: NOK
#  VALUES:
#   Returns the value of VBOX_MAGIC, for now:
#     VBOX_030102      :VirtualBox-3.1.2
#     VBOX_GENERIC     :VirtualBox-*
#   Else
#     VBOX_NOLOCC      :*
#
#FUNCEND###############################################################
function getVBOXMAGIC () {
    printDBG $S_VBOX ${D_MAINT} $LINENO $BASH_SOURCE "\$*=<${*}>"
    local _lv=$(getVersionStrgVBOX $1)
    local _m=;
    case ${_lv} in
	VirtualBox-3.1.2)  _m=VBOX_030102;;
	VirtualBox-2*)     _m=VBOX_02x;;
	VirtualBox-*)      _m=VBOX_GENERIC;;
         *)                       echo -n NOLOC;return 1;;
    esac
    echo -n $_m
}




#FUNCBEG###############################################################
#NAME:
#  getACCELLERATOR_VBOX
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Returns the available accelerator as support compiled into 
#  the tested executable.
#
#  Currently the actual availability and state of required
#  kernel modules is not checked.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: name of executable      
#
#OUTPUT:
#  RETURN:
#   0: OK
#   1: NOK
#  VALUES:
#   <accelerator>
#     VBOX
#      No specific accelerator, this value is due to SW-design.
#     ffs.
#
#FUNCEND###############################################################
function getACCELLERATOR_VBOX () {
    if [ -z "${1}" ];then
	return
    fi
    echo VBOX
}



#FUNCBEG###############################################################
#NAME:
#  getHYPERRELRUN_VBOX
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Returns the versionstring of current hypervisor/emulator.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: name of executable      
#
#OUTPUT:
#  RETURN:
#   0: OK
#   1: NOK
#  VALUES:
#FUNCEND###############################################################
function getHYPERRELRUN_VBOX () {
    if [ -z "${1}" ];then
	return
    fi
    case $(getACCELLERATOR_VBOX $1) in
	VBOX)
	    getVersionStrgVBOX $1
	    ;;
    esac
}


#FUNCBEG###############################################################
#NAME:
#  getSTARTERCALL_VBOX4CONF
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Returns the executable from configuration file.
#  In case of multiple entries the last detected setting wins.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: name of configurationfile - *.ctys
#
#OUTPUT:
#  RETURN:
#   0: OK
#   1: NOK
#  VALUES:
#FUNCEND###############################################################
function getSTARTERCALL_VBOX4CONF () {
    if [ -z "${1}" ];then
	return
    fi
    if [ ! -f "$1" ];then
	return
    fi
    local myStarter=$(awk -F'=' 'BEGIN{x="";}/STARTERCALL/{x=$2;}END{printf("%s",x);}' ${1});
    myStarter=$(eval echo $myStarter);
    myStarter=$(bootstrapGetRealPathname ${myStarter})
    if [ -z "$myStarter" ];then
	return
    fi
    echo  $myStarter
}


#FUNCBEG###############################################################
#NAME:
#  getHYPERRELRUN_VBOX4CONF
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Returns the versionstring of current hypervisor/emulator.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: name of configurationfile - *.ctys  
#
#OUTPUT:
#  RETURN:
#   0: OK
#   1: NOK
#  VALUES:
#FUNCEND###############################################################
function getHYPERRELRUN_VBOX4CONF () {
    if [ -z "${1}" ];then
	return
    fi
    local myStarter=$(getSTARTERCALL_VBOX4CONF ${1});
    if [ -z "$myStarter" ];then
	return
    fi
    getHYPERRELRUN_VBOX $myStarter
}

#FUNCBEG###############################################################
#NAME:
#  getACCELLERATOR_VBOX4CONF
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Returns the accelerator of current hypervisor/emulator.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: name of executable      
#
#OUTPUT:
#  RETURN:
#   0: OK
#   1: NOK
#  VALUES:
#FUNCEND###############################################################
function getACCELLERATOR_VBOX4CONF () {
    if [ -z "${1}" ];then
	return
    fi
    local myStarter=$(getSTARTERCALL_VBOX4CONF ${1});
    if [ -z "$myStarter" ];then
	return
    fi
    getACCELLERATOR_VBOX $myStarter
}


