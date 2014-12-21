#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@users.sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_011
#
########################################################################
#
# Copyright (C) 2007,2008,2009,2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

########################################################################
#
#     Copyright (C) 2007,2008,2009,2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
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
printDBG $S_CONF  ${D_FRAME} $LINENO $BASH_SOURCE "C_EXECLOCAL=${C_EXECLOCAL}"

#protect multiple inclusion
if [ -z "$__QEMU_INCLUDED__" ];then
__QEMU_INCLUDED__=1

#Extend this when required, 
#e.g. PATH=${PATH}:/usr/sbin


#
#Base path, where the qemu packages for initial tests are stored.
QEMU_BASE=${QEMU_BASE:-$HOME/qemu}


###############################################################
#
#Resolution priority for actual default-executable.
#
# 1.) Check preset QEMUKVM
# 2.) Check preset QEMU
# 3.) Search each of QEMU_EXELIST from-left-to-right
#     either absolut - when provided - or relative
#     by QEMU_PATHLIST from-left-to-right.
# 4.) The result is a QEMU_EXELIST with actual available 
#     FQN only. This list is cleared from members of the
#     QEMU_BLACKLIST.
#
#
#The order of QEMUKVM and QEMU resolution could be varied
#by following additional variables.
#
################################################################


#
#QEMU blacklist, contains non-emulator support tools.
#QEMU_BLACKLIST is not applied to QEMU and QEMUKVM
QEMU_BLACKLIST=${QEMU_QEMU_BLACKLIST:-/usr/bin/qemu-io:/usr/bin/qemu-img};


#
#Colon seperated list of PATH for enumeration of available QEMU executables
#When this is not set, the following default checks define the resulting
#PATH location for additional search and resolution.
QEMU_PATHLIST=${QEMU_PATHLIST:-/opt/qemu/bin:/opt/vde/bin:/usr/libexec:/usr/local/bin:/usr/bin};


#
#Colon seperated list of executables for specific QEMU versions
#This list is enumerated when empty only, else it is kept as given.
#The members could be either FQNs or just executables, which 
#than is resolbed.
QEMU_EXELIST=;


#
#Colon seperated list of executables for specific QEMU versions
#to be prepended to the QEMU_EXELIST. Thus this could be used
#to blacklist specific default entries by prepending them with 
#their FQN.
QEMU_EXELIST_PREPEND=${QEMU_EXELIST_PREPEND:-qemu-kvm:kvm:qemu};


