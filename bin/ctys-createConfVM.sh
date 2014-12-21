#!/bin/bash
########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_005
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
#  ctys-createConfVM.sh
#
#AUTHOR:
AUTHOR="Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org"
#
#FULLNAME:
FULLNAME="Unified Sessions Manager"
#
#CALLFULLNAME:
CALLFULLNAME="Create new configuration file for VirtualMachines"
#
#LICENCE:
LICENCE=GPL3
#
#TYPE:
#  bash-script
#
#VERSION:
VERSION=01_11_005
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
TARGET_OS_SOON="OpenBSD+FreeBSD+Linux"

#to be tested - might be almsot OK - but for now FFS
#...probably some difficulties with desktop-switching only?!
TARGET_OS_FFS="ffs."

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
# if [ "${*}" != "${*//-V/}" ];then
#     if [ -n "${C_TERSE}" ];then
# 	echo -n ${VERSION}
#     else
# 	echo "$0: VERSION=${VERSION}"
#     fi
#     exit 0
# fi


. ${MYLIBPATH}/lib/misc.sh
. ${MYLIBPATH}/lib/help/help.sh
. ${MYLIBPATH}/lib/network/network.sh
. ${MYLIBPATH}/lib/hw/hook.sh
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



#
#dummy stubs for VMW avoids for now hook of CORE
#
function getVNCACCESSPORT () { return; }
function getGUESTVRAM () { return; }


#early prefetch
_ty=`echo " $* "| sed -n 's/([^)]*)//g;s/^.* -t/-t/;s/-t \([a-zA-Z0-9]*\) .*$/\1/p'|tr '[:lower:]' '[:upper:]'`
printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_ty=$_ty"
if [ -n "${_ty// /}" ];then
    C_SESSIONTYPE="${_ty}"
else
    C_SESSIONTYPE="${C_SESSIONTYPE:-QEMU}"
    printINFO 2 $LINENO $BASH_SOURCE 1 "Setting default:C_SESSIONTYPE='${C_SESSIONTYPE:-QEMU}'"

fi
printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:C_SESSIONTYPE=$C_SESSIONTYPE"
C_SESSIONTYPE=$(echo "$C_SESSIONTYPE"| tr '[:lower:]' '[:upper:]')
C_SESSIONTYPE=${C_SESSIONTYPE// /}


#
#activate final execution checks
C_EXECLOCAL=1
case ${C_SESSIONTYPE} in
    XEN)
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
	. ${MYLIBPATH}/lib/libXENbase.sh
	;;
    QEMU)
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
	. ${MYLIBPATH}/lib/libQEMUbase.sh
	;;
    VMW)
	if [ -d "${HOME}/.ctys" -a -d "${HOME}/.ctys/vmw" ];then
	    if [ -f "${HOME}/.ctys/vmw/vmw.conf-${MYOS}.sh" ];then
		. "${HOME}/.ctys/vmw/vmw.conf-${MYOS}.sh"
	    fi
	fi

	if [ -d "${MYCONFPATH}/vmw" ];then
	    if [ -f "${MYCONFPATH}/vmw/vmw.conf-${MYOS}.sh" ];then
		. "${MYCONFPATH}/vmw/vmw.conf-${MYOS}.sh"
	    fi
	fi
	. ${MYLIBPATH}/lib/libVMWserver2.sh
	. ${MYLIBPATH}/lib/libVMWconf.sh
	;;
    *)
	ABORT=1;
	printERR $LINENO $BASH_SOURCE ${ABORT} "Sessiontype not supported:C_SESSIONTYPE=${C_SESSIONTYPE}"
	gotoHell ${ABORT}
	;;
esac


#########################################################################
#plugins - project specific commons and feature plugins                 #
#########################################################################
PLUGINPATHS=${MYINSTALLPATH}/plugins/CORE
LD_PLUGIN_PATH=${LD_PLUGIN_PATH}:${PLUGINPATHS}
MYROOTHOOK=${MYINSTALLPATH}/plugins/hook.sh
if [ ! -f "${MYROOTHOOK}" ];then 
    ABORT=2
    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing p
    ackages hook: hook=${MYROOTHOOK}"
    gotoHell ${ABORT}
fi
. ${MYROOTHOOK}
initPackages "${MYROOTHOOK}"


################################################################
#    Default definitions - User-Customizable  from shell       #
################################################################


#
#Load default values for configuration.
#
#Source pre-set environment from user
if [ -f "${HOME}/.ctys/ctys-createConfVM.d/defaults-${C_SESSIONTYPE}.ctys" ];then
    . "${HOME}/.ctys/ctys-createConfVM.d/defaults-${C_SESSIONTYPE}.ctys"
fi

#Source pre-set environment from installation 

if [ -f "${MYCONFPATH}/ctys-createConfVM.d/defaults-${C_SESSIONTYPE}.ctys" ];then
    . "${MYCONFPATH}/ctys-createConfVM.d/defaults-${C_SESSIONTYPE}.ctys"
else
    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "Cannot load system defaults, just check it."
fi


AUTO_WITH_DEFAULTS_ALL=;
CONTINUE_WITH_OPTDEFAULTS=;
function getAttrVal () {
    local _name=$1;
    local _default=$2;
    local _type=${3:-OPTIONAL};
    local _pref=${4:-};
    local _val=;
    local _flow=n;
    local rcnt=0;
    while [ "$_flow" != y -a -n "$_flow" ];do
	if [ "$_type" != MANDATORY ];then
	    echo -n "${_pref}$_name=[${_default}]"; 
	else
	    echo -e -n "${_pref}"
	    setFontAttrib FMAGENTA "$_name"
	    echo -n "=["
	    setFontAttrib FMAGENTA "${_default}"
	    echo -n "]"
	fi

	if [ \( "$CONTINUE_WITH_OPTDEFAULTS" == y -a "$_type" != MANDATORY \) -o  "$AUTO_WITH_DEFAULTS_ALL" == y  ];then
	    echo
	else
	    read _val
	fi

	[ -z "${_val}" ]&&_val=$_default;
	[ "${CTYS_XTERM}" == 0 ]&&echo -n -e "\033[2K";
	case $_type in
	    OPTIONAL)
		echo -e "${_pref}$_name=$_val"
		[ "${CTYS_XTERM}" == 0 ]&&echo -n -e "\033[2K";
		echo -n -e "${_pref}Continue [y|return|n|C]"; 
		if [ "$CONTINUE_WITH_OPTDEFAULTS" != y ];then
		    read _flow
		    [ "$_flow"  == C ]&&CONTINUE_WITH_OPTDEFAULTS=y&&_flow=y;
		else
		    setFontAttrib BOLD $(setFontAttrib BGREEN "C")
		    echo
		    _flow=y;
		fi
		;;
	    *)	
		echo -e -n "${_pref}"
		setFontAttrib FMAGENTA "$_name"
		echo -e "=$_val"
		if [ -n "$_val" ];then
		    [ "${CTYS_XTERM}" == 0 ]&&echo -n -e "\033[2K";
		    getOK "${_pref}"
		    [ $? -eq 0 ]&&_flow=y||_flow=n;
		else
		    _flow=r;
		    echo -n "${_pref}";
		    setFontAttrib BOLD $(setFontAttrib FRED "MANDATORY")
		    echo -n ", value required";
		    if [ $rcnt -gt 1 -a "${AUTO_WITH_DEFAULTS_ALL}" == y ];then
			echo -e -n "\n\n${_pref}";
			setFontAttrib BOLD $(setFontAttrib FRED "Endlessloop")
			echo  " detected, missing initial value, check your defaults.";
#			echo -e "${_pref}""When 'empty defaults', omit '--auto-all', use '--auto'";

			echo -e -n "${_pref}""When 'empty defaults', ";
			setFontAttrib BOLD $(setFontAttrib FRED "omit '--auto-all'")
			echo -e -n ", ";
			setFontAttrib BOLD $(setFontAttrib FGREEN "use '--auto'")
			echo "."
			exit 1
		    fi
		    let rcnt++;
		    [ "${CTYS_XTERM}" == 0 ]&&echo  -e "\033[1A\033[2K\033[1A\033[2K\033[1A";
		fi
		;;
	esac
	if [ -z "${_val}" ];then
	    case $_type in
  		MANDATORY)_flow=${_flow:-n};;
		OPTIONAL);;
		*);;
	    esac
	fi
	if [ -n "$_flow" -a "$_flow" != y -a "$_flow" != r -a "${CTYS_XTERM}" == 0 ];then
	    echo -n -e "\033[1A\033[2K\033[2A\033[2K";
	fi
    done
    eval $_name="'$_val'"
}


function getOK () {
    local _pfx=${1};
    local _flow=${AUTO_WITH_DEFAULTS_ALL}
    local r=;
    if [ "$_flow" != y ];then
	while [ "$_flow" != y -a "$_flow" != n ];do
	    if [ -n "${r}" ];then
		echo -n "$_pfx""Continue ["; 
		setFontAttrib BOLD $(setFontAttrib FRED 'y|n')
		echo -n "]"; 
		setFontAttrib BOLD $(setFontAttrib FRED ' \\077 ')
	    else
		echo -n "$_pfx""Continue [y|n]"; 
	    fi
	    read _flow
	    case $_flow in
		y|Y)return 0;;
		n|N)return 1;;
		*) 
		    if [ "${CTYS_XTERM}" == 0 ];then
			echo -n -e "\033[1A\033[2K"
			r=1;
		    fi
		    ;;
	    esac
	done
    else
	echo -n "$_pfx""Continue [y|n]"; 
	setFontAttrib BOLD $(setFontAttrib BGREEN "A")
	echo
    fi
}

function printOut () {
    if [ -z "${EXPERT_MODE}" ];then
	echo -e  "$*"
    fi
}

function getUUID () {
    local UUID=00000000-0000-0000-$(date +%Y)-$(date +%m%d%H%M%S)00;

    case "${MYOS}" in
	Linux)
	    CTYS_UUID=`getPathName $LINENO $BASH_SOURCE WARNINGEXT uuidgen /usr/bin`
	    if [ -n "${CTYS_UUID}" ];then
		callErrOutWrapper $LINENO $BASH_SOURCE ${CTYS_UUID}>/dev/null
		if [ $? -ne 0 ];then
		    printWNG 1 $LINENO $BASH_SOURCE 1 "No access to \"uuidgen\", automated UUID"
		    printWNG 1 $LINENO $BASH_SOURCE 1 "generation currently not available."
		    printWNG 1 $LINENO $BASH_SOURCE 1 "Using a minimal-approach by 'date'."
		else
		    UUID=`${CTYS_UUID}`
		fi
	    else
		echo >&2
		echo "${_prefix1}""No access to \"uuidgen\", automated UUID">&2
		echo "${_prefix1}""generation is currently not available.">&2
		echo "${_prefix1}""Using a minimal-approach by 'date'.">&2
		echo >&2
	    fi
	    ;;
	FreeBSD|OpenBSD)
	    CTYS_UUID=`getPathName $LINENO $BASH_SOURCE WARNINGEXT uuid /usr/local/bin`
	    if [ -n "${CTYS_UUID}" ];then
		callErrOutWrapper $LINENO $BASH_SOURCE ${CTYS_UUID}>/dev/null
		if [ $? -ne 0 ];then
		    printWNG 1 $LINENO $BASH_SOURCE 1 "No access to \"uuidgen\", automated UUID"
		    printWNG 1 $LINENO $BASH_SOURCE 1 "generation currently not available."
		    printWNG 1 $LINENO $BASH_SOURCE 1 "Using a minimal-approach by 'date'."
		else
		    UUID=`${CTYS_UUID}`
		fi
	    else
		echo >&2
		echo "${_prefix1}""No access to \"uuidgen\", automated UUID">&2
		echo "${_prefix1}""generation is currently not available.">&2
		echo "${_prefix1}""Using a minimal-approach by 'date'.">&2
		echo >&2
	    fi
	    ;;
	*) 
	    echo >&2
	    echo "${_prefix1}""UUID generation is not available for ${MYOS}.">&2
	    echo "${_prefix1}""Using a minimal-approach by 'date'.">&2
	    echo >&2
            ;;
    esac
    echo $UUID
}


_prefix0="  "
_prefix1="    "
_prefix2="       "
_prefix3="          "

