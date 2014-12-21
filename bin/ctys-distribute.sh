
########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_003
#
########################################################################
#
#     Copyright (C) 2009,2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
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
#  ctys-distribute.sh
#
#AUTHOR:
AUTHOR="Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org"
#
#FULLNAME:
FULLNAME="Unified Sessions Manager - remote distribution and installation"
#
#CALLFULLNAME:
CALLFULLNAME="ctys-distribute.sh"
#
#LICENCE:
LICENCE=GPL3
#
#TYPE:
#  sh-script
#
#VERSION:
VERSION=01_11_003
#DESCRIPTION:
#  Distribution script for automated remote instllation of ctys.
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

MYBOOTSTRAP=${MYBOOTSTRAP}/bootstrap.01.01.003.sh
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

argLst=;
while [ -n "$1" ];do
    case $1 in
	'-D')shift;
	    _doctrans=$1;
	    case "${_doctrans}" in
		0)
		    ;;
		1)
		    ;;
		2)
		    ;;
		*)
		    echo "$0:ERROR:-D ${_doctrans}" >&2
		    exit 1
		    ;;
	    esac
	    ;;

	'-F')shift;
	    FORCE=$1;
	    case $FORCE in
		1)FORCE=force;;
		2)FORCE=forceclean;;
		3)FORCE=forceall;;
		force|forceclean|forceall);;
		*)
		    echo "$0:ERROR:Unknown force flag:-F ${FORCE}" >&2
		    echo "$0:ERROR:(force|1):      force" >&2
		    echo "$0:ERROR:(forceclean|2): forceclean" >&2
		    echo "$0:ERROR:(forceall|3):   forceall" >&2
		    exit 1;;
	    esac
	    ;;

	'-l')shift;
	    RUSER=$1;
	    ;;

	'-M')shift;
	    MODE=$1;
	    ;;

	'-P')shift;
	    _pkg=$1;

	    case $_pkg in
		'UserHomeCopy')
		    INSTTYPE=UserHomeCopy;
		    ;;

		'UserHomeLinkonly')
		    INSTTYPE=UserHomeLinkonly;
#		    INSTDIR="${MYLIBPATH}";
		    LINKONLY="linkonly";
		    ;;

		'SharedAnyDirectory,'*)
		    INSTTYPE=SharedAnyDirectory;
		    INSTDIR="${_pkg/$INSTTYPE,}";
		    INSTDIR="${INSTDIR%%,*}";

		    LNKDIRTMP="${_pkg//*,}";
		    if [ "${LNKDIRTMP}" != "${INSTDIR}" ];then
			LNKDIR="${LNKDIRTMP}";
		    fi
 		    ;;

		'SharedAnyLinkonly,'*)
		    INSTTYPE=SharedAnyLinkonly;
		    INSTDIR="${_pkg/$INSTTYPE,}";
		    INSTDIR="${INSTDIR%%,*}";
		    LNKDIR="${_pkg//*,}";
		    LINKONLY="linkonly";
		    ;;

		'AnyDirectory,'*)
		    INSTTYPE=AnyDirectory;
		    INSTDIR="${_pkg/$INSTTYPE,}";
 		    INSTDIR="${INSTDIR%%,*}";
		    if [ -z "${INSTDIR}" ];then
			echo "ERROR:Missing installation target:\"$_pkg\"">&2
		    fi
 		    INSTDIR="${INSTDIR}";
# 		    INSTDIR="${INSTDIR}/ctys-$(${MYCALLPATH}/getCurCTYSRel.sh)";
		    LNKDIR=NONE;
		    KEYS="noconf"
 		    ;;

		*)
		    echo "ERROR:Unknown P-option:\"$_pkg\"">&2
		    exit 1;
		    ;;
	    esac
	    ;;

	'-d')shift;;

	'-H'|'--helpEx'|'-helpEx')shift;_HelpEx="${1:-$MYCALLNAME}";;
	'-h'|'--help'|'-help')_showToolHelp=1;;
	'-V')_printVersion=1;;
	'-X')C_TERSE=1;;

	'-'*)showToolHelp;
	    echo "ERROR:Unknow option:\"${1}\"">&2
	    exit 0
	    ;;
        *)TARGETLST="${TARGETLST} $1";;
    esac
    shift
done


if [ -z "${TARGETLST}" ];then
    TARGETLST=localhost
fi

if [ -n "${RUSER}" -a "${TARGETLST//@}" != "${TARGETLST}" ];then
    echo "ERROR:\"-l\" option and EMail style addresses \"<USER>@<HOST>\"">&2
    echo "ERROR:cannot be used intermixed.">&2
    echo "  RUSER     = ${RUSER}">&2
    echo "  TARGETLST = ${TARGETLST}">&2
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

