#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_10_009
#
########################################################################
#
# Copyright (C) 2007,2008,2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

#QEMU generic default parameters, will be reset in setVersionQEMU
QEMU_MAGIC=QEMU_GENERIC
QEMU_ACCELERATOR=;
QEMU_VERSTRING=;
QEMU_STATE=DISABLED
QEMU_DEFAULTOPTS=
QEMU_PREREQ=;

QEMU_SERVER=;

QEMU_PRODVERS=;
QEMU_PRODVERS_QEMUBASE=;
QEMU_PRODVERS_QEMUKVM=;


#internal for ps-eval
QEMU_EXELIST_BASENAME=;


_myPKGNAME_QEMU="${BASH_SOURCE}"
_myPKGVERS_QEMU="01.11.009"
hookInfoAdd $_myPKGNAME_QEMU $_myPKGVERS_QEMU

QEMU_VERSTRING="${_myPKGVERS_QEMU}"

_myPKGBASE_QEMU="`dirname ${_myPKGNAME_QEMU}`"

_myTAP=;

if [ -d "${HOME}/.ctys" -a -d "${HOME}/.ctys/qemu" ];then
    if [ -f "${HOME}/.ctys/qemu/qemu.conf-${MYOS}.sh" ];then
	. "${HOME}/.ctys/qemu/qemu.conf-${MYOS}.sh"
    fi
fi

if [ -d "${MYCONFPATH}/qemu" ];then
    if [ -f "${MYCONFPATH}/qemu/qemu.conf-${MYOS}.sh" ];then
	. "${MYCONFPATH}/qemu/qemu.conf-${MYOS}.sh"
    fi
fi

_waitcQEMU=${QEMU_INIT_WAITC:-2}
_waitsQEMU=${QEMU_INIT_WAITS:-2}

_pingQEMU=${CTYS_PING_DEFAULT_QEMU:-0};
_pingcntQEMU=${CTYS_PING_ONE_MAXTRIAL_QEMU:-20};
_pingsleepQEMU=${CTYS_PING_ONE_WAIT_QEMU:-2};

_sshpingQEMU=${CTYS_SSHPING_DEFAULT_QEMU:-0};
_sshpingcntQEMU=${CTYS_SSHPING_ONE_MAXTRIAL_QEMU:-20};
_sshpingsleepQEMU=${CTYS_SSHPING_ONE_WAIT_QEMU:-2};

_actionuserQEMU="${MYUID}";



. ${MYLIBPATH}/lib/libQEMUbase.sh

#FUNCBEG###############################################################
#NAME:
#  checkConsole
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Checks whether console is available.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: name of UNIX domain socket
#      
#
#OUTPUT:
#  RETURN:
#   0: OK
#   1: NOK
#  VALUES:
#
#FUNCEND###############################################################
function checkConsole () {
    local _myCon=${1};
    if [ ! -e "${_myCon}" ];then
	printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:Missing UNIX domain console port:<${_myCon}>"
	return 1
    fi
    local _n=$(${CTYS_LSOF}|awk -v f="${_myCon}" 'BEGIN{n=0}$0~f{n++;}END{print n;}');
    if [ "$_n" != 1 ];then
	return $_n;
    fi
    return 0
}


#FUNCBEG###############################################################
#NAME:
#  releaseConsole
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  If occupied, tries to release by killing the client.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: name of UNIX domain socket
#      
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function releaseConsole () {
    local _myCon=${1};
    if [ ! -e "${_myCon}" ];then
	printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:Missing UNIX domain console port:<${_myCon}>"
	return 1
    fi
    local _s=$(${CTYS_LSOF} ${_myCon}|awk -v f="${_myCon}" '$0~f{print $NF;}');
    if [ -n "$CTYS_NETCAT" ];then
	local con=$CTYS_NETCAT;
    else
	local con=$VDE_UNIXTERM;
    fi
    for i in $_s;do
	${PS} ${PSEF}|awk -v a="${con}" -v m="${_myCon}" '$0~a&&$0~m{print $2;}'|xargs kill 2>/dev/null
    done
}