function getValues () {
    local _idx=1;
    local _sum=23;

    function setExtras4Kickstart () {
	local _sum0=$_sum;
	let _sum+=2;

	echo
	echo -e -n "${_prefix2}"
	setFontAttrib BOLD "KICKSTART";
	echo -e "($((_idx++))/"$(setFontAttrib FMAGENTA "${_sum}")")";
	echo "${_prefix3}""The following protocol options are supported:"
	echo 
	echo "${_prefix3}"" 'nfs:<hostname>:<absolute-path-ks-file>"
	echo "${_prefix3}"" 'ftp://<hostname>/<ftp-path-ks-file>"
	echo "${_prefix3}"" 'http://<hostname>/<ftp-path-ks-file>"
	echo "${_prefix3}"" 'https://<hostname>/<ftp-path-ks-file>"
	echo
	KICKSTART=
	getAttrVal KICKSTART "$KICKSTART" OPTIONAL "${_prefix2}"
	INST_EXTRA=${DEFAULT_INST_EXTRA:-"text"}
	INST_EXTRA="${DEFAULT_INST_EXTRA} ${KICKSTART}"
	echo
    }

    echo
    echo
    echo
    setFontAttrib UNDL $(setFontAttrib BOLD "Input custom values - assemble ${C_SESSIONTYPE} call:")"\n";
    echo
    echo

    echo -e -n "${_prefix0}"
    setFontAttrib BOLD "EDITOR";
    echo "($((_idx++))/${_sum})";
    printOut "${_prefix1}""Author responsible for current configuration";
    echo
    EDITOR="${EDITOR:-$MYUID}"
    getAttrVal EDITOR "${EDITOR}" OPTIONAL "${_prefix1}"
    echo




    echo -e -n "${_prefix0}"
    setFontAttrib BOLD "LABEL";
    echo "($((_idx++))/${_sum})";
    echo "${_prefix1}""The label/machine name used for addressing the VM."
    echo "${_prefix1}""This is also the name of the configuration files"
    echo
    echo "${_prefix1}""It is recommended to use the hostname of the virtual machine."
    echo


    case ${C_SESSIONTYPE} in
	VMW)
	    rcnt=0;
	    FINISHED="";
	    while [ -z "$FINISHED" ];do
		getAttrVal LABEL "${LABEL}" MANDATORY "${_prefix1}"
		let rcnt++;
		if [ -e "${IDDIR}/${LABEL}.vmx" ];then
		    echo
		    echo "${_prefix1}""CONF-FILE = ${IDDIR}/${LABEL}.ctys"
		    echo "${_prefix1}""VMX-FILE  = ${IDDIR}/${LABEL}.vmx"
		    echo -e "\033[2K";
		    FINISHED=1;

 		    local dName=$(getVMWLABEL "${IDDIR}/${LABEL}.vmx")
		    if [ -z "$dName" ];then
			echo -n "${_prefix1}""Missing'"
			setSeverityColor WNG "displayName"
			echo "' in vms-file. "
		    else
			if [ "$dName" != "$LABEL" ];then
			    echo -n "${_prefix1}""The '"
			    setSeverityColor WNG "displayName=${dName}"
			    echo -n "' and the '"
			    setSeverityColor WNG "LABEL=${LABEL}"
			    echo "' are different. "
			    echo "${_prefix1}""These should match for convenience. "
			fi
		    fi
		else
		    echo
		    echo "${_prefix1}""CONF-FILE = ${IDDIR}/${LABEL}.ctys"
		    echo -n "${_prefix1}"
		    setSeverityColor ERR "Missing"
		    echo -n " prerequired "
		    setSeverityColor ERR "peer-vmx-file:"
		    echo
		    echo -n "${_prefix1}""VMX-FILE  = "
		    setSeverityColor ERR "${IDDIR}/${LABEL}.vmx"
		    echo


		    echo  -n "${_prefix1}"
		    setSeverityColor INF "TIP:"
		    echo  " Try as a 'work-around' the creation of a segmented virtual disk"
		    echo  "${_prefix1}""- at least as a dummy - before creating an actual disk."

		    [ -n "${AUTO_WITH_DEFAULTS_ALL}" ]&&echo&&exit 1;
 		    [ "${CTYS_XTERM}" == 0 ]&&echo -n -e "\033[9A\033[2K\033[1A";
		fi
		echo
	    done
	    [ "${CTYS_XTERM}" == 0 ]&&echo -n -e "\033[2A";
	    echo
	    ;;
	'QEMU')
	    getAttrVal LABEL "${LABEL}" MANDATORY "${_prefix1}"
	    echo
	    echo "${_prefix1}""CONF-FILE          = ${IDDIR}/${LABEL}.ctys"
	    echo "${_prefix1}""WRAPPERSCRIPT      = ${IDDIR}/${LABEL}.sh"
	    ;;

	'XEN')
	    getAttrVal LABEL "${LABEL}" MANDATORY "${_prefix1}"
	    echo
	    echo "${_prefix1}""XEN-CONF-FILE      = ${IDDIR}/${LABEL}.conf"
	    echo "${_prefix1}""CONF-FILE          = ${IDDIR}/${LABEL}.ctys"
	    echo "${_prefix1}""WRAPPERSCRIPT      = ${IDDIR}/${LABEL}.sh"
	    ;;
	*)
	    ABORT=1;
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Unknown session type:${C_SESSIONTYPE}"
	    gotoHell ${ABORT}
	    ;;
    esac
    echo

    echo -e -n "${_prefix0}"
    setFontAttrib BOLD "UUID";
    echo "($((_idx++))/${_sum})";
    echo
    case ${C_SESSIONTYPE} in
	VMW)
 	    local u=$(getVMWUUID "${IDDIR}/${LABEL}.vmx")
	    printOut "${_prefix1}""The Unique-Unified-ID of the vmx-file will be used."
	    printOut "${_prefix1}""Make changes by means of supplier."
	    printOut " "
	    printOut "${_prefix1}""UUID=$u"
	    ;;
	*)
	    printOut "${_prefix1}""The Unique-Unified-ID of the VM, generated by uuidgen."
	    printOut "${_prefix1}""Changing this value is not really senseful in almost any case."
	    getAttrVal UUID $(getUUID) OPTIONAL "${_prefix1}"
	    ;;
    esac
    UUID=${UUID//-/}
    echo

    echo -e -n "${_prefix0}"
    setFontAttrib BOLD "MAC";
    echo "($((_idx++))/${_sum})";
    printOut "${_prefix1}""MAC-Address of VM."
    echo
    printOut "${_prefix1}""The MAC Address is almost mandatory required for"
    printOut "${_prefix1}""various features, thus should be provided in any case."
    printOut "${_prefix1}""The ranges and calculation of private MAC addresses"
    printOut "${_prefix1}""is described in the Appendices of the ctys-User-Manual."
    printOut "${_prefix1}""The following functions automate the evaluation of MAC"
    printOut "${_prefix1}""and IP addresses by utilizing 'ctys-macmap' when a "
    printOut "${_prefix1}""database is available."
    printOut
    printOut "${_prefix1}""E.g. 00:50:56:13:13:d0"
    printOut
    printOut
    printOut "${_prefix1}""Current version supports the interactive creation of"
    printOut "${_prefix1}"$(setSeverityColor TRY "Single-Interface-Configurations only.")
    case ${C_SESSIONTYPE} in
	VMW)
	    printOut "${_prefix1}"" Thus the first"
	    printOut "${_prefix1}""interface from the vmx-file is recognized only."
	    ;;
    esac
    printOut "${_prefix1}""Multiple interfaces require manual modification"
    printOut "${_prefix1}""of created configuration files."
    printOut
    if [ -z "${MAC}" ];then
	local _ix=;
	local _nx=0;
        local MACx=$(ctys-macmap -m ${LABEL}|tr '[:lower:]' '[:upper:]')
	local suspic=0;
	for _ix in $MACx;do let _nx++;done

	case ${C_SESSIONTYPE} in
	    VMW)
		local MACy=$(getVMWMAClst "${IDDIR}/${LABEL}.vmx"|tr '[:lower:]' '[:upper:]')
		MACy=${MACy#*=};MACy=${MACy%% *};
		if [ -n "$MACx" -a -n "$MACy" ];then
		    if [  "$MACx" != "$MACy" ];then
			suspic=1;
			if [  $_nx -eq 1 ];then
			    echo -n "${_prefix1}""The address from the database for  '"
			    setSeverityColor ERR "LABEL=${LABEL}"
			    echo "' is"
			    echo -n "${_prefix1}""'"
			    setSeverityColor ERR "MAC(db)=${MACx}"
			    echo "' but the entry"
			    echo -n "${_prefix1}""from the vmx-file is '"
			    setSeverityColor ERR "MAC(vmx)=${MACy}"
			    echo "'."
			    echo
			    echo "${_prefix1}""This may cause some ugly errors."
			    echo
			    MACx=$MACy
			else
			    echo -n "${_prefix1}""Multiple addresses found for '"
			    setSeverityColor ERR "LABEL=${LABEL}"
			    echo "'"
			    echo -n "${_prefix1}""'"
			    setSeverityColor ERR "MAC(db)=${_ix}..."
			    echo "' but the entry"
			    echo -n "${_prefix1}""from the vmx-file is '"
			    setSeverityColor ERR "MAC(vmx)=${MACy}"
			    echo "'."
			    echo
			    echo "${_prefix1}""This may cause some ugly errors."
			    echo
			    MACx=$MACy
			fi
		    fi
		else
		    [ -z "$MACx" ]&&MACx=$MACy;
		fi
		;;
	esac

	if [ $_nx -eq 1 ];then
	    _co=y;
	    MAC=$MACx
	else
	    if [ -n "$MACx" ];then
		echo -n "${_prefix1}"
		setFontAttrib FRED "Ambiguous MAC addressess for LABEL as hostname:";
		echo
		echo
		_nx=1;
		local a=;
		local b=;
		local c=;
		for _ix in $(ctys-macmap ${LABEL});do 
		    echo -n "${_prefix1}"
		    setFontAttrib FRED $(printf "%04d" "${_nx}");
		    a=${_ix%%;*}
		    b=${_ix%;*}
		    b=${b#*;}
		    c=${_ix##*;}
		    printf ": %-15s  %17s   %s\n" $a $b $c;
		    let _nx++;
		done
		echo
		case ${C_SESSIONTYPE} in
		    VMW)
			echo -n -e "${_prefix1}""Default is the vmx-entry:"
			MAC=${MACy}
			setFontAttrib FMAGENTA "${MAC}";
			echo
			;;
		    *)
			echo -n -e "${_prefix1}""Default is the last:"
			MAC=${b}
			setFontAttrib FRED "${MAC}($a;$c)";
			echo
			;;
		esac
		echo
	    fi
	    suspic=1;
	fi

    fi
    if((suspic==1));then
	getAttrVal MAC "$MAC" MANDATORY "${_prefix1}"
    else
 	getAttrVal MAC "$MAC" OPTIONAL "${_prefix1}"
    fi
    echo

    echo -e -n "${_prefix0}"
    setFontAttrib BOLD "IP";
    echo "($((_idx++))/${_sum})";
    printOut "${_prefix1}""TCP/IP address of the GuestOS within created VM, this"
    printOut "${_prefix1}""has to "$(setFontAttrib BOLD "match")" the mapping-value of "$(setFontAttrib BOLD "MAC adresses")
    printOut "${_prefix1}""Refer  to 'ctys-macmap' for additional information when"
    printOut "${_prefix1}""a mapping-database for automation is available."
    printOut 
    printOut "${_prefix1}""E.g. 172.20.6.205"
    echo 
    if [ -z "${IP}" ];then
	local IPx=$([ -n "${MAC}" ]&&ctys-macmap -u -i $(echo ${MAC}|tr 'a-z' 'A-Z'))
	local _ix=;
	local _nx=0;
	for _ix in $IPx;do let _nx++;done
	if [ $_nx -eq 1 ];then
	    _co=y;
	    IP=$IPx;
	else
	    if [ -n "$IPx" ];then
		echo -n "${_prefix1}"
		setFontAttrib FRED "Ambiguous IP addressess for current MAC address:";
		echo
		echo
		_nx=1;
		local a=;
		local b=;
		local c=;
		for _ix in $(ctys-macmap ${MAC});do 
		    echo -n "${_prefix1}"
		    setFontAttrib FRED $(printf "%04d" "${_nx}");
		    a=${_ix%%;*}
		    b=${_ix%;*}
		    b=${b#*;}
		    c=${_ix##*;}
		    printf ": %-15s  %17s   %s\n" $a $b $c;
		    let _nx++;
		done
		echo
		echo -n -e "${_prefix1}""Default is the last:"
		IP=${c}
		setFontAttrib FRED "${IP}($a;$b)";
		echo
		echo
	    fi
	fi

    fi
    getAttrVal IP "$IP" OPTIONAL "${_prefix1}"
    echo

    local brdgchk="$(netListBridges)"
    if [ -n "${brdgchk}" ];then
	local _ix=;
	local _nx=0;
	for _ix in $brdgchk;do let _nx++;done
	if [ $_nx -eq 1 ];then
	    _co=y;
	    BRIDGE=$brdgchk;
	else
	    if [ -n "$brdgchk" ];then
		echo -n "${_prefix1}"
		setFontAttrib FRED "Multiple bridges present:";
		echo
		echo
		_nx=1;
		for _ix in $brdgchk;do 
		    echo -n "${_prefix1}"
		    setFontAttrib FRED $(printf "%04d: %s" "${_nx}" "${_ix}");
		    let _nx++;
		done
		echo
		echo -n -e "${_prefix1}""Default is the last:"
		BRIDGE=${_ix}
		setFontAttrib FRED "${BRIDGE}";
		echo
		echo
	    fi
	    getAttrVal BRIDGE "$BRIDGE" MANDATORY "${_prefix1}"
	    echo
	fi
    fi

    echo
    echo -e -n "${_prefix1}"
    setFontAttrib BOLD "DHCP";
    echo -e "($((_idx++))/${_sum0}->EXTRAS:"$(setFontAttrib FMAGENTA "${_sum}")")";
    echo "${_prefix2}""If DHCP selected this is used for boot of install "
    echo "${_prefix2}""configuration only."
    echo
    DHCP=
    getAttrVal DHCP "$DHCP" OPTIONAL "${_prefix2}"
    if [ -n "${DHCP}" ];then
	TCP="${TCP} ${IP:+ ip=dhcp}"
    else
	TCP="${TCP} ${IP:+ ip=$IP}"
	if [ -n "${IP}" ];then
	    local _sum0=$_sum;
	    let _sum+=2;

	    echo
	    echo -e -n "${_prefix1}"
	    setFontAttrib BOLD "NETMASK";
	    echo -e "($((_idx++))/${_sum0}->TCP:"$(setFontAttrib FMAGENTA "${_sum}")")";
	    echo "${_prefix2}""If DHCP selected this is used for boot of install "
	    echo "${_prefix2}""configuration only."
	    echo
	    if [ -z "$NETMASK" ];then
		if [ -n "$BRIDGE" ];then
		    NETMASK=$(netGetMask $BRIDGE)
		else
		    NETMASK=$(netCalcMask $IP)
		fi
	    fi
	    getAttrVal NETMASK "$NETMASK" OPTIONAL "${_prefix2}"
	    TCP="${TCP} ${NETMASK:+ netmask=$NETMASK}"

	    echo
	    echo -e -n "${_prefix1}"
	    setFontAttrib BOLD "GATEWAY";
	    echo -e "($((_idx++))/"$(setFontAttrib FMAGENTA "${_sum}")")";
	    echo "${_prefix2}""If DHCP selected this is used for boot of install "
	    echo "${_prefix2}""configuration only."
	    echo
	    if [ -z "$GATEWAY" ];then
		if [ -n "$IP" ];then
		    GATEWAY=$(netGetDefaultGW $IP)
		else
		    GATEWAY=$(netGetDefaultGW $BRIDGE)
		fi
	    fi
	    getAttrVal GATEWAY "$GATEWAY" OPTIONAL "${_prefix2}"
	    TCP="${TCP} ${GATEWAY:+ gateway=$GATEWAY}"
	fi
	echo
    fi

    echo -e -n "${_prefix0}"
    setFontAttrib BOLD "DIST";
    echo "($((_idx++))/${_sum})";
    printOut "${_prefix1}""The distribution of the GuestOS."
    printOut "${_prefix1}""E.g. CentOS, OpenBSD, FreeBSD, OpenSolaris."
    echo
    getAttrVal DIST "${DIST:-$MYDIST}" OPTIONAL "${_prefix1}"
    echo

    echo -e -n "${_prefix0}"
    setFontAttrib BOLD "RELEASE";
    echo "($((_idx++))/${_sum})";
    printOut "${_prefix1}""The distributions release of GuestOS."
    printOut "${_prefix1}""E.g. 5.4"
    echo
    getAttrVal DISTREL "${DISTREL:-$MYREL}" OPTIONAL "${_prefix1}"
    echo

    echo -e -n "${_prefix0}"
    setFontAttrib BOLD "OS";
    echo "($((_idx++))/${_sum})";
    printOut "${_prefix1}""GuestOS"
    printOut "${_prefix1}""E.g. Linux, OpenBSD, FreeBSD, OpenSolaris."
    echo
    getAttrVal OS "${OS:-$MYOS}" OPTIONAL "${_prefix1}"
    echo

    echo -e -n "${_prefix0}"
    setFontAttrib BOLD "OSREL";
    echo "($((_idx++))/${_sum})";
    printOut "${_prefix1}""Version of GuestOS"
    printOut "${_prefix1}""E.g. 2.6.18-128.el5"
    echo
    getAttrVal OSREL "${OSREL:-$MYOSREL}" OPTIONAL "${_prefix1}"
    echo

    case ${C_SESSIONTYPE} in
	VMW)
	    ;;
	*)
	    echo -e -n "${_prefix0}"
	    setFontAttrib BOLD "STARTERCALL";
	    echo "($((_idx++))/${_sum})";
	    printOut "${_prefix1}""The default call-variant"
	    STARTERCALL=${STARTERCALL:-$DEFAULTSTARTERCALL};
	    echo
	    getAttrVal STARTERCALL "${STARTERCALL// /}" OPTIONAL "${_prefix1}"
	    echo

	    echo -e -n "${_prefix0}"
	    setFontAttrib BOLD "WRAPPERCALL";
	    echo "($((_idx++))/${_sum})";
	    printOut "${_prefix1}""The default wrapper-call for all calls."
	    printOut "${_prefix1}""This value should be kept if unsure."
	    printOut "${_prefix1}""For current versions the 'future obsolation message'"
	    printOut "${_prefix1}""could be ignored safely."
	    echo
	    WRAPPERCALL=${WRAPPERCALL:-$DEFAULTWRAPPERCALL};
	    getAttrVal WRAPPERCALL "${WRAPPERCALL// /}" OPTIONAL "${_prefix1}"
	    echo
	    ;;
    esac

    echo -e -n "${_prefix0}"
    setFontAttrib BOLD "ARCH";
    echo "($((_idx++))/${_sum})";
    printOut "${_prefix1}""Architecture of CPU for GuestOS"
    printOut "${_prefix1}""When empty default is used."
    case ${C_SESSIONTYPE} in
	VMW)
	    echo
	    printOut "${_prefix1}""Ignored for VMW configuration, but used for ENUMERATE"
	    printOut "${_prefix1}""into the database, thus has to be in sync."
	    ;;
    esac
    echo
    ARCHinfo=$(getCurArch.sh)
    getAttrVal ARCH "${ARCHinfo// /}" OPTIONAL "${_prefix1}"
    echo

    case ${C_SESSIONTYPE} in
	XEN)
	    echo -e -n "${_prefix0}"
	    setFontAttrib BOLD "ACCELERATOR";
	    echo "($((_idx++))/${_sum})";
	    printOut "${_prefix1}""Set preference for accellerator support, default is"
	    printOut "${_prefix1}""paravirtualization."
	    echo
	    printOut "${_prefix1}""Values:"
	    printOut "${_prefix1}""  XEN:  'PARA' or 'HVM'"
	    echo
	    if [ -z "${ACCELERATOR}" ];then
		ACCELERATORinfo=$(getACCELERATOR_XEN)
	    else
		ACCELERATORinfo=${ACCELERATOR}

	    fi
	    local _r123=;
	    local loopcnt=0;
	    while [ -z "$_r123" -a $loopcnt -lt 20 ];do
		getAttrVal ACCELERATOR "${ACCELERATORinfo// /}" MANDATORY "${_prefix1}"
		case "${ACCELERATOR}" in
		    HVM)_r123=1;;
		    PARA)_r123=1;;
		    *)let loopcnt++;
		esac
		if [ -z "$_r123" ];then
		    echo 
		    echo -e -n "${_prefix1}"""$(setFontAttrib FRED "'${ACCELERATOR}'");
		    echo -e -n " is not valid, choose "
		    echo -e -n "$(setFontAttrib FGREEN "'HVM'")";
		    echo -e -n " or ";
		    echo -e -n "$(setFontAttrib FGREEN "'PARA'")";
		    echo 
		    echo 
		fi
	    done
	    ;;
	QEMU)
	    echo -e -n "${_prefix0}"
	    setFontAttrib BOLD "ACCELERATOR";
	    echo "($((_idx++))/${_sum})";
	    printOut "${_prefix1}""Set preference for accellerator support, default is"
	    printOut "${_prefix1}""\"fastest\"."
	    echo
	    printOut "${_prefix1}""Values: 'QEMU', 'KQEMU', or 'KVM'"
	    echo

	    if [ -z "${ACCELERATOR}" ];then
		ACCELERATORinfo=$(getACCELERATOR_QEMU $QEMU)
	    else
		ACCELERATORinfo=${ACCELERATOR}

	    fi
	    local _r123=;
	    while [ -z "$_r123" ];do
		getAttrVal ACCELERATOR "${ACCELERATORinfo// /}" MANDATORY "${_prefix1}"
		case "${ACCELERATOR}" in
		    KVM)_r123=1;;
		    QEMU)_r123=1;;
