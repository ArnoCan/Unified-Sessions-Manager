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
# Copyright (C) 2007,2008,2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

_myPKGNAME_XEN_ENUMERATE="${BASH_SOURCE}"
_myPKGVERS_XEN_ENUMERATE="01.11.009"
hookInfoAdd $_myPKGNAME_XEN_ENUMERATE $_myPKGVERS_XEN_ENUMERATE
_myPKGBASE_XEN_ENUMERATE="`dirname ${_myPKGNAME_XEN_ENUMERATE}`"


#FUNCBEG###############################################################
#NAME:
#  enumerateMySessionsXEN
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Enumerates all XEN sessions, therefore the vmx-files will be scanned
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
function enumerateMySessionsXEN () {
    printDBG $S_XEN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=${@}"

    local _myMAC=;
    local _myMAClst=;
    local _myIP=;
    local _myIPlst=;


    local _base="${*//\%/ }"
    _base=${_base:-$DEFAULT_ENUM_BASE}
    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_base=${_base}"

    #just for sureness ...
    if [ -z "${_base}" ];then
 	ABORT=1
 	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing base for search: Check your path/file call-parameters.";
	gotoHell ${ABORT}
    fi


    function getGUESTVRAM_XEN () {
	local _IP=;
	for i in `getConfFilesList "${1}"`;do
	    _IP=`cat  "${i}"|getConfValueOf "memory"`
            if [ "$_IP" != "" ];then
		printDBG $S_XEN ${D_DATA} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from ${i}"
		break;
	    fi
	done
	if [ -n "${_IP// /}" ];then
	    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_IP=${_IP} from ${1}"
	    echo ${_IP##* }
            return
	fi
	getGUESTVRAM "${1}"
    }

    function getGUESTVCPU_XEN () {
	local _IP=;
	for i in `getConfFilesList "${1}"`;do
	    _IP=`cat  "${i}"|getConfValueOf "vcpus"`
            if [ "$_IP" != "" ];then
		printDBG $S_XEN ${D_DATA} $LINENO $BASH_SOURCE "$FUNCNAME:${_IP} from ${i}"
		break;
	    fi
	done
	if [ -n "${_IP// /}" ];then
	    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_IP=${_IP} from ${1}"
	    echo ${_IP##* }
            return
	fi
	getGUESTVCPU "${1}"
    }



    #avoids of multiple rescans when MAPDB enabled.
    local _curMACCache=;


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
    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_baseabs=${_baseabs}"
    if [ ! -f "${_myPKGBASE_XEN_ENUMERATE}/enumfilter.awk" ];then
 	ABORT=1
 	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing:${_myPKGBASE_XEN_ENUMERATE}/enumfilter.awk";
	gotoHell ${ABORT}
    fi
    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:MATCH-FILTER=${_myPKGBASE_XEN_ENUMERATE}/enumfilter.awk";
    local _out=;
    local _count=0;
    checkPathElements FIND-PATH ${_baseabs// /:}
    {
	local _curbase=
	for _curbase in ${_baseabs};do
 	    find ${_curbase} -type f  \( -name '*.conf' -o -name '*.ctys' \) \
		-exec awk -F'=' -v matchMin=4 -f ${_myPKGBASE_XEN_ENUMERATE}/enumfilter.awk {} \; \
		-print 2>/dev/null

		local ret=$?;
		if [  $ret -ne 0  ];then
		    echo "XEN:Partial access error/check permissions:$MYUID@$MYHOST with \"find ${_curbase} ...(ret=$ret)\"">&2
		fi
	done
    }|\
    while read X;do
        CURRENTENUM=${X};
        _curMACCache="";
	_out=;
    	printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:MATCH($((_count++)))=${X}"
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
		_out="${_out}XEN";
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
		_out="${_out};";  
		_out="${_out};";  
                echo "${_out}"
	    else
                local _out1=;
		_out1="${MYHOST}"; 
		_out1="${_out1};`getLABEL_XEN ${X}`";
		_out1="${_out1};${X}";
		_out1="${_out1};`getUUID_XEN ${X}`";
		#_out="${_out};`getMAC ${X}`";
                local _out2=;
		_out2="${_out2};";
		_out2="${_out2};";
		_out2="${_out2};";
		_out2="${_out2};";
		#_out="${_out};`getIP ${X}`";
                local _out3=;
		_out3="${_out3};XEN";
		_out3="${_out3};`getDIST ${X}`";
		_out3="${_out3};`getDISTREL ${X}`";
		_out3="${_out3};`getOS ${X}`";
		_out3="${_out3};`getOSREL ${X}`";
		_out3="${_out3};`getVERNO ${X}`";
		_out3="${_out3};`getSERNO ${X}`";
		#_out3="${_out3};`getCATEGORY ${X}`";
		_out3="${_out3};VM";
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
		_out4="${_out4};$(getHYPERRELRUN_XEN4CONF )";
		_out4="${_out4};$(getACCELERATOR ${X})";
		_out4="${_out4};$(getSTARTERCALL ${X})";
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
		_out7="${_out7};`getGUESTVRAM_XEN ${X}`";
		_out7="${_out7};`getGUESTVCPU_XEN ${X}`";
		_out7="${_out7};`getCONTEXTSTRING ${X}`";
		_out7="${_out7};`getUSERSTRING ${X}`";

		_out8=;
		_out8="${_out8};${MYUID}";
		_out8="${_out8};${MYGID}";

		local _myHosts=$(getDEFAULTHOSTS ${X})
		_out8="${_out8};${_myHosts:-$XEN_DEFAULT_HOSTS}";
		local _myCon=$(getDEFAULTCONSOLE ${X})
		_out8="${_out8};${_myCon:-$XEN_DEFAULT_CONSOLE}";

		local i=0;
		_myMAC=`getMAClst_XEN ${X}`;
		printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_myMAC=${_myMAC}";

		_myIP=`getIPlst ${X}`;
		printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_myIP=${_myIP}";

		local _myIFlst=`getIFlst INTERFACES "${_myMAC}" "${_myIP}"`
		local i3=;
		local _out=;

		printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_myIFlst=<${_myIFlst}>";
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

			local _macCheck=$(${MYLIBEXECPATH}/ctys-macmap.sh ${C_DARGS} -p ${DBPATHLST} "${A[0]}\;")
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

			 _out="${_out};${A[0]}${_out3};${A[4]};${_myNetName}${_out4};${A[3]}${_out5};${A[1]};${A[5]};${A[2]}${_out7}${_out8}"
			 printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_out=<${_out}>";
			 echo -e "${_out}"
		    done
		else
		    _out="${_out1};${_out2};${_out3};;${_out4};${_out5};;;${_out7}${_out8}"
		    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_out=<${_out}>";
		    echo  -e "${_out}"
		fi
		_myMAC=; #reset cache
		_myIP=;  #reset cache
	    fi
	fi
    done
}
