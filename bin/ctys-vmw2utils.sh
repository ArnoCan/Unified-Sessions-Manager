#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_10_010
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


################################################################
#                   Begin of FrameWork                         #
################################################################


#FUNCBEG###############################################################
#
#PROJECT:
MYPROJECT="Unified Sessions Manager"
#
#NAME:
#  ctys-extractMAClst.sh
#
#AUTHOR:
AUTHOR="Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org"
#
#FULLNAME:
FULLNAME="CTYS VMW Server-2 Utilities"
#
#CALLFULLNAME:
CALLFULLNAME="ctys-vmw2utils.sh"
#
#LICENCE:
LICENCE=GPL3
#
#TYPE:
#  bash-script
#
#VERSION:
VERSION=01_10_010
#DESCRIPTION:
#  Configures the VDE based TAP device and virtual switch.
#
#EXAMPLE:
#
#PARAMETERS:
#
#  refer to online help "-h" and/or "-H"
#
#OUTPUT:
#  RETURN:
#  VALUES:
#    Standard output is screen.
#
#FUNCEND###############################################################


################################################################
#                     Global shell options.                    #
################################################################
shopt -s nullglob



################################################################
#       System definitions - do not change these!              #
################################################################

C_EXECLOCAL=1;

#Execution anchor
MYCALLPATHNAME=$0
MYCALLNAME=`basename $MYCALLPATHNAME`
MYCALLNAME=${MYCALLNAME%.sh}
MYCALLPATH=`dirname $MYCALLPATHNAME`

#
#If a specific library is forced by the user
#
if [ -n "${CTYS_LIBPATH}" ];then
    MYLIBPATH=$CTYS_LIBPATH
    MYLIBEXECPATHNAME=${CTYS_LIBPATH}/bin/$MYCALLNAME
else
    MYLIBEXECPATHNAME=$MYCALLPATHNAME
fi

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

MYBOOTSTRAP=${MYBOOTSTRAP}/bootstrap.01.01.003.sh
if [ ! -f "${MYBOOTSTRAP}" ];then
    echo "${MYCALLNAME}:$LINENO:ERROR:Missing:MYBOOTSTRAP=${MYBOOTSTRAP}"
    cat <<EOF  

DESCRIPTION:
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
MYLIBPATH=${CTYS_LIBPATH:-`dirname $MYLIBEXECPATH`}

#path for various loads: libs, help, macros, plugins
MYHELPPATH=${MYLIBPATH}/help/${MYLANG}


###################################################
#Check master hook                                #
###################################################
bootstrapCheckInitialPath
###################################################
#OK - Now should work.                            #
###################################################

MYCONFPATH=${MYLIBPATH}/conf/ctys
if [ ! -d "${MYCONFPATH}" ];then
    echo "${MYCALLNAME}:$LINENO:ERROR:Missing:MYCONFPATH=${MYCONFPATH}"
    exit 1
fi

if [ -f "${MYCONFPATH}/versinfo.conf.sh" ];then
    . ${MYCONFPATH}/versinfo.conf.sh
fi

MYMACROPATH=${MYCONFPATH}/macros
if [ ! -d "${MYMACROPATH}" ];then
    echo "${MYCALLNAME}:$LINENO:ERROR:Missing:MYMACROPATH=${MYMACROPATH}"
    exit 1
fi

MYPKGPATH=${MYLIBPATH}/plugins
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

if [ ! -d "${MYINSTALLPATH}" ];then
    ABORT=1;
    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing:MYINSTALLPATH=${MYINSTALLPATH}"
    gotoHell ${ABORT}
fi

