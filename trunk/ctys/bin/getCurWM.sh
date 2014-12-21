#!/bin/bash

#FUNCBEG###############################################################
#NAME:
#  getCurWM.sh
#
#TYPE:
#  generic-script
#
#DESCRIPTION:
#  Used during bootstrap of each call to get current Release.
#
#EXAMPLE:
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
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


#
#check this is a X11 session
#
#TODO: Verify 3:VNC from "outside"
#
#OpenSUSE not by default!!!
# xwminfo -root>/dev/null 2>/dev/null
# if [ $? -ne 0 ];then
#     echo "ERROR:Cannot get \"xwminfo\"">&2
# fi

#
#check GNOME
if [ -z "$WM"  ];then
    if [ -n "$GNOME_DESKTOP_SESSION_ID" ];then
	WM=GNOME;
    fi
fi

#
#check KDE
if [ -z "$WM"  ];then
    if [ -n "$KDE_FULL_SESSION" -o -n "$KDE_SESSION_UID" -o -n "$KDE_SESSION_VERSION" ];then
	WM=KDE;
    fi
fi

#
#check XFCE


#
#check FVWM
if [ -z "$WM"  ];then
    if [ -n "$FVWM_MODULEDIR" ];then
	WM=FVWM;
    fi
fi



WM=${WM// /}
if [ -n "$WM" ];then
    echo -n $WM
    exit 0
fi
exit 1
