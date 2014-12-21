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
# Copyright (C) 2007,2008,2010,2011 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

#XEN generic default parameters, will be reset in setVersionXEN
XEN_MAGIC=XEN_GENERIC
XEN_VERSTRING=;
XEN_STATE=DISABLED
XEN_DEFAULTOPTS="-x -q"
XEN_PREREQ=;
XEN_PRODVERS=;
XEN_ACCELERATOR=;
XEN_SERVER=;

_myPKGNAME_XEN="${BASH_SOURCE}"
_myPKGVERS_XEN="01.11.018"
hookInfoAdd $_myPKGNAME_XEN $_myPKGVERS_XEN

_myPKGBASE_XEN="`dirname ${_myPKGNAME_XEN}`"

XEN_VERSTRING="${_myPKGVERS_XEN}";

#used for LIST of jobdata by cacheStoreWorkerPIDData
XENJOBPOSTFIX="DomU"


if [ -d "${HOME}/.ctys" -a -d "${HOME}/.ctys/xen" ];then
    #Source pre-set environment from user
    if [ -f "${HOME}/.ctys/xen/xen.conf-${MYOS}.sh" ];then
	. "${HOME}/.ctys/xen/xen.conf-${MYOS}.sh"
    fi
fi

if [ -d "${MYCONFPATH}/xen" ];then
    if [ -f "${MYCONFPATH}/xen/xen.conf-${MYOS}.sh" ];then
	. "${MYCONFPATH}/xen/xen.conf-${MYOS}.sh"
    fi
fi

_waitcXEN=${XEN_INIT_WAITC:-2}
_waitsXEN=${XEN_INIT_WAITS:-2}

_pingXEN=${CTYS_PING_DEFAULT_XEN:-1};
_pingcntXEN=${CTYS_PING_ONE_MAXTRIAL_XEN:-20};
_pingsleepXEN=${CTYS_PING_ONE_WAIT_XEN:-2};

_sshpingXEN=${CTYS_SSHPING_DEFAULT_XEN:-0};
_sshpingcntXEN=${CTYS_SSHPING_ONE_MAXTRIAL_XEN:-20};
_sshpingsleepXEN=${CTYS_SSHPING_ONE_WAIT_XEN:-2};

_actionuserXEN="${MYUID}";



. ${MYLIBPATH}/lib/libXENbase.sh



#FUNCBEG###############################################################
#NAME:
#  getClientTPXEN
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
# GENERIC-IF-DESCRIPTION:
#  Gives the termination points port number, to gwhich a client could be 
#  attachhed. This port is forseen to be used in port-forwarding e.g.
#  by OpenSSH.
#
#  The port is the local port number, gwhich in general has to be mapped 
#  on remote site, when already in use. Therefore the application has
#  to provide a port-number-independent client access protocol in order 
#  to be used by connection forwarding. In any other case display 
#  forwarding has to be choosen.
#
#  Some applications support only one port for access by multiple 
#  sessions, dispatching and bundling the communications channels
#  by their own protocol. 
#
#  While others require for each channel a seperate litenning port.
#
#  So it is up to the specific package to support a function returning 
#  the required port number gwhich could be used to attach an forwarded 
#  port. 
#  
#  The applications client has to support a remapped port number.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: <label>
#       The <label> to gwhich the client will be attached.
#
#  $2: <pname>
#      The pname of the configuration file, this is required for 
#      VNC-sessions, and given to avoid scanning for labels
#
#OUTPUT:
#  RETURN:
#    0: If OK
#    1: else
#
#  VALUES:
#    <TP-port>
#      The TP port, to gwhich a client could be attached.
#
#FUNCEND###############################################################
function getClientTPXEN () {
    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=$@"
    local _ret=`listMySessionsXEN S MACHINE|awk -F';' -v l="${1}" '$2~l{print $7;}'`
    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME port number=<$_ret> from LABEL=<$1> ID=<$2>"
    echo ${_ret}
}


#FUNCBEG###############################################################
#NAME:
#  isActiveXEN
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
#OUTPUT:
#  RETURN:
#    0: Active
#    1: Not active
#
#  VALUES:
#    0: Active
#    1: Not active
#
#FUNCEND###############################################################
function isActiveXEN () {
    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:<$1>"

    if [ -z "$1" ];then
	ABORT=2
	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing ID"
	gotoHell ${ABORT}
    fi
    local x=$(${PS} ${PSEF} |grep -v "grep"|grep -v "$CALLERJOB"|grep ${1#*:} 2>/dev/null)

    case ${XEN_MAGIC} in
	XEN_*)
	    if [ -n "${VIRSH}" ];then
                    #preferred
		x=`callErrOutWrapper $LINENO $BASH_SOURCE ${VIRSHCALL} ${VIRSH} list|grep ${1#*:} 2>/dev/null`
	    else
		ABORT=2
		printERR $LINENO $BASH_SOURCE ${ABORT} "Requires VIRSH or XM"
		gotoHell ${ABORT}
	    fi
  	    ;;
        RELAY)#no own client support, see hosts plugins
            ;;
        DISABLED)#nothing to do
            ;;
	*)  #ooooops!!!!!!
	    ABORT=2
	    printERR $LINENO $BASH_SOURCE ${ABORT} "mismatch:XEN_MAGIC=${XEN_MAGIC}"
	    gotoHell ${ABORT}
	    ;;
    esac

    if [ -n "$x" ];then
	printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:0($x)"
	echo 0
	return 0;
    fi
    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:1($x)"
    echo 1
    return 1;
}




