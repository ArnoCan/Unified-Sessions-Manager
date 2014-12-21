#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_02_007a17
#
########################################################################
#
# Copyright (C) 2007 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

MYANCHOR=$1
if [ ! -f "${MYANCHOR}" ];then
    echo "Missing given anchor file for configuration of new VM."
    echo "  MYANCHOR=${MYANCHOR}"
    exit 1
fi

MYCALLPREF=`dirname $0`

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
#pre-configured anchors
#
#. ${MYCALLPREF}/MYVM.anchor
. ${MYANCHORPATH}




#################
#
#derived hooks
#
MYVMBASE=`dirname ${MYVMPATH}`
MYIMAGE0=${MYVMPATH}/${MYDISK0}.img
MYKICKVM=${MYVMPATH}/${MYVM}.ks
MYKICKINST=${MYTMPNFS}/${MYVM}.ks

MYCONFINST=${MYVMPATH}/${MYVM}-inst.conf
MYCONFRT=${MYVMPATH}/${MYVM}.conf



##################
#
#Aliases for inbound file replacement
#

#List of aliasses to be replaced within MYCONFFILES
MYALIASES="MYVM MYDISK0 MYIMAGE0 MYMAC MYUUID MYKERNEL MYRAMDISK MYKICKINSTKS MYFTP"

#List of MYCONFFILES with aliasses to be replaced
MYCONFFILES="${MYCONFINST} ${MYCONFRT} ${MYKICKVM}"



#################
STARTTIME=`date +%H:%M:%S`

which xm 2>/dev/null >/dev/null
if [ $? != 0 ];then
    echo "Missing \"xm\", check your PATH"
    exit 1
fi



##################################################################
#0.prepare target
##################################################################
echo "Create directories for runtime environment"

if [ ! -d "${MYVMBASE}" ];then
    mkdir -p ${MYVMBASE}
fi

if [ ! -d "${MYVMPATH}" ];then
    mkdir ${MYVMPATH}
fi

##################################################################
#1. prepare runtime environment for install and post-install
##################################################################
echo "Copy configuration templates into runtime environment"

#make my embedded backup
tar zcf ${MYVMPATH}/${MYVM}.tgz ${MYCALLPREF}

#cp and rename
cp ${MYCALLPREF}/MYVM.conf  ${MYVMPATH}/${MYVM}.conf
cp ${MYCALLPREF}/MYVM.ctys  ${MYVMPATH}/${MYVM}.ctys
cp ${MYCALLPREF}/MYVM-inst.conf  ${MYVMPATH}/${MYVM}-inst.conf
cp ${MYCALLPREF}/MYVM.ks  ${MYVMPATH}/${MYVM}.ks


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


##################################################################
#2. create image
##################################################################
echo "Create image files for virtual storage"
#without pre-reserve
dd if=/dev/zero of=${MYIMAGE0} oflag=direct bs=1M count=1 seek=4095

#
#fully pre-reserved
#dd if=/dev/zero of=${MYIMAGE0} oflag=direct bs=1M count=4096


##################################################################
#3. call install VM as template for native install
##################################################################
echo "Copy kickstart file to target for NFS access"
#required for NFS-access by kernel to kickstart file
cp ${MYKICKVM} ${MYKICKINST}


echo "Start native install"
xm create ${MYCONFINST}

echo "Open text console"
xm console ${MYVM}

##################################################################
#4. call install VM as template for native install
##################################################################
echo "Start post install"
xm create ${MYCONFRT}

echo "Open text console"
xm console ${MYVM}




ENDTIME=`date +%H:%M:%S`
echo
echo "--------------------------"
echo
echo "Start at:    ${STARTTIME}"
echo "Finished at: ${ENDTIME}"
echo
echo "--------------------------"
echo
