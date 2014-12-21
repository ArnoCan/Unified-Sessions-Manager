#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_10_010
#
########################################################################
#
# Copyright (C) 2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

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

printDBG $S_CONF  ${D_FRAME} $LINENO $BASH_SOURCE "LOAD-CONFIG:${BASH_SOURCE}"

if [ -f "${HOME}/.ctys/systools.conf-SunOS.sh" ];then
    . "${HOME}/.ctys/systools.conf-SunOS.sh"
else

    if [ -f "${MYCONFPATH}/systools.conf-SunOS.sh" ];then
	. "${MYCONFPATH}/systools.conf-SunOS.sh"
    else
	if [ -f "${MYLIBEXECPATH}/../conf/ctys/systools.conf-SunOS.sh" ];then
	    . "${MYLIBEXECPATH}/../conf/ctys/systools.conf-SunOS.sh"
	else
	    ABORT=1;
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing system tools configuration file:\"systools.conf-SunOS.sh\""
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Check your installation."
	    gotoHell ${ABORT}
	fi
    fi
fi



PATH=/usr/xpg4/bin:/opt/sfw/bin:/sbin:/usr/sbin:/usr/openwin/bin:${PATH}
export PATH


#
#reset callers TTY settings when pseudoterminal option of ssh is used.
STTY=`stty -g 2>/dev/null`
if [ $? -eq 0 ];then
    trap "stty $STTY" EXIT
fi

################################################################
#           Absolutely basic for bootstrap                     #
################################################################

#initially native access for current user required
WHICH=`getPathName  $LINENO $BASH_SOURCE ERROR which  /usr/bin`
WHICH1=`callErrOutWrapper $LINENO $BASH_SOURCE  $WHICH which`
if [ $? -ne 0 ];then
    ABORT=1
    printERR $LINENO $_BASE_XEN ${ABORT} "Missing \"which\""
    gotoHell ${ABORT}

    printERR $LINENO $_BASE_XEN ${ABORT} "Does not make sence, even for \"-n\"!"
    exit ${ABORT}
fi

# if [ "$WHICH" != "$WHICH1" ];then
#     ABORT=1
#     printERR $LINENO $_BASE_XEN ${ABORT} "Do not want several versions of which on the same machine!"
#     printERR $LINENO $_BASE_XEN ${ABORT} " 1. check executables/links/etc."
#     printERR $LINENO $_BASE_XEN ${ABORT} " 2. check your PATH"
#     printERR $LINENO $_BASE_XEN ${ABORT} " ->WHICH  = $WHICH"
#     printERR $LINENO $_BASE_XEN ${ABORT} " ->WHICH1 = $WHICH1"
#     splitPath 15 PATH $PATH
#     gotoHell ${ABORT}

#     printERR $LINENO $_BASE_XEN ${ABORT} "Could be serious, thus correct it first!"
#     exit ${ABORT}
# fi





################################################################
#           Default definitions for system tools               #
################################################################

KSU=`getPathName  $LINENO $BASH_SOURCE WARNINGEXT ksu  /usr/kerberos/bin`
[ -z "${KSU}" ]&&KSU=`getPathName  $LINENO $BASH_SOURCE WARNINGEXT ksu  /usr/bin`
SUDO=`getPathName $LINENO $BASH_SOURCE WARNINGEXT sudo /usr/bin`

