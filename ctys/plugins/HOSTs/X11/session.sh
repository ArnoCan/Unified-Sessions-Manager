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

_myPKGNAME_X11_SESSION="${BASH_SOURCE}"
_myPKGVERS_X11_SESSION="01.10.013"
hookInfoAdd $_myPKGNAME_X11_SESSION $_myPKGVERS_X11_SESSION
_myPKGBASE_X11_SESSION="`dirname ${_myPKGNAME_X11_SESSION}`"


#FUNCBEG###############################################################
#NAME:
#  startSessionX11
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1:  <label>
#  $2:  <cmd>
#  $3:  <shell>
#  $4:  <callopts>
#  $5:  <xopts>
#  $6:  <chdir>
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function startSessionX11 () {
    printDBG $S_X11 ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=<$@>"
    printDBG $S_X11 ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_label     =\$1=<$1>"
    printDBG $S_X11 ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_xclient   =\$2=<$2>"
    printDBG $S_X11 ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_xclientsh =\$3=<$3>"
    printDBG $S_X11 ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_copts     =\$4=<$4>"
    printDBG $S_X11 ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_xopts     =\$5=<$5>"
    printDBG $S_X11 ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_titlekey  =\$6=<$6>"
    printDBG $S_X11 ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_chdir     =\$7=<$7>"
    local _label=${1:-DEFAULT-$DATETIME};
    local _xclient=${2};
    local _xclientsh=${3## };
    local _copts=${4};
    local _xopts=${5};
    local _titlekey=${6};
    local _chdir=${7};

    local _xcall=;

    #should not occur
    if [ -z "${_xclient// /}" ];then
	_xclient=${X11_XTERM_DEFAULT}

        #might be empty for a native program
	if [ -z "${_xclientsh// /}" ];then
	    _xclientsh=${X11_XTERM_SHELL_DEFAULT} 
	fi
    fi

    checkUniqueness4Label ${_label};
    if [ $? -eq 0 ];then
	local _unique=1
    else
	if [ -z "${C_ALLOWAMBIGIOUS}" ];then
	    ABORT=2
	    printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Ambigious <session-label>:${_label}"
	    printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Use \"CONNECT\" when attaching a session of type HOSTS"
	    printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:as client only."
	    gotoHell ${ABORT}
	else 
	    printWNG 1 $LINENO $BASH_SOURCE ${RET} "${FUNCNAME}:Label is ambigious:${_label}"
	fi
    fi

    #xopts
    if [ -z "${_xopts// /}" ];then
	case ${_xclient// /} in
	    XTERM)_xopts="${X11_DEFAULT_OPTS} ${X11_DEFAULT_OPTS_XTERM}";;
	    GTERM)_xopts="${X11_DEFAULT_OPTS} ${X11_DEFAULT_OPTS_GTERM}";;
	    *)	_xopts="${X11_DEFAULT_OPTS}";;
	esac
    fi

    _xopts="${_xopts} ${C_GEOMETRY:+ ${_xp}geometry $C_GEOMETRY} "

    printDBG $S_X11 ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_xclient=\"${_xclient}\""
    printDBG $S_X11 ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_xclientsh=\"${_xclientsh}\""
    printDBG $S_X11 ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_xopts=\"${_xopts}\""

    if [ "$_label" != NOTITLE ];then
	if [ "${_xp}" == "-"  ];then
	    _xopts="${_xopts} ${_xp}${_titlekey:-title} CTYS-X11-${CALLERJOBID}-${_label} "
	else
	    _xopts="${_xopts} ${_xp}${_titlekey:-title}=CTYS-X11-${CALLERJOBID}-${_label} "
	fi
    fi

    case $_xclient in
	EMACS|EMACSA|EMACSM|EMACSAM)
            local _bn="$_label"
	    local _cmd="${X11EMACXEXE}";
	    local _emacscall=;

	    if [ -z "${_xclientsh}" ];then
		local _emacsrun="exec ${CLIEXE} -i ${_copts:+\"$_copts\"}"
	    else
		local _emacsrun="exec ${CLIEXE} -c \"${_xclientsh} ${_copts}\""
	    fi

	    local _emacsrunfile=${MYTMP}/emacs.${MYPID}.${RANDOM}
	    _xclientsh=${_xclientsh:-$X11_XTERM_SHELL_DEFAULT} 

	    printDBG $S_X11 ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_emacsrun=\"${_emacsrun}\""
	    printDBG $S_X11 ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_emacsrunfile=\"${_emacsrunfile}\""

	    echo "$_emacsrun" >${_emacsrunfile}
	    chmod 755 ${_emacsrunfile}

            #ffs. but will be done!
            #requires ansi-color
