#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_007
#
########################################################################
#
#     Copyright (C) 2007,2008,2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
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
#  ctys-plugins.sh
#
#AUTHOR:
AUTHOR="Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org"
#
#FULLNAME:
FULLNAME="Unified Sessions Manager"
#
#CALLFULLNAME:
CALLFULLNAME="Check and Manage Plugins"
#
#LICENCE:
LICENCE=GPL3
#
#TYPE:
#  bash-script
#
#VERSION:
VERSION=01_11_007
#DESCRIPTION:
#  Main untility of project ctys for manging sessions.
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
#
#FUNCEND###############################################################

################################################################
#                     Global shell options.                    #
################################################################
shopt -s nullglob



################################################################
#       System definitions - do not change these!              #
################################################################
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

MYBOOTSTRAP=${MYBOOTSTRAP}/bootstrap.01.01.006.sh
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


#
#Verify OS support
#
case ${MYOS} in
    Linux);;
    FreeBSD|OpenBSD);;
    SunOS);;
    *)
        printINFO 1 $LINENO $BASH_SOURCE 1 "${MYCALLNAME} is not supported on ${MYOS}"
	gotoHell 0
	;;
esac

if [ "${*}" != "${*//-X/}" ];then
    C_TERSE=1
fi



#path to directory containing the default mapping db
if [ ! -d "${HOME}/.ctys/db/default" ];then
  echo "${MYCALLNAME}:$LINENO:ERROR:Missing standard directory:$MYCONFPATH/groups"
  echo "${MYCALLNAME}:$LINENO:ERROR:Has to be present at least, check your installation"
  exit 1

fi
DEFAULT_DBPATHLST=${DEFAULT_DBPATHLST:-$HOME/.ctys/db/default}

#path to directory containing the default mapping db
if [ -d "${MYCONFPATH}/db/default" ];then
    DEFAULT_DBPATHLST=${DEFAULT_DBPATHLST:-$MYCONFPATH/db/default}
fi


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

################################################################
#    Default definitions - User-Customizable  from shell       #
################################################################

###################
#generic
DEFAULT_C_SESSIONTYPE=${DEFAULT_C_SESSIONTYPE:-CLI}
DEFAULT_C_SCOPE=${DEFAULT_C_SCOPE:-USER}
DEFAULT_KILL_DELAY_POWEROFF=${DEFAULT_KILL_DELAY_POWEROFF:-20}
DEFAULT_LIST_CONTENT=${DEFAULT_LIST_CONTENT:-ALL,BOTH}


###################
#CREATE

###################
#LIST
DEFAULT_C_MODE_ARGS_LIST=${DEFAULT_C_MODE_ARGS_LIST:-"label,id,user,group,pid"}
#DEFAULT_LIST_C_SCOPE="USRLST"
#DEFAULT_LIST_C_SCOPE_ARGS="all"

###################
#ENUMERATE
DEFAULT_C_MODE_ARGS_ENUMERATE=${DEFAULT_C_MODE_ARGS_ENUMERATE:-'.'}

###################
#CREATE
DEFAULT_C_MODE_ARGS=${DEFAULT_C_MODE_ARGS_CREATE:-'1,DEFAULT,REUSE'}



################################################################
#Globalized convenience settings for Basic-Community-Packages  #
################################################################

#Common: Defines the timeout an established port-forwarding tunnel by 
#OpenSSH.
#Should wait for it's first and only one (just an wannabee oneshot - within
#the period any number of connects are possible) connection. This is choosen,
#because because now no precautions have to be and are not implemented for
#cancellation of no longer required tunnels. So you might no set a high value,
#just smallerr than a minute.
#Existing ports are not reused anyway, because the next tunnel-request
#increments the highest present for a new tunnel.
#
#APPLY:Increment when clients do not connect with CONNECTIONFORWARDING.
SSH_ONESHOT_TIMEOUT=${SSH_ONESHOT_TIMEOUT:-20}


#Common: Defines the timeout to delay the start of a client after server
#
#APPLY:Increment this value when clients do not connect.
R_CLIENT_DELAY=${R_CLIENT_DELAY:-2}

