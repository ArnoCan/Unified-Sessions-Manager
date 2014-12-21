#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_007
#
########################################################################
#
#     Copyright (C) 2007,2008,2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
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
#  ctys
#
#AUTHOR:
AUTHOR="Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org"
#
#FULLNAME:
FULLNAME="Unified Sessions Manager"
#
#CALLFULLNAME:
CALLFULLNAME="Manage address resolution."
#
#LICENCE:
LICENCE=GPL3
#
#TYPE:
#  bash-script
#
#VERSION:
VERSION=01_11_007
#DESCRIPTION:
#  Main untility of project ctys for manging sessions.
#
#EXAMPLE:
#
#PARAMETERS:
#
#  refer to online help "-h" and/or "-H"
#
#OUTPUT:
#  RETURN:
#    0: OK
#    1: NOK: parameter error
#    2: NOK: missing environment element,files, etc.
#   11: NOK: unambiguity requested, but result is abigiuous
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
	gotoHell 1
	;;
esac


. ${MYLIBPATH}/lib/misc.sh
. ${MYLIBPATH}/lib/security.sh
. ${MYLIBPATH}/lib/help/help.sh
. ${MYLIBPATH}/lib/groups.sh
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

#should be set only, when postfixes required before exit.
globalExitValue=0;


#path to directory containing the tmp
MYTMP=${MYTMP:-/tmp/$USER}
if [ ! -d "${MYTMP}" ];then
    mkdir -p "${MYTMP}"
fi

#controls debugging for awk-scripts
doDebug $S_BIN  ${D_MAINT} $LINENO $BASH_SOURCE
D=$?

unset C_SUBCALL;
C_INTERACTIVE=0;
CTYS_MULTITYPE=ALL;
C_TERSE=;

_outputset=0;
_rtscope=0;
_user=;
_groups=0;
_machine=0;
_table=0;
_tab=;
_TABARGS=;
_title=0;
_titleidx=0;
_macmap=0;
_macmaponly=0;
_macmaponlytrial=0;
_st=0;
_pm=0;
#_src=ALL;
#_src=ENUM;
_vb=0;
_tcp=0;
_dns=0;
_mac=0;
_ids=0;
_uuid=0;
_label=0;
_ver=0;
_ip=0;
_ser=0;
_cat=0;
_dist=0;
_distrel=0;
_os=0;
_osrel=0;
_sort=0;
_usort=0;
_sortkey=0;
_unique=0;
_rsort=0;
_first=0;
_last=0;
_all=0;
_rttype=0;
_reverse=0;
_mark=0;
_cost=0;
_rebuildcache=0;
_keepRTCache=0;
_keepAll=0;
_arglst=;
_cacheoff=0;
_complement=0;

_arch=0;
_cstr=0;
_hyrel=0;
_pform=0;
_scap=0;
_sreq=0;
_vstat=0;
_vram=0;
_vcpu=0;
_ustr=0;
_rsrv1=0;
_rsrv2=0;
_rsrv3=0;
_rsrv4=0;
_rsrv5=0;
_rsrv6=0;
_rsrv7=0;
_rsrv8=0;
_rsrv9=0;
_rsrv10=0;
_rsrv11=0;
_rsrv12=0;
_rsrv13=0;
_rsrv14=0;
_rsrv15=0;


_execloc=0;
_gateway=0;
_sshport=0;
_netname=0;
_hwcap=0;
_hwreq=0;
_ifname=0;
_netmask=0;
_relay=0;
_reloccap=0;
_ctysrel=0;

#storage of concatenated STATCACHEDB and volatile RT data of LIST
#will be reset before usage when RTCACHE:<key> is set.
RTCACHEDB=${MYTMP}/${MYCALLNAME}.${DATETIME}.cdb

#Maximum age of a cached DB in seconds, when threshold reached cache
#will be forced to clear.
CACHECLEARPERIOD=${CTYS_CACHECLEARPERIOD:-3600}



#FUNCBEG###############################################################
#NAME:
#  setGroupsFeature
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Sets environment and loads plugins a required for GROUPS plugin.
#
#EXAMPLE:
#
#PARAMETERS:
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function setGroupsFeature () {
    #assure for append...
    if [ -n "$CTYS_GROUPS_PATH" ];then
	mstr=$HOME/.ctys/groups
	CTYS_GROUPS_PATH=${CTYS_GROUPS_PATH//$mstr}
	mstr=$MYCONFPATH/groups
	CTYS_GROUPS_PATH=${CTYS_GROUPS_PATH//$mstr}
    fi

    if [ -n "$CTYS_GROUPS_PATH" ];then
	checkPathElements CTYS_GROUPS_PATH ${CTYS_GROUPS_PATH}
    fi

    if [ ! -d "${HOME}/.ctys/groups" ];then
	ABORT=1;
	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing standard directory:${HOME}/.ctys/groups"
	printERR $LINENO $BASH_SOURCE ${ABORT} "Has to be present at least, check your installation"
	gotoHell ${ABORT}
    fi

    if [ ! -d "${MYCONFPATH}/groups" ];then
	ABORT=1;
	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing standard directory:${MYCONFPATH}/groups"
	printERR $LINENO $BASH_SOURCE ${ABORT} "Has to be present at least, check your installation"
	gotoHell ${ABORT}
    fi

    CTYS_GROUPS_PATH="${HOME}/.ctys/groups:${MYCONFPATH}/groups${CTYS_GROUPS_PATH:+:$CTYS_GROUPS_PATH}"

    PLUGINPATHS=${MYINSTALLPATH}/plugins/CORE

    #
    #Perform the initialization according and based on LD_PLUGIN_PATH.
    #
    MYROOTHOOK=${MYINSTALLPATH}/plugins/hook.sh
    if [ ! -f "${MYROOTHOOK}" ];then 
	ABORT=1
	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing packages hook: hook=${MYROOTHOOK}"
	gotoHell ${ABORT}
    fi
    . ${MYROOTHOOK}
    initPackages "${MYROOTHOOK}"
}



#FUNCBEG###############################################################
#NAME:
#  myFetchOptionsPre
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Analyse CLI options. It sets the appropriate context, gwhich could be 
#  for remote or local execution.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Callcontext:
#      LOCAL  : for local execution
#      REMOTE : for local and remote execution, because some HAS to 
#               be recognized locally too, so for "simplicity" => both.
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function myFetchOptionsPre () {
    printDBG $S_BIN ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=<${@}>"
    local _myArgs=$@

    printDBG $S_BIN ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_myArgs=<${_myArgs}>"

    _RUSER0=;
    _RHOST0=;

    #control flow
    EXECUTE=1;
    unset ABORT
    OPTIND=1
    OPTLST="c:C:d:hH:i:I:l:L:M:o:p:R:sS:T:VwWx:X";
    _ARGSCALL=$_myArgs
    while getopts $OPTLST CUROPT ${_myArgs} && [ -z "${ABORT}" ]; do
	case ${CUROPT} in
	    L) #[-l:]
		if [ -z "${OPTARG}" ]; then
		    ABORT=1;         
   		    printERR $LINENO $BASH_SOURCE ${ABORT} "remote user for SSH access-verification: \"-L\""
		fi
                _RUSER0=${OPTARG}
		printDBG $S_BIN ${D_FLOW} $LINENO $BASH_SOURCE "remote user for SSH access-verification:$_RUSER0"
		;;

	    R) #[-R]
		if [ -z "${OPTARG}" ]; then
		    ABORT=1;         
   		    printERR $LINENO $BASH_SOURCE ${ABORT} "database path or address-mapping: \"-p\""
		fi
                _RHOSTS0=${OPTARG}
		printDBG $S_BIN ${D_UID} $LINENO $BASH_SOURCE "database path or address-mapping:_RHOSTS0=\"${_RHOSTS0}\""
		;;
	esac
    done
}