#FUNCBEG###############################################################
#NAME:
#  serverRequireXEN
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
function serverRequireXEN () {
    printDBG $S_XEN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME \$@=$@"
    local _CS_SPLIT=`echo ${*}|sed -n 's/CONNECTIONFORWARDING/SERVERONLY/p'`;
    local _S=`getSessionType ${*}`;_S=${_S:-$C_SESSIONTYPE};
    local _A=`getActionResulting ${*}`;
    local _ret=1;
    local _res=;

    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "_CS_SPLIT=\"${_CS_SPLIT}\""
    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "_S=\"${_S}\""
    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "_A=\"${_A}\""

    #if split not supported server only could be used
    if [ -n "${_CS_SPLIT}" ];then
        #check for consoles, gwhich are one decisive for component location
	local _myConsole=;
	[ "${*}" != "${*//:[cC][lL][iI]}" ]&&_myConsole=CLI
	[ "${*}" != "${*//:[gG][tT][eE][rR][mM]}" ]&&_myConsole=GTERM
	[ "${*}" != "${*//:[xX][tT][eE][rR][mM]}" ]&&_myConsole=XTERM
	[ "${*}" != "${*//:[vV][nN][cC]}" ]&&_myConsole=VNC

	case $_A in 
 	    CONNECT)
		case $_myConsole in
		    CLI|GTERM|XTERM) #ERROR for CS-SPLIT, SERVERONLY allowed
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
		    CLI|GTERM|XTERM) #ERROR for CS-SPLIT, SERVERONLY allowed
			ABORT=1;
			printERR $LINENO $BASH_SOURCE ${ABORT} "The console type $_myConsole for $_A cannot be combined with"
			printERR $LINENO $BASH_SOURCE ${ABORT} "option: -L CONNECTIONFORWARDING"
			gotoHell ${ABORT}
			;;
		    VNC)
			_res="${_CS_SPLIT}";_ret=0;
			;;
		    *)
			printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:Assume true:$_myConsole for $_A "
			_res="${*}";_ret=0;
			;;
		esac
		;;
	esac
    else
 	_res="${*}";_ret=0;
    fi

    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_res=\"${_res}\""
    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_ret=\"${_ret}\""
    echo -n "${_res}";
    return ${_ret};  
}



#FUNCBEG###############################################################
#NAME:
#  clientRequireXEN
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
function clientRequireXEN () {
    printDBG $S_XEN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME \$@=$@"
    local _CS_SPLIT=`echo ${*}|sed -n 's/CONNECTIONFORWARDING/1/p;s/LOCALONLY/1/p;s/CLIENTONLY/1/p'`;
    local _S=`getSessionType ${*}`;_S=${_S:-$C_SESSIONTYPE};
    local _A=`getActionResulting ${*}`;
    local _ret=1;
    local _res=;

    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "_CS_SPLIT=\"${_CS_SPLIT}\""
    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "_S=\"${_S}\""
    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "_A=\"${_A}\""

    #if split not supported server only could be used
    if [ -n "${_CS_SPLIT}" ];then
        #check for consoles, gwhich are one decisive for component location
	local _myConsole=;
	[ "${*}" != "${*//:[cC][lL][iI]}" ]&&_myConsole=CLI
	[ "${*}" != "${*//:[gG][tT][eE][rR][mM]}" ]&&_myConsole=GTERM
	[ "${*}" != "${*//:[xX][tT][eE][rR][mM]}" ]&&_myConsole=XTERM
	[ "${*}" != "${*//:[vV][nN][cC]}" ]&&_myConsole=VNC

	case $_A in 
 	    CONNECT)
		case $_myConsole in
		    CLI|GTERM|XTERM) #ERROR for CS-SPLIT, SERVERONLY allowed
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
		    CLI|GTERM|XTERM) #ERROR for CS-SPLIT, SERVERONLY allowed
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
	esac
    else
 	_res=;_ret=1;
    fi

    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_res=\"${_res}\""
    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_ret=\"${_ret}\""
    echo -n "${_res}";
    return ${_ret};  
}



