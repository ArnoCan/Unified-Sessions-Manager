#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_07_001b01
#
########################################################################
#
# Copyright (C) 2007,2008 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

printDBG $S_CONF  ${D_FRAME} $LINENO $BASH_SOURCE "LOAD-CONFIG:${BASH_SOURCE}"

################################################################
#    Private for development and test                          #
################################################################
CTYS_PRIVATE=${MYLIBPATH}/../..

################################################################
#    Default definitions - User-Customizable  from shell       #
################################################################

#
#
#The following variables force control on the state of addressed
#plugins when present. The scope of control is local only.
#
#
#The syntax is:
#
#
#   export <plugin-type>_IGNORE=1
#
#
#When set, the bootstrap-loader ignores the given <plugin-type>.
#This should be in case of dependencies such as of XEN from VNC
#utilized carefully. But on machines with OpenBSD e.g. the plugins
#VMW and XEN could be set to ignore safely.
#
#export PM_IGNORE=1
#export CLI_IGNORE=1
#export X11_IGNORE=1
#export VNC_IGNORE=1
#export XEN_IGNORE=1
#export VBOX_IGNORE=1
#export VMW_IGNORE=1
#export QEMU_IGNORE=1
#export OVZ_IGNORE=1
#
#
# This could be configured conditionally for each of the following
# variables, and any other valid shell variable.
# This is particularly helpful in case of NFS mounted home directories
# sharing the identical user-configuration for multiple machines within 
# a cluster:
#
#   MYHOST   : actual host
#   MYOS     : actual OS
#   MYOSREL  : release of actual OS
#   MYDIST   : actual distribution
#   MYREL    : release of actual distribution
#
#
# Some examples for ignoring of XEN-plugin on specific sets of 
# nodes:
#
#   ->host01 only
#     [ "$MYHOST" == "host01" ]&&export XEN_IGNORE=1;
#
#   ->Any node NOT on "clust0*"
#     [ "${MYHOST#clust0*}" == "${MYHOST}" ]&&export XEN_IGNORE=1;
#
#   ->Any node IS on "clust0*"
#     [ "${MYHOST#clust0*}" != "${MYHOST}" ]&&export XEN_IGNORE=1;
#
#   ->Any node in domain "exe1"
#     [ "${MYHOST##*.exe1}" == "${MYHOST}" ]&&export XEN_IGNORE=1;
#
#   ->Any node NOT running OpenBSD
#     [ "${MYOS}" != "OpenBSD" ]&&export XEN_IGNORE=1;
#
#   ->Any node IS running Linux
#     [ "${MYOS}" == "Linux" ]&&export XEN_IGNORE=1;
#
#   ->Any node IS running CentOS
#     [ "${MYDIST}" == "CentOS" ]&&export XEN_IGNORE=1;
#
#   ->Any node which IS NOT final execution target
#     [ -z "$C_EXECLOCAL" ]&&export XEN_IGNORE=1;
#
#   ->....
#
#
# Almost any combination and any additional constraint could be
# added by means of bash.
#
# When using internal state variables the user is responsible for
# any resulting side effect.
#


##################
#Configuration of supported contexts for standard plugins.
#

#######
#PM    #
#######
#
#PM supports currently OpenBSD, Solaris, and Linux
#Solaris and OpenBSD may have some restrictions
case ${MYOS} in
    OpenBSD);;
    FreeBSD);;
    SunOS);;
    Linux);;
    *)export PM_IGNORE=1;;
esac

_lchk=`echo -e " $* "| sed -n '/ -E /p'`


#######
#XEN   #
#######
#
#XEN is supported for this version only:
# -> on Linux only as server, else as client only.
#    VNC check will be done by plugin
#    Check for "-e", because C_EXECLOCAL is not yet initialized.
#
# -> Even though PVM only tested until now, HVM should work properly.
#
[ "${MYOS}" != "Linux" -a -n "$_lchk" ]&&export XEN_IGNORE=1;


