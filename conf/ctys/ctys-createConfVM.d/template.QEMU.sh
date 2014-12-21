#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_011
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
#  ctys-QEMU-configuration(7)
#





########################################################################


#
#This releases the ENUMERATE scanner, which now detects this file to 
#be a valid QEMU configuration. When this file should not be enumerated 
#and included into the cacheDB, than replace the string part "QEMU" with 
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

printDBG $S_QEMU ${D_FLOW} $LINENO $BASH_SOURCE "FRAMEWORK-LOAD:MYLIBPATH=${MYLIBPATH}"
printDBG $S_QEMU ${D_FLOW} $LINENO $BASH_SOURCE "EXEC-WRAPPER:CTYSWRAPPER=$CTYSWRAPPER"
printDBG $S_QEMU ${D_FLOW} $LINENO $BASH_SOURCE "EXEC-WRAPPER:WRAPPERARGS=${*}"

#
#load common QEMU/KVM functions
#
. ${MYLIBPATH}/lib/libQEMUbase.sh


########################################################################
#
#Load shared environment of QEMU plugin.
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

if [ -d "${HOME}/.ctys" -a -d "${HOME}/.ctys/qemu" ];then
    if [ -f "${HOME}/.ctys/qemu/qemu.conf-${MYOS}.sh" ];then
	. "${HOME}/.ctys/qemu/qemu.conf-${MYOS}.sh"
    fi
fi

if [ -d "${MYCONFPATH}/qemu" ];then
    if [ -f "${MYCONFPATH}/qemu/qemu.conf-${MYOS}.sh" ];then
	. "${MYCONFPATH}/qemu/qemu.conf-${MYOS}.sh"
    fi
fi



#
#import configuration keys from local conf-file.
#
_myconf=${CTYSWRAPPERPATH}/${MYCALLNAME%%.sh}
printDBG $S_BIN ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:_myconf=$_myconf"
. ${_myconf}.ctys


#########################
#Start assembly of call.#
#########################


#Check for a supported version
REALSTARTERCALL=`bootstrapGetRealPathname ${STARTERCALL}`

QEMU_MAGIC=$(getQEMUMAGIC ${STARTERCALL})
printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "QEMU_MAGIC  =${QEMU_MAGIC}"

QEMU_VERSION=$(getVersionStrgQEMUALL ${STARTERCALL})
printDBG $S_QEMU ${D_MAINT} $LINENO $BASH_SOURCE "QEMU_VERSION=${QEMU_VERSION}"


#
#Should be set in conf-file
#
STARTERCALL=$(gwhich ${STARTERCALL})
if [ $? -ne 0 ];then
    ABORT=127
    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing:STARTERCALL=${STARTERCALL}"
    printINFO 1 $LINENO $BASH_SOURCE 1 "Probably your configuring only a VM,"
    printINFO 1 $LINENO $BASH_SOURCE 1 "doing so on a non-native platform."
    gotoHell ${ABORT}
fi



#
#Should be set in conf-file
#
WRAPPERCALL=${WRAPPERCALL:-$VDE_VDEQ}
WRAPPERCALL=${WRAPPERCALL:-vdeq}
WRAPPERCALL=$(gwhich ${WRAPPERCALL})
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


EXECALL="${WRAPPERCALL} ";
EXECALL="${EXECALL} ${STARTERCALL} "


#
#Caches the call options(keys only) for current version
#
callOptionsQEMUcacheOpts $STARTERCALL


_check=0;
_print=0;
#ARGSADD=;
#BOOTMODE=VHDD;


while [ -n "$1" ];do
    case $1 in

############################
#START-MANDATORY OPTIONS
######
	'-d')shift;;

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
	    case "$INSTMODE" in
		DEFAULT)
		    INSTMODE=;
		    INSTMODE_SETTINGS=defaults
		    ;;
		'')
		    ;;
		*)
		    INSTMODE_SETTINGS=cli||INSTMODE_SETTINGS=defaults
		    ;;
	    esac
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
	    echo
 	    echo "Current STARTERCALL=$STARTERCALL"
 	    echo
 	    callOptionsQEMUlist $STARTERCALL;
            exit 0;
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


        '--argsadd='*)
	    ARGSADD="${ARGSADD} ${1#*=}";
	    ;;

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