#ffs		    KQEMU)_r123=1;;
		esac
		if [ -z "$_r123" ];then
		    echo 
		    echo -e -n "${_prefix1}"""$(setFontAttrib FRED "'${ACCELERATOR}'");
		    echo -e -n " is not valid, choose "
		    echo -e -n "$(setFontAttrib FGREEN "'KVM',")";
#ffs		    echo -e -n "$(setFontAttrib FGREEN "'KQEMU',")";
		    echo -e -n "$(setFontAttrib FBLUE "('KQEMU' f.f.s.),")";
		    echo -e -n " or ";
		    echo -e -n "$(setFontAttrib FGREEN "'QEMU'")";
		    echo 
		    echo 
		fi
	    done
	    ;;
    esac
    echo

    echo -e -n "${_prefix0}"
    setFontAttrib BOLD "SMP";
    echo "($((_idx++))/${_sum})";
    printOut "${_prefix1}""Number of emulated CPUs/Cores."
    printOut "${_prefix1}""When empty default is used."
    echo
    case ${C_SESSIONTYPE} in
	VMW)
	    SMPinfo=$(getVMWGUESTVCPU "${IDDIR}/${LABEL}.vmx");
	    SMPinfo=${SMPinfo:-$SMP};
	    ;;
	*)
	    SMPinfo=${SMP};
	    ;;
    esac
    getAttrVal SMP "${SMPinfo// /}" OPTIONAL "${_prefix1}"
    echo

    echo -e -n "${_prefix0}"
    setFontAttrib BOLD "MEMSIZE";
    echo "($((_idx++))/${_sum})";
    printOut "${_prefix1}""The assigned amount of RAM."
    echo
    case ${C_SESSIONTYPE} in
	VMW)
	    MEMSIZE=$(getVMWGUESTVRAM "${IDDIR}/${LABEL}.vmx");
	    MEMSIZE=${MEMSIZE:-512}
	    ;;
	*)
	    MEMSIZE=${MEMSIZE:-512}
	    ;;
    esac
    getAttrVal MEMSIZE "$MEMSIZE" OPTIONAL "${_prefix1}"
    echo

    case ${C_SESSIONTYPE} in
	VMW)
	    ;;
	*)
	    echo -e -n "${_prefix0}"
	    setFontAttrib BOLD "KBD_LAYOUT";
	    echo "($((_idx++))/${_sum})";
	    printOut "${_prefix1}""The Layout of the virtual keyboard."
	    echo
	    KBD_LAYOUT=${KBD_LAYOUT:-de}
	    getAttrVal KBD_LAYOUT "$KBD_LAYOUT" OPTIONAL "${_prefix1}"
	    echo
	    ;;
    esac


    ##############################################################################
    #
    #Load default values for configuration.
    #
    #
    printINFO 2 $LINENO $BASH_SOURCE 1 "${MYCONFPATH}/ctys-createConfVM.d/defaults-sources.ctys"


    #Source pre-set environment from user
    if [ -f "${HOME}/.ctys/ctys-createConfVM.d/defaults-sources.ctys" ];then
	. "${HOME}/.ctys/ctys-createConfVM.d/defaults-sources.ctys"
    fi
    #
    #
    #Source pre-set environment from installation 
    if [ -f "${MYCONFPATH}/ctys-createConfVM.d/defaults-sources.ctys" ];then
	. "${MYCONFPATH}/ctys-createConfVM.d/defaults-sources.ctys"
    fi
    #
    #
    ##############################################################################


    case ${C_SESSIONTYPE} in
	VMW)
	    ;;
	*)
	    echo -e -n "${_prefix0}"
	    setFontAttrib BOLD "DEFAULTBOOTMODE";
	    echo "($((_idx++))/${_sum})";
	    printOut "${_prefix1}""The default mode for 'BOOTMODE' parameter when omitted."
	    printOut
	    echo "${_prefix1}""Available: VHDD, HDD, FDD, CD, DVD, USB"
	    echo
	    DEFAULTBOOTMODE=${DEFAULTBOOTMODE:-VHDD}
	    getAttrVal DEFAULTBOOTMODE "$DEFAULTBOOTMODE" OPTIONAL "${_prefix1}"
	    DEFAULTBOOTMODE=$(echo ${DEFAULTBOOTMODE}|tr 'a-z' 'A-Z')
	    echo
	    case ${DEFAULTBOOTMODE} in
		VHDD|HDD)
		    local _sum0=$_sum;
		    let _sum+=2;

		    DEFAULTINSTTARGET=${IDDIR}/${HDDBOOTIMAGE}
		    echo -e -n "${_prefix1}"
		    setFontAttrib BOLD "HDDBOOTIMAGE_INST_SIZE";
		    echo -e "($((_idx++))/${_sum0}->HDD:"$(setFontAttrib FMAGENTA "${_sum}")")";
		    printOut "${_prefix2}""For installation only, the size of the HDD bootimage."
		    printOut "${_prefix2}""Additional drives could be activated manually within the "
		    printOut "${_prefix2}""configuration files, refer to inline comments."
		    printOut 
		    printOut "${_prefix2}""Values/Units must be valid for 'qemu-img' and 'dd', e.g. 'M' or 'G'."
		    echo
		    HDDBOOTIMAGE_INST_SIZE=${HDDBOOTIMAGE_INST_SIZE:-5G}
		    getAttrVal HDDBOOTIMAGE_INST_SIZE "$HDDBOOTIMAGE_INST_SIZE" OPTIONAL "${_prefix2}"
		    echo

		    echo -e -n "${_prefix1}"
		    setFontAttrib BOLD "HDDBOOTIMAGE_INST_BLOCKSIZE";
		    echo -e "($((_idx++))/"$(setFontAttrib FMAGENTA "${_sum}")")";
		    printOut "${_prefix2}""For installation only, the size of blocks for HDD bootimage."
		    echo "${_prefix2}""The BLOCKSIZE must match following formula:"
		    echo
		    echo "${_prefix2}"" SIZE = BLOCKCOUNT * BLOCKSIZE"
		    echo
		    printOut "${_prefix2}""Values/Units must be valid for 'qemu-img' and 'dd', e.g. 'M' or 'G'."
		    printOut
		    HDDBOOTIMAGE_INST_BLOCKSIZE=${HDDBOOTIMAGE_INST_BLOCKSIZE:-1G}
		    getAttrVal HDDBOOTIMAGE_INST_BLOCKSIZE "$HDDBOOTIMAGE_INST_BLOCKSIZE" OPTIONAL "${_prefix2}"
		    echo

		    echo -e -n "${_prefix1}"
		    setFontAttrib BOLD "HDDBOOTIMAGE_INST_BLOCKCOUNT";
		    echo -e "($((_idx++))/"$(setFontAttrib FMAGENTA "${_sum}")")";
		    printOut "${_prefix2}""For installation only, the number of blocks for HDD bootimage."
		    echo "${_prefix2}""The BLOCKCOUNT must match following formula:"
		    echo
		    echo "${_prefix2}"" SIZE = BLOCKCOUNT * BLOCKSIZE"
		    echo
		    printOut "${_prefix2}""Values/Units must be valid for 'qemu-img' and 'dd', e.g. 'M' or 'G'."
		    printOut
		    HDDBOOTIMAGE_INST_BLOCKCOUNT=${HDDBOOTIMAGE_INST_BLOCKCOUNT:-5}
		    getAttrVal HDDBOOTIMAGE_INST_BLOCKCOUNT "$HDDBOOTIMAGE_INST_BLOCKCOUNT" OPTIONAL "${_prefix2}"
		    echo

		    echo -e -n "${_prefix1}"
		    setFontAttrib BOLD "HDDBOOTIMAGE_INST_BALLOON";
		    echo -e "($((_idx++))/${_sum0}->HDD:"$(setFontAttrib FMAGENTA "${_sum}")")";
		    printOut "${_prefix2}""This is experimental, it deactivates the initial total"
		    printOut "${_prefix2}""allocation of storage. Storage is 'blown up' in chunks"
		    printOut "${_prefix2}""of BLOCKSIZE as required."
		    printOut 
		    printOut "${_prefix2}""Values/Units must be valid for 'qemu-img' and 'dd', e.g. 'M' or 'G'."
		    echo
		    HDDBOOTIMAGE_INST_BALLOON=${HDDBOOTIMAGE_INST_BALLOON:-y}
		    getAttrVal HDDBOOTIMAGE_INST_BALLOON "$HDDBOOTIMAGE_INST_BALLOON" OPTIONAL "${_prefix2}"
		    echo

		    ;;
	    esac

	    echo -e -n "${_prefix0}"
	    setFontAttrib BOLD "DEFAULTINSTMODE";
	    echo "($((_idx++))/${_sum})";
	    printOut "${_prefix1}""The default mode for 'INSTMODE' parameter when omitted."
	    printOut
	    echo "${_prefix1}""Available: VHDD, HDD, FDD, CD, DVD, USB, NET"
	    echo
	    echo "${_prefix1}""Refer to manual for tested combinations."
	    echo
	    DEFAULTINSTMODE=${DEFAULTINSTMODE:-CD}
	    getAttrVal DEFAULTINSTMODE "$DEFAULTINSTMODE" OPTIONAL "${_prefix1}"
	    DEFAULTINSTMODE=$(echo ${DEFAULTINSTMODE}|tr 'a-z' 'A-Z')
	    echo
	    echo
	    case ${DEFAULTINSTMODE} in
		CD)
		    echo -e -n "${_prefix1}"
		    setFontAttrib BOLD "INSTSRCCDROM";
		    echo -e "($((_idx++))/${_sum})";
		    echo "${_prefix2}""Bootable CD/DVD media - ISO file"
		    printOut "${_prefix2}""This could be any bootable cdrom/dvd or iso-file."
		    printOut
		    printOut "${_prefix2}""Prepare iso files on linux/UNIX with:"
		    printOut
		    printOut "${_prefix2}"" \"dd if=/dev/cdrom of=<install-filename>.iso\""
		    printOut
		    printOut "${_prefix2}""An example list is contained within the template file."
		    echo
		    INSTSRCCDROM=${INSTSRCCDROM:-/dev/cdrom}
		    getAttrVal INSTSRCCDROM "$INSTSRCCDROM" MANDATORY "${_prefix2}"
		    echo
		    DEFAULTINSTSOURCE=${INSTSRCCDROM}
		    ;;
		DVD)
		    echo -e -n "${_prefix1}"
		    setFontAttrib BOLD "INSTSRCDVD";
		    echo -e "($((_idx++))/${_sum})";
		    echo "${_prefix2}""Bootable CD/DVD media"
		    printOut "${_prefix2}""This could be any bootable cdrom/dvd or iso-file."
		    printOut
		    printOut "${_prefix2}""Prepare iso files on linux/UNIX with:"
		    printOut
		    printOut "${_prefix2}"" \"dd if=/dev/dvd of=<install-filename>.iso\""
		    printOut
		    printOut "${_prefix2}""An example list is contained within the template file."
		    echo
		    INSTSRCDVD=${INSTSRCDVD:-/dev/dvd}
		    getAttrVal INSTSRCDVD "$INSTSRCDVD" MANDATORY "${_prefix2}"
		    echo
		    DEFAULTINSTSOURCE=${INSTSRCDVD}
		    ;;
		FDD)
		    echo -e -n "${_prefix1}"
		    setFontAttrib BOLD "INSTSRCFDD";
		    echo -e "($((_idx++))/${_sum})";
		    echo "${_prefix2}""Bootable floppy media"
		    printOut "${_prefix2}""This could be any bootable fdd or img-file."
		    printOut
		    printOut "${_prefix2}""Prepare img files on linux/UNIX with:"
		    printOut
		    printOut "${_prefix2}"" \"dd if=/dev/fd0 of=fda.img\""
		    echo
		    INSTSRCFDD=${INSTSRCFDD:-/dev/fd0}
		    getAttrVal INSTSRCFDD "$INSTSRCFDD" MANDATORY "${_prefix2}"
		    echo
		    DEFAULTINSTSOURCE=${INSTSRCFDD}
		    ;;
		HDD)
		    echo -e -n "${_prefix1}"
		    setFontAttrib BOLD "INSTSRCHDD";
		    echo -e "($((_idx++))/${_sum})";
		    echo "${_prefix2}""Bootable harddisk media"
		    printOut "${_prefix2}""This could be any bootable hdd or img-file."
		    printOut
		    printOut "${_prefix2}""Prepare img files on linux/UNIX with:"
		    printOut
		    printOut "${_prefix2}"" \"dd if=/dev/hda of=hda.img\""
		    echo
		    INSTSRCHDD=${INSTSRCHDD:-hda}
		    getAttrVal INSTSRCHDD "$INSTSRCHDD" MANDATORY "${_prefix2}"
		    echo
		    DEFAULTINSTSOURCE=${INSTSRCHDD}
		    ;;
		USB)
		    echo -e -n "${_prefix1}"
		    setFontAttrib BOLD "INSTSRCUSB";
		    echo -e "($((_idx++))/${_sum})";
		    echo "${_prefix2}""Bootable USB media"
		    printOut "${_prefix2}""This could be any bootable fdd or img-file."
		    printOut
		    printOut "${_prefix2}""Prepare img files on linux/UNIX with:"
		    printOut
		    printOut "${_prefix2}"" \"dd if=/dev/usb of=<install-filename>.img\""
		    echo
		    INSTSRCUSB=${INSTSRCUSB:-/dev/usb}
		    getAttrVal INSTSRCUSB "$INSTSRCUSB" MANDATORY "${_prefix2}"
		    echo
		    DEFAULTINSTSOURCE=${INSTSRCUSB}
		    ;;


		KS)
		    echo -e -n "${_prefix1}"
		    setFontAttrib BOLD "KS";
		    echo -e "($((_idx++))/${_sum})";
		    echo "${_prefix2}""KickStart."
		    printOut "${_prefix2}""Kernel boot and network install"
		    printOut "${_prefix2}""by various protocols."
		    printOut
		    case ${DIST} in
			CentOS)
			    setExtras4Kickstart
			    ;;
		    esac
		    ;;

	    esac

	    case ${C_SESSIONTYPE} in
		XEN)
		    echo -e -n "${_prefix0}"
		    setFontAttrib BOLD "BOOTLOADER";
		    echo "($((_idx++))/${_sum})";
		    echo "${_prefix1}""The bootloader to be used."
		    echo
		    BOOTLOADER=${BOOTLOADER:-$DEFAULT_BOOTLOADER};
		    getAttrVal BOOTLOADER "${BOOTLOADER// /}" MANDATORY "${_prefix1}"
		    echo
		    ;;
		QEMU)
		    ;;
	    esac

	    case ${C_SESSIONTYPE} in
		XEN|QEMU)
		    echo -e -n "${_prefix0}"
		    setFontAttrib BOLD "INST_KERNEL";
		    echo "($((_idx++))/${_sum})";
		    echo "${_prefix1}""Kernel to be used for initial boot in INSTMODE."
		    printOut "${_prefix1}""The kernel image has to be suitable to the GuestOS,"
		    printOut "${_prefix1}""e.g. for CentOS the image is on the install media within"
		    printOut "${_prefix1}""the relative path 'images/xen/vmlinuz'."
		    printOut
		    printOut "${_prefix1}""When empty default is used."
		    echo
		    INST_KERNEL=${INST_KERNEL:-$DEFAULT_INST_KERNEL};
		    case ${C_SESSIONTYPE} in
			XEN)
			    getAttrVal INST_KERNEL "${INST_KERNEL// /}" MANDATORY "${_prefix1}"
			    ;;
			QEMU)
			    getAttrVal INST_KERNEL "${INST_KERNEL// /}" OPTIONAL "${_prefix1}"
			    ;;
		    esac

		    case ${ACCELERATOR} in
			PARA)
			    echo
			    echo -e -n "${_prefix0}"
			    setFontAttrib BOLD "INST_EXTRA";
			    echo "($((_idx++))/${_sum})";
			    echo "${_prefix1}""Value of kernel parameters."
			    echo
			    INST_EXTRA=${INST_EXTRA:-$DEFAULT_INST_EXTRA};
			    case ${C_SESSIONTYPE} in
				XEN)
				    getAttrVal INST_EXTRA "${INST_EXTRA}" OPTIONAL "${_prefix1}"
				    ;;
				QEMU)
				    getAttrVal INST_EXTRA "${INST_EXTRA}" OPTIONAL "${_prefix1}"
				    ;;
			    esac
			    echo

			    echo
			    echo -e -n "${_prefix0}"
			    setFontAttrib BOLD "INST_ROOTARGS";
			    echo "($((_idx++))/${_sum})";
			    echo "${_prefix1}""Value of root in install configuraiotn."
			    echo
			    INST_ROOTARGS=${INST_ROOTARGS:-$DEFAULT_INST_ROOTARGS};
			    case ${C_SESSIONTYPE} in
				XEN)
				    getAttrVal INST_ROOTARGS "${INST_ROOTARGS}" OPTIONAL "${_prefix1}"
				    ;;
				QEMU)
				    getAttrVal INST_ROOTARGS "${INST_ROOTARGS}" OPTIONAL "${_prefix1}"
				    ;;
			    esac
			    echo
			    ;;
		    esac
		    echo
		    case ${C_SESSIONTYPE} in
			XEN)
			    case ${ACCELERATOR} in
				PARA)
				    echo -e -n "${_prefix0}"
				    setFontAttrib BOLD "INST_INITRD";
				    echo "($((_idx++))/${_sum})";
				    echo "${_prefix1}""Initrd to be used for initial boot in INSTMODE."
				    echo
				    printOut "${_prefix1}""When empty default is used."
				    printOut
				    INST_INITRD=${INST_INITRD:-$DEFAULT_INST_INITRD};
				    getAttrVal INST_INITRD "${INST_INITRD// /}" MANDATORY "${_prefix1}"
				    ;;
			    esac
			    ;;
			QEMU)
			    echo -e -n "${_prefix0}"
			    setFontAttrib BOLD "INST_INITRD";
			    echo "($((_idx++))/${_sum})";
			    echo "${_prefix1}""Initrd to be used for initial boot in INSTMODE."
			    echo
			    printOut "${_prefix1}""When empty default is used."
			    printOut
			    INST_INITRD=${INST_INITRD:-$DEFAULT_INST_INITRD};
			    getAttrVal INST_INITRD "${INST_INITRD// /}" OPTIONAL "${_prefix1}"
			    ;;
		    esac
		    echo

		    case ${DIST} in
			debian)
			    case ${ACCELERATOR} in
				PARA)
				    echo -e -n "${_prefix0}"
				    setFontAttrib BOLD "DOMU_KERNEL";
				    echo "($((_idx++))/${_sum})";
				    echo "${_prefix1}""Kernel to be executed within DomU."
				    echo
				    DOMU_KERNEL=${DOMU_KERNEL:-$DEFAULT_DOMU_KERNEL};
				    case ${C_SESSIONTYPE} in
					XEN)
					    getAttrVal DOMU_KERNEL "${DOMU_KERNEL// /}" MANDATORY "${_prefix1}"
					    ;;
					QEMU)
					    getAttrVal DOMU_KERNEL "${DOMU_KERNEL// /}" OPTIONAL "${_prefix1}"
					    ;;
				    esac
				    echo

				    echo -e -n "${_prefix0}"
				    setFontAttrib BOLD "DOMU_MODULESDIR";
				    echo "($((_idx++))/${_sum})";
				    echo "${_prefix1}""Modules for kernel to be executed within DomU."
				    echo
				    DOMU_MODULESDIR=${DOMU_MODULESDIR:-$DEFAULT_DOMU_MODULESDIR};
				    case ${C_SESSIONTYPE} in
					XEN)
					    getAttrVal DOMU_MODULESDIR "${DOMU_MODULESDIR// /}" MANDATORY "${_prefix1}"
					    ;;
					QEMU)
					    getAttrVal DOMU_MODULESDIR "${DOMU_MODULESDIR// /}" OPTIONAL "${_prefix1}"
					    ;;
				    esac
				    echo

				    echo -e -n "${_prefix0}"
				    setFontAttrib BOLD "DOMU_INITRD";
				    echo "($((_idx++))/${_sum})";
				    echo "${_prefix1}""Initrd to be used within the DomU."
				    echo
				    DOMU_INITRD=${DOMU_INITRD:-$DEFAULT_DOMU_INITRD};
				    case ${C_SESSIONTYPE} in
					XEN)
					    getAttrVal DOMU_INITRD "${DOMU_INITRD// /}" MANDATORY "${_prefix1}"
					    ;;
					QEMU)
					    getAttrVal DOMU_INITRD "${DOMU_INITRD// /}" OPTIONAL "${_prefix1}"
					    ;;
				    esac
				    echo

				    echo -e -n "${_prefix0}"
				    setFontAttrib BOLD "DOMU_EXTRA";
				    echo "($((_idx++))/${_sum})";
				    echo "${_prefix1}""Kernel parameters for the DomU."
				    echo
				    DOMU_EXTRA=${DOMU_EXTRA:-$DEFAULT_DOMU_EXTRA};
				    case ${C_SESSIONTYPE} in
					XEN)
					    getAttrVal DOMU_EXTRA "${DOMU_EXTRA// /}" OPTIONAL "${_prefix1}"
					    ;;
					QEMU)
					    getAttrVal DOMU_EXTRA "${DOMU_EXTRA// /}" OPTIONAL "${_prefix1}"
					    ;;
				    esac
				    echo

				    echo -e -n "${_prefix0}"
				    setFontAttrib BOLD "DOMU_ROOT";
				    echo "($((_idx++))/${_sum})";
				    echo "${_prefix1}""Root for the DomU."
				    echo
				    DOMU_ROOT=${DOMU_ROOT:-$DEFAULT_DOMU_ROOT};
				    case ${C_SESSIONTYPE} in
					XEN)
					    getAttrVal DOMU_ROOT "${DOMU_ROOT// /}" OPTIONAL "${_prefix1}"
					    ;;
					QEMU)
					    getAttrVal DOMU_ROOT "${DOMU_ROOT// /}" OPTIONAL "${_prefix1}"
					    ;;
				    esac
				    echo
				    ;;
			    esac
			    ;;
		    esac
		    ;;
	    esac
	    ;;
    esac



    echo -e -n "${_prefix0}"
    setFontAttrib BOLD "VMSTATE";
    echo "($((_idx++))/${_sum})";
    printOut "${_prefix1}""The VMSTATE defines whether the created configuration"
    printOut "${_prefix1}""is recognized by the ctys tools or not. When ACTIVE the"
    printOut "${_prefix1}""automated inventory collector \"ctys-vdbgen\" and the"
    printOut "${_prefix1}""\"start-by-search-and-match\" algorithms detect"
    printOut "${_prefix1}""the VM as valid."
    echo "${_prefix1}""Current applicable values are"
    echo
    echo "${_prefix1}""  ACTIVE"
    echo "${_prefix1}""  DISABLED"
    echo
    VMSTATE=${VMSTATE:-ACTIVE}
    getAttrVal VMSTATE "$VMSTATE" OPTIONAL "${_prefix1}"
}



