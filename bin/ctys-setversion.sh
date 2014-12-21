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
#  ctys-setversion.sh
#
#AUTHOR:
AUTHOR="Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org"
#
#FULLNAME:
FULLNAME="Unified Sessions Manager - remote execution"
#
#CALLFULLNAME:
CALLFULLNAME="ctys-setversion.sh"
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

_nTarget=;

while [ -n "$1" ];do
    case $1 in
 	'--version='*)_nVERSION=${1#*=};_nVERSION=${_nVERSION// /};_nVERSION=${_nVERSION//./_};;
 	'--variant='*)_nVARIANT=${1#*=};_nVARIANT=${_nVARIANT// /};;
 	'--target='*) _nTarget=${1#*=};;

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



if [ -n "$_nTarget" ];then
    _tDIR="${_nTarget%/*}";

    if [ ! -d ];then
	ABORT=1
	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing directory:<${_tDIR}>"
	gotoHell ${ABORT}
    fi

    #LOC
    LOC=`find ${MYINSTALLPATH} -type f -name '*[!~]'  -name '[!0-9][!0-9]*' -exec cat {} \;|wc -l`

    #LOC-NET
    LOCNET=`find ${MYINSTALLPATH} -type f -name '*[!~]'  -name '[!0-9][!0-9]*' -exec cat {} \;|sed -n '/^ *#.*/d;/^$/d;p'|wc -l`

    LOD1=`find ${MYINSTALLPATH}/help ${MYINSTALLPATH}/doc -type f -name '*[!~]'  -exec cat {} \;|wc -l`

    #LOD
    MYDOCSOURCE="`dirname ${MYINSTALLPATH}`/ctys-manual.${INSTVERSION}"
    if [ ! -d "${MYDOCSOURCE}" ];then
	MYDOCSOURCE=;
	if [ -f "${MYDOCSOURCE}" ];then
	    LOD2=`wc -l ${MYDOCSOURCE}`
	else
	    LOD2=0;
	fi
    else
	LOD2=`find ${MYDOCSOURCE} -type f -name '*.tex'  -exec cat {} \;|wc -l`
    fi

    LOD=$((LOD1+LOD2));

    echo "###">"${_nTarget}"
    echo "DATE=${DATE}">>"${_nTarget}"
    echo "TIME=${TIME}">>"${_nTarget}"
    echo "###">>"${_nTarget}"
    echo "LOC=\"${LOC// }\"">>"${_nTarget}"
    echo "LOCNET=\"${LOCNET// }\"">>"${_nTarget}"
    echo "LOD=\"${LOD// }\"">>"${_nTarget}"
    echo "VERSION=\"${_nVERSION}\"">>"${_nTarget}"
    echo "CTYSREL=\"${_nVERSION}\"">>"${_nTarget}"
    echo "CTYSVARIANT=\"${_nVARIANT}\"">>"${_nTarget}"

    exit 0
fi


#
#
#
CTYSVERSGEN=${MYCONFPATH}/versinfo.gen.sh

#
#
#
CTYSGETREL=${MYLIBEXECPATH}/getCurCTYSRel.sh
if [ -n "${_nVERSION}" ];then
    if [ -n "${CTYSGETREL}" ];then
	sed -i 's/CTYS_RELEASE=..*/CTYS_RELEASE='"${_nVERSION}"'/g' ${CTYSGETREL}
    else
	ABORT=1;
	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing:\"${CTYSGETREL}\""
	gotoHell ${ABORT}
    fi

    if [ -n "${CTYSVERSGEN}" ];then
	sed -i 's/CTYSREL=.*$/CTYSREL='"${_nVERSION}"'/g' ${CTYSVERSGEN}
	sed -i 's/VERSION=.*$/VERSION='"${_nVERSION}"'/g' ${CTYSVERSGEN}
    fi

fi



#
#
#
CTYSGETVAR=${MYLIBEXECPATH}/getCurCTYSVariant.sh
if [ -n "${_nVARIANT}" ];then
    if [ -n "${CTYSGETREL}" ];then
	sed -i 's/CTYS_VARIANT=.*$/CTYS_VARIANT='"${_nVARIANT}"'/g' ${CTYSGETVAR}
    else
	ABORT=1;
	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing:\"${CTYSGETVAR}\""
	gotoHell ${ABORT}
    fi

    if [ -n "${CTYSVERSGEN}" ];then
	sed -i 's/CTYSVARIANT=.*$/CTYSVARIANT='"${_nVARIANT}"'/g' ${CTYSVERSGEN}
    fi

fi



