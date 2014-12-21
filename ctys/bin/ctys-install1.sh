#!/bin/bash
########################################################################
#
#PROJET:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_011
#
########################################################################
#
#     Copyright (C)2007,2008,2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
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
#  ctys-install.sh
#
#AUTHOR:
AUTHOR="Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org"
#
#FULLNAME:
FULLNAME="Unified Sessions Manager - CLI-Installer - Stage-1"
#
#CALLFULLNAME:
CALLFULLNAME="ctys-install.sh"
#
#LICENCE:
LICENCE=GPL3
#
#TYPE:
#  bash-script
#
#VERSION:
VERSION=01_11_011
#DESCRIPTION:
#  Install script for ctys.
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
#
#Deactivate CTYS_INI check
#
export CTYS_INSTALLER=1;

#
#Execution anchor
MYCALLPATHNAME=$0
MYCALLNAME=`basename $MYCALLPATHNAME`
MYCALLNAME=${MYCALLNAME%.sh}
MYCALLPATH=`dirname $MYCALLPATHNAME`
if [ "${MYCALLPATH}" == "." ];then
    MYCALLPATH=${PWD}
fi
if [ -n "${MYCALLPATH##/*}" ];then
    cd "${MYCALLPATH}"
    MYCALLPATH=${PWD}
    cd -
fi


#
#If a specific library is forced by the user
#
MYLIBPATH=$(dirname ${MYCALLPATH})
CTYS_LIBPATH=${MYLIBPATH}

if [ -n "${CTYS_LIBPATH_INSTALL}" ];then
    MYLIBEXECPATHNAME=${CTYS_LIBPATH_INSTALL}/bin/${MYCALLNAME}
else
    MYLIBEXECPATHNAME=${MYCALLPATHNAME}
fi

#
#identify the actual location of the callee
#
if [ -n "${MYLIBEXECPATHNAME##/*}" ];then
    MYLIBEXECPATHNAME=${PWD}/${MYLIBEXECPATHNAME}
fi
MYLIBEXECPATH=`dirname ${MYLIBEXECPATHNAME}`

###################################################
#load basic library required for bootstrap        #
###################################################
MYBOOTSTRAP=${MYLIBEXECPATH}/bootstrap
if [ ! -d "${MYBOOTSTRAP}" ];then
    MYBOOTSTRAP=${MYCALLPATH}/bootstrap
    if [ ! -d "${MYBOOTSTRAP}" ];then
	echo "${MYCALLNAME}:$LIBDIRENO:ERROR:Missing:MYBOOTSTRAP=${MYBOOTSTRAP}"
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

MYBOOTSTRAP=${MYBOOTSTRAP}/bootstrap.01.01.004.sh
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

MYLIBPATH="$(dirname $MYCALLPATHNAME)"
if [ "$MYLIBPATH" == "." ];then
    MYLIBPATH=$PWD
fi
CTYS_LIBPATH=${MYLIBPATH}

###################################################
#Check master hook                                #
###################################################
#acue check
#bootstrapCheckInitialPath
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
#MYOPTSFILES=${MYOPTSFILES:-$_MYLIBEXECPATHNAME/help/$MYLANG/*_base_options} 
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
    FreeBSD);;
    *)
        printINFO 1 $LINENO $BASH_SOURCE 1 "${MYCALLNAME} is not supported on ${MYOS}"
	gotoHell 0
	;;
esac

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

if [ -z "${HOME}" ];then
    ABORT=1;
    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing mandatory variable:HOME"
    gotoHell ${ABORT}
fi
if [ "${HOME}" == "/" ];then
    ABORT=1;
    printERR $LINENO $BASH_SOURCE ${ABORT} "Unacceptable value:HOME=\"/\""
    printERR $LINENO $BASH_SOURCE ${ABORT} "  Your HOME must not be \"/\""
    gotoHell ${ABORT}
fi
if [ ! -d "${HOME}" ];then
    ABORT=1;
    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing mandatory directory:HOME=\"${HOME}\""
    gotoHell ${ABORT}
fi


. ${MYLIBPATH}/lib/help/help.sh

unset DOWNGRADE
unset REMOVE
unset FORCE
unset FORCEALL
unset FORCECLEAN
unset LINKONLY

function printOut ()  {
    if [ -n "$SILENT" ];then
	return
    fi
    if [ -z "$1" ];then
        echo 
	return
    fi
    echo "$*"
}