CONSOLE=$(echo ${CONSOLE}|tr 'a-z' 'A-Z');

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
#The socket for access to VDE's virtual switch port: vde_switch
#should be already defined in the shared configuration files.
#
QEMUSOCK=${QEMUSOCK:-/var/tmp/vde_switch0.$USER}
if [ ! -d "${QEMUSOCK}" ];then
    ABORT=127
    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing directory for socket:"
    printERR $LINENO $BASH_SOURCE ${ABORT} " QEMUSOCK=\"${QEMUSOCK}\""
    printERR $LINENO $BASH_SOURCE ${ABORT} "Call \"ctys-setupVDE\""
    gotoHell ${ABORT}
else
    if [ ! -S "${QEMUSOCK}/ctl" ];then
	ABORT=127
	printERR $LINENO $BASH_SOURCE ${ABORT} "Is missing or not a socket: "
	printERR $LINENO $BASH_SOURCE ${ABORT} "  QEMUSOCK=\"${QEMUSOCK}/ctl\""
	printERR $LINENO $BASH_SOURCE ${ABORT} "Call \"ctys-setupVDE\""
	gotoHell ${ABORT}
    fi
fi



#
#inherited by export, but normally as defined here
#should be already defined in the shared configuration files.
# QEMUBIOS=${QEMUBIOS:-$HOME/qemu/pc-bios}
# if [ ! -d "${QEMUBIOS}" ];then
#     ABORT=127
#     printERR $LINENO $BASH_SOURCE ${ABORT} "Missing basic runtime components:"
#     printERR $LINENO $BASH_SOURCE ${ABORT} "  QEMUBIOS=\"${QEMUBIOS}\""
#     gotoHell ${ABORT}
# fi



#
#ATTENTION:
#  One serial port is required in current version for managing the 
#  QEMU VM by monitor commands.
#  This may change in a future version, but is mandatory for this.
#
#This wrapper is expected to continue beeing present, which is OK.
#E.g. when using "vdeq" as wrapper for qemu, this will also call
#"qemu" synchronous.
#The requirement is the availability of an unique identifier, which keeps 
#being unique and could be calculated for the whole lifetime of the 
#final QEMU process.
#Additionally allowing ambiguity of LABEL, due to the "-A" option of ctys.
MYQEMUMONSOCK=`netGetUNIXDomainSocket "$$" "$LABEL" "${QEMUMONSOCK}"`

#
# Probable old junk.
if [ -e "${MYQEMUMONSOCK}" ];then
    printWNG 1 $LINENO $BASH_SOURCE 0 "UNIX-Domain Sockets from previous call detected, "
    printWNG 1 $LINENO $BASH_SOURCE 0 "will be removed:"
    printWNG 1 $LINENO $BASH_SOURCE 0 "MYQEMUMONSOCK=<${MYQEMUMONSOCK}>"
    printWNG 1 $LINENO $BASH_SOURCE 0 "This is an error workaround for vdeq_switch,"
    printWNG 1 $LINENO $BASH_SOURCE 0 "missing remove sockets for removed ports"
    printWNG 1 $LINENO $BASH_SOURCE 0 "CALL:<${CTYS_UNLINK} ${MYQEMUMONSOCK}>"
    ${CTYS_UNLINK} ${MYQEMUMONSOCK}
fi


#
#These settings are required for several reasons.
#
EXECALL="${EXECALL} ${QEMUBIOS:+ -L $QEMUBIOS} "
if [ -n "${NIC}" ];then
    EXECALL="${EXECALL} -net nic,macaddr=${MAC0},model=${NIC} "
    EXECALL="${EXECALL} -net vde,sock=${QEMUSOCK} "
fi
EXECALL="${EXECALL} -name \"${LABEL}\" "

case "${VGADRIVER}" in
    -std-vga)
	if [ "$(callOptionsQEMUcacheCheck '-std-vga')" == "-std-vga" ];then
	    EXECALL="${EXECALL} ${VGADRIVER} "
	else
	    printWNG 1 $LINENO $BASH_SOURCE 1 "Option 'VGADRIVER=$VGADRIVER' is not supported"
	    printWNG 1 $LINENO $BASH_SOURCE 1 "by STARTERCALL=${STARTERCALL}."
	    printWNG 1 $LINENO $BASH_SOURCE 1 "ignoring it for now."
	    printWNG 1 $LINENO $BASH_SOURCE 1 "Try '-vga', or update qemu/qemu-kvm"
	fi
	;;
    -vga*)
	if [ "$(callOptionsQEMUcacheCheck '-vga')" == '-vga' ];then
	    EXECALL="${EXECALL} ${VGADRIVER} "
	else
	    printWNG 1 $LINENO $BASH_SOURCE 1 "Option 'VGADRIVER=$VGADRIVER' is not supported"
	    printWNG 1 $LINENO $BASH_SOURCE 1 "by STARTERCALL=${STARTERCALL}."
	    printWNG 1 $LINENO $BASH_SOURCE 1 "ignoring it for now."
	    printWNG 1 $LINENO $BASH_SOURCE 1 "Try '-vga', or update qemu/qemu-kvm"
	fi
	;;