#FUNCBEG###############################################################
#NAME:
#  setVersionXEN
#
#TYPE:
#  bash-function
#
:
#  Sets defaults and MAGIC-ID for local Xen version.
#
#  The defaults for XEN_DEFAULTOPTS will only be used when no CLI
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
#    XEN_MAGIC:  {XEN_3|...}
#      Value to be checked, when no local native components are 
#      present, the following values will be set.
#
#
#    XEN_DEFAULTOPTS
#      Appropriate defaults.
#
#      -XM                   : ""
#
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function setVersionXEN () {
    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=$@"
    local _checkonly=;
    if [ "$1" == "NOEXIT" ];then
	local _checkonly=1;        
    fi

    #
    #present for a Xen-ified kernel
    local _syscap=/sys/hypervisor/properties/capabilities

    #will load only when missing
    hookPackage CLI
    hookPackage X11
    hookPackage VNC
    hookInitPropagate4Package CLI X11 VNC

    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:loaded pre-requisites:CLI, X11, VNC"

    #
    #Check local components in any case, post-fetchin here puts them to init list
    #by the time.
    #

    #CLI - let us say required!!!
    local _vncOK=`hookInfoCheckPKG CLI`
    if [ -z "${_vncOK}" ];then
	ABORT=1;
	if [ "${C_SESSIONTYPE}" == "XEN" -a -z "${_checkonly}" ];then
	    printERR $LINENO $BASH_SOURCE ${ABORT} "This feature requires additional CLI plugin to be pre-loaded."
	    printERR $LINENO $BASH_SOURCE ${ABORT} "-> Set the option \"-T vnc,cli,...\" "
	    printERR $LINENO $BASH_SOURCE ${ABORT} "-> Check actually loaded plugins with option \"-v\""
	    gotoHell ${ABORT}
	else
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "This feature reuqires additional CLI plugin to be pre-loaded."
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "-> Set the option \"-T vnc,cli,...\" "
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "-> Check actually loaded plugins with option \"-v\""
	    return ${ABORT}
	fi
    else
	XEN_PREREQ="${XEN_PREREQ} CLI-ValidatedBy(hookInfoCheckPKG)"
    fi

    #X11 - let us say required!!!
    local _vncOK=`hookInfoCheckPKG X11`
    if [ -z "${_vncOK}" ];then
	ABORT=1;
	if [ "${C_SESSIONTYPE}" == "XEN" -a -z "${_checkonly}" ];then
	    printERR $LINENO $BASH_SOURCE ${ABORT} "This feature requires additional X11 plugin to be pre-loaded."
	    printERR $LINENO $BASH_SOURCE ${ABORT} "-> Set the option \"-T vnc,x11,...\" "
	    printERR $LINENO $BASH_SOURCE ${ABORT} "-> Check actually loaded plugins with option \"-v\""
	    gotoHell ${ABORT}
	else
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "This feature reuqires additional X11 plugin to be pre-loaded."
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "-> Set the option \"-T vnc,x11,...\" "
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "-> Check actually loaded plugins with option \"-v\""
	    return ${ABORT}
	fi
    else
	XEN_PREREQ="${XEN_PREREQ} X11-ValidatedBy(hookInfoCheckPKG)"
    fi

    #VNC - let us say required!!!
    local _vncOK=`hookInfoCheckPKG VNC`
    if [ -z "${_vncOK}" ];then
	ABORT=1;
	if [ "${C_SESSIONTYPE}" == "XEN" -a -z "${_checkonly}" ];then
	    printERR $LINENO $BASH_SOURCE ${ABORT} "This feature requires additional VNC plugin to be pre-loaded."
	    printERR $LINENO $BASH_SOURCE ${ABORT} "-> Set the option \"-T vnc,xen,...\" "
	    printERR $LINENO $BASH_SOURCE ${ABORT} "-> Check actually loaded plugins with option \"-v\""
	    gotoHell ${ABORT}
	else
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "This feature reuqires additional VNC plugin to be pre-loaded."
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "-> Set the option \"-T vnc,xen,...\" "
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "-> Check actually loaded plugins with option \"-v\""
	    return ${ABORT}
	fi
    else
	XEN_PREREQ="${XEN_PREREQ} VNC-ValidatedBy(hookInfoCheckPKG)"
    fi

    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:verified pre-requisites:CLI, X11, VNC"

    #
    #if not final and though actual execution target just relay it,
    #so client and additional basic server-checks only on this node
    #
    XEN_MAGIC=RELAY;
    if [ -n "${_vncOK}" ];then
	XEN_PREREQ="${XEN_PREREQ} <LocalClientVNC>"
    fi
    XEN_PREREQ="${XEN_PREREQ} <LocalXserverDISPLAY>"
    XEN_PREREQ="${XEN_PREREQ} <delayedValidationOnFinalTarget>"
    if [ -z "$C_EXECLOCAL" ];then
	XEN_STATE=ENABLED
	XEN_PREREQ="VM-CAPABILITY:GenericClientCapabilityOnly ${XEN_PREREQ}"
	printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:C_EXECLOCAL  = ${C_EXECLOCAL}"
	printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:XEN_MAGIC       = ${XEN_MAGIC}"
	printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:XEN_STATE       = ${XEN_STATE}"
	printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:XEN_VERSTRING   = ${XEN_VERSTRING}"
	printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:XEN_PREREQ      = ${XEN_PREREQ}"
	printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:XEN_DEFAULTOPTS = ${XEN_DEFAULTOPTS}"
	return 0
    fi

    local _myLoc=`getLocation ${C_CLIENTLOCATION}`
    if [ -z "${XM}" ];then
	XEN_MAGIC=NOLOC;
	XEN_PREREQ="${XEN_PREREQ} <`setStatusColor ${XEN_STATE} MISSING`:xm>"
	if [ "${C_SESSIONTYPE}" == "XEN" -a -z "${_checkonly}" -a "${_myLoc}" != CONNECTIONFORWARDING -a "${_myLoc}" != CLIENTONLY  ];then
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Cannot execute \"xm\""
	    gotoHell ${ABORT}
	else
	    return ${ABORT}
	fi
    fi
    if [ -z "${VIRSH}" ];then
	XEN_MAGIC=NOLOC;
	XEN_PREREQ="${XEN_PREREQ} <`setStatusColor ${XEN_STATE} MISSING`:virsh>"
	if [ "${C_SESSIONTYPE}" == "XEN" -a -z "${_checkonly}" -a "${_myLoc}" != CONNECTIONFORWARDING -a "${_myLoc}" != CLIENTONLY  ];then
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Cannot execute \"virsh\""
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Check the installation of \"libvirt\", gwhich is a mandatory prerequisite for XEN."
	    gotoHell ${ABORT}
	else
	    return ${ABORT}
	fi
    fi

    #setup callee for executables requiring root-permission 
    checkedSetSUaccess  "${MYCONFPATH}/xen/xen.conf-${MYOS}.sh" XENCALL    XM                 info
    checkedSetSUaccess  "${MYCONFPATH}/xen/xen.conf-${MYOS}.sh" VIRSHCALL  VIRSH              connect

    #could be set to Xen original, gwhich has default no-permission
    checkedSetSUaccess  "${MYCONFPATH}/xen/xen.conf-${MYOS}.sh" XBCALL    XEN_BRIDGE_SCRIPT status

    local _verstrg=$(getVersionStrgXEN);

    #
    #give it up, but as a client almost any machine might work
    #
    if [ -z "${_verstrg}" ];then
	XEN_MAGIC=NOLOC;
	ABORT=2
	XEN_PREREQ="${XEN_PREREQ} <`setStatusColor ${XEN_STATE} MISSING`:EVAL-VERSION>"
	if [ "${C_SESSIONTYPE}" == "XEN" -a -z "${_checkonly}" ];then
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Cannot evaluate version"
	    gotoHell ${ABORT}
	else
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "CHKONLY:Xen seems not to be installed."
	    return ${ABORT}
	fi
    fi
    XEN_PRODVERS=${_verstrg};
    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:XEN_PRODVERS=${XEN_PRODVERS}"
    XEN_ACCELERATOR=$(getACCELERATOR_XEN);
    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:XEN_ACCELERATOR=${XEN_ACCELERATOR}"

    XEN_MAGIC=$(getXENMAGIC);

    #basic tool is xm
    if [ -z "$XM" ];then
	XEN_MAGIC=NOLOC;
	XEN_PREREQ="${XEN_PREREQ} <`setStatusColor ${XEN_STATE} MISSING`:xm>"
	ABORT=2
	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing executable for xm check your Xen installation."
	printERR $LINENO $BASH_SOURCE ${ABORT} "  Checked by call of:\"${XENCALL} gwhich ${XM}\""
	printERR $LINENO $BASH_SOURCE ${ABORT} "   =>\"${_res}\""
	printERR $LINENO $BASH_SOURCE ${ABORT} "  For call-prefix configuration see XENCALL"
	printERR $LINENO $BASH_SOURCE ${ABORT} "PATH--->`echo;splitPath 10 PATH ${PATH}`"
	printERR $LINENO $BASH_SOURCE ${ABORT} "<---PATH"
	if [ "${C_SESSIONTYPE}" == "XEN" -a -z "${_checkonly}" ];then
	    gotoHell ${ABORT}
	else
	    return ${ABORT}
	fi
    fi


    #enable conditionally - disable-checks follow immediately
    XEN_STATE=ENABLED

    local _cap=;
    if [ -e "${_syscap}" ];then
	for i in `cat ${_syscap}`;do

	    if [ -z "${_verstrg}" ];then
		_verstrg=$i;
		XEN_PREREQ="${XEN_PREREQ} <${_verstrg}-from(${_syscap// /_})>"
		_cap="$i";
	    else
		_cap="${_cap}%$i";
	    fi
	done
    else
	XEN_STATE=DISABLED
	XEN_MAGIC=DISABLED;
	XEN_PREREQ="${XEN_PREREQ} <`setStatusColor ${XEN_STATE} MISSING`:kernel_not_active:${_cap// /_}>"

	printDBG $S_XEN ${D_FLOW} $LINENO $BASH_SOURCE "Missing capabilities: XEN_STATE = ${XEN_STATE}"
    fi

    #Check:ACCESS-PERMISSIONS-XM
    if [ "${XEN_STATE}" == ENABLED ];then
	callErrOutWrapper $LINENO $BASH_SOURCE  ${XENCALL} ${XM} info >/dev/null
	if [ $? -ne 0 ];then
	    XEN_STATE=DISABLED
	    if [ "${USER}" == "root" ];then
		XEN_PREREQ="${XEN_PREREQ} <`setStatusColor ${XEN_STATE} ACCESS-FAILED`:xm_info>"
	    else
		XEN_MAGIC=NO_PERMISSION;
		XEN_PREREQ="${XEN_PREREQ} <`setStatusColor ${XEN_STATE} ACCESS-FAILED-CHECK-PERMISSION`:xm>"
	    fi
	    if [ "$C_SESSIONTYPE" == XEN ];then
 		ABORT=1
		printERR $LINENO $BASH_SOURCE ${ABORT} "Final check of access-permissions for current USER=${USER} failed."
		printERR $LINENO $BASH_SOURCE ${ABORT} "=> failed to perform \"${XENCALL} ${XM} info\""
		printERR $LINENO $BASH_SOURCE ${ABORT} "most common reason is required root permission, check "
		printERR $LINENO $BASH_SOURCE ${ABORT} " => ksu/sudo  \"...-Z KSU,SUDO \""
		printERR $LINENO $BASH_SOURCE ${ABORT} " => setting XEN_STATE=DISABLED"
		gotoHell ${ABORT}
	    else
		ABORT=0
		printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "Final check of access-permissions for current USER=${USER} failed."
		printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "=> failed to perform \"${XENCALL} ${XM} info\""
		printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "most common reason is required root permission, check "
		printWNG 2 $LINENO $BASH_SOURCE ${ABORT} " => ksu/sudo  \"...-Z KSU,SUDO \""
		printWNG 2 $LINENO $BASH_SOURCE ${ABORT} " => setting XEN_STATE=DISABLED"
	    fi
	    XEN_MAGIC=NO_PERMISSION;
	    XEN_PREREQ="${XEN_PREREQ} <`setStatusColor ${XEN_STATE} FAILED`:${XENCALL// /_}_${XM}_info-USER=${USER}-NO-ACCESS>"
	else
	    XEN_PREREQ="${XEN_PREREQ} ${XENCALL// /_}_${XM}_info-USER=${USER}-ACCESS-PERMISSION-GRANTED"
	fi
    fi

    #Check:ACCESS-PERMISSIONS-VIRSH
    if [ "${XEN_STATE}" == ENABLED ];then
	callErrOutWrapper $LINENO $BASH_SOURCE  ${VIRSHCALL} ${VIRSH} dominfo 0 >/dev/null
	if [ $? -ne 0 -a "${XEN_STATE}" == ENABLED ];then
	    XEN_STATE=DISABLED
	    XEN_MAGIC=NO_PERMISSION;
	    XEN_PREREQ="${XEN_PREREQ} <`setStatusColor ${XEN_STATE} ACCESS-PERMISSION-MISSING-OR-FAILURE`:virsh>"
	    if [ "$C_SESSIONTYPE" == XEN ];then
		ABORT=1
		printERR $LINENO $BASH_SOURCE ${ABORT} "Final check of access-permissions for current USER=${USER} failed."
		printERR $LINENO $BASH_SOURCE ${ABORT} "=> failed to perform \"${VIRSHCALL} ${VIRSH} info\""
		printERR $LINENO $BASH_SOURCE ${ABORT} "most common reason is required root permission, check "
		printERR $LINENO $BASH_SOURCE ${ABORT} " => ksu/sudo  \"...-Z KSU,SUDO \""
		printERR $LINENO $BASH_SOURCE ${ABORT} " => setting XEN_STATE=DISABLED"
		gotoHell ${ABORT}
	    else
		printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "Final check of access-permissions for current USER=${USER} failed."
		printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "=> failed to perform \"${VIRSHCALL} ${VIRSH} info\""
		printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "most common reason is required root permission, check "
		printWNG 2 $LINENO $BASH_SOURCE ${ABORT} " => ksu/sudo  \"...-Z KSU,SUDO \""
		printWNG 2 $LINENO $BASH_SOURCE ${ABORT} " => setting XEN_STATE=DISABLED"
	    fi
	    XEN_STATE=DISABLED
	    XEN_MAGIC=NO_PERMISSION;
	    XEN_PREREQ="${XEN_PREREQ} <`setStatusColor ${XEN_STATE} FAILED`:${VIRSHCALL// /_}_${VIRSH}_dominfo-USER=${USER}-NO-ACCESS-PERMISSION>"
	else
	    XEN_PREREQ="${XEN_PREREQ} ${VIRSHCALL// /_}_${VIRSH}_dominfo-USER=${USER}-ACCESS-PERMISSION-GRANTED"
	fi
    fi

    #Check:HYPERVISOR-STATE
    if [ "${XEN_STATE}" == ENABLED ];then
	${XENCALL} ${XM} info 2>&1 |grep -q "nr_cpus" 
	if [ $? -ne 0 ];then
	    XEN_STATE=DISABLED
 	    XEN_PREREQ="${XEN_PREREQ} <`setStatusColor ${XEN_STATE} MISSING-ACCESS_PERMISSION`:${XENCALL// /_}_${XM}_info-HYPERVISOR-STATE=DISABLED"
	    ${VIRSHCALL} ${VIRSH} info 2>&1 |grep -q "running" 
	    if [ $? -ne 0 ];then
		printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "Xen-Hypervisor is not active,"
		printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "you probably are not in Dom0, try another kernel."
		printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "  MYHOST  =${MYHOST}"
		printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "  MYOS    =${MYOS}"
		printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "  MYOSREL =${MYOSREL}"
		XEN_MAGIC=DISABLED;
		XEN_PREREQ="${XEN_PREREQ} <`setStatusColor ${XEN_STATE} FAILED`:${VIRSHCALL// /_}_${VIRSH}_info-HYPERVISOR-STATE=DISABLED"
		printDBG $S_XEN ${D_FLOW} $LINENO $BASH_SOURCE "${VIRSH}_info-HYPERVISOR: XEN_STATE = ${XEN_STATE}"
	    else
		XEN_STATE=ENABLED
		XEN_PREREQ="${XEN_PREREQ} `setStatusColor ${XEN_STATE} ENABLED`:${VIRSHCALL// /_}_${VIRSH}_info-HYPERVISOR-STATE=ENABLED"
	    fi
	else
	    XEN_PREREQ="${XEN_PREREQ} ${XENCALL// /_}_${XM}_info-HYPERVISOR-STATE=ENABLED"
	    XEN_SERVER=ENABLED;
	fi
    fi

    #
    #currently somewhat restrictive to specific versions due to sparsely documented
    #variants.
    #
    case ${XEN_MAGIC} in
	XEN_303)
	    XEN_DEFAULTOPTS="";
	    XEN_VERSTRING="${_myPKGVERS_XEN}";
	    XEN_PREREQ="VM-CAPABILITY:XEN-${XEN_VERSTRING}-${MYARCH}${_cap:+%$_cap} ${XEN_PREREQ}"
	    ;;

	XEN_30)
	    XEN_DEFAULTOPTS="";
	    XEN_VERSTRING="${_myPKGVERS_XEN}";
	    XEN_PREREQ="VM-CAPABILITY:XEN-${XEN_VERSTRING}-${MYARCH}${_cap:+%$_cap} ${XEN_PREREQ}"
	    ;;

	XEN_310)
	    XEN_DEFAULTOPTS="";
	    XEN_VERSTRING="${_myPKGVERS_XEN}";
	    XEN_PREREQ="VM-CAPABILITY:XEN-${XEN_VERSTRING}-${MYARCH}${_cap:+%$_cap} ${XEN_PREREQ}"
	    ;;

	XEN_31x)
	    printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "Setting XEN_MAGIC=\"XEN_31x\" for an untested xen-3.1.x version."
	    printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "."
	    printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "Tested (hypervisor-)versions:"
	    printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "->\"xen-3.0.3\"."
	    printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "->\"xen-3.2.1\"."
	    XEN_DEFAULTOPTS="";
	    XEN_VERSTRING="${_myPKGVERS_XEN}";
	    XEN_PREREQ="VM-CAPABILITY:XEN-${XEN_VERSTRING}-${MYARCH}${_cap:+%$_cap} ${XEN_PREREQ}"
	    ;;

	XEN_321)
	    XEN_DEFAULTOPTS="";
	    XEN_VERSTRING="${_myPKGVERS_XEN}";
	    XEN_PREREQ="VM-CAPABILITY:XEN-${XEN_VERSTRING}-${MYARCH}${_cap:+%$_cap} ${XEN_PREREQ}"
	    ;;

	XEN_32x)
	    printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "Setting XEN_MAGIC=\"XEN_32x\" for an untested xen-3.2.x version."
	    printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "."
	    printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "Tested (hypervisor-)versions:"
	    printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "->\"xen-3.0.3\"."
	    printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "->\"xen-3.2.1\"."
	    XEN_VERSTRING="${_myPKGVERS_XEN}";
	    XEN_DEFAULTOPTS="";
	    XEN_PREREQ="VM-CAPABILITY:XEN-${XEN_VERSTRING}-${MYARCH}${_cap:+%$_cap} ${XEN_PREREQ}"
	    ;;

	XEN_3x)
	    printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "Setting XEN_MAGIC=\"XEN_3x\" for an untested xen-3.x version."
	    printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "."
	    printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "Tested (hypervisor-)versions:"
	    printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "->\"xen-3.0.3\"."
	    printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "->\"xen-3.2.1\"."
	    XEN_DEFAULTOPTS="";
	    XEN_VERSTRING="${_myPKGVERS_XEN}";
	    XEN_PREREQ="VM-CAPABILITY:XEN-${XEN_VERSTRING}-${MYARCH}${_cap:+%$_cap} ${XEN_PREREQ}"
	    ;;

	XEN_400)
	    XEN_DEFAULTOPTS="";
	    XEN_VERSTRING="${_myPKGVERS_XEN}";
	    XEN_PREREQ="VM-CAPABILITY:XEN-${XEN_VERSTRING}-${MYARCH}${_cap:+%$_cap} ${XEN_PREREQ}"
	    ;;

	XEN_4x)
	    printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "Setting XEN_MAGIC=\"XEN_4x\" for an untested xen-4.x version."
	    printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "."
	    printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "Tested (hypervisor-)versions:"
	    printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "->\"xen-4.0.0_21091_05-6.6\"."
	    XEN_DEFAULTOPTS="";
	    XEN_VERSTRING="${_myPKGVERS_XEN}";
	    XEN_PREREQ="VM-CAPABILITY:XEN-${XEN_VERSTRING}-${MYARCH}${_cap:+%$_cap} ${XEN_PREREQ}"
	    ;;

	XEN_GENERIC)
            #
	    XEN_DEFAULTOPTS="";
	    XEN_VERSTRING="${_myPKGVERS_XEN}";
	    XEN_PREREQ="VM-CAPABILITY:XEN-${XEN_VERSTRING}-${MYARCH}${_cap:+%$_cap} ${XEN_PREREQ}"
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "Setting XEN_GENERIC for unprepared version."
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "Somewhat risky due to feature evolution, but anyhow, setting it."
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "XEN_GENERIC = \"${_verstrg}\""
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "KERNEL      = \"${MYOS} - ${MYOSREL}\""
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "."
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "Tested (hypervisor-)versions:"
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "->\"xen-3.0.3\"."
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "->\"xen-3.2.1\"."
	    ;;

         NOLOC)
	    printWNG 1 $LINENO $BASH_SOURCE 0 "Not supported or misconfigured local version:"
	    printWNG 1 $LINENO $BASH_SOURCE 0 "  ctys    :<${VERSION}>"
	    printWNG 1 $LINENO $BASH_SOURCE 0 "  XEN     :<${_myPKGVERS_XEN}>"
	    printWNG 1 $LINENO $BASH_SOURCE 0 "  Product :<${_verstrg}>"
	    printWNG 1 $LINENO $BASH_SOURCE 0 "."
	    printWNG 1 $LINENO $BASH_SOURCE 0 "Remaining applicable options:"
	    printWNG 1 $LINENO $BASH_SOURCE 0 "->remote: \"-L DISPLAYFORWARDING\""
	    printWNG 1 $LINENO $BASH_SOURCE 0 "->remote: \"-L SERVERONLY\"(partial...)"
	    printWNG 1 $LINENO $BASH_SOURCE 0 "->local:  VNC-client"
	    printWNG 1 $LINENO $BASH_SOURCE 0 "."
	    XEN_PREREQ="VM-CAPABILITY:XEN-${XEN_VERSTRING}-${MYARCH}${_cap:+%$_cap} ${XEN_PREREQ}"
	    ;;
    esac
    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:XEN_MAGIC       = ${XEN_MAGIC}"
    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:XEN_STATE       = ${XEN_STATE}"
    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:XEN_VERSTRING   = ${XEN_VERSTRING}"
    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:XEN_PREREQ      = ${XEN_PREREQ}"
    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:XEN_DEFAULTOPTS = ${XEN_DEFAULTOPTS}"

    return $?;
}




