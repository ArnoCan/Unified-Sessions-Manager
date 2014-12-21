#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_018
#
########################################################################
#
# Copyright (C) 2008,2010,2011 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

_myPKGNAME_CACHE="${BASH_SOURCE}"
_myPKGVERS_CACHE="01.11.018"
hookInfoAdd "$_myPKGNAME_CACHE" "$_myPKGVERS_CACHE"

#
#Cache for process data, valid only for current process
myProcCache=;

#FUNCBEG###############################################################
#NAME:
#  cacheGetUniquePname
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Searches the cache for a unique match. 
#  When a unique match occurs "0" and additionally the value is echoe-ed.
#  if no-match occur's just "0" and an empty string is returned.
#
#  In case of ambiguity this call terminates.
#
#EXAMPLE:
#PARAMETERS:
# $1: <base>
#     standard format, seperated by "%", when not available an empty string
#     has to be provided.
#
# $2:   Container address for location of data for requested VM.
#       Current version supports TCP/IP addresses only, which will be matched literally 
#       only as stored within the cacheDB.
#       The following three variants are supported:
#
#       -> "FROMCALL"
#          Extracts the execution target from the call.
#          This results in MYHOST when executed locally, which has to be matched
#          literally within the cacheDB.
#
#       -> <valid-host-address>
#          Just takes the string as given
#
#       -> NONE
#          Will be ignored.
#
# $3:  PLUGIN
#
# $4-* <rest-of-match-key-list>
#
#OUTPUT:
#  RETURN:
#   0: OK
#
#  VALUES:
#   PNAME: when OK
#
#FUNCEND###############################################################
function cacheGetUniquePname () {
    local _org=$*;
    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=<${@}>"

    if((C_NSCACHELOCATE==0));then
	printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:Nameservice is noncached:"
	printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:  C_NSCACHELOCATE=0"
	return 0
    fi

    if((C_NSCACHELOCATE==3&&C_EXECLOCAL!=1));then
	printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:Nameservice is not on execution site:"
	printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:  C_NSCACHELOCATE=$C_NSCACHELOCATE"
	return 0
    fi

    if((C_NSCACHELOCATE==2&&C_EXECLOCAL==1));then
	printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:Nameservice is not on callers site:"
	printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:  C_NSCACHELOCATE=$C_NSCACHELOCATE"
	return 0
    fi

    local base=$1;shift
    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:base=<${base}>"

    local exectarget=$1;shift
    [ "$exectarget" == NONE ]&&exectarget=;
    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:exectarget=<${exectarget}>"

    local _exeplugin=$1;shift
    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_exeplugin=<${_exeplugin}>"

    #################
    #fetch host
    #
    case "$exectarget" in
	FROMCALL)
	    _exehost=`digGetSSHTarget ${_org}`
	    if [ -z "${_exehost}" ];then
		_exehost=`digGetCTYSTarget ${_org}`
		if [ -z "${_exehost}" ];then
		    _exehost=${MYHOST}
		fi
	    fi
	    ;;
    esac
    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:exectarget=<${_exehost}>"
    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:Nameservice is in cached mode"
    local _VHOST="${MYLIBEXECPATH}/ctys-vhost.sh ${C_DARGS} -C MACMAP -o IDS -p ${DBPATHLST} -s -M unique"
    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_VHOST=$_VHOST"
    if [ -n "${base// /}" ];then
        #has basename list
	local _i9=;
	local _idx=0;
	for _i9 in ${base//%/ };do
	    if [ -n "${exectarget}" ];then
		local _call="${_VHOST} ${C_DARGS} F:1:${exectarget}  ${_exeplugin:+F:2:$_exeplugin} ${_i9} ${@} not E:28:1 ";
		_pname=$(${_call});
		local _ret=$?;
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_call=<${_call}> => <${_pname}>"
	    else
		local _call="${_VHOST} ${C_DARGS} ${_i9} ${@} not E:28:1 ";
		_pname=$(${_call});
		local _ret=$?;
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_call=<${_call}> => <${_pname}>"
	    fi
	    if [ $_ret -ne 0 ];then
		printERR $LINENO $BASH_SOURCE ${_ret} "$FUNCNAME:Called:    \"${_call}\""
		printERR $LINENO $BASH_SOURCE ${_ret} "$FUNCNAME:Check with: $(setSeverityColor TRY unset \"-s\" option) and $(setSeverityColor TRY set \"ctys-vhost -M all\" option)"
		if [ $_ret -eq 1 ];then
		    printERR $LINENO $BASH_SOURCE ${_ret} "$FUNCNAME:Parameter error:"
		fi
		if [ $_ret -eq 2 ];then
		    printERR $LINENO $BASH_SOURCE ${_ret} "$FUNCNAME:Missing a file, check your cacheDB, and/or"
		    printERR $LINENO $BASH_SOURCE ${_ret} "$FUNCNAME:deactivate nameservice-caching, refer to $(setSeverityColor TRY \"ctys -c\" option)."
		fi
		if [ $_ret -eq 10 ];then
		    printERR $LINENO $BASH_SOURCE ${_ret} "$FUNCNAME:Missing \"macmap.fdb\" for mapping of TCP/IP addresses"
		    printERR $LINENO $BASH_SOURCE ${_ret} "$FUNCNAME:to MAC-Addresses"
		fi
		if [ $_ret -eq 11 ];then
		    printERR $LINENO $BASH_SOURCE ${_ret} "$FUNCNAME:Requested result from local cache is ambiguous, check"
		    printERR $LINENO $BASH_SOURCE ${_ret} "$FUNCNAME: your cacheDB, and/or deactivate nameservice-caching:"
		    printERR $LINENO $BASH_SOURCE ${_ret} "$FUNCNAME: ->remote/local site"
		    printERR $LINENO $BASH_SOURCE ${_ret} "$FUNCNAME: ->for all"
		    printERR $LINENO $BASH_SOURCE ${_ret} "$FUNCNAME:for additional info refer to \"-c\" option."
		fi
		return ${_ret}
	    fi
	    if [ -n "${_pname}" ];then
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:MATCH-PNAME=${_pname}"
		let _idx++;
	    fi
	    if((_idx>1));then
		ABORT=11;
		printERR $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:Requested result from local cache is ambiguous:"
		printERR $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:base=\"${base}\" => for=\"${base//%/ }\""
		printERR $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:\"${_VHOST} ${_org}\""
		return ${ABORT}
	    fi
	done
    else

	if [ -n "${exectarget}" ];then
	    local _call="${_VHOST} ${C_DARGS} F:1:${exectarget} ${_exeplugin:+F:2:$_exeplugin} ${@} not E:28:1 ";
	    printFINALCALL 1  $LINENO $BASH_SOURCE "FINAL-WRAPPER-SCRIPT-CALL" "${_call}"
	    _pname=$(${_call});
            local _ret=$?;
	    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_call=<${_call}> => <${_pname}>"
	else
	    local _call="${_VHOST} ${C_DARGS} ${@} not E:28:1 ";
	    _pname=$(${_call});
            local _ret=$?;
	    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_call=<${_call}> => <${_pname}>"
	fi
	if [ $_ret -ne 0 ];then
	    printERR $LINENO $BASH_SOURCE ${_ret} "$FUNCNAME:Called:     \"${_VHOST} ${exectarget}  ${@}\""
	    printERR $LINENO $BASH_SOURCE ${_ret} "$FUNCNAME:Check with: no \"-s\" and \"-M all\""
	    if [ $_ret -eq 1 ];then
		printERR $LINENO $BASH_SOURCE ${_ret} "$FUNCNAME:Parameter error:"
	    fi
	    if [ $_ret -eq 2 ];then
		printERR $LINENO $BASH_SOURCE ${_ret} "$FUNCNAME:  Missing a file, check your cacheDB, and/or"
		printERR $LINENO $BASH_SOURCE ${_ret} "$FUNCNAME:  deactivate nameservice-caching, refer to \"-c\" option."
	    fi
	    if [ $_ret -eq 10 ];then
		printERR $LINENO $BASH_SOURCE ${_ret} "$FUNCNAME:  Missing \"macmap.fdb\" for mapping of TCP/IP addresses"
		printERR $LINENO $BASH_SOURCE ${_ret} "$FUNCNAME:  to MAC-Addresses"
	    fi
	    if [ $_ret -eq 11 ];then
		printERR $LINENO $BASH_SOURCE ${_ret} "$FUNCNAME:  Requested result from local cache is ambiguous, check"
		printERR $LINENO $BASH_SOURCE ${_ret} "$FUNCNAME:  your cacheDB, and/or deactivate nameservice-caching,"
		printERR $LINENO $BASH_SOURCE ${_ret} "$FUNCNAME:  refer to \"-c\" option."
	    fi
	    return ${_ret}
	fi
    fi

    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_pname=<${_pname}>"
    echo -n -e "${_pname}"
    return 0
}


