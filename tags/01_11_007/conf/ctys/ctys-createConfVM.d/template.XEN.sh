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
VERSION=MARKER_VERNO
#
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



########################################################################
#
#
#For description refer to man pages:
# 
#  ctys-XEN-configuration(7)
#
#
########################################################################


#
#This releases the ENUMERATE scanner, which now detects this file to 
#be a valid XEN configuration. When this file should not be enumerated 
#and included into the cacheDB, than replace the string part "XEN" with 
#"IGNORE".
#
#For current version the ENUMERATE information is stored within the 
#"*.ctys" file.
#
#@#MAGICID-IGNORE


#
#Don't change this
#
#@#INST_SERNO                =  MARKER_SERNO
#@#INST_DATE                 =  MARKER_DATE
#@#INST_CTYSREL              =  MARKER_CTYSREL
#@#INST_VERNO                =  MARKER_VERNO
#@#INST_EDITOR               =  MARKER_EDITOR
#@#LABEL                     = "MARKER_LABEL"
#

################################################################
#                     Global shell options.                    #
################################################################
shopt -s nullglob

#
#The root! 
#
#Require this, because this script could be almost located anywhere,
#and the UnifiedSesessionsManager could be installled anywhere else,
#thus all is floating by definition, so give me a hook please!
#
if [ -z "${CTYS_LIBPATH}" ];then
    echo "ERROR:This script requires the variable CTYS_LIBPATH to be set.">&2
    echo "ERROR:Refer to \"UnifiedSessionsManager\" user manual.">&2
    exit 1;
fi
MYLIBPATH=${CTYS_LIBPATH}
if [ ! -d "$MYLIBPATH" ];then
    echo "ERROR:This script requires the variable CTYS_LIBPATH to be set.">&2
    echo "ERROR:Not valid CTYS_LIBPATH=${CTYS_LIBPATH}">&2
    echo "ERROR:Refer to \"UnifiedSessionsManager\" user manual.">&2
    exit 2;
fi
MYLIBEXECPATH=${CTYS_LIBPATH}/bin


################################################################
#       System definitions - do not change these!              #
################################################################
#Execution anchor
MYCALLPATHNAME=$0




MYCALLNAME=`basename $MYCALLPATHNAME`

if [ -n "${MYCALLPATHNAME##/*}" ];then
    MYCALLPATHNAME=${PWD}/${MYCALLPATHNAME}
fi
MYCALLPATH=`dirname $MYCALLPATHNAME`

#
#LIST action requires absolute PATHNAME for allocation
#of configuration files, thus evaluation of some attributes.
#
#The filename-prefix is expected to be the same as the 
#directoryname name.
#
CTYSWRAPPER=${0}
CTYSWRAPPERPATH=$(dirname ${0})
if [ -z "${CTYSWRAPPERPATH}" -o "${CTYSWRAPPERPATH}" == "." ];then
    CTYSWRAPPERPATH="$PWD"
