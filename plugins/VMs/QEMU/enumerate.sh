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
# Copyright (C) 2007,2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

_myPKGNAME_QEMU_ENUMERATE="${BASH_SOURCE}"
_myPKGVERS_QEMU_ENUMERATE="01.10.008"
hookInfoAdd $_myPKGNAME_QEMU_ENUMERATE $_myPKGVERS_QEMU_ENUMERATE
_myPKGBASE_QEMU_ENUMERATE="`dirname ${_myPKGNAME_QEMU_ENUMERATE}`"


#FUNCBEG###############################################################
#NAME:
#  enumerateMySessionsQEMU
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Enumerates all QEMU sessions, therefore the vmx-files will be scanned
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
#
#  VALUES:
#    standard enumerate output format
#
#FUNCEND###############################################################
function enumerateMySessionsQEMU () {
    printDBG $S_QEMU ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=${@}"

    local _myMAC=;
    local _myIP=;

    local _base="${*//\%/ }"
    _base=${_base:-$DEFAULT_ENUM_BASE}
    printDBG $S_QEMU ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_base=${_base}"

    #just for sureness ...
    if [ -z "${_base}" ];then
 	ABORT=1
 	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing base for search: Check your path/file call-parameters.";
	gotoHell ${ABORT}
    fi
    function getGUESTVRAM_QEMU () {
	local _IP=;
	for i in `getConfFilesList "${1}"`;do
	    _IP=`cat  "${i}"|sed -n 's/.* -m *\([0-9]*\)[^0-9]*/\1/p'`
            if [ "$_IP" != "" ];then
		printDBG $S_QEMU ${D_DATA} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from ${i}"
		break;
	    fi
	done
	if [ -z "${_IP// /}" ];then
	    _IP=128;
	fi
	if [ -n "${_IP// /}" ];then
	    printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_IP=${_IP} from ${1}"
	    echo ${_IP##* }
            return
	fi
	getGUESTVRAM "${1}"
    }

    function getGUESTVCPU_QEMU () {
	local _IP=;
	for i in `getConfFilesList "${1}"`;do
	    _IP=`cat  "${i}"|sed -n 's/-smp *\([0-9]*\)/\1/p'`
            if [ "$_IP" != "" ];then
		printDBG $S_QEMU ${D_DATA} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from ${i}"
		break;
	    fi
	done
	if [ -z "${_IP// /}" ];then
	    _IP=1;
	fi
	if [ -n "${_IP// /}" ];then
	    printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_IP=${_IP} from ${1}"
	    echo ${_IP##* }
            return
	fi
	getGUESTVCPU_QEMU ${1}
    }



    #ID/PNAME should be shown as unique and unambiguos ID, ready to be used
    #Make each base absolut, if not yet
    local _i2=;
    local X=;
    local _baseabs=;
    local _basen=;
    for _i2 in ${_base};do
	_i2="${_i2//\~/$HOME}"
	if [ "${_i2#/}" == "${_i2}" ];then
	    _baseabs="${_baseabs} ${PWD}/${_i2}"
	else
	    _baseabs="${_baseabs} ${_i2}"
	fi
    done
    _baseabs="${_baseabs## }"
    printDBG $S_QEMU ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_baseabs=${_baseabs}"
    if [ ! -f "${_myPKGBASE_QEMU_ENUMERATE}/enumfilter.awk" ];then
 	ABORT=1
 	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing:${_myPKGBASE_QEMU_ENUMERATE}/enumfilter.awk";
	gotoHell ${ABORT}
    fi
    printDBG $S_QEMU ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:MATCH-FILTER=${_myPKGBASE_QEMU_ENUMERATE}/enumfilter.awk";
    local _out=;
    local _lastX=;
    checkPathElements FIND-PATH ${_baseabs// /:}
    {
	local _curbase=
	for _curbase in ${_baseabs};do
	    find ${_curbase} -type f -name '*.ctys' \
		-exec awk -F'=' -v matchMin=4 -f ${_myPKGBASE_QEMU_ENUMERATE}/enumfilter.awk {} \; \
		-print 2>/dev/null
		local ret=$?;
		if [  $ret -ne 0  ];then
		    echo "QEMU:Partial access error/check permissions:$MYUID@$MYHOST with \"find ${_curbase} ...(ret=$ret)\"">&2
		fi
	done
    }|\
    while read X;do
        CURRENTENUM=${X};
	_out=;
    	printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:MATCH=${X}"

	local _X1="${X##*/}";
	local _X2="${_lastX##*/}";

	if [ "${_X1%%.*}" == "${_X2%%.*}" ];then
	    ABORT=1;
    	    printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:MATCH=${X} == LASTMATCH=${_lastX}"
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Configuration-Redundancy: CURRENTMATCH == LASTMATCH"
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:LASTMATCH    =($_X2)${_lastX}"
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:CURRENTMATCH =($_X1)${X}"
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:CURRENTMATCH is ignored."
	    _lastX=${X};
	    continue;
	fi
	_lastX=${X};

 	if [ -f "${X}" ];then
	    if [ ! -r "${X}" ];then
		_out="${MYHOST}";
		_out="${_out};";  
		_out="${_out};";  
		_out="${_out};";  
		_out="${_out};";  
		_out="${_out};";  
		_out="${_out};";  
		_out="${_out};";  
		_out="${_out};";  
		_out="${_out};";  
		_out="${_out}QEMU";
		_out="${_out};";  
		_out="${_out};";  
		_out="${_out};";  
		_out="${_out};";  
		_out="${_out};";  
		_out="${_out};";  
		_out="${_out};";  
		_out="${_out};";  
		_out="${_out};";  
		_out="${_out};";
		_out="${_out};";  
		_out="${_out};";  
		_out="${_out};";  
		_out="${_out};";  
		_out="${_out};";  
		_out="${_out};";  
		_out="${_out};";  
		_out="${_out};";  
		_out="${_out};";  
		_out="${_out};";  
		_out="${_out};";  
		_out="${_out};";  
		_out="${_out};";  
		_out="${_out};";  
		_out="${_out};";  
		_out="${_out};";  
		_out="${_out};";  
		_out="${_out};";  
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
		_out2="${_out2};`getVNCACCESSDISPLAY ${X}`";
		_out2="${_out2};`getVNCACCESSPORT  ${X}`";
		_out2="${_out2};`getSPORT ${X}`";
		_out2="${_out2};`getVNCBASEPORT  ${X}`";
		#_out="${_out};`getIP ${X}`";
                local _out3=;
		_out3="${_out3};QEMU";
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
		#_out3="${_out3};`getSSHPORT  ${X}`";
                local _out4=;
		#NETNAME:_out4="${_out4};";
		_out4="${_out4};`getHYPERRELRUN_QEMU4CONF ${X}`";
		_out4="${_out4};`getACCELLERATOR_QEMU4CONF ${X}`";
		_out4="${_out4};`getSTARTERCALL_QEMU4CONF ${X}`";
		_out4="${_out4};";
                 #_out="${_out};`getGUESTIFNAME ${X}`";
                local _out5=;
		_out5="${_out5};`getCTYSRELEASE ${X}`";
                 #_out="${_out};`getGUESTNETMASK ${X}`";
                local _out6=;
		#_out6="${_out6};`getGATEWAY ${X}`";
		#_out5="${_out5};`getRELAY ${X}`";
                local _out7=;
		_out7="${_out7};`getGUESTARCH ${X}`";
		_out7="${_out7};`getGUESTPLATFORM ${X}`";
		_out7="${_out7};`getGUESTVRAM_QEMU ${X}`";
		_out7="${_out7};`getGUESTVCPU_QEMU ${X}`";
		_out7="${_out7};`getCONTEXTSTRING ${X}`";
		_out7="${_out7};`getUSERSTRING ${X}`";

		local i=0;
		_myMAC=`getMAClst ${X}`;
		printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_myMAC=${_myMAC}";

		_myIP=`getIPlst ${X}`;
		printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_myIP=${_myIP}";

		local _myIFlst=`getIFlst INTERFACES "${_myMAC}" "${_myIP}"`
		local i3=;
		local _out=;

		printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_myIFlst=<${_myIFlst}>";
		if [ -n "${_myIFlst// /}" ];then
		    for i3 in $_myIFlst;do
			local _confmac=$(echo ${i3%=*}|tr 'a-z' 'A-Z');
			_out="${_out1};${i3%=*}${_out2}";
			i3=${i3#*=};

			local A[0]=${i3%%\%*};i3=${i3#*\%};
			A[1]=${i3%%\%*};i3=${i3#*\%};
			A[2]=${i3%%\%*};i3=${i3#*\%};
			A[3]=${i3%%\%*};i3=${i3#*\%};
			A[4]=${i3%%\%*};i3=${i3#*\%};
			A[5]=${i3%%\%*};

			local _macCheck=$(${MYLIBEXECPATH}/ctys-macmap.sh ${C_DARGS} -p ${DBPATHLST} "${A[0]};")
			local _ipCheck=${_macCheck##*;}
			_macCheck=${_macCheck#*;};_macCheck=${_macCheck%;*};_macCheck=$(echo $_macCheck|tr 'a-z' 'A-Z');

			if [ -n "${_ipCheck}" -a -n "${_macCheck}" -a -n "${_confmac}"  -a "${_macCheck}" != "${_confmac}" ];then
			    printWNG  1 $LINENO $BASH_SOURCE 1 "Inconsistent MAC-IP-pair found for ${X}:"
			    printWNG  1 $LINENO $BASH_SOURCE 1 "->From Config-File: IP=\"${A[0]}\" MAC=\"${_confmac}\""
			    printWNG  1 $LINENO $BASH_SOURCE 1 "->From Database:    IP=\"${A[0]}\" MAC=\"${_macCheck}\""
			    printWNG  1 $LINENO $BASH_SOURCE 1 "Check your database with:"
			    printWNG  1 $LINENO $BASH_SOURCE 1 "${MYLIBEXECPATH}/ctys-macmap.sh ${C_DARGS} -p ${DBPATHLST} \"${A[0]}\""
			fi

			local _myNetName=$(netGetNetName "${A[0]}")

			_out="${_out};${A[0]}${_out3};${A[4]};${_myNetName}${_out4};${A[3]}${_out5};${A[1]};${A[5]};${A[2]}${_out7}"
			printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_out=<${_out}>";
			echo -e "${_out}"
		    done
		else
		    _out="${_out1};${_out2};${_out3};;${_out4};${_out5};;;${_out7}"
		    printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_out=<${_out}>";
		    echo -e "${_out}"
		fi
		_myMAC=; #reset cache
		_myIP=;  #reset cache
            fi
	fi
    done
}
