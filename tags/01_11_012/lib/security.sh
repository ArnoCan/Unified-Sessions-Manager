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
# Copyright (C) 2007,2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

_myLIBNAME_security="${BASH_SOURCE}"
_myLIBVERS_security="01.10.013"
libManInfoAdd "${_myLIBNAME_security}" "${_myLIBVERS_security}"




#FUNCBEG###############################################################
#NAME:
#  fetchSUaccessOpts
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Extracts "-Z" option for USE_KSU and/or USE_SUDO. 
#  
#EXAMPLE:
#GLOBALS:
#  0=>off  1=>on
#
#  USE_KSU=0|1
#  USE_SUDO=0|1
#
#
#PARAMETERS:
#  $*:   cli-args-string
#
#
#OUTPUT:
#  RETURN:
#    0: Success
#    1: Failure
#  VALUES:
#
#FUNCEND###############################################################
function fetchSUaccessOpts () {
    local _CLIARGS=$*

    zopt=`echo " ${_CLIARGS} "|sed -n 's/^[^(]*-Z//;s/ *\([^ ]*\) .*$/\1/p'`

    printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:zopt=\"$zopt\""

    if [ "${zopt//[Nn][Oo][Kk][Ss][Uu]}" != "${zopt}" ];then
	export USE_K5USERS=0;
	printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:USE_K5USERS=$USE_K5USERS"
    else
	if [ "${zopt//[Kk][Ss][Uu]}" != "${zopt}" ];then
	    export USE_K5USERS=1;
	    printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:USE_K5USERS=$USE_K5USERS"
	fi
    fi

    if [ "${zopt//[Nn][Oo][Ss][Uu][Dd][Oo]}" != "${zopt}" ];then
	export USE_SUDO=0;
	printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:USE_SUDO=$USE_SUDO"
    else
	if [ "${zopt//[Ss][Uu][Dd][Oo]}" != "${zopt}" ];then
	    export USE_SUDO=1;
	    printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:USE_SUDO=$USE_SUDO"
	fi
    fi

    if [ "${zopt//[Aa][Ll][Ll]}" != "${zopt}" ];then
	export USE_K5USERS=1;
	export USE_SUDO=1;
	printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:USE_K5USERS=$USE_K5USERS"
	printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:USE_SUDO=$USE_SUDO"
    fi
}


