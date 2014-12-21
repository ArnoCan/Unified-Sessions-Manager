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
#  ctys-extractMAClst.sh
#
#AUTHOR:
AUTHOR="Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org"
#
#FULLNAME:
FULLNAME="ctys-macros.sh"
#
#CALLFULLNAME:
CALLFULLNAME="CTYS Macro Utility"
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

argLst=;
while [ -n "$1" ];do
    case $1 in
	'-a')_atom=1;;
	'-c')_combined=1;;
	'-D')shift;TREELEVEL=$1;
	    if [ -z "${TREELEVEL// /}" ];then
		ABORT=1;
		printERR $LINENO $BASH_SOURCE ${ABORT} "Missing directory tree deepness-level."
		gotoHell ${ABORT}
	    fi
	    if [ -n "${TREELEVEL//[0-9]/}" ];then
		ABORT=1;
		printERR $LINENO $BASH_SOURCE ${ABORT} "Non-numeric directory tree level:<${TREELEVEL}>"
		gotoHell ${ABORT}
	    fi
	    ;;

	'-e')
	    if [ -z "${2}" -o "${2#-}" != "${2}" ];then
		_edit=${CTYS_MACRO_PATH//:/ }
	    else
		shift;
		for i in ${1//%/ };do
		    if [ -d "$i" -o -f "$i" ];then
			_edit="$_edit $i "
		    else
			_edit="$_edit $(matchFirstFile $i . ${CTYS_MACRO_PATH})"
		    fi
		done
	    fi
	    if [ -z "${_edit}" ];then
		ABORT=1;
		printERR $LINENO $BASH_SOURCE ${ABORT} "Edit requires either a list or CTYS_MACRO_PATH"
		gotoHell ${ABORT}
	    fi
            ;;

	'-E')_expand=1;_combined=1;;
	'-F')_filetree=1;
	    if [ -z "${CTYS_TREE}" ];then
		ABORT=1;
		printERR $LINENO $BASH_SOURCE ${ABORT} "Required command \"tree\" not available."
		gotoHell ${ABORT}

	    fi
	    ;;
	'-f')shift;_myFile=${1};;
	'-N')_defines=1;;


	'-S')_dirtree=1;
	    if [ -z "${CTYS_TREE}" ];then
		ABORT=1;
		printERR $LINENO $BASH_SOURCE ${ABORT} "Required command \"tree\" not available."
		gotoHell ${ABORT}

	    fi
	    ;;

	'-l')_mfiles=1;;

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


if [ -z "$_atom" -a -z "$_combined" -a -z "$_mfiles" ];then
    _mfiles=1;
#    _atom=1;
#    _combined=1;
fi

#set for later list "-l"
_mySearchPath="${CTYS_MACRO_PATH}";
_tmpx="${_myFilePath%/*}";
if [ "${_mySearchPath}" == "${_mySearchPath//$_tmpx}" ];then
    _mySearchPath="${_mySearchPath}:${_tmpx}";
fi

_myFilePath=`matchFirstFile "$_myFile" "$_mySearchPath"`;
if [ -z "$_myFile" ];then
    _myFilePath=${CTYS_MACRO_DB}
fi
if [ ! -f "${_myFilePath}" ];then
    ABORT=2
    printERR $LINENO $BASH_SOURCE ${ABORT} "Cannot access MACRO file db:\"${_myFilePath}\""
    gotoHell ${ABORT}
fi

if [ -n "$_edit" ];then
    _editX=;
    for i in ${_edit//%/ };do
	if [ -e $i ];then
	    _editX="$_editX $i"
	fi
    done

    $CTYS_MACROSEDIT ${_editX//%/ }&
    exit $?
fi


if [ -n "${argLst}" ];then
    argLst=${argLst//%/ }
    for i in ${argLst};do
	echo "$i=<$(replaceMacro MACRO:$i)>"
    done
    exit $?
fi

function fetchMacros () {
    awk '{cont=gsub("\\\\$","");if(cont==0)print;else printf("%s",$0);}'|\
    sed 's/  */ /g'|\
    awk -v d=1 -F'=' '
/^ *#.*/||/^$/{
  next;
}

NF==1{
  next;
}
{
  gsub("[mM][aA][cC][rR][oO]:","macro:")
}
{
  m=$1
  msub="";
  subm="";

  for(i=2;i<=NF;i++){
     if(i==2)subm=$i;
     else subm=subm"="$i;
  }
  if(subm~/macro:/){
     gsub("^[^m]*macro:","macro:",subm)
     msub=subm;
  }
  if(msub!~/^$/){
     printf("%s=%s\n",m,msub);
  }
  else{
     printf("%s\n",m,msub);
  }
}
'\
|sed '
  s/\(^.*[mM][aA][cC][rR][oO]:[^,% ]*\).*$/\1/;
  s/ \([mM][aA][cC][rR][oO]:[^,% ]*\)/%\1/g;
  s/\([^=]*\)=/%macro:\1%/;
  s/[^%mM]*\(%*[mM][aA][cC][rR][oO]:[^,% ]*\)[^,% ]*/<\1>/g;
  s/\(>\)\([^><]\+\)\(<\)/\1\3/g;
  s/[<>]//g;
  s/%*[mM][aA][cC][rR][oO]//g;
  s/^://g;
'
}


function fetchMacroDefinesAtoms () {
    awk '{cont=gsub("\\\\$","");if(cont==0)print;else printf("%s",$0);}'|\
    sed 's/  */ /g'|\
    awk -v d=1 -F'=' '
/^ *#.*/||/^$/{
  next;
}

!/[mM][aA][cC][rR][oO]/&&NF==2{
     print;
}
'
}

function fetchMacroDefinesCombined () {
    awk '{cont=gsub("\\\\$","");if(cont==0)print;else printf("%s",$0);}'|\
    sed 's/  */ /g'|\
    awk -v d=1 -F'=' '
/^ *#.*/||/^$/{
  next;
}

!/[mM][aA][cC][rR][oO]/&&NF==2{
  next;
}

{
     print;
}
'
}


