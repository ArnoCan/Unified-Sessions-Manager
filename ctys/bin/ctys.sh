#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_011
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
#  ctys
#
#AUTHOR:
AUTHOR="Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org"
#MAINTAINER:
MAINTAINER="Arno-Can Uestuensoez - acue_sf1@sourceforge.net"
#
#FULLNAME:
FULLNAME="Unified Sessions Manager"
#
#CALLFULLNAME:
CALLFULLNAME="Commutate To Your Session"
#
#LICENCE:
LICENCE=GPL3
#
#TYPE:
#  bash-script
#
#VERSION:
VERSION=01_11_011
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
MYCALLNAME0=${MYCALLNAME}
MYCALLNAME=${MYCALLNAME%.sh}
MYCALLPATH=`dirname $MYCALLPATHNAME`

#
#If a specific library is forced by the user
#
if [ -n "${CTYS_LIBPATH}" ];then
    MYLIBPATH=$CTYS_LIBPATH
    MYLIBEXECPATHNAME=${CTYS_LIBPATH}/bin/$MYCALLNAME0
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
MYLIBEXECPATHNAME=${MYLIBEXECPATHNAME%.sh}
MYLIBEXECPATHNAME=${MYLIBEXECPATHNAME}.sh

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

MYBOOTSTRAP=${MYBOOTSTRAP}/bootstrap.01.01.004.sh
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


#path to directory containing the default mapping db
if [ ! -d "${HOME}/.ctys/db/default" ];then
  echo "${MYCALLNAME}:$LINENO:ERROR:Missing standard directory:${HOME}/.ctys/db/default"
  echo "${MYCALLNAME}:$LINENO:ERROR:Has to be present at least, check your installation"
  exit 1

fi
DEFAULT_DBPATHLST=${DEFAULT_DBPATHLST:-$HOME/.ctys/db/default}

#path to directory containing the default mapping db
if [ -d "${MYCONFPATH}/db/default" ];then
    DEFAULT_DBPATHLST=${DEFAULT_DBPATHLST:-$MYCONFPATH/db/default}
fi


if [ ! -d "${HOME}/.ctys/groups" ];then
  echo "${MYCALLNAME}:$LINENO:ERROR:Missing standard directory:${HOME}/.ctys/groups"
  echo "${MYCALLNAME}:$LINENO:ERROR:Has to be present at least, check your installation"
  exit 1
fi

if [ ! -d "${MYCONFPATH}/groups" ];then
  echo "${MYCALLNAME}:$LINENO:ERROR:Missing standard directory:${MYCONFPATH}/groups"
  echo "${MYCALLNAME}:$LINENO:ERROR:Has to be present at least, check your installation"
  exit 1
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
DEFAULT_CTYS_MULTITYPE=${DEFAULT_CTYS_MULTITYPE:-DEFAULT}
DEFAULT_C_SCOPE=${DEFAULT_C_SCOPE:-USER}
DEFAULT_KILL_DELAY_POWEROFF=${DEFAULT_KILL_DELAY_POWEROFF:-20}
DEFAULT_LIST_CONTENT=${DEFAULT_LIST_CONTENT:-BOTH,TAB_TCP}


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
CTYS_MULTITYPE=${CTYS_MULTITYPE:-$DEFAULT_CTYS_MULTITYPE}
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
C_RESOLVER=${C_RESOLVER:-CHAIN};
C_SSH=1;
C_SSH_PSEUDOTTY=DEFAULT;
unset C_EXECLOCAL;
unset C_NOEXEC;
unset C_LISTSES;
unset C_TERSE;
C_PRINTINFO=0;


unset C_DISPLAY

unset C_WMC_DESK
unset C_MDESK;
 
unset C_GEOMETRY;
unset C_REMOTERESOLUTION;
unset C_FORCE;
unset C_ALLOWAMBIGIOUS;
#WNG=1;

unset R_HOSTS;
unset R_OPTS;
export R_OPTS="";
#unset R_TEXT;
unset X_OPTS;

#0=>off, 1=>on
export C_STACK=0;

#sub-task manager of *.VMSTACK-groupfile
#0=>off, 1=>on
C_STACKMASTER=0;

#Reuse parts of stack if active
#0=>off, 
#1=>check bottom, 
#2=>find topmost-only
C_STACKREUSE=0;


#ForwardAgent of SSH, default is NO. Setting to 1=>'-A'
unset C_AGNTFWD;