function displaySystemValues () {
    echo
    echo

    setFontAttrib UNDL $(setFontAttrib BOLD "Current local System startup-values and defaults:""\n");
    echo 
    echo

    echo
    echo "${_prefix1}""Configuration location         = ${MYHOST}";
    echo
    echo "${_prefix1}""Sessiontype                    = ${C_SESSIONTYPE}";
    echo
    echo "${_prefix1}""UID                            = ${MYUID}";
    echo "${_prefix1}""GID                            = ${MYGID#*;}";
    echo "${_prefix1}""DATE                           = ${DATETIME}"
    echo "${_prefix1}""CTYSREL                        = ${CTYSREL}";
    echo "${_prefix1}""HOST                           = ${MYHOST}";
    echo
    echo "${_prefix1}""ID                             = $ID"
    echo "${_prefix1}""CTYS                           = ${ID//.conf/.ctys}"
    echo "${_prefix1}""SERNO                          = $DATETIME"
    echo "${_prefix1}""VERNO                          = ${VERSION//_/.}"

    echo
    case ${C_SESSIONTYPE} in
	XEN)
	    echo "${_prefix1}""XM                             = ${XM}"
	    echo "${_prefix1}""VIRSH                          = ${VIRSH}"
	    echo "${_prefix1}""XENTRACE                       = ${XENTRACE}"
	    XEN_MAGICID=$(getXENMAGIC)
	    echo "${_prefix1}""MAGICID                        = ${XEN_MAGICID}"
	    XEN_HYPERREL=$(getVersionStrgXEN)
	    echo "${_prefix1}""HYPERREL-XEN                   = ${XEN_HYPERREL}"
	    if [ -z "${ACCELERATOR}" ];then
		ACCELERATORinfo=$(getACCELERATOR_XEN)
	    else
		ACCELERATORinfo=${ACCELERATOR}           
	    fi
	    echo "${_prefix1}""HYPERREL-XEN-ACCLERATOR        = ${XEN_ACCELERATORinfo}"
	    ;;
	QEMU)

	    echo
	    echo "${_prefix1}""QEMUBASE                       = ${QEMUBASE}"
	    QEMUBASE_MAGICID=$(getQEMUMAGIC ${QEMUBASE})
	    echo "${_prefix1}""MAGICID                        = ${QEMUBASE_MAGICID}"
	    QEMUBASE_HYPERREL=$(getVersionStrgQEMUALL ${QEMUBASE})
	    echo "${_prefix1}""HYPERREL-QEMU                  = ${QEMUBASE_HYPERREL}"
	    QEMUBASE_ACCELERATOR=$(getACCELERATOR_QEMU ${QEMUBASE})
	    echo "${_prefix1}""HYPERREL-QEMU-ACCLERATOR       = ${QEMUBASE_ACCELERATOR}"

	    echo
	    echo "${_prefix1}""QEMUKVM                        = ${QEMUKVM}"
	    QEMUKVM_MAGICID=$(getQEMUMAGIC ${QEMUKVM})
	    echo "${_prefix1}""MAGICID                        = ${QEMUKVM_MAGICID}"
	    QEMUKVM_HYPERREL=$(getVersionStrgQEMUALL ${QEMUKVM})
	    echo "${_prefix1}""HYPERREL-KVM                   = ${QEMUKVM_HYPERREL}"
	    QEMUKVM_ACCELERATOR=$(getACCELERATOR_QEMU ${QEMUKVM})
	    echo "${_prefix1}""HYPERREL-KVM-ACCLERATOR        = ${QEMUKVM_ACCELERATOR}"
	    ;;
    esac
    echo

    #CATEGORYinfo=$(getVMinfo.sh)
    case ${C_SESSIONTYPE} in
	PM)CATEGORYinfo=PM;;
	*)CATEGORYinfo=VM;;
    esac
    echo "${_prefix1}""CATEGORY                       = $(getVMinfo.sh)"

    PLATFORMinfo=$(getPLATFORM)
    echo "${_prefix1}""PLATFORM                       = ${PLATFORMinfo}"
    VMSTATEinfo=ACTIVE
    echo "${_prefix1}""VMSTATE                        = ACTIVE"
    echo
    CPUinfo=$(getCPUinfo.sh)
    echo "${_prefix1}""CPU-INFO                       = ${CPUinfo//\%/ }"
    ARCHinfo=$(getCurArch.sh)
    echo "${_prefix1}""ARCH                           = ${ARCHinfo//\%/ }"
    MEMinfo=$(getMEMinfo.sh)
    echo "${_prefix1}""MEM                            = ${MEMinfo//\%/ }"
    HDDinfo=$(getHDDinfo.sh)
    echo "${_prefix1}""HDD                            = ${HDDinfo//\%/ }"
    FSinfo=$(getFSinfo.sh)
    echo "${_prefix1}""FS                             = ${FSinfo//\%/ }"
    echo 
    echo "${_prefix1}""DISTRIBUTION                   = ${DIST:-$MYDIST}"
    echo "${_prefix1}""RELEASE                        = ${DISTREL:-$MYREL}"
    echo "${_prefix1}""OS                             = ${OS:-$MYOS}"
    echo "${_prefix1}""OS-RELEASE                     = ${OSREL:-$MYOSREL}"
    echo 
    case ${C_SESSIONTYPE} in
	XEN)
	    echo "${_prefix1}""BOOTLOADER                     = ${BOOTLOADER:-DEFAULT_BOOTLOADER}"
	    echo 
	    ;;
    esac
    case ${C_SESSIONTYPE} in
	VMW);;
	*)
	    echo "${_prefix1}""INITIAL-INST-BOOSTRAP-MACHINE  : DEFAULTINSTMODE=${DEFAULTINSTMODE:-(Not yet defined.)}"
	    case ${DEFAULTINSTMODE} in
		*)
		    echo "${_prefix1}""  INST_KERNEL                    = <${DEFAULT_INST_KERNEL:-Not yet defined.}>"
		    echo "${_prefix1}""  INST_INITRD                    = <${DEFAULT_INST_INITRD:-Not yet defined.}>"
		    echo "${_prefix1}""  INST_EXTRA                     = <${DEFAULT_INST_EXTRA:-Not yet defined.}>"
		    ;;
	    esac
	    ;;
    esac

}



function displayValues () {
    echo
    echo
    echo
    setFontAttrib UNDL $(setFontAttrib BOLD "The resulting user values for VM parameters - SESSIONTYPE=${C_SESSIONTYPE}:")"\n";
    echo
    echo

    echo "${_prefix1}""EDITOR                         = $EDITOR"
    echo
    echo "${_prefix1}""LABEL                          = $LABEL"
    echo
    echo "${_prefix1}""MYDIST                         = $MYDIST"
    echo "${_prefix1}""MYREL                          = $MYREL"
    echo "${_prefix1}""MYOS                           = $MYOS"
    echo "${_prefix1}""MYOSREL                        = $MYOSREL"
    echo
    echo "${_prefix1}""DIST                           = $DIST"
    echo "${_prefix1}""DISTREL                        = $DISTREL"
    echo "${_prefix1}""OS                             = $OS"
    echo "${_prefix1}""OSREL                          = $OSREL"
    echo
    echo "${_prefix1}""CONF-FILE                      = ${IDDIR}/${LABEL}.ctys"
    case ${C_SESSIONTYPE} in
	VMW)
	    echo "${_prefix1}""VMX-FILE                       = ${IDDIR}/${LABEL}.vmx"
	    ;;
	XEN)
	    echo "${_prefix1}""WRAPPERSCRIPT                  = ${IDDIR}/${LABEL}.sh"
	    echo "${_prefix1}""XEN-CONF-FILE                  = ${IDDIR}/${LABEL}.conf"
	    case ${DIST} in
		CentOS)
		    echo "${_prefix1}""kickstart                      = ${IDDIR}/${LABEL}-centos-5.ks"
		    ;;

		Scientific)
		    echo "${_prefix1}""kickstart                      = ${IDDIR}/${LABEL}-Scientific-5.ks"
		    ;;

		Fedora)
		    echo "${_prefix1}""kickstart                      = ${IDDIR}/${LABEL}-Fedora-8.ks"
		    ;;

		debian)
		    case ${MYDIST} in
			debian) 
                            echo "${_prefix1}""debootstrap-wrapper            = ${IDDIR}/${LABEL}-debian-5.sh"
			    ;;
			*)	
			    echo -e -n "${_prefix1}""debootstrap-wrapper("
			    setFontAttrib FBLUE "debian";
                            echo ")    = ${IDDIR}/${LABEL}-debian-5.sh"
			    ;;
		    esac
		    ;;
		Ubuntu)
		    case ${MYDIST} in
			Ubuntu) 
                            echo "${_prefix1}""debootstrap-wrapper            = ${IDDIR}/${LABEL}-Ubuntu-9.sh"
			    ;;
			*)	
			    echo -e -n "${_prefix1}""debootstrap-wrapper("
			    setFontAttrib FBLUE "debian";
                            echo ")    = ${IDDIR}/${LABEL}-Ubuntu-9.sh"
			    ;;
		    esac
		    ;;
	    esac
	    ;;
	QEMU)
	    echo "${_prefix1}""WRAPPERSCRIPT                  = ${IDDIR}/${LABEL}.sh"
	    case ${DIST} in
		CentOS)
		    echo "${_prefix1}""kickstart                      = ${IDDIR}/${LABEL}-centos-5.ks"
		    ;;

		debian)
#		    echo "${_prefix1}""debootstrap-wrapper            = ${IDDIR}/${LABEL}-debian-5.sh"
		    ;;
	    esac
	    ;;
    esac
    echo
    case ${C_SESSIONTYPE} in
	VMW)
	    ;;
	XEN)
	    echo "${_prefix1}""STARTERCALL                    = ${XM}"
#ffs        echo "${_prefix1}""WRAPPERCALL                    = ${WRAPPERCALL}"
	    echo "${_prefix1}""BOOTLOADER                     = ${BOOTLOADER}"
	    ;;
	QEMU)
	    echo "${_prefix1}""STARTERCALL                    = ${STARTERCALL}"
	    echo "${_prefix1}""WRAPPERCALL                    = ${WRAPPERCALL}"
	    ;;
    esac
    echo
    echo "${_prefix1}""UUID                           = $UUID"
    echo "${_prefix1}""MAC                            = $MAC"
    echo "${_prefix1}""DHCP                           = $DHCP"
    echo "${_prefix1}""IP                             = $IP"
    echo "${_prefix1}""NETMASK                        = $NETMASK"
    echo "${_prefix1}""GATEWAY                        = $GATEWAY"
    echo "${_prefix1}""BRIDGE                         = $BRIDGE"
    echo
    echo "${_prefix1}""ARCH                           = $ARCH"
    case ${C_SESSIONTYPE} in
	VMW);;
	*)
	    echo "${_prefix1}""ACCELERATOR                    = $ACCELERATOR"
	    ;;
    esac
    echo "${_prefix1}""SMP                            = $SMP"
    echo "${_prefix1}""MEMSIZE                        = $MEMSIZE"
    case ${C_SESSIONTYPE} in
	VMW);;
	*)
	    echo "${_prefix1}""KBD_LAYOUT                     = $KBD_LAYOUT"
	    ;;
    esac
    echo
    case ${C_SESSIONTYPE} in
	VMW)