if [ -z "$KSU" -a -z "$SUDO" -a "$USER" != "root" ];then
    _myID="`id $USER`"
    _myID=${_myID#uid=};_myID=${_myID%%(*};
    if [ ${_myID} -eq 0 ];then
	printERR $LINENO $BASH_SOURCE 1 "non-root user \"$USER\" has ID=0, don't do that"
    else
	printWNG 1 $LINENO $BASH_SOURCE 1 "Probably limited access, missing:ksu and sudo, and $USER!=root"
    fi
else
    printDBG $S_CONF  ${D_FRAME} $LINENO $BASH_SOURCE "KSU=$KSU"
    printDBG $S_CONF  ${D_FRAME} $LINENO $BASH_SOURCE "SUDO=$SUDO"
fi

KILL=`getPathName $LINENO $BASH_SOURCE WARNINGEXT kill /usr/bin`
PKILL=`getPathName $LINENO $BASH_SOURCE WARNINGEXT pkill /usr/bin`



#########
#WMCTRL
#Required for desktop/workspace switching, has to be installed manually and be present 
#on DISPLAY target machines only.
[ -z "$CTYS_WMCTRL" ]&&CTYS_WMCTRL=`getPathName $LINENO $BASH_SOURCE WARNINGEXT wmctrl /usr/bin`
#CTYS_WMCTRL=${CTYS_WMCTRL:-wmctrl}



#########
#LM-SENSORS
#Displaying the health state of PMs.
CTYS_SENSORS=${CTYS_SENSORS:-sensors}



#########
#HDDTEMP
#Temperatures of most HDDs for usage with gkrellm.
CTYS_HDDTEMP=${CTYS_HDDTEMP:-/usr/sbin/hddtemp}



#########
#SMARTCTL
#Used for temperature evaluation when polling values.
#Supports most 3ware RAID arrays.
CTYS_SMARTCTL=${CTYS_SMARTCTL:-/usr/sbin/smartctl}


#########
#DMIDECODE
#Used for fetching the UUID of current machine for generating of
#configuration file. 
CTYS_DMIDECODE=${CTYS_DMIDECODE:-/usr/sbin/dmidecode}



#########
#If bridge is set during boot, and DHCP is used, probably a lower level,
#maybe 0 should be used.
#Else it seems safe for commen platforms setting it higher.
#  system-default=30, 
#  ctys-fallback=0
#This is the delay for the creation of the first VDE-switch.
BRIDGE_FORWARDDELAY=${BRIDGE_FORWARDDELAY:-15};

#########
#CP
CP=/usr/bin/cp
CPR=" -pPR "


#########
#PS
#
PS=ps
PSF=" -f "
PSEF=" -ef "
PSU=" -u  "
PSG=" -g  "
PSL=" -e -l -f "


##########################
#CTYS_BASH=bash
#CTYS_SSH=ssh
#CTYS_SED=sed
#CTYS_AWK=awk

[ -z "$CTYS_NETSTAT" ]&&CTYS_NETSTAT=`getPathName $LINENO $BASH_SOURCE WARNING netstat /usr/bin`

[ -z "$CLIEXE" ]&&CLIEXE=`getPathName $LINENO $BASH_SOURCE ERROR ${CLISHELL} /usr/bin`
[ -z "$BASHEXE" ]&&BASHEXE="$CLIEXE"
[ -z "$CTYS_UNLINK" ]&&CTYS_UNLINK=`getPathName $LINENO $BASH_SOURCE ERROR unlink /usr/sbin`


#[ -z "$CTYS_SYSCTL" ]&&CTYS_SYSCTL=`getPathName $LINENO $BASH_SOURCE ERROR sysctl /sbin`
[ -z "$CTYS_SYSCTL" ]&&CTYS_SYSCTL=`getPathName $LINENO $BASH_SOURCE WARNINGEXT sysctl /sbin`
[ -z "$CTYS_LSPCI" ]&&CTYS_LSPCI=`getPathName $LINENO $BASH_SOURCE WARNINGEXT lspci /sbin`

[ -z "$CTYS_CHMOD" ]&&CTYS_CHMOD=`getPathName $LINENO $BASH_SOURCE ERROR chmod /usr/bin`
[ -z "$CTYS_TREE" ]&&CTYS_TREE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT tree /usr/bin`
[ -z "$CTYS_DD" ]&&CTYS_DD=`getPathName $LINENO $BASH_SOURCE WARNINGEXT dd /bin`
[ -z "$CTYS_BRCTL" ]&&CTYS_BRCTL=`getPathName $LINENO $BASH_SOURCE WARNINGEXT brctl /usr/sbin`
[ -z "$CTYS_IFCONFIG" ]&&CTYS_IFCONFIG=`getPathName $LINENO $BASH_SOURCE WARNINGEXT ifconfig /sbin`
[ -z "$CTYS_IP" ]&&CTYS_IP=`getPathName $LINENO $BASH_SOURCE WARNINGEXT ip /sbin`
[ -z "$CTYS_ROUTE" ]&&CTYS_ROUTE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT route /sbin`
[ -z "$CTYS_SMARTCTL" ]&&CTYS_SMARTCTL=`getPathName $LINENO $BASH_SOURCE WARNINGEXT smartctl /usr/sbin`

#
#force compatibility
USER=$LOGNAME

#requires a pty, set's ENV
EXECSHELLWRAPPER="${CLISHELL} -l -c "

#does not require a pty, but may cause some PATH trouble.
EXECSHELLWRAPPERNOPTY="${CLISHELL} -c "


#
#Online-Help
#
[ -z "$CTYS_PDFVIEWER" ]&&CTYS_PDFVIEWER=`getPathName $LINENO $BASH_SOURCE WARNINGEXT kpdf /usr/bin`
[ -z "$CTYS_PDFVIEWER" ]&&CTYS_PDFVIEWER=`getPathName $LINENO $BASH_SOURCE WARNINGEXT gpdf /usr/bin`
[ -z "$CTYS_PDFVIEWER" ]&&CTYS_PDFVIEWER=`getPathName $LINENO $BASH_SOURCE WARNINGEXT acroread /usr/bin`
[ -z "$CTYS_PDFVIEWER" ]&&CTYS_PDFVIEWER=`getPathName $LINENO $BASH_SOURCE WARNINGEXT acroread /opt/Adobe/Reader8/bin`
[ -z "$CTYS_PDFVIEWER" ]&&CTYS_PDFVIEWER=`getPathName $LINENO $BASH_SOURCE WARNINGEXT acroread /opt/Adobe/Reader9/bin`
[ -z "$CTYS_PDFVIEWER" ]&&CTYS_PDFVIEWER=`getPathName $LINENO $BASH_SOURCE WARNINGEXT acroread /opt/Adobe/Reader7/bin`

[ -z "$CTYS_HTMLVIEWER" ]&&CTYS_HTMLVIEWER=`getPathName $LINENO $BASH_SOURCE WARNINGEXT konqueror /usr/bin`
[ -z "$CTYS_HTMLVIEWER" ]&&CTYS_HTMLVIEWER=`getPathName $LINENO $BASH_SOURCE WARNINGEXT firefox /usr/bin`

[ -z "$CTYS_MANVIEWER" ]&&CTYS_MANVIEWER=`getPathName $LINENO $BASH_SOURCE WARNINGEXT man /usr/bin`



#
#ctys-scripts editor
#
#Emacs
[ -z "$CTYS_SCRIPTEDIT" ]&&CTYS_SCRIPTEDIT=`getPathName $LINENO $BASH_SOURCE WARNINGEXT emacs /usr/bin`
#
#vi
[ -z "$CTYS_SCRIPTEDIT" ]&&CTYS_SCRIPTEDIT=`getPathName $LINENO $BASH_SOURCE WARNINGEXT gvim /usr/bin`
[ -z "$CTYS_TERMINAL" ]&&CTYS_TERMINAL=`getPathName $LINENO $BASH_SOURCE WARNINGEXT gnome-terminal /usr/bin`
[ -n "$CTYS_TERMINAL" -a -z "$CTYS_SCRIPTEDIT" ]&&CTYS_VIM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vim /usr/bin`
[ -n "$CTYS_TERMINAL" -a -n "$CTYS_VIM" -a -z "$CTYS_SCRIPTEDIT" ]&&CTYS_SCRIPTEDIT="$CTYS_TERMINAL -e $CTYS_VIM"
#
[ -z "$CTYS_SCRIPTEDIT" ]&&CTYS_SCRIPTEDIT=`getPathName $LINENO $BASH_SOURCE WARNINGEXT konqueror /usr/bin`
[ -z "$CTYS_SCRIPTEDIT" ]&&CTYS_SCRIPTEDIT=`getPathName $LINENO $BASH_SOURCE WARNINGEXT nautilus /usr/bin`


#
#ctys-macros editor
#
#Emacs
[ -z "$CTYS_MACROSEDIT" ]&&CTYS_MACROSEDIT=`getPathName $LINENO $BASH_SOURCE WARNINGEXT emacs /usr/bin`
#
#vi
[ -z "$CTYS_MACROSEDIT" ]&&CTYS_MACROSEDIT=`getPathName $LINENO $BASH_SOURCE WARNINGEXT gvim /usr/bin`
[ -z "$CTYS_TERMINAL" ]&&CTYS_TERMINAL=`getPathName $LINENO $BASH_SOURCE WARNINGEXT gnome-terminal /usr/bin`
[ -n "$CTYS_TERMINAL" -a -z "$CTYS_MACROSEDIT" ]&&CTYS_VIM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vim /usr/bin`
[ -n "$CTYS_TERMINAL" -a -n "$CTYS_VIM" -a -z "$CTYS_MACROSEDIT" ]&&CTYS_MACROSEDIT="$CTYS_TERMINAL -e  $CTYS_VIM"
#
[ -z "$CTYS_MACROSEDIT" ]&&CTYS_MACROSEDIT=`getPathName $LINENO $BASH_SOURCE WARNINGEXT konqueror /usr/bin`
[ -z "$CTYS_MACROSEDIT" ]&&CTYS_MACROSEDIT=`getPathName $LINENO $BASH_SOURCE WARNINGEXT nautilus /usr/bin`


#
#ctys-groups editor
#
#Emacs
[ -z "$CTYS_GROUPSEDIT" ]&&CTYS_GROUPSEDIT=`getPathName $LINENO $BASH_SOURCE WARNINGEXT emacs /usr/bin`
#
#vi
[ -z "$CTYS_GROUPSEDIT" ]&&CTYS_GROUPSEDIT=`getPathName $LINENO $BASH_SOURCE WARNINGEXT gvim /usr/bin`
[ -z "$CTYS_TERMINAL" ]&&CTYS_TERMINAL=`getPathName $LINENO $BASH_SOURCE WARNINGEXT gnome-terminal /usr/bin`
[ -n "$CTYS_TERMINAL" -a -z "$CTYS_GROUPSEDIT" ]&&CTYS_VIM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vim /usr/bin`
[ -n "$CTYS_TERMINAL" -a -z "$CTYS_GROUPSEDIT" ]&&CTYS_GROUPSEDIT="$CTYS_TERMINAL -e $CTYS_VIM"
#
[ -z "$CTYS_GROUPSEDIT" ]&&CTYS_GROUPSEDIT=`getPathName $LINENO $BASH_SOURCE WARNINGEXT konqueror /usr/bin`
[ -z "$CTYS_GROUPSEDIT" ]&&CTYS_GROUPSEDIT=`getPathName $LINENO $BASH_SOURCE WARNINGEXT nautilus /usr/bin`


#
#ctys-config editor
#
[ -z "$CTYS_CONFIGEDIT" ]&&CTYS_CONFIGEDIT=`getPathName $LINENO $BASH_SOURCE WARNINGEXT konqueror /usr/bin`
#
#Emacs
[ -z "$CTYS_CONFIGEDIT" ]&&CTYS_CONFIGEDIT=`getPathName $LINENO $BASH_SOURCE WARNINGEXT emacs /usr/bin`
#
#vi
[ -z "$CTYS_CONFIGEDIT" ]&&CTYS_CONFIGEDIT=`getPathName $LINENO $BASH_SOURCE WARNINGEXT gvim /usr/bin`
[ -z "$CTYS_TERMINAL" ]&&CTYS_TERMINAL=`getPathName $LINENO $BASH_SOURCE WARNINGEXT gnome-terminal /usr/bin`
[ -n "$CTYS_TERMINAL" -a -z "$CTYS_CONFIGEDIT" ]&&CTYS_VIM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vim /usr/bin`
[ -n "$CTYS_TERMINAL" -a -z "$CTYS_CONFIGEDIT" ]&&CTYS_CONFIGEDIT="$CTYS_TERMINAL -e $CTYS_VIM"
#
[ -z "$CTYS_CONFIGEDIT" ]&&CTYS_CONFIGEDIT=`getPathName $LINENO $BASH_SOURCE WARNINGEXT nautilus /usr/bin`
