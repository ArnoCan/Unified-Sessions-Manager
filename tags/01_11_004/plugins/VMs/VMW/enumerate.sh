#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_09_001
#
########################################################################
#
# Copyright (C) 2007,2008 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

_myPKGNAME_VMW_ENUMERATE="${BASH_SOURCE}"
_myPKGVERS_VMW_ENUMERATE="01.06.001a09"
hookInfoAdd $_myPKGNAME_VMW_ENUMERATE $_myPKGVERS_VMW_ENUMERATE
_myPKGBASE_VMW_ENUMERATE="`dirname ${_myPKGNAME_VMW_ENUMERATE}`"


#FUNCBEG###############################################################
#NAME:
#  enumerateMySessionsVMW
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Enumerates all VMW sessions, therefore the vmx-files will be scanned
#  and the matched attributes displayed.
#
#  Therefore the following order of files will be scanned for values:
#
#    1. <pname>
#       The standard configuration file for VM, as given.
#
#    2. <pname-prefix>.ctys
#       The prefix of given filename with the ".ctys" suffix.
#
#    3. <pname-dirname>.ctys
#       The dirname of given file with ".ctys" suffix.
#
#  In each case the searched key is expected to have the prefix "#@#" 
#  within the file.
#
#  For detailed interface description refer to genric dispatcher.
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
#
#FUNCEND###############################################################
function enumerateMySessionsVMW () {
    printDBG $S_VMW ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=${@}"

    local _myMAC=;
    local _myMAClst=;
    local _myIP=;
    local _myIPlst=;

    local _base="${*//\%/ }"
    _base=${_base:-$HOME $RS_PREFIX_R $RS_PREFIX_L}
    printDBG $S_VMW ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_base=${_base}"

    #just for safety ...
    if [ -z "${_base}" ];then
 	ABORT=1
 	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing base for search: Check your path/file call-parameters.";
	gotoHell ${ABORT}
    fi


    . ${MYLIBPATH}/lib/libVMWconf.sh

    #This value is defined as anchor to be supported from VMs config file!!!
    function getMAClst_VMW () {
        #might be cached already, don't forget to reset for each record!!!
        if [ -n "${_myMAC}" ];then
	    echo ${_myMAC}
	    return
        fi
	getVMWMAClst "${1}"
    }


    #ID/PNAME should be shown as unique and unambiguos ID, ready to be used
    #Make each base absolut, if not yet
    local _i2=;
    local _baseabs=;
    for _i2 in ${_base};do
	_i2="${_i2//\~/$HOME}"
	if [ "${_i2#/}" == "${_i2}" ];then
	    _baseabs="${_baseabs} ${PWD}/${_i2}"
	else
	    _baseabs="${_baseabs} ${_i2}"
	fi
	local X=;
	printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_baseabs=${_baseabs}"
	if [ ! -f "${_myPKGBASE_VMW_ENUMERATE}/enumfilter.awk" ];then
 	    ABORT=1
 	    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing:${_myPKGBASE_VMW_ENUMERATE}/enumfilter.awk";
	    gotoHell ${ABORT}
	fi
	printDBG $S_VMW ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:Use MATCH-FILTER:${_myPKGBASE_VMW_ENUMERATE}/enumfilter.awk";

    done

    checkPathElements FIND-PATH ${_baseabs// /:}
    {
	local _curbase=
	for _curbase in ${_baseabs};do
	    find ${_curbase} -name '*.vmx' \
		-exec awk -F'=' -v matchMin=5 -f ${_myPKGBASE_VMW_ENUMERATE}/enumfilter.awk {} \; \
		-print 2>/dev/null
	    local ret=$?;
            if [  $ret -ne 0  ];then
		echo "VMW:Partial access error/check permissions:$MYUID@$MYHOST with \"find ${_curbase} ...(ret=$ret)\"">&2
            fi
	done
    }|\
    while read X;do
        CURRENTENUM=${X};
        local _out=;
    	printDBG $S_VMW ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:MATCH=${X}"
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
		_out="${_out}VMW";
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
		echo ${_out}
	    else
		local _cont="";

		case $VMW_MAGIC in
		    VMW_P1*);;
		    VMW_S1*);;
		    VMW_S20)
			local _ib=;

			_ib=$(ctysVMWS2ConvertToDatastore $X)
			if [ -n "$_ib" ];then
 			    _cont="STORAGE:${_ib}"
 			    _cont="${_cont// /%}"
 			    _cont="${_cont//[/}";_cont="${_cont//]/}"
			fi

			_ib=$(ctysVMWS2FetchVMWObjID4Path $X)
			if [ -n "$_ib" ];then
 			    _cont="${_cont:+$_cont,}OID:${_ib}"
			fi
    			printDBG $S_VMW ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:_cont=${_cont}"
			;;
		    VMW_WS[567]*);;
                esac
                local _out1=;
		_out1="${MYHOST}"; 
		_out1="${_out1};`getVMWLABEL ${X}`";
		_out1="${_out1};${X}";
		_out1="${_out1};`getVMWUUID ${X}`";
		#_out="${_out};`getMAC ${X}`";
                local _out2=;
		_out2="${_out2};";
		_out2="${_out2};`getVMWVNCACCESSPORT  ${X}`";
		_out2="${_out2};";
		_out2="${_out2};";
		#_out="${_out};`getIP ${X}`";
                local _out3=;
		_out3="${_out3};VMW";
		_out3="${_out3};`getDIST ${X}`";
		_out3="${_out3};`getDISTREL ${X}`";

                local _ostrial=`getOS ${X}`;
                if [ -z "$_ostrial" ];then
                    #even though might be something like "other"
		    _ostrial="`getVMWOS ${X}`";
		fi
		_out3="${_out3};${_ostrial}";

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
		_out4="${_out4};${VMW_VMWAREVERSION}";
		_out4="${_out4};";
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
		_out7="${_out7};`getGUESTARCH ${X}`";
		_out7="${_out7};`getGUESTPLATFORM ${X}`";
		_out7="${_out7};`getVMWGUESTVRAM ${X}`";
		_out7="${_out7};`getVMWGUESTVCPU ${X}`";

		_out7="${_out7};VERSION:${VMW_PRODVERS},${_cont}`getCONTEXTSTRING ${X}`";
		_out7="${_out7%,}";

		_out7="${_out7};`getUSERSTRING ${X}`";

		local i=0;
		_myMAC=`getMAClst_VMW ${X}`;
		printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_myMAC=${_myMAC}";

		_myIP=`getIPlst ${X}`;
		printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_myIP=${_myIP}";

		local _myIFlst=`getIFlst INTERFACES "${_myMAC}" "${_myIP}"`
		local i3=;
		local _out=;

		printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_myIFlst=<${_myIFlst}>";
		if [ -n "${_myIFlst// /}" ];then
		    for i3 in $_myIFlst;do
			local _confmac=$(echo ${i3%=*}|tr 'a-z' 'A-Z');
			_out="${_out1};${_confmac}${_out2}";
			i3=${i3#*=};

			local A[0]=${i3%%\%*};i3=${i3#*\%};
			A[1]=${i3%%\%*};i3=${i3#*\%};
			A[2]=${i3%%\%*};i3=${i3#*\%};
			A[3]=${i3%%\%*};i3=${i3#*\%};
			A[4]=${i3%%\%*};i3=${i3#*\%};
			A[5]=${i3%%\%*};

			local _macCheck=$(${MYLIBEXECPATH}/ctys-macmap.sh ${C_DARGS} -p ${DBPATHLST} "${A[0]}")
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
			printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_out=<${_out}>";
			echo -e "${_out}"
		    done
		else
		    _out="${_out1};${_out2};${_out3};;${_out4};${_out5};;;${_out7}"
  		    printDBG $S_VMW ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_out=<${_out}>";
		    echo -e "${_out}"
		fi
		_myMAC=; #reset cache
		_myIP=;  #reset cache
	    fi
	fi
    done
}



