#!/bin/bash
########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@users.sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_018
#
########################################################################
#
#     Copyright (C) 2010,2011 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
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
#  ctys-xdg.sh
#
#AUTHOR:
AUTHOR="Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org"
#
#FULLNAME:
FULLNAME="Unified Sessions Manager - Free Desktop Utility"
#
#CALLFULLNAME:
CALLFULLNAME="ctys-xdg.sh"
#
#LICENCE:
LICENCE=GPL3
#
#TYPE:
#  sh-script
#
#VERSION:
VERSION=01_11_018
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
    Linux);;
#     SunOS)
# 	export PATH=/usr/xpg4/bin:/opt/sfw/bin:/usr/sbin:/usr/bin:/usr/openwin/bin:$PATH
# 	;;
    *)
	ABORT=1;
	printERR $LINENO $BASH_SOURCE ${ABORT} "Current OS is not supported:\"${MYOS}\""
	gotoHell ${ABORT}
	;;
esac



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



_BYPASSARGS=;
GEO=;

_mGUI=;
_mNOUSER=;
_mCreate=;
_mCancel=;
_mScope=${MENU_DEFAULT_SCOPE:-PRIVATE};
MENU_DEFAULT_PRIVATE_LST="${MENU_DEFAULT_PRIVATE_LST:-$HOME/.config/menus:$HOME/.local/share/applications:$HOME/.local/share/desktop-directories}"
_mEdit=${MENU_DEFAULT_PRIVATE_LST};
SRCX=;
_mEditCall=;
_mFORCE=;

while [ -n "$1" ];do
    case $1 in
 	'--menu-create')   _mCreate=1;;
 	'--menu-create='*) _mCreate=1;
 	                   SRCX=${1#*=}
                           ;;

 	'--menu-cancel')   _mCancel=1;;
 	'--menu-cancel='*) _mCancel=1;
 	                   SRCX=${1#*=}
                           ;;

 	'-e')              
                           _mEditCall=1;
                           if [ -z "${2}" -o "${2#-}" != "${2}" ];then
                                _mEditX=${_mEdit//:/ }
    	                   else
		                 shift;
		                 for i in ${1//%/ };do
		                     if [ -d "$i" -o -f "$i" ];then
			                 _mEditX="$_mEditX $i "
		                     else
			                 _mEditX="$_mEditX $(matchFirstFile $i . ${_mEdit//:/ })"
		                     fi
		                done
	                   fi
 	                   if [ -z "${_mEditX}" ];then
		                ABORT=1;
		                printERR $LINENO $BASH_SOURCE ${ABORT} "Edit requires either a list or defaults"
		                gotoHell ${ABORT}
	                   fi
			   _mEdit=$_mEditX
                           ;;

 	'--menu-edit='*)   _mEditCall=1;
 	                   _mEditX=${1#*=}
                           if [ -z "${_mEditX}" -o "${_mEditX#-}" != "${_mEditX}" ];then
                                _edit=${_mEditX//:/ }
    	                   else
		                 for i in ${_mEditX//%/ };do
		                     if [ -d "$i" -o -f "$i" ];then
			                 _edit="$_edit $i "
		                     else
			                 _edit="$_edit $(matchFirstFile $i . ${_mEdit})"
		                     fi
		                done
	                   fi
 	                   if [ -z "${_edit}" ];then
		                ABORT=1;
		                printERR $LINENO $BASH_SOURCE ${ABORT} "Edit requires either a list or defaults"
		                gotoHell ${ABORT}
	                   fi
			   _mEdit=$_edit			   
                           ;;

 	'--menu-gui')     _mGUI=1;;

 	'--menu-private') _mScope=PRIVATE;;
 	'--menu-private'*) _mScope=PRIVATE;
 	                   TARGETX=${1#*=}
                           ;;

 	'--user')         _mNOUSER=;;
 	'--no-user')      _mNOUSER=1;;

 	'--menu-shared')  _mScope=SHARED;;
 	'--menu-shared'*) _mScope=SHARED;
 	                   TARGETX=${1#*=}
                           ;;

 	'--menu-edit')     case ${_mScope} in
 	                       PRIVATE) _mEdit=${MENU_DEFAULT_PRIVATE_LST//:/ };;
 	                       SHARED)  _mEdit=${MENU_DEFAULT_SHARED_LST//:/ };;
 	                       *)       _mEdit=${MENU_DEFAULT_SHARED_LST//:/ };;
                           esac
                           ;;

 	'--force')         _mFORCE=0;;

	'-g')              shift;GEO=$1;
                           GEO=$(getGeometry  -g  ${GEO});
                           GEO="--geometry=${GEO}";
                           ;;

	'-d')shift;;

	'-H'|'--helpEx'|'-helpEx')shift;_HelpEx="${1:-$MYCALLNAME}";;
	'-h'|'--help'|'-help')_showToolHelp=1;;
	'-V')_printVersion=1;;
	'-X')C_TERSE=1;_BYPASSARGS="${_BYPASSARGS} $1";;
        *)
	    ABORT=1
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Unknown option:<${1}>"
	    gotoHell ${ABORT}
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