#FUNCBEG###############################################################
#NAME:
#  cacheGetActionUserFromCall
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  This fuction requires the cacheDB mandatorily.
#
#EXAMPLE:
#PARAMETERS:
# $1:   Requested Component in accordance to <machine-address>
#
#        <user>@<host>                :USER
#        -l <user>                    :USER
#
# $2:   Container address for location of data for requested VM.
#       Current version supports TCP/IP addresses only, which will be matched literally 
#       only as stored within the cacheDB.
#       The following three variants are supported:
#
#       -> "FROMCALL"
#          Extracts the execution target from the call.
#          This results in MYHOST when executed locally, which has to be matched
#          literally within the cacheDB.
#
# $3-*: <complete-call>
#        Evaluates the plugins:
#          QEMU,XEN,VMW,PM
#        Replaces the suboptions for:
#          CREATE, CANCEL
#
#
#OUTPUT:
#  RETURN:
#  
#  VALUES:
#   <exec-user>
#
#FUNCEND###############################################################
function cacheGetActionUserFromCall () {
    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=<${@}>"
    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:C_NSCACHELOCATE=${C_NSCACHELOCATE}"
    local _myRequest=$1;shift
    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:REQUEST=${_myRequest}"
    local _origin=$1;shift
    local _org=$*;

    #################
    #fetch host
    #
    local _exeuser=;
    case "$_origin" in
	FROMCALL)
	    _exeuser=`digGetSSHUser ${_org}`
	    if [ -z "${_exeuser}" ];then
		_exeuser=`digGetCTYSTargetUser ${_org}`
	    fi
	    ;;
    esac

    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_exeuser      =<${_exeuser}>"
    if [ -z "${_exeuser}" ];then
	_exeuser=$MYUID;
    fi
    echo -n -e ${_exeuser}
}