function fetchInstallOpts () {
    TEMPLATEDIR=${TEMPLATEDIR:-$HOME/ctys}
    BINDIR=${BINDIR:-$HOME/bin}
    UTILDIR=${UTILDIR:-$HOME/utils}
    SCRIPTDIR=${SCRIPTDIR:-$MYCONFPATH/scripts}


    while [ -n "${1}" ];do
	case $1 in
	    [dD][oO][cC][sS]=*)
                   DOCS=${1/*=}
                   DOCS=${DOCS//\"/}
                   ;;
	    [lL][iI][bB][dD][iI][rR]=*)
                   LIBDIR=${1/*=}
                   LIBDIR=${LIBDIR//\"/}
                   ;;
            [bB][iI][nN][dD][iI][rR]=*)
                   BINDIR=${1/*=}
                   BINDIR=${BINDIR//\"/}
		   if [ "${BINDIR}" == NONE ];then
                       BINDIR=;
		   fi
                   ;;
            [uU][tT][iI][lL][dD][iI][rR]=*)
                   UTILDIR=${1/*=}
                   UTILDIR=${UTILDIR//\"/}
                   ;;
            [sS][cC][rR][iI][tT][dD][iI][rR]=*)
                   SCRIPTDIR=${1/*=}
                   SCRIPTDIR=${SCRIPTDIR//\"/}
                   ;;
            [tT][eE][mM][pP][lL][aA][tT][eE][dD][iI][rR]=*)
                   TEMPLATEDIR=${1/*=}
                   TEMPLATEDIR=${TEMPLATEDIR//\"/}
                   ;;
            [nN][oO][cC][oO][nN][fF])
                   NOCONF=1
                   ;;
            [fF][oO][rR][cC][eE])
                   FORCE=1
                   ;;
            [vV][eE][rR][iI][fF][yY])
                   VERIFY=1
                   ;;
            [lL][iI][nN][kK][oO][nN][lL][yY])
                   LINKONLY=1
                   ;;
            [fF][oO][rR][cC][eE][aA][lL][lL])
                   FORCEALL=1
                   ;;
            [fF][oO][rR][cC][eE][cC][lL][eE][aA][nN])
                   printOut ""
                   printOut "You have choosen \"FORCECLEAN\"."
                   printOut ""
                   printOut "This will destroy ALL your present ctys-configurations by removing"
                   printOut ""
                   printOut "  \"rm -rf  $HOME/.ctys\""
                   printOut ""
                   printOut "So you require to regenerate at least your mapping databases by \"ctys-vdbgen.sh\"."
#                    printOut -n "Do you want to continue[yN]: "
#                    read NORETURN;
                   NORETURN=y;
                   case ${NORETURN} in
                         y|Y)
                           REMOVE=1
                           FORCECLEAN=1
                           ;;
                         *)
                           ABORT=0;
                           gotoHell ${ABORT}
                           ;;
                   esac
                   ;;
            [rR][eE][mM][oO][vV][eE])
                   REMOVE=1
                   ;;
            -X)
                   C_TERSE=1;
                   ;;
            version|--version|-V)
                   if [ -n "${C_TERSE}" ];then
                       echo -n ${VERSION}
                   else
                       echo "$0: VERSION=${VERSION}"
                   fi
                   gotoHell 0
                   ;;

	    '-H'|'--helpEx'|'-helpEx')shift;printHelpEx "${1:-$MYCALLNAME}";exit 0;;
            '-h'|'--help'|'-help')showToolHelp;exit 0;;
            *)
                   echo "$BASH_SOURCE:Unknown options:<$1>"
                   gotoHell 1
                   ;;
        esac
        shift
    done
    BINDIR=${BINDIR//\"}
    UTILDIR=${UTILDIR//\"}
    SCRIPTDIR=${SCRIPTDIR//\"}
}


function verify1 () {
    if [ -z "$VERIFY" ];then
	return
    fi

    echo
    echo "**************************************************************"
    echo "* You should see now various version information, from call  *"
    echo "*                                                            *"
    echo "  \${CTYSCALL} -d w:0,i:0 -v => ${CTYSCALL} -d w:0,i:0 -v"
    echo "*                                                            *"
    echo "**************************************************************"
    echo
    echo
    echo
    echo "              ###################"
    echo "              # BASIC CHECK - 1 #"
    echo "              ###################"
    echo
    echo
    ${CTYSCALL} -d w:0,i:0 -v 
    echo
    echo
    echo
    echo

    echo
    echo "**************************************************************"
    echo "*                                                            *"
    echo "* If version information is displayed above, the             *"
    echo "* installation seems to be successful and operable.          *"
    echo "*                                                            *"
    echo "* Now a call with preload of all available plugins will be   *"
    echo "* performed, this checks almost any base-requirement and     *"
    echo "* available shell resources for maximum synchronouos usage   *"
    echo "* of plugin-types.                                           *"
    echo "*                                                            *"
    echo "  \${CTYSCALL} -d w:0,i:0 -v -T all => ${CTYSCALL} -d w:0,i:0 -v -T all"
    echo "*                                                            *"
    echo "*                                                            *"
    echo "*                                                            *"
    echo "* It could exhaust some resources gwhich frequently leads     *"
    echo "* to some \"not very obviouos\" error messages.                *"
    echo "*                                                            *"
    echo "* Trust me, the syntax of the scripts might be in almost     *"
    echo "* any case not the reason!                                   *"
    echo "*                                                            *"
    echo "* Workaround is given after following call-results.          *"
    echo "*                                                            *"
    echo "**************************************************************"
    echo
    echo
    echo
    echo "              ###################"
    echo "              # BASIC CHECK - 2 #"
    echo "              ###################"
    echo
    echo
    ${CTYSCALL} -d w:0,i:0 -v -T all
    echo
    echo
    echo
    echo

    echo "**************************************************************"
    echo "*                                                            *"
    echo "* If you got some strange errors from the previous call,     *"
    echo "* your bash-environent for shell execution is probably       *"
    echo "* too small, exhausted anyhow.                               *"
    echo "*                                                            *"
    echo "* SOLUTIONs if fails:                                        *"
    echo "*                                                            *"
    echo "*  -> just use a limited number of pluging for each call,    *"
    echo "*     see options \"-t\" and \"-T\"                             *"
    echo "*                                                            *"
    echo "*  -> check your environment, e.g. with.                     *"
    echo "*        \"env|wc -c\"                                         *"
    echo "*     and reduce it(at least your exports).                  *"
    echo "*     Some kernels are limited to above 128k.                *"
    echo "*                                                            *"
    echo "*  -> use a newer with sysctl-support or a patched kernel.   *"
    echo "*                                                            *"
    echo "*  -> use an OS supporting sysctl-setting of shell-MEM.      *"
    echo "*                                                            *"
    echo "*                                                            *"
    echo "**************************************************************"
    echo
}

function verify2 () {
    if [ -z "$VERIFY" ];then
	return
    fi

    echo
    echo
    echo
    echo "**************************************************************"
    echo "*                                                            *"
    echo "* Display now the actual operational states of installed     *"
    echo "* plugins.                                                   *"
    echo "*                                                            *"
    echo "* These may change for next call, when missing prerequisites *"
    echo "* are installed, or vice versa.                              *"
    echo "*                                                            *"
    echo "**************************************************************"

    echo
    echo
    echo "**************************************************************"
    echo "*                                                            *"
    echo "* SERVER features                                            *"
    echo "*                                                            *"
    echo "**************************************************************"
    ${CTYSPLUGINS} -E -T ALL 

    echo
    echo
    echo "**************************************************************"
    echo "*                                                            *"
    echo "* CLIENT features                                            *"
    echo "*                                                            *"
    echo "**************************************************************"
    ${CTYSPLUGINS} -T ALL 

    gwhich ctys 2>/dev/null >/dev/null
    if [ $? -ne 0 ];then
	echo
	echo "#########################################################"
	echo "#                                                       #"
	echo "#  WARNING: Don't forget to update your PATH variable:  #"
	echo "#                                                       #"
	echo "#########################################################"
	echo "#                                                       #"
	echo "#  add:PATH=\${PATH}"
	echo "#  add:PATH=\${PATH}:\${BINDIR}"
	echo "#  add:PATH=\${PATH}:\${UTILDIR}"
	echo "#  add:PATH=\${PATH}:\${CTYS_SCRIPT_PATH}"
	echo "#                                                       #"
	echo "#########################################################"
	echo "#                                                       #"
	echo "#  For SSHD you might require some configuration.       #"
	echo "#  For further information refer to \"sshd_config\"       #"
	echo "#  and \"ssh_config\"                                     #"
	echo "#                                                       #"
	echo "#  - \$HOME/ssh/environment                             #"
	echo "#    PATH=<expanded-PATH-no-vars>                       #"
	echo "#  - in /etc/ssh/sshd_conf                              #"
	echo "#    \"PermitUserEnvironment yes\"                        #"
	echo "#                                                       #"
	echo "#  Alternative:                                         #"
	echo "#  - in /etc/ssh/ssh_conf                               #"
	echo "#    \"SendEnv yes\"                                      #"
	echo "#  - in /etc/ssh/sshd_conf                              #"
	echo "#    \"AcceptEnv yes\"                                    #"
	echo "#                                                       #"
	echo "#                                                       #"
	echo "#########################################################"
	echo
	splitPath 10 "  PATH" "$PATH";
	echo
	echo "#########################################################"
	echo
	checkPathElements  PATH   "$PATH";
	echo
    else
	echo
	echo "OK, ctys could be accessed by \$PATH search."
	echo
    fi

    echo
    echo
    echo "#########################################################"
    echo
    echo "Do not forget to change your VNC password with \"vncpasswd\""
    echo
    echo "#########################################################"
    echo
    echo
}



fetchInstallOpts ${*//,/ }

