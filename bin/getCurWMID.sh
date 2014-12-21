#!/bin/bash

#FUNCBEG###############################################################
#NAME:
#  getCurWM.sh
#
#TYPE:
#  generic-script
#
#DESCRIPTION:
#  Checks whether running on CONSOLE, if not prints the WINDOWID.
#
#EXAMPLE:
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#    ${WINDOWID}
#      Is an XTerm
#    ''
#      Is CONSOLE
#
#FUNCEND###############################################################

CALLDIR=`dirname $0`

CUROS=`${CALLDIR}/getCurOS.sh`
CURDIST=`${CALLDIR}/getCurDistribution.sh`
CURREL=`${CALLDIR}/getCurRelease.sh`

WM=;

case $CUROS in
    Linux) 
        #ffs
	case "${CURDIST}" in
	    XenServer);;
	    ESX);;
	    ESXi)exit 1;;
	esac
	;;
    FreeBSD|OpenBSD)
	;;
    SunOS)
	;;
    *)
	exit 1
        ;;
esac


WM=$(getCurWM)

if [ -n "$WM"  ];then
    echo "$WINDOWID";
    exit 0;
fi
exit 1;