#FUNCBEG###############################################################
#NAME:
#  clientServerSplitSupportedXEN
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
function clientServerSplitSupportedXEN () {
    printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME $1"
    case $1 in
	CREATE)return 0;;
#	CANCEL)return 0;;
    esac
    return 1;
}


#FUNCBEG###############################################################
#NAME:
#  handleXEN
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
function handleXEN () {
  printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "${FUNCNAME}:$*"

  local OPMODE=$1;shift
  local ACTION=$1;shift

  case ${ACTION} in
      LIST)
	  case ${OPMODE} in
              PROLOGUE)
		  hookPackage "${_myPKGBASE_XEN}/config.sh"
		  hookPackage "${_myPKGBASE_XEN}/list.sh"
		  ;;
              EPILOGUE)
		  ;;
	      CHECKPARAM)
		  ;;
	      ASSEMBLE)
		  ;;
	      EXECUTE)
		  ;;
	  esac
	  ;;

      INFO)
	  case ${OPMODE} in
              PROLOGUE)
		  hookPackage "${_myPKGBASE_XEN}/info.sh"
		  ;;
              EPILOGUE)
		  ;;
	      CHECKPARAM)
		  ;;
	      ASSEMBLE)
		  ;;
	      EXECUTE)
		  hookPackage "${_myPKGBASE_XEN}/list.sh"
		  ;;
	  esac
	  ;;

      ENUMERATE)
	  case ${OPMODE} in
              PROLOGUE)
		  hookPackage "${_myPKGBASE_XEN}/config.sh"
		  hookPackage "${_myPKGBASE_XEN}/enumerate.sh"
		  ;;
              EPILOGUE)
		  ;;
	      CHECKPARAM)
		  ;;
	      ASSEMBLE)
		  ;;
	      EXECUTE)
		  hookPackage "${_myPKGBASE_XEN}/session.sh"
		  hookPackage "${_myPKGBASE_XEN}/list.sh"
		  ;;
	  esac
	  ;;

      CREATE) 
	  case ${OPMODE} in
              PROLOGUE)
		  ;;
              EPILOGUE)
		  ;;
	      CHECKPARAM)
		  hookPackage "${_myPKGBASE_XEN}/config.sh"
		  hookPackage "${_myPKGBASE_XEN}/create.sh"
		  createConnectXEN ${OPMODE} ${ACTION} 
		  ;;
	      ASSEMBLE)
		  hookPackage "${_myPKGBASE_XEN}/config.sh"
		  hookPackage "${_myPKGBASE_XEN}/create.sh"
		  createConnectXEN ${OPMODE} ${ACTION} 
		  ;;
	      EXECUTE)
		  hookPackage "${_myPKGBASE_XEN}/session.sh"
		  hookPackage "${_myPKGBASE_XEN}/list.sh"
		  hookPackage "${_myPKGBASE_XEN}/config.sh"
		  hookPackage "${_myPKGBASE_XEN}/create.sh"
		  createConnectXEN ${OPMODE} ${ACTION} 
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
		  hookPackage "${_myPKGBASE_XEN}/config.sh"
		  hookPackage "${_myPKGBASE_XEN}/cancel.sh"
		  cutCancelSessionXEN ${OPMODE} ${ACTION} 
		  ;;
	      ASSEMBLE)
		  hookPackage "${_myPKGBASE_XEN}/config.sh"
		  hookPackage "${_myPKGBASE_XEN}/cancel.sh"
		  cutCancelSessionXEN ${OPMODE} ${ACTION} 
		  ;;
	      EXECUTE)
		  hookPackage "${_myPKGBASE_XEN}/session.sh"
		  hookPackage "${_myPKGBASE_XEN}/list.sh"
		  cutCancelSessionXEN ${OPMODE} ${ACTION} 
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
                      printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "C_MODE_ARGS=$C_MODE_ARGS"
                      _C_GETCLIENTPORT=$C_MODE_ARGS
		  else
		      ABORT=1
		      printERR $LINENO $BASH_SOURCE ${ABORT} "Missing <session-label>|<session-id>"
		      gotoHell ${ABORT}
		  fi
                  ;;

	      EXECUTE)
		  hookPackage "${_myPKGBASE_XEN}/config.sh"
		  hookPackage "${_myPKGBASE_XEN}/session.sh"
		  hookPackage "${_myPKGBASE_XEN}/list.sh"
		  printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "Remote command:OPTARG=${OPTARG}"
  		  echo "CLIENTPORT(XEN,${MYHOST},${_C_GETCLIENTPORT})=`getClientTPXEN ${_C_GETCLIENTPORT//,/ }`"
		  gotoHell 0
		  ;;

 	      ASSEMBLE)
		  assembleExeccall ${OPMODE}
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
                      printDBG $S_XEN ${D_UID} $LINENO $BASH_SOURCE "C_MODE_ARGS=$C_MODE_ARGS"
                      _MYID=$C_MODE_ARGS
		  else
		      ABORT=1
		      printERR $LINENO $BASH_SOURCE ${ABORT} "Missing <session-id>"
		      gotoHell ${ABORT}
		  fi
                  ;;

	      EXECUTE)
		  printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "Remote command:OPTARG=${OPTARG}"
 		  echo "ISACTIVE(XEN,${C_MODE_ARGS})=`isActiveXEN ${C_MODE_ARGS}`"
		  gotoHell 0
		  ;;

 	      ASSEMBLE)
 		  ;;
          esac
	  ;;

      *)
          ABORT=1;
          printERR $LINENO $BASH_SOURCE ${ABORT} "System Error, unexpected XEN:OPMODE=${OPMODE} ACTION=${ACTION}"
	  gotoHell ${ABORT}
          ;;
  esac
}


