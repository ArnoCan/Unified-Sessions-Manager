#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_10_008
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

#FUNCBEG###############################################################
#NAME:
#  getVersionStrgXEN
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Fetch version info for XEN.
#
#EXAMPLE:
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#   0: OK
#   1: NOK
#  VALUES:
#
#FUNCEND###############################################################
function getVersionStrgXEN () {
    local _verstrg=;

    if [ -d "/sys" -a -d "/sys/hypervisor" -a -d "/sys/hypervisor/version" ];then
	local _mOk=0;
	if [ -e "/sys/hypervisor/version/major" ];then
	    _verstrg="${_verstrg}$(cat /sys/hypervisor/version/major)"
	    ((++_mOk));
	fi
	if [ -e "/sys/hypervisor/version/minor" ];then
	    _verstrg="${_verstrg}.$(cat /sys/hypervisor/version/minor)"
	    ((++_mOk));
	fi
	if [ -e "/sys/hypervisor/version/extra" ];then
	    _verstrg="${_verstrg}$(cat /sys/hypervisor/version/extra)"
	fi

	if((_mOk==2));then
	    _verstrg=${_verstrg// /}
	    _verstrg=${_verstrg//,/}
	    _verstrg=${_verstrg//;/}
	    if [ -n "${_verstrg}" ];then
		echo "xen-${_verstrg%.}";
	    fi
	    return
	fi
	_verstrg=;
    fi

    #
    #ask rpm, frequently version number is more finegrained
    #
    if [ -n "$CTYS_RPM" ];then
        _verstrg=`callErrOutWrapper $LINENO $BASH_SOURCE ${CTYS_RPM} -q xen `
	if [ -n "${_verstrg}" ];then
	    XEN_PREREQ="${XEN_PREREQ} ${_verstrg}-DetectedVersionBy(rpm)"
	fi
    fi

    #
    #ask aptitude, frequently version number is more finegrained
    #
    if [ -n "$CTYS_APTITUDE" ];then
        _verstrg=$(callErrOutWrapper $LINENO $BASH_SOURCE ${CTYS_APTITUDE} -V show xen-hypervisor|sed -n 's/^..*xen-hypervisor-\(..*\)/\1/p')
	if [ -n "${_verstrg}" ];then
	    _verstrg=${_verstrg%-*}
	    case $_verstrg in
		"3.2-1")_verstrg="xen-${_verstrg}";;
		"3.2"*)_verstrg="xen-3.2";;
		"3."*)_verstrg="xen-3.x";;
		*)_verstrg="xen-x";;
	    esac
	    XEN_PREREQ="${XEN_PREREQ} ${_verstrg}-DetectedVersionBy(rpm)"
	fi
    fi


    #
    #ask syscap, from the originator, sometime a little casual
    #
    if [ -z "${_verstrg}" ];then
	if [ -e "${_syscap}" ];then
	    _verstrg=`cat ${_syscap}`;
	    _verstrg=${_verstrg%% *};
	    if [ -n "${_verstrg}" ];then
		XEN_PREREQ="${XEN_PREREQ} <${_verstrg}-from(${_syscap// /_})>"
	    fi
	fi
    fi

    #
    #ask virsh, try to guess, but just once with virsh
    #
    if [ -z "${_verstrg}" ];then
	if [ -n "${VIRSH}" ];then
	    _Xverstrg=`callErrOutWrapper $LINENO $BASH_SOURCE ${XENCALL} ${VIRSH} version|awk '/Running hypervisor/{print $3 " " $4}'`
	    case $_Xverstrg in
		"XenProxy 3.358.115")_verstrg="xen-3.0.3";;
		"XenProxy 3."*)_verstrg="xen-3.x";;
		*)_verstrg="xen-x";;
	    esac
	    XEN_PREREQ="${XEN_PREREQ} ${_verstrg}-DetectedVersionBy(virsh->${_Xverstrg// /_})"
	fi
    fi

    _verstrg=${_verstrg// /};
    _verstrg=${_verstrg//;/};
    _verstrg=${_verstrg//,/};
    if [ -n "${_verstrg}" -a "${_verstrg}" != "${_verstrg//[0-9]/}" ];then
	echo "${_verstrg}";
    fi
}



#FUNCBEG###############################################################
#NAME:
#  getXENMAGIC
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Fetch version info for machine-processing.
#
#EXAMPLE:
#
#PARAMETERS:
#      
#
#OUTPUT:
#  RETURN:
#   0: OK
#   1: NOK
#  VALUES:
#   Returns the value of XEN_MAGIC, for now:
#     XEN_303       :xen-3.0.3*
#     XEN_30        :xen-3.0-x86_64*,xen-3.0-i386*,xen-3.0-*
#     XEN_32x       :xen-3.2-*
#     XEN_310       :xen-3.1.0*
#     XEN_31x       :xen-3.1*
#     XEN_3x        :xen-3*
#   Else
#     NOLOCC        :*
#
#FUNCEND###############################################################
function getXENMAGIC () {
    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "\$*=<${*}>"
    local _lv=$(getVersionStrgXEN)
    local _m=;
    case ${_lv} in
	[xX][eE][nN]-3.0.3*)      _m=XEN_303;;
	[xX][eE][nN]-3.0-x86_64*) _m=XEN_30;;
	[xX][eE][nN]-3.0-i386*)   _m=XEN_30;;
	[xX][eE][nN]-3.0-*)       _m=XEN_30;;
	[xX][eE][nN]-3.1.0*)      _m=XEN_310;;
	[xX][eE][nN]-3.1*)        _m=XEN_31x;;
	[xX][eE][nN]-3.2-1*)      _m=XEN_321;;
	[xX][eE][nN]-3.2-*)       _m=XEN_32x;;
	[xX][eE][nN]-3*)          _m=XEN_3x;;
	[xX][eE][nN]-*)           _m=XEN_GENERIC;;
        *)                        echo -n NOLOC;return 1;;
    esac
    echo -n $_m
}




