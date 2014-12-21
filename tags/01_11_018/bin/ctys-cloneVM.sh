#!/bin/bash
########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_018
#
########################################################################
#
#     Copyright (C) 2011 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
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
#  ctys-cloneVM.sh
#
#AUTHOR:
AUTHOR="Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org"
#
#FULLNAME:
FULLNAME="Unified Sessions Manager"
#
#CALLFULLNAME:
CALLFULLNAME="Clone VirtualMachines"
#
#LICENCE:
LICENCE=GPL3
#
#TYPE:
#  bash-script
#
#VERSION:
VERSION=01_11_018
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




##############################################
#Temporary workaround
if [ -n "${DISTREL}" ];then
    RELEASE=${DISTREL}
else
    if [ -n "${RELEASE}" ];then
	DISTREL=${RELEASE}
    fi
fi
##############################################

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

    VBOX)
	if [ -d "${HOME}/.ctys" -a -d "${HOME}/.ctys/vbox" ];then
	    if [ -f "${HOME}/.ctys/vbox/vbox.conf-${MYOS}.sh" ];then
		. "${HOME}/.ctys/vbox/vbox.conf-${MYOS}.sh"
	    fi
	fi

	if [ -d "${MYCONFPATH}/vbox" ];then
	    if [ -f "${MYCONFPATH}/vbox/vbox.conf-${MYOS}.sh" ];then
		. "${MYCONFPATH}/vbox/vbox.conf-${MYOS}.sh"
	    fi
	fi
	. ${MYLIBPATH}/lib/libVBOXbase.sh
	. ${MYLIBPATH}/lib/libVBOX.sh
	. ${MYLIBPATH}/lib/libVBOXconf.sh
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


_ARGS=;
_ARGSCALL=$*;
_RUSER0=;
LABEL=;
OLABEL=;

_CREATEIMAGE=;
_NOCREATEIMAGE=;
_SAVEPARAKERN=;
_NOSAVEPARAKERN=;


while [ -n "$1" ];do
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:\${1}=<${1}>"
    case $1 in
	'-t')shift;C_SESSIONTYPE=$1;C_SESSIONTYPE=$(echo "$C_SESSIONTYPE"| tr '[:lower:]' '[:upper:]');;

	'--create-image')_CREATEIMAGE=1;;
	'--no-create-image')_NOCREATEIMAGE=1;;

	'--save-para-kernel')_SAVEPARAKERN=1;;
	'--no-save-para-kernel')_NOSAVEPARAKERN=1;;

        '--label='*) LABEL=${1#*=};;
        '--label-old='*) OLABEL=${1#*=};;

        '--configuration-file='*)DEFAULTSFILE=${1#*=};;

	'--directory='*)_RDIRECTORYBASE=${1#*=};;

        '--ip='*)_IP=${1#*=};;
        '--tcp='*)_TCP=${1#*=};;
        '--mac='*)_MAC=${1#*=};;

        '--uuid='*)_UUID=${1#*=};;

        '--vm-state='*)_VMSTATE=${1#*=};;

	'-f')C_FORCE=1;;

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


#
#label
#
if [ -z "${LABEL}" ];then
    ABORT=1;
    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing option \"--label\"."
    gotoHell ${ABORT}
fi