#FUNCBEG###############################################################
#NAME:
#  cacheGetMachineAddressFromCall
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  This fuction requires the cacheDB mandatorily.
#
#EXAMPLE:
#PARAMETERS:
# $1:   Requested Component in accordance to <machine-address>
#
#        <basepath>                   :BASEPATH|BASE|B
#        <TCP/IP>                     :TCP|T
#        <Mac-Addr>                   :MAC|M                    
#        <uuid>                       :UUID|U
#        <label>                      :LABEL|L
#        <pathname>                   :ID|I|PATHNAME|PNAME|P
#        <filename>                   :FILENAME|FNAME|F
#        <machine-address>            :MACHINEADDRESS|MADDR
#        <machine-addres-components>  :VHOST
#
#       In addition to the common attributes the following specific formats
#       are supported:
#
#        <machine-address>
#         a collection of the complete set of available parts of machine address 
#         for current input. The short-keys are used for the comma seperated list.
#
#        <machine-addres-components>
#         The same content and semantics as for <machine-address>, but prepared 
#         for an AND based chained query by ctys-vhost.sh.
#
#       The latter types provide data components as present, thus ignore 
#       intermediate resolution and mapping errors for sub-parts.
#       Anyhow, even though the resulting output-string is valid and may be 
#       sufficienttly sized for uniqueness, the return code will indicate 
#       intermediate conversion errors, but may be frequently ignored.
#
#
# $2:   Container address for location of data for requested VM.
#       Current version supports TCP/IP addresses only, which will be matched literally 
#       only as stored within the cacheDB.
#       The following three variants are supported:
#
#       -> "FROMCALL"
#          Extracts the execution target from the call.
#          This results in MYHOST when executed locally, which has to be matched
#          literally within the cacheDB.
#
#       -> <valid-host-address>
#          Just takes the srting as given
#
#       -> NONE
#          Will be ignored.
#
# $3-*: <complete-call>
#        Evaluates the plugins:
#          QEMU,XEN,VMW,PM
#        Replaces the suboptions for:
#          CREATE, CANCEL
#
#
#OUTPUT:
#  RETURN:
#  
#  VALUES:
#   <complete-call-with-cofig-filepath>
#
#FUNCEND###############################################################
function cacheGetMachineAddressFromCall () {
    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=<${@}>"
    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:C_NSCACHELOCATE=${C_NSCACHELOCATE}"
    local _myRequest=$1;shift
    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:REQUEST=${_myRequest}"
    local _exehost=$1;shift
    [ "$_exehost" == NONE ]&&_exehost=;

    local _org="${*}"
    local _actionuser=$(cacheGetActionUserFromCall USER FROMCALL $_org)

    #################
    #fetch host
    #
    case "$_exehost" in
	FROMCALL)
	    _exehost=`digGetSSHTarget ${_org}`
	    if [ -z "${_exehost}" ];then
		_exehost=`digGetCTYSTarget ${_org}`
		if [ -z "${_exehost}" ];then
		    _exehost=${MYHOST}
		fi
	    fi
	    ;;
    esac
    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_exehost      =<${_exehost}>"

    local _org=${*};
    case $C_NSCACHELOCATE in
	0|3)
	    echo -n "${_org}"
	    return 1
	    ;;
    esac
    
    local _ret=0;
    local _exeplugin=;
    local _exeaction=;
    local _exeasubargs=;
    local _ctysaddr=;
    local _buf=;
    local _pname=;




    #################
    #fetch plugin
    #
    _buf="${_org##* -t}";
    if [ "${_org}" != "${_buf}" ];then
        _buf="${_buf## }";
        _exeplugin="${_buf%% *}";
    else
        _exeplugin="VNC";
    fi
    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_exeplugin=<${_exeplugin}>"
    if [ -z "$_exeplugin" ];then
	echo -n "$_org"
	return 1
    fi

    case ${_exeplugin//\"} in
	[vV][nN][cC]|[cC][lL][iI]|[rR][dD][pP]|[xX]11)
	    echo -n "$_org"
	    return 1
	    ;;
    esac

    #################
    #check action
    #
    _buf="${_org##*-a}";
    if [ "${_org}" != "${_buf}" ];then
        _buf="${_buf## }";
        _exeaction="${_buf%% *}";
        _exeaction="${_exeaction%%=*}";
        _exeaction="${_exeaction##[\"\#]}";
        _buf="${_buf##*=}";
        _exeasubargs="${_buf%% *}";
	_exeaction=${_exeaction//\"}
    else
	_ret=1;
	printERR $LINENO $BASH_SOURCE ${_ret} "Missing action:"
	printERR $LINENO $BASH_SOURCE ${_ret} "\"${_org}\""
	return ${_ret}
    fi
    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_buf=<${_buf}>"
    if [ -z "$_buf" ];then
	echo -n "$_org"
	return 1
    fi


    case ${_exeaction} in
	[cC][rR][eE][aA][tT][eE])
	    ;;
	[cC][aA][nN][cC][eE][lL])
	    ;;
	*)
	    echo -n "$_org"
	    return 1
	    ;;
    esac
    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_exeaction    =<${_exeaction}>"
    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_exeasubargs  =<${_exeasubargs}>"


    #################
    #now _exeasubargs contains subargs of CREATE/CANCEL only
    #
    local _new=;
    A=`cliSplitSubOpts ${_exeasubargs}`
    for i in $A;do
	KEY=`cliGetKey ${i}`
	ARG=`cliGetArg ${i}`
        if [ -n "${ARG}" ];then
	    case $KEY in
		DBRECORD|DBREC|DR)
		    local _dbrec="${ARG}";
		    printDBG $S_VMW ${D_UID} $LINENO $BASH_SOURCE "DBRECORD=${_dbrec}"
		    ;;
		BASEPATH|BASE|B)
		    local _base="${ARG}";
		    printDBG $S_CORE ${D_UID} $LINENO $BASH_SOURCE "BASE=${_base}"
		    ;;
		TCP|T)
		    local _tcp="${ARG}";
		    printDBG $S_CORE ${D_UID} $LINENO $BASH_SOURCE "TCP=${_tcp}"
		    let _unambig+=1;
		    ;;
		MAC|M)
		    local _mac="${ARG}";
		    printDBG $S_CORE ${D_UID} $LINENO $BASH_SOURCE "MAC=${_mac}"
		    let _unambig+=1;
		    ;;
		UUID|U)
		    local _uuid="${ARG}";
 		    printDBG $S_CORE ${D_UID} $LINENO $BASH_SOURCE "UUID=${_uuid}"
		    let _unambig+=1;
		    ;;
		LABEL|L)
		    local _label="${ARG}";
 		    printDBG $S_CORE ${D_UID} $LINENO $BASH_SOURCE "LABEL=${_label}"
		    let _unambig+=1;
		    ;;
		FILENAME|FNAME|F)
		    local _fname="${ARG}";
		    printDBG $S_CORE ${D_UID} $LINENO $BASH_SOURCE "FILENAME=${_fname}"
		    let _unambig++;
		    ;;
		ID|I|PATHNAME|PNAME|P)
		    if [ -n "${ARG##/*}" ]; then
			_ret=1;
			printERR $LINENO $BASH_SOURCE ${_ret} "PNAME has to be an absolute path, use fname else."
			printERR $LINENO $BASH_SOURCE ${_ret} " PNAME=${ARG}"
 			return ${_ret}
		    fi
		    local _idgiven=1;
		    _pname=${ARG}
		    printDBG $S_CORE ${D_UID} $LINENO $BASH_SOURCE "PATHNAME=${_pname}"
		    ;;
	    esac
	else
	    case $KEY in
		ALL)
		    case $C_NSCACHELOCATE in
			2)
			    if [ -z "$C_EXECLOCAL" -a "$C_NSCACHEONLY" == 1 ];then
				return 1
			    fi
			    ;;
		    esac
		    return
		    ;;
	    esac
	fi

    done
    


    local _VHOST="${MYLIBEXECPATH}/ctys-vhost.sh ${C_DARGS} -p ${DBPATHLST} -s -M unique"
    local _klist="${_exehost} ${_exeplugin} ${_pname}  ${_tcp} ${_mac} ${_uuid} ${_label} ${_fname}"
    #################
    #
    case $C_NSCACHELOCATE in
	1|2)
	    if [ -z "${_pname}" ];then
		if [ -n "${_dbrec}" ];then
		    local _VHOST="${MYLIBEXECPATH}/ctys-vhost.sh ${C_DARGS} -p ${DBPATHLST} -s "
		    _pname=`${_VHOST} -o PNAME R:${_dbrec}`
		else

 		    local _klist="${_exehost} ${_exeplugin} ${_pname}  ${_tcp} ${_mac} ${_uuid} ${_label} ${_fname}"
  		    _klist="${_klist//\'}"
		    _pname=`cacheGetUniquePname "${_base}" ${_exehost:-NONE} "${_exeplugin}" ${_klist//\"}  ${_actionuser:+ F:44:$_actionuser}`
		fi
		if [ $? -ne 0 ];then
		    _ret=1;
		    printERR $LINENO $BASH_SOURCE ${_ret} "$FUNCNAME:Cannot fetch unique pathname, analyse with "
		    printERR $LINENO $BASH_SOURCE ${_ret} "$FUNCNAME:  \"ctys-vhost.sh -M all ...\""
		    return $_ret
		fi
	    fi
	    ;;
    esac
    #
    #PNAME should be present here, else there might be few, or no chance.
    #
    function _getBASEPATH () {
	if [ -n "${_base}" ];then
	    echo -n -e "${_base}"
	    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_base=<${_base}>"
	else
	    let _ret++;
	    return 1
	fi
    }

    function _getTCP  () {
	local _lret=0;
	if [ -z "${_tcp}" ];then
	    if [ -n "${_dbrec}" ];then
		local _VHOST="${MYLIBEXECPATH}/ctys-vhost.sh ${C_DARGS} -p ${DBPATHLST} -s "
		_tcp=`${_VHOST} -o TCP R:${_dbrec}`
		_lret=$?;
	    else
		if [ -n "${_mac}" ];then
		    _VHOST="${_VHOST} ${C_DARGS} -C MACMAP  -o TCP ${_mac}"
		    _VHOST="${_VHOST} ${_actionuser:+ F:44:$_actionuser}"
		    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_VHOST=<${_VHOST}>"
 		    _tcp=`${_VHOST}`
		    _lret=$?;
		else
		    _VHOST="${_VHOST} ${C_DARGS} -o TCP E:28:1 ${_klist}"
		    _VHOST="${_VHOST} ${_actionuser:+ F:44:$_actionuser}"
		    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_VHOST=<${_VHOST}>"
 		    _tcp=`${_VHOST}`
		    _lret=$?;
		fi
	    fi
	fi
	if [ -n "${_tcp}" ];then
	    echo -n -e "${_tcp}"
	else
	    let _ret+=_lret;
	    return $_lret
	fi
    }

    function _getMAC  () {
	local _lret=0;
	if [ -z "${_mac}" ];then
	    if [ -n "${_dbrec}" ];then
		local _VHOST="${MYLIBEXECPATH}/ctys-vhost.sh ${C_DARGS} -p ${DBPATHLST} -s "
		_mac=`${_VHOST} -o MAC R:${_dbrec}`
		_lret=$?;
	    else
		if [ -n "${_tcp}" ];then
		    _VHOST="${_VHOST} ${C_DARGS} -o MAC E:28:1 ${_tcp}"
		    _VHOST="${_VHOST} ${_actionuser:+ F:44:$_actionuser}"
		    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_VHOST=<${_VHOST}>"
 		    _mac=`${_VHOST}`
		    _lret=$?;
		else
		    _VHOST="${_VHOST} ${C_DARGS} -o MAC E:28:1 ${_klist}"
		    _VHOST="${_VHOST} ${_actionuser:+ F:44:$_actionuser}"
		    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_VHOST=<${_VHOST}>"
 		    _mac=`${_VHOST}`
		    _lret=$?;
		fi
	    fi
	fi
	if [ -n "${_mac}" ];then
	    echo -n -e "${_mac}"

	    	else
	    let _ret+=_lret;
	    return $_lret
	fi
    }

    function _getUUID  () {
	local _lret=0;
	if [ -z "${_uuid}" ];then
	    if [ -n "${_dbrec}" ];then
		local _VHOST="${MYLIBEXECPATH}/ctys-vhost.sh ${C_DARGS} -p ${DBPATHLST} -s "
		_uuid=`${_VHOST} -o UUID R:${_dbrec}`
		_lret=$?;
	    else
		_VHOST="${_VHOST} ${C_DARGS} -o UUID E:28:1 ${_klist}"
		_VHOST="${_VHOST} ${_actionuser:+ F:44:$_actionuser}"
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_VHOST=<${_VHOST}>"
 		_uuid=`${_VHOST}`
		_lret=$?;
	    fi
	fi
	if [ -n "${_uuid}" ];then
	    echo -n -e "${_uuid}"
# 	    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_uuid=<${_uuid}>"
	else
	    let _ret+=_lret;
	    return $_lret
	fi
    }

    function _getLABEL  () {
	local _lret=0;
	if [ -z "${_label}" ];then
	    if [ -n "${_dbrec}" ];then
		local _VHOST="${MYLIBEXECPATH}/ctys-vhost.sh ${C_DARGS} -p ${DBPATHLST} -s "
		_label=`${_VHOST} -o LABEL R:${_dbrec}`
		_lret=$?;
	    else
		_VHOST="${_VHOST} ${C_DARGS} -o UUID E:28:1 ${_klist}"
		_VHOST="${_VHOST} ${_actionuser:+ F:44:$_actionuser}"
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_VHOST=<${_VHOST}>"
 		_label=`${_VHOST}`
		_lret=$?;
	    fi
	fi
	if [ -n "${_label}" ];then
	    echo -n -e "${_label}"
	    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_label=<${_label}>"
	else
	    let _ret+=_lret;
	    return $_lret
	fi
    }

    function _getPATHNAME  () {
	if [ -n "${_pname}" ];then
	    echo -n -e "${_pname}"
	    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_pname=<${_pname}>"
	else
	    if [ -n "${_dbrec}" ];then
		local _VHOST="${MYLIBEXECPATH}/ctys-vhost.sh ${C_DARGS} -p ${DBPATHLST} -s "
		_pname=`${_VHOST} -o PNAME R:${_dbrec}`
		return $?;
	    else

		_VHOST="${_VHOST} ${C_DARGS} -o PNAME  -p ${DBPATHLST} -s ${_klist}"
		_VHOST="${_VHOST} ${_actionuser:+ F:44:$_actionuser}"
		printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_VHOST=<${_VHOST}>"
 		_pname=`${_VHOST}`
		_lret=$?;
		return $?;

# 		let _ret++;
# 		return 1
	    fi
	fi
    }

    function _getFILENAME  () {
	if [ -z "${_fname}" ];then
	    if [ -z "${_pname}" -a -n "$_dbrec" ];then
		_pname=$(_getPATHNAME )
	    fi
	    _fname="${_pname##*/}";
	fi
	if [ -n "${_fname}" ];then
	    echo -n -e "${_fname}"
	    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_fname=<${_fname}>"
	else
	    let _ret++;
	    return 1
	fi
    }

    case ${_myRequest} in
	BASEPATH|BASE|B)_getBASEPATH;;
	TCP|T)_getTCP;;
	MAC|M)_getMAC;;
	UUID|U)_getUUID;;
	LABEL|L)_getLABEL;;
	ID|I|PATHNAME|PNAME|P)_getPATHNAME;;
	FILENAME|FNAME|F)_getFILENAME;;
	MACHINEADDRESS|MADDR)
	    local _resultBuf=;
	    local _rf=;
	    _rf=`_getBASEPATH`;  if [ -n "$_rf" ];then _resultBuf="${_resultBuf},B:${_rf}"; fi
	    _rf=`_getTCP`;       if [ -n "$_rf" ];then _resultBuf="${_resultBuf},T:${_rf}"; fi
	    _rf=`_getMAC`;       if [ -n "$_rf" ];then _resultBuf="${_resultBuf},M:${_rf}"; fi
	    _rf=`_getUUID`;      if [ -n "$_rf" ];then _resultBuf="${_resultBuf},U:${_rf}"; fi
	    _rf=`_getLABEL`;     if [ -n "$_rf" ];then _resultBuf="${_resultBuf},L:${_rf}"; fi
	    _rf=`_getPATHNAME`;  if [ -n "$_rf" ];then _resultBuf="${_resultBuf},P:${_rf}"; fi
	    _rf=`_getFILENAME`;  if [ -n "$_rf" ];then _resultBuf="${_resultBuf},F:${_rf}"; fi
	    _resultBuf="${_resultBuf#,}";
	    if [ $_ret -eq 0 ];then
		echo -n -e "${_resultBuf}"
	    fi