#FUNCBEG###############################################################
#NAME:
#  getACCELERATOR_XEN
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Returns the available accelerator.
#
#
#EXAMPLE:
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#   0: OK
#   1: NOK
#  VALUES:
#   <accelerator>
#     HVM
#      Returns this when HVM support is available.
#     PARA
#      Paravirtualization only.
#
#FUNCEND###############################################################
function getACCELERATOR_XEN () {
    local _syscap=/sys/hypervisor/properties/capabilities
    local _cap=;
    if [ -e "${_syscap}" ];then
	_cap=$(cat ${_syscap});
	if [ "${_cap}" != "${_cap//hvm/}" ];then
	    echo -n "HVM"
	    return
	fi
    fi
    echo -n "PARA"
    return
}


#FUNCBEG###############################################################
#NAME:
#  getHYPERRELRUN_XEN
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Returns the versionstring of current hypervisor/emulator.
#
#EXAMPLE:
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#   0: OK
#   1: NOK
#  VALUES:
#FUNCEND###############################################################
function getHYPERRELRUN_XEN () {
    getVersionStrgXEN
}






#FUNCBEG###############################################################
#NAME:
#  getSTARTERCALL_XEN4CONF
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Returns the executable from configuration file.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: name of configurationfile - either *.ctys of *.conf      
#
#OUTPUT:
#  RETURN:
#   0: OK
#   1: NOK
#  VALUES:
#FUNCEND###############################################################
function getSTARTERCALL_XEN4CONF () {
    echo -n "${XM}"
}


#FUNCBEG###############################################################
#NAME:
#  getHYPERRELRUN_XEN4CONF
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Returns the versionstring of current hypervisor/emulator.
#
#EXAMPLE:
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#   0: OK
#   1: NOK
#  VALUES:
#FUNCEND###############################################################
function getHYPERRELRUN_XEN4CONF () {
    getVersionStrgXEN
}

#FUNCBEG###############################################################
#NAME:
#  getACCELERATOR_XEN4CONF
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
function getACCELERATOR_XEN4CONF () {
    getACCELERATOR_XEN
}



#FUNCBEG###############################################################
#NAME:
#  getARCH_XEN
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Returns the available "maximum" architecture.
#
#
#EXAMPLE:
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#   0: OK
#   1: NOK
#  VALUES:
#   <accelerator>
#     i386
#     x86_64
#
#FUNCEND###############################################################
function getARCHR_XEN () {
    local _syscap=/sys/hypervisor/properties/capabilities
    local _cap=;

    if [ -e "${_syscap}" ];then
	_cap=$(cat ${_syscap});
	if [ "${_cap}" != "${_cap//x86_64/}" ];then
	    echo -n "x86_64"
	    return
	fi
	echo -n "i386"
	return
    fi

    if [ -n "$XM" ];then
	_cap=$(${XM} info|awk '/xen_caps/{print;}');
	if [ "${_cap}" != "${_cap//x86_64/}" ];then
	    echo -n "x86_64"
	    return
	fi
	echo -n "i386"
	return
    fi

}
