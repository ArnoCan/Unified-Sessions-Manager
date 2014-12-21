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
#     Copyright (C) 2007,2008,2009,2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
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
#  ctys-callVncserver.sh
#
#AUTHOR:
AUTHOR="Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org"
#
#FULLNAME:
FULLNAME="Unified Sessions Manager"
#
#CALLFULLNAME:
ALLFULLNAME="Call VNC server"
#
#LICENCE:
LICENCE=GPL3
#
#TYPE:
#  bash-script
#
#VERSION:
VERSION=01_10_013
#DESCRIPTION:
#  Wrapper schript for calling vncserver.
#
#EXAMPLE:
#
#PARAMETERS:
#  $*: Pass throug new <VNC-options> and append missing defaults.
#
#OUTPUT:
#  RETURN:
#    state of call for vncserver
#  VALUES:
#    output of call of vncserver
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

MYBOOTSTRAP=${MYBOOTSTRAP}/bootstrap.01.01.005.sh
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

###################################################
#Check master hook                                #
###################################################
bootstrapCheckInitialPath
###################################################
#OK - Now should work.                            #
###################################################

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
TARGET_OS="Linux+OpenBSD+FreeBSD+Solaris+OpenSolaris"

#to be tested - coming soon
TARGET_OS_SOON=""

#to be tested - might be almsot OK - but for now FFS
#...probably some difficulties with desktop-switching only?!
TARGET_OS_FFS="NetBSD"

#release
TARGET_WM="Gnome,fvwm,KDE"

#to be tested - coming soon
TARGET_WM_SOON=""

#to be tested - coming soon
TARGET_WM_FORESEEN=""

################################################################
#                     End of FrameWork                         #
################################################################

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
#initPackages "${MYROOTHOOK}"

hookPackage "${MYLIBPATH}/plugins/CORE/CACHE.sh"


#
#Verify OS support
#
case ${MYOS} in
    Linux)
	[ -z "$X11XAUTH" ]&&X11XAUTH=`getPathName $LINENO $BASH_SOURCE WARNINGEXT xauth /usr/X11R6/bin`
	[ -z "$X11XAUTH" ]&&X11XAUTH=`getPathName $LINENO $BASH_SOURCE ERROR xauth /usr/bin`
	;;
    FreeBSD|OpenBSD)
	[ -z "$X11XAUTH" ]&&X11XAUTH=`getPathName $LINENO $BASH_SOURCE ERROR xauth /usr/X11R6/bin`
	;;
    SunOS)
	[ -z "$X11XAUTH" ]&&X11XAUTH=`getPathName $LINENO $BASH_SOURCE ERROR xauth /usr/openwin/bin`
	;;
    *)
        printINFO 1 $LINENO $BASH_SOURCE 1 "${MYCALLNAME} is not supported on ${MYOS}"
	gotoHell 0
	;;
esac



if [ "${*}" != "${*//-X/}" ];then
    C_TERSE=1
fi
if [ "${*}" != "${*//-V/}" ];then
    if [ -n "${C_TERSE}" ];then
	echo -n ${VERSION}
    else
	echo "$0: VERSION=${VERSION}"
    fi
    exit 0
fi

if [ "${*}" != "${*//--print/}" ];then
    C_PRINT=1
    C_PFEXE=1
fi

if [ "${*}" != "${*//--check/}" ];then
    C_CHECK=1
fi

if [ -n "${C_PRINT}" ];then
        printINFO 0 $LINENO $BASH_SOURCE 1 "INPUT:${MYCALLNAME}:<${*}>"
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
fi

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

#Source pre-set environment from user
if [ -f "${HOME}/.ctys/vnc/vnc.conf-${MYOS}.sh" ];then
  . "${HOME}/.ctys/vnc/vnc.conf-${MYOS}.sh"
fi

#Source pre-set environment from user
if [ -f "${MYCONFPATH}/vnc/vnc.conf-${MYOS}.sh" ];then
  . "${MYCONFPATH}/vnc/vnc.conf-${MYOS}.sh"
fi


################################################################
#    Specific definitions - User-Customizable  from shell      #
################################################################

case ${MYOS} in
    Linux)
	if [ ! -f $HOME/.vnc/passwd ];then
	    cp $HOME/.vnc/passwd.realVNC $HOME/.vnc/passwd
	fi
	;;
    FreeBSD|OpenBSD)
	if [ ! -f $HOME/.vnc/passwd ];then
	    cp $HOME/.vnc/passwd.tightVNC $HOME/.vnc/passwd
	fi
	;;
    SunOS)
	if [ ! -f $HOME/.vnc/passwd ];then
	    cp $HOME/.vnc/passwd.tightVNC $HOME/.vnc/passwd
	fi
	;;
esac


. ${MYLIBPATH}/lib/cli/cli.sh

_myJob=`cliGetOptValue "-j" ${@}`
printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "_myJob=$_myJob"

#Used only for current script, to be removed for vncviewer
CLISERVERONLY="-d -j --print --check"


#
#Defaults fo vncserver.
#  +kb ?
#CLIDEFAULTS=" -name ${NAME:-VncServerDefault} -depth 16 -localhost -nolisten tcp "
CLIDEFAULTS=" -name ${NAME:-VncServerDefault} -depth 16  "

printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "DISPLAY=$DISPLAY"

printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "\$@=$@"
X="`cliOptionsStrip REMOVE ${CLISERVERONLY} -- ${@}`"
printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "\$X=$X"
X="`cliOptionsAddMissing ${CLIDEFAULTS} -- ${X}`"
printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "\$X=$X"

LBL=`echo " $X "|sed -n 's/.*-name *\([^ ]*\) *.*/\1/p'`
printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "LBL=${LBL}"

printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "PATH=${PATH}"
OUTPUT="${VNCSERVER_NATIVE} ${X}"
printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "CALL=${OUTPUT}"

#generic: Linux+OBSD+Solaris+..
printFINALCALL $LINENO $BASH_SOURCE "FINAL-EXEC-CALL:callVncserver" "${OUTPUT} ${X}"
if [ -z "${C_CHECK}" ];then
    RESULT=`${OUTPUT} ${X} 2>&1|awk -F':' -v d=${LBL} '/d/&&!/Log file/&&/^New/{id=$2;gsub(" .*$","",id);printf("%s\n",id);}'`
    RESULT="${RESULT%% *}"
    printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "RESULT=${RESULT}"
    echo $RESULT
fi