#FUNCBEG###############################################################
#NAME:
#  setVersionQEMU
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Sets defaults and MAGIC-ID for local Qemu version.
#
#  The defaults for QEMU_DEFAULTOPTS will only be used when no CLI
#  options are given.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: NOEXIT
#      This optional parameter as literal forces a return instead of 
#      exit by "gotoHell". Should be used, for test-only, when for
#      missing or erroneous plugins specific actions has to follow
#      within current execution thread.
#      
#
#OUTPUT:
#  GLOBALS:
#    QEMU_MAGIC:  {QEMU_090|QEMU_091|QEMU_09x|...}
#      Value to be checked, when no local native components are 
#      present, the following values will be set.
#
#
#    QEMU_DEFAULTOPTS
#      Appropriate defaults.
#
#      -XM                   : ""
#
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function setVersionQEMU () {
    printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:<${@}>"
    local _checkonly=;
    if [ "$1" == "NOEXIT" ];then
	local _checkonly=1;        
    fi

    #
    #will load only when missing
    hookPackage CLI
    hookPackage X11
    hookPackage VNC

    printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:loaded pre-requisites:CLI, X11, VNC"

    #
    #set for checks, e.g. CONNECTIONFORWAARDING
    local _rdisp=1
    runningOnDisplayStation
    _rdisp=$?


    #
    #Check local components in any case, post-fetchin here puts them to init list
    #by the time.
    #

    #CLI - let us say required!!!
    local _cliOK=`hookInfoCheckPKG CLI`
    if [ -z "${_cliOK}" ];then
	ABORT=1;
	if [ "${C_SESSIONTYPE}" == "QEMU" -a -z "${_checkonly}" ];then
	    printERR $LINENO $BASH_SOURCE ${ABORT} "This feature requires additional CLI plugin to be pre-loaded."
	    printERR $LINENO $BASH_SOURCE ${ABORT} "-> Set the option \"-T vnc,cli,...\" "
	    printERR $LINENO $BASH_SOURCE ${ABORT} "-> Check actually loaded plugins with option \"-v\""
	    gotoHell ${ABORT}
	else
	    printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "This feature reuqires additional CLI plugin to be pre-loaded."
	    printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "-> Set the option \"-T vnc,cli,...\" "
	    printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "-> Check actually loaded plugins with option \"-v\""
	    return ${ABORT}
	fi
    else
	QEMU_PREREQ="${QEMU_PREREQ} CLI-ValidatedBy(hookInfoCheckPKG)"
    fi

    #X11 - let us say required!!!
    local _x11OK=`hookInfoCheckPKG X11`
    if [ -z "${_x11OK}" ];then
	ABORT=1;
	if [ "${C_SESSIONTYPE}" == "QEMU" -a -z "${_checkonly}" ];then
	    printERR $LINENO $BASH_SOURCE ${ABORT} "This feature requires additional X11 plugin to be pre-loaded."
	    printERR $LINENO $BASH_SOURCE ${ABORT} "-> Set the option \"-T vnc,x11,...\" "
	    printERR $LINENO $BASH_SOURCE ${ABORT} "-> Check actually loaded plugins with option \"-v\""
	    gotoHell ${ABORT}
	else
	    printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "This feature reuqires additional X11 plugin to be pre-loaded."
	    printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "-> Set the option \"-T vnc,x11,...\" "
	    printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "-> Check actually loaded plugins with option \"-v\""
	    return ${ABORT}
	fi
    else
	QEMU_PREREQ="${QEMU_PREREQ} X11-ValidatedBy(hookInfoCheckPKG)"
    fi

    #VNC - let us say required!!!
    local _vncOK=`hookInfoCheckPKG VNC`
    if [ -z "${_vncOK}" ];then
	ABORT=1;
	if [ "${C_SESSIONTYPE}" == "QEMU" -a -z "${_checkonly}" ];then
	    printERR $LINENO $BASH_SOURCE ${ABORT} "This feature requires additional VNC plugin to be pre-loaded."
	    printERR $LINENO $BASH_SOURCE ${ABORT} "-> Set the option \"-T vnc,xen,...\" "
	    printERR $LINENO $BASH_SOURCE ${ABORT} "-> Check actually loaded plugins with option \"-v\""
	    gotoHell ${ABORT}
	else
	    printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "This feature reuqires additional VNC plugin to be pre-loaded."
	    printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "-> Set the option \"-T vnc,xen,...\" "
	    printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "-> Check actually loaded plugins with option \"-v\""
	    return ${ABORT}
	fi
    else
	QEMU_PREREQ="${QEMU_PREREQ} VNC-ValidatedBy(hookInfoCheckPKG)"
    fi

    printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:verified pre-requisites:CLI, X11, VNC"

    #
    #if not final and though actual execution target just relay it,
    #so client and additional basic server-checks only on this node
    #
    QEMU_MAGIC=RELAY;
    if [ -n "${_cliOK}" ];then
	QEMU_PREREQ="${QEMU_PREREQ} <LocalClientCLI>"
    fi
    if [ -n "${_x11OK}" ];then
	QEMU_PREREQ="${QEMU_PREREQ} <LocalClientX11>"
    fi
    if [ -n "${_vncOK}" ];then
	QEMU_PREREQ="${QEMU_PREREQ} <LocalClientVNC>"
    fi
    if [ -z "$C_EXECLOCAL" ];then
	QEMU_STATE=ENABLED
	QEMU_SERVER=;
	QEMU_PREREQ="${QEMU_PREREQ} <LocalXserverDISPLAY>"
	QEMU_PREREQ="${QEMU_PREREQ} <delayedValidationOnFinalTarget>"
	QEMU_PREREQ="${QEMU_PREREQ} <GenericClientCapabilityOnly>"
	printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "QEMU_MAGIC       = ${QEMU_MAGIC}"
	printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "QEMU_STATE       = ${QEMU_STATE}"
	printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "QEMU_VERSTRING   = ${QEMU_VERSTRING}"
	printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "QEMU_PREREQ      = ${QEMU_PREREQ}"
	printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "QEMU_DEFAULTOPTS = ${QEMU_DEFAULTOPTS}"
	return 0
    fi

    printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:QEMU     = ${QEMU}"
    printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:QEMUBASE = ${QEMUBASE}"
    printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:QEMUKVM  = ${QEMUKVM}"

    #####
    # 1.) Check preset QEMU==QEMUBASE
    if [ -n "${QEMUBASE}" ];then
	QEMU=$(bootstrapGetRealPathname ${QEMUBASE});
	local _qemubase=$(dirname ${QEMU})
	QEMU_PRODVERS_QEMUBASE=$(getVersionStrgQEMUALL ${QEMU})
    fi


    #####
    # 2.) Check preset QEMUKVM
    if [ -n "${QEMUKVM}" ];then
	QEMUKVM=$(bootstrapGetRealPathname ${QEMUKVM});
	local _qemubase=$(dirname ${QEMUKVM})
	QEMU_PRODVERS_QEMUKVM=$(getVersionStrgQEMUALL ${QEMUKVM})
    fi

    #####
    #1.+2.) decide which one to use
    if [ -n "${QEMU_PRODVERS_QEMUKVM}" ];then
        #QEMUKVM
	QEMU_PRODVERS="${QEMU_PRODVERS_QEMUKVM}"
	QEMU=$QEMUKVM
    else
	if [ -n "${QEMU_PRODVERS_QEMUBASE}" ];then
            #QEMU
	    QEMU_PRODVERS="${QEMU_PRODVERS_QEMUBASE}"
	fi
        #try path resolution else
    fi
    printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "QEMU_PRODVERS_QEMUKVM  = ${QEMU_PRODVERS_QEMUKVM}"
    printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "QEMU_PRODVERS_QEMUBASE = ${QEMU_PRODVERS_QEMUBASE}"

    #####
    #Prepare
    if [ -n "${QEMU_EXELIST}" ];then
	QEMU_EXELIST=${QEMU_EXELIST_PREPEND}:${QEMU_EXELIST}
    else
	QEMU_EXELIST=${QEMU_EXELIST_PREPEND}:${QEMU_EXELIST}

	QEMU_PATHLIST=${_qemubase:+$_qemubase:$QEMU_PATHLIST}
	for p in ${QEMU_PATHLIST//:/ };do
	    for i in ${p}/qemu-*;do
		QEMU_EXELIST=${QEMU_EXELIST}:${i}
	    done
	done
    fi
    printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "QEMU_EXELIST(RAW)   = ${QEMU_EXELIST}"
    printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "QEMU_BLACKLIST(RAW) = ${QEMU_BLACKLIST}"
    printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "QEMU_PATHLIST       = ${QEMU_PATHLIST}"


    local _BUF=;
    local _buf=;
    local _x=;

    for i in ${QEMU_BLACKLIST//:/ };do
	_BUF=${_BUF}:$(export PATH=${QEMU_PATHLIST}:${PATH}&&bootstrapGetRealPathname &&gwhich ${i} 2>/dev/null);
    done
    _BUF=${_BUF##:}
    QEMU_BLACKLIST=":${_BUF%%:}:"
    printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "QEMU_BLACKLIST(RESOLVED) = ${QEMU_BLACKLIST}"

    function checkBlacklist () {
 	[ "${QEMU_BLACKLIST}" != "${QEMU_BLACKLIST//$1:/}" ]&&return
	echo "${1}"
    }

    #####
    #3.+4.)Resolve
    for f in ${QEMU_EXELIST//:/ };do
	_x=$(checkBlacklist $f);
        [ -z "$_x" ]&&continue
	if [ -f "${_x}" ];then
	    _BUF=${_BUF}:${_x}
	else
	    _buf=$(PATH=${QEMU_PATHLIST}:${PATH}&&gwhich ${_x} 2>/dev/null);
	    if [ -n "$_buf" ];then
		_BUF=${_BUF}:${_buf}
	    fi
	fi
    done
    QEMU_EXELIST=${_BUF}
    printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "QEMU_EXELIST(PROCESSED)=${QEMU_EXELIST}"


    #####
    #set capabilities for display of INFO
    #resolve symbolic links
    _BUF=;
    QEMU_EXELIST_BASENAME=;
    for i in ${QEMU_EXELIST//:/ };do
	local _tx=${i// /_};
	QEMU_PREREQ="${QEMU_PREREQ} <CPU-Emulation:${_tx##*/}>"

	_tx=$(bootstrapGetRealPathname ${i});
	_BUF=${_BUF}:${_tx};
	QEMU_EXELIST_BASENAME=${QEMU_EXELIST_BASENAME}:${_tx##*/}
    done
    QEMU_EXELIST=${_BUF}
    printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "QEMU_EXELIST_BASENAME   = ${QEMU_EXELIST_BASENAME}"

    #####
    #if not found yet
    if [ -z "${QEMU}" ];then
	QEMU_EXELIST=${QEMU_EXELIST##:}
	QEMU=${QEMU_EXELIST%%:*}
	QEMU_EXELIST=${QEMU_EXELIST#*:}
	if [ -z "${QEMU}" ];then
            #
            #serious!
            #
	    QEMU_PREREQ="${QEMU_PREREQ} <LocalXserverDISPLAY>"
	    QEMU_PREREQ="${QEMU_PREREQ} <delayedValidationOnFinalTarget>"
	    QEMU_PREREQ="${QEMU_PREREQ} <GenericClientCapabilityOnly>"
	    if [ -n "$C_EXECLOCAL" ];then
		QEMU_MAGIC=NOLOC;
		QEMU_PREREQ="${QEMU_PREREQ} <`setStatusColor ${QEMU_STATE} QEMU-Exe`:CANNOT-EVALUATE>"
	    fi
	    ABORT=2
	    local _myLoc=`getLocation ${C_CLIENTLOCATION}`
	    if [ "${C_SESSIONTYPE}" == "QEMU" -a -z "${_checkonly}" -a "${_myLoc}" != CONNECTIONFORWARDING -a "${_myLoc}" != CLIENTONLY  ];then
		printERR $LINENO $BASH_SOURCE ${ABORT} "Cannot locate executable \"qemu\""
		gotoHell ${ABORT}
	    else
		printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "Cannot locate executable \"qemu\""
		return ${ABORT}
	    fi
	fi
    else
	QEMU_EXELIST_BASENAME=${QEMU_EXELIST_BASENAME}:${QEMU##*/}
    fi
    printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "QEMU_EXELIST_BASENAME   = ${QEMU_EXELIST_BASENAME}"

    if [ -z "${QEMU_PRODVERS}" ];then
	QEMU_PRODVERS=$(getVersionStrgQEMUALL ${QEMU})
    fi
    QEMU_MAGIC=$(getQEMUMAGIC ${QEMU})
    QEMU_ACCELERATOR=$(getACCELERATOR_QEMU ${QEMU})

    printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "QEMU                    = ${QEMU}"
    printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "QEMU_PRODVERS           = ${QEMU_PRODVERS}"
    printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "QEMU_PRODVERS_QEMUBASE  = ${QEMU_PRODVERS_QEMUBASE}"
    printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "QEMU_PRODVERS_QEMUKVM   = ${QEMU_PRODVERS_QEMUKVM}"
    printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "QEMU_MAGIC              = ${QEMU_MAGIC}"
    printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "QEMU_ACCELERATOR       = ${QEMU_ACCELERATOR}"

    if [ -z "${QEMU_PRODVERS}" ];then
	QEMU_PREREQ="${QEMU_PREREQ} <LocalXserverDISPLAY>"
	QEMU_PREREQ="${QEMU_PREREQ} <delayedValidationOnFinalTarget>"
	QEMU_PREREQ="${QEMU_PREREQ} <GenericClientCapabilityOnly>"
	ABORT=2
	if [ "${C_SESSIONTYPE}" == "QEMU" -a -z "${_checkonly}" ];then
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Cannot evaluate version of QEMU"
	    printERR $LINENO $BASH_SOURCE ${ABORT} "A common reason is missing of the required shared libraries"
	    printERR $LINENO $BASH_SOURCE ${ABORT} "e.g. libSDL"
	    gotoHell ${ABORT}
	else
	    printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "CHKONLY:QEMU seems not to be installed."
	    return ${ABORT}
	fi
    fi

    if [ $_rdisp -ne 0 ];then
	printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "VDE_SWITCH=${VDE_SWITCH}"
	if [ -n "${VDE_SWITCH}" ];then
	    local _vdebuf=`callErrOutWrapper $LINENO $BASH_SOURCE ${VDE_SWITCH} -v|sed -n 's/VDE \([0-9.]\+\)[^0-9\.]*/\1/p'`
	    _vdebuf="vde-${_vdebuf}-`getExecArch ${VDE_SWITCH}`"
	    local _buf1="VM-CAPABILITY:QEMU-${QEMU_VERSTRING}-${MYARCH}"
	    if [ -n "${QEMU_PRODVERS_QEMUKVM}" -a -n "${QEMUKVM}" ];then
		_buf1="${_buf1}%${QEMU_PRODVERS_QEMUKVM}-`getExecArch ${QEMUKVM}`"
	    fi
	    if [ -n "${QEMU_PRODVERS_QEMUBASE}" -a -n "${QEMUBASE}" ];then
		_buf1="${_buf1}%${QEMU_PRODVERS_QEMUBASE}-`getExecArch ${QEMUBASE}`"
	    fi
	    QEMU_PREREQ="${_buf1}%${_vdebuf} ${QEMU_PREREQ}"
	else
	    QEMU_STATE=DISABLED
	    QEMU_SERVER=;
	    QEMU_PREREQ="${QEMU_PREREQ} <`setStatusColor ${QEMU_STATE} MISSING`:vde_switch>"

	    ABORT=2
	    if [ "${C_SESSIONTYPE}" == "QEMU" -a -z "${_checkonly}" ];then
		printERR $LINENO $BASH_SOURCE ${ABORT} "Cannot locate executable \"vde_tunctl\""
		gotoHell ${ABORT}
	    else
		printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "Cannot locate executable \"vde_tunctl\""
		return ${ABORT}
	    fi
	fi
    fi

    ##########
    if [ $_rdisp -ne 0 ];then
	printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "VDE_TUNCTL=${VDE_TUNCTL}"
	if [ -z "${VDE_TUNCTL}" ];then
	    QEMU_PREREQ="${QEMU_PREREQ} <GenericClientCapabilityOnly>"
	    QEMU_STATE=DISABLED
	    QEMU_SERVER=;
	    QEMU_PREREQ="${QEMU_PREREQ} <`setStatusColor ${QEMU_STATE} MISSING`:vde_tunctl>"

	    ABORT=2
	    if [ "${C_SESSIONTYPE}" == "QEMU" -a -z "${_checkonly}" ];then
		printERR $LINENO $BASH_SOURCE ${ABORT} "Cannot locate executable \"vde_tunctl\""
		gotoHell ${ABORT}
	    else
		printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "Cannot locate executable \"vde_tunctl\""
		return ${ABORT}
	    fi
	fi
	if [ -n "${VDE_TUNCTL}" ];then
            local _tst=`${QEMUCALL} ${VDE_TUNCTL} -xyz 2>&1 |grep "tun-clone"`
	    if [ -n "${_tst}" ];then
		QEMU_PREREQ="${QEMU_PREREQ} ${VDECALL// /_}_${VDE_TUNCTL}_info-USER=${USER}-ACCESS-PERMISSION-GRANTED"
	    else
		printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "Final check of access for current USER=${USER} failed."
		printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "=> failed to perform \"${VDECALL} ${VDE_TUNCTL} -xyz\""
		QEMU_PREREQ="${QEMU_PREREQ} <GenericClientCapabilityOnly>"
		QEMU_STATE=DISABLED
		QEMU_SERVER=;
		QEMU_PREREQ="${QEMU_PREREQ} <`setStatusColor ${QEMU_STATE} FAILED`:${VDECALL// /_}_${VDE_TUNCTL}_info-USER=${USER}-NO-ACCESS>"
	    fi
	fi
    fi

    ##########
    if [ $_rdisp -ne 0 ];then
	printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "VDE_SWITCH=${VDE_SWITCH}"
	if [ -z "${VDE_SWITCH}" ];then
	    ABORT=2
	    if [ "${C_SESSIONTYPE}" == "QEMU" -a -z "${_checkonly}" ];then
		printERR $LINENO $BASH_SOURCE ${ABORT} "Cannot locate executable \"vde_switch\""
		gotoHell ${ABORT}
	    else
		printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "Cannot locate executable \"vde_switch\""
		return ${ABORT}
	    fi
	fi
	callErrOutWrapper $LINENO $BASH_SOURCE  ${VDECALL}  ${VDE_SWITCH} -v >/dev/null
	if [ $? -ne 0 ];then
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "Final check of access for current USER=${USER} failed."
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "=> failed to perform \"${VDECALL} ${VDE_SWITCH} -v\""
	    QEMU_PREREQ="${QEMU_PREREQ} <GenericClientCapabilityOnly>"
	    QEMU_STATE=DISABLED
	    QEMU_SERVER=;
	    QEMU_PREREQ="${QEMU_PREREQ} <`setStatusColor ${QEMU_STATE} FAILED`:${VDECALL// /_}_${VDE_SWITCH}_info-USER=${USER}-NO-ACCESS>"
	else
	    QEMU_PREREQ="${QEMU_PREREQ} ${VDECALL// /_}_${VDE_SWITCH}_info-USER=${USER}-ACCESS-PERMISSION-GRANTED"
	fi
    fi

    ##########
    if [ $_rdisp -ne 0 ];then
	printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "VDE_UNIXTERM=${VDE_UNIXTERM}"
	if [ -z "${VDE_UNIXTERM}" ];then
	    ABORT=2
	    if [ "${C_SESSIONTYPE}" == "QEMU" -a -z "${_checkonly}" ];then
		printERR $LINENO $BASH_SOURCE ${ABORT} "Cannot locate executable \"vde_unixterm\""
		gotoHell ${ABORT}
	    else
		printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "Cannot locate executable \"vde_unixterm\""
		return ${ABORT}
	    fi
	fi
	if [ -n "$VDE_UNIXTERM" ];then
            local _tst=`${VDECALL} ${VDE_UNIXTERM} 2>&1 |grep connecting`
	    if [ -n "$_tst" ];then
		QEMU_PREREQ="${QEMU_PREREQ} ${VDECALL// /_}_${VDE_UNIXTERM}_info-USER=${USER}-ACCESS-PERMISSION-GRANTED"
		printDBG $S_QEMU ${D_SYS} $LINENO "$BASH_SOURCE" "$FUNCNAME:`setSeverityColor TRY \"call(${VDE_UNIXTERM})\"` => [ `setSeverityColor INF OK` ]"
	    else
		QEMU_PREREQ="${QEMU_PREREQ} <GenericClientCapabilityOnly>"
		QEMU_PREREQ="${QEMU_PREREQ} <`setStatusColor TRY FAILED`:${VDECALL// /_}_${VDE_UNIXTERM}_info-USER=${USER}-NO-ACCESS>"
		printDBG $S_QEMU ${D_SYS} $LINENO "$BASH_SOURCE" "$FUNCNAME:`setSeverityColor TRY \"call(${VDE_UNIXTERM})\"` => [ `setSeverityColor ERR NOK` ]"
	    fi
	fi
    fi

    ##########
    if [ $_rdisp -ne 0 ];then
	printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "VDE_DEQ=${VDE_DEQ}"
	if [ -z "${VDE_DEQ}" ];then
	    ABORT=2
	    if [ "${C_SESSIONTYPE}" == "QEMU" -a -z "${_checkonly}" ];then
		printERR $LINENO $BASH_SOURCE ${ABORT} "Cannot locate executable \"vde_deq\""
		gotoHell ${ABORT}
	    else
		QEMU_PREREQ="${QEMU_PREREQ} <GenericClientCapabilityOnly>"
		printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "Cannot locate executable \"vde_deq\""
		return ${ABORT}
	    fi
	fi
	if [ -n "$VDE_DEQ" ];then
            local _tst=`${VDECALL} ${VDE_DEQ} 2>&1 |grep qemu_executable`
	    if [ -n "$_tst" ];then
		QEMU_PREREQ="${QEMU_PREREQ} ${VDECALL// /_}_${VDE_DEQ}_info-USER=${USER}-ACCESS-PERMISSION-GRANTED"
		printDBG $S_QEMU ${D_SYS} $LINENO "$BASH_SOURCE" "$FUNCNAME:`setSeverityColor TRY \"call(${VDE_DEQ} --help)\"` => [ `setSeverityColor INF OK` ]"
	    else
		QEMU_PREREQ="${QEMU_PREREQ} <GenericClientCapabilityOnly>"
		QEMU_PREREQ="${QEMU_PREREQ} <`setStatusColor ${QEMU_STATE} FAILED`:${VDECALL// /_}_${VDE_DEQ}_info-USER=${USER}-NO-ACCESS>"
		printDBG $S_QEMU ${D_SYS} $LINENO "$BASH_SOURCE" "$FUNCNAME:`setSeverityColor TRY \"call(${VDE_DEQ} --help)\"` => [ `setSeverityColor ERR NOK` ]"
	    fi
	fi
    fi


    ##########
    if [ $_rdisp -ne 0 ];then
	printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "VDE_DEQ=${VDE_DEQ}"
	if [ -n "$CTYS_NETCAT" ];then
	    QEMU_PREREQ="${QEMU_PREREQ} ${CTYS_NETCAT// /_}_info-USER=${USER}-ACCESS-PERMISSION-GRANTED"
	else
	    QEMU_PREREQ="${QEMU_PREREQ} <`setSeverityColor INF INFO`:Missing:CTYS_NETCAT_use:VDE_UNIXTERM=${VDE_UNIXTERM}>"
	fi
    fi


    ##########
    if [ $_rdisp -ne 0 ];then
	printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "CTYS_IFCONFIG=${CTYS_IFCONFIG}"
	if [ -z "${CTYS_IFCONFIG}" ];then
	    ABORT=2
	    if [ "${C_SESSIONTYPE}" == "QEMU" -a -z "${_checkonly}" ];then
		printERR $LINENO $BASH_SOURCE ${ABORT} "Cannot locate executable \"ifconfig\""
		gotoHell ${ABORT}
	    else
		QEMU_PREREQ="${QEMU_PREREQ} <GenericClientCapabilityOnly>"
		printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "Cannot locate executable \"ifconfig\""
		return ${ABORT}
	    fi
	fi
    fi


    ##########
    if [ $_rdisp -ne 0 ];then
	printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "CTYS_BRCTL=${CTYS_BRCTL}"
	if [ -z "${CTYS_BRCTL}" ];then
	    ABORT=2
	    if [ "${C_SESSIONTYPE}" == "QEMU" -a -z "${_checkonly}" ];then
		printERR $LINENO $BASH_SOURCE ${ABORT} "Cannot locate executable \"brctl\""
		gotoHell ${ABORT}
	    else
		QEMU_PREREQ="${QEMU_PREREQ} <GenericClientCapabilityOnly>"
		printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "Cannot locate executable \"brctl\""
		return ${ABORT}
	    fi
	fi
    fi



    ##########
    if [ $_rdisp -ne 0 ];then
	printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "QEMUSOCK=${QEMUSOCK}"
	printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "QEMUMGMT=${QEMUMGMT}"
	if [ $_rdisp -ne 0  -a \( ! -e "${QEMUSOCK}" -o ! -e "${QEMUMGMT}" \) ];then
	    ABORT=2
	    if [ ! -e "${QEMUSOCK}" ];then
		QEMU_SERVER=;
		QEMU_PREREQ="${QEMU_PREREQ} <`setStatusColor ${QEMU_STATE} FAILED`:QEMUSOCK=${QEMUSOCK}_info-USER=${USER}-SOCK-NON-EXISTENT>"
		if [ "${C_SESSIONTYPE}" == "QEMU" -a -z "${_checkonly}" ];then
		    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing socket for \"vde_switch\" QEMUSOCK=${QEMUSOCK}"
		else
		    QEMU_PREREQ="${QEMU_PREREQ} <GenericClientCapabilityOnly>"
		    printDBG $S_QEMU ${D_SYS} $LINENO "$BASH_SOURCE" "$FUNCNAME:`setSeverityColor TRY \"check(QEMUSOCK=${QEMUSOCK})\"` => [ `setSeverityColor ERR NOK` ]"
		    printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "Missing socket for \"vde_switch\" QEMUSOCK=${QEMUSOCK}"
		fi
	    else
		QEMU_PREREQ="${QEMU_PREREQ} <`setStatusColor ${QEMU_STATE} INFO `:QEMUSOCK=${QEMUSOCK}_info-USER=${USER}-SOCK-EXISTS>"
	    fi

	    if [ ! -e "${QEMUMGMT}" ];then
		QEMU_PREREQ="${QEMU_PREREQ} <`setStatusColor ${QEMU_STATE} FAILED`:QEMUMGMT=${QEMUMGMT}_info-USER=${USER}-SOCK-NON-EXISTENT>"
		QEMU_SERVER=;
		if [ "${C_SESSIONTYPE}" == "QEMU" -a -z "${_checkonly}" ];then
		    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing management socket for \"vde_switch\" QEMUMGMT=${QEMUMGMT}"
		else
		    QEMU_PREREQ="${QEMU_PREREQ} <GenericClientCapabilityOnly>"
		    printDBG $S_QEMU ${D_SYS} $LINENO "$BASH_SOURCE" "$FUNCNAME:`setSeverityColor TRY \"check(QEMUMGMT=${QEMUMGMT})\"` => [ `setSeverityColor ERR NOK` ]"
		    printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "Missing management socket for \"vde_switch\" QEMUMGMT=${QEMUMGMT}"
		fi
	    else
		QEMU_PREREQ="${QEMU_PREREQ} <`setStatusColor ${QEMU_STATE} INFO `:QEMUMGMT=${QEMUMGMT}_info-USER=${USER}-SOCK-EXISTS>"
	    fi

	    if [ "${C_SESSIONTYPE}" == "QEMU" -a -z "${_checkonly}" ];then
		printERR $LINENO $BASH_SOURCE ${ABORT} "Call: \"ctys-setupVDE.sh\" on \"${MYHOST}\""
	    else
		QEMU_PREREQ="${QEMU_PREREQ} <GenericClientCapabilityOnly>"
		printDBG $S_QEMU ${D_SYS} $LINENO "$BASH_SOURCE" "$FUNCNAME:`setSeverityColor ERR Call: \"ctys-setupVDE.sh\"` ]"
		printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "Call: \"ctys-setupVDE.sh\" on \"${MYHOST}\""
	    fi

	    if [ "${C_SESSIONTYPE}" == "QEMU" -a -z "${_checkonly}" ];then
		gotoHell ${ABORT}
	    else
		return ${ABORT}
	    fi
	fi
    fi

    #
    #Check presence of VDE switch, could be created on the fly too.
    #
    if [ $_rdisp -ne 0 ];then
	${CTYS_SETUPVDE} -X -s "${QEMUSOCK}" -S "${QEMUMGMT}" check
	if [ $? -ne 0 ];then
	    ABORT=127
	    QEMU_SERVER=;
	    if [ "${C_SESSIONTYPE}" == "QEMU" -a -z "${_checkonly}" ];then
		printERR $LINENO $BASH_SOURCE ${ABORT} "Missing VDE-switch, is at least erroneous."
		printERR $LINENO $BASH_SOURCE ${ABORT} "  QEMUSOCK  = ${QEMUSOCK}"
		printERR $LINENO $BASH_SOURCE ${ABORT} "  QEMUMGMT  = ${QEMUMGMT}"
		gotoHell ${ABORT}
	    else
		QEMU_PREREQ="${QEMU_PREREQ} <`setStatusColor ${QEMU_STATE} FAILED`:ctys-setupVDE.sh%check-NO-ACCESS>"
		QEMU_PREREQ="${QEMU_PREREQ} <`setStatusColor ${QEMU_STATE} FAIL-INFO`:QEMUSOCK=${QEMUSOCK}>"
		QEMU_PREREQ="${QEMU_PREREQ} <`setStatusColor ${QEMU_STATE} FAIL-INFO`:QEMUMGMT=${QEMUMGMT}>"

		QEMU_PREREQ="${QEMU_PREREQ} <GenericClientCapabilityOnly>"
		printDBG $S_QEMU ${D_SYS} $LINENO "$BASH_SOURCE" "$FUNCNAME:Missing VDE-switch."
		printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "Missing VDE-switch, is at least erroneous."
		printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "  QEMUSOCK = ${QEMUSOCK}"
		printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "  QEMUMGMT = ${QEMUMGMT}"
		return ${ABORT}
	    fi
	fi
	QEMU_SERVER=ENABLED;
	QEMU_PREREQ="${QEMU_PREREQ} <QEMUSOCK=${QEMUSOCK}_info-USER=${USER}-ACCESS-GRANTED>"
	QEMU_PREREQ="${QEMU_PREREQ} <QEMUMGMT=${QEMUMGMT}_info-USER=${USER}-ACCESS-GRANTED>"
    fi

    #enable conditionally - disable-checks follow immediately
    QEMU_STATE=ENABLED


    #currently somewhat restrictive to specific versions.
    case ${QEMU_MAGIC} in
	QEMU_090)
	    QEMU_DEFAULTOPTS="";
	    printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "Setting QEMU_MAGIC=\"QEMU_090\", draft-tested, switch to QEMU-0.9.1"
	    ;;

	QEMU_091)
	    QEMU_DEFAULTOPTS="";
	    ;;

	QEMU_09x)
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "Setting QEMU_MAGIC=\"QEMU_09x\" for an untested QEMU-0.9x version."
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "Might work perfectly, as long as compatible to QEMU-0.9.1, but is not verified."
	    QEMU_DEFAULTOPTS="";
	    ;;

	QEMU_010)
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "Setting QEMU_MAGIC=\"QEMU_010\" for an untested QEMU-0.10x version."
	    QEMU_DEFAULTOPTS="";
	    ;;

	QEMU_011)
	    QEMU_DEFAULTOPTS="";
	    ;;

	QEMU_012)
	    QEMU_DEFAULTOPTS="";
	    ;;

	QEMU_GENERIC)
	    QEMU_DEFAULTOPTS="";
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "Setting QEMU_GENERIC for unprepared version."
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "QEMU_GENERIC = \"${QEMU_PRODVERS}\""
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "KERNEL      = \"${MYOS} - ${MYOSREL}\""
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "."
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "Tested versions:"
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "->\"QEMU-0.9.[01]\""
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "->\"QEMU-0.12.2\""
	    ;;

         *)
	    QEMU_PREREQ="${QEMU_PREREQ} <UnknownMAGICID>"
	    QEMU_PREREQ="${QEMU_PREREQ} <GenericClientCapabilityOnly>"
	    printWNG 1 $LINENO $BASH_SOURCE 0 "Unknown MAGICID:${QEMU_MAGIC}"
	    printWNG 1 $LINENO $BASH_SOURCE 0 "Not supported or misconfigured local version:"
	    printWNG 1 $LINENO $BASH_SOURCE 0 "  ctys    :<${VERSION}>"
	    printWNG 1 $LINENO $BASH_SOURCE 0 "  QEMU    :<${_myPKGVERS_QEMU}>"
	    printWNG 1 $LINENO $BASH_SOURCE 0 "  Product :<${QEMU_PRODVERS}>"
	    printWNG 1 $LINENO $BASH_SOURCE 0 "."
	    printWNG 1 $LINENO $BASH_SOURCE 0 "Remaining $(setSeverityColor TRY safe) applicable $(setSeverityColor TRY options):"
	    printWNG 1 $LINENO $BASH_SOURCE 0 "->remote: \"-L DISPLAYFORWARDING\""
	    printWNG 1 $LINENO $BASH_SOURCE 0 "->remote: \"-L SERVERONLY\"(partial...)"
	    printWNG 1 $LINENO $BASH_SOURCE 0 "->local:  VNC-client"
	    printWNG 1 $LINENO $BASH_SOURCE 0 "."
	    ;;
    esac
    printDBG $S_QEMU ${D_FLOW} $LINENO $BASH_SOURCE "QEMU_MAGIC       = ${QEMU_MAGIC}"
    printDBG $S_QEMU ${D_FLOW} $LINENO $BASH_SOURCE "QEMU_STATE       = ${QEMU_STATE}"
    printDBG $S_QEMU ${D_FLOW} $LINENO $BASH_SOURCE "QEMU_VERSTRING   = ${QEMU_VERSTRING}"
    printDBG $S_QEMU ${D_FLOW} $LINENO $BASH_SOURCE "QEMU_PREREQ      = ${QEMU_PREREQ}"
    printDBG $S_QEMU ${D_FLOW} $LINENO $BASH_SOURCE "QEMU_DEFAULTOPTS = ${QEMU_DEFAULTOPTS}"

    [ "${QEMU_STATE}" == ENABLED ];
    return $?;
}





#FUNCBEG###############################################################
#NAME:
#  serverRequireQEMU
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Reports whether a server component has to be called for the current
#  action.
#
#EXAMPLE:
#
#PARAMETERS:
# $*: ${EXECCALL}|<options-list>
#     Generally a string containing an <options-list>, where the
#     first match is choosen. So only one type option is allowed to
#     be contained.
#
#OUTPUT:
#  RETURN:
#    INPUT, where required changes for destination are set.
#  VALUES:
#    0: true, required - output is valid.
#    1: false, not required - output is not valid.
#
#FUNCEND###############################################################
function serverRequireQEMU () {
    printDBG $S_QEMU ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME \$@=$@"
    local _CS_SPLIT=`echo ${*}|sed -n 's/CONNECTIONFORWARDING/SERVERONLY/p'`;
    local _S=`getSessionType ${*}`;_S=${_S:-$C_SESSIONTYPE};
    local _A=`getActionResulting ${*}`;
    local _ret=1;
    local _res=;

    printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "_CS_SPLIT=\"${_CS_SPLIT}\""
    printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "_S=\"${_S}\""
    printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "_A=\"${_A}\""

    #if split not supported server only could be used
    if [ -n "${_CS_SPLIT}" ];then
        #check for consoles, gwhich are one decisive for component location
	local _myConsole=;
	[ "${*}" != "${*//:[sS][dD][lL]}" ]&&_myConsole=SDL
	[ "${*}" != "${*//:[cC][lL][iI]}" ]&&_myConsole=CLI
	[ "${*}" != "${*//:[gG][tT][eE][rR][mM]}" ]&&_myConsole=GTERM
	[ "${*}" != "${*//:[xX][tT][eE][rR][mM]}" ]&&_myConsole=XTERM
	[ "${*}" != "${*//:[vV][nN][cC]}" ]&&_myConsole=VNC

	if [ -z "${_myConsole}" ];then
	    _myConsole=${QEMU_DEFAULT_CONSOLE}
	fi

	case $_A in 
 	    CONNECT)
		case $_myConsole in
		    SDL|CLI|GTERM|XTERM) #ERROR for CS-SPLIT, SERVERONLY allowed
			ABORT=1;
			printERR $LINENO $BASH_SOURCE ${ABORT} "The console type $_myConsole for $_A cannot be combined with"
			printERR $LINENO $BASH_SOURCE ${ABORT} "option: -L CONNECTIONFORWARDING"
			gotoHell ${ABORT}
			;;
		    VNC)
			_res=;_ret=1;
			;;
		    *)
			printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:Assume false:$_myConsole for $_A "
			_res=;_ret=1;
			;;
		esac
		;;
 	    CREATE)  
		case $_myConsole in
		    SDL|CLI|GTERM|XTERM) #ERROR for CS-SPLIT, SERVERONLY allowed
			ABORT=1;
			printERR $LINENO $BASH_SOURCE ${ABORT} "The console type $_myConsole for $_A cannot be combined with"
			printERR $LINENO $BASH_SOURCE ${ABORT} "option: -L CONNECTIONFORWARDING"
			gotoHell ${ABORT}
			;;
		    VNC)
			_res="${_CS_SPLIT}";_ret=0;
			;;
		    *)
			printWNG 1 $LINENO $BASH_SOURCE 0 "$FUNCNAME:Assume true:$_myConsole for $_A "
			_res="${*}";_ret=0;
			;;
		esac
		;;
	esac
    else
 	_res="${*}";_ret=0;
    fi

    printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_res=\"${_res}\""
    printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_ret=\"${_ret}\""
    echo -n "${_res}";
    return ${_ret};  
}