fi
MYCALLPATHNAME=${MYLIBPATH}/bin/${0##*/}
cd ${CTYSWRAPPERPATH}

###################################################
#load basic library required for bootstrap        #
###################################################
MYBOOTSTRAP=${MYLIBPATH}/bin/bootstrap
if [ ! -d "${MYLIBPATH}" ];then
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
_MYCALLPATHNAME=`bootstrapGetRealPathname ${MYCALLPATHNAME}`
MYCALLPATH=`dirname ${_MYCALLPATHNAME}`
#
###################################################
#Now find libraries might perform reliable.       #
###################################################


#current language, not really NLS
MYLANG=${MYLANG:-en}

#path for various loads: libs, help, macros, plugins
MYLIBPATH=${CTYS_LIBPATH:-`dirname $MYCALLPATH`}

###################################################
#Check master hook                                #
###################################################
bootstrapCheckInitialPath
###################################################
#OK - Now should work.                            #
###################################################


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
. ${MYLIBPATH}/lib/misc.sh
. ${MYLIBPATH}/lib/network/network.sh


#register libraries
bootstrapRegisterLib
baseRegisterLib
libManagerRegisterLib

##############################################
#Now the environment is armed, so let's go.  #
##############################################

printDBG $S_XEN ${D_FLOW} $LINENO $BASH_SOURCE "FRAMEWORK-LOAD:MYLIBPATH=${MYLIBPATH}"
printDBG $S_XEN ${D_FLOW} $LINENO $BASH_SOURCE "EXEC-WRAPPER:CTYSWRAPPER=$CTYSWRAPPER"
printDBG $S_XEN ${D_FLOW} $LINENO $BASH_SOURCE "EXEC-WRAPPER:WRAPPERARGS=${*}"

#
#load common XEN/KVM functions
#
. ${MYLIBPATH}/lib/libXENbase.sh


########################################################################
#
#Load shared environment of XEN plugin.
#
########################################################################

if [ -d "${HOME}/.ctys" ];then
    if [ -f "${HOME}/.ctys/ctys.conf.sh" ];then
	. "${HOME}/.ctys/ctys.conf.sh"
    fi
fi

if [ -d "${MYCONFPATH}" ];then
    if [ -f "${MYCONFPATH}/ctys.conf.sh" ];then
	. "${MYCONFPATH}/ctys.conf.sh"
    fi
fi


if [ -d "${HOME}/.ctys" ];then
    if [ -f "${HOME}/.ctys/systools.conf-${MYDIST}.sh" ];then
	. "${HOME}/.ctys/systools.conf-${MYDIST}.sh"
    fi
fi

if [ -d "${MYCONFPATH}" ];then
    if [ -f "${MYCONFPATH}/systools.conf-${MYDIST}.sh" ];then
	. "${MYCONFPATH}/systools.conf-${MYDIST}.sh"
    fi
fi


#
#activate final execution checks
C_EXECLOCAL=1

if [ -d "${HOME}/.ctys" -a -d "${HOME}/.ctys/xen" ];then
    if [ -f "${HOME}/.ctys/xen/xen.conf-${MYOS}.sh" ];then
	. "${HOME}/.ctys/xen/xen.conf-${MYOS}.sh"
    fi
fi

if [ -d "${MYCONFPATH}/xen" ];then
    if [ -f "${MYCONFPATH}/xen/xen.conf-${MYOS}.sh" ];then
	. "${MYCONFPATH}/xen/xen.conf-${MYOS}.sh"
    fi
fi



#
#import configuration keys from local conf-file.
#
_myconf=${CTYSWRAPPERPATH}/${MYCALLNAME%%.sh}
printDBG $S_BIN ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:_myconf=$_myconf"
. ${_myconf}.ctys


#
#Get options
#
_check=0;
_print=0;
ARGSADD=;
#BOOTMODE=VHDD;


while [ -n "$1" ];do
    case $1 in

############################
#START-MANDATORY OPTIONS
######
        '--check')
	    _check=1;
	    ;;
        '--vncaccessdisplay='*)
	    VNCACCESSDISPLAY=${1#*=};
	    ;;

        '--bootmode='*)
	    BOOTMODE=${1#*=};
	    ;;

        '--console='*)
	    CONSOLE=${1#*=};
	    ;;
######
#END-MANDATORY OPTIONS
############################


        '--instmode='*)
	    INSTMODE=${1#*=};
	    [ -n "$INSTMODE" ]&&INSTMODE_SETTINGS=cli||INSTMODE_SETTINGS=defaults
	    ;;

        '--instmode')
	    INSTMODE=;
	    INSTMODE_SETTINGS=defaults
	    ;;

        '--initmode')
	    INITMODE=1;
	    ;;

        '--initmodeonly')
	    INITMODE=1;
	    INITMODEONLY=1;
	    ;;

        '--kernelmode='*)
	    KERNELMODE=${1#*=};
	    ;;

        '--addargs='*)
	    ADDARGS=${1#*=};
	    ;;


	'-X')_terse=1;;
	'-V')printVersion;exit 0;;
	'-h')showToolHelp;exit 0;;

        '--listoptions')
	    LISTOPTIONS=1;
	    ;;

        '--print')
	    _print=1;
	    ;;

        '--startercall='*)
	    STARTERCALL=${1#*=};
	    ;;

        '--wrappercall='*)
	    WRAPPERCALL=${1#*=};
	    ;;

	'-d')shift;;

        -*)  
	    ABORT=1
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Erroneous parameter:${1}"
	    gotoHell ${ABORT}
	    ;;

        *)  #server list
	    ARGSADD="${ARGSADD} $1";
	    ARGSADD="${ARGSADD## }";
	    ARGSADD="${ARGSADD%% }";
	    printDBG $S_BIN ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:ARGSADD=$ARGSADD"
	    ;;
    esac
    shift;
done

#########################
#Start assembly of call.#
#########################


#Check for a supported version
REALSTARTERCALL=`bootstrapGetRealPathname ${STARTERCALL}`

XEN_MAGIC=$(getXENMAGIC ${STARTERCALL})
printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "XEN_MAGIC  =${XEN_MAGIC}"

XEN_VERSION=$(getVersionStrgXEN ${STARTERCALL})
printDBG $S_XEN ${D_MAINT} $LINENO $BASH_SOURCE "XEN_VERSION=${XEN_VERSION}"