#	    _emacscall="${_emacscall} -eval \"(ansi-color-for-comint-mode-on)\""
#	    _emacscall="${_emacscall} -eval \"(require 'ansi-color) (ansi-color-for-comint-mode-on)\""

	    case  ${_xclient} in
		EMACS)
		    case "${X11EMACSVERS}" in
			21.*|20.*|1[0-9].*)#safety for marketing
			    ABORT=2
			    printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Requires Emacs of version 22.x or higher."
			    gotoHell ${ABORT}
			    ;;
			22.*)#verified
			    _emacscall="${_emacscall} -eval \"(make-comint \\\"${_bn}\\\" \\\"${_emacsrunfile}\\\")\""
			    _emacscall="${_emacscall} -eval \"(switch-to-buffer \\\"\*${_bn}\*\\\")\""
			    ;;
			*)#verified
			    _emacscall="${_emacscall} -eval \"(make-comint \\\"${_bn}\\\" \\\"${_emacsrunfile}\\\")\""
			    _emacscall="${_emacscall} -eval \"(switch-to-buffer \\\"\*${_bn}\*\\\")\""
			    ;;
# 			21.*)#verified - but for some erroneous partly
# 			    _emacscall="${_emacscall} -eval \"(make-comint \\\"${_bn}\\\" \\\"${_emacsrunfile}\\\")\""
# 			    ;;
# 			*)#optimism
# 			    _emacscall="${_emacscall} -eval \"(make-comint \\\"${_bn}\\\" \\\"${_emacsrunfile}\\\")\""
# 			    ;;
		    esac
		    ;;
		EMACSM)
		    case "${X11EMACSVERS}" in
			21.*|20.*|1[0-9].*)#safety for marketing
			    ABORT=2
			    printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Requires Emacs of version 22.x or higher."
			    gotoHell ${ABORT}
			    ;;
			22.*)#verified
			    _emacscall="${_emacscall} -eval \"(make-comint \\\"${_bn}\\\" \\\"${_emacsrunfile}\\\")\""
			    _emacscall="${_emacscall} -eval \"(switch-to-buffer \\\"\*${_bn}\*\\\")\""
			    _emacscall="${_emacscall} -eval \"(split-window-vertically)\""
			    _emacscall="${_emacscall} -eval \"(switch-to-buffer-other-window \\\"\*${MYHOST}\*\\\" )\""

			    _emacscall="${_emacscall} -eval \"(make-comint \\\"${MYHOST}\\\" \\\"${CLIEXE}\\\")\""
			    ;;
			*)#verified
			    _emacscall="${_emacscall} -eval \"(make-comint \\\"${_bn}\\\" \\\"${_emacsrunfile}\\\")\""
			    _emacscall="${_emacscall} -eval \"(switch-to-buffer \\\"\*${_bn}\*\\\")\""
			    _emacscall="${_emacscall} -eval \"(split-window-vertically)\""
			    _emacscall="${_emacscall} -eval \"(switch-to-buffer-other-window \\\"\*${MYHOST}\*\\\" )\""
			    _emacscall="${_emacscall} -eval \"(make-comint \\\"${MYHOST}\\\" \\\"${CLIEXE}\\\")\""
			    ;;