esac


case ${QEMU_MAGIC} in
    QEMU_090)
	;;
    QEMU_091)
	EXECALL="${EXECALL} $(callOptionsQEMUcacheCheck -no-kqemu) "
	;;
    QEMU_09*)
	EXECALL="${EXECALL} $(callOptionsQEMUcacheCheck -no-kqemu)  "
	;;
    QEMU_012)
	;;
    *)
	;;
esac


#
#Could be ntp, but should be kept.
EXECALL="${EXECALL} ${TIMEOPT} "


#
#These settings should be adapted as required.
EXECALL="${EXECALL} -k ${KBD_LAYOUT} "
EXECALL="${EXECALL} -m ${MEMSIZE} "



#
#Kernel from CLI has higher priority
#
_AX=${KERNELMODE%%\%*}
KERNELIMAGE=${_AX:-$KERNELIMAGE}
#
#External kernel and initrd, when required customize it:
# KERNELIMAGE="yourKernel"
if [ -n "${KERNELIMAGE}" -a ! -f "${KERNELIMAGE}" ];then
    ABORT=127
    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing kernel image:\"${KERNELIMAGE}\""
    gotoHell ${ABORT}
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
if [ -n "${INITRDIMAGE}" -a ! -f "${INITRDIMAGE}" ];then
    ABORT=127
    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing initrd image:\"${INITRDIMAGE}\""
    gotoHell ${ABORT}
fi

#
#Kernel append parameters.
#
APPEND=${KERNELMODE##*\%}



printDBG $S_QEMU ${D_FLOW} $LINENO $BASH_SOURCE "PRE-BOOTMODE:EXECALL=${EXECALL}"
printDBG $S_QEMU ${D_FLOW} $LINENO $BASH_SOURCE "PRE-BOOTMODE:CHECK-IMAGES"
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
LASTPATH="${LASTPATH} ${KERNELIMAGE:+ -kernel $KERNELIMAGE } "
LASTPATH="${LASTPATH} ${INITRDIMAGE:+ -initrd $INITRDIMAGE}"
BOOTMODE=$(echo $BOOTMODE|tr 'a-z' 'A-Z')
case ${BOOTMODE} in
    FDD)
        LASTPATH="${LASTPATH} -boot a"
	if [ ! -f "${FDDIMAGE}" ];then
	    ABORT=127
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing FDD boot device:FDDIMAGE=${FDDIMAGE}"
	    gotoHell ${ABORT}
	fi
	LASTPATH="${LASTPATH} ${FDDIMAGE}"
	;;

    CD)
        LASTPATH="${LASTPATH} -boot d"
	if [ ! -f "${CDIMAGE}" ];then
	    ABORT=127
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing CD boot device:CDIMAGE=${CDIMAGE}"
	    gotoHell ${ABORT}
	fi
	LASTPATH="${LASTPATH} ${CDIMAGE}"
	;;

    DVD)
        LASTPATH="${LASTPATH} -boot d"
	if [ ! -f "${DVDIMAGE}" ];then
	    ABORT=127
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing DVD boot device:DVDIMAGE=${DVDIMAGE}"
	    gotoHell ${ABORT}
	fi
	LASTPATH="${LASTPATH} ${DVDDIMAGE}"
	;;

    VHDD|HDD)
        LASTPATH="${LASTPATH} -boot c"
	if [ -n "${BOOTSRC}" ];then
	    HDDBOOTIMAGE=${BOOTSRC}
	fi
	if [ ! -e "${HDDBOOTIMAGE}" ];then
	    ABORT=127
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing VHDD boot device:HDDBOOTIMAGE=${HDDBOOTIMAGE}"
	    gotoHell ${ABORT}
	fi
	LASTPATH="${LASTPATH} ${HDDBOOTIMAGE}"
	;;

    USB)
        LASTPATH="${LASTPATH} -boot c"
	if [ ! -f "${USBBOOTIMAGE}" ];then
	    ABORT=127
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing USB boot device:USBBOOTIMAGE=${USBBOOTIMAGE}"
	    gotoHell ${ABORT}
	fi
	LASTPATH="${LASTPATH} ${USBBOOTIMAGE}"
	;;

    PXE)
        #
        #reminder for some older versions.
        #
        #EXECALL="${EXECALL} -option-rom ${QEMUBIOS}/pxe-ne2k_pci.bin"
        #
 	EXECALL="${EXECALL} -boot n "
	;;

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
	    HDD*)echo -e '-hdb';;
	    FDD*)echo -e '-fdb';;
	    USB*)echo -e '-hdb';;
	esac
    else
	case "$_im" in
	    HDD*)[ "$_bm" == USB ]&&echo -e '-hdb'||echo -e '-hda';;
	    FDD*)echo -e '-fda';;
	    USB*)[ "$_bm" == HDD ]&&echo -e '-hdb'||echo -e '-hda';;
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
	    HDDDOS)