function chek4Install () {
    case "${MYWM}" in
	GNOME);;

	KDE)
	    if [ -z "$_mFORCE" ];then
		if [ "${_mGUI}" == 1 ];then
		    local _KDESTRG=;
		    _KDESTRG="${_KDESTRG}\nCurrent version is verified for GNOME only."
		    _KDESTRG="${_KDESTRG}\nKDE works and is partly verified, but"
		    _KDESTRG="${_KDESTRG}\nsome drawbacks still exist."
		    _KDESTRG="${_KDESTRG}\nThe icons are frequently causing some problems,"
		    _KDESTRG="${_KDESTRG}\nshifted due priorities."
		    _KDESTRG="${_KDESTRG}\n"
		    _KDESTRG="${_KDESTRG}\nDo you want to proceed?"
		    _KDESTRG="${_KDESTRG}\n"

		    guiCONFIRM 1 "${_KDESTRG}"
		    if [ $? -ne 0 ];then
			exit 1;
		    fi
		else
		    ABORT=1
		    printERR $LINENO $BASH_SOURCE ${ABORT} "Current version is verified for GNOME only."
		    printERR $LINENO $BASH_SOURCE ${ABORT} "KDE works and is partly verified, but"
		    printERR $LINENO $BASH_SOURCE ${ABORT} "some drawbacks still exist."
		    printERR $LINENO $BASH_SOURCE ${ABORT} "The icons are frequently causing some problems,"
		    printERR $LINENO $BASH_SOURCE ${ABORT} "shifted due priorities."
		    printERR $LINENO $BASH_SOURCE ${ABORT} "If you want to proceed use option \"--force\"."
		    gotoHell ${ABORT}

		fi
	    fi
	    ;;

	*)
	    if [ -z "$_mFORCE" ];then
		ABORT=1
		printERR $LINENO $BASH_SOURCE ${ABORT} "Cannot detect running windows manager."
		printERR $LINENO $BASH_SOURCE ${ABORT} "Current version is verified for GNOME only."
		printERR $LINENO $BASH_SOURCE ${ABORT} "Others may work - and partly do."
		printERR $LINENO $BASH_SOURCE ${ABORT} "If you want to proceed use option \"--force\""
		gotoHell ${ABORT}

	    fi
	    ;;
    esac
}


function finalMessage () {
    printINFO 1 $LINENO $BASH_SOURCE 0 "Do not forget to logout+login for fresh initialization!"
}



