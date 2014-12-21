#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_09_001
#
########################################################################
#
#     Copyright (C) 2007,2008 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
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
# This version copied and adapted from the original script of
# Xen-3.0.3-25.0.4.el5 from CentOS-5.0 distribution for the
# UnifiedSessionsManager.
#
# This was neccessary, mainly due to debugging issues as an integral
# part for setting up WoL by PM, requiring a previous re-ordering
# and re-configuration of the IF targeted by WoL packets.
# Anyhow, should be obsolete, when the so called MAGIC-PACKET(TM) could be 
# set on a vif, other attributes, such as broadcast, seems to work already.
#
#
# Copyright (C) by Owners of Xen
# Copyright (C) by Owners of CentOS
#
#
# It is adapted in order of simplification of access grant for userland 
# access. For ctys the "stop" case only is required when WoL has to be 
# activated.
#
# The only supported call interface for now is:
#
#    network-bridge stop bridge=<bridge-to-stop> netdev=<netdev>
#
# This will be compatible for an immediate switch-over to the original 
# script, when preferred. For doing so the following has to be supported:
#
# 1. if appropriate: call only as root, than anthing might be ok.
# 2. if user land required:
#     a. set access bits for each PATH part of group for 
#        /etc/xen/scripts/network-bridge
#     b. assure ksu/sudo for at least:
#        ip, ifup, brctl
#
#
# Because this is just an error-workaround, for erroneous setting of "wol g"
# by ethtool, it may be removed later.
#
########################################################################
#
# Copyright (C) 2007 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
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
#  ctys-callVncserver.sh
#
#AUTHOR:
AUTHOR="Adapted from Xen by Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org"
#
#FULLNAME:
FULLNAME="Unified Sessions Manager"
#
#CALLFULLNAME:
CALLFULLNAME="network-bridge"
#
#LICENCE:
LICENCE=GPL3
#
#TYPE:
#  bash-script
#
#VERSION:
VERSION=01_09_001
#DESCRIPTION:
#  Stopper script for XenBridge.
#
#EXAMPLE:
#
#PARAMETERS:
#  see above.
#
#OUTPUT:
#  RETURN:
#    0: ok
#    1: nok
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

C_EXECLOCAL=1;

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

###################################################
#Check master hook                                #
###################################################
bootstrapCheckInitialPath
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
    *)
        printINFO 1 $LINENO $BASH_SOURCE 1 "${MYCALLNAME} is not supported on ${MYOS}"
	gotoHell 0
	;;
esac



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

. ${MYLIBPATH}/lib/security.sh
. ${MYLIBPATH}/lib/network/network.sh


#============================================================================
#
# adapted from Xen original with minor functional changes only
# added traces
#
#============================================================================
#
# Usage:
#
# network-bridge stop bridge=<bridge-name>
#
#============================================================================

printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "\$@=$@"

#
#simplified CLI arguments for internall calls
#

command=`echo " $@ "|sed -n 's/.*start .*/start/p'`
[ -z "${command// /}" ]&&command=`echo " $@ "|sed -n 's/.*stop .*/stop/p'`
[ -z "${command// /}" ]&&command=`echo " $@ "|sed -n 's/.*status .*/status/p'`
case $command in
    start|stop|status);;
    *)
	ABORT=0;
	printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "Missing command:command=<$command>"
	gotoHell ${ABORT}
	;;
esac

printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "command=${command}"

bridge=`echo " $@ "|sed -n 's/.*bridge=\([^ ]*\) .*/\1/p'`
if [ -z "$bridge" ];then
    ABORT=1;
    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing parameter:\"bridge=\""
    gotoHell ${ABORT}
fi
printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "bridge=$bridge"

netdev=`echo " $@ "|sed -n 's/.*netdev=\([^ ]*\) .*/\1/p'`

if [ -z "$netdev" ];then
    ABORT=1;
    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing parameter:\"netdev=\""
    gotoHell ${ABORT}
fi
printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "netdev=$netdev"

vifnum=`echo $@|sed -n 's/.*vifnum=\([^ ]*\) .*/\1/p'`


vifnum=${vifnum:-$(ip route list | awk '/^default / { print $NF }' | sed 's_^[^0-9]*__')}
vifnum=${vifnum:-0}
bridge=${bridge:-xenbr${vifnum}}
netdev=${netdev:-eth${vifnum}}
antispoof=${antispoof:-no}


function is_bonding() {
    [ -f "/sys/class/net/$1/bonding/slaves" ]
}



