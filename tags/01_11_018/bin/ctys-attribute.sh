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
#  ctys-attribute.sh
#
#AUTHOR:
AUTHOR="Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org"
#
#FULLNAME:
FULLNAME="Unified Sessions Manager"
#
#CALLFULLNAME:
CALLFULLNAME="Manage attributes"
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
. ${MYLIBPATH}/lib/libconf.sh
. ${MYLIBPATH}/lib/help/help.sh
# . ${MYLIBPATH}/lib/network/network.sh
# . ${MYLIBPATH}/lib/hw/hook.sh
# . ${MYLIBPATH}/lib/groups.sh


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
_ATTRKEYONLY=;


while [ -n "$1" ];do
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:\${1}=<${1}>"
    case $1 in
	'-t')shift;C_SESSIONTYPE=$1;C_SESSIONTYPE=$(echo "$C_SESSIONTYPE"| tr '[:lower:]' '[:upper:]');;

        '--list'*)_LIST=1;;

        '--attribute-create='*)_CREATE=1;_POS=${1#*=};;
        '--attribute-create')_CREATE=1;_POS=top;;

        '--attribute-delete='*)_DELETE=1;_OCCUR=${1#*=};;
        '--attribute-delete')_DELETE=1;_OCCUR=first;;

        '--attribute-replace='*)_REPLACE=1;_OCCUR=${1#*=};;
        '--attribute-replace')_REPLACE=1;_OCCUR=first;;

        '--attribute-keyonly')_ATTRKEYONLY=1;;

        '--attribute-name='*)_ATTRNAME=${1#*=};;
        '--attribute-value-new='*)_ATTRVALNEW=${1#*=};;
        '--attribute-value-old='*)_ATTRVALOLD=${1#*=};;


	'-H'|'--helpEx'|'-helpEx')shift;_HelpEx="${1:-$MYCALLNAME}";;
	'-h'|'--help'|'-help')_showToolHelp=1;;
	'-V')_printVersion=1;;
	'-X')C_TERSE=1;;

	'-d')shift;;


#	'-f')C_FORCE=1;;
# 	'--inExec')_inExec=1;;


	*)
 	    _ARGS="${_ARGS} ${1}"
 	    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_ARGS=${_ARGS}"
	    ;;
    esac
    shift
done


#
#session type
#
if [ -z "${C_SESSIONTYPE}" ];then
    C_SESSIONTYPE=NONE;
fi



if [ -n "${_LIST}" ];then
    #
    #check
    if [ -n "${_CREATE}"  \
        -o -n "${_DELETE}"  \
        -o -n "${_REPLACE}"  \
        -o -n "${_ATTRKEYONLY}" \
        -o -n "${_ATTRNAME}" \
        -o -n "${_ATTRVALNEW}" \
        -o -n "${_ATTRVALOLD}" \
	];then
	ABORT=1;
	printERR $LINENO $BASH_SOURCE ${ABORT} "Too many parameters."
	gotoHell ${ABORT}
    fi
else
    if [ -n "${_CREATE}" ];then
        #
        #attribute name
        #
	if [ -z "${_ATTRNAME}" ];then
	    ABORT=1;
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing attribute name:\"--attribute-name\""
	    gotoHell ${ABORT}
	fi
        #
        #attribute value new
        #
	if [ -z "${_ATTRVALNEW}" -a -z "${_ATTRKEYONLY}" ];then
	    ABORT=1;
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing attribute name:\"--attribute-value-new\""
	    gotoHell ${ABORT}
	fi

        #
        #attribute value new
        #
	if [ \( -n "${_ATTRVALNEW}" -o -n "${_ATTRVALOLD}" \) -a -n "${_ATTRKEYONLY}" ];then
	    ABORT=1;
	    printERR $LINENO $BASH_SOURCE ${ABORT} "No values are permitted for:\"--attribute-keyonly\""
	    gotoHell ${ABORT}
	fi

	#
	#check
	if [ -n "${_DELETE}"  \
            -o -n "${_REPLACE}"  \
            -o -n "${_ATTRVALOLD}" \
	    ];then
	    ABORT=1;
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Too many parameters."
	    gotoHell ${ABORT}
	fi
    else
	if [ -n "${_DELETE}" ];then
            #
            #attribute name
            #
	    if [ -z "${_ATTRNAME}" ];then
		ABORT=1;
		printERR $LINENO $BASH_SOURCE ${ABORT} "Missing attribute name:\"--attribute-name\""
		gotoHell ${ABORT}
	    fi

    	    #
	    #check
	    if [ -n "${_CREATE}"  \
                -o -n "${_REPLACE}"  \
		-o -n "${_ATTRVALNEW}" \
		-o -n "${_ATTRVALOLD}" \
		];then
		ABORT=1;
		printERR $LINENO $BASH_SOURCE ${ABORT} "Too many parameters."
		gotoHell ${ABORT}
	    fi

	else
            #
            #attribute name
            #
	    if [ -z "${_ATTRKEYONLY}" ];then
		ABORT=1;
		printERR $LINENO $BASH_SOURCE ${ABORT} "Conflicting attribute key:\"--attribute-keyonly\""
		printERR $LINENO $BASH_SOURCE ${ABORT} "Requires:\"--attribute-create\" or \"--attribute-delete\""
		gotoHell ${ABORT}
	    fi

            #
            #attribute name
            #
	    if [ -z "${_ATTRNAME}" ];then
		ABORT=1;
		printERR $LINENO $BASH_SOURCE ${ABORT} "Missing attribute name:\"--attribute-name\""
		gotoHell ${ABORT}
	    fi
            #
            #attribute value new
            #
	    if [ -z "${_ATTRVALNEW}" ];then
		ABORT=1;
		printERR $LINENO $BASH_SOURCE ${ABORT} "Missing attribute name:\"--attribute-value-new\""
		gotoHell ${ABORT}
	    fi

