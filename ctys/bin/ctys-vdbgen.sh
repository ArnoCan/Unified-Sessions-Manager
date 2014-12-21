#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_017
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
#  ctys-vdbgen.sh
#
#AUTHOR:
AUTHOR="Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org"
#
#FULLNAME:
FULLNAME="Unified Sessions Manager"
#
#CALLFULLNAME:
CALLFULLNAME="VM mapping DB generator"
#
#LICENCE:
LICENCE=GPL3
#
#TYPE:
#  bash-script
#
#VERSION:
VERSION=01_11_017
#DESCRIPTION:
#  Main untility of project ctys for generation of nameservice DB.
#
#EXAMPLE:
#
#PARAMETERS:
#
#  refer to online help "-h" and/or "-H"
#
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
    if [ "${*}" != "${*//-V/}" ];then
	echo -n ${VERSION}
	exit 0
    fi
fi

#path to directory containing the default mapping db
if [ -d "${HOME}/.ctys/db/default" ];then
    DEFAULT_DBPATHLST=${DEFAULT_DBPATHLST:-$HOME/.ctys/db/default}
fi

#path to directory containing the default mapping db
if [ -d "${MYCONFPATH}/db/default" ];then
    DEFAULT_DBPATHLST=${DEFAULT_DBPATHLST:-$HOME/conf/db/default}
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
PLUGINPATHS=${MYINSTALLPATH}/plugins/CORE

#
#HOSTs+VMs+GUESTs:
#
#  Whereas the remaining are seen as dynamic attached hooks representing
#  pluggable add-ons.
#
PLUGINPATHS=${PLUGINPATHS}:${MYINSTALLPATH}/plugins/HOSTs
PLUGINPATHS=${PLUGINPATHS}:${MYINSTALLPATH}/plugins/VMs
PLUGINPATHS=${PLUGINPATHS}:${MYINSTALLPATH}/plugins/GUESTs

#
#The environment variable LD_PLUGIN_PATH is similiar to LD_LIBRARY_PATH,
#loading bash plugins.
#
LD_PLUGIN_PATH=${LD_PLUGIN_PATH}:${PLUGINPATHS}


_cliorg=${*};

case " ${*} " in
    *" -h "*|*" -help "*|*" --help "*|"  ")
	showToolHelp
	gotoHell 0
	;;
	*' -H '*)shift;printHelpEx "${1:-$MYCALLNAME}";gotoHell 0;;
esac

case " ${*} " in
    *" -V "*)
	printVersion
	gotoHell 0
	;;
esac

echo
echo "Prepare execution-call:"
echo

#
#
_t=`echo "$*"| sed -n 's/(.*)//g;s/^.* -T/-T/;s/-T \([a-zA-Z0-9:]*[^ ]\).*$/\1/p'`
if [ -n "${_t}" ];then
    CTYS_MULTITYPE=`echo "${_t}"|tr '[:lower:]' '[:upper:]'`
    printDBG $S_BIN ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:CTYS_MULTITYPE=$CTYS_MULTITYPE"
fi
if [ -z "${CTYS_MULTITYPE}" ];then
    _t=`echo "$*"| sed -n 's/^.* -t/-t/;s/-t \([a-zA-Z0-9]*\) .*$/\1/p'`
    if [ -n "${_t}" ];then
	C_SESSIONTYPE=`echo "${_t}"|tr '[:lower:]' '[:upper:]'`
    else
        C_SESSIONTYPE=${DEFAULT_C_SESSIONTYPE}
    fi
    CTYS_MULTITYPE=${C_SESSIONTYPE}
    printDBG $S_BIN ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:C_SESSIONTYPE=$C_SESSIONTYPE"
fi

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


progressFilter=0;




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

NEWARGS=;

_splitted=1;
#unset _splitted;

#unset _splitted_keep_files=1;
unset _splitted_keep_files;

tmax=${CTYS_VDBGEN_PARTARGETS}

