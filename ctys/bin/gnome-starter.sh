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
FULLNAME="gnome-starter.sh"
#
#CALLFULLNAME:
CALLFULLNAME="CTYS demo for gnome integration"
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
################################################################

[ -z "$CTYS_ZENITY" ]&&CTYS_ZENITY=`getPathName $LINENO $BASH_SOURCE ERROR zenity /usr/bin`

if [ -z "$CTYS_ZENITY" ];then
    ABORT=1;
    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing 'zenity'"
    gotoHell ${ABORT}
fi


echo "4TEST:$*">&2
_action=${1:-CREATE};shift
_target=${1:-CONSOLE};shift
_scope=${1:-ALL};shift


function guiCheckCacheDB () {
    n=$(ctys-vhost -o index |wc -l)
    if [ "$n" == 0 ];then
	txt="Missing cacheDB, requires the default DB.\n" 
	txt="${txt}Use 'ctys-vdbgen' for creation.\n" 
	txt="${txt}\n" 
	txt="${txt}Refer to manuals for additonal information by typing one of:\n" 
	txt="${txt}\n" 
	txt="${txt}'ctys-vdbgen -H'\n" 
	txt="${txt}'ctys-vdbgen -H html'\n" 
	txt="${txt}'ctys-vdbgen -H man'\n" 
	txt="${txt}'ctys-vdbgen -H pdf'\n" 
	zenity --error \
	    --text="$txt" 
	exit 1
    else
	return 0;
    fi
}

function guiGetConfirm () {
    if zenity --entry \
	--width=600 \
	--title="ctys - Selection " \
	--text="Execute or modify:" \
	--entry-text "$1"
    then echo
    fi
}

function fetchRecord () {
    awk -F';' '
         BEGIN{idx=0;}
         {x="";for(i=1;i<=NF;i++){if($i!~/^$/){x=x";"$i;}else{x=x";\"\"";}}printf("%04d %s\n", idx,x);idx++;}
     '|\
     awk -F';' '{printf("%s %05s %s %s %s %s %s %s\n", $1,$5,$4,$3,$2,$8,$6,$7);}'
}

function fetchLoginRecord () {
    awk -F';' '
         BEGIN{idx=0;}
         {x="";for(i=1;i<=NF;i++){if($i!~/^$/){x=x";"$i;}else{x=x";\"\"";}}printf("%04d %s\n", idx,x);idx++;}
     '|\
     awk -F';' '{printf("%s %05s %s %s %s %s %s %s %s %s %s\n", $1,$8,$4,$3,$2,$7,$5,$6,$11,$9,$10);}'
}

function guiGetLIST () {
    local _sel=$1
    zenity --list \
	--width=750 \
	--height=500 \
	--title="ctys - CREATE - $_sel" \
	--column="Count" --column="Index" --column="Label" --column="stype" --column="Host" \
        --column="Console" --column="User" --column="Group" \
	--print-column=ALL  --separator=';' \
	$(#honour parser of zenity!!!
	    [ "$_sel" == PM  ]&&ctys-vhost -o pm,label,uid,gid,index,stype,defcon,sort:3 F:18:PM |fetchRecord;
	    [ "$_sel" == VM  ]&&ctys-vhost -o pm,label,uid,gid,index,stype,defcon,sort:3 F:18:VM |fetchRecord;
 	    [ "$_sel" == ALL ]&&ctys-vhost -o pm,label,uid,gid,index,stype,defcon,sort:3         |fetchRecord ;
         )
}

function guiGetLoginLIST () {
    local _sel=$1
echo "_sel=$_sel">&2
    zenity --list \
	--width=1030 \
	--height=500 \
	--title="ctys - LOGIN - $_sel" \
	--column="Count" --column="Index" --column="Label" --column="stype" --column="Host" \
        --column="Guest" --column="Distribution" --column="Release" --column="Console" --column="User" --column="Group" \
	--print-column=ALL  --separator=';' \
	$(#honour parser of zenity!!!
	    [ "$_sel" == PM  ]&&ctys-vhost -o pm,label,uid,gid,index,stype,defhosts,netname,dist,distrel,sort:3 F:18:PM |fetchLoginRecord;
	    [ "$_sel" == VM  ]&&ctys-vhost -o pm,label,uid,gid,index,stype,defhosts,netname,dist,distrel,sort:3 F:18:VM |fetchLoginRecord;
 	    [ "$_sel" == ALL ]&&ctys-vhost -o pm,label,uid,gid,index,stype,defhosts,netname,dist,distrel,sort:3         |fetchLoginRecord ;
         )
}

function guiListAction () {
    case "$_action" in
	CREATE)
	    guiCheckCacheDB
	    case "$_target" in
		CONSOLE)
		    case "$_scope" in
			ALL)x=$(guiGetLIST ALL);;
			PM)x=$(guiGetLIST PM);;
			VM)x=$(guiGetLIST VM);;
		    esac
		    if [ $? -eq 0 ];then
			x=$(echo $x|awk -F';' '
                      {
                        gsub("^0*","",$2);
                        c="-t "$4" -a create=dbrec:"$2",reuse";
                        if($6!~/^$/&&$6!~/""/){
                           c=c",CONSOLE:"$6;
                        }
                        c=c" -Y ";
                        c=c" -c local ";
                        c=c" "$7"@"$5;
                        print c;
                      }')
			x="ctys $x"
			x=$(guiGetConfirm "$x")
			if [ $? -eq 0 ];then
			    $x
			fi
		    fi
		    exit 
		    ;;
	    esac
	    ;;
	LOGIN)
	    guiCheckCacheDB
	    case "$_target" in
		CONSOLE)
		    case "$_scope" in
			ALL)x=$(guiGetLoginLIST ALL);;
			PM)x=$(guiGetLoginLIST PM);;
			VM)x=$(guiGetLoginLIST VM);;
		    esac
		    if [ $? -eq 0 ];then
			x=$(echo $x|awk -F';' '
                      {
                        gsub("^0*","",$2);
                        c=" -a create=l:"$3",reuse";
                        if($9!~/^$/&&$9!~/""/){
                           c=c" -t "$9" ";
                        }
                        c=c" -Y ";
                        c=c" -c local ";
                        if($6!~/^$/&&$6!~/""/){
                           c=c" "$10"@"$6;
                        }else{
                           c=c" "$10"@"$3;
                        }
                        print c;
                      }')
			x="ctys $x"
			x=$(guiGetConfirm "$x")
			if [ $? -eq 0 ];then
			    $x
			fi
		    fi
		    exit 
		    ;;
	    esac
	    ;;
	LIST)
	    guiCheckCacheDB
	    x=$(guiGetALL)
	    if [ $? -eq 0 ];then
		echo $x
	    fi
	    exit 
	    ;;
	*)
	    zenity --error \
		--text="Unknown choice:$1"
	    ;;
    esac
}


guiListAction


