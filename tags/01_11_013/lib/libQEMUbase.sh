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

printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "LOAD-LIB-QEMUBASE"

#FUNCBEG###############################################################
#NAME:
#  getVersionStrgQEMU
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Fetch version info for QEMUKVM.
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
function getVersionStrgQEMU () {
    if [ -z "${1}" ];then
	return
    fi

#4TEST:Keep temp for reminder
#    _verstrg1=$(callErrOutWrapper $LINENO $BASH_SOURCE ${QEMUCALL} ${1} -h|awk '$0~/version/&&$0~/Copyright/{printf("qemu-%s",$5);}')
    _verstrg1=$(callErrOutWrapper $LINENO $BASH_SOURCE ${QEMUCALL} ${1} -h|sed -n '/Copyright/s/^.*\([0-9]\+\.[0-9]\+\.[0-9]\+\).*$/\1/p')
    _verstrg1="qemu-${_verstrg1}"
    echo ${_verstrg1//,/};
}


#FUNCBEG###############################################################
#NAME:
#  getVersionStrgQEMUKVM
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Fetch version info for QEMUKVM.
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
#
#FUNCEND###############################################################
function getVersionStrgQEMUKVM () {
    if [ -z "${1}" ];then
	return
    fi
    _verstrg2=`callErrOutWrapper $LINENO $BASH_SOURCE ${QEMUCALL} ${1} -h|awk '$0~/version/&&$0~/kvm/&&$0~/Copyright/{gsub("\\\\(","",$6);gsub("\\\\)","",$6);printf("qemu-%s-%s",$5,$6);}'`
    echo ${_verstrg2//,/}
}

#FUNCBEG###############################################################
#NAME:
#  getVersionStrgQEMUALL
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Fetch version info for any QEMU emulator executable.
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
#
#FUNCEND###############################################################
function getVersionStrgQEMUALL () {
    if [ -z "${1}" ];then
	return
    fi
    local _ac=$(getACCELERATOR_QEMU ${1})
    case $_ac in
	KVM)   getVersionStrgQEMUKVM ${1};;
	QEMU)  getVersionStrgQEMU    ${1};;
    esac
}


#FUNCBEG###############################################################
#NAME:
#  getQEMUMAGIC
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Fetch version info for executable of QEMU/QEMUKVM/KVM variant and
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
#   Returns the value of QEMU_MAGIC, for now:
#     QEMU_090      :qemu-0.9.0*
#     QEMU_091      :qemu-0.9.1*
#     QEMU_012      :qemu-0.12.0*
#     QEMU_GENERIC  :qemu-*
#   Else
#     QEMU_NOLOCC   :*
#
#FUNCEND###############################################################
function getQEMUMAGIC () {
    printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "\$*=<${*}>"
    local _lv=$(getVersionStrgQEMU $1)
    local _m=;
    case ${_lv} in
	[qQ][eE][mM][uU]-0.9.0*)  _m=QEMU_090;;
	[qQ][eE][mM][uU]-0.9.1*)  _m=QEMU_091;;
	[qQ][eE][mM][uU]-0.9*)    _m=QEMU_09x;;
	[qQ][eE][mM][uU]-0.10*)   _m=QEMU_010;;
	[qQ][eE][mM][uU]-0.11.0*) _m=QEMU_011;;
	[qQ][eE][mM][uU]-0.11*)   _m=QEMU_011;;
	[qQ][eE][mM][uU]-0.12*)   _m=QEMU_012;;
	[qQ][eE][mM][uU]-*)       _m=QEMU_GENERIC;;
         *)                       echo -n NOLOC;return 1;;
    esac
    echo -n $_m
}




#FUNCBEG###############################################################
#NAME:
#  callOptionsQEMUlist
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Validates availability of option.
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
#
#FUNCEND###############################################################
function callOptionsQEMUlist () {
    if [ -z "${1}" ];then
	return
    fi
    eval $1 -h |awk -v o="$2" '/^ *-/{print $1;}'|sort -u
}