if [ -z "${LIBDIR}" ];then
    if [ -n "${LINKONLY}" ];then
	LIBDIR="${MYLIBPATH}"
    else
	LIBDIR=$HOME/lib
	LIBDIR0=$LIBDIR
	LIBDIR="${LIBDIR}/ctys-$(${MYCALLPATH}/getCurCTYSRel.sh)";

        #Set link for add-on installs by unpack-only
	LIBDIRlnk="$(${MYCALLPATH}/getCurCTYSRel.sh)";
	LIBDIRlnk="${LIBDIRlnk//_/.}";
	LIBDIRlnk="${LIBDIR0}/ctys-${LIBDIRlnk}";
    fi
fi

LIBS=${LIBDIR};
printDBG $S_BIN ${D_UI} $LINENO $BASH_SOURCE "LIBS    = <${LIBS}>"
UTILS1="${UTILDIR}/bootstrap"
printDBG $S_BIN ${D_UI} $LINENO $BASH_SOURCE "UTILS1  = <${UTILS1}>"
VERSGEN="${LIBS}/conf/ctys/versinfo.gen.sh";
printDBG $S_BIN ${D_UI} $LINENO $BASH_SOURCE "VERSGEN = <${VERSGEN}>"
BIN1="${BINS1}/$(basename ${MYBOOTSTRAP})"
printDBG $S_BIN ${D_UI} $LINENO $BASH_SOURCE "BIN1    = <${BIN1}>"
DOCDIR=${DOCDIR:-$LIBS/doc}
printDBG $S_BIN ${D_UI} $LINENO $BASH_SOURCE "DOCDIR  = <${DOCDIR}>"
HELPDIR=${HELPDIR:-$LIBS/help}
printDBG $S_BIN ${D_UI} $LINENO $BASH_SOURCE "HELPDIR = <${HELPDIR}>"