#0=>off, 1=>on
C_ASYNC=DEFAULT;

#0=>off, 1=>on
C_PARALLEL=DEFAULT;

#0=>off, 1=>on
C_CACHEDOP=DEFAULT;

#0=>off, 1=>on
C_CACHEDOPMEM=1;

#0=>off, 1=>on
C_CACHEKEEP=0;

#0=>off, 1=>on
C_CACHERAW=0;

#0=>off, 1=>on
C_CACHEONLY=0;

#0=>off, 1=>on
C_CACHEPROCESSED=0;

#0=>off, 1=>on
CALLERCACHEREUSE=;

#0=>off, 1=>on
C_CACHEAUTO=0;


#0=>off, 1=>on
C_NSCACHEONLY=0;


#0=>OFF
#1=>1.LOCAL and/or(if no local match)  2.REMOTE
#2=>LOCAL
#3=>REMOTE
C_NSCACHELOCATE=1;

#to be used for cache of all tools, if not set else
export DBPATHLST=${DBPATHLST:-$DEFAULT_DBPATHLST}


#Options for formatting text with "pr" when printing out the embedded help.
PR_OPTS=${PR_OPTS:--o 5 -l 76}

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
printDBG $S_BIN ${D_UI} $LINENO $BASH_SOURCE "<${0} ${*}>"
printDBG $S_BIN ${D_FLOW} $LINENO $BASH_SOURCE "<${MYUID}@${MYHOST}>"
printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "<PATH=${PATH}>"
printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "<LD_PLUGIN_PATH=${LD_PLUGIN_PATH}>"
printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "<RS_PREFIX_L=${RS_PREFIX_L}>"
printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "<RS_PREFIX_R=${RS_PREFIX_R}>"




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
. ${MYLIBPATH}/lib/groups.sh
. ${MYLIBPATH}/lib/network/network.sh



#########################################################################
#plugins - project specific commons and feature plugins                 #
#########################################################################


#These will be loaded in given path-order, units within the given
#directories are loaded in alphabetical order.
#There is one hard-coded exception for the CORE directory:

#
#CORE:
#
#  Units within CORE are just loaded and registered, but will not
#  be called for generic initialization. This is due to the design,
#  that core modules are hardcoded project specific libraries 
#  handeled as building blocks. 
#
#PLUGINPATHS=${MYINSTALLPATH}/plugins/CORE

#
#GENERIC:
#
#  Units within GENERIC perform common tasks gwhich span multiple plugins, but 
#  are frequently tied together. One example is the call of LIST, where normally 
#  all selected - as default ALL enabled - types will be listed and displayed in 
#  a unified manner.
#  Thus these calls are not scheduled as own jobs, but as calls/callbacks from
#  a generic dispatcher executed as remote controller.
#
#PLUGINPATHS=${PLUGINPATHS}:${MYINSTALLPATH}/plugins/GENERIC
PLUGINPATHS=${MYINSTALLPATH}/plugins/GENERIC

#
#HOSTs+VMs+GUESTs:
#
#  Whereas the remaining are seen as dynamic attached hooks representing
#  pluggable add-ons.
#
PLUGINPATHS=${PLUGINPATHS}:${MYINSTALLPATH}/plugins/HOSTs
PLUGINPATHS=${PLUGINPATHS}:${MYINSTALLPATH}/plugins/VMs
PLUGINPATHS=${PLUGINPATHS}:${MYINSTALLPATH}/plugins/PMs
PLUGINPATHS=${PLUGINPATHS}:${MYINSTALLPATH}/plugins/GUESTs

#
#The environment variable LD_PLUGIN_PATH is similiar to LD_LIBRARY_PATH,
#loading bash plugins.
#
LD_PLUGIN_PATH=${LD_PLUGIN_PATH}:${PLUGINPATHS}


########################################################################
#
#CLI processing - after basic debug options within "base"
#
########################################################################

_CLIARGS="`replaceMacro $*`"
if [ -z "${_CLIARGS// }" ];then
    ABORT=1;
    printERR $LINENO $BASH_SOURCE ${ABORT} "Cannot evaluate commandline args:\"${*}\""
    gotoHell $ABORT
fi
#_CLIARGS="$*"
printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_CLIARGS=\"$_CLIARGS\""


