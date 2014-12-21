#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_009
#
########################################################################
#
# Copyright (C) 2007,2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

_myPKGNAME_PM_ENUMERATE="${BASH_SOURCE}"
_myPKGVERS_PM_ENUMERATE="01.11.009"
hookInfoAdd $_myPKGNAME_PM_ENUMERATE $_myPKGVERS_PM_ENUMERATE


#FUNCBEG###############################################################
#NAME:
#  enumerateMySessionsPM
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Enumerates all PM sessions, therefore the vmx-files will be scanned
#  and the matched attributes displayed.
#
#  For detailed interface descritpion refer to genric dispatcher.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: <basename-list>=<basename>[%<basename-list>]
#
#GLOBALS:
#OUTPUT:
#  RETURN:
#  VALUES:
#    standard enumerate output format
#
#FUNCEND###############################################################
function enumerateMySessionsPM () {
    printDBG $S_PM ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=${@}"

    case "${MYOS}" in
	Linux);;
	FreeBSD|OpenBSD);;
	SunOS);;
	*)
	    printDBG $S_PM ${D_BULK} $LINENO $_BASE_PM "${FUNCNAME}:OS not supported by PM:${MYOS}"
	    return
	    ;;
    esac

    local _base="${*//\%/ }"
    _base=${_base:-$DEFAULT_ENUM_BASE}
    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_base=${_base}"

    #just for sureness ...
    if [ -z "${_base}" ];then
 	ABORT=1
 	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing base for search: Check your path/file call-parameters.";
	gotoHell ${ABORT}
    fi

    #ID/PNAME should be shown as unique and unambiguos ID, ready to be used
    #Make each base absolut, if not yet
    local _i2=;
    local X=;
    local _baseabs=;
    for _i2 in ${_base};do
	_i2="${_i2//\~/$HOME}"
	if [ "${_i2#/}" == "${_i2}" ];then
	    _baseabs="${_baseabs} ${PWD}/${_i2}"
	else
	    _baseabs="${_baseabs} ${_i2}"
	fi
    done
    _baseabs="${_baseabs## }"
    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_baseabs=${_baseabs}"
    checkPathElements FIND-PATH ${_baseabs// /:}
    {
	printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:#@#MAGICID-${MYOS}"
	local _curbase=
	for _curbase in ${_baseabs};do
	    find ${_curbase} -type f -name '*.conf' \
		-exec grep -q "#@#MAGICID-${MYOS}" {} \; \
		-print 2>/dev/null
	    local ret=$?;
            if [  $ret -ne 0  ];then
		echo "PM:Partial access error/check permissions:$MYUID@$MYHOST with \"find ${_curbase} ...(ret=$ret)\"">&2
            fi
	done
    }|\
    while read X;do
        CURRENTENUM=${X};
        local _out=;
    	printDBG $S_PM ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:MATCH=${X}"
 	if [ -f "${X}" ];then
	    if [ ! -r "${X}" ];then
		_out="${MYHOST}";#
		_out="${_out};"; 
		_out="${_out};";
		_out="${_out};";
		_out="${_out};";
		_out="${_out};";
		_out="${_out};";
		_out="${_out};";
		_out="${_out};";
		_out="${_out};";
		_out="${_out}$(getVMinfo.sh);";#
#		_out="${_out}PM;";#
		_out="${_out};";
		_out="${_out};";
		_out="${_out};";
		_out="${_out};";
		_out="${_out};";
		_out="${_out};";
		_out="${_out};";
		_out="${_out};";
		_out="${_out};";
		_out="${_out};";#
		_out="${_out};";
		_out="${_out};";
		_out="${_out};";
		_out="${_out};";
		_out="${_out};";
		_out="${_out};";
		_out="${_out};";
		_out="${_out};";
		_out="${_out};";
		_out="${_out};";#
		_out="${_out};";
		_out="${_out};";
		_out="${_out};";
		_out="${_out};";
		_out="${_out};";
		_out="${_out};";
		_out="${_out};";
		_out="${_out};";
		_out="${_out};";
		_out="${_out};";#
		_out="${_out};";
		_out="${_out};";
		_out="${_out};";
		_out="${_out};";
                echo "${_out}"
	    else
                local _out1=;
		_out1="${MYHOST}"; 
		_out1="${_out1};`getLABEL ${X}`";
		_out1="${_out1};${X}";
		_out1="${_out1};`getUUID ${X}`";
		#_out="${_out};`getMAC ${X}`";
                local _out2=;
		_out2="${_out2};";
		_out2="${_out2};`getVNCACCESSPORT ${X}`";
		_out2="${_out2};";
		_out2="${_out2};";
		#_out="${_out};`getIP ${X}`";
                local _out3=;
		_out3="${_out3};$(getVMinfo.sh)";
#		_out3="${_out3};PM";
		_out3="${_out3};`getDIST ${X}`";
		_out3="${_out3};`getDISTREL ${X}`";
		_out3="${_out3};`getOS ${X}`";
		_out3="${_out3};`getOSREL ${X}`";
		_out3="${_out3};`getVERNO ${X}`";
		_out3="${_out3};`getSERNO ${X}`";
		_out3="${_out3};`getCATEGORY ${X}`";
		_out3="${_out3};`getVMSTATE ${X}`";
		_out3="${_out3};`getHYPERREL ${X}`";
		_out3="${_out3};`getSTACKCAP ${X}`";
		_out3="${_out3};`getSTACKREQ ${X}`";
		_out3="${_out3};`getHWCAP ${X}`";
		_out3="${_out3};`getHWREQ ${X}`";
		_out3="${_out3};`getEXECLOCATION ${X}`";
		_out3="${_out3};`getRELOCCAP ${X}`";
		printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_out3=<${_out3}>";

		#_out3="${_out3};`getSSHPORT  ${X}`";
                local _out4=;
		#NETNAME:_out4="${_out4};";
		_out4="${_out4};";
		_out4="${_out4};$PM_ACCELERATOR";
		_out4="${_out4};";
		_out4="${_out4};";
                 #_out="${_out};`getGUESTIFNAME ${X}`";
                local _out5=;
		_out5="${_out5};`getCTYSRELEASE ${X}`";
                 #_out="${_out};`getGUESTNETMASK ${X}`";
                local _out6=;
		#_out6="${_out6};`getGATEWAY ${X}`";
		#_out5="${_out5};`getRELAY ${X}`";
                local _out7=;
		_out7="${_out7};`getGUESTARCH ${X}`";#
		_out7="${_out7};`getGUESTPLATFORM ${X}`";
		_out7="${_out7};`getGUESTVRAM ${X}`";
		_out7="${_out7};`getGUESTVCPU ${X}`";
		_out7="${_out7};`getCONTEXTSTRING ${X}`";
		_out7="${_out7};`getUSERSTRING ${X}`";

		_out8=;
		_out8="${_out8};${MYUID}";
		_out8="${_out8};${MYGID}";
		_out8="${_out8};${PM_DEFAULT_HOSTS}";
		_out8="${_out8};${PM_DEFAULT_CONSOLE}";


		local _myIFlst=`getIFlst ID ${X}`
		local i3=;
		local _out=;

		printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_myIFlst=<${_myIFlst}>";
		if [ -n "${_myIFlst// /}" ];then
		    for i3 in $_myIFlst;do
			 printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:i3=<${i3}>";
			_out="${_out1};${i3%=*}${_out2}";
			i3=${i3#*=};

			local A[0]=${i3%%\%*};i3=${i3#*\%};
			 A[1]=${i3%%\%*};i3=${i3#*\%};
			 A[2]=${i3%%\%*};i3=${i3#*\%};
			 A[3]=${i3%%\%*};i3=${i3#*\%};
			 A[4]=${i3%%\%*};i3=${i3#*\%};
			 A[5]=${i3%%\%*};

			 local _myNetName=`netGetNetName "${A[0]}"`
			 _out="${_out};${A[0]}${_out3};${A[4]};${_myNetName}${_out4};${A[3]}${_out5};${A[1]};${A[5]};${A[2]}${_out7}${_out8}"
			 printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_out=<${_out}>";
			 echo -e "${_out}"
		    done
		else
		    _out="${_out1};${_out2};${_out3};;${_out4};${_out5};;;${_out7}${_out8}"
		    printDBG $S_PM ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_out=<${_out}>";
		    echo -e "${_out}"
 		fi
		_myMAC=; #reset cache
		_myIP=;  #reset cache
	    fi
	fi
    done
}
