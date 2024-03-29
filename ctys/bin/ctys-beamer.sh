#!/bin/bash
########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@users.sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_011
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


#FUNCEG###############################################################
#
#PROJECT:
MYPROJECT="Unified Sessions Manager"
#
#NAME:
#  ctys-beamer.sh
#
#AUTHOR:
AUTHOR="Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org"
#
#FULLNAME:
FULLNAME="Unified Sessions Manager - remote execution"
#
#CALLFULLNAME:
CALLFULLNAME="ctys-beamer.sh"
#
#LICENCE:
LICENCE=GPL3
#
#TYPE:
#  sh-script
#
#VERSION:
VERSION=01_11_011
#DESCRIPTION:
#  Remote execution script.
#
#  For further information refer to help and manual.
#
#
#EXAMPLE:
#
#PARAMETERS:
#
#
#  refer to online help "-h" and/or "-H"
#
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################


#list of access points for established tunnel entries
declare -a AP;
APIDX=0;

################################################################
#       System definitions - do not change these!              #
################################################################
#Execution anchor
MYCALLPATHNAME=$0
MYCALLNAME=`basename $MYCALLPATHNAME`
MYCALLNAME=${MYCALLNAME%.sh}
MYCALLPATH=`dirname $MYCALLPATHNAME`

#
#
#acue: 20090709:Temporary workaround
#
#If a specific library is forced by the user
#
#if [ -n "${CTYS_LIBPATH}" ];then
#    MYLIBPATH=$CTYS_LIBPATH
#    MYLIBEXECPATHNAME=${CTYS_LIBPATH}/bin/$MYCALLNAME
#else
    MYLIBEXECPATHNAME=$MYCALLPATHNAME
#fi

#
#identify the actual location of the callee
#
if [ -n "${MYLIBEXECPATHNAME##/*}" ];then
	MYLIBEXECPATHNAME=${PWD}/${MYLIBEXECPATHNAME}
fi
MYLIBEXECPATH=`dirname $MYLIBEXECPATHNAME`

###################################################
#load basic library required for bootstrap        #
###################################################
MYBOOTSTRAP=${MYLIBEXECPATH}/bootstrap
if [ ! -d "${MYBOOTSTRAP}" ];then
    MYBOOTSTRAP=${MYCALLPATH}/bootstrap
    if [ ! -d "${MYBOOTSTRAP}" ];then
	echo "${MYCALLNAME}:$LINENO:ERROR:Missing:MYBOOTSTRAP=${MYBOOTSTRAP}"
	cat <<EOF  


DESCRIPTION:
  This directory contains the common mandatory bootstrap functions.
  Your installation my be erroneous.  

SOLUTION-PROPOSAL:
  First of all check your installation, because an error at this level
  might - for no reason - bypass the final tests.

  If this does not help please send a bug-report.

EOF
	exit 1
    fi
fi

MYBOOTSTRAP=${MYBOOTSTRAP}/bootstrap.01.01.005.sh
if [ ! -f "${MYBOOTSTRAP}" ];then
  echo "${MYCALLNAME}:$LINENO:ERROR:Missing:MYBOOTSTRAP=${MYBOOTSTRAP}"
cat <<EOF  

DESCIPTION:
  This file contains the common mandatory bootstrap functions required
  for start-up of any shell-script within this package.

  It seems though your installation is erroneous or you detected a bug.  

SOLUTION-PROPOSAL:
  First of all check your installation, because an error at this level
  might - for no reason - bypass the final tests.

  When your installation seems to be OK, you may try to set a TEMPORARY
  symbolic link to one of the files named as "bootstrap.<highest-version>".
  
    ln -s ${MYBOOTSTRAP} bootstrap.<highest-version>

  in order to continue for now. 

  Be aware, that any installation containing the required file will replace
  the symbolic link, because as convention the common boostrap files are
  never symbolic links, thus only recognized as a temporary workaround to 
  be corrected soon.

  If this does not work you could try one of the other versions.

  Please send a bug-report.

EOF
  exit 1
fi

###################################################
#Start bootstrap now                              #
###################################################
. ${MYBOOTSTRAP}
###################################################
#OK - utilities to find components of this version#
#available now.                                   #
###################################################