#FUNCBEG###############################################################
#NAME:
#  checkedSetSUaccess
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Due to required root permissions for some calls impersonation aproach
#  either by sudo or ksu should be used for restricted calls. These calls 
#  might be released for call with root permissions selectively by local 
#  impersonation as root or an preconfigured execution-account.
#  The ctys-tools should be executed as a different user without enhanced
#  privileges.
#
#  When using the root account natively no additional permissions are 
#  required of course.
#
#  For ordinary users without enhnaced privileges one of the following two 
#  approaches could be applied:
#
#  - ksu
#    The preferred approach should be the seamless usage of kerberos, 
#    therefore "ksu" with the configuration file ".k5users" should be used.
#
#    For each user the following entry is required:
#
#     "<users-pricipal> /usr/bin/which /usr/sbin/xm /usr/bin/virsh"
#
#    Where the paths may vary.
#
#    Due to the required few calls to which, xm and/or virsh only ".k5login" 
#    is not required.
#
#    The usage of kerberos is activated as default by the variable
#    "USE_K5USERS". When used in companion with SUDO, then kerberos has priority 
#    if configured.
#
#
#  - sudo
#    Basically the same, but to be handled by local configurations on any 
#    machine.
#
#    The usage of sudo is deactivated as default by the variable
#    "unset USE_SUDO". Could be used in combination with kerberos, but has less 
#    priority when k5users is configured.
#
#
#  REMARKS: The given variables will be set "eval" call, even though could
#           be initially set here, no "export" is applied. 
#           So preferably they should be pre-set, just re-/assigned here.
#
#
#  Any preset variable will be kept, but checked for permissions. When a new 
#  impersonation scan has to be performed, the variable must be cleared before.
#
#  
#EXAMPLE:
#
#  XENCALL="${XENCALL:-ksu -e }"
#  XENCALL="${XENCALL:-sudo }"
#
#  VIRSHCALL="${VIRSHCALL:-ksu -e }"
#  VIRSHCALL="${VIRSHCALL:-sudo }"
#
#GLOBALS:
#  0=>off  1=>on
#
#  USE_KSU=0|1
#  USE_SUDO=0|1
#
#
#PARAMETERS:
#
#  The parameters are order dependant and case sensitive, use keywords literally only.
#
#  [$(+1)]:retry
#        Previous set permissions are ignored, whole procedure is repeated.
#
#  [$(+1)]:norootpreference
#        When not set the root permission is seen as given, when the user is named
#        "root", no actual checks are performed.
#        For some cases the call of this function is the final execution too, thus 
#        setting this ignores the actual user and tries actually to execute the given 
#        trial call in any case.
#
#  [$(+1)]:display1
#        The default behaviour of this call is to suppress any output and just return
#        the execution state.
#        For some rare cases the actual result could be of interest which is echoed on
#        stdout, when set this is displayed on stdout.
#
#  [$(+1)]:display2
#        Similar to display1, but displays stderr.
#
#  $(+1):config-file hint
#        Hint to be presented for source of change.
#
#  $(+1):SU-PREFIX-VAR
#        Prefix to be used for impersonalization, content could be empty, than
#        current USER is tested.
#
#  $(+1):SU-CALLEE-VAR
#        The command to be checked for execution permissions.
#
#  $(+1-*):SU-CALLEE-PARAMS
#        Optional parameters to be tested.
#        This is somewhat tricky. Some commands resquire root permissions only for
#        specific parameters accessing restricted system resources. The remaining 
#        set of parameters are accessible for all users.
#
#        Things become somewhat complicated when the test itself performs a critical 
#        call covering the checked permission. 
#
#        So, it has to be decided from case to case how to proceed.
#
#        For example in case of xm from Xen standard package things are somewhat 
#        simpler to handle by "xm info".
#
#
#OUTPUT:
#  RETURN:
#    0: Success
#    1: Failure
#  VALUES:
#
#FUNCEND###############################################################
function checkedSetSUaccess () {
    printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=$@"
    if [ "$1" == retry ];then
	local retry=1;
	shift
    fi

    if [ "$1" == norootpreference ];then
	local norootpref=1;
	shift
    fi

    local disp1=">/dev/null";
    if [ "$1" == display1 ];then
	local disp1=;
	shift
    fi

    local disp2="2>/dev/null";
    if [ "$1" == display2 ];then
	local disp2=;
	shift
    fi

    local _confFile=$1;shift
    local _suPrefix=$1;shift
    if [ -z "${_suPrefix// /}" ];then
	printERR $LINENO $BASH_SOURCE 1  "$FUNCNAME:Internal error, missing parameter"
	gotoHell 1
    fi

    local _suPrefixContent=`eval echo \\\${${_suPrefix}}`

    local _suCallee=$1;shift
    if [ -z "${_suCallee// /}" ];then
	printERR $LINENO $BASH_SOURCE 1  "$FUNCNAME:Internal error, missing parameter"
	gotoHell 1
    fi
    local _suCalleeContent=`eval echo \\\${${_suCallee}}`
    if [ -z "${_suCalleeContent// /}" ];then
	printERR $LINENO $BASH_SOURCE 1  "$FUNCNAME:Internal error, missing content for ${_suCallee}"
	gotoHell 1
    fi
    local _suCalleeArgs=$*

    printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_confFile=$_confFile"
    printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_suPrefix=$_suPrefix"
    printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_suPrefixContent=$_suPrefixContent"
    printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_suCallee=$_suCallee"
    printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_suCalleeContent=$_suCalleeContent"
    printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_suCalleeArgs=$_suCalleeArgs"

    #let this be!
    local _ret=1;

    #if I am root, permissions might not be the question, particularly
    #no entries in k5users and sudoers will be applied.
    #No ID or group membership checked, usage for root-permissions will not be supported.
    if [ "${USER}" == "root" -a -z "$norootpref" ];then
	eval ${_suPrefix}=;
	printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "permission-detected:USER==root"
	printWNG 2 $LINENO $BASH_SOURCE 1  "No ksu/sudo required, USER==root"
	return 0;
    fi

    #
    #Evaluate permissions actually to use, valid for passwd request too!
    #
    if [ -n "${_suPrefixContent}" -a -z "$retry" ];then
        #do the precheck
	_useGIVEN=1;
        case "${_suPrefixContent}" in
	    */sudo*|sudo*)
                #avoid password reuquest
		if [ "$USE_SUDO" == "1" ];then
		    eval ${_suPrefixContent} ${_suCalleeContent} ${_suCalleeArgs} ${disp2} ${disp1}

		    if [ $? -eq 0 ];then
			_useGIVEN=0;
			printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "permission-detected:GIVEN"
			_ret=0;
		    fi
		fi
		;;
	    */ksu*|ksu*)
		if [ "$USE_K5USERS" == "1" ];then
		    eval ${_suPrefixContent} ${_suCalleeContent} ${_suCalleeArgs} ${disp2} ${disp1}
		    if [ $? -eq 0 ];then
			_useGIVEN=0;
			printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "permission-detected:GIVEN"
			_ret=0;
		    fi
		fi
		;;
	    *)
		_useGIVEN=3;
		printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "unknown-permission-detected:GIVEN-UNKNOWN"
		_ret=1;
		;;
	esac
    else
        #
        #Check call, when an entry is found keep this.
        #So, if there is an entry this will be kept in any case, as more distinguished
        #permission, thus seen as more "valuable".
        #
        #Anyhow, still some pitfalls remain, e.g. when sudo feature for distinguished entries 
        #with specific cli-params are utilized.
        #
        #At least for now the distinction wheter a specific parameter requires root permissions for 
        #it's eventually accessed restricted system resource could be solved by current approach.
        #

        #next priority:Kerberos
        if((_ret!=0));then
            #check kerberos
	    if [ "$USE_K5USERS" == "1" ];then
		printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "try KERBEROS"
		local _check="${KSU} -q -e ${_suCalleeContent} ${_suCalleeArgs}"
		printWNG 2 $LINENO $BASH_SOURCE 0  "**HINT**:if call hangs check native call:${_check} "
		eval callErrOutWrapper $LINENO $BASH_SOURCE ${_check} ${disp1}
		if [ $? -eq 0 ];then
		    eval ${_suPrefix}="\"${_suPrefixContent:-$KSU -q -e }\""
		    _ret=0;
		    printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "permission-detected:KERBEROS"
		fi    
	    else
		printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "USE_K5USERS not set, ignore:KERBEROS"
	    fi
	fi

        #next priority:sudo
        if((_ret!=0));then
	    if [ "$USE_SUDO" == "1" ];then
                #check sudoers
		printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "try SUDO"
		local _check="${SUDO} ${_suCalleeContent} ${_suCalleeArgs}"
		printWNG 2 $LINENO $BASH_SOURCE 0  "**HINT**:if call hangs check native call:${_check} "
