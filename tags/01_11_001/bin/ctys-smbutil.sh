#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_09_001
#
########################################################################
#
#     Copyright (C) 2007,2008 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
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
FULLNAME="ctys-smbutil.sh"
#
#CALLFULLNAME:
CALLFULLNAME="CTYS SMB Utility"
#
#LICENCE:
LICENCE=GPL3
#
#TYPE:
#  bash-script
#
#VERSION:
VERSION=01_09_001
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


#
#Verify OS support
#
case ${MYOS} in
    Linux);;
    FreeBSD|OpenBSD);;
    *)
        printINFO 1 $LINENO $BASH_SOURCE 1 "${MYCALLNAME} is not supported on ${MYOS}"
	gotoHell 0
	;;
esac


if [ "${*}" != "${*//-X/}" ];then
    C_TERSE=1
fi


. ${MYLIBPATH}/lib/help/help.sh

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
case "${MYOS}" in
    Linux)
	CTYS_HOST=`getPathName       $LINENO $BASH_SOURCE ERROR host      /usr/bin`
	CTYS_NMBLOOKUP=`getPathName  $LINENO $BASH_SOURCE ERROR nmblookup /usr/bin`
	;;
    FreeBSD|OpenBSD)
	CTYS_HOST=`getPathName       $LINENO $BASH_SOURCE ERROR host      /usr/sbin`
	CTYS_NMBLOOKUP=`getPathName  $LINENO $BASH_SOURCE ERROR nmblookup /usr/local/bin`
	;;
    *)  
 	printERR $LINENO $BASH_SOURCE 1 "Unsupported OS=$MYOS"
 	printERR $LINENO $BASH_SOURCE 1 "Might fail, but continue..."
	;;
esac

_ARGS=;
_ARGSCALL=$*;
_RUSER0=;


argLst=;
while [ -n "$1" ];do
    case $1 in
	'-d')shift;;

	'-i')_ip=1;;
	'-n')_name=1;;

	'-l')shift;CTYS_NETACCOUNT=$1;;
	'-L')shift;_RUSER0=$1;;
	'-R')shift;_RHOSTS0=$1;;

	'-r')shift;
            arg=${1//,/ }
            for a in $arg;do
		case $a in
		    [rR][eE][vV][eE][rR][sS][eE]|[rR]|-)_reverse=1;;
		    [pP][iI][nN][gG]*)
			_ping=1;
			PCNT=${a#*:};
                        if [ -n "$PCNT" -a "${a//:/}" != "${a}"  ];then
			    if [ "${PCNT//\%/}" != "${PCNT}" ];then
				PTIME=${PCNT#*%}                          
				PCNT=${PCNT%\%*}
			    else
				PTIME=1
			    fi
			else
			    PTIME=1
			    PCNT=1
			fi
			printDBG $S_BIN ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:PCNT =$PCNT"
			printDBG $S_BIN ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:PTIME=$PTIME"
			;;
		    *)
			ABORT=1;
			printERR $LINENO $BASH_SOURCE ${ABORT} "Unknown RuntimeState=$1"
			gotoHell ${ABORT}
		esac
	    done
	    ;;

	'-H'|'--helpEx'|'-helpEx')shift;_HelpEx="${1:-$MYCALLNAME}";;
	'-h'|'--help'|'-help')_showToolHelp=1;;
	'-V')_printVersion=1;;
	'-X')C_TERSE=1;;

        -*)
	    ABORT=1;
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Unkown option:\"$1\""
	    gotoHell ${ABORT}
	    ;;

        *)  #server list
	    argLst="${argLst} $1";
	    argLst="${argLst## }";
	    argLst="${argLst%% }";
	    printDBG $S_BIN ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:argLst=$argLst"
	    ;;
    esac
    shift
done

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



#set defaults

CTYS_NETACCOUNT=${CTYS_NETACCOUNT:-$USER}

[ -z "$_ip" -a -z "$_name" ]&&_name=1;

if 
[ -n "$_ip" -a -n "$_name" -a -n "$_terse" ];then
    ABORT=1;
    printERR $LINENO $BASH_SOURCE ${ABORT} "In combination with TERSE(\"-X\") only IP(\"-i\") or NAME(\"-n\") is supported."
    gotoHell ${ABORT}
fi



export CALLFILE=$0
function check4ret () {
  RET=$(($?));
  if [ "${RET}" != "0" ] ; then
    PREFIX="ERROR:RET(${RET}):${CALLFILE:-LINENO}($1) ${2:-}";shift 2;
    echo "${PREFIX}";
    until [ -z "$1" ];
    do
      echo "${PREFIX}:$1"; shift;
    done
    if [ ${CONTINUE} -gt ${RET} ] ; then 
      echo "${PREFIX}:CONTINUE=${CONTINUE}";
    else
      exit ${RET};
    fi
  fi;
  return ${RET}
}


DOMAIN=`uname -n`;DOMAIN=${DOMAIN#*.}
check4ret $LINENO "" "DOMAIN=${DOMAIN}"

DOMAINLIST=`${CTYS_NMBLOOKUP} -T -d w:0,i:0 ${DOMAIN} '*'`;
check4ret $LINENO "" "DOMAINLIST=${DOMAINLIST}"

DOMAINLIST=`echo "${DOMAINLIST}"|sed -n -e 's/\(^[^,]*\),.*$/\1/p'`
check4ret $LINENO "" "sed:DOMAINLIST=${DOMAINLIST}"




#build raw list
if [ -n "$_name" ];then
    DOMAINLIST=`echo ${DOMAINLIST}`
else
    DOMAINLIST=`for i in ${DOMAINLIST};do ${CTYS_HOST} $i;done|awk '{printf(" %s",$NF);}'`
fi
#unique sort applies when names are displayed for hosts with multiple interfaces
DOMAINLIST=`for i in ${DOMAINLIST};do echo $i;done|sort -u`


#apply constraints

#ping
if [ -n "$_ping" ];then
    [ -z "$_terse" ]&&echo "=> ping-check"
    TMPLST=;
    idx=0;
    success=0;
    for i in ${DOMAINLIST};do
	printDBG $S_BIN ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:i=$i"
	ping -c ${PCNT:-1} -w ${PTIME:-1} ${i} 2>&1 >/dev/null
	if [ $? -eq 0 ];then           
	    [ -z "$_reverse" ]&&TMPLST="${TMPLST} ${i}"
	    ((success++))
	    [ -z "$_terse" ]&&echo -n "+"
	else
	    [ -n "$_reverse" ]&&TMPLST="${TMPLST} ${i}"
	    [ -z "$_terse" ]&&echo -n "-"
	fi
	((idx++))
	if((idx%10==0));then echo -n "|";fi
	if((idx%50==0));then echo;fi
    done
    echo
    [ -z "$_terse" ]&&echo "  => checked=$idx"
    [ -z "$_terse" ]&&echo "  => success=$success"
    [ -z "$_terse" ]&&echo 
    DOMAINLIST=${TMPLST};
fi

#display results
if [ -n "$_terse" ];then
    echo ${DOMAINLIST}
else
    idx=0;
    if [ -n "$_name" -a -n "$_ip" ];then
	for i in ${DOMAINLIST};do
            IP=`${CTYS_HOST} $i|awk '{printf("%s",$NF);}'`
	    printf "%04d   %-15s %s\n" $idx $IP $i
	    ((idx++))
	done
    else
	for i in ${DOMAINLIST};do
	    printf "%04d   %s\n" $idx $i
	    ((idx++))
	done
    fi
fi


gotoHell 0

