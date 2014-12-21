#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:
VERSION=01_06_001a03
#
########################################################################
#
# Copyright (C) 2007 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

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

#set this if required to one of:
#  "sudo "
#  "ksu -q -e "
#
#XMCALL=;

MYCALLPREF=`dirname $0`

MYPATTERN=${1:-default};shift
if [ ! -d "${MYPATTERN}" ];then
    echo "*****************************************"
    echo "Missing given pattern for install target."
    echo "  MYPATTERN=${MYPATTERN}"
    echo "*****************************************"
    exit 1
fi
echo
echo "###"
echo "Using:MYPATTERN=${MYPATTERN}"


MYANCHOR=${1:-$MYCALLPREF/$MYPATTERN/MYVM.anchor};shift
if [ ! -f "${MYANCHOR}" ];then
    echo "******************************************************"
    echo "Missing given anchor file for configuration of new VM."
    echo "  MYANCHOR=${MYANCHOR}"
    echo "******************************************************"
    exit 1
fi
echo
echo "###"
echo "Using:MYANCHOR=${MYANCHOR}"


MYANCHORPATH="${MYCALLPREF}/${MYANCHOR}"
if [ ! -f "${MYANCHORPATH}" ];then
    echo "Anchor file has to be within sub-tree of current template version."
    echo
    echo "  MYANCHORPATH=${MYANCHORPATH}"
    echo
    echo "Missing given anchor file for configuration of new VM within sub-tree."
    echo
    echo "  MYANCHOR=${MYANCHOR}"
    exit 1
fi


#
#pre-configured anchor
#
echo
echo "###"
echo "Source generic pattern from:"
echo "->${MYVMBASE}/${MYPATTERN}/MYVM.anchor"
. ${MYCALLPREF}/${MYPATTERN}/MYVM.anchor

echo
echo "###"
echo "Superpose custom entries from:"
echo "->${MYANCHORPATH}"
. ${MYANCHORPATH}




#################
#
#derived hooks
#
MYVMBASE=`dirname ${MYVMPATH}`
MYIMAGE0=${MYVMPATH}/${MYDISK0}.img
MYKICKVM=${MYVMPATH}/${MYVM}.ks
MYKICKSW=${MYVMPATH}/${MYVM}.sw

#using this for kernel CLI, has to be readable by the kernel during
#install.
MYKICKINST=${MYTMPNFS}/${MYVM}.ks

MYCONFINST=${MYVMPATH}/${MYVM}-inst.conf
MYCONFRT=${MYVMPATH}/${MYVM}.conf
MYCONFRT1=${MYVMPATH}/${MYVM}.ctys

MYHDD=${MYVMPATH}/${MYVM}-hdd.sh


##################
#
#Aliases for inbound file replacement
#


##################
#
#Aliases for inbound file replacement
#

#List of MYCONFFILES with aliasses to be replaced
MYCONFFILES="${MYCONFINST} ${MYCONFRT} ${MYCONFRT1} "
MYCONFFILES="${MYCONFFILES} ${MYKICKVM} ${MYKICKSW} ${MYHDD}"

#List of aliasses to be replaced within MYCONFFILES
if [ -z "${MYALIASES}" ];then
    echo
    echo "********************************************"
    echo "Missing \"MYALIASES\", check your anchor-file."
    echo "********************************************"
    exit 1
fi

#List of MYCONFFILES with aliasses to be replaced
if [ -z "${MYCONFFILES}" ];then
    echo
    echo "**********************************************"
    echo "Missing \"MYCONFFILES\", check your anchor-file."
    echo "**********************************************"
    exit 1
fi



#################
STARTTIME=`date +%H:%M:%S`

XM=xm
which $XM 2>/dev/null >/dev/null
if [ $? != 0 ];then
    XM=/usr/sbin/xm
    which $XM 2>/dev/null >/dev/null
    if [ $? != 0 ];then
        echo
	echo "*****************************"
	echo "Missing \"xm\", check your PATH"
	echo "*****************************"
	exit 1
    fi
fi

$XMCALL $XM info
if [ $? != 0 ];then
    echo
    echo "********************************************************"
    echo "Missing permissions for \"$XMCALL $XM\", check sudo/ksu."
    echo "Set XMCALL to "
    echo "  sudo"
    echo "  ksu -q -e"
    echo "********************************************************"
    exit 1