argLst=;
while [ -n "$1" ];do
    if [ -z "${_ARGS}" ];then
	case $1 in
	    '--base='*)
		BASEPATHLST="${1#*=}";
		printDBG $S_BIN ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:BASEPATHLST=$BASEPATHLST"
		;;

	    '--cacheDB='*)
		_dbfilepath="${1#*=}";
		;;


	    "--append")
		_appendmode=1;
		;;

	    "--replace")
		unset _appendmode;
		_replacemode=1;
		;;

	    "--stdio")
		_stdiomode=1;
		;;

	    "--filecontext")
		filecontext=1;
		;;

	    "--no-splitted")
		unset _splitted;
		;;

	    "--progressall")
		progressFilter=1;
		;;

	    "--progress")
		progressFilter=2;
		;;

	    "--splitted")
		_splitted=1;
		;;

	    "--splitted-keep-files")
		_splitted_keep_files=1;
		;;

	    '--threads='*)
		tmax="${1#*=}";
		;;

	    "--scan-all-states")
		_scanall=1;
		;;


	    "-t")
		shift;_tOpt=$1;
		;;

	    "-T")
		shift;_TOpt=$1;
		;;

	    "-b")
		shift;_bOpt=$1;
		;;

	    "-c")
		shift;_cOpt=$1;
		;;

	    "-C")
		shift;_COpt=$1;
		;;


	    '-d')shift;;
	    '-H'|'--helpEx'|'-helpEx')shift;_HelpEx="${1:-$MYCALLNAME}";;
	    '-h'|'--help'|'-help')_showToolHelp=1;;
	    '-V')_printVersion=1;;
	    '-X')C_TERSE=1;_BYPASSARGS="${_BYPASSARGS} $1";;

            '--')_ARGS=" ";;
	    '-'*)
		_BYPASSARGS="${_BYPASSARGS} $1";
		case $1 in
 		    '-b')shift;_BYPASSARGS="${_BYPASSARGS} $1";_SET_B=$(echo "$1"|tr 'a-z' 'A-Z');;

 		    '-a'|'-A'|'-b'|'-d'|'-D'|'-c'|'-C'|'-F'|'-g'|'-j')shift;_BYPASSARGS="${_BYPASSARGS} $1";;
		    '-p'|'-r'|'-s'|'-S'|'-k'|'-l'|'-L'|'-M'|'-o'|'-O')shift;_BYPASSARGS="${_BYPASSARGS} $1";;
		    '-t'|'-T'|'-W'|'-x'|'-z'|'-Z')                    shift;_BYPASSARGS="${_BYPASSARGS} $1";;

		    '-H'|'-E'|'-f'|'-h'|'-n'|'-v'|'-V'|'-w'|'-X'|'-y'|'Y'|'-z');;
		esac
		;;
#             *)_ARGS="${_ARGS} $1";;
	esac
	shift
    else
        _ARGS="${_ARGS} $1";
	shift
    fi
done

if [ -z "${_ARGS}" ];then
    ABORT=1;
    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing arguments: <target-hosts>"
    printERR $LINENO $BASH_SOURCE ${ABORT} "Do not forget the double-hyphen seperator. "
    printERR $LINENO $BASH_SOURCE ${ABORT} "  ${0} .... -- <target-hosts>"
    printERR $LINENO $BASH_SOURCE ${ABORT} "For local scan use localhost:"
    printERR $LINENO $BASH_SOURCE ${ABORT} "  ${0} .... -- localhost"
    printERR $LINENO $BASH_SOURCE ${ABORT} "  ${0} .... -- scanUser@localhost"
    gotoHell ${ABORT}

fi


###############
#
#cacheDB
#
if [ -z "$_dbfilepath" ];then
    if [ -n "${DEFAULT_VDBGEN_DB}" ];then
	_dbfilepath=${DEFAULT_VDBGEN_DB}
	echo "Require DB-PATH,        USE: DEFAULT_VDBGEN_DB=\"${_dbfilepath}\""
    else
	if [ -n "${DEFAULT_DBPATHLST}" ];then
	    _dbfilepath=${DEFAULT_DBPATHLST}
	    echo "Require DB-PATH,        USE: DEFAULT_DBPATHLST=\"${_dbfilepath}\""
	fi
    fi
fi
if [ -n "$_dbfilepath" ];then
    echo "Require DB-PATH,        USE: -o => \"${_dbfilepath}\""