# 			21.*)#optimism
# 			    _emacscall="${_emacscall} -eval \"(make-comint \\\"${_bn}\\\" \\\"${_emacsrunfile}\\\")\""
# 			    _emacscall="${_emacscall} -eval \"(switch-to-buffer \\\"\*${_bn}\*\\\")\""
# 			    _emacscall="${_emacscall} -eval \"(split-window-vertically)\""
# 			    _emacscall="${_emacscall} -eval \"(switch-to-buffer-other-window \\\"\*${MYHOST}\*\\\" )\""
# 			    _emacscall="${_emacscall} -eval \"(make-comint \\\"${MYHOST}\\\" \\\"${_xclientsh}\\\")\""
# 			    ;;
# 			*)#optimism
# 			    _emacscall="${_emacscall} -eval \"(make-comint \\\"${_bn}\\\" \\\"${_emacsrunfile}\\\")\""
# 			    _emacscall="${_emacscall} -eval \"(switch-to-buffer \\\"\*${_bn}\*\\\")\""
# 			    _emacscall="${_emacscall} -eval \"(split-window-vertically)\""
# 			    _emacscall="${_emacscall} -eval \"(switch-to-buffer-other-window \\\"\*${MYHOST}\*\\\" )\""
# 			    _emacscall="${_emacscall} -eval \"(make-comint \\\"${MYHOST}\\\" \\\"${_xclientsh}\\\")\""
# 			    ;;
		    esac
		    ;;

		EMACSA)
		    case "${X11EMACSVERS}" in
			21.*|20.*|1[0-9].*)#safety for marketing
			    ABORT=2
			    printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Requires Emacs of version 22.x or higher."
			    gotoHell ${ABORT}
			    ;;
			22.*)#verified
			    _emacscall="${_emacscall} -eval \"(ansi-term \\\"${_emacsrunfile}\\\" \\\"${_label}\\\" )\""
			    ;;
			*)#verified
			    _emacscall="${_emacscall} -eval \"(ansi-term \\\"${_emacsrunfile}\\\" \\\"${_label}\\\" )\""
			    ;;
# 			21.*)#verified
# 			    _emacscall="${_emacscall} -eval \"(ansi-term \\\"${_emacsrunfile}\\\" \\\"${_label}\\\" )\""
# 			    ;;
# 			*)#optimism
# 			    _emacscall="${_emacscall} -eval \"(ansi-term \\\"${_emacsrunfile}\\\" \\\"${_label}\\\" )\""
# 			    ;;
		    esac
		    ;;
		EMACSAM)
		    #some ansi-gaps in upper win.
		    case "${X11EMACSVERS}" in
			21.*|20.*|1[0-9].*)#safety for marketing
			    ABORT=2
			    printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Requires Emacs of version 22.x or higher."
			    gotoHell ${ABORT}
			    ;;
			22.*)#verified-some ansi-gaps in upper win.
			    _emacscall="${_emacscall} -eval \"(ansi-term \\\"${_emacsrunfile}\\\" \\\"${_label}\\\" )\""
			    _emacscall="${_emacscall} -eval \"(split-window-vertically)\""
			    _emacscall="${_emacscall} -eval \"(switch-to-buffer-other-window \\\"\*${MYHOST}\*\\\" )\""
			    _emacscall="${_emacscall} -eval \"(ansi-term \\\"${CLIEXE}\\\" \\\"${MYHOST}\\\" )\""
			    ;;
			*)#verified-some ansi-gaps in upper win.
			    _emacscall="${_emacscall} -eval \"(ansi-term \\\"${_emacsrunfile}\\\" \\\"${_label}\\\" )\""
			    _emacscall="${_emacscall} -eval \"(split-window-vertically)\""
			    _emacscall="${_emacscall} -eval \"(switch-to-buffer-other-window \\\"\*${MYHOST}\*\\\" )\""
			    _emacscall="${_emacscall} -eval \"(ansi-term \\\"${CLIEXE}\\\" \\\"${MYHOST}\\\" )\""
			    ;;