if [ -n "$C_EXECLOCAL" ];then
    [ -z "$CTYS_SETUPVDE" ]&&CTYS_SETUPVDE=`getPathName $LINENO $BASH_SOURCE ERROR ctys-setupVDE.sh ${MYLIBEXECPATH}`

    #
    #Can do this with any user, so sould be the same for the following
    #access-permissions too.
    #
    case ${MYARCH// /} in
	amd64|x86_64)
	    [ -z "$QEMUBASE" ]&&QEMUBASE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu-system-x86_64 /usr/local/bin`
	    [ -z "$QEMUBASE" ]&&QEMUBASE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu-system-x86_64 /usr/bin`
	    [ -z "$QEMUBASE" ]&&QEMUBASE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu-system-x86_64 /usr/libexec/bin`
	    [ -z "$QEMUBASE" ]&&QEMUBASE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu-system-x86_64 /opt/qemu/bin`
	    ;;
    esac
    [ -z "$QEMUBASE" ]&&QEMUBASE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu /usr/local/bin`
    [ -z "$QEMUBASE" ]&&QEMUBASE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu /usr/bin`
    [ -z "$QEMUBASE" ]&&QEMUBASE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu /usr/libexec/bin`
    [ -z "$QEMUBASE" ]&&QEMUBASE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu /opt/qemu/bin`

    [ -z "$QEMUIO" ]&&QEMUIO=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu-io /usr/local/bin`
    [ -z "$QEMUIO" ]&&QEMUIO=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu-io /usr/bin`
    [ -z "$QEMUIO" ]&&QEMUIO=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu-io /usr/libexec/bin`
    [ -z "$QEMUIO" ]&&QEMUIO=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu-io /opt/qemu/bin`

    [ -z "$QEMUIMG" ]&&QEMUIMG=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu-img /usr/local/bin`
    [ -z "$QEMUIMG" ]&&QEMUIMG=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu-img /usr/bin`
    [ -z "$QEMUIMG" ]&&QEMUIMG=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu-img /usr/libexec/bin`
    [ -z "$QEMUIMG" ]&&QEMUIMG=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu-img /opt/qemu/bin`

    #
    #Currently supports "VirtualSquare/VDE" only for Networking on Linux-Platforms
    #
    [ -z "$VDE_TUNCTL" ]&&VDE_TUNCTL=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vde_tunctl /usr/local/sbin`
    [ -z "$VDE_TUNCTL" ]&&VDE_TUNCTL=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vde_tunctl /usr/sbin`
    [ -z "$VDE_TUNCTL" ]&&VDE_TUNCTL=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vde_tunctl /usr/bin`
    [ -z "$VDE_TUNCTL" ]&&VDE_TUNCTL=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vde_tunctl /opt/vde/sbin`

    [ -z "$VDE_SWITCH" ]&&VDE_SWITCH=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vde_switch /usr/local/bin`
    [ -z "$VDE_SWITCH" ]&&VDE_SWITCH=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vde_switch /usr/bin`
    [ -z "$VDE_SWITCH" ]&&VDE_SWITCH=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vde_switch /opt/vde/bin`

    [ -z "$VDE_UNIXTERM" ]&&VDE_UNIXTERM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT unixterm /usr/local/bin`
    [ -z "$VDE_UNIXTERM" ]&&VDE_UNIXTERM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT unixterm /usr/bin`
    [ -z "$VDE_UNIXTERM" ]&&VDE_UNIXTERM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT unixterm /opt/vde/bin`

    [ -z "$VDE_DEQ" ]&&VDE_DEQ=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vdeq  /usr/local/bin`
    [ -z "$VDE_DEQ" ]&&VDE_DEQ=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vdeq  /usr/bin`
    [ -z "$VDE_DEQ" ]&&VDE_DEQ=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vdeq  /opt/vde/bin`

    ###

    [ -z "$CTYS_IP" ]&&CTYS_IP=`getPathName $LINENO $BASH_SOURCE ERROR ip /sbin`
    [ -z "$CTYS_IFCONFIG" ]&&CTYS_IFCONFIG=`getPathName $LINENO $BASH_SOURCE ERROR ifconfig /sbin`
    [ -z "$CTYS_IFUP" ]&&CTYS_IFUP=`getPathName $LINENO $BASH_SOURCE ERROR ifup /sbin`
    [ -z "$CTYS_IFDOWN" ]&&CTYS_IFDOWN=`getPathName $LINENO $BASH_SOURCE ERROR ifdown /sbin`
    [ -z "$CTYS_ROUTE" ]&&CTYS_ROUTE=`getPathName $LINENO $BASH_SOURCE ERROR route /sbin`

    case ${MYDIST} in
	MeeGo)
	    [ -z "$CTYS_NETWORK" ]&&CTYS_NETWORK=`getPathName $LINENO $BASH_SOURCE ERROR network /etc/init.d`
	    [ -z "$CTYS_BRCTL" ]&&CTYS_BRCTL=`getPathName $LINENO $BASH_SOURCE ERROR brctl /usr/sbin`
	    [ -z "$CTYS_IPTABLES" ]&&CTYS_IPTABLES=`getPathName $LINENO $BASH_SOURCE ERROR iptables /sbin`

	    [ -z "$CTYS_NETCAT" ]&&CTYS_NETCAT=`getPathName $LINENO $BASH_SOURCE WARNING nc /usr/bin`
	    #CTYS_NETCAT_ACCESS_DELAY=${CTYS_NETCAT_ACCESS_DELAY:-1}

	    [ -z "$CTYS_LSOF" ]&&CTYS_LSOF=`getPathName $LINENO $BASH_SOURCE WARNING lsof /usr/sbin`

	    [ -z "$QEMUKVM" ]&&QEMUKVM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu-kvm /usr/local/bin`
	    [ -z "$QEMUKVM" ]&&QEMUKVM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu-kvm /usr/bin`
	    [ -z "$QEMUKVM" ]&&QEMUKVM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu-kvm /usr/libexec`
	    [ -z "$QEMUKVM" ]&&QEMUKVM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu-kvm /opt/qemu/bin`


            #
            #To be set when required, the actual path may vary.
            #
            #Sets the virtual switch for interconnection of QEMU-VMs with the
            #external NIC of current container, which could be VM itself.
	    #QEMUBIOS=${QEMUBIOS:-/usr/share/kvm}
	    ;;

	CentOS)
	    [ -z "$CTYS_NETWORK" ]&&CTYS_NETWORK=`getPathName $LINENO $BASH_SOURCE ERROR network /etc/init.d`
	    [ -z "$CTYS_BRCTL" ]&&CTYS_BRCTL=`getPathName $LINENO $BASH_SOURCE ERROR brctl /usr/sbin`
	    [ -z "$CTYS_IPTABLES" ]&&CTYS_IPTABLES=`getPathName $LINENO $BASH_SOURCE ERROR iptables /sbin`

	    [ -z "$CTYS_NETCAT" ]&&CTYS_NETCAT=`getPathName $LINENO $BASH_SOURCE WARNING nc /usr/bin`
	    #CTYS_NETCAT_ACCESS_DELAY=${CTYS_NETCAT_ACCESS_DELAY:-1}

	    [ -z "$CTYS_LSOF" ]&&CTYS_LSOF=`getPathName $LINENO $BASH_SOURCE WARNING lsof /usr/sbin`

	    [ -z "$QEMUKVM" ]&&QEMUKVM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu-kvm /usr/local/bin`
	    [ -z "$QEMUKVM" ]&&QEMUKVM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu-kvm /usr/bin`
	    [ -z "$QEMUKVM" ]&&QEMUKVM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu-kvm /usr/libexec`
	    [ -z "$QEMUKVM" ]&&QEMUKVM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu-kvm /opt/qemu/bin`


            #
            #To be set when required, the actual path may vary.
            #
            #Sets the virtual switch for interconnection of QEMU-VMs with the
            #external NIC of current container, which could be VM itself.
	    #QEMUBIOS=${QEMUBIOS:-/usr/share/kvm}
	    ;;

	EnterpriseLinux)
	    [ -z "$CTYS_NETWORK" ]&&CTYS_NETWORK=`getPathName $LINENO $BASH_SOURCE ERROR network /etc/init.d`
	    [ -z "$CTYS_BRCTL" ]&&CTYS_BRCTL=`getPathName $LINENO $BASH_SOURCE ERROR brctl /usr/sbin`
	    [ -z "$CTYS_IPTABLES" ]&&CTYS_IPTABLES=`getPathName $LINENO $BASH_SOURCE ERROR iptables /sbin`

	    [ -z "$CTYS_NETCAT" ]&&CTYS_NETCAT=`getPathName $LINENO $BASH_SOURCE WARNING nc /usr/bin`
	    #CTYS_NETCAT_ACCESS_DELAY=${CTYS_NETCAT_ACCESS_DELAY:-1}

	    [ -z "$CTYS_LSOF" ]&&CTYS_LSOF=`getPathName $LINENO $BASH_SOURCE WARNING lsof /usr/sbin`

	    [ -z "$QEMUKVM" ]&&QEMUKVM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu-kvm /usr/local/bin`
	    [ -z "$QEMUKVM" ]&&QEMUKVM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu-kvm /usr/bin`
	    [ -z "$QEMUKVM" ]&&QEMUKVM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu-kvm /usr/libexec`
	    [ -z "$QEMUKVM" ]&&QEMUKVM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu-kvm /opt/qemu/bin`


            #
            #To be set when required, the actual path may vary.
            #
            #Sets the virtual switch for interconnection of QEMU-VMs with the
            #external NIC of current container, which could be VM itself.
	    #QEMUBIOS=${QEMUBIOS:-/usr/share/kvm}
	    ;;

	RHEL)
	    [ -z "$CTYS_NETWORK" ]&&CTYS_NETWORK=`getPathName $LINENO $BASH_SOURCE ERROR network /etc/init.d`
	    [ -z "$CTYS_BRCTL" ]&&CTYS_BRCTL=`getPathName $LINENO $BASH_SOURCE ERROR brctl /usr/sbin`
	    [ -z "$CTYS_IPTABLES" ]&&CTYS_IPTABLES=`getPathName $LINENO $BASH_SOURCE ERROR iptables /sbin`

	    [ -z "$CTYS_NETCAT" ]&&CTYS_NETCAT=`getPathName $LINENO $BASH_SOURCE WARNING nc /usr/bin`
	    #CTYS_NETCAT_ACCESS_DELAY=${CTYS_NETCAT_ACCESS_DELAY:-1}

	    [ -z "$CTYS_LSOF" ]&&CTYS_LSOF=`getPathName $LINENO $BASH_SOURCE WARNING lsof /usr/sbin`

	    [ -z "$QEMUKVM" ]&&QEMUKVM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu-kvm /usr/local/bin`
	    [ -z "$QEMUKVM" ]&&QEMUKVM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu-kvm /usr/bin`
	    [ -z "$QEMUKVM" ]&&QEMUKVM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu-kvm /usr/libexec`
	    [ -z "$QEMUKVM" ]&&QEMUKVM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu-kvm /opt/qemu/bin`


            #
            #To be set when required, the actual path may vary.
            #
            #Sets the virtual switch for interconnection of QEMU-VMs with the
            #external NIC of current container, which could be VM itself.
	    #QEMUBIOS=${QEMUBIOS:-/usr/share/kvm}
	    ;;

	Scientific)
	    [ -z "$CTYS_NETWORK" ]&&CTYS_NETWORK=`getPathName $LINENO $BASH_SOURCE ERROR network /etc/init.d`
	    [ -z "$CTYS_BRCTL" ]&&CTYS_BRCTL=`getPathName $LINENO $BASH_SOURCE ERROR brctl /usr/sbin`
	    [ -z "$CTYS_IPTABLES" ]&&CTYS_IPTABLES=`getPathName $LINENO $BASH_SOURCE ERROR iptables /sbin`

	    [ -z "$CTYS_NETCAT" ]&&CTYS_NETCAT=`getPathName $LINENO $BASH_SOURCE WARNING nc /usr/bin`
	    #CTYS_NETCAT_ACCESS_DELAY=${CTYS_NETCAT_ACCESS_DELAY:-1}

	    [ -z "$CTYS_LSOF" ]&&CTYS_LSOF=`getPathName $LINENO $BASH_SOURCE WARNING lsof /usr/sbin`

	    [ -z "$QEMUKVM" ]&&QEMUKVM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu-kvm /usr/local/bin`
	    [ -z "$QEMUKVM" ]&&QEMUKVM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu-kvm /usr/bin`
	    [ -z "$QEMUKVM" ]&&QEMUKVM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu-kvm /usr/libexec`
	    [ -z "$QEMUKVM" ]&&QEMUKVM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu-kvm /opt/qemu/bin`


            #
            #To be set when required, the actual path may vary.
            #
            #Sets the virtual switch for interconnection of QEMU-VMs with the
            #external NIC of current container, which could be VM itself.
	    #QEMUBIOS=${QEMUBIOS:-/usr/share/kvm}
	    ;;

	Fedora)
	    [ -z "$CTYS_NETWORK" ]&&CTYS_NETWORK=`getPathName $LINENO $BASH_SOURCE ERROR network /etc/init.d`
	    [ -z "$CTYS_BRCTL" ]&&CTYS_BRCTL=`getPathName $LINENO $BASH_SOURCE ERROR brctl /usr/sbin`
	    [ -z "$CTYS_IPTABLES" ]&&CTYS_IPTABLES=`getPathName $LINENO $BASH_SOURCE ERROR iptables /sbin`

	    [ -z "$CTYS_NETCAT" ]&&CTYS_NETCAT=`getPathName $LINENO $BASH_SOURCE WARNING nc /usr/bin`
	    #CTYS_NETCAT_ACCESS_DELAY=${CTYS_NETCAT_ACCESS_DELAY:-1}

	    [ -z "$CTYS_LSOF" ]&&CTYS_LSOF=`getPathName $LINENO $BASH_SOURCE WARNING lsof /usr/sbin`

	    [ -z "$QEMUKVM" ]&&QEMUKVM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu-kvm /usr/local/bin`
	    [ -z "$QEMUKVM" ]&&QEMUKVM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu-kvm /usr/bin`
	    [ -z "$QEMUKVM" ]&&QEMUKVM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu-kvm /usr/libexec`
	    [ -z "$QEMUKVM" ]&&QEMUKVM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu-kvm /opt/qemu/bin`


            #
            #To be set when required, the actual path may vary.
            #
            #Sets the virtual switch for interconnection of QEMU-VMs with the
            #external NIC of current container, which could be VM itself.
	    #QEMUBIOS=${QEMUBIOS:-/usr/share/kvm}
	    ;;

	SuSE)
	    [ -z "$CTYS_NETWORK" ]&&CTYS_NETWORK=`getPathName $LINENO $BASH_SOURCE ERROR network /etc/init.d`
	    [ -z "$CTYS_IPTABLES" ]&&CTYS_IPTABLES=`getPathName $LINENO $BASH_SOURCE ERROR iptables /usr/sbin`
	    [ -z "$CTYS_BRCTL" ]&&CTYS_BRCTL=`getPathName $LINENO $BASH_SOURCE ERROR brctl /sbin`

	    #[ -z "$CTYS_NETCAT" ]&&CTYS_NETCAT=`getPathName $LINENO $BASH_SOURCE WARNINGEXT netcat /usr/bin`
	    [ -z "$CTYS_NETCAT" ]&&CTYS_NETCAT=`getPathName $LINENO $BASH_SOURCE WARNINGEXT nc /usr/bin`
	    CTYS_NETCAT_ACCESS_DELAY=${CTYS_NETCAT_ACCESS_DELAY:-1}

	    [ -z "$CTYS_LSOF" ]&&CTYS_LSOF=`getPathName $LINENO $BASH_SOURCE WARNING lsof /usr/bin`

	    [ -z "$QEMUKVM" ]&&QEMUKVM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu-kvm /usr/local/bin`
	    [ -z "$QEMUKVM" ]&&QEMUKVM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu-kvm /usr/bin`
	    [ -z "$QEMUKVM" ]&&QEMUKVM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu-kvm /usr/libexec`
	    [ -z "$QEMUKVM" ]&&QEMUKVM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu-kvm /opt/qemu/bin`


            #
            #To be set when required, the actual path may vary.
            #
            #Sets the virtual switch for interconnection of QEMU-VMs with the
            #external NIC of current container, which could be VM itself.
	    #QEMUBIOS=${QEMUBIOS:-/usr/share/kvm}
	    ;;

	openSUSE)
	    [ -z "$CTYS_NETWORK" ]&&CTYS_NETWORK=`getPathName $LINENO $BASH_SOURCE ERROR network /etc/init.d`
	    [ -z "$CTYS_IPTABLES" ]&&CTYS_IPTABLES=`getPathName $LINENO $BASH_SOURCE ERROR iptables /usr/sbin`
	    [ -z "$CTYS_BRCTL" ]&&CTYS_BRCTL=`getPathName $LINENO $BASH_SOURCE ERROR brctl /sbin`

	    #[ -z "$CTYS_NETCAT" ]&&CTYS_NETCAT=`getPathName $LINENO $BASH_SOURCE WARNING netcat /usr/bin`
	    [ -z "$CTYS_NETCAT" ]&&CTYS_NETCAT=`getPathName $LINENO $BASH_SOURCE WARNINGEXT nc /usr/bin`
	    CTYS_NETCAT_ACCESS_DELAY=${CTYS_NETCAT_ACCESS_DELAY:-1}

	    [ -z "$CTYS_LSOF" ]&&CTYS_LSOF=`getPathName $LINENO $BASH_SOURCE WARNING lsof /usr/bin`

	    [ -z "$QEMUKVM" ]&&QEMUKVM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu-kvm /usr/local/bin`
	    [ -z "$QEMUKVM" ]&&QEMUKVM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu-kvm /usr/bin`
	    [ -z "$QEMUKVM" ]&&QEMUKVM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu-kvm /usr/libexec`
	    [ -z "$QEMUKVM" ]&&QEMUKVM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu-kvm /opt/qemu/bin`


            #
            #To be set when required, the actual path may vary.
            #
            #Sets the virtual switch for interconnection of QEMU-VMs with the
            #external NIC of current container, which could be VM itself.
	    #QEMUBIOS=${QEMUBIOS:-/usr/share/kvm}

	    #
            #Force appropriate options for embedded QEMU VNC server when required.
	    #VNCVIEWER_OPT_RealVNC4="  -PreferredEncoding hextile  -FullColour -AutoSelect=0 -Shared=1 "
	    #VNCVIEWER_OPT_RealVNC="   -PreferredEncoding hextile  -FullColour -AutoSelect=0 -Shared=1 "
	    #VNCVIEWER_OPT_TigerVNC="  -PreferredEncoding hextile  -FullColour -AutoSelect=0 -Shared=1 "
	    #VNCVIEWER_OPT_TightVNC="  -encodings         hextile  -truecolour  -shared "
	    #VNCVIEWER_OPT_GENERIC=""

	    ;;

	debian)
	    [ -z "$CTYS_NETWORK" ]&&CTYS_NETWORK=`getPathName $LINENO $BASH_SOURCE ERROR networking /etc/init.d`
	    [ -z "$CTYS_IPTABLES" ]&&CTYS_IPTABLES=`getPathName $LINENO $BASH_SOURCE ERROR iptables /sbin`
	    [ -z "$CTYS_BRCTL" ]&&CTYS_BRCTL=`getPathName $LINENO $BASH_SOURCE ERROR brctl /usr/sbin`

            #requires support of "-U"!
	    case $MYREL in
		4.*)
                    #yes, nc in standard distro does not support "-U"!
	            [ -z "$CTYS_NETCAT" ]&&CTYS_NETCAT=`getPathName $LINENO $BASH_SOURCE WARNINGEXT nc /bin`
  	            [ -z "$CTYS_NETCAT" ]&&CTYS_NETCAT=`getPathName $LINENO $BASH_SOURCE WARNINGEXT netcat /bin`
                    #
		    ;;
		5.*)
                    #yes, nc in standard distro does not support "-U"!
	            [ -z "$CTYS_NETCAT" ]&&CTYS_NETCAT=`getPathName $LINENO $BASH_SOURCE WARNINGEXT nc /bin`
  	            [ -z "$CTYS_NETCAT" ]&&CTYS_NETCAT=`getPathName $LINENO $BASH_SOURCE WARNINGEXT netcat /bin`
	            [ -n "$CTYS_NETCAT" ]&&CTYS_NETCAT="${CTYS_NETCAT} -q 0 "
                    #
		    ;;
		*)
  	            [ -z "$CTYS_NETCAT" ]&&CTYS_NETCAT=`getPathName $LINENO $BASH_SOURCE WARNINGEXT netcat /bin`
		    ;;
	    esac
	    #CTYS_NETCAT_ACCESS_DELAY=${CTYS_NETCAT_ACCESS_DELAY:-1}


	    [ -z "$CTYS_LSOF" ]&&CTYS_LSOF=`getPathName $LINENO $BASH_SOURCE WARNING lsof /usr/bin`
	    [ -z "$CTYS_LSOF" ]&&CTYS_LSOF=`getPathName $LINENO $BASH_SOURCE WARNING lsof /usr/sbin`

	    [ -z "$QEMUKVM" ]&&QEMUKVM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT kvm /usr/local/bin`
	    [ -z "$QEMUKVM" ]&&QEMUKVM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT kvm /usr/bin`
	    [ -z "$QEMUKVM" ]&&QEMUKVM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT kvm /usr/libexec`
	    [ -z "$QEMUKVM" ]&&QEMUKVM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT kvm /opt/qemu/bin`


	    [ -z "$QEMUIMG" ]&&QEMUIMG=`getPathName $LINENO $BASH_SOURCE WARNINGEXT kvm-img /usr/bin`

            #
            #To be set when required, the actual path may vary.
            #
            #Sets the virtual switch for interconnection of QEMU-VMs with the
            #external NIC of current container, which could be VM itself.
	    #QEMUBIOS=${QEMUBIOS:-/usr/share/kvm}
	    ;;

	Ubuntu)
	    [ -z "$CTYS_NETWORK" ]&&CTYS_NETWORK=`getPathName $LINENO $BASH_SOURCE ERROR networking /etc/init.d`
	    [ -z "$CTYS_IPTABLES" ]&&CTYS_IPTABLES=`getPathName $LINENO $BASH_SOURCE ERROR iptables /sbin`
	    [ -z "$CTYS_BRCTL" ]&&CTYS_BRCTL=`getPathName $LINENO $BASH_SOURCE ERROR brctl /usr/sbin`

            #Detecting -U option for netcat-variant on Ubuntu is even worst than anyway!!!
	    if [ -n "$CTYS_NETCAT" ];then
		$CTYS_NETCAT -h 2>&1|grep -e '-U'|grep -q 'UNIX' 2>/dev/null
		[ $? != 0 ]&&unset CTYS_NETCAT
	    fi

	    if [ -z "$CTYS_NETCAT" ];then
		CTYS_NETCAT=`getPathName $LINENO $BASH_SOURCE WARNINGEXT nc.openbsd /bin`
		if [ -n "$CTYS_NETCAT" ];then
		    CTYS_NETCAT="${CTYS_NETCAT} -q 0 "
		fi
	    fi

	    [ -z "$CTYS_NETCAT" ]&&CTYS_NETCAT=`getPathName $LINENO $BASH_SOURCE WARNING netcat /bin`
	    if [ -n "$CTYS_NETCAT" ];then
		$CTYS_NETCAT -h 2>&1|grep -e '-U'|grep -q 'UNIX' 2>/dev/null
		[ $? != 0 ]&&unset CTYS_NETCAT
	    fi


	    [ -z "$CTYS_NETCAT" ]&&CTYS_NETCAT=`getPathName $LINENO $BASH_SOURCE WARNINGEXT nc /usr/bin`
	    if [ -n "$CTYS_NETCAT" ];then
		$CTYS_NETCAT -h 2>&1|grep -e '-U'|grep -q 'UNIX' 2>/dev/null
		[ $? != 0 ]&&unset CTYS_NETCAT
	    fi

	    [ -z "$CTYS_LSOF" ]&&CTYS_LSOF=`getPathName $LINENO $BASH_SOURCE WARNING lsof /usr/bin`
	    if [ -n "$CTYS_NETCAT" ];then
		$CTYS_NETCAT -h 2>&1|grep -e '-U'|grep -q 'UNIX' 2>/dev/null
		[ $? != 0 ]&&unset CTYS_NETCAT
	    fi
	    #CTYS_NETCAT_ACCESS_DELAY=${CTYS_NETCAT_ACCESS_DELAY:-1}


	    [ -z "$QEMUKVM" ]&&QEMUKVM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT kvm /usr/local/bin`
	    [ -z "$QEMUKVM" ]&&QEMUKVM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT kvm /usr/bin`
	    [ -z "$QEMUKVM" ]&&QEMUKVM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT kvm /usr/libexec`
	    [ -z "$QEMUKVM" ]&&QEMUKVM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT kvm /opt/qemu/bin`


            #
            #To be set when required, the actual path may vary.
            #
            #Sets the virtual switch for interconnection of QEMU-VMs with the
            #external NIC of current container, which could be VM itself.
	    #QEMUBIOS=${QEMUBIOS:-/usr/share/kvm}
	    ;;

	Mandriva)
	    [ -z "$CTYS_NETWORK" ]&&CTYS_NETWORK=`getPathName $LINENO $BASH_SOURCE ERROR network /etc/init.d`
	    [ -z "$CTYS_BRCTL" ]&&CTYS_BRCTL=`getPathName $LINENO $BASH_SOURCE ERROR brctl /usr/sbin`
	    [ -z "$CTYS_IPTABLES" ]&&CTYS_IPTABLES=`getPathName $LINENO $BASH_SOURCE ERROR iptables /sbin`

	    #[ -z "$CTYS_NETCAT" ]&&CTYS_NETCAT=`getPathName $LINENO $BASH_SOURCE WARNING netcat /bin`
	    [ -z "$CTYS_NETCAT" ]&&CTYS_NETCAT=`getPathName $LINENO $BASH_SOURCE WARNINGEXT nc /usr/bin`
	    #CTYS_NETCAT_ACCESS_DELAY=${CTYS_NETCAT_ACCESS_DELAY:-1}

	    [ -z "$CTYS_LSOF" ]&&CTYS_LSOF=`getPathName $LINENO $BASH_SOURCE WARNING lsof /usr/sbin`

	    [ -z "$QEMUKVM" ]&&QEMUKVM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu-kvm /usr/local/bin`
	    [ -z "$QEMUKVM" ]&&QEMUKVM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu-kvm /usr/bin`
	    [ -z "$QEMUKVM" ]&&QEMUKVM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu-kvm /usr/libexec`
	    [ -z "$QEMUKVM" ]&&QEMUKVM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu-kvm /opt/qemu/bin`


            #
            #To be set when required, the actual path may vary.
            #
            #Sets the virtual switch for interconnection of QEMU-VMs with the
            #external NIC of current container, which could be VM itself.
	    #QEMUBIOS=${QEMUBIOS:-/usr/share/kvm}
	    ;;

	FreeBSD)
	    [ -z "$CTYS_NETWORK" ]&&CTYS_NETWORK=`getPathName $LINENO $BASH_SOURCE ERROR network /etc/init.d`
	    [ -z "$CTYS_IPTABLES" ]&&CTYS_IPTABLES=`getPathName $LINENO $BASH_SOURCE ERROR iptables /usr/sbin`
	    [ -z "$CTYS_BRCTL" ]&&CTYS_BRCTL=`getPathName $LINENO $BASH_SOURCE ERROR brctl /sbin`

	    #[ -z "$CTYS_NETCAT" ]&&CTYS_NETCAT=`getPathName $LINENO $BASH_SOURCE WARNINGEXT netcat /usr/bin`
	    [ -z "$CTYS_NETCAT" ]&&CTYS_NETCAT=`getPathName $LINENO $BASH_SOURCE WARNINGEXT nc /usr/bin`
	    #CTYS_NETCAT_ACCESS_DELAY=${CTYS_NETCAT_ACCESS_DELAY:-1}

	    [ -z "$CTYS_LSOF" ]&&CTYS_LSOF=`getPathName $LINENO $BASH_SOURCE WARNING lsof /usr/bin`

	    [ -z "$QEMUKVM" ]&&QEMUKVM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu /usr/local/bin`
	    [ -z "$QEMUKVM" ]&&QEMUKVM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu /usr/bin`
	    [ -z "$QEMUKVM" ]&&QEMUKVM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu /usr/libexec`
	    [ -z "$QEMUKVM" ]&&QEMUKVM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu /opt/qemu/bin`


            #
            #To be set when required, the actual path may vary.
            #
            #Sets the virtual switch for interconnection of QEMU-VMs with the
            #external NIC of current container, which could be VM itself.
	    #QEMUBIOS=${QEMUBIOS:-/usr/share/kvm}
	    ;;

	*)
	    [ -z "$CTYS_NETWORK" ]&&CTYS_NETWORK=`getPathName $LINENO $BASH_SOURCE ERROR network /etc/init.d`
	    [ -z "$CTYS_BRCTL" ]&&CTYS_BRCTL=`getPathName $LINENO $BASH_SOURCE ERROR brctl /usr/sbin`
	    [ -z "$CTYS_IPTABLES" ]&&CTYS_IPTABLES=`getPathName $LINENO $BASH_SOURCE ERROR iptables /sbin`

	    #[ -z "$CTYS_NETCAT" ]&&CTYS_NETCAT=`getPathName $LINENO $BASH_SOURCE WARNING netcat /bin`
	    [ -z "$CTYS_NETCAT" ]&&CTYS_NETCAT=`getPathName $LINENO $BASH_SOURCE WARNINGEXT nc /usr/bin`

            #for safety
	    CTYS_NETCAT_ACCESS_DELAY=${CTYS_NETCAT_ACCESS_DELAY:-1}

	    [ -z "$CTYS_LSOF" ]&&CTYS_LSOF=`getPathName $LINENO $BASH_SOURCE WARNING lsof /usr/sbin`

	    [ -z "$QEMUKVM" ]&&QEMUKVM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu-kvm /usr/local/bin`
	    [ -z "$QEMUKVM" ]&&QEMUKVM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu-kvm /usr/bin`
	    [ -z "$QEMUKVM" ]&&QEMUKVM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu-kvm /usr/libexec`
	    [ -z "$QEMUKVM" ]&&QEMUKVM=`getPathName $LINENO $BASH_SOURCE WARNINGEXT qemu-kvm /opt/qemu/bin`


            #
            #To be set when required, the actual path may vary.
            #
            #Sets the virtual switch for interconnection of QEMU-VMs with the
            #external NIC of current container, which could be VM itself.
	    #QEMUBIOS=${QEMUBIOS:-/usr/share/kvm}
	    ;;
    esac

    if [ -z "$CTYS_NETCAT" ];then 
	printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "Cannot use netcat call-variant(<1.89-1), lack of \"-U <UNIX-Domain>\""
	printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "Missing CentOS/Redhat(TM)/OpenBSD call-variant \"nc\" with support of\"-U\""
	printWNG 2 $LINENO $BASH_SOURCE ${ABORT} " a.) refer to DebianBugReport #348564"
	printWNG 2 $LINENO $BASH_SOURCE ${ABORT} " b.) refer to netcat-openbsd version >= 1.89-1"
    fi

    if [ -z "$CTYS_NETCAT" -a -z "$VDE_UNIXTERM" ];then 
	printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "Cannot use netcat call-variant(<1.89-1), lack of \"-U <UNIX-Domain>\""
	printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "Missing CentOS/Redhat(TM)/OpenBSD call-variant \"nc\" with support of\"-U\""
	printWNG 1 $LINENO $BASH_SOURCE ${ABORT} " a.) refer to DebianBugReport #348564"
	printWNG 1 $LINENO $BASH_SOURCE ${ABORT} " b.) refer to netcat-openbsd version >= 1.89-1"
	if [ -z "$VDE_UNIXTERM" ];then
	    ABORT=1;
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing MANDATORY fall-back \"unixterm\" from VDE package."
	    printERR $LINENO $BASH_SOURCE ${ABORT} " 1.) If possible, install \"nc\""
	    printERR $LINENO $BASH_SOURCE ${ABORT} "     a.) refer to DebianBugReport #348564"
	    printERR $LINENO $BASH_SOURCE ${ABORT} "     b.) refer to netcat-openbsd version >= 1.89-1"
	    printERR $LINENO $BASH_SOURCE ${ABORT} " 2.) Force the usage of \"netcat\" if you have installed a "
	    printERR $LINENO $BASH_SOURCE ${ABORT} "     never version."
	    printERR $LINENO $BASH_SOURCE ${ABORT} " 3.) Anyhow, in any case check your "
	    printERR $LINENO $BASH_SOURCE ${ABORT} "     VDE/VirtualDistributedEthernet/VirtualSquare"
	    printERR $LINENO $BASH_SOURCE ${ABORT} "     installation."
	else
	    printWNG 2 $LINENO $BASH_SOURCE ${ABORT} "Use fall-back \"unixterm\", please install \"nc\" soon."
	fi
    fi