fi
if [ -z "$_dbfilepath" ];then
    ABORT=1;
    printERR $LINENO $BASH_SOURCE ${ABORT} "At least default for DB-file required."
    printERR $LINENO $BASH_SOURCE ${ABORT} "Use:"
    printERR $LINENO $BASH_SOURCE ${ABORT} "."
    printERR $LINENO $BASH_SOURCE ${ABORT} "prio1: -> \"-p <db-dir-path>\""
    printERR $LINENO $BASH_SOURCE ${ABORT} "prio2: -> export DEFAULT_DBPATHLST=..."
    printERR $LINENO $BASH_SOURCE ${ABORT} "."
    printERR $LINENO $BASH_SOURCE ${ABORT} "The value should be common for the whole set of"
    printERR $LINENO $BASH_SOURCE ${ABORT} "ctys-tools, due to supporting the most generic link"
    printERR $LINENO $BASH_SOURCE ${ABORT} "between PMs and VMs/GuestOSs."
    gotoHell ${ABORT}
fi

if [ ! -d "${_dbfilepath}" ];then
    if [ ! -d "${_dbfilepath%/*}" ];then
	ABORT=1;
	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing BASE directory, required to be present."
	printERR $LINENO $BASH_SOURCE ${ABORT} "  _dbfilepath=${_dbfilepath%/*}"
	gotoHell ${ABORT}
    fi

    if [ -f "${_dbfilepath%/*}/enum.fdb" ];then
	ABORT=1;
	printERR $LINENO $BASH_SOURCE ${ABORT} "The choosen BASE directory is a cacheDB directory itself,"
	printERR $LINENO $BASH_SOURCE ${ABORT} "nested databases are not supported."
	printERR $LINENO $BASH_SOURCE ${ABORT} "Present cacheDB:"
	printERR $LINENO $BASH_SOURCE ${ABORT} "  _dbfilepath=${_dbfilepath%/*}"
	printERR $LINENO $BASH_SOURCE ${ABORT} "  ENUM-DB    =${_dbfilepath%/*}/enum.fdb"
	gotoHell ${ABORT}
    fi

    if [ ! -d "${_dbfilepath}" ];then
	echo "Require DB-PATH      CREATE: \"${_dbfilepath##*/}\""
	mkdir ${_dbfilepath}
    fi
fi


if [ ! -d "$_dbfilepath" ];then
    ABORT=1;
    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing directory, required to be present."
    printERR $LINENO $BASH_SOURCE ${ABORT} "  _dbfilepath=${_dbfilepath}"
    gotoHell ${ABORT}
fi
_dbfilepath=$_dbfilepath/enum.fdb



#################
#
#TARGETS
#
if [ -z "${_ARGS}" ];then
    _ARGS=localhost
fi
if [ -n "${RUSER}" -a "${_ARGS//@}" != "${_ARGS}" ];then
    echo "ERROR:\"-l\" option and EMail style addresses \"<USER>@<HOST>\"">&2
    echo "ERROR:cannot be used intermixed.">&2
    echo "  RUSER     = ${RUSER}">&2
    echo "  _ARGS = ${_ARGS}">&2
    exit 1
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



################
#
#append/replace
#
if [ "${_appendmode}" == 1 ];then
    echo "APPEND mode                : ON(1)"
else
    if [ "${_replacemode}" == 1 ];then
	echo "APPEND mode off => REPLACE : OFF(0)"
	echo "REPLACE mode on            : ON(1)"
    else
	_replacemode=1;
	echo "IMPLICIT REPLACE mode on   : ON(1)"
	if [ -e "${_dbfilepath}" ];then
	    ABORT=1;
	    printERR $LINENO $BASH_SOURCE ${ABORT} "\"IMPLICIT REPLACE\" is only allowed when \"enum.fdb\" is absent,"
	    printERR $LINENO $BASH_SOURCE ${ABORT} "if you actually want to replace, choose \"--replace\""
	    gotoHell ${ABORT}
	fi
    fi
fi



################
#
#stdio
#
if [ "${_stdiomode}" == 1 ];then
    echo "STDIO mode on              : ON(1)"