# 	    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_resultBuf=<${_resultBuf}>"
	    ;;
	VHOST)#temporary workaround for still missing MADDR in ctys-vhost.sh
	    local _resultBuf=;
	    local _rf=;
	    _rf=`_getBASEPATH`;  if [ -n "$_rf" ];then _resultBuf="${_resultBuf} ${_rf}"; fi
	    _rf=`_getTCP`;       if [ -n "$_rf" ];then _resultBuf="${_resultBuf} ${_rf}"; fi
	    _rf=`_getMAC`;       if [ -n "$_rf" ];then _resultBuf="${_resultBuf} ${_rf}"; fi
	    _rf=`_getUUID`;      if [ -n "$_rf" ];then _resultBuf="${_resultBuf} ${_rf}"; fi
	    _rf=`_getLABEL`;     if [ -n "$_rf" ];then _resultBuf="${_resultBuf} ${_rf}"; fi
	    _rf=`_getPATHNAME`;  if [ -n "$_rf" ];then _resultBuf="${_resultBuf} ${_rf}"; fi
	    _rf=`_getFILENAME`;  if [ -n "$_rf" ];then _resultBuf="${_resultBuf} ${_rf}"; fi
	    if [ $_ret -eq 0 ];then
		echo -n -e "${_resultBuf}"
	    fi
	    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_resultBuf=<${_resultBuf}>"
	    ;;
    esac
    return $_ret
}