#
#Pre-fetch, whether checks for compatibility should be restrictive and terminating
#or more in a relay-manner, not ultimately due to various versions, configurations
#and installed components.
#
_t=`echo " $_CLIARGS "| sed -n 's/([^)]*)//g;/ -E /p'`
if [ -n "${_t}" ];then
    C_EXECLOCAL=1;
    printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:C_EXECLOCAL=$C_EXECLOCAL"
fi

#
#the quicky
_smast=`echo " ${_CLIARGS} "|sed -n 's/\.VMSTACK//p' `
if [ -n "$_smast" ];then
    C_STACKMASTER=1;
fi
printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:C_STACKMASTER=${C_STACKMASTER}"
printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_CLIARGS     =${_CLIARGS}"
printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_smast       =\"${_smast}\""



#
#  This function analyses an ARGV for occurance of "-t" option, gwhich 
#  is the type of session to be handeled. If not found the pre-set
#  default will be assumed.
#
#  Once the decision is made, the appropriate module will be loaded
#  by source-ing. Therefore the Name of the plugin will be returned to be 
#  "sourced" in global namespace.
#
#  The former approach of automatic sourcing all available modules during
#  startup will still be possible, when setting the environment variable
#  "CTYS_MULTITYPE". This is more flexible due to possibility of combined
#  and intermixed calls, but requires some "stripping" of the sources to
#  reduce resource requirements when loading multiple plugins. 
#
#  CTYS_MULTITYPE may contain ALL or a ":"/colon separated list with
#  plugins to be loaded.
#
#  However, the next version is planned to be reworked or written in Perl.
#  A scripting language at all seems to be most appropriate to this task.
#
_t=`echo " $_CLIARGS "| sed -n 's/([^)]*)//g;s/^.* -T/-T/;s/-T \([a-zA-Z0-9,]*[^ ]\).*$/\1/p'`
if [ -n "${_t}" ];then
    CTYS_MULTITYPE=`echo "${_t}"|tr '[:lower:]' '[:upper:]'`
    printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:CTYS_MULTITYPE=$CTYS_MULTITYPE"
fi

_ac=`echo " $_CLIARGS "| sed -n 's/([^)]*)//g;s/^.* -a/-a/;s/-a \([a-zA-Z0-9]*\)[= ].*$/\1/p'|tr '[:lower:]' '[:upper:]'`
_ac="${_ac// /}"
if [ -n "${_ac}" ];then
    printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_ac=$_ac"
    C_MODE=${_ac}
fi

if [ -z "${CTYS_MULTITYPE//*DEFAULT*/}" ];then
    _ty=`echo " $_CLIARGS "| sed -n 's/([^)]*)//g;s/^.* -t/-t/;s/-t \([a-zA-Z0-9]*\) .*$/\1/p'|tr '[:lower:]' '[:upper:]'`
    printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_ty=$_ty"
    if [ -n "${_ty// /}" ];then
	CTYS_MULTITYPE="${_ty}"
	case $_ac in
	    LIST|ENUMERATE|SHOW|INFO);;
	    *)C_SESSIONTYPE=${CTYS_MULTITYPE};;
	esac
    else
	case ${_ac// /} in
	    LIST|ENUMERATE|SHOW|INFO)CTYS_MULTITYPE=ALL;;
	esac
    fi
    printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:C_SESSIONTYPE=$C_SESSIONTYPE"
fi


#rework later, for now allows dumb clients.
#pre-fetch clientlocation for checks on pre-requisites.
C_CLIENTLOCATION=`cliGetOptValue "-L" ${_CLIARGS}`
case $C_CLIENTLOCATION in
    CF|CONNECTIONFORWARDING)C_CLIENTLOCATION="-L CONNECTIONFORWARDING";;
    CO|CLIENTONLY)C_CLIENTLOCATION="-L CLIENTONLY";;
    LO|LOCALONLY)C_CLIENTLOCATION="-L LOCALONLY";;
    *)C_CLIENTLOCATION="-L DISPLAYFORWARDING";;
esac
printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:C_CLIENTLOCATION=$C_CLIENTLOCATION"



#
#pre-fetch su-settings for initial plugin bootstrap
#
fetchSUaccessOpts ${_CLIARGS}

#
#Perform the initialization according and based on LD_PLUGIN_PATH.
#
MYROOTHOOK=${MYINSTALLPATH}/plugins/hook.sh
if [ ! -f "${MYROOTHOOK}" ];then 
    ABORT=2
    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing packages hook: hook=${MYROOTHOOK}"
    gotoHell ${ABORT}