#
#Check this, for now it's OK.
#Missing BALLON - seek
#
		printFINALCALL 1  $LINENO $BASH_SOURCE "FINAL-EXECCALL" "${QEMUIMG} create -f raw ${_it} ${HDDBOOTIMAGE_INST_SIZE}\""
		if [ "$_check" == "0" ];then
                    #create raw image
		    ${QEMUIMG} create  -f raw ${_it} ${HDDBOOTIMAGE_INST_SIZE} 
		    if [ $? != 0 ];then
			ABORT=127
			printERR $LINENO $BASH_SOURCE ${ABORT} "Creation of image for installation failed"
			printERR $LINENO $BASH_SOURCE ${ABORT} "\"${QEMUIMG} create -f raw ${_it} ${HDDBOOTIMAGE_INST_SIZE}\""
			gotoHell ${ABORT}
		    fi
		fi

		    printFINALCALL 1  $LINENO $BASH_SOURCE "FINAL-EXECCALL" "${CTYS_DD} if=/dev/zero of=${_it} bs=${HDDBOOTIMAGE_INST_BLOCKSIZE} count=${HDDBOOTIMAGE_INST_BLOCKCOUNT}\""
		if [ "$_check" == "0" ];then
		    ${CTYS_DD}  if=/dev/zero of=${_it} bs=${HDDBOOTIMAGE_INST_BLOCKSIZE} count=${HDDBOOTIMAGE_INST_BLOCKCOUNT}
		    if [ $? != 0 ];then
			ABORT=127
			printERR $LINENO $BASH_SOURCE ${ABORT} "Failed to initialize boot image."
			printERR $LINENO $BASH_SOURCE ${ABORT} "\"${CTYS_DD}  if=/dev/zero of=${_it} bs=${HDDBOOTIMAGE_INST_BLOCKSIZE} count=${HDDBOOTIMAGE_INST_BLOCKCOUNT}\""
			gotoHell ${ABORT}
		    fi
		fi
		;;
	    HDD)
		printFINALCALL 1  $LINENO $BASH_SOURCE "FINAL-EXECCALL" "${QEMUIMG} create -f ${QEMU_IMG:-raw} ${_it} ${HDDBOOTIMAGE_INST_SIZE}\""
		if [ "$_check" == "0" ];then
                    #create raw image
		    ${QEMUIMG} create  -f ${QEMU_IMG:-raw} ${_it} ${HDDBOOTIMAGE_INST_SIZE} 
		    if [ $? != 0 ];then
			ABORT=127
			printERR $LINENO $BASH_SOURCE ${ABORT} "Creation of image for installation failed"
			printERR $LINENO $BASH_SOURCE ${ABORT} "\"${QEMUIMG} create -f ${QEMU_IMG:-raw} ${_it} ${HDDBOOTIMAGE_INST_SIZE}\""
			gotoHell ${ABORT}
		    fi
		fi