#
#
#The actual presence of the runtime environment is for the creation of the
#pre-requirements not require - for now.
#Thus providing the setup on non-Xen machines too, for later execution
#on the target Xen-machine.
#
if [ -z "$INITMODEONLY" ];then
    #
    #Should be set in conf-file
    #
    STARTERCALL=${STARTERCALL:-$XEN}
    STARTERCALL=${STARTERCALL:-xen-kvm}
    STARTERCALL=$(gwhich ${STARTERCALL})
    if [ $? -ne 0 ];then
	ABORT=127
	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing:STARTERCALL=${STARTERCALL}"
	gotoHell ${ABORT}
    fi



    #
    #Should be set in conf-file
    #
#     WRAPPERCALL=${WRAPPERCALL:-$VDE_VDEQ}
#     WRAPPERCALL=${WRAPPERCALL:-vdeq}
#     WRAPPERCALL=$(gwhich ${WRAPPERCALL})
    if [ -n  "${WRAPPERCALL// /}" -a "${WRAPPERCALL}" != "NONE" ];then
	gwhich ${WRAPPERCALL}>/dev/null
	if [ $? -ne 0 ];then
	    ABORT=127
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing:WRAPPERCALL=${WRAPPERCALL}"
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Refer to VDE - VirtualSquare"
	    gotoHell ${ABORT}
	fi
    else
	WRAPPERCALL=""
    fi


    EXECALL0="${WRAPPERCALL} ";
    EXECALL0="${EXECALL} ${STARTERCALL} ";
    EXECALL=;

    if [ -n "$LISTOPTIONS" ];then
	echo
	echo "Current STARTERCALL=$STARTERCALL"
	echo
	callOptionsXENlist $STARTERCALL;
	exit 0;
    fi
fi

CONSOLE=$(echo ${CONSOLE}|tr 'a-z' 'A-Z')