MYOPTSFILES=${MYOPTSFILES:-$MYLIBPATH/help/$MYLANG/*_base_options} 
checkFileListElements "${MYOPTSFILES}"
if [ $? -ne 0 ];then
    ABORT=1;
    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing:MYOPTSFILES=${MYOPTSFILES}"
    gotoHell ${ABORT}
fi


################################################################
# Main supported runtime environments                          #
################################################################
#release
TARGET_OS="Linux: CentOS/RHEL(5+), SuSE-Professional 9.3"

#to be tested - coming soon
TARGET_OS_SOON="OpenBSD+Linux(might work for any dist.):Ubuntu+OpenSuSE"

#to be tested - might be almsot OK - but for now FFS
#...probably some difficulties with desktop-switching only?!
TARGET_OS_FFS="FreeBSD+Solaris/SPARC/x86"

#release
TARGET_WM="Gnome + fvwm"

#to be tested - coming soon
TARGET_WM_SOON="xfce"

#to be tested - coming soon
TARGET_WM_FORESEEN="KDE(might work now)"

################################################################
#                     End of FrameWork                         #
################################################################

. ${MYLIBPATH}/lib/help/help.sh
. ${MYLIBPATH}/lib/security.sh
. ${MYLIBPATH}/lib/network/network.sh


#
#Verify OS support
#
case ${MYOS} in
    Linux);;
    *)
        printINFO 1 $LINENO $BASH_SOURCE 1 "${MYCALLNAME} is not supported on ${MYOS}"
	gotoHell 0
	;;
esac

#path to directory containing the default mapping db
if [ -d "${HOME}/.ctys/db/default" ];then
    DEFAULT_DBPATHLST=${DEFAULT_DBPATHLST:-$HOME/.ctys/db/default}
fi

#path to directory containing the default mapping db
if [ -d "${MYCONFPATH}/db/default" ];then
    DEFAULT_DBPATHLST=${DEFAULT_DBPATHLST:-$HOME/conf/db/default}
fi


_myHint="${MYCONFPATH}/systools.conf-${MYDIST}.sh"
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



. ${MYLIBPATH}/lib/libVMWserver2.sh


##########################
##########################
_ex=0
ACTION=;
ACTIONCHK=0;
_ARGS=;
_ARGSCALL=$*;
_RUSER=;



################################################################
#    Default definitions - User-Customizable  from shell       #
################################################################


function execAction () {
    while [ -n "$1" ];do
	printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:1=${1}"
	ACTION=$(echo $1|tr 'a-z' 'A-Z');
	shift;SCOPE=$(echo $1|tr 'a-z' 'A-Z');
	case $ACTION in
	    FETCH|F)
		case $SCOPE in
		    VMWPATH4OBJID|P4O) 
			shift;
			ctysVMWS2FetchVMWPath4ObjID $1;
			;;
		    VMWOBJID4PATH|O4P) 
			shift;
			ctysVMWS2FetchVMWObjID4Path $1;
			;;
# 		    REMOTEVMWPATH4OBJID) 
# 			ctysVMWS2FetchRemoteVMWPath4ObjID
# 			;;
		    DATASTORE|D) 
			shift;
			ctysVMWS2FetchDatastore $1;
			;;
		    *)
			printERR $LINENO $BASH_SOURCE ${ABORT} "ACTION=$ACTION unknown SCOPE=$SCOPE"
			gotoHell ${ABORT}  
			;;
		esac
		;;

	    CONVERT|C)
		case $SCOPE in
		    TODATASTORE|2D) 
			shift;
			ctysVMWS2ConvertToDatastore $1
			;;
# 		    CHECKLOCALCLIENT) 
# 			ctysVMWS2CheckLocalClient
# 			;;
		    *)
			printERR $LINENO $BASH_SOURCE ${ABORT} "ACTION=$ACTION unknown SCOPE=$SCOPE"
			gotoHell ${ABORT}  
			;;
		esac
		;;

	    LIST|L)
		case $SCOPE in
		    INVENTORY|I) 
			ctysVMWS2ListVmInventory
			;;
		    DATASTORES|D) 
			ctysVMWS2ListDatastores
			;;
# 		    LOCALSERVERS) 
# 			ctysVMWS2ListLocalServers
# 			;;
# 		    SERVERPATHS) 
# 			ctysVMWS2ListServerPaths
# 			;;
# 		    CLIENTS) 
# 			ctysVMWS2ListClients
# 			;;
# 		    LOCALCLIENTS) 
# 			ctysVMWS2ListLocalClients
# 			;;
# 		    REMOTECLIENTS) 
# 			ctysVMWS2ListRemoteClients
# 			;;
# 		    REMOTECLIENTSEX) 
# 			ctysVMWS2ListRemoteClientsEx
# 			;;
# 		    LOCALCLIENTSEX) 
# 			ctysVMWS2ListLocalClientsEx
# 			;;
# 		    RELAYS) 
# 			ctysVMWS2ListRelays
# 			;;
		    *)
			printERR $LINENO $BASH_SOURCE ${ABORT} "ACTION=$ACTION unknown SCOPE=$SCOPE"
			gotoHell ${ABORT}  
			;;
		esac
		;;

	    *)
		ABORT=1;
		printERR $LINENO $BASH_SOURCE ${ABORT} "Unknown ACTION=$ACTION"
		gotoHell ${ABORT}  
		;;
	esac
	shift
    done
}

printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_ARGSCALL=${_ARGSCALL}"

_RUSER0=;
_RHOSTS0=;
while [ -n "$1" ];do
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:1=${1}"
    case $1 in
	'-L')shift;_RUSER0=$1;;
	'-R')shift;_RHOSTS0=$1;;

	'-n')_nohead=1;;

	'-H'|'--helpEx'|'-helpEx')shift;_HelpEx="${1:-$MYCALLNAME}";;
	'-h'|'--help'|'-help')_showToolHelp=1;;
	'-V')_printVersion=1;;
	'-X')C_TERSE=1;;

	'-d')shift;;

        -*)
	    ABORT=1;
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Unkown option:\"$1\""
	    gotoHell ${ABORT}
	    ;;

	*)
   	    _ARGS="${_ARGS} $1"
	    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_ARGS=${_ARGS}"
	    ;;
    esac
    shift
done

if [ -n "$*" ];then
    printERR $LINENO $BASH_SOURCE 1 "Remaining arguments:$_ARGSCALL"
    gotoHell 1
fi

function beamMeUp () {
    if [ -n "${_RHOSTS0}" ];then
	_RARGS=${_ARGSCALL//$_ARGS/}
	_MYLBL=${MYCALLNAME}-${MYUID}-${DATE}
	printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_ARGS =<$_ARGS>"
	printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_RARGS=<$_RARGS>"
	_RARGS=${_ARGSCALL//$_RHOSTS0/}
	_RARGS=${_RARGS//-R/}
	if [ -n "${_RUSER0}" ];then
	    _RARGS=${_RARGS//$_RUSER0/}
	    _RARGS=${_RARGS//\-L/}
	fi
	_RARGS=$(echo ${_RARGS}|sed 's/^  *//;s/  *$//')
	printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_RARGS=<$_RARGS>"
	_RARGS=${_RARGS//\%/\%\%}
	_RARGS=${_RARGS//,/,,}
	_RARGS=${_RARGS//:/::}
	_RARGS=${_RARGS//  / }
	_RARGS=${_RARGS//  / }
	_RARGS=${_RARGS// /\%}
	printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_RARGS=<$_RARGS>"
	_MYLBL=${MYCALLNAME}-${MYUID}-${DATE}

	if [ "$C_TERSE" != 1 ];then
	    printINFO 1 $LINENO $BASH_SOURCE 1 "Remote execution${_RUSER0:+ as \"$_RUSER0\"} on:${_RHOSTS0}"
	fi
	_call="ctys ${C_DARGS} -t cli -a create=l:${_MYLBL},cmd:${MYCALLNAME}${_RARGS:+%$_RARGS} ${_RUSER0:+-l $_RUSER0} ${_RHOSTS0}"
	printFINALCALL $LINENO $BASH_SOURCE "FINAL-REMOTE-CALL:" "${_call}"
	${_call}
	exit $?
    fi
}
beamMeUp

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

execAction ${_ARGS}
gotoHell $_ex