if is_bonding ${netdev}; then
    pdev="${netdev}"
    vdev="veth${vifnum}"
else
    pdev="p${netdev}"
    vdev="veth${vifnum}"
fi

vif0="vif0.${vifnum}"

printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "vifnum=$vifnum"
printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "bridge=$bridge"
printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "netdev=$netdev"
printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "antispoof=$antispoof"
printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "pdev=$pdev"
printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "vdev=$vdev"
printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "vif0=$vif0"

CTYS_IFUP=`getPathName   $LINENO $BASH_SOURCE ERROR ifup     /sbin`
CTYS_IFDOWN=`getPathName $LINENO $BASH_SOURCE ERROR ifdown   /sbin`
CTYS_IP=`getPathName     $LINENO $BASH_SOURCE ERROR ip       /sbin`
CTYS_BRCTL=`getPathName  $LINENO $BASH_SOURCE ERROR brctl    /usr/sbin`



#try a harmless call, and trust for the others
#just copy it for now from
#
# transfer_addrs
#
function setXMCALL () {
    printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=$@"
    local src=$1
    local dst=$2
    printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "src=$src dst=$dst"

    # Don't bother if $dst already has IP addresses.
    if $CTYS_IP addr show dev ${dst} | egrep -q '^ *inet ' ; then
        return
    fi
    # Address lines start with 'inet' and have the device in them.
    # Replace 'inet' with 'ip addr add' and change the device name $src
    # to 'dev $src'.
    local _call=`${CTYS_IP} addr show dev ${src//\//\\/}|sed  -n "s_  *inet  *\(.\+\)${src//\//\\/}_ \1 dev ${dst//\//\\/}_p"`
    if [ -n "${_call}" ];then
	checkedSetSUaccess  "${MYLIBEXECPATH}/ctys-xen-network-bridge.sh" XMCALL  CTYS_IP addr add ${_call}
	checkedSetSUaccess  "${MYLIBEXECPATH}/ctys-xen-network-bridge.sh" XMCALL  CTYS_IP addr del ${_call}
    fi
}
setXMCALL ${netdev} ${pdev}

#
#for now trust one for all, instead of safe-checking all
#
# checkedSetSUaccess  "${MYLIBEXECPATH}/ctys-xen-network-bridge.sh" XMCALL  CTYS_IFUP
# checkedSetSUaccess  "${MYLIBEXECPATH}/ctys-xen-network-bridge.sh" XMCALL  CTYS_IFDOWN
# checkedSetSUaccess  "${MYLIBEXECPATH}/ctys-xen-network-bridge.sh" XMCALL  CTYS_IP
# checkedSetSUaccess  "${MYLIBEXECPATH}/ctys-xen-network-bridge.sh" XMCALL  CTYS_BRCTL

CTYS_IP="$XMCALL $CTYS_IP"
CTYS_IFUP="$XMCALL $CTYS_IFUP"
CTYS_IFDOWN="$XMCALL $CTYS_IFDOWN"
CTYS_BRCTL="$XMCALL $CTYS_BRCTL"
printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "CTYS_IFUP=$CTYS_IFUP"
printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "CTYS_IFDOWN=$CTYS_IFDOWN"
printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "CTYS_IP=$CTYS_IP"
printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "CTYS_BRCTL=$CTYS_BRCTL"

function get_ip_info() {
    printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME"
    addr_pfx=`$CTYS_IP addr show dev $1 | sed -n 's_^ *inet \(.*\) [^ ]*$_\1_p'`
    printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:addr_pfx=$addr_pfx"
    gateway=`$CTYS_IP route show dev $1 | fgrep default | sed 's_default via __'`
    printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:gateway=$gateway"
}

function is_ifup() {
    $CTYS_IP link show dev $1 | awk '{ exit $3 !~ /[<,]UP[,>]/ }'
}

function do_ifup() {
    printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=$@"
    if ! $CTYS_IFUP $1 || ! is_ifup $1 ; then
        if [ ${addr_pfx} ] ; then
            # use the info from get_ip_info()
            $CTYS_IP addr flush $1
            $CTYS_IP addr add ${addr_pfx} dev $1
            $CTYS_IP link set dev $1 up
            [ ${gateway} ] && $CTYS_IP route add default via ${gateway}
        fi
    fi
}




