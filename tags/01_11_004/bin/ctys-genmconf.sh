#!/bin/bash
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
#     Copyright (C) 2007,2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
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
#  ctys-genmconf.sh
#
#AUTHOR:
AUTHOR="Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org"
#
#FULLNAME:
FULLNAME="Unified Sessions Manager"
#
#CALLFULLNAME:
CALLFULLNAME="Generate Machine configuration"
#
#LICENCE:
LICENCE=GPL3
#
#TYPE:
#  bash-script
#
#VERSION:
VERSION=01_11_003
#DESCRIPTION:
#  Utility of project ctys for generation of PM data supporting 
#  ENUMERATE. This is seperated, due to some of the data requires
#  root privileges for read operations.
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
. ${MYLIBPATH}/lib/misc.sh
. ${MYLIBPATH}/lib/network/network.sh
. ${MYLIBPATH}/lib/groups.sh
. ${MYLIBPATH}/lib/hw/hook.sh

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



PROGRESS=;
TSTFS=;
ROUNDS=;


function generate () {
    local _timeStart=$(getCurTime)

    function getLocalStackCap () {
    #xen
	local _stackap=`ctys ${C_DARGS} -a info|awk -F':' 'BEGIN{x="";}/PM-CAPABILI/||/VM-CAPABILI/{printf("%s%s",x,$2);x=",";}'`
	echo -n "${_stackap}"
    }


###
    case ${CATEGORY} in
	PM)
	    if [ -e "${_VMCONF}" ];then
		printERR $LINENO $BASH_SOURCE 2 "PM choosen, but found existing:"
		printERR $LINENO $BASH_SOURCE 2 "  VMCONF=\"${_VMCONF}\""
		printERR $LINENO $BASH_SOURCE 2 "Remove manually or change to VM"
		gotoHell 2;
	    fi
	    ;;
	VM)
	    if [ -e "${_PMCONF}" ];then
		printERR $LINENO $BASH_SOURCE 2 "VM choosen, but found existing:"
		printERR $LINENO $BASH_SOURCE 2 "  PMCONF=\"${_PMCONF}\""
		printERR $LINENO $BASH_SOURCE 2 "Remove manually or change to PM"
		gotoHell 2;
	    fi
	    ;;
    esac


###
    if [ -n "$fileout" ];then
	CTYSDIR=/etc/ctys.d
	if [ ! -d "${CTYSDIR}" ];then
	    mkdir "${CTYSDIR}"
	fi

	if [ ! -d "${CTYSDIR}" ];then
	    echo "ERROR:Cannot create missing directory:\"${CTYSDIR}\""
	    exit 1;
	fi

	touch "${MCONF}" 2>/dev/null
	if [ $? -ne 0 ];then
	    printERR $LINENO $BASH_SOURCE 1 "No access permission:MCONF=\"${MCONF}\""
	    gotoHell 1;
	fi

	_STACKLEVELF="${MCONF%/*}/STACKLEVEL.assume"
	touch "${_STACKLEVELF}" 2>/dev/null
	if [ $? -ne 0 ];then
	    printERR $LINENO $BASH_SOURCE 1 "No access permission:STACKLEVELF=\"${_STACKLEVELF}\""
	    gotoHell 1;
	fi
    fi