#FUNCBEG###############################################################
#NAME:
#  cacheReplaceCtysAddress
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  If CACHEDOP is set, than evaluates a given final single-target call 
#  for configuration based plugins and replaces the ctys-address 
#  within it's suboption by it's correponding configuration filepath.
#
#
#EXAMPLE:
#PARAMETERS:
# $*: <complete-call>
#     Evaluates the plugins:
#       QEMU,XEN,VMW,PM
#     Replaces the suboptions for:
#       CREATE, CANCEL
#
#OUTPUT:
#  RETURN:
#  
#  VALUES:
#   <complete-call-with-cofig-filepath>
#
#FUNCEND###############################################################
function cacheReplaceCtysAddress () {
    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=<${@}>"
    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:C_NSCACHELOCATE=${C_NSCACHELOCATE}"

    case $C_NSCACHELOCATE in
	0)
	    echo -n "$*"
	    return
	    ;;
	3)
	    if [ -z "C_EXECLOCAL" ];then
		echo -n "$*"
		return 
	    fi
	    ;;
    esac
    local _org=$*;
    
    local _ret=0;
    local _pname=;
    local _exehost=;
    local _exeplugin=;
    local _exeaction=;
    local _exeasubargs=;
    local _ctysaddr=;
    local _buf=;



    #################
    #fetch plugin
    #
    _buf="${_org##* -t}";
    if [ "${_org}" != "${_buf}" ];then
        _buf="${_buf## }";
        _exeplugin="${_buf%% *}";
    else
        _exeplugin="VNC";
    fi
    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_exeplugin    =<${_exeplugin}>"
    if [ -z "$_exeplugin" ];then
	echo -n "$_org"
	return
    fi

    case ${_exeplugin//\"} in
	[vV][nN][cC]|[cC][lL][iI]|[rR][dD][pP]|[xX]11)
	    echo -n "$_org"
	    return
	    ;;
    esac

    #################
    #check action
    #
    _buf="${_org##*-a}";
    if [ "${_org}" != "${_buf}" ];then
        _buf="${_buf## }";
        _exeaction="${_buf%% *}";
        _exeaction="${_exeaction%%=*}";
        _exeaction="${_exeaction##[\"\#]}";
        _buf="${_buf##*=}";
        _exeasubargs="${_buf%% *}";
    else
	_ret=1;
	printERR $LINENO $BASH_SOURCE ${_ret} "Missing action:"
	printERR $LINENO $BASH_SOURCE ${_ret} "\"${_org}\""
	return ${_ret}
    fi
    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_buf=<${_buf}>"
    if [ -z "$_buf" ];then
	echo -n "$_org"
	return
    fi

    case ${_exeaction//\"} in
	[cC][rR][eE][aA][tT][eE])
	    ;;
	[cC][aA][nN][cC][eE][lL])
	    ;;
	*)
	    echo -n "$_org"
	    return
	    ;;
    esac
    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_exeaction    =<${_exeaction}>"
    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_exeasubargs  =<${_exeasubargs}>"

    _maddr=$(cacheGetMachineAddressFromCall MACHINEADDRESS FROMCALL $@)
    _ret=$?

    printINFO 2 $LINENO $BASH_SOURCE 0 "($_stime):Resolved <machine-address>=\"${_maddr}\""
    if [ -n "${_maddr// /}" ];then
	_org=${_org//\//\\\/};
	_maddr=${_maddr//\//\\\/}
	printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_org=\"${_org}\""
	printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_maddr=\"${_maddr}\""
	_buf=`echo  " ${_org} "|sed 's/\(.* -a *[^=]*=\)\(.*\)/\1'"${_maddr}"',\2/'`;
#	printDBG $S_CORE ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:Cache-Result:_buf=<${_buf}>"
	echo $_buf
    else
	echo $_org
    fi
    return $_ret
}


#FUNCBEG###############################################################
#NAME:
#  cacheStoreAttrListPersistent
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Stores a set of attributes persistently, which has the syntactical form
#  
#    <attr-id-list>:= <attr-id>=<attr-value>;[<attr-id-list>]
#
#  Each attribute ID conforms to the ctys-configuration syntax:
#
#    <attr-id> := <attr-name>
#
#    REMARK: 
#      To avoid confusion, the match-key:=<attr-id> is generic, thus
#      the literal ctys-configuration entries "#@#<attr-name>" could 
#      be used, as well as any other, such as a short form for cached 
#      attributes for example. Non-Ambiguity is the only requirement.
#
#  The default storage is within the MYTMP directory path and 
#
#
#
#
#the value of a given option into a temporary file attached to
#  the file, the common 
#  configuration file syntax is used.
#
#  For now old-style only of options.
#
#EXAMPLE:
#
#PARAMETERS:
# $1:   <file-name>
#       Relative filename only.
# $2:   SHAREDCOPY|PRIVATE
#
# $3-*: <attr-id-list>
#
#
#OUTPUT:
#  RETURN:
#   0: OK
#   1: NO-OPT
#   2: NO-FILE
#  VALUES:
#    value provided with option
#
#FUNCEND###############################################################
function cacheStoreAttrListPersistent () {
    printDBG $S_LIB ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=<${@}>"
    local _myOutFile="${1}";shift
    local _share="${1}";shift
    case "${_share}" in
	SHAREDCOPY)_share=1;;
	*)_share=0;;
    esac

    local _myOut="${MYTMP}/${_myOutFile}";
    local _myOutShared="${MYTMPSHARED}/${_myOutFile}";

    if [ "$USER" != root -a "${_share}" == "1" -a -n "${MYTMPSHARED}" -a -d "${MYTMPSHARED}" ];then
	echo -e "${@}">"${_myOutShared}"
	if [ -n "${CTYS_JOBDATACCESSMODE}" ];then
	    ${CTYS_CHMOD} ${CTYS_JOBDATSHAREDACCESSMODE} "${_myOutShared}"
	else
	    ${CTYS_CHMOD} o-rwx,g+rwx "${_myOutShared}"
	fi
    fi

    if [ -d "${MYTMP}" ];then
	echo -e "${@}">"${_myOut}"
	printDBG $S_LIB ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:Stored in:<${_myOut}>"
	if [ -n "${CTYS_JOBDATACCESSMODE}" ];then
	    ${CTYS_CHMOD} ${CTYS_JOBDATACCESSMODE} "${_myOut}"
	else
	    ${CTYS_CHMOD} o-rwx,g-rwx,u+r "${_myOut}"
	fi
	if [ ! -f "${_myOut}" ];then
	    ABORT=2;
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Cannot create storage file:<${_myOut}>"
	    gotoHell ${ABORT}
	fi
    else
	ABORT=2;
	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing temporary storage:MYTMP=${MYTMP}>"
	gotoHell ${ABORT}
    fi
}