#
#boot
#
BOOTSRC=${BOOTMODE##*\%}
BOOTMODE=${BOOTMODE%%\%*}
BOOTSRC=${BOOTSRC//$BOOTMODE}

#
#installation
#
if [ -n "$INSTMODE" ];then
    _A0=${INSTMODE}

    #USE uppercase only
    _A=${INSTMODE}
    INSTMODE=$(echo ${_A%%\%*}|tr 'a-z' 'A-Z')
    if [ "$INSTMODE" == "$_A" ];then
	ABORT=127
	printERR $LINENO $BASH_SOURCE ${ABORT} "Erroneous INSTMODE=${_A0}"
	gotoHell ${ABORT}
    fi
    [ "${INSTMODE}" == "DEFAULT" ]&&INSTMODE=;
    INSTMODE=${INSTMODE:-$DEFAULTINSTMODE}

    #keep case
    _A=${_A#*\%}
    INSTSRC=${_A%%\%*}
    if [ "$INSTSRC" == "$_A" ];then
	ABORT=127
	printERR $LINENO $BASH_SOURCE ${ABORT} "Erroneous INSTMODE=${_A0}"
	gotoHell ${ABORT}
    fi
    CHK=$(echo ${INSTSRC}|tr 'a-z' 'A-Z')
    [ "${CHK}" == "DEFAULT" ]&&INSTSRC=;
    if [ -z "${INSTSRC}" -a  "${INSTMODE}" == "${DEFAULTINSTMODE}" ];then
	INSTSRC=${DEFAULTINSTSRC};
    fi

    #USE uppercase only
    _A=${_A#*\%}
    INSTTARGETMODE=$(echo ${_A%%\%*}|tr 'a-z' 'A-Z')
    if [ "$INSTTARGETMODE" == "$_A" ];then
	ABORT=127
	printERR $LINENO $BASH_SOURCE ${ABORT} "Erroneous INSTMODE=${_A0}"
	gotoHell ${ABORT}
    fi
    [ "${INSTTARGETMODE}" == "DEFAULT" ]&&INSTTARGETMODE=;
    INSTTARGETMODE=${INSTTARGETMODE:-$DEFAULTBOOTMODE}

    #keep case
    _A=${_A#*\%}
    INSTTARGET=${_A%%\%*}
    if [ "$INSTTARGET" == "$_A" ];then
	ABORT=127
	printERR $LINENO $BASH_SOURCE ${ABORT} "Erroneous INSTMODE=${_A0}"
	gotoHell ${ABORT}
    fi
    CHK=$(echo ${INSTTARGET}|tr 'a-z' 'A-Z')
    [ "${CHK}" == "DEFAULT" ]&&INSTTARGET=;
    if [ -z "${INSTTARGET}" -a  "${INSTTARGETMODE}" == "${DEFAULTBOOTMODE}" ];then
	INSTTARGET=${DEFAULTINSTTARGET};
    fi

    _A=${_A#*\%}
    INSTSTAGE=$(echo ${_A%%\%*}|tr 'a-z' 'A-Z')
    [ "${INSTSTAGE}" == "DEFAULT" ]&&INSTSTAGE=;
else
    if [ "$INSTMODE_SETTINGS" == defaults ];then
	INSTMODE=${DEFAULTINSTMODE}
	INSTSRC=${DEFAULTINSTSOURCE};
	INSTTARGETMODE=${DEFAULTBOOTMODE}
	INSTTARGET=${DEFAULTINSTTARGET};
	INSTSTAGE=;
    fi
fi

if [ -z "$INSTMODE" ];then
    BOOTMODE=${BOOTMODE:-$DEFAULTBOOTMODE}
    BOOTSRC=${BOOTSRC:-$HDDBOOTIMAGE}
fi

#
#DomU-Name
#
[ -n "${CLI_CONF}" -a -n "${LABEL}" ]&&EXECALL="${EXECALL} name='${LABEL}' "


# #
# #Optional CPU architecture
# #
# if [ -n "${ARCH}" ];then
#     EXECALL="${EXECALL} -cpu ${ARCH} "
# fi


#
#SMP/#CPU
#
[ -n "${CLI_CONF}" -a -n "${SMP}" ]&&EXECALL="${EXECALL} vcpus=${SMP} "

#
#MEMSIZE
#
[ -n "${CLI_CONF}" -a -n "${MEMSIZE}" ]&&EXECALL="${EXECALL} memory=${MEMSIZE} "

#
#TIMEOPT
#
#[ -n "${TIMEOPT}" ]&&EXECALL="${EXECALL} localtime=${TIMEOPT} "

#
#NIC
#
if [ -n "${CLI_CONF}" ];then
    case "${NIC}" in
	ne2000)EXECALL="${EXECALL} ne2000=1 ";;
    esac
fi

#
#Network
#
VIF=;
if [ -n "${CLI_CONF}" ];then
    if [ "${ACCELERATOR}" == HVM ];then
	[ -n "${MAC0}" ]&&VIF="${VIF:+$VIF,}'type=${BACKEND},mac=${MAC0}${XENBRDG:+,bridge=$XENBRDG}'"
	[ -n "${MAC1}" ]&&VIF="${VIF:+$VIF,}'type=${BACKEND},mac=${MAC1}${XENBRDG:+,bridge=$XENBRDG}'"
	[ -n "${MAC2}" ]&&VIF="${VIF:+$VIF,}'type=${BACKEND},mac=${MAC2}${XENBRDG:+,bridge=$XENBRDG}'"
	[ -n "${MAC3}" ]&&VIF="${VIF:+$VIF,}'type=${BACKEND},mac=${MAC3}${XENBRDG:+,bridge=$XENBRDG}'"
	[ -n "${MAC4}" ]&&VIF="${VIF:+$VIF,}'type=${BACKEND},mac=${MAC4}${XENBRDG:+,bridge=$XENBRDG}'"
    else
	[ -n "${MAC0}" ]&&VIF="${VIF:+$VIF,}'mac=${MAC0}${XENBRDG:+,bridge=$XENBRDG}'"
	[ -n "${MAC1}" ]&&VIF="${VIF:+$VIF,}'mac=${MAC0}${XENBRDG:+,bridge=$XENBRDG}'"
	[ -n "${MAC2}" ]&&VIF="${VIF:+$VIF,}'mac=${MAC0}${XENBRDG:+,bridge=$XENBRDG}'"
	[ -n "${MAC3}" ]&&VIF="${VIF:+$VIF,}'mac=${MAC0}${XENBRDG:+,bridge=$XENBRDG}'"
	[ -n "${MAC4}" ]&&VIF="${VIF:+$VIF,}'mac=${MAC0}${XENBRDG:+,bridge=$XENBRDG}'"
    fi

    if [ -n "$VIF" ];then
	EXECALL="${EXECALL} vif=\"[${VIF}]\""
    fi
fi
#
#Kernel from CLI has higher priority
#
_AX=${KERNELMODE%%\%*}
KERNELIMAGE=${_AX:-$KERNELIMAGE}
#
#External kernel and initrd, when required customize it:
# KERNELIMAGE="yourKernel"
if [ -n "${CLI_CONF}" ];then
    if [ -n "${KERNELIMAGE}" -a ! -f "${KERNELIMAGE}" ];then
	ABORT=127
	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing kernel image:\"${KERNELIMAGE}\""
	gotoHell ${ABORT}
    fi
fi

#
#Initrd from CLI has higher priority
#
_AX=${KERNELMODE#*\%}
_AX=${_AX%\%*}
INITRDIMAGE=${_AX:-$INITRDIMAGE}
#
#External kernel and initrd, when required customize it:
# INITRDIMAGE="yourInitrd"
if [ -n "${CLI_CONF}" ];then
    if [ -n "${INITRDIMAGE}" -a ! -f "${INITRDIMAGE}" ];then
	ABORT=127
	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing initrd image:\"${INITRDIMAGE}\""
	gotoHell ${ABORT}
    fi
fi


#
#Kernel append parameters.
#
APPEND=${KERNELMODE##*\%}



printDBG $S_XEN ${D_FLOW} $LINENO $BASH_SOURCE "PRE-BOOTMODE:EXECALL=${EXECALL}"
printDBG $S_XEN ${D_FLOW} $LINENO $BASH_SOURCE "PRE-BOOTMODE:CHECK-IMAGES"
#
#Do the actual boot of GuestOS
#
#
#ATTENTION:
#  Full path is required for ps-based LIST action as last argument,
#  subcall for almost any other.
#
#  The final part of the call, which will be handled by "ps" analysis.
#  The entry has to be the last for the call, it is evaluated by
#  NF-field index of awk.
#  ->label-name is dirname of kernel.
#    Do not change it's position!
#
#  
LASTPATH=;
if [ -n "${CLI_CONF}" ];then
    LASTPATH="${LASTPATH} ${KERNELIMAGE:+ kernel='$KERNELIMAGE'} "
    LASTPATH="${LASTPATH} ${INITRDIMAGE:+ initrd='$INITRDIMAGE'} "
    LASTPATH="${LASTPATH} ${INITRDIMAGE:+ extra='$APPEND'}"
    LASTPATH="${LASTPATH} ${ROOT:+ extra='$ROOT'}"
fi

DISKS=;

case ${BOOTMODE} in
#     FDD)
#         LASTPATH="${LASTPATH} boot=a "
# 	if [ ! -f "${FDDIMAGE}" ];then
# 	    ABORT=127
# 	    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing FDD boot device:FDDIMAGE=${FDDIMAGE}"
# 	    gotoHell ${ABORT}
# 	fi
#         DISKS="${DISKS:+$DISKS,}'file:${FDDIMAGE},fda,w'"
# 	;;

    CD)
        LASTPATH="${LASTPATH} boot=d"
	if [ ! -f "${CDIMAGE}" ];then
	    ABORT=127
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing CD boot device:CDIMAGE=${CDIMAGE}"
	    gotoHell ${ABORT}
	fi
	EXECALL="${EXECALL} addcdrom='${CDIMAGE}'"
#        DISKS="${DISKS:+$DISKS,}'file:${CDIMAGE},${BACKEND:+$BACKEND:}hdc:cdrom,r'"
	;;

    DVD)
        LASTPATH="${LASTPATH} boot=d "
	if [ ! -f "${DVDIMAGE}" ];then
	    ABORT=127
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing DVD boot device:DVDIMAGE=${DVDIMAGE}"
	    gotoHell ${ABORT}
	fi
	EXECALL="${EXECALL} addcdrom='${DVDIMAGE}'"
#        DISKS="${DISKS:+$DISKS,}'file:${DVDIMAGE},${BACKEND:+$BACKEND:}hdc:cdrom,r'"
	;;

    VHDD|HDD)
        LASTPATH="${LASTPATH} boot=c "
	if [ -n "${BOOTSRC}" ];then
	    HDDBOOTIMAGE=${BOOTSRC}
	fi
	if [ ! -e "${HDDBOOTIMAGE}" ];then
	    ABORT=127
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing VHDD boot device:HDDBOOTIMAGE=${HDDBOOTIMAGE}"
	    gotoHell ${ABORT}
	fi
	if [ -n "${CLI_CONF}" ];then
            DISKS="${DISKS:+$DISKS,}'file:${HDDBOOTIMAGE},${BACKEND:+$BACKEND:}xvda,w'"
	fi
	;;

#     USB)
#         LASTPATH="${LASTPATH} boot=c "
# 	if [ ! -f "${USBBOOTIMAGE}" ];then
# 	    ABORT=127
# 	    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing USB boot device:USBBOOTIMAGE=${USBBOOTIMAGE}"
# 	    gotoHell ${ABORT}
# 	fi
#         DISKS="${DISKS:+$DISKS,}'tap:aio:${USBBOOTIMAGE},xvda,w'"
# 	;;

#     PXE)
#         #
#         #reminder for some older versions.
#         #
#         #EXECALL="${EXECALL} -option-rom ${XENBIOS}/pxe-ne2k_pci.bin"
#         #
#  	EXECALL="${EXECALL} boot=n "
# 	;;

    *)
	if [ -z "${INSTMODE}" ];then
	    ABORT=127
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Not supported for $LABEL: --bootmode=\"${BOOTMODE}\""
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Either a valid bootmode or instmode is required"
	    gotoHell ${ABORT}
	fi
	;;
esac



function setInstTarget () {
    local _bm=$1;
    local _im=$2;
    if [ "$_bm" == "$_im" ];then
	case "$_im" in
	    HDD*)echo -e 'xvdb';;
	    FDD*)echo -e 'xvfdb';;
	    USB*)echo -e 'xvdb';;
	esac
    else
	case "$_im" in
	    HDD*)[ "$_bm" == USB ]&&echo -e 'xvdb'||echo -e 'xvda';;
	    FDD*)echo -e 'xfda';;
	    USB*)[ "$_bm" == HDD ]&&echo -e 'xvdb'||echo -e 'xvda';;
	esac
    fi 
}

