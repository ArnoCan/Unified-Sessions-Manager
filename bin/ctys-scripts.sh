#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_009
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
FULLNAME="ctys-scripts.sh"
#
#CALLFULLNAME:
CALLFULLNAME="CTYS Scripts Utility"
#
#LICENCE:
LICENCE=GPL3
#
#TYPE:
#  bash-script
#
#VERSION:
VERSION=01_11_009
#DESCRIPTION:
#  See manual.
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

MYSCRIPTPATH=${MYSCRIPTPATH:-$MYCONFPATH/scripts}
if [ ! -d "${MYSCRIPTPATH}" ];then
  echo "${MYCALLNAME}:$LINENO:ERROR:Missing:MYSCRIPTPATH=${MYSCRIPTPATH}"
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
. ${MYLIBPATH}/lib/misc.sh

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


. ${MYLIBPATH}/lib/help/help.sh
. ${MYLIBPATH}/lib/network/network.sh
. ${MYLIBPATH}/lib/groups.sh

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
_RUSER0=;
_RHOSTS0=;
_ARGS=;
_ARGSCALL=$*;
TREELEVEL=;

_listscripts=;
_display=;

argLst=;
while [ -n "$1" ];do
    case $1 in
	'-e')
	    if [ -z "${2}" -o "${2#-}" != "${2}" ];then
		_edit="${CTYS_SCRIPT_PATH//:/ }"
	    else
		shift;
		for i in ${*//%/ };do
		    if [ "${1#-}" != "${1}" ];then
			continue
  		    fi
		    if [ -d "$i" -o -f "$i" ];then
			_edit="$_edit $i "
		    else
			_edit="$_edit $(matchFirstFile $i . ${CTYS_SCRIPT_PATH})"
		    fi
		    shift
		done
	    fi
	    if [ -z "${_edit}" ];then
		ABORT=1;
		printERR $LINENO $BASH_SOURCE ${ABORT} "Edit requires either a list or CTYS_SCRIPT_PATH"
		gotoHell ${ABORT}
	    fi
            ;;

	'-m')
	    case "$2" in
		[0])
		    shift;_display=${1};
		    ;;
		'')
		    _display=0;
		    ;;
		*)
		    _display=0;
		    ;;
	    esac
            ;;

	'-l')_listscripts=1;;

	'-d')shift;;

	'-H'|'--helpEx'|'-helpEx')shift;_HelpEx="${1:-$MYCALLNAME}";;
	'-h'|'--help'|'-help')_showToolHelp=1;;
	'-V')_printVersion=1;;
	'-X')C_TERSE=1;;

        -*)
	    ABORT=1;
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Unkown option:\"$1\""
	    gotoHell ${ABORT}
	    ;;

        *)  #macro list
	    argLst="${argLst} $1";
	    argLst="${argLst## }";
	    argLst="${argLst%% }";
	    argLst="${argLst//  / }";
	    argLst=${argLst// /\%};
	    printDBG $S_BIN ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:argLst=$argLst"
	    ;;
    esac
    shift;
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


if [ -z "$_display" -a -z "$_listscripts" ];then
    _listscripts=1;
#    _atom=1;
#    _combined=1;
fi

#set for later list "-l"
_mySearchPath="${CTYS_SCRIPT_PATH}";


if [ -n "$_edit" ];then
    if [  -z "$CTYS_SCRIPTEDIT" ];then
	ABORT=2
	printERR $LINENO $BASH_SOURCE $ABORT "Cannot evaluate Emacs for edit."
	exit $?

    fi
    [ -z "${_edit}" ]&&_edit=" ."

    _editX=;
    for i in ${_edit//%/ };do
	if [ -e $i ];then
	    _editX="$_editX $i"
	fi
    done

    $CTYS_SCRIPTEDIT ${_editX//%/ }&sleep 1
    exit $?
fi


function listScripts () {
    if [ -z "$C_TERSE" ];then
	echo 
	echo "---------------------------------------------------------"
	echo "available files - Standalone Macro Files"
	echo "---------------------------------------------------------"

	echo
	echo "Current macros files of:"
	echo
	splitPath 20 "SearchPath" "${_mySearchPath}"
	echo
	echo
    fi

    for i in ${_mySearchPath//:/ };do
	if [ -z "$C_TERSE" ];then
	    echo "$i:"
	fi
	if [ -d "${i}" ];then
	    for fx in ${i}/*;do
		if [ -n "${argLst}" ];then
		    for chk in "${argLst}";do
			if [ "${fx}" == "${fx//$chk/}" ];then
			    _IGTMP=1
			fi
		    done
		    if [ -n "$_IGTMP" ];then
			unset _IGTMP;
			continue
		    fi
		fi

		if [ -z "$C_TERSE" ];then
		    echo " ->${fx##*/}"
		else
		    echo "${fx##*/}"
		fi
	    done
	fi
	if [ -z "$C_TERSE" ];then
	    echo
	fi
    done
}


if [ -n "$_listscripts" ];then
    listScripts
fi

if [ -n "$_display" ];then
    if [ -z "$C_TERSE" ];then
	echo "----------------------------------------"
	echo "Script Sources:"
	echo "----------------------------------------"
    fi

    case $_display in
	0)
	    LOFFSET0="    "
	    LOFFSET1="       "

	    if [ -z "${argLst}" ];then
		argLst=$(C_TERSE=1 listScripts)
	    fi

	    for j in ${argLst};do
		for i in ${_mySearchPath//:/ };do
		    if [ -e "$i/$j" ];then
			if [ -z "$C_TERSE" ];then
			    echo "${LOFFSET0}---------------------------------------------------------"
			    echo "${LOFFSET0}current selected file:"
			    echo "${LOFFSET0} => $i/$j"
			    echo "${LOFFSET0}---------------------------------------------------------"
			fi
			cat $i/$j| awk -v lo="${LOFFSET1}" '{print lo"   "$0;}'
			echo
		    fi
		done
	    done
	    ;;
	*)
	    printERR $LINENO $BASH_SOURCE 1 "Unknown value:${_display}"
	    exit $?
	    ;;
    esac

    exit $?
fi