#FUNCBEG###############################################################
#NAME:
#  cacheGetAttrFromPersistent
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
# $1:   LAZY|FORCEREAD
#       Forces to reread cached list from process file.
# $2:   <file-name>
#       Relative filename only.
# $3:   <attr-id>
#
#
#OUTPUT:
#  RETURN:
#   0: OK
#   1: NO-OPT
#   2: NO-FILE
#  VALUES:
#    value provided with option
#
#FUNCEND###############################################################
function cacheGetAttrFromPersistent () {
    printDBG $S_LIB ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=<${@}>"
    local _myProc=${1};shift
    local _myInFile="${1}";shift
    local _myAttr=${1};shift

    local _myIn="${MYTMP}/${_myInFile}";
    local _myInShared="${MYTMPSHARED}/${_myInFile}";

    printDBG $S_LIB ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_myProc     =<${_myProc}>"
    printDBG $S_LIB ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_myIn       =<${_myIn}>"
    printDBG $S_LIB ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_myInShared =<${_myInShared}>"
    printDBG $S_LIB ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_myAttr     =<${_myAttr}>"

    if [ -z "${_myAttr}" ];then
	ABORT=2;
	printERR $LINENO $BASH_SOURCE ${ABORT} "Cannot read storage file:<${_myOut}>"
	return $ABORT
    fi

    if [ ! -f "${_myIn}" -a ! -f "${_myInShared}" ];then
	return
    fi

    if [ -f "${_myIn}" ];then
	case "$_myProc" in
	    FORCEREAD)
		myProcCache=$(cat "${_myIn}");
		;;
	esac

	if [ -z "${myProcCache// /}" ];then
	    myProcCache=$(cat "${_myIn}");
	fi

	if [ -z "${myProcCache// /}" ];then
	    myProcCache=$(cat "${_myInShared}");
	fi

	printDBG $S_LIB ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:myProcCache:<${myProcCache}>"
	if [ -z "${myProcCache}" ];then
	    return
	fi

	local _a=;
	local _buf=;
	local _i=;
	for _i in ${myProcCache//;/ };do
	    [ "${_i%%=*}" != "$_myAttr" ]&&continue;
	    _buf=${_i##*=};
	    break;
	done
    fi
    printDBG $S_LIB ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_buf:<${_buf}>"
    if [ -z "${_buf}" ];then
        #might not be an own task, just display foreigners, if available
	if [ -r "${_myInShared}" ];then
	    local _tmpbuf=$(cat "${_myInShared}");
	    for _i in ${_tmpbuf//;/ };do
		[ "${_i%%=*}" != "$_myAttr" ]&&continue;
		_buf=${_i##*=};
		break;
	    done
	else
	    return
	fi

    fi
    echo -e "${_buf}"
    printDBG $S_LIB ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_buf:<${_buf}>"
}




#FUNCBEG###############################################################
#NAME:
#  cacheStoreWorkerPIDData
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Common function for all non-ps data required additionally.
#
#EXAMPLE:
#PARAMETERS:
#  $1: SERVER|CLIENT
#      Poll SERVER or CLIENT
#  $2: <session-type>
#      The sesion type to be recognized, only one is possible.
#  $3: <id>|""
#      first priority for exclusive search
#  $4: <label>|""
#      used if <id> is absent
#  $5: <recursion counter>
#      has to be set initially to "0"
#  $6: [<file-postfix>]
#      Prevents ambiguity of uncorrelated sources.
#      Specializes storage, e.g. for usage of DomU-IDs as synonoym for PIDs.
#  $7: [(ADD|REPLACE|"")]
#      control behaviour of optional attributes, default=""=ADD
#  $8: [<additional-specific-attributes>]
#      to be appended to/replace the stored attribute list
#      format:
#           <attr-name>=<attr-val>;
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function cacheStoreWorkerPIDData () {
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "${FUNCNAME}:\$@=<${@}>"

    local _cs=${1}
    case "$_cs" in
	SERVER|CLIENT);;
	*)
	    ABORT=1
	    printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Unknown Client-Server-MODE:${_cs}"
	    gotoHell ${ABORT}
	    ;;
    esac

    local _st=${2}
    local _id=${3}
    local _lbl=${4}
    local _rec=${5};
    local _postfix=${6};
    local _mode=${7};
    local _custom=${8};

    local _myAttrLst=;
    local _myAttrLst="${_myAttrLst}JOBID=${CALLERJOB}:$((JOB_IDXSUB++));"
    local _myAttrLst="${_myAttrLst}UID=${MYUID};"
    local _myAttrLst="${_myAttrLst}GID=${MYGID};"
    if [ -n "$_custom" ];then
	case "$_mode" in
	    REPLACE)_myAttrLst="$_custom";;
	    ADD|"")_myAttrLst="${_myAttrLst}${_custom}";;
	    *)
		ABORT=1
		printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Unknown MODE:${_mode}"
		gotoHell ${ABORT}
		;;
	esac
    fi

    if [ -n "$_id" ];then
	local _myServerPID=`listMySessions ${_cs},PKG:${_st},MACHINE|awk -F';' -v i="$_id" '$4~i{printf("%s",$11);}'`
    fi
    if [ -z "$_myServerPID" -a -n "$_lbl" ];then
	local _myServerPID=`listMySessions ${_cs},PKG:${_st},MACHINE|awk -F';' -v l="$_lbl" '$3~l{printf("%s",$11);}'`
    fi

    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "${FUNCNAME}:_myServerPID=<${_myServerPID}>"
    if [ -n "${_myServerPID}" ];then
	cacheStoreAttrListPersistent "${_myServerPID}${_postfix:+.$_postfix}" SHAREDCOPY "${_myAttrLst}"
    else
	let _rec++;
	if((_rec>CTYS_MAXRECURSE));then
	    ABORT=1
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "Cannot get PID for LABEL=\"${_lbl}\""
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "  => JobID will not be displayed in LIST"
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "     _myAttrLst=<${_myAttrLst}>"
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "Either the process requires too long to start:"
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "  => Try first to raise the sleep-timer:"
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "     $(setSeverityColor INF CTYS_MAXRECURSE)=${CTYS_MAXRECURSE}"
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "or failed to start:"
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "  => Try first to repeat only,"
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "     -> particularly for $(setSeverityColor WNG VNCclients)($(setSeverityColor WNG BadAccess-Error)),"
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "        requires CLIENT-start repetition only,"
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "        else may require a complete restart."
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "     else, check for the reason."
	    return ${ABORT}
	fi
	if((_rec>CTYS_PRE_FETCHPID_REPEAT));then
	    ABORT=1
	    printWNG  1 $LINENO $BASH_SOURCE ${ABORT} "Cannot get PID for LABEL=\"${_lbl}\""
	    printINFO 1 $LINENO $BASH_SOURCE ${ABORT} "  => JobID will not be displayed in $(setSeverityColor WNG LIST)"
	    printINFO 1 $LINENO $BASH_SOURCE ${ABORT} "     _myAttrLst=<${_myAttrLst}>"
	    printERR $LINENO $BASH_SOURCE ${ABORT}    "Either the process requires too long to start:"
	    printINFO 1 $LINENO $BASH_SOURCE ${ABORT} "  => Try first to raise the sleep-timer:"
	    printINFO 1 $LINENO $BASH_SOURCE ${ABORT} "     $(setSeverityColor WNG CTYS_PRE_FETCHPID_REPEAT)=${CTYS_PRE_FETCHPID_REPEAT}"
	    printERR $LINENO $BASH_SOURCE ${ABORT}    "or failed to start:"
	    printINFO 1 $LINENO $BASH_SOURCE ${ABORT} "  => Try first to repeat only,"
	    printINFO 1 $LINENO $BASH_SOURCE ${ABORT} "     -> particularly for $(setSeverityColor WNG VNCclients)($(setSeverityColor WNG BadAccess-Error)),"
	    printINFO 1 $LINENO $BASH_SOURCE ${ABORT} "        requires CLIENT-start repetition only,"
	    printINFO 1 $LINENO $BASH_SOURCE ${ABORT} "        else may require a complete restart."

	    case ${VMW_MAGIC} in
		VMW_S2*)
		    printWNG  1 $LINENO $BASH_SOURCE ${ABORT} "or you should hurry up with your login"
		    printINFO 1 $LINENO $BASH_SOURCE ${ABORT} "  => Ignore or restart, and provide your credentials"
		    printINFO 1 $LINENO $BASH_SOURCE ${ABORT} "     within the configured timeout:"
		    printINFO 1 $LINENO $BASH_SOURCE ${ABORT} "      $(setSeverityColor WNG CTYS_PRE_FETCHPID_WAIT)*$(setSeverityColor WNG CTYS_PRE_FETCHPID_REPEAT)=$((CTYS_PRE_FETCHPID_WAIT*CTYS_PRE_FETCHPID_REPEAT))sec"
		    printINFO 1 $LINENO $BASH_SOURCE ${ABORT} "     or customize a longer period."
		    ;;
	    esac
	    printERR $LINENO $BASH_SOURCE ${ABORT}    "else, check for the reason."
	    return ${ABORT}
	fi
	sleep ${CTYS_PRE_FETCHPID_WAIT}
	cacheStoreWorkerPIDData "${_cs}" "${_st}" "${_id}" "${_lbl}" "${_rec}" "${_postfix}" "${_mode}" "${_custom}"
    fi
}