fi

#
#Due to required root permissions for most of the calls to xm/virsh the 
#impersonation aproach either by sudo or ksu should be used for restricted
#calls. These calls might be released for call with root permissions 
#selectively by local impersonation as root or an execution-account, instead 
#of releasing the whole set of ctys. The ctys-tools should be executed as a 
#different user without enhanced privileges.
#
#When using the root account natively no additional permissions are required
#of course.
#
#
#For ordinary users without enhnaced privileges one of the following two 
#approaches could be applied:
#
# - ksu
#   The preferred approach should be the seamless usage of kerberos, therefore
#   "ksu" with the configuration file ".k5users" should be used.
#
#   For each user the following entry is required:
#
#     "<users-pricipal> /usr/bin/which /usr/sbin/xm /usr/bin/virsh"
#
#   Where the paths may vary.
#
#   Due to the required few calls to which, xm and/or virsh only ".k5login" 
#   is not required.
#
# - sudo
#   Basically the same, but to be handled by local configurations on any machine.
#
#
#QEMUCALL="${XENCALL:-ksu -e }"
#VDECALL="${VDECALL:-ksu -e }"


#
#Default behaviour for CANCEL
QEMU_CANCEL_DEFAULT=${QEMU_CANCEL_DEFAULT:-POWEROFF}