# Usage: transfer_addrs src dst
# Copy all IP addresses (including aliases) from device $src to device $dst.
function transfer_addrs () {
    printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=$@"
    local src=$1
    local dst=$2
    printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "src=$src dst=$dst"

    local lCTYSIP=${CTYS_IP}

    # Don't bother if $dst already has IP addresses.
    if $CTYS_IP addr show dev ${dst} | egrep -q '^ *inet ' ; then
        return
    fi
    # Address lines start with 'inet' and have the device in them.
    # Replace 'inet' with 'ip addr add' and change the device name $src
    # to 'dev $src'.
    local _call=`${lCTYSIP} addr show dev ${src}|sed  -n "s_  *inet  *\(.\+\)${src//\//\\/}_${lCTYSIP//\//\\/} addr add \1 dev ${dst//\//\\/}_p"`
    if [ -n "${_call}" ];then
	callErrOutWrapper $LINENO $BASH_SOURCE ${_call}
    fi
    # Remove automatic routes on destination device
    local _call=`$lCTYSIP route list | sed -ne '
/dev '"${dst//\//\\/}"'\( \|$\)/ {
	s_^_'"${lCTYSIP//\//\\/}"' route del _
        s_$_;_
	p
	}'`
    if [ -n "${_call}" ];then
	callErrOutWrapper $LINENO $BASH_SOURCE ${_call}
    fi
}

# Usage: transfer_routes src dst
# Get all IP routes to device $src, delete them, and
# add the same routes to device $dst.
# The original routes have to be deleted, otherwise adding them
# for $dst fails (duplicate routes).
function transfer_routes () {
    printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=$@"
    local src=$1
    local dst=$2

    local lCTYSIP=${CTYS_IP}

    # List all routes and grep the ones with $src in.
    # Stick 'ip route del' on the front to delete.
    # Change $src to $dst and use 'ip route add' to add.
    local _call=`$lCTYSIP route list | sed -ne '
    /dev '"${src//\//\\/}"'\( \|$\)/ {
	    h
	    s_^_'"${lCTYSIP//\//\\/}"' route del _
        s_$_;_
	    P
	    g
	    s_'"${src//\//\\/}"'_'"${dst//\//\\/}"'_
	    s_^_'"${lCTYSIP//\//\\/}"'1 route add _
        s_$_;_
	    P
	    d
	    }'`
    if [ -n "${_call}" ];then
	callErrOutWrapper $LINENO $BASH_SOURCE ${_call}
    fi
}


##
# link_exists interface
#
# Returns 0 if the interface named exists (whether up or down), 1 otherwise.
#
function link_exists()
{
    printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=$@"
    callErrOutWrapper $LINENO $BASH_SOURCE $CTYS_IP link show "$1" >/dev/null
    if [ $? -eq 0 ];then
	printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:-------------"
	return 0
    else
	printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:--------------"
	return 1
    fi
}


# Usage: add_to_bridge bridge dev
add_to_bridge () {
    printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=$@"
    local bridge=$1
    local dev=$2

    # Don't add $dev to $bridge if it's already on a bridge.
    if [ -e "/sys/class/net/${bridge}/brif/${dev}" ]; then
	callErrOutWrapper $LINENO $BASH_SOURCE $CTYS_IP link set ${dev} up || true
	return
    fi
    callErrOutWrapper $LINENO $BASH_SOURCE $CTYS_BRCTL addif ${bridge} ${dev}
    callErrOutWrapper $LINENO $BASH_SOURCE $CTYS_IP link set ${dev} up
}

# adds $dev to $bridge but waits for $dev to be in running state first
add_to_bridge2() {
    printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=$@"
    local bridge=$1
    local dev=$2
    local maxtries=20

    echo -n "Waiting for ${dev} to negotiate link."
    callErrOutWrapper $LINENO $BASH_SOURCE $CTYS_IP link set ${dev} up
    for i in `seq ${maxtries}` ; do
	netCheckIfIs UP ${dev}
	if [ $? -eq 0 ]; then
	    break
	else
	    echo -n '.'
	    sleep 1
	fi
    done

    if [ ${i} -eq ${maxtries} ] ; then echo '(link isnt in running state)' ; fi

    add_to_bridge ${bridge} ${dev}
}

# Set the default forwarding policy for $dev to drop.
# Allow forwarding to the bridge.
antispoofing () {
    printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=$@"
    callErrOutWrapper $LINENO $BASH_SOURCE $CTYS_IPTABLES -P FORWARD DROP
    callErrOutWrapper $LINENO $BASH_SOURCE $CTYS_IPTABLES -F FORWARD
    callErrOutWrapper $LINENO $BASH_SOURCE $CTYS_IPTABLES -A FORWARD -m physdev --physdev-in ${pdev} -j ACCEPT
    callErrOutWrapper $LINENO $BASH_SOURCE $CTYS_IPTABLES -A FORWARD -m physdev --physdev-in ${vif0} -j ACCEPT
}