#
#
#
if [ -n "$_mCreate" -a "$_mScope" == PRIVATE ];then
    #
    chek4Install
    #
    TMPX=/tmp/ctys-tmp4convert.${DATETIME}.$$
    TARGETX=${TARGETX:-$HOME}
    SRCX=${SRCX:-$MYCONFPATH/xdg.d/HOME}
    if [ ! -e "${TARGETX}" ];then
	ABORT=1
	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing HOME($TARGETX) directory, check your environment!"
	gotoHell ${ABORT}
    fi
    if [ "${TARGETX// /}" == "/" ];then
	ABORT=1
	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing HOME($TARGETX) directory is \"/\","
	printERR $LINENO $BASH_SOURCE ${ABORT} "continue manually if you really want that!"
	gotoHell ${ABORT}
    fi
    if [ ! -e "${TARGETX}/.config" ];then
	ABORT=1
	printINFO 1 $LINENO $BASH_SOURCE ${ABORT} "Creating initial \"${TARGETX}/.config\"!"
	mkdir -p "${TARGETX}/.config"
    fi
    [ ! -e "${TARGETX}/.config/menus" ]&&mkdir -p "${TARGETX}/.config/menus"
    [ ! -e "${TARGETX}/.config/menus/applications-merged" ]&&mkdir -p "${TARGETX}/.config/menus/applications-merged"
    if [ ! -e "${TARGETX}/.local" ];then
	ABORT=1
	printINFO 1 $LINENO $BASH_SOURCE ${ABORT} "Creating initial \"${TARGETX}/.local\"!"
	mkdir -p "${TARGETX}/.local"
    fi
    [ -e "${TMPX}" ]&&rm -rf ${TMPX}
    ${CP} -r ${SRCX}  ${TMPX}
    find ${TMPX} -type f \( -name '*.menu' -o -name '*.desktop' \)   -exec sed -i 's@_MYHOME_@'"${TARGETX}"'@g' {} \;
    ${CP} -r ${TMPX}/* ${TMPX}/.???*  ${TARGETX}
    rm -rf ${TMPX}
    finalMessage
    exit 0
fi



#
#
if [ -n "$_mCreate" -a "$_mScope" == SHARED ];then
    #
    chek4Install
    #
    TMPX=/tmp/ctys-tmp4convert.${DATETIME}.$$
	TARGETX=${TARGETX:-$MYLIBPATH}
#     if [ -n "${_mNOUSER}" ];then
# 	TARGETX=${TARGETX:-$MYLIBPATH}
#     else
# 	TARGETX=${TARGETX:-/}
#     fi
    SRCX=${SRCX:-$MYCONFPATH/xdg.d/SHARED}
    if [ ! -e "/etc/xdg/menus" ];then
	ABORT=1
	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing \"/etc/xdg/menus\"!"
	gotoHell ${ABORT}
    fi
    if [ ! -e "/usr/share/applications" ];then
	ABORT=1
	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing \"/usr/share/applications\"!"
	gotoHell ${ABORT}
    fi
    if [ ! -e "/usr/share/desktop-directories" ];then
	ABORT=1
	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing \"/usr/share/desktop-directories\"!"
	gotoHell ${ABORT}
    fi
    [ -e "${TMPX}" ]&&rm -rf ${TMPX}
    ${CP} -r ${SRCX}  ${TMPX}
    find ${TMPX} -type f \( -name '*.menu' -o -name '*.desktop' \)   -exec sed -i 's@_MYHOME_@'"${TARGETX}"'@g' {} \;

    if [ -n "${_mNOUSER}" ];then
        ${CP} -r ${TMPX}/*  /
    else
        ${CP} -r ${TMPX}/* ${TMPX}/.???*  ${TARGETX}
    fi
    rm -rf ${TMPX}
    finalMessage
    exit 0
fi



#
#
#
if [ -n "$_mCancel" -a "$_mScope" == PRIVATE ];then
    if [ "${_mGUI}" == 1 ];then
	guiCONFIRM 1 "Are you sure to remove the UnifiedSessionsManager menus?"
	if [ $? -ne 0 ];then
	    exit 1;
	fi
    fi
    #
    TMPX=/tmp/ctys-tmp4convert.${DATETIME}.$$
    TARGETX=${HOME}
    SRCX=${SRCX:-$MYCONFPATH/xdg.d/HOME}
    for i in $(find ${SRCX} -type f );do
	echo $i
	_tx="${TARGETX}/${i#$SRCX/}"
	if [ -e "${_tx}" ];then
	    echo "Remove:${_tx}"
	    rm -f "${_tx}"
	fi
    done
    finalMessage
    exit 0
fi



#
#
#
if [ -n "$_mCancel" -a "$_mScope" == SHARED ];then
    if [ "${_mGUI}" == 1 ];then
	guiCONFIRM 1 "Are you sure to remove the UnifiedSessionsManager menus?"
	if [ $? -ne 0 ];then
	    exit 1;
	fi
    fi
    #
    TMPX=/tmp/ctys-tmp4convert.${DATETIME}.$$
    TARGETX=${TARGETX:-/}
    SRCX=${SRCX:-$MYCONFPATH/xdg.d/SHARED}
    for i in $(find ${SRCX} -type f );do
	echo $i
	_tx="${TARGETX}/${i#$SRCX/}"
	if [ -e "${_tx}" ];then
	    echo "Remove:${_tx}"
	    rm -f "${_tx}"
	fi
    done
    finalMessage
    exit 0
fi

#
#
#
if [ -n "${_mEditCall}" -a  -n "$_mEdit" ];then
    _mEditX=;
    if [ "${_mEdit//%/}" != "${_mEdit}" ];then
	_lst="${_mEdit//%/ }"
    else
	_lst="${_mEdit//:/ }"
    fi
    for ix in ${_lst};do
	if [ -d "${ix}" -o  -e "${ix}" ];then
 	    _mEditX="$_mEditX $ix"
	fi
    done
    $CTYS_MENUEDIT ${GEO} ${_mEditX//%/ }
    exit $?
fi

exit 1
