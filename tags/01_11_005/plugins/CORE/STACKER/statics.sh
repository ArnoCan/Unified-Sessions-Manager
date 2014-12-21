#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_06_001a13
#
########################################################################
#
# Copyright (C) 2007 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################












#FUNCBEG###############################################################
#NAME:
#  stackerCheckStatics
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#-performs dynamic checksk
#
#-first does a static pre-check, requires local cacheDB
# could be forced to operate by optimistic-scan
#
#-checks whether it is a compatible, thus accessible stack
#-checks whether remaining CAPABILITIES match REQUIREMENT.
#
#
#
#
#EXAMPLE:
#
#PARAMETERS:
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function stackerCheckStatics () {
    printDBG $S_CORE ${D_FRAME} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=${@}"
    return
}