#######
#QEMU  #
#######
#
#QEMU is supported for this version only:
# -> on Linux only as server, else as client only.
#    VNC check will be done by plugin
[ "${MYOS}" != "Linux" -a -n "$_lchk" ]&&export QEMU_IGNORE=1;
#
#trial of OpenBSD-qemu on >=4.3
#
if [ "${MYOS}" == "OpenBSD" ];then
    case "${MYOSREL%%.*}" in
	4)
	    case "${MYOSREL#*.}" in
		[3-9]*)unset QEMU_IGNORE;;
	    esac
	    ;;
	[5-9])unset QEMU_IGNORE;;
    esac
fi

#
#pre-trial of QEMU for Solaris on >=10
#Anyhow, heavily experimental for several reasons.
#
# if [ "${MYOS}" == "SunOS" ];then
#     case "${MYOSREL%%.*}" in
# 	1[01])unset QEMU_IGNORE;;
#     esac
# fi

#######
#VMW   #
#######
#
#VMW is supported on Linux only, else as client only.
#Native local client and VNC access for WS6 will be checked by plugin.
[ "${MYOS}" != "Linux" ]&&export VMW_IGNORE=1;


###########################################################################
#                                                                         #
#ATTENTION:                                                               #
#  The plugins CLI+X11+VNC could be called MANDATORY for others, so       #
#  their "IGNORE-ance" might force unforseen side-effects, think twice!!! #
#                                                                         #
#  Same is true for PM when you require WoL and controlled PM shutdown,   #
#  what might be obvious!                                                 #
#                                                                         #
###########################################################################



###################
#generic
DEFAULT_C_SESSIONTYPE=${DEFAULT_C_SESSIONTYPE:-VNC}
DEFAULT_CTYS_MULTITYPE=${DEFAULT_CTYS_MULTITYPE:-DEFAULT}
DEFAULT_C_SCOPE=${DEFAULT_C_SCOPE:-USER}
DEFAULT_KILL_DELAY_POWEROFF=${DEFAULT_KILL_DELAY_POWEROFF:-20}
DEFAULT_LIST_CONTENT=${DEFAULT_LIST_CONTENT:-ALL,BOTH}

#The account to be used for generic network actions.
#When root permissions are required, the user root will be 
#called, but has to be preconfigured for network login or a 
#password authentication will be requested.
CTYS_NETACCOUNT=${CTYS_NETACCOUNT:-$USER}


###################
#CREATE
DEFAULT_C_MODE_ARGS=${DEFAULT_C_MODE_ARGS_CREATE:-'1,DEFAULT,REUSE'}


###################
#LIST
#DEFAULT_C_MODE_ARGS_LIST=${DEFAULT_C_MODE_ARGS_LIST:-"label,id,user,group,pid"}
DEFAULT_C_MODE_ARGS_LIST=${DEFAULT_C_MODE_ARGS_LIST:-"both,tab_tcp,dns"}

# DEFAULT_LIST_C_SCOPE="USRLST"
# DEFAULT_LIST_C_SCOPE_ARGS="all"


###################
#ENUMERATE
DEFAULT_C_MODE_ARGS_ENUMERATE=${DEFAULT_C_MODE_ARGS_ENUMERATE:-'.'}




################################################################
#Globalized convenience settings for Basic-Community-Packages  #
################################################################


#Common: Defines the timeout an established port-forwarding tunnel by 
#OpenSSH.
#Should wait for it's first and only one (just an wannabee oneshot - within
#the period any number of connects are possible) connection. This is choosen,
#because because now no precautions have to be and are not implemented for
#cancellation of no longer required tunnels. So you might no set a high value,
#just smallerr than a minute.
#Existing ports are not reused anyway, because the next tunnel-request
#increments the highest present for a new tunnel.
#
#APPLY:Increment when clients do not connect with CONNECTIONFORWARDING.
SSH_ONESHOT_TIMEOUT=${SSH_ONESHOT_TIMEOUT:-120}