#		callErrOutWrapper $LINENO $BASH_SOURCE ${_check} ${disp1}
#		callErrOutWrapper $LINENO $BASH_SOURCE eval ${_check} ${disp1}
		eval ${_check} ${disp1}
		if [ $? -eq 0 ];then
		    eval ${_suPrefix}="\"${_suPrefixContent:-$SUDO }\""
		    _ret=0;
		    printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "permission-detected:SUDOERS"
		fi
	    else
		printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "USE_SUDO not set, ignore:sudoers"
	    fi    
	fi    

        #check native permissions
        if((_ret!=0));then
	    printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "CHECK:${_suCalleeContent} ${_suCalleeArgs} ${disp2} ${disp1}"

	    if [ -n "${_suCalleeContent}" ];then
		eval "${_suCalleeContent} ${_suCalleeArgs} ${disp2} ${disp1}"
#		eval callErrOutWrapper $LINENO $BASH_SOURCE ${_suCalleeContent} ${_suCalleeArgs} ${disp2} ${disp1}
		_ret=$?
		if [ $_ret -eq 0 ];then
		    local _useNATIVE=1;
		    printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "permission-detected:NATIVE"
		fi
	    fi
	fi

    fi

    #just for safety, inform of own impersonation capability
    if [ $_ret -eq 0 ];then
        if [ -z "${_suPrefix}" ];then
	    if [ "`id -u`" -eq 0 -a "$USER" != root ];then
		printERR $LINENO $BASH_SOURCE 1  "Oh,..."
		printERR $LINENO $BASH_SOURCE 1  " USER  =${USER}"
		printERR $LINENO $BASH_SOURCE 1  " ${_suCallee}    =${_suCalleeContent}"
		printERR $LINENO $BASH_SOURCE 1  "...you have native root permission as non-root!"
		printERR $LINENO $BASH_SOURCE 1  "Be careful with that axe Eugene!"
		printERR $LINENO $BASH_SOURCE 1  "Anyhow, continue despite assuming that THIS IS an ERROR!"
	    fi
	fi
	return ${_ret}
    fi

    printWNG 2 $LINENO $BASH_SOURCE 1  "NO-ACCESS-GRANTED to USER=$USER for root-permisson to call"
    printWNG 2 $LINENO $BASH_SOURCE 1  "  \"${_suPrefix}=${_suPrefixContent}\""
    printWNG 2 $LINENO $BASH_SOURCE 1  "  \"${_suCallee}=${_suCalleeContent} ${_suCalleeArgs}\""
    printWNG 2 $LINENO $BASH_SOURCE 1  "."
    printWNG 2 $LINENO $BASH_SOURCE 1  "  -> Set ksu/sudo by editing \"/root/.k5users\" and/or \"etc/sudoers\", "
    printWNG 2 $LINENO $BASH_SOURCE 1  "    will be probe-ed and utilized properly."
    printWNG 2 $LINENO $BASH_SOURCE 1  "."
    printWNG 2 $LINENO $BASH_SOURCE 1  "     The general access permission by \"/root/.k5login\" MUST NOT be used!!!"
    printWNG 2 $LINENO $BASH_SOURCE 1  "."
    printWNG 2 $LINENO $BASH_SOURCE 1  " or"
    printWNG 2 $LINENO $BASH_SOURCE 1  "."
    printWNG 2 $LINENO $BASH_SOURCE 1  "  -> Set ${_suPrefix} to \"ksu -e \" or \"sudo \" and export it(SPACES!!!)."
    printWNG 2 $LINENO $BASH_SOURCE 1  "."
    printWNG 2 $LINENO $BASH_SOURCE 1  " or"
    printWNG 2 $LINENO $BASH_SOURCE 1  "."
    printWNG 2 $LINENO $BASH_SOURCE 1  "  -> Configure it in this file"
    printWNG 2 $LINENO $BASH_SOURCE 1  "     \"${_confFile}\""
    printWNG 2 $LINENO $BASH_SOURCE 1  "."
    printWNG 2 $LINENO $BASH_SOURCE 1  "Refer to ctys-manual for help and references."
    printWNG 2 $LINENO $BASH_SOURCE 1  "."

    return ${_ret}
}





