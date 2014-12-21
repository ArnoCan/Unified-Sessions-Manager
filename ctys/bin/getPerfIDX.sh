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


################################################################
#                   Begin of FrameWork                         #
################################################################


#FUNCBEG###############################################################
#
#PROJECT:
MYPROJECT="Unified Sessions Manager"
#
#NAME:
#  getPerfIDX.sh
#
#AUTHOR:
AUTHOR="Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org"
#
#FULLNAME:
FULLNAME="Unified Sessions Manager"
#
#CALLFULLNAME:
CALLFULLNAME="Evaluates the performance index of current node for comparison."
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
#  Generic load simulation with some similarity to compiler 
#  requirements. This script is mainly to be used by ctys-genmconf.sh
#  and will be utilized for generation of the host-tables of 
#  dmucs in conjunction with compile-farms.
#
#EXAMPLE:
#
#PARAMETERS:
#  -X  terse
#      Short output for machine processing, no <CR>.
#      Else a "." and/or '*' is printed as progress indicator to stdout.
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


C_TERSE=0;
if [ "${*}" != "${*//-X/}" ];then
    C_TERSE=1
fi


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


################################################################
#    Default definitions - User-Customizable  from shell       #
################################################################


CALLIDX=$(date +"%H%M%S")$$
#
#Number of CPUs, which defined the parallel tasks
#
NUMCPU=1;
NUMCPU=$(getCPUinfo.sh);
NUMCPU=${NUMCPU#CPU:}
NUMCPU=${NUMCPU%%x*}

#
#Number of REP-loops to be performed.
#
ROUNDS=5;

#
#Number of repetition for "atomic" measurement unit.

#
#For CPU/MEM-Stress
#REP_CM=100;
REP_CM=50;

#
#For HDD-Ceche-Stress
REP_H_CACHE=50;

#
#For HDD-WriteThrough-Stress
REP_H_WTHROUGH=1

#
#Arrays are not the best choice for performance in bash,
#thus fit here perfectly.
#
declare -a DUMMY
export DUMMY
DUMMY=(
00 01 02 03 04 05 06 07
10 11 12 13 14 15 16 17
20 21 22 23 24 25 26 27
30 31 32 33 34 35 36 37
40 41 42 43 44 45 46 47
50 51 52 53 54 55 56 57
60 61 62 63 64 65 66 67
70 71 72 73 74 75 76 77
80 81 82 83 84 85 86 87
90 91 92 93 94 95 96 97
);
DUMMYLINE=10;


#
#Test filesystem
#TSTFS=/var/tmp
TSTFS=/tmp

#
###############
#
_ARGS=;
_ARGSCALL=$*;
_RUSER0=;


PROGRESS=0;
while [ -n "$1" ];do
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:\${1}=<${1}>"
    case $1 in
	'-H'|'--helpEx'|'-helpEx')shift;_HelpEx="${1:-$MYCALLNAME}";;
	'-h'|'--help'|'-help')_showToolHelp=1;;
	'-V')_printVersion=1;;
	'-X')C_TERSE=1;;

	'-d')shift;;

	--progress)PROGRESS=1;;


	--testfs|--testfs=*)
            ARG=${1#*=}; if [ "${1}" == "${ARG}" ];then shift; ARG=$1; fi

	    if [ -z "${ARG}" ];then
		ABORT=1;
		printERR $LINENO $BASH_SOURCE ${ABORT} "Missing filesystem argument:testfs"
		gotoHell ${ABORT}
	    fi

	    if [ ! -d "${ARG}" ];then
		ABORT=1;
		printERR $LINENO $BASH_SOURCE ${ABORT} "Missing filesytem:<${ARG}>"
		gotoHell ${ABORT}
	    fi
	    TSTFS=${ARG};
	    ;;

	--rounds|--rounds=*)
            ARG=${1#*=}; if [ "${1}" == "${ARG}" ];then shift; ARG=$1; fi

	    ROUNDS=${ARG%%\%*};
	    if [ -z "${ROUNDS}" -o -n "${ROUNDS//[0-9]/}" ];then
		ABORT=1;
		printERR $LINENO $BASH_SOURCE ${ABORT} "Missing valid numerical value:ROUNDS=<${ROUNDS}>"
		printERR $LINENO $BASH_SOURCE ${ABORT} "Input:<${ARG}>"
		gotoHell ${ABORT}
	    fi
	    if [ "${ROUNDS}" == "${ARG}" ];then
		ABORT=1;
		printERR $LINENO $BASH_SOURCE ${ABORT} "Missing option parts:<${ARG}>"
		printINFO 0 $LINENO $BASH_SOURCE 1 "Got    :<rounds>"
		printINFO 0 $LINENO $BASH_SOURCE 1 "Missing:<cpu-cycles>,<hdd-cache-cycles>,<hdd-write-through-cycles>"
		gotoHell ${ABORT}
	    fi
	    ARG=${ARG#*\%};

	    REP_CM=${ARG%%\%*};
	    if [ -z "${REP_CM}" -o -n "${REP_CM//[0-9]/}" ];then
		ABORT=1;
		printERR $LINENO $BASH_SOURCE ${ABORT} "Missing valid numerical value:REP_CM=<${REP_CM}>"
		printERR $LINENO $BASH_SOURCE ${ABORT} "Input:<${ARG}>"
		gotoHell ${ABORT}
	    fi
	    if [ "${REP_CM}" == "${ARG}" ];then
		ABORT=1;
		printERR $LINENO $BASH_SOURCE ${ABORT} "Missing option parts:<${ARG}>"
		printINFO 0 $LINENO $BASH_SOURCE 1 "Got    :<rounds>,<cpu-cycles>"
		printINFO 0 $LINENO $BASH_SOURCE 1 "Missing:<hdd-cache-cycles>,<hdd-write-through-cycles>"
		gotoHell ${ABORT}
	    fi
            ARG=${ARG#*\%};
	    
            REP_H_CACHE=${ARG%%\%*};
	    if [ -z "${REP_H_CACHE}" -o -n "${REP_H_CACHE//[0-9]/}" ];then
		ABORT=1;
		printERR $LINENO $BASH_SOURCE ${ABORT} "Missing valid numerical value:REP_H_CACHE=<${REP_H_CACHE}>"
		printERR $LINENO $BASH_SOURCE ${ABORT} "Input:<${ARG}>"
		gotoHell ${ABORT}
	    fi
	    if [ "${REP_H_CACHE}" == "${ARG}" ];then
		ABORT=1;
		printERR $LINENO $BASH_SOURCE ${ABORT} "Missing option parts:<${ARG}>"
		printINFO 0 $LINENO $BASH_SOURCE 1 "Got    :<rounds>,<cpu-cycles>,<hdd-cache-cycles>"
		printINFO 0 $LINENO $BASH_SOURCE 1 "Missing:<hdd-write-through-cycles>"
		gotoHell ${ABORT}
	    fi
            ARG=${ARG#*\%};

	    REP_H_WTHROUGH=${ARG%%\%*};
	    if [ -z "${REP_H_WTHROUGH}" -o -n "${REP_H_WTHROUGH//[0-9]/}" ];then
		ABORT=1;
		printERR $LINENO $BASH_SOURCE ${ABORT} "Missing valid numerical value:REP_H_WTHROUGH=<${REP_H_WTHROUGH}>"
		printERR $LINENO $BASH_SOURCE ${ABORT} "Input:<${ARG}>"
		gotoHell ${ABORT}
	    fi
	    ;;

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

idn=0;
idx=0;
function measureExec () {
    local REP_CM=${1:-100};
    local id=${2:-$((++idn))};
    local r=;
    local i=;
    local str=;

    for((r=0;r<REP_CM;r++));do
	[ "$PROGRESS" == 1 ]&&if((r%5==0));then echo -n "${id}";fi >&2
	for((i=0;i<${#DUMMY[@]};i++));do
	    local x1=${DUMMY[$i]};
	    let x=x+x1;
            str="$x${str}"
            echo $str>/dev/null
	done
    done
}


function measureHDDwrite () {
    local REP_H_CACHE=${1:-100};
    local BS=${2:-10k};
    local CNT=${3:-100};
    local FSx=${4:-$TSTFS};
    local r=;
    local i=;
    local str=;

    for((r=0;r<REP_H_CACHE;r++));do
	[ "$PROGRESS" == 1 ]&&if((r%5==0));then echo -n "*";else echo -n ".";fi >&2
	case ${MYDIST} in
	    SunOS)
		times dd if=/dev/zero of=${FSx}/$CALLIDX bs=$BS count=$CNT 2>&1|\
                   awk -v bs="${BS}" -v cnt="${CNT}"  '
                      BEGIN{x=0;}
                         x==1{
                          gsub("m"," ",$2);
                          gsub("s$","",$2);

                          min=$2;
                          gsub(" .*$","",min);
                          pos=match(min,"[.,]");
                          min=substr(min,1,pos-1)""substr(min,pos+1,3);

                          sec=$2;
                          gsub("^.* ","",sec);
                          pos=match(sec,"[.,]");
                          sec=substr(sec,1,pos-1)""substr(sec,pos+1,3);

                          xs=60*min+sec
                          if(xs==0){xs=1;}

                          if(bs~/k$/){gsub("k","",bs);}
                          if(bs~/M$/){gsub("M","",bs);bs*=1024;}
                          if(bs~/G$/){gsub("G","",bs);bs*=1024*1024;}
                          if(cnt~/k$/){gsub("k","",cnt);cnt*=1024;}
                          if(cnt~/M$/){gsub("M","",cnt);cnt*=1024*1024;}
                          if(cnt~/G$/){gsub("G","",cnt);cnt*=1024*1024*1024;}

                          mx=bs*cnt;
                          mbs=mx/xs;
                          mbs*=1000;
                          mbs/=1024;

                          print mbs;
                       }
                       {x=1}
                   '
		;;

	    *)
		dd if=/dev/zero of=${FSx}/$CALLIDX bs=$BS count=$CNT 2>&1|awk '
                   /MB\/s/{print $(NF-1);}
                   /bytes\/sec/{x=$(NF-1);gsub("\\(","",x);x/=1024*1024;print x;}
                   '
		;;
	esac
	rm -rf ${FSx}/${CALLIDX}
    done
}





###
 ###########
  ###########
 ###########
###


PVERS=${VERSION//_/}
if [ "$PROGRESS" == 1 ];then
    printf "\nPERFVERS=%s\n" ${PVERS} >&2
else
    [ "$C_TERSE" != 1 ]&&printf "\nPERFVERS=%s\n" ${PVERS} 
fi
[ "$C_TERSE" == 1 ]&&printf "PERFVERS:%s" ${PVERS}

#
#Exec-Performance
#
res=;
export -f measureExec

[ "$PROGRESS" == 1 ]&&printf "\nPERFEXEC(ROUNDS=%03d - CPU-cycles=%04d):CPU-Performance Measurement\n" ${ROUNDS} ${REP_CM} >&2
{
    [ "$PROGRESS" == 1 ]&&{ 
        echo -n "NUMCPU(${NUMCPU}="; 
        idx=a;
        for((j=0;j<NUMCPU;j++));do echo -n $idx;idx=$(echo -n $idx|tr 'a-y' 'b-z'); done; echo ')'; 
	}>&2
    for((i=0;i<${ROUNDS};i++));do
	[ "$PROGRESS" == 1 ]&&printf "\n%03d:" ${i}>&2
	idx=a;
 	for((j=0;j<NUMCPU;j++));do                
            {   eval measureExec ${REP_CM} $idx; } &
	    idx=$(echo $idx|tr 'a-y' 'b-z');
	done
	wait; 
    done
    [ "$PROGRESS" == 1 ]&&echo>&2
    times
}|awk -v p="${PROGRESS}" -v t="${C_TERSE}" '
         BEGIN{x=0;}
         x==1{
            gsub("m"," ",$2);
            gsub("s$","",$2);

            min=$2;
            gsub(" .*$","",min);
            pos=match(min,"[.,]");
            min=substr(min,1,pos-1)""substr(min,pos+1,3);

            sec=$2;
            gsub("^.* ","",sec);
            pos=match(sec,"[.,]");
            sec=substr(sec,1,pos-1)""substr(sec,pos+1,3);

            x=60*min+sec

            if(p==1){print "PERFEXEC:"x"(msecs systime)"|"cat 1>&2"}
            else{
               if(t!=1){print "PERFEXEC:"x"(msecs systime)"}
            }
            if(t==1){printf(",PERFEXEC:%d",x);}
         }
         {x=1}'


#
#HDD-Cache-Performance
#
res=;
export -f measureHDDwrite
[ "$PROGRESS" == 1 ]&&printf "\n\nPERFHDDCACHE(100*10k - ROUNDS=%03d - cycles=%03d):HDD-Cache Measurement\n" ${ROUNDS} ${REP_H_CACHE}>&2
for((i=0;i<${ROUNDS};i++));do
    [ "$PROGRESS" == 1 ]&&printf "\n%03d:" ${i} >&2
    measureHDDwrite ${REP_H_CACHE} 10k 100 ${TSTFS}
done |awk -v p="${PROGRESS}" -v t="${C_TERSE}" -v fs="${TSTFS}" '
  BEGIN{x=0;c=0;}
  /^[0-9][0-9][0-9]:/&&p==1{print|"cat 1>&2";}
  /^[0-9][0-9,.]*$/{x+=$1;c++;}
  END{
     if(c!=0)x=x/c;
     if(p==1){printf("\nPERFHDDCACHE(100*10k):%dMB/sec\non %s\n",x,fs)|"cat 1>&2";}
     else{
        if(t!=1){printf("\nPERFHDDCACHE(100*10k):%dMB/sec\non %s\n",x,fs);}
     }
     if(t==1){printf(",PERFHDDCACHE:%d",x);}
  }'



#
#HDD-Write-Through-Performance
#
res=;


#expect M-megabyte
RAM=$(getMEMinfo.sh)
RAM=${RAM#*RAM:}
RAM=${RAM%%[^0-9]*}
DOUBLERAM=$((2*RAM));

#expect G-gigabyte
FSSIZE=$(getFSinfo /var)
FSSIZE=${FSSIZE##*-}
FSSIZE=${FSSIZE%%[^0-9.]*}
FSSIZE=$(echo|awk -v fs="$FSSIZE" '{print int(fs*1024);}')

if [ -z "${DOUBLERAM}" ];then
    ABORT=2;
    printERR $LINENO $BASH_SOURCE ${ABORT} "Cannot evaluate:RAM Size"
    gotoHell ${ABORT}
fi
if [ -z "${FSSIZE}" ];then
    ABORT=2;
    printERR $LINENO $BASH_SOURCE ${ABORT} "Cannot evaluate:File System Size"
    gotoHell ${ABORT}
fi

if [ ${DOUBLERAM} -gt ${FSSIZE} ];then
    printWNG 1 $LINENO $BASH_SOURCE 1  "Low resources for HDD-Write-Through-Performance measurement"
    printWNG 1 $LINENO $BASH_SOURCE 1  "Senseful test requires: DOUBLERAM(${DOUBLERAM})<(2+n)*FSSIZE(${FSSIZE})"
    printINFO 1 $LINENO $BASH_SOURCE 1 "Setting:DOUBLERAM=${DOUBLERAM} to FSSIZE/2=$((FSSIZE/2))"
    DOUBLERAM=$((FSSIZE/2))
fi

export -f measureHDDwrite
[ "$PROGRESS" == 1 ]&&printf "\n\nPERFHDDWRITETHROUGH(SIZE=%dMB - 2*RAM=%dMB - ROUNDS=%03d):HDD-Write-Through Measurement\n" ${FSSIZE} ${DOUBLERAM} ${REP_H_WTHROUGH} >&2
for((i=0;i<1;i++));do
    [ "$PROGRESS" == 1 ]&&printf "\n%03d:" ${i}>&2
    measureHDDwrite ${REP_H_WTHROUGH}  1000k ${DOUBLERAM} ${TSTFS}
done |awk -v p="${PROGRESS}" -v dr="${DOUBLERAM}" -v t="${C_TERSE}"  -v fs="${TSTFS}" '
  BEGIN{x=0;c=0;}
  /^[0-9][0-9][0-9]:/&&p==1{print|"cat 1>&2";}
  /^[0-9][0-9,.]*$/{x+=$1;c++;}
  END{
     if(c!=0)x=x/c;
     if(p==1){printf("\nPERFHDDWRITETHROUGH(1*%sM):%dMB/sec\non %s\n",dr,x,fs)|"cat 1>&2";}
     else{
        if(t!=1){printf("\nPERFHDDWRITETHROUGH(1*%sM):%dMB/sec\non %s\n",dr,x,fs);}
     }
     if(t==1){printf(",PERFHDDWRITETHROUGH:%d",x);}
  }'

[ "$PROGRESS" == 1 ]&&echo;