# Usage: create_bridge bridge
create_bridge () {
    printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=$@"
    local bridge=$1

    # Don't create the bridge if it already exists.
    if [ ! -e "/sys/class/net/${bridge}/bridge" ]; then
	callErrOutWrapper $LINENO $BASH_SOURCE $CTYS_BRCTL  addbr ${bridge}
	callErrOutWrapper $LINENO $BASH_SOURCE $CTYS_BRCTL  stp ${bridge} off
	callErrOutWrapper $LINENO $BASH_SOURCE $CTYS_BRCTL  setfd ${bridge} 0
	callErrOutWrapper $LINENO $BASH_SOURCE $CTYS_SYSCTL -w "net.bridge.bridge-nf-call-arptables=0"
	callErrOutWrapper $LINENO $BASH_SOURCE $CTYS_SYSCTL -w "net.bridge.bridge-nf-call-ip6tables=0"
	callErrOutWrapper $LINENO $BASH_SOURCE $CTYS_SYSCTL -w "net.bridge.bridge-nf-call-iptables=0"
        callErrOutWrapper $LINENO $BASH_SOURCE $CTYS_IP link set ${bridge} arp off
        callErrOutWrapper $LINENO $BASH_SOURCE $CTYS_IP link set ${bridge} multicast off
    fi

    # A small MTU disables IPv6 (and therefore IPv6 addrconf).
    mtu=$(callErrOutWrapper $LINENO $BASH_SOURCE $CTYS_IP link show ${bridge} | sed -n 's_.* mtu \([0-9]\+\).*_\1_p')
    callErrOutWrapper $LINENO $BASH_SOURCE $CTYS_IP link set ${bridge} mtu 68
    callErrOutWrapper $LINENO $BASH_SOURCE $CTYS_IP link set ${bridge} up
    callErrOutWrapper $LINENO $BASH_SOURCE $CTYS_IP link set ${bridge} mtu ${mtu:-1500}
}

function op_stop () {
    printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=$@"
    doDebug $S_BIN  ${D_BULK} $LINENO $BASH_SOURCE
    D=$?

    if [ "${bridge}" == "null" ]; then
	printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "${bridge} = null"
	return
    fi
    link_exists "$bridge"
    if [ $? -ne 0 ]; then
	printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "! link_exists ${bridge}"
	return
    fi

    link_exists "$pdev"
    if [ $? -eq 0 ]; then
	printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "link_exists ${pdev}"
	$CTYS_IP link set dev ${vif0} down
	mac=`callErrOutWrapper $LINENO $BASH_SOURCE $CTYS_IP link show ${netdev} | grep 'link\/ether' | sed -e 's_.*ether \(..:..:..:..:..:..\).*_\1_'`

	transfer_addrs ${netdev} ${pdev}
	callErrOutWrapper $LINENO $BASH_SOURCE $CTYS_IFDOWN ${netdev}
	if [ $? -ne 0 ]; then
	    callErrOutWrapper $LINENO $BASH_SOURCE get_ip_info ${netdev}
	fi
	callErrOutWrapper $LINENO $BASH_SOURCE $CTYS_IP link set ${netdev} down arp off

	callErrOutWrapper $LINENO $BASH_SOURCE $CTYS_IP link set ${netdev} addr fe:ff:ff:ff:ff:ff
	callErrOutWrapper $LINENO $BASH_SOURCE $CTYS_IP link set ${pdev} down
	callErrOutWrapper $LINENO $BASH_SOURCE $CTYS_IP addr flush ${netdev}
	callErrOutWrapper $LINENO $BASH_SOURCE $CTYS_IP link set ${pdev} addr ${mac} arp on

        if [ $D -eq 0 ];then
	    printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME"
	    echo "$LINENO----------------">&2
	    /usr/sbin/brctl show >&2
	    /sbin/ifconfig >&2
	    echo "----------------">&2
	fi
	callErrOutWrapper $LINENO $BASH_SOURCE $CTYS_BRCTL delif ${bridge} ${pdev}
	callErrOutWrapper $LINENO $BASH_SOURCE $CTYS_BRCTL delif ${bridge} ${vif0}
	callErrOutWrapper $LINENO $BASH_SOURCE $CTYS_IP link set ${bridge} down

        if [ $D -eq 0 ];then
	    printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME"
	    echo "$LINENO----------------">&2
	    /usr/sbin/brctl show >&2
	    /sbin/ifconfig >&2
	    echo "----------------">&2
	fi

	callErrOutWrapper $LINENO $BASH_SOURCE $CTYS_IP link set ${netdev} name ${vdev}
	callErrOutWrapper $LINENO $BASH_SOURCE $CTYS_IP link set ${pdev} name ${netdev}
	callErrOutWrapper $LINENO $BASH_SOURCE do_ifup ${netdev}

        if [ $D -eq 0 ];then
	    printDBG $S_BIN ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME"
	    echo "$LINENO----------------">&2
	    /usr/sbin/brctl show >&2
	    /sbin/ifconfig >&2
	    echo "----------------">&2
	fi

    else
	callErrOutWrapper $LINENO $BASH_SOURCE transfer_routes ${bridge} ${netdev}
	callErrOutWrapper $LINENO $BASH_SOURCE $CTYS_IP link set ${bridge} down
    fi
    callErrOutWrapper $LINENO $BASH_SOURCE $CTYS_BRCTL delbr ${bridge}
}