#Common: Defines the timeout after all XClients of one desktop are 
#started. Due to problems with reliability a shift of distinguished 
#windows seems not to work(at least in my environment on CentOS-5.0/Gnome).
#So current desktop is switched for default pop-up on target desktop
#gwhich could take some time until the window actually is displayed.
#When the desktop is meanwhile switched the window will be positioned 
#on the current if not yet displayed.
#Depends on actual base, it seems that at least 5seconds are required,
#for safety 8 seconds are choosen.
#
#APPLY:Increment this value when clients pop-up on wrong desktop.
X_DESKTOPSWITCH_DELAY=${X_DESKTOPSWITCH_DELAY:-8}



################################################################
#Basic-Package Settings: VNC
#
#General remarks: 
# The geometry parameter will be reset - for server too - when selected
# at the CLI by "-g" option. So the value here is just a default, when no 
# call parameter is supported.
#

#Bulk: Defines the timeout to wait between bulk creation of sessions 
R_CREATE_TIMEOUT=${R_CREATE_TIMEOUT:-5}


#Bulk: Defines the maximum allowed number of sessions to be created by a bulk call.
#ATTENTION:Mistakenly using e.g. 1000 will probably force you to reboot your machines!!!!
#A call of "ctys -a cancel=all poorHost" might help?!
#
#APPLY:Increment this when more VNC-bulk sessions on a node are required.
R_CREATE_MAX=${R_CREATE_MAX:-20}


################################################################
#      Internal control flow - do not change these!            #
################################################################
C_SESSIONTYPE=DEFAULT
PACKAGES_KNOWNTYPES=

unset C_XTOOLKITOPTS;

unset C_SESSIONID;
unset C_SESSIONIDARGS;
unset C_SESSIONFLAG;
C_MODE=CREATE
#unset C_MODE_ARGS
#C_MODE_ARGS="1,DEFAULT,REUSE"
C_MODE_ARGS=DEFAULT
C_SCOPE=DEFAULT
unset C_SCOPE_ARGS
unset C_SCOPE_CONCAT
C_SSH=1
unset C_EXECLOCAL;
unset C_NOEXEC;
unset C_LISTSES;
unset C_TERSE;
C_PRINTINFO=0;
C_ASYNC=DEFAULT;

unset C_WMC_DESK
unset C_MDESK;
 
unset C_GEOMETRY;
unset C_REMOTERESOLUTION;
unset C_FORCE;
unset C_ALLOWAMBIGIOUS;
#WNG=1;

unset R_HOSTS;
unset R_OPTS;
#unset R_TEXT;
unset X_OPTS;


#Options for formatting text with "pr" when printing out the embedded help.
PR_OPTS=${PR_OPTS:--o 5 -l 76}

#Using this as a ready to use option, some lengthy keywords for now,
#but recognition has priority over string replace-functions!
C_CLIENTLOCATION=${C_CLIENTLOCATION:-"-L DISPLAYFORWARDING"};


#Base for remapping of local client access ports for CONNECTIONFORWARDING
LOCAL_PORTREMAP=${LOCAL_PORTREMAP:-5950}

#Is defined to be used when set, so it is foreseen as test-path for remote call
#R_PATH

#Is defined to be used when set, so it is foreseen as test-path for local call
#L_PATH