#FUNCBEG###############################################################
#NAME:
#  clientRequireQEMU
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Reports whether a client component has to be called for the current
#  action.
#
#EXAMPLE:
#
#PARAMETERS:
# $*: ${EXECCALL}|<options-list>
#     Generally a string containing an <options-list>, where the
#     first match is choosen. So only one type option is allowed to
#     be contained.
#
#OUTPUT:
#  RETURN:
#    INPUT, where required changes for destination are set.
#  VALUES:
#    0: true, required - output is valid.
#    1: false, not required - output is not valid.
#
#FUNCEND###############################################################
function clientRequireQEMU () {
    printDBG $S_QEMU ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME \$@=$@"
    local _CS_SPLIT=`echo ${*}|sed -n 's/CONNECTIONFORWARDING/1/p;s/LOCALONLY/1/p;s/CLIENTONLY/1/p'`;
    local _S=`getSessionType ${*}`;_S=${_S:-$C_SESSIONTYPE};
    local _A=`getActionResulting ${*}`;
    local _ret=1;
    local _res=;

    printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "_CS_SPLIT=\"${_CS_SPLIT}\""
    printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "_S=\"${_S}\""
    printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "_A=\"${_A}\""

    #if split not supported server only could be used
    if [ -n "${_CS_SPLIT}" ];then
        #check for consoles, gwhich are one decisive for component location
	local _myConsole=;
	[ "${*}" != "${*//:[sS][dD][lL]}" ]&&_myConsole=SDL
	[ "${*}" != "${*//:[cC][lL][iI]}" ]&&_myConsole=CLI
	[ "${*}" != "${*//:[gG][tT][eE][rR][mM]}" ]&&_myConsole=GTERM
	[ "${*}" != "${*//:[xX][tT][eE][rR][mM]}" ]&&_myConsole=XTERM
	[ "${*}" != "${*//:[vV][nN][cC]}" ]&&_myConsole=VNC

	if [ -z "${_myConsole}" ];then
	    _myConsole=${QEMU_DEFAULT_CONSOLE}
	fi

	case $_A in 
 	    CONNECT)
		case $_myConsole in
		    SDL|CLI|GTERM|XTERM) #ERROR for CS-SPLIT, SERVERONLY allowed
			ABORT=1;
			printERR $LINENO $BASH_SOURCE ${ABORT} "The console type $_myConsole for $_A cannot be combined with"
			printERR $LINENO $BASH_SOURCE ${ABORT} "option: -L CONNECTIONFORWARDING"
			gotoHell ${ABORT}
			;;
		    VNC)
			_res=${*};_ret=0;
			;;
		    *)
			printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:Assume true:$_myConsole for $_A "
			_res=${*};_ret=0;
			;;
		esac
		;;
 	    CREATE)  
		case $_myConsole in
		    SDL|CLI|GTERM|XTERM) #ERROR for CS-SPLIT, SERVERONLY allowed
			ABORT=1;
			printERR $LINENO $BASH_SOURCE ${ABORT} "The console type $_myConsole for $_A cannot be combined with"
			printERR $LINENO $BASH_SOURCE ${ABORT} "option: -L CONNECTIONFORWARDING"
			gotoHell ${ABORT}
			;;
		    VNC)
			_res=${*};_ret=0;
			;;
		    *)
			printWNG 1 $LINENO $BASH_SOURCE 0 "$FUNCNAME:Assume true:$_myConsole for $_A "
			_res=${*};_ret=0;
			;;
		esac
		;;
	esac
    else
 	_res=;_ret=1;
    fi

    printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_res=\"${_res}\""
    printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_ret=\"${_ret}\""
    echo -n "${_res}";
    return ${_ret};  
}