#
#old
#
[ -z "${OLABEL}" ]&&OLABEL=${PWD##*/};

if [ -z "${OLABEL}" -o ! -f "${OLABEL}.ctys" ];then
    ABORT=1;
    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing old label:"
    printERR $LINENO $BASH_SOURCE ${ABORT} "-> \"dirname \$PWD=${OLABEL}\"."
    printERR $LINENO $BASH_SOURCE ${ABORT} "-> \"--label-source=<label-old>\"."
    gotoHell ${ABORT}
fi


#
#target directory
#
if [ -n "${_RDIRECTORYBASE}" ];then
    if [ ! -d "${_RDIRECTORYBASE}" ];then
	ABORT=1;
	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing parent directory for target:\"${_RDIRECTORYBASE}\""
	gotoHell ${ABORT}
    else
	_RDIRECTORY="${_RDIRECTORYBASE}/${LABEL}"
	if [ -d "${_RDIRECTORY}" ];then
	    if [ -z "$C_FORCE" ];then
		ABORT=1;
		printERR $LINENO $BASH_SOURCE ${ABORT} "Target directory exists:\"${_RDIRECTORY}\""
		gotoHell ${ABORT}
	    fi
	else
	    mkdir "${_RDIRECTORY}"
	fi

	if [ ! -d "${_RDIRECTORY}" ];then
	    ABORT=1;
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Cannot create target directory:\"${_RDIRECTORY}\""
	    gotoHell ${ABORT}
	fi
    fi
else
    ABORT=1;
    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing option \"--directory\"."
    gotoHell ${ABORT}
fi





###############################
###############################
function getProgress {
    ls -l "$1" "$2"|awk 'BEGIN{a=0;x1=0;x2=0;}$5!~/^$/{if(x1==0){x1=$5;}else{x2=$5;}}END{x=100;if(x1!=0){x=int(100*x2/x1)};print x1":"x2":"x;}'
}

function drawLine {
    [ -b "$C_TERSE" ]&&return
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

function drawStart {
    [ -b "$C_TERSE" ]&&return
    echo
    setFontAttrib BCYAN "                                                                                 "
    echo
    setFontAttrib BCYAN "  +---------------------------------------------------------------------------+  "
    echo
    setFontAttrib BCYAN "  |                                                                           |  "
    echo
    setFontAttrib BCYAN "  |                          ";
    setFontAttrib BCYAN $(printf "Start duplication of VM");
    setFontAttrib BCYAN "                          |  ";
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
}


function drawAdapt {
    [ -b "$C_TERSE" ]&&return
    echo
    setFontAttrib BYELLOW "                                                       "
    echo
    setFontAttrib BYELLOW "       ";
    setFontAttrib BYELLOW $(printf "Adapt attributes by "&&setFontAttrib BOLD  "ctys-createConfVM.sh");
    setFontAttrib BYELLOW "        ";
    echo
    setFontAttrib BYELLOW "                                                       "
    echo
    echo
}

function drawAdaptFinished {
    [ -b "$C_TERSE" ]&&return
    echo
    setFontAttrib BYELLOW "                                                       "
    echo
    setFontAttrib BYELLOW "    ";
    setFontAttrib BYELLOW $(printf "Adapt attributes finished "&&setFontAttrib BOLD  "ctys-createConfVM.sh");
    setFontAttrib BYELLOW "     ";
    echo
    setFontAttrib BYELLOW "                                                       "
    echo
    echo
}


###############################
###############################



#
#For: generic
#
function copyVM () {
    local _fileset=;
    local _ORIGIN="CloneFrom-$OLABEL"
    local _CREATELABEL="CLONED"

    function mkCREATED () {
	echo "DATETIME=$DATETIME">"${1}/$_CREATELABEL"
	echo "CLONE-VERSION=$VERSION">>"${1}/$_CREATELABEL"
	echo "UID=$MYUID">>"${1}/$_CREATELABEL"
	echo "GUID=$MYGID">>"${1}/$_CREATELABEL"
	echo "HOST=$MYHOST">>"${1}/$_CREATELABEL"
	echo "OS=$MYOS">>"${1}/$_CREATELABEL"
	echo "OSREL=$MYOSREL">>"${1}/$_CREATELABEL"
	echo "DIST=$MYDIST">>"${1}/$_CREATELABEL"
	echo "DISTREL=$MYREL">>"${1}/$_CREATELABEL"

	echo "SOURCE=$OLABEL">>"${1}/$_CREATELABEL"
    }

    function cp2old () {
	if [ ! -d "${2}/$_ORIGIN" ];then
	    mkdir -p "${2}/$_ORIGIN"
	    if [ -f "$(dirname ${1})/${_CREATELABEL}" ];then
		${CP} ${CPR} "$(dirname ${1})/$_CREATELABEL" "${2}/$_ORIGIN"	
	    fi
	fi
	if [ -d "${1##*/}/$_ORIGIN" ];then
	    ${CP} ${CPR} "${1##*/}/$_ORIGIN" "${2}/$_ORIGIN"	
	fi
	${CP} ${CPR} "${1}" "${2}/$_ORIGIN"	
    }

    function cp2oldDeactivate () {
	cp2old "${1}" "${2}"	

	#deactivate
	if [ -f "${2}/$_ORIGIN/${1}" ];then
	    _ADAPT=;
	    _ADAPT="${_ADAPT}  ${MYLIBEXECPATH}/ctys-attribute.sh"	
	    _ADAPT="${_ADAPT}   --attribute-create=top"
	    _ADAPT="${_ADAPT}   --attribute-keyonly"
	    _ADAPT="${_ADAPT}   --attribute-name='#@#MAGICID-IGNORE'"
	    _ADAPT="${_ADAPT}   '${2}/$_ORIGIN/${1}'"
	    eval ${_ADAPT}
	fi
    }

    drawStart

 #################
  #################
   #################

    mkCREATED "${_RDIRECTORY}"

    #ctys-conf
    if [ -f "${OLABEL}.ctys" ];then
	drawLine
	${CP}  ${CPR} "${OLABEL}.ctys"      "${_RDIRECTORY}/${LABEL}.ctys"
	cp2oldDeactivate "${OLABEL}.ctys" "${_RDIRECTORY}"
	[ -z "$C_TERSE" ]&&echo -n "Copied:${OLABEL}.ctys -> "&&setFontAttrib BOLD "${LABEL}.ctys"
    else
	case "${C_SESSIONTYPE}" in
	    QEMU)
		ABORT=1;
		printERR $LINENO $BASH_SOURCE ${ABORT} "Missing configuration file for QEMU/KVM:\"${OLABEL}.ctys\""
		gotoHell ${ABORT}
		;;
	esac
    fi

    #ctys-kickstart
    X=$(echo ${OLABEL}*.ks)
    if [ -f "${X}" ];then
	drawLine
	NKS0="${X}"
	NKS="${NKS0}"
	NKS="${NKS//$OLABEL/$LABEL}"
	${CP}  ${CPR} "${NKS0}" "${_RDIRECTORY}/${NKS}"
	cp2old "${NKS0}" "${_RDIRECTORY}"
	[ -z "$C_TERSE" ]&&echo -n "Copied:${NKS0} -> "&&setFontAttrib BOLD "${NKS}"
    fi

    #ctys-wrapper
    if [ -f "${OLABEL}.sh" ];then
	drawLine
	${CP}  ${CPR} "${OLABEL}.sh"        "${_RDIRECTORY}/${LABEL}.sh"
	cp2old "${OLABEL}.sh" "${_RDIRECTORY}"
	[ -z "$C_TERSE" ]&&echo -n "Copied:${OLABEL}.sh -> "&&setFontAttrib BOLD  "${LABEL}.sh"
    else
	case "${C_SESSIONTYPE}" in
	    QEMU)
		ABORT=1;
		printERR $LINENO $BASH_SOURCE ${ABORT} "Missing wrapper file for QEMU/KVM:\"${OLABEL}.sh\""
		gotoHell ${ABORT}
		;;
	esac
    fi

    case "${C_SESSIONTYPE}" in
	XEN)
            #xen-conf
	    if [ -f "${OLABEL}.conf" ];then
		drawLine
		${CP}  ${CPR} "${OLABEL}.conf"      "${_RDIRECTORY}/${LABEL}.conf"
		cp2oldDeactivate "${OLABEL}.conf" "${_RDIRECTORY}"
		[ -z "$C_TERSE" ]&&echo -n "Copied:${OLABEL}.conf -> "&&setFontAttrib BOLD "${LABEL}.conf"
	    else
		ABORT=1;
		printERR $LINENO $BASH_SOURCE ${ABORT} "Missing configuration file for XEN:\"${OLABEL}.conf\""
		gotoHell ${ABORT}
	    fi
	    ;;

	VMW)
            #vmw-vmx
	    if [ -f "${OLABEL}.vmx" ];then
		drawLine
		${CP}  ${CPR} "${OLABEL}.vmx"      "${_RDIRECTORY}/${LABEL}.vmx"
		cp2oldDeactivate "${OLABEL}.vmx" "${_RDIRECTORY}"
		[ -z "$C_TERSE" ]&&echo -n "Copied:${OLABEL}.vmx -> "&&setFontAttrib BOLD "${LABEL}.vmx"
	    else
		ABORT=1;
		printERR $LINENO $BASH_SOURCE ${ABORT} "Missing configuration file for VMW:\"${OLABEL}.VMX\""
		gotoHell ${ABORT}
	    fi
	    ;;
    esac


    #
    #if missing create it for later adaption to new VM
    if [ ! -f "${OLABEL}.defaults" ];then
	_ADAPT=;
	_ADAPT="${_ADAPT}  ${MYLIBEXECPATH}/ctys-createConfVM.sh"
	_ADAPT="${_ADAPT}  --label=${OLABEL}"
	_ADAPT="${_ADAPT}  --defaults-file-create"
	_ADAPT="${_ADAPT}  --defaults-file=${OLABEL}.defaults"
	_ADAPT="${_ADAPT}  --no-create-conf-data"
	_ADAPT="${_ADAPT}  --no-create-image"
	_ADAPT="${_ADAPT}  --no-save-para-kernel"
	_ADAPT="${_ADAPT}  --auto-all"
	${_ADAPT}
    fi


    #ctys-defaults-old-vm
    if [ -f "${OLABEL}.defaults" ];then
	drawLine
	#
	#The exeption: Copy the original for documentation purposes
