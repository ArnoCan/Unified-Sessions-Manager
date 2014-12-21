#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_11_005
#
########################################################################
#
# Copyright (C) 2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

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

printDBG $S_CONF  ${D_FRAME} $LINENO $BASH_SOURCE "LOAD-CONFIG:${BASH_SOURCE}"

################################################################
#    Default definitions - User-Customizable  from shell       #
################################################################

export RDP_BASEPORT=${RDP_BASEPORT:-3000}
export RDPACCESSPORT;
export RDPACCESSDISPLAY;

#avoids race conditions "lazy release vs. hungry allocation"
RDPPORTSEED=10;

#
case ${MYDIST} in
    ESX)
	#rdesktop
	[ -z "$RDPRDESK" ]&&RDPRDESK=`getPathName $LINENO $BASH_SOURCE WARNINGEXT rdesktop /usr/bin`
	RDPRDESK_NATIVE=${RDPRDESK_NATIVE:-$RDPRDESK}
	RDPRDESK_OPT=""
	RDPRDESK_OPT_GENERIC=""

	#tsclient
# 	[ -z "$RDPTSC" ]&&RDPTSC=`getPathName $LINENO $BASH_SOURCE WARNINGEXT tsclient /usr/bin`
# 	RDPTSC_NATIVE=${RDPTSC_NATIVE:-$RDPTSC}
# 	RDPTSC_OPT=""
# 	RDPTSC_OPT_GENERIC=""
	;;

    XenServer)
	#rdesktop
	[ -z "$RDPRDESK" ]&&RDPRDESK=`getPathName $LINENO $BASH_SOURCE WARNINGEXT rdesktop /usr/bin`
	RDPRDESK_NATIVE=${RDPRDESK_NATIVE:-$RDPRDESK}
	RDPRDESK_OPT=""
	RDPRDESK_OPT_GENERIC=""

	#tsclient
# 	[ -z "$RDPTSC" ]&&RDPTSC=`getPathName $LINENO $BASH_SOURCE WARNINGEXT tsclient /usr/bin`
# 	RDPTSC_NATIVE=${RDPTSC_NATIVE:-$RDPTSC}
# 	RDPTSC_OPT=""
# 	RDPTSC_OPT_GENERIC=""
	;;

    CentOS)
	#rdesktop
	[ -z "$RDPRDESK" ]&&RDPRDESK=`getPathName $LINENO $BASH_SOURCE WARNINGEXT rdesktop /usr/bin`
	RDPRDESK_NATIVE=${RDPRDESK_NATIVE:-$RDPRDESK}
	RDPRDESK_OPT=""
	RDPRDESK_OPT_GENERIC=""

	#tsclient
# 	[ -z "$RDPTSC" ]&&RDPTSC=`getPathName $LINENO $BASH_SOURCE WARNINGEXT tsclient /usr/bin`
# 	RDPTSC_NATIVE=${RDPTSC_NATIVE:-$RDPTSC}
# 	RDPTSC_OPT=""
# 	RDPTSC_OPT_GENERIC=""
	;;


    MeeGo)
	#rdesktop
	[ -z "$RDPRDESK" ]&&RDPRDESK=`getPathName $LINENO $BASH_SOURCE WARNINGEXT rdesktop /usr/bin`
	RDPRDESK_NATIVE=${RDPRDESK_NATIVE:-$RDPRDESK}
	RDPRDESK_OPT=""
	RDPRDESK_OPT_GENERIC=""

	#tsclient
# 	[ -z "$RDPTSC" ]&&RDPTSC=`getPathName $LINENO $BASH_SOURCE WARNINGEXT tsclient /usr/bin`
# 	RDPTSC_NATIVE=${RDPTSC_NATIVE:-$RDPTSC}
# 	RDPTSC_OPT=""
# 	RDPTSC_OPT_GENERIC=""
	;;


#     EnterpriseLinux)
# 	;;
#     Scientific)
# 	;;
#     Fedora)
# 	;;
#     SuSE)
# 	;;
#     openSUSE)
# 	;;
    debian)
	#rdesktop
	[ -z "$RDPRDESK" ]&&RDPRDESK=`getPathName $LINENO $BASH_SOURCE WARNINGEXT rdesktop /usr/bin`
	RDPRDESK_NATIVE=${RDPRDESK_NATIVE:-$RDPRDESK}
	RDPRDESK_OPT=""
	RDPRDESK_OPT_GENERIC=""

	#tsclient
# 	[ -z "$RDPTSC" ]&&RDPTSC=`getPathName $LINENO $BASH_SOURCE WARNINGEXT tsclient /usr/bin`
# 	RDPTSC_NATIVE=${RDPTSC_NATIVE:-$RDPTSC}
# 	RDPTSC_OPT=""
# 	RDPTSC_OPT_GENERIC=""
	;;
#     Ubuntu)
# 	;;
#     Mandriva)
# 	;;
    *)
	#rdesktop
	[ -z "$RDPRDESK" ]&&RDPRDESK=`getPathName $LINENO $BASH_SOURCE WARNINGEXT rdesktop /usr/bin`
	RDPRDESK_NATIVE=${RDPRDESK_NATIVE:-$RDPRDESK}
	RDPRDESK_OPT=""
	RDPRDESK_OPT_GENERIC=""

	#tsclient
# 	[ -z "$RDPTSC" ]&&RDPTSC=`getPathName $LINENO $BASH_SOURCE WARNINGEXT tsclient /usr/bin`
# 	RDPTSC_NATIVE=${RDPTSC_NATIVE:-$RDPTSC}
# 	RDPTSC_OPT=""
# 	RDPTSC_OPT_GENERIC=""
	;;
esac



#
#For products with combined start the server-wait+client-wait is performed.
#
#Timeout after execution of client/server.
RDP_INIT_WAITC=${RDP_INIT_WAITC:-1}
RDP_INIT_WAITS=${RDP_INIT_WAITS:-2}