fi
. ${MYROOTHOOK}
initPackages "${MYROOTHOOK}"

#################################################################################
#prepare execution                                                              #
#################################################################################

#The special case of handling local call without a execution-target.
#Exception is given, when "-l" option is present, than the 
#"missing execution-target" is virtually handeled as a seperate target,
#requiring explicit context options.
if [ "${_CLIARGS//-l/}" == "${_CLIARGS}" ];then
    orgArgs=$_CLIARGS
    printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:orgArgs=$orgArgs"
fi


#Therefore global arguments are superposed by more specific arguments in the 
#following order. The priotrity is as common given to:
#
# - For 1.:     first-wins => Environment could customize
# - Remaining:  last-wins  => Present Call-Options predominate
#
# 1. defaults - hardcoded or inherited from calling shell
# 2. global CLI options for client and server
# 3. globals call-option for call-target "... -- '(<remote-global>)'...":
#     - server
#     - client if executed remotely on server site (Display Forwarding)
# 4. target specific context-options of call:
#      "... -- '(<remote-global>)' <taget>'(<context-options>)'"
#
#=>Resulting in actual call options.
#
#...could be perfect, of course.
#
#fetch global options for all given nodes
fetchOptions LOCAL $_CLIARGS


#now do the remaining part manually
#shift $(( OPTIND - 1))

printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:remaining for fetchArguments:\$_CLIARGS=\"$_CLIARGS\"  OPTIND=${OPTIND}"
_CLIARGS=`echo "$_CLIARGS"|awk -v drop="$(( OPTIND - 1))" '{for(i=1;i<=NF;i++)if(i>drop)printf(" %s",$i);}'`
printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:remaining for fetchArguments:\$_CLIARGS=\"$_CLIARGS\""

#
#now the remote part =>
#

# After the "--" the first entry is global remote parameter for all
# remote sessions, when no hostname-prefix exists. This could be varied
# by host specific options.
#
# Example:
#
#   The following example shows three hosts, where each has a different 
#   debugging level.
#
#   First of all the debugging flag and level is not forward propagated,
#   and as common for all environment settings "the last wins".
#
#     "...-d 6 -- ( -d 3 ) host01 host02( -d 1) host02(-d 0)..."
#
#   So, the given scenario results in the following situation:
#
#     -> localhost:   -d 6          = -d 6
#     -> host01:      -d 3          = -d 3
#     -> host02:      -d 3 -> -d 1  = -d 1
#     -> host03:      -d 3 -> -d 0  = -d 0
#
#
if [ -n "$_CLIARGS" ];then
    fetchArguments $_CLIARGS
else
    if [ -n "${orgArgs}" ];then
	remain="`cliOptionsStrip KEEP '-d' -- ${orgArgs}`"
	if [ -n "${remain}" ];then
	    remain="(${remain})"
	fi
    fi
    fetchArguments "${remain}"
fi

printDBG $S_BIN ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME:Finalize execCalls"
#################################################################################
#Check whether remote execution requested                                       #
#################################################################################

if [ -z "${ABORT}" -a -z "${C_EXECLOCAL}" ];then
  #Prepare call array, by performing options-expansion/permutation/correlation, 
  #call grouping, and call ordering, and last but not least 
  #apply consistency checks.
  #
  buildExecCalls
fi

printDBG $S_BIN ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME:Process execCalls"

#################################################################################
#End of prerequisite-checks...                                                  #
#...commit for execution                                                        #
#################################################################################
if [ -n "${ABORT}" ]; then
  gotoHell ${ABORT}
fi


#################################################################################
#prepare tasks, evaluate CLI...                                                 #
#################################################################################
doExecCallsPrologue

CALLERCACHE="${CALLERCACHE:-$MYTMP/$CALLERJOBID}.${RANDOM}"
CALLERCACHEREUSE="${CALLERCACHEREUSE:-$CALLERCACHE}"
printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:CALLERCACHE     =${CALLERCACHE}"
printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:CALLERCACHEREUSE=${CALLERCACHEREUSE}"


printDBG $S_BIN ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME:Process execCalls"