#FUNCBEG###############################################################
#NAME:
#  callOptionsQEMUcheck
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Validates availability of option.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: name of executable
#  $2: option, including leading hyphens.
#      
#
#OUTPUT:
#  RETURN:
#   0: OK
#   1: NOK
#  VALUES:
#
#FUNCEND###############################################################
function callOptionsQEMUcheck () {
    if [ -n "${1}" -a -f "${1}" ];then
	${1} -h |awk -v e=$1 -v o="$2" '/^ *-/&&$1~o{print o;}'
    fi
}


#FUNCBEG###############################################################
#NAME:
#  callOptionsQEMUcacheOpts
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Validates availability of option.
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
#
#FUNCEND###############################################################
MYQEMUOPTIONSCACHE=;
MYQEMUOPTIONSCACHEKEY=;
function callOptionsQEMUcacheOpts () {
    if [ -n "${1}" ];then
	MYQEMUOPTIONSCACHEKEY=$1;
	MYQEMUOPTIONSCACHE=$( $1 -h |awk -v o="$2" '/^ *-/{print $1;}')
    fi
}


#FUNCBEG###############################################################
#NAME:
#  callOptionsQEMUcacheCheck
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Validates availability of option.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: name of executable
#  $2: option, including leading hyphens.
#      
#
#OUTPUT:
#  RETURN:
#   0: OK
#   1: NOK
#  VALUES:
#
#FUNCEND###############################################################
function callOptionsQEMUcacheCheck () {
    if [ "${MYQEMUOPTIONSCACHEKEY}" != "${1}" ];then
	if [ "${MYQEMUOPTIONSCACHE}" != "${MYQEMUOPTIONSCACHE//$1/}" ];then
    	    echo -n "$1"
	fi
    fi
}



#FUNCBEG###############################################################
#NAME:
#  getACCELERATOR_QEMU
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
#     KVM
#      Returns this when KVM support is compiled in.
#     KQEMU
#      Currently not supported
#     QEMU
#      No specific accelerator, this value is due to SW-design.
#
#FUNCEND###############################################################
function getACCELERATOR_QEMU () {
    if [ -z "${1}" ];then
	return
    fi
    if [ -n "${MYQEMUOPTIONSCACHE}" -a "${MYQEMUOPTIONSCACHEKEY}" == "${1}" ];then
	if [ -n "$(callOptionsQEMUcacheCheck $1 '-no-kvm')" ];then
	    echo KVM
	    return
	fi
    fi
    if [ -n "$(callOptionsQEMUcheck $1 '-no-kvm')" ];then
	echo KVM
	return
    fi
    echo QEMU
}


#FUNCBEG###############################################################
#NAME:
#  getHYPERRELRUN_QEMU
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
function getHYPERRELRUN_QEMU () {
    if [ -z "${1}" ];then
	return
    fi
    case $(getACCELERATOR_QEMU $1) in
	KVM)
	    getVersionStrgQEMUKVM $1
	    ;;
	QEMU)
	    getVersionStrgQEMU $1
	    ;;
    esac
}


#FUNCBEG###############################################################
#NAME:
#  getSTARTERCALL_QEMU4CONF
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
function getSTARTERCALL_QEMU4CONF () {
    if [ -z "${1}" ];then
	return
    fi
    if [ ! -f "$1" ];then
	return
    fi
    local myStarter=$(source ${1}&& echo $STARTERCALL);
    myStarter=$(bootstrapGetRealPathname ${myStarter})
    if [ -z "$myStarter" ];then
	return
    fi
    echo  $myStarter
}


#FUNCBEG###############################################################
#NAME:
#  getHYPERRELRUN_QEMU4CONF
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
function getHYPERRELRUN_QEMU4CONF () {
    if [ -z "${1}" ];then
	return
    fi
    local myStarter=$(getSTARTERCALL_QEMU4CONF ${1});
    if [ -z "$myStarter" ];then
	return
    fi
    getHYPERRELRUN_QEMU $myStarter
}

#FUNCBEG###############################################################
#NAME:
#  getACCELERATOR_QEMU4CONF
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
function getACCELERATOR_QEMU4CONF () {
    if [ -z "${1}" ];then
	return
    fi
    local myStarter=$(getSTARTERCALL_QEMU4CONF ${1});
    if [ -z "$myStarter" ];then
	return
    fi
    getACCELERATOR_QEMU $myStarter
}