#Common: Defines the timeout to delay the start of a client after server
#
#APPLY:Increment this value when clients do not connect.
R_CLIENT_DELAY=${R_CLIENT_DELAY:-2}



#Common: Defines the timeout after all XClients of one desktop are 
#started. Due to problems with reliability a shift of distinguished 
#windows seems not to work(at least in my environment on CentOS-5.0/Gnome).
#So current desktop is switched for default pop-up on target desktop
#which could take some time until the window actually is displayed.
#When the desktop is meanwhile switched the window will be positioned 
#on the current if not yet displayed.
#Depends on actual base, it seems that at least 5seconds are required,
#for safety 8 seconds are choosen.
#
#APPLY:Increment this value when clients pop-up on wrong desktop.
X_DESKTOPSWITCH_DELAY=${X_DESKTOPSWITCH_DELAY:-3}


#Flush time of local cached sessions in seconds.
#When set to 0, the caching is switched off completely. 
#When a low delay is shoosen, the cache will be flushed for almost any call, this 
#is due to the average collection time for remote information, which takes some 
#"decades" of seconds. Thus is wasted resource only.
#So, set it to reasonable long-delay, but a safe low-latency for state-change 
#detection.
SESSIONCACHEPERIOD=${SESSIONCACHEPERIOD:-20}


#Maximum cache age for cache-db and groups-cache of ctys-vhost.sh.
#When this outdates, the cache data will be rebuild from the
#present raw data.
#This could take some minutes.
#Value units are seconds. 
CTYS_CACHECLEARPERIOD=${CTYS_CACHECLEARPERIOD:-360000}


################################################################
#Basic-Package Settings: VNC
#
#General remarks: 
# The geometry parameter will be reset - for server too - when selected
# at the CLI by "-g" option. So the value here is just a default, when no 
# call parameter is supported.
#

#Bulk: Defines the timeout to wait between bulk creation of sessions 
R_CREATE_TIMEOUT=${R_CREATE_TIMEOUT:-3}



#Bulk: Defines the maximum allowed number of sessions to be created by a bulk call.
#ATTENTION:Mistakenly using e.g. 1000 will probably force you to reboot your machines!!!!
#A call of "ctys -a cancel=all poorHost" might help?!
#
#APPLY:Increment this when more VNC-bulk sessions on a node are required.
R_CREATE_MAX=${R_CREATE_MAX:-20}


#
#Sets the common maximum of recursion for all functions calling theirself.
#When this threshold is exceeded the function calls by convention an ""gotoHell"
#for controlled exit.
#
#Local variations has not to be applied, but the common maximum could be set as 
#the local default.
#
CTYS_MAXRECURSE=${CTYS_MAXRECURSE:-20};
CTYS_MAXRECURSEBASECALLS=${CTYS_MAXRECURSEBASECALLS:-200};

#Delay after call of VNCserver, before execution of VNCviewer.
#Only required on fast machines, though due to dialogue-response it should be  set
#moderately.
#If not, sometimes the client tries to attach too fast, before the server is ready.
#This leads to immediate termination of the client only with "BadAccess" Error, an 
#following connect will succeed. 
VNCVIEWER_DELAY=${VNCVIEWER_DELAY:-3}

#######wrapper for vncviewer
VNCVIEWER="${MYLIBEXECPATH}/ctys-callVncviewer.sh "

#######wrapper for vncserver
VNCSERVER="${MYLIBEXECPATH}/ctys-callVncserver.sh "



#######wrapper for vncviewer
RDPVIEWER="${MYLIBEXECPATH}/ctys-callRDPviewer.sh "


################################################################
#Basic-Package Settings: XEN
#ffs.


################################################################
#Guest-OS connection

#
#The TCP/IP address or hostename of the guest OS the connection 
#has to be established to.
#If this is provided, it has highest priority and will be used.
GUEST_IP=DEFAULT