function listFormatMultiple () {
    awk -F':' '
      BEGIN{
        abuf1[1]="";
        abuf2[1]="";
        ind=1;
        max1=0;
        formstr1="%-20s=%s\n";
      }
      NF!=1{
        buf=$2;
        for(i=3;i<=NF;i++){
          buf=buf":"$i;
        }
        if(length($1)>max1){
          max1=length($1);
          formstr1="%-"max1"s=%s\n";
        }
        abuf1[ind]=$1;
        abuf2[ind]=buf;
        ind++;  
      }
      END{
        for(i=1;i<ind;i++){
          printf(formstr1,abuf1[i],abuf2[i]);
        }
      }
    '
}


if [ "$_dirtree" == "1" -o "$_filetree" == "1" ];then
    if [ "$_dirtree" == "1" ];then
	echo "---------------------------------------------------------"
	echo "List of Macros Directroy Trees:"
	echo "---------------------------------------------------------"

echo "_mySearchPath=${_mySearchPath}"
#echo "_mySearchPath=${_mySearchPath}"

	if [ -z "${_mySearchPath}" ];then
	    argLst=.
	fi
	for j in ${_mySearchPath//:/ };do
	    if [ "${j#/}" != "${j}" ];then
		${CTYS_TREE} -C -A -d ${TREELEVEL:+-L $TREELEVEL} $j
	    else
		p=${_mySearchPath}

		for i in ${p//:/ };do
		    if [ -e "$i/$j" ];then
			${CTYS_TREE} -C -A -d ${TREELEVEL:+-L $TREELEVEL} $i/$j
		    fi
		done
	    fi
	done
    fi

    if [ "$_filetree" == "1" ];then
	echo "---------------------------------------------------------"
	echo "List of Macros File Trees:"
	echo "---------------------------------------------------------"
	for j in ${argLst//\%/ };do
	    for i in ${_mySearchPath//:/ };do
		if [ -e "$i/$j" ];then
		    ${CTYS_TREE}  -C -A ${TREELEVEL:+-L $TREELEVEL} $i/$j
		fi
		done
	    done
	fi
    exit $?
fi



if [ -n "$_mfiles" ];then
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
fi


if [ -n "$_atom" -o -n "$_combined" ];then
    if [ -z "$C_TERSE" ];then
	echo "---------------------------------------------------------"
	echo "current selected file:"
	echo " => ${_myFilePath}"
	echo "---------------------------------------------------------"
    fi
fi




if [ -n "$_atom" ];then
    if [ -z "$C_TERSE" ];then
	echo 
	echo "---------------------------------------------------------"
	echo "atoms - Single Level"
	echo "---------------------------------------------------------"
    fi
    if [ -n "$_defines" -o  -n "$_expand" ];then
	cat ${_myFilePath}|fetchMacroDefinesAtoms|sed 's/\(^[^=]*\)=/\1:/'|listFormatMultiple|sort
    else
	ALL=`cat ${_myFilePath}|fetchMacros`
	for i in $ALL;do echo $i|awk -F':' 'NF==1{print}'; done|sort
    fi
fi



if [ -n "$_combined" ];then
    if [ -z "$C_TERSE" ];then
	echo
	echo "---------------------------------------------------------"
	echo "combined - Nested Multiple Levels"
	echo "---------------------------------------------------------"
    fi
    if [ -n "$_expand" ];then
	ALL=`cat ${_myFilePath}|fetchMacros`
	for i in $ALL;do echo "${i%%:*}:`replaceMacro macro:${i%%:*}%${_myFilePath}`"; done\
           |awk -F':' 'NF>=3{print}'|listFormatMultiple|sort
    else
	if [ -n "$_defines" ];then
	    cat ${_myFilePath}|fetchMacroDefinesCombined|sed 's/\(^[^=]*\)=/\1:/;'|listFormatMultiple|sort
	else
	    ALL=`cat ${_myFilePath}|fetchMacros`
	    for i in $ALL;do echo $i; done |listFormatMultiple|sed 's/} *$//;'|sort
	fi
    fi|\
    if [ -z "$C_TERSE" ];then
        cat
    else
        sed 's/ *=/=/g'
    fi
fi