###
    UUID=;
    if [ -n "${uuidg}" ];then
	case "${MYOS}" in
	    Linux)
		CTYS_UUID=`getPathName $LINENO $BASH_SOURCE ERROR uuidgen /usr/bin`
		callErrOutWrapper $LINENO $BASH_SOURCE ${CTYS_UUID}>/dev/null
		if [ $? -ne 0 ];then
		    printERR $LINENO $BASH_SOURCE 1 "No access to \"uuidgen\", but continue."
		else
		    UUID=`${CTYS_UUID}|sed 's/-//g'`
		fi
		[ -z "$VIRSH" ]&&VIRSH=`getPathName $LINENO $BASH_SOURCE WARNINGEXT virsh /usr/bin`
		;;
	    FreeBSD|OpenBSD)
		CTYS_UUID=`getPathName $LINENO $BASH_SOURCE ERROR uuid /usr/local/bin`
		callErrOutWrapper $LINENO $BASH_SOURCE ${CTYS_UUID}>/dev/null
		if [ $? -ne 0 ];then
		    printERR $LINENO $BASH_SOURCE 1 "No access to \"uuid\", but continue."
		else
		    UUID=`${CTYS_UUID}|sed 's/-//g'`
		fi
		;;
	    SunOS)
		printWNG 1 $LINENO $BASH_SOURCE 1 "UUID generation currently for ${MYOS} not supported"
	        UUID=;
                ;;
	    *) ;;
	esac
    else
	case "${MYOS}" in
	    Linux)
		CTYS_UUID=`getPathName $LINENO $BASH_SOURCE WARNING dmidecode /usr/sbin`
		callErrOutWrapper $LINENO $BASH_SOURCE ${CTYS_UUID}>/dev/null
		if [ $? -ne 0 ];then
		    printWNG 1 $LINENO $BASH_SOURCE 1 "No access to \"dmidecode\", cannot fetch UUID."
		else
		    UUID=`${CTYS_UUID}|awk '/UUID/{if(NF==2)print $2;}'|sed 's/-//g'`
		    if [ -z "${UUID}" ];then
			printWNG 1 $LINENO $BASH_SOURCE 1 "Access granted to \"dmidecode\", but UUID not present."
			printWNG 1 $LINENO $BASH_SOURCE 1 "Check your HW, if appropriate use \"-u\"."
		    fi
		fi
		[ -z "$VIRSH" ]&&VIRSH=`getPathName $LINENO $BASH_SOURCE WARNINGEXT virsh /usr/bin`
		;;
	    FreeBSD|OpenBSD)
		CTYS_UUID=`getPathName $LINENO $BASH_SOURCE WARNING dmidecode /usr/local/sbin`
		callErrOutWrapper $LINENO $BASH_SOURCE ${CTYS_UUID}>/dev/null
		if [ $? -ne 0 ];then
		    printWNG 1 $LINENO $BASH_SOURCE 1 "No access to \"dmidecode\", cannot fetch UUID."
		else
		    UUID=`${CTYS_UUID}|awk '/UUID/{if(NF==2)print $2;}'|sed 's/-//g'`
		    if [ -z "${UUID}" ];then
			printWNG 1 $LINENO $BASH_SOURCE 1 "Access granted to \"dmidecode\", but UUID not present."
			printWNG 1 $LINENO $BASH_SOURCE 1 "Check your HW, if appropriate use \"-u\"."
		    fi
		fi
		;;
	    SunOS)
		CTYS_UUID=`getPathName $LINENO $BASH_SOURCE ERROR getSolarisUUID.sh ${MYLIBEXECPATH}`
		callErrOutWrapper $LINENO $BASH_SOURCE ${CTYS_UUID}>/dev/null
		if [ $? -ne 0 ];then
		    printERR $LINENO $BASH_SOURCE 1 "No access to \"uuid\", but continue."
		else
		    UUID=`${CTYS_UUID}|sed 's/-//g'`
		fi
		;;
	    *)  UUID=;;
	esac
    fi


    if [ -z "${key}" ];then
    #local PM
	_HOST=${MYHOST}
	ID=${MCONF};
	OS=${MYOS};
    else
	if [ -n "${mac}" ];then
	    MAC="${mac}"
	else
	    MAC=`ctys-vhost.sh ${C_DARGS} -C macmaponly -o MAC $key`;
	fi
	if [ -n "${ip}" ];then
	    IP="${ip}"
	else
	    IP=`ctys-vhost.sh ${C_DARGS} -C macmaponly -o TCP $key`;
	fi
	if [ -z "${uuid}" -a -z "${uuidg}" ];then
	    UUID=`ctys-vhost.sh ${C_DARGS} -C macmap -o UUID $key`;
	fi
	_HOST=`ctys-vhost.sh ${C_DARGS} -C macmap -o DNS $key`;
	_ID=`ctys-vhost.sh ${C_DARGS} -C macmap -o IDS $key`;
	OS=`ctys-vhost.sh ${C_DARGS} -C macmap -o OS $key`;
    fi



    {

	printf "#@#-----------------------------------------------------------\n";
	printf "#@#Created by      = $0\n";
	printf "#@#CTYSREL         = $CTYSREL\n";
	printf "#@#VERNO           = 01.01.001a01\n";
	printf "#@#DATE            = $DATETIME\n";
	printf "#@#-----------------------------------------------------------\n";
	printf "\n";
	printf "#@#The next entry is required as literally \"#@#MAGICID-<plugin>\"\n";
	printf "#@#where <plugin> is the enumerating plugin name.\n";
	printf "#@#MAGICID-${MYOS}\n";
	printf "#@#HOST            = \"${_HOST}\"\n";
	printf "#@#LABEL           = \"${_HOST%%.*}\"\n";
	printf "#@#ID              = \"${ID}\"\n";
	printf "#@#UUID            = \"${UUID}\"\n";
	printf "#@#VNCPORT         = \n";
	printf "#@#VNCBASE         = \n";
	printf "#@#VNCDISPLAY      = \n";
	printf "#@#SPORT           = \n";
	_ugid="`getMyUGID`"
	printf "#@#UID             = \"${_ugid%;*}\"\n";
	printf "#@#GID             = \"${_ugid#*;}\"\n";
	printf "#@#DIST            = \"${MYDIST}\"\n";
	printf "#@#DISTREL         = \"${MYREL}\"\n";
	printf "#@#OS              = \"${OS}\"\n";
	printf "#@#OSREL           = \"${MYOSREL}\"\n";
	printf "#@#SERNO           = $DATETIME\n";
	printf "#@#CATEGORY        = \"${CATEGORY}\"\n";
	printf "#@#ARCH            = \"${MYARCH}\"\n";
	printf "#@#PLATFORM        = \"%s\"\n" "`getPLATFORM`";
	printf "#@#VMSTATE         = \"ACTIVE\"\n";

	if [ "${CATEGORY}" == "PM" ];then
	    printf "#@#EXECLOCATION    = \"LOCAL\"\n";
	    printf "#@#RELOCCAP        = \"FIXED\"\n";
	else
	    printf "#@#HYPERREL        = \"\"\n";
	    printf "#@#EXECLOCATION    = \"LOCAL\"\n";
	    printf "#@#RELOCCAP        = \"PINNED\"\n";
	fi

#    printf "#@#SSHPORT         = \"22\"\n";

	_STACKCAP="`getLocalStackCap`";
	printf "#@#STACKCAP        = \"%s\"\n" "${_STACKCAP}";

	printf "#@#STACKREQ        = \"\"\n";

	printINFO 1 $LINENO $BASH_SOURCE 1 "Evaluate HW capacity now, including basic"
	printINFO 1 $LINENO $BASH_SOURCE 1 "performance measurement. This could require"
	printINFO 1 $LINENO $BASH_SOURCE 1 "several minutes, particularly on slow machines."
	if [ "${PROGRESS}" != 1 ];then
	    printINFO 1 $LINENO $BASH_SOURCE 1 "Use '--progress' for verbose processing."
	fi

	_HWCAP=$(getHWCAP);
	_HWCAP="${_HWCAP},$(getPerfIDX.sh -X ${PROGRESS:+--progress} ${TSTFS:+--testfs=$TSTFS} ${ROUNDS:+--rounds=$ROUNDS})";

	printf "#@#HWCAP           = \"%s\"\n" "${_HWCAP}";

	printf "#@#HWREQ           = \"\"\n";


	_buf0="`getCPUinfo.sh`"; _buf0=${_buf0#*CPU:}; _buf0=${_buf0%%x*};
	_buf1="`getMEMinfo.sh`"; _buf1=${_buf1#*RAM:}; _buf1=${_buf1%%,*};
	if [ "${CATEGORY}" == "PM" ];then
	    if [ "${_STACKCAP//xen-}" != "${_STACKCAP}" ];then
		_buf=;
		if [ "${MYOS}" == "Linux" -a -n "${VIRSH}" ];then
		    _buf=`${VIRSH} nodeinfo|awk  '/^CPU\(s\):/{printf("%s",$2);}'`
		    _buf0="${_buf0}/${_buf}"
		else
		    _buf0="${_buf0}/${_buf0}"
		fi

		_buf=;
		if [ "${MYOS}" == "Linux" -a -n "${VIRSH}" ];then
		    _buf=`${VIRSH} nodeinfo|awk  '/^Memory size/{printf("%sM",$3/1024);}'`
		    _buf1="${_buf1}/${_buf}"
		else
		    _buf1="${_buf1}/${_buf1}"
		fi
	    fi
	fi
	printf "#@#VCPU            = \"%s\"\n" "${_buf0}";
	printf "#@#VRAM            = \"%s\"\n" "${_buf1}";


	printf "\n";
	printf "#@#This value represents the KVM - here Keyboard-Mouse-Video -  port\n";
	printf "#@#CONSOLE_KVM     = \n";
	printf "\n";
	printf "#@#This value represents the serial port\n";
	printf "#@#CONSOLE_COM     = \n";

	printf "\n";

	defaultgw="`netGetDefaultGW`";
	printf "#@#GATEWAY         = \"${defaultgw}\"\n";
	printf "\n";
	printf "#@#Network interface, following is supported:\n";
	printf "#@#- One IP-address for each Etherner\n";
	printf "#@#- Multiple IP-addresses for arbitrary Ethernets\n";
	printf "#@#- MAC-address only\n";
	printf "#@#\n";
	printf "#@#CSTRG           = \"Generated%%by%%genmconf.\"\n";
	printf "#@#USTRG           = \"\"\n";

	if [ -z "${key}" ];then
	    cnt=0;
	    for i in `netGetIFlst ${range} CONFIG`;do
		printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:i=<$i>"
		mac=${i%%=*};      buf=${i##*=}
		ip=${buf%%\%*};    buf=${buf#*\%}
		mask=${buf%%\%*};  buf=${buf#*\%}
		name=${buf%%\%*}
		sshplst=`netGetSSHPORTlst ${ip}`
		relay=`netListBridges ${name}`
		ifdat="${ip}%${mask}%${relay}%${name}%${sshplst}%${defaultgw}"

		printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:ifdat=<$ifdat>"

		printf "#@#MAC$((cnt))             = \"${mac}\"\n";
		printf "#@#IP$((cnt))              = \"%s\"\n" ${ifdat};
		let cnt++;
	    done
	else
	    printf "#@#MAC             = \"${MAC}\"\n";
	    printf "#@#IP              = \"${IP}\"\n";
	fi
    }|\
    {
	if [ -n "${fileout}" ];then
#	    cat >"${MCONF}"
	    tee "${MCONF}"
	    if [ ! -f "${MCONF}" -o ! -w "${MCONF}" ];then
		printERR $LINENO $BASH_SOURCE 1 "Creation failed:MCONF=\"${MCONF}\""
		gotoHell 1;
	    fi
	else 
	    cat
	fi
    }

    printf "\n";


#
#temporary workaround
#
    {
	case $CATEGORY in
	    PM)
		_STACKLEVEL="0";
		printINFO 2 $LINENO $BASH_SOURCE 1 "Temporary Workaround:"
		printINFO 2 $LINENO $BASH_SOURCE 1 "  Manual management of static stack-levels:"
		printINFO 2 $LINENO $BASH_SOURCE 1 "    STACKLEVEL=\"${_STACKLEVEL}\""
		printINFO 2 $LINENO $BASH_SOURCE 1 "  PM is defined to be fixed, do not change this."
		printf "#@#STACKLEVEL      = \"%s\"\n" "${_STACKLEVEL}";

		printINFO 1 $LINENO $BASH_SOURCE 1 ""
		printINFO 1 $LINENO $BASH_SOURCE 1 "PM base information is generated."
		printINFO 1 $LINENO $BASH_SOURCE 1 "The following values may need to be adapted:"
		printINFO 1 $LINENO $BASH_SOURCE 1 ""
		printINFO 1 $LINENO $BASH_SOURCE 1 "  HWCAP"
		printINFO 1 $LINENO $BASH_SOURCE 1 "  HWREQ (for mobile boot devices)"
		printINFO 1 $LINENO $BASH_SOURCE 1 ""
		;;
	    VM)
		_STACKLEVEL="1";
		printINFO 2 $LINENO $BASH_SOURCE 1 "Temporary Workaround:"
		printINFO 2 $LINENO $BASH_SOURCE 1 "  Manual management of static stack-levels:"
		printINFO 2 $LINENO $BASH_SOURCE 1 "    Default: STACKLEVEL=\"${_STACKLEVEL}\""
		printINFO 2 $LINENO $BASH_SOURCE 1 "  Adapt manually to required values."
		printINFO 2 $LINENO $BASH_SOURCE 1 "  =>\"${MCONF%/*}/STACKLEVEL.assume\""
		printf "#@#STACKLEVEL      = \"%s\"\n" "${_STACKLEVEL}";

		printINFO 1 $LINENO $BASH_SOURCE 1 ""
		printINFO 1 $LINENO $BASH_SOURCE 1 "VM base information is generated."
		printINFO 1 $LINENO $BASH_SOURCE 1 "The following values may need to be adapted:"
		printINFO 1 $LINENO $BASH_SOURCE 1 ""
		printINFO 1 $LINENO $BASH_SOURCE 1 "  HYPERREL"
		printINFO 1 $LINENO $BASH_SOURCE 1 "  EXECLOCATION"
		printINFO 1 $LINENO $BASH_SOURCE 1 "  RELOCCAP"
		printINFO 1 $LINENO $BASH_SOURCE 1 "  STACKCAP"
		printINFO 1 $LINENO $BASH_SOURCE 1 "  STACKREQ"
		printINFO 1 $LINENO $BASH_SOURCE 1 "  HWCAP"
		printINFO 1 $LINENO $BASH_SOURCE 1 "  HWREQ"
		printINFO 1 $LINENO $BASH_SOURCE 1 ""
		;;
	    *)
		printERR $LINENO $BASH_SOURCE 1 "ERROR:Unknown machine type:\"$1\""
		gotoHell 1;
		;;
	esac
	local _timeEnd=$(getCurTime)

    }|\
    {
	if [ -n "${fileout}" ];then
	    cat >"${MCONF%/*}/STACKLEVEL.assume"
#	    tee >"${MCONF%/*}/STACKLEVEL.assume"
	    if [ ! -f "${_STACKLEVELF}" -o ! -w "${_STACKLEVELF}" ];then
		printERR $LINENO $BASH_SOURCE 1 "Creation failed:STACKLEVELF=\"${_STACKLEVELF}}\""
		gotoHell 1;
	    fi
	else 
	    cat
	fi
    }
}




CATEGORY=$(getVMinfo);
CATEGORY=${CATEGORY:-PM};
CTYSDIR=${CTYSDIR:-/etc/ctys.d}
case ${CATEGORY} in
    VM)
	MCONF=${CTYSDIR}/vm.conf
	;;
    *)
	MCONF=${CTYSDIR}/pm.conf
	;;