function prepInstTarget () {
    local _im=$1;
    local _it=$2;
    if [ -z "${INITMODE}" ];then
	printINFO 1 $LINENO $BASH_SOURCE 1 "Not in INITMODE(--initmode), omit device creation."
	return
    fi

    if [ "${_it#\/dev}" == "${_it}" ];then
	if [ -e "${_it}" ];then
	    printWNG 1 $LINENO $BASH_SOURCE 1 "Present install target will be used, "
	    printWNG 1 $LINENO $BASH_SOURCE 1 "for re-creation remove this manually before:"
	    printWNG 1 $LINENO $BASH_SOURCE 1 "'$MYHOST:$_it'"
	    return
	fi
	case "$_im" in
	    HDD)
		local _EX="${CTYS_DD} if=/dev/zero of=${_it} "
#		_EX="${_EX} oflag=direct "
		_EX="${_EX} bs=${HDDBOOTIMAGE_INST_BLOCKSIZE} "
		if [ "$HDDBOOTIMAGE_INST_BALLOON" == y ];then
		    local _bsx=${HDDBOOTIMAGE_INST_BLOCKCOUNT%%[^0-9]}
		    local _unit=${HDDBOOTIMAGE_INST_BLOCKCOUNT##[0-9]}
		    _unit=${_unit//[0-9]/};
		    if((_bsx<1));then
			ABORT=127
			printERR $LINENO $BASH_SOURCE ${ABORT} "Blockcount for image creation is not valid:$_bsx"
			gotoHell ${ABORT}
		    fi
 		    _EX="${_EX} count=1 seek=$((_bsx-1))$_unit "
		else
		    _EX="${_EX} count=${HDDBOOTIMAGE_INST_BLOCKCOUNT}"
		fi
		printFINALCALL $LINENO $BASH_SOURCE "FINAL-INIT-HDD" "${_EX}"
		if [ "$_check" == "0" ];then
		    ${_EX}
		    if [ $? != 0 ];then
			ABORT=127
			printERR $LINENO $BASH_SOURCE ${ABORT} "Failed to create boot image."
			printERR $LINENO $BASH_SOURCE ${ABORT} "'${_EX}'"
			gotoHell ${ABORT}
		    fi
		fi
		;;
	    FDD)
		ABORT=127
		printERR $LINENO $BASH_SOURCE ${ABORT} "Creation of an file image for FDD is not supported."
		gotoHell ${ABORT}
		;;
	    USB)
		ABORT=127
		printERR $LINENO $BASH_SOURCE ${ABORT} "Creation of an file image for USB is not supported."
		gotoHell ${ABORT}
		;;
	    CD|DVD)
		ABORT=127
		printERR $LINENO $BASH_SOURCE ${ABORT} "Creation of CDROM/DVD boot media is not yet supported."
		gotoHell ${ABORT}
		;;
	esac
    else
	echo "#Use existing device :\"${_it}\""
	case "$_im" in
	    HDD*)
		;;
	    FDD*)
		ABORT=127
		printERR $LINENO $BASH_SOURCE ${ABORT} "Creation of \"${_im}\" boot media is not yet supported."
		gotoHell ${ABORT}
		;;
	    USB*)
		ABORT=127
		printERR $LINENO $BASH_SOURCE ${ABORT} "Creation of \"${_im}\" boot media is not yet supported."
		gotoHell ${ABORT}
		;;
	    CD*|DVD*)
		ABORT=127
		printERR $LINENO $BASH_SOURCE ${ABORT} "Creation of \"${_im}\" boot media is not yet supported."
		gotoHell ${ABORT}
		;;
	esac
    fi
}

