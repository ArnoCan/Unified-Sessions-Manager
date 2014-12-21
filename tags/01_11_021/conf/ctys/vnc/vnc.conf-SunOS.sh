#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@users.sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_06_001a11
#
########################################################################
#
# Copyright (C) 2008 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
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

printDBG $S_CONF  ${D_FRAME} $LINENO $BASH_SOURCE "LOAD-CONFIG:${BASH_SOURCE}"

################################################################
#    Default definitions - User-Customizable  from shell       #
################################################################

export VNC_BASEPORT=${VNC_BASEPORT:-5900}
export VNCACCESSPORT;
export VNCACCESSDISPLAY;

#avoids race conditions "lazy release vs. hungry allocation"
VNCPORTSEED=10;


[ -z "${VNCVEXE// /}" ]&&VNCVEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vncviewer /opt/sfw/bin`
[ -z "${VNCVEXE// /}" ]&&VNCVEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vncviewer /usr/bin`

[ -z "${VNCSEXE// /}" ]&&VNCSEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vncserver /opt/sfw/bin`
[ -z "${VNCSEXE// /}" ]&&VNCSEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vncserver /usr/bin`

[ -z "${VNCPEXE// /}" ]&&VNCPEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vncpasswd /opt/sfw/bin`
[ -z "${VNCPEXE// /}" ]&&VNCPEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT vncpasswd /usr/bin`

#vncviewer - passed through by wrapper
VNCVIEWER_NATIVE=${VNCVIEWER_NATIVE:-$VNCVEXE}
VNCVIEWER_OPT_GENERIC=""

VNCVIEWER_OPT_TightVNC=" -encodings          hextile  -truecolour  -shared "

case ${MYDIST} in
    SunOS)
	VNCVIEWER_OPT_RealVNC=" -encodings          hextile  -truecolour  -shared "
	;;
    OpenSolaris)
	VNCVIEWER_OPT_RealVNC=" -PreferredEncoding  hextile  -fullcolour  -shared "
	;;
esac

#vncserver - passed through by wrapper
VNCSERVER_NATIVE=${VNCSERVER_NATIVE:-$VNCSEXE}
VNCSERVER_OPT_RealVNC=" -depth 24 -geometry 1268x994  "
VNCSERVER_OPT_TightVNC="-depth 24 -geometry 1268x994 -localhost -nolisten tcp "
VNCSERVER_OPT_GENERIC=" -depth 24 -geometry 1268x994 -localhost -nolisten tcp "

VNC_INIT_WAITC=${VNC_INIT_WAITC:-1}
VNC_INIT_WAITS=${VNC_INIT_WAITS:-2}