# 	    echo "${_prefix1}""XM                             = ${XM}"
# 	    echo "${_prefix1}""VIRSH                          = ${VIRSH}"
# 	    echo "${_prefix1}""XENTRACE                       = ${XENTRACE}"
# 	    echo "${_prefix1}""MAGICID                        = ${XEN_MAGICID}"
# 	    echo "${_prefix1}""HYPERREL-XEN                   = ${XEN_HYPERREL}"
# 	    echo "${_prefix1}""HYPERREL-XEN-ACCELERATOR       = ${ACCELERATOR}"
	    ;;
	XEN)
	    echo "${_prefix1}""XM                             = ${XM}"
	    echo "${_prefix1}""VIRSH                          = ${VIRSH}"
	    echo "${_prefix1}""XENTRACE                       = ${XENTRACE}"
	    echo "${_prefix1}""MAGICID                        = ${XEN_MAGICID}"
	    echo "${_prefix1}""HYPERREL-XEN                   = ${XEN_HYPERREL}"
	    echo "${_prefix1}""HYPERREL-XEN-ACCELERATOR       = ${ACCELERATOR}"
	    ;;
	QEMU)
	    echo "${_prefix1}""QEMUBASE                       = ${QEMUBASE}"
	    echo "${_prefix1}""MAGICID                        = ${QEMUBASE_MAGICID}"
	    echo "${_prefix1}""HYPERREL-QEMU                  = ${QEMUBASE_HYPERREL}"
	    echo "${_prefix1}""HYPERREL-QEMU-ACCELERATOR      = ${QEMUBASE_ACCELERATOR}"
	    echo
	    echo "${_prefix1}""QEMUKVM                        = ${QEMUKVM}"
	    echo "${_prefix1}""MAGICID                        = ${QEMUKVM_MAGICID}"
	    echo "${_prefix1}""HYPERREL-KVM                   = ${QEMUKVM_HYPERREL}"
	    echo "${_prefix1}""HYPERREL-KVM-ACCELERATOR       = ${QEMUKVM_ACCELERATOR}"
	    ;;
    esac
    case ${C_SESSIONTYPE} in
	VMW);;
	*)
	    echo
	    echo "${_prefix1}""DEFAULTBOOTMODE                = $DEFAULTBOOTMODE"
	    case ${DEFAULTBOOTMODE} in
		VHDD|HDD)
		    echo "${_prefix1}""  HDDBOOTIMAGE                 = $DEFAULTINSTTARGET"
		    echo "${_prefix1}""  HDDBOOTIMAGE_INST_SIZE       = $HDDBOOTIMAGE_INST_SIZE"
		    echo "${_prefix1}""  HDDBOOTIMAGE_INST_BLOCKSIZE  = $HDDBOOTIMAGE_INST_BLOCKSIZE"
		    echo "${_prefix1}""  HDDBOOTIMAGE_INST_BLOCKCOUNT = $HDDBOOTIMAGE_INST_BLOCKCOUNT"
		    ;;
		USB)
		    echo "${_prefix1}""  USB                          = MAX-AVAIL"
		    ;;
	    esac
	    echo
	    case ${DEFAULTBOOTMODE} in
		FDD)
		    echo "${_prefix0}""Fixed Values from defaults.conf-file:"
		    echo "${_prefix1}""FDDBOOTIMAGE_INST_SIZE         = $FDDBOOTIMAGE_INST_SIZE"
		    ;;
		CD)
		    echo "${_prefix0}""Fixed Values from defaults.conf-file:"
		    echo "${_prefix1}""CDBOOTIMAGE_INST_SIZE          = $CDBOOTIMAGE_INST_SIZE"
		    ;;
		DVD)
		    echo "${_prefix0}""Fixed Values from defaults.conf-file:"
		    echo "${_prefix1}""DVDBOOTIMAGE_INST_SIZE         = $DVDBOOTIMAGE_INST_SIZE"
		    ;;
	    esac
	    ;;
    esac
    echo
    case ${C_SESSIONTYPE} in
	XEN)
	    echo "${_prefix1}""BOOTLOADER                     = ${DEFAULT_BOOTLOADER}"
	    echo 
	    ;;
    esac
    case ${C_SESSIONTYPE} in
	VMW);;
	*)
	    case ${DEFAULTINSTMODE} in
		*)
		    if [ -z "$INST_KERNEL" ];then
			echo "${_prefix1}""  Use bootable media of DEFAULTINSTMODE"
		    else
			case ${ACCELERATOR} in
			    HVM)
				echo "${_prefix1}""  INST_KERNEL==BOOTLOADER      = $INST_KERNEL"
				;;
			    PARA)
				echo "${_prefix1}""  INST_KERNEL(kernel)          = $INST_KERNEL"
				echo "${_prefix1}""  INST_INITRD(ramdisk)         = $INST_INITRD"
				echo "${_prefix1}""  INST_EXTRA(extra)            = $INST_EXTRA"
				echo "${_prefix1}""  INST_ROOTARGS(root)          = $INST_ROOTARGS"
				;;
			esac
		    fi
		    ;;
	    esac
	    case ${DIST} in
		debian)
		    case ${ACCELERATOR} in
			PARA)
			    echo 
			    echo "${_prefix1}""  DOMU_KERNEL(kernel)          = $DOMU_KERNEL"
			    echo "${_prefix1}""  DOMU_MODULESDIR              = $DOMU_MODULESDIR"
			    echo "${_prefix1}""  DOMU_INITRD(ramdisk)         = $DOMU_INITRD"
			    echo "${_prefix1}""  DOMU_EXTRA(extra)            = $DOMU_EXTRA"
			    echo "${_prefix1}""  DOMU_ROOT(root)              = $DOMU_ROOT"
			    ;;
		    esac
		    ;;
	    esac
	    echo
	    echo "${_prefix1}""DEFAULTINSTMODE                = <$DEFAULTINSTMODE>"
	    case ${DEFAULTINSTMODE} in
		DVD|CD)
		    echo "${_prefix1}""  INSTSRCCDROM                 = $INSTSRCCDROM"
		    ;;
		FDD)
		    echo "${_prefix1}""  INSTSRCFDD                   = $INSTSRCFDD"
		    ;;
		HDD)
		    echo "${_prefix1}""  INSTSRCHDD                   = $INSTSRCHDD"
		    ;;
		USB)
		    echo "${_prefix1}""  INSTSRCUSB                   = $INSTSRCUSB"
		    ;;
	    esac
	    echo
	    echo
	    ;;
    esac
    case ${C_SESSIONTYPE} in
	VMW)
	    echo "${_prefix1}""Values to be adapted manually:"
	    echo
	    echo "${_prefix1}""  LABEL <-> displayName"
	    echo "${_prefix1}""    from:"
	    echo "${_prefix1}""      displayName                = <displayName>"
	    echo "${_prefix1}""    to:"
	    echo "${_prefix1}""      displayName                = <$LABEL>"
	    echo
	    echo "${_prefix1}""  Ethernet:"
	    echo "${_prefix1}""    from:"
	    echo "${_prefix1}""      ethernet0.addressType      = \"generated\""
	    echo "${_prefix1}""      ethernet0.generatedAddress = \"00:0c:....\""
	    echo "${_prefix1}""    to:"
	    echo "${_prefix1}""      ethernet0.addressType      = \"static\""
	    echo "${_prefix1}""      ethernet0.address          = \"$MAC\""
	    echo
	    echo "${_prefix1}""  UUID:"
	    echo "${_prefix1}""    from:"
	    echo "${_prefix1}""      uuid.action                = \"generated\""
	    echo "${_prefix1}""    to:"
	    echo "${_prefix1}""      uuid.action                = \"keep\""
	    echo
	    echo
	    ;;
    esac
    echo
    echo
    echo "${_prefix1}""VMSTATE                        = $VMSTATE"
    echo
}




function createConf () {
    echo
    setFontAttrib BCYAN "                                                                                 "
    echo
    setFontAttrib BCYAN "  +---------------------------------------------------------------------------+  "
    echo
    setFontAttrib BCYAN "  |                                                                           |  "
    echo
    setFontAttrib BCYAN "  |     ";
	    setFontAttrib BCYAN $(printf "Start creation of configuration files for %s" $(setFontAttrib UNDL $(setFontAttrib BOLD "$C_SESSIONTYPE")));
    echo -e -n $(setFontAttrib BCYAN " ")
    setFontAttrib BCYAN $(printf "with %s"$(setFontAttrib UNDL $(setFontAttrib BOLD "x86-Guests")));
    case $C_SESSIONTYPE in
	QEMU)
	    setFontAttrib BCYAN "        |  ";
	    ;;
	XEN|VMW)
	    setFontAttrib BCYAN "         |  ";
	    ;;
    esac
    echo
    setFontAttrib BCYAN "  |                             Version:${VERSION//_/.}                             |  "
    echo
    setFontAttrib BCYAN "  |                                                                           |  "
    echo
    setFontAttrib BCYAN "  +---------------------------------------------------------------------------+  "
    echo
    setFontAttrib BCYAN "                                                                                 "
    echo
    echo

    SERNO=$DATETIME;
    IDDIR=${_RDIRECTORY:-$PWD}
    case ${C_SESSIONTYPE} in
	XEN)
	    ID="${IDDIR}/${LABEL:-<LABEL>}.ctys"
	    ;;
	VMW)
	    ID="${IDDIR}/${LABEL:-<LABEL>}.vmx"
	    ;;
	*)
	    ID="${IDDIR}/${LABEL:-<LABEL>}.ctys"
	    ;;
    esac

    displaySystemValues

    while [ 1 == 1 ]; do
	getValues
	ID=${IDDIR}/${LABEL}
	displayValues

	echo
	echo
	echo
	setFontAttrib BCYAN "                                                                               "
	echo
	setFontAttrib BCYAN "  +-------------------------------------------------------------------------+  "
	echo
	setFontAttrib BCYAN "  |                                                                         |  "
	echo
	setFontAttrib BCYAN "  |    Continue(y) now for actual creation of files or repeat(n) dialog.    |  ";
	echo
	setFontAttrib BCYAN "  |    Cancel with <Ctrl-C>                                                 |  ";
	echo
	setFontAttrib BCYAN "  |                                                                         |  "
	echo
	setFontAttrib BCYAN "  +-------------------------------------------------------------------------+  "
	echo
	setFontAttrib BCYAN "                                                                               "
	echo
	echo
	echo
	echo
		DEFAULT_INST_EXTRA="${DEFAULT_INST_EXTRA} ${TCP} "

	getOK
	[ $? -eq 0 ]&&break
    done
}