#
#set real path to install, resolv symbolic links
_MYLIBEXECPATHNAME=`bootstrapGetRealPathname ${MYLIBEXECPATHNAME}`
MYLIBEXECPATH=`dirname ${_MYLIBEXECPATHNAME}`

_MYCALLPATHNAME=`bootstrapGetRealPathname ${MYCALLPATHNAME}`
MYCALLPATHNAME=`dirname ${_MYCALLPATHNAME}`

#
###################################################
#Now find libraries might perform reliable.       #
###################################################

#current language, not really NLS
MYLANG=${MYLANG:-en}

#path for various loads: libs, help, macros, plugins
#MYLIBPATH=${CTYS_LIBPATH:-`dirname $MYLIBEXECPATH`}
MYLIBPATH=$(dirname $MYLIBEXECPATH)

#path for various loads: libs, help, macros, plugins
MYHELPPATH=${MYHELPPATH:-$MYLIBPATH/help/$MYLANG}


###################################################
#Check master hook                                #
###################################################
bootstrapCheckInitialPath
###################################################
#OK - Now should work.                            #
###################################################

MYCONFPATH=${MYCONFPATH:-$MYLIBPATH/conf/ctys}
if [ ! -d "${MYCONFPATH}" ];then
  echo "${MYCALLNAME}:$LINENO:ERROR:Missing:MYCONFPATH=${MYCONFPATH}"
  exit 1
fi

if [ -f "${MYCONFPATH}/versinfo.conf.sh" ];then
    . ${MYCONFPATH}/versinfo.conf.sh
fi

MYMACROPATH=${MYMACROPATH:-$MYCONFPATH/macros}
if [ ! -d "${MYMACROPATH}" ];then
  echo "${MYCALLNAME}:$LINENO:ERROR:Missing:MYMACROPATH=${MYMACROPATH}"
  exit 1
fi

MYPKGPATH=${MYPKGPATH:-$MYLIBPATH/plugins}
if [ ! -d "${MYPKGPATH}" ];then
  echo "${MYCALLNAME}:$LINENO:ERROR:Missing:MYPKGPATH=${MYPKGPATH}"
  exit 1
fi

MYINSTALLPATH= #Value is assigned in base. Symbolic links are replaced by target


##############################################
#load basic library required for bootstrap   #
##############################################
. ${MYLIBPATH}/lib/base.sh
. ${MYLIBPATH}/lib/libManager.sh
#
#Germish: "Was the egg or the chicken first?"
#
#..and prevent real load order for later display.
#
bootstrapRegisterLib
baseRegisterLib
libManagerRegisterLib
##############################################
#Now the environment is armed, so let's go.  #
##############################################


#######
#deact in base.sh
# MYOS=`dirname $0`
# MYOS=`${MYOS}/getCurOS.sh`

if [ -z "$BASH" ];then
    echo "*********************************************************************"
    echo "* The UnifiedSessionsManager scripts require the \"bash\".            *"
    echo "* For the installation of this version a user driven setting of the *"
    echo "* \"bash\" shell is required.                                         *"
    echo "*                                                                   *"
    echo "* Call: 1. bash                                                     *"
    echo "*       2. <path>/ctys-install.sh <args>                               *"
    echo "*                                                                   *"
    echo "*********************************************************************"
    exit 1
fi

if [ "$HOME" == "/" ];then
    echo "The UnifiedSessionsManager requires a HOME directory differen from top=\"/\"."
    echo "If you are root, you may create \"/root\" and set this as your home."
    exit 1
fi

#CTYS_LIBPATH_INSTALL=$(dirname $0)
CTYS_LIBPATH_INSTALL=${MYLIBEXECPATH}
if [ "$CTYS_LIBPATH_INSTALL" == "." ];then
    CTYS_LIBPATH_INSTALL=$(dirname $PWD)
else
    CTYS_LIBPATH_INSTALL=$(dirname $CTYS_LIBPATH_INSTALL)
fi
export CTYS_LIBPATH_INSTALL
MYLIBPATH=$CTYS_LIBPATH_INSTALL


case ${MYOS} in
    SunOS)
	export PATH=/usr/xpg4/bin:/opt/sfw/bin:/usr/sbin:/usr/bin:/usr/openwin/bin:$PATH
	;;
esac

function gwhich () {
    case ${MYOS} in
	SunOS)
	    local _xf=`which $*`;
	    case $_xf in
		no*)
		    return 1;
		    ;;
	    esac
	    echo -n -e $_xf
	    ;;
	*)which $*
	    ;;
    esac
}

