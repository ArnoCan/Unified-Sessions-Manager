#!/bin/bash

#FUNCBEG###############################################################
#NAME:
#  checkCLIDialogue.sh
#
#TYPE:
#  generic-script
#
#DESCRIPTION:
#  Checks whether running as GUI call without Dialogue-Console.
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


#in XTerm:
#WM=$(getCurWM)
if [ -n "$WINDOWID"  ];then
    exit 0;
fi

#in GUI, no CLI
if [ -n "$WINDOWPATH"  ];then
    exit 1;
fi

#assume for now CONSOLE
exit 0;