TARGETLST=`fetchGroupMemberHosts ${TARGETLST}`
for i in ${TARGETLST};do
    if [ "${i}" == "localhost" ];then
	echo "##########################################";
	echo "${INSTTYPE}:${LINKONLY} ${FORCE}";
	echo "->INSTDIR=${INSTDIR}";
	echo "->LNKDIR=${LNKDIR:--}";
	echo "->target=$i";
	echo "##########################################";

	KEYS="${KEYS} ${LINKONLY} ${FORCE}"
	if [ -n "${LNKDIR}" ];then
	    KEYS="${KEYS} bindir=\"${LNKDIR}\""
	fi
	if [ -n "${INSTDIR}" ];then
	    KEYS="${KEYS} libdir=\"${INSTDIR}\""
	fi
	if [ -n "${_doctrans}" ];then
	    KEYS="${KEYS} DOCS=\"${_doctrans}\""
	fi
 	echo " ->KEYS=\"${KEYS}\""

	case "$INSTTYPE" in
	    'UserHomeCopy'|'UserHomeLinkonly'|'UserAnyDirectory'|'SharedAnyDirectory'|'SharedAnyLinkonly'|'AnyDirectory')
		echo " ->install"
		echo "   from  :\"$(dirname ${MYCALLPATH})\""
		echo "   with  :\"${MYCALLPATH}/ctys-install.sh ${KEYS}\""
		case "$INSTTYPE" in
		    'UserHomeCopy'|'UserHomeLinkonly'|'SharedAnyLinkonly')
			echo "   linkTo:\"${MYLIBPATH}\""
			;;
		esac
		"${MYCALLPATH}"/ctys-install.sh ${D_ARGS} ${KEYS}
		if [ -n "${MODE}" ];then
		    echo " ->chmod"
		    if [ -n "${INSTDIR}" ];then
    			chmod -R ${MODE} "${INSTDIR}"
		    else 
    			chmod -R ${MODE} "${HOME}/lib/ctys-$(${MYCALLPATH}/getCurCTYSRel.sh)"
		    fi
		fi
		;;

	    *)
		echo "ERROR:Unknown INSTTYPE=$INSTTYPE">&2
		echo "ERROR:Check \"-P\" option.">&2
		exit 1;;
	esac
    else
	echo "##########################################";
	echo "${INSTTYPE}:${LINKONLY} ${FORCE}";
	echo "->INSTDIR=${INSTDIR}";
	echo "->LNKDIR=${LNKDIR:--}";
	echo -n "->target=$i";
	if [ -n "${RUSER}" ];then
	    echo  " - RUSER=${RUSER}";
	    i="${RUSER}@${i}";
	    echo "  setting target=RUSER@target=$i";
	else
	    echo
	fi
	echo "##########################################";

	KEYS="${LINKONLY} ${FORCE}"
	if [ -n "${LNKDIR}" ];then
	    KEYS="${KEYS} bindir=\"${LNKDIR}\""
	fi
	if [ -n "${INSTDIR}" ];then
	    KEYS="${KEYS} libdir=\"${INSTDIR}\""
	fi
	if [ -n "${_doctrans}" ];then
	    KEYS="${KEYS} DOCS=\"${_doctrans}\""
	fi
 	echo " ->KEYS=\"${KEYS}\""

	case "$INSTTYPE" in
	    'SharedAnyLinkonly')
		echo " ->install"
		echo "   from:\"${i}:${INSTDIR}\""
		echo "   with:\"${i}:${INSTDIR}/bin/ctys-install.sh ${KEYS}\""
		ssh -X -t -t ${i} PATH=/usr/xpg4/bin:\$PATH\&\&"${INSTDIR}"/bin/ctys-install.sh  ${D_ARGS} ${KEYS}

		if [ -n "${MODE}" ];then
		    echo " ->chmod"

		    if [ -n "${INSTDIR}" ];then
			ssh -X -t -t ${i} chmod -R ${MODE} "${INSTDIR}"
		    else 
			ssh -X -t -t ${i} chmod -R ${MODE} "${HOME}/lib/ctys-$(${MYCALLPATH}/getCurCTYSRel.sh)"
		    fi
		fi
		;;

	    'UserHomeCopy'|'UserHomeLinkonly'|'SharedAnyDirectory'|'AnyDirectory')
		TMPTARGET="/tmp/\${USER}/ctys-$(${MYCALLPATH}/getCurCTYSRel.sh)"
 		echo " ->TMPTARGET=\"${TMPTARGET}\""
		if [ -z "${TMPTARGET}" ];then
		    echo "ERROR:Missing:TMPTARGET">&2
		    exit 1;
		fi
		case $FORCE in
		    2|forceclean)
			echo " ->clean"
			ssh -X -t -t ${i} rm -rf "${TMPTARGET}"\;
			;;
		esac
		echo " ->mkdir"
		ssh -X -t -t ${i} mkdir -p "${TMPTARGET}"
		echo " ->scp"
		echo "   from:\"${MYLIBPATH}\""
		echo "   to:  \"${TMPTARGET}\""
		scp -r ${MYLIBPATH}/* ${MYLIBPATH}/.[a-zA-Z0-9]* ${i}:"${TMPTARGET}"
		echo " ->install"
		echo "   from:\"${i}:${TMPTARGET}\""
		echo "   with:\"${TMPTARGET}/bin/ctys-install.sh ${KEYS}\""
		ssh -X -t -t ${i} PATH=/usr/xpg4/bin:\$PATH\&\&"${TMPTARGET}"/bin/ctys-install.sh  ${D_ARGS} ${KEYS}


		if [ -n "${MODE}" ];then
		    echo " ->chmod"

		    if [ -n "${INSTDIR}" ];then
			ssh -X -t -t ${i} chmod -R ${MODE} "${INSTDIR}"
		    else 
			ssh -X -t -t ${i} chmod -R ${MODE} "${HOME}/lib/ctys-$(${MYCALLPATH}/getCurCTYSRel.sh)"
		    fi
		fi
		;;

	    *)
		echo "ERROR:Unknown INSTTYPE=$INSTTYPE">&2
		echo "ERROR:Check \"-P\" option.">&2
		exit 1;;
	esac

    fi
done