fi


##################################################################
#0.prepare target
##################################################################
echo
echo "###"
echo "Create directories for runtime environment"

echo
echo "###"
echo " MYVMBASE=${MYVMBASE}"
if [ ! -d "${MYVMBASE}" ];then
    mkdir -p ${MYVMBASE}
fi

echo
echo "###"
echo " MYVMPATH=${MYVMPATH}"
if [ ! -d "${MYVMPATH}" ];then
    mkdir ${MYVMPATH}
fi

##################################################################
#1. prepare runtime environment for install and post-install
##################################################################
echo
echo "###"
echo "Copy configuration templates into runtime environment"

#make my embedded backup
tar zcf ${MYVMPATH}/${MYVM}.tgz ${MYCALLPREF}/${MYPATTERN}

#cp and rename
cp ${MYCALLPREF}/${MYPATTERN}/MYVM.conf      ${MYVMPATH}/${MYVM}.conf
cp ${MYCALLPREF}/${MYPATTERN}/MYVM.ctys      ${MYVMPATH}/${MYVM}.ctys
cp ${MYCALLPREF}/${MYPATTERN}/MYVM-hdd.sh    ${MYVMPATH}/${MYVM}-hdd.sh
cp ${MYCALLPREF}/${MYPATTERN}/MYVM-inst.conf ${MYVMPATH}/${MYVM}-inst.conf
cp ${MYCALLPREF}/${MYPATTERN}/MYVM.ks        ${MYVMPATH}/${MYVM}.ks
cp ${MYCALLPREF}/${MYPATTERN}/MYVM.sw        ${MYVMPATH}/${MYVM}.sw


echo
echo "###"
echo "Adapt configuration to templates"
for f in ${MYCONFFILES};do
    echo "FILE:${f}"
    for i in ${MYALIASES};do
	icontent=`eval echo \\\${${i}}`
	echo "   ${i}->${icontent}"
	icontent="${icontent//\//\\/}"
	sed -i "s/%${i}%/${icontent}/g" ${f}
    done
done

echo
echo "###"
echo "Verify no remaining aliases to be replaced"
for f in ${MYCONFFILES};do
    echo "FILE:${f}"
    MATCH=`sed -n "/%[^%]*%/p" ${f}`
    if [ -n "$MATCH" ];then
	echo "Pattern found:"
	echo "---------------------------"
	echo $MATCH
	echo "---------------------------"
	MATCH=;
	MATCHED=1;
    fi
done
if [ -n "$MATCHED" ];then
    echo "**********************************"
    echo "Check pattern found and try again."
    echo "**********************************"
    exit 1
fi


##################################################################
#2. create image
##################################################################
echo
echo "###"
echo "Create image files for virtual storage"
sh ${MYHDD}


##################################################################
#3. call install VM as template for native install
##################################################################
echo
echo "###"
echo "Copy kickstart file to target for NFS access for guest OS"
#required for NFS-access by kernel to kickstart file
cp ${MYKICKVM} ${MYKICKINST}

echo
echo "###"
echo "Append selected SW"
#required for NFS-access by kernel to kickstart file
cat ${MYKICKSW}>>${MYKICKINST}


echo
echo "###"
echo "Start native install"
$XMCALL $XM create ${MYCONFINST}

echo
echo "###"
echo "Open text console"
$XMCALL $XM console ${MYVM}

echo
echo "###"
echo "Activate configuration file for ENUMERATE."
sed -i 's/#@#MAGICID-IGNORE/#@#MAGICID-XEN/' ${MYCONFRT}


##################################################################
#4. call install VM as template for native install
##################################################################
echo
echo "###"
echo "Start post install"
$XMCALL $XM create ${MYCONFRT}

echo
echo "###"
echo "Open text console"
$XMCALL $XM console ${MYVM}


ENDTIME=`date +%H:%M:%S`
echo "###"
echo
echo "-------------------------------"
echo
echo "Start at:    ${STARTTIME}"
echo "Finished at: ${ENDTIME}"
echo
echo "-------------------------------"
echo
