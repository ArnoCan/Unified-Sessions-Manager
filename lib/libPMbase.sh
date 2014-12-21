#!/bin/bash

########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_10_008
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
#
#Requires the ctys framework, at least
#
#  <bin>/bootstrap/bootstrap<version>
#  <lib>/base.h
#
#
#
#


#FUNCBEG###############################################################
#NAME:
#  getACCELLERATOR_PM
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function getACCELLERATOR_PM () {
    case ${MYOS} in
	Linux)
	    cat /proc/cpuinfo|\
            sed -n 's/\t//g;s/^\([^[:space:]]*[[:space:]]\{0,2\}[^[:space:]]*\)[[:space:]]*: *\(.*\)$/\1:\2/gp'|\
            awk -F':' '
              BEGIN{
                 _processor=0
                 _flags="";
              }
              $2~/vmx/         {_flagsVMX=1;}
              $2~/svm/         {_flagsSVM=1;}
              $2~/pae/         {_flagsPAE=1;}
              END{
                 if(_flagsVMX==1||_flagsSVM==1){
                   printf("HVM");
                 }else{
                   printf("PARA");
                 }
              }
              '
            ;;
       	*)
	    ;;
    esac
}