#FUNCBEG###############################################################
#NAME:
#  setSUaccess
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Sets the given call prefix. No call checks are performed, just the presence 
#  of a authorization method is required.
#
#  This call is foreseen particularly for critical calls such as "halt"
#  which will shutdown the system immediately in any case of success on
#  OpenBSD.
#
#  Thus the access permissions has to be prepared thoroughly for this call 
#  and will be just trusted as given. The following cases are supported.
#
#  - native/root permissions
#  - ksu
#  - sudo
#
#
#  
#EXAMPLE:
#
#  XENCALL="${XENCALL:-ksu -e }"
#  XENCALL="${XENCALL:-sudo }"
#
#  VIRSHCALL="${VIRSHCALL:-ksu -e }"
#  VIRSHCALL="${VIRSHCALL:-sudo }"
#
#GLOBALS:
#  0=>off  1=>on
#
#  USE_KSU=0|1
#  USE_SUDO=0|1
#
#
#PARAMETERS:
#  $1:   config-file hint
#        Hint to be presented for source of change.
#
#  $2:   SU-PREFIX-VAR
#        Prefix to be used for impersonalization, content could be empty, than
#        current USER is tested.
#
#  $3:   SU-CALLEE-VAR
#        The command to be checked for execution permissions.
#
#  $4-*: SU-CALLEE-PARAMS
#        Optional parameters to be tested.
#        This is somewhat tricky. Some commands resquire root permissions only for
#        specific parameters accessing restricted system resources. The remaining 
#        set of parameters are accessible for all users.
#
#        Things become somewhat complicated when the test itself performs a critical 
#        call covering the checked permission. 
#
#        So, it has to be decided from case to case how to proceed.
#
#        For example in case of xm from Xen standard package things are somewhat 
#        simpler to handle by "xm info".
#
#
#OUTPUT:
#  RETURN:
#    0: Success
#    1: Failure
#  VALUES:
#
#FUNCEND###############################################################
function setSUaccess () {
    printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=$@"
    local _confFile=$1;shift
    local _suPrefix=$1;shift
    if [ -z "${_suPrefix// /}" ];then
	printERR $LINENO $BASH_SOURCE 1  "$FUNCNAME:Internal error, missing parameter"
	gotoHell 1
    fi

    local _suPrefixContent=`eval echo \\\${${_suPrefix}}`

    local _suCallee=$1;shift
    if [ -z "${_suCallee// /}" ];then
	printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:No callee provided, not neccessarily an error."
	printWNG 2 $LINENO $BASH_SOURCE 1 "$FUNCNAME:No callee provided, not neccessarily an error."
	return 2
    fi
    local _suCalleeContent=`eval echo \\\${${_suCallee}}`
    if [ -z "${_suCalleeContent// /}" ];then
	printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:No access value for ${_suCallee}"
	printWNG 2 $LINENO $BASH_SOURCE 1  "$FUNCNAME:No access value for ${_suCallee}"
	return 2
    fi
    local _suCalleeArgs=$*

    printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_confFile=$_confFile"
    printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_suPrefix=$_suPrefix"
    printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_suPrefixContent=$_suPrefixContent"
    printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_suCallee=$_suCallee"
    printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_suCalleeContent=$_suCalleeContent"
    printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_suCalleeArgs=$_suCalleeArgs"

    local _ret=1;

    #if I am root, permissions might not be the question, particularly
    #no entries in k5users and sudoers will be applied.
    #No ID or group membership checked, usage for root-permissions will not be supported.
    if [ "${USER}" == "root" ];then
	eval ${_suPrefix}=;
	printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "permission-detected:USER==root"
	printWNG 2 $LINENO $BASH_SOURCE 1  "No ksu/sudo required, USER==root"
	return 0;
    fi

    if [ -n "${_suPrefixContent}" ];then
	printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "Already set:${_suPrefixContent}"
	return 0;
    fi

    if [ "$USE_K5USERS" == "1" ];then
	printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "try KERBEROS"
	eval ${_suPrefix}="\"${_suPrefixContent:-$KSU -e }\""
	printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "permission-detected:KERBEROS"
	return 0;
    else
	printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "USE_K5USERS not set, ignore:KERBEROS"
    fi

    if [ "$USE_SUDO" == "1" ];then
	printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "try SUDO"
	eval ${_suPrefix}="\"${_suPrefixContent:-$SUDO }\""
	printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "permission-detected:SUDOERS"
 	return 0;
    else
	printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "USE_SUDO not set, ignore:sudoers"
    fi    

    if [ "`id -u`" -eq 0 -a "$USER" != root ];then
	printERR $LINENO $BASH_SOURCE 1  " USER  =${USER}"
	printERR $LINENO $BASH_SOURCE 1  " ${_suCallee}    =${_suCalleeContent}"
	printERR $LINENO $BASH_SOURCE 1  "...you have native root permission as non-root!"
	printERR $LINENO $BASH_SOURCE 1  "Anyhow, continue despite assuming that THIS IS an ERROR!"
 	return 0;
    fi

    printWNG 2 $LINENO $BASH_SOURCE 1  "NO-ACCESS-GRANTED to USER=$USER for root-permisson to call"
    printWNG 2 $LINENO $BASH_SOURCE 1  "  \"${_suPrefix}=${_suPrefixContent}\""
    printWNG 2 $LINENO $BASH_SOURCE 1  "  \"${_suCallee}=${_suCalleeContent} ${_suCalleeArgs}\""
    printWNG 2 $LINENO $BASH_SOURCE 1  "."
    printWNG 2 $LINENO $BASH_SOURCE 1  "  -> Set ksu/sudo by editing \"/root/.k5users\" and/or \"etc/sudoers\", "
    printWNG 2 $LINENO $BASH_SOURCE 1  "    will be probe-ed and utilized properly."
    printWNG 2 $LINENO $BASH_SOURCE 1  "."
    printWNG 2 $LINENO $BASH_SOURCE 1  "     The general access permission by \"/root/.k5login\" MUST NOT be used!!!"
    printWNG 2 $LINENO $BASH_SOURCE 1  "."
    printWNG 2 $LINENO $BASH_SOURCE 1  " or"
    printWNG 2 $LINENO $BASH_SOURCE 1  "."
    printWNG 2 $LINENO $BASH_SOURCE 1  "  -> Set ${_suPrefix} to \"ksu -e \" or \"sudo \" and export it(SPACES!!!)."
    printWNG 2 $LINENO $BASH_SOURCE 1  "."
    printWNG 2 $LINENO $BASH_SOURCE 1  " or"
    printWNG 2 $LINENO $BASH_SOURCE 1  "."
    printWNG 2 $LINENO $BASH_SOURCE 1  "  -> Configure it in this file"
    printWNG 2 $LINENO $BASH_SOURCE 1  "     \"${_confFile}\""
    printWNG 2 $LINENO $BASH_SOURCE 1  "."
    printWNG 2 $LINENO $BASH_SOURCE 1  "Refer to ctys-manual for help and references."
    printWNG 2 $LINENO $BASH_SOURCE 1  "."

    return ${_ret}
}





#FUNCBEG###############################################################
#NAME:
#  getGroup
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Displays the main group.
#  
#EXAMPLE:
#GLOBALS:
#
#PARAMETERS:
#  $1:   user
#
#
#OUTPUT:
#  RETURN:
#    0: Success
#    1: Failure
#  VALUES:
#    main-group
#FUNCEND###############################################################
function getGroup () {
    printDBG $S_LIB ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=$@"
    id -g -n $1
}