#
#Sets the prefix for Unix domain sockets
CTYS_SOCKBASE=${CTYS_SOCKBASE:-/var/tmp}


#
#Sets the virtual switch for interconnection of QEMU-VMs with the
#external NIC of current container, which could be VM itself.
QEMUSOCK=${QEMUSOCK:-$CTYS_SOCKBASE/vde_switch0.$USER}


#
#Sets the virtual switch for interconnection of QEMU-VMs with the
#external NIC of current container, which could be VM itself.
QEMUMGMT=${QEMUMGMT:-$CTYS_SOCKBASE/vde_mgmt0.$USER}



#
#Sets the pathname for the local unix-domain socket to be used for 
#QEMU VMs for monitor access.
#
#The following placeholders has to be replaced by their actual values:
#  ACTUALLABEL:  the LABEL of the actual VM to be managed.
#  ACTUALPID:    the PID of the actual VM to be managed.
QEMUMONSOCK=${QEMUMONSOCK:-$CTYS_SOCKBASE/qemumon.ACTUALLABEL.ACTUALPID.$USER}


#
#The signal spec to be ignored when CLI0 is used.
QEMU_SIGIGNORESPEC="${QEMU_SIGIGNORESPEC:-2 3 19}"


#
#The default console when non provided, final hard-coded 
#fall-back is VNC
QEMU_DEFAULT_CONSOLE=${QEMU_DEFAULT_CONSOLE:-VNC}