#
printDBG $S_XEN ${D_FLOW} $LINENO $BASH_SOURCE "PRE-INSTMODE:EXECALL=${EXECALL}"
printDBG $S_XEN ${D_FLOW} $LINENO $BASH_SOURCE "PRE-INSTMODE:CHECK-IMAGES"
#
case ${INSTMODE} in
    FDD*)
 	INSTSRC=${INSTSRC:-$INSTSRCFDD}
	if [ "$_print" == "1" ];then
	    echo '#############################'
	    echo '#INSTALL - FROM FDD'
	    echo '#'
	    echo '#Requires GuestOS support.'
	    echo '#'
	    echo '#The resulting calls are:'
	    echo '#'
	fi
	prepInstTarget ${INSTTARGETMODE} ${INSTTARGET}
	_myMode=$(setInstTarget ${INSTMODE} ${INSTTARGETMODE});
	LASTPATH="${LASTPATH} boot='a' "
	if [ -n "${CLI_CONF}" ];then
            DISKS="${DISKS:+$DISKS,}'file:${INSTSRC},${BACKEND:+$BACKEND:}fda,w'"
            DISKS="${DISKS:+$DISKS,}'file:${INSTTARGET},${BACKEND:+$BACKEND:}${_myMode},w'"
	fi
	;;

    HDD*)
 	INSTSRC=${INSTSRC:-$INSTSRCHDD}
	if [ "$_print" == "1" ];then
	    echo '###########################'
	    echo '#INSTALL - FROM HDD'
	    echo
	    echo '#The resulting calls are:   #'
	    echo
	fi
	prepInstTarget ${INSTTARGETMODE} ${INSTTARGET}
	_myMode=$(setInstTarget ${INSTMODE} ${INSTTARGETMODE});
	LASTPATH="${LASTPATH} boot='c' "
	if [ -n "${CLI_CONF}" ];then
            DISKS="${DISKS:+$DISKS,}'file:${INSTSRC},${BACKEND:+$BACKEND:}xvda,w'"
            DISKS="${DISKS:+$DISKS,}'file:${INSTTARGET},${BACKEND:+$BACKEND:}${_myMode},w'"
	fi
	;;

    USB*)
 	INSTSRC=${INSTSRC:-$INSTSRCUSB}
	if [ "$_print" == "1" ];then
	    echo '###########################'
	    echo '#INSTALL - FROM USB'
	    echo
	    echo '#The resulting calls are:   #'
	    echo
	fi
	prepInstTarget ${INSTTARGETMODE} ${INSTTARGET}
	_myMode=$(setInstTarget ${INSTMODE} ${INSTTARGETMODE});
	LASTPATH="${LASTPATH} boot='c' "
	if [ -n "${CLI_CONF}" ];then
            DISKS="${DISKS:+$DISKS,}'file:${INSTSRC},${BACKEND:+$BACKEND:}xvda,w'"
            DISKS="${DISKS:+$DISKS,}'file:${INSTTARGET},${BACKEND:+$BACKEND:}${_myMode},w'"
	fi
	;;

    CD*|DVD*)
 	INSTSRC=${INSTSRC:-$INSTSRCCDROM}
	if [ "$_print" == "1" ];then
	    echo '###########################'
	    echo '#INSTALL - FROM CD/DVD'
	    echo
	    echo '#The resulting calls are:   #'
	    echo
	fi
	prepInstTarget ${INSTTARGETMODE} ${INSTTARGET}
	_myMode=$(setInstTarget ${INSTMODE} ${INSTTARGETMODE});
	LASTPATH="${LASTPATH} boot='d' "
	if [ -n "${CLI_CONF}" ];then
            DISKS="${DISKS:+$DISKS,}'file:${INSTSRC},hdc:cdrom,r'"
            DISKS="${DISKS:+$DISKS,}'file:${INSTTARGET},${BACKEND:+$BACKEND:}${_myMode},w'"
	fi
	;;

    KS)
 	INSTSRC=;
	if [ "$_print" == "1" ];then
	    echo '###########################'
	    echo '#INSTALL - FROM KickStart'
	    echo
	    echo '#The resulting calls are:   #'
	    echo
	fi
	prepInstTarget ${INSTTARGETMODE} ${INSTTARGET}
	_myMode=$(setInstTarget ${INSTMODE} ${INSTTARGETMODE});
	LASTPATH="${LASTPATH} boot='d' "
	if [ -n "${CLI_CONF}" ];then
            DISKS="${DISKS:+$DISKS,}'file:${INSTTARGET},${BACKEND:+$BACKEND:}${_myMode},w'"
	fi
	;;

    PXE)
 	INSTSRC=;
	if [ "$_print" == "1" ];then
	    echo '###########################'
	    echo '#INSTALL - FROM PXE'
	    echo
	    echo '#The resulting calls are:   #'
	    echo
	fi
	prepInstTarget ${INSTTARGETMODE} ${INSTTARGET}
	_myMode=$(setInstTarget ${INSTMODE} ${INSTTARGETMODE});
	LASTPATH="${LASTPATH} boot='n' "
	if [ -n "${CLI_CONF}" ];then
            DISKS="${DISKS:+$DISKS,}'file:${INSTTARGET},${BACKEND:+$BACKEND:}${_myMode},w'"
	fi
	;;

    *)
	if [ -z "${BOOTMODE}" ];then
	    ABORT=127
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Not supported for $LABEL: --instmode=\"${INSTMODE}\""
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Either a valid bootmode or instmode is required"
	    gotoHell ${ABORT}
	fi
	;;