# 		printFINALCALL 1  $LINENO $BASH_SOURCE "FINAL-EXECCALL"  "${CTYS_DD} if=/dev/zero of=${_it} bs=${HDDBOOTIMAGE_INST_BLOCKSIZE} count=${HDDBOOTIMAGE_INST_BLOCKCOUNT}\""
# 		if [ "$_check" == "0" ];then
# 		    ${CTYS_DD}  if=/dev/zero of=${_it} bs=${HDDBOOTIMAGE_INST_BLOCKSIZE} count=${HDDBOOTIMAGE_INST_BLOCKCOUNT}
# 		    if [ $? != 0 ];then
# 			ABORT=127
# 			printERR $LINENO $BASH_SOURCE ${ABORT} "Failed to initialize boot image."
# 			printERR $LINENO $BASH_SOURCE ${ABORT} "\"${CTYS_DD}  if=/dev/zero of=${_it} bs=${HDDBOOTIMAGE_INST_BLOCKSIZE} count=${HDDBOOTIMAGE_INST_BLOCKCOUNT}\""
# 			gotoHell ${ABORT}
# 		    fi
# 		fi
		;;
	    FDD)echo -e '-fdb';;
	    USB)
		if [ $? != 0 ];then
		    ABORT=127
		    printERR $LINENO $BASH_SOURCE ${ABORT} "Creation an file image for USB is not supported."
		    gotoHell ${ABORT}
		fi
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
		;;
	    USB*)
                #create raw image
		case "$INSTSTAGE" in
		    INIT)
			if [ "$_print" == "1" ];then
			    echo "#Create a file-image :\"${_it}\""
			    printFINALCALL 1  $LINENO $BASH_SOURCE "FINAL-EXECCALL" "\"${CTYS_DD} if=/dev/zero of=${_it} bs=512 count=2880\""
			fi
			if [ "$_check" == "0" ];then
			    ${CTYS_DD} if=/dev/zero of=${_it} bs=512 count=2880
			    if [ $? != 0 ];then
				ABORT=127
				printERR $LINENO $BASH_SOURCE ${ABORT} "Creation of image for installation failed"
				printERR $LINENO $BASH_SOURCE ${ABORT} "\"${CTYS_DD} if=/dev/zero of=${_it} bs=512 count=2880\""
				gotoHell ${ABORT}
			    fi
			fi
			;;
		esac
		if [ "$_print" == "1" ];then
		    echo "#Continue now to proceed on raw-device from within GuestOS."
		fi
		;;
	    CD*|DVD*)
		ABORT=127
		printERR $LINENO $BASH_SOURCE ${ABORT} "Creation of CDROM/DVD boot media is not yet supported."
		gotoHell ${ABORT}
		;;
	esac
    fi
}

#
printDBG $S_QEMU ${D_FLOW} $LINENO $BASH_SOURCE "PRE-INSTMODE:EXECALL=${EXECALL}"
printDBG $S_QEMU ${D_FLOW} $LINENO $BASH_SOURCE "PRE-INSTMODE:CHECK-IMAGES"
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
	LASTPATH="${LASTPATH} -boot a "
	LASTPATH="${LASTPATH} -fda ${INSTSRC}"

        #Requires INSTTARGET at last position for conf-detection.
	LASTPATH="${LASTPATH} ${_myMode} ${INSTTARGET} "
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
	LASTPATH="${LASTPATH} -boot c "
	LASTPATH="${LASTPATH} -hda ${INSTSRC}"

        #Requires INSTTARGET at last position for conf-detection.
	LASTPATH="${LASTPATH} ${_myMode} ${INSTTARGET} "
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
	LASTPATH="${LASTPATH} -boot c "
	LASTPATH="${LASTPATH} -hda ${INSTSRC}"

        #Requires INSTTARGET at last position for conf-detection.
	LASTPATH="${LASTPATH} ${_myMode} ${INSTTARGET} "
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
	LASTPATH="${LASTPATH} -boot d "
	LASTPATH="${LASTPATH} -cdrom ${INSTSRC}"

        #Requires INSTTARGET at last position for conf-detection.
	LASTPATH="${LASTPATH} ${_myMode} ${INSTTARGET} "
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

        #
        #reminder for some older versions.
        #
        #EXECALL="${EXECALL} -option-rom ${QEMUBIOS}/pxe-ne2k_pci.bin"
        #
 	EXECALL="${EXECALL} -boot n "

        #Requires INSTTARGET at last position for conf-detection.
	LASTPATH="${LASTPATH} ${_myMode} ${INSTTARGET} "
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



#
#Optional data floppy
#
if [ -n "${FDB}" -a -f "${FDB}" ];then
    EXECALL="${EXECALL} -fdb ${FDB} "
fi