#FUNCBEG###############################################################
#NAME:
#  clientServerSplitSupportedQEMU
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Checks whether the split of client and server is supported.
#  This is just a hardcoded attribute and controls the application 
#  matrix of following attribute values of option "-L" locality:
#
#   - CONNECTIONFORWARDING
#   - DISPLAYFORWARDING
#   - SERVERONLY
#   - LOCALONLY
#
#EXAMPLE:
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#    0: If supported
#    1: else
#
#  VALUES:
#
#FUNCEND###############################################################
function clientServerSplitSupportedQEMU () {
    printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME $1"
    case $1 in
	CREATE)return 0;;
#	CANCEL)return 0;;
    esac
    return 1;
}


#
#Managed load of sub-packages gwhich are required in almost any case.
#On-demand-loads will be performed within requesting action.
#
hookPackage "${_myPKGBASE_QEMU}/config.sh"
hookPackage "${_myPKGBASE_QEMU}/session.sh"
hookPackage "${_myPKGBASE_QEMU}/enumerate.sh"
hookPackage "${_myPKGBASE_QEMU}/list.sh"
hookPackage "${_myPKGBASE_QEMU}/info.sh"



#FUNCBEG###############################################################
#NAME:
#  handleQEMU
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Main dispatcher for current plugin. It manages specific actions and
#  context-specific sets of suboptions.
#
#  It has to follow defined interfaces for main framework, due its dynamic
#  detection, load, and initialization.
#  Anything works by naming convention, for files, directories, and function 
#  names so don't alter it.
#
#  Arbitrary subpackages could be defined and chained-loaded. This is due 
#  design decision of plugin developers. Just the entry point is fixed by 
#  common framework.
#
#EXAMPLE:
#
#PARAMETERS:
#
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function handleQEMU () {
  printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "${FUNCNAME}:$*"
  local OPMODE=$1;shift
  local ACTION=$1;shift

  case ${ACTION} in
      CREATE) 
	  case ${OPMODE} in
              PROLOGUE)
		  ;;
              EPILOGUE)
		  ;;
	      CHECKPARAM)
		  hookPackage "${_myPKGBASE_QEMU}/create.sh"
		  createConnectQEMU ${OPMODE} ${ACTION} 
		  ;;
	      EXECUTE|ASSEMBLE)
		  hookPackage "${_myPKGBASE_QEMU}/create.sh"
		  createConnectQEMU ${OPMODE} ${ACTION} 
		  ;;
	  esac
	  ;;

      CANCEL)
	  case ${OPMODE} in
              PROLOGUE)
		  ;;
              EPILOGUE)
		  ;;
	      CHECKPARAM)
		  hookPackage "${_myPKGBASE_QEMU}/cancel.sh"
		  cutCancelSessionQEMU ${OPMODE} ${ACTION} 
		  ;;
	      EXECUTE|ASSEMBLE)
		  hookPackage "${_myPKGBASE_QEMU}/cancel.sh"
		  cutCancelSessionQEMU ${OPMODE} ${ACTION} 
		  ;;
	  esac
          ;;

      GETCLIENTPORT)
	  case ${OPMODE} in
              PROLOGUE)
		  ;;
              EPILOGUE)
		  ;;
              CHECKPARAM)
		  if [ -n "$C_MODE_ARGS" ];then
                      printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "C_MODE_ARGS=$C_MODE_ARGS"
                      _C_GETCLIENTPORT=$C_MODE_ARGS
		  else
		      ABORT=1
		      printERR $LINENO $BASH_SOURCE ${ABORT} "Missing <session-label>|<session-id>"
		      gotoHell ${ABORT}
		  fi
                  ;;

	      EXECUTE)
		  printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "Remote command:OPTARG=${OPTARG}"
  		  echo "CLIENTPORT(QEMU,${MYHOST},${_C_GETCLIENTPORT})=`getClientTPQEMU ${_C_GETCLIENTPORT//,/ }`"
		  gotoHell 0
		  ;;

 	      ASSEMBLE)
 		  ;;
          esac
	  ;;

      ISACTIVE)
	  case ${OPMODE} in
              PROLOGUE)
		  ;;
              EPILOGUE)
		  ;;
              CHECKPARAM)
		  if [ -n "$C_MODE_ARGS" ];then
                      printDBG $S_QEMU ${D_UID} $LINENO $BASH_SOURCE "C_MODE_ARGS=$C_MODE_ARGS"
                      _MYID=$C_MODE_ARGS
		  else
		      ABORT=1
		      printERR $LINENO $BASH_SOURCE ${ABORT} "Missing <session-id>"
		      gotoHell ${ABORT}
		  fi
                  ;;

	      EXECUTE)
		  printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "Remote command:OPTARG=${OPTARG}"
 		  echo "ISACTIVE(QEMU,${C_MODE_ARGS})=`isActiveQEMU ${C_MODE_ARGS}`"
		  gotoHell 0
		  ;;

 	      ASSEMBLE)
 		  ;;
          esac
	  ;;


      *)
          ABORT=1;
          printERR $LINENO $BASH_SOURCE ${ABORT} "System Error, unexpected QEMU:OPMODE=${OPMODE} ACTION=${ACTION}"
	  gotoHell ${ABORT}
          ;;
  esac
}



#FUNCBEG###############################################################
#NAME:
#  initQEMU
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function initQEMU () {
  local _curInit=$1;shift
  local _initConsequences=$1
  local ret=0;

  local _raise=$((INITSTATE<_curInit));

  printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:${INITSTATE} -> ${_curInit} - ${_raise}"

  if [ "$_raise" == "1" ];then
      #for raise of INITSTATE do not touch the OS's decisions, just expand.

      case $_curInit in
	  0);;#NOP - Done by shell
	  1)  
              #adjust version specifics  
              setVersionQEMU $_initConsequences
              ret=$?

              #add own help to searchlist for options
	      MYOPTSFILES="${MYOPTSFILES} ${MYHELPPATH}/010_qemu"
	      ;;
	  2);;
	  3);;
	  4);;
	  5);;
	  6);;
      esac
  else
      case $_curInit in
	  *);;
      esac

  fi

  return $ret
}