#4TEST	${CP}  ${CPR} "${OLABEL}.defaults"  "${_RDIRECTORY}/${OLABEL}.defaults"
	cp2old "${OLABEL}.defaults" "${_RDIRECTORY}"
	[ -z "$C_TERSE" ]&&echo -n "Copied:${OLABEL}.defaults(*) -> "&&setFontAttrib BOLD "${OLABEL}.defaults"
    else
	ABORT=1;
	printERR $LINENO $BASH_SOURCE ${ABORT} "Cannot create file with attribute-defaults for transformation:"
	printERR $LINENO $BASH_SOURCE ${ABORT} "->\"${OLABEL}.defaults\""
	printERR $LINENO $BASH_SOURCE ${ABORT} "Try to execute creation of defaults by manual call, eventually"
	printERR $LINENO $BASH_SOURCE ${ABORT} "omit \"--auto-all\" using interactive dialogue:"
	printERR $LINENO $BASH_SOURCE ${ABORT} "\"${_ADAPT}\""
	gotoHell ${ABORT}
    fi

    #all-generic-recursive except old-vm-ctys-configs
    if [ -n "$_CREATEIMAGE" -o -z "$_NOCREATEIMAGE" ];then
        #
        #big images may cause hanging copy jobs else, it seems safe to target all subjobs!
	function clearCP () {
	    kill -9 $(jobs -p) 2>/dev/null
	}
	trap clearCP 0 15 

	for i in *;do
	    #not required
	    [ "$i" == "${OLABEL}.ctys" ]&&continue;

	    X=$(echo ${OLABEL}*.ks)
	    [ "$i" == "${X}" ]&&continue;

	    [ "$i" == "${OLABEL}.sh" ]&&continue;
	    [ "$i" == "${OLABEL}.defaults" ]&&continue;

	    [ "$i" == "${_CREATELABEL}" ]&&continue;