#FUNCBEG###############################################################
#NAME:
#  myFetchOptions
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Analyse CLI options. It sets the appropriate context, gwhich could be 
#  for remote or local execution.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Callcontext:
#      LOCAL  : for local execution
#      REMOTE : for local and remote execution, because some HAS to 
#               be recognized locally too, so for "simplicity" => both.
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function myFetchOptions () {
    printDBG $S_BIN ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=<${@}>"
    local _myArgs=$@

    printDBG $S_BIN ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_myArgs=<${_myArgs}>"

    _RUSER0=;
    _RHOST0=;

    #control flow
    EXECUTE=1;
    unset ABORT
    OPTIND=1
    OPTLST="c:C:d:hH:i:I:l:M:o:p:sS:T:VwWx:X";
    while getopts $OPTLST CUROPT ${_myArgs} && [ -z "${ABORT}" ]; do
	case ${CUROPT} in

	    c) #[-c:]
		if [ -z "${OPTARG}" ]; then
		    ABORT=1;         
		fi
                _cost=;
                case ${OPTARG} in
                    [mM][iI][nN][cC][nN][tT])             _cost=mincnt;;
                    [mM][aA][xX][cC][nN][tT])             _cost=maxcnt;;
                    [cC][nN][tT])                         _cost=cnt;;
		    *)
			ABORT=1;         
   			printERR $LINENO $BASH_SOURCE ${ABORT} "Unknown COST: \"${OPTARG}\""
			;;
                esac
		_tcp=1;
		_ids=1;
		_mac=1;
		_uuid=1;
		_pm=1;
		_st=1;
		_os=1;
		;;

	    C) #[-C:]
		if [ -z "${OPTARG}" ]; then
		    ABORT=1;         
		fi
		for iS in ${OPTARG//,/ }; do
                    case ${iS} in
                        #
                        #setting sets
                        #
			[oO][fF][fF])
			    _cacheoff=1;
			    ;;
			[mM][aA][cC][mM][aA][pP])
			    _macmap=1;
			    ;;
			[mM][aA][cC][mM][aA][pP][oO][nN][lL][yY])
			    _macmaponly=1;
			    ;;
			[gG][rR][oO][uU][pP][sS])
			    _groups=1;
			    ;;

                        #
                        #setting persistency
                        #
			[aA][dD][jJ][uU][sS][tT])
			    _adjust=1;
			    ;;
			[rR][eE][bB][uU][iI][lL][dD][cC][aA][cC][hH][eE])
			    _groups=1;
			    _rebuildcache=1;
			    ;;
			[kK][eE][eE][pP][aA][lL][lL])
			    _keepAll=1;
			    ;;

                        #
                        #clear sets
                        #
			[cC][lL][eE][aA][rR][tT][mM][pP])
                            echo
			    echo "CLEARTMP"
 			    echo "-> Clear all current caches of \"${MYCALLNAME}\" for \"${USER}\":"
 			    echo "   -> TMP-Caches    :\"${MYTMP}\""
                            echo
			    find ${MYTMP}      -name "${MYCALLNAME}.*.cdb" -exec /bin/rm -rf {} \; -printf "      %p\n"
 			    echo 
                            gotoHell 0;
			    ;;

			[cC][lL][eE][aA][rR][aA][lL][lL])
                            local _allStat="${DBPATHLST//:/ }"
                            echo
			    echo "CLEARUSER"
 			    echo "-> Clear all current caches for \"${USER}\":"
 			    echo "   -> TMP-Caches    :\"${MYTMP}\""
 			    echo 
			    find ${MYTMP}      -name "${MYCALLNAME}.*.cdb" -exec /bin/rm -rf {} \; -printf "      %p\n"
 			    echo 
 			    echo "   -> Static-Caches :\"${_allStat}\""
                            echo
			    local i4del=;
			    for i4del in `find ${_allStat}   -name '*.cdb' -print`;do
				echo "      $i4del"
				rm -rf "${i4del}"
			    done
 			    echo 
                            gotoHell 0;
			    ;;

                        #
                        #list sets
                        #
			[lL][iI][sS][tT])
                            local _allStat="${DBPATHLST//:/ }"
                            echo
			    echo "Current \"${MYCALLNAME}\" file-caches for \"${USER}\":"
 			    find ${MYTMP}    -type f -name "${MYCALLNAME}.*.cdb" -printf "  %4kk  " -exec wc -l {} \;
			    find ${_allStat} -type f -name '*.cdb'               -printf "  %4kk  " -exec wc -l {} \;
                            echo
			    echo "Current \"${MYCALLNAME}\" group-caches of groups for \"${USER}\":"
 			    find ${MYTMP}    -type d -printf "  %4kk  " -print |grep 'ctys-vhost.grpscache.cdb'
 			    find ${_allStat} -type d -printf "  %4kk  " -print |grep 'ctys-vhost.grpscache.cdb'
                            echo
                            gotoHell 0;
			    ;;


			[lL][iI][sS][tT][tT][aA][rR][gG][eE][tT][sS])
                            local _allStat="${DBPATHLST//:/ }"
                            echo
			    echo "Current \"${MYCALLNAME}\" file-caches for \"${USER}\":"
 			    find ${MYTMP}    -type f -name "${MYCALLNAME}.*.cdb" -printf "  %4kk  " -exec wc -l {} \;
			    find ${_allStat} -type f -name '*.cdb'               -printf "  %4kk  " -exec wc -l {} \;
                            echo
                            gotoHell 0;
			    ;;


			[lL][iI][sS][tT][gG][rR][oO][uU][pP][sS])
                            local _allStat="${DBPATHLST//:/ }"
                            echo
			    echo "Current \"${MYCALLNAME}\" group-caches for \"${USER}\":"
 			    find ${MYTMP}    -type f -printf "  %4kk  " -exec wc -l {} \;|grep 'ctys-vhost.grpscache.cdb'
 			    find ${_allStat} -type f -printf "  %4kk  " -exec wc -l {} \;|grep 'ctys-vhost.grpscache.cdb'
                            echo
                            gotoHell 0;
			    ;;


                        #
                        #members of sets
                        #
			[mM][eE][mM][bB][eE][rR][sS][dD][bB])
                            echo
			    echo "MEMBERSDB - ctys stack- addresses."
                            echo 
                            ${MYLIBEXECPATH}/ctys-vhost.sh ${C_DARGS} -s \
                               -p "${DBPATHLST}" -o ctys -M all .|sort
                            gotoHell 0;
			    ;;


			*)
			    ABORT=1;         
   			    printERR $LINENO $BASH_SOURCE ${ABORT} "Unknown MappingSource: \"${OPTARG}\""
			    ;;
                    esac
		done
		;;

	    d) #[-d:]
		;;


	    h) #[-h]
		showToolHelp
		ABORT=0;
		;;
	    H)  printHelpEx "${OPTARG:-$MYCALLNAME}";ABORT=0;;

	    i) #[-i:]
		if [ -z "${OPTARG}" ]; then
		    ABORT=1;         
		fi
                local KEYLST=`echo "$OPTARG"|tr '[:lower:]' '[:upper:]'|sed 's/,/ /g'`
		for KEY in $KEYLST;do
                    case ${KEY} in
			CTYSADDRESS|CTYS)_ctysin=1;;
			*)
			    ABORT=1;         
   			    printERR $LINENO $BASH_SOURCE ${ABORT} "Unknown OUTPUT: \"${KEY}\""
			    ;;
                    esac
		done
		;;

	    I) #[-I:]
		if [ -z "${OPTARG}" ]; then
		    ABORT=1;         
		fi
		local i=;
                for i in ${OPTARG//,/ };do
                    case ${i} in
			[0-2])  C_INTERACTIVE=${i};;
			*)
			    ABORT=1;         
    			    printERR $LINENO $BASH_SOURCE ${ABORT} "Unknown AMOUNT: \"-I ${OPTARG}\""
    			    printERR $LINENO $BASH_SOURCE ${ABORT} "Requires:       \"-I <level>\""
			    ;;
                    esac
		done
		;;

	    l) #[-L:]
		if [ -z "${OPTARG}" ]; then
		    ABORT=1;         
   		    printERR $LINENO $BASH_SOURCE ${ABORT} "remote user for SSH access-verification: \"-l\""
		fi
                _user=${OPTARG}
		printDBG $S_BIN ${D_FLOW} $LINENO $BASH_SOURCE "remote user for SSH access-verification:$_user"		
		;;

	    M) #[-M:]
		if [ -z "${OPTARG}" ]; then
		    ABORT=1;         
		fi
                _first=0;
                _last=0;
                _all=0;
		local i=;
                for i in ${OPTARG//,/ };do
                    case ${i} in
			[fF][iI][rR][sS][tT])     _first=1;;
			[lL][aA][sS][tT])         _last=1;;
			[aA][lL][lL])             _all=1;;
			[sS][oO][rR][tT])         _sort=1;;
			[uU][sS][oO][rR][tT])     _usort=1;;
			[uU][nN][iI][qQ][uU][eE]) _unique=1;_all=1;;
			[cC][oO][mM][pP][lL][eE][mM][eE][nN][tT]) _complement=1;;
			*)
			    ABORT=1;         
   			    printERR $LINENO $BASH_SOURCE ${ABORT} "Unknown AMOUNT: \"${OPTARG}\""
			    ;;
                    esac
		done
		;;

	    o) #[-o:]
		if [ -z "${OPTARG}" ]; then
		    ABORT=1;         
		fi
		for i in ${OPTARG//,/ };do
		    KEY=`echo ${i%%:*}|tr '[:lower:]' '[:upper:]'`
		    ARG=`echo ${i}|awk -F':' '{print $2}'`
                    case ${KEY} in
			CTYSADDRESS|CTYS)                 _ctysaddr=1;_machine=1;_outputset=1;;

			ARCH)                             _arch=1;_outputset=1;;
			CATEGORY|CAT)                     _cat=1;_outputset=1;;
			CONTEXTSTRING|CSTRG)              _cstr=1;_outputset=1;;
			CPORT|VNCPORT)                    _cport=1;_outputset=1;;
			CTYSRELEASE)                      _ctysrel=1;_outputset=1;;
			DIST)                             _dist=1;_outputset=1;;
			DISTREL)                          _distrel=1;_outputset=1;;
			DNS|D)                            _dns=1;_outputset=1;;
			EXECLOCATION)                     _execloc=1;_outputset=1;;
			GATEWAY)                          _gateway=1;_outputset=1;;
			GROUPID|GID)                      _gid=1;_outputset=1;;
			HWCAP)                            _hwcap=1;_outputset=1;;
			HWREQ)                            _hwreq=1;_outputset=1;;
			HYPERREL|HYREL)                   _hyrel=1;_outputset=1;;
			IDS|ID|I)                         _ids=1;_outputset=1;;
			IFNAME)                           _ifname=1;_outputset=1;;
			IP)                               _ip=1;_tcp=1;_outputset=1;;
			LABEL|L)                          _label=1;_outputset=1;;
			MAC|M)                            _mac=1;_outputset=1;;
			MACHINE)                          _machine=1;_table=0;_outputset=1;;
			MAXKEY)                           _pm=1;_st=1;_label=1;_ids=1;_uuid=1;_mac=1;_outputset=1;;
			NETMASK)                          _netmask=1;_outputset=1;;
			NETNAME)                          _netname=1;_outputset=1;;
			OS|O)                             _os=1;_outputset=1;;
			OSREL)                            _osrel=1;_outputset=1;;
			PLATFORM|PFORM)                   _pform=1;_outputset=1;;
			PM|HOST|H)                        _pm=1;_outputset=1;;
			PNAME|P)                          _ids=1;_outputset=1;;
			RELAY)                            _relay=1;_outputset=1;;
			RELOCCAP)                         _reloccap=1;_outputset=1;;
			SERIALNUMBER|SERNO)               _ser=1;_outputset=1;;
			SPORT|SERVERACCESS|S)             _sport=1;_outputset=1;;
			SSHPORT)                          _sshport=1;_outputset=1;;
			STACKCAP|SCAP)                    _scap=1;_outputset=1;;
			STACKREQ|SREQ)                    _sreq=1;_outputset=1;;
			TCP|T)                            _tcp=1;_outputset=1;;
			TITLE)                            _title=1;;
			TITLEIDXASC)                      _titleidx=2;;
			TITLEIDX)                         _titleidx=1;;
			STYPE|ST)                         _st=1;_outputset=1;;
			USERSTRING|USTRG)                 _ustr=1;_outputset=1;;
			USERID|UID)                       _uid=1;_outputset=1;;
			UUID|U)                           _uuid=1;_outputset=1;;
			VCPU)                             _vcpu=1;_outputset=1;;
			VERSION|VER|VERNO)                _ver=1;_outputset=1;;
			VMSTATE|VSTAT)                    _vstat=1;_outputset=1;;
			VNCBASE)                          _vb=1;_outputset=1;;
			VNCDISPLAY|DISP)                  _disp=1;_outputset=1;;
			VRAM)                             _vram=1;_outputset=1;;

 			TAB_GEN|TAB)                      _tab=TAB_GEN;
                                                          _TABARGS=${ARG}
                                                          _title=1;_machine=1;_table=1;
							  _outputset=1;
                                                          ;;
 			REC_GEN|REC)                      _tab=REC_GEN;
                                                          _TABARGS=${ARG}
                                                          _title=1;_machine=1;_table=1;
							  _outputset=1;
                                                          ;;
 			XML_GEN|XML)                      _tab=XML_GEN;
                                                          _TABARGS=${ARG}
                                                          _title=1;_machine=1;_table=1;
							  _outputset=1;
                                                          ;;
 			SPEC_GEN|SPEC)                    _tab=SPEC_GEN;
                                                          _TABARGS=${ARG}
                                                          _title=1;_machine=1;_table=1;
							  _outputset=1;
                                                          ;;

			SORT)       _sort=1;
			    local _SORTARGS=${ARG}
			    local i=;
			    for i in ${_SORTARGS//\%/ };do
				case ${i} in
				    [aA][lL][lL]|[aA])#will be sorted in the topmost schedular once, does not require sub-sorts
					if [ -n "${CTYS_SUBCALL}" ];then
					    _sort=0;
					fi
					;;
				    [uU][nN][iI][qQ][uU][eE]|[uU])
					_unique=1;
					;;
				    [rR][eE][vV][eE][rR][sS][eE]|[rR])
					_rsort=1;
					;;
				    [eE][aA][cC][hH])
					;;
				    [0-9][0-9][0-9]|[0-9][0-9]|[0-9])
					_sortkey=$i
					;;
				    *)
					ABORT=1
					printERR $LINENO $BASH_SOURCE ${ABORT} "Unexpected sort suboption:${_SORTARGS}"
					gotoHell ${ABORT}
					;;
				esac
			    done
			    ;;


			*)
			    ABORT=1;         
   			    printERR $LINENO $BASH_SOURCE ${ABORT} "Unknown OUTPUT: \"${KEY}\""
			    ;;
                    esac
		done
		;;

	    p) #[-p:]
		if [ -z "${OPTARG}" ]; then
		    ABORT=1;         
   		    printERR $LINENO $BASH_SOURCE ${ABORT} "database path or address-mapping: \"-p\""
		fi
                DBPATHLST=${OPTARG}
		printDBG $S_BIN ${D_UID} $LINENO $BASH_SOURCE "database path or address-mapping:DBPATHLST=\"${DBPATHLST}\""
		if [ ! -d "${DBPATHLST}" ];then
		    ABORT=1;         
   		    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing selected cacheDB=\"${DBPATHLST}\""
		fi
		;;

	    s) #[-s]
		C_SUBCALL=1;
		;;

	    S) #[-S:]
		if [ -z "${OPTARG}" ]; then
		    ABORT=1;         
		fi
		for iS in ${OPTARG//,/ }; do
                    #let the shell do:iS=`echo ${iS}|tr '[:lower:]' '[:upper:]'`
                    case ${iS} in
                        #
                        #DB
                        #
			[[lL][iI][sS][tT][aA][lL][lL])
                            local _allStat1="${DBPATHLST//:/ }"
                            local _allStat=;
                            local _dl=;
                            for _dl in ${_allStat1};do
				_allStat="`dirname ${_dl}` ${_allStat}"
			    done

			    if [ -z "$C_TERSE" ];then
				echo
				echo "Current file-databases for \"${USER}\":"
			    fi
 			    find ${MYTMP}    -type f -name '*.fdb' -printf "  %4kk  " -exec wc -l {} \;
			    find ${_allStat} -type f -name '*.fdb' -printf "  %4kk  " -exec wc -l {} \;
			    if [ -z "$C_TERSE" ];then
				echo
			    fi
                            setGroupsFeature
			    if [ -z "$C_TERSE" ];then
				echo
				echo "Current group files of:"
				echo
				splitPath 20 "CTYS_GROUPS_PATH" "$CTYS_GROUPS_PATH"
				echo
			    fi
			    listGroups SHORT
			    if [ -z "$C_TERSE" ];then
				echo
			    fi
                            gotoHell 0;
			    ;;

			[[lL][iI][sS][tT])
			    if [ -z "$C_TERSE" ];then
				local _allStat="${DBPATHLST//:/ }"
				echo
				echo "Current file-databases for \"${USER}\":"
			    fi
 			    find ${MYTMP}    -type f -name '*.fdb' -printf "  %4kk  " -exec wc -l {} \;
			    find ${_allStat} -type f -name '*.fdb' -printf "  %4kk  " -exec wc -l {} \;
			    if [ -z "$C_TERSE" ];then
				echo
			    fi
                            setGroupsFeature
			    if [ -z "$C_TERSE" ];then
				echo
				echo "Current group files of:"
				echo
				splitPath 20 "CTYS_GROUPS_PATH" "$CTYS_GROUPS_PATH"
				echo
			    fi
			    listGroups SHORT
			    if [ -z "$C_TERSE" ];then
				echo
			    fi
                            gotoHell 0;
			    ;;


                        #
                        #DB
                        #
			[[lL][iI][sS][tT][dD][bB])
                            local _allStat1="${DBPATHLST//:/ }"
                            local _allStat=;
                            local _dl=;
                            for _dl in ${_allStat1};do
				_allStat="`dirname ${_dl}` ${_allStat}"
			    done

			    if [ -z "$C_TERSE" ];then
				echo
				echo "Current file-databases for \"${USER}\":"
			    fi
 			    find ${MYTMP}    -type f -name '*.fdb' -printf "  %4kk  " -exec wc -l {} \;
			    find ${_allStat} -type f -name '*.fdb' -printf "  %4kk  " -exec wc -l {} \;
			    if [ -z "$C_TERSE" ];then
				echo 
			    fi
                            gotoHell 0;
			    ;;
			[mM][eE][mM][bB][eE][rR][sS][dD][bB])
			    if [ -z "$C_TERSE" ];then
				echo
				echo "MEMBERSDB - ctys stack- addresses."
				echo 
			    fi
                            ${MYLIBEXECPATH}/ctys-vhost.sh ${C_DARGS} -s \
                                -p "${DBPATHLST}" -C OFF -o ctys -M all .|sort
                            gotoHell 0;
			    ;;


                        #
                        #GROUPS
                        #
			[lL][iI][sS][tT][gG][rR][oO][uU][pP]*)
                            setGroupsFeature
			    if [ -z "$C_TERSE" ];then
				echo
				echo "Current group files of:${iS}"
				echo
				splitPath 20 "CTYS_GROUPS_PATH" "$CTYS_GROUPS_PATH"
				echo
			    fi
                            if [ "${iS//:/}" == "${iS}" ];then
				listGroups SHORT
			    else
				listGroups SHORT "${iS#*:}"
                            fi
			    if [ -z "$C_TERSE" ];then
				echo
			    fi
                            gotoHell 0;
			    ;;
			[cC][oO][nN][tT][eE][nN][tT][gG][rR][oO][uU][pP])
                            setGroupsFeature
			    if [ -z "$C_TERSE" ];then
				echo
				echo "Current group files of:"
				echo
				splitPath 20 "CTYS_GROUPS_PATH" "$CTYS_GROUPS_PATH"
				echo
			    fi
			    listGroups CONTENT
			    if [ -z "$C_TERSE" ];then
				echo 
			    fi
                            gotoHell 0;
			    ;;
