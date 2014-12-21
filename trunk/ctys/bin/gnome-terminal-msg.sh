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


echo "*******************************************************************"
echo "*                                                                 *"
echo "* Keep the default use of RUN-IN-TERM-MODE for start of logins    *"
echo "* in current version!!!                                           *"
echo "* -> desktop-file:\"Terminal=true\"                               *"
echo "*                                                                 *"
echo "* Otherwise the GUI may hang, when a remote SSH password is       *"
echo "* requested by OpenSSH command line. This is due to missing       *"
echo "* terminal session when no terminal is present.                   *"
echo "*                                                                 *"
echo "* Is going to be reworked soon.                                   *"
echo "*                                                                 *"
echo "******************************************************************"