#
#The name of the file from which the guest OS information should be 
#fetsched. The highest priority has 0, when read successful, the 
#others will be ignored.
#
# 0. This will be evaluated, when GUEST_IP is not provided.
#
#    The content will be scanned for an entry of the following 
#    form, which has to be administered manually by the user:
#
#    ${GUEST_CONFPREFIX}CTYS-IP=<ip-address>|<hostname>[:<ssh-port>]
#
#Letting this with DEFAULT, evaluates the given <vm-name> with the 
#following algorithm in order to get mapping information from VM
#to the guest OS, which is in this case a session of type HOST.
#
# 1. <vm-name-directory>/<vm-config-file>
#    Evaluation same as for 0.). 
#
# 2. Else:
#    <vm-name-directory>/<vm-config-file>.ctys
#    Evaluation same as for 0.). 
#
# 2. Else:
#    <vm-name-directory>.ctys
#    Evaluation same as for 0.). 
#
#
GUEST_DATAFILE=DEFAULT

#
#Common prefix for ctys-extensions in shell-files
GUEST_CONFPREFIX_SH='#@#'



################################################################
#Miscellaneous settings

#Options for formatting text with "pr" when printing out the embedded help.
PR_OPTS=${PR_OPTS:--o 5 -l 73 -F}




#Using this as a ready to use option, some lengthy keywords for now,
#but recognition has priority over string replace-functions!
C_CLIENTLOCATION="${C_CLIENTLOCATION:--L DISPLAYFORWARDING}"



#Base for remapping of local client access ports for CONNECTIONFORWARDING.
#Even though released curretnly for user-setting, you might know what you
#are doing. don't blame me, or ctys!
LOCAL_PORTREMAP=${LOCAL_PORTREMAP:-5950}


#
#The mode for access to Job-Data containing the JobID and some additional 
#runtime information.
#Might not be scurity critical, but anyhow, the JOBID will be used for
#access scope-filters when selecting access entities, thus could be 
#utilized for additional security constarints. At least for those triggered 
#by selections of ctys specific calls.
#
#Influences the output of LIST too.
#
#Anyhow, do not forget, this does not influence the immediate port access!
#
CTYS_JOBDATACCESSMODE="u+r,g-rwx,o-rwx"
CTYS_JOBDATSHAREDACCESSMODE="u+rwx,g+rwx,o+rwx"


#The default directory used for shared temporary data
#
#Could be set to private, is normally common data should be visible to the 
#current user only.
#
#Anyhow, root is prohibited to be visible from non-root.
#
if [ -z "$USER" -a -n "$LOGNAME" ];then
    USER="$LOGNAME";
fi
if [ "${MYTMPSHARED}" != NONE ];then
    MYTMPSHARED=${MYTMPSHARED:-/tmp/ctys.shared}
    if [ ! -d "${MYTMPSHARED}" ];then
	mkdir -p "${MYTMPSHARED}"
	chmod ${CTYS_JOBDATSHAREDACCESSMODE} "${MYTMPSHARED}"
    fi
    if [ ! -d ${MYTMPSHARED} ];then
	echo "${BASH_SOURCE}:${LINENO}:ERROR:Cannot create MYTMPSHARED=${MYTMPSHARED}"
	exit 1;
    fi
fi

#
#The default directory used for private temporary data
#
MYTMP=${MYTMP:-/tmp/ctys.$MYUID}
if [ ! -d "${MYTMP}" ];then
    mkdir -p ${MYTMP}
    chmod ${CTYS_JOBDATACCESSMODE} ${MYTMP}
fi
if [ ! -d ${MYTMP} ];then
    echo "${BASH_SOURCE}:${LINENO}:ERROR:Cannot create MYTMP=${MYTMP}"
    exit 1;
fi


#Is defined to be used when set, so it is foreseen as test-path for remote call
#R_PATH



#Is defined to be used when set, so it is foreseen as test-path for local call
#L_PATH


#
#The default directory-path for the mapping database of ctys.
#
DEFAULT_DBPATHLST=${DEFAULT_DBPATHLST:-$MYCONFPATH/db/default}