# 			21.*)#optimism-some ansi-gaps in upper win.
# 			    _emacscall="${_emacscall} -eval \"(ansi-term \\\"${_emacsrunfile}\\\" \\\"${_label}\\\" )\""
# 			    _emacscall="${_emacscall} -eval \"(split-window-vertically)\""
# 			    _emacscall="${_emacscall} -eval \"(switch-to-buffer-other-window \\\"\*${MYHOST}\*\\\" )\""
# 			    _emacscall="${_emacscall} -eval \"(ansi-term \\\"${_xclientsh}\\\" \\\"${MYHOST}\\\" )\""
# 			    ;;
# 			*)#optimism-some ansi-gaps in upper win.
# 			    _emacscall="${_emacscall} -eval \"(ansi-term \\\"${_emacsrunfile}\\\" \\\"${_label}\\\" )\""
# 			    _emacscall="${_emacscall} -eval \"(split-window-vertically)\""
# 			    _emacscall="${_emacscall} -eval \"(switch-to-buffer-other-window \\\"\*${MYHOST}\*\\\" )\""
# 			    _emacscall="${_emacscall} -eval \"(ansi-term \\\"${_xclientsh}\\\" \\\"${MYHOST}\\\" )\""
# 			    ;;
		    esac
		    ;;
		*)
		    ABORT=1;
		    printERR $LINENO $BASH_SOURCE ${ABORT} "Unsupported: ${KEY}=${ARG}"
 		    gotoHell ${ABORT}
		    ;;
	    esac
	    _xcall="${_chdir:+cd $_chdir&&}${_cmd}  ${_xopts}  ${_emacscall}"
	    case ${MYOS} in
		Linux)
		    printDBG $S_X11 ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:CTYS_UNLINKDELAY=\"${CTYS_UNLINKDELAY}\""
		    { sleep ${CTYS_UNLINKDELAY}&&${CTYS_UNLINK} ${_emacsrunfile}; }&
		    ;;
		FreeBSD|OpenBSD)
		    _xcall="${_xcall};rm ${_emacsrunfile}"
		    ;;
		SunOS)
		    _xcall="${_xcall};rm ${_emacsrunfile}"
		    ;;
	    esac
	    ;;
	*)
	    case ${_xclient// /} in
		XTERM)local _cmd="${X11XTERMEXE}"
		    if [ -n "${_xclientsh// /}" -o -n "${_copts// /}" ];then
			_xcall="${_chdir:+cd $_chdir&&}${_cmd}  ${_xopts} -e ${_xclientsh} ${_copts}"
		    else
			_xcall="${_cmd}  ${_xopts}"
		    fi
		    ;;
		GTERM)local _cmd="${X11GTERMEXE}"
		    if [ -n "${_xclientsh// /}" -o -n "${_copts// /}" ];then
			_xcall="${_chdir:+cd $_chdir&&}${_cmd}  ${_xopts} -e \"${_xclientsh} ${_copts}\""
		    else
			_xcall="${_cmd}  ${_xopts}"
		    fi
		    ;;
		*)local _cmd="${_xclient}"
		    if [ -n "${_xclientsh// /}" -o -n "${_copts// /}" ];then
			_xcall="${_chdir:+cd $_chdir&&}${_cmd}  ${_xopts} -e \"${_xclientsh} ${_copts}\""
		    else
			_xcall="${_cmd}  ${_xopts}"
		    fi
		    ;;
	    esac

	    ;;
    esac

    #
    #gnome-terminal is ASYNC in any case!
    if [ "$C_ASYNC" == 1 ];then
	_xcall="${_xcall} &"
    fi

    printDBG $S_X11 ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_xcall =\"${_xcall}\""
    printDBG $S_X11 ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:C_STACK=\"${C_STACK}\""
    printFINALCALL $LINENO $BASH_SOURCE "FINAL-X11-CCONSOLE:STARTER(${_label})" "${_xcall}"
    case ${C_DISPLAY// /} in
	*[a-z][A-Z]*)
	    export DISPLAY=":$(C_SESSIONTYPE=ALL fetchDisplay4Label ALL ${C_DISPLAY})";
	    ;;
	'')
            ;;
	*)
	    export DISPLAY=":${C_DISPLAY}";
	    ;;
    esac

    if [ -z "${C_NOEXEC}" ];then
	eval ${_xcall}
    fi
}