#			[mM][eE][mM][bB][eE][rR][sS][gG][rR][oO][uU][pP]6*)
			[mM][eE][mM][bB][eE][rR][sS][gG][rR][oO][uU][pP][67]*)
                            setGroupsFeature
			    if [ -z "$C_TERSE" ];then
				echo
				echo "Current group files of:"
				echo
				splitPath 20 "CTYS_GROUPS_PATH" "$CTYS_GROUPS_PATH"
				echo
			    fi
                            if [ "${iS//:/}" == "${iS}" ];then
				local allgrp=$(C_TERSE_OLD=$C_TERSE;C_TERSE=1;listGroups SHORT;C_TERSE=$C_TERSE_OLD;)
				fetchGroupMemberHosts "$allgrp"
			    else
				fetchGroupMemberHosts  "${iS#*:}"
                            fi
			    if [ -z "$C_TERSE" ];then
				echo 
			    fi
                            gotoHell 0;
			    ;;
			[mM][eE][mM][bB][eE][rR][sS][gG][rR][oO][uU][pP]5*)
                            setGroupsFeature
			    if [ -z "$C_TERSE" ];then
				echo
				echo "Current group files of:"
				echo
				splitPath 20 "CTYS_GROUPS_PATH" "$CTYS_GROUPS_PATH"
				echo
			    fi
                            if [ "${iS//:/}" == "${iS}" ];then
				listGroupMembers DEEP5CALL
			    else
				listGroupMembers DEEP5CALL "${iS#*:}"
                            fi
			    if [ -z "$C_TERSE" ];then
				echo 
			    fi
                            gotoHell 0;
			    ;;
			[mM][eE][mM][bB][eE][rR][sS][gG][rR][oO][uU][pP]4*)
                            setGroupsFeature
			    if [ -z "$C_TERSE" ];then
				echo
				echo "Current group files of:"
				echo
				splitPath 20 "CTYS_GROUPS_PATH" "$CTYS_GROUPS_PATH"
				echo
			    fi
                            if [ "${iS//:/}" == "${iS}" ];then
				listGroupMembers DEEP4CALL
			    else
				listGroupMembers DEEP4CALL "${iS#*:}"
                            fi
			    if [ -z "$C_TERSE" ];then
				echo 
			    fi
                            gotoHell 0;
			    ;;
			[mM][eE][mM][bB][eE][rR][sS][gG][rR][oO][uU][pP]3*)
                            setGroupsFeature
			    echo
			    echo "Current group files of:"
			    echo
			    splitPath 20 "CTYS_GROUPS_PATH" "$CTYS_GROUPS_PATH"
			    echo
                            if [ "${iS//:/}" == "${iS}" ];then
				listGroups DEEP3
			    else
				listGroups DEEP3 "${iS#*:}"
                            fi
			    echo 
                            gotoHell 0;
			    ;;
			[mM][eE][mM][bB][eE][rR][sS][gG][rR][oO][uU][pP]2*)
                            setGroupsFeature
			    if [ -z "$C_TERSE" ];then
				echo
				echo "Current group files of:"
				echo
				splitPath 20 "CTYS_GROUPS_PATH" "$CTYS_GROUPS_PATH"
				echo
			    fi
                            if [ "${iS//:/}" == "${iS}" ];then
				listGroupMembers DEEP
			    else
				listGroupMembers DEEP "${iS#*:}"
                            fi
			    if [ -z "$C_TERSE" ];then
				echo 
			    fi
                            gotoHell 0;
			    ;;
			[mM][eE][mM][bB][eE][rR][sS][gG][rR][oO][uU][pP]|[mM][eE][mM][bB][eE][rR][sS][gG][rR][oO][uU][pP]:*)
                            setGroupsFeature
			    if [ -z "$C_TERSE" ];then
				echo
				echo "Current group files of:"
				echo
				splitPath 20 "CTYS_GROUPS_PATH" "$CTYS_GROUPS_PATH"
				echo
			    fi
                            if [ "${iS//:/}" == "${iS}" ];then
				listGroups DEEP
			    else
				listGroups DEEP "${iS#*:}"
                            fi
			    if [ -z "$C_TERSE" ];then
				echo 
			    fi
                            gotoHell 0;
			    ;;

			*)
			    ABORT=1;         
   			    printERR $LINENO $BASH_SOURCE ${ABORT} "Unknown MappingSource: \"${OPTARG}\""
			    ;;
                    esac
		done
		;;

	    T) #[-T:]
		if [ -z "${OPTARG}" ]; then
		    ABORT=1;         
		fi
                #To be pre-processed in calling-main.
                #Defines the types of plugins to be loaded
		CTYS_MULTITYPE=${OPTARG};
		;;

	    V) #[-V]
		printVersion
		ABORT=0;
		;;

	    x) #[-x:]
		if [ -z "${OPTARG}" ]; then
		    ABORT=1;         
		fi

                local KEYLST=`echo "$OPTARG"|tr '[:lower:]' '[:upper:]'|sed 's/,/ /g'`
		for KEY in $KEYLST;do
                    case ${KEY} in
			[pP][iI][nN][gG]) _rttype=1;  [ $_rtscope == 0 ]&&_rtscope=1;;
			[sS][sS][hH])     _rttype=2;  [ $_rtscope == 0 ]&&_rtscope=1;;
			
			[pP][mM])         _rtscope=1; [ $_rttype == 0 ]&&_rttype=1;;
			[vV][mM])         _rtscope=2; [ $_rttype == 0 ]&&_rttype=1;;

                        [rR][eE][vV][eE][rR][sS][eE]|R)
                                          _reverse=1;;

                        [mM][aA][rR][kK])
                                          _mark=1;;

			*)
			    ABORT=1;         
   			    printERR $LINENO $BASH_SOURCE ${ABORT} "Unknown RUNTIME-TYPE: \"${KEY}\""
			    ;;
                    esac
		done
		;;

	    X) #[-X]
		C_TERSE=" -X ";
		;;
	    *)
		ABORT=1;
		printERR $LINENO $BASH_SOURCE ${ABORT} "Erroneous parameter:${CUROPT}"
		printERR $LINENO $BASH_SOURCE ${ABORT} "Call \"${MYCALLNAME} -h\" for additional help"
		;;
	esac
    done
    if((_outputset==0));then
	_TABARGS="`replaceMacro macro:TAB_CTYS_VHOST_DEFAULT`"
	_TABARGS=${_TABARGS//\%\%/\%}
	_TABARGS=${_TABARGS#tab_gen:}
	_tab=TAB_GEN;
        _title=1;_machine=1;_table=1;
	printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "_TABARGS=<$_TABARGS>"
    fi


    #check for COST calculation context:
    if [ "${_cost}" == 1 -a \( "$_tcp" != 1 -o "$_pm" != 1 \) ];then
	ABORT=1;
	printERR $LINENO $BASH_SOURCE ${ABORT} "When \"load distribution\", the ip addresses and hosting PM are mandatory."
	printERR $LINENO $BASH_SOURCE ${ABORT} "  COST   = $_cost"
	printERR $LINENO $BASH_SOURCE ${ABORT} "  TCP/IP = $_tcp"
	printERR $LINENO $BASH_SOURCE ${ABORT} "  PM     = $_pm"
    fi

    if [ -n "${ABORT}" -a "${ABORT}" != "0" ];then
	printERR $LINENO $BASH_SOURCE ${ABORT} "ERROR:CLI error for call parameters."
	gotoHell ${ABORT}
    fi
    if [ -n "${ABORT}" ];then
	ABORT=1;
	gotoHell ${ABORT}
    fi


    printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_arglst=$*"
    shift $(( OPTIND - 1))
    printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_arglst=$*"
    _arglst=$*
    if [ -z "$_arglst" ];then
	_arglst='.';
# 	ABORT=1;
# 	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing:arguments"
# 	gotoHell ${ABORT}
    fi

    if [ "${_arglst// -/}" != "${_arglst}" ];then
	printWNG 1 $LINENO $BASH_SOURCE 0 "Possibly options misplaced:<arguments> =? \"${_arglst}\""
	printWNG 1 $LINENO $BASH_SOURCE 0 " => ${MYCALLNAME} [options] <arguments>"
    fi


    #force consistency
    if [ "$_cost" == 1 ];then
	_first=0;_last=0;_usort=0;_all=1;
	_tcp=1;_ids=1;_mac=1;_uuid=1;_pm=1;_st=1;_os=1;
    fi

    if [ "$_first" == 0 -a "$_last" == 0 -a "$_all" == 0 ];then
	_all=1;
    fi
    
    if [ "$_macmaponly" == 1 ];then
	if((_ctysaddr+_machine+_ids+_label+_uuid+_os+_pm+_st>0));then
	    ABORT=1;
	    printERR $LINENO $BASH_SOURCE ${ABORT} "With \"-C MACMAPONLY\" use for \"-o\":{TCP,MAC,DNS},"
	    printERR $LINENO $BASH_SOURCE ${ABORT} "else the cache-databases \"*.cdb\" are required."
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Generally prefer usage of \"-C MACMAP\", gwhich decides"
	    printERR $LINENO $BASH_SOURCE ${ABORT} "for best performance when possible."
	    gotoHell ${ABORT}
	fi
    else
        #if macmap is enabled
        #switch to direct macmap-access(without additional overhead) when only contained parameters given
	if((_macmap==1&&_tcp+_mac+_dns>0&&_ctysaddr+_machine+_ids+_label+_uuid+_os+_pm+_st==0));then
	    _macmaponlytrial=1;
	fi
    fi

    if((_maxidx!=0));then
	_pm=1;
	_st=1;
	_label=1;_ids=1;
	_mac=1;_tcp=1;_uuid=1;
    fi

    if((_machine!=0));then
	_pm=1;
	_st=1;
	_label=1;_ids=1;
	_mac=1;_tcp=1;_uuid=1;
	_distrel=1;_osrel=1;
	_disp=1;_cport=1;_sport=1;_vb=1;
	_dist=1;_os=1;_ver=1;_ser=1;_cat=1;
	_arch=1;_cstr=1;_hyrel=1;_pform=1;_scap=1;
	_sreq=1;_vstat=1;_vram=1;_vcpu=1;_ustr=1;
	_rsrv1=1;_rsrv2=1;_rsrv3=1;_rsrv4=1;_rsrv5=1;
	_rsrv6=1;_rsrv7=1;_rsrv8=1;_rsrv9=1;_rsrv10=1;
	_rsrv11=1;_rsrv12=1;_rsrv13=1;_rsrv14=1;_rsrv15=1;
        _execloc=1;_gateway=1;_hwcap=1;_hwreq=1;_ifname=1;
        _sshport=1;_netname=1;
        _netmask=1;_relay=1;_reloccap=1;_ctysrel=1;
        _uid=1;_gid=1;
    fi
}



#FUNCBEG###############################################################
#NAME:
#  checkStatCacheDB
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Makes the decision for cacheupdate, therefore the caches are simply  
#  removed, when criteria matches. Criteria are:
#
#   1. outdated data due to new available
#   2. outdated cache age, gwhich is just an obligatoric refresh, 
#      currently every hour.
#
#
#EXAMPLE:
#
#PARAMETERS:
#  $1:  Current DB
#
#GLOBALS:
#  CACHECLEARPERIOD 
#    When age reaches threshold, cache will be cleared.
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function checkStatCacheDB () {
    local _curDB=$1
    if [ -z "$_curDB" ];then
	ABORT=2;
	printERR $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:ERROR:Internal ERR:MISSING _curDB=${_curDB}"
	gotoHell ${ABORT}
    fi

    function rmCacheStat () {
	if [ -f ${STATCACHEDB} ];then
	    if [ -z "$C_SUBCALL" ];then
  		printINFO 1 $LINENO $BASH_SOURCE 0 "$FUNCNAME:STATCACHEDB:CACHE clear for REBUILD"
  		rm -f ${STATCACHEDB} 2>/dev/null
	    else
		printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "STATCACHEDB is outdated and requires re-sync."
	    fi
	fi
    }

    function rmCacheGroups () {
	if [ -d "${GRPSCACHEDB}" ];then
	    if [ -z "$C_SUBCALL" ];then
  		printINFO 1 $LINENO $BASH_SOURCE 0 "$FUNCNAME:GRPSCACHEDB:CACHE clear for REBUILD"
  		rm -rf ${GRPSCACHEDB} 2>/dev/null
	    else
		printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "GRPSCACHEDB is outdated and requires re-sync."
	    fi
	fi
    }


    [ "$C_INTERACTIVE" != 0 ]&&printf "CHECK             =%s\n" ${i}

    #prepare DB-Directory with static data
    printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:Check DB-Presence..."

    if [ ! -d "${_curDB}" ];then
	ABORT=7;
	printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "...\"${_curDB}\" NOK"
	printERR $LINENO $BASH_SOURCE ${ABORT} "...ooops!"
	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing DB-directory, required to be present."
	printERR $LINENO $BASH_SOURCE ${ABORT} "DB=\"${_curDB}\""
	gotoHell ${ABORT}
    fi

    STATCACHEDB=${_curDB}/${MYCALLNAME}.statcache.cdb
    GRPSCACHEDB=${_curDB}/${MYCALLNAME}.grpscache.cdb
    ENUMDB=${_curDB}/enum.fdb
    MACMAPfile=${_curDB}/macmap.fdb



    ################
    #Current caches #
    ################

    #basics
    if [ -z "${STATCACHEDB}" ];then
	ABORT=8;
	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing definition:STATCACHEDB=${STATCACHEDB}"
	gotoHell ${ABORT}
    fi
    if [ -z "${GRPSCACHEDB}" ];then
	ABORT=9;
	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing definition:GRPSCACHEDB=${GRPSCACHEDB}"
	gotoHell ${ABORT}
    fi

    #obvious
    if [ -f "${STATCACHEDB}" ];then
        printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "Present:STATCACHEDB=${STATCACHEDB}"
	if [ "$_rebuildcache" == "1" ];then
            printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "CLEAR/Remove STATCACHEDB=${STATCACHEDB} due to REBUILD-flag"
	    rmCacheStat
	fi
    fi

    #the highlight nr#1
    if [ -z "${MACMAPfile}" -o ! -f "${MACMAPfile}" ];then
	ABORT=10;
	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing:MACMAPfile=${MACMAPfile}"
	printERR $LINENO $BASH_SOURCE ${ABORT} "Required for getting TCP/IP-addresses from MAC-addresses."
	printERR $LINENO $BASH_SOURCE ${ABORT} "Following should be applied:"
	printERR $LINENO $BASH_SOURCE ${ABORT} "-> use another option than \"-S $_src\" DEFAULT=ALL"
	printERR $LINENO $BASH_SOURCE ${ABORT} "-> generate data, refer to \"ctys-extractMAClst.sh\""
	printERR $LINENO $BASH_SOURCE ${ABORT} "   and/or \"ctys-extractARPlst.sh\""
	printERR $LINENO $BASH_SOURCE ${ABORT} "."
	printERR $LINENO $BASH_SOURCE ${ABORT} "Following helps quick and dirty(please avoid this), because"
	printERR $LINENO $BASH_SOURCE ${ABORT} "TCP/IP - MAC mapping information will be missing than."
	printERR $LINENO $BASH_SOURCE ${ABORT} "."
	printERR $LINENO $BASH_SOURCE ${ABORT} "->You will not be remembered about an present but"
	printERR $LINENO $BASH_SOURCE ${ABORT} "  empty macmap.fdb!"
	printERR $LINENO $BASH_SOURCE ${ABORT} "  => call \"touch ${MACMAPfile}\""
	printERR $LINENO $BASH_SOURCE ${ABORT} "."
	gotoHell ${ABORT}
    fi
    printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "Found:MACMAPfile=${MACMAPfile}"
    if [ "${MACMAPfile}" -nt "${STATCACHEDB}" ];then
	printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "   but outdated, resync with:"
	printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "     \"${MACMAPfile}\""
	rmCacheStat
    fi

    #depends from obvious
    if [ -d "${GRPSCACHEDB}" ];then
        printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "Present:GRPSCACHEDB=${GRPSCACHEDB}"
	if [ "$_rebuildcache" == "1" ];then
            printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "CLEAR/Remove GRPSCACHEDB=${GRPSCACHEDB} due to REBUILD-flag"
	    rmCacheGroups
        else
	    if [ ! -f "${STATCACHEDB}" ];then
		printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "CLEAR/Remove GRPSCACHEDB=${GRPSCACHEDB} due to missing STATCACHEDB"
		rmCacheGroups
	    else
		if [ "${STATCACHEDB}" -nt "${GRPSCACHEDB}" ];then
		    printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "CLEAR/Remove GRPSCACHEDB=${GRPSCACHEDB} due to newer STATCACHEDB"
		    rmCacheGroups
		else
                    setGroupsFeature
		    local _chkpath1=;
		    local _chk1=;
		    for _chkpath1 in `listGroups`;do
			_chk1=`basename ${_chkpath1}`		    
			if [ ! -f "${GRPSCACHEDB}/${_chk1}" -o "${_chkpath1}" -nt "${GRPSCACHEDB}/${_chk1}" ];then
			    printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "CLEAR/Remove GRPSCACHEDB=${GRPSCACHEDB} due to newer ${_chkpath1}"
			    rmCacheGroups
			fi
		    done
		fi
	    fi
	fi
    else
	printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "FreshAndNew:GRPSCACHEDB=${GRPSCACHEDB}"
	if [ "$_rebuildcache" == "0" ];then
	    _groups=1;
	fi
    fi



    ################
    #Sources caches #
    ################

    if [ -z "${ENUMDB}" -o ! -f "${ENUMDB}" ];then
	ABORT=2;
	printERR $LINENO $BASH_SOURCE ${ABORT} "."
	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing:ENUMDB=${ENUMDB}"
	printERR $LINENO $BASH_SOURCE ${ABORT} "Required as base for mapping PMs and VMs."
	printERR $LINENO $BASH_SOURCE ${ABORT} "Following may be applied:"
	printERR $LINENO $BASH_SOURCE ${ABORT} "-> generate data, refer to $(setSeverityColor TRY \"ctys-vdbgen.sh\")"
	printERR $LINENO $BASH_SOURCE ${ABORT} "."
	gotoHell ${ABORT}
    fi
    printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "Found:ENUMDB=${ENUMDB}"
    if [ "${ENUMDB}" -nt "${STATCACHEDB}" ];then
	printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "   but outdated, clear and resync with:"
	printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "     \"${ENUMDB}\""
	rmCacheStat
    fi

    printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "GROUPS already checked elsewhere!"

    local age=`getDateTimeOfInode ${STATCACHEDB}`;
    if(( (DATETIME-age)>CACHECLEARPERIOD ));then
	printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "STATCACHEDB:lifetime exceeds:CACHECLEARPERIOD=${CACHECLEARPERIOD}"
	rmCacheStat
    fi

    local gage=`getDateTimeOfInode ${GRPSCACHEDB}`;
    if(( (DATETIME-gage)>CACHECLEARPERIOD || (DATETIME-age)>CACHECLEARPERIOD ));then
	printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "GRPSCACHEDB:lifetime exceeds:CACHECLEARPERIOD=${CACHECLEARPERIOD}"
	rmCacheGroups
    fi
    printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "...\"${_curDB}\" OK"

}




#FUNCBEG###############################################################
#NAME:
#  buildStatCacheDB
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1:  Current DB
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function buildStatCacheDB () {
    local _curDB=$1
    if [ -z "$_curDB" ];then
	ABORT=2;
	printERR $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:ERROR:Internal ERR:MISSING _curDB=${_curDB}"
	gotoHell ${ABORT}
    fi
    doDebug $S_BIN  ${D_BULK} $LINENO $BASH_SOURCE 
    D=$?

    function resolveENUM () {
	awk -F';' -v p=${MACMAPfile} -v d=$D -f ${MYLIBEXECPATH}/${MYCALLNAME}.d/ctys-vhost-enum.awk
    }

    STATCACHEDB=${_curDB}/${MYCALLNAME}.statcache.cdb
    GRPSCACHEDB=${_curDB}/${MYCALLNAME}.grpscache.cdb
    ENUMDB=${_curDB}/enum.fdb
    MACMAPfile=${_curDB}/macmap.fdb

    if [ \
	! -f  "${STATCACHEDB}" \
        -o  "${_rebuildcache}" == "1" \
	];then

        local _startTime1=`getCurTime`
	printINFO 1 $LINENO $BASH_SOURCE 0 "."
	printINFO 1 $LINENO $BASH_SOURCE 0 "$FUNCNAME:START($_startTime1):Rebuild stat-cache,"
	printINFO 1 $LINENO $BASH_SOURCE 0 "$FUNCNAME:may take maybe some minutes..."
        [ "$C_INTERACTIVE" != 0 ]&&printf "BUILD STAT-DB     =%s\n" ${i}
	printDBG $S_BIN ${D_FLOW} $LINENO $BASH_SOURCE "STATCACHEDB:Creation required"

	rm -f ${STATCACHEDB} 2>/dev/null

   	printDBG $S_BIN ${D_FLOW} $LINENO $BASH_SOURCE "STATCACHEDB:add ENUMDB=${ENUMDB}"
	if [ "_adjust" == "1" ];then
	    cat ${ENUMDB}|sort -u>${ENUMDB}.adjust
	    rm -f ${ENUMDB}&& mv ${ENUMDB}.adjust ${ENUMDB}
	fi
	cat ${ENUMDB}|resolveENUM |sort -u>>${STATCACHEDB}
        local _endTime1=`getCurTime`
        local _diffTime1=`getDiffTime $_endTime1 $_startTime1`
	printINFO 1 $LINENO $BASH_SOURCE 0 "$FUNCNAME:END  ($_endTime1):Rebuild stat-cache finished"
	printINFO 1 $LINENO $BASH_SOURCE 0 "$FUNCNAME:TOTAL($_diffTime1):Rebuild stat-cache"

    fi


    if [ \
	! -d  "${GRPSCACHEDB}" \
        -o  "${_rebuildcache}" == "1" \
	];then

	if [ "${NOGCACHE}" == 1 ];then
 	    printINFO 2 $LINENO $BASH_SOURCE 0 "."
 	    printINFO 2 $LINENO $BASH_SOURCE 0 "$FUNCNAME:groups-cache is deactivated:NOGCACHE=${NOGCACHE}"
 	    printINFO 2 $LINENO $BASH_SOURCE 0 "."
	    return
	fi

        local _startTime2=`getCurTime`
 	printINFO 1 $LINENO $BASH_SOURCE 0 "."
 	printINFO 1 $LINENO $BASH_SOURCE 0 "$FUNCNAME:START($_startTime2):Rebuild groups-cache,"
 	printINFO 1 $LINENO $BASH_SOURCE 0 "may take some minutes..."

        setGroupsFeature

	if [ ! -d "${GRPSCACHEDB}" ];then
	    mkdir "${GRPSCACHEDB}"
	fi

	local _chkpath1=;
	local _chk0=;
	local _chk1=;

        #expects clean target
	local _lx=`listGroupMembers`;
        _lx=${_lx// /};
        _lx=${_lx//\'/}; #' 4emacs
        _lx=${_lx//\"/}; #" 4emacs
        _lx=`echo ${_lx}|sed 's/([^)]*)//g'`

	for _chk0 in $_lx;do
	    printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "_chk0=${_chk0}"
 	    local _grppath=${_chk0%%:*};_grp=${_grp## }
 	    local _grp=`basename ${_grppath}`
 	    local _lst=;
 	    _lst=${_chk0##*:};
            _lst=${_lst//\}/ };
            _lst=${_lst//\{/ };
            _lst=${_lst//,/ };

	    printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "_lst=${_lst}"
	    for _chk1 in $_lst;do
		printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "_chk1=${_chk1}"

                #uses statcache
		${MYLIBEXECPATH}/ctys-vhost.sh ${C_DARGS} -s \
                                -p "${DBPATHLST}" -M all -o machine ${_chk1}>>${GRPSCACHEDB}/${_grp}
	    done
            [ "$C_INTERACTIVE" != 0 ]&&printf "BUILD GRP-DB      =%s\n" ${_grppath}
	done
        local _endTime2=`getCurTime`
        local _diffTime2=`getDiffTime $_endTime2 $_startTime2`
 	printINFO 1 $LINENO $BASH_SOURCE 0 "$FUNCNAME:END  ($_endTime2):Rebuild groups-cache finished"
 	printINFO 1 $LINENO $BASH_SOURCE 0 "$FUNCNAME:TOTAL($_diffTime2):Rebuild groups-cache"
    fi
}




#FUNCBEG###############################################################
#NAME:
#  vHostCost
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Cost is given for calculations of load distribution.
#
#EXAMPLE:
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function vHostCost () {
    printDBG $S_BIN ${D_FLOW} $LINENO $BASH_SOURCE "Calculate target driven by COST."

    #shift to array
    idx=0;
    declare -a RESULTARRAY
    declare -a RESULTWEIGHT
    RESULTLST_1=`for i in $RESULTLST;do echo $i;done`
#    RESULTLST_1=`for i in $RESULTLST;do echo $i;done|sort`


    #call LIST on each host just once!
    tmpHost0=;
    for i in $RESULTLST_1;do
	RESULTARRAY[$idx]=$i

        #new index
	tmpHost1=`echo $i|awk -F';' '{print $5}'`

	printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "$tmpHost0 == $tmpHost1"
	if [ "$tmpHost0" == "$tmpHost1" ];then 
	    RESULTWEIGHT[$idx]=${RESULTWEIGHT[$((idx-1))]}
	else
	    RESULTWEIGHT[$idx]=`ctys -a LIST=MACHINE  -T ${CTYS_MULTITYPE} $tmpHost1 |wc -l`
	    doDebug $S_BIN  ${D_BULK} $LINENO $BASH_SOURCE 
	    if [ $? == 0 ];then
		tmpCache1=`ctys -a LIST=MACHINE -T ${CTYS_MULTITYPE} $tmpHost1`
		printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "tmpCache1=${tmpCache1}"
	    fi
	fi
	if [ "$C_INTERACTIVE" != 0 ];then
	    printf "RESULTWEIGHT[%03d]=%03d  $tmpHost1\n" $idx ${RESULTWEIGHT[$idx]}
	fi
	printDBG $S_BIN ${D_FLOW} $LINENO $BASH_SOURCE "$tmpHost1=RESULTARRAY[$idx]=${RESULTARRAY[$idx]}"
	printDBG $S_BIN ${D_FLOW} $LINENO $BASH_SOURCE "$tmpHost1=RESULWEIGHT[$idx]=${RESULTWEIGHT[$idx]}"
	tmpHost0=$tmpHost1
	((idx++))
    done


    case $_cost in
	maxcnt)
	    maxIdx=0;
	    maxWeight=0;
	    for((i=0;i<idx;i++));do
		if((RESULTWEIGHT[i]>maxWeight));then
		    maxWeight=${RESULTWEIGHT[$i]};
		    maxIdx=$i;
		    printDBG $S_BIN ${D_FLOW} $LINENO $BASH_SOURCE "maxIdx=$maxIdx=>$maxWeight"
		    if [ "$C_INTERACTIVE" != 0 ];then
			echo  "delta maxIdx($maxIdx)=$maxWeight"
		    fi
		fi
	    done
	    if [ -n "$_ctysaddr" ];then
		echo ${RESULTARRAY[$maxIdx]}|makeCtysAddr
	    else
		echo ${RESULTARRAY[$maxIdx]}
	    fi
	    ;;
	mincnt)
	    minIdx=0;
	    minWeight=99999;
	    for((i=0;i<idx;i++));do
		if((RESULTWEIGHT[i]<minWeight));then
		    minWeight=${RESULTWEIGHT[$i]};
		    minIdx=$i;
		    printDBG $S_BIN ${D_FLOW} $LINENO $BASH_SOURCE "minIdx=$minIdx=>$minWeight"
		    if [ "$C_INTERACTIVE" != 0 ];then
			echo  "delta minIdx($minIdx)=$minWeight"
		    fi
		fi
	    done
	    if [ -n "$_ctysaddr" ];then
		echo ${RESULTARRAY[$minIdx]}|makeCtysAddr
	    else
		echo ${RESULTARRAY[$minIdx]}
	    fi
	    ;;
	cnt)
	    for((i=0;i<idx;i++));do
		if [ -n "$_ctysaddr" ];then
		    echo ${RESULTARRAY[$i]}|makeCtysAddr
		else
		    echo ${RESULTARRAY[$i]}
		fi
	    done
	    ;;
    esac

}



#FUNCBEG###############################################################
#NAME:
#  applyPreSelectionFilter
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function applyPreSelectionFilter () {
    printDBG $S_BIN ${D_FLOW} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=$@"
    printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "s=${*} -v t=$_tcp -v dns=$_dns -v m=$_mac -v ids=$_ids"
    printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "-v u=$_uuid -v p=$_pm -v st=$_st -v o=$_os -v dist=$_dist "
    printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "-v first=$_first -v last=$_last -v all=$_all -v usort=$_usort "
    printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "-v l=$_label -v rt=$_rttype -v d=$D -v unique=$_unique "
    printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "-v rev=$_reverse -v mark=$_mark -v rsort=$_rsort "
    printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "-v rs=$_rtscope -v mach=$_machine -v title=$_title "
    printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "-v cport=$_cport -v sport=$_sport  -v disp=$_disp "
    printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "-v osrel=$_osrel -v distrel=$_distrel "
    printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "-v user=${_user} -v mmap=$_macmap -v callp=${MYLIBEXECPATH}" 
    printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "-v interact=${C_INTERACTIVE}"
    printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "-v rsrv1=$_rsrv1 -v rsrv2=$_rsrv2 -v rsrv3=$_rsrv3"
    printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "-v rsrv4=$_rsrv4 -v rsrv5=$_rsrv5 -v rsrv6=$_rsrv6"
    printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "-v rsrv7=$_rsrv7 -v rsrv8=$_rsrv8 -v rsrv9=$_rsrv9"
    printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "-v rsrv10=$_rsrv10 -v rsrv11=$_rsrv11 -v rsrv12=$_rsrv12"
    printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "-v rsrv13=$_rsrv13 -v rsrv14=$_rsrv14 -v rsrv15=$_rsrv15"
    printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "-v vstat=$_vstat -v hyrel=$_hyrel -v scap=$_scap"
    printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "-v sreq=$_sreq -v arch=$_arch -v pform=$_pform"
    printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "-v vram=$_vram -v vcpu=$_vcpu -v cstr=$_cstr"
    printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "-v ustr=$_ustr"
    printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "-v execloc=$_execloc -v gateway=$_gateway -v hwcap=$_hwcap"
    printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "-v hwreq=$_hwreq -v ifname=$_ifname -v netmask=$_netmask"
    printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "-v relay=$_relay -v reloccap=$_reloccap -v sshport=$_sshport"
    printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "-v netname=$_netname "
    printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "-v ctysrel=$_ctysrel -v complement=$_complement"
    printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "-v uid=$_uid -v gid=$_gid"


    local IFS="
"
    local DBIN=$1;shift

    doDebug $S_BIN  ${D_BULK} $LINENO $BASH_SOURCE 
    D=$?

    function inputFilter () {
        local _final=$1;shift
        local _outmach=$1;shift
	if [ "$_machine" == 1 ];then
            _outmach=1;
	fi

        export C_DARGS;
        if [ "$_final" == "1" ];then
	    awk -F';' -v s="${*}" -v t=$_tcp -v dns=$_dns -v m=$_mac -v ids=$_ids -v u=$_uuid \
		-v rsrv1="$_rsrv1" -v rsrv2="$_rsrv2"   -v rsrv3="$_rsrv3" -v rsrv4="$_rsrv4" \
		-v rsrv5="$_rsrv5" -v rsrv6="$_rsrv6"   -v rsrv7="$_rsrv7" -v rsrv8="$_rsrv8" \
		-v rsrv9="$_rsrv9" -v rsrv10="$_rsrv10" -v rsrv11="$_rsrv11" -v rsrv12="$_rsrv12" \
		-v rsrv13="$_rsrv13" -v rsrv14="$_rsrv14" -v rsrv15="$_rsrv15" \
		-v vstat="$_vstat" -v hyrel="$_hyrel" -v scap="$_scap" -v sreq="$_sreq" \
		-v arch="$_arch" -v pform="$_pform" -v vram="$_vram" -v vcpu="$_vcpu"  \
		-v cstr="$_cstr" -v ustr="$_ustr" \
		-v p=$_pm -v st=$_st -v o=$_os -v first=$_first -v last=$_last -v all=$_all \
                -v vb="$_vb" -v usort=$_usort -v unique=$_unique -v rsort=$_rsort \
		-v l=$_label -v rt=$_rttypeX -v rs=$_rtscopeX -v mach=$_outmach -v dist=$_dist  \
                -v rev=$_reverse -v mark=$_mark \
		-v cport=$_cport -v sport=$_sport  -v disp=$_disp \
		-v distrel=$_distrel -v osrel=$_osrel -v ver="$_ver"  \
		-v ser=$_ser -v cat=$_cat -v complement=$_complement\
		-v d=$D -v user=${_user} -v mmap=$_macmap -v callp="${MYLIBEXECPATH}" \
                -v interact=${C_INTERACTIVE} -v ctysrel="$_ctysrel" \
                -v execloc="$_execloc" -v gateway="$_gateway" -v hwcap="$_hwcap" \
                -v hwreq="$_hwreq" -v ifname="$_ifname" -v netmask="$_netmask" \
                -v relay="$_relay" -v reloccap="$_reloccap" -v sshport=$"_sshport" \
                -v uid="$_uid" -v gid="$_gid" \
                -v netname="$_netname" \
		-f ${MYLIBEXECPATH}/${MYCALLNAME}.d/ctys-vhost-presel.awk \
		|sed 's/; */;/g'
	else
	    awk -v s="${*}"  '$0~s{print $0;}'
	fi
    }

    local _inargs=$*
    local _init=1;

    if((_rttype!=0||C_INTERACTIVE>0));then
 	_rttypeX=3
    else
 	_rttypeX=0
    fi
    _rtscopeX=0

    local LRES=;
    local o=;
    local a=0;
    local complementOld=${_complement};
    [ "${*//[oO][rR]}" != "${*}" ]&&local l=1; #save some perfomance

    while [ -n "${*}" ];do
        local _curArg=$1;shift
 	printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "Apply ergexpr=\"${_curArg}\""
	case "$_curArg" in
	    [aA][nN][dD])o=;continue;;
	    [oO][rR])o=0;continue;;
	    [nN][oO][tT])_complement=1;continue;;
	    [eE]:*)a=1;;
	    [fF]:*)a=1;;
	esac
 	printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "a=<$a>"
        if [ -n "${*}" ];then
            #not last regexpr-filter
            if [ -n "$_init" ];then
 		printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "l=<$l>"
		if [ -z "$l" ];then
		    case "$C_INTERACTIVE" in
			2)RESULTLST=`cat ${DBIN}|inputFilter 1 1 "${_curArg}"`;;
			*)RESULTLST=`cat ${DBIN}|inputFilter $a 1 "${_curArg}"`;;
		    esac
		else
		    LRES=`cat ${DBIN}`;
		    case "$C_INTERACTIVE" in
			2)RESULTLST=`echo "${LRES}"|inputFilter 1 1 "${_curArg}"`;;
			*)RESULTLST=`echo "${LRES}"|inputFilter $a 1 "${_curArg}"`;;
		    esac
		fi
		unset _init;
	    else
 		printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "l=<$l>"
                local i1=;
		if [ -z "$l" ];then
		    case "$C_INTERACTIVE" in
			2)RESULTLST=`for i1 in ${RESULTLST};do echo ${i1};done|inputFilter 1 1 "${_curArg}"`;;
			*)RESULTLST=`for i1 in ${RESULTLST};do echo ${i1};done|inputFilter $a 1 "${_curArg}"`;;
		    esac
		else
		    case "$C_INTERACTIVE" in
			2)  
			    if [ -z "$o" ];then 
				LRES="${RESULTLST}";
				RESULTLST=`for i1 in ${RESULTLST};do echo ${i1};done|inputFilter 1 1 "${_curArg}"`;
			    else  
				RESULTLST=" ${RESULTLST} "$([ -n "${RESULTLST}" ]&&echo;for i1 in ${LRES};do echo ${i1};done|inputFilter 1 1 "${_curArg}")
				o=;
			    fi
			    ;;
			*)
			    if [ -z "$o" ];then 
				LRES="${RESULTLST}";
				RESULTLST=`for i1 in ${RESULTLST};do echo ${i1};done|inputFilter $a 1 "${_curArg}"`;
			    else  
				RESULTLST=" ${RESULTLST} "$([ -n "${RESULTLST}" ]&&echo;for i1 in ${LRES};do echo ${i1};done|inputFilter 1 1 "${_curArg}")
				o=;
			    fi
			    ;;
		    esac
		fi
	    fi
	    printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "RESULT=-->\"$RESULTLST\"<--"
	else
            #last regexpr-filter
            if [ -n "$_init" ];then
		RESULTLST=`cat ${DBIN}|inputFilter 1 0 "${_curArg}"`
		unset _init;
	    else
                local i1=;
		if [ -z "$o" ];then 
		    RESULTLST=`for i1 in ${RESULTLST};do echo ${i1#*#@#};done|inputFilter 1 0 "${_curArg}"`
		else  
		    RESULTLST=$(for i1 in ${RESULTLST};do echo ${i1#*#@#};done|inputFilter 1 0 "")
		    RESULTLST=" ${RESULTLST} "$([ -n "${RESULTLST}" ]&&echo;for i1 in ${LRES};do echo ${i1#*#@#};done|inputFilter 1 0 "${_curArg}")
		    o=;
		fi
	    fi
	    printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "RESULT=-->\"$RESULTLST\"<--"
	fi
	_complement=${complementOld};
    done
    printDBG $S_BIN ${D_DATA} $LINENO $BASH_SOURCE "RESULT-NO-RTSTATE=-->\"$RESULTLST\"<--"

    #to do this for chained filter args
    if [ "$_first" == "1" ];then
	for i1 in ${RESULTLST};do _RESULTLST="${i1}";break;done
	RESULTLST="${_RESULTLST}"
    fi
    [ "$_last" == "1" ]&&RESULTLST=${RESULTLST##*
}

    printDBG $S_BIN ${D_DATA} $LINENO $BASH_SOURCE "RESULT-NO-RTSTATE=-->\"$RESULTLST\"<--"

    local _OUT=;
    local _VM=;
    local _PM=;
    local _pos=;
    local _RESULTLST=;


    function accessCheck () {
	if [ "$_rttype" == 1 ];then
	    ping -c 1 -w 1 $1 2>&1 >/dev/null
	    _ret=$?;
	else
	    ssh $1 echo 2>&1 >/dev/null
	    _ret=$?;
	fi
	if [ "$_reverse" != 0 ];then
	    [ "$_ret" == "0" ]&&return 1||return 0;
	else
	    return $_ret;
	fi
    }

    if((_rttype!=0||C_INTERACTIVE>0));then
      local icnt=0;
      local mcnt=0;
      if((C_INTERACTIVE!=0));then
	  case $_rttype in
	      1)echo -n -e "QUERY:runtime(ping)\n  ";;
	      2)echo -n -e "QUERY:runtime(ping+ssh)\n  ";;
	  esac
      fi
      for i in $RESULTLST;do
        _OUT=${i##*#@#}
        _VM=${i%#@#*}
        _IDX=${_VM%%@*}
        _VM=${_VM#*@}
        _ST=${_VM%%@*}
        _PM=${_VM#*@}
        _PM=${_PM%%@*}
        _VM=${_VM##*@}
        printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "i  =$i"
        printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "IDX=$_IDX"
        printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "PM =$_PM"
        printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "VM =$_VM"
        printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "ST =$_ST"
        printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "OUT=$_OUT"

#
#keep for lazy testing
#  	echo "i  =$i">&2
#  	echo "IDX=$_IDX">&2
#  	echo "PM =$_PM">&2
#  	echo "VM =$_VM">&2
#  	echo "ST =$_ST">&2
#  	echo "OUT=$_OUT">&2

        local _chk=0;
	case $_rtscope in
	    1)accessCheck "$_PM";_chk=$?;;
	    2)accessCheck "$_VM";_chk=$?;;
	esac

	if((C_INTERACTIVE!=0));then
	    ((_chk==0))&&let mcnt++;
	    let icnt++;    
	    if((icnt%50==0));then ((_chk==0))&&echo -n -e "X${icnt}\n  "||echo -n -e "x${icnt}\n  "
	    else
		if((icnt%10==0));then ((_chk==0))&&echo -n "X"||echo -n "x";
		else ((_chk==0))&&echo -n "!"||echo -n "."; fi
	    fi
	fi
	if((_chk==0));then
	    printDBG $S_BIN ${D_FLOW} $LINENO $BASH_SOURCE "$_OUT"
	    _RESULTLST="${_RESULTLST} ${_OUT}"
	else
	    if [ "$_mark" == 1 ];then
		_RESULTLST="${_RESULTLST} -${_OUT//;/;-}"
	    fi
	fi
      done
      if((C_INTERACTIVE!=0));then
	  echo
	  echo "  match=${mcnt} of total=${icnt}"
      fi
      RESULTLST="${_RESULTLST}"
    fi
    printDBG $S_BIN ${D_FLOW} $LINENO $BASH_SOURCE "RESULTLST=-->\"$RESULTLST\"<--"
}





#FUNCBEG###############################################################
#NAME:
#  makeCtysAddr
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Generates a complete ctys <machine-address> from a given "ENUMERATE"
#  string.
#
#  Currently not usabele as a standalone library function!
#
#
#EXAMPLE:
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function makeCtysAddr () {
    if((_tcp+_mac+_ids+_uuid+_label==0));then
	_ids=1;
    fi
    doDebug $S_BIN  ${D_BULK} $LINENO $BASH_SOURCE 
    D=$?

    awk -F';' -v t=$_tcp -v m=$_mac -v ids=$_ids -v u=$_uuid \
	-v p=$_pm  -v complement="$_complement" \
	-v l=$_label -v rt=$_rttype -v rs=$_rtscope -v mach=$_machine \
        -v rev=$_reverse \
	-v d=$D -v user=${_user} \
	-f ${MYLIBEXECPATH}/${MYCALLNAME}.d/ctys-vhost-maddr.awk
}


#FUNCBEG###############################################################
#NAME:
#  useMacMapOnly
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Works on macmap.fdb only.
#
#
#EXAMPLE:
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function useMacMapOnly () {
    printDBG $S_BIN ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:\$*=<${*}>"
    local curMacMap=${1}/macmap.fdb;shift
    local argLst=$*;shift

    doDebug $S_BIN  ${D_BULK} $LINENO $BASH_SOURCE 
    D=$?

    if [ -f "${curMacMap}" ];then
	awk -F';' -v s="${argLst}" -v t=$_tcp -v m=$_mac -v dns=$_dns \
 	    -v first=$_first -v last=$_last -v all=$_all \
	    -v rt=$_rttype -v rs=$_rtscope -v mach=$_machine \
            -v rev=$_reverse \
            -v d=$D  -v w=$WNG  -v complement="$_complement" \
    	    -f ${MYLIBEXECPATH}/${MYCALLNAME}.d/ctys-vhost-macmap.awk "${curMacMap}"
        return 
    fi
    return 1
}

###########################################################
###########################################################



printDBG $S_BIN ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:\$*=<${*}>"

_args="`replaceMacro $*`";

#quick-and-dirty of course
_args="${_args//\%\%/%}";
printDBG $S_BIN ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:_args=<${_args}>"


myFetchOptionsPre ${_args:-*}

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


#avoid array-detection for <machine-addr> input.
if [ "${*}" != "${*//-i/}" ];then
    #Ok, input format is defined, seems to be <machine-addr>
    #Yes, that's the trick!
    #Using just nested matching for resolution!
    _args="${*//[/ }"
    _args="${_args//]/ }"
fi


DBPATHLST=${DBPATHLST:-$DEFAULT_DBPATHLST}
myFetchOptions ${_args:-*}

#basic check for setup db
if [ -z "$DBPATHLST" ];then
    ABORT=1;
    printERR $LINENO $BASH_SOURCE ${ABORT} "At least default for DB-file required."
    printERR $LINENO $BASH_SOURCE ${ABORT} "Usega:"
    printERR $LINENO $BASH_SOURCE ${ABORT} "  prio1: -> \"-p <db-dir-path>\""
    printERR $LINENO $BASH_SOURCE ${ABORT} "  prio2: -> export DEFAULT_DBPATHLST=..."
    gotoHell ${ABORT}
fi

printDBG $S_BIN ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:DBPATHLST=<${DBPATHLST}>"


################################
#
#match MAC-MAP only
#
#
if [ "$_macmaponly" == "1" -o "$_macmaponlytrial" == 1 ];then
    for i in ${DBPATHLST//:/ };do
	printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "Check MACMAP=${i}"
	useMacMapOnly "${i}" ${_arglst}
        if [ $? -eq 0 ];then gotoHell 0;fi
    done
    if [ "$_macmaponly" == "1" ];then
	gotoHell 0
    fi
fi



################################
#
#check databases and caches
#
#
[ "$C_INTERACTIVE" != 0 ]&&printf "START R-Methods\n"
#static data: check each source DB-Directory 
for i in ${DBPATHLST//:/ };do
    printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "Check STATCACHE=${i}"
    checkStatCacheDB "${i}"
done


[ "$C_INTERACTIVE" != 0 ]&&printf "START R/W-Methods\n"
#runtime data: prepare cache
if [ "$_keepRTCache" == "0" -a "$_keepAll" == "0" ];then
    [ "$C_INTERACTIVE" != 0 ]&&printf "RM RTCACHE        =%s\n" ${RTCACHEDB}
    rm -f ${RTCACHEDB} 2>/dev/null
else
    [ "$C_INTERACTIVE" != 0 ]&&printf "KEEPRTCACHE       =%s\n" ${RTCACHEDB}
fi
for i in ${DBPATHLST//:/ };do
    printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "Prepare STATCACHE=${i}"
    buildStatCacheDB "${i}"
done




################################
#
#prepare regexpr-subset
#
#

#compromise: runtime performance and some "structure"
#            RESULTLST is the one and only "data-bus"
if [ "${DBPATHLST}" != "${DBPATHLST//:/ }" ];then
  MULTIDB=1
  _COLLECT=;
fi

for _db in ${DBPATHLST//:/ };do
    if [ "${_cacheoff}" == 1 ];then
	DBWORK="${_db}/enum.fdb"
    else
	DBWORK="${_db}/${MYCALLNAME}.statcache.cdb"
    fi
    applyPreSelectionFilter "${DBWORK}" ${_arglst}
    if [ -n "${MULTIDB}" ];then
	_COLLECT="${_COLLECT:+$_COLLECT}${RESULTLST}"
    fi
done

if [ -n "${MULTIDB}" ];then
    RESULTLST="${_COLLECT}"
fi

printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "RESULTLST=${RESULTLST}"


################################
#
#Is load to be calculated?
#
# ->ATTENTION: Display format could be exceptional divergent(namely for load-display:CNT),
#              when selected, vHostCost will not return!
#
if [ "$_cost" == 1 ];then
    vHostCost
fi



#
# $1:title-display:
#    0: off
#    1: on
#
# $2:awk-filter-file
#
function applyFilter () {
    local t=0;
    local tx=0;
    if [ "$1" == 1 ];then
	local t=${_title};
	local tx=${_titleidx};
    fi

    awk -F';' -v vb="$_vb" -v ip="$_ip" -v dist="$_dist" -v os="$_os" -v ver="$_ver" -v ser="$_ser" \
	-v rsrv1="$_rsrv1" -v rsrv2="$_rsrv2"   -v rsrv3="$_rsrv3" -v rsrv4="$_rsrv4" \
	-v rsrv5="$_rsrv5" -v rsrv6="$_rsrv6"   -v rsrv7="$_rsrv7" -v rsrv8="$_rsrv8" \
	-v rsrv9="$_rsrv9" -v rsrv10="$_rsrv10" -v rsrv11="$_rsrv11" -v rsrv12="$_rsrv12" \
	-v rsrv13="$_rsrv13" -v rsrv14="$_rsrv14" -v rsrv15="$_rsrv15" \
	-v vstat="$_vstat" -v hyrel="$_hyrel" -v scap="$_scap" -v sreq="$_sreq" \
	-v arch="$_arch" -v pform="$_pform" -v vram="$_vram" -v vcpu="$_vcpu"  \
	-v cstr="$_cstr" -v ustr="$_ustr" -v complement="$_complement" \
        -v cat="$_cat" -v l="$_label" -v i="$_ids" -v t="$_st" -v uu="$_uuid"  \
	-v mac="$_mac"  -v dsp="$_disp" -v cp="$_cport" -v sp="$_sport"  \
	-v h="$_pm" -v tcp="$_tcp" -v dns="$_dns" \
	-v d=$D  -v dargs="${C_DARGS}" -v callp="${MYLIBEXECPATH}/" \
        -v execloc="$_execloc" -v gateway="$_gateway" -v hwcap="$_hwcap" \
        -v hwreq="$_hwreq" -v ifname="$_ifname" -v netmask="$_netmask" \
        -v relay="$_relay" -v reloccap="$_reloccap" -v sshport=$"_sshport" \
        -v netname="$_netname" \
        -v distrel=$_distrel -v osrel=$_osrel  -v ctysrel="$_ctysrel" \
        -v uid=$_uid -v gid=$_gid \
	-v cols="$_TABARGS" \
        \
 	-f ${2} \
        \
	-v title=${t} -v titleidx=${tx}
}


function applySort () {
    if [ "$_sort" == 1 ];then
	local _mySort=sort;
	if [ "$_sortkey" -ne 0 ];then
	    [ "$_table" -eq 1 ]\
              &&_mySort="${_mySort} -t | -k ${_sortkey}"\
              ||_mySort="${_mySort} -t ; -k ${_sortkey}";
	fi
	[ "$_usort" -ne 0 ]&&_mySort="${_mySort} -u";
	[ "$_rsort" -ne 0 ]&&_mySort="${_mySort} -r";
	${_mySort}
    else
	cat
    fi
}


function generateData () {
    if [ -n "$_ctysaddr" ];then
	for i in $RESULTLST;do
	    echo "$i"|makeCtysAddr
	done
    else
	if [ "$_table" == 1 ];then
            for i in $RESULTLST;do echo "$i"; done|\
            case $_tab in
	    TAB_GEN)
		    applyFilter 0 "${MYLIBEXECPATH}/${MYCALLNAME}.d/canonize.awk"\
                    |applyFilter 0 "${MYLIBPATH}/lib/tab_gen/tab_gen.awk"\
                    |applySort
		    ;;
	    XML_GEN)
		    applyFilter 0 "${MYLIBEXECPATH}/${MYCALLNAME}.d/canonrec.awk"\
                    |applyFilter 0 "${MYLIBPATH}/lib/tab_gen/xml_gen.awk"\
                    |applySort
		    ;;
	    REC_GEN)
		    applyFilter 0 "${MYLIBEXECPATH}/${MYCALLNAME}.d/canonrec.awk"\
                    |applyFilter 0 "${MYLIBPATH}/lib/tab_gen/rec_gen.awk"\
                    |applySort
		    ;;
	    SPEC_GEN)
		    applyFilter 0 "${MYLIBEXECPATH}/${MYCALLNAME}.d/canonrec.awk"\
                    |applyFilter 0 "${MYLIBPATH}/lib/tab_gen/spec_gen.awk"\
                    |applySort
		    ;;
            esac
	else
	    for i in $RESULTLST;do echo "$i"; done\
            |applySort
	fi
    fi
}


#
#table header
#
if [ "${_title}" != 0 -o "${_titleidx}" != 0 ];then
    if [ "$_table" == 1 ];then
        case $_tab in
	    TAB_GEN)
		echo ""|applyFilter 1 "${MYLIBEXECPATH}/${MYCALLNAME}.d/canonize.awk"\
                |applyFilter 1 "${MYLIBPATH}/lib/tab_gen/tab_gen.awk";
		;;
	    XML_GEN)
		echo ""|applyFilter 1 "${MYLIBEXECPATH}/${MYCALLNAME}.d/canonrec.awk"\
                |applyFilter 1 "${MYLIBPATH}/lib/tab_gen/xml_gen.awk";
		;;
	    REC_GEN)
		echo ""|applyFilter 1 "${MYLIBEXECPATH}/${MYCALLNAME}.d/canonrec.awk"\
                |applyFilter 1 "${MYLIBPATH}/lib/tab_gen/rec_gen.awk";
		;;
	    SPEC_GEN)
		echo ""|applyFilter 1 "${MYLIBEXECPATH}/${MYCALLNAME}.d/canonrec.awk"\
                |applyFilter 1 "${MYLIBPATH}/lib/tab_gen/spec_gen.awk";
		;;
	esac
    else
	echo ""|applyFilter 1 "${MYLIBEXECPATH}/${MYCALLNAME}.d/canonize.awk";
    fi