function exchangeMARKER () {
    local _state=${1}
    local _fname=${2}
    case ${MYOS} in
	Linux|SunOS|FreeBSD|OpenBSD)
            #
            #performance is not the priority
            #

            #
            #conf file
	    awk -v vstate="${_state}" '{
               gsub("MARKER_SESSIONTYPE",                  "'"${C_SESSIONTYPE}"'"                );

               gsub("MARKER_SERNO",                        "'"${SERNO}"'"                        );

               gsub("MARKER_CTYSREL",                      "'"${CTYSREL//_/.}"'"                 );
               gsub("MARKER_VERNO",                        "'"${VERSION//_/.}"'"                 );

               gsub("MARKER_DEFAULTSTARTERCALL",           "'"${STARTERCALL}"'"                  );
               gsub("MARKER_DEFAULTWRAPPERCALL",           "'"${WRAPPERCALL}"'"                  );

               gsub("MARKER_IDDIR",                        "'"${IDDIR}"'"                        );
               gsub("MARKER_ID__",                         "'"${_myconf}"'"                      );

               gsub("MARKER_UID",                          "'"${MYUID}"'"                        );
               gsub("MARKER_GID",                          "'"${MYGID}"'"                        );
               gsub("MARKER_DATE",                         "'"${DATE}"'"                         );
               gsub("MARKER_HOST",                         "'"${MYHOST}"'"                       );

               gsub("MARKER_ACCELERATOR",                  "'"${ACCELERATOR}"'"                  );
               gsub("MARKER_QEMU_HYPERREL",                "'"${QEMU_HYPERREL}"'"                );
               gsub("MARKER_QEMU_MAGICID",                 "'"${QEMU_MAGICID}"'"                 );
               gsub("MARKER_QEMU__",                       "'"${QEMUBASE}"'"                     );

               gsub("MARKER_XEN_HYPERREL",                 "'"${XEN_HYPERREL}"'"                 );
               gsub("MARKER_XEN_MAGICID",                  "'"${XEN_MAGICID}"'"                  );
               gsub("MARKER_XEN__",                        "'"${XM}"'"                           );

               gsub("MARKER_QEMUBASE_ACCELERATOR",         "'"${QEMUBASE_ACCELERATOR}"'"         );
               gsub("MARKER_QEMUBASE_HYPERREL",            "'"${QEMUBASE_HYPERREL}"'"            );
               gsub("MARKER_QEMUBASE_MAGICID",             "'"${QEMUBASE_MAGICID}"'"             );
               gsub("MARKER_QEMUBASE__",                   "'"${QEMUBASE}"'"                     );

               gsub("MARKER_QEMUKVM_ACCELERATOR",          "'"${QEMUKVM_ACCELERATOR}"'"          );
               gsub("MARKER_QEMUKVM_HYPERREL",             "'"${QEMUKVM_HYPERREL}"'"             );
               gsub("MARKER_QEMUKVM_MAGICID",              "'"${QEMUKVM_MAGICID}"'"              );
               gsub("MARKER_QEMUKVM__",                    "'"${QEMUBASE}"'"                     );


               gsub("MARKER_CATEGORY",                     "'"${CATEGORYinfo}"'"                 );
               gsub("MARKER_PLATFORM",                     "'"${PLATFORMinfo}"'"                 );
               gsub("MARKER_VMSTATE",                      "'"${VMSTATEinfo}"'"                  );
               gsub("MARKER_CPUINFO",                      "'"${CPUinfo}"'"                      );
               gsub("MARKER_ARCH",                         "'"${ARCHinfo}"'"                     );
               gsub("MARKER_SMP",                          "'"${SMPinfo}"'"                      );

               gsub("MARKER_INST_DIST",                    "'"${MYDIST}"'"                       );
               gsub("MARKER_INST_RELEASE",                 "'"${MYREL}"'"                        );
               gsub("MARKER_INST_OSREL",                   "'"${MYOSREL}"'"                      );
               gsub("MARKER_INST_OS",                      "'"${MYOS}"'"                         );

               gsub("MARKER_EDITOR",                       "'"${MYUID}"'"                        );
               gsub("MARKER_LABEL",                        "'"${LABEL}"'"                        );
      	       gsub("MARKER_UUID",                         "'"${UUID}"'"                         );
	       gsub("MARKER_MAC",                          "'"${MAC}"'"                          );
	       gsub("MARKER_IP",                           "'"${IP}"'"                           );
	       gsub("MARKER_DHCP",                         "'"${DHCP}"'"                         );
	       gsub("MARKER_NETMASK",                      "'"${NETMASK}"'"                      );
	       gsub("MARKER_GATEWAY",                      "'"${GATEWAY}"'"                      );
	       gsub("MARKER_BRIDGE",                       "'"${BRIDGE}"'"                       );
	       gsub("MARKER_DIST",                         "'"${DIST}"'"                         );
	       gsub("MARKER_RELEASE",                      "'"${DISTREL}"'"                      );
	       gsub("MARKER_OSREL",                        "'"${OSREL}"'"                    );
	       gsub("MARKER_OS_",                          "'"${OS}"'"                           );
	       gsub("MARKER_ARCH",                         "'"${ARCH}"'"                         );
	       gsub("MARKER_MEMSIZE",                      "'"${MEMSIZE}"'"                      );
	       gsub("MARKER_KBD_LAYOUT",                   "'"${KBD_LAYOUT}"'"                   );

	       gsub("MARKER_DEFAULTBOOTMODE",              "'"${DEFAULTBOOTMODE}"'"              );
	       gsub("MARKER_DEFAULTINSTMODE",              "'"${DEFAULTINSTMODE}"'"              );
	       gsub("MARKER_DEFAULTINSTTARGET",            "'"${DEFAULTINSTTARGET}"'"            );
	       gsub("MARKER_DEFAULTINSTSOURCE",            "'"${DEFAULTINSTSOURCE}"'"            );

	       gsub("MARKER_INSTSRCCDROM",                 "'"${INSTSRCCDROM}"'"                 );
	       gsub("MARKER_INSTSRCFDD",                   "'"${INSTSRCFDD}"'"                   );
	       gsub("MARKER_INSTSRCHDD",                   "'"${INSTSRCHDD}"'"                   );
	       gsub("MARKER_INSTSRCUSB",                   "'"${INSTSRCUSB}"'"                   );

	       gsub("MARKER_HDD_A",                        "'"${HDDBOOTIMAGE}"'"                 );
	       gsub("MARKER_HDD_a",                        "'"${HDD_a}"'"                        );
	       gsub("MARKER_HDD_B",                        "'"${HDD_B}"'"                        );
	       gsub("MARKER_HDD_b",                        "'"${HDD_b}"'"                        );
	       gsub("MARKER_HDD_C",                        "'"${HDD_C}"'"                        );
	       gsub("MARKER_HDD_c",                        "'"${HDD_c}"'"                        );
	       gsub("MARKER_HDD_D",                        "'"${HDD_D}"'"                        );
	       gsub("MARKER_HDD_d",                        "'"${HDD_d}"'"                        );
	       gsub("MARKER_HDDBOOTIMAGE_INST_SIZE",       "'"${HDDBOOTIMAGE_INST_SIZE}"'"       );
	       gsub("MARKER_HDDBOOTIMAGE_INST_BLOCKSIZE",  "'"${HDDBOOTIMAGE_INST_BLOCKSIZE}"'"  );
	       gsub("MARKER_HDDBOOTIMAGE_INST_BLOCKCOUNT", "'"${HDDBOOTIMAGE_INST_BLOCKCOUNT}"'" );
	       gsub("MARKER_HDDBOOTIMAGE_INST_BALLOON",    "'"${HDDBOOTIMAGE_INST_BALLOON:-y}"'" );

	       gsub("MARKER_INST_BOOTLOADER",              "'"${INST_BOOTLOADER}"'"              );
	       gsub("MARKER_INST_KERNEL",                  "'"${INST_KERNEL}"'"                  );
 	       gsub("MARKER_INST_INITRD",                  "'"${INST_INITRD}"'"                  );
	       gsub("MARKER_INST_EXTRA",                   "'"${INST_EXTRA}"'"                   );
	       gsub("MARKER_INST_ROOTARGS",                "'"${INST_ROOTARGS}"'"                );


	       gsub("MARKER_VNC__",                        "'"${VNC:-1}"'"                       );
	       gsub("MARKER_VNCCONSOLE",                   "'"${VNCCONSOLE:-1}"'"                );
	       gsub("MARKER_VNCUNUSED",                    "'"${VNCUNUSED:-1}"'"                 );


	       gsub("MARKER_LOCALTIME",                    "'"${TIMEOPT:-1}"'"                   );

	       gsub("MARKER_KSLOCATION",                   "'"${KSLOCATION:-http://${MYHOST}/tmp/default.ks}"'"   );
	       gsub("MARKER_REPOSITORY_URL",               "'"${DEFAULT_REPOSITORY_URL:-http://${MYHOST}/tmp/${MYDIST}-${MYREL}}"'" );

	       gsub("MARKER_BOOTLOADER",                   "'"${BOOTLOADER}"'"                   );
	       gsub("MARKER_DOMU_KERNEL",                  "'"${DOMU_KERNEL:-$DEFAULT_DOMU_KERNEL}"'"   );
	       gsub("MARKER_DOMU_MODULESDIR",              "'"${DOMU_MODULESDIR:-$DEFAULT_DOMU_MODULESDIR}"'"   );
	       gsub("MARKER_DOMU_INITRD",                  "'"${DOMU_INITRD:-$DEFAULT_DOMU_INITRD}"'"   );
	       gsub("MARKER_DOMU_EXTRA",                   "'"${DOMU_EXTRA:-$DEFAULT_DOMU_EXTRA}"'"   );
	       gsub("MARKER_DOMU_ROOT",                    "'"${DOMU_ROOT:-$DEFAULT_DOMU_ROOT}"'"   );

               if(vstate=="ACTIVE"){
   	         gsub("MAGICID-IGNORE", "MAGICID-do-not-IGNORE =>ACTIVATED");
               }

               print;
               }' ${_fname}

	    ;;
	*)
	    ABORT=1;
	    printERR $LINENO $BASH_SOURCE ${ABORT} "OS not yet supported:OS=${MYOS}"
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Check your installation."
	    gotoHell ${ABORT}
	    ;;
    esac
}

function createData () {
    local _myconf=${IDDIR}/${LABEL}.conf
    echo
    echo
    echo
    setFontAttrib BCYAN "                                                                               "
    echo
    setFontAttrib BCYAN "  +-------------------------------------------------------------------------+  "
    echo
    setFontAttrib BCYAN "  |                                                                         |  "
    echo
    setFontAttrib BCYAN "  |    Start actual creation                                                |  ";
    echo
    setFontAttrib BCYAN "  |                                                                         |  "
    echo
    setFontAttrib BCYAN "  +-------------------------------------------------------------------------+  "
    echo
    setFontAttrib BCYAN "                                                                               "
    echo
    echo
    echo
    echo
    if [ -f "${_myconf}" -o -f "${_myconf%.conf}.ctys" ];then
	local _curmv=;
	setFontAttrib UNDL "Move and deactivate present files:"
	echo
	echo
	if [ -f "${_myconf}" ];then
	    case ${C_SESSIONTYPE} in
		XEN)  echo "${_prefix0}""XEN-CONF-FILE           = ${_myconf##*/}.${DATETIME}"
		    sed 's/MAGICID-do-not-IGNORE/MAGICID-IGNORE/g;s/ACTIVATED/DISABLED/g;' ${_myconf}>${_myconf}.${DATETIME}
		    rm  -f ${_myconf}
		    ;;
	    esac
	fi
        _curmv="${_myconf%.conf}.ctys";
        if [ -f "${_curmv}" ];then
            echo "${_prefix0}""CTYS-CONF-FILE          = ${_curmv##*/}.${DATETIME}"
            sed 's/MAGICID-do-not-IGNORE/MAGICID-IGNORE/g;s/ACTIVATED/DISABLED/g;' ${_curmv}>${_curmv}.${DATETIME}
            rm  -f ${_curmv}
        fi
        _curmv="${_myconf%.conf}.sh";
        if [ -f "${_curmv}" ];then
            echo "${_prefix0}""WRAPPERSCRIPT           = ${_curmv##*/}.${DATETIME}"
            sed 's/MAGICID-do-not-IGNORE/MAGICID-IGNORE/g;s/ACTIVATED/DISABLED/g;' ${_curmv}>${_curmv}.${DATETIME}
            rm  -f ${_curmv}
        fi
    case ${DIST} in
	CentOS)
            _curmv="${_myconf%.conf}-centos-5.ks";
            if [ -f "${_curmv}" ];then
		echo "${_prefix0}""Kickstart File          = ${_curmv##*/}.${DATETIME}"
		sed 's/MAGICID-do-not-IGNORE/MAGICID-IGNORE/g;s/ACTIVATED/DISABLED/g;' ${_curmv}>${_curmv}.${DATETIME}
		rm  -f ${_curmv}
            fi
	    ;;

	Scientific)
            _curmv="${_myconf%.conf}-Scientific-5.ks";
            if [ -f "${_curmv}" ];then
		echo "${_prefix0}""Kickstart File          = ${_curmv##*/}.${DATETIME}"
		sed 's/MAGICID-do-not-IGNORE/MAGICID-IGNORE/g;s/ACTIVATED/DISABLED/g;' ${_curmv}>${_curmv}.${DATETIME}
		rm  -f ${_curmv}
            fi
	    ;;

	debian)
            _curmv="${_myconf%.conf}-debian-5.sh"
            if [ -f "${_curmv}" ];then
		echo -n -e "${_prefix0}""debootstrap-wrapper("
		setFontAttrib FBLUE "*";
		echo ")  = ${_curmv##*/}.${DATETIME}"
		sed 's/MAGICID-do-not-IGNORE/MAGICID-IGNORE/g;s/ACTIVATED/DISABLED/g;' ${_curmv}>${_curmv}.${DATETIME}
		rm  -f ${_curmv}
            fi
	    ;;
	Ubuntu)
            _curmv="${_myconf%.conf}-Ubuntu-5.sh"
            if [ -f "${_curmv}" ];then
		echo -n -e "${_prefix0}""debootstrap-wrapper("
		setFontAttrib FBLUE "*";
		echo ")  = ${_curmv##*/}.${DATETIME}"
		sed 's/MAGICID-do-not-IGNORE/MAGICID-IGNORE/g;s/ACTIVATED/DISABLED/g;' ${_curmv}>${_curmv}.${DATETIME}
		rm  -f ${_curmv}
            fi
	    ;;
    esac
    fi
    echo
    echo
    setFontAttrib UNDL "Create a new set of configuration files and helper scripts:"
    echo
    echo
    case ${C_SESSIONTYPE} in
	XEN)  echo -n -e "${_prefix0}""XEN-CONF-FILE           = "
	    setFontAttrib BOLD "${_myconf}"
	    echo
	    ;;
    esac
    echo -n -e "${_prefix0}""CTYS-CONF-FILE          = "
    setFontAttrib BOLD "${_myconf%.conf}.ctys"
    echo
    case ${C_SESSIONTYPE} in
	QEMU)
	    echo -n -e "${_prefix0}""WRAPPERSCRIPT           = "
	    setFontAttrib BOLD "${_myconf%.conf}.sh"
	    ;;
	XEN)
	    echo -n -e "${_prefix0}""WRAPPERSCRIPT           = "
	    setFontAttrib BOLD "${_myconf%.conf}.sh"
	    ;;
    esac    

    case ${DIST} in
	CentOS)
	    echo
	    echo
	    echo  -e "${_prefix0}""Installation-Utilities:"
 	    echo -n -e "${_prefix1}""Basic Kickstart-File  = "
	    setFontAttrib BOLD "${_myconf%.conf}-centos-5.ks"
	    echo
	    echo
 	    echo -n -e "${_prefix2}"
	    setFontAttrib FMAGENTA "REMINDER:"
	    echo
 	    echo -e "${_prefix3}""This is applicable for INSTMODE=KS only!!!"
 	    echo -e "${_prefix3}""Don't forget to copy this file to the appropriate location"
 	    echo -e "${_prefix3}""as given by value of INST_EXTRA. Read permissions for all"
 	    echo -e "${_prefix3}""is required for remote access."
	    echo
	    ;;
	Scientific)
	    echo
	    echo
	    echo  -e "${_prefix0}""Installation-Utilities:"
 	    echo -n -e "${_prefix1}""Basic Kickstart-File  = "
	    setFontAttrib BOLD "${_myconf%.conf}-Scientific-5.ks"
	    echo
	    echo
 	    echo -n -e "${_prefix2}"
	    setFontAttrib FMAGENTA "REMINDER:"
	    echo
 	    echo -e "${_prefix3}""Don't forget to copy this file to the appropriate location"
 	    echo -e "${_prefix3}""as given by value of INST_EXTRA. Read permissions for all"
 	    echo -e "${_prefix3}""is required for remote access."
	    echo
	    ;;
	Fedora)
	    echo
	    echo
	    echo  -e "${_prefix0}""Installation-Utilities:"
 	    echo -n -e "${_prefix1}""Basic Kickstart-File  = "
	    setFontAttrib BOLD "${_myconf%.conf}-Fedora-5.ks"
	    echo
	    echo
 	    echo -n -e "${_prefix2}"
	    setFontAttrib FMAGENTA "REMINDER:"
	    echo
 	    echo -e "${_prefix3}""Don't forget to copy this file to the appropriate location"
 	    echo -e "${_prefix3}""as given by value of INST_EXTRA. Read permissions for all"
 	    echo -e "${_prefix3}""is required for remote access."
	    echo
	    ;;
	debian)
	    case ${C_SESSIONTYPE} in
		XEN)
		    echo
		    echo
		    echo  -e "${_prefix0}""Installation-Utilities:"
		    echo -n -e "${_prefix1}""debootstrap-wrapper("
		    setFontAttrib FBLUE "*";
		    echo -n -e ")= "
		    setFontAttrib BOLD "${_myconf%.conf}-${ACCELERATOR}-debian-5.sh"
		    echo
		    echo
 		    echo -n -e "${_prefix2}"
		    setFontAttrib FMAGENTA "REMINDER:"
		    echo
 		    echo -e "${_prefix3}""This file creates a fully operational VM and is a template for  "
 		    echo -e "${_prefix3}""creation of para virtualized VMs based on debian/debootstrap."
 		    echo -e "${_prefix3}""The creation is provided native on debian only, but the created VM "
 		    echo -e "${_prefix3}""with stored kernel+initrd could be executed on several other"
 		    echo -e "${_prefix3}""Linux-Distributions."
		    echo
		    ;;
	    esac
	    ;;
	Ubuntu)
	    case ${C_SESSIONTYPE} in
		XEN)
		    case $ACCELERATOR in
			PARA)
			    echo
			    echo
			    echo  -e "${_prefix0}""Installation-Utilities:"
			    echo -n -e "${_prefix1}""debootstrap-wrapper("
			    setFontAttrib FBLUE "*";
			    echo -n -e ")= "
			    setFontAttrib BOLD "${_myconf%.conf}-${ACCELERATOR}-Ubuntu-9.sh"
			    ;;
		    esac
		    ;;
	    esac
	    ;;
    esac
    echo
    echo

    setFontAttrib FRED   "."
    setFontAttrib FGREEN "."
    setFontAttrib FBKUE  "."
    setFontAttrib FRED   "."
    setFontAttrib FGREEN "."
    setFontAttrib FBKUE  "."
    setFontAttrib FRED   "."
    setFontAttrib FGREEN "."
    setFontAttrib FBKUE  "."
    setFontAttrib FRED   "."
    setFontAttrib FGREEN "."
    setFontAttrib FBKUE  "."
    setFontAttrib FRED   "."
    setFontAttrib FGREEN "."
    setFontAttrib FBKUE  "."
    setFontAttrib FRED   "."
    setFontAttrib FGREEN "."
    setFontAttrib FBKUE  "."
    setFontAttrib FRED   "."
    setFontAttrib FGREEN "."
    setFontAttrib FBKUE  "."
    echo
    local _idxX=0;

    echo
    echo -n -e "$((_idxX++)). "
    if [ -n "${EXPERT_MODE}" ];then
	setFontAttrib FBLUE "Replacing"
	echo -n -e " \"MARKER\" with actual values and create:"
	echo
	echo "     ${_myconf%.conf}.ctys"
	echo 
	echo "   from"
	echo "     ${MYCONFPATH}/ctys-createConfVM.d/template.${C_SESSIONTYPE}.ctys"
	echo 
    else
	setFontAttrib FBLUE "Create:"
	echo "${_myconf%.conf}.ctys"
    fi
    exchangeMARKER ${VMSTATE:-ACTIVE} ${MYCONFPATH}/ctys-createConfVM.d/template.${C_SESSIONTYPE}.ctys >${_myconf%.conf}.ctys
    if [ -n "${EXPERT_MODE}" ];then
	echo -n -e "   ..."
	setFontAttrib FGREEN "done"
	echo
	echo
    fi

    case ${C_SESSIONTYPE} in
	XEN) 
	    echo -n -e "$((_idxX++)). "
	    if [ -n "${EXPERT_MODE}" ];then
		setFontAttrib FBLUE "Replacing"
		echo -n -e " \"MARKER\" with actual values and create:"
		echo
		echo "     ${_myconf}"
		echo 
		echo "   from"
		echo "     ${MYCONFPATH}/ctys-createConfVM.d/template.${C_SESSIONTYPE}.conf"
		echo 
	    else
		setFontAttrib FBLUE "Create:"
		echo "${_myconf}"
	    fi
	    exchangeMARKER IGNORE ${MYCONFPATH}/ctys-createConfVM.d/template.${C_SESSIONTYPE}.conf >${_myconf}
	    if [ -n "${EXPERT_MODE}" ];then
		echo -n -e "   ..."
		setFontAttrib FGREEN "done"
		echo
		echo
	    fi
	    ;;
    esac
    case ${C_SESSIONTYPE} in
	QEMU|XEN) 
	    echo -n -e "$((_idxX++)). "
	    if [ -n "${EXPERT_MODE}" ];then
		setFontAttrib FBLUE "Replacing"
		echo -n -e " \"MARKER\" with actual values and create:"
		echo
		echo "     ${_myconf%.conf}.sh"
		echo 
		echo "   from"
		echo "     ${MYCONFPATH}/ctys-createConfVM.d/template.${C_SESSIONTYPE}.sh"
		echo 
	    else
		setFontAttrib FBLUE "Create:"
		echo "${_myconf%.conf}.sh"
	    fi
	    exchangeMARKER IGNORE ${MYCONFPATH}/ctys-createConfVM.d/template.${C_SESSIONTYPE}.sh >${_myconf%.conf}.sh
	    chmod u+x ${_myconf%.conf}.sh
	    if [ -n "${EXPERT_MODE}" ];then
		echo -n -e "   ..."
		setFontAttrib FGREEN "done"
		echo
		echo
	    fi
	    ;;
    esac

    case ${DIST} in
	CentOS)
	    echo -n -e "$((_idxX++)). "
	    if [ -n "${EXPERT_MODE}" ];then
		setFontAttrib FBLUE "Replacing"
		echo -n -e " \"MARKER\" with actual values and create:"
		echo
		echo "     ${_myconf%.conf}-centos-5.ks"
		echo 
		echo "   from"
		echo "     ${MYCONFPATH}/ctys-createConfVM.d/template.centos-5.ks"
		echo 
	    else
		setFontAttrib FBLUE "Create:"
		echo "${_myconf%.conf}-centos-5.ks"
	    fi
	    exchangeMARKER IGNORE ${MYCONFPATH}/ctys-createConfVM.d/template.centos-5.ks >${_myconf%.conf}-centos-5.ks.zwi
	    exchangeMARKER IGNORE ${_myconf%.conf}-centos-5.ks.zwi >${_myconf%.conf}-centos-5.ks
	    rm  -f ${_myconf%.conf}-centos-5.ks.zwi
	    if [ -n "${EXPERT_MODE}" ];then
		echo -n -e "   ..."
		setFontAttrib FGREEN "done"
		echo
		echo
	    fi
	    ;;
	Scientific)
	    echo -n -e "$((_idxX++)). "
	    if [ -n "${EXPERT_MODE}" ];then
		setFontAttrib FBLUE "Replacing"
		echo -n -e " \"MARKER\" with actual values and create:"
		echo
		echo "     ${_myconf%.conf}-Scientific-5.ks"
		echo 
		echo "   from"
		echo "     ${MYCONFPATH}/ctys-createConfVM.d/template.scientific-5.ks"
		echo 
	    else
		setFontAttrib FBLUE "Create:"
		echo "${_myconf%.conf}-scientific-5.ks"
	    fi
	    exchangeMARKER IGNORE ${MYCONFPATH}/ctys-createConfVM.d/template.scientific-5.ks >${_myconf%.conf}-scientific-5.ks.zwi
	    exchangeMARKER IGNORE ${_myconf%.conf}-scientific-5.ks.zwi >${_myconf%.conf}-Scientific-5.ks
	    rm  -f ${_myconf%.conf}-scientific-5.ks.zwi
	    if [ -n "${EXPERT_MODE}" ];then
		echo -n -e "   ..."
		setFontAttrib FGREEN "done"
		echo
		echo
	    fi
	    ;;
	Fedora)
	    echo -n -e "$((_idxX++)). "
	    if [ -n "${EXPERT_MODE}" ];then
		setFontAttrib FBLUE "Replacing"
		echo -n -e " \"MARKER\" with actual values and create:"
		echo
		echo "     ${_myconf%.conf}-Fedora-8.ks"
		echo 
		echo "   from"
		echo "     ${MYCONFPATH}/ctys-createConfVM.d/template.fedora-8.ks"
		echo 
	    else
		setFontAttrib FBLUE "Create:"
		echo "${_myconf%.conf}-Fedora-8.ks"
	    fi
	    exchangeMARKER IGNORE ${MYCONFPATH}/ctys-createConfVM.d/template.fedora-8.ks >${_myconf%.conf}-fedora-8.ks.zwi
	    exchangeMARKER IGNORE ${_myconf%.conf}-fedora-8.ks.zwi >${_myconf%.conf}-Fedora-8.ks
	    rm  -f ${_myconf%.conf}-fedora-8.ks.zwi
	    if [ -n "${EXPERT_MODE}" ];then
		echo -n -e "   ..."
		setFontAttrib FGREEN "done"
		echo
		echo
	    fi
	    ;;
    esac

    case ${C_SESSIONTYPE} in
	XEN)
	    case ${DIST} in
		debian)
		    echo -n -e "$((_idxX++)). "
		    if [ -n "${EXPERT_MODE}" ];then
			setFontAttrib FBLUE "Replacing"
			echo -n -e " \"MARKER\" with actual values and create:"
			echo
			echo "     ${_myconf%.conf}-${ACCELERATOR}-debian-5.sh"
			echo 
			echo "   from"
			echo "     ${MYCONFPATH}/ctys-createConfVM.d/template.${ACCELERATOR}.debian-5.sh"
			echo 
		    else
			setFontAttrib FBLUE "Create:"
			echo "${_myconf%.conf}-debian-5.sh"
		    fi
		    exchangeMARKER IGNORE ${MYCONFPATH}/ctys-createConfVM.d/template.${ACCELERATOR}.${C_SESSIONTYPE}.debian-5.sh >${_myconf%.conf}-${ACCELERATOR}-debian-5.sh
		    if [ -n "${EXPERT_MODE}" ];then
			echo -n -e "   ..."
			setFontAttrib FGREEN "done"
			echo
			echo
		    fi
		    ;;
		Ubuntu)
		    echo -n -e "$((_idxX++)). "
		    if [ -n "${EXPERT_MODE}" ];then
			setFontAttrib FBLUE "Replacing"
			echo -n -e " \"MARKER\" with actual values and create:"
			echo
			echo "     ${_myconf%.conf}-${ACCELERATOR}-Ubuntu-9.sh"
			echo 
			echo "   from"
			echo "     ${MYCONFPATH}/ctys-createConfVM.d/template.${ACCELERATOR}.ubuntu-9.sh"
			echo 
		    else
			setFontAttrib FBLUE "Create:"
			echo "${_myconf%.conf}-Ubuntu-9.sh"
		    fi
		    case $ACCELERATOR in
			PARA)
			    exchangeMARKER IGNORE ${MYCONFPATH}/ctys-createConfVM.d/template.${ACCELERATOR}.${C_SESSIONTYPE}.ubuntu-9.sh >${_myconf%.conf}-${ACCELERATOR}-Ubuntu-9.sh
			    ;;
		    esac
		    if [ -n "${EXPERT_MODE}" ];then
			echo -n -e "   ..."
			setFontAttrib FGREEN "done"
			echo
			echo
		    fi
		    ;;
	    esac
	    ;;
    esac

    echo
    setFontAttrib FRED   "."
    setFontAttrib FGREEN "."
    setFontAttrib FBKUE  "."
    setFontAttrib FRED   "."
    setFontAttrib FGREEN "."
    setFontAttrib FBKUE  "."
    setFontAttrib FRED   "."
    setFontAttrib FGREEN "."
    setFontAttrib FBKUE  "."
    setFontAttrib FRED   "."
    setFontAttrib FGREEN "."
    setFontAttrib FBKUE  "."
    setFontAttrib FRED   "."
    setFontAttrib FGREEN "."
    setFontAttrib FBKUE  "."
    setFontAttrib FRED   "."
    setFontAttrib FGREEN "."
    setFontAttrib FBKUE  "."
    setFontAttrib FRED   "."
    setFontAttrib FGREEN "."
    setFontAttrib FBKUE  "."
    echo
    echo

}