#FUNCBEG###############################################################
#NAME:
#  xenCancelDom0
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  The Dom0 will pe cleared from specific state history of hypervisor.
#  The main application is for now as a work-around for setting WoL in
#  case of Xen-3.0.2, where ethtool "wol g" is erroneous, even though
#  broadcasts are detected well ("wol umbg").
#
#
#EXAMPLE:
#
#GLOBALS:
#  CTYS_ETHTOOL_WOLIF
#    Uses this variable to decide whether and if so, gwhich bridge
#    has to be stopped.
#    This is required at least for Xen-3.0.2 because pethX ignores
#    teh "wol g", but handles "wol umbg", thus seems to be a bug.
#
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
function xenCancelDom0 () {
    local _ret=1;
    printDBG $S_XEN ${D_DATA} $LINENO $BASH_SOURCE "$FUNCNAME:XEN_STATE=${XEN_STATE}"
    local _bridges=;

    XEN_BRIDGE_SCRIPT="${XBCALL} ${XEN_BRIDGE_SCRIPT}"


    #Yes, missing su-check method. 
    #Don't forget, has to find a bridge with user-land and check for root-permission.
    #OR probably a pre configured specific user with sudo+chown of resources, who knows???!!!
    #BUT, expecting for now, access to all or none!
    #This is particularly ugly, when having mutliple bridges,
    #configured for access differently, and e.g. one is the debugging-peer, whereas the
    #WoL interface is located on another!
    [ -z "$CTYS_BRCTL" ]&&CTYS_BRCTL=`getPathName $LINENO $BASH_SOURCE WARNING brctl /usr/sbin`
    [ -z "$CTYS_BRCTL" ]&&CTYS_BRCTL=`getPathName $LINENO $BASH_SOURCE WARNING brctl /sbin`
    _bridges=`netListBridges`
    _ret=0;
    local i=;
    for i in $_bridges;do
        #will be stopped anyhow!!!
	checkedSetSUaccess  "${MYCONFPATH}/xen/xen.conf-${MYOS}.sh" XBCALL    CTYS_BRCTL  stp $i on
	let _ret+=$?;
    done
    if [ $_ret -ne 0 ];then
	ABORT=1;
	printERR $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:Missing permission:CTYS_BRCTL=\"${CTYS_BRCTL}\""
        return $ABORT
#        gotoHell $ABORT
    fi
    CTYS_BRCTL="${XBCALL} ${CTYS_BRCTL}"


    #other interfaces are not of interest, and might be even required for debugging purposes.
    if [ -n "${CTYS_ETHTOOL_WOLIF}" ];then
	printDBG $S_XEN ${D_DATA} $LINENO $BASH_SOURCE "$FUNCNAME:CTYS_ETHTOOL_WOLIF=${CTYS_ETHTOOL_WOLIF}"

        #standard of Xen for remnaming schema of physical IF
	_bridges=`netListBridges p${CTYS_ETHTOOL_WOLIF}`
	_ret=$?
	if [ $_ret -eq 0 -a -z "${_bridges}" ];then
            #non-standard, literal IF name as member of a bridge, thus a provided
            #patch for bonding will work too.
	    _bridges=`netListBridges ${CTYS_ETHTOOL_WOLIF}`
	    _ret=$?
	fi
    fi


    if [ $_ret -eq 0 ];then

	printWNG 2 $LINENO $BASH_SOURCE 0  "${CTYS_ETHTOOL_WOLIF} is member of a bridge, assume of Xen, thus stop it."
	printWNG 2 $LINENO $BASH_SOURCE 0  "   _bridges=${_bridges}"

        #yes, should be only one!
	for i in $_bridges;do
	    logger -i -s -t ${MYCALLNAME} -- "`basename $BASH_SOURCE`:$LINENO:stop:bridge=${i} netdev=${CTYS_ETHTOOL_WOLIF}"
	    wall "Network disconnect:bridge=${i} netdev=${CTYS_ETHTOOL_WOLIF}"
            if [ "${XEN_BRIDGE_SCRIPT//ctys-xen-}" == "${XEN_BRIDGE_SCRIPT}" ];then
		callErrOutWrapper $LINENO $BASH_SOURCE ${XEN_BRIDGE_SCRIPT} stop bridge=$i netdev=${CTYS_ETHTOOL_WOLIF} ${C_DARGS}
		_ret=$?
	    else
		${XEN_BRIDGE_SCRIPT} stop bridge=$i netdev=${CTYS_ETHTOOL_WOLIF} ${C_DARGS}
		_ret=$?
	    fi
	    if [ $_ret -ne 0 ];then
		ABORT=1;
		printERR $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:Cancel Dom0 failed:\"${XEN_BRIDGE_SCRIPT} stop bridge=$i netdev=eth${_int}\"=>$_ret"
	    fi
	done
    else
	printWNG 2 $LINENO $BASH_SOURCE 0  "No \"bridged\" interface found, \"brctl stop\" not required."
    fi
    
}