else
    echo "STDIO mode off             : OFF(0)"
fi




################
#
#filecontext
#
if [ "${filecontext}" == 1  ];then
    echo "Set for Filecontext     ON: "
fi




#
#progressall
#
if [ "${progressFilter}" == 1  ];then
    echo "Set Progress Trace All  ON: DEFAULT=\"\""
    echo "  Requires on targets     :\"(-d 2,s:16:w:0,p)\""
fi



#
#progress
#
if [ "${progressFilter}" == 2  ];then
    echo "Set Progress Final      ON: DEFAULT=\"\""
    echo "  Requires on targets     :\"(-d 2,s:16,w:0,p)\""
fi


#
#
#
if [ -z "${filecontext}" ];then

    if [ -n "${_tOpt}" ];then
	echo "Set TYPE scope          ADD: DEFAULT=\"-t ${_tOpt}\""
#Reminder:	NEWARGS="-t $_tOpt  ${NEWARGS}"
    else
	echo "Set TYPE scope          ADD: DEFAULT=\"-t ALL\""
        _tOpt=ALL
#Reminder:	NEWARGS="-t ALL  ${NEWARGS}"
    fi


    if [ -n "${_TOpt}" ];then
	echo "Preload TYPE set        ADD: DEFAULT=\"-T ${_TOpt}\""
	NEWARGS="-T $_TOpt  ${NEWARGS}"
    else
	echo "Preload TYPE set        ADD: DEFAULT=\"-T ALL\""
	NEWARGS="-T ALL  ${NEWARGS}"
    fi

    if [ -n "${_bOpt}" ];then
	echo "Should speed-up         ADD: DEFAULT=\"-b ${_bOpt} \""
#Reminder: 	NEWARGS="-t $_bOpt  ${NEWARGS}"
    else
 	echo "For splitted operations ADD: DEFAULT=\"-b sync,seq \""
#Reminder:  	NEWARGS="-b sync,seq  ${NEWARGS}"
    fi

    if [ -n "${_cOpt}" ];then
	echo "Nameservice cache       OFF: DEFAULT=\"-c ${_cOpt} \""
	NEWARGS="-c $_cOpt  ${NEWARGS}"
    else
	echo "Nameservice cache       OFF: DEFAULT=\"-c off \""
	NEWARGS="-c off  ${NEWARGS}"
    fi

    if [ -n "${_COpt}" ];then
	echo "Data cache              OFF: DEFAULT=\"-C ${_cOpt} \""
	NEWARGS="-C $_COpt  ${NEWARGS}"
    else
	echo "Data cache              OFF: DEFAULT=\"-C off \""
	NEWARGS="-C off  ${NEWARGS}"
    fi
else
    echo "filecontext is set, ignoring: -c, .-C, -b, -T, -t"
fi

echo


_t=`echo "${_BYPASSARGS}"| sed -n '/[eE][nN][uU][mM][eE][rR][aA][tT][eE]/p'`
if [ -z "${_t}" ];then
    _srchpath=;
    echo -n "Resulting ENUMERATE     ADD: DEFAULT=\""
    if [ -z "${BASEPATHLST}" ];then
	_srcpath="${DEFAULT_ENUM_BASE}";
    else
	_srcpath="${BASEPATHLST}";
    fi

    if [ -n "${_srcpath}" ];then
	_srcpath="${_srcpath} ${BASEAPPENDLST}";
    else
	_srcpath="${BASEAPPENDLST}";
    fi
    _srcpath="${_srcpath//  / }";

#Reminder:for OBSD    _srcpath="`echo ${_srcpath}|sed -n 's/^ *\([^ ].*[^ ]\) *$/\1/;s/ \+/\%/g;p'`";
    _srcpath="`echo ${_srcpath}|sed -n 's/^ *\([^ ].*[^ ]\) *$/\1/;s/  */%/g;p'`";

    if [ -z "${filecontext}" ];then
	NEWARGS="-a enumerate=matchvstat:${_scanall:+all%}active%disabled%empty,machine${_srcpath:+,b:$_srcpath} ${NEWARGS}"
    else
	NEWARGS=" ${NEWARGS}"
    fi

    echo "\"${NEWARGS}\""