function createImage () {
    local _mcall=${IDDIR}/${LABEL}.sh
    echo 
    echo -e "Going to create the preconfigured storage image now: "
    echo 
    echo -n -e "${_prefix0}"
    setFontAttrib BOLD   "${IDDIR}/${HDDBOOTIMAGE}"
    echo 
    echo 
    getOK
    [ $? -ne 0 ]&&return
    echo
    _mcall="$_mcall ${DARGS:--d printfinal} --initmodeonly --instmode --console=none "
    printFINALCALL $LINENO $BASH_SOURCE "FINAL-EXECCALL" "${_mcall}"
    echo
    setFontAttrib FRED   "."
    setFontAttrib FGREEN "."
    setFontAttrib FBKUE  "."
    setFontAttrib FRED   "."
    setFontAttrib FGREEN "."
    setFontAttrib FBKUE  "."
    setFontAttrib FRED   "."
    setFontAttrib FGREEN "."
    setFontAttrib FBKUE  "."
    setFontAttrib FRED   "."
    setFontAttrib FGREEN "."
    setFontAttrib FBKUE  "."
    setFontAttrib FRED   "."
    setFontAttrib FGREEN "."
    setFontAttrib FBKUE  "."
    setFontAttrib FRED   "."
    setFontAttrib FGREEN "."
    setFontAttrib FBKUE  "."
    setFontAttrib FRED   "."
    setFontAttrib FGREEN "."
    setFontAttrib FBKUE  "."
    echo
    echo
    ${_mcall}
    echo
    setFontAttrib FRED   "."
    setFontAttrib FGREEN "."
    setFontAttrib FBKUE  "."
    setFontAttrib FRED   "."
    setFontAttrib FGREEN "."
    setFontAttrib FBKUE  "."
    setFontAttrib FRED   "."
    setFontAttrib FGREEN "."
    setFontAttrib FBKUE  "."
    setFontAttrib FRED   "."
    setFontAttrib FGREEN "."
    setFontAttrib FBKUE  "."
    setFontAttrib FRED   "."
    setFontAttrib FGREEN "."
    setFontAttrib FBKUE  "."
    setFontAttrib FRED   "."
    setFontAttrib FGREEN "."
    setFontAttrib FBKUE  "."
    setFontAttrib FRED   "."
    setFontAttrib FGREEN "."
    setFontAttrib FBKUE  "."
    echo
}


function saveParaKernel () {
    local _idxX=0;
    if [ -z "${DOMU_KERNEL}" ];then
	return
    fi

    if [ ! -e "${DOMU_KERNEL}" ];then
	ABORT=1;
	printERR $LINENO $BASH_SOURCE ${ABORT} "You have selected to store the kernel+initrd within the VM directory."
	printERR $LINENO $BASH_SOURCE ${ABORT} "The kernel of your choice is on current machine not present:"
	printERR $LINENO $BASH_SOURCE ${ABORT} "."
	printERR $LINENO $BASH_SOURCE ${ABORT} "DOMU_KERNEL=${DOMU_KERNEL}"
	printERR $LINENO $BASH_SOURCE ${ABORT} "."
	printERR $LINENO $BASH_SOURCE ${ABORT} "Either proceed on the target machine with an existing DomU-Kernel"
   	printERR $LINENO $BASH_SOURCE ${ABORT} "or/and choose option '$(setFontAttrib FBLUE "--no-save-para-kernel")' and store manually later."
	gotoHell ${ABORT}

	[  -z "$_NOSAVEPARAKERN" ]&&saveParaKernel

	return
    fi

    if [ "$ACCELERATOR" != PARA ];then
	echo 
	echo -e "The storage of the kernel and the initrd is required for para virtualized systems only."
	echo -e "Thus nothing to do."
	echo 
	return
    fi 

    echo
    setFontAttrib UNDL "Save now kernel and initrd for system independent usage: "
    echo
    echo -n -e "${_prefix0}""The modules for now have to be stored within the VM/GuestOS."
    echo 
    echo 
    echo 
    echo -n -e "${_prefix0}"
    setFontAttrib BOLD   "${IDDIR}/boot"
    echo 
    echo 
    setFontAttrib FRED   "."
    setFontAttrib FGREEN "."
    setFontAttrib FBKUE  "."
    setFontAttrib FRED   "."
    setFontAttrib FGREEN "."
    setFontAttrib FBKUE  "."
    setFontAttrib FRED   "."
    setFontAttrib FGREEN "."
    setFontAttrib FBKUE  "."
    setFontAttrib FRED   "."
    setFontAttrib FGREEN "."
    setFontAttrib FBKUE  "."
    setFontAttrib FRED   "."
    setFontAttrib FGREEN "."
    setFontAttrib FBKUE  "."
    setFontAttrib FRED   "."
    setFontAttrib FGREEN "."
    setFontAttrib FBKUE  "."
    setFontAttrib FRED   "."
    setFontAttrib FGREEN "."
    setFontAttrib FBKUE  "."
    echo
    echo
    echo -n -e "$((_idxX++)). "
    setFontAttrib FBLUE "Create:"
    echo "'${IDDIR}/boot'"
    mkdir -p "${IDDIR}/boot/grub"
    echo

    if [ -e "${DOMU_KERNEL}" ];then
	echo -n -e "$((_idxX++)). "
	setFontAttrib FBLUE "Store:"
	echo "'${DOMU_KERNEL}'"
	cp -a "${DOMU_KERNEL}"  "${IDDIR}/boot"
    fi


    DOMU_KERNEL_CONF="${DOMU_KERNEL%/*}/config${DOMU_KERNEL##*/vmlinuz}"
    if [ -e "${DOMU_KERNEL_CONF}" ];then
	echo -n -e "$((_idxX++)). "
	setFontAttrib FBLUE "Store:"
	echo "'${DOMU_KERNEL_CONF}'"
	cp -a "${DOMU_KERNEL_CONF}"  "${IDDIR}/boot"
    fi

    DOMU_KERNEL_SYSMAP="${DOMU_KERNEL%/*}/System.map${DOMU_KERNEL##*/vmlinuz}"
    if [ -e "${DOMU_KERNEL_SYSMAP}" ];then
	echo -n -e "$((_idxX++)). "
	setFontAttrib FBLUE "Store:"
	echo "'${DOMU_KERNEL_SYSMAP}'"
	cp -a "${DOMU_KERNEL_SYSMAP}"  "${IDDIR}/boot"
    fi



    if [ -e "${DOMU_INITRD}" ];then
	echo -n -e "$((_idxX++)). "
	setFontAttrib FBLUE "Store:"
	echo "'${DOMU_INITRD}'"
	cp -a "${DOMU_INITRD}"  "${IDDIR}/boot"
    fi

    if [ -e "/boot/grub/menu.lst" ];then
	echo -n -e "$((_idxX++)). "
	setFontAttrib FBLUE "Store:"
	echo "'/boot/grub/menu.lst'"
	cp -a "/boot/grub/menu.lst"  "${IDDIR}/boot/grub"
    fi

    if [ -e "/boot/grub/device.map" ];then
	echo -n -e "$((_idxX++)). "
	setFontAttrib FBLUE "Store:"
	echo "'/boot/grub/device.map'"
	cp -a "/boot/grub/device.map"  "${IDDIR}/boot/grub"
    fi

    echo
    setFontAttrib FRED   "."
    setFontAttrib FGREEN "."
    setFontAttrib FBKUE  "."
    setFontAttrib FRED   "."
    setFontAttrib FGREEN "."
    setFontAttrib FBKUE  "."
    setFontAttrib FRED   "."
    setFontAttrib FGREEN "."
    setFontAttrib FBKUE  "."
    setFontAttrib FRED   "."
    setFontAttrib FGREEN "."
    setFontAttrib FBKUE  "."
    setFontAttrib FRED   "."
    setFontAttrib FGREEN "."
    setFontAttrib FBKUE  "."
    setFontAttrib FRED   "."
    setFontAttrib FGREEN "."
    setFontAttrib FBKUE  "."
    setFontAttrib FRED   "."
    setFontAttrib FGREEN "."
    setFontAttrib FBKUE  "."
    echo
}


_ARGS=;
_ARGSCALL=$*;
_RUSER0=;
LABEL=;


while [ -n "$1" ];do
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:\${1}=<${1}>"
    case $1 in
	'-C')_CREATEDIR=1;;
	'-D')shift;_RDIRECTORY=$1;LABEL=${1##*/};;

	'-t')shift;C_SESSIONTYPE=$1;C_SESSIONTYPE=$(echo "$C_SESSIONTYPE"| tr '[:lower:]' '[:upper:]');;

	'--expert')EXPERT_MODE=y;;
	'--auto-all')AUTO_WITH_DEFAULTS_ALL=y;CONTINUE_WITH_OPTDEFAULTS=y;;
	'--auto')CONTINUE_WITH_OPTDEFAULTS=y;;

	'--create-image')_CREATEIMAGE=1;;
	'--no-create-image')_NOCREATEIMAGE=1;;

	'--save-para-kernel')_SAVEPARAKERN=1;;
	'--no-save-para-kernel')_NOSAVEPARAKERN=1;;

        '--label='*) LABEL=${1#*=};;
        '--label')
	    shift;LABEL=$1;
	    ;;


        '--defaults-file='*) DEFAULTSFILE=${1#*=};;
        '--defaults-file')
	    shift;DEFAULTSFILE=$1;
	    ;;

	'--list-env-var-options'|'--levo')_listEnvVarOptions=1;;

	'-H'|'--helpEx'|'-helpEx')shift;_HelpEx="${1:-$MYCALLNAME}";;
	'-h'|'--help'|'-help')_showToolHelp=1;;
	'-V')_printVersion=1;;
	'-X')C_TERSE=1;;

	'-d')shift;;


	*)
	    ABORT=1;
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Unknown option \"$1\""
	    gotoHell ${ABORT}

# 	    _ARGS="${_ARGS} ${1}"
# 	    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_ARGS=${_ARGS}"
	    ;;
    esac
    shift
done

if [ -n "${AUTO_WITH_DEFAULTS_ALL}" -a -z "$LABEL" ];then
    ABORT=1;
    printERR $LINENO $BASH_SOURCE ${ABORT} "Auto-Mode-All requires presetting of all"
    printERR $LINENO $BASH_SOURCE ${ABORT} "mandatory shell variables."
    printERR $LINENO $BASH_SOURCE ${ABORT} "Use shell variables and/or the following options:"
    printERR $LINENO $BASH_SOURCE ${ABORT} " '--label'"
    printERR $LINENO $BASH_SOURCE ${ABORT} "   The main anchor variable 'LABEL' is not inherited"
    printERR $LINENO $BASH_SOURCE ${ABORT} "   from environment for avoidance of unintended side"
    printERR $LINENO $BASH_SOURCE ${ABORT} "   effects."
    printERR $LINENO $BASH_SOURCE ${ABORT} "."
    printERR $LINENO $BASH_SOURCE ${ABORT} "Additional variables may be set in defaults of by shell,"
    printERR $LINENO $BASH_SOURCE ${ABORT} "these will be prompted for, it is safe to work through"
    printERR $LINENO $BASH_SOURCE ${ABORT} "by iterative calls."

    gotoHell ${ABORT}