if [ -z "${MANDIR}" ];then
    for imp in ${DOCDIR}/*/man;do
	MANDIR="${MANDIR}:${imp}"
    done
fi
printDBG $S_BIN ${D_UI} $LINENO $BASH_SOURCE "MANDIR  = <${MANDIR}>"

if [ -n "${BINDIR}" ];then
    BINS1="${BINDIR}/bootstrap"

    CTYSCALL="${BINDIR}/ctys.sh"
    CTYSPLUGINS="${BINDIR}/ctys-plugins.sh"

    LNKLSTBIN=;

    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/checkCLIDialogue.sh"

    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/ctys.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/ctys-attribute.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/ctys-beamer.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/ctys-callVncserver.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/ctys-callVncviewer.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/ctys-createConfVM.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/ctys-cloneVM.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/ctys-config.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/ctys-distribute.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/ctys-dnsutil.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/ctys-extractARPlst.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/ctys-extractMAClst.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/ctys-genmconf.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/ctys-getMasterPid.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/ctys-getNetInfo.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/ctys-groups.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/ctys-install.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/ctys-install1.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/ctys-macros.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/ctys-macmap.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/ctys-plugins.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/ctys-scripts.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/ctys-setversion.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/ctys-setupVDE.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/ctys-smbutil.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/ctys-testutils.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/ctys-vdbgen.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/ctys-vboxutils.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/ctys-vhost.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/ctys-vmw2utils.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/ctys-vping.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/ctys-wakeup.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/ctys-xdg.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/ctys-xen-network-bridge.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/getCPUinfo.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/getCurArch.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/getCurCTYSRel.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/getCurCTYSVariant.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/getCurDistribution.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/getCurGID.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/getCurOS.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/getCurOSRel.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/getCurRelease.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/getCurWM.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/getCurWMID.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/getFSinfo.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/getGeometry.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/getHDDinfo.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/getHDDtemp.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/getMEMinfo.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/getPerfIDX.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/getSolarisUUID.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/getVMinfo.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/pathlist.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/gnome-starter.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/gnome-terminal-msg.sh"
    LNKLSTBIN="$LNKLSTBIN ${BINDIR}/stripIt.sh"
fi
printDBG $S_BIN ${D_UI} $LINENO $BASH_SOURCE "LNKLSTBIN = <${LNKLSTBIN}>"

LNKLSTUTIL="${UTILDIR}/ctys-distBuild.sh"
LNKLSTUTIL="${LNKLSTUTIL} ${UTILDIR}/ctys-distBuild.d"

CTYSTEMPLATES="${TEMPLATEDIR}"
CTYSTEMPLATESINST="${LIBS}/ctys"

#
#ctys configuration files
#
CTYSCONF="${HOME}/.ctys"
CTYSCONFINST="${LIBS}/conf/ctys"


#
#top configuration files
#
TOPCONF="${HOME}/.toprc"
TOPCONFINST="${LIBS}/conf/toprc"

#
#vnc configuration files
#
VNCCONF="${HOME}/.vnc"

case ${MYDIST} in
    Ubuntu)
	VNCCONFINST="${LIBS}/conf/vnc-Ubuntu"
	;;
    OpenBSD)
	VNCCONFINST="${LIBS}/conf/vnc-OpenBSD"
	;;
    OpenSolaris)
	VNCCONFINST="${LIBS}/conf/vnc-OpenSolaris"
	;;
    *)
	VNCCONFINST="${LIBS}/conf/vnc"
	;;
esac


if [ -n "$REMOVE" -a -z "$FORCECLEAN" ];then
    gotoHell 0
fi


#######
#create
#######
printOut ""
printOut "Check installed vs. new version"
printOut ""
NEWVER=`${MYLIBEXECPATH}/ctys.sh -X -V -d w:0,i:0`
if [ $? -ne 0 ];then
    printOut "  Cannot get number from installed version"
    if [ -n "${FORCE}" -o -n "${FORCEALL}" -o -n "${FORCECLEAN}" ];then
	printOut "  Anyhow, FORCE is set, thus kill it blindly."
        printOut ""
	NEWVER=;
    else
	printOut "  For procedure  use a FORCE flag, meanwhile terminate installation for safety."
    fi
fi

if [  -n "${BINDIR}" -a -d "${BINDIR}" -a -f "${BINDIR}/ctys.sh" ];then
    if [ -f "${VERSGEN}" ];then
	OLDVER=`cat ${VERSGEN}|sed -n 's/^CTYSREL="\([^"][^"]*\)"/\1/p'`
    else
	OLDVER=;
    fi

    printOut "  Will be installed if following is true:"
    printOut ""
    printOut "    installed:\"${OLDVER}\" =< new:\"$NEWVER\""
    printOut ""
    printOut "  OR one of force-flags is set."
else
    OLDVER=;
    printOut "  not yet installed => install new:$NEWVER"
fi


######
#clean config
######
if [ -n "$REMOVE" ];then
    if [ -d "${LIBS}" ];then    
#	cd ${LIBDIR}
        echo
        echo "You are going to delete:"
        echo
	[ -z "${LINKONLY}" ]&&echo " LIBS        = ${LIBS}"
        for L in $LNKLSTBIN $LNKLSTUTIL;do
	    echo " SYMLNK      = ${L}"
	done
        echo
        echo " BOOTSTRAP has to be deleted manually."
        echo "   BOOTSTRAP = ${BIN1}"
        echo
        echo " Has to be deleted manually:"
        echo
        echo "   CTYSCONF       = ${CTYSCONF}"
        echo "   CTYSTEMPLATES  = ${CTYSTEMPLATES}"
        echo "   VNCCONF        = ${VNCCONF}"
        echo
#        echo -n "Do you want to continue:[yYnN]"&&read X
	X=y;
        case $X in
	    y|Y)
		echo
		echo "*******************************************************"
		echo
		echo "Files within runtime installation are not checked"
		echo "for modification."
                echo
		echo "You should be sure to have backups of custom plugins."
 		echo
		echo "*******************************************************"
 		echo
#		echo -n "Do you want still to continue? [yYnN]"&&read X2
		X2=y;
		case $X2 in
		    y|Y)
			echo
			echo "OK, this is the point of no return - now."
			echo
			[ -z "${LINKONLY}" ]&&rm -rf ${LIBS}
			rm -f ${LNKLSTBIN} ${LNKLSTUTIL}
			;;
		esac
		;;
	    n|N)
                gotoHell 0
		;;
        esac
    else
	echo "No libs($LIBS) installed, seems to be removed already."
    fi
fi


######
#clean templates
######
if [ -n "$REMOVE" ];then
    if [ -z "${CTYSTEMPLATES}" ];then    
	printOut "Suppress of install for libs($CTYSTEMPLATES)"
    else
	if [ -n "${CTYSTEMPLATES}" -a -d "${CTYSTEMPLATES}" ];then    
	    echo
	    echo "You are going to delete:"
	    echo
	    echo "   TEMPLATES = ${CTYSTEMPLATES}"
	    echo
#            echo -n "Do you want to continue:[yYnN]"&&read X
	    X=y;
	    case $X in
		y|Y)
		    echo
		    echo "*******************************************************"
		    echo
		    echo "Files are not checked for modification."
		    echo
		    echo "You should be sure to have backups if so."
 		    echo
		    echo "*******************************************************"
 		    echo
#		    echo -n "Do you want still to continue? [yYnN]"&&read X2
		    X2=y;
		    case $X2 in
			y|Y)
			    echo
			    echo "OK, this is the point of no return - now."
			    echo
			    rm -rf "${CTYSTEMPLATES}"
			    ;;
		    esac
		    ;;
		n|N)
		    gotoHell 0
		    ;;
	    esac
	else
	    echo "No libs($CTYSTEMPLATES) installed, seems to be removed already."
	fi
    fi
fi

if [ -L "${LIBDIR}" ];then
    rm -f "${LIBDIR}"
fi


if [ -L "${LIBDIRlnk}" ];then
    rm -f "${LIBDIRlnk}"
fi


if [ ! -d "${LIBDIR}" ];then
    mkdir -p "${LIBDIR}"
    if [ ! -d "${LIBDIR}" ];then
	ABORT=1;
	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing mandatory directory:LIBDIR=\"${LIBDIR}\""
	gotoHell ${ABORT}
    fi
fi

if [ -n "${BINDIR}" -a ! -d "${BINDIR}" ];then
    mkdir -p "${BINDIR}"
    if [ ! -d "${BINDIR}" ];then
	ABORT=1;
	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing mandatory directory:BINDIR=\"${BINDIR}\""
	gotoHell ${ABORT}
    fi
fi

if [ ! -d "${UTILDIR}" ];then
    mkdir -p "${UTILDIR}"
    if [ ! -d "${UTILDIR}" ];then
	ABORT=1;
	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing mandatory directory:UTILDIR=\"${UTILDIR}\""
	gotoHell ${ABORT}
    fi
fi

if [ ! -d "${SCRIPTDIR}" ];then
    mkdir -p "${SCRIPTDIR}"
    if [ ! -d "${SCRIPTDIR}" ];then
	ABORT=1;
	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing mandatory directory:SCRIPTDIR=\"${SCRIPTDIR}\""
	gotoHell ${ABORT}
    fi
fi

if [ -n "${TEMPLATEDIR}" -a ! -d "${TEMPLATEDIR}" ];then
    mkdir -p "${TEMPLATEDIR}"
    if [ ! -d "${TEMPLATEDIR}" ];then
	ABORT=1;
	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing mandatory directory:TEMPLATEDIR=\"${TEMPLATEDIR}\""
	gotoHell ${ABORT}
    fi
fi


######
#clean libraries
######
if [ -n "$REMOVE" -a  -z "${LINKONLY}" ];then
    rm -rf "${LIBS}"
fi

######
#clean symbolic links
######
if [ -n "$REMOVE" ];then
    for L in $LNKLSTBIN $LNKLSTUTIL;do
	rm -f ${L}
    done
fi


printOut ""
printOut ""
printOut "**************************************************************"
printOut "*                                                            *"
printOut "* Runtime executables and symbolic links.                    *"
printOut "*                                                            *"
printOut "**************************************************************"
printOut ""

if [ -z "${OLDVER}"  -o "${NEWVER}" \> "${OLDVER}" -o -n "${FORCE}" -o -n "${FORCEALL}" -o -n "${FORCECLEAN}" ];then
    printOut "install now libraries..."

    if [ -z "${LINKONLY}" ];then
	printOut "install MYLIBPATH = ${MYLIBPATH}";  
	printOut "to      LIBS      = ${LIBS}";  
	printOut "        LIBDIR    = ${LIBDIR}";  
	printOut "";  
	install -d ${LIBDIR}; 

	LIBS=${LIBS//\"};
	LIBTMP=${LIBS%/*}
	LIBDIR=${LIBDIR//\"};
	MYLIBPATH=${MYLIBPATH//\"};

	case "$DOCS" in
	    0)
                #Quick...
		cp ${CPR} ${MYLIBPATH} ${LIBTMP}
		find ${LIBTMP} -type f \( -name '*.pdf' -o -name '*.html' -o -name '*.png'   \) -exec rm {} \;
		    ;;
	    1)
		cp ${CPR} ${MYLIBPATH} ${LIBTMP}
		;;
	    2)
                #Quick...
		mkdir ${LIBTMP}/$(basename ${MYLIBPATH})
		cp ${CPR} ${MYLIBPATH}/doc ${LIBTMP}/$(basename ${MYLIBPATH})
		;;
	    *)
		cp ${CPR} ${MYLIBPATH} ${LIBTMP}
		;;
	esac

        TMPNAME=${MYLIBPATH##*/}
        NEWNAME=${LIBS##*/};
	if [ -e "${LIBS}" -a "${TMPNAME}" != "${NEWNAME}" ];then
	    echo "Replace previous \"${TMPNAME}\""
	    rm -rf "${LIBS}"
	    echo "by \"${NEWNAME}\""
	    mv ${LIBTMP}/${TMPNAME} ${LIBS};
	fi

    fi

    if [ -n "${BINDIR}" ];then
	if [ -n "${LINKONLY}" ];then
	    printOut "BOOTSTRAP has to be installed in case of LINKONLY too.";
	fi
	printOut "install now bootstrap base..."

	printOut "install BOOTSTRAP = ${MYBOOTSTRAP}";
	printOut "to      =>${BINS1}";
	install -d ${BINS1}     
	cp ${CPR} ${MYBOOTSTRAP%/*}/* ${BINS1}

	printOut "";  

	printOut "install BOOTSTRAP = ${MYBOOTSTRAP}";
	printOut "to      => ${UTILS1}";
	install -d ${UTILS1}
	cp ${CPR} ${MYBOOTSTRAP%/*}/* ${UTILS1}

	printOut 
	for L in ${LNKLSTBIN};do
	    L0=${LIBS}/bin${L#$BINDIR};
	    L0=${L0//\"};
	    L1=${L//\"};

	    printOut "update symbolic link: ${L1}"

	    rm -f "${L1}"
	    printOut " ->ln -s ${L0} ${L1}"
	    ln -s "${L0}" "${L1}"

	    rm -f "${L1%.sh}"
	    printOut " ->ln -s ${L0} ${L1%.sh}"
	    ln -s "${L0}" "${L1%.sh}"
	done
	for L in ${LNKLSTUTIL};do
	    L0=${LIBS}/bin${L#$UTILDIR};
	    L0=${L0//\"};
	    L1=${L//\"};

	    printOut "update symbolic link: ${L1}"

	    rm -f "${L1}"
	    printOut " ->ln -s ${L0} ${L1}"
	    ln -s "${L0}" "${L1}"

	    rm -f "${L1%.sh}"
	    printOut " ->ln -s ${L0} ${L1%.sh}"
	    ln -s "${L0}" "${L1%.sh}"
	done
    fi
fi


#
#put self-starter for shared-no-install services in place
#



if [ -z "$BINDIR" ];then
    printOut ""
    printOut ""
    printOut "**************************************************************"
    printOut "*                                                            *"
    printOut "* Use \"-P\" option of type \"Linkonly\" for final runtime       *"
    printOut "* configuration.                                             *"
    printOut "*                                                            *"
    printOut "* Finish - Installed only.                                   *"
    printOut "*                                                            *"
    printOut "**************************************************************"
    printOut ""
    gotoHell 0
fi

case ${MYOS} in
    SunOS)
	printOut ""
	printOut ""
	printOut "**************************************************************"
	printOut "*                                                            *"
	printOut "* Adapt system binaries.                               *"
	printOut "*                                                            *"
	printOut "**************************************************************"
	printOut ""
	ln -sf $(gwhich gsed) ${BINDIR}/sed
	;;
esac

printOut ""
printOut ""
printOut "**************************************************************"
printOut "*                                                            *"
printOut "* Final runtime configuration.                               *"
printOut "*                                                            *"
printOut "**************************************************************"
printOut ""

if [ -z "${OLDVER}"  -o "${NEWVER}" \> "${OLDVER}" -o -n "${FORCE}" -o -n "${FORCEALL}" -o -n "${FORCECLEAN}" ];then

    if [ -n "${LINKONLY}" ];then
	printOut "Configuration will be installed in case of LINKONLY too.";
        printOut ""
    fi


    if [ -z "${CTYSTEMPLATES}" ];then 
	printOut "no templates to be installed."
	printOut "  default is located at \"${CTYSTEMPLATESINST}\""
    else
	printOut "install ${CTYSTEMPLATES} directory, if not yet present..."
	if [ ! -d "${CTYSTEMPLATES}" ];then 
	    cp ${CPR} "${CTYSTEMPLATESINST//\"}" "${CTYSTEMPLATES//\"}"; 
	else
	    if [ -n "${FORCEALL}" ];then
		printOut "  ...already present, but will be backuped to:${CTYSTEMPLATES}.bak.${DATETIME}"
		mv "${CTYSTEMPLATES//\"}" "${CTYSTEMPLATES//\"}.bak.${DATETIME}"
		cp  ${CPR} "${CTYSTEMPLATESINST//\"}" "${CTYSTEMPLATES//\"}"; 
	    else
		if [ -n "${FORCECLEAN}" ];then
		    printOut "  ...already present, but will be removed due to FORCEALL flag."
		    rm -rf "${CTYSTEMPLATES//\"}"
		    cp ${CPR} "${CTYSTEMPLATESINST//\"}" "${CTYSTEMPLATES//\"}"; 
		else
		    printOut "  ...already present, so kept untouched."
		    printOut "  Default is located at \"${CTYSTEMPLATESINST}\""
		fi
	    fi
	fi
    fi

    if [ -n "${NOCONF}" ];then 
	printOut "no individual configuration to be installed."
	printOut "  default is located at \"${LIBS}/conf/ctys\""
    else
	printOut "install ${CTYSCONF} directory, if not yet present..."
	if [ ! -d "${CTYSCONF}" ];then 
	    cp ${CPR} "${CTYSCONFINST//\"}" "${CTYSCONF//\"}"; 
	else
	    if [ -n "${FORCEALL}" ];then
		printOut "  ...already present, but will be backuped to:${CTYSCONF}.bak.${DATETIME}"
		mv "${CTYSCONF}" "${CTYSCONF//\"}.bak.${DATETIME}"
		cp  ${CPR} "${CTYSCONFINST//\"}" "${CTYSCONF//\"}"; 
	    else
		if [ -n "${FORCECLEAN}" ];then
		    printOut "  ...already present, but will be removed due to FORCEALL flag."
		    rm -rf "${CTYSCONF}"
		    cp ${CPR} "${CTYSCONFINST//\"}" "${CTYSCONF//\"}"; 
		else
		    printOut "  ...already present, so kept untouched."
		    printOut "  Default is located at \"${LIBS}/conf/ctys\""
		fi
	    fi
	fi

	printOut "install $HOME/.vnc directory, if not yet present..."
	if [ ! -d "${VNCCONF}" ];then 
	    cp ${CPR} "${VNCCONFINST//\"}" "${VNCCONF//\"}";
	else
	    printOut "  ...already present, so kept untouched."
	    printOut "  Default is located at \"${VNCCONFINST}\""
	fi

	printOut "install $HOME/.toprc, if not yet present..."
	if [ ! -d "${TOPCONF}" ];then 
	    cp ${CPR} "${TOPCONFINST//\"}" "${TOPCONF//\"}"; 
	else
	    printOut "  ...already present, so kept untouched."
	    printOut "  Default is located at \"${TOPCONFINST}\""
	fi
    fi
else
    printOut "The installed version seems to be up to date."
    printOut " -> use \"force\" or \"forceall\" for installing this version"
    printOut " -> \"remove\" for old version"
    gotoHell 0
fi



printOut ""
printOut "Update generic data:"
printOut " for \"${MYINSTALLPATH}\""
printOut " -> \"${VERSGEN}\""

#LOC
LOC=`find ${MYINSTALLPATH} -type f -name '*[!~]'  -name '[!0-9][!0-9]*' -exec cat {} \;|wc -l`

#LOC-NET
LOCNET=`find ${MYINSTALLPATH} -type f -name '*[!~]'  -name '[!0-9][!0-9]*' -exec cat {} \;|sed -n '/^ *#.*/d;/^$/d;p'|wc -l`

#LOD -Lines-Of-Documentation
#Generated during install:
#LOD=`find ${MYINSTALLPATH} -type f -name '*[!~]'  -name '[0-9][0-9]*' -exec cat {} \;|wc -l`


INSTVERSION=$(${MYCALLPATH}/getCurCTYSRel.sh)


if [ -e "${MYLIBPATH}/INTERNAL" ];then
    INSTVARIANT=INTERNAL
else
    if [ -e "${MYLIBPATH}/ALL" ];then
	INSTVARIANT=ALL
    else
	if [ -e "${MYLIBPATH}/DOC" ];then
	    INSTVARIANT=DOC
	else
	    if [ -e "${MYLIBPATH}/BASE" ];then
		INSTVARIANT=BASE
	    else

		INSTVARIANT=$(${MYCALLPATH}/getCurCTYSVariant.sh)
	    fi
	fi
    fi
fi

LOD1=`find ${MYINSTALLPATH}/help ${MYINSTALLPATH}/doc -type f -name '*[!~]'  -exec cat {} \;|wc -l`

MYDOCSOURCE="`dirname ${MYINSTALLPATH}`/ctys-manual.${INSTVERSION}"
if [ ! -d "${MYDOCSOURCE}" ];then
    MYDOCSOURCE=;
    if [ -f "${MYDOCSOURCE}" ];then
	LOD2=`wc -l ${MYDOCSOURCE}`
    else
	LOD2=0;
    fi
else
    LOD2=`find ${MYDOCSOURCE} -type f -name '*.tex'  -exec cat {} \;|wc -l`
fi

LOD=$((LOD1+LOD2));

VERSGEN=${VERSGEN//\"}
echo "###">"${VERSGEN}"
echo "DATE=${DATE}">>"${VERSGEN}"
echo "TIME=${TIME}">>"${VERSGEN}"
echo "###">>"${VERSGEN}"
echo "LOC=\"${LOC// }\"">>"${VERSGEN}"
echo "LOCNET=\"${LOCNET// }\"">>"${VERSGEN}"
echo "LOD=\"${LOD// }\"">>"${VERSGEN}"
echo "VERSION=\"${INSTVERSION}\"">>"${VERSGEN}"
echo "CTYSREL=\"${INSTVERSION}\"">>"${VERSGEN}"
echo "CTYSVARIANT=\"${INSTVARIANT}\"">>"${VERSGEN}"


if [ -n "${NOCONF}" ];then 
    printOut "no individual PATH adaption, has to be set manually."
else
    #establish PATH for search, bash-only
    printOut ""
    printOut "Check call environment:"
    if [ -n "${FORCE}" -o -n "${FORCEALL}" -o -n "${FORCECLEAN}" ];then
	printOut ""
	printOut "Force-flag set => append \"${BINDIR}\" to PATH in..."

	FNAME=;
	if [ -f ${HOME}/.bashrc ];then
	    FNAME=${HOME}/.bashrc
	    printOut "Setting:$(setSeverityColor INF ' "$HOME/.bashrc"')."
	else
	    printOut "$(setSeverityColor WNG '***************************************')"
	    printOut "ATTENTION:Missing .bashrc"
	    printOut "$(setSeverityColor ERR ' "$HOME/.bashrc"'), this may cause errors of type:"
	    printOut "$(setSeverityColor WNG 'Variable not yet set:CTYS_INI')"
	    printOut "$(setSeverityColor TRY 'At least provide an empty file.')"
	    printOut "$(setSeverityColor WNG '***************************************')"
	fi

	if [ -f ${HOME}/.bash_profile ];then
	    FNAME="${FNAME} ${HOME}/.bash_profile"
	    printOut "Setting:$(setSeverityColor INF ' "$HOME/.bash_profile"')."
	else
	    if [ -z "${FNAME}" ];then
		printOut "$(setSeverityColor WNG '***************************************')"
		printOut "ATTENTION:Missing .bash_profile"
		printOut "$(setSeverityColor WNG ' "$HOME/.bash_profile"'), this may later cause errors of type:"
		printOut "$(setSeverityColor WNG 'Variable not yet set:CTYS_INI')"
		printOut "$(setSeverityColor TRY 'At least provide an empty file.')"
		printOut "$(setSeverityColor WNG '***************************************')"
	    else
		printOut "Missing:$(setSeverityColor WNG ' "$HOME/.bash_profile"')"
	    fi
	fi
	if [ -f ${HOME}/.profile ];then
	    FNAME="${FNAME} ${HOME}/.profile"
	    printOut "Setting:$(setSeverityColor INF ' "$HOME/.profile"')"
	fi

	if [ -z "${FNAME}" ];then
	    FNAME=${HOME}/.profile
	    printOut "...\"bash\" shell is supported only, force creation of \"$FNAME\""
	    printOut "check your PATH for \"$HOME/bin\" manually."
	    touch ${FNAME}
	fi

	for fn in ${FNAME}; do
	    printOut "...in \"${fn}\""

	    printOut "-> Clear history in \"${fn}\""
	    case ${MYOS} in
		Linux)
		    sed -i '/###CTYS-BASHRCGEN-BEG/,/###BASHRCGEN-END/d' "${fn}"
		    ;;
#		SunOS|FreeBSD|OpenBSD)
		*)
		    mv ${fn} ${fn}.$$.tmp
		    sed '/###CTYS-BASHRCGEN-BEG/,/###BASHRCGEN-END/d' "${fn}.$$.tmp" > ${fn}
		    rm ${fn}.$$.tmp
		    ;;
	    esac
	    echo "###CTYS-BASHRCGEN-BEG">>"${fn}"
	    echo "#">>"${fn}"
	    echo "#generated by \"${MYCALLNAME}\"">>"${fn}"
	    echo "#">>"${fn}"
	    echo "if [ -z \"\${CTYS_INI}\" ];then">>"${fn}"
	    case ${MYOS} in
		SunOS)
		    _myPATH=${BINDIR}:${UTILDIR}:${CTYS_SCRIPT_PATH}:/usr/xpg4/bin:/opt/sfw/bin:$PATH;
		    echo "  PATH=${BINDIR}:${UTILDIR}:${CTYS_SCRIPT_PATH}:/usr/xpg4/bin:/opt/sfw/bin:\$PATH">>"${fn}"
		    ;;
		*)
		    _myPATH=${BINDIR}:${UTILDIR}:${CTYS_SCRIPT_PATH}:$PATH;
		    echo "  PATH=${BINDIR}:${UTILDIR}:${CTYS_SCRIPT_PATH}:\$PATH">>"${fn}"
		    ;;
	    esac
	    echo "  MANPATH=${MANDIR}:\${MANPATH};export MANPATH">>"${fn}"
	    echo "  CTYS_LIBPATH=${LIBS};export CTYS_LIBPATH;">>"${fn}"
	    echo "  CTYS_INI=1;export CTYS_INI">>"${fn}"
	    echo "fi">>"${fn}"
	    echo "#">>"${fn}"
	    echo "###CTYS-BASHRCGEN-END">>"${fn}"
	done

	if [ ! -e ${HOME}/.ssh ];then
	    echo "  Create missing directoy \"${HOME}/.ssh\""
	    mkdir ${HOME}/.ssh
	fi
	echo "  Append to \"${HOME}/.ssh/environment\""
	echo "PATH=${_myPATH}">>"${HOME}/.ssh/environment"
	PATH=${_myPATH}

    else
	printOut "...a force-flag required."
    fi
