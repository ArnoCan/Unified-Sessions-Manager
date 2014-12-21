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

printDBG $S_CONF  ${D_FRAME} $LINENO $BASH_SOURCE "LOAD-CONFIG:${BASH_SOURCE}"


#Default shell to be used for execution
[ -z "$C_CLI_DEFAULT" ]&&C_CLI_DEFAULT="${CLIEXE} -l -i"

CLI_SHELL_DEFAULT="${CLIEXE} -i";
CLI_SHELL_CMD_DEFAULT="${CLIEXE} -c";

