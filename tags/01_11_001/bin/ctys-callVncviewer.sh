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
#  ctys-callVncviewer.sh
#
#AUTHOR:
AUTHOR="Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org"
#
#FULLNAME:
FULLNAME="Unified Sessions Manager"
#
#CALLFULLNAME:
CALLFULLNAME="Call VNC viewer"
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
#  Wrapper schript for calling vncviewer.
#
#EXAMPLE:
#
#PARAMETERS:
#  $*: Pass throug new <VNC-options> and append missing defaults.
#
#OUTPUT:
#  RETURN:
#    state of call for vncviewer
#  VALUES:
#    output of call of vncviewer
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
#are available now.                               #
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
if [ ! -f "${MYLIBPATH}/lib/base.sh" ];then
  echo "${MYCALLNAME}:$LINENO:ERROR:Missing mandatory initial library:${MYLIBPATH}/lib/base.sh"
  exit 1
fi
. ${MYLIBPATH}/lib/base.sh


if [ ! -f "${MYLIBPATH}/lib/libManager.sh" ];then
  echo "${MYCALLNAME}:$LINENO:ERROR:Missing mandatory initial library:${MYLIBPATH}/lib/libManager.sh"
  exit 1
fi
. ${MYLIBPATH}/lib/libManager.sh

#
#"Was the egg or the chicken first?"
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
TARGET_OS="Linux-CentOS/RHEL(5+)"

#to be tested - coming soon
TARGET_OS_SOON="OpenBSD+Linux(might work now):Ubuntu+OpenSuSE"

#to be tested - might be almsot OK - but for now FFS
#...probably some difficulties with desktop-switching only?!
TARGET_OS_FFS="FreeBSD+Solaris/SPARC/x86"

#release
TARGET_WM="Gnome"

#to be tested - coming soon
TARGET_WM_SOON="fvwm"

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


. ${MYLIBPATH}/lib/cli/cli.sh

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


#Used only for current script, to be removed for vncviewer
CLILIBONLY="-d -j --print --check"

#Defaults fo vncviewer.
#CLIDEFAULTS="-passwd ~/.vnc/passwd "
CLIDEFAULTS="-passwd $HOME/.vnc/passwd "

printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "DISPLAY=$DISPLAY"

printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "\$@=$@"
X="`cliOptionsStrip REMOVE $CLILIBONLY -- $@`"
printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "\$X=$X"
X="`cliOptionsAddMissing $CLIDEFAULTS -- $X`"
printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "\$X=$X"


OUTPUT="${VNCVIEWER_NATIVE} ${X}"
printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "PATH=${PATH}"
printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "PWD=${PWD}"
printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "CALL=${OUTPUT}"
printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "C_ASYNC=${C_ASYNC}"


if [ "${C_ASYNC}" == 0 ];then
    printFINALCALL $LINENO $BASH_SOURCE "FINAL-EXEC-CALL:callVncviewer" "${OUTPUT}"
    if [ -z "${C_CHECK}" ];then
	eval ${OUTPUT}  
    fi
else
#KEEP4REMINDER
#    printFINALCALL $LINENO $BASH_SOURCE "FINAL-EXEC-CALL:callVncviewer" "${BASHEXE} -c \"${OUTPUT}\""
    printFINALCALL $LINENO $BASH_SOURCE "FINAL-EXEC-CALL:callVncviewer" "${OUTPUT}"
    if [ -z "${C_CHECK}" ];then
	OUTPUT="${OUTPUT}"
#	printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "EXEC:${BASHEXE} -c ${OUTPUT} &"
	printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "EXEC:${OUTPUT} &"

#KEEP4REMINDER
#OK-but CL-sync:	exec ${BASHEXE} -c "${OUTPUT}"
#	exec ${BASHEXE} -c "${OUTPUT}"&
	${OUTPUT}&

#KEEP4REMINDER
        #OK:best, but maybe proc-analysis will be broken, do it later: exec  ${OUTPUT}&
        #ERR-REMINDER-Broken in CentOS-5.4+..: exec ${BASHEXE} -c "\"${OUTPUT}\"" &
        #                                      exec ${BASHEXE} -c "${OUTPUT} " &
    fi
fi
