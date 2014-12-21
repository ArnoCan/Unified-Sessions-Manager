#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_10_013
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


shopt -s nullglob
shopt -s extglob

#
#Set some common basic definitions.
#

#if not yet initialized, but pre-defined, than set it
if [ -z "${MYLIBPATH}" ];then
    MYLIBPATH=${CTYS_LIBPATH}
fi

#moment of truth, where it is required to be set
if [ ! -d "${MYLIBPATH}" ];then
  echo "${MYCALLNAME}:$LINENO:ERROR:Missing:MYLIBPATH=${MYLIBPATH}"
  echo "${MYCALLNAME}:$LINENO:ERROR:Required to point to the root of the"
  echo "${MYCALLNAME}:$LINENO:ERROR:library to be used."
  exit 1
fi

#make it absolute
if [ -n "${MYLIBPATH##/*}" ];then
    cd "${MYLIBPATH}"
    MYLIBPATH=${PWD}
    cd -
fi

MYLANG=${MYLANG:-$LANG}
case ${MYLANG} in
    de*|De*|DE*) MYLANG=de;;
    en*|En*|EN*) MYLANG=en;;
    *)           MYLANG=en;;
esac


if [ -z "${MYMANPATH}" ];then
MYDOCPATH=${MYDOCPATH:-$MYLIBPATH/doc/$MYLANG}
    case ${MYLANG} in
	de)
	    MYMANPATH=${MYLIBPATH}/doc/de/man:${MYLIBPATH}/doc/en/man
	    ;;
	en)
	    MYMANPATH=${MYLIBPATH}/doc/en/man:${MYLIBPATH}/doc/de/man
	    ;;
	*)
	    MYLANG=en
	    MYMANPATH=${MYLIBPATH}/doc/en/man:${MYLIBPATH}/doc/de/man
	    ;;
    esac
fi

MYDOCBASE=${MYDOCBASE:-$MYLIBPATH/doc}
if [ ! -d "${MYDOCBASE}" ];then
    echo "${MYCALLNAME}:$LINENO:ERROR:Missing:MYDOCBASE=${MYDOCBASE}"
    exit 1
fi

MYDOCPATH=${MYDOCPATH:-$MYDOCBASE/$MYLANG}
if [ ! -d "${MYDOCPATH}" ];then
    echo "${MYCALLNAME}:$LINENO:ERROR:Missing:MYDOCPATH=${MYDOCPATH}"
    exit 1
fi

MYDOCSEARCH=${MYDOCPATH}
#For now
if [ "${MYDOCPATH//\/en/}" == "${MYDOCPATH}" ];then
    MYDOCSEARCH=${MYDOCSEARCH}:${MYDOCBASE}/en
fi
if [ "${MYDOCPATH//\/de/}" == "${MYDOCPATH}" ];then
    MYDOCSEARCH=${MYDOCSEARCH}:${MYDOCBASE}/de
fi