#Source pre-set environment from user
if [ -f "${HOME}/.ctys/ctys.conf.sh" ];then
  . "${HOME}/.ctys/ctys.conf.sh"
fi

#Source pre-set environment from installation 
if [ -f "${MYCONFPATH}/ctys.conf.sh" ];then
  . "${MYCONFPATH}/ctys.conf.sh"
fi

#system tools
if [ -f "${HOME}/.ctys/systools.conf-${MYDIST}.sh" ];then
    . "${HOME}/.ctys/systools.conf-${MYDIST}.sh"
else

    if [ -f "${MYCONFPATH}/systools.conf-${MYDIST}.sh" ];then
	. "${MYCONFPATH}/systools.conf-${MYDIST}.sh"
    else
	if [ -f "${MYLIBEXECPATH}/../conf/ctys/systools.conf-${MYDIST}.sh" ];then
	    . "${MYLIBEXECPATH}/../conf/ctys/systools.conf-${MYDIST}.sh"
	else
	    ABORT=1;
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing system tools configuration file:\"systools.conf-${MYDIST}.sh\""
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Check your installation."
	    gotoHell ${ABORT}
	fi
    fi
fi


. ${MYLIBPATH}/lib/help/help.sh
. ${MYLIBPATH}/lib/misc.sh
. ${MYLIBPATH}/lib/network/network.sh
. ${MYLIBPATH}/lib/groups.sh


