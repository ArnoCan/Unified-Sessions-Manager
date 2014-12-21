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
#     Copyright (C) 2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
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

_myLIBNAME_base="${BASH_SOURCE}"
_myLIBVERS_base="01.11.011"

shopt -s nullglob
shopt -s extglob


#set for known WMs -> used in GUI functions
if [ -z "${MYWM}" ];then
    MYWM=$(${MYLIBEXECPATH}/getCurWM.sh)
fi


###############################################################
#                    Base definitions                          #
################################################################


#FUNCBEG###############################################################
#NAME:
#  guiCONFIRM
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
guiCONFIRM () {
    local _err=${1};shift
    printERR $LINENO $BASH_SOURCE "${_err}" "${*}"
    case "$MYWM" in
	GNOME)
	    zenity --question --text="${*}"
	    return $?
	    ;;
	KDE)
	    kdialog --yesno "${*}"
	    return $?
	    ;;
	*)
	    printERR $LINENO $BASH_SOURCE ${_err} "Gnome is required, the \nWindowManager=[${MYWM}]\n is not supported."
	    return ${_err}
	    ;;
    esac
}




#FUNCBEG###############################################################
#NAME:
#  guiERR
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
guiERR () {
    local _err=${1};shift
    printERR $LINENO $BASH_SOURCE "${_err}" "${*}"
    case "$MYWM" in
	GNOME)
	    zenity --error --text="${*}"
	    ;;
	KDE)
	    kdialog --error "${*}"
	    ;;
	*)
	    printERR $LINENO $BASH_SOURCE ${_err} "Gnome is required, the \nWindowManager=[${MYWM}]\n is not supported."
	    return ${_err}
	    ;;
    esac
}


#FUNCBEG###############################################################
#NAME:
#  guiWNG
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
guiWNG () {
    local _wng=${1};shift
    printWNG 1 $LINENO $BASH_SOURCE "$_wng" "${*}"
    case "$MYWM" in
	GNOME)
	    zenity --warning --text="${*}"
	    ;;
	KDE)
	    kdialog --sorry "${*}"
	    ;;
	*)
	    printERR $LINENO $BASH_SOURCE ${_wng} "Gnome is required, the \nWindowManager=[${MYWM}]\n is not supported."
	    return ${_wng}
	    ;;
    esac
}


#FUNCBEG###############################################################
#NAME:
#  guiINFO
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
guiINFO () {
    local _inf=${1};shift
    printINFO 2 $LINENO $BASH_SOURCE "$_inf" "${*}"
    case "$MYWM" in
	GNOME)
	    zenity --info --text="${*}"
	    ;;
	KDE)
	    kdialog --info "${*}"
	    ;;
	*)
	    printERR $LINENO $BASH_SOURCE ${_inf} "Gnome is required, the \nWindowManager=[${MYWM}]\n is not supported."
	    return ${_inf}
	    ;;
    esac
}



#FUNCBEG###############################################################
#NAME:
#  guiCHECKEXIT
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
guiCHECKEXIT () {
    case "$MYWM" in
	GNOME) ;;
	KDE) ;;
	*)
	    ABORT=2;
	    if [ -n "${MYWM}" ];then
		guiERR ${ABORT} "Gnome is required, the \nWindowManager=[${MYWM}]\n is not supported."
	    else
		printERR $LINENO $BASH_SOURCE ${ABORT} "Gnome is required, the \nWindowManager=[${MYWM}]\n is not supported."
	    fi
	    gotoHell ${ABORT}
	    ;;
    esac
}

#FUNCBEG###############################################################
#NAME:
#  guiCHECK
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: [WM]
#      Check also the exact windows manager
#
#  $2: [EXIT|SILENT]
#      EXIT
#        Exit process if fails
#      SILENT
#        No screen output, just return code.
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
guiCHECK () {
    ABORT=2;
    if [ -n "${MYWM}" ];then
	case "$1" in
	    WM)
		case "$MYWM" in
		    GNOME) ;;
		    KDE) ;;
		    *)
			case "$2" in
			    EXIT)
				guiERR ${ABORT} "Gnome or KDE is required, the \nWindowManager=[${MYWM}]\n is not supported."
				gotoHell ${ABORT}
				;;
			    SILENT)
				return 1
				;;
			    *)
				guiWNG ${ABORT} "Gnome or KDE is required, the \nWindowManager=[${MYWM}]\n may be erroneous."
				return 1
				;;
			esac
		esac
		;;
	esac
    else
	case "$2" in
	    EXIT)
		printERR $LINENO $BASH_SOURCE ${ABORT} "WindowManager is required."
		gotoHell ${ABORT}
		;;
	    SILENT)
		return 1
		;;
	    *)
		printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "WindowManager is required"
		return 1
		;;
	esac
    fi
}



MYINSTALLPATH=`getRealPathname ${MYLIBEXECPATHNAME}`
MYINSTALLPATH=${MYINSTALLPATH%/*/*}
printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "MYINSTALLPATH=${MYINSTALLPATH}"

