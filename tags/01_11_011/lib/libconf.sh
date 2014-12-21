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
# Copyright (C) 2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################




#FUNCBEG###############################################################
#NAME:
#  getConfFilesList
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  First wins.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Name of "ID" or "PNAME" containing the configuration.
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function getConfFilesList () {
    local fx=;
    for i in "${1%.vdi}.ctys" "${1%.*}.vmx" "${1%.*}.conf" "${1%.*}.ctys" "${1%/*}.ctys" "${CTYSCONF}";do
        [ ! -f "$i" ]&&continue;
	fx="${fx} ${i}"
    done
    echo "${fx}"
}