fi

#
#do it redundant for performance
#
if [ "$_unique" == "0" ];then
    generateData
else
    if((WNG<2));then
	_res=`generateData|testUniqueOnly`
	case $_res in
	    AMBIGUOUS*)
		ABORT=11;
		printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "Query result on cache for UNIQUE key \"${_arglst}\" is $_res"
		globalExitValue=11;
		;;
	    *)[ -n "$_res" ]&&echo $_res;;
	esac
    else
	_rlst=`generateData`
	_res=`for i in $_rlst;do echo $i;done|testUniqueOnly`
	case $_res in
	    AMBIGUOUS*)
		ABORT=11;
		printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "Query result on cache for UNIQUE key \"${_arglst}\" is $_res"
                _ecnt=11;
                _ei=;
		for _ei in $_rlst;do
 		    printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "#${_ecnt} \"p:${_ei}\""
		    let _ecnt++;
		done
		globalExitValue=11;
		;;
	    *)[ -n "$_res" ]&&echo $_res;;
	esac
    fi
fi


################################
#
#POSTFIXES: some add-ons
#
if [ "$_keepRTCache" == "0" -a "$_keepAll" == "0" ];then
    rm -f ${RTCACHEDB} 2>/dev/null
else
    if [ "$C_INTERACTIVE" != 0 ];then
	printf "KEEPRTCACHE       =%s\n" ${RTCACHEDB}
	printf "RESULTWEIGHT[%03d]=%03d  $tmpHost1\n" $idx ${RESULTWEIGHT[$idx]}
    fi
fi
gotoHell ${globalExitValue}