#4TEST: 2check
	    [ "$i" == "${OLABEL}.conf" ]&&continue; #xen
	    [ "$i" == "${OLABEL}.vmx" ]&&continue; #vmw


	    #...now of interest
	    drawLine
	    local _ct0=$(getCurTime);
	    local _q=0;
	    ${CP}  ${CPR} "$i" "${_RDIRECTORY}"&
	    local _jl=$(jobs -p +);
	    local _jx=$_jl;


	    while [ -n "$_jl" -a "$_q" -ne 100 ];do
		[ -z "$C_TERSE" ]&&getDiffTime $_ct0&&printf " %3d%% %s\r" $_q $(setFontAttrib BOLD "$i")
		sleep 3
		_q=$(getProgress "$i" "${_RDIRECTORY}/$i")
		_q=${_q##*:}
		_jx=$(jobs -p);[ "$_jx" == "${_jx//$_jl}" ]&&_jl=;
	    done
	    [ -z "$C_TERSE" ]&&getDiffTime $_ct0
	done    
    fi

    #kernel
    if [ -d "$boot" ];then
	if [ -n "$_SAVEPARAKERN" -o -z "$_NOSAVEPARAKERN" ];then
	    local _ct0=$(getCurTime);
	    drawLine
	    ${CP}  ${CPR} boot  "${_RDIRECTORY}"
	    [ -z "$C_TERSE" ]&&getDiffTime $_ct0&&printf " %3d%% %s\n" 100 $(setFontAttrib BOLD "boot")
	fi
    fi

    ######
    ##########
    ######
    drawLine
    drawAdapt
    _ADAPT=;
    if [ -n "$_IP" ];then
	_ADAPT="${_ADAPT}  IP=$_IP"
    fi

    if [ -n "$_MAC" ];then
	_ADAPT="${_ADAPT}  MAC=$_MAC"
    fi

    if [ -n "$_UUID" ];then
	_ADAPT="${_ADAPT}  UUID=$_UUID"
    fi

    if [ -n "$_VMSTATE" ];then
	_ADAPT="${_ADAPT}  VMSTATE=$_VMSTATE"
    fi

    _ADAPT="${_ADAPT}  ${MYLIBEXECPATH}/ctys-createConfVM.sh"
    _ADAPT="${_ADAPT}  -t ${C_SESSIONTYPE}"
    _ADAPT="${_ADAPT}  --label=${LABEL}"
    _ADAPT="${_ADAPT}  --defaults-file=${_ORIGIN}/${OLABEL}.defaults"
    _ADAPT="${_ADAPT}  --no-create-image"
    _ADAPT="${_ADAPT}  --no-save-para-kernel"
    _ADAPT="${_ADAPT}  --auto-all"
    _ADAPT="${_ADAPT}  ${C_TERSE:+ -X}"
    cd "${_RDIRECTORY}"
    printFINALCALL 0  $LINENO $BASH_SOURCE "VM-COnfiguration" "${_ADAPT}"
    eval "${_ADAPT}"
    cd -
    drawAdaptFinished
   #################
  #################
 #################

    drawLine
    if [ -z "$C_TERSE" ]; then 
	echo
	echo -n "Finished, duration was:"&&getDiffTime $_c0
	echo
	echo
    fi
}