foundmp=;
for mp in ${MYMANPATH//:/ };do
    [ -d "${mp}" ]&&foundmp=1;
done
if [ -z "${foundmp}" ];then
  echo "${MYCALLNAME}:$LINENO:ERROR:Missing:MYMANPATH=${MYMANPATH}"
  exit 1
fi

MYHELPPATH=${MYHELPPATH:-$MYLIBPATH/help/$MYLANG}
if [ ! -d "${MYHELPPATH}" ];then
  echo "${MYCALLNAME}:$LINENO:ERROR:Missing:MYHELPPATH=${MYHELPPATH}"
  exit 1
fi

MYCONFPATH=${MYCONFPATH:-$MYLIBPATH/conf/ctys}
if [ ! -d "${MYCONFPATH}" ];then
  echo "${MYCALLNAME}:$LINENO:ERROR:Missing:MYCONFPATH=${MYCONFPATH}"
  exit 1
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

MYADDONSPATH=${MYADDONSPATH:-$MYLIBPATH/addons}
if [ ! -d "${MYADDONSPATH}" ];then
  echo "${MYCALLNAME}:$LINENO:ERROR:Missing:MYADDONSPATH=${MYADDONSPATH}"
  exit 1
fi

MYINSTALLPATH= #Value is assigned in base. Symbolic links are replaced by target

_myLIBNAME_base="${BASH_SOURCE}"
_myLIBVERS_base="01.10.013"



#The only compromise for bootstrap, calling it explicit 
#from anywhere. 
function baseRegisterLib () {
  libManInfoAdd "${_myLIBNAME_base}" "${_myLIBVERS_base}"
}

################################################################
#               Default definitions - 1/2                      #
################################################################
MYLIBEXECPATH=${MYLIBEXECPATH:-`dirname $0`}

MYHOST=`uname -n`

#Basic OS info for variant decisions.
MYOS=${MYOS:-`$MYLIBEXECPATH/getCurOS.sh`}
MYOSREL=${MYOSREL:-`$MYLIBEXECPATH/getCurOSRel.sh`}
MYDIST=${MYDIST:-`$MYLIBEXECPATH/getCurDistribution.sh`}
MYREL=${MYREL:-`$MYLIBEXECPATH/getCurRelease.sh`}
MYARCH=${MYARCH:-`$MYLIBEXECPATH/getCurArch.sh`}

MYUID=$USER
MYGID=`$MYLIBEXECPATH/getCurGID.sh`
MYPID=$$
MYPPID=$PPID

DATE=`date +"%Y.%m.%d"`
TIME=`date +"%H:%M:%S"`
HOUR=${TIME%%:*};
#DATETIME=`date +"%Y%m%d%H%M%S"`
DATETIME="${DATE//.}${TIME//:}"
DAYOFWEEK=`date +"%u"`


#
#For now 16bit-array, to be used in level-mode or match-mode.
#

#
#levels
#
export      D_UI=$((2#1))
export    D_FLOW=$((2#10))
export     D_UID=$((2#100))
export    D_DATA=$((2#1000))
export   D_MAINT=$((2#10000))
export   D_FRAME=$((2#100000))
export     D_SYS=$((2#1000000))
export    D_STAT=$((2#10000000000000))
export     D_TST=$((2#100000000000000))
export    D_BULK=$((2#1000000000000000))

#
#subsystems
#
export    S_CONF=$((2#1))
export     S_BIN=$((2#10))
export     S_LIB=$((2#100))
export    S_CORE=$((2#1000))
export     S_GEN=$((2#10000))
export     S_CLI=$((2#100000))
export     S_X11=$((2#1000000))
export     S_VNC=$((2#10000000))
export    S_QEMU=$((2#100000000))
export     S_VMW=$((2#1000000000))
export     S_XEN=$((2#10000000000))
export      S_PM=$((2#100000000000))
export     S_KVM=$((2#1000000000000))

#
#ALL4all
#
export     D_ALL=$((16#ffff))

#mode
M=4;

#debug
DBG=0;

#info
INF=2;

#warning
WNG=2;

#Debugging
C_DARGS=;

#file-scope-list
F=0;
FLST=;
I=1;

#print final interface-pre-exec data
#1: prints
C_PFEXE=;

###############################################################
#                    Base definitions                          #
################################################################

#FUNCBEG###############################################################
#NAME:
#  fetchDBGArgs
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function fetchDBGArgs () {
    if [ -n "`echo $*| sed -n 's/([^)]*)//g;s/-d /1/p'`" ];then
	C_DARGS=`echo " ${*} "| sed -n 's/^.*-d  *\([^ \t)]*\)[ \t)].*$/\1/p'`
	local i=;
	local KEY=;
	local ARG=;
	for i in ${C_DARGS//[,()]/ };do
	    KEY=`echo ${i%%:*}|tr '[:lower:]' '[:upper:]'`
	    ARG=`echo ${i}|awk -F':' '{print $2}'`
	    case $KEY in
		FILELIST|F)
		    if [ -z "${ARG}" ];then
			echo "requires numeric value:$KEY">&2
			exit 1;
		    fi
		    FLST=${ARG//[eE][xX][cC][lL][uU][dD][eE]/};
		    if [ "$FLST" != "$ARG" ];then
			I=0;
		    else
			FLST=${FLST//[iI][nN][cC][lL][uU][dD][eE]/};
			if [ "$FLST" != "$ARG" ];then
			    I=1;
			fi
		    fi
                    F=1;
		    ;;
		SUBSYSTEM|S)
		    S=${ARG};
		    if [ -n "${S//[0-9]/}" ];then
			echo "requires numeric value:$KEY">&2
			exit 1;
		    fi
		    ;;
		PATTERN|P)M=1;;
		MIN)M=2;;
		MAX)M=4;;
		WARNING|W)
		    export WNG=${ARG};
		    if [ -n "${WNG//[0-9]/}" ];then
			echo "requires numeric value:$KEY">&2
			exit 1;
		    fi
		    ;;
		INFO|I)
		    export INF=${ARG};
		    if [ -n "${I//[0-9]/}" ];then
			echo "requires numeric value:$KEY">&2
			exit 1;
		    fi
		    ;;
		[0-9]*)
		    DBG=$KEY;
		    if [ -n "${DBG//[0-9]/}" ];then
			echo "requires numeric value:$KEY">&2
			exit 1;
		    fi
		    ;;
		ALL)DBG=$D_ALL;;
		PRINTFINAL|PFIN|PF)
		    C_PFEXE=1;
		    ;;
		*)
		    echo "DBG:unknown value:$KEY">&2
		    exit 1;
		    ;;
	    esac
	done
	C_DARGS=" -d ${C_DARGS} "
	DARGS=" ${C_DARGS} "
    fi
}
fetchDBGArgs $*

if [ -n "`echo $*| sed -n 's/-y/1/p'`" ];then
    export CTYS_XTERM=0;
fi


#FUNCBEG###############################################################
#NAME:
#  checkBASHversion
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function checkBASHversion () {
  #Check some debug features, for runtime basically,
  #for technical part of development, could be ignored for application, if really neccessary!
  if [ ${BASH_VERSINFO[0]} -lt 3 ];then
    echo "${MYCALLNAME}:${MYUID}@${MYHOST}:$LINENO $BASH_SOURCE:WARNING:Version of BASH should be newer than 3.0 required:${BASH_VERSINFO[*]};" >&2;
    if [ -z "`echo $*| sed -n 's/-f/1/p'`" ];then
      echo "${MYCALLNAME}:${MYUID}@${MYHOST}:$$:$LINENO $BASH_SOURCE:INFO:An appropriate version might be installed." >&2;
      echo "${MYCALLNAME}:${MYUID}@${MYHOST}:$$:$LINENO $BASH_SOURCE:INFO:For now the mismatch is regarded as minor, though try temporarily the  \"-f\" option." >&2;
      exit 1  
    fi
  fi

  #Some mandatory features like almost full scope of arrays and
  #correct line numbering for debugging is seen as mandatory prerequisite!
  if [ \
       ${BASH_VERSINFO[0]} -lt 2 \
       -o ${BASH_VERSINFO[0]} -lt 2 -a ${BASH_VERSINFO[1]} -lt 6 \
  ];then
    echo "${MYCALLNAME}:${MYUID}@${MYHOST}:$$:$LINENO $BASH_SOURCE:ERROR:Version of BASH newer than 2.05 required, current=${BASH_VERSINFO[*]};" >&2;
    exit 1  
  fi
}

checkBASHversion $*

#FUNCBEG###############################################################
#NAME:
#  doDebug
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Returns wheter debug level matches. If some specific
#  actions to be done. E.g. evaluating time-intensive
#  debug actions for tests.
#
#   -> doDebug <subsys> <dbg-level> <line> <file>
#
#EXAMPLE:
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#    0: Debug it.
#    1: No debug.
#  VALUES:
#
#FUNCEND###############################################################
function doDebug  () {
    ((DBG>0))||return 1;
    local s=$1;shift;
    [ -n "${S}" ]&&{ ((S&s))||return 1; }
    local l=$1;shift;
    local L=$1;shift;
    local f=${1%/*/*};f=${1#$f\/};shift;
    if((M&4&&DBG>l));then echo -e "${MYCALLNAME}:${MYUID}@${MYHOST}:$$:$f:$L:$l:DBG>on">&2;return 0;fi
    if((M&2&&DBG<l));then echo -e "${MYCALLNAME}:${MYUID}@${MYHOST}:$$:$f:$L:$l:DBG<on">&2;return 0;fi
    if((M&1&&DBG&l));then echo -e "${MYCALLNAME}:${MYUID}@${MYHOST}:$$:$f:$L:$l:DBG&on">&2;return 0;fi
    return 1;
}



#FUNCBEG###############################################################
#NAME:
#  printDBG
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Prints only when called with more than one option and matches defined 
#  number.
#
#   -> printDBG <subsys> <dbg-level> <line> <file> <message>
#
#  implementation priority: PERFORMANCE
#
#EXAMPLE:
#PARAMETERS:
#OUTPUT:
#  RETURN:
#  VALUES:
#FUNCEND###############################################################
function printDBG {
    local r=$?;
    ((DBG>0))||return $r;
    local s=$1;shift;
    [ -n "${S}" ]&&{ ((S&s))||return $r; }
    local l=$1;shift;
    local L=$1;shift;
    local f=${1%/*/*};f=${1#$f\/};shift;
    ((F^1))&&{
	((M&4&&DBG>l))&&{ echo -e "${MYCALLNAME}:${MYUID}@${MYHOST}:$$:$f:$L:$s:$l:$*">&2;return $r; }
	((M&2&&DBG<l))&&{ echo -e "${MYCALLNAME}:${MYUID}@${MYHOST}:$$:$f:$L:$s:$l:$*">&2;return $r; }
	((M&1&&DBG&l))&&{ echo -e "${MYCALLNAME}:${MYUID}@${MYHOST}:$$:$f:$L:$s:$l:$*">&2;return $r; }
    }||{ [  "$I" == 1 -a "${FLST//$f/}" != "${FLST}" ]&&{
	    ((M&4&&DBG>l))&&{ echo -e "${MYCALLNAME}:${MYUID}@${MYHOST}:$$:$f:$L:$s:$l:$*">&2;return $r; }
	    ((M&2&&DBG<l))&&{ echo -e "${MYCALLNAME}:${MYUID}@${MYHOST}:$$:$f:$L:$s:$l:$*">&2;return $r; }
	    ((M&1&&DBG&l))&&{ echo -e "${MYCALLNAME}:${MYUID}@${MYHOST}:$$:$f:$L:$s:$l:$*">&2;return $r; }
	}
    }||{ [ "$I" == 0 -a "${FLST//$f/}" == "${FLST}" ]&&{
	    ((M&4&&DBG>l))&&{ echo -e "${MYCALLNAME}:${MYUID}@${MYHOST}:$$:$f:$L:$s:$l:$*">&2;return $r; }
	    ((M&2&&DBG<l))&&{ echo -e "${MYCALLNAME}:${MYUID}@${MYHOST}:$$:$f:$L:$s:$l:$*">&2;return $r; }
	    ((M&1&&DBG&l))&&{ echo -e "${MYCALLNAME}:${MYUID}@${MYHOST}:$$:$f:$L:$s:$l:$*">&2;return $r; }
	}
    }
}


#FUNCBEG###############################################################
#NAME:
#  printERR
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Prints errors
#   -> printERR <line> <fname> <code> <message>
#
#EXAMPLE:
#PARAMETERS:
#OUTPUT:
#  RETURN:
#  VALUES:
#FUNCEND###############################################################
function printERR () {
    local r=$?;
    local L=$1;shift;
    local f=${1%/*/*};f=${1#$f\/};shift;
    if((DBG>0));then 
	if [ "$CTYS_XTERM" == 1  ];then local b="${MYCALLNAME}:${MYUID}@${MYHOST}:$$:$f:$L:ERROR:$1";
	else local b="${MYCALLNAME}:${MYUID}@${MYHOST}:$$:$f:$L:\033[31mERROR\033[m:$1";fi
    else
	if [ "$CTYS_XTERM" == 1  ];then local b="${MYCALLNAME}:${MYUID}@${MYHOST}:ERROR:$1";
	else local b="${MYCALLNAME}:${MYUID}@${MYHOST}:$$:\033[31mERROR\033[m:$1";fi
    fi
    shift;echo -e "$b:$*" >&2;
    return $r;
}



#FUNCBEG###############################################################
#NAME:
#  printWNG
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Prints warnings
#   -> printWNG <warning-level> <line> <fname> <code> <message>
#
#EXAMPLE:
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function printWNG () {
    local r=$?;
    local l=$1;shift;
    ((WNG>l))||return;
    local L=$1;shift;
    local f=${1%/*/*};f=${1#$f\/};shift;
    if((DBG>0));then 
	if [ "$CTYS_XTERM" == 1  ];then local b="${MYCALLNAME}:${MYUID}@${MYHOST}:$$:$f:$L:WARNING:$1";
	else local b="${MYCALLNAME}:${MYUID}@${MYHOST}:$$:$f:$L:\033[35mWARNING\033[m:$1";fi
    else
	if [ "$CTYS_XTERM" == 1  ];then local b="${MYCALLNAME}:${MYUID}@${MYHOST}:$$:WARNING:$1";
	else local b="${MYCALLNAME}:${MYUID}@${MYHOST}:$$:\033[35mWARNING\033[m:$1";fi
    fi    
    shift;echo -e "$b:$*" >&2;
    return $r;
}




#FUNCBEG###############################################################
#NAME:
#  printINFO
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Prints warnings
#   -> printINFO <info-level> <line> <fname> <code> <message>
#
#EXAMPLE:
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function printINFO () {
    local r=$?;
    local l=$1;shift;
    ((INF>l))||return;
    local L=$1;shift;
    local f=${1%/*/*};f=${1#$f\/};shift;
    if((DBG>0));then 
	if [ "$CTYS_XTERM" == 1  ];then local b="${MYCALLNAME}:${MYUID}@${MYHOST}:$$:$f:$L:INFO:$1";
	else local b="${MYCALLNAME}:${MYUID}@${MYHOST}:$$:$f:$L:\033[32mINFO\033[m:$1";fi
    else
	if [ "$CTYS_XTERM" == 1  ];then local b="${MYCALLNAME}:${MYUID}@${MYHOST}:$$:INFO:$1";
	else local b="${MYCALLNAME}:${MYUID}@${MYHOST}:$$:\033[32mINFO\033[m:$1";fi
    fi
    shift; echo -e "$b:$*" >&2;
    return $r;
}



#FUNCBEG###############################################################
#NAME:
#  printFINALCALL
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Prints final call strings
#   -> printFINALCALL <line> <fname> <title> <exec-or-call-string>
#
#EXAMPLE:
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function printFINALCALL () {
    local r=$?;
    [ -z "${C_PFEXE}" ]&&return;
    local L=$1;shift;
    local f=${1%/*/*};f=${1#$f\/};shift;
    local t=${1};shift;
    local a=${*//  / };
    if((DBG>0));then 
	if [ "$CTYS_XTERM" == 1  ];then local b="${MYCALLNAME}:${MYUID}@${MYHOST}:$$:$f:$L:PRINT:\n$t\n--->\n${a//  / }\n<---";
	else local b="${MYCALLNAME}:${MYUID}@${MYHOST}:$$:$f:$L:\033[32mPRINT\033[m:\n\033[1m\033[4m$t\033[m\n\033[1m===>\033[m\n${a//  / }\n\033[1m<===\033[m";fi
    else
	if [ "$CTYS_XTERM" == 1  ];then local b="${MYCALLNAME}:${MYUID}@${MYHOST}:$$:PRINT:\n$t\n--->\n${a//  / }\n<---";
	else local b="${MYCALLNAME}:${MYUID}@${MYHOST}:$$:\033[32mPRINT\033[m:\n\033[1m\033[4m$t\033[m\n\033[1m===>\033[m\n${a//  / }\n\033[1m<===\033[m";fi
    fi
    shift; echo -e "$b" >&2;
    return $r;
}


#FUNCBEG###############################################################
#NAME:
#  callErrOutWrapper
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Fetched the User-ID and Group-UID of primary group,
#  as string in the format:
#
#    <uid>;<guid>
#
#EXAMPLE:
#
#GLOBAL:
#  CTYS_NOCALLWRAPPER
#
#PARAMETERS:
#  $1:    LINENO of caller
#  $2:    BASH_SOURCE of caller
#  $3-*:  The call to be wrapped
#
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function callErrOutWrapper () {
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:<${@}>"

    local _originLine=$1;shift
    local _originFile=$1;shift
    local _cli=$*
    local _res=0
    printDBG $S_LIB $D_BULK $_originLine "$_originFile" 0 "$FUNCNAME:<${@}>"

    if [ -n "${CTYS_NOCALLWRAPPER}" ];then
	${_cli}
	return $?
    fi

    exec 3>&1
    exec 4>&2
    local _buf=`{ eval "${_cli}"; } 2>&1 1>&3;echo -n "_-_-_$?";`
    printDBG $S_LIB $D_BULK $_originLine "$_originFile" "$FUNCNAME:A-_buf=<${_buf}>"
    _res="${_buf##*_-_-_}"
    if [ -n "${_res//[0-9]/}" ];then
	printERR $LINENO $BASH_SOURCE 1 "${FUNCNAME}:Possible internal error, but seems recoverable, continue:"
	printERR $LINENO $BASH_SOURCE 1 "${FUNCNAME}:=>_buf=<${_buf}>"
	_res=1;
    fi

    _buf="${_buf%_-_-_*}"

    printDBG $S_LIB ${D_BULK} $_originLine "$_originFile" "$FUNCNAME:B-_buf=<${_buf}>"
    exec 3>&-
    exec 4>&-

    echo ${_buf}

    local _rd=;
    [ "$CTYS_XTERM" == 0 ]\
      &&{ [ "$_res" == 0 ]&&_rd="\033[32m OK \033[m"||_rd="\033[31m NOK \033[m"; }\
      ||{ [ "$_res" == 0 ]&&_rd=" OK "||_rd=" NOK "; }

    printDBG $S_LIB ${D_BULK} $_originLine "$_originFile" "$FUNCNAME:_res=<${_rd}>"
    printDBG $S_LIB ${D_SYS} $_originLine "$_originFile" "$FUNCNAME:`setSeverityColor TRY \"call(${_cli})\"` => [ ${_rd} ]"
    return $_res
}



#FUNCBEG###############################################################
#NAME:
#  splitPath
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Lists long search paths(e.g. PATH, LD_LIBRARY_PATH) as one entry 
#  on each line spanning multiple lines.
#
#EXAMPLE:
#
#PARAMETERS:
# $1:  Prefix-String for indention
# $2:  Name of variable
# $3:  colon-seperated path variable
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function splitPath () {
  local _indent=$1;shift
  echo "${1}:${2}"|awk -F":" -v inde=${_indent} '
    { 
      printf("%-"inde-1"s= %s\n",$1,$2);
      for(i=3;i<=NF;i++){
        printf("%"inde+2"s%s\n",":",$i);
      }
    }
  '
}


#FUNCBEG###############################################################
#NAME:
#  splitArgs
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Lists call strings with one option on each line.
#
#  REMARK: 
#   Last option is ambiguous due to suboptions
#   for generic processing, so it could be the
#   first argument.
#
#EXAMPLE:
#
#PARAMETERS:
# $1:  Prefix-String for indention
# $2:  Name of variable
# $3:  colon-seperated path variable
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function splitArgs () {
  local _indent=$1;shift
  local _name=$1;shift

  echo "${_name}:${*}"|sed 's/ --/ |--/g;s/ \(-[^-]\)/ |\1/g;'|awk -F'|' -v inde=${_indent} '
    { 
      printf("%-"inde-1"s",$1);
      for(i=2;i<=NF;i++){
        printf("\n%"inde+2"s%s","",$i);
      }
    }
    END{print "";}
  '|awk -v inde=${_indent} '
    $3==""{ 
        print;
    }
    $3!=""{ 
      printf("%"inde+2"s%s %s","",$1,$2);
      for(i=3;i<=NF;i++){
        printf("\n%"inde+2"s%s","",$i);
      }
    }
    END{print "";}
  '
}






#FUNCBEG###############################################################
#NAME:
#  checkPathElements
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Checks for dengling path elements in search paths seperated by ":"
#
#EXAMPLE:
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function checkPathElements () {
  local PNAME=$1;shift
  local P=;
  for i in `echo ${*}|awk -F':' '{for(i=1;i<=NF;i++)print $i;}'`;do 
    if [ ! -d "${i}" ];then
       RET=1;
       [ -z "$P" ]&&P=1&&printWNG 2 $LINENO $BASH_SOURCE ${RET} "${FUNCNAME}:Invalid search path element in \"${PNAME}\":"
       printWNG 2 $LINENO $BASH_SOURCE ${RET} "${FUNCNAME}: ->${i}"
    fi
  done
  return ${RET}
}

#FUNCBEG###############################################################
#NAME:
#  checkFileListElements
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Checks for existenz and type of a list of files.
#
#EXAMPLE:
#
#PARAMETERS:
#  $@: A list of files-paths with one of the seperators "[: ]"
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function checkFileListElements () {
  local PNAME=$1;shift
  local P
  for i in `echo ${*}|awk -F'[:]' '{for(i=1;i<=NF;i++)print $i;}'`;do 
    if [ ! -f "${i}" ];then
       RET=1;
       [ -z "$P" ]&&P=1&&printWNG 1 $LINENO $BASH_SOURCE ${RET} "${FUNCNAME}:Invalid search file list element in \"${PNAME}\":"
       printWNG 1 $LINENO $BASH_SOURCE ${RET} "${FUNCNAME}: ->${i}"
    fi
  done
  return ${RET}
}




#FUNCBEG###############################################################
#NAME:
#  getRealPathname
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Returns real target for sysmbolic links, else the pathname itself.
#
#  Hardlink is not treated specially.
#
#   $1: Argument is checked for beeing a sysmbolic link, and
#       if so the target will be evaluated and returned,
#       else input is echoed.
#
#EXAMPLE:
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function getRealPathname () {
    local _maxCnt=20;
    local _realPath=${1}
    local _cnt=0

    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "_realPath=${_realPath}"
    while((_cnt<_maxCnt)) ;do    
	if [ -h "${_realPath}" ];then
            _realPath=`ls -l ${1}|awk '{print $NF}'`
        else
	    break;
	fi
	let cnt++;
    done
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "_realPath=${_realPath}"
    if((_maxCnt==0));then
        ABORT=1;
	printERR $LINENO $BASH_SOURCE ${ABORT} "Path could not be evaluated:${1}"
	printERR $LINENO $BASH_SOURCE ${ABORT} "INFO: Seems to be a circular-chained sysmbolic link"
	printERR $LINENO $BASH_SOURCE ${ABORT} "INFO: Aborted recursion level: ${_maxCnt}"
	gotoHell ${ABORT}
    fi
    echo -n "$_realPath"
}




#FUNCBEG###############################################################
#NAME:
#  gotoHell
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Exit with ignore-check
#
#EXAMPLE:
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function gotoHell () {
  printDBG $S_LIB ${D_FLOW} $LINENO $BASH_SOURCE "Controlled exit($1)"
  [ -n "${C_PRINTINFO}" -a "${C_PRINTINFO}"  != 0 ]&&printLegal;
  [ -z "${IGNORE}" ]&&exit $1
  printWNG 1 $LINENO $BASH_SOURCE ${RET} "${FUNCNAME}:Ignoring exit"
}



#FUNCBEG###############################################################
#NAME:
#  getUserGroup
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function getUserGroup () {
   id $1|sed -n 's/.*gid=[0-9]*(\([^)]*\)).*/\1/p'
}


#FUNCBEG###############################################################
#NAME:
#  checkConsole
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Checks whether running on console.
#
#  Therefore some simplification is assumed due to the specific environment:
#
#   1. ctys supports only SSH connections
#   2  the client and a server could be identified unambiguously by evaluation 
#      the SSH environment variable "SSH_CONNECTION" only, which is on the
#      "originating" client not set.
#
#      The originating client is the very first client, from where the session
#      is started. Any intermediate server, serving as a client in case of 
#      chained sessions, has this variable set.
#
#      But anyhow, it is no longer called from a CONSOLE, thus the criteria 
#      of detection the very-first call is sufficient.

#  
#EXAMPLE:
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#    0: IsCONSOLE
#    1: NOT
#  VALUES:
#
#FUNCEND###############################################################
function checkConsole () {
    test -z "${SSH_CONNECTION}"
}


#FUNCBEG###############################################################
#NAME:
#  getPathName
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Due to some wrappers, e.g. "consolehelper" for CentOS/RHEL, the 
#  function evaluates the PATH variable only when run from a console,
#  else hard-coded paths are checked. The paths has to be specifically
#  adapted to the different platforms of course.
#
#  This approach includes support for pre-configured authorization by 
#  usage of PAM modules for specific console-wrappers.1
#  
#EXAMPLE:
#
#PARAMETERS:
#  $1: LINENO of caller
#  $2: BASH_SOURCE of caller
#  $3: ERROR|WARNING|WARNINGEXT
#       ERROR
#        Prints an error message and exits.
#       WARNING  
#        Prints a warning and continues.
#       WARNINGEXT
#        Prints a warning-extended when activated by "-w" and continues.
#  $4: exec callee
#  $5: default path
#
#
#OUTPUT:
#  RETURN:
#    0: Success
#    1: Failure
#  VALUES:
#    pathname
#     With absolute path
#
#FUNCEND###############################################################
function getPathName () {
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:<$@>"
    local _pname=;
    local _ret=1;

    #if not on console trouble is caused by several console-wrappers
    checkConsole 2>/dev/null >/dev/null
    if [ $? -eq 0 ];then
	printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "running from CONSOLE"
        #try whether access is permitted, else continue with usual business
	_pname=`gwhich $4 2>/dev/null`
	_ret=$?
    fi
    if [ $_ret -ne 0 ];then
        #try the system specific path
	if [ -n "${5}" ];then
	    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "try \"${5}/${4}\""
	    _pname=`gwhich ${5}/${4} 2>/dev/null`
	    _ret=$?
	else
	    case $3 in
		ERROR)printERR $1 $2 1  "Missing required default path";gotoHell 1;;
		WARNING)printWNG 1 $1 $2 1  "Missing required default path";;
		WARNINGEXT|*)printWNG 2 $1 $2 1  "Missing required default path";;
	    esac
	fi
    fi
    if [ $_ret -ne 0 ];then
	case $3 in
	    ERROR)printERR $1 $2 1  "Can not evaluate exec-access to \"`setSeverityColor ERR ${4}`\"";gotoHell 1;;
	    WARNING)printWNG 1 $1 $2 1  "Can not evaluate exec-access to \"`setSeverityColor WNG ${4}`\"";;
	    WARNINGEXT|*)printWNG 2 $1 $2 1  "Can not evaluate exec-access to \"`setSeverityColor WNG ${4}`\"";;
	esac
	
    fi
    [ -n "${_pname}" -a $_ret -eq 0 ]&&_disp=`setSeverityColor INF ${_pname}`||_disp=`setSeverityColor WNG "ABSENT(${5}/${4})"`;
    printDBG $S_LIB ${D_SYS} $1 "$2" "$FUNCNAME:`setSeverityColor TRY \"eval(${4})\"` => [ ${_disp} ]"
    if [ $_ret -eq 0 ];then
	echo "$_pname"	
    fi
    return $_ret
}




#FUNCBEG###############################################################
#NAME:
#  setSeverityColor
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Encapsulates the input-string with appropriate escape sequences for
#  colored output. Therefore it is checked whether XTERM is set, and 
#  only than proceeded.
#
#  Operates on STATEs rather than explicitly defined colors. 
#
#  REMARK:
#    Due to performance reasons for parts of common trace-output the 
#    values are hardcoded within the whole module.
#  
#EXAMPLE:
#
#PARAMETERS:
#  $1: ERR|WNG|INF|TRY
#
#      ERR: Error, initally:        red(31)
#      WNG: Warning, initially:     magenta(35)
#      INF: Information, initially: green(32)
#      TRY: Trial input, initially: blue(34)
#
#  $2-*
#OUTPUT:
#  RETURN:
#    0: OK
#    1: NOK
#  VALUES:
#    "<esc-color>$2-*<esc-color-reset>"
#
#FUNCEND###############################################################
function setSeverityColor () {
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:<$@>"
    local col=$1;shift
    [ "$CTYS_XTERM" != 0 ]&&echo -n -e "$*"||\
    case $col in
	ERR)echo -n -e "\033[31m${*}\033[m";;
	WNG)echo -n -e "\033[35m${*}\033[m";;
	INF)echo -n -e "\033[32m${*}\033[m";;
	TRY)echo -n -e "\033[34m${*}\033[m";;
	*)    echo -n -e "$*";;
    esac
}


#FUNCBEG###############################################################
#NAME:
#  setFontAttrib
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Encapsulates the input-string with appropriate escape sequences for
#  atributes of charachter representation.
#
#  REMARK:
#    Due to performance reasons for parts of common trace-output the 
#    values are hardcoded within the whole module.
#  
#EXAMPLE:
#
#PARAMETERS:
#  $1: BOLD|UNDL|
#      FBLACK|FRED|FGREEN|FYELLOW|FBLUE|FMAGENTA|FCYAN|FWHITE
#      BBLACK|BRED|BGREEN|BYELLOW|BBLUE|BMAGENTA|BCYAN|BWHITE
#      RESET
#  $2-*
#
#OUTPUT:
#  RETURN:
#    0: OK
#    1: NOK
#  VALUES:
#    "<esc-color>$2-*<esc-color-reset>"
#
#FUNCEND###############################################################
function setFontAttrib () {
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:<$@>"
    local col=$1;shift
    [ "$CTYS_XTERM" != 0 ]&&echo -n -e "$*"||\
    case $col in
	BOLD)echo -n -e "\033[1m${*}\033[m";;
	UNDL)echo -n -e "\033[4m${*}\033[m";;

	FBLACK)echo -n -e "\033[30m${*}\033[m";;
	FRED)echo -n -e "\033[31m${*}\033[m";;
	FGREEN)echo -n -e "\033[32m${*}\033[m";;
	FYELLOW)echo -n -e "\033[33m${*}\033[m";;
	FBLUE)echo -n -e "\033[34m${*}\033[m";;
	FMAGENTA)echo -n -e "\033[35m${*}\033[m";;
	FCYAN)echo -n -e "\033[36m${*}\033[m";;
	FWHITE)echo -n -e "\033[37m${*}\033[m";;

	BBLACK)echo -n -e "\033[40m${*}\033[m";;
	BRED)echo -n -e "\033[41m${*}\033[m";;
	BGREEN)echo -n -e "\033[42m${*}\033[m";;
	BYELLOW)echo -n -e "\033[43m${*}\033[m";;
	BBLUE)echo -n -e "\033[44m${*}\033[m";;
	BMAGENTA)echo -n -e "\033[45m${*}\033[m";;
	BCYAN)echo -n -e "\033[46m${*}\033[m";;
	BWHITE)echo -n -e "\033[47m${*}\033[m";;

        RESET)echo -n -e "\033[m${*}";;

	*)    echo -n -e "$*";;
    esac
}


MYINSTALLPATH=`getRealPathname ${MYLIBEXECPATHNAME}`
MYINSTALLPATH=${MYINSTALLPATH%/*/*}
printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "MYINSTALLPATH=${MYINSTALLPATH}"