op_start () {
    printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=$@"
    if [ "${bridge}" == "null" ] ; then
	return
    fi

    if ! is_bonding ${netdev}; then
	if ! link_exists "$vdev"; then
            if link_exists "$pdev"; then
            # The device is already up.
		return
            else
		echo "
Link $vdev is missing.
This may be because you have reached the limit of the number of interfaces
that the loopback driver supports.  If the loopback driver is a module, you
may raise this limit by passing it as a parameter (nloopbacks=<N>); if the
driver is compiled statically into the kernel, then you may set the parameter
using loopback.nloopbacks=<N> on the domain 0 kernel command line.
" >&2
		exit 1
            fi
	fi
	create_bridge ${bridge}

	if link_exists "$vdev"; then
	    mac=`callErrOutWrapper $LINENO $BASH_SOURCE $CTYS_IP link show ${netdev} | grep 'link\/ether' | sed -e 's_.*ether \(..:..:..:..:..:..\).*_\1_'`
	    preiftransfer ${netdev}
	    transfer_addrs ${netdev} ${vdev}
	    if is_bonding ${netdev} || ! callErrOutWrapper $LINENO $BASH_SOURCE $CTYS_IFDOWN ${netdev}; then
  	        # Remember the IP details if necessary.
		get_ip_info ${netdev}
		callErrOutWrapper $LINENO $BASH_SOURCE $CTYS_IP link set ${netdev} down
		callErrOutWrapper $LINENO $BASH_SOURCE $CTYS_IP addr flush ${netdev}
	    fi
	    callErrOutWrapper $LINENO $BASH_SOURCE $CTYS_IP link set ${netdev} name ${pdev}
	    callErrOutWrapper $LINENO $BASH_SOURCE $CTYS_IP link set ${vdev} name ${netdev}

	    setup_bridge_port ${pdev}
	    setup_bridge_port ${vif0}
	    callErrOutWrapper $LINENO $BASH_SOURCE $CTYS_IP link set ${netdev} addr ${mac} arp on

	    callErrOutWrapper $LINENO $BASH_SOURCE $CTYS_IP link set ${bridge} up
	    add_to_bridge  ${bridge} ${vif0}
	    add_to_bridge2 ${bridge} ${pdev}
	    do_ifup ${netdev}
	else
	# old style without ${vdev}
	    transfer_addrs  ${netdev} ${bridge}
	    transfer_routes ${netdev} ${bridge}
	fi
    else
	create_bridge ${bridge}

	add_to_bridge  ${bridge} ${vif0}
	add_to_bridge2 ${bridge} ${pdev}

	# old style without ${vdev}
	transfer_addrs  ${netdev} ${bridge}
	transfer_routes ${netdev} ${bridge}
    fi


    if [ ${antispoof} = 'yes' ] ; then
	antispoofing
    fi
}



############################
#for now 
if [ -z "$command" ];then command="stop";fi
############################


case "$command" in
    start)
	op_start
	;;
    
    stop)
	op_stop
	;;

    status)
	show_status ${netdev} ${bridge}
	;;

    *)
	echo "Unknown command: $command" >&2
	echo 'Valid commands are: start, stop, status' >&2
	exit 1
esac