#start time
_c0=$(getCurTime);

case ${C_SESSIONTYPE} in
    QEMU)
	copyVM
	if [ -z "$C_TERSE" ]; then 
	    echo
	    echo "Finished, may work now from the box."
	    echo -n "Duration was:"&&getDiffTime $_c0
	    echo
	    echo
	fi
	printINFO 2 $LINENO $BASH_SOURCE 1 "Finished, may work now from the box."
	;;

    XEN)
	copyVM
	if [ -z "$C_TERSE" ]; then 
	    echo
	    echo "Finished, may work now from the box."
	    echo -n "Duration was:"&&getDiffTime $_c0
	    echo
	    echo
	fi
	printINFO 2 $LINENO $BASH_SOURCE 1 "Finished, may work now from the box."
	;;

    VMW)
	copyVMVMW
	if [ -z "$C_TERSE" ]; then 
	    echo
	    echo "Finished, may work now from the box."
	    echo -n "Duration was:"&&getDiffTime $_c0
	    echo
	    echo
	fi
	A=1;
	printWNG 1 $LINENO $BASH_SOURCE ${A} "$(setFontAttrib FRED 'ATTENTION:')"
	printWNG 1 $LINENO $BASH_SOURCE ${A} "For $(setFontAttrib BOLD 'current CTYS version') this sessiontype $(setFontAttrib BOLD 'VMW') requires "
	printWNG 1 $LINENO $BASH_SOURCE ${A} "manual postprocessing by OEM tools of VMware(TM)."
	printWNG 1 $LINENO $BASH_SOURCE ${A} "Edit the \"<${LABEL}>.$(setFontAttrib BOLD 'vmx')\" file and adapt the values"
	printWNG 1 $LINENO $BASH_SOURCE ${A} "for:"
	printWNG 1 $LINENO $BASH_SOURCE ${A} " -> eth[0-9]"
	printWNG 1 $LINENO $BASH_SOURCE ${A} " -> uuid"
	printWNG 1 $LINENO $BASH_SOURCE ${A} " -> DisplayName"
	printWNG 1 $LINENO $BASH_SOURCE ${A} "More as required..."
	printWNG 1 $LINENO $BASH_SOURCE ${A} "Additional configuration and registration may be required for specific"
	printWNG 1 $LINENO $BASH_SOURCE ${A} "versions..."
	;;

    VBOX)
	copyVMW
	if [ -z "$C_TERSE" ]; then 
	    echo
	    echo "Finished, may work now from the box."
	    echo -n "Duration was:"&&getDiffTime $_c0
	    echo
	    echo
	fi
	A=1;
	printWNG 1 $LINENO $BASH_SOURCE ${A} "$(setFontAttrib FRED 'ATTENTION:')"
	printWNG 1 $LINENO $BASH_SOURCE ${A} "For $(setFontAttrib BOLD 'current CTYS version') this sessiontype $(setFontAttrib BOLD 'VBOX') requires "
	printWNG 1 $LINENO $BASH_SOURCE ${A} "manual postprocessing by OEM tools of VirtualBox(TM)."
	printWNG 1 $LINENO $BASH_SOURCE ${A} "Configure your VM in the GUI or by \"VBoxManage\":"
	printWNG 1 $LINENO $BASH_SOURCE ${A} " -> Import Machine, adapt UUID"
	printWNG 1 $LINENO $BASH_SOURCE ${A} " -> Configure network: Bridged, set MAC"
	printWNG 1 $LINENO $BASH_SOURCE ${A} " -> Enable RDP access as required"
	printWNG 1 $LINENO $BASH_SOURCE ${A} "More as required..."
	;;

    *)
	ABORT=1;
	printERR $LINENO $BASH_SOURCE ${ABORT} "Sessiontype not supported:C_SESSIONTYPE=${C_SESSIONTYPE}"
	gotoHell ${ABORT}
	;;

esac


