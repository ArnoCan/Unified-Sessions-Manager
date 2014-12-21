#!/bin/bash
########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_10_013
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



#
#Common default anchors
#
DEFAULT_REPOSITORY_URL_BASE=${DEFAULT_REPOSITORY_URL_BASE:-http://delphi/isos}
DEFAULT_REPOSITORY_URL_RAW_BASE=${DEFAULT_REPOSITORY_URL_RAW_BASE:-http://delphi/UNIXDist}
DEFAULT_MOUNT_BASE=${DEFAULT_MOUNT_BASE:-/mntn/swpool}
INSTSRCCDROM_BASE=${INSTSRCCDROM_BASE:-$DEFAULT_MOUNT_BASE/UNIXDist}
INSTSRCFS_BASE=${INSTSRCFS_BASE:-$DEFAULT_MOUNT_BASE/isosrv}

DEFAULT_REPOSITORY_URL_MISCOS_BASE=${DEFAULT_REPOSITORY_URL_MISCOS_BASE:-http://delphi/miscOS}


DEFAULT_HTML_TMP_URL_BASE=${DEFAULT_HTML_TMP_URL_BASE:-http://delphi/tmp}




function fetchAvailableDefaults () {

    SOURCEDIR=${MYCONFPATH}/ctys-createConfVM.d/defaults-sources.d
    if [ -d "$SOURCEDIR" ];then
	for i in $SOURCEDIR/*.ctys;do
	    source ${i}
	done
    else
	ABORT=1;
	printERR $LINENO $BASH_SOURCE ${ABORT} "Missing configuration directory:$SOURCEDIR"
	gotoHell ${ABORT}
    fi




    case ${MYDIST} in
	CentOS)
	    case ${DIST} in
		CentOS)          set-CentOS;;
		debian)          set-debian;;
		Fedora)          set-Fedora;;
		FreeBSD)         set-FreeBSD;;
		Gentoo)          set-Gentoo;;
		Mandriva)        set-Mandriva;;
		OpenBSD)         set-OpenBSD;;
		OpenSolaris)     set-OpenSolaris;;
		openSUSE)        set-openSUSE;;
		Scientific)      set-Scientific;;
		Solaris)         set-Solaris;;
		Ubuntu)          set-Ubuntu;;

		MSProducts)      set-MSProducts;;

		BootStick)       set-BootSticks;;
	    esac
	    ;;

	openSUSE)
	    case ${DIST} in
		CentOS)          set-CentOS;;
		debian)          set-debian;;
		Fedora)          set-Fedora;;
		FreeBSD)         set-FreeBSD;;
		Gentoo)          set-Gentoo;;
		Mandriva)        set-Mandriva;;
		OpenBSD)         set-OpenBSD;;
		OpenSolaris)     set-OpenSolaris;;
		openSUSE)        set-openSUSE;;
		Scientific)      set-Scientific;;
		Solaris)         set-Solaris;;
		Ubuntu)          set-Ubuntu;;

		MSProducts)      set-MSProducts;;

		BootStick)       set-BootSticks;;
	    esac
	    ;;

	debian)
	    case ${DIST} in
		CentOS)          set-CentOS;;
		debian)          set-debian;;
		Fedora)          set-Fedora;;
		FreeBSD)         set-FreeBSD;;
		Gentoo)          set-Gentoo;;
		Mandriva)        set-Mandriva;;
		OpenBSD)         set-OpenBSD;;
		OpenSolaris)     set-OpenSolaris;;
		openSUSE)        set-openSUSE;;
		Scientific)      set-Scientific;;
		Solaris)         set-Solaris;;
		Ubuntu)          set-Ubuntu;;

		MSProducts)      set-MSProducts;;

		BootStick)       set-BootSticks;;
	    esac
	    ;;
    esac

}