#
#The default console when non provided, final hard-coded 
#fall-back is VHDD
QEMU_DEFAULT_BOOTMODE=${QEMU_DEFAULT_BOOTMODE:-VHDD}

#
#Timeout for first attempt to connect to a VM after create call.
#QEMU requires longer to start, particularly within stacks, when
#multiplr layers are involved.
QEMU_INIT_WAITC=${QEMU_INIT_WAITC:-2}
QEMU_INIT_WAITS=${QEMU_INIT_WAITS:-2}

#
#Timeout for polling the base IP stack mainly after initial start.
#WAIT unit is seconds, REPEAT unit is #nr.
CTYS_PING_DEFAULT_QEMU=${CTYS_PING_DEFAULT_QEMU:-0};
CTYS_PING_ONE_MAXTRIAL_QEMU=${CTYS_PING_ONE_MAXTRIAL_QEMU:-20};
CTYS_PING_ONE_WAIT_QEMU=${CTYS_PING_ONE_WAIT_QEMU:-2};

#
#Timeout for polling the base SSH access, requires preconfigured permissions.
#WAIT unit is seconds, REPEAT unit is #nr.
CTYS_SSHPING_DEFAULT_QEMU=${CTYS_SSHPING_DEFAULT_QEMU:-0};
CTYS_SSHPING_ONE_MAXTRIAL_QEMU=${CTYS_SSHPING_ONE_MAXTRIAL_QEMU:-20};
CTYS_SSHPING_ONE_WAIT_QEMU=${CTYS_SSHPING_ONE_WAIT_QEMU:-2};


#
#Trials to interconnect a vncviewer to the QEMU-VM for "vnc"
QEMU_RETRYVNCCLIENTCONNECT=15; #numerical, integer - #trials
QEMU_RETRYVNCCLIENTTIMEOUT=3;  #numerical, integer - seconds

#
#individual QEMU defaults for STACKCHECK parameter
#0:OFF, 1:ON
_stackChkContextQEMU=0;
_stackChkHWCapQEMU=1;
_stackChkStacCapQEMU=1:


#
#Basic version - compatibility has default priority.
#QEMU=${QEMUBASE};
#
#For performance as default priority.
QEMU=${QEMUKVM:-$QEMUBASE};

#
#For additional versions
#
PATH=$PATH:$QEMU_PATHLIST


#
#default HOSTs for login
#
QEMU_DEFAULT_HOSTS=VNC

#
#default HOSTs for CONSOLE
#
QEMU_DEFAULT_CONSOLE=VNC


#protect multiple inclusion
fi

