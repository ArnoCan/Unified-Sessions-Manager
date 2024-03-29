#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@users.sourceforge.net
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


_myLIBNAME_geometry="${BASH_SOURCE}"
_myLIBVERS_geometry="01.07.001b06"
libManInfoAdd "${_myLIBNAME_geometry}" "${_myLIBVERS_geometry}"

export _myLIBBASE_geometry="`dirname ${_myLIBNAME_geometry}`"


#FUNCBEG###############################################################
#NAME:
#  getScreenOffset
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Reads by default from "/etc/X11/xorg.conf" or from any other when 
#  given, the Screen-Label, xoffset, and yoffset for given ServerLayout
#  and screen, where screen could be given by it's index or label.
#
#ATTENTION:
#  SPECIAL REQUIREMENT:
#   Current implementation requires "Identifier" as first
#   entry in LayoutSections
#
#EXAMPLE:
#
#  XORGCFG=${1:-$XORGCFG_DEFAULT}
#  DEBUG=1
#
#  echo
#  echo "Layout[all] Screen0 -> $XORGCFG"
#  getScreenOffset $DEBUG "Layout[all]" "Screen0" 0 $XORGCFG
#  echo "ret=$?"
#  echo
#
#PARAMETERS:
#
# $1: DEBUG:        0=on, else off
# $2: SECTIONNAME:  Literal name of LayoutSection to use, if empty first is taken.
# $3: SCREENALIAS:  Literal name of Screen section (used in LayoutSection), if
#                   empty SCREENNR is used
# $4: SCREENNR:     Index number of screen, if SCREENALIAS given, this will be 
#                   ignored. Range is (0<=N)
# $5: XORGCFG:      Pathname to be used as configuration file for Xorg data, 
#                   if empty default is used(XORGCFG_DEFAULT).
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#    "%s %d %d", $3, $4, $5
#      $3: Screen label from xorg.conf
#      $4: xoffset
#      $5: yoffset
#  
#FUNCEND###############################################################
function getScreenOffset () {
  local XORGCFG=${5:-$XORGCFG_DEFAULT}
  XORGCFG=${XORGCFG:-/etc/X11/xorg.conf}
  local D=$1
  cat ${XORGCFG}|\
    sed 's/"//g'|\
    awk -v d="$D" -v sect="${2}" -v nr="${4}" -v alias="${3}" -f ${_myLIBBASE_geometry}/geometry01.awk
}
export -f getScreenOffset





#FUNCBEG###############################################################
#NAME:
#  expandGeometry
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#
#
# Reminder/hints:
#   C_GEOMETRY=`expandGeometry "${OPTARG}"`;
#   "<x-size>x<y-size>[[+,-]<x-offset>[+,-]<y-offset>]"
#   "<x-size>x<y-size>[:[<ScreenSection>|<ScreenIndex>][:[ServerLayout:]]]
#
#EXAMPLE:
# Test-Examples:
# -standard:xorg.conf
#   "500x500"
#   "500x500:Screen4"
#   "500x500:5:Layout[all]"
#   "500x500:Screen6:Layout[all]"
#
# -custom:xorg.conf
#   "400x400"
#   "400x400:Screen3"
#   "400x400:4:Layout[0,1]"
#   "400x400:Screen5:Layout[0,1]"
#
#PARAMETERS:
#
# $1: DEBUG:       
#     0=on, else off
# $2: GEOMETRYX:    
#     Extended geometry option.
#
#         <geometry>=<x-size>x<y-size>+<xoffset>+<yoffset>
#
#       or the positioning relevant part of 
#
#        <geometryExtended>=
#          <geometry>
#          [:[<ScreenSection>|<ScreenIndex>]
#            [:[ServerLayout]
#              [:[alternateConfigFile]
#              ]
#            ]
#          ]
#
# $3: Config file.
#     Default:/etc/X11/xorg.conf
#     This parameter is for kept for historical reasons, if defined
#     $2 has priority.
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#    As appropriate to given result:
#
#         <xsize>
#      or <xsize>x<ysize>
#      or <xsize>x<ysize>+<xoffset>
#      or <xsize>x<ysize>+<xoffset>+<yoffset>
#
#FUNCEND###############################################################
function expandGeometry () {
  local XORGCFG=${3:-/etc/X11/xorg.conf}
  local D=$1
  local myGeomX=$2;
  local myConfFile=${myGeomX#*:*:*:}
  if [ "$myConfFile" != "${myGeomX}" ];then
      XORGCFG=$myConfFile
      myGeomX=${myGeomX%:*}
  fi

  #for misbahaviour of "%%"
  myGeomX=${myGeomX%%:}
  myGeomX=${myGeomX%%:}
  myGeomX=${myGeomX%%:}

  printDBG $S_LIB ${D_DATA} $LINENO $BASH_SOURCE "$FUNCNAME $*"
  echo ${myGeomX}|\
    awk -F':'  -v d="${D}" -v xorgconf=${XORGCFG} -f ${_myLIBBASE_geometry}/geometry02.awk
}


#getScreenSize
#getScreenOffset
