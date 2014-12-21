#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_09_001
#
########################################################################
#
# Copyright (C) 2007,2008 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
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


[ -z "$X11XAUTH" ]&&X11XAUTH=`getPathName $LINENO $BASH_SOURCE WARNINGEXT xauth /usr/X11R6/bin`
[ -z "$XORGCFG_DEFAULT" ]&&XORGCFG_DEFAULT=/etc/X11/xorg.conf


[ -z "$X11EXE" ]&&X11EXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT X /usr/X11R6/bin`


[ -z "$X11MWMEXE" ]&&X11MWMEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT mwm /usr/X11R6/bin`
[ -z "$X11GDMEXE" ]&&X11GDMEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT gdm /usr/X11R6/bin`
[ -z "$X11KDMEXE" ]&&X11KDMEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT kdm /usr/X11R6/bin`
[ -z "$X11KDECONFEXE" ]&&X11KDECONFEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT kde-config /usr/X11R6/bin`
[ -z "$X11FVWMEXE" ]&&X11FVWMEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT fvwm /usr/X11R6/bin`
[ -z "$X11XFCE4EXE" ]&&X11XFCE4EXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT startxfce4 /usr/X11R6/bin`
[ -z "$X11XFCE4SESEXE" ]&&X11XFCE4SESEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT xfce4-session /usr/X11R6/bin`

[ -z "$X11XTERMEXE" ]&&X11XTERMEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT xterm /usr/X11R6/bin`
[ -z "$X11GTERMEXE" ]&&X11GTERMEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT gnome-terminal /usr/X11R6/bin`
[ -z "$X11EMACXEXE" ]&&X11EMACXEXE=`getPathName $LINENO $BASH_SOURCE WARNINGEXT emacs /usr/X11R6/bin`


if [ -n "$X11EMACXEXE" ];then
    X11EMACSVERS=`${X11EMACXEXE} -version 2>&1|awk '/GNU Emacs/&&$3~/[0-9.]/{print $3}'`
fi


X11_DEFAULT_OPTS="${X11_DEFAULT_OPTS}";
X11_DEFAULT_OPTS_GTERM="${X11_DEFAULT_OPTS_GTERM}";
X11_DEFAULT_OPTS_XTERM="${X11_DEFAULT_OPTS_XTERM:- -sb -bg white -fg black}";

gwhich gnome-terminal 2>/dev/null >/dev/null
if [ $? == 0 ];then
    X11_XTERM_DEFAULT="gnome-terminal ";
    X11_WM_OPTPRE="--";
else
    X11_XTERM_DEFAULT="xterm ";
    X11_WM_OPTPRE="-";
fi

X11_XTERM_SHELL_DEFAULT="${X11_XTERM_SHELL_DEFAULT:-$CLI_SHELL_DEFAULT}";
X11_XTERM_SHELL_DEFAULT="${X11_XTERM_SHELL_DEFAULT:-$CLIEXE}";