#FUNCBEG###############################################################
#NAME:
#  initXEN
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
function initXEN () {
  local _curInit=$1;shift
  local _initConsequences=$1
  local ret=0;

  local _raise=$((INITSTATE<_curInit));

  printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:${INITSTATE} -> ${_curInit} - ${_raise}"

  if [ "$_raise" == "1" ];then
      #for raise of INITSTATE do not touch the OS's decisions, just expand.
      case $_curInit in
	  0);;#NOP - Done by shell
	  1)
              #adjust version specifics  
              setVersionXEN $_initConsequences
              ret=$?

              #add own help to searchlist for options
	      MYOPTSFILES="${MYOPTSFILES} ${MYHELPPATH}/010_xen"
	      ;;
	  2);;
	  3);;
	  4);;
	  5);;
	  6);;
      esac
  else
      #When reducing INITSTATE assume analogy to OS, thus shutdown network.
      #but prepare DomU-s before processing Dom0.
      #Anyhow, this is an post-fix add-on to the stack-propagation of VMs, thus
      #each of them might be prepared, so this only handles the SELF-case when 
      #requested.
      case $_curInit in
	  0)xenCancelDom0;;
	  1);;
	  2);;
	  3);;
	  4);;
	  5);;
	  6)xenCancelDom0;;
      esac
  fi
  return $ret
}