#assure for append...
if [ -n "$CTYS_GROUPS_PATH" ];then
    mstr=$HOME/.ctys/groups
    CTYS_GROUPS_PATH=${CTYS_GROUPS_PATH//$mstr}
    mstr=$MYCONFPATH/groups
    CTYS_GROUPS_PATH=${CTYS_GROUPS_PATH//$mstr}
fi

if [ -n "$CTYS_GROUPS_PATH" ];then
    checkPathElements CTYS_GROUPS_PATH ${CTYS_GROUPS_PATH}
fi

if [ ! -d "${HOME}/.ctys/groups" ];then
    ABORT=1;
    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing standard directory:${HOME}/.ctys/groups"
    printERR $LINENO $BASH_SOURCE ${ABORT} "Has to be present at least, check your installation"
    gotoHell ${ABORT}
fi

if [ ! -d "${MYCONFPATH}/groups" ];then
    ABORT=1;
    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing standard directory:${MYCONFPATH}/groups"
    printERR $LINENO $BASH_SOURCE ${ABORT} "Has to be present at least, check your installation"
    gotoHell ${ABORT}
fi

CTYS_GROUPS_PATH="${HOME}/.ctys/groups:${MYCONFPATH}/groups${CTYS_GROUPS_PATH:+:$CTYS_GROUPS_PATH}"




################################################################
#                    Initial call trace                        #
################################################################
printDBG $S_BIN ${D_FLOW} $LINENO $BASH_SOURCE ""
printDBG $S_BIN ${D_FLOW} $LINENO $BASH_SOURCE "-----------------------------------------------------------------------------"
printDBG $S_BIN ${D_FLOW} $LINENO $BASH_SOURCE "TRACE:CALL-PARAMS:"
printDBG $S_BIN ${D_FLOW} $LINENO $BASH_SOURCE "<${0} ${*}>"
printDBG $S_BIN ${D_FLOW} $LINENO $BASH_SOURCE "-----------------------------------------------------------------------------"
printDBG $S_BIN ${D_FLOW} $LINENO $BASH_SOURCE "TRACE:ENV-PARAMS:"
printDBG $S_BIN ${D_FLOW} $LINENO $BASH_SOURCE "<PATH=${PATH}>"
printDBG $S_BIN ${D_FLOW} $LINENO $BASH_SOURCE "<LD_PLUGIN_PATH=${LD_PLUGIN_PATH}>"
printDBG $S_BIN ${D_FLOW} $LINENO $BASH_SOURCE "<RS_PREFIX_L=${RS_PREFIX_L}>"
printDBG $S_BIN ${D_FLOW} $LINENO $BASH_SOURCE "<RS_PREFIX_R=${RS_PREFIX_R}>"
printDBG $S_BIN ${D_FLOW} $LINENO $BASH_SOURCE "-----------------------------------------------------------------------------"
printDBG $S_BIN ${D_FLOW} $LINENO $BASH_SOURCE ""




#################################################################################
#load libraries and plugins                                                     #
#################################################################################
#
#Remark: The online help is loaded only when requested by user.
#        The runtime modules are loaded "by-startup-scan" not on demand.
#
#        - BASE-libs and CORE-plugins with related help:
#          are loaded - due to beeing prerequisite - as hardcoded entities.
#          Related help is loaded when requested, but on-demand as said.
#
#        - ADD-ON-PACKAGES
#          Loaded "by-startup-scan".
#
#        - ADD-ON-MACROS
#          CONFIG-MACROS: Loaded as given by User-Option.
#

#########################################################################
#libraries - generic functions                                          #
#########################################################################

#These will be hardcoded and just sourced, but are completely unmanaged.
. ${MYLIBPATH}/lib/cli/cli.sh
. ${MYLIBPATH}/lib/misc.sh
. ${MYLIBPATH}/lib/security.sh
. ${MYLIBPATH}/lib/help/help.sh
. ${MYLIBPATH}/lib/geometry/geometry.sh
. ${MYLIBPATH}/lib/wmctrlEncapsulation.sh
. ${MYLIBPATH}/lib/network/network.sh
. ${MYLIBPATH}/lib/groups.sh


#########################################################################
#plugins - project specific commons and feature plugins                 #
#########################################################################


PLUGINPATHS=${MYINSTALLPATH}/plugins/CORE
PLUGINPATHS=${PLUGINPATHS}:${MYINSTALLPATH}/plugins/GENERIC
PLUGINPATHS=${PLUGINPATHS}:${MYINSTALLPATH}/plugins/HOSTs
PLUGINPATHS=${PLUGINPATHS}:${MYINSTALLPATH}/plugins/VMs
PLUGINPATHS=${PLUGINPATHS}:${MYINSTALLPATH}/plugins/PMs
PLUGINPATHS=${PLUGINPATHS}:${MYINSTALLPATH}/plugins/GUESTs

LD_PLUGIN_PATH=${LD_PLUGIN_PATH}:${PLUGINPATHS}


function echoX ()  {
    if [ -z "$C_TERSE" ];then
	echo -e $*
    fi
}

function printfX ()  {
    if [ -z "$C_TERSE" ];then
	eval printf $*
    fi
}
function 0_initPlugins ()  {
    #
    #Perform the initialization according and based on LD_PLUGIN_PATH.
    #

    echoX
    echoX "------------------------------"
    echoX "Start check on:${MYHOST}"
    echoX "------------------------------"
    echoX "Prepare check on:${MYHOST}"
    echoX "------------------------------>>>"
    MYROOTHOOK=${MYINSTALLPATH}/plugins/hook.sh
    if [ ! -f "${MYROOTHOOK}" ];then 
	ABORT=2
	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing packages hook: hook=${MYROOTHOOK}"
	gotoHell ${ABORT}
    fi
    echoX "<<<------------------------------"
    echoX "Checking PLUGINS-STATEs on:${MYHOST}"
    echoX "Perform:${MYROOTHOOK}"
    echoX "------------------------------>>>"
    . ${MYROOTHOOK}

    ODBG=$DBG;
    [ -z "$DBG" -o "$DBG" == 0 ]&&DBG=1;
    initPackages "${MYROOTHOOK}"
    DBG=$ODBG;

    echoX "<<<------------------------------"
    echoX "...results on:${MYHOST} to:"
    echoX
}

function 1_pluginsEnumerate () {
    local _knownTypes="`hookGetKnownTypes`"
    local _disabledTypes="`hookGetDisabledTypes`"
    local _ignoredTypes="`hookGetIgnoredTypes`"

    local _allign=5;
    local _label=12;
    local _label1=23;

    if [ -z "$C_EXECLOCAL" ];then
	printfX "'%$((1*_allign))s%-${_label}s:%-$((2*_allign))s\n' ' ' 'Check-Client/Server' '`setSeverityColor TRY CLIENT features`'"
    else
	printfX "'%$((1*_allign))s%-${_label}s:%-$((2*_allign))s\n' ' ' 'Check-Client/Server' '`setSeverityColor TRY SERVER+CLIENT features`'"
    fi
    echoX

    printfX "'%$((1*_allign))s%-${_label}s:%-$((2*_allign))s\n' ' ' 'Host' '${MYHOST}'"
    printfX "'%$((1*_allign))s%-${_label}s:%-$((2*_allign))s\n' ' ' 'OS' '${MYOS}'"
    printfX "'%$((1*_allign))s%-${_label}s:%-$((2*_allign))s\n' ' ' 'OS-Release' '${MYOSREL}'"
    printfX "'%$((1*_allign))s%-${_label}s:%-$((2*_allign))s\n' ' ' 'Distribution' '${MYDIST}'"
    printfX "'%$((1*_allign))s%-${_label}s:%-$((2*_allign))s\n' ' ' 'Release'      ' ${MYREL}'"
    echoX

    printfX "'%$((1*_allign))s%-${_label}s:%-$((2*_allign))s\n' ' ' 'PLUGINS States as Maximum-Possible' 'Forced states as requested by \"-t\", \"-T\", CORE and GENERIC are not handled here, \"-E\" is considered.'"
    printfX "'%$((1*_allign))s%-${_label}s:%-$((2*_allign))s\n' ' ' 'Check \"ctys.conf.sh\" for deactivated plugins.'"

    printfX "'%$((1*_allign))s%-${_label}s %-$((2*_allign))s\n' ' ' '' '\"${MYCALLNAME} ${CALLARGS}\"'"
    echoX

    #IGNORED(-)
    printfX "'%$((2*_allign))s%-${_label1}s%-$((2*_allign))s\n' ' ' '`setStatusColor IGNORED IGNORED`(-):' '`setStatusColor IGNORED ${_ignoredTypes}`'"

    #AVAILABLE(0)
    printfX "'%$((2*_allign))s%-${_label1}s%-$((2*_allign))s\n' ' ' '`setStatusColor AVAILABLE AVAILABLE`(0):' '`setStatusColor AVAILABLE ${_knownTypes}`'"

    #DISABLED(1)
    printfX "'%$((2*_allign))s%-${_label1}s%-$((2*_allign))s\n' ' ' '`setStatusColor DISABLED DISABLED`(1):' '`setStatusColor DISABLED ${_disabledTypes}`'"

    #ENABLED(2)
    local _curEnabled=$_knownTypes;
    for i in ${_disabledTypes};do
	_curEnabled=${_curEnabled//$i}
    done
    printfX "'%$((2*_allign))s%-${_label1}s%-$((2*_allign))s\n' ' ' '`setStatusColor ENABLED ENABLED`(2):' '`setStatusColor ENABLED ${_curEnabled}`'"

    #IDLE(3)
    local _curIdle=;
    if [ "${C_SESSIONTYPE}" == ALL ];then
	_curIdle="";
    else
	_curIdle=${_curEnabled//$C_SESSIONTYPE};
    fi

    #BUSY(4)
    local _curBusy=;
    if [ "${C_SESSIONTYPE}" == ALL ];then
	_curBusy=${_curEnabled};
    else
	local _t=`echo " $CALLARGS "| sed -n 's/^.* -t/-t/;s/-t \([a-zA-Z0-9]*\) .*$/\1/p'`
	if [ -n "${_t}" ];then
	    _curBusy=`echo "${_t}"|tr '[:lower:]' '[:upper:]'`
	else
	    _curBusy=${C_SESSIONTYPE};
	fi
    fi
    for i in ${_disabledTypes};do
	_curBusy=${_curBusy//$i/${i}\(DISABLED)}
    done
    _curIdle=${_curEnabled//$_curBusy};

    printfX "'%$((2*_allign))s%-${_label1}s%-$((2*_allign))s\n' ' ' '`setStatusColor IDLE IDLE`(3):' '`setStatusColor IDLE ${_curIdle}`'"

    printfX "'%$((2*_allign))s%-${_label1}s%-$((2*_allign))s\n' ' ' '`setStatusColor BUSY BUSY`(4):' '`setStatusColor BUSY ${_curBusy}`'"

    echoX
    printfX "'%$((1*_allign))s%-${_label}s:%-$((2*_allign))s\n' ' ' 'PLUGINS resulting current operational info - As requested by \"-t\", \"-T\", and \"-E\"' ''"
    echoX
    for _ty in ${_knownTypes};do
	eval handle${_ty} PROLOGUE INFO
	eval info${_ty} $_allign 
    done
    echoX "------------------------------"
    echoX "End check on:${MYHOST}"
    echoX "------------------------------"
}




_ARGS=;
_ARGSCALL=$*;
RUSER=;
RUSER0=;

while [ -n "$1" ];do
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:\${1}=<${1}>"
    case $1 in
	'-A');;

	'-d')shift;;

	'-l')shift;RUSER=$1;;

	'-T')shift;;
	'-t')shift;;
	'-Z')shift;
	    _mysub=$1;
	    _cnt=0;
	    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "Set \"su\" mechanism..."
	    for i in ${_mysub//,/ };do
		case $i in
		    [kK][sS][uU})  export USE_K5USERS=1;((_cnt++));;
		    [nN][oO][kK][sS][uU])export USE_K5USERS=0;((_cnt++));;

		    [sS][uU][dD][oO])  export USE_SUDO=1;((_cnt++));;
		    [nN][oO][sS][uU][dD][oO])export USE_SUDO=0;((_cnt++));;


		    [aA][lL][lL])   export USE_SUDO=1;export USE_K5USERS=1;((_cnt++));;
		    *);;
		esac
	    done
	    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "...results to:"
	    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "  USE_K5USERS        =${USE_K5USERS}"
	    printDBG $S_CORE ${D_BULK} $LINENO $BASH_SOURCE "  USE_SUDO           =${USE_SUDO}"
	    if((_cnt=0));then
		ABORT=2;
		printERR $LINENO $BASH_SOURCE ${ABORT} "Argument error:\"-Z ${_mysub}\""
		gotoHell $ABORT
	    fi

	    ;;
	'-E')
	    C_EXECLOCAL=1;
	    printDBG $S_BIN ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:C_EXECLOCAL"
	    ;;

	'--quick-list')_qcheck=1;C_TERSE=1;;
	'--quick-tab')_qcheck=2;C_TERSE=1;;

	'-H'|'--helpEx'|'-helpEx')shift;_HelpEx="${1:-$MYCALLNAME}";;
	'-h'|'--help'|'-help')_showToolHelp=1;;
	'-V')_printVersion=1;;
	'-X')C_TERSE=1;;

        -*)
	    ABORT=1;
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Unkown option:\"$1\""
	    gotoHell ${ABORT}
	    ;;

	*)
	    _ARGS="${_ARGS} ${1}"
	    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_ARGS=${_ARGS}"
	    ;;
    esac
    shift