function maskit0 () {
    local _x="${*}"
    _x=${_x//\{/\\\{}
    _x=${_x//\}/\\\}}
    _x=${_x//\;/\\\;}
    _x=${_x//\&/\\\&}

    _x=${_x//\'/\\\'}
    _x=${_x//\"/\\\"}

    echo -n $_x
}


function maskit1 () {
    local _x="${*}"
    _x=${_x//\\/\\\\}
    _x=${_x//\%/\%\%}
    _x=${_x//,/,,}
    _x=${_x//:/::}
    _x=${_x//  / }
    _x=${_x//  / }
    _x=${_x// /\%}

    echo -n $_x
}


#FUNCBEG###############################################################
#NAME:
#  beamMeUp0
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  This function performs the actual transfer of one call.
#
#
#PARAMETERS:
#
#
#  $1: <remote-site>
#
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function beamMeUp0 () {
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:\$*=<$*>"
    local _rh=$*;
    _rh=$(fetchGroupMemberHosts ${_rh})

    if [ -n "${_RUSER0}" ];then
	_RARGS=${_RARGS//$_RUSER0/}
	_RARGS=${_RARGS//\-L/}
    fi
    _RARGS=$(echo ${_RARGS}|sed 's/^  *//;s/  *$//')

    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_RARGS=<$_RARGS>"
    _MYLBL=${MYCALLNAME}-${MYUID}-${DATETIME}

    if [ "$C_TERSE" != 1 ];then
 	printINFO 1 $LINENO $BASH_SOURCE 1 "Use either '-X' or '-d i:0' to suppress these startup $(setFontAttrib FGREEN INFO) messages"
 	printINFO 1 $LINENO $BASH_SOURCE 1 "."
	printINFO 1 $LINENO $BASH_SOURCE 1 "Remote execution by  $(setFontAttrib BOLD SSH-CHAIN) on:${_rh}"
 	printINFO 1 $LINENO $BASH_SOURCE 1 "."
    fi


    local _TRANSFORM="$(maskit0 ${_ARGS})";
    _TRANSFORM="${_TRANSFORM//\\\&\\\&/_AND_}";
    _TRANSFORM="$(maskit1 ${_RARGS} ${_TRANSFORM})";
    _TRANSFORM="$(maskit0 ${_TRANSFORM})";


    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_TRANSFORM=<$_TRANSFORM>"

    _call="ctys ${C_DARGS} -t cli "
    if [ -n "$_SET_B" ];then
	_call="${_call}  -b $_SET_B "
	if [ "$C_TERSE" != 1 ];then
	    printINFO 1 $LINENO $BASH_SOURCE 1 "Current background mode is $(setFontAttrib BOLD \"-b ${_SET_B}\")"
	fi
    else
	if [ "$C_TERSE" != 1 ];then
	    printINFO 1 $LINENO $BASH_SOURCE 1 "Current background mode is $(setFontAttrib BOLD default)"
	fi
    fi
    if [ "$C_TERSE" != 1 ];then
	printINFO 1 $LINENO $BASH_SOURCE 1 "The $(setFontAttrib BOLD default) background mode $(setFontAttrib BOLD \"-b SYNC,SEQ\") is $(setFontAttrib BOLD SYNCHRONOUS) and $(setFontAttrib BOLD SEQUENTIAL) "
	printINFO 1 $LINENO $BASH_SOURCE 1 "recommended for single CLI dialogue actions."
	printINFO 1 $LINENO $BASH_SOURCE 1 "Use generic option $(setFontAttrib BOLD '-b ASYNC,PAR')  for $(setFontAttrib BOLD 'remote desktops'), $(setFontAttrib BOLD servers),"
	printINFO 1 $LINENO $BASH_SOURCE 1 "and $(setFontAttrib BOLD 'parallel actions')."
 	printINFO 1 $LINENO $BASH_SOURCE 1 "."
	printINFO 1 $LINENO $BASH_SOURCE 1 "Display resulting execution call by usage of common debugging option '-d pf'."
 	printINFO 1 $LINENO $BASH_SOURCE 1 "."
    fi


    if [ "$C_TERSE" != 1 ];then
	case $_MODE in
	    CTYS-HOPS|CH|0)
		printINFO 1 $LINENO $BASH_SOURCE 1 "Local Hold-Timeout for CTYS-HOPS connection is:${CTYS_PREDETACH_TIMEOUT:-10}"
 		printINFO 1 $LINENO $BASH_SOURCE 1 "."
		;;

	    SSH-CHAIN|SC|1)
		printINFO 1 $LINENO $BASH_SOURCE 1 "Local Hold-Timeout for SSH-CHAIN connection is:${_HOPHOLD:-60}"
 		printINFO 1 $LINENO $BASH_SOURCE 1 "."
		;;
	esac
    fi


    _call="${_call} ${_BYPASSARGS} -a create=l:${_MYLBL},cmd:${MYCALLNAME}${_TRANSFORM:+%$_TRANSFORM}"
    _call="${_call} ${_AGENTFORW:+-Y} ${_RUSER0:+-l $_RUSER0} ${_rh}"
    _call="${_call}${_HOPHOLD:+&&sleep $_HOPHOLD} "
    printFINALCALL 0  $LINENO $BASH_SOURCE "FINAL-REMOTE-CALL:" "${_call}"
    ${_call}
}




#FUNCBEG###############################################################
#NAME:
#  beamMeUp
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  This function transfers the call to a remote site for execution.
#  A set of chained relays is supported.
#
#
#PARAMETERS:
#
#GLOBALS:
#
#
# _RHOSTS0: <relay0-host0[%<relay0-host1>][%<...>][,<relay1-host0>[%<relay1-host1>]...]...
#           <relayX-hostX>=[user@]<host>
#
# _RUSER0   <relay-user>
#
# _ARGSCALL
# _ARGS
# MYCALLNAME
# MYUID
# DATE
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function beamMeUp () {
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:\$*=<$*>"
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_RHOSTS0=<$_RHOSTS0>"

    if [ -n "${_RHOSTS0}" -a "${_RHOSTS0#*@}" != localhost ];then
        local _h=;
	local _RARGS0=$_RARGS
	local _LVL1=;
	for _h in ${_RHOSTS0//,/ };do
	    local _x0=${_h%%\%*}
	    if [ "$_x0" != "${_h}" ];then
		_x1=${_h#*\%}
		_x1=${_x1##\%}
		_x1=${_x1%%\%}

		_RARGS=" -R ${_x1} "${_RARGS0:+$_RARGS0}
	    else
		_RARGS=" -R localhost "${_RARGS0}
	    fi
	    _LVL1=" ${_LVL1} ${_x0} "
	done
	beamMeUp0 ${_LVL1} 
	exit $?
    fi
}




#FUNCBEG###############################################################
#NAME:
#  resolveTunnels
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  This function builds a list of resolved relay chains.
#
#
#PARAMETERS:
#
#GLOBALS:
#
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function resolveTunnels () {
    function strucPrint () {
	if [ xA == A ];then
	    printf "SSH-TUNNEL:%-"$((_loopcnt*4))"s%s\n" " " "$*" >&2
	fi
    }
    local _resolved=$1;shift
    local _nextpath=$*
    local _LVL1=;
    local _multi=;

    local _loopcnt=${_loopcnt:-0};
    if((_loopcnt++>10));then exit 1;fi

    strucPrint ""
    strucPrint "$_loopcnt:>>>>>>>>>>>>>>>><"
    strucPrint "\$*=$*"

    if [ -n "${_nextpath}" -a "${_nextpath#*@}" != localhost ];then
	_hx=${_nextpath};
	strucPrint "$LINENO:_hx=$_hx"
        local i=;
	for i in ${_hx//%/ };do
	    strucPrint ""
	    strucPrint ""
	    strucPrint "$_loopcnt>>>>>>>>>>>>>>>><"
	    strucPrint  "$LINENO:i=$i"
	    _hx=${_hx#$i}
	    _hx=${_hx#\%}
	    strucPrint "$LINENO:_hx=$_hx"

	    _LVL1=$(fetchGroupMemberHosts ${i})
	    _LVL1="${_LVL1## }"
	    _LVL1="${_LVL1%% }"

	    strucPrint "$LINENO:_LVL1=<$_LVL1>"

	    local j=;
	    for j in $_LVL1;do
		if [ "$_LVL1" != "${_LVL1// /}" ];then
		    _multi=1
		    local _hX=$_hx
		else
		    _multi=;
		fi
		_LVL1=${_LVL1#$j}
		_LVL1=${_LVL1## }

		strucPrint "###############################"
		strucPrint "$LINENO:j=$j"
		strucPrint "$LINENO:_LVL1=<${_LVL1}>"

		if [ -n "$_multi" ];then
		    j="${j## }"
		    j="${j%% }"
		    local _o=${j}%${_hX}
		    _o=${_o##%}
		    strucPrint "$LINENO:_o=<$_o>"
		    local _xl=${resolved##*,}
		    strucPrint "$LINENO:_xl=$_xl"

		    strucPrint "--------------------"
		    strucPrint "$LINENO:resolved=$resolved"
		    strucPrint "$LINENO:j=<$j>"

		    resolved=$(resolveTunnels "$resolved"  "${_o}")
		    strucPrint "$LINENO:j=${j}"
		    strucPrint "$LINENO:_LVL1=${_LVL1}"

		    strucPrint "$LINENO:resolved=$resolved"
		    strucPrint "$LINENO:_xl=$_xl"
		    resolved="$resolved,$_xl"
		    strucPrint "$LINENO:resolved=$resolved"
		else
		    resolved="${resolved}${resolved:+%}$j"
		fi
		strucPrint "$LINENO:resolved=$resolved"
	    done
	done
    fi
    strucPrint "$LINENO:resolved=$resolved"
    echo $resolved
}





#FUNCBEG###############################################################
#NAME:
#  setupTunnels
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  This function builds a list of resolved relay chains.
#
#
#PARAMETERS:
#
#GLOBALS:
#
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function setupTunnels () {
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:\$*=<$*>"

    local _tlst=$1;shift
    local _tlstX=;
    local tun=;

    for _h in ${_tlst//,/ };do
	tun="$tun ssh -f ${_X11} ${_TRM:+-t} ${_RUSER0:+-l $_RUSER0} "

	_lport=${_h#*:}
	_lport=${_lport%%\%*}
	if [ -n "${_h%%:*}" -a  "${_h%%\%*}" ==  "${_lport}" ];then
	    _lport=;
	    repeat=;
	    for((r=0;r<100;r++));do
		_lport=$(netGetFirstFreePort);
		for((x=0;x<APIDX;x++));do
		    if [ "${AP[$x]}" == "$_lport" ];then
			repeat=1
		    fi
		done
		[ -z "$repeat" ]&&break;
	    done
	fi
	AP[$((APIDX++))]=${_lport};

	local _hi=;
	local sshaccess=;
	[ "$C_TERSE" != 1 ]&&echo -n "Search free ports "

	local _last=${_h##*%};
	if [ "$_last" != "$_h" ];then 
	    _h="${_h%\%*}%LAST";
	fi

	for _hi in ${_h//%/ };do

	    if [ "$_hi" == LAST ];then _hi=$_last;_last=0;fi

	    _hnam=${_hi%:*}
	    _port=${_hi#*:}
	    [ "$_hnam" == "$_port" ]&&_port=;

	    [ "$C_TERSE" != 1 ]&&echo -n "."
	    sshaccess="${sshaccess} ssh ${_RUSER0:+-l $_RUSER0} ${_AGENTFORW:+-A} $_hnam "
	    if [ -n "$_port" -a "$_port" != "$_hnam" ];then
		_nport=$_port
	    else
		if [ "$_last" != "0" ];then
		    printFINALCALL 1  $LINENO $BASH_SOURCE "FINAL-REMOTE-CALL:" "$sshaccess  $MYCALLNAME --getfreeport"
		    _nport=$($sshaccess  $MYCALLNAME --getfreeport)
		    _port=;
		fi
	    fi

	    if [ "$_last" != "0" ];then
		if [ -n "$_nport" -a "$_hnam${_port:+:$_port}" != "${_h##*\%}" ];then
		    tun="${tun} ${_AGENTFORW:+-A} -L $_lport:localhost:$_nport $_hnam ssh ${_X11} ${_TRM:+-t} ${_RUSER0:+-l $_RUSER0} "
		    _lport=$_nport
		fi
	    else
		break;
	    fi
	done
	[ "$C_TERSE" != 1 ]&&echo
	tun="${tun} ${_AGENTFORW:+-A} -L $_lport:localhost:${_port:-22} $_hnam sleep ${_TUNHOLD:-60};"
    done

    tun=${tun// /_-_}
    for _h in ${tun//;/ };do
	_h=${_h//_-_/ }
	_h=${_h## }
	if [ -z "$_NOXEC" ];then
	    [ "$C_TERSE" != 1 ]&&echo "...establish circuit"
	    printFINALCALL 0  $LINENO $BASH_SOURCE "FINAL-REMOTE-CALL:" "${_h}"
	    eval $_h
	fi
    done
}


INSTTYPE=;
INSTDIR=;
LNKDIR=;
TARGETLST=;
RUSER=;
_doctrans=;

_ARGS=;
_ARGSCALL=$*;
_RUSER0=;
LABEL=;

_BYPASSARGS=;
_AGENTFORW=;

_MODE=0;
argLst=;

_SET_B=;

_X11=;

while [ -n "$1" ];do
    if [ -z "${_ARGS}" ];then
	case $1 in
 	    '--x11'*)_X11=" -X ";;
 	    '--ssh-hop-holdtime='*)_HOPHOLD=${1#*=};;
 	    '--ssh-tunnel-holdtime='*)_TUNHOLD=${1#*=};;
 	    '--ctys-predetach-holdtime='*)CTYS_PREDETACH_TIMEOUT=${1#*=};;
	    '--mode='*)_MODE=${1#*=};;
	    '--getfreeport')netGetFirstFreePort;exit;;
	    '--ignore-err')_IGERR=1;;

	    '--display-only')_NOXEC=1;;

	    '-d')shift;;

	    '-R')shift;_RHOSTS0=$1;;
	    '-L')shift;_RUSER0=$1;;

	    '-H'|'--helpEx'|'-helpEx')shift;_HelpEx="${1:-$MYCALLNAME}";;
	    '-h'|'--help'|'-help')_showToolHelp=1;;
	    '-V')_printVersion=1;;
	    '-X')C_TERSE=1;_BYPASSARGS="${_BYPASSARGS} $1";;
            '--%--')_ARGS=" ";;
            '--'|'--beam-this')_ARGS=" ";;
	    '-'*)
		_BYPASSARGS="${_BYPASSARGS} $1";
		case $1 in
 		    '-b')shift;_BYPASSARGS="${_BYPASSARGS} $1";_SET_B=$(echo "$1"|tr 'a-z' 'A-Z');;

 		    '-a'|'-A'|'-b'|'-d'|'-D'|'-c'|'-C'|'-F'|'-g'|'-j')shift;_BYPASSARGS="${_BYPASSARGS} $1";;
		    '-p'|'-r'|'-s'|'-S'|'-k'|'-l'|'-L'|'-M'|'-o'|'-O')shift;_BYPASSARGS="${_BYPASSARGS} $1";;
		    '-t'|'-T'|'-W'|'-x'|'-z'|'-Z')                    shift;_BYPASSARGS="${_BYPASSARGS} $1";;

		    '-H'|'-E'|'-f'|'-h'|'-n'|'-v'|'-V'|'-w'|'-X'|'-y');;

		    '-z')shift;_TRM=" -t ";;
		    '-Y')_AGENTFORW=1;;
		esac
		;;
            *)_ARGS="${_ARGS} $1";;
	esac
	shift
    else
        _ARGS="${_ARGS} $1";
	shift
    fi
done

_ARGS=${_ARGS## };
_ARGS=${_ARGS%% };
_ARGS=${_ARGS//\\/\\\\};
_RARGS=${_ARGSCALL//$_ARGS/}
_RARGS=${_RARGS%% };

if [ "$_RARGS" != "${_RARGS%%--beam-this}" ];then
    _RARGS=${_RARGS%%--beam-this*};
else
    _RARGS=${_RARGS%%--\%--};
fi

_RARGS=${_RARGS//$_RHOSTS0/}
_RARGS=${_RARGS//-R/}
printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_ARGS =<$_ARGS>"
printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_RARGS=<$_RARGS>"

if [ -n "$_HelpEx" ];then
    printHelpEx "${_HelpEx}";
    exit 0;
fi

if [ -n "$_showToolHelp" ];then
    showToolHelp;
    exit 0;
fi

if [ -n "$_printVersion" ];then
    printVersion;
    exit 0;
fi

if [ -z "${_RHOSTS0}" ];then
    ABORT=1
    printERR $LINENO $BASH_SOURCE ${ABORT} "ERROR:Missing remote host/relay chain: \"-R\""
    printERR $LINENO $BASH_SOURCE ${ABORT} "  $0 "
    printERR $LINENO $BASH_SOURCE ${ABORT} "  Call options = <${_ARGSCALL}>"
    gotoHell ${ABORT}
fi

if [ -n "${_RUSER0}" -a "${_RHOSTS0//@}" != "${_RHOSTS0}" ];then
    ABORT=1
    printERR $LINENO $BASH_SOURCE ${ABORT} "ERROR:\"-L\" option and EMail style addresses \"<USER>@<HOST>\""
    printERR $LINENO $BASH_SOURCE ${ABORT} "ERROR:cannot be used intermixed."
    printERR $LINENO $BASH_SOURCE ${ABORT} "  _RUSER0   = ${_RUSER0}"
    printERR $LINENO $BASH_SOURCE ${ABORT} "  _RHOSTS0  = ${_RHOSTS0}"
    gotoHell ${ABORT}
fi

if [ -z "${_ARGS}" ];then
    ABORT=1
    printERR $LINENO $BASH_SOURCE ${ABORT} "ERROR:Missing remote call"
    printERR $LINENO $BASH_SOURCE ${ABORT} "  _ARGSCALL     = <${_ARGSCALL}>"
    gotoHell ${ABORT}
fi

_MODE=$(echo "$_MODE"|tr 'a-z' 'A-Z')
case $_MODE in

    CTYS-HOPS|CH|0)
	_ARGS="${_ARGS//_AND_/&&}";
	beamMeUp
	_ARGS=$(echo ${_ARGS}|sed 's/--beam-this / /g;')
	_ARGS=$(echo ${_ARGS}|sed 's/--[% ]/ /g;')
	_ARGS=$(echo ${_ARGS}|sed 's/--%--/ /g;')
	_ARGS=$(echo ${_ARGS}|sed 's/\([^%]*\)%\([^%]*\)/\1 \2 /g;')
	printFINALCALL 0  $LINENO $BASH_SOURCE "FINAL-REMOTE-CALL:" "${_ARGS}"
	eval ${_ARGS} 
	sleep ${CTYS_PREDETACH_TIMEOUT:-10} 
	exit
	;;

    SSH-CHAIN|SC|1)
	_ARGSx=${_ARGS}
	_HOPHOLD=${_HOPHOLD:-60}
	_ARGS="sleep ${_HOPHOLD}"

	if [ "$C_TERSE" != 1 ];then
 	    printINFO 1 $LINENO $BASH_SOURCE 1 "Use either '-X' or '-d i:0' to suppress these startup $(setFontAttrib FGREEN INFO) messages"
 	    printINFO 1 $LINENO $BASH_SOURCE 1 "."
	    printINFO 1 $LINENO $BASH_SOURCE 1 "Remote execution by  $(setFontAttrib BOLD SSH-CHAIN)."
	    if [ -n "${_SET_B}" ];then
		printINFO 1 $LINENO $BASH_SOURCE 1 "Current background mode is $(setFontAttrib BOLD \"-b ${_SET_B}\")."
	    fi
	    printINFO 1 $LINENO $BASH_SOURCE 1 "The $(setFontAttrib BOLD default) background mode $(setFontAttrib BOLD \"-b SYNC,SEQ\") is $(setFontAttrib BOLD SYNCHRONOUS) and $(setFontAttrib BOLD SEQUENTIAL) "
	    printINFO 1 $LINENO $BASH_SOURCE 1 "recommended for single CLI dialogue actions."
	    printINFO 1 $LINENO $BASH_SOURCE 1 "Use generic option $(setFontAttrib BOLD '-b ASYNC,(SEQ|PAR)')  for $(setFontAttrib BOLD 'remote desktops'), $(setFontAttrib BOLD servers),"
	    printINFO 1 $LINENO $BASH_SOURCE 1 "and $(setFontAttrib BOLD 'parallel actions'). The modes $(setFontAttrib BOLD 'SEQ') and $(setFontAttrib BOLD 'PAR') are the same for SSH-CHAIN."
 	    printINFO 1 $LINENO $BASH_SOURCE 1 "."
	    printINFO 1 $LINENO $BASH_SOURCE 1 "Display resulting execution call by usage of common debugging option '-d pf'."
 	    printINFO 1 $LINENO $BASH_SOURCE 1 "."

	    printINFO 1 $LINENO $BASH_SOURCE 1 "Local Hold-Timeout for SSH-CHAIN connection is:${_HOPHOLD}"
 	    printINFO 1 $LINENO $BASH_SOURCE 1 "."
	fi

# 	for _p in ${_RHOSTS0//,/ };do
# 	    _tlst=$(resolveTunnels "" "${_p}")


# 	    setupTunnels "${_tlst}"
# 	    if [ "$C_TERSE" != 1 ];then
# 		printINFO 1 $LINENO $BASH_SOURCE 1 "Remote execution through SSH tunnel:${_tlst}"
#  		printINFO 1 $LINENO $BASH_SOURCE 1 "."
# 	    fi
# 	done


	for _p in ${_RHOSTS0//,/ };do
	    _tlst=$(resolveTunnels "" "${_p}")

	    setupTunnels "${_tlst}"
	    if [ "$C_TERSE" != 1 ];then
		printINFO 1 $LINENO $BASH_SOURCE 1 "Remote execution through SSH tunnel:${_tlst}"
 		printINFO 1 $LINENO $BASH_SOURCE 1 "."
	    fi
	done

	CONNECT_DELAY=${CONNECT_DELAY:-5}
	sleep ${CONNECT_DELAY}
	for((i=0;i<APIDX;i++));do
	    if [ -z "${_RUSER0}" ];then
		_RUSER0x=${_RHOSTS0%@*}
		if [ "$_RUSER0x" != "${_RHOSTS0}" ];then
		    _RUSER0=${_RUSER0x##*\%}
		fi
	    fi

	    if [ "$C_TERSE" != 1 -a -n "${_RUSER0}" ];then
		printINFO 1 $LINENO $BASH_SOURCE 1 "Remote execution${_RUSER0:+ as \"$_RUSER0\"} on:${_tlst}"
 		printINFO 1 $LINENO $BASH_SOURCE 1 "."
	    fi
	    _call="ssh  "
	    if [ -n "$_SET_B" ];then
		case "$_SET_B" in
		    ASYNC|ASYNC,*|*,ASYNC|1|1,*|*,1)
			_call="${_call}  -f "
			;;
		esac
	    fi
	    _call="$_call ${_X11:+  -X} -p ${AP[$i]} ${_AGENTFORW:+-A} ${_RUSER0:+-l $_RUSER0} localhost \"${_ARGSx}\""
	    printFINALCALL 0  $LINENO $BASH_SOURCE "FINAL-REMOTE-CALL:" "${_call}"
	    eval ${_call}
	done
	exit
	;;

    *)
	ABORT=1
	printERR $LINENO $BASH_SOURCE ${ABORT} "Unknown MODE=\"$_MODE\""
	gotoHell ${ABORT}
	;;
esac