esac

_PMCONF=${CTYSDIR}/pm.conf
_VMCONF=${CTYSDIR}/vm.conf
_ARGS=;
_ARGSCALL=$*;
range="WITHIP";
RUSER=;
_RUSER0=;

while [ -n "$1" ];do
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:\${1}=<${1}>"
    case $1 in
	'-l')shift;RUSER=$1;;

	'-r')shift;
	    range=$1;
	    case ${range} in
		[aA][lL][lL])range=ALL;;
		[wW][iI][tT][hH][iI][pP])range=WITHIP;;
		[wW][iI][tT][hH][mM][aA][cC])range=WITHMAC;;
		*)
		    printERR $LINENO $BASH_SOURCE 1 "Range unknown:range=\"${range}\""
		    gotoHell 1;
		    ;;
	    esac
	    ;;

	'-P')fileout=1;;
	'-k')shift;key=$1;;
	'-I')shift;ip=$1;;
	'-u')uuidg=1;;
	'-U')shift;uuid=$1;;
	'-M')shift;mac=$1;;

	--progress)PROGRESS=1;;


	--testfs|--testfs=*)
            TSTFS=${1#*=}; if [ "${1}" == "${TSTFS}" ];then shift; TSTFS=$1; fi
	    ;;

	--rounds|--rounds=*)
            ROUNDS=${1#*=}; if [ "${1}" == "${ROUNDS}" ];then shift; ROUNDS=$1; fi
	    ;;


	'-x')shift;_type=$1;
 	    case $_type in
 		[vV][mM])
 		    CATEGORY=VM;
		    _VMCONF=${CTYSDIR}/vm.conf
		    MCONF=${CTYSDIR}/vm.conf
 		    ;;
		[pP][mM])
		    CATEGORY=PM;
		    _PMCONF=${CTYSDIR}/pm.conf
		    MCONF=${CTYSDIR}/pm.conf
		    ;;
 	    esac
	    ;;

	'-H'|'--helpEx'|'-helpEx')shift;_HelpEx="${1:-$MYCALLNAME}";;
	'-h'|'--help'|'-help')_showToolHelp=1;;
	'-V')_printVersion=1;;
	'-X')C_TERSE=1;;

	'-d')shift;;

	-*)
	    ABORT=1;
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Unknown option <$1>"
	    gotoHell ${ABORT}
	    ;;

	*)
	    _ARGS="${_ARGS} ${1}"
	    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_ARGS=${_ARGS}"
	    ;;

    esac
    shift
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


#
#2. final stage of remote-redirection from the execution-gateway, could be after multiple hops
#
_RARGS=${_ARGSCALL//$_ARGS/}
_MYLBL=${MYCALLNAME}-${MYUID}-${DATE}
printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_ARGS =<$_ARGS>"
printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_RARGS=<$_RARGS>"
_RARGS=${_RARGS//\%/\%\%}
_RARGS=${_RARGS//,/,,}
_RARGS=${_RARGS//:/::}
_RARGS=${_RARGS//  / }
_RARGS=${_RARGS//  / }
_RARGS=${_RARGS// /\%}
printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_RARGS=<$_RARGS>"
printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_MYLBL=<$_MYLBL>"

if [ -z "${_ARGS}" ];then
    generate
else
    if [ "$C_TERSE" != 1 ];then
	printINFO 1 $LINENO $BASH_SOURCE 1 "Remote execution${RUSER:+ as \"$RUSER\"} on:${_ARGS}"
    fi
    ctys ${C_DARGS} -t cli -a create=l:${_MYLBL},cmd:${MYCALLNAME}${_RARGS:+%$_RARGS} ${RUSER:+-l $RUSER} ${_ARGS}
fi