#             #
#             #attribute value old
#             #
# 	    if [ -z "${_ATTRVALOLD}" ];then
# 		ABORT=1;
# 		printERR $LINENO $BASH_SOURCE ${ABORT} "Missing attribute name:\"--attribute-value-old\""
# 		gotoHell ${ABORT}
# 	    fi

    	    #
	    #check
	    if [ -n "${_CREATE}"  \
		-o -n "${_DELETE}" \
		];then
		ABORT=1;
		printERR $LINENO $BASH_SOURCE ${ABORT} "Too many parameters."
		gotoHell ${ABORT}
	    fi
	fi
    fi
fi


#
#config file
#
if [ -z "${_ARGS}" ];then
    ABORT=1;
    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing file name."
    gotoHell ${ABORT}
fi


#
#
#
for i in ${_ARGS};do
    if [ ! -f "${i}" ];then
	ABORT=1;
	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing file::\"${i}\""
	gotoHell ${ABORT}
    fi
done


#
#
#
for i in ${_ARGS};do
    if [ -n "${_LIST}" ];then
	getAttribute "" ".*" $i
    else
	if [ -n "${_CREATE}" ];then
	    _POS=$(echo "${_POS}"|tr 'a-z' 'A-Z');
	    if [ -n "$_ATTRKEYONLY" ];then
		_AVA="${_ATTRNAME}"
	    else
		_AVA="${_ATTRNAME}=${_ATTRVALNEW}"
	    fi
	    case $_POS in
                [1-9]|[1-9][0-9]|[1-9][0-9][0-9]|[1-9][0-9][0-9][0-9]|[1-9][0-9][0-9][0-9]|[1-9][0-9][0-9][0-9][0-9]|[1-9][0-9][0-9][0-9][0-9][0-9]|[1-9][0-9][0-9][0-9][0-9][0-9][0-9])
		    mv ${i} ${i}.tmp
		    awk  -v line="$_POS" -v ava="${_AVA}" '
                      BEGIN{l=1;}
                      l==line{print ava;l++;}
                      {print;l++;}
                      END{if(line>l){print ava;}}
                      ' ${i}.tmp>${i}
		    rm -f ${i}.tmp
		    ;;

		''|TOP)
		    mv ${i} ${i}.tmp
		    echo "${_AVA}"> ${i};
		    cat ${i}.tmp>>${i}
		    rm -f ${i}.tmp
		    ;;

		BOTTOM)
		    echo "${_AVA}">> ${i};
		    ;;
		*)
		    ABORT=1;
		    printERR $LINENO $BASH_SOURCE ${ABORT} "Unknown keyword for position:\"${_POS}\""
		    gotoHell ${ABORT}
		    ;;
	    esac
	else
	    if [ -n "${_DELETE}" ];then
		_OCCUR=$(echo "${_OCCUR}"|tr 'a-z' 'A-Z');
		_OCCUR_MAX=$(cat ${i}|grep "${_ATTRNAME}"|wc -l)
		[ "${_OCCUR}" == FIRST ]&&_OCCUR=1;
		if [ "${_OCCUR}" == LAST ];then
		    _OCCUR="${_OCCUR_MAX}"
		fi
		if((_OCCUR>_OCCUR_MAX));then
		    _OCCUR="${_OCCUR_MAX}"
		fi
		if [ -z "${_OCCUR}" ];then
		    _OCCUR=1;
		fi
		case $_OCCUR in
                    [1-9]|[1-9][0-9]|[1-9][0-9][0-9]|[1-9][0-9][0-9][0-9]|[1-9][0-9][0-9][0-9]|[1-9][0-9][0-9][0-9][0-9]|[1-9][0-9][0-9][0-9][0-9][0-9]|[1-9][0-9][0-9][0-9][0-9][0-9][0-9])
			mv ${i} ${i}.tmp
			awk  -F'=' -v count="$_OCCUR" -v an="${_ATTRNAME}" '
                      BEGIN{o=0;}
                      $1==an{o++;}
                      $1==an&&o==count{next;}
                      {print;}
                      ' ${i}.tmp>${i}
			rm -f ${i}.tmp
			;;

		    0)
			;;

		    *)
			ABORT=1;
			printERR $LINENO $BASH_SOURCE ${ABORT} "Unknown keyword for occurance:\"${_OCCUR}\""
			gotoHell ${ABORT}
			;;
		esac
	    else
		setAttribute "$C_SESSIONTYPE" "${_ATTRNAME}" "${_ATTRVALNEW}" "${_ATTRVALOLD}" "${_OCCUR}" ${i}
	    fi
	fi
    fi



    if [ ! -f "${i}" ];then
	ABORT=1;
	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing file:\"${i}\""
	gotoHell ${ABORT}
    fi
done