fi


#Set link for add-on installs by unpack-only
if [ -d "$LIBDIR" ];then
   if [ -L "$LIBDIRlnk" ];then
       rm -f "$LIBDIRlnk"
   fi 
   ln -s "$LIBDIR" "$LIBDIRlnk"
fi



if [ -n "$VERIFY" ];then
    printOut ""
    printOut ""
    printOut ""
    printOut "**************************************************************"
    printOut "**************************************************************"
    printOut "*                                                            *"
    printOut "* Installation finished, now some basic execution tests are  *"
    printOut "* perfomed, check expected output.                           *"
    printOut "*                                                            *"
    printOut "**************************************************************"
    printOut "**************************************************************"
    printOut ""
    printOut ""
fi
verify1
verify2




if [ -n "$SILENT" ];then
    gotoHell 0
fi


cat <<EOF 


#######################################################################
#                                                                     #
# HINT: Using the "Unified Sessions Manager" demands a Sigle-Sign-On  #
#       environment for frequently required SSH remote calls.         #
#                                                                     #
#       Kerberos and OpenSSH keys are supported.                      #
#                                                                     #
#######################################################################


Try help first:  "ctys -h"
   
EOF


printOut "$(setSeverityColor TRY 'HINT:')"
printOut "If you want to $(setSeverityColor TRY ' deactivate specific plugins')"
printOut "check the file $(setSeverityColor TRY ' "ctys.conf.sh"')"
printOut "for variables:$(setSeverityColor TRY '"export <plugin-type>_IGNORE=1"')"
printOut "But $(setSeverityColor WNG ' review dependencies') before, "
printOut "$(setSeverityColor INF 'e.g. CLI, X11, and VNC are required by QEMU/KVM and XEN.')"
printOut "$(setSeverityColor INF 'RDP is required by VBOX.')"