done


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

_RARGS=${_ARGSCALL//$_ARGS/}
_MYLBL=${MYCALLNAME}-${MYUID}-${DATETIME}-$$

printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_ARGS =<$_ARGS>"
printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_RARGS=<$_RARGS>"
_RARGS=${_RARGS//\%/\%\%}
_RARGS=${_RARGS//,/,,}
_RARGS=${_RARGS//:/::}
_RARGS=${_RARGS//  / }
_RARGS=${_RARGS//  / }
_RARGS=${_RARGS// /\%}
printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_RARGS=<$_RARGS>"
printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_MYLBL=<$_MYLBL>"


if [ -z "${_ARGS}" ];then
    _t=`echo " $_ARGSCALL "| sed -n 's/(.*)//g;s/^.* -T/-T/;s/-T \([a-zA-Z0-9,]*[^ ]\).*$/\1/p'`
    if [ -n "${_t}" ];then
	CTYS_MULTITYPE=`echo "${_t}"|tr '[:lower:]' '[:upper:]'`
	printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:CTYS_MULTITYPE=$CTYS_MULTITYPE"
    fi
    if [ -z "${CTYS_MULTITYPE//*DEFAULT*/}" ];then
	_ac=`echo " $_ARGSCALL "| sed -n 's/^.* -a/-a/;s/-a \([a-zA-Z0-9]*\)[= ].*$/\1/p'|tr '[:lower:]' '[:upper:]'`
	_ty=`echo " $_ARGSCALL "| sed -n 's/^.* -t/-t/;s/-t \([a-zA-Z0-9]*\) .*$/\1/p'|tr '[:lower:]' '[:upper:]'`
	if [ -n "${_ty}" ];then
	    CTYS_MULTITYPE="${_ty}"
	fi
	printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:C_SESSIONTYPE=$C_SESSIONTYPE"
    fi

    0_initPlugins

    case "$_qcheck" in
	1)  1_pluginsEnumerate|awk -F';' '{printf("%-30s %-10s %-12s %-20s %-15s %-10s\n",$1,$2,$3,$4,$5,$6);}'
	    ;;
	2)  1_pluginsEnumerate|awk -F';' -v h="$MYACCOUNT" '
              BEGIN{
                 cli="-";x11="-";vnc="-";rdp="-";qemu="-";kvm="-";vbox="-";vmw="-";xen="-";pm="-";x="x";V="V";
              }
              {acc=$3;}
              $2~/PM/&&$6~/ENABLED/{pm=acc;if(pm~/^$/)pm=x;next;}
              $2~/CLI/&&$6~/ENABLED/{cli=acc;if(cli~/^$/)cli=x;next;}
              $2~/X11/&&$6~/ENABLED/{x11=acc;if(x11~/^$/)x11=x;next;}
              $2~/VNC/&&$6~/ENABLED/{vnc=acc;if(vnc~/^$/)vnc=x;next;}
              $2~/RDP/&&$6~/ENABLED/{rdp=acc;if(rdp~/^$/)rdp=x;next;}

              $2~/VBOX/&&$6~/ENABLED/{vbox=acc;if(vbox~/^$/)vbox=V;next;}

              $5~/VMW_S1/&&$6~/ENABLED/{vmw=acc;if(vmw~/^$/)vmw="S1";next;}
              $5~/VMW_S2/&&$6~/ENABLED/{vmw=acc;if(vmw~/^$/)vmw="S2";next;}
              $5~/VMW_S/&&$6~/ENABLED/{vmw=acc;if(vmw~/^$/)vmw="S";next;}
              $5~/VMW_P1/&&$6~/ENABLED/{vmw=acc;if(vmw~/^$/)vmw="P1";next;}
              $5~/VMW_P2/&&$6~/ENABLED/{vmw=acc;if(vmw~/^$/)vmw="P2";next;}
              $5~/VMW_P3/&&$6~/ENABLED/{vmw=acc;if(vmw~/^$/)vmw="P3";next;}
              $5~/VMW_P/&&$6~/ENABLED/{vmw=acc;if(vmw~/^$/)vmw="P";next;}
              $5~/VMW_WS6/&&$6~/ENABLED/{vmw=acc;if(vmw~/^$/)vmw="W6";next;}
              $5~/VMW_WS7/&&$6~/ENABLED/{vmw=acc;if(vmw~/^$/)vmw="W7";next;}
              $5~/VMW_W/&&$6~/ENABLED/{vmw=acc;if(vmw~/^$/)vmw="W";next;}
              $5~/VMW_RC/&&$6~/ENABLED/{vmw=acc;if(vmw~/^$/)vmw="C2";next;}
              $2~/VMW/&&$6~/ENABLED/{vmw=acc;if(vmw~/^$/)vmw=V;next;}

              $2~/XEN/&&$6~/ENABLED/{xen=acc;if(xen~/^$/)xen=V;next;}

              $0~/kvm/&&$2~/QEMU/&&$6~/ENABLED/{qemu=acc;if(qemu~/^$/)qemu=V;kvm=acc;if(kvm~/^$/)kvm=V;next;}
#              $0~/kvm/&&$6~/ENABLED/{kvm=acc;if(kvm~/^$/)kvm=V;next;}
              $2~/QEMU/&&$6~/ENABLED/{qemu=acc;if(qemu~/^$/)qemu=V;next;}

              END{
                 printf("%-30s | %-6s | %-4s %-4s %-4s %-4s | %-6s %-6s %-6s %-6s %-6s\n",
                     h, pm, cli, x11, vnc, rdp, kvm, qemu, vbox, vmw, xen);
              }
              '
	    ;;
	*)
	    1_pluginsEnumerate
	    ;;
    esac
else
    case "$_qcheck" in
	1)  
	    echo ""|awk -F';' '
              END{
                 printf("%-30s %-10s %-12s %-20s %-15s %-10s\n","Hostname","Plugin","Accelerator","Version","MAGIC-ID","State");
                 printf("--------------------------------------------------------------------------------------------------------\n");
              }
              '
	    ;;
	2)  
	    echo ""|awk -F';' '
              END{
                 printf("%-30s | %-6s | %-4s %-4s %-4s %-4s | %-6s %-6s %-6s %-6s %-6s\n",
                     "Hostname", "PM", "CLI", "X11", "VNC", "RDP", "KVM", "QEMU", "VBOX", "VMW", "XEN");
                 printf("-------------------------------+--------+---------------------+-----------------------------------\n");
              }
              '
	    ;;
    esac

    if [ "$C_TERSE" != "1" ];then
	printINFO 1 $LINENO $BASH_SOURCE 1 "Remote execution${RUSER:+ as \"$RUSER\"} on:${_ARGS}"
    fi

    case "$_qcheck" in
 	[12])  
	    _execStrg="ctys ${C_DARGS} -t cli -a create=l:${_MYLBL},cmd:${MYCALLNAME}%${_RARGS} ${RUSER:+-l $RUSER}"
	    _execStrg="$_execStrg -b 0,3 "
	    _execStrg="$_execStrg ${_ARGS}"
	    printFINALCALL 0  $LINENO $BASH_SOURCE "FINAL-CLI-CONSOLE:STARTER(${_label})" "${_execStrg}"
	    ${_execStrg}
	    ;;
	*)  
	    _execStrg="ctys ${C_DARGS} -t cli -a create=l:${_MYLBL},cmd:${MYCALLNAME}%${_RARGS} ${RUSER:+-l $RUSER} "
	    if [ "$C_TERSE" != "1" ];then
		_execStrg="$_execStrg -b 0,2 "
	    else
		_execStrg="$_execStrg -b 1,3 "
	    fi
	    _execStrg="$_execStrg ${_ARGS}"
	    printFINALCALL 0  $LINENO $BASH_SOURCE "FINAL-CLI-CONSOLE:STARTER(${_label})" "${_execStrg}"
	    ${_execStrg}
	    ;;
    esac
fi