esac


if [ -n "${INITMODEONLY}" ];then
    printINFO 1 $LINENO $BASH_SOURCE 1 "VM is ready for GuestOS install."
    gotoHell 0
fi


if [ -n "${INSTMODE}" ];then
    EXECALL="install='y' ${EXECALL} "
fi


#
#Optional data floppy
#
if [ -n "${FDB}" -a -f "${FDB}" ];then
    DISKS="${DISKS:+$DISKS,}'file:${FDB},${BACKEND:+$BACKEND:}fdb,w'"
fi


#
#Optional data drive
#
if [ -n "${CLI_CONF}" -a -n "${HDB}" -a -f "${HDB}" ];then
    DISKS="${DISKS:+$DISKS,}'file:${HDB},${BACKEND:+$BACKEND:}xvdb,w'"
fi


#
#Optional data drive
#
if [ -n "${CLI_CONF}" -a -n "${HDC}"  -a -f "${HDC}" ];then
    DISKS="${DISKS:+$DISKS,}'file:${HDC},${BACKEND:+$BACKEND:}xvdc,w'"
fi


#
#Optional data drive
#
if [ -n "${CLI_CONF}" -a -n "${HDD}"  -a -f "${HDD}" ];then
    DISKS="${DISKS:+$DISKS,}'file:${HDD},${BACKEND:+$BACKEND:}xvdd,w'"