#
#The storage for pre-configured access-groups
#
CTYS_GROUPS_TMPPATH=${CTYS_GROUPS_TMPPATH:-$MYTMP/groups} 
if [ -z "${CTYS_GROUPS_PATH}" ];then
    CTYS_GROUPS_PATH="${CTYS_GROUPS_PATH}:${HOME}/.ctys/groups"
    CTYS_GROUPS_PATH="${CTYS_GROUPS_PATH}:${MYCONFPATH}/groups"
    CTYS_GROUPS_PATH="${CTYS_GROUPS_PATH}:${CTYS_GROUPS_TMPPATH}"
fi

#
#The number of current present intermediate runtime files, triggering
#a find and delte for all files older than 24h, 
#uses "find ... -atime 1 ..."
#performs on "CTYS_GROUPS_TMPPATH", be careful with that axe Eugene.
#
CTYS_CLEARTMPGROUPS=${CTYS_CLEARTMPGROUPS:-100}

#
#default base directories for enumeration trees
#
DEFAULT_ENUM_BASE="~ /etc/ctys.d /mntn/vmpool"


#################################################################
#
#Authentication
#

printDBG $S_CONF  ${D_FRAME} $LINENO $BASH_SOURCE "LOAD:USE_K5USERS=${USE_K5USERS}"
printDBG $S_CONF  ${D_FRAME} $LINENO $BASH_SOURCE "LOAD:USE_SUDO=${USE_SUDO}"

#
#The default for impersonation is to use kerberos and thus /root/.k5users
#for authentication.
# 1=>on  0=>off
#DEFAULT: Sets for specific actions it's own values, which are known to be uncritical.
#
export USE_K5USERS=${USE_K5USERS:-DEFAULT}

#
#When set sudo is tried for impersonation.
#Default is not to use, because a missing userr results in a password request,
#which is somewhat annoying for background tasks.
# 1=>on  0=>off
#DEFAULT: Sets for specific actions it's own values, which are known to be uncritical.
#
export USE_SUDO=${USE_SUDO:-DEFAULT}

#
#"sudo" requires a TTY, so switch it on in any case.
#This results in "-t -t" options for ssh, which forces the creation of a pseudo-tty 
#in any case.
#
if [ "${USE_SUDO}" == "1" ];then
    export C_SSH_PSEUDOTTY=2
else
    export C_SSH_PSEUDOTTY=${C_SSH_PSEUDOTTY:-DEFAULT}
fi

printDBG $S_CONF  ${D_FRAME} $LINENO $BASH_SOURCE "LOAD:USE_K5USERS=${USE_K5USERS}"
printDBG $S_CONF  ${D_FRAME} $LINENO $BASH_SOURCE "LOAD:USE_SUDO=${USE_SUDO}"



#################################################################
#
#Macros
#
CTYS_MACRO_DB=${CTYS_MACRO_DB:-$HOME/.ctys/macros/default}
if [ ! -f "${CTYS_MACRO_DB}" ];then
    CTYS_MACRO_DB=$MYCONFPATH/macros/default
fi

#
#The storage for pre-configured access-groups
#
CTYS_MACRO_TMPPATH=${CTYS_MACRO_TMPPATH:-$MYTMP/macros} 
if [ -z "${CTYS_MACRO_PATH}" ];then
    CTYS_MACRO_PATH="${CTYS_MACRO_PATH}:${HOME}/.ctys/macros"
    CTYS_MACRO_PATH="${CTYS_MACRO_PATH}:${MYCONFPATH}/macros"
    CTYS_MACRO_PATH="${CTYS_MACRO_PATH}:${CTYS_MACRO_TMPPATH}"
    CTYS_MACRO_PATH="${CTYS_MACRO_PATH}:${CTYS_PRIVATE}/tst/macros"
fi




#################################################################
#
#Misc
#