if [ "${C_CACHEDOP}" == 1 -a "${C_CACHEONLY}" == 1 ];then
    cachereuseage=`getDateTimeOfInode ${CALLERCACHEREUSE}`;

    printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "LIFETIME            = ${SESSIONCACHEPERIOD}"
    printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "cachereuseage       = ${cachereuseage}"
    printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "DATETIME            = ${DATETIME}"
    printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "SESSIONCACHEPERIOD  = ${SESSIONCACHEPERIOD}"

    if [ "${C_CACHEAUTO}" == 1 ];then
	digCheckLocal
	if [ $? -eq 1 -a -n "${CTYS_SUBCALL}" ];then
 	    ABORT=2
	    printERR $LINENO $BASH_SOURCE ${ABORT} "AUTO is supported for local access only:R_HOSTS=\"${R_HOSTS}\""
	    gotoHell ${ABORT}
	fi
    fi

    if [ -f "${CALLERCACHEREUSE}" ];then
	if(( (DATETIME-cachereuseage)>SESSIONCACHEPERIOD ));then
	    if [ "${C_CACHEAUTO}" == 1 ];then
  		printWNG 1 $LINENO $BASH_SOURCE 0 "$FUNCNAME:INFO:Cache outdated:actual age=\"$((DATETIME-cachereuseage))\" seconds - outdated=\"${SESSIONCACHEPERIOD}\" seconds"
  		printWNG 1 $LINENO $BASH_SOURCE 0 "$FUNCNAME:INFO:Clear cache:${CALLERCACHEREUSE}"
		rm -f ${CALLERCACHEREUSE} 2>/dev/null
	    else
		ABORT=1;
  		printERR $LINENO $BASH_SOURCE 0 "$FUNCNAME:INFO:Cache outdated:actual age=\"$((DATETIME-cachereuseage))\" seconds - outdated=\"${SESSIONCACHEPERIOD}\" seconds"
		printERR $LINENO $BASH_SOURCE ${ABORT} "Rebuild cache, or use another TIMEOUT, or use AUTO"
		gotoHell ${ABORT}
	    fi
	fi
    else
	if [ "${C_CACHEAUTO}" == 1 ];then
  	    printWNG 1 $LINENO $BASH_SOURCE 0 "$FUNCNAME:INFO:Missing cache, will be rebuild:${CALLERCACHEREUSE}"
	else
	    ABORT=1;
  	    printERR $LINENO $BASH_SOURCE 0 "$FUNCNAME:INFO:Missing cache:${CALLERCACHEREUSE}"
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Rebuild cache, or use another TIMEOUT, or use AUTO"
	    gotoHell ${ABORT}
	fi
    fi

fi

printDBG $S_BIN ${D_UI} $LINENO $BASH_SOURCE "Use KERBEROS=${USE_KSU}"
printDBG $S_BIN ${D_UI} $LINENO $BASH_SOURCE "Use SUDO    =${USE_SUDO}"

#################################################################################
#execute call...                                                                #
#  ...handle calls from prepared array as resulting form buildExecCalls         #
#    ...on individual entities                                                  #
#      ...based on user+host                                                    #
#        ...by local and/or remote execution.                                   #
#################################################################################

    #doing this for collectors to support cache processing within EPILOGUE
if [ "${C_CACHEDOP}" == 1 -a "${C_CACHEONLY}" == 0 ];then
    doExecCalls|cat >"${CALLERCACHE}"
else
    doExecCalls
fi

#################################################################################
#postfix tasks...                                                               #
#################################################################################
doExecCallsEpilogue

#if plugin has not processed and removed it jet then just "cat" and remove it
if [ -s "${CALLERCACHE}" ];then
    printDBG $S_BIN ${D_UID} $LINENO $BASH_SOURCE "Cached results present"
    if [ "${C_CACHEPROCESSED}" == 0 ];then
	if [ -f "${CALLERCACHE}" ];then
	    printDBG $S_BIN ${D_UID} $LINENO $BASH_SOURCE "Use default for cached results"
	    cat "${CALLERCACHE}"
	else
	    printDBG $S_BIN ${D_UID} $LINENO $BASH_SOURCE "No cached output."
	fi
    fi
fi
if [ -f "${CALLERCACHE}" ];then
    if [ "${C_CACHEKEEP}" == 0 ];then
	printDBG $S_BIN ${D_UID} $LINENO $BASH_SOURCE "Clear temporary runtime cache"
	rm -f "${CALLERCACHE}"
    fi
fi

#################################################################################
#End of commutation...                                                          #
#...beeing here seems to be a successful task was done.                         #
#################################################################################
gotoHell 0 