fi



printDBG $S_XEN ${D_FLOW} $LINENO $BASH_SOURCE "PRE-CONSOLE:EXECALL=${EXECALL}"
case ${CONSOLE} in
    SDL)
	EXECALL="${EXECALL} con=sdl "
	EXECALL="${EXECALL} ${ARGSADD} ${LASTPATH}"
	;;

    VNC)
	EXECALL="${EXECALL} con=vnc "
	EXECALL="${EXECALL} ${ARGSADD} ${LASTPATH}"
	;;

    CLI0)
	EXECALL="${EXECALL} con=nographic "
	EXECALL="${EXECALL} ${ARGSADD} ${LASTPATH}"
	EXECALL=" -c ${EXECALL}"
	;;

    CLI|XTERM|GTERM|EMACSM|EMACS|EMACSAM|EMACSA)
	EXECALL=" -c ${EXECALL} con=nographic"
        ;;

    NONE)
	EXECALL="${EXECALL} con=nographic "
	EXECALL="${EXECALL} ${ARGSADD} ${LASTPATH}"
	printDBG $S_XEN ${D_FLOW} $LINENO $BASH_SOURCE "NONE:no console"
	;;
    *)
	ABORT=127
	printERR $LINENO $BASH_SOURCE ${ABORT} "Unknown display --console=\"${CONSOLE}\""
	gotoHell ${ABORT}
	;;
esac


if [ -n "${DISKS}" ];then
    DISKS=" disk=\"[${DISKS}]\" "
fi

EXECALL="  ${_myconf}.conf ${EXECALL} "
EXECALL="${EXECALL0} create ${EXECALL} ${DISKS} "
EXECALL="${EXECALL//  / }"
EXECALL="${EXECALL//  / }"
EXECALL="${EXECALL//, /,}"
EXECALL="${EXECALL// ,/,}"

printDBG $S_XEN ${D_FLOW} $LINENO $BASH_SOURCE "EVAL:EXECALL=${EXECALL}"

if [ "$_print" == "1" ];then
    echo '###########################'
    echo '#Display call             #'
    echo '###########################'
    echo
    echo
    echo "XEN_VERSION      = \"${XEN_VERSION}\""
    echo "XEN_MAGIC        = \"${XEN_MAGIC}\""
    echo "XEN_ACCELERATOR = \"$(getACCELERATOR_XEN ${STARTERCALL})\""
    echo
    echo
    echo "MYCALLNAME   = \"$MYCALLNAME\""
    echo "               +->STARTERCALL     = $STARTERCALL"
    echo "               +->REALSTARTERCALL = $REALSTARTERCALL"
    echo
    echo
    echo '#The resulting call is:   #'
    echo '--->'
    echo "eval \"${EXECALL}\""
    echo '<---'
    echo
    splitArgs "     " EXECALL ${EXECALL}
fi

printFINALCALL $LINENO $BASH_SOURCE "FINAL-EXECCALL" "${EXECALL}"
if [ "$_check" == "0" ];then
    eval "${EXECALL}"
    _ret=$?
    if [ $_ret -ne 0 ];then
	printERR $LINENO $BASH_SOURCE ${ABORT} "ExecFailed(exit=$_ret):EXECALL=${EXECALL}"
    fi
fi
gotoHell $_ret