#Switches some coloring for keeywords on.
#Requires terminal to be capable of handling ESC sequences.
# 0=>on 1=>off
#
if [ -z "${CTYS_XTERM}" ];then
    if [ "${TERM}" == xterm ];then
	CTYS_XTERM=0
    else
	if [ "${TERM}" == dtterm ];then
	    CTYS_XTERM=0
	else
	    CTYS_XTERM=1
	fi
    fi
fi
if [ "${CTYS_XTERM}" == 0 ];then
    R_OPTS="${R_OPTS} -y ";
fi


#################################################################
#
#Deactivate groups caching
#
export NOGCACHE=${NOGCACHE:-1};



#################################################################
#
#Sets the base directory, where sockets of UNIX domain will be allocated.
#Due to security reasons, this is th only from-the-box supported approach
#
CTYS_SOCKBASE=${CTYS_SOCKBASE:-/var/tmp}


#################################################################
#
#Delay for "unlink" of temporary files.
#
export CTYS_UNLINKDELAY=20


#
#The signal spec to be ignored at command line by default, 
#when a tightly coupled CLI0 console is requested.
#Else is is the default for all asessions when "-S ON"
#is set.
#
CTYS_SIGIGNORESPEC="${CTYS_SIGIGNORESPEC:-2 3 19}"


#
#
export VNC_BASEPORT=${VNC_BASEPORT:-5900}

#
#
DEFAULT_STACKMODE=${DEFAULT_STACKMODE:-CONTROLLER}

#
#Timeout for first attempt to get dumpxml with virsh after initial start.
#WAIT unit is seconds, REPEAT unit is #nr
#the overall repetition is limited by CTYS_MAXRECURSE
#
CTYS_PRE_FETCHPID_WAIT=${CTYS_PRE_FETCHPID_WAIT:-2}
CTYS_PRE_FETCHPID_REPEAT=${CTYS_PRE_FETCHPID_REPEAT:-30}


#
#Timeout for polling the base IP stack mainly after initial start.
#WAIT unit is seconds, REPEAT unit is #nr.
#
CTYS_PING_ONE_MAXTRIAL=${CTYS_PING_ONE_MAXTRIAL:-30};
CTYS_PING_ONE_WAIT=${CTYS_PING_ONE_WAIT:-2};


#
#Timeout for polling the base SSH access, requires preconfigured permissions.
#WAIT unit is seconds, REPEAT unit is #nr.
#
CTYS_SSHPING_ONE_MAXTRIAL=${CTYS_SSHPING_ONE_MAXTRIAL:-30};
CTYS_SSHPING_ONE_WAIT=${CTYS_SSHPING_ONE_WAIT:-2};


#
#Default shell, might cause some effort to change!
#
CLISHELL=bash


#
#Default sessions to be killed during a CANCEL action on upper layers.
#This is due to performance enhancement a reduced set, because not all 
#support a CANCAL action at all.
#
CTYS_STACKERKILL_DEFAULT="XEN,QEMU,VMW"


[ -z "$CTYS_BROWSER" ]&&CTYS_BROWSER=`getPathName $LINENO $BASH_SOURCE WARNINGEXT firefox /usr/bin`


#
#The timeout of complete detach of the IO from a server process 
#for final stdio error traces.
#
CTYS_PREDETACH_TIMEOUT=20
CTYS_PREDETACH_TIMEOUT_HOSTS=3


#
#Optional: External kernel and initrd, when required customize it.
#Path could be absolute or relative to call directory.
#
#KERNELIMAGE="yourKernel"


#
#Optional: External kernel and initrd, when required customize it.
#Path could be absolute or relative to call directory.
#
#INITRDIMAGE="yourInitrd"


#
#For special-workaround when setting permission of vde_switch
#first bond-slave is dropped - after a "while", thus
#delay checks for some seconds.
#
NET_WAIT_BOND_WORKAROUND=${NET_WAIT_BOND_WORKAROUND:-8}


#
#Handling of free ports mainly for SSH-Tunnels
#
NET_PORTRANGE_MIN=20000
NET_PORTRANGE_MAX=21000
NET_PORTSEED=100
