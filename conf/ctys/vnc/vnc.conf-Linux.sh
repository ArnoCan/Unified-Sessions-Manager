#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_011
#
########################################################################
#
# Copyright (C) 2007,2008,2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

########################################################################
#
#     Copyright (C) 2007,2008,2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
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

################################################################
#    Default definitions - User-Customizable  from shell       #
################################################################

export VNC_BASEPORT=${VNC_BASEPORT:-5900}
export VNCACCESSPORT;
export VNCACCESSDISPLAY;

#avoids race conditions "lazy release vs. hungry allocation"
VNCPORTSEED=10;

#make all specific, due to frequent minimal deviation, BUT A DEVIATION, for what ever reason???!!!
#
#ffs.:"copyrect"
#keep "hextile" for being generic for VMware-WS6 too(see pg. 183).
#
case ${MYDIST} in
    ESX)
	[ -z "$VNCVEXE" ]&&VNCVEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vncviewer /usr/bin`
	[ -z "$VNCSEXE" ]&&VNCSEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vncserver /usr/bin`
	[ -z "$VNCPEXE" ]&&VNCPEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vncpasswd /usr/bin`

        #vncviewer - passed through by wrapper
	VNCVIEWER_NATIVE=${VNCVIEWER_NATIVE:-$VNCVEXE}
	[ -z "${VNCVIEWER_OPT_RealVNC4}" ]&&VNCVIEWER_OPT_RealVNC4="   -PreferredEncoding hextile  -FullColour -AutoSelect=0 -Shared=1 "
	[ -z "${VNCVIEWER_OPT_RealVNC}" ]&&VNCVIEWER_OPT_RealVNC="    -PreferredEncoding hextile  -FullColour -AutoSelect=0 -Shared=1 "
	[ -z "${VNCVIEWER_OPT_TigerVNC}" ]&&VNCVIEWER_OPT_TigerVNC="   -PreferredEncoding hextile  -FullColour -AutoSelect=0 -Shared=1 "
	[ -z "${VNCVIEWER_OPT_TightVNC}" ]&&VNCVIEWER_OPT_TightVNC="   -encodings         hextile  -truecolour  -shared "
	[ -z "${VNCVIEWER_OPT_GENERIC}" ]&&VNCVIEWER_OPT_GENERIC=""

        #vncserver - passed through by wrapper
	VNCSERVER_NATIVE=${VNCSERVER_NATIVE:-$VNCSEXE}
	[ -z "${VNCSERVER_OPT_RealVNC4}" ]&&VNCSERVER_OPT_RealVNC4="   -depth 24 -geometry 1268x994 -localhost -nolisten tcp -nohttpd "
	[ -z "${VNCSERVER_OPT_RealVNC}" ]&&VNCSERVER_OPT_RealVNC="    -depth 24 -geometry 1268x994 -localhost -nolisten tcp -nohttpd "
	[ -z "${VNCSERVER_OPT_TigerVNC}" ]&&VNCSERVER_OPT_TigerVNC="   -depth 24 -geometry 1268x994 -localhost -nolisten tcp "
	[ -z "${VNCSERVER_OPT_TightVNC}" ]&&VNCSERVER_OPT_TightVNC="   -depth 24 -geometry 1268x994 -localhost -nolisten tcp "
	[ -z "${VNCSERVER_OPT_GENERIC}" ]&&VNCSERVER_OPT_GENERIC="    -depth 24 -geometry 1268x994 -localhost -nolisten tcp "
	;;
    XenServer)
	[ -z "$VNCVEXE" ]&&VNCVEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vncviewer /usr/bin`
	[ -z "$VNCSEXE" ]&&VNCSEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vncserver /usr/bin`
	[ -z "$VNCPEXE" ]&&VNCPEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vncpasswd /usr/bin`

        #vncviewer - passed through by wrapper
	VNCVIEWER_NATIVE=${VNCVIEWER_NATIVE:-$VNCVEXE}
	[ -z "${VNCVIEWER_OPT_RealVNC4}" ]&&VNCVIEWER_OPT_RealVNC4="   -PreferredEncoding hextile  -FullColour -AutoSelect=0 -Shared=1 "
	[ -z "${VNCVIEWER_OPT_RealVNC}" ]&&VNCVIEWER_OPT_RealVNC="    -PreferredEncoding hextile  -FullColour -AutoSelect=0 -Shared=1 "
	[ -z "${VNCVIEWER_OPT_TigerVNC}" ]&&VNCVIEWER_OPT_TigerVNC="   -PreferredEncoding hextile  -FullColour -AutoSelect=0 -Shared=1 "
	[ -z "${VNCVIEWER_OPT_TightVNC}" ]&&VNCVIEWER_OPT_TightVNC="   -encodings         hextile  -truecolour  -shared "
	[ -z "${VNCVIEWER_OPT_GENERIC}" ]&&VNCVIEWER_OPT_GENERIC=""

        #vncserver - passed through by wrapper
	VNCSERVER_NATIVE=${VNCSERVER_NATIVE:-$VNCSEXE}
	[ -z "${VNCSERVER_OPT_RealVNC4}" ]&&VNCSERVER_OPT_RealVNC4="   -depth 24 -geometry 1268x994 -localhost -nolisten tcp -nohttpd "
	[ -z "${VNCSERVER_OPT_RealVNC}" ]&&VNCSERVER_OPT_RealVNC="    -depth 24 -geometry 1268x994 -localhost -nolisten tcp -nohttpd "
	[ -z "${VNCSERVER_OPT_TigerVNC}" ]&&VNCSERVER_OPT_TigerVNC="   -depth 24 -geometry 1268x994 -localhost -nolisten tcp "
	[ -z "${VNCSERVER_OPT_TightVNC}" ]&&VNCSERVER_OPT_TightVNC="   -depth 24 -geometry 1268x994 -localhost -nolisten tcp "
	[ -z "${VNCSERVER_OPT_GENERIC}" ]&&VNCSERVER_OPT_GENERIC="    -depth 24 -geometry 1268x994 -localhost -nolisten tcp "
	;;
    CentOS)
	[ -z "$VNCVEXE" ]&&VNCVEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vncviewer /usr/bin`
	[ -z "$VNCSEXE" ]&&VNCSEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vncserver /usr/bin`
	[ -z "$VNCPEXE" ]&&VNCPEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vncpasswd /usr/bin`

        #vncviewer - passed through by wrapper
	VNCVIEWER_NATIVE=${VNCVIEWER_NATIVE:-$VNCVEXE}
	[ -z "${VNCVIEWER_OPT_RealVNC4}" ]&&VNCVIEWER_OPT_RealVNC4="   -PreferredEncoding hextile  -FullColour -AutoSelect=0 -Shared=1 "
	[ -z "${VNCVIEWER_OPT_RealVNC}" ]&&VNCVIEWER_OPT_RealVNC="    -PreferredEncoding hextile  -FullColour -AutoSelect=0 -Shared=1 "
	[ -z "${VNCVIEWER_OPT_TigerVNC}" ]&&VNCVIEWER_OPT_TigerVNC="   -PreferredEncoding hextile  -FullColour -AutoSelect=0 -Shared=1 "
	[ -z "${VNCVIEWER_OPT_TightVNC}" ]&&VNCVIEWER_OPT_TightVNC="   -encodings         hextile  -truecolour  -shared "
	[ -z "${VNCVIEWER_OPT_GENERIC}" ]&&VNCVIEWER_OPT_GENERIC=""

        #vncserver - passed through by wrapper
	VNCSERVER_NATIVE=${VNCSERVER_NATIVE:-$VNCSEXE}
	[ -z "${VNCSERVER_OPT_RealVNC4}" ]&&VNCSERVER_OPT_RealVNC4="   -depth 24 -geometry 1268x994 -localhost -nolisten tcp -nohttpd "
	[ -z "${VNCSERVER_OPT_RealVNC}" ]&&VNCSERVER_OPT_RealVNC="    -depth 24 -geometry 1268x994 -localhost -nolisten tcp -nohttpd "
	[ -z "${VNCSERVER_OPT_TigerVNC}" ]&&VNCSERVER_OPT_TigerVNC="   -depth 24 -geometry 1268x994 -localhost -nolisten tcp "
	[ -z "${VNCSERVER_OPT_TightVNC}" ]&&VNCSERVER_OPT_TightVNC="   -depth 24 -geometry 1268x994 -localhost -nolisten tcp "
	[ -z "${VNCSERVER_OPT_GENERIC}" ]&&VNCSERVER_OPT_GENERIC="    -depth 24 -geometry 1268x994 -localhost -nolisten tcp "
	;;
    EnterpriseLinux)
	[ -z "$VNCVEXE" ]&&VNCVEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vncviewer /usr/bin`
	[ -z "$VNCSEXE" ]&&VNCSEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vncserver /usr/bin`
	[ -z "$VNCPEXE" ]&&VNCPEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vncpasswd /usr/bin`

        #vncviewer - passed through by wrapper
	VNCVIEWER_NATIVE=${VNCVIEWER_NATIVE:-$VNCVEXE}
	[ -z "${VNCVIEWER_OPT_RealVNC4}" ]&&VNCVIEWER_OPT_RealVNC4="   -PreferredEncoding hextile  -FullColour -AutoSelect=0 -Shared=1 "
	[ -z "${VNCVIEWER_OPT_RealVNC}" ]&&VNCVIEWER_OPT_RealVNC="    -PreferredEncoding hextile  -FullColour -AutoSelect=0 -Shared=1 "
	[ -z "${VNCVIEWER_OPT_TigerVNC}" ]&&VNCVIEWER_OPT_TigerVNC="   -PreferredEncoding hextile  -FullColour -AutoSelect=0 -Shared=1 "
	[ -z "${VNCVIEWER_OPT_TightVNC}" ]&&VNCVIEWER_OPT_TightVNC="   -encodings         hextile  -truecolour  -shared "
	[ -z "${VNCVIEWER_OPT_GENERIC}" ]&&VNCVIEWER_OPT_GENERIC=""

        #vncserver - passed through by wrapper
	VNCSERVER_NATIVE=${VNCSERVER_NATIVE:-$VNCSEXE}
	[ -z "${VNCSERVER_OPT_RealVNC4}" ]&&VNCSERVER_OPT_RealVNC4="   -depth 24 -geometry 1268x994 -localhost -nolisten tcp -nohttpd "
	[ -z "${VNCSERVER_OPT_RealVNC}" ]&&VNCSERVER_OPT_RealVNC="    -depth 24 -geometry 1268x994 -localhost -nolisten tcp -nohttpd "
	[ -z "${VNCSERVER_OPT_TigerVNC}" ]&&VNCSERVER_OPT_TigerVNC="   -depth 24 -geometry 1268x994 -localhost -nolisten tcp "
	[ -z "${VNCSERVER_OPT_TightVNC}" ]&&VNCSERVER_OPT_TightVNC="   -depth 24 -geometry 1268x994 -localhost -nolisten tcp "
	[ -z "${VNCSERVER_OPT_GENERIC}" ]&&VNCSERVER_OPT_GENERIC="    -depth 24 -geometry 1268x994 -localhost -nolisten tcp "
	;;
    RHEL)
	[ -z "$VNCVEXE" ]&&VNCVEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vncviewer /usr/bin`
	[ -z "$VNCSEXE" ]&&VNCSEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vncserver /usr/bin`
	[ -z "$VNCPEXE" ]&&VNCPEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vncpasswd /usr/bin`

        #vncviewer - passed through by wrapper
	VNCVIEWER_NATIVE=${VNCVIEWER_NATIVE:-$VNCVEXE}
	[ -z "${VNCVIEWER_OPT_RealVNC4}" ]&&VNCVIEWER_OPT_RealVNC4="   -PreferredEncoding hextile  -FullColour -AutoSelect=0 -Shared=1 "
	[ -z "${VNCVIEWER_OPT_RealVNC}" ]&&VNCVIEWER_OPT_RealVNC="    -PreferredEncoding hextile  -FullColour -AutoSelect=0 -Shared=1 "
	[ -z "${VNCVIEWER_OPT_TigerVNC}" ]&&VNCVIEWER_OPT_TigerVNC="   -PreferredEncoding hextile  -FullColour -AutoSelect=0 -Shared=1 "
	[ -z "${VNCVIEWER_OPT_TightVNC}" ]&&VNCVIEWER_OPT_TightVNC="   -encodings         hextile  -truecolour  -shared "
	[ -z "${VNCVIEWER_OPT_GENERIC}" ]&&VNCVIEWER_OPT_GENERIC=""

        #vncserver - passed through by wrapper
	VNCSERVER_NATIVE=${VNCSERVER_NATIVE:-$VNCSEXE}
	[ -z "${VNCSERVER_OPT_RealVNC4}" ]&&VNCSERVER_OPT_RealVNC4="   -depth 24 -geometry 1268x994 -localhost -nolisten tcp -nohttpd "
	[ -z "${VNCSERVER_OPT_RealVNC}" ]&&VNCSERVER_OPT_RealVNC="    -depth 24 -geometry 1268x994 -localhost -nolisten tcp -nohttpd "
	[ -z "${VNCSERVER_OPT_TigerVNC}" ]&&VNCSERVER_OPT_TigerVNC="   -depth 24 -geometry 1268x994 -localhost -nolisten tcp "
	[ -z "${VNCSERVER_OPT_TightVNC}" ]&&VNCSERVER_OPT_TightVNC="   -depth 24 -geometry 1268x994 -localhost -nolisten tcp "
	[ -z "${VNCSERVER_OPT_GENERIC}" ]&&VNCSERVER_OPT_GENERIC="    -depth 24 -geometry 1268x994 -localhost -nolisten tcp "
	;;
    Scientific)
	[ -z "$VNCVEXE" ]&&VNCVEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vncviewer /usr/bin`
	[ -z "$VNCSEXE" ]&&VNCSEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vncserver /usr/bin`
	[ -z "$VNCPEXE" ]&&VNCPEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vncpasswd /usr/bin`

        #vncviewer - passed through by wrapper
	VNCVIEWER_NATIVE=${VNCVIEWER_NATIVE:-$VNCVEXE}
	[ -z "${VNCVIEWER_OPT_RealVNC4}" ]&&VNCVIEWER_OPT_RealVNC4="   -PreferredEncoding hextile  -FullColour -AutoSelect=0 -Shared=1 "
	[ -z "${VNCVIEWER_OPT_RealVNC}" ]&&VNCVIEWER_OPT_RealVNC="    -PreferredEncoding hextile  -FullColour -AutoSelect=0 -Shared=1 "
	[ -z "${VNCVIEWER_OPT_TightVNC}" ]&&VNCVIEWER_OPT_TightVNC="   -PreferredEncoding hextile  -FullColour -AutoSelect=0 -Shared=1 "
	[ -z "${VNCVIEWER_OPT_TigerVNC}" ]&&VNCVIEWER_OPT_TigerVNC="   -encodings         hextile  -truecolour  -shared "
	[ -z "${VNCVIEWER_OPT_GENERIC}" ]&&VNCVIEWER_OPT_GENERIC=""

        #vncserver - passed through by wrapper
	VNCSERVER_NATIVE=${VNCSERVER_NATIVE:-$VNCSEXE}
	[ -z "${VNCSERVER_OPT_RealVNC4}" ]&&VNCSERVER_OPT_RealVNC4="   -depth 24 -geometry 1268x994 -localhost -nolisten tcp -nohttpd "
	[ -z "${VNCSERVER_OPT_RealVNC}" ]&&VNCSERVER_OPT_RealVNC="    -depth 24 -geometry 1268x994 -localhost -nolisten tcp -nohttpd "
	[ -z "${VNCSERVER_OPT_TigerVNC}" ]&&VNCSERVER_OPT_TigerVNC="   -depth 24 -geometry 1268x994 -localhost -nolisten tcp "
	[ -z "${VNCSERVER_OPT_TightVNC}" ]&&VNCSERVER_OPT_TightVNC="   -depth 24 -geometry 1268x994 -localhost -nolisten tcp "
	[ -z "${VNCSERVER_OPT_GENERIC}" ]&&VNCSERVER_OPT_GENERIC="    -depth 24 -geometry 1268x994 -localhost -nolisten tcp "
	;;
    Fedora)
	[ -z "$VNCVEXE" ]&&VNCVEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vncviewer /usr/bin`
	[ -z "$VNCSEXE" ]&&VNCSEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vncserver /usr/bin`
	[ -z "$VNCPEXE" ]&&VNCPEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vncpasswd /usr/bin`

        #vncviewer - passed through by wrapper
	VNCVIEWER_NATIVE=${VNCVIEWER_NATIVE:-$VNCVEXE}
	[ -z "${VNCVIEWER_OPT_RealVNC4}" ]&&VNCVIEWER_OPT_RealVNC4="   -PreferredEncoding hextile  -FullColour -AutoSelect=0 -Shared=1 "
	[ -z "${VNCVIEWER_OPT_RealVNC}" ]&&VNCVIEWER_OPT_RealVNC="    -PreferredEncoding hextile  -FullColour -AutoSelect=0 -Shared=1 "
	[ -z "${VNCVIEWER_OPT_TigerVNC}" ]&&VNCVIEWER_OPT_TigerVNC="   -PreferredEncoding hextile  -FullColour -AutoSelect=0 -Shared=1 "
	[ -z "${VNCVIEWER_OPT_TightVNC}" ]&&VNCVIEWER_OPT_TightVNC="   -encodings         hextile  -truecolour  -shared "
	[ -z "${VNCVIEWER_OPT_GENERIC}" ]&&VNCVIEWER_OPT_GENERIC=""

        #vncserver - passed through by wrapper
	VNCSERVER_NATIVE=${VNCSERVER_NATIVE:-$VNCSEXE}
	[ -z "${VNCSERVER_OPT_RealVNC4}" ]&&VNCSERVER_OPT_RealVNC4="   -depth 24 -geometry 1268x994 -localhost -nolisten tcp -nohttpd "
	[ -z "${VNCSERVER_OPT_RealVNC}" ]&&VNCSERVER_OPT_RealVNC="    -depth 24 -geometry 1268x994 -localhost -nolisten tcp -nohttpd "
	[ -z "${VNCSERVER_OPT_TigerVNC}" ]&&VNCSERVER_OPT_TigerVNC="   -depth 24 -geometry 1268x994 -localhost -nolisten tcp "
	[ -z "${VNCSERVER_OPT_TightVNC}" ]&&VNCSERVER_OPT_TightVNC="   -depth 24 -geometry 1268x994 -localhost -nolisten tcp "
	[ -z "${VNCSERVER_OPT_GENERIC}" ]&&VNCSERVER_OPT_GENERIC="    -depth 24 -geometry 1268x994 -localhost -nolisten tcp "
	;;
    SuSE)
	[ -z "$VNCVEXE" ]&&VNCVEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vncviewer /usr/X11R6/bin`
	[ -z "$VNCSEXE" ]&&VNCSEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vncserver /usr/X11R6/bin`
	[ -z "$VNCPEXE" ]&&VNCPEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vncpasswd /usr/X11R6/bin`

        #vncviewer - passed through by wrapper
	VNCVIEWER_NATIVE=${VNCVIEWER_NATIVE:-$VNCVEXE}
	[ -z "${VNCVIEWER_OPT_RealVNC4}" ]&&VNCVIEWER_OPT_RealVNC4="   -PreferredEncoding hextile  -FullColour -AutoSelect=0 -Shared=1 "
	[ -z "${VNCVIEWER_OPT_RealVNC}" ]&&VNCVIEWER_OPT_RealVNC="    -PreferredEncoding hextile  -FullColour -AutoSelect=0 -Shared=1 "
	[ -z "${VNCVIEWER_OPT_TigerVNC}" ]&&VNCVIEWER_OPT_TigerVNC="   -PreferredEncoding hextile  -FullColour -AutoSelect=0 -Shared=1 "
	[ -z "${VNCVIEWER_OPT_TightVNC}" ]&&VNCVIEWER_OPT_TightVNC="   -encodings         hextile  -truecolour  -shared "
	[ -z "${VNCVIEWER_OPT_GENERIC}" ]&&VNCVIEWER_OPT_GENERIC=""

        #vncserver - passed through by wrapper
	VNCSERVER_NATIVE=${VNCSERVER_NATIVE:-$VNCSEXE}
	[ -z "${VNCSERVER_OPT_RealVNC4}" ]&&VNCSERVER_OPT_RealVNC4="   -depth 24 -geometry 1268x994 -localhost -nolisten tcp -nohttpd "
	[ -z "${VNCSERVER_OPT_RealVNC}" ]&&VNCSERVER_OPT_RealVNC="    -depth 24 -geometry 1268x994 -localhost -nolisten tcp -nohttpd "
	[ -z "${VNCSERVER_OPT_TigerVNC}" ]&&VNCSERVER_OPT_TigerVNC="   -depth 24 -geometry 1268x994 -localhost -nolisten tcp "
	[ -z "${VNCSERVER_OPT_TightVNC}" ]&&VNCSERVER_OPT_TightVNC="   -depth 24 -geometry 1268x994 -localhost -nolisten tcp "
	[ -z "${VNCSERVER_OPT_GENERIC}" ]&&VNCSERVER_OPT_GENERIC="    -depth 24 -geometry 1268x994 -localhost -nolisten tcp "
	;;
    openSUSE)
	[ -z "$VNCVEXE" ]&&VNCVEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vncviewer /usr/bin`
	[ -z "$VNCSEXE" ]&&VNCSEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vncserver /usr/bin`
	[ -z "$VNCPEXE" ]&&VNCPEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vncpasswd /usr/bin`

        #vncviewer - passed through by wrapper
	VNCVIEWER_NATIVE=${VNCVIEWER_NATIVE:-$VNCVEXE}
	[ -z "${VNCVIEWER_OPT_RealVNC4}" ]&&VNCVIEWER_OPT_RealVNC4="  -PreferredEncoding hextile  -FullColour -AutoSelect=0 -Shared=1 "
	[ -z "${VNCVIEWER_OPT_RealVNC}" ]&&VNCVIEWER_OPT_RealVNC="   -PreferredEncoding hextile  -FullColour -AutoSelect=0 -Shared=1 "
	[ -z "${VNCVIEWER_OPT_TigerVNC}" ]&&VNCVIEWER_OPT_TigerVNC="  -PreferredEncoding hextile  -FullColour -AutoSelect=0 -Shared=1 "
	[ -z "${VNCVIEWER_OPT_TightVNC}" ]&&VNCVIEWER_OPT_TightVNC="  -encodings         hextile  -truecolour  -shared "
	[ -z "${VNCVIEWER_OPT_GENERIC}" ]&&VNCVIEWER_OPT_GENERIC=""

        #vncserver - passed through by wrapper
	VNCSERVER_NATIVE=${VNCSERVER_NATIVE:-$VNCSEXE}
	[ -z "${VNCSERVER_OPT_RealVNC4}" ]&&VNCSERVER_OPT_RealVNC4="  -depth 24 -geometry 1268x994 -localhost -nolisten tcp -nohttpd "
	[ -z "${VNCSERVER_OPT_RealVNC}" ]&&VNCSERVER_OPT_RealVNC="   -depth 24 -geometry 1268x994 -localhost -nolisten tcp -nohttpd "
	[ -z "${VNCSERVER_OPT_TigerVNC}" ]&&VNCSERVER_OPT_TigerVNC="  -depth 24 -geometry 1268x994 -localhost -nolisten tcp "
	[ -z "${VNCSERVER_OPT_TightVNC}" ]&&VNCSERVER_OPT_TightVNC="  -depth 24 -geometry 1268x994 -localhost -nolisten tcp "
	[ -z "${VNCSERVER_OPT_GENERIC}" ]&&VNCSERVER_OPT_GENERIC="   -depth 24 -geometry 1268x994 -localhost -nolisten tcp "
	;;
    debian)
	[ -z "$VNCVEXE" ]&&VNCVEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vncviewer /usr/bin`
	[ -z "$VNCSEXE" ]&&VNCSEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vncserver /usr/bin`
	[ -z "$VNCPEXE" ]&&VNCPEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vncpasswd /usr/bin`

        #vncviewer - passed through by wrapper
	VNCVIEWER_NATIVE=${VNCVIEWER_NATIVE:-$VNCVEXE}
	[ -z "${VNCVIEWER_OPT_RealVNC}" ]&&VNCVIEWER_OPT_RealVNC="   -encodings         hextile  -truecolour  -shared "
	[ -z "${VNCVIEWER_OPT_RealVNC4}" ]&&VNCVIEWER_OPT_RealVNC4="  -PreferredEncoding hextile  -fullcolour  -shared "
	[ -z "${VNCVIEWER_OPT_TigerVNC}" ]&&VNCVIEWER_OPT_TigerVNC="  -PreferredEncoding hextile  -fullcolour  -shared "
	[ -z "${VNCVIEWER_OPT_TightVNC}" ]&&VNCVIEWER_OPT_TightVNC="  -encodings         hextile  -truecolour  -shared "
	[ -z "${VNCVIEWER_OPT_GENERIC}" ]&&VNCVIEWER_OPT_GENERIC=""

        #vncserver - passed through by wrapper
	VNCSERVER_NATIVE=${VNCSERVER_NATIVE:-$VNCSEXE}
	[ -z "${VNCSERVER_OPT_RealVNC}" ]&&VNCSERVER_OPT_RealVNC="   -depth 24 -geometry 1268x994 -localhost  "
	[ -z "${VNCSERVER_OPT_RealVNC4}" ]&&VNCSERVER_OPT_RealVNC4="  -depth 24 -geometry 1268x994 -localhost  "

        #work-around for broken path
	case $MYREL in
	    5.0)
		[ -z "${VNCSERVER_OPT_RealVNC4}" ]&&VNCSERVER_OPT_RealVNC4="${VNCSERVER_OPT_RealVNC4} -fp /usr/share/font/X11/misc"
		;;
	esac

	[ -z "${VNCSERVER_OPT_TigerVNC}" ]&&VNCSERVER_OPT_TigerVNC="   -depth 24 -geometry 1268x994 -localhost -nolisten tcp "
	[ -z "${VNCSERVER_OPT_TightVNC}" ]&&VNCSERVER_OPT_TightVNC="  -depth 24 -geometry 1268x994 -localhost -nolisten tcp "
	[ -z "${VNCSERVER_OPT_GENERIC}" ]&&VNCSERVER_OPT_GENERIC="   -depth 24 -geometry 1268x994 -localhost -nolisten tcp "
	;;
    Ubuntu)
	[ -z "$VNCVEXE" ]&&VNCVEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vncviewer /usr/bin`
	[ -z "$VNCSEXE" ]&&VNCSEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vncserver /usr/bin`
	[ -z "$VNCPEXE" ]&&VNCPEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vncpasswd /usr/bin`

        #vncviewer - passed through by wrapper
	VNCVIEWER_NATIVE=${VNCVIEWER_NATIVE:-$VNCVEXE}
	[ -z "${VNCVIEWER_OPT_RealVNC}" ]&&VNCVIEWER_OPT_RealVNC="    -encodings         hextile  -truecolour  -shared "
	[ -z "${VNCVIEWER_OPT_RealVNC4}" ]&&VNCVIEWER_OPT_RealVNC4="  -PreferredEncoding hextile   -fullcolour  -shared "
	[ -z "${VNCVIEWER_OPT_TigerVNC}" ]&&VNCVIEWER_OPT_TigerVNC="  -PreferredEncoding hextile   -fullcolour  -shared "
	[ -z "${VNCVIEWER_OPT_TightVNC}" ]&&VNCVIEWER_OPT_TightVNC="   -encodings         hextile  -truecolour  -shared "
	[ -z "${VNCVIEWER_OPT_GENERIC}" ]&&VNCVIEWER_OPT_GENERIC=""

        #vncserver - passed through by wrapper
	VNCSERVER_NATIVE=${VNCSERVER_NATIVE:-$VNCSEXE}
	[ -z "${VNCSERVER_OPT_RealVNC4}" ]&&VNCSERVER_OPT_RealVNC4="   -depth 24 -geometry 1268x994 -localhost  "
	[ -z "${VNCSERVER_OPT_RealVNC}" ]&&VNCSERVER_OPT_RealVNC="    -depth 24 -geometry 1268x994 -localhost  "
	[ -z "${VNCSERVER_OPT_TigerVNC}" ]&&VNCSERVER_OPT_TigerVNC="   -depth 24 -geometry 1268x994 -localhost "
	[ -z "${VNCSERVER_OPT_TightVNC}" ]&&VNCSERVER_OPT_TightVNC="   -depth 24 -geometry 1268x994 -localhost "
	[ -z "${VNCSERVER_OPT_GENERIC}" ]&&VNCSERVER_OPT_GENERIC="    -depth 24 -geometry 1268x994 -localhost  "
# 	VNCSERVER_OPT_TightVNC="   -depth 24 -geometry 1268x994 -localhost -nolisten tcp "
# 	VNCSERVER_OPT_GENERIC="    -depth 24 -geometry 1268x994 -localhost -nolisten tcp "
	;;
    Mandriva)
	[ -z "$VNCVEXE" ]&&VNCVEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vncviewer /usr/bin`
	[ -z "$VNCSEXE" ]&&VNCSEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vncserver /usr/bin`
	[ -z "$VNCPEXE" ]&&VNCPEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vncpasswd /usr/bin`

        #vncviewer - passed through by wrapper
	VNCVIEWER_NATIVE=${VNCVIEWER_NATIVE:-$VNCVEXE}
	[ -z "${VNCVIEWER_OPT_RealVNC4}" ]&&VNCVIEWER_OPT_RealVNC4="    -PreferredEncoding hextile  -FullColour -AutoSelect=0 -Shared=1 "
	[ -z "${VNCVIEWER_OPT_RealVNC}" ]&&VNCVIEWER_OPT_RealVNC="     -PreferredEncoding hextile  -FullColour -AutoSelect=0 -Shared=1 "
	[ -z "${VNCVIEWER_OPT_TigerVNC}" ]&&VNCVIEWER_OPT_TigerVNC="    -PreferredEncoding hextile  -FullColour -AutoSelect=0 -Shared=1 "
	[ -z "${VNCVIEWER_OPT_TightVNC}" ]&&VNCVIEWER_OPT_TightVNC="    -encodings         hextile  -truecolour  -shared "
	[ -z "${VNCVIEWER_OPT_GENERIC}" ]&&VNCVIEWER_OPT_GENERIC=""

        #vncserver - passed through by wrapper
	VNCSERVER_NATIVE=${VNCSERVER_NATIVE:-$VNCSEXE}
	[ -z "${VNCSERVER_OPT_RealVNC4}" ]&&VNCSERVER_OPT_RealVNC4="    -depth 24 -geometry 1268x994 -localhost -nolisten tcp -nohttpd "
	[ -z "${VNCSERVER_OPT_RealVNC}" ]&&VNCSERVER_OPT_RealVNC="     -depth 24 -geometry 1268x994 -localhost -nolisten tcp -nohttpd "
	[ -z "${VNCSERVER_OPT_TigerVNC}" ]&&VNCSERVER_OPT_TigerVNC="   -depth 24 -geometry 1268x994 -localhost -nolisten tcp "
	[ -z "${VNCSERVER_OPT_TightVNC}" ]&&VNCSERVER_OPT_TightVNC="    -depth 24 -geometry 1268x994 -localhost -nolisten tcp "
	[ -z "${VNCSERVER_OPT_GENERIC}" ]&&VNCSERVER_OPT_GENERIC="     -depth 24 -geometry 1268x994 -localhost -nolisten tcp "
	;;
    MeeGo)
	[ -z "$VNCVEXE" ]&&VNCVEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vncviewer /usr/bin`
	[ -z "$VNCSEXE" ]&&VNCSEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vncserver /usr/bin`
	[ -z "$VNCPEXE" ]&&VNCPEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vncpasswd /usr/bin`

        #vncviewer - passed through by wrapper
	VNCVIEWER_NATIVE=${VNCVIEWER_NATIVE:-$VNCVEXE}
	[ -z "${VNCVIEWER_OPT_RealVNC4}" ]&&VNCVIEWER_OPT_RealVNC4="   -PreferredEncoding hextile  -FullColour -AutoSelect=0 -Shared=1 "
	[ -z "${VNCVIEWER_OPT_RealVNC}" ]&&VNCVIEWER_OPT_RealVNC="    -PreferredEncoding hextile  -FullColour -AutoSelect=0 -Shared=1 "
	[ -z "${VNCVIEWER_OPT_TigerVNC}" ]&&VNCVIEWER_OPT_TigerVNC="   -PreferredEncoding hextile  -FullColour -AutoSelect=0 -Shared=1 "
	[ -z "${VNCVIEWER_OPT_TightVNC}" ]&&VNCVIEWER_OPT_TightVNC="   -encodings         hextile  -truecolour  -shared "
	[ -z "${VNCVIEWER_OPT_GENERIC}" ]&&VNCVIEWER_OPT_GENERIC=""

        #vncserver - passed through by wrapper
	VNCSERVER_NATIVE=${VNCSERVER_NATIVE:-$VNCSEXE}
	[ -z "${VNCSERVER_OPT_RealVNC4}" ]&&VNCSERVER_OPT_RealVNC4="   -depth 24 -geometry 1268x994 -localhost -nolisten tcp -nohttpd "
	[ -z "${VNCSERVER_OPT_RealVNC}" ]&&VNCSERVER_OPT_RealVNC="    -depth 24 -geometry 1268x994 -localhost -nolisten tcp -nohttpd "
	[ -z "${VNCSERVER_OPT_TigerVNC}" ]&&VNCSERVER_OPT_TigerVNC="   -depth 24 -geometry 1268x994 -localhost -nolisten tcp "
	[ -z "${VNCSERVER_OPT_TightVNC}" ]&&VNCSERVER_OPT_TightVNC="   -depth 24 -geometry 1268x994 -localhost -nolisten tcp "
	[ -z "${VNCSERVER_OPT_GENERIC}" ]&&VNCSERVER_OPT_GENERIC="    -depth 24 -geometry 1268x994 -localhost -nolisten tcp "
	;;
    *)
	[ -z "$VNCVEXE" ]&&VNCVEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vncviewer /usr/bin`
	[ -z "$VNCSEXE" ]&&VNCSEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vncserver /usr/bin`
	[ -z "$VNCPEXE" ]&&VNCPEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vncpasswd /usr/bin`

        #vncviewer - passed through by wrapper
	VNCVIEWER_NATIVE=${VNCVIEWER_NATIVE:-$VNCVEXE}
	[ -z "${VNCVIEWER_OPT_RealVNC4}" ]&&VNCVIEWER_OPT_RealVNC4="    -PreferredEncoding hextile  -FullColour -AutoSelect=0 -Shared=1 "
	[ -z "${VNCVIEWER_OPT_RealVNC}" ]&&VNCVIEWER_OPT_RealVNC="     -PreferredEncoding hextile  -FullColour -AutoSelect=0 -Shared=1 "
	[ -z "${VNCVIEWER_OPT_TigerVNC}" ]&&VNCVIEWER_OPT_TigerVNC="    -PreferredEncoding hextile  -FullColour -AutoSelect=0 -Shared=1 "
	[ -z "${VNCVIEWER_OPT_TightVNC}" ]&&VNCVIEWER_OPT_TightVNC="    -encodings         hextile  -truecolour  -shared "
	[ -z "${VNCVIEWER_OPT_GENERIC}" ]&&VNCVIEWER_OPT_GENERIC=""

        #vncserver - passed through by wrapper
	VNCSERVER_NATIVE=${VNCSERVER_NATIVE:-$VNCSEXE}
	[ -z "${VNCSERVER_OPT_RealVNC4}" ]&&VNCSERVER_OPT_RealVNC4="    -depth 24 -geometry 1268x994 -localhost -nolisten tcp -nohttpd "
	[ -z "${VNCSERVER_OPT_RealVNC}" ]&&VNCSERVER_OPT_RealVNC="     -depth 24 -geometry 1268x994 -localhost -nolisten tcp -nohttpd "
	[ -z "${VNCSERVER_OPT_TigerVNC}" ]&&VNCSERVER_OPT_TigerVNC="   -depth 24 -geometry 1268x994 -localhost -nolisten tcp "
	[ -z "${VNCSERVER_OPT_TightVNC}" ]&&VNCSERVER_OPT_TightVNC="    -depth 24 -geometry 1268x994 -localhost -nolisten tcp "
	[ -z "${VNCSERVER_OPT_GENERIC}" ]&&VNCSERVER_OPT_GENERIC="     -depth 24 -geometry 1268x994 -localhost -nolisten tcp "
	;;
esac



#
#For products with combined start the server-wait+client-wait is performed.
#
#Timeout after execution of client/server.
VNC_INIT_WAITC=${VNC_INIT_WAITC:-1}
VNC_INIT_WAITS=${VNC_INIT_WAITS:-2}

