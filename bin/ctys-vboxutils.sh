#!/bin/bash


#############
#
#Currently not provided
#
#############
#
#
echo
echo "##########################"
echo "# Currently not provided #">&2
echo "##########################"
echo
exit 1
#
#
#############




########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_006alphaPreRelease
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

DEFAULT_C_SESSIONTYPE=${DEFAULT_C_SESSIONTYPE:-VNC}
DEFAULT_C_SCOPE=${DEFAULT_C_SCOPE:-USER}
C_SCOPE=${C_SCOPE:-$DEFAULT_C_SCOPE}

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
FULLNAME="CTYS VirtualBox Utilities"
#
#CALLFULLNAME:
CALLFULLNAME="ctys-vboxutils.sh"
#
#LICENCE:
LICENCE=GPL3
#
#TYPE:
#  bash-script
#
#VERSION:
VERSION=01_11_006alphaPreRelease
#DESCRIPTION:
#  Offers some base functions, currently pre-release, may even not work.
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
. ${MYLIBPATH}/lib/misc.sh
. ${MYLIBPATH}/lib/security.sh
. ${MYLIBPATH}/lib/network/network.sh
. ${MYLIBPATH}/lib/groups.sh

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



. ${MYLIBPATH}/lib/libVBOX.sh

PLUGINPATHS=${MYINSTALLPATH}/plugins/CORE
PLUGINPATHS=${PLUGINPATHS}:${MYINSTALLPATH}/plugins/GENERIC
# PLUGINPATHS=${PLUGINPATHS}:${MYINSTALLPATH}/plugins/HOSTs
# PLUGINPATHS=${PLUGINPATHS}:${MYINSTALLPATH}/plugins/VMs
# PLUGINPATHS=${PLUGINPATHS}:${MYINSTALLPATH}/plugins/PMs
# PLUGINPATHS=${PLUGINPATHS}:${MYINSTALLPATH}/plugins/GUESTs

LD_PLUGIN_PATH=${LD_PLUGIN_PATH}:${PLUGINPATHS}



function 0_initPlugins ()  {
    MYROOTHOOK=${MYINSTALLPATH}/plugins/hook.sh
    if [ ! -f "${MYROOTHOOK}" ];then 
	ABORT=2
	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing packages hook: hook=${MYROOTHOOK}"
	gotoHell ${ABORT}
    fi
    . ${MYROOTHOOK}
    initPackages "${MYROOTHOOK}"
}


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
# 		    VBOXPATH4OBJID|P4O) 
# 			shift;
# 			ctysVBOXS2FetchVBOXPath4ObjID $1;
# 			;;
# 		    VBOXOBJID4PATH|O4P) 
# 			shift;
# 			ctysVBOXS2FetchVBOXObjID4Path $1;
# 			;;
# # 		    REMOTEVBOXPATH4OBJID) 
# # 			ctysVBOXS2FetchRemoteVBOXPath4ObjID
# # 			;;
# 		    DATASTORE|D) 
# 			shift;
# 			ctysVBOXS2FetchDatastore $1;
# 			;;
		    *)
			printERR $LINENO $BASH_SOURCE ${ABORT} "ACTION=$ACTION unknown SCOPE=$SCOPE"
			gotoHell ${ABORT}  
			;;
		esac
		;;

	    CONVERT|C)
		case $SCOPE in
# 		    TODATASTORE|2D) 
# 			shift;
# 			ctysVBOXS2ConvertToDatastore $1
# 			;;
# # 		    CHECKLOCALCLIENT) 
# # 			ctysVBOXS2CheckLocalClient
# # 			;;
		    *)
			printERR $LINENO $BASH_SOURCE ${ABORT} "ACTION=$ACTION unknown SCOPE=$SCOPE"
			gotoHell ${ABORT}  
			;;
		esac
		;;

	    LIST|L)
		case $SCOPE in
# 		    INVENTORY|I) 
# 			ctysVBOXS2ListVmInventory
# 			;;
# 		    DATASTORES|D) 
# 			ctysVBOXS2ListDatastores
# 			;;
		    SERVERS) 
			ctysVBOXListLocalServers
			;;
# 		    SERVERPATHS) 
# 			ctysVBOXS2ListServerPaths
# 			;;
		    CLIENTS) 
			C_SCOPE="USER"
			C_SCOPE_ARGS="ALL"
			ctysVBOXListClientServers
			;;
# 		    LOCALCLIENTS) 
# 			ctysVBOXS2ListLocalClients
# 			;;
# 		    REMOTECLIENTS) 
# 			ctysVBOXS2ListRemoteClients
# 			;;
# 		    REMOTECLIENTSEX) 
# 			ctysVBOXS2ListRemoteClientsEx
# 			;;
# 		    LOCALCLIENTSEX) 
# 			ctysVBOXS2ListLocalClientsEx
# 			;;
# 		    RELAYS) 
# 			ctysVBOXS2ListRelays
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

0_initPlugins
execAction ${_ARGS}
gotoHell $_ex