#
#Optional data drive
#
if [ -n "${HDB}" -a -f "${HDB}" ];then
    EXECALL="${EXECALL} -hdb ${HDB} "
fi


#
#Optional data drive
#
if [ -n "${HDC}"  -a -f "${HDC}" ];then
    EXECALL="${EXECALL} -hdc ${HDC} "
fi


#
#Optional data drive
#
if [ -n "${HDD}"  -a -f "${HDD}" ];then
    EXECALL="${EXECALL} -hdd ${HDD} "
fi

#
#Optional CPU architecture
#
if [ -n "${CPU}" ];then
    EXECALL="${EXECALL} -cpu ${CPU} ";
else
    #anyhow...for suprising pop-ups of x86-types
    EXECALL="${EXECALL} -cpu qemu32 ";
fi

#
#Optional number of simulated CPUs/Cores
#
if [ -n "${SMP}" ];then
    EXECALL="${EXECALL} -smp ${SMP} "
fi



printDBG $S_QEMU ${D_FLOW} $LINENO $BASH_SOURCE "PRE-CONSOLE:EXECALL=${EXECALL}"
case ${CONSOLE} in
    SDL)
	EXECALL="${EXECALL} $(callOptionsQEMUcacheCheck -no-quit) "

 	if [ -n "${MYQEMUMONSOCK}" ];then
            EXECALL="${EXECALL} -serial mon:unix:${MYQEMUMONSOCK},server,nowait "
	fi

	EXECALL="${EXECALL} -serial vc:1000x300"
	EXECALL="${EXECALL} ${ARGSADD} ${LASTPATH}"
	;;

    VNC)
	if [ -z "${VNCACCESSDISPLAY}" ];then
	    ABORT=127
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing --vncaccessdisplay="
	    gotoHell ${ABORT}
	fi

 	if [ -n "${MYQEMUMONSOCK}" ];then
            EXECALL="${EXECALL} -serial mon:unix:${MYQEMUMONSOCK},server,nowait "
	fi
	EXECALL="${EXECALL} -daemonize "
	EXECALL="${EXECALL} -vnc :${VNCACCESSDISPLAY}  ${ARGSADD} ${LASTPATH}"
	;;

    CLI0)
	EXECALL="${EXECALL} -nographic  ${ARGSADD} ${LASTPATH}"
	;;

    CLI|XTERM|GTERM|EMACSM|EMACS|EMACSAM|EMACSA)
	EXECALL="${EXECALL} -daemonize "
	if [ -z "${VNCACCESSDISPLAY}" ];then
	    ABORT=127
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing --vncaccessdisplay="
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Is required at least as dummy."
	    gotoHell ${ABORT}
	fi
	EXECALL="${EXECALL} -vnc :${VNCACCESSDISPLAY} " #required at least as dummy
 	if [ -n "${MYQEMUMONSOCK}" ];then
            EXECALL="${EXECALL} -serial mon:unix:${MYQEMUMONSOCK},server,nowait "
	fi
	EXECALL="${EXECALL} ${ARGSADD} ${LASTPATH}"
        ;;

    NONE)
	printDBG $S_QEMU ${D_FLOW} $LINENO $BASH_SOURCE "NONE:no console"
	;;
    *)
	ABORT=127
	printERR $LINENO $BASH_SOURCE ${ABORT} "Unknown display --console=\"${CONSOLE}\""
	gotoHell ${ABORT}
	;;
esac

printDBG $S_QEMU ${D_FLOW} $LINENO $BASH_SOURCE "EVAL:EXECALL=${EXECALL}"

if [ "$_print" == "1" ];then
    echo '###########################'
    echo '#Display call             #'
    echo '###########################'
    echo
    echo
    echo "QEMU_VERSION      = \"${QEMU_VERSION}\""
    echo "QEMU_MAGIC        = \"${QEMU_MAGIC}\""
    echo "QEMU_ACCELERATOR = \"$(getACCELERATOR_QEMU ${STARTERCALL})\""
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

printFINALCALL 0  $LINENO $BASH_SOURCE "FINAL-EXECCALL" "${EXECALL}"
if [ "$_check" == "0" ];then
    eval "${EXECALL}"
    _ret=$?
    if [ $_ret -ne 0 ];then
	printERR $LINENO $BASH_SOURCE ${ABORT} "ExecFailed(exit=$_ret):EXECALL=${EXECALL}"
    fi
fi
gotoHell $_ret