fi



#
NEWARGS=" ${NEWARGS} ${_BYPASSARGS}"
NEWARGS=" ${NEWARGS} "


#prepare stats
if [ -n "${_appendmode}" -a -z "$_stdiomode" ];then
    preappend=`wc -l ${_dbfilepath}`
    preappend=${preappend%% *}
else
    preappend=0;
fi

_ssumtime=`getCurTime`;
echo
{
    echo "-> generate DB(may take a while)..."
    echo "-----------------------------------"
    echo "START:${_ssumtime}"
    echo "------"
    echo
}
{
    if [ -n "$_stdiomode" ];then
	echo "RESULTING CALL:\"${MYLIBEXECPATH}/ctys.sh -t ${_tOpt} ${NEWARGS} ${_ARGS} \""
	${MYLIBEXECPATH}/ctys.sh -t ${_tOpt} ${NEWARGS} ${_ARGS}
    else
	if [ -z "$_splitted" -o -n "${_bOpt}" ];then
	    if [ -n "${_bOpt}" ];then
 		NEWARGS="-b ${_bOpt}  ${NEWARGS}"
	    else
 		NEWARGS="-b sync,par  ${NEWARGS}"
	    fi
	    if [ "${progressFilter}" -ne 0 ];then
		_ARGS="-- '(-d 2,s:16:w:0,p)' ${_ARGS}"
	    fi
 	    echo "RESULTING CALL:\"${MYLIBEXECPATH}/ctys.sh -t ${_tOpt} ${NEWARGS}${_appendmode:+>} ${_ARGS} >${_dbfilepath}\""
	    if [ -n "${_appendmode}" ];then
		${MYLIBEXECPATH}/ctys.sh -t ${_tOpt} ${NEWARGS} ${_ARGS}>${_dbfilepath}.tmp
		fetchedRecsRaw=$(cat ${_dbfilepath}.tmp|wc -l)
		fetchedRecsUnique=$(cat ${_dbfilepath}.tmp|sort -u|wc -l)
		sort -u ${_dbfilepath}.tmp >>${_dbfilepath}
	    else
		${MYLIBEXECPATH}/ctys.sh -t ${_tOpt} ${NEWARGS} ${_ARGS}>${_dbfilepath}.tmp
		fetchedRecsRaw=$(cat ${_dbfilepath}.tmp|wc -l)
		sort -u ${_dbfilepath}.tmp >${_dbfilepath}
		fetchedRecsUnique=$(cat ${_dbfilepath}|wc -l)
	    fi
	else
 	    NEWARGS="-b sync,seq  ${NEWARGS}"
	    TARGETS=$( ${MYLIBEXECPATH}/ctys-groups.sh -X -m 5 ${_ARGS});
	    if [ -z "${TARGETS}" ];then
		TARGETS="${_ARGS}";
	    else
		_m5=1;
	    fi
	    idx=0;
	    tcnt=0;

	    OFS=$IFS
	    if [ "$_m5" == 1 ];then
	        IFS="
"
   	    fi
	    NFS=$IFS
	    for rtarget in ${TARGETS} LAST;do
 		IFS=$OFS 
		if [ -z "$rtarget" ];then
		    continue
		fi
		if [ "$_m5" == 1 ];then
		    rtarget="${rtarget#ctys}"
		fi
		if [ "$rtarget" != LAST ];then
		    let idx++;
		    rf="$( IFS=$OFS fetchGroupMemberHosts ${rtarget}).${idx}.${DATETIME}"
		    rf="$(  fetchGroupMemberHosts ${rtarget}).${idx}.${DATETIME}"
		    rf="${rf// /}"
		    if [ "${progressFilter}" -ne 0 -a "${rtarget#--}" == "${rtarget}" ];then
			rtarget="-- '(-d 2,s:16:w:0,p)' ${rtarget}"
		    fi
		    _call=" ${MYLIBEXECPATH}/ctys.sh -t $_tOpt ${NEWARGS} ${rtarget} >${_dbfilepath}.${rf}.tmp  "
		    printFINALCALL 1  $LINENO $BASH_SOURCE "FINAL-REMOTE-CALL:" "${_call}"
		    eval ${_call} &
		    let tcnt++;

		    #4TEST:try it semi-permanent, may not really harm!
		    sleep 1
		fi
		if [ $tcnt -ge $tmax -o "$rtarget" == LAST ];then
		    wait
		    let tcnt=tcnt-tmax;
		fi
 		IFS=$NFS 
	    done

	    #wait for fclose???!!!
	    sleep 1

 	    IFS=$OFS
	    if [ -n "${_replacemode}" ];then
		rm -f ${_dbfilepath}
	    fi
	    rm -f ${_dbfilepath}.tmp

	    for fl in ${_dbfilepath}.*.${DATETIME}.tmp;do
		cat ${fl} >>${_dbfilepath}.tmp
		if [ -z "$_splitted_keep_files" ];then
		    rm -f ${fl}
		fi
	    done

	    #wait for fclose???!!!
	    sleep 1

	    fetchedRecsRaw=$(cat ${_dbfilepath}.tmp|wc -l)
 	    if [ -n "${_appendmode}" ];then
		fetchedRecsUnique=$(cat ${_dbfilepath}.tmp|sort -u|wc -l)
		sort -u ${_dbfilepath}.tmp >>${_dbfilepath}
	    else
		sort -u ${_dbfilepath}.tmp >${_dbfilepath}
		fetchedRecsUnique=$(cat ${_dbfilepath}|wc -l)
	    fi
	fi
    fi
} 2>&1|\
if [ -z "$_stdiomode" ];then
  awk -F'-' -v prog="$progressFilter"  '
    BEGIN{
        head=1;
        idx=0;
      }
    $1~/^RESULTING/{
        printf(".\n");
        printf("%s\n\n",$0);
        next;
      }
    head==1{
        head=0;
        printf("%05s|%-35s|%-10s|%-8s|%-8s|%-8s\n","Index","Machine","SType","Start","End","Duration");
        printf("-----+-----------------------------------+----------+--------+--------+--------\n");
      }
    $1~/:scan4sessions:START$/{
      if(prog==1){
        x=$1;
        gsub("^[^:]*:","",x);
        gsub(":.*","",x);
        printf("%05s|%-35s|%-10s|%-8s|%-8s|%-8s\n",idx++,x,$(NF-3),$(NF-2),$(NF-1),$NF);
      }
      next;
    }
    $1~/:scan4sessions:FINISH$/{
      if(prog==1||(prog==2&&$(NF-3)!="machine")){
        x=$1;
        gsub("^[^:]*:","",x);
        gsub(":.*","",x);
        printf("%05s|%-35s|%-10s|%-8s|%-8s|%-8s\n",idx++,x,$(NF-3),$(NF-2),$(NF-1),$NF);
      }
      next;
    }
    {print;}
    END{
      print "";
    }'
else
  cat
fi

_fsumtime=`getCurTime`;
_sumduration=`getDiffTime $_ssumtime $_fsumtime`;
echo "------"
echo "END:${_fsumtime}"
echo "DURATION:${_sumduration}"
echo "-----------------------------------"
echo "RET=$?"
echo "-----------------------------------"
echo
if [ -z "$_stdiomode" ];then
    final=`wc -l ${_dbfilepath}`
    final=${final%% *};
    echo "Cached data:"
    echo
    if [ -n "${_appendmode}" ];then
	delta=$((final-preappend));
	echo "  Mode:                    APPEND"
	echo "  Pre-Appended:            ${preappend} records"
	echo "  Appended:                ${delta} records"
	echo "  Fetched Records Raw:     ${fetchedRecsRaw} records"
	echo "  Fetched Records Unique:  ${fetchedRecsUnique} records"
	echo "  Final:                   ${final} records"
    else
	echo "  Mode:                    REPLACE"
	echo "  Fetched Records Raw:     ${fetchedRecsRaw} records"
	echo "  Fetched Records Unique:  ${fetchedRecsUnique} records"
	echo "  Created:                 ${final} records"
    fi
    echo
    echo "-----------------------------------"
fi
echo "   ...finished."