fi


function fListEnvVarOptions () {
    local _hvar=;
    local _lval=;
    local LSTRG="%40s" 
    local FSTRG="%s:%s\n" 

    function printIt ()  {
	[  -z "$2" ]&&return
	local _col=$1;shift
	_lval=$(printf $LSTRG "$1")
	_lval=$(setFontAttrib $_col "$_lval")
	if [ -z "$2" ];then
	    local x=$(eval echo \${$1})
	    printf $FSTRG "$_lval" "$x"
	else
	    printf $FSTRG "$_lval" "$2"
	fi
    }

    echo
    echo "Not all values require to be set, some will be requested later by dialogue."
    echo "Thus it is not neccessary to have values assigned to the complete displayed set."
    echo
    echo
    echo "Actually used sources for default values:"
    printf "  %-10s = %s\n" "no-marker" "Pre-Set value, either from defaults configuration, or by commandline."
    printf "  %-10s = %s\n" "no-value" "Either requested by dialog later, or the defaults of the finally called"
    printf "  %10s   %s\n" "" "application are used."
    printf "  %-10s = %s\n" "(g)" "Dynamically generated."
    printf "  %-10s = %s\n" "(c)" "Read from actual configuration file, e.g. vmx-file."
    printf "  %-10s = %s\n" "(h)" "Used from current host as default."
    echo
    echo "Applicable modifications:"
    _hvar=$(printf "%-10s" blue)
    _hvar=$(setFontAttrib FBLUE "$_hvar")
    printf "  %-s = %s\n" "$_hvar" "By call option, defines dependency for others."

    _hvar=$(printf "%-10s" green)
    _hvar=$(setFontAttrib FGREEN "$_hvar")
    printf "  %-s = %s\n" "$_hvar" "By environment, 'could be set almost independent' from other values."

    _hvar=$(printf "%-10s" cyan)
    _hvar=$(setFontAttrib FCYAN "$_hvar")
    printf "  %-s = %s\n" "$_hvar" "By miscellaneous facilities, but is dependent from others."
    printf "  %10s   %s\n" "" "E.g. LABEL defines by convention the network 'hostname', thus the TCP/IP params."
    printf "  %10s   %s\n" "" "This could ..., but should not be altered!"

    echo
    echo "Most of the missing values will be fetched during actual execution of this tool by dynamic evaluation."
    echo
    echo
    _lval=$(printf $LSTRG "VAR name")
    _lval=$(setFontAttrib BOLD "$_lval")
    printf $FSTRG "$_lval" "$(setFontAttrib BOLD Initial Value)"
    echo
    printIt FBLUE    C_SESSIONTYPE
    printIt FBLUE    LABEL
    printIt FCYAN    MAC
    printIt FCYAN    IP
    printIt FCYAN    BRIDGE
    printIt FCYAN    DHCP
    printIt FCYAN    NETMASK
    printIt FCYAN    TCP
    printIt FCYAN    GATEWAY
    echo
    printIt FGREEN EDITOR

    case ${C_SESSIONTYPE} in
	VMW)
	    _hvar=$(getVMWUUID "${IDDIR}/${LABEL}.vmx")
	    _hvar=${_hvar:+$_hvar (c)}
	    ;;
	*)
	    _hvar=${UUID:-$(getUUID)}
	    _hvar=${_hvar:+$_hvar (h)}
	    ;;
    esac
    echo
    UUID=${UUID:-$_hvar}
    printIt FGREEN UUID



    echo
    printIt FGREEN DIST "${DIST:-$MYDIST (h)}"
    printIt FGREEN DISTREL "${DISTREL:-$MYREL (h)}"
    printIt FGREEN OS "${OS:-$MYOS (h)}"
    printIt FGREEN OSREL "${OSREL:-$MYOSREL (h)}"
    echo
    printIt FGREEN ARCH "${ARCH:-$(getCurArch.sh) (h)}"

    case ${C_SESSIONTYPE} in
	XEN)_hvar="$(getACCELERATOR_XEN)"
	    _hvar=${_hvar// /}
	    _hvar=${_hvar:-PARA}
	    ;;
	QEMU)_hvar="$(getACCELERATOR_QEMU)"
	    _hvar=${_hvar:-QEMU}
	    ;;
	*)_hvar=;;
    esac
    ACCELERATOR=${ACCELERATOR:-$_hvar}
    [ -n "${_hvar}" ]&&_hvar="$_hvar (h)"
    printIt FGREEN ACCELERATOR "${ACCELERATOR:-$_hvar}"

    case ${C_SESSIONTYPE} in
	VMW)_hvar="$(getVMWGUESTVCPU "${IDDIR}/${LABEL}.vmx")";;
	*)_hvar=;;
    esac
    [ -n "$_hvar" ]&&_hvar="$_hvar (h)"
    printIt FGREEN SMP ${SMP:-$_hvar}
 
    case ${C_SESSIONTYPE} in
	VMW)_hvar="$(getVMWGUESTVRAM "${IDDIR}/${LABEL}.vmx")";;
	*)_hvar=;;
    esac
    [ -n "$_hvar" ]&&_hvar="$_hvar (h)"
    printIt FGREEN MEMSIZE ${MEMSIZE:-512}

    printIt FGREEN KBD_LAYOUT ${KBD_LAYOUT:-de}


    ########
    #
    printINFO 2 $LINENO $BASH_SOURCE 1 "${MYCONFPATH}/ctys-createConfVM.d/defaults-sources.ctys"
    #
    #Source pre-set environment from user
    if [ -f "${HOME}/.ctys/ctys-createConfVM.d/defaults-sources.ctys" ];then
	. "${HOME}/.ctys/ctys-createConfVM.d/defaults-sources.ctys"
    fi
    #
    #Source pre-set environment from installation 
    if [ -f "${MYCONFPATH}/ctys-createConfVM.d/defaults-sources.ctys" ];then
	. "${MYCONFPATH}/ctys-createConfVM.d/defaults-sources.ctys"
    fi
    #
    ########

    echo
    STARTERCALL=${STARTERCALL:-$DEFAULTSTARTERCALL}
    if [ -n "${STARTERCALL}" ];then
	printIt FGREEN STARTERCALL ${STARTERCALL}
    else
	printIt FGREEN STARTERCALL ${QEMU}
    fi

    printIt FGREEN WRAPPERCALL ${WRAPPERCALL:-$DEFAULTWRAPPERCALL}
    echo

    case ${C_SESSIONTYPE} in
	VMW)
	    ;;
	*)
	    DEFAULTBOOTMODE=${DEFAULTBOOTMODE:-VHDD}
	    printIt FGREEN DEFAULTBOOTMODE 
	    case ${DEFAULTBOOTMODE} in
		VHDD|HDD)
		    echo
		    DEFAULTINSTTARGET=${IDDIR}/${HDDBOOTIMAGE}
		    printIt FGREEN DEFAULTINSTTARGET
		    HDDBOOTIMAGE_INST_SIZE=${HDDBOOTIMAGE_INST_SIZE:-5G}
		    printIt FGREEN HDDBOOTIMAGE_INST_SIZE
		    HDDBOOTIMAGE_INST_BLOCKSIZE=${HDDBOOTIMAGE_INST_BLOCKSIZE:-1G}
		    printIt FGREEN HDDBOOTIMAGE_INST_BLOCKSIZE
		    printIt FGREEN HDDBOOTIMAGE_INST_BLOCKCOUNT
		    printIt FGREEN HDDBOOTIMAGE_INST_BALLOON
		    ;;
	    esac
	    echo
	    DEFAULTINSTMODE=${DEFAULTINSTMODE:-CD}
	    printIt FGREEN DEFAULTINSTMODE
	    case ${DEFAULTINSTMODE} in
		CD)
		    INSTSRCCDROM=${INSTSRCCDROM:-/dev/cdrom}
		    printIt FGREEN INSTSRCCDROM
		    DEFAULTINSTSOURCE=${INSTSRCCDROM}
		    printIt FGREEN DEFAULTINSTSOURCE
		    ;;
		DVD)
		    INSTSRCDVD=${INSTSRCDVD:-/dev/dvd}
		    printIt FGREEN INSTSRCDVD
		    DEFAULTINSTSOURCE=${INSTSRCDVD}
		    printIt FGREEN DEFAULTINSTSOURCE
		    ;;
		FDD)
		    INSTSRCFDD=${INSTSRCFDD:-/dev/fd0}
		    printIt FGREEN INSTSRCFDD
		    DEFAULTINSTSOURCE=${INSTSRCFDD}
		    printIt FGREEN DEFAULTINSTSOURCE
		    ;;
		HDD)
		    INSTSRCHDD=${INSTSRCHDD:-hda}
		    printIt FGREEN INSTSRCHDD
		    DEFAULTINSTSOURCE=${INSTSRCHDD}
		    printIt FGREEN DEFAULTINSTSOURCE
		    ;;
		USB)
		    INSTSRCUSB=${INSTSRCUSB:-/dev/usb}
		    printIt FGREEN INSTSRCUSB
		    DEFAULTINSTSOURCE=${INSTSRCUSB}
		    printIt FGREEN DEFAULTINSTSOURCE
		    ;;
		KS)
		    case ${DIST} in
			CentOS)
			    printIt FGREEN  KICKSTART
			    ;;
		    esac
		    ;;

	    esac

	    case ${C_SESSIONTYPE} in
		XEN)
		    echo
		    BOOTLOADER=${BOOTLOADER:-$DEFAULT_BOOTLOADER};
		    printIt FGREEN BOOTLOADER
		    ;;
		QEMU)
		    ;;
	    esac

	    case ${C_SESSIONTYPE} in
		XEN|QEMU)
		    INST_KERNEL=${INST_KERNEL:-$DEFAULT_INST_KERNEL};
		    printIt FGREEN INST_KERNEL
		    case ${ACCELERATOR} in
			PARA)
			    INST_EXTRA=${INST_EXTRA:-$DEFAULT_INST_EXTRA};
			    printIt FGREEN INST_EXTRA
			    INST_ROOTARGS=${INST_ROOTARGS:-$DEFAULT_INST_ROOTARGS};
			    printIt FGREEN INST_ROOTARGS
			    ;;
		    esac

		    case ${C_SESSIONTYPE} in
			XEN)
			    case ${ACCELERATOR} in
				PARA)
				    INST_INITRD=${INST_INITRD:-$DEFAULT_INST_INITRD};
				    printIt FGREEN INST_INITRD
				    ;;
			    esac
			    ;;
			QEMU)
			    INST_INITRD=${INST_INITRD:-$DEFAULT_INST_INITRD};
			    printIt FGREEN INST_INITRD
			    ;;
		    esac
		    case ${DIST} in
			debian)
			    case ${ACCELERATOR} in
				PARA)
				    echo
				    DOMU_KERNEL=${DOMU_KERNEL:-$DEFAULT_DOMU_KERNEL};
				    printIt FGREEN DOMU_KERNEL
				    DOMU_MODULESDIR=${DOMU_MODULESDIR:-$DEFAULT_DOMU_MODULESDIR};
				    printIt FGREEN DOMU_MODULESDIR
				    DOMU_INITRD=${DOMU_INITRD:-$DEFAULT_DOMU_INITRD};
				    printIt FGREEN DOMU_INITRD
				    DOMU_EXTRA=${DOMU_EXTRA:-$DEFAULT_DOMU_EXTRA};
				    printIt FGREEN DOMU_EXTRA
				    DOMU_ROOT=${DOMU_ROOT:-$DEFAULT_DOMU_ROOT};
				    printIt FGREEN DOMU_ROOT
				    ;;
			    esac
			    ;;
		    esac
		    ;;
	    esac
	    ;;
    esac
    echo
    printIt FGREEN VMSTATE
    echo
    echo
    echo "Remember that his is a draft pre-display of current defaults."
    echo "No consistency-checks for provided values are performed at this stage."
    echo "Some missing values are evaluated at a later stage dynamically."
    echo
    echo
}

if [ -n "$_listEnvVarOptions" ];then
    fListEnvVarOptions
    exit 0;
fi
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

C_SESSIONTYPE=$(echo "$C_SESSIONTYPE"| tr '[:lower:]' '[:upper:]')
C_SESSIONTYPE=${C_SESSIONTYPE// /}

#
#for safety only "single-level-mkdir"
#
if [ -n "${_RDIRECTORY}" ];then
    if [ -d "${_RDIRECTORY}" ];then
	cd "${_RDIRECTORY}"
    else
	if [ "${_CREATEDIR}" != 1 ];then
	    ABORT=1;
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing directory, try \"-C\""
	    gotoHell ${ABORT}
	fi
	_RDIRECTORYBASE="${_RDIRECTORY%/*}"
	if [ -d "${_RDIRECTORYBASE}" ];then
	    mkdir "${_RDIRECTORY}"
	    cd "${_RDIRECTORYBASE}"
	fi
    fi
fi



createConf
createData

case ${C_SESSIONTYPE} in
    VMW)
	if [ -n "$_CREATEIMAGE"  ];then
	    ABORT=1;
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Image creation for VMW is not yet supported"
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Use tools of supplier."
	    gotoHell ${ABORT}
	fi
	;;

    QEMU|XEN)
	if [ -z "$_NOCREATEIMAGE" ];then
	    if [ -z "$_CREATEIMAGE"  -a "$DIST" == debian -a "$ACCELERATOR" == PARA ];then
		ABORT=1;
		printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "Image creation for $(setFontAttrib FBLUE 'para virtualized VMs') is supported on '$(setFontAttrib FBLUE debian)'"
		printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "by debootstrap method with the specific $(setFontAttrib UNDL 'debootstrap-wrapper')."
		printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "Thus the creation of the image should be performed there, else"
		printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "might fail due to safety reasons with missing filesystem."
		printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "."
		printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "Force creation by '$(setFontAttrib FBLUE '--create-image')' option for manual"
		printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "correction or using another approach."
		printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "."
		printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "For now $(setFontAttrib FRED 'no image') is $(setFontAttrib FRED 'created')"
		printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "."
	    else
		createImage
	    fi
	fi
	;;
esac


case ${C_SESSIONTYPE} in
    VMW)
	if [ -n "$_SAVEPARAKERN" ];then
            printINFO 1 $LINENO $BASH_SOURCE 1 "${MYCALLNAME} is not supported on ${MYOS}"
	fi
	;;
    QEMU|XEN)
	case "$ACCELERATOR" in
	    PARA)
		[  -z "$_NOSAVEPARAKERN" ]&&saveParaKernel
		;;
	    *)
		[ -n "$_SAVEPARAKERN" ]&&saveParaKernel
		;;
	esac

esac


echo
echo
echo
setFontAttrib BGREEN $(setFontAttrib BOLD "That's it.")
echo
echo
case ${C_SESSIONTYPE} in
    XEN)
	echo "Check now the contents of the configuration files manually and adapt them when/as required"
	_mcall=${IDDIR}/${LABEL}.sh;_mcall=${_mcall##*/};
	echo -n "and perform a dummy-call for '${_mcall}  "
	setFontAttrib FBLUE "--check -d printfinal "
	echo "--instmode=...' and "
	echo -n "'${_mcall} "
	setFontAttrib FBLUE "--check -d printfinal "
	echo " --bootmode=...'"
	echo
	echo -n "Or use the display of "
	setFontAttrib BOLD   "FINAL"
	echo " for cut-and-paste of raw-calls."
	echo
	echo -n -e "Refer to the document "
	setFontAttrib BOLD   "ctys-configuration-XEN(7)"
	echo " for additional information."
	;;
    QEMU)
	echo "Check now the contents of the configuration files manually and adapt them when/as required"
	_mcall=${IDDIR}/${LABEL}.sh;_mcall=${_mcall##*/};
	echo "and perform a dummy-call for '${_mcall} --check  -d printfinal --instmode=...' and "
	echo "'${_mcall} --check -d printfinal --bootmode=...'"
	echo
	echo -n "Or use the display of "
	setFontAttrib BOLD   "FINAL"
	echo " for cut-and-paste for raw-calls."
	echo
	echo -n -e "Refer to the document "
	setFontAttrib BOLD   "ctys-configuration-QEMU(7)"
	echo " for additional information."
	;;
    VMW)
	echo -n -e "Refer to the document "
	setFontAttrib BOLD   "ctys-configuration-VMW(7)"
	echo " for additional information."
	echo
	echo -n -e "Don't forget to insert '"
	setFontAttrib FBLUE  "#@#MAGICID-IGNORE"
	echo "' into the vmx-file."
	echo "This avoids redundant entries within the automatically scanned database."
	;;
esac
echo
echo

